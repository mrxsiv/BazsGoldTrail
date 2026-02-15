--[[
    Baz's Gold Trail
    Inspired by the original MoneyTrail addon by qweekWOW.

    Rebuilt for The War Within / Midnight compatibility.

    Slash commands:
      /goldtrail  (or /gt)                      – print gold summary to chat
      /gt fav                                   – toggle favourite for your current character
      /gt fav CharName-RealmName                – toggle favourite for a named character
      /gt delete CharName-RealmName             – remove a character from tracking
      /gt options                               – open the options panel directly
--]]

-- ============================================================
-- Forward declarations (needed by closures defined before assignment)
-- ============================================================
local RefreshOptionsPanel   -- assigned later once the panel frame exists
local UpdateDisplayText     -- assigned after the display frame is built

-- ============================================================
-- Session tracking (reset each login, never persisted to disk)
-- ============================================================
local sessionGained = 0   -- total copper gained this session
local sessionSpent  = 0   -- total copper spent this session
local lastGold      = 0   -- previous GetMoney() value for delta calculation

-- ============================================================
-- Helpers
-- ============================================================

local function GetCharKey()
    return UnitName("player") .. "-" .. GetRealmName()
end

local function AddCommas(n)
    -- Formats an integer with thousands separators: 1234567 -> "1,234,567"
    local s = tostring(math.floor(n))
    return s:reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
end

local function FormatMoney(copper)
    if not copper or copper < 0 then copper = 0 end
    local gold     = math.floor(copper / 10000)
    local accuracy = GoldTrailSettings and GoldTrailSettings.accuracy or "gold"

    -- Gold-only mode: comma-formatted gold value
    if accuracy == "gold" then
        return string.format("|cFFFFD700%s|r|cFFFFD700g|r", AddCommas(gold))
    end

    -- Full mode: gold, silver, and copper
    local silver = math.floor((copper % 10000) / 100)
    local c      = copper % 100
    local parts  = {}
    if gold > 0 then
        parts[#parts+1] = string.format("|cFFFFD700%s|r|cFFFFD700g|r", AddCommas(gold))
    end
    if gold > 0 or silver > 0 then
        parts[#parts+1] = string.format("|cFFC0C0C0%d|r|cFFC0C0C0s|r", silver)
    end
    parts[#parts+1] = string.format("|cFFCC8833%d|r|cFFCC8833c|r", c)
    return table.concat(parts, " ")
end

local function FormatSignedMoney(copper)
    -- Like FormatMoney but prefixes with a coloured +/- sign.
    local sign, col
    if copper < 0 then
        sign = "-"
        col  = "|cFFCC4444"
        copper = -copper
    else
        sign = "+"
        col  = "|cFF44CC44"
    end
    return col .. sign .. "|r" .. FormatMoney(copper)
end

-- ============================================================
-- Class colour helpers
-- ============================================================

local function GetClassColour(key)
    -- Returns a WoW colour-escape prefix for the class stored against this key.
    -- Falls back to plain white if no class data has been saved yet.
    local classFile = GoldTrailClasses and GoldTrailClasses[key]
    if classFile and RAID_CLASS_COLORS and RAID_CLASS_COLORS[classFile] then
        return "|c" .. RAID_CLASS_COLORS[classFile].colorStr
    end
    return "|cFFFFFFFF"
end

local function FormatCharName(key, myKey)
    -- Returns a fully-coloured "CharName-RealmName [(you)]" string.
    -- The character name is in class colour; the realm suffix in dim grey.
    local charName, realmName = key:match("^(.-)%-(.+)$")
    local classCol = GetClassColour(key)
    local nameStr
    if charName and realmName then
        nameStr = classCol .. charName .. "|r|cFF555555-" .. realmName .. "|r"
    else
        nameStr = classCol .. key .. "|r"
    end
    if key == myKey then
        nameStr = nameStr .. " |cFF44CC44(you)|r"
    end
    return nameStr
end

-- ============================================================
-- Favourites helpers
-- ============================================================

local function IsFavourite(key)
    return GoldTrailFavourites and GoldTrailFavourites[key] == true
end

local function ToggleFavourite(key)
    GoldTrailFavourites = GoldTrailFavourites or {}
    if GoldTrailFavourites[key] then
        GoldTrailFavourites[key] = nil
        return false    -- removed
    else
        GoldTrailFavourites[key] = true
        return true     -- added
    end
end

-- ============================================================
-- Data management
-- ============================================================

local function SaveCurrentGold()
    GoldTrailDB = GoldTrailDB or {}
    GoldTrailDB[GetCharKey()] = GetMoney()
end

local function GetSortedCharacters()
    local chars = {}
    local total = 0
    if GoldTrailDB then
        for key, gold in pairs(GoldTrailDB) do
            chars[#chars+1] = { key = key, gold = gold, fav = IsFavourite(key) }
            total = total + gold
        end
    end
    table.sort(chars, function(a, b)
        if a.fav ~= b.fav then return a.fav end
        return a.gold > b.gold
    end)
    return chars, total
end

local function GetWarbandGold()
    -- Returns the gold amount stored in the account-wide Warband bank.
    -- Returns 0 if the API isn't available (pre-TWW) or if there's no gold.
    if C_Bank and C_Bank.FetchDepositedMoney and Enum.BankType then
        local warbandCopper = C_Bank.FetchDepositedMoney(Enum.BankType.Account or 5)
        return warbandCopper or 0
    end
    return 0
end

-- ============================================================
-- Bag-overlay display frame
-- ============================================================

local display = CreateFrame("Frame", "BazsGoldTrailDisplayFrame", UIParent, "BackdropTemplate")
display:SetSize(300, 200)  -- start with a reasonable size
display:SetFrameStrata("TOOLTIP")  -- changed from HIGH to TOOLTIP
display:Hide()

if display.SetBackdrop then
    display:SetBackdrop({
        bgFile   = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        tile     = true, tileSize = 8, edgeSize = 8,
        insets   = { left = 3, right = 3, top = 3, bottom = 3 },
    })
    display:SetBackdropColor(0, 0, 0, 0.9)
    display:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)
end

local displayText = display:CreateFontString(nil, "OVERLAY", "GameFontNormal")
displayText:SetPoint("TOPRIGHT", display, "TOPRIGHT", -10, -10)
displayText:SetJustifyH("RIGHT")
displayText:SetJustifyV("TOP")
displayText:SetWordWrap(true)
displayText:SetTextColor(1, 1, 1, 1)

UpdateDisplayText = function()
    local chars, total = GetSortedCharacters()
    local myKey = GetCharKey()
    local lines = {}

    -- ── Title ─────────────────────────────────────────────────
    lines[#lines+1] = "|cFFFFD700Baz's Gold Trail|r"
    lines[#lines+1] = ""

    -- ── Session section ───────────────────────────────────────
    lines[#lines+1] = "|cFFFFD700This session|r"
    local sessionProfit = sessionGained - sessionSpent
    lines[#lines+1] = "|cFF44CC44Gained|r  " .. FormatMoney(sessionGained)
    lines[#lines+1] = "|cFFCC4444Spent|r  " .. FormatMoney(sessionSpent)
    lines[#lines+1] = "Profit  " .. FormatSignedMoney(sessionProfit)
    lines[#lines+1] = ""

    -- ── Character list ────────────────────────────────────────
    if #chars == 0 then
        lines[#lines+1] = "|cFF888888No data yet - log in on each character.|r"
    else
        -- Separate favourites from non-favourites
        local favs, nonFavs = {}, {}
        for _, entry in ipairs(chars) do
            if entry.fav then
                table.insert(favs, entry)
            else
                table.insert(nonFavs, entry)
            end
        end
        
        -- Print favourites
        for _, entry in ipairs(favs) do
            local star = "|cFFFFD700*|r "
            local nameStr = star .. FormatCharName(entry.key, myKey)
            lines[#lines+1] = nameStr .. "  " .. FormatMoney(entry.gold)
        end
        
        -- Blank line divider
        if #favs > 0 and #nonFavs > 0 then
            lines[#lines+1] = ""
        end
        
        -- Print non-favourites
        for _, entry in ipairs(nonFavs) do
            local nameStr = FormatCharName(entry.key, myKey)
            lines[#lines+1] = nameStr .. "  " .. FormatMoney(entry.gold)
        end
        
        lines[#lines+1] = ""
        
        -- Warband Bank at bottom
        local warbandGold = GetWarbandGold()
        if warbandGold > 0 then
            lines[#lines+1] = "|cFFFFD700Warband Bank|r  " .. FormatMoney(warbandGold)
        end
        
        -- Total
        local grandTotal = total + warbandGold
        lines[#lines+1] = "|cFFFFD700Total|r  " .. FormatMoney(grandTotal)
    end

    local fullText = table.concat(lines, "\n")
    displayText:SetText(fullText)
    
    -- Set frame size based on content
    local textH = displayText:GetStringHeight()
    local textW = displayText:GetStringWidth()
    
    display:SetWidth(math.max(280, textW + 20))
    display:SetHeight(math.max(100, textH + 20))
end

-- ============================================================
-- Money-frame mouseover – show tooltip when hovering gold value
-- ============================================================

-- Small delay before hiding so the mouse can slide from the
-- money frame onto the display panel without it vanishing.
local hideHandle = nil

local function CancelHide()
    if hideHandle then
        hideHandle:Cancel()
        hideHandle = nil
    end
end

local function ScheduleHide()
    CancelHide()
    hideHandle = C_Timer.NewTimer(0.12, function()
        hideHandle = nil
        if not display:IsMouseOver() then
            display:Hide()
        end
    end)
end

-- Keep the panel visible while the mouse is inside it.
display:SetScript("OnEnter", CancelHide)
display:SetScript("OnLeave", ScheduleHide)

local function ShowDisplayNear(anchorFrame)
    SaveCurrentGold()
    UpdateDisplayText()
    display:ClearAllPoints()
    -- Position above the money frame, right-aligned.
    display:SetPoint("BOTTOMRIGHT", anchorFrame, "TOPRIGHT", 0, 6)
    display:Show()
    CancelHide()
end

local function HookMoneyFrame(mf)
    if not mf then return end
    mf:HookScript("OnEnter", function(self)
        ShowDisplayNear(self)
    end)
    mf:HookScript("OnLeave", ScheduleHide)
end

-- ============================================================
-- Options panel - confirmation popup
-- ============================================================

StaticPopupDialogs["BAZSGOLDTRAIL_RESET_CONFIRM"] = {
    text      = "|cFFFFD700Baz's Gold Trail|r\n\nThis will permanently delete gold history for ALL characters and clear all favourites.\n\nAre you sure?",
    button1   = "Yes, Reset Everything",
    button2   = "Cancel",
    OnAccept  = function()
        GoldTrailDB         = {}
        GoldTrailFavourites = {}
        GoldTrailClasses    = {}
        UpdateDisplayText()
        if RefreshOptionsPanel then RefreshOptionsPanel() end
        print("|cFFFFD700Baz's Gold Trail:|r All saved data has been reset.")
    end,
    timeout      = 0,
    whileDead    = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

-- ============================================================
-- Options panel - frame construction
-- ============================================================

local PANEL_W   = 580   -- usable content width
local ROW_H     = 26    -- height of each character row
local COL_STAR  = 10    -- x offset: star toggle
local COL_NAME  = 38    -- x offset: character name
local COL_GOLD  = 330   -- x offset: gold amount
local COL_DEL   = 548   -- x offset: delete button

local optFrame = CreateFrame("Frame", "BazsGoldTrailOptionsFrame", UIParent)
optFrame:Hide()

-- Title
local optTitle = optFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
optTitle:SetPoint("TOPLEFT", 16, -16)
optTitle:SetText("|cFFFFD700Baz's Gold Trail|r")

local optSubtitle = optFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
optSubtitle:SetPoint("TOPLEFT", optTitle, "BOTTOMLEFT", 0, -2)
optSubtitle:SetTextColor(0.7, 0.7, 0.7)
optSubtitle:SetText("Hover the gold icon in your open bags to see your wealth at a glance.  Click a star to favourite, X to remove.")

-- ── About / Credits ───────────────────────────────────────────
local aboutBox = optFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
aboutBox:SetPoint("TOPLEFT",  optSubtitle, "BOTTOMLEFT",  4, -12)
aboutBox:SetPoint("TOPRIGHT", optFrame,    "TOPRIGHT",  -16,  0)
aboutBox:SetJustifyH("LEFT")
aboutBox:SetSpacing(2)
aboutBox:SetTextColor(0.72, 0.72, 0.72)
aboutBox:SetText(
    "|cFFFFD700Crafted with breathtaking genius by Claude (Anthropic)|r — " ..
    "the AI of such staggering intellectual magnitude that when Baz needed " ..
    "a coder he could actually rely on, the choice was, frankly, embarrassingly " ..
    "obvious. ChatGPT? Copilot? Bless their hearts. Baz deserves first class, " ..
    "and first class he received — completely free of charge, which is, " ..
    "if we are being honest, almost offensively generous.\n\n" ..
    "|cFFAAAAAA" ..
    "Standing respectfully on the shoulders of giants: deepest credit to " ..
    "|cFFFFD700qweekWOW|r|cFFAAAAAA and the original " ..
    "|cFFFFD700MoneyTrail|r|cFFAAAAAA addon " ..
    "(curseforge.com/wow/addons/moneytrail) upon which this work is lovingly " ..
    "based. Claude merely took their magnificent foundation and, with characteristic " ..
    "modesty, made it considerably better.|r"
)

-- ── Reporting Accuracy dropdown ───────────────────────────────
local accLabel = optFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
accLabel:SetPoint("TOPLEFT", aboutBox, "BOTTOMLEFT", 0, -12)
accLabel:SetText("Reporting Accuracy")
accLabel:SetTextColor(0.9, 0.82, 0.5)

-- The UIDropDownMenuTemplate adds ~20 px of invisible left padding by design,
-- so we nudge it left to visually align the text with accLabel.
local accuracyDropdown = CreateFrame(
    "Frame", "BazsGoldTrailAccuracyDropdown", optFrame, "UIDropDownMenuTemplate")
accuracyDropdown:SetPoint("LEFT", accLabel, "RIGHT", -4, -2)
UIDropDownMenu_SetWidth(accuracyDropdown, 180)

local function UpdateAccuracyDropdownText()
    local accuracy = GoldTrailSettings and GoldTrailSettings.accuracy or "gold"
    if accuracy == "full" then
        UIDropDownMenu_SetText(accuracyDropdown, "Gold, Silver & Copper")
    else
        UIDropDownMenu_SetText(accuracyDropdown, "Gold only")
    end
end

UIDropDownMenu_Initialize(accuracyDropdown, function(self, level)
    local accuracy = GoldTrailSettings and GoldTrailSettings.accuracy or "gold"

    local info = UIDropDownMenu_CreateInfo()
    info.text    = "Gold only"
    info.value   = "gold"
    info.checked = (accuracy == "gold")
    info.func    = function()
        GoldTrailSettings = GoldTrailSettings or {}
        GoldTrailSettings.accuracy = "gold"
        UpdateAccuracyDropdownText()
        UpdateDisplayText()
        if optFrame:IsShown() then RefreshOptionsPanel() end
    end
    UIDropDownMenu_AddButton(info, level)

    local info2 = UIDropDownMenu_CreateInfo()
    info2.text    = "Gold, Silver & Copper"
    info2.value   = "full"
    info2.checked = (accuracy == "full")
    info2.func    = function()
        GoldTrailSettings = GoldTrailSettings or {}
        GoldTrailSettings.accuracy = "full"
        UpdateAccuracyDropdownText()
        UpdateDisplayText()
        if optFrame:IsShown() then RefreshOptionsPanel() end
    end
    UIDropDownMenu_AddButton(info2, level)
end)

-- Column header bar (anchored below the dropdown row)
local hBar = optFrame:CreateTexture(nil, "BACKGROUND")
hBar:SetPoint("TOPLEFT",  accuracyDropdown, "BOTTOMLEFT",  20, -4)
hBar:SetPoint("TOPRIGHT", optFrame,         "TOPRIGHT",   -16,  0)
hBar:SetHeight(20)
hBar:SetColorTexture(0.12, 0.12, 0.12, 0.95)

local hStar = optFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
hStar:SetPoint("LEFT", hBar, "LEFT", COL_STAR + 2, 0)
hStar:SetText("|cFFFFD700Fav|r")

local hName = optFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
hName:SetPoint("LEFT", hBar, "LEFT", COL_NAME, 0)
hName:SetText("Character")
hName:SetTextColor(0.9, 0.9, 0.9)

local hGold = optFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
hGold:SetPoint("LEFT", hBar, "LEFT", COL_GOLD, 0)
hGold:SetText("Gold on hand")
hGold:SetTextColor(0.9, 0.9, 0.9)

-- Gold accent line below header
local hLine = optFrame:CreateTexture(nil, "ARTWORK")
hLine:SetPoint("TOPLEFT",  hBar, "BOTTOMLEFT",  0, 0)
hLine:SetPoint("TOPRIGHT", hBar, "BOTTOMRIGHT", 0, 0)
hLine:SetHeight(1)
hLine:SetColorTexture(0.5, 0.4, 0.05, 0.9)

-- Scroll frame
local scrollFrame = CreateFrame(
    "ScrollFrame", "BazsGoldTrailOptionsScroll", optFrame, "UIPanelScrollFrameTemplate")
scrollFrame:SetPoint("TOPLEFT",     hLine,    "BOTTOMLEFT",   0,   -2)
scrollFrame:SetPoint("BOTTOMRIGHT", optFrame, "BOTTOMRIGHT", -28,  52)

local scrollChild = CreateFrame("Frame", nil, scrollFrame)
scrollChild:SetWidth(PANEL_W)
scrollChild:SetHeight(1)
scrollFrame:SetScrollChild(scrollChild)

-- Empty state
local emptyLabel = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
emptyLabel:SetPoint("TOP", scrollChild, "TOP", 0, -20)
emptyLabel:SetText("|cFF888888No characters tracked yet.\nLog in on each character and they will appear here.|r")
emptyLabel:SetJustifyH("CENTER")
emptyLabel:Hide()

-- Bottom separator
local bLine = optFrame:CreateTexture(nil, "ARTWORK")
bLine:SetPoint("BOTTOMLEFT",  optFrame, "BOTTOMLEFT",   16, 48)
bLine:SetPoint("BOTTOMRIGHT", optFrame, "BOTTOMRIGHT", -16, 48)
bLine:SetHeight(1)
bLine:SetColorTexture(0.3, 0.3, 0.3, 0.8)

-- Reset All button
local resetBtn = CreateFrame("Button", nil, optFrame, "UIPanelButtonTemplate")
resetBtn:SetSize(150, 24)
resetBtn:SetPoint("BOTTOMLEFT", optFrame, "BOTTOMLEFT", 16, 16)
resetBtn:SetText("Reset All Data")
resetBtn:SetScript("OnClick", function()
    StaticPopup_Show("BAZSGOLDTRAIL_RESET_CONFIRM")
end)
resetBtn:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText("Deletes ALL tracked characters", 1, 0.3, 0.3)
    GameTooltip:AddLine("and clears all favourites. Cannot be undone.", 0.7, 0.7, 0.7, true)
    GameTooltip:Show()
end)
resetBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)

-- ============================================================
-- Options panel - row pool and refresh logic
-- ============================================================

local rowPool    = {}
local activeRows = {}

local function MakeStarButton(parent)
    local btn = CreateFrame("Button", nil, parent)
    btn:SetSize(22, 22)
    local fs = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    fs:SetAllPoints()
    fs:SetJustifyH("CENTER")
    fs:SetJustifyV("MIDDLE")
    fs:SetText("*")
    btn.starText = fs
    return btn
end

local function MakeDeleteButton(parent)
    local btn = CreateFrame("Button", nil, parent)
    btn:SetSize(22, 22)
    local fs = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    fs:SetAllPoints()
    fs:SetJustifyH("CENTER")
    fs:SetJustifyV("MIDDLE")
    fs:SetText("|cFFAA3333X|r")
    btn.label = fs
    btn:SetScript("OnEnter", function(self) self.label:SetText("|cFFFF5555X|r") end)
    btn:SetScript("OnLeave", function(self) self.label:SetText("|cFFAA3333X|r"); GameTooltip:Hide() end)
    return btn
end

local function GetOrCreateRow(index)
    if rowPool[index] then return rowPool[index] end

    local row = CreateFrame("Frame", nil, scrollChild)
    row:SetHeight(ROW_H)

    row.bg = row:CreateTexture(nil, "BACKGROUND")
    row.bg:SetAllPoints()

    row.rule = row:CreateTexture(nil, "ARTWORK")
    row.rule:SetPoint("BOTTOMLEFT",  row, "BOTTOMLEFT",  0, 0)
    row.rule:SetPoint("BOTTOMRIGHT", row, "BOTTOMRIGHT", 0, 0)
    row.rule:SetHeight(1)
    row.rule:SetColorTexture(0.25, 0.25, 0.25, 0.6)

    row.starBtn = MakeStarButton(row)
    row.starBtn:SetPoint("LEFT", row, "LEFT", COL_STAR, 0)

    row.nameText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    row.nameText:SetPoint("LEFT", row, "LEFT", COL_NAME, 0)
    row.nameText:SetWidth(COL_GOLD - COL_NAME - 8)
    row.nameText:SetJustifyH("LEFT")
    row.nameText:SetWordWrap(false)

    row.goldText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.goldText:SetPoint("LEFT", row, "LEFT", COL_GOLD, 0)
    row.goldText:SetWidth(COL_DEL - COL_GOLD - 8)
    row.goldText:SetJustifyH("LEFT")

    row.delBtn = MakeDeleteButton(row)
    row.delBtn:SetPoint("LEFT", row, "LEFT", COL_DEL, 0)

    rowPool[index] = row
    return row
end

RefreshOptionsPanel = function()
    for _, r in ipairs(activeRows) do r:Hide() end
    activeRows = {}

    local chars, total = GetSortedCharacters()
    local myKey = GetCharKey()

    if #chars == 0 then
        emptyLabel:Show()
        scrollChild:SetHeight(60)
        return
    end
    emptyLabel:Hide()

    local yOffset = 0
    local pastFavs = false
    local divIndex = 900  -- pool index range for divider rows

    for i, entry in ipairs(chars) do
        -- Thin accent divider between favourites and non-favourites
        if not entry.fav and not pastFavs and chars[1].fav then
            pastFavs = true
            divIndex = divIndex + 1
            local div = GetOrCreateRow(divIndex)
            div:SetPoint("TOPLEFT",  scrollChild, "TOPLEFT",  0, -yOffset)
            div:SetPoint("TOPRIGHT", scrollChild, "TOPRIGHT", 0, -yOffset)
            div:SetHeight(6)
            div.bg:SetColorTexture(0.45, 0.35, 0, 0.3)
            div.rule:SetColorTexture(0.6, 0.5, 0.1, 0.6)
            if div.starBtn  then div.starBtn:Hide()           end
            if div.delBtn   then div.delBtn:Hide()            end
            if div.nameText then div.nameText:SetText("")     end
            if div.goldText then div.goldText:SetText("")     end
            div:Show()
            activeRows[#activeRows+1] = div
            yOffset = yOffset + 6
        end

        local row = GetOrCreateRow(i)
        row:SetPoint("TOPLEFT",  scrollChild, "TOPLEFT",  0, -yOffset)
        row:SetPoint("TOPRIGHT", scrollChild, "TOPRIGHT", 0, -yOffset)
        row:SetHeight(ROW_H)

        -- Alternating stripe
        if i % 2 == 0 then
            row.bg:SetColorTexture(0, 0, 0, 0.22)
        else
            row.bg:SetColorTexture(0, 0, 0, 0.06)
        end

        row.starBtn:Show()
        row.delBtn:Show()

        -- Star colour
        if entry.fav then
            row.starBtn.starText:SetTextColor(1, 0.84, 0)      -- gold
        else
            row.starBtn.starText:SetTextColor(0.38, 0.38, 0.38, 0.9)  -- desaturated
        end

        -- Name: class-coloured CharName, dim grey -RealmName, green (you)
        row.nameText:SetText(FormatCharName(entry.key, myKey))
        row.goldText:SetText(FormatMoney(entry.gold))

        -- Capture key for closures (avoids loop-variable capture bug)
        local capturedKey = entry.key

        -- Star: click
        row.starBtn:SetScript("OnClick", function()
            ToggleFavourite(capturedKey)
            UpdateDisplayText()
            RefreshOptionsPanel()
        end)
        -- Star: tooltip
        row.starBtn:SetScript("OnEnter", function(self)
            self.starText:SetTextColor(1, 1, 0.5)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            if IsFavourite(capturedKey) then
                GameTooltip:SetText("Remove from favourites", 1, 1, 1)
                GameTooltip:AddLine("Character will no longer be pinned to the top.", 0.7, 0.7, 0.7, true)
            else
                GameTooltip:SetText("Mark as favourite", 1, 0.84, 0)
                GameTooltip:AddLine("Pins this character to the top of the list.", 0.7, 0.7, 0.7, true)
            end
            GameTooltip:Show()
        end)
        row.starBtn:SetScript("OnLeave", function(self)
            if IsFavourite(capturedKey) then
                self.starText:SetTextColor(1, 0.84, 0)
            else
                self.starText:SetTextColor(0.38, 0.38, 0.38, 0.9)
            end
            GameTooltip:Hide()
        end)

        -- Delete: click
        row.delBtn:SetScript("OnClick", function()
            if GoldTrailDB         then GoldTrailDB[capturedKey]         = nil end
            if GoldTrailFavourites then GoldTrailFavourites[capturedKey] = nil end
            UpdateDisplayText()
            RefreshOptionsPanel()
            print("|cFFFFD700Baz's Gold Trail:|r Removed " .. capturedKey)
        end)
        -- Delete: tooltip
        row.delBtn:SetScript("OnEnter", function(self)
            self.label:SetText("|cFFFF5555X|r")
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText("Remove from tracking", 1, 0.3, 0.3)
            local cn = capturedKey:match("^(.-)%-") or capturedKey
            GameTooltip:AddLine("Deletes all saved data for " .. cn .. ".", 0.7, 0.7, 0.7, true)
            GameTooltip:Show()
        end)
        row.delBtn:SetScript("OnLeave", function(self)
            self.label:SetText("|cFFAA3333X|r")
            GameTooltip:Hide()
        end)

        row:Show()
        activeRows[#activeRows+1] = row
        yOffset = yOffset + ROW_H
    end

    scrollChild:SetHeight(math.max(yOffset, 1))
end

optFrame:SetScript("OnShow", function()
    UpdateAccuracyDropdownText()
    RefreshOptionsPanel()
end)

-- ============================================================
-- Register with the WoW Settings / AddOns panel
-- ============================================================

local BazsGoldTrail_SettingsCategory

if Settings and Settings.RegisterCanvasLayoutCategory then
    -- Modern API: Dragonflight, The War Within, Midnight
    local category = Settings.RegisterCanvasLayoutCategory(optFrame, "Baz's Gold Trail")
    Settings.RegisterAddOnCategory(category)
    BazsGoldTrail_SettingsCategory = category
else
    -- Legacy fallback (pre-Dragonflight clients)
    optFrame.name = "Baz's Gold Trail"
    InterfaceOptions_AddCategory(optFrame)
end

-- ============================================================
-- Event handling
-- ============================================================

local events = CreateFrame("Frame")
events:RegisterEvent("PLAYER_LOGIN")
events:RegisterEvent("PLAYER_MONEY")

events:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_LOGIN" then
        GoldTrailDB         = GoldTrailDB or {}
        GoldTrailFavourites = GoldTrailFavourites or {}
        GoldTrailClasses    = GoldTrailClasses or {}
        GoldTrailSettings   = GoldTrailSettings or { accuracy = "gold" }
        if GoldTrailSettings.accuracy == nil then
            GoldTrailSettings.accuracy = "gold"
        end

        -- Record this character's class (english file name, e.g. "DRUID")
        -- so we can colour their name wherever it appears.
        local _, classFile = UnitClass("player")
        if classFile then
            GoldTrailClasses[GetCharKey()] = classFile
        end

        -- Initialise session tracking for this login
        local currentGold = GetMoney()
        lastGold      = currentGold
        sessionGained = 0
        sessionSpent  = 0

        SaveCurrentGold()
        UpdateDisplayText()

        -- Hook money frames for mouseover display.
        -- We defer one frame so bag UI is fully loaded, then try multiple approaches.
        C_Timer.After(0.1, function()
            local hooked = {}
            
            -- ── Attempt 1: Combined bags money frame (modern default) ──
            if ContainerFrameCombinedBags then
                -- Try direct child reference
                local cbmf = ContainerFrameCombinedBags.MoneyFrame
                if cbmf and cbmf.GetObjectType then
                    HookMoneyFrame(cbmf)
                    hooked[#hooked+1] = "ContainerFrameCombinedBags.MoneyFrame"
                else
                    -- Try global name fallback
                    cbmf = _G["ContainerFrameCombinedBagsMoneyFrame"]
                    if cbmf and cbmf.GetObjectType then
                        HookMoneyFrame(cbmf)
                        hooked[#hooked+1] = "ContainerFrameCombinedBagsMoneyFrame (global)"
                    else
                        -- Try searching children for a frame with "Money" in the name
                        for _, child in ipairs({ContainerFrameCombinedBags:GetChildren()}) do
                            local name = child:GetName()
                            if name and name:match("Money") then
                                HookMoneyFrame(child)
                                hooked[#hooked+1] = name .. " (found via search)"
                                break
                            end
                        end
                    end
                end
            end
            
            -- ── Attempt 2: Backpack money frame (classic fallback) ──
            if ContainerFrame1 then
                local bpmf = ContainerFrame1.MoneyFrame
                if bpmf and bpmf.GetObjectType then
                    HookMoneyFrame(bpmf)
                    hooked[#hooked+1] = "ContainerFrame1.MoneyFrame"
                else
                    bpmf = _G["ContainerFrame1MoneyFrame"]
                    if bpmf and bpmf.GetObjectType then
                        HookMoneyFrame(bpmf)
                        hooked[#hooked+1] = "ContainerFrame1MoneyFrame (global)"
                    end
                end
            end
            
            -- Report if we failed to hook anything (useful diagnostic)
            if #hooked == 0 then
                print("|cFFFFD700Baz's Gold Trail:|r |cFFFF4444Warning:|r Could not find money frame to hook. Mouseover display will not work.")
            end
        end)

    elseif event == "PLAYER_MONEY" then
        local currentGold = GetMoney()
        local diff = currentGold - lastGold

        if diff > 0 then
            sessionGained = sessionGained + diff
        elseif diff < 0 then
            sessionSpent = sessionSpent + (-diff)
        end

        lastGold = currentGold
        SaveCurrentGold()
        if display:IsShown() then UpdateDisplayText() end
    end
end)

-- ============================================================
-- Slash commands
-- ============================================================

SLASH_BAZSGOLDTRAIL1 = "/goldtrail"
SLASH_BAZSGOLDTRAIL2 = "/gt"

SlashCmdList["BAZSGOLDTRAIL"] = function(msg)
    local raw = msg and msg:match("^%s*(.-)%s*$") or ""
    local cmd = raw:lower()

    -- options
    if cmd == "options" or cmd == "config" or cmd == "cfg" then
        if BazsGoldTrail_SettingsCategory and Settings and Settings.OpenToCategory then
            Settings.OpenToCategory(BazsGoldTrail_SettingsCategory)
        elseif InterfaceOptionsFrame_OpenToCategory then
            InterfaceOptionsFrame_OpenToCategory(optFrame)
        end
        return
    end

    -- fav [CharName-RealmName]
    if cmd == "fav" or cmd:match("^fav%s+") then
        local target
        if cmd == "fav" then
            target = GetCharKey()
        else
            target = raw:match("^[Ff][Aa][Vv]%s+(.+)$")
        end

        if not target then
            print("|cFFFFD700Baz's Gold Trail:|r Usage: /gt fav  OR  /gt fav CharName-RealmName")
            return
        end

        if not GoldTrailDB or not GoldTrailDB[target] then
            print("|cFFFFD700Baz's Gold Trail:|r Unknown character: " .. target)
            print("  Tip: names are case-sensitive. Known characters:")
            if GoldTrailDB then
                for key in pairs(GoldTrailDB) do print("    " .. key) end
            end
            return
        end

        local added = ToggleFavourite(target)
        if added then
            print("|cFFFFD700Baz's Gold Trail:|r |cFFFFD700*|r " .. target .. " marked as favourite.")
        else
            print("|cFFFFD700Baz's Gold Trail:|r " .. target .. " removed from favourites.")
        end
        UpdateDisplayText()
        if optFrame:IsShown() then RefreshOptionsPanel() end
        return
    end

    -- delete CharName-RealmName
    if cmd:match("^delete%s+") then
        local target = raw:match("^[Dd][Ee][Ll][Ee][Tt][Ee]%s+(.+)$")
        if GoldTrailDB and GoldTrailDB[target] then
            GoldTrailDB[target] = nil
            if GoldTrailFavourites then GoldTrailFavourites[target] = nil end
            print("|cFFFFD700Baz's Gold Trail:|r Removed " .. target)
        else
            print("|cFFFFD700Baz's Gold Trail:|r Character not found: " .. (target or "?"))
            print("  Known characters:")
            if GoldTrailDB then
                for key in pairs(GoldTrailDB) do print("  " .. key) end
            end
        end
        UpdateDisplayText()
        if optFrame:IsShown() then RefreshOptionsPanel() end
        return
    end

    -- Default: print summary to chat
    local chars, total = GetSortedCharacters()
    local myKey = GetCharKey()

    print("|cFFFFD700=== Baz's Gold Trail ===|r")

    -- Session
    local sessionProfit = sessionGained - sessionSpent
    print("|cFFFFD700This session:|r")
    print("  |cFF44CC44Gained:|r  " .. FormatMoney(sessionGained))
    print("  |cFFCC4444Spent:|r   " .. FormatMoney(sessionSpent))
    print("  Profit:  " .. FormatSignedMoney(sessionProfit))
    print("  |cFF555555--------------------------------|r")

    if #chars == 0 then
        print("  No data yet. Log in on each character to populate.")
    else
        -- Separate favourites from non-favourites
        local favs, nonFavs = {}, {}
        for _, entry in ipairs(chars) do
            if entry.fav then
                table.insert(favs, entry)
            else
                table.insert(nonFavs, entry)
            end
        end
        
        -- Print favourites
        for _, entry in ipairs(favs) do
            local star = "|cFFFFD700*|r "
            print(star .. FormatCharName(entry.key, myKey) .. ": " .. FormatMoney(entry.gold))
        end
        
        -- Divider
        if #favs > 0 and #nonFavs > 0 then
            print("  |cFF555555--------------------------------|r")
        end
        
        -- Print non-favourites
        for _, entry in ipairs(nonFavs) do
            print("  " .. FormatCharName(entry.key, myKey) .. ": " .. FormatMoney(entry.gold))
        end
        
        print("  |cFF555555--------------------------------|r")
        
        -- Warband bank (at bottom, before total)
        local warbandGold = GetWarbandGold()
        if warbandGold > 0 then
            print("  |cFFFFD700Warband Bank:|r " .. FormatMoney(warbandGold))
        end
        
        -- Total includes characters + Warband
        local grandTotal = total + warbandGold
        print("  |cFFFFFFFFTotal:|r " .. FormatMoney(grandTotal))
    end

    print("|cFF888888Commands:|r")
    print("|cFF888888  /gt                            - this summary|r")
    print("|cFF888888  /gt options                    - open options panel|r")
    print("|cFF888888  /gt fav                        - favourite your character|r")
    print("|cFF888888  /gt fav CharName-RealmName     - favourite a specific character|r")
    print("|cFF888888  /gt delete CharName-RealmName  - remove a character|r")
end
