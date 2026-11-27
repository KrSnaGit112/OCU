# Velotoma Updates & Releases (OCU)

Official public release and distribution channel for **Velotoma Media Engine** & **Velotoma Web Assistant**.

---

## 🪟 Windows Installation (3 Simple Ways)

### 1. 1-Line PowerShell Command (Recommended)
Open **PowerShell** or **Windows Terminal** and run:

```powershell
irm https://raw.githubusercontent.com/KrSnaGit112/OCU/main/install.ps1 | iex
```
*(Automatically fetches the latest release manifest, verifies SHA-256 checksum, and installs cleanly.)*

---

### 2. Double-Click Command Runner (`run_install.cmd`)
1. Download [run_install.cmd](https://raw.githubusercontent.com/KrSnaGit112/OCU/main/run_install.cmd).
2. Double-click `run_install.cmd` (works both alongside a downloaded `.exe` or standalone via PowerShell bootstrapper).

---

### 3. Direct Graphical Wizard (`.exe`)
Download `Velotoma-Media-Engine-Setup-v*.exe` directly from **[Latest Releases](https://github.com/KrSnaGit112/OCU/releases/latest)** and run the installer wizard.

---

## 🚀 Linux Installation (3 Simple Ways)

### 1. Universal Terminal Command (Recommended)
Open your terminal and run:

```bash
wget -O install.sh https://raw.githubusercontent.com/KrSnaGit112/OCU/main/install.sh && bash install.sh
```
*(For system-wide installation to `/opt/omnicore`, run with `sudo bash install.sh`).*

---

### 2. 1-Click Script (`quick-install.sh`)
1. Download [quick-install.sh](https://raw.githubusercontent.com/KrSnaGit112/OCU/main/quick-install.sh).
2. Run it in terminal:
```bash
bash quick-install.sh
```
*(Or right-click the file and choose **Run in Terminal**).*

---

### 3. Double-Click Desktop Installer (`Install-OmniCore.desktop`)
1. Download [Install-OmniCore.desktop](https://raw.githubusercontent.com/KrSnaGit112/OCU/main/Install-OmniCore.desktop).
2. Right-click the file and select **Allow Launching** (on Linux Mint / Cinnamon / GNOME).
3. Double-click to start the visual terminal installation.

---

## 📦 Direct Downloads & Releases

| Package | Platform | Format | Description |
| :--- | :--- | :--- | :--- |
| **Windows Master Setup** | Windows x64 | `.exe` | Single-file graphical wizard |
| **Windows 1-Click Script** | Windows x64 | `.ps1` / `.cmd` | Verified automated Windows runner (`install.ps1` / `run_install.cmd`) |
| **Linux Setup Bundle** | Linux x64 | `.sh` | Standalone offline self-extracting archive |
| **Linux Tarball** | Linux x64 | `.tar.gz` | Portable application archive |
| **Web Assistant Companion** | All | `.crx` | Cryptographically signed browser extension |

👉 **[View All Release Assets & Checksums](https://github.com/KrSnaGit112/OCU/releases/latest)**
