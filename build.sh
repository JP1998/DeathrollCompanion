#!/bin/sh

# Import all the configuration from build-settings.conf
set -o allexport && source ./build-settings.conf && set +o allexport

# Copy all included files into the addon folder while deleting anything
# that either doesn't exist or is ignored in the source folder
rsync -av --exclude-from=".buildignore" --delete-excluded . "$ADDON_FOLDER/$ADDON_RENAME"

# Rename the .toc file to reflect the rename of the addon folder
mv "$ADDON_FOLDER/$ADDON_RENAME/DeathrollCompanion.toc" "$ADDON_FOLDER/$ADDON_RENAME/$ADDON_RENAME.toc"

# Append a "(Development)" flag to the addon name in the toc-file to be able to identify it in-game
sed -i -r -e 's/^## Title: (.*)$/## Title: \1 (Development)/g' "$ADDON_FOLDER/$ADDON_RENAME/$ADDON_RENAME.toc"
