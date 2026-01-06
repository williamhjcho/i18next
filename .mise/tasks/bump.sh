#!/usr/bin/env bash
#MISE description="Bumps the current version of the package"
#USAGE arg "<version>" help="The new version to bump the package to"

set -euo pipefail

NEW_VERSION="${usage_version?}"

# Validate version format (major.minor.patch)
if ! [[ "$NEW_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "Error: Version must be in format major.minor.patch (e.g., 1.2.3)"
    exit 1
fi

# Extract current version from pubspec.yaml
CURRENT_VERSION=$(grep '^version:' pubspec.yaml | sed 's/version: //')

echo "Current version: $CURRENT_VERSION"
echo "New version: $NEW_VERSION"

# Compare versions
IFS='.' read -r -a current <<< "$CURRENT_VERSION"
IFS='.' read -r -a new <<< "$NEW_VERSION"

is_higher=false

# Compare major.minor.patch
for i in 0 1 2; do
    if [ "${new[$i]}" -gt "${current[$i]}" ]; then
        is_higher=true
        break
    elif [ "${new[$i]}" -lt "${current[$i]}" ]; then
        break
    fi
done

if [ "$is_higher" = false ]; then
    echo "Error: New version ($NEW_VERSION) must be higher than current version ($CURRENT_VERSION)"
    exit 1
fi

# Ask for confirmation
read -p "Update pubspec.yaml version from $CURRENT_VERSION to $NEW_VERSION? [y/N] " -n 1 -r
echo  # Move to a new line
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
fi

# Update pubspec.yaml
sed -i.bak "s/^version: .*/version: $NEW_VERSION/" pubspec.yaml
rm pubspec.yaml.bak
echo "✓ Successfully bumped version to $NEW_VERSION"

# Ask to create git tag
read -p "Create git tag $NEW_VERSION? [y/N] " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
fi

git add pubspec.yaml
git commit -m "chore: bump v$NEW_VERSION"
git tag "v$NEW_VERSION"
echo "✓ Created tag v$NEW_VERSION"

echo "Push changes and tag to remote with: 'git push && git push --tags'"
