#!/bin/bash
#
# MIT License - Copyright (c) 2025 Emmanuel Madehin
# See LICENSE file for full license text
#
# release.sh - Version bump and release automation for Git projects
# Usage: ./release.sh [major|minor|patch] [--beta] [--clean-tags]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Utility functions
info()    { echo -e "${BLUE}[INFO]${NC} $1"; }
warn()    { echo -e "${YELLOW}[WARN]${NC} $1"; }
error()   { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }

# Parse arguments
BUMP_TYPE="${1:-patch}"
IS_BETA=false
CLEAN_TAGS=false

for arg in "$@"; do
    case "$arg" in
        --beta) IS_BETA=true ;;
        --clean-tags) CLEAN_TAGS=true ;;
    esac
done

# Validate bump type
case "$BUMP_TYPE" in
    major|minor|patch) ;;
    *) error "Invalid bump type: $BUMP_TYPE. Use: major, minor, or patch." ;;
esac

# Clean local tags if requested
if [[ "$CLEAN_TAGS" == "true" ]]; then
    info "Cleaning local tags..."
    git fetch --tags --prune
    LOCAL_TAGS=$(git tag)
    REMOTE_TAGS=$(git ls-remote --tags origin | awk '{print $2}' | sed 's|refs/tags/||')

    for tag in $LOCAL_TAGS; do
        if ! echo "$REMOTE_TAGS" | grep -q "^$tag$"; then
            warn "Deleting local tag not found remotely: $tag"
            git tag -d "$tag" >/dev/null 2>&1 || true
        fi
    done
    success "Local tags cleaned."
fi

# Determine current version
CURRENT_VERSION=$(git describe --tags --abbrev=0 2>/dev/null || echo "v0.0.0")
CURRENT_VERSION=${CURRENT_VERSION#v}

if [[ "$CURRENT_VERSION" == "0.0.0" ]]; then
    info "No existing tags found. Starting at v0.1.0"
    NEW_VERSION=$([[ "$IS_BETA" == "true" ]] && echo "v0.1.0-beta.1" || echo "v0.1.0")
else
    if [[ "$CURRENT_VERSION" =~ ^([0-9]+)\.([0-9]+)\.([0-9]+)(-beta\.([0-9]+))?$ ]]; then
        MAJOR=${BASH_REMATCH[1]}
        MINOR=${BASH_REMATCH[2]}
        PATCH=${BASH_REMATCH[3]}
        BETA_NUM=${BASH_REMATCH[5]:-0}
    else
        error "Invalid version format: $CURRENT_VERSION"
    fi

    case "$BUMP_TYPE" in
        major)
            ((MAJOR++)); MINOR=0; PATCH=0; BETA_NUM=0 ;;
        minor)
            ((MINOR++)); PATCH=0; BETA_NUM=0 ;;
        patch)
            if [[ "$IS_BETA" == "true" ]]; then
                if [[ "$CURRENT_VERSION" =~ -beta\. ]]; then
                    ((BETA_NUM++))
                else
                    ((PATCH++)); BETA_NUM=1
                fi
            else
                ((PATCH++)); BETA_NUM=0
            fi
            ;;
    esac

    if [[ "$IS_BETA" == "true" && "$BETA_NUM" -gt 0 ]]; then
        NEW_VERSION="v${MAJOR}.${MINOR}.${PATCH}-beta.${BETA_NUM}"
    else
        NEW_VERSION="v${MAJOR}.${MINOR}.${PATCH}"
    fi
fi

info "New version: $NEW_VERSION"

# Confirm
read -p "Create and push tag $NEW_VERSION? (y/N) " -n 1 -r
echo ""
[[ ! $REPLY =~ ^[Yy]$ ]] && { warn "Cancelled."; exit 0; }

# Check clean working directory
if [[ -n $(git status --porcelain) ]]; then
    error "Working directory not clean. Commit or stash changes first."
fi

# Create and push tag
info "Creating tag $NEW_VERSION..."
git tag -a "$NEW_VERSION" -m "Release $NEW_VERSION"

info "Pushing tag to origin..."
git push origin "$NEW_VERSION"

success "Tag $NEW_VERSION created and pushed."
success "CI/CD pipeline will now handle build and release."
