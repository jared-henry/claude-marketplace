---
description: Test a bootstrap/install script in a Docker container for correctness and idempotency
disable-model-invocation: true
---

# Bootstrap Test

You are testing a bootstrap or installation script inside a Docker container to verify it works on a fresh system and is idempotent (safe to re-run).

## Prerequisites

- Docker must be running on the host machine
- The bootstrap script must exist in the target directory

## Procedure

### Step 1: Identify the target

Ask the user:
- Which bootstrap script to test (default: `./bootstrap.sh`)
- Which Docker image to use (default: `ubuntu:24.04`)
- Which directory contains the files to copy into the container
- Any environment variables needed (e.g., `TILDE_ALLOW_ROOT=1`)

### Step 2: Start a container

```bash
docker run --rm -d --name bootstrap-test <image> sleep infinity
```

### Step 3: Install prerequisites

Install the minimum packages needed to run the bootstrap script. Typically:

```bash
docker exec bootstrap-test bash -c "apt-get update -qq && apt-get install -y -qq git curl ca-certificates"
```

Adapt for the base image (e.g., `apk add` for Alpine, `dnf install` for Fedora).

### Step 4: Copy files into the container

Copy the project files into the appropriate location inside the container. For a home directory repo:

```bash
# Create directory structure first
docker exec bootstrap-test mkdir -p /root/<subdirs>
# Copy files
docker cp <local_path> bootstrap-test:<container_path>
```

**Important:** If the repo is private, you cannot `git clone` inside the container without credentials. Copy files directly instead.

### Step 5: Run #1 — Fresh install

Run the bootstrap script and capture all output:

```bash
docker exec bootstrap-test bash -c "<env_vars> /path/to/bootstrap.sh"
```

Check for:
- [ ] Exit code 0 (no errors)
- [ ] All expected packages installed
- [ ] All symlinks created and pointing to correct targets
- [ ] Generated config files have correct content (absolute paths, platform-specific values)
- [ ] File permissions are correct (600 for keys, 700 for .ssh, 755 for scripts)
- [ ] No unexpected warnings or errors in output

### Step 6: Verify state

Run verification commands inside the container:

```bash
docker exec bootstrap-test bash -c '
echo "=== Symlinks ==="
ls -la <expected symlink paths>

echo "=== Generated files ==="
cat <generated config files>

echo "=== Permissions ==="
stat -c "%a %n" <critical files>

echo "=== Config values ==="
git config --global --list
'
```

Report any discrepancies.

### Step 7: Run #2 — Idempotency test

Run the exact same bootstrap command again:

```bash
docker exec bootstrap-test bash -c "<env_vars> /path/to/bootstrap.sh"
```

Verify:
- [ ] Exit code 0
- [ ] Output shows "OK" / "already exists" / "already installed" for everything
- [ ] No files were backed up (no new backup directory created)
- [ ] No duplicate entries in append-mode files (e.g., known_hosts line count unchanged)
- [ ] Symlinks unchanged (same targets as after run #1)
- [ ] Generated files unchanged (not overwritten)

### Step 8: Cleanup

```bash
docker stop bootstrap-test
```

### Step 9: Report

Present results in a table:

| Check | Run #1 | Run #2 (idempotency) |
|-------|--------|---------------------|
| Exit code | ... | ... |
| Packages | ... | ... |
| Symlinks | ... | ... |
| Generated files | ... | ... |
| Permissions | ... | ... |
| Duplicates | N/A | ... |

If any check fails, provide the specific error output and suggest fixes.

## Notes

- For containers running as root, remind the user about any `ALLOW_ROOT` environment variables
- Symlink permissions always show 777 on Linux — check the **target** file permissions instead
- The container has no YubiKey access, so SSH/signing tests will not work inside it — that's expected
- If the bootstrap installs packages from external repos (Homebrew, GH CLI), expect network-dependent install times
