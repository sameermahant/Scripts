#!/bin/bash
set -eu

# I prefer to use softwares in portable mode, as its easy to remove without disturbing the system stability.
# This script installs / updates the Visual Studio Code IDE in the /opt directory

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run with root privileges."
   exit 1
fi

VISUAL_STUDIO_CODE_URL="https://update.code.visualstudio.com/latest/linux-x64/stable"
TEMPORARY_OUTPUT_FILE_LOCATION="/tmp/vscode.tar.gz"

echo "Downloading VSCode to /tmp/"
wget -q "${VISUAL_STUDIO_CODE_URL}" -O "${TEMPORARY_OUTPUT_FILE_LOCATION}"

if [ -f "${TEMPORARY_OUTPUT_FILE_LOCATION}" ]; then
    echo "Download completed."
else
    echo "Download failed."
    exit
fi

echo "Extracting to /tmp/ ..."
cd /tmp/
tar -xf vscode.tar.gz
echo "Completed extracting."
# Note: Extracted folder name is 'VSCode-linux-x64'

echo "Removing old version ..."
rm -rf /opt/VSCode-linux-x64 || true

echo "Setting up new version ..."
mv VSCode-linux-x64 /opt/

rm -rf "${TEMPORARY_OUTPUT_FILE_LOCATION}"

echo "Done."