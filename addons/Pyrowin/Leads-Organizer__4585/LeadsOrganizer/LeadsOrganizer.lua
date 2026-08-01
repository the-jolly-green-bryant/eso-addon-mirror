--[[
    Leads Organizer — filter and sort scrying leads.
    Panel: /leadsorg or keybind (Controls → Keybindings → General).
    Search uses the in-game Antiquities journal; this panel lists active leads only.
]]

LeadsOrganizer = LeadsOrganizer or {}
local LO = LeadsOrganizer

LO.name = "LeadsOrganizer"
LO.version = "1.4.0"
LO.SCENE_NAME = "LeadsOrganizerMainScene"

local EM = EVENT_MANAGER

local function GetADM()
    return ANTIQUITY_DATA_MANAGER
end

local function SafeGetString(stringId, fallback)
    if not stringId then
        return fallback
    end
    local ok, text = pcall(GetString, stringId)
    if ok and text and text ~= "" then
        return text
    end
    return fallback
end

LO.SORT_ZONE = 1
LO.SORT_EXPIRY = 2
LO.SORT_NAME = 3

LO.SORT_LABELS = {
    [LO.SORT_ZONE] = "Zone",
    [LO.SORT_EXPIRY] = "Expiry (soonest)",
    [LO.SORT_NAME] = "Name",
}

local DEFAULT_SETTINGS = {
    sortMode = LO.SORT_EXPIRY,
    showGreenAlwaysAvailable = true,
    showCompletedBefore = true,
    hideAboveScryingSkill = false,
    currentZoneOnly = false,
}

local NO_EXPIRY_SORT_VALUE = 999999999
local LEAD_ROW_DATA_TYPE = 1

--- Journal scryable tile: primary = Scry, tertiary = View in Codex (see zo_antiquityjournal_keyboard).
--- Secondary (R) is free on that strip; used for Travel to Zone via Beam Me Up.
local KEYBIND_SCRY = "UI_SHORTCUT_PRIMARY"
local KEYBIND_TRAVEL = "UI_SHORTCUT_SECONDARY"
local KEYBIND_CODEX = "UI_SHORTCUT_TERTIARY"

local function SafeCall(method, obj, ...)
    if not obj or not method then
        return nil
    end
    local fn = obj[method]
    if not fn then
        return nil
    end
    local ok, r1, r2 = pcall(fn, obj, ...)
    if ok then
        return r1, r2
    end
    return nil
end

local function SetRowLabelTextColor(label, textColor)
    if not label or not textColor then
        return
    end
    local r, g, b = GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, textColor)
    label:SetColor(r, g, b, 1)
end

local function UpdateLeadKeybindStrip()
    if not KEYBIND_STRIP or not LO.leadKeybindStripDescriptor or not LO.leadKeybindStripActive then
        return
    end
    if KEYBIND_STRIP.RefreshKeybindButtonGroup then
        KEYBIND_STRIP:RefreshKeybindButtonGroup(LO.leadKeybindStripDescriptor)
    elseif KEYBIND_STRIP.UpdateKeybindButtonGroup then
        KEYBIND_STRIP:UpdateKeybindButtonGroup(LO.leadKeybindStripDescriptor)
    end
end

local function FormatSecondsRough(secs)
    if not secs or secs <= 0 or secs >= NO_EXPIRY_SORT_VALUE then
        return nil
    end
    local d = zo_floor(secs / 86400)
    local h = zo_floor((secs % 86400) / 3600)
    local m = zo_floor((secs % 3600) / 60)
    if d > 0 then
        return string.format("%dd %dh", d, h)
    end
    if h > 0 then
        return string.format("%dh %dm", h, m)
    end
    if m > 0 then
        return string.format("%dm", m)
    end
    return "<1m"
end

local function SafeGetLeadExpiryDisplayText(antiquityData)
    if antiquityData.GetLeadExpirationStatus then
        local ok, _, timeRemaining = pcall(function()
            return antiquityData:GetLeadExpirationStatus()
        end)
        if ok and timeRemaining and timeRemaining ~= "" then
            return timeRemaining
        end
    end
    if antiquityData.GetLeadTimeRemainingS then
        local ok, secs = pcall(function()
            return antiquityData:GetLeadTimeRemainingS()
        end)
        if ok and secs then
            local rough = FormatSecondsRough(secs)
            if rough then
                return rough .. " left"
            end
        end
    end
    local id = antiquityData.GetId and antiquityData:GetId() or antiquityData.antiquityId
    if id and GetAntiquityLeadTimeRemainingSeconds then
        local secs = GetAntiquityLeadTimeRemainingSeconds(id)
        local rough = FormatSecondsRough(secs)
        if rough then
            return rough .. " left"
        end
    end
    return nil
end

local function StripGenderSuffix(text)
    if not text or text == "" then
        return text
    end
    return text:gsub("%^[a-zA-Z]+$", "")
end

local function GetSettings()
    return LO.settings
end

--- Player zone id (stable); prefer ZOS helper over raw unit index when available.
local function GetPlayerCurrentZoneId()
    if ZO_ExplorationUtils_GetPlayerCurrentZoneId then
        local z = ZO_ExplorationUtils_GetPlayerCurrentZoneId()
        if z and z ~= 0 then
            return z
        end
    end
    local zoneIndex = GetUnitZoneIndex("player")
    if not zoneIndex then
        return nil
    end
    return GetZoneId(zoneIndex)
end

--- Zone for an antiquity/lead row (object or light table). Uses global GetAntiquityZoneId(number id) when needed — do not name this GetAntiquityZoneId (global name clash).
local function GetLeadObjectZoneId(antiquityData)
    if antiquityData.GetZoneId then
        local ok, z = pcall(function()
            return antiquityData:GetZoneId()
        end)
        if ok and z then
            return z
        end
    end
    if antiquityData.zoneId then
        return antiquityData.zoneId
    end
    local id = antiquityData.GetId and antiquityData:GetId() or antiquityData.antiquityId
    if id and GetAntiquityZoneId then
        local ok, z = pcall(function()
            return GetAntiquityZoneId(id)
        end)
        if ok and z then
            return z
        end
    end
    return nil
end

--- "Current zone only" is strict: antiquities with zone 0 / unknown (anywhere) are hidden when the filter is on.
local function LeadObjectMatchesCurrentZoneFilter(antiquityData)
    if antiquityData.IsInCurrentPlayerZone then
        local ok, matches = pcall(function()
            return antiquityData:IsInCurrentPlayerZone()
        end)
        if ok and not matches then
            return false
        end
    end
    local pZone = GetPlayerCurrentZoneId()
    if not pZone then
        return false
    end
    local aZone = GetLeadObjectZoneId(antiquityData)
    if not aZone or aZone == 0 then
        return false
    end
    return aZone == pZone
end

function LO.IsGreenAlwaysAvailable(antiquityData)
    if antiquityData.RequiresLead then
        return not antiquityData:RequiresLead()
    end
    return antiquityData.requiresLead == false
end

function LO.HasCompletedBefore(antiquityData)
    if antiquityData.GetNumRecovered and (antiquityData:GetNumRecovered() or 0) > 0 then
        return true
    end
    if (antiquityData.numRecovered or 0) > 0 then
        return true
    end
    if antiquityData.HasAchievedAllGoals and antiquityData:HasAchievedAllGoals() then
        return true
    end
    return false
end

function LO.AntiquityPassesFilters(antiquityData)
    if not antiquityData then
        return false
    end
    local settings = GetSettings()
    if not settings then
        return true
    end
    if settings.hideAboveScryingSkill then
        local meets = SafeCall("MeetsScryingSkillRequirements", antiquityData)
        if meets == false then
            return false
        end
    end
    if not settings.showGreenAlwaysAvailable and LO.IsGreenAlwaysAvailable(antiquityData) then
        return false
    end
    if not settings.showCompletedBefore and LO.HasCompletedBefore(antiquityData) then
        return false
    end
    if settings.currentZoneOnly and not LeadObjectMatchesCurrentZoneFilter(antiquityData) then
        return false
    end
    return true
end

function LO.FilterAllActiveLeads(antiquityData)
    local ok, passes = pcall(LO.AntiquityPassesFilters, antiquityData)
    return ok and passes == true
end

local function GetLeadSortTime(antiquityData)
    if not (antiquityData.HasLead and antiquityData:HasLead()) then
        return NO_EXPIRY_SORT_VALUE
    end
    local leadTime
    if antiquityData.GetLeadTimeRemainingS then
        leadTime = antiquityData:GetLeadTimeRemainingS()
    end
    if (not leadTime or leadTime == 0) and antiquityData.GetId and GetAntiquityLeadTimeRemainingSeconds then
        leadTime = GetAntiquityLeadTimeRemainingSeconds(antiquityData:GetId())
    end
    if not leadTime or leadTime == 0 then
        return NO_EXPIRY_SORT_VALUE
    end
    return leadTime
end

local function CompareAntiquityNames(left, right)
    if left.CompareNameTo and right.CompareNameTo then
        return left:CompareNameTo(right)
    end
    local ln = (left.GetName and left:GetName()) or ""
    local rn = (right.GetName and right:GetName()) or ""
    return ln < rn
end

function LO.SortByZone(leftAntiquityData, rightAntiquityData)
    local lz = GetLeadObjectZoneId(leftAntiquityData)
    local rz = GetLeadObjectZoneId(rightAntiquityData)
    local leftZone = (lz and GetZoneNameById(lz)) or ""
    local rightZone = (rz and GetZoneNameById(rz)) or ""
    if leftZone ~= rightZone then
        return leftZone < rightZone
    end
    return CompareAntiquityNames(leftAntiquityData, rightAntiquityData)
end

function LO.SortByExpiry(leftAntiquityData, rightAntiquityData)
    local leftTime = GetLeadSortTime(leftAntiquityData)
    local rightTime = GetLeadSortTime(rightAntiquityData)
    if leftTime ~= rightTime then
        return leftTime < rightTime
    end
    return LO.SortByZone(leftAntiquityData, rightAntiquityData)
end

function LO.SortByName(leftAntiquityData, rightAntiquityData)
    return CompareAntiquityNames(leftAntiquityData, rightAntiquityData)
end

function LO.GetActiveSortFunction()
    local settings = GetSettings()
    if settings.sortMode == LO.SORT_ZONE then
        return LO.SortByZone
    elseif settings.sortMode == LO.SORT_NAME then
        return LO.SortByName
    end
    return LO.SortByExpiry
end

function LO.SortActiveLeadSections()
    if not ANTIQUITY_MANAGER or not ANTIQUITY_MANAGER.antiquitySectionData then
        return false
    end

    local sortFunction = LO.GetActiveSortFunction()
    for _, section in pairs(ANTIQUITY_MANAGER.antiquitySectionData) do
        if section.sectionType == ZO_ANTIQUITY_SECTION_TYPE.ACTIVE_LEAD and section.list then
            section.sortFunction = sortFunction
            if #section.list > 1 then
                table.sort(section.list, sortFunction)
            end
        end
    end
    return true
end

function LO.ApplySubcategoryFilter()
    if ZO_SCRYABLE_ANTIQUITY_ALL_LEADS_SUBCATEGORY_DATA then
        pcall(function()
            ZO_SCRYABLE_ANTIQUITY_ALL_LEADS_SUBCATEGORY_DATA:SetAntiquityFilterFunction(LO.FilterAllActiveLeads)
        end)
    end
end

--- Same notion as “All Active Leads”: in progress, has a lead, or always-available (no lead required).
local function IsActiveLeadCandidate(antiquityData)
    if antiquityData.HasAchievedAllGoals and antiquityData:HasAchievedAllGoals() then
        return false
    end
    local inProgress = antiquityData.IsInProgress and antiquityData:IsInProgress()
    local hasLead = antiquityData.HasLead and antiquityData:HasLead()
    if inProgress or hasLead then
        return true
    end
    if antiquityData.RequiresLead then
        if not antiquityData:RequiresLead() then
            return true
        end
    elseif antiquityData.requiresLead == false then
        return true
    end
    return false
end

function LO.CollectFilteredActiveLeads()
    local seen = {}
    local list = {}

    local adm = GetADM()
    if adm and adm.antiquities then
        for _, antiquityData in pairs(adm.antiquities) do
            if antiquityData and IsActiveLeadCandidate(antiquityData) and LO.AntiquityPassesFilters(antiquityData) then
                local id = (antiquityData.GetId and antiquityData:GetId()) or antiquityData.antiquityId
                if id and not seen[id] then
                    seen[id] = true
                    table.insert(list, antiquityData)
                end
            end
        end
    end

    local sortFn = LO.GetActiveSortFunction()
    table.sort(list, sortFn)

    return list
end

local function GetRowPayload(data)
    if type(data) == "table" and data.data ~= nil then
        return data.data
    end
    return data
end

function LO.ApplyLeadRowSelection(control, antiquityId)
    if not control or not antiquityId then
        return
    end
    LO.SetLeadRowSelected(control, antiquityId)
end

function LO.OnLeadRowMouseUp(control, button, upInside, scrollList)
    if not upInside or button ~= MOUSE_BUTTON_INDEX_LEFT then
        return
    end
    scrollList = scrollList or LO.resultsScroll
    if scrollList and ZO_ScrollList_MouseClick then
        ZO_ScrollList_MouseClick(scrollList, control)
    end
    if control.loAntiquityId then
        LO.ApplyLeadRowSelection(control, control.loAntiquityId)
    end
end

function LO.OnLeadRowHighlighted(control, data)
    local antiquityId = control and control.loAntiquityId
    if not antiquityId and data then
        local payload = GetRowPayload(data)
        if type(payload) == "table" then
            antiquityId = payload.antiquityId
        end
    end
    if control and antiquityId then
        LO.ApplyLeadRowSelection(control, antiquityId)
    end
end

function LO.SetupLeadScrollRow(control, data, scrollList)
    scrollList = scrollList or LO.resultsScroll
    local payload = GetRowPayload(data)
    local text = ""
    control.loAntiquityId = nil
    if type(payload) == "table" then
        text = payload.text or ""
        control.loAntiquityId = payload.antiquityId
    elseif type(payload) == "string" then
        text = payload
    end

    control:SetMouseEnabled(true)
    if control.SetFont then
        control:SetFont("ZoFontGameMedium")
    end
    if control.SetMaxLineCount then
        control:SetMaxLineCount(2)
    end
    if control.SetWrapMode and TEXT_WRAP_MODE_WRAP_TEXT then
        control:SetWrapMode(TEXT_WRAP_MODE_WRAP_TEXT)
    end
    control:SetText(text)

    if LO.selectedAntiquityId and control.loAntiquityId == LO.selectedAntiquityId then
        LO.selectedRowControl = control
        SetRowLabelTextColor(control, INTERFACE_TEXT_COLOR_SELECTED)
    else
        SetRowLabelTextColor(control, INTERFACE_TEXT_COLOR_DEFAULT)
    end

    control:SetHandler("OnMouseUp", nil)
    control:SetHandler("OnMouseUp", function(rowControl, mouseButton, isUpInside)
        LO.OnLeadRowMouseUp(rowControl, mouseButton, isUpInside, scrollList)
    end)
end

function LO.ClearLeadSelection()
    LO.selectedRowControl = nil
    LO.selectedAntiquityId = nil
    UpdateLeadKeybindStrip()
end

function LO.SetLeadRowSelected(control, antiquityId)
    if LO.selectedRowControl and LO.selectedRowControl ~= control then
        SetRowLabelTextColor(LO.selectedRowControl, INTERFACE_TEXT_COLOR_DEFAULT)
    end
    LO.selectedRowControl = control
    LO.selectedAntiquityId = antiquityId
    SetRowLabelTextColor(control, INTERFACE_TEXT_COLOR_SELECTED)
    UpdateLeadKeybindStrip()
end

function LO.AntiquityCanScry(antiquityId)
    local adm = GetADM()
    if not antiquityId or not adm then
        return false
    end
    local data = adm:GetAntiquityData(antiquityId)
    if not data or not data.CanScry then
        return false
    end
    local ok, canScry, _msg = pcall(function()
        return data:CanScry()
    end)
    return ok and canScry == true
end

function LO.IsPanelActive()
    return LO.scene and SCENE_MANAGER:IsShowing(LO.SCENE_NAME)
end

function LO.PerformSelectedScry()
    local id = LO.selectedAntiquityId
    if not id or not ScryForAntiquity then
        return
    end
    pcall(function()
        ScryForAntiquity(id)
    end)
end

function LO.PerformSelectedCodex()
    local id = LO.selectedAntiquityId
    local adm = GetADM()
    if not id or not adm or not ANTIQUITY_JOURNAL_KEYBOARD then
        return
    end
    local data = adm:GetAntiquityData(id)
    if not data or not data.GetAntiquityCategoryData then
        return
    end
    local okCat, categoryData = pcall(function()
        return data:GetAntiquityCategoryData()
    end)
    if not okCat or not categoryData or not categoryData.GetId then
        return
    end
    local catId = categoryData:GetId()
    local formattedName = ""
    if data.GetFormattedName then
        local okN, n = pcall(function()
            return data:GetFormattedName()
        end)
        if okN and n then
            formattedName = n
        end
    end
    pcall(function()
        if SCENE_MANAGER and not SCENE_MANAGER:IsShowing("antiquityJournalKeyboard") then
            SCENE_MANAGER:Show("antiquityJournalKeyboard")
        end
        ANTIQUITY_JOURNAL_KEYBOARD:ShowCategory(catId, formattedName)
    end)
end

---------------------------------------------------------------------------
-- Travel to zone (same Beam Me Up path as SurveyMapTeleport)
---------------------------------------------------------------------------

local function NormalizeZoneId(zoneId)
    return tonumber(zoneId) or zoneId
end

local function ZoneIdsMatch(zoneIdA, zoneIdB)
    zoneIdA = NormalizeZoneId(zoneIdA)
    zoneIdB = NormalizeZoneId(zoneIdB)
    if not zoneIdA or not zoneIdB then
        return false
    end
    if zoneIdA == zoneIdB then
        return true
    end
    if BMU and BMU.getParentZoneId then
        local parentA = NormalizeZoneId(BMU.getParentZoneId(zoneIdA))
        local parentB = NormalizeZoneId(BMU.getParentZoneId(zoneIdB))
        return parentA == zoneIdB or parentB == zoneIdA or (parentA and parentB and parentA == parentB)
    end
    return false
end

local function HouseMatchesZone(record, zoneId, parentZoneId)
    if not record then
        return false
    end
    return ZoneIdsMatch(record.zoneId, zoneId)
        or ZoneIdsMatch(record.zoneId, parentZoneId)
        or ZoneIdsMatch(record.parentZoneId, zoneId)
        or ZoneIdsMatch(record.parentZoneId, parentZoneId)
end

local function GetPreferredHouseIdForZone(zoneId, parentZoneId)
    if not BMU or not BMU.getZoneSpecificHouse then
        return nil
    end
    local preferred = BMU.getZoneSpecificHouse(zoneId) or BMU.getZoneSpecificHouse(parentZoneId)
    if preferred and preferred > 0 then
        return preferred
    end
    local zoneHouses = BMU.savedVarsServ and BMU.savedVarsServ.zoneSpecificHouses
    if not zoneHouses then
        return nil
    end
    for mappedZoneId, houseId in pairs(zoneHouses) do
        if ZoneIdsMatch(mappedZoneId, zoneId) or ZoneIdsMatch(mappedZoneId, parentZoneId) then
            if houseId and houseId > 0 then
                return houseId
            end
        end
    end
    return nil
end

local function GetOwnedHousesList()
    if BMU.IsNotKeyboard and BMU.IsNotKeyboard() then
        return ZO_COLLECTIBLE_DATA_MANAGER:GetAllCollectibleDataObjects(
            { ZO_CollectibleCategoryData.IsHousingCategory },
            { ZO_CollectibleData.IsUnlocked }
        )
    end
    if COLLECTIONS_BOOK_SINGLETON then
        return COLLECTIONS_BOOK_SINGLETON:GetOwnedHouses()
    end
    return {}
end

local function GetHouseIdFromEntry(house, isGamepad)
    if isGamepad then
        return house:GetReferenceId()
    end
    return house.houseId
end

local function FindOwnedHouseInZone(zoneId, parentZoneId)
    local parentZoneName = BMU.formatName(GetZoneNameById(parentZoneId), false)
    local preferredHouseId = GetPreferredHouseIdForZone(zoneId, parentZoneId)
    local fallbackHouseId
    local isGamepad = BMU.IsNotKeyboard and BMU.IsNotKeyboard()

    for _, house in pairs(GetOwnedHousesList()) do
        local houseId = GetHouseIdFromEntry(house, isGamepad)
        if houseId and houseId > 0 then
            local houseZoneId = GetHouseZoneId(houseId)
            if ZoneIdsMatch(houseZoneId, zoneId) or ZoneIdsMatch(houseZoneId, parentZoneId) then
                if preferredHouseId and houseId == preferredHouseId then
                    return houseId, parentZoneName
                end
                if not fallbackHouseId then
                    fallbackHouseId = houseId
                end
            end
        end
    end

    if preferredHouseId and preferredHouseId > 0 then
        return preferredHouseId, parentZoneName
    end
    return fallbackHouseId, parentZoneName
end

local function ResolveHouseForZone(zoneId, resultTable)
    local parentZoneId = NormalizeZoneId(BMU.getParentZoneId(zoneId))
    zoneId = NormalizeZoneId(zoneId)
    local parentZoneName = BMU.formatName(GetZoneNameById(parentZoneId), false)
    local preferredHouseId = GetPreferredHouseIdForZone(zoneId, parentZoneId)

    if preferredHouseId and preferredHouseId > 0 then
        return preferredHouseId, parentZoneName
    end

    if resultTable then
        for _, record in pairs(resultTable) do
            if record and record.isOwnHouse and record.houseId and record.houseId > 0 then
                if HouseMatchesZone(record, zoneId, parentZoneId) then
                    return record.houseId, record.parentZoneName or parentZoneName
                end
            end
        end
    end

    return FindOwnedHouseInZone(zoneId, parentZoneId)
end

local function JumpToHouseOutside(houseId, zoneId)
    if BMU.portToOwnHouseWithZonePreference then
        -- Preferred house for zone first, then houseId as fallback (never primary residence).
        BMU.portToOwnHouseWithZonePreference(true, zoneId, true, houseId)
    elseif BMU.portToOwnHouse then
        local parentZoneId = BMU.getParentZoneId(zoneId)
        local parentZoneName = BMU.formatName(GetZoneNameById(parentZoneId), false)
        BMU.portToOwnHouse(false, houseId, true, parentZoneName)
    end
end

local function TryPortToHouseInZone(zoneId, resultTable)
    if not BMU.portToOwnHouse and not BMU.portToOwnHouseWithZonePreference then
        return false
    end
    if not CanLeaveCurrentLocationViaTeleport() then
        return false
    end

    local houseId = ResolveHouseForZone(zoneId, resultTable)
    if not houseId or houseId == 0 then
        return false
    end

    -- Defer like Beam Me Up / SurveyMapTeleport (secure call context).
    zo_callLater(function()
        if not CanLeaveCurrentLocationViaTeleport() then
            return
        end
        JumpToHouseOutside(houseId, zoneId)
    end, 250)

    return true
end

local function ReportNoTravel()
    if BMU and BMU.printToChat and BMU.SI then
        BMU.printToChat(BMU.SI.get("SI_TELE_CHAT_NO_FAST_TRAVEL"))
    else
        CHAT_ROUTER:AddSystemMessage("Leads Organizer: No travel option for this zone (no players, no house there, or no wayshrine discovered).")
    end
end

--- Player jump first; then own house in zone; then wayshrine recall for overland zones.
local function PortToZone(zoneId)
    zoneId = NormalizeZoneId(zoneId)
    local resultTable = BMU.createTable({
        index = BMU.indexListZoneHidden,
        fZoneId = zoneId,
        dontDisplay = true,
        noOwnHouses = false,
    })

    for _, entry in pairs(resultTable) do
        if entry and entry.displayName and entry.displayName ~= "" and not entry.zoneWithoutPlayer then
            BMU.PortalToPlayer(
                entry.displayName,
                entry.sourceIndexLeading,
                entry.zoneName,
                entry.zoneId,
                entry.category,
                true,
                true,
                true
            )
            return
        end
    end

    if TryPortToHouseInZone(zoneId, resultTable) then
        return
    end

    if BMU.isZoneOverlandZone and BMU.isZoneOverlandZone(zoneId) and BMU.PortalToZone then
        BMU.PortalToZone(zoneId)
        return
    end

    ReportNoTravel()
end

function LO.GetSelectedLeadZoneId()
    local id = LO.selectedAntiquityId
    if not id then
        return nil
    end
    local adm = GetADM()
    local data = adm and adm:GetAntiquityData(id)
    if not data then
        return nil
    end
    local zoneId = GetLeadObjectZoneId(data)
    if not zoneId or zoneId == 0 then
        return nil
    end
    return zoneId
end

function LO.CanTravelToSelectedLeadZone()
    return LO.GetSelectedLeadZoneId() ~= nil
end

function LO.PerformSelectedTravelToZone()
    if not BMU or not BMU.createTable or not BMU.PortalToPlayer or not BMU.portToOwnHouse then
        CHAT_ROUTER:AddSystemMessage("Leads Organizer: Travel to Zone requires Beam Me Up to be enabled.")
        return
    end

    local zoneId = LO.GetSelectedLeadZoneId()
    if not zoneId then
        CHAT_ROUTER:AddSystemMessage("Leads Organizer: Could not determine the zone for this lead.")
        return
    end

    PortToZone(zoneId)
end

function LO.BuildLeadKeybindStripDescriptor()
    if LO.leadKeybindStripDescriptor then
        return
    end
    -- Visible strip at bottom of screen (same shortcuts as Antiquities journal scryable tiles).
    -- Secondary (R) = Travel to Zone (Beam Me Up); free on the journal tile strip.
    LO.leadKeybindStripDescriptor = {
        {
            alignment = KEYBIND_STRIP_ALIGN_CENTER,
            name = function()
                return SafeGetString(SI_ANTIQUITY_SCRY, "Scry")
            end,
            keybind = KEYBIND_SCRY,
            callback = function()
                LO.PerformSelectedScry()
            end,
            visible = function()
                return LO.IsPanelActive()
            end,
            enabled = function()
                return LO.selectedAntiquityId ~= nil
            end,
        },
        {
            alignment = KEYBIND_STRIP_ALIGN_CENTER,
            name = function()
                return "Travel to Zone"
            end,
            keybind = KEYBIND_TRAVEL,
            callback = function()
                LO.PerformSelectedTravelToZone()
            end,
            visible = function()
                return LO.IsPanelActive()
            end,
            enabled = function()
                return LO.CanTravelToSelectedLeadZone()
            end,
        },
        {
            alignment = KEYBIND_STRIP_ALIGN_CENTER,
            name = function()
                return SafeGetString(SI_ANTIQUITY_VIEW_IN_CODEX, "View in Codex")
            end,
            keybind = KEYBIND_CODEX,
            callback = function()
                LO.PerformSelectedCodex()
            end,
            visible = function()
                return LO.IsPanelActive()
            end,
            enabled = function()
                return LO.selectedAntiquityId ~= nil
            end,
        },
        {
            alignment = KEYBIND_STRIP_ALIGN_CENTER,
            name = function()
                return SafeGetString(SI_DIALOG_CLOSE, "Close")
            end,
            keybind = "UI_SHORTCUT_NEGATIVE",
            callback = function()
                LO.ToggleWindow()
            end,
            visible = function()
                return LO.IsPanelActive()
            end,
        },
    }
end

function LO.InstallLeadKeybindStrip()
    LO.BuildLeadKeybindStripDescriptor()
    if LO.leadKeybindStripActive or not KEYBIND_STRIP or not LO.leadKeybindStripDescriptor then
        return
    end
    local ok = pcall(function()
        KEYBIND_STRIP:AddKeybindButtonGroup(LO.leadKeybindStripDescriptor)
    end)
    LO.leadKeybindStripActive = ok
    UpdateLeadKeybindStrip()
end

function LO.RemoveLeadKeybindStrip()
    if not LO.leadKeybindStripActive or not KEYBIND_STRIP or not LO.leadKeybindStripDescriptor then
        return
    end
    pcall(function()
        KEYBIND_STRIP:RemoveKeybindButtonGroup(LO.leadKeybindStripDescriptor)
    end)
    LO.leadKeybindStripActive = false
end

function LO.SetupResultsScrollList()
    if LO.leadScrollInitialized then
        return
    end
    local backdrop = LO.window and LO.window:GetNamedChild("ResultsBackdrop")
    LO.resultsScroll = backdrop and backdrop:GetNamedChild("ScrollList")
    if not LO.resultsScroll or not ZO_ScrollList_AddDataType then
        return
    end
    -- Built-in ZO_SelectableLabel rows receive mouse clicks; custom Control wrappers often do not.
    ZO_ScrollList_AddDataType(LO.resultsScroll, LEAD_ROW_DATA_TYPE, "ZO_SelectableLabel", 52, LO.SetupLeadScrollRow, nil)
    if ZO_ScrollList_EnableHighlight then
        ZO_ScrollList_EnableHighlight(LO.resultsScroll, "ZO_ThinListHighlight", LO.OnLeadRowHighlighted)
    end
    LO.leadScrollInitialized = true
end

function LO.RefreshPanelLeadList()
    LO.SetupResultsScrollList()
    local scroll = LO.resultsScroll
    if not scroll then
        return
    end

    LO.ClearLeadSelection()

    local scrollData = ZO_ScrollList_GetDataList(scroll)
    ZO_ClearNumericallyIndexedTable(scrollData)

    local list = LO.CollectFilteredActiveLeads()
    if #list == 0 then
        table.insert(scrollData, ZO_ScrollList_CreateDataEntry(LEAD_ROW_DATA_TYPE, {
            text = "No active leads match the current filters. Open Journal → Antiquities → Scryable once if this stays empty.",
        }))
    else
        for i = 1, #list do
            local antiquityData = list[i]
            local quality = (antiquityData.GetQuality and antiquityData:GetQuality()) or 0
            local rawName = (antiquityData.GetName and antiquityData:GetName()) or "?"
            local qualityColor = GetAntiquityQualityColor(quality)
            local name = qualityColor:Colorize(StripGenderSuffix(rawName))
            local line = string.format("• %s — %s", name, LO.FormatLeadLineDetail(antiquityData))
            local id = (antiquityData.GetId and antiquityData:GetId()) or antiquityData.antiquityId
            table.insert(scrollData, ZO_ScrollList_CreateDataEntry(LEAD_ROW_DATA_TYPE, { text = line, antiquityId = id }))
        end
    end

    ZO_ScrollList_Commit(scroll)
    if ZO_ScrollList_ResetToTop then
        ZO_ScrollList_ResetToTop(scroll)
    end
    LO.TrySelectFirstLead()
    UpdateLeadKeybindStrip()
end

function LO.TrySelectFirstLead()
    local scroll = LO.resultsScroll
    if not scroll then
        return
    end
    local dataList = ZO_ScrollList_GetDataList(scroll)
    for i = 1, #dataList do
        local payload = GetRowPayload(dataList[i])
        if type(payload) == "table" and payload.antiquityId then
            if ZO_ScrollList_SetHighlightedDataIndex then
                ZO_ScrollList_SetHighlightedDataIndex(scroll, i)
            end
            zo_callLater(function()
                if not LO.resultsScroll then
                    return
                end
                local control
                if ZO_ScrollList_GetDataIndexControl then
                    control = ZO_ScrollList_GetDataIndexControl(LO.resultsScroll, i)
                end
                if control and control.loAntiquityId then
                    LO.SetLeadRowSelected(control, control.loAntiquityId)
                else
                    LO.selectedAntiquityId = payload.antiquityId
                    UpdateLeadKeybindStrip()
                end
            end, 0)
            return
        end
    end
end

function LO.FormatLeadLineDetail(antiquityData)
    local parts = {}
    local zoneId = GetLeadObjectZoneId(antiquityData)
    local zoneName = (zoneId and zoneId ~= 0) and GetZoneNameById(zoneId) or nil
    if zoneName and zoneName ~= "" then
        table.insert(parts, zoneName)
    end

    if antiquityData.HasLead and antiquityData:HasLead() then
        local timeRemaining = SafeGetLeadExpiryDisplayText(antiquityData)
        if timeRemaining and timeRemaining ~= "" then
            table.insert(parts, "Expires: " .. timeRemaining)
        else
            table.insert(parts, "Lead active")
        end
    elseif LO.IsGreenAlwaysAvailable(antiquityData) then
        table.insert(parts, "Always available")
    end

    if antiquityData.MeetsScryingSkillRequirements and not antiquityData:MeetsScryingSkillRequirements() then
        table.insert(parts, "Scrying skill too low")
    end

    if antiquityData.IsInProgress and antiquityData:IsInProgress() then
        table.insert(parts, "In progress")
    end

    return table.concat(parts, " · ")
end

function LO.RefreshAntiquityLists()
    LO.ApplySubcategoryFilter()
    LO.SortActiveLeadSections()
    local adm = GetADM()
    if adm then
        adm:RefreshAll()
    end
    zo_callLater(function()
        if SCENE_MANAGER:IsShowing(LO.SCENE_NAME) then
            LO.RefreshPanelLeadList()
        end
    end, 100)
end

function LO.InstallHooks()
    if not LO.SortActiveLeadSections() then
        zo_callLater(LO.InstallHooks, 1000)
        return
    end
    LO.ApplySubcategoryFilter()
    LO.RefreshAntiquityLists()
end

function LO.OnSortSelected(_, _, entry)
    GetSettings().sortMode = entry.sortMode
    LO.RefreshAntiquityLists()
end

function LO.SetupSortDropdown(dropdown)
    if not dropdown then
        return
    end

    dropdown:ClearItems()
    dropdown:SetSortsItems(false)

    local defaultEntry
    for sortMode = LO.SORT_ZONE, LO.SORT_NAME do
        local entry = ZO_ComboBox:CreateItemEntry(LO.SORT_LABELS[sortMode], LO.OnSortSelected)
        entry.sortMode = sortMode
        dropdown:AddItem(entry, ZO_COMBOBOX_SUPPRESS_UPDATE)
        if GetSettings().sortMode == sortMode then
            defaultEntry = entry
        end
    end

    dropdown:UpdateItems()
    if defaultEntry then
        dropdown:SelectItem(defaultEntry)
    end
end

function LO.OnHideScryingToggled(control, button, upInside)
    ZO_CheckButton_OnClicked(control)
    GetSettings().hideAboveScryingSkill = ZO_CheckButton_IsChecked(control)
    LO.RefreshAntiquityLists()
end

function LO.OnShowGreenToggled(control, button, upInside)
    ZO_CheckButton_OnClicked(control)
    GetSettings().showGreenAlwaysAvailable = ZO_CheckButton_IsChecked(control)
    LO.RefreshAntiquityLists()
end

function LO.OnShowDoneToggled(control, button, upInside)
    ZO_CheckButton_OnClicked(control)
    GetSettings().showCompletedBefore = ZO_CheckButton_IsChecked(control)
    LO.RefreshAntiquityLists()
end

function LO.OnCurrentZoneOnlyToggled(control, button, upInside)
    ZO_CheckButton_OnClicked(control)
    GetSettings().currentZoneOnly = ZO_CheckButton_IsChecked(control)
    LO.RefreshAntiquityLists()
end

function LO.SetCheckButtonState(button, checked)
    if not button then
        return
    end
    if checked then
        ZO_CheckButton_SetChecked(button)
    else
        ZO_CheckButton_SetUnchecked(button)
    end
end

function LO.SyncWindowControlsFromSettings()
    LO.SetupSortDropdown(LO.sortDropdown)
    LO.SetCheckButtonState(LO.hideScryingToggle, GetSettings().hideAboveScryingSkill)
    LO.SetCheckButtonState(LO.showGreenToggle, GetSettings().showGreenAlwaysAvailable)
    LO.SetCheckButtonState(LO.showDoneToggle, GetSettings().showCompletedBefore)
    LO.SetCheckButtonState(LO.currentZoneOnlyToggle, GetSettings().currentZoneOnly)
end

function LO.BuildSettingsMenu()
    if not LibAddonMenu2 then
        return
    end

    local panelData = {
        type = "panel",
        name = "Leads Organizer",
        displayName = "Leads Organizer",
        author = "ESO Community",
        version = LO.version,
        registerForRefresh = true,
        registerForDefaults = true,
    }

    local options = {
        {
            type = "description",
            text = "Open the panel with |c00FFFF/leadsorg|r or assign a key in Controls → Keybindings → General. Use the Antiquities journal search when you need text search.",
        },
        {
            type = "dropdown",
            name = "Sort active leads by",
            tooltip = "Applies to Active Leads lists in the Scryable antiquities journal and to this panel.",
            choices = { LO.SORT_LABELS[LO.SORT_ZONE], LO.SORT_LABELS[LO.SORT_EXPIRY], LO.SORT_LABELS[LO.SORT_NAME] },
            choicesValues = { LO.SORT_ZONE, LO.SORT_EXPIRY, LO.SORT_NAME },
            getFunc = function() return GetSettings().sortMode end,
            setFunc = function(value)
                GetSettings().sortMode = value
                LO.SyncWindowControlsFromSettings()
                LO.RefreshAntiquityLists()
            end,
            default = DEFAULT_SETTINGS.sortMode,
        },
        {
            type = "checkbox",
            name = "Hide leads this character cannot scry (skill)",
            tooltip = "Hides antiquities that require a higher Scrying skill than this character currently has.",
            getFunc = function() return GetSettings().hideAboveScryingSkill end,
            setFunc = function(value)
                GetSettings().hideAboveScryingSkill = value
                LO.SyncWindowControlsFromSettings()
                LO.RefreshAntiquityLists()
            end,
            default = DEFAULT_SETTINGS.hideAboveScryingSkill,
        },
        {
            type = "checkbox",
            name = "Show green always-available leads",
            tooltip = "Zone starter leads that do not require discovering a lead. Affects All Active Leads only.",
            getFunc = function() return GetSettings().showGreenAlwaysAvailable end,
            setFunc = function(value)
                GetSettings().showGreenAlwaysAvailable = value
                LO.SyncWindowControlsFromSettings()
                LO.RefreshAntiquityLists()
            end,
            default = DEFAULT_SETTINGS.showGreenAlwaysAvailable,
        },
        {
            type = "checkbox",
            name = "Show leads completed before",
            tooltip = "Antiquities you have already recovered at least once.",
            getFunc = function() return GetSettings().showCompletedBefore end,
            setFunc = function(value)
                GetSettings().showCompletedBefore = value
                LO.SyncWindowControlsFromSettings()
                LO.RefreshAntiquityLists()
            end,
            default = DEFAULT_SETTINGS.showCompletedBefore,
        },
        {
            type = "checkbox",
            name = "Show leads in current zone only",
            tooltip = "When enabled, only antiquities tied to a specific zone that matches where you are now are listed. Uses the same player zone as the game UI. Entries with no fixed zone (zone 0) are hidden while this is on. Also updates All Active Leads in the journal.",
            getFunc = function() return GetSettings().currentZoneOnly end,
            setFunc = function(value)
                GetSettings().currentZoneOnly = value
                LO.SyncWindowControlsFromSettings()
                LO.RefreshAntiquityLists()
            end,
            default = DEFAULT_SETTINGS.currentZoneOnly,
        },
    }

    LibAddonMenu2:RegisterAddonPanel("LeadsOrganizerOptions", panelData)
    LibAddonMenu2:RegisterOptionControls("LeadsOrganizerOptions", options)
end

function LO.InitializeWindow()
    if LO.windowInitialized then
        return
    end

    LO.window = LeadsOrganizerWindowTopLevel
    if not LO.window then
        return
    end

    local closeBtn = LO.window:GetNamedChild("Close")
    if closeBtn then
        closeBtn:SetHandler("OnClicked", function()
            LO.ToggleWindow()
        end)
    end

    local sortDropdownControl = LO.window:GetNamedChild("SortDropdown")
    LO.sortDropdown = sortDropdownControl and ZO_ComboBox_ObjectFromContainer(sortDropdownControl)
    LO.SetupSortDropdown(LO.sortDropdown)

    local function filterRowToggle(rowName, toggleName)
        local row = LO.window:GetNamedChild(rowName)
        return row and row:GetNamedChild(toggleName)
    end
    LO.hideScryingToggle = filterRowToggle("FilterRowHideScrying", "HideScryingToggle")
    LO.showGreenToggle = filterRowToggle("FilterRowShowGreen", "ShowGreenToggle")
    LO.showDoneToggle = filterRowToggle("FilterRowShowDone", "ShowDoneToggle")
    LO.currentZoneOnlyToggle = filterRowToggle("FilterRowCurrentZone", "CurrentZoneOnlyToggle")

    LO.SetCheckButtonState(LO.hideScryingToggle, GetSettings().hideAboveScryingSkill)
    LO.SetCheckButtonState(LO.showGreenToggle, GetSettings().showGreenAlwaysAvailable)
    LO.SetCheckButtonState(LO.showDoneToggle, GetSettings().showCompletedBefore)
    LO.SetCheckButtonState(LO.currentZoneOnlyToggle, GetSettings().currentZoneOnly)

    if LO.hideScryingToggle then
        LO.hideScryingToggle:SetHandler("OnClicked", LO.OnHideScryingToggled)
    end
    if LO.showGreenToggle then
        LO.showGreenToggle:SetHandler("OnClicked", LO.OnShowGreenToggled)
    end
    if LO.showDoneToggle then
        LO.showDoneToggle:SetHandler("OnClicked", LO.OnShowDoneToggled)
    end
    if LO.currentZoneOnlyToggle then
        LO.currentZoneOnlyToggle:SetHandler("OnClicked", LO.OnCurrentZoneOnlyToggled)
    end

    LO.SetupResultsScrollList()

    LO.scene = SCENE_MANAGER:GetScene(LO.SCENE_NAME)
    if not LO.scene then
        local fragment = ZO_FadeSceneFragment:New(LO.window)
        LO.scene = ZO_Scene:New(LO.SCENE_NAME, SCENE_MANAGER)
        LO.scene:AddFragment(fragment)
        if FRAGMENT_GROUP and FRAGMENT_GROUP.MOUSE_DRIVEN_UI_WINDOW then
            LO.scene:AddFragmentGroup(FRAGMENT_GROUP.MOUSE_DRIVEN_UI_WINDOW)
        end
        SCENE_MANAGER:Add(LO.scene)

        LO.scene:RegisterCallback("StateChange", function(oldState, newState)
            if newState == SCENE_SHOWING then
                LO.InstallLeadKeybindStrip()
            elseif newState == SCENE_SHOWN then
                LO.SyncWindowControlsFromSettings()
                LO.RefreshAntiquityLists()
                UpdateLeadKeybindStrip()
            elseif newState == SCENE_HIDING or newState == SCENE_HIDDEN then
                LO.RemoveLeadKeybindStrip()
                LO.ClearLeadSelection()
            end
        end)
    end

    LO.windowInitialized = true
end

function LO.EnsureWindow()
    if not LO.windowInitialized then
        LO.InitializeWindow()
    end
    return LO.scene ~= nil
end

function LO.ToggleWindow()
    if not LO.EnsureWindow() then
        return
    end
    if SCENE_MANAGER:IsShowing(LO.SCENE_NAME) then
        SCENE_MANAGER:Hide(LO.SCENE_NAME)
    else
        SCENE_MANAGER:Show(LO.SCENE_NAME)
    end
end

LeadsOrganizer.ToggleWindow = LO.ToggleWindow

function LO.Initialize()
    ZO_CreateStringId("SI_BINDING_NAME_LEADS_ORGANIZER_TOGGLE", "Toggle Leads Organizer")

    LO.settings = ZO_SavedVars:NewAccountWide("LeadsOrganizer_SavedVariables", 2, nil, DEFAULT_SETTINGS)

    LO.BuildSettingsMenu()
    LO.InstallHooks()

    EM:RegisterForEvent(LO.name, EVENT_ANTIQUITY_UPDATED, function()
        zo_callLater(LO.RefreshAntiquityLists, 50)
    end)
    EM:RegisterForEvent(LO.name, EVENT_ANTIQUITY_LEAD_ACQUIRED, function()
        zo_callLater(LO.RefreshAntiquityLists, 50)
    end)
    EM:RegisterForEvent(LO.name, EVENT_SKILL_RANK_UPDATE, function()
        zo_callLater(LO.RefreshAntiquityLists, 50)
    end)
    EM:RegisterForEvent(LO.name, EVENT_PLAYER_ACTIVATED, function()
        LO.EnsureWindow()
        zo_callLater(LO.RefreshAntiquityLists, 50)
    end)

    SLASH_COMMANDS["/leadsorg"] = function()
        LO.ToggleWindow()
    end

    SLASH_COMMANDS["/leadsorganizer"] = function(arg)
        if arg == "refresh" then
            LO.RefreshAntiquityLists()
            d("Leads Organizer: refreshed.")
        else
            LO.ToggleWindow()
        end
    end
end

local function OnAddOnLoaded(_, addOnName)
    if addOnName ~= LO.name then
        return
    end
    EM:UnregisterForEvent(LO.name, EVENT_ADD_ON_LOADED)
    local ok, err = pcall(LO.Initialize)
    if not ok then
        d("Leads Organizer failed to initialize: " .. tostring(err))
    end
end

EM:RegisterForEvent(LO.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)

function LeadsOrganizer_Keybind_Toggle()
    if LeadsOrganizer and LeadsOrganizer.ToggleWindow then
        LeadsOrganizer.ToggleWindow()
    end
end
