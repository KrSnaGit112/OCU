#!/usr/bin/env bash
# =====================================================================
# OmniCore Media Engine: Unified Universal Linux Installer
# Version: 1.0.0
# Compatible with: Ubuntu, Debian, Fedora, Arch, openSUSE, Mint, RHEL
# =====================================================================

set -e

APP_NAME="OmniCore Media Engine"
APP_ID="com.omnicore.engine"
APP_ID_LEGACY="com.krsna.engine"
EXT_ID="odcahhkipbkgkcljfnolkaiibomhpfij"
VERSION="1.0.13"

# ANSI Color Codes
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Parse Command Line Options
IS_SILENT=0
CUSTOM_PREFIX=""
IS_UNINSTALL=0

for arg in "$@"; do
  case $arg in
    -y|--yes|--silent|-s)
      IS_SILENT=1
      shift
      ;;
    --uninstall|-u)
      IS_UNINSTALL=1
      shift
      ;;
    --prefix=*)
      CUSTOM_PREFIX="${arg#*=}"
      shift
      ;;
    --help|-h)
      echo "OmniCore Media Engine Unified Linux Installer v$VERSION"
      echo ""
      echo "Usage: $0 [options]"
      echo ""
      echo "Options:"
      echo "  -y, --silent       Run unattended installation with defaults"
      echo "  --prefix=<path>    Custom installation directory"
      echo "  -u, --uninstall    Completely uninstall OmniCore Media Engine"
      echo "  -h, --help         Display this help message"
      exit 0
      ;;
  esac
done

# Detect Permissions & Default Paths
if [ "$(id -u)" -eq 0 ]; then
  IS_ROOT=1
  DEFAULT_DIR="/opt/omnicore"
  BIN_DIR="/usr/local/bin"
  DESKTOP_DIR="/usr/share/applications"
  ICON_BASE_DIR="/usr/share/icons/hicolor"
  CHROME_NATIVE_DIR="/etc/opt/chrome/native-messaging-hosts"
  BRAVE_NATIVE_DIR="/etc/brave/native-messaging-hosts"
  CHROMIUM_NATIVE_DIR="/etc/chromium/native-messaging-hosts"
  EDGE_NATIVE_DIR="/etc/opt/edge/native-messaging-hosts"
  CHROME_POLICY_DIR="/etc/opt/chrome/policies/managed"
  BRAVE_POLICY_DIR="/etc/brave/policies/managed"
  CHROMIUM_POLICY_DIR="/etc/chromium/policies/managed"
  CHROME_EXT_DIR="/usr/share/google-chrome/extensions"
  BRAVE_EXT_DIR="/usr/share/brave-browser/extensions"
  CHROMIUM_EXT_DIR="/usr/share/chromium/extensions"
else
  IS_ROOT=0
  DEFAULT_DIR="$HOME/.local/share/omnicore"
  BIN_DIR="$HOME/.local/bin"
  DESKTOP_DIR="$HOME/.local/share/applications"
  ICON_BASE_DIR="$HOME/.local/share/icons/hicolor"
  CHROME_NATIVE_DIR="$HOME/.config/google-chrome/NativeMessagingHosts"
  BRAVE_NATIVE_DIR="$HOME/.config/BraveSoftware/Brave-Browser/NativeMessagingHosts"
  CHROMIUM_NATIVE_DIR="$HOME/.config/chromium/NativeMessagingHosts"
  EDGE_NATIVE_DIR="$HOME/.config/microsoft-edge/NativeMessagingHosts"
  CHROME_POLICY_DIR=""
  BRAVE_POLICY_DIR=""
  CHROMIUM_POLICY_DIR=""
  CHROME_EXT_DIR="$HOME/.config/google-chrome/External Extensions"
  BRAVE_EXT_DIR="$HOME/.config/BraveSoftware/Brave-Browser/External Extensions"
  CHROMIUM_EXT_DIR="$HOME/.config/chromium/External Extensions"
fi

INSTALL_DIR="${CUSTOM_PREFIX:-$DEFAULT_DIR}"

# -------------------------------------------------------------
# UNINSTALLATION ROUTINE
# -------------------------------------------------------------
perform_uninstall() {
  echo -e "${YELLOW}${BOLD}Uninstalling ${APP_NAME}...${NC}"

  # Terminate running engine processes
  pkill -f "OmniCoreMediaEngine" || true
  pkill -f "engine-winui" || true
  pkill -f "KrSnaEngine" || true

  # 1. Remove Executable & Directory
  if [ -d "$INSTALL_DIR" ]; then
    echo -e "  Removing: $INSTALL_DIR"
    rm -rf "$INSTALL_DIR"
  fi

  # 2. Remove Binary Symlink
  if [ -L "$BIN_DIR/omnicore" ] || [ -f "$BIN_DIR/omnicore" ]; then
    echo -e "  Removing: $BIN_DIR/omnicore"
    rm -f "$BIN_DIR/omnicore"
  fi

  # 3. Remove Desktop Launcher
  if [ -f "$DESKTOP_DIR/omnicore.desktop" ]; then
    echo -e "  Removing: $DESKTOP_DIR/omnicore.desktop"
    rm -f "$DESKTOP_DIR/omnicore.desktop"
  fi

  # 4. Remove Icons
  for size in 16 48 128 256 512; do
    icon_file="$ICON_BASE_DIR/${size}x${size}/apps/omnicore.png"
    if [ -f "$icon_file" ]; then
      rm -f "$icon_file"
    fi
  done

  # 5. Remove Native Messaging Manifests (both current & legacy com.krsna.engine)
  for nat_dir in "$CHROME_NATIVE_DIR" "$BRAVE_NATIVE_DIR" "$CHROMIUM_NATIVE_DIR" "$EDGE_NATIVE_DIR"; do
    if [ -d "$nat_dir" ]; then
      rm -f "$nat_dir/$APP_ID.json" "$nat_dir/$APP_ID_LEGACY.json" "$nat_dir/com.krsna.enhancer.json"
    fi
  done

  # 6. Remove External Extension Declarations
  for ext_dir in "$CHROME_EXT_DIR" "$BRAVE_EXT_DIR" "$CHROMIUM_EXT_DIR"; do
    if [ -d "$ext_dir" ]; then
      rm -f "$ext_dir/$EXT_ID.json" "$ext_dir/$EXT_ID_LEGACY.json"
    fi
  done

  # 7. Update Desktop and Icon Caches
  if command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database "$DESKTOP_DIR" 2>/dev/null || true
  fi
  if command -v gtk-update-icon-cache >/dev/null 2>&1; then
    gtk-update-icon-cache -f -t "$ICON_BASE_DIR" 2>/dev/null || true
  fi

  echo -e "\n${GREEN}${BOLD}OmniCore Media Engine was successfully uninstalled from your system.${NC}"
  exit 0
}

if [ "$IS_UNINSTALL" -eq 1 ]; then
  perform_uninstall
fi

# -------------------------------------------------------------
# INSTALLATION BANNER & PROMPT
# -------------------------------------------------------------
echo -e "${CYAN}${BOLD}"
echo "=========================================================="
echo "    OmniCore Media Engine - Unified Linux Installer v$VERSION"
echo "=========================================================="
echo -e "${NC}"

if [ "$IS_ROOT" -eq 1 ]; then
  echo -e "Mode: ${GREEN}System-Wide (Root / Sudo)${NC}"
else
  echo -e "Mode: ${YELLOW}User-Space (Non-Root)${NC}"
fi
echo -e "Target Directory: ${BOLD}$INSTALL_DIR${NC}"
echo ""

if [ "$IS_SILENT" -eq 0 ]; then
  read -p "Do you want to proceed with installation? [Y/n] " response
  response=${response:-Y}
  if [[ ! "$response" =~ ^[Yy]$ ]]; then
    echo -e "${RED}Installation cancelled by user.${NC}"
    exit 0
  fi
fi

# -------------------------------------------------------------
# TERMINATE RUNNING INSTANCES
# -------------------------------------------------------------
pkill -f "OmniCoreMediaEngine" || true
pkill -f "engine-winui" || true
pkill -f "KrSnaEngine" || true

# -------------------------------------------------------------
# PREPARE DIRECTORIES
# -------------------------------------------------------------
mkdir -p "$INSTALL_DIR" 2>/dev/null || true

# Guard against permission denied on non-root or restricted targets
if [ ! -w "$INSTALL_DIR" ]; then
  if [ "$IS_ROOT" -eq 0 ]; then
    echo -e "${YELLOW}[WARN] Target $INSTALL_DIR is not writable by current user.${NC}"
    INSTALL_DIR="$HOME/.local/share/omnicore"
    BIN_DIR="$HOME/.local/bin"
    DESKTOP_DIR="$HOME/.local/share/applications"
    ICON_BASE_DIR="$HOME/.local/share/icons/hicolor"
    echo -e "${GREEN}[INFO] Automatically switching to writable user-space path: $INSTALL_DIR${NC}"
  fi
fi

mkdir -p "$INSTALL_DIR" 2>/dev/null || true
mkdir -p "$INSTALL_DIR/bin" 2>/dev/null || true
mkdir -p "$INSTALL_DIR/extension" 2>/dev/null || true
mkdir -p "$INSTALL_DIR/engine" 2>/dev/null || true
mkdir -p "$BIN_DIR" 2>/dev/null || true
mkdir -p "$DESKTOP_DIR" 2>/dev/null || true

# -------------------------------------------------------------
# EXTRACT EMBEDDED PAYLOAD OR LOCAL REPO
# -------------------------------------------------------------
echo -e "\n${BLUE}Extracting OmniCore application payload...${NC}"

# Check if running as a self-extracting archive (payload appended after __ARCHIVE_FOLLOWS__)
ARCHIVE_LINE=$(grep -a -n '^__ARCHIVE_FOLLOWS__' "$0" 2>/dev/null | head -n 1 | cut -d: -f1 || true)
HAS_EMBEDDED_PAYLOAD=0

if [ -n "$ARCHIVE_LINE" ]; then
  # Probe if there are at least 256 bytes of actual binary payload following the marker
  PAYLOAD_SAMPLE=$(tail -n +$((ARCHIVE_LINE + 1)) "$0" 2>/dev/null | head -c 512 | wc -c || echo 0)
  if [ "$PAYLOAD_SAMPLE" -ge 256 ]; then
    HAS_EMBEDDED_PAYLOAD=1
  fi
fi

if [ "$HAS_EMBEDDED_PAYLOAD" -eq 1 ]; then
  tail -n +$((ARCHIVE_LINE + 1)) "$0" | tar --overwrite -xz -C "$INSTALL_DIR" 2>/dev/null || tail -n +$((ARCHIVE_LINE + 1)) "$0" | tar -xz -C "$INSTALL_DIR"
else
  # Running from source/distribution directory or standalone install.sh
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  FOUND_TAR=""

  if [ -f "$SCRIPT_DIR/payload.tar.gz" ]; then
    FOUND_TAR="$SCRIPT_DIR/payload.tar.gz"
  elif [ -d "$SCRIPT_DIR/../../engine-desktop/bin/Release/net8.0/linux-x64/publish" ]; then
    cp -r "$SCRIPT_DIR/../../engine-desktop/bin/Release/net8.0/linux-x64/publish/"* "$INSTALL_DIR/"
    if [ -d "$SCRIPT_DIR/../../dist" ]; then
      cp -r "$SCRIPT_DIR/../../dist/"* "$INSTALL_DIR/extension/"
    fi
    if [ -f "$SCRIPT_DIR/../../OmniCore-Web-Assistant-v$VERSION.crx" ]; then
      cp "$SCRIPT_DIR/../../OmniCore-Web-Assistant-v$VERSION.crx" "$INSTALL_DIR/"
    elif [ -f "$SCRIPT_DIR/../../OmniCore-Web-Assistant.crx" ]; then
      cp "$SCRIPT_DIR/../../OmniCore-Web-Assistant.crx" "$INSTALL_DIR/"
    fi
    FOUND_TAR="copied_from_source"
  fi

  if [ -n "$FOUND_TAR" ] && [ "$FOUND_TAR" != "copied_from_source" ]; then
    tar --overwrite -xz -f "$FOUND_TAR" -C "$INSTALL_DIR" 2>/dev/null || tar -xz -f "$FOUND_TAR" -C "$INSTALL_DIR"
  elif [ -z "$FOUND_TAR" ]; then
    # Standalone script execution: download application payload automatically from GitHub Releases
    echo -e "${CYAN}[INFO] Standalone script detected. Fetching OmniCore application payload from GitHub Releases...${NC}"
    TAR_URL="https://github.com/KrSnaGit112/OCU/releases/download/v${VERSION}/OmniCore-Media-Engine-v${VERSION}-linux-x64.tar.gz"
    TEMP_TAR="/tmp/omnicore_payload_${VERSION}_$$.tar.gz"

    DOWNLOAD_SUCCESS=0
    if command -v curl >/dev/null 2>&1; then
      echo -e "${BLUE}Downloading package via curl...${NC}"
      if curl -sSL -L "$TAR_URL" -o "$TEMP_TAR" --progress-bar; then
        DOWNLOAD_SUCCESS=1
      fi
    elif command -v wget >/dev/null 2>&1; then
      echo -e "${BLUE}Downloading package via wget...${NC}"
      if wget -q --show-progress -O "$TEMP_TAR" "$TAR_URL"; then
        DOWNLOAD_SUCCESS=1
      fi
    fi

    if [ "$DOWNLOAD_SUCCESS" -eq 1 ] && [ -s "$TEMP_TAR" ]; then
      echo -e "${GREEN}[OK] Download complete. Extracting payload to $INSTALL_DIR...${NC}"
      tar --overwrite -xz -f "$TEMP_TAR" -C "$INSTALL_DIR" 2>/dev/null || tar -xz -f "$TEMP_TAR" -C "$INSTALL_DIR"
      rm -f "$TEMP_TAR" 2>/dev/null || true
    else
      echo -e "${RED}[ERROR] Failed to download application payload from: $TAR_URL${NC}"
      echo -e "${YELLOW}Please download OmniCore-Media-Engine-Setup-v${VERSION}-linux-x64.sh directly from:${NC}"
      echo "  https://github.com/KrSnaGit112/OCU/releases/tag/v${VERSION}"
      exit 1
    fi
  fi
fi

# Ensure world-readability and executable permissions across entire installation tree
chmod -R a+rX "$INSTALL_DIR" 2>/dev/null || true
if [ -f "$INSTALL_DIR/OmniCoreMediaEngine" ]; then
  chmod +x "$INSTALL_DIR/OmniCoreMediaEngine" 2>/dev/null || true
fi

# -------------------------------------------------------------
# NATIVE MESSAGING HOST MANIFEST GENERATION
# -------------------------------------------------------------
echo -e "${BLUE}Registering Native Messaging Hosts for Chromium, Chrome, Brave & Edge...${NC}"

EXEC_ESC_PATH="$INSTALL_DIR/OmniCoreMediaEngine"

MANIFEST_PRIMARY=$(cat <<EOF
{
  "name": "com.omnicore.engine",
  "description": "OmniCore Media Engine Native Host",
  "path": "$EXEC_ESC_PATH",
  "type": "stdio",
  "allowed_origins": [
    "chrome-extension://$EXT_ID/"
  ]
}
EOF
)

MANIFEST_LEGACY=$(cat <<EOF
{
  "name": "com.krsna.engine",
  "description": "OmniCore Media Engine Native Host (Compatibility Alias)",
  "path": "$EXEC_ESC_PATH",
  "type": "stdio",
  "allowed_origins": [
    "chrome-extension://$EXT_ID/"
  ]
}
EOF
)

# Register into all detected or prospective browser directories safely
for nat_dir in "$CHROME_NATIVE_DIR" "$BRAVE_NATIVE_DIR" "$CHROMIUM_NATIVE_DIR" "$EDGE_NATIVE_DIR"; do
  if [ -n "$nat_dir" ]; then
    mkdir -p "$nat_dir" 2>/dev/null || true
    if [ -w "$nat_dir" ]; then
      rm -f "$nat_dir/$APP_ID.json" "$nat_dir/$APP_ID_LEGACY.json" "$nat_dir/com.krsna.enhancer.json" 2>/dev/null || true
      echo "$MANIFEST_PRIMARY" > "$nat_dir/$APP_ID.json" 2>/dev/null || true
      echo "$MANIFEST_LEGACY" > "$nat_dir/$APP_ID_LEGACY.json" 2>/dev/null || true
      chmod 644 "$nat_dir/$APP_ID.json" "$nat_dir/$APP_ID_LEGACY.json" 2>/dev/null || true
    fi
  fi
done

# -------------------------------------------------------------
# CHROMIUM EXTERNAL EXTENSION REGISTRATION
# -------------------------------------------------------------
echo -e "${BLUE}Configuring browser extension auto-detection...${NC}"

if [ -f "$INSTALL_DIR/OmniCore-Web-Assistant-v$VERSION.crx" ]; then
  CRX_PATH="$INSTALL_DIR/OmniCore-Web-Assistant-v$VERSION.crx"
elif [ -f "$INSTALL_DIR/OmniCore-Web-Assistant.crx" ]; then
  CRX_PATH="$INSTALL_DIR/OmniCore-Web-Assistant.crx"
else
  CRX_PATH="$INSTALL_DIR/OmniCore-Web-Assistant-v$VERSION.crx"
fi
  EXT_JSON=$(cat <<EOF
{
  "external_crx": "$CRX_PATH",
  "external_version": "$VERSION"
}
EOF
)
  for ext_dir in "$CHROME_EXT_DIR" "$BRAVE_EXT_DIR" "$CHROMIUM_EXT_DIR"; do
    mkdir -p "$ext_dir" 2>/dev/null || true
    if [ -w "$ext_dir" ]; then
      echo "$EXT_JSON" > "$ext_dir/$EXT_ID.json"
      chmod 644 "$ext_dir/$EXT_ID.json" 2>/dev/null || true
      rm -f "$ext_dir/cnkobbofemhdlbpjdfbfikehpeiemnml.json" 2>/dev/null || true
    fi
  done

# -------------------------------------------------------------
# DESKTOP LAUNCHER & ICONS
# -------------------------------------------------------------
echo -e "${BLUE}Installing desktop application launcher and icons...${NC}"

# Install high-resolution icons
for size in 16 48 128 256; do
  target_icon_dir="$ICON_BASE_DIR/${size}x${size}/apps"
  mkdir -p "$target_icon_dir"
  if [ -f "$INSTALL_DIR/icon-${size}.png" ]; then
    cp "$INSTALL_DIR/icon-${size}.png" "$target_icon_dir/omnicore.png"
    chmod 644 "$target_icon_dir/omnicore.png"
  elif [ -f "$INSTALL_DIR/extension/icon-${size}.png" ]; then
    cp "$INSTALL_DIR/extension/icon-${size}.png" "$target_icon_dir/omnicore.png"
    chmod 644 "$target_icon_dir/omnicore.png"
  fi
done

# High-res 512x512 from brand-logo if available
target_icon_512="$ICON_BASE_DIR/512x512/apps"
mkdir -p "$target_icon_512"
if [ -f "$INSTALL_DIR/brand-logo.png" ]; then
  cp "$INSTALL_DIR/brand-logo.png" "$target_icon_512/omnicore.png"
  chmod 644 "$target_icon_512/omnicore.png"
elif [ -f "$INSTALL_DIR/Assets/brand-logo.png" ]; then
  cp "$INSTALL_DIR/Assets/brand-logo.png" "$target_icon_512/omnicore.png"
  chmod 644 "$target_icon_512/omnicore.png"
fi

# Create omnicore.desktop
DESKTOP_ENTRY=$(cat <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=OmniCore Media Engine
GenericName=Media Downloader & Engine
Comment=Modern High-Performance Media Downloader, Processor & Web Assistant
Exec=$INSTALL_DIR/OmniCoreMediaEngine %U
Path=$INSTALL_DIR
Icon=omnicore
Terminal=false
StartupNotify=true
Categories=AudioVideo;Audio;Video;Network;FileTransfer;
MimeType=x-scheme-handler/omnicore;
Keywords=media;download;video;audio;youtube;stream;enhancer;omnicore;
EOF
)

if [ -w "$DESKTOP_DIR" ] || [ ! -e "$DESKTOP_DIR" ]; then
  mkdir -p "$DESKTOP_DIR" 2>/dev/null || true
  rm -f "$DESKTOP_DIR/omnicore.desktop" 2>/dev/null || true
  echo "$DESKTOP_ENTRY" > "$DESKTOP_DIR/omnicore.desktop" 2>/dev/null || true
  chmod 644 "$DESKTOP_DIR/omnicore.desktop" 2>/dev/null || true
fi

# Detect real login user (even when running under sudo)
REAL_USER="${SUDO_USER:-$USER}"
REAL_HOME=$(getent passwd "$REAL_USER" 2>/dev/null | cut -d: -f6 || echo "$HOME")
REAL_HOME="${REAL_HOME:-$HOME}"

# Also install to user's Desktop folder if present (Linux Mint / Cinnamon desktop)
for target_desktop in "$REAL_HOME/Desktop" "$HOME/Desktop"; do
  if [ -d "$target_desktop" ]; then
    rm -f "$target_desktop/omnicore.desktop" 2>/dev/null || true
    echo "$DESKTOP_ENTRY" > "$target_desktop/omnicore.desktop" 2>/dev/null || true
    chmod +x "$target_desktop/omnicore.desktop" 2>/dev/null || true
    if [ "$IS_ROOT" -eq 1 ] && [ -n "$SUDO_USER" ]; then
      chown "$REAL_USER":"$REAL_USER" "$target_desktop/omnicore.desktop" 2>/dev/null || true
    fi
    gio set "$target_desktop/omnicore.desktop" metadata::trusted true 2>/dev/null || true
  fi
done

# Symlink CLI binary safely
if [ -w "$BIN_DIR" ] || [ ! -e "$BIN_DIR" ]; then
  mkdir -p "$BIN_DIR" 2>/dev/null || true
  rm -f "$BIN_DIR/omnicore" 2>/dev/null || true
  ln -sf "$INSTALL_DIR/OmniCoreMediaEngine" "$BIN_DIR/omnicore" 2>/dev/null || true
fi

# Update desktop and icon databases
if command -v update-desktop-database >/dev/null 2>&1; then
  update-desktop-database "$DESKTOP_DIR" 2>/dev/null || true
fi
if command -v gtk-update-icon-cache >/dev/null 2>&1; then
  gtk-update-icon-cache -f -t "$ICON_BASE_DIR" 2>/dev/null || true
fi

# -------------------------------------------------------------
# CREATE STANDALONE UNINSTALLER SCRIPT
# -------------------------------------------------------------
UNINSTALLER_SCRIPT="$INSTALL_DIR/uninstall.sh"
cat <<EOF > "$UNINSTALLER_SCRIPT"
#!/usr/bin/env bash
# OmniCore Media Engine Standalone Uninstaller
SCRIPT_PATH="\$(cd "\$(dirname "\${BASH_SOURCE[0]}")" && pwd)"
"\$SCRIPT_PATH/install.sh" --uninstall
EOF
chmod +x "$UNINSTALLER_SCRIPT"

# Copy install.sh into install directory for uninstaller invocation
cp "$0" "$INSTALL_DIR/install.sh" 2>/dev/null || true
chmod +x "$INSTALL_DIR/install.sh" 2>/dev/null || true

# -------------------------------------------------------------
# COMPLETION
# -------------------------------------------------------------
echo -e "\n${GREEN}${BOLD}=========================================================="
echo "    OmniCore Media Engine has been successfully installed!"
echo "==========================================================${NC}"
echo -e "Installation path: ${BOLD}$INSTALL_DIR${NC}"
echo -e "Command line:      ${BOLD}omnicore${NC}"
echo -e "Desktop menu:      Applications -> Audio & Video -> OmniCore Media Engine"
echo -e "Uninstaller:       ${BOLD}$INSTALL_DIR/uninstall.sh${NC}"
echo ""

if [ "$IS_SILENT" -eq 0 ]; then
  read -p "Would you like to launch OmniCore Media Engine now? [Y/n] " launch_resp
  launch_resp=${launch_resp:-Y}
  if [[ "$launch_resp" =~ ^[Yy]$ ]]; then
    echo "Launching OmniCore Media Engine..."
    if [ "$IS_ROOT" -eq 1 ] && [ -n "$SUDO_USER" ] && [ "$SUDO_USER" != "root" ]; then
      sudo -u "$SUDO_USER" DISPLAY="${DISPLAY:-:0}" XAUTHORITY="${XAUTHORITY:-$REAL_HOME/.Xauthority}" "$INSTALL_DIR/OmniCoreMediaEngine" >/dev/null 2>&1 &
    else
      "$INSTALL_DIR/OmniCoreMediaEngine" >/dev/null 2>&1 &
    fi
  fi
fi

exit 0

__ARCHIVE_FOLLOWS__
