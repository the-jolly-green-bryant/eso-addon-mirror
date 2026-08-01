local COMPANION_NAME_COLOR = ZO_ColorDef:New(GetInterfaceColor(INTERFACE_COLOR_TYPE_UNIT_REACTION_COLOR, UNIT_REACTION_COLOR_COMPANION))
local RAPPORT_INCREASE_BACKGROUND_COLOR = ZO_ColorDef:New("102d0b")
local RAPPORT_DECREASE_BACKGROUND_COLOR = ZO_ColorDef:New("3f0a0a")

function ZO_LootHistory_Shared:AddCompanionRapportEntry(companionId, isIncrease, currentRapport, previousRapport, adjustmentAmountType)
    local rapportFormatter = isIncrease and SI_LOOT_HISTORY_COMPANION_RAPPORT_GAIN_FORMATTER or SI_LOOT_HISTORY_COMPANION_RAPPORT_LOSS_FORMATTER
    local colorizedCompanionName = COMPANION_NAME_COLOR:Colorize(GetCompanionName(companionId))
    local change = currentRapport - previousRapport
    local iconFormatter = isIncrease and LOOT_RAPPORT_INCREASE_ICON_FORMATTER or LOOT_RAPPORT_DECREASE_ICON_FORMATTER
    local lootData =
    {
        text = zo_strformat(rapportFormatter, colorizedCompanionName),
        icon = string.format(iconFormatter, adjustmentAmountType),
        color = ZO_SELECTED_TEXT,
        backgroundColor = isIncrease and RAPPORT_INCREASE_BACKGROUND_COLOR or RAPPORT_DECREASE_BACKGROUND_COLOR,
        companionId = companionId,
        companionName = colorizedCompanionName,
        entryType = LOOT_ENTRY_TYPE_COMPANION_RAPPORT,
        showIconOverlayText = true,
        iconOverlayText = zo_strformat('<<F:1>>', change)
    }
    local lootEntry = self:CreateLootEntry(lootData)
    lootEntry.isPersistent = true
    self:InsertOrQueue(lootEntry)
end

function ZO_LootHistory_Shared:OnCompanionRapportUpdate(companionId, previousRapport, currentRapport, adjustmentAmountType)
    if currentRapport ~= previousRapport then
        self:AddCompanionRapportEntry(companionId, currentRapport > previousRapport, currentRapport, previousRapport, adjustmentAmountType)
    end
end

function ZO_CompanionOverview_Keyboard:RefreshCompanionRapport()
    if HasActiveCompanion() and COMPANION_OVERVIEW_KEYBOARD_FRAGMENT:IsShowing() then
        --Grab the rapport value, level, and description for the active companion
        local rapportValue = GetActiveCompanionRapport()
        local rapportLevel = GetActiveCompanionRapportLevel()
        local rapportDescription = GetActiveCompanionRapportLevelDescription(rapportLevel)

        self.rapportBar:SetValue(rapportValue)
        self.rapportStatusLabel:SetText(GetString("SI_COMPANIONRAPPORTLEVEL", rapportLevel) .. zo_strformat(' (<<F:1>>)', rapportValue))
        self.rapportDescriptionLabel:SetText(rapportDescription)
    end
end
