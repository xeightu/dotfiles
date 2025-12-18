#!/bin/bash
# ┌──────────────────────────────────────────────────┐
# │           MAINTENANCE ACTIONS LIBRARY            │
# └──────────────────────────────────────────────────┘

# --- Colors ---
C_RED='\033[1;31m'
C_GREEN='\033[1;32m'
C_YELLOW='\033[1;33m'
C_BLUE='\033[1;34m'
C_CYAN='\033[1;36m'
C_NC='\033[0m' # No Color

# --- Helper: Print Header ---
print_header() {
  printf "\n${C_BLUE}=================================================================${C_NC}\n"
  printf "${C_BLUE}  $1${C_NC}\n"
  printf "${C_BLUE}=================================================================${C_NC}\n"
}

# --- Helper: Ask User ---
ask_user() {
  local prompt="$1"
  local reply

  while true; do
    read -p "$(echo -e "${C_YELLOW}$prompt [y/n]:${C_NC} ")" -n 1 -r reply
    echo "" # New line
    case $reply in
    [Yy]*) return 0 ;;
    [Nn]*) return 1 ;;
    *) printf "  ${C_RED}Invalid input. Please press 'y' or 'n'.${C_NC}\n" ;;
    esac
  done
}

# --- Helper: Check Internet (Redundant) ---
check_internet() {
  if ! ping -c 1 -W 2 8.8.8.8 &>/dev/null && ! ping -c 1 -W 2 1.1.1.1 &>/dev/null; then
    printf "${C_RED}[ERROR] No internet connection. Aborting maintenance.${C_NC}\n"
    return 1
  fi
  return 0
}

# --- Function: Arch News ---
check_arch_news() {
  print_header "CHECKING ARCH LINUX NEWS"
  if ! command -v curl &>/dev/null; then
    printf "${C_YELLOW}Curl not found, skipping news.${C_NC}\n"
    return
  fi

  printf "${C_YELLOW}Fetching latest headlines...${C_NC}\n"
  curl -s --connect-timeout 5 "https://archlinux.org/feeds/news/" | python3 -c "
import sys
import xml.etree.ElementTree as ET
try:
    tree = ET.parse(sys.stdin)
    root = tree.getroot()
    count = 0
    for item in root.findall('./channel/item'):
        if count >= 4: break
        title = item.find('title').text
        pubDate = item.find('pubDate').text
        date_clean = ' '.join(pubDate.split(' ')[:3])
        print(f' \033[1;33m[{date_clean}]\033[0m \033[1;37m{title}\033[0m')
        count += 1
except Exception:
    print('\033[1;30m(No news or parsing error)\033[0m')
"
  printf "\n"
}

# --- Function: Update Mirrors ---
update_mirrors() {
  print_header "OPTIMIZING MIRRORS"

  if command -v rate-mirrors &>/dev/null; then
    if ask_user "Run rate-mirrors to find fastest servers?"; then
      export TMPFILE="$(mktemp)"
      printf "${C_CYAN}:: Benchmarking mirrors (this may take a while)...${C_NC}\n"
      rate-mirrors --save "$TMPFILE" arch --max-delay=21600 &&
        sudo mv "$TMPFILE" /etc/pacman.d/mirrorlist &&
        sudo chmod 644 /etc/pacman.d/mirrorlist &&
        printf "${C_GREEN}Mirrorlist updated successfully.${C_NC}\n"
      rm -f "$TMPFILE"
    fi
  elif command -v reflector &>/dev/null; then
    if ask_user "Run reflector to sort mirrors?"; then
      sudo reflector --latest 10 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
      printf "${C_GREEN}Mirrorlist updated.${C_NC}\n"
    fi
  else
    printf "${C_RED}No mirror tool found. Install rate-mirrors-bin or reflector.${C_NC}\n"
  fi
}

# --- Function: System Update ---
perform_update() {
  check_internet || return 1
  print_header "SYSTEM UPDATE"

  local LOG_FILE=${PACMAN_LOG:-"/tmp/pacman_update.fallback.log"}

  sudo -v

  # 1. pacman + yay
  if command -v yay &>/dev/null; then
    printf "${C_CYAN}:: Updating System (Official Repos + AUR)...${C_NC}\n"

    yay -Syu --sudoloop --logfile "$LOG_FILE"

    if [ $? -ne 0 ]; then
      printf "${C_RED}Error during update. Aborting.${C_NC}\n"
      return 1
    fi

  else
    # Fallback
    printf "${C_YELLOW}Yay not found. Falling back to Pacman only.${C_NC}\n"
    printf "${C_CYAN}:: Updating Core Packages (Pacman)...${C_NC}\n"
    sudo pacman -Syu --logfile "$LOG_FILE"
    if [ $? -ne 0 ]; then
      printf "${C_RED}Critical error during pacman update. Aborting.${C_NC}\n"
      return 1
    fi
  fi

  # 2. Flatpak
  if command -v flatpak &>/dev/null; then
    printf "\n${C_CYAN}:: Updating Flatpaks...${C_NC}\n"
    flatpak update
  fi

  printf "\n${C_GREEN}Update phase completed.${C_NC}\n"
}

# --- Function: System Cleanup ---
perform_cleanup() {
  print_header "PERFORMING SYSTEM CLEANUP"

  # 1. Orphan Cleanup
  local ORPHANS=$(pacman -Qdtq 2>/dev/null)
  if [ -n "$ORPHANS" ]; then
    local COUNT=$(echo "$ORPHANS" | wc -w)
    printf "\n${C_CYAN}:: Found $COUNT orphan package(s).${C_NC}\n"

    if ask_user "Remove orphans?"; then
      sudo pacman -Rns $ORPHANS
    else
      printf "Skipping orphans.\n"
    fi
  else
    printf "${C_GREEN}No orphan packages found.${C_NC}\n"
  fi

  # 2. Pacman Cache
  if command -v paccache &>/dev/null; then
    printf "\n${C_CYAN}:: Pacman Cache Cleaning${C_NC}\n"
    if ask_user "Clean pacman cache (keep last 2 versions)?"; then
      sudo paccache -rk2
    fi
  fi

  # 3. AUR Cache
  if command -v yay &>/dev/null; then
    printf "\n${C_CYAN}:: AUR Cache Cleaning${C_NC}\n"
    if ask_user "Run AUR cache cleaner (yay -Sc)?"; then
      yay -Sc
    fi
  fi

  # 4. Flatpak Cleanup
  if command -v flatpak &>/dev/null; then
    printf "\n${C_CYAN}:: Flatpak Cleanup${C_NC}\n"
    if ask_user "Uninstall unused Flatpak runtimes?"; then
      flatpak uninstall --unused
    fi
  fi

  # 5. Journald
  printf "\n${C_CYAN}:: System Logs (Journald)${C_NC}\n"
  if ask_user "Vacuum system logs (keep only 50M)?"; then
    sudo journalctl --vacuum-size=50M
  fi

  printf "${C_GREEN}System cleanup phase completed.${C_NC}\n"
}

# --- Function: Timeshift Snapshot (Custom Rotation) ---
create_snapshot() {
  print_header "SMART TIMESHIFT SNAPSHOT"
  if ! command -v timeshift &>/dev/null; then
    printf "${C_YELLOW}Timeshift not installed, skipping.${C_NC}\n"
    return 0
  fi

  if ! ask_user "Create a new Timeshift snapshot now?" "y"; then
    printf "Skipping snapshot creation.\n"
    return 0
  fi

  local SNAP_COMMENT="Pre-update snapshot"
  local MAX_SNAPSHOTS=5

  printf "${C_YELLOW}Creating new snapshot...${C_NC}\n"
  sudo timeshift --create --comments "$SNAP_COMMENT" --tags D

  if [ $? -ne 0 ]; then
    printf "${C_RED}Snapshot creation failed.${C_NC}\n"
    return 1
  fi
  printf "${C_GREEN}Snapshot created successfully.${C_NC}\n"

  printf "\n${C_YELLOW}Checking rotation limits (Max: $MAX_SNAPSHOTS)...${C_NC}\n"

  local SNAP_LIST
  SNAP_LIST=$(sudo timeshift --list | grep "$SNAP_COMMENT" | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}_[0-9]{2}-[0-9]{2}-[0-9]{2}' | sort)

  local COUNT
  COUNT=$(echo "$SNAP_LIST" | grep -cve '^\s*$') # считаем непустые строки

  if [ "$COUNT" -gt "$MAX_SNAPSHOTS" ]; then
    local REMOVE_COUNT=$((COUNT - MAX_SNAPSHOTS))
    printf "${C_CYAN}:: Found $COUNT snapshots. Removing $REMOVE_COUNT oldest...${C_NC}\n"

    local TO_DELETE
    TO_DELETE=$(echo "$SNAP_LIST" | head -n "$REMOVE_COUNT")

    for SNAP_NAME in $TO_DELETE; do
      if [ -n "$SNAP_NAME" ]; then
        printf "  -> Deleting: ${C_RED}$SNAP_NAME${C_NC}\n"
        sudo timeshift --delete --snapshot "$SNAP_NAME" --yes
      fi
    done
    printf "${C_GREEN}Rotation complete.${C_NC}\n"
  else
    printf "${C_GREEN}Count ($COUNT) is within limit ($MAX_SNAPSHOTS). No deletion needed.${C_NC}\n"
  fi

  printf "\n${C_CYAN}:: Current Snapshots List:${C_NC}\n"
  sudo timeshift --list
}

# --- Function: Security Scans ---
perform_scans() {
  print_header "SECURITY CHECKS"

  if command -v rkhunter &>/dev/null; then
    if ask_user "Run Rkhunter scan?"; then
      sudo rkhunter --check --sk 2>/dev/null
    fi
  else
    printf "${C_YELLOW}Rkhunter not installed.${C_NC}\n"
  fi

  if command -v lynis &>/dev/null; then
    if ask_user "Run Lynis system audit?"; then
      echo "Starting Lynis..."
      sudo lynis audit system | grep "Score"
    fi
  else
    printf "${C_YELLOW}Lynis not installed.${C_NC}\n"
  fi
}
