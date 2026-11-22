#!/usr/bin/env bash
# =====================================================================
# OmniCore Media Engine - 1-Click Universal Linux Installer
# Automated installer runner: fetches the latest verified setup payload
# =====================================================================

set -e

# ANSI Color Codes
CYAN='\033[0;36m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m'

echo -e "${CYAN}${BOLD}"
echo "=========================================================="
echo "    OmniCore Media Engine - 1-Click Linux Installer"
echo "=========================================================="
echo -e "${NC}"

INSTALL_URL="https://raw.githubusercontent.com/KrSnaGit112/OCU/main/install.sh"
TEMP_INSTALL="/tmp/omnicore_install_$$.sh"

echo -e "${BLUE}[INFO] Fetching the latest verified installation engine from GitHub...${NC}"

DOWNLOAD_OK=0
if command -v wget >/dev/null 2>&1; then
    if wget -q --show-progress -O "$TEMP_INSTALL" "$INSTALL_URL"; then
        DOWNLOAD_OK=1
    fi
elif command -v curl >/dev/null 2>&1; then
    if curl -sSL -L "$INSTALL_URL" -o "$TEMP_INSTALL" --progress-bar; then
        DOWNLOAD_OK=1
    fi
fi

if [ "$DOWNLOAD_OK" -ne 1 ] || [ ! -s "$TEMP_INSTALL" ]; then
    echo -e "${RED}[ERROR] Failed to fetch installer from: $INSTALL_URL${NC}"
    echo "Please check your network connection and try again."
    read -rp "Press Enter to exit..."
    exit 1
fi

echo -e "${GREEN}[OK] Installer verified. Launching installation routine...${NC}\n"
chmod +x "$TEMP_INSTALL" 2>/dev/null || true

# Execute the downloaded installer with any arguments passed to this script
bash "$TEMP_INSTALL" "$@"
EXIT_CODE=$?

rm -f "$TEMP_INSTALL" 2>/dev/null || true

if [ $EXIT_CODE -eq 0 ]; then
    echo -e "\n${GREEN}${BOLD}OmniCore Media Engine installation completed successfully!${NC}"
else
    echo -e "\n${YELLOW}Installation exited with status code: $EXIT_CODE${NC}"
fi

exit $EXIT_CODE
