--------------------------------------------------
-- ShibUI Action Bar Module
--------------------------------------------------
local SUI = SUI
local sv

SUI.ActionBar = SUI.ActionBar or {}
local ActionBar = SUI.ActionBar

local Log = function(...) SUI.Debug:Log("Action Bar", ...) end

-- Apply the bar template
ApplyTemplateToControl(ZO_ActionBar1, "SUI_ActionBar1")

function ActionBar:ApplyWeaponSwapVisibility()
    ZO_ActionBar1WeaponSwap:SetAlpha(sv.showWeaponSwap and 1 or 0)
end

function ActionBar:ToggleWeaponSwap()
    sv.showWeaponSwap = not sv.showWeaponSwap
    self:ApplyWeaponSwapVisibility()
    Log("Weapon Swap Icon: " .. (sv.showWeaponSwap and "ON" or "OFF"), 0)
end

function ActionBar:ApplyKeybindingsVisibility()
    -- Use a small delay to ensure UI elements are created
    zo_callLater(function()
        -- hide/show each action button's text
        for i = 1, 8 do
            local buttonText = _G["ActionButton"..i.."ButtonText"]
            if buttonText and buttonText.SetHidden then
                buttonText:SetHidden(not sv.showKeybindings)
            end
        end

        -- quickslot text
        local quickslotText = _G["QuickslotButtonButtonText"]
        if quickslotText and quickslotText.SetHidden then
            quickslotText:SetHidden(not sv.showKeybindings)
        end

        -- ultimate button text
        local ultimateText = _G["CompanionUltimateButtonButtonText"]
        if ultimateText and ultimateText.SetHidden then
            ultimateText:SetHidden(not sv.showKeybindings)
        end
    end, 100)
end

function ActionBar:ToggleKeybindings()
    sv.showKeybindings = not sv.showKeybindings
    self:ApplyKeybindingsVisibility()
    Log("Action Bar Keybindings: " .. (sv.showKeybindings and "ON" or "OFF"), 0)
end

function ActionBar:ApplyUltimateButtonScaling()
    zo_callLater(function()
        local actionButton8 = _G["ActionButton8"]
        local companionUltimateButton = _G["CompanionUltimateButton"]
        
        if actionButton8 then
            if sv.scaledUltimateButton then
                ApplyTemplateToControl(actionButton8, "SUI_UltimateActionButton_Keyboard_Template")
                if actionButton8.flipCard then
                    actionButton8.flipCard:SetDimensions(57, 57)
                end
            else
                ApplyTemplateToControl(actionButton8, "SUI_ActionButton_Keyboard_Template")
                if actionButton8.flipCard then
                    actionButton8.flipCard:SetDimensions(47, 47) -- Default size
                end
            end
        end
        
        if companionUltimateButton then
            if sv.scaledUltimateButton then
                ApplyTemplateToControl(companionUltimateButton, "SUI_UltimateActionButton_Keyboard_Template")
                if companionUltimateButton.flipCard then
                    companionUltimateButton.flipCard:SetDimensions(57, 57)
                end
            else
                ApplyTemplateToControl(companionUltimateButton, "SUI_ActionButton_Keyboard_Template")
                if companionUltimateButton.flipCard then
                    companionUltimateButton.flipCard:SetDimensions(47, 47) -- Default size
                end
            end
        end
    end, 100)
end

function ActionBar:ToggleUltimateButtonScaling()
    sv.scaledUltimateButton = not sv.scaledUltimateButton
    self:ApplyUltimateButtonScaling()
    Log("Scaled Ultimate Buttons: " .. (sv.scaledUltimateButton and "ON" or "OFF"), 0)
end

-- Hook all buttons
SecurePostHook(ActionButton, "ApplyStyle", function(self)
    if self.slot == _G["ActionButton8"] or self.slot == _G["CompanionUltimateButton"] then
        if sv.scaledUltimateButton then
            ApplyTemplateToControl(self.slot, "SUI_UltimateActionButton_Keyboard_Template")
            -- Ensure FlipCard maintains correct size
            zo_callLater(function()
                if self.flipCard then
                    self.flipCard:SetDimensions(57, 57)
                end
            end, 50)
        else
            ApplyTemplateToControl(self.slot, "SUI_ActionButton_Keyboard_Template")
            -- Apply default size
            zo_callLater(function()
                if self.flipCard then
                    self.flipCard:SetDimensions(47, 47)
                end
            end, 50)
        end
    else
        ApplyTemplateToControl(self.slot, "SUI_ActionButton_Keyboard_Template")
    end
end)

-- Hook the backbar timer
SecurePostHook(ZO_ActionBarTimer, "ApplyStyle", function(self)
    ApplyTemplateToControl(self.slot, "SUI_ActionBarTimer_BackBarSlot_Keyboard_Template")
end)

-- Hook the buff/debuff icons
SecurePostHook("CreateControlFromVirtual", function(name, parent, template, suffix)
    if template == "ZO_BuffDebuffIcon" then
        local control = GetControl(name, suffix)
        if control then
            ApplyTemplateToControl(control, "SUI_BuffDebuffIcon")
        end
    end
end)

--------------------------------------------------
-- Handle Ultimate Button After Swap
-- Override animation style method to maintain custom sizing
--------------------------------------------------
local originalApplySwapAnimationStyle = ActionButton.ApplySwapAnimationStyle
function ActionButton:ApplySwapAnimationStyle()
    originalApplySwapAnimationStyle(self)
    
    if self.slot == _G["ActionButton8"] then
        local size = sv.scaledUltimateButton and 57 or 47
        self.flipCard:SetDimensions(size, size)
        local timeline = self.hotbarSwapAnimation
        if timeline then
            local firstAnimation = timeline:GetFirstAnimation()
            local lastAnimation = timeline:GetLastAnimation()
            firstAnimation:SetStartAndEndWidth(size, size)
            firstAnimation:SetStartAndEndHeight(size, 0)
            lastAnimation:SetStartAndEndWidth(size, size)
            lastAnimation:SetStartAndEndHeight(0, size)
        end
    end
end

function ActionBar:Initialize()
    sv = SUI.SavedVars.saved
    self:ApplyWeaponSwapVisibility()
    self:ApplyKeybindingsVisibility()
    self:ApplyUltimateButtonScaling()
    
    -- Also apply settings when player is activated (UI fully loaded)
    EVENT_MANAGER:RegisterForEvent("SUI_ActionBar_PlayerActivated", EVENT_PLAYER_ACTIVATED, function()
        self:ApplyKeybindingsVisibility()
        self:ApplyUltimateButtonScaling()
        EVENT_MANAGER:UnregisterForEvent("SUI_ActionBar_PlayerActivated", EVENT_PLAYER_ACTIVATED)
    end)
    
    Log("Initialized")
end