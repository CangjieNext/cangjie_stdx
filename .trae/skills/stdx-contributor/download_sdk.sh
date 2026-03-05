#!/bin/bash

# Cangjie SDK Download Script
# Usage: ./download_sdk.sh <version> <os_type>
# Example: ./download_sdk.sh 260305 linux

VERSION="${1:-260305}"
OS_TYPE="${2:-linux}"
SDK_DIR="${VERSION}"

# Replace with your GitCode personal access token
ACCESS_TOKEN="<YOUR_GITCODE_ACCESS_TOKEN>"

DOWNLOAD_URL="https://gitcode.com/Cangjie/cangjie-sdk-release/raw/main/cangjie-sdk-${VERSION}-${OS_TYPE}-x86_64.tar.gz"

echo "=========================================="
echo "Cangjie SDK Downloader"
echo "=========================================="
echo "Version: ${VERSION}"
echo "OS Type: ${OS_TYPE}"
echo "Target Dir: ${SDK_DIR}"
echo ""

if [ -d "${SDK_DIR}/cangjie" ]; then
    echo "SDK already exists at ${SDK_DIR}/cangjie"
    echo "To activate: source ${SDK_DIR}/cangjie/envsetup.sh"
    exit 0
fi

echo "Downloading Cangjie SDK..."
mkdir -p "${SDK_DIR}"

# Download SDK
curl -L -o "${SDK_DIR}/cangjie-sdk.tar.gz" "${DOWNLOAD_URL}"

if [ $? -ne 0 ]; then
    echo "Error: Failed to download SDK"
    rm -rf "${SDK_DIR}"
    exit 1
fi

# Extract SDK
echo "Extracting SDK..."
tar -xzf "${SDK_DIR}/cangjie-sdk.tar.gz" -C "${SDK_DIR}"

if [ $? -ne 0 ]; then
    echo "Error: Failed to extract SDK"
    rm -rf "${SDK_DIR}"
    exit 1
fi

# Cleanup
rm -f "${SDK_DIR}/cangjie-sdk.tar.gz"

echo ""
echo "=========================================="
echo "SDK installed successfully!"
echo "=========================================="
echo "SDK Path: ${SDK_DIR}/cangjie"
echo ""
echo "To activate, run:"
echo "  source ${SDK_DIR}/cangjie/envsetup.sh"
echo ""
echo "To verify installation:"
echo "  cjc -v"
