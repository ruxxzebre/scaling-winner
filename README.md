# PAYDAY 2 Modpack (Scaling Winner)

A curated collection of mods for PAYDAY 2.

## Prerequisites

- `-skip_intro` flag in `Launch Options` (optional)

### Linux

- In the `Compatibility tab` in the `game properties` make sure to select `Proton Experimental`
- Add these `Launch options` in the `General tab` in the `Properties` of the game: `WINEDLLOVERRIDES="wsock32=n,b" %command%`

## Installation

### Option 1: Clone directly into PAYDAY 2 folder

```bash
# Navigate to your PAYDAY 2 installation folder
cd "C:\Program Files (x86)\Steam\steamapps\common\PAYDAY 2"

# Clone directly into current directory
git clone https://github.com/ruxxzebre/scaling-winner.git .
```

### Option 2: Clone and copy

```bash
git clone https://github.com/ruxxzebre/scaling-winner.git
# Then copy the mods/ and assets/mod_overrides/ folders to your PAYDAY 2 directory
```

### Updating

Run the updater script from your PAYDAY 2 folder:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\modpack_update.ps1
```

Or run it inline with curl:

```powershell
curl -L https://raw.githubusercontent.com/ruxxzebre/scaling-winner/main/modpack_update.ps1 | powershell -NoProfile -ExecutionPolicy Bypass -
```

On Linux:

```bash
sh ./modpack_update.sh
```

Inline with curl:

```bash
curl -L https://raw.githubusercontent.com/ruxxzebre/scaling-winner/main/modpack_update.sh | sh
```

## Mods Included

[SuperBLT](https://superblt.znix.xyz/) - Required mod loader for PAYDAY 2

### BLT Mods (`mods/`)

| Mod                         | Description                                        | Repository                                       | Author        |
| --------------------------- | -------------------------------------------------- | ------------------------------------------------ | ------------- |
| Any Day Any Heist           | Play any heist on any day, skip day requirements   | [ModWorkshop](https://modworkshop.net/mod/43232) | @Hacker_lyx   |
| Borderless Windowed Updated | Run the game in borderless windowed mode           | [ModWorkshop](https://modworkshop.net/mod/27683) | @Shatyuka     |
| Dynamic Weapon Animations   | Adds realistic weapon sway and movement animations | [ModWorkshop](https://modworkshop.net/mod/45913) | @Roko         |
| Endscreen XP List           | Shows detailed XP breakdown on heist end screen    | [ModWorkshop](https://modworkshop.net/mod/42283) | @zReko        |
| Hotline Miami Hud           | Replaces HUD with Hotline Miami inspired style     | [ModWorkshop](https://modworkshop.net/mod/27294) | @Eightan      |
| Advanced Crosshairs         | Highly customizable crosshair options              | [ModWorkshop](https://modworkshop.net/mod/29585) | @Offyerrocker |
| QuickChat                   | Quick chat wheel for fast team communication       | [ModWorkshop](https://modworkshop.net/mod/30917) | @sl0nderman   |
| Realtime XP                 | Shows XP gains in real-time during heists          | [ModWorkshop](https://modworkshop.net/mod/34540) | @James        |
| Tacticool Sprint            | Tactical sprint animations with weapon lowering    | [ModWorkshop](https://modworkshop.net/mod/43232) | @EUPHORIA     |
| The Fixes                   | Community-driven collection of bug fixes           | [ModWorkshop](https://modworkshop.net/mod/23732) | @Dom          |
| Ultrawide Fix               | Fixes UI scaling issues for ultrawide monitors     | [ModWorkshop](https://modworkshop.net/mod/32486) | @powware      |
| VanillaHUD Plus             | Enhanced vanilla HUD with additional features      | [ModWorkshop](https://modworkshop.net/mod/43232) | @test1        |

### Override Mods (`assets/mod_overrides/`)

| Mod                   | Description                              | Source                                                 | Author          |
| --------------------- | ---------------------------------------- | ------------------------------------------------------ | --------------- |
| Hotline Miami Menu    | Hotline Miami themed main menu and music | [ModWorkshop](https://modworkshop.net/mod/27294)       | @Eightan        |
| The Particle Massacre | Improved particles all across the board  | [ModWorkshop](https://modworkshop.net/mod/37435)       | @ZLBBR          |
| UA Grivna             | Replace USD bills with UAH               | [NexusMods](https://www.nexusmods.com/payday2/mods/76) | @Z3BRO/@davakim |

Thanks to the mod developers who made these amazing mods
And to the PAYDAY 2 modding community for keeping the game alive.

## Notes

- Some mods may require configuration. Check individual mod folders for settings.
- If you encounter issues after a game update, pull the latest version of this repo.

## License

This repository is a collection of mods made by their respective authors. All mods remain property of their original creators. See individual mods for their specific licenses.
