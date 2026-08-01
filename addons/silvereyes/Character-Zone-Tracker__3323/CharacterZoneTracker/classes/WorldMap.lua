--[[ 
    ===================================
          World Map Integration
    ===================================
  ]]
  
local addon = CharacterZoneTracker
local debug = false
local CBZ_DIALOG_NAME_CONFIRM_ZONE_RESET = addon.name .. "_ConfirmZoneReset"
local CBZ_DIALOG_NAME_CONFIRM_LOAD_ACCOUNT = addon.name .. "_ConfirmLoadAccount"
local COLOR_NORMAL = ZO_ColorDef:New(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_NORMAL))
local COLOR_QUALITY_ARTIFACT = ZO_ColorDef:New(GetInterfaceColor(INTERFACE_COLOR_TYPE_ITEM_QUALITY_COLORS, ITEM_DISPLAY_QUALITY_ARTIFACT))
local getPinDetails, getCompleteText, getResetText, markPinComplete, markPinIncomplete, shouldPinShowCompletionMenu

-- Singleton class
local WorldMap = ZO_Object:Subclass()

function WorldMap:New()
    return ZO_Object.New(self)
end

function WorldMap:Initialize()
  
    -- Placeholder handler to make the total number of handlers returned by GetDynamicHandlers be greater than 1, to trigger the context menu.
    local dummyHandler =
    {
        name = function() return GetString(SI_DIALOG_CANCEL) end,
        gamepadName = GetString(SI_DIALOG_CANCEL),
        gamepadDialogEntryName = GetString(SI_DIALOG_CANCEL),
        gamepadDialogEntryColor = COLOR_NORMAL,
        callback = function(pin) --[[ noop ]] end,
        czbRemove = true
    }
    
    -- Menu action to force-complete a zone activity
    ZO_MapPin.PIN_CLICK_HANDLERS[MOUSE_BUTTON_INDEX_LEFT][MAP_PIN_TYPE_POI_SEEN] = 
    {
        {
            -- Show / hide logic for pin menu
            show = shouldPinShowCompletionMenu,
            GetDynamicHandlers = function(pin)
                local handlers = {
                    {
                        name = getCompleteText,
                        gamepadName = getCompleteText,
                        gamepadDialogEntryName = getCompleteText,
                        gamepadDialogEntryColor = COLOR_NORMAL,
                        callback = markPinComplete,
                    },
                    dummyHandler,
                }

                return handlers
            end,
        }
    }
  
    -- Menu action to force-reset a zone activity
    ZO_MapPin.PIN_CLICK_HANDLERS[MOUSE_BUTTON_INDEX_LEFT][MAP_PIN_TYPE_POI_COMPLETE] = 
    {
        {
            -- Show / hide logic for pin menu
            show = shouldPinShowCompletionMenu,
            GetDynamicHandlers = function(pin)
                local handlers = {
                    {
                        name = getResetText,
                        gamepadName = getResetText,
                        gamepadDialogEntryName = getResetText,
                        gamepadDialogEntryColor = COLOR_NORMAL,
                        callback = markPinIncomplete,
                    },
                    dummyHandler,
                }

                return handlers
            end,
        }
    }
    
    -- Hook pin click menu creation events to remove the dummy handler menu entry before display.
    ZO_PreHook("ZO_WorldMap_SetupGamepadChoiceDialog", function(...) self:PrehookSetupPinChoiceMenu(...) end)
    ZO_PreHook("ZO_WorldMap_SetupKeyboardChoiceMenu", function(...) self:PrehookSetupPinChoiceMenu(...) end)

    -- Replace keyboard world map completion background with the tall version, to add room for our buttons
    function ZO_WorldMapZoneStory_Keyboard:GetBackgroundFragment()
        return MEDIUM_TALL_LEFT_PANEL_BG_FRAGMENT
    end
    
    -- Map completion reset button dialog
    ESO_Dialogs[CBZ_DIALOG_NAME_CONFIRM_ZONE_RESET] =
    {
        title = {
            text = SI_CZB_RESET_ACTION,
        },
        mainText = {
            text = SI_CZB_RESET_CONFIRM,
            align = TEXT_ALIGN_CENTER
        },
        buttons = {
            [1] = {
                text = SI_OPTIONS_RESET,
                callback = function(dialog)
                    addon.ZoneGuideTracker:ResetCurrentZone()
                end
            },
            [2] = {
                text = SI_DIALOG_CANCEL
            }
        }
    }
    
    -- Show the reset button
    CharacterZoneTracker_KeyboardResetButton:SetHidden(false)
    
    -- Map completion load account button dialog
    ESO_Dialogs[CBZ_DIALOG_NAME_CONFIRM_LOAD_ACCOUNT] =
    {
        title = {
            text = SI_CZB_LOAD_ACCOUNT_ACTION,
        },
        mainText = {
            text = SI_CZB_LOAD_ACCOUNT_CONFIRM,
            align = TEXT_ALIGN_CENTER
        },
        buttons = {
            [1] = {
                text = SI_CZB_LOAD,
                callback = function(dialog)
                    addon.ZoneGuideTracker:LoadBaseGameCompletionForCurrentZone()
                end
            },
            [2] = {
                text = SI_DIALOG_CANCEL
            }
        }
    }
    
    -- Show the load account button
    CharacterZoneTracker_KeyboardLoadAccountButton:SetHidden(false)
end




---------------------------------------
--
--          Public Methods
-- 
---------------------------------------

function WorldMap:PrehookSetupPinChoiceMenu(pinDatas)
    for pinDataIndex = #pinDatas, 1, -1 do
        local pinData = pinDatas[pinDataIndex]
        local handler = pinData.handler
        if handler then
            if handler.czbRemove then
                table.remove(pinDatas, pinDataIndex)
            end
        end
    end
end

function WorldMap:OnKeyboardLoadAccountButtonClick(control)
  
    local zoneId, completionZoneId = addon.Utility.GetZoneIdsAndIndexes(GetCurrentMapZoneIndex())
    if completionZoneId == 0 then
        return
    end
    
    local zoneName = GetZoneNameById(completionZoneId)
    ZO_Dialogs_ShowDialog(CBZ_DIALOG_NAME_CONFIRM_LOAD_ACCOUNT, nil, {
				titleParams = { },
				mainTextParams = { ZO_HIGHLIGHT_TEXT:Colorize(zoneName) },
			})
end

function WorldMap:OnKeyboardResetButtonClick(control)
  
    local zoneId, completionZoneId = addon.Utility.GetZoneIdsAndIndexes(GetCurrentMapZoneIndex())
    if completionZoneId == 0 then
        return
    end
    
    local zoneName = GetZoneNameById(completionZoneId)
    ZO_Dialogs_ShowDialog(CBZ_DIALOG_NAME_CONFIRM_ZONE_RESET, nil, {
				titleParams = { },
				mainTextParams = { ZO_HIGHLIGHT_TEXT:Colorize(zoneName) },
			})
end


---------------------------------------
--
--          Private Methods
-- 
---------------------------------------

function getPinDetails(pin)
    if not pin then
        addon.Utility.Debug("No pin data", debug)
        return
    end
    if not pin.GetPOIZoneIndex then
        addon.Utility.Debug("Pin has no GetPOIZoneIndex() function", debug)
        return
    end
    local poiZoneIndex = pin:GetPOIZoneIndex()
    if poiZoneIndex == -1 then
        addon.Utility.Debug("Pin POI zone index is -1", debug)
        return
    end
    local poiIndex = pin:GetPOIIndex()
    if poiIndex == -1 then
        addon.Utility.Debug("Pin POI index is -1", debug)
        return
    end
    
    local poiZoneId, completionZoneId, _, completionZoneIndex = addon.Utility.GetZoneIdsAndIndexes(poiZoneIndex)
    if completionZoneIndex == 0 then
        return
    end
    
    local objective, completionType = addon.ZoneGuideTracker:GetPOIObjective(completionZoneIndex, nil, poiZoneIndex, poiIndex)
    return objective, completionType, completionZoneId
end
function getCompleteText(pin)
    local objective, completionType = getPinDetails(pin)
    if not objective then
        return
    end
    local stringTemplate = GetString("SI_ZONECOMPLETIONTYPE_SHORTDESCRIPTION", completionType)
    return zo_strformat(stringTemplate, objective.name)
end
function getResetText(pin)
    local objective, completionType = getPinDetails(pin)
    if not objective then
        return
    end
    return zo_strformat(SI_GUILD_FINDER_GUILD_INFO_ATTRIBUTE_FORMATTER, GetString(SI_OPTIONS_RESET), objective.name)
end
function markPinComplete(pin)
    local objective, completionType, completionZoneId = getPinDetails(pin)
    if not objective then
        return
    end
    
    addon.Data:SetActivityComplete(completionZoneId, completionType, objective.activityIndex, true)
    addon.ZoneGuideTracker:UpdateUIAndAnnounce(objective)
end
function markPinIncomplete(pin)
    local objective, completionType, completionZoneId = getPinDetails(pin)
    if not objective then
        return
    end
    
    addon.Data:SetActivityComplete(completionZoneId, completionType, objective.activityIndex, nil)
    addon.ZoneGuideTracker:UpdateUI(objective)
end
function shouldPinShowCompletionMenu(pin)
    local objective = getPinDetails(pin)
    if objective == nil then
        addon.Utility.Debug("Pin matched no objective", debug)
    end
    return objective ~= nil
end



-- Create singleton
addon.WorldMap = WorldMap:New()