---
name: "stdx-contributor"
description: "Guide for contributing to Cangjie stdx project. Invoke when user wants to fix bugs, add features, build, test, or submit PRs to cangjie_stdx repository."
---

# Cangjie Stdx Contributor Guide

This skill guides you through the complete workflow for contributing to the Cangjie stdx project, including cloning code, downloading SDK, building, testing, and submitting PRs.

## Workflow Overview

1. Clone the repository and checkout dev branch
2. Analyze the problem and modify code
3. Download SDK and build the project
4. Run test cases to verify changes
5. Commit and push code, create PR

## Step 1: Clone Repository

```bash
mkdir -p cangjie_stdx && cd cangjie_stdx
git clone https://gitcode.com/Cangjie/cangjie_stdx.git .
git checkout dev
```

## Step 2: Download SDK Script

Create a script `download_sdk.sh` to download the latest Cangjie SDK:

```bash
#!/bin/bash

# Cangjie SDK Download Script
# Usage: ./download_sdk.sh <version> <os_type>
# Example: ./download_sdk.sh 260305 linux

VERSION="${1:-260305}"
OS_TYPE="${2:-linux}"
SDK_DIR="${VERSION}"
ACCESS_TOKEN="<YOUR_GITCODE_ACCESS_TOKEN>"  # Replace with your token

DOWNLOAD_URL="https://gitcode.com/Cangjie/cangjie-sdk-release/raw/main/cangjie-sdk-${VERSION}-${OS_TYPE}-x86_64.tar.gz"

echo "Downloading Cangjie SDK ${VERSION} for ${OS_TYPE}..."
mkdir -p "${SDK_DIR}"

# Download SDK
curl -L -o "${SDK_DIR}/cangjie-sdk.tar.gz" "${DOWNLOAD_URL}"

# Extract SDK
tar -xzf "${SDK_DIR}/cangjie-sdk.tar.gz" -C "${SDK_DIR}"

# Cleanup
rm -f "${SDK_DIR}/cangjie-sdk.tar.gz"

echo "SDK installed at: ${SDK_DIR}/cangjie"
echo "To activate: source ${SDK_DIR}/cangjie/envsetup.sh"
```

Run the script:
```bash
chmod +x download_sdk.sh
./download_sdk.sh 260305 linux
```

## Step 3: Build Project

```bash
# Setup environment
source <SDK_PATH>/cangjie/envsetup.sh

# Build stdx
cd cangjie_stdx
python3 build.py clean
python3 build.py build -t release --target-lib=/usr/lib/x86_64-linux-gnu
python3 build.py install
```

Build outputs:
- Static library: `target/linux_x86_64_cjnative/static/stdx/`
- Dynamic library: `target/linux_x86_64_cjnative/dynamic/stdx/`

## Step 4: Run Tests

### Setup Test Framework

```bash
# Clone test repository
git clone -b dev https://gitcode.com/Cangjie/cangjie_test.git

# Clone test framework
git clone https://gitcode.com/Cangjie/cangjie_test_framework.git
```

### Create Test Config

Create `test_framework.cfg`:
```ini
[test-home]
dir =
    /path/to/cangjie_test/testsuites/LLT

[running]
temp_dir = /path/to/test_temp/run

[logging]
name = /path/to/test_temp/log
level = INFO
```

### Run Tests

```bash
source <SDK_PATH>/cangjie/envsetup.sh
export CANGJIE_STDX_PATH=/path/to/cangjie_stdx/target/linux_x86_64_cjnative/static/stdx

cd cangjie_test

# Run specific test suite
python3 /path/to/cangjie_test_framework/main.py \
    --cfg /path/to/test_framework.cfg \
    --test_cfg testsuites/LLT/configs/cjnative/cjnative_test.cfg \
    testsuites/LLT/API/stdx/net/http/body/ \
    -j4 --timeout 120
```

## Step 5: Commit and Create PR

### Configure Git

```bash
# Set your identity
git config user.name "Your Name"
git config user.email "your.email@example.com"
```

### Create Feature Branch

```bash
git checkout -b feature/your-feature-name
git add <modified-files>
git commit -m "feat(module): brief description

- Detailed change 1
- Detailed change 2"
```

### Push to Fork

```bash
# Add your fork as remote (replace <USERNAME> with your GitCode username)
git remote add fork https://oauth2:<YOUR_ACCESS_TOKEN>@gitcode.com/<USERNAME>/cangjie_stdx.git

# Push to fork
git push -u fork feature/your-feature-name
```

### Create Pull Request

1. Visit: `https://gitcode.com/<USERNAME>/cangjie_stdx/merge_requests/new?source_branch=feature/your-feature-name`
2. Set target repository: `Cangjie/cangjie_stdx`
3. Set target branch: `dev`
4. Fill in PR title and description

### PR Description Template

```markdown
## 功能描述

Brief description of what this PR does.

## 修改内容

- Change 1
- Change 2

## 修改的文件

- `path/to/file1.cj` - Description
- `path/to/file2.cj` - Description

## 测试结果

| 测试套件 | 通过/总数 |
|---------|----------|
| Suite 1 | X/X |
| Suite 2 | X/X |
| **总计** | **X/X** |
```

## Important Notes

1. **Access Token**: Replace `<YOUR_GITCODE_ACCESS_TOKEN>` with your personal access token from GitCode
2. **Username**: Replace `<USERNAME>` with your GitCode username
3. **SDK Version**: Check https://gitcode.com/Cangjie/cangjie-sdk-release for latest versions
4. **Branch**: Always create PRs targeting the `dev` branch
5. **Tests**: Ensure all related tests pass before submitting PR

## Common Issues

### Build Errors

- Check SDK version compatibility
- Ensure all dependencies are installed (OpenSSL, etc.)
- Run `python3 build.py clean` before rebuilding

### Test Failures

- Check if CANGJIE_STDX_PATH is set correctly
- Ensure the library is built before running tests
- Check test logs in the log directory

### Push Permission Denied

- Fork the repository first
- Use your fork as the remote
- Ensure your access token has write permissions
