TamrielAmbulance = {}

-- AddOn variables
TamrielAmbulance.name = "TamrielAmbulance"
TamrielAmbulance.prettyName = "Tamriel Ambulance"
TamrielAmbulance.coloredName = "|cff0000Tamriel |c000000Ambulance|r"
TamrielAmbulance.author = "|cff6600Infenix|r"
TamrielAmbulance.version = "1.2.11"
TamrielAmbulance.website = "https://github.com/ImInfenix/TamrielAmbulance"

-------------------------------------------------------------------------------------------------------------------------
-- Initialization
-------------------------------------------------------------------------------------------------------------------------

function TamrielAmbulance.Initialize()
    TamrielAmbulance.savedVariables = ZO_SavedVars:NewAccountWide("TamrielAmbulance_SavedVariables", 1, nil, {})

    -- Fonts
    TamrielAmbulance.fonts = {
        ["Large"] = 2,
        ["Medium"] = 3,
        ["Small"] = 4
    }

    -- LibAddonMenu-2.0 Initializing
    TamrielAmbulance.InitializeLAM()

    -- Window display settings restore
    if TamrielAmbulance.savedVariables.GUILeft == nil then
        TamrielAmbulance.savedVariables.GUILeft = 0
    end
    if TamrielAmbulance.savedVariables.GUITop == nil then
        TamrielAmbulance.savedVariables.GUITop = 540
    end
    if TamrielAmbulance.savedVariables.resurrectionCount == nil then
        TamrielAmbulance.savedVariables.resurrectionCount = 0
    end
    if TamrielAmbulance.savedVariables.recordedResurrections == nil then
        TamrielAmbulance.savedVariables.recordedResurrections = {}
    end

    TamrielAmbulance.shouldDisplay = true
    TamrielAmbulance.UpdateDisplayCondition()

    local left = TamrielAmbulance.savedVariables.GUILeft
    local top = TamrielAmbulance.savedVariables.GUITop

    GUI_TamrielAmbulance:ClearAnchors()
    GUI_TamrielAmbulance:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
    TamrielAmbulance.UpdateFontSize()

    -- AddOn Loading
    EVENT_MANAGER:RegisterForEvent(TamrielAmbulance.name, EVENT_PLAYER_ACTIVATED, TamrielAmbulance.OnPlayerActivated)

    -- Game Layout
    EVENT_MANAGER:RegisterForEvent(TamrielAmbulance.name, EVENT_ACTION_LAYER_POPPED, TamrielAmbulance.LayerPopped)
    EVENT_MANAGER:RegisterForEvent(TamrielAmbulance.name, EVENT_ACTION_LAYER_PUSHED, TamrielAmbulance.LayerPushed)

    -- AddOn Tracking
    EVENT_MANAGER:RegisterForEvent(TamrielAmbulance.name, EVENT_RESURRECT_RESULT,
        TamrielAmbulance.OnResurrectionResultReceived)
    EVENT_MANAGER:RegisterForEvent(TamrielAmbulance.name, EVENT_GROUP_MEMBER_JOINED,
        TamrielAmbulance.OnMemberJoinedGroup)
    EVENT_MANAGER:RegisterForEvent(TamrielAmbulance.name, EVENT_GROUP_MEMBER_LEFT, TamrielAmbulance.OnMemberLeftGroup)

    TamrielAmbulance.UpdateWindow()
end

function TamrielAmbulance.OnAddOnLoaded(eventCode, addonName)
    if (addonName ~= TamrielAmbulance.name or isLoaded) then
        return
    end

    -- Unregister for load event
    EVENT_MANAGER:UnregisterForEvent(addonName, eventCode)

    TamrielAmbulance.Initialize()
end

function TamrielAmbulance.OnPlayerActivated(eventCode)
    -- Unregister for player activated event
    EVENT_MANAGER:UnregisterForEvent(addonName, eventCode)
end

-------------------------------------------------------------------------------------------------------------------------
-- Core AddOn Callbacks
-------------------------------------------------------------------------------------------------------------------------

function TamrielAmbulance.OnResurrectionResultReceived(eventCode, targetCharacterName, result, targetDisplayName)
    if (result == RESURRECT_RESULT_SUCCESS) then
        local resurrectionsTable = TamrielAmbulance.savedVariables.recordedResurrections
        local currentCount = resurrectionsTable[targetDisplayName]
        if (currentCount == nil) then
            resurrectionsTable[targetDisplayName] = 1
        else
            resurrectionsTable[targetDisplayName] = currentCount + 1
        end
        TamrielAmbulance.UpdateWindow()
    end
end

-------------------------------------------------------------------------------------------------------------------------
-- Core AddOn Functions
-------------------------------------------------------------------------------------------------------------------------

function TamrielAmbulance.UpdateDisplayCondition()
    if (TamrielAmbulance.savedVariables.showOnlyInGroup) then
        TamrielAmbulance.shouldDisplay = IsPlayerInGroup(GetUnitName("player"))
    else
        TamrielAmbulance.shouldDisplay = true
    end
end

function TamrielAmbulance.GetPlayersCount()
    local counter = 0
    for _ in pairs(TamrielAmbulance.savedVariables.recordedResurrections) do
        counter = counter + 1
    end
    return counter
end

function TamrielAmbulance.GetPlayersDisplayCount()
    return math.min(TamrielAmbulance.GetPlayersCount(), TamrielAmbulance.savedVariables.maximumPlayerDisplayCount)
end

local function GetSortedTable(t, order)
    -- collect the keys
    local keys = {}
    for k in pairs(t) do
        keys[#keys + 1] = k
    end

    -- if order function given, sort by it by passing the table and keys a, b,
    -- otherwise just sort the keys
    if order then
        table.sort(keys, function(a, b)
            return order(t, a, b)
        end)
    else
        table.sort(keys)
    end

    -- return the iterator function
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end

-------------------------------------------------------------------------------------------------------------------------
-- Other Callbacks
-------------------------------------------------------------------------------------------------------------------------

function TamrielAmbulance.OnMemberJoinedGroup(eventCode, memberCharacterName, memberDisplayName, isLocalPlayer)
    if (isLocalPlayer) then
        if (TamrielAmbulance.savedVariables.showOnlyInGroup) then
            TamrielAmbulance.shouldDisplay = true
            TamrielAmbulance.ToggleWindow(true)
        end
        if (TamrielAmbulance.savedVariables.resetOnGroupJoined) then
            TamrielAmbulance.ResetCounter()
        end
    end
end

function TamrielAmbulance.OnMemberLeftGroup(eventCode, memberCharacterName, reason, isLocalPlayer, isLeader,
    memberDisplayName, actionRequiredVote)
    if (isLocalPlayer and TamrielAmbulance.savedVariables.showOnlyInGroup) then
        TamrielAmbulance.shouldDisplay = false
        TamrielAmbulance.ToggleWindow(false)
    end
end

-------------------------------------------------------------------------------------------------------------------------
-- UI Handling
-------------------------------------------------------------------------------------------------------------------------

function TamrielAmbulance.LayerPopped(eventCode, layerIndex, activeLayerIndex)
    TamrielAmbulance.ToggleWindow(activeLayerIndex == 2)
end

function TamrielAmbulance.LayerPushed(eventCode, layerIndex, activeLayerIndex)
    TamrielAmbulance.ToggleWindow(activeLayerIndex == 2)
end

function TamrielAmbulance.SaveWindowPosition()
    TamrielAmbulance.savedVariables.GUILeft = GUI_TamrielAmbulance:GetLeft()
    TamrielAmbulance.savedVariables.GUITop = GUI_TamrielAmbulance:GetTop()
end

function TamrielAmbulance.ToggleWindow(value)
    GUI_TamrielAmbulance:SetHidden(not value or not TamrielAmbulance.shouldDisplay)
end

function TamrielAmbulance.SwitchDisplayStatus()
    TamrielAmbulance.shouldDisplay = not TamrielAmbulance.shouldDisplay
    TamrielAmbulance.ToggleWindow(true)
end

function TamrielAmbulance.ResetCounter()
    TamrielAmbulance.savedVariables.recordedResurrections = {}
    TamrielAmbulance.UpdateWindow()
end

function TamrielAmbulance.UpdateWindow()

    local resurrectionsTable = TamrielAmbulance.savedVariables.recordedResurrections

    if (not TamrielAmbulance.savedVariables.displayByPlayer) then
        local resurrectionCount = 0
        for name, count in pairs(resurrectionsTable) do
            resurrectionCount = resurrectionCount + count
        end
        GUI_TamrielAmbulanceCounter:SetText(resurrectionCount)
    else
        local playersNames = nil
        local playersCounters = nil

        local displayedPlayers = 0
        local maximumPlayerDisplayCount = TamrielAmbulance.savedVariables.maximumPlayerDisplayCount

        for key, value in GetSortedTable(resurrectionsTable, function(t, a, b)
            return t[b] < t[a]
        end) do
            if (playersNames == nil) then
                playersNames = key
                playersCounters = value
            else
                playersNames = playersNames .. "\n" .. key
                playersCounters = playersCounters .. "\n" .. value
            end

            displayedPlayers = displayedPlayers + 1

            if (displayedPlayers >= maximumPlayerDisplayCount) then
                break
            end
        end

        GUI_TamrielAmbulancePlayersList:SetText(playersNames)
        GUI_TamrielAmbulanceCountersList:SetText(playersCounters)
    end

    GUI_TamrielAmbulanceCounter:SetHidden(TamrielAmbulance.savedVariables.displayByPlayer)
    GUI_TamrielAmbulancePlayersList:SetHidden(not TamrielAmbulance.savedVariables.displayByPlayer)
    GUI_TamrielAmbulanceCountersList:SetHidden(not TamrielAmbulance.savedVariables.displayByPlayer)

    TamrielAmbulance.UpdateWindowSize()
end

function TamrielAmbulance.UpdateFontSize()
    local fontSize = TamrielAmbulance.fonts[TamrielAmbulance.savedVariables.selectedFontSize]

    GUI_TamrielAmbulanceTitle:SetFont("ZoFontWinH" .. fontSize)
    GUI_TamrielAmbulanceCounter:SetFont("ZoFontWinH" .. (fontSize + 1))
    GUI_TamrielAmbulancePlayersList:SetFont("ZoFontWinH" .. (fontSize + 1))
    GUI_TamrielAmbulanceCountersList:SetFont("ZoFontWinH" .. (fontSize + 1))

    TamrielAmbulance.UpdateWindowSize()
end

function TamrielAmbulance.UpdateWindowSize()
    local fontDrawSize = TamrielAmbulance.fonts[TamrielAmbulance.savedVariables.selectedFontSize]

    if (TamrielAmbulance.savedVariables.displayByPlayer) then
        TamrielAmbulance.globalWidth = 140 + (6 - fontDrawSize) * 20
        TamrielAmbulance.globalHeight = 40 + TamrielAmbulance.GetPlayersDisplayCount() * (17 + (6 - fontDrawSize) * 2)
    else
        TamrielAmbulance.globalWidth = 100 + (6 - fontDrawSize) * 15
        TamrielAmbulance.globalHeight = 50
    end

    GUI_TamrielAmbulance:SetDimensions(TamrielAmbulance.globalWidth, TamrielAmbulance.globalHeight)
    GUI_TamrielAmbulanceBackground:SetDimensions(TamrielAmbulance.globalWidth, TamrielAmbulance.globalHeight)
end

function TamrielAmbulance.SwitchDisplayMode()
    TamrielAmbulance.savedVariables.displayByPlayer = not TamrielAmbulance.savedVariables.displayByPlayer
    TamrielAmbulance.UpdateWindow()
end

-------------------------------------------------------------------------------------------------------------------------
-- Entry Point
-------------------------------------------------------------------------------------------------------------------------

EVENT_MANAGER:RegisterForEvent(TamrielAmbulance.name, EVENT_ADD_ON_LOADED, TamrielAmbulance.OnAddOnLoaded)

-------------------------------------------------------------------------------------------------------------------------
-- AddOn Commands
-------------------------------------------------------------------------------------------------------------------------

SLASH_COMMANDS["/ambulance"] = TamrielAmbulance.SwitchDisplayStatus
SLASH_COMMANDS["/resetambulance"] = TamrielAmbulance.ResetCounter

-------------------------------------------------------------------------------------------------------------------------
-- AddOn Bindings
-------------------------------------------------------------------------------------------------------------------------

ZO_CreateStringId("SI_BINDING_NAME_TAMRIEL_AMBULANCE_TOGGLE", "Toggle Window")
ZO_CreateStringId("SI_BINDING_NAME_TAMRIEL_AMBULANCE_RESET", "Reset counter")
ZO_CreateStringId("SI_BINDING_NAME_TAMRIEL_AMBULANCE_SWITCH", "Switch display mode")
