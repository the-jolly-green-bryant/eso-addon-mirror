CompanionHelper = CompanionHelper or {}
local CH = CompanionHelper

CH.addon_name = "CompanionHelper"
CH.status = CH.status or {} -- must be populated somewhere
CH.CompanionData = CH.CompanionData or {}
CH.CompanionData.Companion = CH.CompanionData.Companion or {}


local function GetRapportStatus()
    for statusName, range in pairs(CH.status) do
      if CH.ActiveCompanion.Rapport >= range.min and CH.ActiveCompanion.Rapport <= range.max then
          return statusName, range.min, range.max == 5500 and range.max or range.max + 1
      end
    end
end

local function GetCompanionRapportData()
    CH.ActiveCompanion.Rapport = GetActiveCompanionRapport()
    CH.ActiveCompanion.Status, CH.ActiveCompanion.StatusMinVal, CH.ActiveCompanion.StatusMaxVal = GetRapportStatus()
    CH.ActiveCompanion.StatusPercentCompletion = (CH.ActiveCompanion.Rapport / CH.ActiveCompanion.StatusMaxVal) * 100
end

local function MessageCompanionRapport()
    d(string.format(
        "|c1565c0You and %s are currently %s partners. You're currently: %d/%d (%.0f%%) through %s's tier|r",
        CH.ActiveCompanion.name,
        CH.ActiveCompanion.Status,
        CH.ActiveCompanion.Rapport,
        CH.ActiveCompanion.StatusMaxVal,
        CH.ActiveCompanion.StatusPercentCompletion,
        CH.ActiveCompanion.name
    ))
end

local function SetActiveCompanion()
    local defId = GetActiveCompanionDefId()
    local data = CH.CompanionData.Companion[defId]
    if not data then return end

    CH.ActiveCompanion = data
    GetCompanionRapportData()

    CH.LastSummoned = CH.LastSummoned or data

    if CH.LastSummoned.name ~= data.name then
        CH.LastSummoned = data
        CH.ActiveCompanion = data
        d("Welcome to the party " .. data.name)
        MessageCompanionRapport()
    end
end

local function UnsetActiveCompanion()
    local name = (CH.ActiveCompanion and CH.ActiveCompanion.name) or "companion"
    d("Farewell " .. name .. ", may our paths cross some other time")
    CH.ActiveCompanion = nil
end

local function OnCompanionRapportUpdate(eventCode, companionDefId, rapportDelta, newRapport)
    local positiveChange = newRapport > CH.ActiveCompanion.Rapport
    CH.ActiveCompanion.Rapport = newRapport

    local tierPromotion = newRapport >= CH.ActiveCompanion.StatusMaxVal
    local tierDemotion = newRapport <= CH.ActiveCompanion.StatusMinVal

    if tierPromotion or tierDemotion then
        GetRapportStatus()
    end

    if positiveChange then
        if tierPromotion then
            d(string.format(
                "|c2e7d32%s is values you so much, you are now considered a %s partner, your new rapport is %d/%d (%d%%)|r",
                CH.ActiveCompanion.name,
                CH.ActiveCompanion.Status,
                CH.ActiveCompanion.Rapport,
                CH.ActiveCompanion.StatusMaxVal,
                CH.ActiveCompanion.StatusPercentCompletion
            ))
        else
            d(string.format(
                "|c2e7d32%s is extremely pleased with your recent actions, your new rapport is %d/%d (%d%%)|r",
                CH.ActiveCompanion.name,
                CH.ActiveCompanion.Rapport,
                CH.ActiveCompanion.StatusMaxVal,
                CH.ActiveCompanion.StatusPercentCompletion
            ))
        end
    elseif not positiveChange then
        if tierDemotion then
            d(string.format(d
                "|cd32f2f%s is has shunned you and now considers you a %s, your new rapport is %d/%d (%d%%)|r",
                CH.ActiveCompanion.name,
                CH.ActiveCompanion.Status,
                CH.ActiveCompanion.Rapport,
                CH.ActiveCompanion.StatusMaxVal,
                CH.ActiveCompanion.StatusPercentCompletion
            ))
        else
            d(string.format(
                "|cd32f2f%s is severely displeased with your recent actions, your new rapport is %d/%d (%d%%)|r",
                CH.ActiveCompanion.name,
                CH.ActiveCompanion.Rapport,
                CH.ActiveCompanion.StatusMaxVal,
                CH.ActiveCompanion.StatusPercentCompletion
            ))
        end
    end
end

local function OnAddonLoaded(_, addonName)
    if addonName ~= CH.addon_name then return end
    EVENT_MANAGER:UnregisterForEvent(CH.addon_name, EVENT_ADD_ON_LOADED)

    SetActiveCompanion()
    CreateDevPanel()
    UpdateDevPanelVisibility()

    if EVENT_COMPANION_ACTIVATED then
        EVENT_MANAGER:RegisterForEvent(CH.addon_name, EVENT_COMPANION_ACTIVATED, function(_, companionDefId)
            SetActiveCompanion(companionDefId or GetActiveCompanionDefId())
        end)
    end

    if EVENT_COMPANION_DEACTIVATED then
        EVENT_MANAGER:RegisterForEvent(CH.addon_name, EVENT_COMPANION_DEACTIVATED, function()
            UnsetActiveCompanion()
        end)
    end

    local currentId = GetActiveCompanionDefId and GetActiveCompanionDefId() or nil
    if currentId and currentId ~= 0 then
        SetActiveCompanion(currentId)
    end

    if EVENT_COMPANION_RAPPORT_UPDATE then
        EVENT_MANAGER:RegisterForEvent(CH.addon_name, EVENT_COMPANION_RAPPORT_UPDATE, OnCompanionRapportUpdate)
    end
end

local function HandleSlashCommand(arg)
    if arg == 'rapport' then
        GetCompanionRapportData()
        MessageCompanionRapport()
    end
end

SLASH_COMMANDS["/companionhelper"] = function(arg)
    HandleSlashCommand(arg)
end


EVENT_MANAGER:RegisterForEvent(CH.addon_name, EVENT_ADD_ON_LOADED, OnAddonLoaded)