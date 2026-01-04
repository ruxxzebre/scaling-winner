# PAYDAY 2 Modpack (Scaling Winner)

A curated collection of mods for PAYDAY 2.

## Prerequisites

### Windows

You're good!

### Linux (IMPORTANT!)

- In the `Compatibility tab` in the `game properties` make sure to select `Proton Experimental`
- Add these `Launch options` in the `General tab` in the `Properties` of the game: `WINEDLLOVERRIDES="wsock32=n,b" %command%`

## Installation

### Quick Installation

Run in terminal from your PAYDAY 2 folder:

**Windows (PowerShell):**

```powershell
iwr -Uri "https://raw.githubusercontent.com/ruxxzebre/scaling-winner/main/modpack_update.ps1" -UseBasicParsing | iex
```

**Linux (Proton):**

```bash
wget -qO- https://raw.githubusercontent.com/ruxxzebre/scaling-winner/main/modpack_update.sh | sh
```

### Manual Installation

Download [latest modpack archive](https://github.com/ruxxzebre/scaling-winner/archive/refs/heads/main.zip) and run the updater script from your PAYDAY 2 folder:

Windows:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\modpack_update.ps1
```

Linux:

```bash
sh ./modpack_update.sh
```

### Clone and Copy

```bash
git clone https://github.com/ruxxzebre/scaling-winner.git
# Then copy the mods/ and assets/mod_overrides/ folders to your PAYDAY 2 directory
```

### Updating

Re-run the Quick Installation commands above, or use `git stash && git pull` if you cloned the repo.

## Mods Included

[SuperBLT](https://superblt.znix.xyz/) - Required mod loader for PAYDAY 2

### BLT Mods (`mods/`)

| Mod                            | Description                                        | Repository                                       | Author        |
| ------------------------------ | -------------------------------------------------- | ------------------------------------------------ | ------------- |
| Modpack Updater                | In-game menu to update modpack from GitHub         | mods/ModpackUpdater                              | @ruxxzebre    |
| Any Day Any Heist              | Play any heist on any day, skip day requirements   | [ModWorkshop](https://modworkshop.net/mod/43232) | @Hacker_lyx   |
| Borderless Windowed Updated    | Run the game in borderless windowed mode           | [ModWorkshop](https://modworkshop.net/mod/27683) | @Shatyuka     |
| Dynamic Weapon Animations      | Adds realistic weapon sway and movement animations | [ModWorkshop](https://modworkshop.net/mod/45913) | @Roko         |
| Endscreen XP List              | Shows detailed XP breakdown on heist end screen    | [ModWorkshop](https://modworkshop.net/mod/42283) | @zReko        |
| Hotline Miami Hud              | Replaces HUD with Hotline Miami inspired style     | [ModWorkshop](https://modworkshop.net/mod/27294) | @Eightan      |
| Advanced Crosshairs            | Highly customizable crosshair options              | [ModWorkshop](https://modworkshop.net/mod/29585) | @Offyerrocker |
| QuickChat                      | Quick chat wheel for fast team communication       | [ModWorkshop](https://modworkshop.net/mod/30917) | @sl0nderman   |
| Realtime XP                    | Shows XP gains in real-time during heists          | [ModWorkshop](https://modworkshop.net/mod/34540) | @James        |
| Tacticool Sprint               | Tactical sprint animations with weapon lowering    | [ModWorkshop](https://modworkshop.net/mod/43232) | @EUPHORIA     |
| The Fixes                      | Community-driven collection of bug fixes           | [ModWorkshop](https://modworkshop.net/mod/23732) | @Dom          |
| Ultrawide Fix                  | Fixes UI scaling issues for ultrawide monitors     | [ModWorkshop](https://modworkshop.net/mod/32486) | @powware      |
| VanillaHUD Plus                | Enhanced vanilla HUD with additional features      | [ModWorkshop](https://modworkshop.net/mod/43232) | @test1        |
| Stop crime spree crash on join | Fixes crashes on joining high crime spree lobbies  | [ModWorkshop](https://modworkshop.net/mod/21026) | @<Pipemax32>  |
| Math Helper Updated            | Helps in Rats and Cookoff jobs                     | [ModWorkshop](https://modworkshop.net/mod/25950) | @Offyerrocker |

### Override Mods (`assets/mod_overrides/`)

| Mod                   | Description                              | Source                                                 | Author          |
| --------------------- | ---------------------------------------- | ------------------------------------------------------ | --------------- |
| Hotline Miami Menu    | Hotline Miami themed main menu and music | [ModWorkshop](https://modworkshop.net/mod/27294)       | @Eightan        |
| The Particle Massacre | Improved particles all across the board  | [ModWorkshop](https://modworkshop.net/mod/37435)       | @ZLBBR          |
| UA Grivna             | Replace USD bills with UAH               | [NexusMods](https://www.nexusmods.com/payday2/mods/76) | @Z3BRO/@davakim |

Thanks to the mod developers who made these amazing mods
And to the PAYDAY 2 modding community for keeping the game alive.

### Custom mod settings (Payday 2/mods/saves)

- VanillaHUD Plus: Health circle is turn off in favor of health bar for enemies
- Advanced Crosshairs: TODO
- Quick Chat: TODO

## Notes

- Some mods may require configuration. Check individual mod folders for settings. (Modpack is good as-is and provides comfortable defaults)
- If you encounter issues after a game update, pull the latest version of this repo. If issue is not fixed - [report as issue](https://github.com/ruxxzebre/scaling-winner/issues/new/choose).

## License

This repository is a collection of mods made by their respective authors. All mods remain property of their original creators. See individual mods for their specific licenses.

## TODO

- Update scripts should replace saves (mod configs) when Force Update option is selected in Modpack Updater menu
- Remove dev files (lua bindings/dev folder) from downloaded modpack zip archive
- Tests for update scripts
- Add options to disable optional mods like UA Grivna and The Particle Massacre
- Add options to disable helper/time-saver mods like Math Helper and similar ones, like those which show the key cards right away or highlight correct PC to hack in big bank heist
- Add option to hide mod options from the payday menus to prevent unnecessary configuration
- Github Action that builds the modpack
- Update scripts should try to detect if they're in Payday 2 folder and short circuit if not (and have a test mode that disables such flag)
- Update scripts should try to find a Payday 2 folder in default system locations if script was executed not from Payday 2 folder, shor tciruit otherwise

## Other handy goodies:

- `-skip_intro` flag in `Launch Options` disabled intro videos
