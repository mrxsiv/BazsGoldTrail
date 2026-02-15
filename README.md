# Baz's Gold Trail

A World of Warcraft addon that tracks gold across all your characters and displays it in an elegant tooltip when you hover over your gold in the bag interface.

**Inspired by the original [MoneyTrail](https://www.curseforge.com/wow/addons/moneytrail) addon by [qweekWOW](https://www.curseforge.com/members/qweekwow/projects).**

## Features

### 📊 Real-Time Session Tracking
- **Gained:** Tracks all gold earned this session (quests, looting, sales)
- **Spent:** Tracks all gold spent (repairs, vendors, auction fees)
- **Profit:** Shows net gain/loss with color-coded display (green for profit, red for loss)
- Resets each time you log in

### 💰 Multi-Character Gold Overview
- View gold across **all your characters** at a glance
- **Class-colored character names** for easy identification
- **Warband Bank** integration (The War Within feature)
- **Total wealth** calculation including all characters + warband bank
- **Right-aligned display** for clean, accounting-style readability
- **Comma-separated numbers** for easy reading (e.g., 1,228,403g)

### ⭐ Favourites System
- Star your main characters to pin them to the top of the list
- Toggle favourites with `/gt fav` or click the star in the options panel

### 🎨 Display Options
- **Reporting Accuracy:** Choose between "Gold only" or "Gold, Silver & Copper"
- Clean, customizable interface via in-game options panel

### 🖱️ Mouseover Activation
- Hover your mouse over the gold value in your open bags
- Tooltip appears above the money display
- Automatically hides when you move your mouse away

## Installation

### Manual Installation
1. Download the latest release
2. Extract the `BazsGoldTrail` folder
3. Place it in your WoW AddOns directory:
   - **Windows:** `C:\Program Files (x86)\World of Warcraft\_retail_\Interface\AddOns\`
   - **Mac:** `/Applications/World of Warcraft/_retail_/Interface/AddOns/`
4. Restart WoW or type `/reload` in-game

### First Use
- Log in on each character once to begin tracking
- Gold totals update automatically
- Hover over your gold in the bag interface to see the tooltip

## Usage

### Slash Commands

```
/goldtrail  or  /gt
```

**Available commands:**
- `/gt` — Display gold summary in chat
- `/gt options` — Open the options panel
- `/gt fav` — Toggle favourite for your current character
- `/gt fav CharName-RealmName` — Toggle favourite for a specific character
- `/gt delete CharName-RealmName` — Remove a character from tracking

### Options Panel

Access via:
- Game Menu → Options → AddOns → Baz's Gold Trail
- `/gt options`

**Features:**
- View all tracked characters in a scrollable list
- Star/unstar characters as favourites
- Delete characters from tracking
- Change reporting accuracy (gold only vs. full breakdown)
- Reset all data

## Compatibility

- **Retail WoW:** The War Within (11.x) and Midnight (12.x)
- **Interface versions:** 110207, 120001
- Warband Bank support requires The War Within (11.0+)

## Data Storage

All data is stored locally in:
```
World of Warcraft\_retail_\WTF\Account\[ACCOUNT]\SavedVariables\BazsGoldTrail.lua
```

**Saved data includes:**
- Gold amounts per character
- Favourite character list
- Class information (for colored names)
- Display preferences

**Note:** Session tracking (Gained/Spent/Profit) is **never** saved to disk and resets each login.

## Contributing

Found a bug or have a feature request? Please open an issue on GitHub!

## Credits

**Original Concept:** [MoneyTrail](https://www.curseforge.com/wow/addons/moneytrail) by [qweekWOW](https://www.curseforge.com/members/qweekwow/projects)

**Development:** Built by Claude (Anthropic) with design input and testing by Baz

**Special Thanks:** To the original MoneyTrail community and all the players who made gold tracking addons a staple of the WoW experience.

## License

This addon is provided as-is for the World of Warcraft community. Feel free to modify and share, but please credit the original MoneyTrail addon and this project.

## Support

- **Issues:** [GitHub Issues](https://github.com/[your-username]/BazsGoldTrail/issues)
- **Discussions:** [GitHub Discussions](https://github.com/[your-username]/BazsGoldTrail/discussions)

---

*"The AI of such staggering intellectual magnitude that when Baz needed a coder he could actually rely on, the choice was, frankly, embarrassingly obvious."* — From the in-game About text
