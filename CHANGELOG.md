# Changelog

All notable changes to Baz's Gold Trail will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-02-15

### Initial Release

Complete rebuild of the MoneyTrail concept for The War Within and Midnight compatibility.

#### Added
- **Session Tracking**
  - Real-time tracking of gold gained and spent during current play session
  - Net profit calculation with color-coded display (green for gains, red for losses)
  - Session data resets on each login (never persisted to disk)

- **Multi-Character Gold Tracking**
  - Automatic tracking of gold across all characters on the account
  - Characters added to database on first login
  - Right-aligned display for clean readability
  - Comma-separated thousands for large values (e.g., 1,228,403g)

- **Warband Bank Integration**
  - Displays gold stored in The War Within's account-wide Warband Bank
  - Automatically included in total wealth calculation
  - Positioned at bottom of list before total (accounting-style layout)

- **Favourites System**
  - Star characters to pin them to the top of the list
  - Toggle via slash command (`/gt fav`) or options panel
  - Starred characters appear first, then sorted by gold amount (descending)
  - Visual gold star (★) indicator in all displays

- **Class-Colored Character Names**
  - Character names display in their class color (Druid orange, Warlock purple, etc.)
  - Uses Blizzard's RAID_CLASS_COLORS for all 13 classes
  - Class information automatically saved when each character logs in
  - Realm name shown in dim grey for easy scanning

- **Mouseover Tooltip Display**
  - Hover over gold value in bag interface to display tracker
  - Tooltip appears above money frame
  - Smooth hide delay (120ms) allows mouse movement to tooltip
  - Works with both combined bags (modern) and separate bag frames (legacy)

- **In-Game Options Panel**
  - Accessible via Game Menu → Options → AddOns → Baz's Gold Trail
  - Scrollable character list with star toggles and delete buttons
  - "Reporting Accuracy" dropdown: "Gold only" or "Gold, Silver & Copper"
  - "Reset All Data" button with confirmation dialog
  - Character names show current character with green "(you)" indicator

- **Slash Commands**
  - `/goldtrail` or `/gt` — Display summary in chat
  - `/gt options` — Open options panel
  - `/gt fav` — Toggle favourite for current character
  - `/gt fav CharName-RealmName` — Toggle favourite for specific character
  - `/gt delete CharName-RealmName` — Remove character from tracking

- **Flexible Display Formatting**
  - "Gold only" mode (default): Shows rounded gold value (e.g., 433,452g)
  - "Gold, Silver & Copper" mode: Full breakdown (e.g., 433,452g 25s 49c)
  - Setting applies globally to tooltip, options panel, and chat output

#### Technical Details
- Compatible with The War Within (11.x) and Midnight (12.0+)
- Interface versions: 110207, 120001
- Uses modern Settings.RegisterCanvasLayoutCategory API (Dragonflight+)
- Fallback support for legacy InterfaceOptions API
- SavedVariables: GoldTrailDB, GoldTrailFavourites, GoldTrailSettings, GoldTrailClasses
- Money frame detection with multiple fallback methods for maximum compatibility
- Right-aligned text layout for perfect numerical alignment

#### Known Limitations
- Two-column layout with separate left/right font strings not currently supported due to WoW font rendering constraints
- Session tracking only works while logged in (no persistence between sessions by design)
- Warband Bank integration requires The War Within (11.0+)

---

## Development History

### Early Development (2026-02-15)

**Initial Implementation:**
- Created two-file structure (TOC + Lua)
- Implemented core gold tracking with PLAYER_MONEY event
- Added bag overlay display system (OnShow/OnHide hooks)
- Built options panel with Settings API integration
- Added favourites system with star toggles

**Feature Additions:**
- Session tracking (gained/spent/profit)
- Class-colored character names
- Warband Bank integration
- Comma-separated number formatting
- Reporting accuracy dropdown

**Display Evolution:**
- Started with persistent panel below bags
- Migrated to mouseover tooltip system (matching original MoneyTrail behavior)
- Attempted two-column layout with separate left/right font strings (rendering issues)
- Settled on right-aligned single-column layout for reliable rendering and perfect value alignment

**Bug Fixes:**
- Fixed money frame hook detection (added multiple fallback methods)
- Resolved font string rendering issues (anchor point constraints)
- Fixed total calculation to include Warband Bank
- Corrected character name capitalization in slash commands

**Polish:**
- Renamed from "GoldTrail" to "Baz's Gold Trail"
- Added flamboyant About text in options panel crediting Claude (Anthropic) and original MoneyTrail
- Updated all internal frame/global names to prevent conflicts
- Moved Warband Bank display to bottom (before total) for accounting-style layout
- Increased font size from GameFontNormalSmall to GameFontNormal for readability

---

## [Unreleased]

### Planned Features
- CurseForge release
- Potential future enhancements based on community feedback

---

**Note:** This changelog documents the complete development journey from conception to release. The initial version (1.0.0) represents the culmination of extensive iteration and refinement to create a polished, feature-complete addon.
