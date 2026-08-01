local CH = {}
CharacterHomes = CH

local WAYSHRINE_ICON    = "/esoui/art/icons/mapkey/mapkey_wayshrine.dds"
local WAYSHRINE_ICON_MO = "/esoui/art/icons/mapkey/mapkey_wayshrine.dds"
local HOME_ICON         = "/esoui/art/collections/collections_tabicon_housing_up.dds"
local HOME_ICON_MO      = "/esoui/art/collections/collections_tabicon_housing_over.dds"
local CLOSE_ICON     = "/esoui/art/buttons/decline_up.dds"
local CLOSE_ICON_MO  = "/esoui/art/buttons/decline_over.dds"
local EDIT_ICON      = "/esoui/art/buttons/edit_up.dds"
local EDIT_ICON_MO   = "/esoui/art/buttons/edit_over.dds"
local SAVE_ICON      = "/esoui/art/buttons/accept_up.dds"
local SAVE_ICON_MO   = "/esoui/art/buttons/accept_over.dds"
local ROW_H          = 44

-- Single account-wide SavedVars, keyed per megaserver.  Structure:
-- CharacterHomesSavedVars[GetWorldName()]["@account"]["$AccountWide"] = {
--   account    = { [alias] = { houseId, owner, displayName, zone } },
--   characters = { [charName] = { primary = {...} or nil, named = { [alias] = {...} } } }
-- }
-- entry fields: houseId (number), owner (string|nil), displayName (string), zone (string|nil)

-- ── Forward declarations ──────────────────────────────────────────────────────
local populateDialog
local refreshIfOpen
local getOwnedHouses

-- ── Helpers ───────────────────────────────────────────────────────────────────

local function msg(text, ...)
    if select("#", ...) > 0 then text = string.format(text, ...) end
    d("|cffd700[CharacterHomes]|r " .. text)
end

local function charName() return GetUnitName("player") end

local function charData()
    local n = charName()
    if not CH.sv.characters[n] then
        CH.sv.characters[n] = { primary = nil, named = {} }
    end
    local cd = CH.sv.characters[n]
    if not cd.named then cd.named = {} end
    return cd
end

local function getHouseName(houseId)
    local collectibleId = GetCollectibleIdForHouse(houseId)
    if collectibleId and collectibleId ~= 0 then
        local name = GetCollectibleName(collectibleId)
        if name and name ~= "" then return name end
    end
    return GetMapName() or ("House #" .. houseId)
end

local function makeEntryKey(houseId, owner)
    local houseName = getHouseName(houseId)
    if owner and owner ~= "" then
        return owner .. "_" .. houseName
    end
    return houseName
end

-- Must be defined before currentHouseInfo which calls it.
local function getHouseZone(houseId)
    local zoneId = GetHouseZoneId(houseId)
    if zoneId and zoneId > 0 then
        local parentId = GetParentZoneId(zoneId)
        return GetZoneNameById((parentId and parentId > 0) and parentId or zoneId)
    end
    return nil
end

local function currentHouseInfo()
    local houseId = GetCurrentZoneHouseId()
    if not houseId or houseId == 0 then return nil, nil, nil, nil end
    local owner = GetCurrentHouseOwner() or ""
    if owner == "" or owner == GetDisplayName() then owner = nil end
    return houseId, owner, getHouseName(houseId), getHouseZone(houseId)
end

local function jumpTo(entry)
    if entry.owner and entry.owner ~= "" then
        JumpToSpecificHouse(entry.owner, entry.houseId)
    else
        RequestJumpToHouse(entry.houseId)
    end
end

local function resolveNamed(name)
    local lname = string.lower(name)
    local cd = charData()
    for k, v in pairs(cd.named) do
        if string.lower(k) == lname or string.lower(v.displayName or "") == lname then return v end
    end
    for k, v in pairs(CH.sv.account) do
        if string.lower(k) == lname or string.lower(v.displayName or "") == lname then return v end
    end
end

-- ── Slash Commands ────────────────────────────────────────────────────────────

function CH.SlashSetHome(args)
    local name = args and zo_strtrim(args) or ""
    if name == "" then
        msg("Usage: /setglobalhome |cffffff<name>|r  (account-wide alias)")
        msg("To set your character primary home use /setmyhome with no arguments.")
        return
    end
    local houseId, owner, houseName, zoneName = currentHouseInfo()
    if not houseId then msg("You must be inside a house.") return end
    CH.sv.account[makeEntryKey(houseId, owner)] = { houseId = houseId, owner = owner, displayName = name, zone = zoneName }
    msg("Account home '|cffffff%s|r' -> %s%s", name, houseName,
        owner and (" (|cffffff" .. owner .. "|r)") or "")
    refreshIfOpen()
end

function CH.SlashSetMyHome(args)
    local name      = args and zo_strtrim(args) or ""
    local houseId, owner, houseName, zoneName = currentHouseInfo()
    if not houseId then msg("You must be inside a house.") return end
    -- named homes use the alias as initial display label; primary falls back to official name
    local entry    = { houseId = houseId, owner = owner, displayName = (name ~= "" and name or "Primary Residence"), zone = zoneName }
    local ownerStr = owner and (" (|cffffff" .. owner .. "|r)") or ""
    local cd = charData()
    if name == "" then
        cd.primary = entry
        msg("Primary home for |cffffff%s|r -> %s%s", charName(), houseName, ownerStr)
        refreshIfOpen()
        if CH_DEBUG then
            d("[CH DEBUG] set primary for key='" .. charName() .. "' houseId=" .. tostring(houseId))
            d("[CH DEBUG] cd.primary after set = " .. tostring(cd.primary))
            d("[CH DEBUG] sv.characters key check = " .. tostring(CH.sv.characters[charName()] ~= nil))
        end
    else
        cd.named[makeEntryKey(houseId, owner)] = entry
        msg("Character home '|cffffff%s|r' -> %s%s", name, houseName, ownerStr)
        refreshIfOpen()
    end
end

function CH.SlashResetHome()
    charData().primary = nil
    msg("Primary home cleared for |cffffff%s|r.", charName())
    refreshIfOpen()
end

function CH.SlashDelHome(args)
    local name = args and zo_strtrim(args) or ""
    if name == "" then msg("Usage: /delhome |cffffff<name>|r") return end
    local lname = string.lower(name)
    local matches = {}
    for k, v in pairs(CH.sv.account) do
        if string.lower(k):find(lname, 1, true) or string.lower(v.displayName or ""):find(lname, 1, true) then
            table.insert(matches, { key = k, entry = v })
        end
    end
    if #matches == 0 then
        msg("No account home matching '|cffffff%s|r'.", name)
    elseif #matches > 1 then
        msg("'|cffffff%s|r' matches %d homes — be more specific:", name, #matches)
        for _, m in ipairs(matches) do
            msg("  |cffffff%s|r  (%s)", m.entry.displayName or m.key, m.key)
        end
    else
        local m = matches[1]
        CH.sv.account[m.key] = nil
        msg("Account home '|cffffff%s|r' removed.", m.entry.displayName or m.key)
        refreshIfOpen()
    end
end

function CH.SlashDelMyHome(args)
    local name = args and zo_strtrim(args) or ""
    if name == "" then msg("Usage: /delmyhome |cffffff<name>|r  (or 'primary')") return end
    local cd = charData()
    if string.lower(name) == "primary" then
        if cd.primary then
            cd.primary = nil
            msg("Primary home cleared for |cffffff%s|r.", charName())
            refreshIfOpen()
        else
            msg("No primary home set for |cffffff%s|r.", charName())
        end
        return
    end
    local lname = string.lower(name)
    local matches = {}
    for k, v in pairs(cd.named) do
        if string.lower(k):find(lname, 1, true) or string.lower(v.displayName or ""):find(lname, 1, true) then
            table.insert(matches, { key = k, entry = v })
        end
    end
    if #matches == 0 then
        msg("No character home matching '|cffffff%s|r'.", name)
    elseif #matches > 1 then
        msg("'|cffffff%s|r' matches %d homes — be more specific:", name, #matches)
        for _, m in ipairs(matches) do
            msg("  |cffffff%s|r  (%s)", m.entry.displayName or m.key, m.key)
        end
    else
        local m = matches[1]
        cd.named[m.key] = nil
        msg("Character home '|cffffff%s|r' removed.", m.entry.displayName or m.key)
        refreshIfOpen()
    end
end

function CH.SlashHome(args)
    local query = args and zo_strtrim(args) or ""
    if query == "" then
        local cd = charData()
        if cd.primary then
            local official = getHouseName(cd.primary.houseId)
            msg("Heading to |cffffff%s|r (%s)...", cd.primary.displayName or official, official)
            jumpTo(cd.primary)
        else
            msg("No primary home set. Use /setmyhome inside a house.")
        end
        return
    end

    local lq      = string.lower(query)
    local matches = {}

    -- first pass: search registered entries by display label
    local function collectLabelMatches()
        local found = {}
        local function check(entry)
            local dn = string.lower(entry.displayName or "")
            if dn ~= "" and dn:find(lq, 1, true) then
                table.insert(found, { label = entry.displayName, entry = entry })
            end
        end
        local cd = charData()
        if cd.primary then check(cd.primary) end
        for _, entry in pairs(cd.named)      do check(entry) end
        for _, entry in pairs(CH.sv.account) do check(entry) end
        return found
    end

    -- fallback: search ALL owned houses by official ESO name, jump directly
    local function collectOwnedMatches()
        local found = {}
        for _, h in ipairs(getOwnedHouses()) do
            if string.lower(h.name):find(lq, 1, true) then
                table.insert(found, { label = h.name, entry = { houseId = h.houseId } })
            end
        end
        return found
    end

    matches = collectLabelMatches()
    if #matches == 0 then
        matches = collectOwnedMatches()
    end

    if #matches == 0 then
        msg("No home matching '|cffffff%s|r'. Use /homes to see your list.", query)
        -- note: /gohome is the command (renamed from /home to avoid EHT conflict)
    elseif #matches == 1 then
        local m = matches[1]
        local official = getHouseName(m.entry.houseId)
        msg("Heading to |cffffff%s|r (%s)...", m.label or official, official)
        jumpTo(m.entry)
    else
        table.sort(matches, function(a, b) return (a.label or "") < (b.label or "") end)
        msg("'|cffffff%s|r' matches %d homes — be more specific:", query, #matches)
        for _, m in ipairs(matches) do
            msg("  |cffffff%s|r", m.label or "")
        end
    end
end

function CH.SlashHomes()
    CH.ShowDialog()
end

-- ── UI ────────────────────────────────────────────────────────────────────────

local scrollChild   -- the scroll child control from XML
local contentWrap   -- single CT_CONTROL parenting all dynamic rows
local trashBin      -- hidden off-screen container; we reparent old contentWraps here
                    -- instead of calling Destroy() which is unreliable in ESO
local bgSeq              = 0
local comboSeq           = 0
local populating         = false
local CH_DEBUG           = false
local accountOwnerFilter = 0  -- 0=all, 1=mine (no owner), 2=friends (has owner)

local function addTooltip(ctrl, text)
    ctrl:SetHandler("OnMouseEnter", function(self)
        InitializeTooltip(InformationTooltip, self, BOTTOM, 0, -4)
        InformationTooltip:AddLine(text, "ZoFontGame", 1, 1, 1)
    end)
    ctrl:SetHandler("OnMouseExit", function()
        ClearTooltip(InformationTooltip)
    end)
end

local ownedHouseCache = nil

getOwnedHouses = function()
    if not ownedHouseCache then
        ownedHouseCache = {}
        for houseId = 1, 1000 do
            local collectibleId = GetCollectibleIdForHouse(houseId)
            if collectibleId and collectibleId ~= 0 then
                if GetCollectibleUnlockStateById(collectibleId) == COLLECTIBLE_UNLOCK_STATE_UNLOCKED_OWNED then
                    local name = GetCollectibleName(collectibleId) or ("House #" .. houseId)
                    table.insert(ownedHouseCache, { houseId = houseId, name = name, zone = getHouseZone(houseId) })
                end
            end
        end
        table.sort(ownedHouseCache, function(a, b) return a.name < b.name end)
    end
    return ownedHouseCache
end

local allHouseCache = nil

local function getAllHouses()
    if not allHouseCache then
        allHouseCache = {}
        for houseId = 1, 1000 do
            local collectibleId = GetCollectibleIdForHouse(houseId)
            if collectibleId and collectibleId ~= 0 then
                local name = GetCollectibleName(collectibleId)
                if name and name ~= "" then
                    table.insert(allHouseCache, { houseId = houseId, name = name })
                end
            end
        end
        table.sort(allHouseCache, function(a, b) return a.name < b.name end)
    end
    return allHouseCache
end

local function getScrollChild()
    if not scrollChild then
        scrollChild = CharacterHomesDialogScrollPanelScrollChild
    end
    return scrollChild
end

local function getSearchFilter()
    local eb = CharacterHomesDialogSearchFilterBgEdit
    if not eb then return "" end
    return string.lower(zo_strtrim(eb:GetText() or ""))
end

local function accountOwnerMatchesFilter(entry)
    if accountOwnerFilter == 0 then return true end
    local isOwned = (entry.owner == nil or entry.owner == "")
    if accountOwnerFilter == 1 then return isOwned end
    return not isOwned  -- filter 2: friends
end

local function entryMatchesFilters(_, entry)
    local search = getSearchFilter()
    if search == "" then return true end
    local houseName = getHouseName(entry.houseId) or ""
    if string.lower(houseName):find(search, 1, true)               then return true end
    if string.lower(entry.displayName or ""):find(search, 1, true) then return true end
    if string.lower(entry.zone or ""):find(search, 1, true)        then return true end
    if string.lower(entry.owner or ""):find(search, 1, true)       then return true end
    return false
end

function CH.OnFilterChanged()
    if not CH.sv then return end
    if not scrollChild then return end
    if CharacterHomesDialog:IsHidden() then return end
    zo_callLater(populateDialog, 0)
end

local function getRowWidth()
    local panel = CharacterHomesDialogScrollPanel
    return (panel and panel:GetWidth() > 0 and panel:GetWidth() or 700) - 18
end

local function getTrashBin()
    if not trashBin then
        trashBin = WINDOW_MANAGER:CreateControl("CHTrashBin", GuiRoot, CT_CONTROL)
        trashBin:SetHidden(true)
        trashBin:SetDimensions(1, 1)
        trashBin:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, -200, -200)
    end
    return trashBin
end

local function clearRows()
    if contentWrap then
        contentWrap:SetParent(getTrashBin())  -- reparent away; Destroy is unreliable in ESO
        contentWrap = nil
    end
end

local function getContent()
    if not contentWrap then
        local sc = getScrollChild()
        contentWrap = WINDOW_MANAGER:CreateControl(nil, sc, CT_CONTROL)
        contentWrap:SetAnchor(TOPLEFT, sc, TOPLEFT, 0, 0)
        contentWrap:SetDimensions(getRowWidth(), 10)
    end
    return contentWrap
end

-- Column offsets
local COL_TELE      = 0    -- teleport icon  (44px)
local COL_TYPE      = 44   -- owner @name    (176px; blank for own homes)
local COL_ALIAS     = 220  -- display label  (fills to house column)
local HOUSE_COL_W   = 320  -- house column fixed width
local COL_DEL       = -28  -- delete btn     (right edge offset, 24px wide)
-- COL_HOUSE is computed per-row as: rowW - 60 - HOUSE_COL_W

local function addHeader(text, yOff)
    local c   = getContent()
    local lbl = WINDOW_MANAGER:CreateControl(nil, c, CT_LABEL)
    lbl:SetFont("ZoFontWinH3")
    lbl:SetText(text)
    lbl:SetColor(0.78, 0.68, 0.38, 1)
    lbl:SetAnchor(TOPLEFT, c, TOPLEFT, 2, yOff)
    return yOff + 30
end

local function addRow(typeLabel, aliasName, entry, yOff, onDelete)
    local c        = getContent()
    local rowW     = getRowWidth()
    local colHouse = rowW - 60 - HOUSE_COL_W
    local isOwned  = (entry.owner == nil or entry.owner == "")

    local row = WINDOW_MANAGER:CreateControl(nil, c, CT_CONTROL)
    row:SetDimensions(rowW, ROW_H)
    row:SetAnchor(TOPLEFT, c, TOPLEFT, 0, yOff)
    row:SetMouseEnabled(true)

    bgSeq = bgSeq + 1
    local bg = CreateControlFromVirtual("CHBg" .. bgSeq, row, "ZO_SliderBackdrop")
    bg:SetAnchorFill(row)
    bg:SetCenterColor(0, 0, 0, 0)
    bg:SetEdgeColor(0, 0, 0, 0)
    row:SetHandler("OnMouseEnter", function() bg:SetCenterColor(1, 1, 1, 0.06) end)
    row:SetHandler("OnMouseExit",  function() bg:SetCenterColor(0, 0, 0, 0) end)

    local isPrimary = (typeLabel == "Primary")
    local teleIcon   = isPrimary and HOME_ICON    or WAYSHRINE_ICON
    local teleIconMO = isPrimary and HOME_ICON_MO or WAYSHRINE_ICON_MO
    local ico = WINDOW_MANAGER:CreateControl(nil, row, CT_BUTTON)
    ico:SetDimensions(34, 34)
    ico:SetAnchor(LEFT, row, LEFT, COL_TELE + 3, 0)
    ico:SetNormalTexture(teleIcon)
    ico:SetPressedTexture(teleIcon)
    ico:SetMouseOverTexture(teleIconMO)
    ico:SetHandler("OnClicked", function()
        CharacterHomesDialog:SetHidden(true)
        SetGameCameraUIMode(false)
        jumpTo(entry)
    end)
    local teleLabel = entry.owner and ("Teleport to " .. (entry.displayName or officialName) .. "\n|c888888via " .. entry.owner .. "|r")
                                   or ("Teleport to " .. (entry.displayName or officialName))
    addTooltip(ico, teleLabel)

    -- col2: owner @name for friend homes; blank for own homes
    local typeLbl = WINDOW_MANAGER:CreateControl(nil, row, CT_LABEL)
    typeLbl:SetFont("ZoFontGame")
    local ownerText = (entry.owner and entry.owner ~= "") and ("|c7a9cbf" .. entry.owner .. "|r") or ""
    typeLbl:SetText(ownerText)
    typeLbl:SetAnchor(LEFT, row, LEFT, COL_TYPE, 0)
    typeLbl:SetDimensions(COL_ALIAS - COL_TYPE - 4, ROW_H)
    typeLbl:SetVerticalAlignment(TEXT_ALIGN_CENTER)

    -- col3: user's arbitrary display label (editable)
    local aliasLbl = WINDOW_MANAGER:CreateControl(nil, row, CT_LABEL)
    aliasLbl:SetFont("ZoFontWinH4")
    local displayText = entry.displayName or ""
    aliasLbl:SetText(displayText ~= "" and ("|cffffff" .. displayText .. "|r") or "")
    aliasLbl:SetAnchor(LEFT, row, LEFT, COL_ALIAS, 0)
    aliasLbl:SetDimensions(colHouse - COL_ALIAS - 4, ROW_H)
    aliasLbl:SetVerticalAlignment(TEXT_ALIGN_CENTER)

    -- col4: official ESO house name derived from houseId (not editable as text; changed via combo)
    local officialName = getHouseName(entry.houseId) or ("House #" .. tostring(entry.houseId or 0))
    local houseLbl = WINDOW_MANAGER:CreateControl(nil, row, CT_LABEL)
    houseLbl:SetFont("ZoFontGame")
    houseLbl:SetText(officialName)
    houseLbl:SetColor(0.75, 0.75, 0.75, 1)
    houseLbl:SetAnchor(LEFT, row, LEFT, colHouse, 0)
    houseLbl:SetDimensions(HOUSE_COL_W, ROW_H)
    houseLbl:SetVerticalAlignment(TEXT_ALIGN_CENTER)

    -- ── inline edit controls (hidden until edit mode) ─────────────────────────

    -- col3: display name editbox (replaces alias label in edit mode)
    local dnBgW = colHouse - COL_ALIAS - 8
    local dnBg  = WINDOW_MANAGER:CreateControl(nil, row, CT_BACKDROP)
    dnBg:SetCenterColor(0, 0, 0, 0.7)
    dnBg:SetAnchor(LEFT, row, LEFT, COL_ALIAS, 0)
    dnBg:SetDimensions(dnBgW, ROW_H - 8)
    dnBg:SetHidden(true)

    local dnEdit = WINDOW_MANAGER:CreateControl(nil, dnBg, CT_EDITBOX)
    dnEdit:SetFont("ZoFontGame")
    dnEdit:SetColor(1, 1, 1, 1)
    dnEdit:SetMaxInputChars(64)
    dnEdit:SetAnchor(TOPLEFT, dnBg, TOPLEFT, 4, 4)
    dnEdit:SetDimensions(dnBgW - 8, ROW_H - 16)

    -- col4: owned-house dropdown (replaces house label in edit mode, owned homes only)
    comboSeq = comboSeq + 1
    local houseComboCtrl = WINDOW_MANAGER:CreateControlFromVirtual("CHHouseCombo" .. comboSeq, row, "ZO_ComboBox")
    houseComboCtrl:SetAnchor(LEFT, row, LEFT, colHouse, 0)
    houseComboCtrl:SetDimensions(HOUSE_COL_W, ROW_H - 4)
    houseComboCtrl:SetHidden(true)
    local houseCombo    = ZO_ComboBox_ObjectFromContainer(houseComboCtrl)
    local selectedHouseId = entry.houseId

    local editBtn = WINDOW_MANAGER:CreateControl(nil, row, CT_BUTTON)
    editBtn:SetDimensions(24, 24)
    editBtn:SetAnchor(RIGHT, row, RIGHT, -32, 0)
    editBtn:SetNormalTexture(EDIT_ICON)
    editBtn:SetMouseOverTexture(EDIT_ICON_MO)
    addTooltip(editBtn, "Edit label or change house")

    local del = WINDOW_MANAGER:CreateControl(nil, row, CT_BUTTON)
    del:SetDimensions(24, 24)
    del:SetAnchor(RIGHT, row, RIGHT, COL_DEL + 24, 0)
    del:SetNormalTexture(CLOSE_ICON)
    del:SetMouseOverTexture(CLOSE_ICON_MO)
    del:SetHandler("OnClicked", onDelete)
    addTooltip(del, "Remove from list")

    local exitEditMode  -- forward declare

    local function enterEditMode()
        ico:SetHidden(true)
        aliasLbl:SetHidden(true)
        houseLbl:SetHidden(true)
        dnBg:SetHidden(false)
        dnEdit:SetText(entry.displayName or "")
        dnEdit:TakeFocus()

        if isOwned then
            local houses = getOwnedHouses()
            houseCombo:ClearItems()
            local selectIdx = 1
            for i, h in ipairs(houses) do
                local houseId = h.houseId
                houseCombo:AddItem(houseCombo:CreateItemEntry(h.name, function()
                    selectedHouseId = houseId
                end))
                if h.houseId == entry.houseId then selectIdx = i end
            end
            houseCombo:SelectItemByIndex(selectIdx)
            houseComboCtrl:SetHidden(false)
        end

        editBtn:SetNormalTexture(SAVE_ICON)
        editBtn:SetMouseOverTexture(SAVE_ICON_MO)
        del:SetHandler("OnClicked", function() exitEditMode(false) end)
    end

    exitEditMode = function(doSave)
        ico:SetHidden(false)
        aliasLbl:SetHidden(false)
        houseLbl:SetHidden(false)
        dnBg:SetHidden(true)
        houseComboCtrl:SetHidden(true)
        editBtn:SetNormalTexture(EDIT_ICON)
        editBtn:SetMouseOverTexture(EDIT_ICON_MO)
        del:SetHandler("OnClicked", onDelete)
        if doSave then
            local newName = zo_strtrim(dnEdit:GetText() or "")
            if newName ~= "" then entry.displayName = newName end
            if isOwned then
                if selectedHouseId ~= entry.houseId then
                    entry.houseId = selectedHouseId
                    entry.owner   = nil
                    -- try to update zone from the owned-houses cache
                    for _, h in ipairs(getOwnedHouses()) do
                        if h.houseId == selectedHouseId then
                            if h.zone then entry.zone = h.zone end
                            break
                        end
                    end
                end
            end
            zo_callLater(populateDialog, 0)
        end
    end

    dnEdit:SetHandler("OnEnterPressed", function() exitEditMode(true) end)
    dnEdit:SetHandler("OnEscapePressed", function() exitEditMode(false) end)

    editBtn:SetHandler("OnClicked", function()
        if dnBg:IsHidden() then enterEditMode()
        else exitEditMode(true) end
    end)

    return yOff + ROW_H + 2
end

local function addNote(text, yOff)
    local c   = getContent()
    local lbl = WINDOW_MANAGER:CreateControl(nil, c, CT_LABEL)
    lbl:SetFont("ZoFontGame")
    lbl:SetText("|c666666" .. text .. "|r")
    lbl:SetAnchor(TOPLEFT, c, TOPLEFT, 6, yOff)
    return yOff + 24
end

populateDialog = function()
    if populating then return end
    populating = true
    clearRows()

    local yOff = 4
    local cd   = charData()

    if CH_DEBUG then
        d("[CH DEBUG] populateDialog: charName='" .. charName() .. "' cd.primary=" .. tostring(cd.primary) .. " named_count=" .. tostring(cd.named and #cd.named or "nil"))
        d("[CH DEBUG] sv.characters keys:")
        for k,v in pairs(CH.sv.characters) do d("  key='" .. tostring(k) .. "'") end
    end

    yOff = addHeader("MY HOMES  (" .. charName() .. ")", yOff)

    local shownChar = 0
    if cd.primary and entryMatchesFilters("Primary", cd.primary) then
        local e = cd.primary
        yOff = addRow("Primary", "", e, yOff, function()
            charData().primary = nil
            zo_callLater(populateDialog, 0)
        end)
        shownChar = shownChar + 1
    end

    for n, e in pairs(cd.named) do
        if entryMatchesFilters(n, e) then
            local name, entry = n, e
            yOff = addRow("Named", name, entry, yOff, function()
                charData().named[name] = nil
                zo_callLater(populateDialog, 0)
            end)
            shownChar = shownChar + 1
        end
    end

    if shownChar == 0 then
        if cd.primary == nil and next(cd.named) == nil then
            yOff = addNote("No character homes set.", yOff)
        else
            yOff = addNote("No character homes match the filter.", yOff)
        end
    end

    yOff = yOff + 6
    yOff = addHeader("ACCOUNT HOMES", yOff)

    local shownAcc = 0
    for n, e in pairs(CH.sv.account) do
        if entryMatchesFilters(n, e) and accountOwnerMatchesFilter(e) then
            local name, entry = n, e
            yOff = addRow("Account", name, entry, yOff, function()
                CH.sv.account[name] = nil
                zo_callLater(populateDialog, 0)
            end)
            shownAcc = shownAcc + 1
        end
    end
    if shownAcc == 0 then
        if next(CH.sv.account) == nil then
            yOff = addNote("No account homes -- use /sethome <name> inside a house.", yOff)
        else
            yOff = addNote("No account homes match the filter.", yOff)
        end
    end

    getContent():SetHeight(yOff + 4)
    populating = false
end

refreshIfOpen = function()
    if CharacterHomesDialog and not CharacterHomesDialog:IsHidden() then
        zo_callLater(populateDialog, 0)
    end
end

function CH.ShowDialog()
    CharacterHomesDialog:SetHidden(false)
    SetGameCameraUIMode(true)
    populateDialog()
end

-- ── Add Bar / Friend Housing Bar ─────────────────────────────────────────────

local ADD_TYPES    = { "Primary (character)", "Named (character)", "Account wide" }
local addTypeIndex = 1
local fhTypeIndex = 1

local function buildFriendHousingBar()
    local dlg = CharacterHomesDialog
    local ref = CharacterHomesDialogFHRefBg

    local selectedFriend  = nil
    local selectedHouseId = nil

    -- Friend dropdown (x=78, w=200) — anchor to dialog TOPLEFT for reliability
    local friendComboCtrl = WINDOW_MANAGER:CreateControlFromVirtual("CHFHFriendCombo", dlg, "ZO_ComboBox")
    friendComboCtrl:SetAnchor(LEFT, ref, LEFT, 78, 0)
    friendComboCtrl:SetDimensions(200, 28)
    local friendCb = ZO_ComboBox_ObjectFromContainer(friendComboCtrl)
    friendCb:SetSortsItems(false)

    -- collect friends
    local friendNames = {}
    local seenLower   = {}
    local numFriends  = GetNumFriends()
    for i = 1, numFriends do
        local displayName = GetFriendInfo(i)
        if displayName and displayName ~= "" then
            table.insert(friendNames, displayName)
            seenLower[string.lower(displayName)] = true
        end
    end
    table.sort(friendNames, function(a, b) return string.lower(a) < string.lower(b) end)

    -- collect guild masters (rankIndex 1) and officers (rankIndex 2), grouped by guild
    -- deduplicated against friends list so no @account appears twice
    local guildGroups = {}
    local numGuilds   = GetNumGuilds()
    for gi = 1, numGuilds do
        local guildId   = GetGuildId(gi)
        local guildName = GetGuildName(guildId)
        local members   = {}
        local numMembers = GetNumGuildMembers(guildId)
        for mi = 1, numMembers do
            local displayName, _, rankIndex = GetGuildMemberInfo(guildId, mi)
            if displayName and displayName ~= "" and rankIndex <= 2 then
                local low = string.lower(displayName)
                if not seenLower[low] then
                    table.insert(members, displayName)
                    seenLower[low] = true
                end
            end
        end
        table.sort(members, function(a, b) return string.lower(a) < string.lower(b) end)
        if #members > 0 then
            table.insert(guildGroups, { name = guildName, members = members })
        end
    end

    -- populate combo with section headers (non-selectable) and member entries
    local itemIndex          = 0
    local firstSelectableIdx = nil

    local function addSectionHeader(label)
        itemIndex = itemIndex + 1
        local entry = friendCb:CreateItemEntry("|c888888-- " .. label .. " --|r", function()
            -- header: re-assert current selection so clicking it changes nothing
            if selectedFriend then
                friendCb:SetSelectedItemText(selectedFriend)
            end
        end)
        friendCb:AddItem(entry)
    end

    local function addFriendEntry(name)
        itemIndex = itemIndex + 1
        local n = name
        friendCb:AddItem(friendCb:CreateItemEntry(n, function() selectedFriend = n end))
        if not firstSelectableIdx then
            firstSelectableIdx = itemIndex
            selectedFriend     = n
        end
    end

    if #friendNames > 0 then
        addSectionHeader("── Friends ──")
        for _, name in ipairs(friendNames) do addFriendEntry(name) end
    end
    for _, group in ipairs(guildGroups) do
        addSectionHeader("── " .. group.name .. " ──")
        for _, name in ipairs(group.members) do addFriendEntry(name) end
    end

    if firstSelectableIdx then
        friendCb:SelectItemByIndex(firstSelectableIdx)
    end

    -- Type dropdown — anchor RIGHT of friend combo, w=200 to match add bar type combo
    local fhTypeComboCtrl = WINDOW_MANAGER:CreateControlFromVirtual("CHFHTypeCombo", dlg, "ZO_ComboBox")
    fhTypeComboCtrl:SetAnchor(LEFT, friendComboCtrl, RIGHT, 8, 0)
    fhTypeComboCtrl:SetDimensions(200, 28)
    local fhTypeCb = ZO_ComboBox_ObjectFromContainer(fhTypeComboCtrl)
    for i, label in ipairs(ADD_TYPES) do
        local idx = i
        fhTypeCb:AddItem(fhTypeCb:CreateItemEntry(label, function() fhTypeIndex = idx end))
    end
    fhTypeCb:SelectFirstItem()

    -- House dropdown: all ESO houses (x=554, w=270)
    local houseComboCtrl = WINDOW_MANAGER:CreateControlFromVirtual("CHFHHouseCombo", dlg, "ZO_ComboBox")
    houseComboCtrl:SetAnchor(LEFT, ref, LEFT, 554, 0)
    houseComboCtrl:SetDimensions(270, 28)
    local houseCb = ZO_ComboBox_ObjectFromContainer(houseComboCtrl)

    for _, h in ipairs(getAllHouses()) do
        local houseId = h.houseId
        houseCb:AddItem(houseCb:CreateItemEntry(h.name, function() selectedHouseId = houseId end))
    end
    local houses = getAllHouses()
    if #houses > 0 then
        selectedHouseId = houses[1].houseId
        houseCb:SelectFirstItem()
    end

    local fhNameEdit = CharacterHomesDialogFHNameBgEdit

    addTooltip(CharacterHomesDialogFHSaveButton, "Save friend's house to your homes list")
    addTooltip(CharacterHomesDialogFHTeleButton, "Teleport to friend's house\n|c888888Does not save to list|r")

    -- Save (checkmark): adds friend's house to the list
    CharacterHomesDialogFHSaveButton:SetHandler("OnClicked", function()
        if not selectedFriend or not selectedHouseId then
            msg("Select a friend and a house first.")
            return
        end
        local officialKey = getHouseName(selectedHouseId)
        local entryKey    = makeEntryKey(selectedHouseId, selectedFriend)
        local labelText   = zo_strtrim(fhNameEdit:GetText() or "")
        local displayName = labelText ~= "" and labelText
                            or (fhTypeIndex == 1 and "Primary Residence" or officialKey)
        local zone        = getHouseZone(selectedHouseId)
        local entry = { houseId = selectedHouseId, owner = selectedFriend, displayName = displayName, zone = zone }
        if fhTypeIndex == 1 then
            charData().primary = entry
            msg("Primary home set to |cffffff%s|r (|c7a9cbf%s|r).", displayName, selectedFriend)
        elseif fhTypeIndex == 2 then
            charData().named[entryKey] = entry
            msg("Character home '|cffffff%s|r' saved (|c7a9cbf%s|r).", displayName, selectedFriend)
        else
            CH.sv.account[entryKey] = entry
            msg("Account home '|cffffff%s|r' saved (|c7a9cbf%s|r).", displayName, selectedFriend)
        end
        fhNameEdit:SetText("")
        zo_callLater(populateDialog, 0)
    end)

    -- Teleport button: just ports to friend's house, no save
    CharacterHomesDialogFHTeleButton:SetHandler("OnClicked", function()
        if not selectedFriend or not selectedHouseId then
            msg("Select a friend and a house.")
            return
        end
        if not CanJumpToHouseFromCurrentLocation() then
            msg("Cannot teleport from your current location.")
            return
        end
        local houseName = getHouseName(selectedHouseId)
        msg("Attempting to port to |cffffff%s|r at |c7a9cbf%s|r...", houseName, selectedFriend)
        CharacterHomesDialog:SetHidden(true)
        SetGameCameraUIMode(false)
        JumpToSpecificHouse(selectedFriend, selectedHouseId)
    end)
end

local addLabelEdit -- set by buildAddBar

local function buildAddBar()
    local dlg = CharacterHomesDialog

    addLabelEdit = CharacterHomesDialogAddLabelBgEdit

    -- AddRefBg is an invisible 1×28 control at x=0 in the add bar row, used as an
    -- anchor reference so combo x-offsets mirror the friend housing bar's column positions exactly.
    local ref = CharacterHomesDialogAddRefBg

    -- Type combo at x=286, aligned with friend housing bar type combo (no label — "My homes:" label is at x=74)
    local typeComboCtrl = WINDOW_MANAGER:CreateControlFromVirtual("CHAddTypeCombo", dlg, "ZO_ComboBox")
    typeComboCtrl:SetAnchor(LEFT, ref, LEFT, 286, 0)
    typeComboCtrl:SetDimensions(200, 28)
    local typeCb = ZO_ComboBox_ObjectFromContainer(typeComboCtrl)
    for i, label in ipairs(ADD_TYPES) do
        local idx = i
        typeCb:AddItem(typeCb:CreateItemEntry(label, function() addTypeIndex = idx end))
    end
    typeCb:SelectFirstItem()

    -- House combo at x=554, mirroring friend housing bar House combo
    local houseComboCtrl = WINDOW_MANAGER:CreateControlFromVirtual("CHAddHouseCombo", dlg, "ZO_ComboBox")
    houseComboCtrl:SetAnchor(LEFT, ref, LEFT, 554, 0)
    houseComboCtrl:SetDimensions(270, 28)
    local houseCb = ZO_ComboBox_ObjectFromContainer(houseComboCtrl)

    local selectedHouseInfo = nil

    local function populateHouseCombo()
        houseCb:ClearItems()
        selectedHouseInfo = nil
        local houses = getOwnedHouses()
        for _, h in ipairs(houses) do
            local info = h
            houseCb:AddItem(houseCb:CreateItemEntry(h.name, function()
                selectedHouseInfo = info
            end))
        end
        if #houses > 0 then
            houseCb:SelectFirstItem()
            selectedHouseInfo = houses[1]
        end
    end
    populateHouseCombo()

    addTooltip(CharacterHomesDialogSetHomeButton, "Save selected house to your homes list")
    addTooltip(CharacterHomesDialogClearButton,   "Teleport to the selected house")

    -- Save (checkmark) button
    local addBtn = CharacterHomesDialogSetHomeButton
    addBtn:SetHandler("OnClicked", function()
        if not selectedHouseInfo then
            msg("No owned homes found — you must own at least one home.")
            return
        end
        local labelText   = zo_strtrim(addLabelEdit:GetText() or "")
        local displayName = labelText ~= "" and labelText
                            or (addTypeIndex == 1 and "Primary Residence" or selectedHouseInfo.name)
        local entryKey    = makeEntryKey(selectedHouseInfo.houseId, nil)
        local entry = { houseId = selectedHouseInfo.houseId, displayName = displayName, zone = selectedHouseInfo.zone }
        if addTypeIndex == 1 then
            charData().primary = entry
            msg("Primary home set to |cffffff%s|r.", displayName)
        elseif addTypeIndex == 2 then
            charData().named[entryKey] = entry
            msg("Character home '|cffffff%s|r' saved.", displayName)
        else
            CH.sv.account[entryKey] = entry
            msg("Account home '|cffffff%s|r' saved.", displayName)
        end
        addLabelEdit:SetText("")
        zo_callLater(populateDialog, 0)
    end)

    -- Teleport button: ports to currently selected owned house
    local teleBtn = CharacterHomesDialogClearButton
    teleBtn:SetHandler("OnClicked", function()
        if not selectedHouseInfo then
            msg("No owned homes found.")
            return
        end
        if not CanJumpToHouseFromCurrentLocation() then
            msg("Cannot teleport from your current location.")
            return
        end
        msg("Heading to |cffffff%s|r...", selectedHouseInfo.name)
        CharacterHomesDialog:SetHidden(true)
        SetGameCameraUIMode(false)
        RequestJumpToHouse(selectedHouseInfo.houseId)
    end)
end

-- ── Addon shortcut links (right of search box) ───────────────────────────────

local function buildAddonLinks()
    local dlg = CharacterHomesDialog
    -- search bar row: y=53, h=28, centre at y=67
    local ROW_Y   = 67
    local RIGHT_X = -224  -- start left of the owner filter combo (200px wide, 16px inset, 8px gap)

    local function tryLink(labelText, cmdCandidates, cmdArgs)
        local cmdKey = nil
        for _, k in ipairs(cmdCandidates) do
            if SLASH_COMMANDS[k] then cmdKey = k break end
        end
        if not cmdKey then return end

        local lbl = WINDOW_MANAGER:CreateControl(nil, dlg, CT_LABEL)
        lbl:SetFont("ZoFontGameSmall")
        lbl:SetText("|c5588bb" .. labelText .. "|r")
        lbl:SetAnchor(RIGHT, dlg, TOPRIGHT, RIGHT_X, ROW_Y)
        lbl:SetMouseEnabled(true)
        lbl:SetHandler("OnMouseEnter", function() lbl:SetText("|cffffff" .. labelText .. "|r") end)
        lbl:SetHandler("OnMouseExit",  function() lbl:SetText("|c5588bb" .. labelText .. "|r") end)
        lbl:SetHandler("OnMouseUp", function(_, btn)
            if btn == MOUSE_BUTTON_INDEX_LEFT then
                SLASH_COMMANDS[cmdKey](cmdArgs)
            end
        end)
        -- estimate width to shift next link left: ~7px per char for ZoFontGameSmall
        RIGHT_X = RIGHT_X - (#labelText * 7 + 16)
    end

    tryLink("Open Port to Friend's House",      { "/ptf" },                                    "open")

    addTooltip(CharacterHomesDialogCloseButton, "Close")
end

-- ── Init ──────────────────────────────────────────────────────────────────────

local function onAddonLoaded(_, name)
    if name ~= "CharacterHomes" then return end

    -- Migrate legacy "Default" profile to the server-specific profile so EU and
    -- NA megaserver characters don't share the same saved data bucket.
    -- Total oversight when I created this, forgot there was a separation between NA and EU
    local server = GetWorldName()
    if server and server ~= "" and server ~= "Default" then
        local raw = CharacterHomesSavedVars
        if raw and raw["Default"] and not raw[server] then
            raw[server] = raw["Default"]
            raw["Default"] = nil
        end
    end

    CH.sv = ZO_SavedVars:NewAccountWide("CharacterHomesSavedVars", 3, nil, {
        account     = {},
        characters  = {},
        ownerFilter = 0,
    }, server)

    -- ensure top-level keys exist (guards against stale saves from version 1)
    if not CH.sv.account    then CH.sv.account    = {} end
    if not CH.sv.characters then CH.sv.characters = {} end

    -- /sethome conflicts with EHT (which also registers /sethome); use /setglobalhome
    SLASH_COMMANDS["/setglobalhome"] = function(a) CH.SlashSetHome(a)   end
    SLASH_COMMANDS["/setmyhome"] = function(a) CH.SlashSetMyHome(a) end
    SLASH_COMMANDS["/resethome"] = function()  CH.SlashResetHome()  end
    SLASH_COMMANDS["/delhome"]   = function(a) CH.SlashDelHome(a)   end
    SLASH_COMMANDS["/delmyhome"] = function(a) CH.SlashDelMyHome(a) end
    -- /home conflicts with EHT; use /gohome
    SLASH_COMMANDS["/gohome"]    = function(a) CH.SlashHome(a)      end
    SLASH_COMMANDS["/homes"]     = function()  CH.SlashHomes()      end

    -- Migrate entries: re-key to official house name, fix zone (re-compute for all entries
    -- so any previously wrong zone values get corrected with the GetParentZoneId fix).
    local function migrateTable(tbl)
        local rekeyed = {}
        for k, v in pairs(tbl) do
            local houseName   = getHouseName(v.houseId) or k
            local newKey      = makeEntryKey(v.houseId, v.owner)
            v.zone = getHouseZone(v.houseId)
            if not v.displayName or v.displayName == k then
                v.displayName = houseName
            end
            rekeyed[newKey] = v
        end
        return rekeyed
    end
    CH.sv.account = migrateTable(CH.sv.account)
    for _, charEntries in pairs(CH.sv.characters) do
        if charEntries.primary then
            charEntries.primary.zone = getHouseZone(charEntries.primary.houseId)
        end
        if charEntries.named then
            charEntries.named = migrateTable(charEntries.named)
        end
    end

    -- owner filter combo (structure defined in XML)
    local ownerCb = ZO_ComboBox_ObjectFromContainer(CharacterHomesDialogOwnerFilterCombo)
    for i, opt in ipairs({ "All account homes", "My homes", "Friends' homes" }) do
        local v = i - 1
        ownerCb:AddItem(ownerCb:CreateItemEntry(opt, function()
            accountOwnerFilter = v
            CH.sv.ownerFilter  = v
            zo_callLater(populateDialog, 0)
        end))
    end
    accountOwnerFilter = CH.sv.ownerFilter or 0
    ownerCb:SelectItemByIndex(accountOwnerFilter + 1)

    buildFriendHousingBar()
    buildAddBar()
    buildAddonLinks()
end

EVENT_MANAGER:RegisterForEvent("CharacterHomes", EVENT_ADD_ON_LOADED, onAddonLoaded)
