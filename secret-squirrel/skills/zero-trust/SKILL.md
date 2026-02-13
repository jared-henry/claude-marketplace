---
description: Encrypt and decrypt skill trees using a YubiKey-derived symmetric key (HMAC-SHA1 + OpenSSL AES-256). Manages provisioning, encryption, decryption, and status of zero-trust protected skills.
disable-model-invocation: true
argument-hint: "[provision | encrypt <skill-name> | decrypt <skill-name> | lock | status]"
allowed-tools: Bash(ykman *), Bash(ykchalresp *), Bash(openssl *), Bash(rm *), Bash(chmod *), Bash(diff *), Read, Write, Edit, Glob, Grep, AskUserQuestion
---

# Zero Trust — YubiKey-Encrypted Skill Trees

You are managing encrypted skills using a YubiKey HMAC-SHA1 challenge-response key and OpenSSL AES-256-CBC encryption.

## How It Works

1. A shared HMAC-SHA1 secret is programmed into OTP slot 2 on one or more YubiKeys
2. A fixed challenge string (`zero-trust-skill-key-v1`) is sent to the YubiKey
3. The YubiKey returns a deterministic 20-byte HMAC response (requires physical touch)
4. That response is used as the passphrase for `openssl enc -aes-256-cbc -pbkdf2`
5. Encrypted skills are stored as `SKILL.md.enc` — plaintext `SKILL.md` only exists when unlocked

The `SessionStart` hook auto-decrypts if a YubiKey is present. The `SessionEnd` hook removes plaintext.

## Deriving the Passphrase

All encrypt/decrypt operations start with this:

```bash
# Convert challenge to hex and get HMAC response from YubiKey (touch required)
CHALLENGE_HEX=$(printf 'zero-trust-skill-key-v1' | xxd -p | tr -d '\n')
PASSPHRASE=$(ykchalresp -2 "$CHALLENGE_HEX" 2>/dev/null || ykman otp calculate 2 "$CHALLENGE_HEX" 2>/dev/null)
```

Tell the user to **touch their YubiKey** before running this.

## Commands

Parse `$ARGUMENTS` to determine which operation to perform.

### `provision`

Program the HMAC-SHA1 secret onto a YubiKey's OTP slot 2. This is a **one-time setup per YubiKey**.

1. Ask the user to plug in the YubiKey they want to provision
2. Verify the YubiKey is detected: `ykman info`
3. Check if OTP slot 2 is already configured: `ykman -r '' otp info`
   - If slot 2 is already programmed, warn the user and ask if they want to overwrite
4. Ask if this is the **first key** (generate new secret) or an **additional key** (use existing secret):

**First key:**
```bash
# Generate a random 20-byte HMAC secret
SECRET=$(openssl rand -hex 20)
echo "SECRET: $SECRET"
echo "SAVE THIS — you need it to provision additional YubiKeys."
echo "Destroy it after all keys are programmed."

# Program onto slot 2 (user must touch YubiKey)
ykman -r '' otp chalresp --touch --force 2 $SECRET
```

**Additional key:**
- Ask the user to provide the hex secret from the first provisioning
```bash
ykman -r '' otp chalresp --touch --force 2 <hex-secret>
```

5. Verify the key works by deriving a response (tell user to touch):
```bash
CHALLENGE_HEX=$(printf 'zero-trust-skill-key-v1' | xxd -p | tr -d '\n')
ykchalresp -2 "$CHALLENGE_HEX"
```

6. If this is an additional key, verify the response matches the first key's response

7. Tell the user: **destroy the plaintext secret** once all keys are provisioned. It now lives only on the YubiKey hardware.

### `encrypt <skill-name>`

Encrypt a skill's SKILL.md file.

1. Locate the skill: look for `skills/<skill-name>/SKILL.md` in the secret-squirrel plugin directory
2. Verify the file exists and is not already encrypted (no `.enc` file alongside it)
3. Derive the passphrase from the YubiKey (tell user to touch):
```bash
CHALLENGE_HEX=$(printf 'zero-trust-skill-key-v1' | xxd -p | tr -d '\n')
PASSPHRASE=$(ykchalresp -2 "$CHALLENGE_HEX")
```
4. Encrypt:
```bash
openssl enc -aes-256-cbc -pbkdf2 -salt \
    -in skills/<skill-name>/SKILL.md \
    -out skills/<skill-name>/SKILL.md.enc \
    -pass "pass:$PASSPHRASE"
```
5. Verify round-trip decryption works:
```bash
openssl enc -aes-256-cbc -pbkdf2 -d \
    -in skills/<skill-name>/SKILL.md.enc \
    -pass "pass:$PASSPHRASE" \
    | diff skills/<skill-name>/SKILL.md - > /dev/null
```
6. Remove the plaintext:
```bash
rm skills/<skill-name>/SKILL.md
```
7. Add the plaintext path to the plugin's `.gitignore`:
```bash
echo 'skills/<skill-name>/SKILL.md' >> .gitignore
```

Print a summary confirming the skill is encrypted.

### `decrypt <skill-name>`

Manually decrypt a specific skill (the SessionStart hook does this automatically).

1. Locate `skills/<skill-name>/SKILL.md.enc`
2. Derive the passphrase (tell user to touch):
```bash
CHALLENGE_HEX=$(printf 'zero-trust-skill-key-v1' | xxd -p | tr -d '\n')
PASSPHRASE=$(ykchalresp -2 "$CHALLENGE_HEX")
```
3. Decrypt:
```bash
openssl enc -aes-256-cbc -pbkdf2 -d \
    -in skills/<skill-name>/SKILL.md.enc \
    -out skills/<skill-name>/SKILL.md \
    -pass "pass:$PASSPHRASE"
```

### `lock`

Remove all decrypted plaintext, leaving only `.enc` files:

```bash
<plugin-root>/scripts/zero-trust.sh lock
```

### `status`

Show the lock/unlock state of all encrypted skills:

```bash
<plugin-root>/scripts/zero-trust.sh status
```

## Prerequisites

- **openssl**: pre-installed on macOS and Linux
- **ykman**: `brew install ykman` or `apt install yubikey-manager`
- **ykpers**: `brew install ykpers` (macOS) — provides `ykchalresp`, needed because macOS HID driver blocks `ykman otp calculate`
- **YubiKey 5 series** with OTP slot 2 available
- **xxd**: usually pre-installed (part of vim)

## Important Guidelines

- **Never commit plaintext SKILL.md** for encrypted skills — always verify `.gitignore` is updated
- **Never log or display the HMAC response** — it is the encryption passphrase
- **Tell the user to touch their YubiKey** before any `ykchalresp` or `ykman otp` command
- **The challenge string is fixed**: `zero-trust-skill-key-v1` — changing it would invalidate all encrypted files
- **Graceful degradation**: if no YubiKey is present, encrypted skills simply remain unavailable
- **The HMAC secret must be the same on all YubiKeys** for interchangeability
- **Use `ykman -r '' otp ...`** for programming commands — the `-r ''` reader override avoids macOS HID conflicts
