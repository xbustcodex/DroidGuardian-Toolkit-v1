![DroidGuardian Toolkit](./droidguardian_banner.png)
[![Version](https://img.shields.io/badge/version-v1.0-blue.svg)](https://github.com/xbustcodex/DroidGuardian-Toolkit-v1.0)
[![Shell](https://img.shields.io/badge/shell-bash-green.svg)](#)
[![Platform](https://img.shields.io/badge/platform-Android%20%7C%20Termux-orange.svg)](#)
[![License](https://img.shields.io/badge/license-MIT-brightgreen.svg)](LICENSE)
# DroidGuardian Toolkit v1.0 🛡️  
Android Device Health, Security & Privacy Auditor (Termux)

**DroidGuardian Toolkit** is a high-level Android auditing toolkit that runs inside **Termux**.  
It focuses on **device health, security posture and privacy permissions** — completely **read‑only** and safe.

No exploits, no payloads, no modifications. Just **clear reports** so you can decide what to fix.

---

## ✨ Features

- 📝 **Device overview**
  - Model, Android version, security patch level, build ID
  - Verified boot state & bootloader hints
  - Google Play / Play Services presence

- 🔐 **Root & security check (heuristic only)**
  - Detects `su` binary and common Magisk packages
  - Basic security recommendations

- 👁 **Privacy permissions scan (user apps only)**
  - Scans user-installed apps for sensitive permissions:
    - Camera, microphone, location
    - SMS, call logs, contacts, calendar
    - External storage access
  - Helps you spot over‑privileged apps

- 💾 **Storage health report**
  - `df -h` filesystem usage
  - Top 15 largest user APKs by size
  - Cleanup recommendations

- 🌐 **Network snapshot**
  - Interfaces (`ip addr`)
  - Routing table (`ip route` / `netstat`)
  - Basic DNS info

- 🧩 **Full audit mode**
  - Runs all checks and saves a full report set in a timestamped folder

All reports are **plain text** and stored under:

```text
~/droidguardian_reports
```

---

## 📥 Requirements

- Android phone or tablet  
- [Termux (F-Droid build recommended)](https://f-droid.org/en/packages/com.termux/)  
- Basic Android command-line tools (usually already present):

```bash
pkg update && pkg upgrade -y
pkg install -y bash coreutils termux-tools
```

For best results also install:

```bash
pkg install -y iproute2
```

---

## 🚀 Installation

Inside Termux:

```bash
cd ~
curl -O https://raw.githubusercontent.com/xbustcodex/DroidGuardian-Toolkit-v1.0/main/droidguardian.sh
chmod +x droidguardian.sh
```

Run it:

```bash
bash droidguardian.sh
```

Optional alias:

```bash
echo 'alias droidguardian="bash ~/droidguardian.sh"' >> ~/.bashrc
source ~/.bashrc
```

Then you can just type:

```bash
droidguardian
```

---

## 🎛 CLI Usage

```bash
bash droidguardian.sh           # interactive menu
bash droidguardian.sh overview  # device overview
bash droidguardian.sh security  # root & security check
bash droidguardian.sh privacy   # privacy permissions scan
bash droidguardian.sh storage   # storage health report
bash droidguardian.sh network   # network snapshot
bash droidguardian.sh audit     # full audit (all checks)
```

Reports are saved under `~/droidguardian_reports`.

---

## ⚖ Legal & Safety Notes

- DroidGuardian Toolkit is **read‑only**:
  - It does not uninstall apps
  - It does not modify settings
  - It does not root your device
- It is intended for:
  - Personal device health checks
  - Privacy-conscious users
  - Education & training

Always double‑check before removing apps or changing security options.  
The author is not responsible for any changes you make as a result of these reports.

---

## 💰 Monetization Ideas

You can use DroidGuardian as a **paid Android health & privacy check-up service**, for example:

- “Android Privacy Check” – scan a client’s phone and send them the report  
- “Device Health Report” – help users free space & review high‑risk apps  
- “Security Posture Review” – combine DroidGuardian + your own advice  

Because it’s read‑only and focused on health / privacy, it’s **safe and friendly** for normal users.

---

## 🛠 Roadmap

- HTML report output
- Simple scoring system (privacy / security / storage)
- Export of summaries to JSON/CSV
