HAL = {}

HAL.name = "HideActionLabels"
HAL.sversion = "1.0.1"
HAL.title = "Hide Action Labels"
HAL.hidden = false
HAL.elements = {
    "ActionButton3ButtonText",
    "ActionButton4ButtonText",
    "ActionButton5ButtonText",
    "ActionButton6ButtonText",
    "ActionButton7ButtonText",
    "AUI_QuickSlotButton1ButtonText",
    "AUI_QuickSlotButton2ButtonText",
    "AUI_QuickSlotButton3ButtonText",
    "AUI_QuickSlotButton4ButtonText",
    "AUI_QuickSlotButton5ButtonText",
    "AUI_QuickSlotButton6ButtonText",
    "AUI_QuickSlotButton7ButtonText",
    "AUI_QuickSlotButton8ButtonText"
}
HAL.special = {
    HAL_Ultimate = {
        Label = ActionButton8ButtonText,
        KeyboardAction = "ACTION_BUTTON_8",
        GamepadAction = "GAMEPAD_ACTION_BUTTON_8",
        GamepadStartIndex = 1,
        KeyBind = 0,
        Mod1 = 0,
        Mod2 = 0,
        Mod3 = 0,
        Mod4 = 0
    },
    HAL_QuickSlot = {
        Label = QuickslotButtonButtonText,
        KeyboardAction = "ACTION_BUTTON_9",
        GamepadAction = "ACTION_BUTTON_9",
        GamepadStartIndex = 2,
        KeyBind = 0,
        Mod1 = 0,
        Mod2 = 0,
        Mod3 = 0,
        Mod4 = 0
    }
}
HAL.backgrounds = {
    "ZO_ActionBar1_AUI_Keybind_bg",
    "ZO_ActionBar1KeybindBG"
}
HAL.defaults = {
    hideQuickslot = true,
    hideUltimate = true,
    hideBackground = true
}

function HAL.HideBackground()
    for _, element in ipairs(HAL.backgrounds) do
        local windowElement = WINDOW_MANAGER:GetControlByName(element, "")
        if (windowElement ~= nil) then
            windowElement:SetHidden(HAL.settings.hideBackground)
        end
    end
end

function HAL.HideLabels()
    if (HAL.hidden) then return end
    for _, element in ipairs(HAL.elements) do
        local windowElement = WINDOW_MANAGER:GetControlByName(element, "")
        if (windowElement ~= nil) then
            windowElement:SetText("")
        end
    end
    if (HAL.settings.hideQuickslot) then
        HAL.special.HAL_QuickSlot.Label:SetText("")
    end
    if (HAL.settings.hideUltimate) then
        HAL.special.HAL_Ultimate.Label:SetText("")
    end
    HAL.HideBackground()
end

function HAL.FindBestKeyBind(action, startIndex)
    local layerIndex, categoryIndex, actionIndex = GetActionIndicesFromName(action)
    for bindingIndex = startIndex or 1, 4, 1 do 
        local keyCode, mod1, mod2, mod3, mod4 = GetActionBindingInfo(layerIndex, categoryIndex, actionIndex, bindingIndex)
        if (keyCode ~= 54 and keyCode ~= 0) then
            return keyCode, mod1, mod2, mod3, mod4
        end
    end
end

function HAL.ShowLabel(special)
    local keyCode, mod1, mod2, mod3, mod4
    if (ZO_Keybindings_ShouldShowGamepadKeybind()) then
        keyCode, mod1, mod2, mod3, mod4 = HAL.FindBestKeyBind(special.GamepadAction, special.GamepadStartIndex)
    else
        keyCode, mod1, mod2, mod3, mod4 = HAL.FindBestKeyBind(special.KeyboardAction)
    end

    if (ZO_Keybindings_ShouldUseIconKeyMarkup(keyCode)) then
        special.Label:SetText(ZO_Keybindings_GenerateIconKeyMarkup(keyCode, 180, false))
    else
        special.Label:SetText(ZO_Keybindings_GetBindingStringFromKeys(keyCode, mod1, mod2, mod3, mod4, KEYBIND_TEXT_OPTIONS_FULL_NAME, KEYBIND_TEXTURE_OPTIONS_EMBED_MARKUP))
    end
end

function HAL:RegisterEvents()
    EVENT_MANAGER:RegisterForEvent("HAL_ActionBarPushed", EVENT_ACTION_LAYER_PUSHED, HAL.HideLabels)
    EVENT_MANAGER:RegisterForEvent("HAL_ActionBarPopped", EVENT_ACTION_LAYER_POPPED, HAL.HideLabels)
end

function HAL:SetupSettings()
    local LAM = LibAddonMenu2

	local panelData = {
		type = "panel",
		name = HAL.title,
		displayName = HAL.title,
		author = "CodeStripper",
		version = "1.0.0",
		registerForDefaults = true,
		website = "https://www.esoui.com/forums/member.php?u=32944"
	}
	LAM:RegisterAddonPanel(HAL.name, panelData)

	local optionsTable = {
		{
			type = "checkbox",
			name = "Hide Active Quickslot",
			tooltip = "Hides the text under your active quickslot",
			getFunc = function()
				return HAL.settings.hideQuickslot
			end,
			setFunc = function(value)
				HAL.settings.hideQuickslot = value
                if(value) then HAL.HideLabels() else HAL.ShowLabel(HAL.special.HAL_QuickSlot) end
			end,
			default = self.defaults.hideQuickslot
		},
		{
			type = "checkbox",
			name = "Hide Ultimate",
			tooltip = "Hides the text under your ultimate",
			getFunc = function()
				return HAL.settings.hideUltimate
			end,
			setFunc = function(value)
                HAL.settings.hideUltimate = value
				if(value) then HAL.HideLabels() else HAL.ShowLabel(HAL.special.HAL_Ultimate) end
			end,
			default = self.defaults.hideUltimate
		},
        {
			type = "checkbox",
			name = "Hide Background",
			tooltip = "Hides the dark bar under your hot bar",
			getFunc = function()
				return HAL.settings.hideBackground
			end,
			setFunc = function(value)
				HAL.settings.hideBackground = value
                HAL.HideBackground()
			end,
			default = self.defaults.hideBackground
		}
	}
	LAM:RegisterOptionControls(HAL.name, optionsTable)
end

function HAL.Initialize()
    HAL.settings = ZO_SavedVars:NewAccountWide("HideActionLabels_SVData", HAL.sversion, nil, HAL.defaults)
    HAL:RegisterEvents()
    HAL:SetupSettings()
end

function HAL.OnAddOnLoaded(event, addonName)
    if addonName == HAL.name then
        HAL.Initialize()
        EVENT_MANAGER:UnregisterForEvent(HAL.name, EVENT_ADD_ON_LOADED)
    end
end

EVENT_MANAGER:RegisterForEvent(HAL.name, EVENT_ADD_ON_LOADED, HAL.OnAddOnLoaded)