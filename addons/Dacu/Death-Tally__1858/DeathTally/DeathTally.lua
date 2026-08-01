--[[
    Developed by Dacu https://twitch.tv/daacu
  ]]
-------------------------------------------------------------------------------------------------
--  Libraries --
-------------------------------------------------------------------------------------------------

DeathTally = {}

DeathTally.Default = {
    OffsetX = 20,
    OffsetY = 75
}
DeathTally.DisplayName = "Death Tally"
DeathTally.Version = "1.3.2 "
DeathTally.Author = "Dacu"
DeathTally.name = "DeathTally"
DeathTally.variableVersion = 1

--- Hide the window if visible and screen state changed to some dialogue/menu interface.
-- @return void
local function HideIfVisible()
    if DeathTally.savedVariables.hiddenUI == false then
        DeathTallyIndicator:SetHidden(true)
    end
end
 
--- Show the window if visible and screen state returned to normal.
-- @return void
local function ShowIfVisible()
    if DeathTally.savedVariables.hiddenUI == false then
        DeathTallyIndicator:SetHidden(false)
    end
end

function DeathTally:RestorePosition()
    DeathTallyIndicator:ClearAnchors()
    DeathTallyIndicator:SetHidden(DeathTally.savedVariables.hiddenUI)
    DeathTallyIndicator:SetTopmost(true)
    DeathTallyIndicator:BringWindowToTop(true)
    DeathTallyIndicator:SetAnchor(
        TOPLEFT,
        GuiRoot,
        TOPLEFT,
        DeathTally.savedVariables.OffsetX,
        DeathTally.savedVariables.OffsetY
    )
    if (DeathTally.AWsavedVariables.TitleColour) then
        DeathTallyIndicatorLabel:SetColor(unpack(DeathTally.AWsavedVariables.TitleColour))
    end
    if DeathTally.AWsavedVariables.NameColour then
        DeathTallyIndicatorData:SetColor(unpack(DeathTally.AWsavedVariables.NameColour))
    end
    if DeathTally.AWsavedVariables.CountColour then
        DeathTallyIndicatorData2:SetColor(unpack(DeathTally.AWsavedVariables.CountColour))
    end
    
end

function DeathTally:SetColour()
    if (DeathTally.AWsavedVariables.TitleColour) then
        DeathTallyIndicatorLabel:SetColor(unpack(DeathTally.AWsavedVariables.TitleColour))
    end
    if DeathTally.AWsavedVariables.NameColour then
        DeathTallyIndicatorData:SetColor(unpack(DeathTally.AWsavedVariables.NameColour))
    end
    if DeathTally.AWsavedVariables.CountColour then
        DeathTallyIndicatorData2:SetColor(unpack(DeathTally.AWsavedVariables.CountColour))
    end
end

function tablelength(T)
    local count = 0
    for _ in pairs(T) do
        count = count + 1
    end
    return count
end

function settext(table2, col)
    list = {}
    tbl = {}
    output = ""
    -- count = 0
    for name, value in pairs(table2) do
        list[#list + 1] = name
    end
    function byval(a, b)
        return table2[a] > table2[b]
    end
    table.sort(list, byval)
    for k = 1, #list do
        if col == "k" then
            output = output .. (list[k]) .. "\n\r"
        elseif col == "all" then
            output = output .. (list[k]) .. ": " .. table2[list[k]] .. " | "
        else
            output = output .. table2[list[k]] .. "\n\r"
        end
    end
    return output
end

function DeathTally.resetTally()
    table1 = {}
    DeathTallyIndicatorData:SetText(settext(table1, "k"))
    DeathTallyIndicatorData2:SetText(settext(table1))
    DeathTallyIndicatorBg:SetDimensions(230, 55)
    DeathTallyIndicatorContainer:SetDimensions(230, 0)
    DeathTally.AWsavedVariables.Table = table1
end

local function printdeath(eventCode, unitTag, isDead)

    if isDead == true then
        if (unitTag == string.match(unitTag, "^group.*$") and unitTag ~= string.match(unitTag, "^group.companion.*$")) then
            local name1 = GetUnitName(unitTag)
            username = GetUnitDisplayName(unitTag)
            username = username:gsub("^@", "")
            local tempcount = table1[username]
            if tempcount == nil then
                table1[username] = 1
            else
                table1[username] = tempcount + 1
            end
            --d(username ..": "..table1[username])

            tl = tablelength(table1)
            --temptbl = settext(table1)
            DeathTallyIndicatorData:SetText(settext(table1, "k"))
            DeathTallyIndicatorData2:SetText(settext(table1))
            DeathTally.AWsavedVariables.Table = table1
            if tl < DeathTally.savedVariables.TallyLength then
                bglen = ((26 * tl) + 55 + 20)
                contlen = ((26 * tl) + 20)
            else
                bglen = ((26 * DeathTally.savedVariables.TallyLength) + 55 + 20)
                contlen = ((26 * DeathTally.savedVariables.TallyLength) + 20)
            end
            DeathTallyIndicatorBg:SetDimensions(230, bglen)
            DeathTallyIndicatorContainer:SetDimensions(230, contlen)
            DeathTallyIndicatorData:SetDimensions(230, contlen)
            DeathTallyIndicatorData2:SetDimensions(230, contlen)
        
        end
    end
end

--### Output Tally to chat ###--
function DeathTally.postTally()
    CHAT_SYSTEM.textEntry:SetText(settext(table1, "all"))
    CHAT_SYSTEM:Maximize()
    CHAT_SYSTEM.textEntry:Open()
    CHAT_SYSTEM.textEntry:FadeIn()
end

local function loadTableToMem()
    if DeathTally.AWsavedVariables.Table ~= nil then
        table2 = {}
        table2 = DeathTally.AWsavedVariables.Table
        tl = tablelength(table2)
        DeathTallyIndicatorData:SetText(settext(table2, "k"))
        DeathTallyIndicatorData2:SetText(settext(table2))
        if tl == 0 then
            bglen = 55
            contlen = 0
        elseif tl < DeathTally.savedVariables.TallyLength then
            bglen = ((26 * tl) + 55 + 20)
            contlen = ((26 * tl) + 20)
        else
            bglen = ((26 * DeathTally.savedVariables.TallyLength) + 55 + 20)
            contlen = ((26 * DeathTally.savedVariables.TallyLength) + 20)
        end
        DeathTallyIndicatorBg:SetDimensions(230, bglen)
        DeathTallyIndicatorContainer:SetDimensions(230, contlen)
        table1 = table2
    end
end

local function grpJoin(eventCode, memberName)
    me = GetUnitName("player")
    if string.match(memberName, me ..".*$" ) then
        if DeathTally.AWsavedVariables.ShowJoin == true then
            DeathTally.savedVariables.hiddenUI = false
            DeathTallyIndicator:SetHidden(false)
            DeathTallyIndicator:SetTopmost(true)
            DeathTallyIndicator:BringWindowToTop(true)
        end
        if DeathTally.AWsavedVariables.ResetJoin == true then
            DeathTally.resetTally()
        end
    end
end

local function grpLeft(eventCode, memberName)
    me = GetUnitName("player")
    if string.match(memberName, me .. ".*$") then
        if DeathTally.AWsavedVariables.HideLeave == true then
            DeathTally.savedVariables.hiddenUI = true
            DeathTallyIndicator:SetHidden(true)
        end
    end
end

-------------------------------------------------------------------------------------------------
--  Menu Functions --
-------------------------------------------------------------------------------------------------
function DeathTally.CreateSettingsWindow()
    local panelData = {
        type = "panel",
        name = "Death Tally",
        displayName = "Death tally",
        author = "DacuTV",
        version = DeathTally.version,
        slashCommand = "/tallysettings",
        registerForRefresh = true,
        registerForDefaults = true
    }

    local optionsData = {
        [1] = {
            type = "header",
            name = "Death Tally Settings"
        },
        [2] = {
            type = "description",
            text = "Here you can adjust how Death Tally Displays."
        },
        [3] = {
            type = "checkbox",
            name = "Show Tally on Group Join",
            tooltip = "When ON the Death Tally will be visible when you join a group. When OFF the Tally will not change state at group join.",
            default = true,
            getFunc = function()
                return DeathTally.AWsavedVariables.ShowJoin
            end,
            setFunc = function(newValue)
                DeathTally.AWsavedVariables.ShowJoin = newValue
            end
        },
        [4] = {
            type = "checkbox",
            name = "Hide Tally when leaving Group",
            tooltip = "When ON the Death Tally will be hidden when you leave a group. When OFF the Tally will not change state when you leave a group.",
            default = true,
            getFunc = function()
                return DeathTally.AWsavedVariables.HideLeave
            end,
            setFunc = function(newValue)
                DeathTally.AWsavedVariables.HideLeave = newValue
            end
        },
        [5] = {
            type = "checkbox",
            name = "Reset Tally when joining Group",
            tooltip = "When ON the Death Tally will be reset when you join a group. When OFF the Tally data will remain unchanged when joining groups.",
            default = false,
            getFunc = function()
                return DeathTally.AWsavedVariables.ResetJoin
            end,
            setFunc = function(newValue)
                DeathTally.AWsavedVariables.ResetJoin = newValue
            end
        },
        [6] = {
            type = "header",
            name = "Custom Colors"
        },
        [7] = {
            type = "description",
            text = "All  the Pretty Stuff, you can set custom colors for your Death Tally UI"
        },
        [8] = {
            type = "colorpicker",
            name = "Death Tally Title Color",
            tooltip = "Changes the Title color of the Death Tally.",
            getFunc = function()
                if DeathTally.AWsavedVariables.TitleColour then
                    return unpack(DeathTally.AWsavedVariables.TitleColour)
                end
            end,
            setFunc = function(r, g, b, a)
                DeathTally.AWsavedVariables.TitleColour = {r, g, b, a}
                DeathTally:SetColour()
            end
        },
        [9] = {
            type = "colorpicker",
            name = "Death Tally Name Color",
            tooltip = "Changes the Player Name color on the Death Tally.",
            getFunc = function()
                if DeathTally.AWsavedVariables.NameColour then
                    return unpack(DeathTally.AWsavedVariables.NameColour)
                end
            end,
            setFunc = function(r, g, b, a)
                DeathTally.AWsavedVariables.NameColour = {r, g, b, a}
                DeathTally:SetColour()
            end
        },
        [10] = {
            type = "colorpicker",
            name = "Death Tally Death Count Color",
            tooltip = "Changes the Death Count number color of the Death Tally.",
            getFunc = function()
                if DeathTally.AWsavedVariables.CountColour then
                    return unpack(DeathTally.AWsavedVariables.CountColour)
                end
            end,
            setFunc = function(r, g, b, a)
                DeathTally.AWsavedVariables.CountColour = {r, g, b, a}
                DeathTally:SetColour()
            end
        },
        [11] = {
            type = "header",
            name = "Tally Length"
        },
        [12] = {
            type = "description",
            text = "Here you can adjust how many deaths the tally displays before it turns into a scroll window."
        },
        [13] = {
            type = "slider",
            name = "On Screen Deaths",
            min = 4,
            max = 40,
            default = 20,
            getFunc = function()
                if DeathTally.savedVariables.TallyLength then
                    return DeathTally.savedVariables.TallyLength
                end
            end,
            setFunc = function(newValue)
                DeathTally.savedVariables.TallyLength = newValue
                loadTableToMem()
            end
        }
    }

    local LAM = LibAddonMenu2

    LAM:RegisterAddonPanel("MyAddon", panelData)
    LAM:RegisterOptionControls("MyAddon", optionsData)
end

function DeathTally.ToggleWindow()
    if not DeathTally.savedVariables.hiddenUI == false then
        DeathTally.savedVariables.hiddenUI = false
        DeathTallyIndicator:SetHidden(false)
        DeathTallyIndicator:SetTopmost(true)
        DeathTallyIndicator:BringWindowToTop(true)
    else
        DeathTally.savedVariables.hiddenUI = true
        DeathTallyIndicator:SetHidden(true)
    end
end

function DeathTally:Initialize()
    EVENT_MANAGER:RegisterForEvent("DeathState", EVENT_UNIT_DEATH_STATE_CHANGED, printdeath)
    EVENT_MANAGER:RegisterForEvent("PlayerActive", EVENT_PLAYER_ACTIVATED, loadTableToMem)
    EVENT_MANAGER:RegisterForEvent("GroupMemberJoined", EVENT_GROUP_MEMBER_JOINED, grpJoin)
    EVENT_MANAGER:RegisterForEvent("GroupMemberLeft", EVENT_GROUP_MEMBER_LEFT, grpLeft)
    DeathTally.CreateSettingsWindow()
    DeathTally.savedVariables = ZO_SavedVars:New("DeathTallySavedVariables", DeathTally.variableVersion, nil, DeathTally.Default)
    DeathTally.AWsavedVariables = ZO_SavedVars:NewAccountWide("DeathTallySavedVariables", DeathTally.variableVersion, nil, DeathTally.Default)
    DeathTally:RestorePosition()
    table1 = {}

    ZO_PreHookHandler(ZO_GameMenu_InGame, "OnShow", function()
        HideIfVisible()
    end)
    ZO_PreHookHandler(ZO_GameMenu_InGame, "OnHide", function()
        ShowIfVisible()
    end)
    ZO_PreHookHandler(ZO_InteractWindow, "OnShow", function()
        HideIfVisible()
    end)
    ZO_PreHookHandler(ZO_InteractWindow, "OnHide", function()
        ShowIfVisible()
    end)
    ZO_PreHookHandler(ZO_KeybindStripControl, "OnShow", function()
        HideIfVisible()
    end)
    ZO_PreHookHandler(ZO_KeybindStripControl, "OnHide", function()
        ShowIfVisible()
    end)
    ZO_PreHookHandler(ZO_MainMenuCategoryBar, "OnShow", function()
        HideIfVisible()
    end)
    ZO_PreHookHandler(ZO_MainMenuCategoryBar, "OnHide", function()
        ShowIfVisible()
    end)

   if not DeathTally.savedVariables.TallyLength then
        DeathTally.savedVariables.TallyLength = 20
    end
end

local function OnAddOnLoaded(event, addonName)
    if addonName == DeathTally.name then
        DeathTally:Initialize()
    end
end

function DeathTally.SaveLoc()
    DeathTally.savedVariables.OffsetX = DeathTallyIndicator:GetLeft()
    DeathTally.savedVariables.OffsetY = DeathTallyIndicator:GetTop()
end

EVENT_MANAGER:RegisterForEvent(DeathTally.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)

ZO_CreateStringId("SI_BINDING_NAME_DEATH_TALLY_TOGGLE", "Toggle Window")
ZO_CreateStringId("SI_BINDING_NAME_DEATH_TALLY_RESET", "Reset Tally")
ZO_CreateStringId("SI_BINDING_NAME_DEATH_TALLY_TOCHAT", "Post Tally to Chat")
SLASH_COMMANDS["/resettally"] = DeathTally.resetTally
SLASH_COMMANDS["/tallyui"] = DeathTally.ToggleWindow
SLASH_COMMANDS["/posttally"] = DeathTally.postTally

