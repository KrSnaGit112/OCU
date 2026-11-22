#!/usr/bin/env bash
# =============================================================================
# OmniCore Media Engine - Automated Linux Installer Runner
# One-click execution script that detects the setup package and runs unattended
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

echo -e "${CYAN}${BOLD}"
echo "============================================================"
echo "    OmniCore Media Engine - Automated Linux Installer"
echo "============================================================"
echo -e "${NC}"

# Find installer .sh in current directory or sibling release directory
INSTALLER=""
if compgen -G "${SCRIPT_DIR}/OmniCore-Media-Engine-Setup-*-linux-x64.sh" > /dev/null; then
    INSTALLER=$(ls -1 "${SCRIPT_DIR}"/OmniCore-Media-Engine-Setup-*-linux-x64.sh | sort -V | tail -n 1)
elif compgen -G "${SCRIPT_DIR}/../../release/OmniCore-Media-Engine-Setup-*-linux-x64.sh" > /dev/null; then
    INSTALLER=$(ls -1 "${SCRIPT_DIR}"/../../release/OmniCore-Media-Engine-Setup-*-linux-x64.sh | sort -V | tail -n 1)
elif compgen -G "${SCRIPT_DIR}/../release/OmniCore-Media-Engine-Setup-*-linux-x64.sh" > /dev/null; then
    INSTALLER=$(ls -1 "${SCRIPT_DIR}"/../release/OmniCore-Media-Engine-Setup-*-linux-x64.sh | sort -V | tail -n 1)
elif [ -f "${SCRIPT_DIR}/install.sh" ]; then
    INSTALLER="${SCRIPT_DIR}/install.sh"
fi

if [ -z "$INSTALLER" ] || [ ! -f "$INSTALLER" ]; then
    echo -e "${RED}[ERROR] Could not find OmniCore Linux installer package!${NC}"
    echo "Please ensure OmniCore-Media-Engine-Setup-*-linux-x64.sh or install.sh is present."
    echo ""
    read -rp "Press Enter to exit..."
    exit 1
fi

echo -e "${GREEN}[FOUND]${NC} Installer package: $(basename "$INSTALLER")"
echo -e "${CYAN}[INFO]${NC} Granting executable permissions..."
chmod +x "$INSTALLER" 2>/dev/null || true

# Test if running from a non-executable filesystem (e.g. NTFS mount or VirtualBox shared folder)
IS_NOEXEC=0
TEMP_TEST="${SCRIPT_DIR}/.exec_test_$$"
if touch "$TEMP_TEST" 2>/dev/null; then
    chmod +x "$TEMP_TEST" 2>/dev/null || true
    if [ ! -x "$TEMP_TEST" ]; then
        IS_NOEXEC=1
    fi
    rm -f "$TEMP_TEST" 2>/dev/null || true
fi

TARGET_EXEC="$INSTALLER"
TMP_DIR=""
if [ "$IS_NOEXEC" -eq 1 ]; then
    echo -e "${YELLOW}[WARN] Installer is on a non-executable filesystem (NTFS/Shared Folder).${NC}"
    echo -e "${CYAN}[INFO] Relocating installer to /tmp for execution...${NC}"
    TMP_DIR="/tmp/omnicore_install_$$"
    mkdir -p "$TMP_DIR"
    cp "$INSTALLER" "$TMP_DIR/"
    TARGET_EXEC="$TMP_DIR/$(basename "$INSTALLER")"
    chmod +x "$TARGET_EXEC" 2>/dev/null || true
fi

echo -e "${CYAN}[INFO]${NC} Launching OmniCore installation with automated defaults..."
echo ""

# Execute via bash explicitly to bypass filesystem execute-bit limitations
bash "$TARGET_EXEC" -y "$@"
EXIT_CODE=$?

if [ -n "$TMP_DIR" ] && [ -d "$TMP_DIR" ]; then
    rm -rf "$TMP_DIR" 2>/dev/null || true
fi

echo ""
if [ $EXIT_CODE -eq 0 ]; then
    echo -e "${GREEN}${BOLD}============================================================${NC}"
    echo -e "${GREEN}${BOLD}  OmniCore Media Engine was installed and configured!${NC}"
    echo -e "${GREEN}${BOLD}============================================================${NC}"
    echo "You can launch it from your Applications menu or Desktop shortcut."
else
    echo -e "${RED}[ERROR] Installation finished with exit code $EXIT_CODE${NC}"
fi

echo ""
read -rp "Press Enter to finish..."
exit $EXIT_CODE
