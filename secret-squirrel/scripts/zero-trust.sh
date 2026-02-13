#!/usr/bin/env bash
set -euo pipefail

# Zero Trust — Encrypt/decrypt skill trees using YubiKey HMAC-SHA1 + OpenSSL
#
# YubiKey OTP slot 2 holds an HMAC-SHA1 secret. A fixed challenge string
# produces a deterministic 20-byte response used as the encryption passphrase.
# The secret never leaves the hardware — only the derived response is used.
#
# Encryption: openssl enc -aes-256-cbc -pbkdf2 (works non-interactively)
# Extension: .enc (encrypted SKILL.md files)
#
# Usage:
#   zero-trust.sh unlock   — decrypt all .enc files (SessionStart hook)
#   zero-trust.sh lock     — remove decrypted plaintext (SessionEnd hook)
#   zero-trust.sh status   — show lock/unlock state of encrypted skills

CHALLENGE="zero-trust-skill-key-v1"
PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}"
SKILLS_DIR="$PLUGIN_ROOT/skills"

# Derive the encryption passphrase from the YubiKey HMAC-SHA1 response.
# Returns the hex response string on stdout.
# Uses ykchalresp (ykpers) on macOS because ykman otp calculate
# fails when the HID driver exclusively claims the OTP USB interface.
derive_passphrase() {
    local challenge_hex
    challenge_hex=$(printf '%s' "$CHALLENGE" | xxd -p | tr -d '\n')
    if command -v ykchalresp &>/dev/null; then
        ykchalresp -2 "$challenge_hex" 2>/dev/null
    else
        ykman otp calculate 2 "$challenge_hex" 2>/dev/null
    fi
}

# Find all encrypted skill files (.enc) under the skills directory.
find_encrypted() {
    find "$SKILLS_DIR" -name "SKILL.md.enc" -type f 2>/dev/null
}

unlock() {
    local enc_files
    enc_files=$(find_encrypted)
    if [ -z "$enc_files" ]; then
        exit 0  # nothing to decrypt
    fi

    if ! ykman info &>/dev/null; then
        exit 0  # no YubiKey, skip silently
    fi

    local passphrase
    passphrase=$(derive_passphrase) || exit 0  # challenge failed, skip

    while IFS= read -r enc_file; do
        local plain_file="${enc_file%.enc}"
        if [ ! -f "$plain_file" ]; then
            openssl enc -aes-256-cbc -pbkdf2 -d \
                -in "$enc_file" -out "$plain_file" \
                -pass "pass:$passphrase" 2>/dev/null || {
                printf '[zero-trust] Failed to decrypt: %s\n' "$enc_file" >&2
                rm -f "$plain_file"  # clean up partial output
            }
        fi
    done <<< "$enc_files"
}

lock() {
    local enc_files
    enc_files=$(find_encrypted)
    if [ -z "$enc_files" ]; then
        exit 0
    fi

    while IFS= read -r enc_file; do
        local plain_file="${enc_file%.enc}"
        if [ -f "$plain_file" ]; then
            rm -f "$plain_file"
        fi
    done <<< "$enc_files"
}

status() {
    local enc_files
    enc_files=$(find_encrypted)
    if [ -z "$enc_files" ]; then
        printf 'No encrypted skills found.\n'
        exit 0
    fi

    printf '%-30s %s\n' "SKILL" "STATUS"
    printf '%-30s %s\n' "-----" "------"
    while IFS= read -r enc_file; do
        local plain_file="${enc_file%.enc}"
        local skill_name
        skill_name=$(basename "$(dirname "$enc_file")")
        if [ -f "$plain_file" ]; then
            printf '%-30s UNLOCKED\n' "$skill_name"
        else
            printf '%-30s LOCKED\n' "$skill_name"
        fi
    done <<< "$enc_files"
}

case "${1:-}" in
    unlock)  unlock ;;
    lock)    lock ;;
    status)  status ;;
    *)
        printf 'Usage: zero-trust.sh {unlock|lock|status}\n' >&2
        exit 1
        ;;
esac
