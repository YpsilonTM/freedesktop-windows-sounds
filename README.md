# Freedesktop Windows Sounds

The classic Linux **freedesktop** sound theme (yes, including the water-drop `bell`) packaged as a one-click Windows sound scheme.

Upstream is [`sound-theme-freedesktop`](https://gitlab.freedesktop.org/xdg/xdg-sound-theme) — the same pack Arch / CachyOS / GNOME fall back to for system alerts.

## Install

1. Download / clone this repo
2. Double-click `install.cmd`  
   or in PowerShell:

```powershell
.\scripts\Install-FreedesktopSounds.ps1
```

Sounds are copied to `%LOCALAPPDATA%\FreedesktopSoundTheme` and the scheme **Freedesktop** is registered + activated for your user.

Preview / tweak events under:  
**Settings → System → Sound → More sound settings → Sounds**

## Uninstall

Double-click `uninstall.cmd`, or:

```powershell
.\scripts\Uninstall-FreedesktopSounds.ps1
```

That switches you back to the Windows `.Default` scheme and removes the installed files.

## What maps where

| Windows event | Freedesktop sound |
|---|---|
| Default Beep | `bell` (water drop) |
| Asterisk | `dialog-information` |
| Exclamation | `dialog-warning` |
| Critical Stop | `dialog-error` |
| Question | `window-question` |
| Notification / Mail | `message` / `message-new-instant` |
| Device Connect / Disconnect | `device-added` / `device-removed` |
| Windows Logon / Logoff / Unlock | `service-login` / `service-logout` |
| Empty Recycle Bin | `trash-empty` |
| Battery / Alarm notifications | `alarm-clock-elapsed` |
| Incoming call notification | `phone-incoming-call` |
| Print Complete | `complete` |

Extra WAVs (`camera-shutter`, `audio-volume-change`, …) ship in `sounds\` if you want to wire them manually.

## Rebuild WAVs from upstream (optional)

Needs Docker:

```powershell
# drop a sound-theme-freedesktop .pkg.tar.zst into source\pack.bin, extract, then:
docker run --rm -v "${PWD}:/work" -w /work alpine sh /work/scripts/convert.sh
```

## License / credits

- **Installer scripts** in this repo: MIT (see `LICENSE`)
- **Sound files**: unchanged from upstream freedesktop theme — mixed CC-BY / CC-BY-SA / GPL. See `CREDITS` and `NOTICE`.
