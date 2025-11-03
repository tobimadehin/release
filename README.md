# release.sh

A minimal, no-dependency Bash utility for managing semantic version releases in Git projects.

## Features
- Auto-bumps `major`, `minor`, or `patch` versions.
- Supports pre-releases (`--beta`).
- Cleans up stale or conflicting local tags (`--clean-tags`).
- Automatically updates package manager files (package.json, Cargo.toml, pyproject.toml, etc.).
- Works on any Git repository with zero setup.

---

## Quick Start

```bash
curl -fsSL https://raw.githubusercontent.com/tobimadehin/release/main/release.sh | bash
````

Run your first release:

```bash
curl -fsSL https://raw.githubusercontent.com/tobimadehin/release/main/release.sh | bash -s patch
```

Create a beta release:

```bash
curl -fsSL https://raw.githubusercontent.com/tobimadehin/release/main/release.sh | bash -s patch --beta
```

Clean up local tags before releasing:

```bash
curl -fsSL https://raw.githubusercontent.com/tobimadehin/release/main/release.sh | bash -s patch --clean-tags
```

---

## Example Workflows

**Patch release**

```bash
curl -fsSL https://raw.githubusercontent.com/tobimadehin/release/main/release.sh | bash patch
```

**Minor release**

```bash
curl -fsSL https://raw.githubusercontent.com/tobimadehin/release/main/release.sh | bash minor
```

**Major release**

```bash
curl -fsSL https://raw.githubusercontent.com/tobimadehin/release/main/release.sh | bash major
```

**Beta release sequence**

```bash
curl -fsSL https://raw.githubusercontent.com/tobimadehin/release/main/release.sh | bash patch --beta  # v1.2.3-beta.1
curl -fsSL https://raw.githubusercontent.com/tobimadehin/release/main/release.sh | bash patch --beta  # v1.2.3-beta.2
curl -fsSL https://raw.githubusercontent.com/tobimadehin/release/main/release.sh | bash patch         # v1.2.3 (final)
```

---

## Recommended GitHub Action

```yaml
name: Release Build
on:
  push:
    tags:
      - 'v*'

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Build project
        run: make build
```

---

## License

MIT License — see [LICENSE](LICENSE) for details.
