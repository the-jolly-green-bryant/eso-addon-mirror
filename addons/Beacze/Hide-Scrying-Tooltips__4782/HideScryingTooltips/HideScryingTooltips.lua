local addonName = "HideScryingTooltips"
local defaults = {
    hideScryable = true,
    hideZone = true,
    hideGamepadScryable = true,
    hideGamepadZone = true,
}

local function InitSettings()
    -- Initialize Saved Variables
    local sv = ZO_SavedVars:NewAccountWide("HideScryingTooltipsSV", 1, nil, defaults)

    -- Define the Settings Panel layout
    local panelData = {
        type = "panel",
        name = addonName,
        displayName = "Hide Scrying Tooltips",
        author = "Beacze",
        version = "1.0.0",
        registerForRefresh = true,
    }
    
    local optionsData = {
        {
            type = "header",
            name = "Hiding Preferences (Keyboard)",
        },
        {
            type = "checkbox",
            name = "Hide in 'Scryable' Tab",
            tooltip = "Hide comparative tooltips when viewing leads in the Scryable list.",
            getFunc = function() return sv.hideScryable end,
            setFunc = function(value) sv.hideScryable = value end,
        },
        {
            type = "checkbox",
            name = "Hide in Zone Tabs",
            tooltip = "Hide comparative tooltips when viewing leads in the Current Zone list or browsing Codex histories.",
            getFunc = function() return sv.hideZone end,
            setFunc = function(value) sv.hideZone = value end,
        },
        {
            type = "header",
            name = "Hiding Preferences (Gamepad)",
        },
        {
            type = "checkbox",
            name = "Hide in 'Scryable' Tab",
            tooltip = "Hide comparative tooltips when highlighting items inside the Scryable list menu in Gamepad UI.",
            getFunc = function() return sv.hideGamepadScryable end,
            setFunc = function(value) sv.hideGamepadScryable = value end,
        },
        {
            type = "checkbox",
            name = "Hide in Zone Tabs",
            tooltip = "Hide comparative tooltips when browsing standard Zone or Codex submenus in Gamepad UI.",
            getFunc = function() return sv.hideGamepadZone end,
            setFunc = function(value) sv.hideGamepadZone = value end,
        },
    }

    local LAM = LibAddonMenu2
    if LAM then
        LAM:RegisterAddonPanel(addonName, panelData)
        LAM:RegisterOptionControls(addonName, optionsData)
    end

    -- ====================================================
    -- KEYBOARD HOOKS (HIDING CONTROL)
    -- ====================================================
    SecurePostHook(ZO_AntiquityTileBase_Keyboard, "ShowTooltip", function(self)
        if not (ItemTooltip and ItemTooltip.HideComparativeTooltips) then return end
        
        local control = self.control
        if not control then return end

        local parent = control:GetParent()
        local parentName = parent and parent.GetName and parent:GetName() or ""
        local controlName = control.GetName and control:GetName() or ""
        
        local fullPathString = string.lower(controlName .. "_" .. parentName)
        local isScryableTab = string.find(fullPathString, "scryable") ~= nil

        if isScryableTab then
            if sv.hideScryable then ItemTooltip:HideComparativeTooltips() end
        else
            if sv.hideZone then ItemTooltip:HideComparativeTooltips() end
        end
    end)

    -- ====================================================
    -- GAMEPAD HOOKS
    -- ====================================================
    if ZO_Antiquity_Gamepad then
        SecurePostHook(ZO_Antiquity_Gamepad, "ShowTooltip", function(self)
            if not (GAMEPAD_TOOLTIPS and GAMEPAD_TOOLTIPS.ClearTooltip) then return end
            
            local isGamepadScryable = false
            if self.owner and self.owner.GetCurrentCategoryData then
                local catData = self.owner:GetCurrentCategoryData()
                if catData and (catData.filterType == ANTIQUITY_FILTER_SCRYABLE or catData.isScryable) then
                    isGamepadScryable = true
                end
            end

            if isGamepadScryable then
                if sv.hideGamepadScryable then
                    GAMEPAD_TOOLTIPS:ClearTooltip(GAMEPAD_LEFT_TOOLTIP)
                end
            else
                if sv.hideGamepadZone then
                    GAMEPAD_TOOLTIPS:ClearTooltip(GAMEPAD_LEFT_TOOLTIP)
                end
            end
        end)
    end
end

-- Wait for addon to load before initializing settings
EVENT_MANAGER:RegisterForEvent(addonName, EVENT_ADD_ON_LOADED, function(event, name)
    if name == addonName then
        InitSettings()
        EVENT_MANAGER:UnregisterForEvent(addonName, EVENT_ADD_ON_LOADED)
    end
end)
