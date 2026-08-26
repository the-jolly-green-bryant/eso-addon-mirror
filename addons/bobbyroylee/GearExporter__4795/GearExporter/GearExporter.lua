--[[
    Gear Exporter
    -------------
    /gearexport  -> scans equipped gear + backpack + bank + ESO Plus bank
                    for weapons/armor/jewelry and opens a window with a
                    plain-text report you can Select All (Ctrl+A) and
                    Copy (Ctrl+C) out of.

    Notes on how this works, since it matters for trusting the output:
      - The craft bag is NOT scanned. Equippable gear can never be stored
        there (ZOS restricts it to crafting materials), so there's nothing
        to find.
      - House storage chests are NOT scanned. There's no reliable, single
        API call to sweep every house's storage across every house you
        own, so rather than give you a partial/misleading result, this
        addon sticks to the four bags that can actually hold your gear
        (equipped, backpack, bank, ESO Plus bank).
      - Set bonus text is pulled live from GetItemLinkSetBonusInfo(), the
        same call the game itself uses to build item tooltips. It is not
        a hardcoded database, so it can't go stale or be wrong for a set
        that exists in your client.
      - A handful of secondary fields (quality name, trait name, armor/
        weapon type name) are wrapped defensively. If one of those calls
        ever fails on a future game patch, that one line is just skipped
        instead of breaking the whole export.
]]--

GearExporter = {}
local EM = GearExporter

-- ---------------------------------------------------------------------
-- Safe call helper: never let one weird item or a renamed API function
-- take down the whole scan.
-- ---------------------------------------------------------------------
local function SafeCall(fn, ...)
    if type(fn) ~= "function" then return nil end
    local ok, a, b, c, d, e, f = pcall(fn, ...)
    if ok then return a, b, c, d, e, f end
    return nil
end

-- Look up a global constant by name without ever crashing if it doesn't
-- exist on this game version.
local function Const(name)
    return _G[name]
end

local EQUIP_TYPE_INVALID  = Const("EQUIP_TYPE_INVALID")
local EQUIP_TYPE_COSTUME  = Const("EQUIP_TYPE_COSTUME")
local ARMORTYPE_NONE      = Const("ARMORTYPE_NONE")
local WEAPONTYPE_NONE     = Const("WEAPONTYPE_NONE")

local BAGS_TO_SCAN = { BAG_WORN, BAG_BACKPACK, BAG_BANK, BAG_SUBSCRIBER_BANK }

local BAG_LABELS = {
    [BAG_WORN]            = "EQUIPPED",
    [BAG_BACKPACK]        = "INVENTORY",
    [BAG_BANK]            = "BANK",
    [BAG_SUBSCRIBER_BANK] = "ESO PLUS BANK",
}

-- ---------------------------------------------------------------------
-- Per-item field helpers
-- ---------------------------------------------------------------------
local function GetEquipSlotName(itemLink)
    local equipType = SafeCall(GetItemLinkEquipType, itemLink)
    if equipType == nil then return nil end
    local name = SafeCall(GetString, "SI_EQUIPTYPE", equipType)
    if name and name ~= "" then return name end
    return nil
end

local function GetQualityName(itemLink)
    local quality = SafeCall(GetItemLinkFunctionalQuality, itemLink)
    if quality == nil then return nil end
    local name = SafeCall(GetString, "SI_ITEMQUALITY", quality)
    if name and name ~= "" then return name end
    return nil
end

local function GetTraitName(itemLink)
    local traitType = SafeCall(GetItemLinkTraitType, itemLink)
    if traitType == nil or traitType == 0 then return nil end
    local name = SafeCall(GetString, "SI_ITEMTRAITTYPE", traitType)
    if name and name ~= "" then return name end
    return nil
end

local function GetArmorOrWeaponTypeName(itemLink)
    local armorType = SafeCall(GetItemLinkArmorType, itemLink)
    if armorType ~= nil and armorType ~= ARMORTYPE_NONE then
        local name = SafeCall(GetString, "SI_ARMORTYPE", armorType)
        if name and name ~= "" then return name end
    end
    local weaponType = SafeCall(GetItemLinkWeaponType, itemLink)
    if weaponType ~= nil and weaponType ~= WEAPONTYPE_NONE then
        local name = SafeCall(GetString, "SI_WEAPONTYPE", weaponType)
        if name and name ~= "" then return name end
    end
    return nil
end

-- Is this itemLink something that can actually be worn (weapon, armor
-- piece, shield, or jewelry)? Filters out consumables/materials/etc.
local function IsGearItem(itemLink)
    local equipType = SafeCall(GetItemLinkEquipType, itemLink)
    if equipType == nil then return false end
    if EQUIP_TYPE_INVALID ~= nil and equipType == EQUIP_TYPE_INVALID then return false end
    if EQUIP_TYPE_COSTUME ~= nil and equipType == EQUIP_TYPE_COSTUME then return false end
    return true
end

-- Pull the live set name + every set bonus line straight from the game.
local function BuildSetText(itemLink, isEquipped)
    local hasSet, setName, numBonuses, numEquipped, maxEquipped = SafeCall(GetItemLinkSetInfo, itemLink)
    if not hasSet then return nil end

    local lines = {}
    table.insert(lines, string.format("  Set: %s (%d/%d equipped)",
        setName or "?", numEquipped or 0, maxEquipped or 0))

    if numBonuses and numBonuses > 0 then
        for i = 1, numBonuses do
            local numRequired, bonusDescription = SafeCall(GetItemLinkSetBonusInfo, itemLink, isEquipped, i)
            if bonusDescription and bonusDescription ~= "" then
                table.insert(lines, string.format("    (%s) %s", tostring(numRequired or "?"), bonusDescription))
            end
        end
    end

    return table.concat(lines, "\n")
end

local function BuildItemReport(bagId, slotIndex, itemLink)
    local rawName = SafeCall(GetItemLinkName, itemLink) or "Unknown Item"
    local name = SafeCall(zo_strformat, "<<1>>", rawName) or rawName

    local slotName = GetEquipSlotName(itemLink)
    local quality  = GetQualityName(itemLink)
    local trait    = GetTraitName(itemLink)
    local typeName = GetArmorOrWeaponTypeName(itemLink)
    local level    = SafeCall(GetItemLinkRequiredLevel, itemLink)

    local header = "- " .. name
    if slotName then header = header .. " [" .. slotName .. "]" end
    if quality then header = header .. " (" .. quality .. ")" end
    if bagId == BAG_WORN then
        header = header .. string.format(" {equipped slot %s}", tostring(slotIndex))
    end

    local details = {}
    if trait then table.insert(details, "Trait: " .. trait) end
    if typeName then table.insert(details, "Type: " .. typeName) end
    if level and level > 0 then table.insert(details, "Lvl " .. tostring(level)) end

    local out = header
    if #details > 0 then
        out = out .. "\n  " .. table.concat(details, " | ")
    end

    local isEquipped = (bagId == BAG_WORN)
    local setText = BuildSetText(itemLink, isEquipped)
    if setText then
        out = out .. "\n" .. setText
    end

    return out
end

-- ---------------------------------------------------------------------
-- Bag scanning. Uses the game's own SHARED_INVENTORY cache so this works
-- identically for equipped gear, backpack, and both bank bags without
-- needing to hardcode per-bag slot numbering.
-- ---------------------------------------------------------------------
local function ScanBag(bagId, reportLines)
    local ok, bagCache = pcall(function() return SHARED_INVENTORY:GetOrCreateBagCache(bagId) end)
    if not ok or type(bagCache) ~= "table" then return end

    local itemLines = {}
    for slotIndex, slotData in pairs(bagCache) do
        local itemLink = (slotData and slotData.itemLink)
        if not itemLink or itemLink == "" then
            itemLink = SafeCall(GetItemLink, bagId, slotIndex)
        end
        if itemLink and itemLink ~= "" and IsGearItem(itemLink) then
            table.insert(itemLines, BuildItemReport(bagId, slotIndex, itemLink))
        end
    end

    if #itemLines > 0 then
        table.insert(reportLines, "== " .. (BAG_LABELS[bagId] or tostring(bagId)) .. " ==")
        for _, line in ipairs(itemLines) do
            table.insert(reportLines, line)
            table.insert(reportLines, "")
        end
    end
end

function EM.BuildFullReport()
    local charName = SafeCall(GetUnitName, "player") or "Character"
    local reportLines = {
        "ESO GEAR EXPORT - " .. charName,
        "(craft bag skipped: can't hold gear | house chests not scanned)",
        "",
    }

    for _, bagId in ipairs(BAGS_TO_SCAN) do
        ScanBag(bagId, reportLines)
    end

    return table.concat(reportLines, "\n")
end

-- ---------------------------------------------------------------------
-- Display window: the report can be much larger than an ESO edit box's
-- practical input limit, so it is split into pages. The complete report
-- is still saved to SavedVariables as one string.
-- ---------------------------------------------------------------------
local windowBuilt = false
local PAGE_SIZE = 45000
local pages = {}
local currentPage = 1

local function SplitReportIntoPages(report)
    local result = {}
    local length = #report

    if length == 0 then
        result[1] = ""
        return result
    end

    local startPos = 1
    while startPos <= length do
        local targetEnd = math.min(startPos + PAGE_SIZE - 1, length)

        if targetEnd < length then
            -- Prefer a newline so an AI never receives a page ending halfway
            -- through an item. Search forward first, then backward.
            local forwardBreak = string.find(report, "\n", targetEnd, true)
            if forwardBreak and forwardBreak <= targetEnd + 4000 then
                targetEnd = forwardBreak
            else
                local backwardBreak = nil
                local pos = targetEnd
                while pos > startPos do
                    if string.sub(report, pos, pos) == "\n" then
                        backwardBreak = pos
                        break
                    end
                    pos = pos - 1
                end
                if backwardBreak and backwardBreak > startPos then
                    targetEnd = backwardBreak
                end
            end
        end

        table.insert(result, string.sub(report, startPos, targetEnd))
        startPos = targetEnd + 1
    end

    return result
end

local function UpdatePage()
    if not EM.editBox or #pages == 0 then return end

    local page = pages[currentPage] or ""
    EM.editBox:SetText(page)

    if EM.pageLabel then
        EM.pageLabel:SetText(string.format(
            "Page %d / %d  —  Ctrl+A, Ctrl+C for this page",
            currentPage, #pages))
    end

    if EM.prevButton then
        EM.prevButton:SetEnabled(currentPage > 1)
    end

    if EM.nextButton then
        EM.nextButton:SetEnabled(currentPage < #pages)
    end

    EM.editBox:TakeFocus()
    SafeCall(function() EM.editBox:SelectAll() end)
end

local function EnsureWindow()
    if windowBuilt then return end
    windowBuilt = true

    local window = WINDOW_MANAGER:CreateTopLevelWindow("GearExporterWindow")
    window:SetDimensions(820, 620)
    window:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    window:SetMovable(true)
    window:SetMouseEnabled(true)
    window:SetClampedToScreen(true)
    window:SetHidden(true)

    local bg = WINDOW_MANAGER:CreateControlFromVirtual(
        "GearExporterWindowBg", window, "ZO_DefaultBackdrop")
    bg:SetAnchorFill(window)

    local title = WINDOW_MANAGER:CreateControl(
        "GearExporterWindowTitle", window, CT_LABEL)
    title:SetAnchor(TOP, window, TOP, 0, 12)
    title:SetFont("ZoFontWinH3")
    title:SetText("Gear Export")

    local pageLabel = WINDOW_MANAGER:CreateControl(
        "GearExporterPageLabel", window, CT_LABEL)
    pageLabel:SetAnchor(TOP, window, TOP, 0, 34)
    pageLabel:SetFont("ZoFontGame")
    pageLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    EM.pageLabel = pageLabel

    local editBg = WINDOW_MANAGER:CreateControlFromVirtual(
        "GearExporterEditBg", window, "ZO_EditBackdrop")
    editBg:SetAnchor(TOPLEFT, window, TOPLEFT, 20, 58)
    editBg:SetAnchor(BOTTOMRIGHT, window, BOTTOMRIGHT, -20, -92)

    local editBox = WINDOW_MANAGER:CreateControlFromVirtual(
        "GearExporterEditBox", editBg, "ZO_DefaultEditMultiLineForBackdrop")
    editBox:SetAnchor(TOPLEFT, editBg, TOPLEFT, 6, 6)
    editBox:SetAnchor(BOTTOMRIGHT, editBg, BOTTOMRIGHT, -6, -6)
    editBox:SetMultiLine(true)
    editBox:SetFont("ZoFontGame")

    -- Each page is deliberately kept below this limit. The old addon used
    -- 60000 for the entire export, which caused long exports to be truncated.
    SafeCall(function() editBox:SetMaxInputChars(PAGE_SIZE) end)

    local prevButton = WINDOW_MANAGER:CreateControlFromVirtual(
        "GearExporterPrevButton", window, "ZO_DefaultButton")
    prevButton:SetAnchor(BOTTOMLEFT, window, BOTTOMLEFT, 20, -14)
    prevButton:SetDimensions(120, 30)
    prevButton:SetText("<< Previous")
    prevButton:SetHandler("OnClicked", function()
        if currentPage > 1 then
            currentPage = currentPage - 1
            UpdatePage()
        end
    end)

    local nextButton = WINDOW_MANAGER:CreateControlFromVirtual(
        "GearExporterNextButton", window, "ZO_DefaultButton")
    nextButton:SetAnchor(BOTTOMRIGHT, window, BOTTOMRIGHT, -20, -14)
    nextButton:SetDimensions(120, 30)
    nextButton:SetText("Next >>")
    nextButton:SetHandler("OnClicked", function()
        if currentPage < #pages then
            currentPage = currentPage + 1
            UpdatePage()
        end
    end)

    local closeButton = WINDOW_MANAGER:CreateControlFromVirtual(
        "GearExporterCloseButton", window, "ZO_DefaultButton")
    closeButton:SetAnchor(BOTTOM, window, BOTTOM, 0, -14)
    closeButton:SetDimensions(100, 30)
    closeButton:SetText("Close")
    closeButton:SetHandler("OnClicked", function()
        window:SetHidden(true)
    end)

    EM.window = window
    EM.editBox = editBox
    EM.pageLabel = pageLabel
    EM.prevButton = prevButton
    EM.nextButton = nextButton
end

function EM.ShowExport()
    EnsureWindow()

    local report = EM.BuildFullReport()

    GearExporterSavedVars = GearExporterSavedVars or {}
    GearExporterSavedVars.lastExport = report

    pages = SplitReportIntoPages(report)
    currentPage = 1

    EM.window:SetHidden(false)
    UpdatePage()
end

-- ---------------------------------------------------------------------
-- Init
-- ---------------------------------------------------------------------
local function OnAddOnLoaded(_, addonName)
    if addonName ~= "GearExporter" then return end
    EVENT_MANAGER:UnregisterForEvent("GearExporter", EVENT_ADD_ON_LOADED)
    GearExporterSavedVars = GearExporterSavedVars or {}

    SLASH_COMMANDS["/gearexport"] = EM.ShowExport
end

EVENT_MANAGER:RegisterForEvent("GearExporter", EVENT_ADD_ON_LOADED, OnAddOnLoaded)
