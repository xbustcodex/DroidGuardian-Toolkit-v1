#!/usr/bin/env bash
# DroidGuardian Toolkit v1.0
# Android Device Health, Security & Privacy Auditor for Termux
# Read-only checks only. No changes are made to the system.

VERSION="1.0"
BASE_DIR="$HOME/droidguardian_reports"

banner() {
  clear
  echo "============================================================="
  echo "                 DroidGuardian Toolkit v$VERSION              "
  echo "        Android Device Health & Privacy Auditor (Termux)     "
  echo "============================================================="
  echo
}

legal_notice() {
  echo "LEGAL / SAFETY NOTE:"
  echo "  - DroidGuardian is a read-only auditor. It does NOT modify"
  echo "    your system, uninstall apps, or change settings."
  echo "  - Results are informational only. Always double-check before"
  echo "    removing apps or changing security options."
  echo
}

pause() {
  echo
  read -p "Press Enter to continue..." _
}

ensure_dirs() {
  mkdir -p "$BASE_DIR"
}

timestamp() {
  date +%Y%m%d_%H%M%S
}

device_overview() {
  ensure_dirs
  local ts report
  ts="$(timestamp)"
  report="$BASE_DIR/device_overview_$ts.txt"

  {
    echo "DroidGuardian Toolkit v$VERSION - Device Overview"
    echo "Generated: $(date)"
    echo
    echo "=== Device Info ==="
    echo "Model:          $(getprop ro.product.model)"
    echo "Manufacturer:   $(getprop ro.product.manufacturer)"
    echo "Device:         $(getprop ro.product.device)"
    echo "Android Ver:    $(getprop ro.build.version.release)"
    echo "SDK Level:      $(getprop ro.build.version.sdk)"
    echo "Build ID:       $(getprop ro.build.id)"
    echo "Security Patch: $(getprop ro.build.version.security_patch)"
    echo
    echo "=== Boot / Verified Boot (heuristic) ==="
    echo "Verified boot state:  $(getprop ro.boot.verifiedbootstate)"
    echo "Bootloader unlock support: $(getprop ro.oem_unlock_supported)"
    echo "Bootloader: $(getprop ro.bootloader)"
    echo
    echo "=== Google Services Presence ==="
    echo "Google Play Store:  $(pm list packages | grep -q com.android.vending && echo 'installed' || echo 'not detected')"
    echo "Google Play Services:  $(pm list packages | grep -q com.google.android.gms && echo 'installed' || echo 'not detected')"
    echo
  } > "$report"

  echo "[+] Device overview written to: $report"
  pause
}

root_and_security_check() {
  ensure_dirs
  local ts report
  ts="$(timestamp)"
  report="$BASE_DIR/security_check_$ts.txt"

  {
    echo "DroidGuardian Toolkit v$VERSION - Root & Security Check"
    echo "Generated: $(date)"
    echo

    echo "=== Root / Magisk Detection (heuristic only) ==="
    if command -v su >/dev/null 2>&1 || [ -x /system/bin/su ] || [ -x /system/xbin/su ]; then
      echo "su binary: PRESENT (device likely rooted or had root tools installed)"
    else
      echo "su binary: not found in common locations."
    fi

    echo
    echo "Magisk app package:"
    if pm list packages | grep -qi magisk; then
      pm list packages | grep -i magisk
    else
      echo "No Magisk-related package detected via pm list."
    fi

    echo
    echo "=== Lock-screen / basic security hints ==="
    echo "This section is limited from Termux. Check manually:"
    echo "  - Strong screen lock (PIN/Password/Biometrics)"
    echo "  - Unknown sources disabled (unless needed)"
    echo "  - Play Protect enabled"
    echo
    echo "=== Recommendation (general) ==="
    echo "  - If you do not intentionally use root, investigate any 'su' or Magisk traces."
    echo "  - Keep your device updated to the latest Android security patch where possible."
    echo
  } > "$report"

  echo "[+] Security check report written to: $report"
  pause
}

privacy_permissions_scan() {
  ensure_dirs
  local ts report
  ts="$(timestamp)"
  report="$BASE_DIR/privacy_scan_$ts.txt"

  echo "[*] This may take a bit depending on number of installed apps..."
  echo

  # Sensitive permissions to check
  local perms=(
    "android.permission.CAMERA"
    "android.permission.RECORD_AUDIO"
    "android.permission.ACCESS_FINE_LOCATION"
    "android.permission.ACCESS_COARSE_LOCATION"
    "android.permission.READ_CONTACTS"
    "android.permission.READ_SMS"
    "android.permission.SEND_SMS"
    "android.permission.READ_CALL_LOG"
    "android.permission.READ_CALENDAR"
    "android.permission.READ_EXTERNAL_STORAGE"
    "android.permission.WRITE_EXTERNAL_STORAGE"
  )

  # Get list of user apps
  mapfile -t apps < <(pm list packages -3 | sed 's/^package://g' | sort)

  {
    echo "DroidGuardian Toolkit v$VERSION - Privacy Permissions Scan"
    echo "Generated: $(date)"
    echo
    echo "Scanning $((${#apps[@]})) user-installed apps for sensitive permissions..."
    echo

    for perm in "${perms[@]}"; do
      echo "============================================================="
      echo "Permission: $perm"
      echo "-------------------------------------------------------------"
      local any=0
      for pkg in "${apps[@]}"; do
        if dumpsys package "$pkg" 2>/dev/null | grep -q "$perm"; then
          echo "$pkg"
          any=1
        fi
      done
      if [ "$any" -eq 0 ]; then
        echo "(no user apps with this permission found)"
      fi
      echo
    done

    echo "============================================================="
    echo "NOTE:"
    echo "  - System apps are not listed here to avoid noise."
    echo "  - Some permissions may be granted at runtime (user choice)."
    echo "  - Use this report to review which apps have access to"
    echo "    camera, mic, location, SMS, contacts and files."
  } > "$report"

  echo "[+] Privacy permissions report written to: $report"
  pause
}

storage_health_check() {
  ensure_dirs
  local ts report
  ts="$(timestamp)"
  report="$BASE_DIR/storage_health_$ts.txt"

  {
    echo "DroidGuardian Toolkit v$VERSION - Storage Health Check"
    echo "Generated: $(date)"
    echo
    echo "=== Filesystem usage (df -h) ==="
    df -h
    echo
    echo "=== Approximate APK sizes for largest user apps ==="
    echo "(Top 15 by APK file size – does NOT include app data/cache)"
    echo

    # Collect apk sizes for user apps
    pm list packages -3 | sed 's/^package://g' | while read -r pkg; do
      apk_path=$(pm path "$pkg" 2>/dev/null | head -n1 | sed 's/^package://g')
      if [ -n "$apk_path" ] && [ -f "$apk_path" ]; then
        size=$(du -m "$apk_path" 2>/dev/null | awk '{print $1}')
        echo "$size MB - $pkg"
      fi
    done | sort -nr | head -n 15

    echo
    echo "=== Recommendations (general) ==="
    echo "  - Consider uninstalling apps you no longer use, especially those"
    echo "    listed above with large APK sizes."
    echo "  - Clear app cache from Android settings for storage-intensive apps."
    echo "  - Move media (photos/videos) to SD card or cloud if space is low."
  } > "$report"

  echo "[+] Storage health report written to: $report"
  pause
}

network_snapshot() {
  ensure_dirs
  local ts report
  ts="$(timestamp)"
  report="$BASE_DIR/network_snapshot_$ts.txt"

  {
    echo "DroidGuardian Toolkit v$VERSION - Network Snapshot"
    echo "Generated: $(date)"
    echo
    echo "=== Active Interfaces (ip addr) ==="
    if command -v ip >/dev/null 2>&1; then
      ip addr show
    else
      ifconfig 2>/dev/null || echo "ip/ifconfig not available."
    fi
    echo
    echo "=== Current Routing Table ==="
    if command -v ip >/dev/null 2>&1; then
      ip route show
    else
      netstat -rn 2>/dev/null || echo "ip/netstat not available."
    fi
    echo
    echo "=== DNS Configuration (if resolv.conf exists) ==="
    [ -f /system/etc/resolv.conf ] && cat /system/etc/resolv.conf || echo "No resolv.conf readable from Termux."
    echo
  } > "$report"

  echo "[+] Network snapshot written to: $report"
  pause
}

full_audit() {
  ensure_dirs
  local ts dir
  ts="$(timestamp)"
  dir="$BASE_DIR/audit_$ts"
  mkdir -p "$dir"

  echo "[*] Running full audit, this may take a few minutes..."
  echo

  local report

  report="$dir/device_overview.txt"
  {
    echo "DroidGuardian Toolkit v$VERSION - Device Overview"
    echo "Generated: $(date)"
    echo
    echo "=== Device Info ==="
    echo "Model:          $(getprop ro.product.model)"
    echo "Manufacturer:   $(getprop ro.product.manufacturer)"
    echo "Device:         $(getprop ro.product.device)"
    echo "Android Ver:    $(getprop ro.build.version.release)"
    echo "SDK Level:      $(getprop ro.build.version.sdk)"
    echo "Build ID:       $(getprop ro.build.id)"
    echo "Security Patch: $(getprop ro.build.version.security_patch)"
    echo
  } > "$report"

  report="$dir/security_check.txt"
  {
    echo "=== Root / Magisk Detection (heuristic only) ==="
    if command -v su >/dev/null 2>&1 || [ -x /system/bin/su ] || [ -x /system/xbin/su ]; then
      echo "su binary: PRESENT (device likely rooted or had root tools installed)"
    else
      echo "su binary: not found in common locations."
    fi
    echo
    echo "Magisk app package:"
    if pm list packages | grep -qi magisk; then
      pm list packages | grep -i magisk
    else
      echo "No Magisk-related package detected via pm list."
    fi
  } > "$report"

  local privacy_report="$dir/privacy_scan.txt"
  echo "[*] Running privacy permissions scan..."
  local perms=(
    "android.permission.CAMERA"
    "android.permission.RECORD_AUDIO"
    "android.permission.ACCESS_FINE_LOCATION"
    "android.permission.ACCESS_COARSE_LOCATION"
    "android.permission.READ_CONTACTS"
    "android.permission.READ_SMS"
    "android.permission.SEND_SMS"
    "android.permission.READ_CALL_LOG"
    "android.permission.READ_CALENDAR"
    "android.permission.READ_EXTERNAL_STORAGE"
    "android.permission.WRITE_EXTERNAL_STORAGE"
  )
  mapfile -t apps < <(pm list packages -3 | sed 's/^package://g' | sort)
  {
    echo "DroidGuardian Toolkit v$VERSION - Privacy Permissions Scan"
    echo
    for perm in "${perms[@]}"; do
      echo "============================================================="
      echo "Permission: $perm"
      echo "-------------------------------------------------------------"
      local any=0
      for pkg in "${apps[@]}"; do
        if dumpsys package "$pkg" 2>/dev/null | grep -q "$perm"; then
          echo "$pkg"
          any=1
        fi
      done
      [ "$any" -eq 0 ] && echo "(no user apps with this permission found)"
      echo
    done
  } > "$privacy_report"

  local storage_report="$dir/storage_health.txt"
  {
    echo "=== Filesystem usage (df -h) ==="
    df -h
    echo
    echo "=== Approximate APK sizes for largest user apps ==="
    pm list packages -3 | sed 's/^package://g' | while read -r pkg; do
      apk_path=$(pm path "$pkg" 2>/dev/null | head -n1 | sed 's/^package://g')
      if [ -n "$apk_path" ] && [ -f "$apk_path" ]; then
        size=$(du -m "$apk_path" 2>/dev/null | awk '{print $1}')
        echo "$size MB - $pkg"
      fi
    done | sort -nr | head -n 15
  } > "$storage_report"

  local net_report="$dir/network_snapshot.txt"
  {
    echo "=== Active Interfaces (ip addr) ==="
    if command -v ip >/dev/null 2>&1; then
      ip addr show
    else
      ifconfig 2>/dev/null || echo "ip/ifconfig not available."
    fi
    echo
    echo "=== Routing Table ==="
    if command -v ip >/dev/null 2>&1; then
      ip route show
    else
      netstat -rn 2>/dev/null || echo "ip/netstat not available."
    fi
  } > "$net_report"

  echo "[+] Full audit complete."
  echo "[+] All reports saved under: $dir"
  pause
}

usage() {
  cat <<EOF
DroidGuardian Toolkit v$VERSION - Android Device Auditor (Termux)

Usage:
  droidguardian.sh           # launch menu
  droidguardian.sh menu      # launch menu
  droidguardian.sh overview  # device overview report
  droidguardian.sh security  # root & security heuristic report
  droidguardian.sh privacy   # privacy permissions scan
  droidguardian.sh storage   # storage health report
  droidguardian.sh network   # network snapshot
  droidguardian.sh audit     # full audit (all of the above)

Reports are stored under:
  $BASE_DIR

EOF
}

menu() {
  while true; do
    banner
    legal_notice
    echo "Reports directory: $BASE_DIR"
    echo
    echo "1) Device overview"
    echo "2) Root & security check"
    echo "3) Privacy permissions scan"
    echo "4) Storage health report"
    echo "5) Network snapshot"
    echo "6) Full audit (all checks)"
    echo "0) Exit"
    echo
    read -p "Select an option: " choice
    echo
    case "$choice" in
      1) device_overview ;;
      2) root_and_security_check ;;
      3) privacy_permissions_scan ;;
      4) storage_health_check ;;
      5) network_snapshot ;;
      6) full_audit ;;
      0) echo "Bye."; exit 0 ;;
      *) echo "Invalid choice."; pause ;;
    esac
  done
}

main() {
  ensure_dirs
  case "$1" in
    ""|menu) menu ;;
    overview) device_overview ;;
    security) root_and_security_check ;;
    privacy) privacy_permissions_scan ;;
    storage) storage_health_check ;;
    network) network_snapshot ;;
    audit) full_audit ;;
    -h|--help|help) usage ;;
    *) echo "Unknown option: $1"; usage; exit 1 ;;
  esac
}

main "$@"
