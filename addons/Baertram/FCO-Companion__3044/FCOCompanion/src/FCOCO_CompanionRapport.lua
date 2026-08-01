FCOCO = FCOCO or  {}
local FCOCompanion = FCOCO
if not FCOCompanion.isCompanionUnlocked then return end
------------------------------------------------------------------------------------------------------------------------

--[[
function ZO_CompanionOverview_Keyboard:RefreshCompanionRapport()
    if HasActiveCompanion() and COMPANION_OVERVIEW_KEYBOARD_FRAGMENT:IsShowing() then
        --Grab the rapport value, level, and description for the active companion
        local rapportValue = GetActiveCompanionRapport()
        local rapportLevel = GetActiveCompanionRapportLevel()
        local rapportDescription = GetActiveCompanionRapportLevelDescription(rapportLevel)

        self.rapportBar:SetValue(rapportValue)
        self.rapportStatusLabel:SetText(GetString("SI_COMPANIONRAPPORTLEVEL", rapportLevel))
        self.rapportDescriptionLabel:SetText(rapportDescription)
    end
end

COMPANION_OVERVIEW_KEYBOARD.rapportBar.value)
]]

local function createRapportValueLable(selfRapportOverviewKeyboard)
    local rapportBar = selfRapportOverviewKeyboard.rapportBar
    local rapportValueLabel
    if not rapportBar.valueLabel then
        local rapportBarControl = rapportBar.control
        local gamePadMode = IsInGamepadPreferredMode()
        rapportValueLabel = WINDOW_MANAGER:CreateControl(rapportBarControl:GetName() .. "ValueLabel", rapportBarControl, CT_LABEL)
        rapportValueLabel:SetFont(gamePadMode and "ZoFontGamepadBold27" or "ZoFontBookPaper") -- "ZoFontWinH3SoftShadowThin")
        rapportValueLabel:SetColor(0, 0, 0, 1)
        rapportValueLabel:SetScale(gamePadMode and 0.7 or 0.9)
        rapportValueLabel:SetWrapMode(TEX_MODE_CLAMP)
        rapportValueLabel:SetText("")
        rapportValueLabel:ClearAnchors()
        rapportValueLabel:SetDimensions(rapportBarControl:GetWidth() - 4, rapportBarControl:GetHeight() - 4)
        rapportValueLabel:SetAnchor(CENTER, rapportBarControl, CENTER, 0, -2)
        rapportValueLabel:SetHidden(true)
        rapportValueLabel:SetMouseEnabled(false)
        rapportValueLabel:SetDrawLevel(5)
        rapportValueLabel:SetDrawTier(DT_HIGH)
        rapportValueLabel:SetDrawLayer(DL_OVERLAY)
        rapportValueLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    end
    return rapportValueLabel
end

SecurePostHook(COMPANION_OVERVIEW_KEYBOARD, "RefreshCompanionRapport", function(selfRapportOverviewKeyboard)
    if HasActiveCompanion() and COMPANION_OVERVIEW_KEYBOARD_FRAGMENT:IsShowing() then
        local rapportValue = GetActiveCompanionRapport()
        local rapportBar = selfRapportOverviewKeyboard.rapportBar
        if not rapportBar.valueLabel then
            rapportBar.valueLabel = createRapportValueLable(selfRapportOverviewKeyboard)
        end
        rapportBar.valueLabel:SetText(tostring(rapportValue) .. "|cFFF0F0/|r" ..tostring(GetMaximumRapport()))
        rapportBar.valueLabel:SetHidden(false)
    end
end)

--[[
How to do this with gamepad mode?
Overwrite the total function ZO_Tooltip:LayoutCompanionOverview(companionData) and add a new section or add something to the
tooltips rapportBar control?
https://github.com/esoui/esoui/blob/8af014ab2db2fa23b14a7a268d58b9bcdd3b3818/esoui/ingame/tooltip/companiontooltips.lua#L5
Or is one able to get the controls of the rapport bar later on again?

SecurePostHook(ZO_COMPANION_GAMEPAD , "RefreshList", function(selfoCmpanionGamepad)
--GAMEPAD_TOOLTIPS.tooltips.GAMEPAD_QUAD_2_3_TOOLTIP
    --GAMEPAD_TOOLTIPS:AcquireSection(GAMEPAD_TOOLTIPS:GetStyle("companionRapportBarSection"))
end)
]]