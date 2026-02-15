# Testing Checklist

Use this checklist before each release to ensure all features work correctly.

## Installation & Startup
- [ ] Addon loads without Lua errors (`/console scriptErrors 1`)
- [ ] No errors in chat on login
- [ ] SavedVariables file created in correct location
- [ ] Addon appears in Interface → AddOns list

## Core Functionality

### Gold Tracking
- [ ] Current character's gold is saved to database on login
- [ ] Gold updates when gaining money (looting, quest rewards, sales)
- [ ] Gold updates when spending money (repairs, vendors, auction fees)
- [ ] Multiple characters can be tracked (test with 2+ characters)
- [ ] Gold values display with comma separators (e.g., 1,228,403g)

### Session Tracking
- [ ] "Gained" increases when earning gold
- [ ] "Spent" increases when spending gold
- [ ] "Profit" shows correct calculation (Gained - Spent)
- [ ] Profit displays in green when positive
- [ ] Profit displays in red when negative
- [ ] Session resets to 0g after logout and login

### Mouseover Display
- [ ] Tooltip appears when hovering over gold in bag interface
- [ ] Tooltip hides when mouse moves away
- [ ] Can move mouse from money icon to tooltip without it disappearing
- [ ] Works with combined bags (modern default)
- [ ] Works with separate bag frames (if combined bags disabled)
- [ ] Tooltip displays above money frame
- [ ] Frame auto-sizes to fit content

### Display Content
- [ ] Title shows "Baz's Gold Trail"
- [ ] Session section shows: Gained, Spent, Profit
- [ ] Character list shows all tracked characters
- [ ] Character names display in correct class colors
- [ ] Current character marked with green "(you)" indicator
- [ ] Favourite characters (starred) appear at top of list
- [ ] Blank line separates favourites from non-favourites
- [ ] Warband Bank displayed (if you have gold in it)
- [ ] Warband Bank positioned before Total
- [ ] Total includes all characters + Warband Bank
- [ ] All gold values right-aligned

## Warband Bank
- [ ] Warband Bank gold displays correctly
- [ ] Updates when depositing/withdrawing from Warband Bank
- [ ] Included in Total calculation
- [ ] Displays in gold color
- [ ] Shows "0g" if empty (or hidden if preferred)

## Favourites System

### Via Slash Command
- [ ] `/gt fav` toggles current character's favourite status
- [ ] `/gt fav CharName-RealmName` toggles specific character
- [ ] Success message appears in chat
- [ ] Starred characters move to top of list immediately
- [ ] Star appears in tooltip display (★)

### Via Options Panel
- [ ] Click star button to toggle favourite
- [ ] Star changes from grey to gold when active
- [ ] Tooltip shows correct text on hover
- [ ] Character moves to top of list immediately
- [ ] Changes persist after `/reload`

## Options Panel

### Access
- [ ] Opens via Game Menu → Options → AddOns → Baz's Gold Trail
- [ ] Opens via `/gt options` command
- [ ] Displays without errors

### Interface
- [ ] Title shows "Baz's Gold Trail"
- [ ] About text displays correctly with credits
- [ ] Reporting Accuracy dropdown functions
- [ ] Character list scrolls if many characters
- [ ] Alternating row backgrounds visible
- [ ] Columns: Fav | Character | Gold on hand | Delete

### Character List
- [ ] All characters displayed
- [ ] Character names in class colors
- [ ] Current character shows green "(you)"
- [ ] Realm names in dim grey
- [ ] Gold amounts formatted correctly
- [ ] Divider line between favourites and non-favourites

### Star Buttons
- [ ] Click to toggle favourite status
- [ ] Gold color when active, grey when inactive
- [ ] Hover tooltip shows appropriate text
- [ ] Changes reflected immediately in list order

### Delete Buttons
- [ ] Red "X" button visible for each character
- [ ] Hover changes color to brighter red
- [ ] Tooltip shows "Remove from tracking"
- [ ] Click removes character from list
- [ ] Confirmation dialog appears
- [ ] Character deleted after confirmation

### Reporting Accuracy Dropdown
- [ ] Opens on click
- [ ] Shows "Gold only" option
- [ ] Shows "Gold, Silver & Copper" option
- [ ] Checkmark on current selection
- [ ] Clicking option changes format immediately
- [ ] Tooltip updates to new format
- [ ] Options panel updates to new format
- [ ] Chat output (`/gt`) uses new format
- [ ] Setting persists after `/reload`

### Reset All Data Button
- [ ] Button visible at bottom
- [ ] Hover tooltip warns about permanent deletion
- [ ] Click shows confirmation dialog
- [ ] "Yes, Reset Everything" button works
- [ ] "Cancel" button cancels action
- [ ] All data cleared after confirmation
- [ ] Success message in chat
- [ ] Tooltip shows "No data yet" message

## Slash Commands

### `/gt` or `/goldtrail` (Summary)
- [ ] Displays header "=== Baz's Gold Trail ==="
- [ ] Shows session tracking (Gained, Spent, Profit)
- [ ] Lists all characters with gold amounts
- [ ] Character names in class colors
- [ ] Current character marked "(you)"
- [ ] Favourites at top with star (★)
- [ ] Warband Bank displayed before Total
- [ ] Total calculated correctly
- [ ] Formatting matches "Reporting Accuracy" setting

### `/gt options`
- [ ] Opens options panel
- [ ] Works even when panel already open

### `/gt fav`
- [ ] Toggles favourite for current character
- [ ] Shows success message in chat
- [ ] Changes persist after `/reload`

### `/gt fav CharName-RealmName`
- [ ] Toggles favourite for specific character
- [ ] Case-insensitive matching works
- [ ] Shows error if character not found
- [ ] Shows success message on toggle

### `/gt delete CharName-RealmName`
- [ ] Removes character from tracking
- [ ] Shows success message
- [ ] Shows error if character not found
- [ ] Lists known characters if name wrong
- [ ] Character removed from all displays

## Data Persistence

### After `/reload`
- [ ] Gold amounts preserved
- [ ] Favourite status preserved
- [ ] Class colors preserved
- [ ] Display settings preserved (accuracy)
- [ ] Session tracking reset to 0g

### After Logout/Login
- [ ] Gold amounts preserved
- [ ] Favourite status preserved
- [ ] Class colors preserved
- [ ] Display settings preserved
- [ ] Session tracking reset to 0g

### Multiple Characters
- [ ] Each character's data saved separately
- [ ] Switching characters shows correct data
- [ ] No data loss or corruption

## Edge Cases

### New Installation
- [ ] Fresh install shows "No data yet" message
- [ ] First login creates SavedVariables
- [ ] No Lua errors on first load

### Single Character
- [ ] Works correctly with only one character
- [ ] No errors or visual glitches
- [ ] Total equals character's gold

### Many Characters (10+)
- [ ] Options panel scrolls smoothly
- [ ] Tooltip displays all characters
- [ ] No performance issues
- [ ] Sorting works correctly

### Large Gold Amounts
- [ ] Handles 1,000,000+ gold correctly
- [ ] Comma formatting works for large numbers
- [ ] No display overflow or wrapping issues

### Zero Gold
- [ ] Displays "0g" correctly
- [ ] No division by zero errors
- [ ] Session profit shows +0g or -0g appropriately

### Warband Bank
- [ ] Works if Warband Bank has 0g
- [ ] Works if Warband Bank not unlocked (The War Within only)
- [ ] Gracefully handles pre-TWW clients (no errors)

## Compatibility

### Game Versions
- [ ] Works in The War Within (11.x)
- [ ] Works in Midnight (12.0+)
- [ ] TOC interface versions correct (110207, 120001)

### UI Configurations
- [ ] Works with ElvUI
- [ ] Works with default Blizzard UI
- [ ] Works with other bag addons (if they modify money frame)
- [ ] Works with UI scale changes

## Known Issues
_Document any known issues that are not blockers for release:_

- [ ] List any known issues here
- [ ] Note any workarounds

---

## Pre-Release Verification

Before creating a release:
- [ ] All critical tests pass
- [ ] Version number updated in TOC file
- [ ] CHANGELOG.md updated with new version
- [ ] README.md up to date
- [ ] No debug print statements in code
- [ ] Git tag created
- [ ] GitHub release created
- [ ] CurseForge updated (if applicable)

---

**Tested by:** _________________  
**Date:** _________________  
**Version:** _________________  
**Notes:** _________________
