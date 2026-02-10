#!/usr/bin/env bash
set -euo pipefail

# Touch ID for sudo (creates /etc/pam.d/sudo_local if needed).
if [[ -x /usr/bin/sudo ]]; then
  if [[ -f /etc/pam.d/sudo_local ]] && /usr/bin/grep -q 'pam_tid\.so' /etc/pam.d/sudo_local; then
    : # Already configured.
  else
    /usr/bin/sudo /usr/bin/install -m 0644 /dev/stdin /etc/pam.d/sudo_local <<'EOF'
auth       sufficient     pam_tid.so
EOF
  fi
fi

# Startup chime off (NVRAM).
if [[ -x /usr/sbin/nvram ]]; then
  if /usr/sbin/nvram -p 2>/dev/null | /usr/bin/grep -q '^StartupMute[[:space:]]\+%01$'; then
    : # Already muted.
  else
    /usr/bin/sudo /usr/sbin/nvram StartupMute=%01
  fi
fi

# Keyboard remaps: Caps Lock -> Escape.
if [[ -x /usr/bin/hidutil ]]; then
  /usr/bin/hidutil property --set '{"UserKeyMapping":[{"HIDKeyboardModifierMappingSrc":0x700000039,"HIDKeyboardModifierMappingDst":0x700000029}]}'
fi

# Persist key remap across reboots via launchd.
LAUNCH_AGENTS_DIR="${HOME}/Library/LaunchAgents"
HIDUTIL_PLIST="${LAUNCH_AGENTS_DIR}/com.user.hidutil.plist"
if [[ -x /usr/bin/hidutil ]]; then
  /bin/mkdir -p "${LAUNCH_AGENTS_DIR}"
  /bin/cat <<'EOF' > "${HIDUTIL_PLIST}"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
  <dict>
    <key>Label</key>
    <string>com.user.hidutil</string>
    <key>ProgramArguments</key>
    <array>
      <string>/usr/bin/hidutil</string>
      <string>property</string>
      <string>--set</string>
      <string>{"UserKeyMapping":[{"HIDKeyboardModifierMappingSrc":0x700000039,"HIDKeyboardModifierMappingDst":0x700000029}]}</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
  </dict>
</plist>
EOF
  /bin/launchctl unload "${HIDUTIL_PLIST}" >/dev/null 2>&1 || true
  /bin/launchctl load "${HIDUTIL_PLIST}" >/dev/null 2>&1 || true
fi

# Dock
/usr/bin/defaults write com.apple.dock appswitcher-all-displays -bool true
/usr/bin/defaults write com.apple.dock autohide -bool true
/usr/bin/defaults write com.apple.dock autohide-delay -float 0.1
/usr/bin/defaults write com.apple.dock autohide-time-modifier -float 0.5
/usr/bin/defaults write com.apple.dock expose-group-apps -bool true
/usr/bin/defaults write com.apple.dock mineffect -string "scale"
/usr/bin/defaults write com.apple.dock show-recents -bool false

# Finder
/usr/bin/defaults write com.apple.finder _FXSortFoldersFirst -bool true
/usr/bin/defaults write com.apple.finder _FXSortFoldersFirstOnDesktop -bool true
/usr/bin/defaults write com.apple.finder FXPreferredViewStyle -string "clmv"
/usr/bin/defaults write com.apple.finder FXRemoveOldTrashItems -bool true
# New window target: Home
/usr/bin/defaults write com.apple.finder NewWindowTarget -string "PfHm"
/usr/bin/defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/"
/usr/bin/defaults write com.apple.finder ShowPathbar -bool true

# Global
/usr/bin/defaults write NSGlobalDomain AppleShowAllExtensions -bool true
/usr/bin/defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
/usr/bin/defaults write NSGlobalDomain NSAutomaticInlinePredictionEnabled -bool false
/usr/bin/defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false
/usr/bin/defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
/usr/bin/defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
/usr/bin/defaults write NSGlobalDomain NSWindowShouldDragOnGesture -bool true

# Restart affected services to pick up changes.
/usr/bin/killall Dock >/dev/null 2>&1 || true
/usr/bin/killall Finder >/dev/null 2>&1 || true
