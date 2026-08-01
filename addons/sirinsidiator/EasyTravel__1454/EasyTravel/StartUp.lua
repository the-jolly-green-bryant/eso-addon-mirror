local ADDON_NAME = "EasyTravel"
local ET = {
    class = {},
    internal = {
        chat = LibChatMessage(ADDON_NAME, "ET"),
        gettext = LibGetText(ADDON_NAME).gettext
    }
}
_G[ADDON_NAME] = ET
local class = ET.class
local internal = ET.internal
local gettext = internal.gettext

local nextEventHandleIndex = 1

local function RegisterForEvent(event, callback)
    local eventHandleName = ADDON_NAME .. nextEventHandleIndex
    EVENT_MANAGER:RegisterForEvent(eventHandleName, event, callback)
    nextEventHandleIndex = nextEventHandleIndex + 1
    return eventHandleName
end

local function UnregisterForEvent(event, name)
    EVENT_MANAGER:UnregisterForEvent(name, event)
end

local function WrapFunction(object, functionName, wrapper)
    if(type(object) == "string") then
        wrapper = functionName
        functionName = object
        object = _G
    end
    local originalFunction = object[functionName]
    object[functionName] = function(...) return wrapper(originalFunction, ...) end
end

internal.RegisterForEvent = RegisterForEvent
internal.UnregisterForEvent = UnregisterForEvent
internal.WrapFunction = WrapFunction

local function OnAddonLoaded(callback)
    local eventHandle = ""
    eventHandle = RegisterForEvent(EVENT_ADD_ON_LOADED, function(event, name)
        if(name ~= ADDON_NAME) then return end
        callback()
        UnregisterForEvent(event, name)
    end)
end

OnAddonLoaded(function()
    local zoneList = class.ZoneList:New()
    internal.zoneList = zoneList
    internal.playerList = class.PlayerList:New(zoneList)
    internal.dialogHelper = class.DialogHelper:New()
    internal.targetHelper = class.TargetHelper:New(internal.playerList)
    local jumpHelper = class.JumpHelper:New(internal.dialogHelper, internal.targetHelper)
    internal.jumpHelper = jumpHelper
    internal.SlashCommandHelper = class.SlashCommandHelper:New(zoneList, internal.playerList, internal.jumpHelper)

    local CANNOT_JUMP_TO = {
        [1] = true, -- Tamriel
        [24] = true, -- The Aurbis
        [39] = true, -- Blackreach
        [GetCyrodiilMapIndex()] = true,
        [GetImperialCityMapIndex()] = true,
    }

    local function ShowSubTargetMenu(subTargets, control)
        ClearMenu()

        for i = 1, #subTargets do
            local target = subTargets[i]
            AddCustomMenuItem(target.data.name, function() jumpHelper:JumpTo(target.data) end)
        end

        ShowMenu(control)
    end

    local function AttemptJumpTo(mapIndex, control)
        if(CANNOT_JUMP_TO[mapIndex]) then
            -- TRANSLATORS: Alert message when trying to jump to a location that can not be reached
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.GENERAL_ALERT_ERROR, gettext("Target cannot be reached via jump"))
            return false
        end

        local targetZone = zoneList:SetMapByIndex(mapIndex)
        if(targetZone) then
            local subTargets = zoneList:GetSubTargets(mapIndex)
            if(subTargets) then
                ShowSubTargetMenu(subTargets, control)
                return false
            else
                jumpHelper:JumpTo(targetZone)
                return true
            end
        end
    end

    local function CancelJump()
        CancelCast()
        zo_callLater(function()
            jumpHelper:CleanUp(false)
        end, 1)
    end

    ET.JumpTo = AttemptJumpTo
    ET.CancelJump = CancelJump

    ZO_PreHook("ZO_WorldMapLocationRowLocation_OnMouseUp", function(label, button, upInside)
        if(upInside and button == MOUSE_BUTTON_INDEX_RIGHT) then
            local data = ZO_ScrollList_GetData(label:GetParent())
            AttemptJumpTo(data.index, label)
            PlaySound(SOUNDS.MAP_LOCATION_CLICKED)
            return true
        end
    end)
end)
