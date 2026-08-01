local selectedGreen, selectedBlue, selectedRed
local smartPresetChoices = {Green = {}, Blue = {}, Red = {}} -- displayed name
local smartPresetValues = {Green = {}, Blue = {}, Red = {}} -- ID

local function RefreshSmartPresets(tree)
    ZO_ClearTable(smartPresetChoices[tree])
    ZO_ClearTable(smartPresetValues[tree])

    table.insert(smartPresetChoices[tree], "-- None --")
    table.insert(smartPresetValues[tree], "NONE")

    for id, preset in pairs(DynamicCP.SMART_PRESETS[tree]) do
        table.insert(smartPresetChoices[tree], preset.name())
        table.insert(smartPresetValues[tree], id)
    end
end

function DynamicCP:CreateSettingsMenu()
    local LAM = LibAddonMenu2
    local panelData = {
        type = "panel",
        name = "Dynamic CP Lite",
        displayName = "|c3bdb5eDynamic CP Lite|r",
        author = "Kyzeragon",
        version = DynamicCP.version,
        registerForRefresh = true,
        registerForDefaults = true,
    }

    local optionsData = {
---------------------------------------------------------------------
-- constellation
        {
            type = "submenu",
            name = "Constellation Settings",
            controls = {
                {
                    type = "header",
                    name = "Labels",
                    width = "half",
                },
                {
                    type = "checkbox",
                    name = "Show labels on stars",
                    tooltip = "Show the names of champion point stars above the stars",
                    default = true,
                    getFunc = function() return DynamicCP.savedOptions.showLabels end,
                    setFunc = function(value)
                        DynamicCP.savedOptions.showLabels = value
                        DynamicCP.RefreshLabels(value)
                    end,
                    width = "full",
                },
                {
                    type = "colorpicker",
                    name = "Passive star labels color",
                    tooltip = "Color of the labels for unslottable stars",
                    default = ZO_ColorDef:New(1, 1, 0.5),
                    getFunc = function() return unpack(DynamicCP.savedOptions.passiveLabelColor) end,
                    setFunc = function(r, g, b)
                        DynamicCP.savedOptions.passiveLabelColor = {r, g, b}
                        DynamicCP.RefreshLabels(DynamicCP.savedOptions.showLabels)
                    end,
                    width = "half",
                    disabled = function() return not DynamicCP.savedOptions.showLabels end
                },
                {
                    type = "slider",
                    name = "Passive star labels size",
                    tooltip = "Font size of the labels for unslottable stars",
                    getFunc = function() return DynamicCP.savedOptions.passiveLabelSize end,
                    default = 24,
                    min = 8,
                    max = 54,
                    step = 1,
                    setFunc = function(value)
                        DynamicCP.savedOptions.passiveLabelSize = value
                        DynamicCP.RefreshLabels(DynamicCP.savedOptions.showLabels)
                    end,
                    width = "half",
                    disabled = function() return not DynamicCP.savedOptions.showLabels end
                },
                {
                    type = "colorpicker",
                    name = "Slottable star labels color",
                    tooltip = "Color of the labels for slottable stars",
                    default = ZO_ColorDef:New(1, 1, 1),
                    getFunc = function() return unpack(DynamicCP.savedOptions.slottableLabelColor) end,
                    setFunc = function(r, g, b)
                        DynamicCP.savedOptions.slottableLabelColor = {r, g, b}
                        DynamicCP.RefreshLabels(DynamicCP.savedOptions.showLabels)
                    end,
                    width = "half",
                    disabled = function() return not DynamicCP.savedOptions.showLabels end
                },
                {
                    type = "slider",
                    name = "Slottable star labels size",
                    tooltip = "Font size of the labels for slottable stars",
                    getFunc = function() return DynamicCP.savedOptions.slottableLabelSize end,
                    default = 18,
                    min = 8,
                    max = 54,
                    step = 1,
                    setFunc = function(value)
                        DynamicCP.savedOptions.slottableLabelSize = value
                        DynamicCP.RefreshLabels(DynamicCP.savedOptions.showLabels)
                    end,
                    width = "half",
                    disabled = function() return not DynamicCP.savedOptions.showLabels end
                },
                {
                    type = "colorpicker",
                    name = "Cluster labels color",
                    tooltip = "Color of the labels for star clusters",
                    default = ZO_ColorDef:New(1, 0.7, 1),
                    getFunc = function() return unpack(DynamicCP.savedOptions.clusterLabelColor) end,
                    setFunc = function(r, g, b)
                        DynamicCP.savedOptions.clusterLabelColor = {r, g, b}
                        DynamicCP.RefreshLabels(DynamicCP.savedOptions.showLabels)
                    end,
                    width = "half",
                    disabled = function() return not DynamicCP.savedOptions.showLabels end
                },
                {
                    type = "slider",
                    name = "Cluster labels size",
                    tooltip = "Font size of the labels for star clusters",
                    getFunc = function() return DynamicCP.savedOptions.clusterLabelSize end,
                    default = 13,
                    min = 8,
                    max = 54,
                    step = 1,
                    setFunc = function(value)
                        DynamicCP.savedOptions.clusterLabelSize = value
                        DynamicCP.RefreshLabels(DynamicCP.savedOptions.showLabels)
                    end,
                    width = "half",
                    disabled = function() return not DynamicCP.savedOptions.showLabels end
                },
                {
                    type = "header",
                    name = "Other",
                    width = "half",
                },
                {
                    type = "checkbox",
                    name = "Double click to slot or unslot stars",
                    tooltip = "Double click the slottable stars to add or remove them to the hotbar, or double click the hotbar stars to unslot them",
                    default = true,
                    getFunc = function() return DynamicCP.savedOptions.doubleClick end,
                    setFunc = function(value)
                        DynamicCP.savedOptions.doubleClick = value
                    end,
                    width = "full",
                    requiresReload = true,
                },
                {
                    type = "checkbox",
                    name = "Show total points",
                    tooltip = "Show your total champion points and for each tree on the top left of the CP screen",
                    default = true,
                    getFunc = function() return DynamicCP.savedOptions.showTotalsLabel end,
                    setFunc = function(value)
                        DynamicCP.savedOptions.showTotalsLabel = value
                        DynamicCPInfoLabel:SetHidden(not value)
                    end,
                    width = "full",
                },
            },
        },
---------------------------------------------------------------------
-- quickstars
        {
            type = "submenu",
            name = "Quickstar Panel Settings",
            controls = {
                {
                    type = "checkbox",
                    name = "Show panel on HUD",
                    tooltip = "Show a panel on your HUD that displays currently slotted stars and also allows changing the stars",
                    default = true,
                    getFunc = function() return DynamicCP.savedOptions.quickstarsShowOnHud end,
                    setFunc = function(value)
                        DynamicCP.savedOptions.quickstarsShowOnHud = value
                        DynamicCP.InitQuickstarsScenes()
                    end,
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = "Show panel on HUD UI",
                    tooltip = "Also show the panel on the HUD UI scene, which means when your cursor is active, e.g. when typing in chatbox",
                    default = true,
                    getFunc = function() return DynamicCP.savedOptions.quickstarsShowOnHudUi end,
                    setFunc = function(value)
                        DynamicCP.savedOptions.quickstarsShowOnHudUi = value
                        DynamicCP.InitQuickstarsScenes()
                    end,
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = "Show panel on CP screen",
                    tooltip = "Also show the panel on the CP screen",
                    default = false,
                    getFunc = function() return DynamicCP.savedOptions.quickstarsShowOnCpScreen end,
                    setFunc = function(value)
                        DynamicCP.savedOptions.quickstarsShowOnCpScreen = value
                        DynamicCP.InitQuickstarsScenes()
                    end,
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = "Lock panel",
                    tooltip = "Lock the panel so it can't be moved",
                    default = false,
                    getFunc = function() return DynamicCP.savedOptions.lockQuickstars end,
                    setFunc = function(value)
                        DynamicCP.savedOptions.lockQuickstars = value
                        DynamicCPQuickstars:SetMovable(not value)
                        DynamicCPQuickstars:SetMouseEnabled(not value)
                        DynamicCPQuickstarsBackdrop:SetHidden(value)
                        if (not value) then
                            DynamicCP.ShowQuickstars()
                        end
                    end,
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = "Use vertical buttons",
                    tooltip = "Set to ON for vertical buttons, OFF for horizontal",
                    default = true,
                    getFunc = function() return DynamicCP.savedOptions.quickstarsVertical end,
                    setFunc = function(value)
                        DynamicCP.savedOptions.quickstarsVertical = value
                        DynamicCP.ShowQuickstars()
                        DynamicCP.ResizeQuickstars()
                    end,
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = "Use mirrored menu side",
                    tooltip = "For vertical buttons: Set to ON to open to the left, OFF to open to the right\nFor horizontal buttons: Set to ON to open above, OFF to open below",
                    default = false,
                    getFunc = function() return DynamicCP.savedOptions.quickstarsMirrored end,
                    setFunc = function(value)
                        DynamicCP.savedOptions.quickstarsMirrored = value
                        DynamicCP.ShowQuickstars()
                        DynamicCP.ResizeQuickstars()
                    end,
                    width = "full",
                },
                {
                    type = "slider",
                    name = "Panel scale %",
                    tooltip = "Scale of the panel to display. Some spacing may look weird especially at more extreme values",
                    default = 100,
                    min = 50,
                    max = 150,
                    step = 5,
                    getFunc = function() return DynamicCP.savedOptions.quickstarsScale * 100 end,
                    setFunc = function(value)
                        DynamicCP.savedOptions.quickstarsScale = value / 100
                        DynamicCP.ShowQuickstars()
                        DynamicCPQuickstars:SetScale(value / 100)
                    end,
                    width = "full",
                },
                {
                    type = "slider",
                    name = "Panel width",
                    tooltip = "Width of the panel. Note that some star names may get cut off depending on the length",
                    default = 200,
                    min = 100,
                    max = 400,
                    step = 5,
                    getFunc = function() return DynamicCP.savedOptions.quickstarsWidth end,
                    setFunc = function(value)
                        DynamicCP.savedOptions.quickstarsWidth = value
                        DynamicCP.ShowQuickstars()
                        DynamicCP.ResizeQuickstars()
                    end,
                    width = "full",
                },
                {
                    type = "slider",
                    name = "Panel opacity %",
                    tooltip = "Opacity of the panel background",
                    default = 50,
                    min = 0,
                    max = 100,
                    step = 5,
                    getFunc = function() return DynamicCP.savedOptions.quickstarsAlpha * 100 end,
                    setFunc = function(value)
                        DynamicCP.savedOptions.quickstarsAlpha = value / 100
                        DynamicCP.ShowQuickstars()

                        DynamicCPQuickstarsGreenButtonBackdrop:SetAlpha(value / 100)
                        DynamicCPQuickstarsBlueButtonBackdrop:SetAlpha(value / 100)
                        DynamicCPQuickstarsRedButtonBackdrop:SetAlpha(value / 100)
                        DynamicCPQuickstarsPanelListsGreenBackdrop:SetAlpha(value / 100)
                        DynamicCPQuickstarsPanelListsBlueBackdrop:SetAlpha(value / 100)
                        DynamicCPQuickstarsPanelListsRedBackdrop:SetAlpha(value / 100)
                        DynamicCPQuickstarsPanelCancelBackdrop:SetAlpha(value / 100)
                        DynamicCPQuickstarsPanelConfirmBackdrop:SetAlpha(value / 100)
                    end,
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = "Hide slotted stars from dropdown",
                    tooltip = "Set to ON if you don't want the dropdowns to show stars that are already slotted in the current or other slots",
                    default = false,
                    getFunc = function() return DynamicCP.savedOptions.quickstarsDropdownHideSlotted end,
                    setFunc = function(value)
                        DynamicCP.savedOptions.quickstarsDropdownHideSlotted = value
                        DynamicCP.UpdateAllDropdowns()
                    end,
                    width = "full",
                },
            },
        },
---------------------------------------------------------------------
-- other
        {
            type = "submenu",
            name = "Other Settings",
            controls = {
                {
                    type = "checkbox",
                    name = "Prompt unsaved changes",
                    tooltip = "Show a warning and option to commit changes if you leave the CP screen without saving changes",
                    default = true,
                    getFunc = function() return DynamicCP.savedOptions.showLeaveWarning end,
                    setFunc = function(value)
                        DynamicCP.savedOptions.showLeaveWarning = value
                    end,
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = "Show cooldown warning",
                    tooltip = "Show a warning if you are unable to commit changes due to ZOS's 30-second cooldown on changing slottables",
                    default = true,
                    getFunc = function() return DynamicCP.savedOptions.showCooldownWarning end,
                    setFunc = function(value)
                        DynamicCP.savedOptions.showCooldownWarning = value
                    end,
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = "Show points on slottables pulldown",
                    tooltip = "Show the number of committed points in the pulldown beneath the slottables hotbar",
                    default = false,
                    getFunc = function() return DynamicCP.savedOptions.showPulldownPoints end,
                    setFunc = function(value)
                        DynamicCP.savedOptions.showPulldownPoints = value
                        DynamicCP.OnSlotsChanged()
                    end,
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = "Show CP gained in chat",
                    tooltip = "Show a chatbox message when you gain champion points",
                    default = true,
                    getFunc = function() return DynamicCP.savedOptions.showPointGainedMessage end,
                    setFunc = function(value)
                        DynamicCP.savedOptions.showPointGainedMessage = value
                    end,
                    width = "full",
                },
            },
        },
---------------------------------------------------------------------
-- preset application
        {
            type = "submenu",
            name = "Automatic Presets",
            controls = {
                {
                    type = "description",
                    text = "Automatic presets will use as many points as you have available, until stars useful for your detected build are all allocated. The icons (e.g. tank, healer, dps, fatecarver, etc.) reflect the \"build\" that will be prioritized. The current presets are:\n\n|c7f9c4f- Auto Combat: prioritizes stars useful in dungeons or trials\n- Auto Craft/Loot: prioritizes crafting and overland looting\n- Auto Thieving: prioritizes nefarious activities\n|c5096b3- Auto PvE: allocates based on your selected LFG role, and if you are a DPS, also allocates based on your max resource and whether you are a heavy attack build (Sergeant's Mail), have Fatecarver or jabs or Blighted Blastbones unlocked (for AoE) or not (single target)\n|cb56238- Auto PvE: allocates based on your selected LFG role, and if you are a DPS, also allocates based on whether you have Pragmatic Fatecarver unlocked (Bastion) or not (Rejuvenation)|r\n\nThe green tree presets above also try to skip Inspiration Boost if your crafting skills are maxed, unless you don't have enough points to reach stars without Inspiration Boost.",
                    width = "full",
                },
                {
                    type = "dropdown",
                    name = "|c7f9c4fCraft|r",
                    tooltip = "Select a preset to preview the CP changes",
                    choices = {},
                    choicesValues = {},
                    getFunc = function()
                        RefreshSmartPresets("Green")
                        DCP_SmartGreenDropdown:UpdateChoices(smartPresetChoices.Green, smartPresetValues.Green)
                        return selectedGreen
                    end,
                    setFunc = function(value)
                        selectedGreen = value

                        DynamicCP.RefreshSmartPresetsApplicationFromSettings(selectedGreen, selectedBlue, selectedRed)
                    end,
                    width = "full",
                    reference = "DCP_SmartGreenDropdown",
                },
                {
                    type = "dropdown",
                    name = "|c5096b3Warfare|r",
                    tooltip = "Select a preset to preview the CP changes",
                    choices = {},
                    choicesValues = {},
                    getFunc = function()
                        RefreshSmartPresets("Blue")
                        DCP_SmartBlueDropdown:UpdateChoices(smartPresetChoices.Blue, smartPresetValues.Blue)
                        return selectedBlue
                    end,
                    setFunc = function(value)
                        selectedBlue = value

                        DynamicCP.RefreshSmartPresetsApplicationFromSettings(selectedGreen, selectedBlue, selectedRed)
                    end,
                    width = "full",
                    reference = "DCP_SmartBlueDropdown",
                },
                {
                    type = "dropdown",
                    name = "|cb56238Fitness|r",
                    tooltip = "Select a preset to preview the CP changes",
                    choices = {},
                    choicesValues = {},
                    getFunc = function()
                        RefreshSmartPresets("Red")
                        DCP_SmartRedDropdown:UpdateChoices(smartPresetChoices.Red, smartPresetValues.Red)
                        return selectedRed
                    end,
                    setFunc = function(value)
                        selectedRed = value

                        DynamicCP.RefreshSmartPresetsApplicationFromSettings(selectedGreen, selectedBlue, selectedRed)
                    end,
                    width = "full",
                    reference = "DCP_SmartRedDropdown",
                },
                {
                    type = "button",
                    name = function()
                        if (DynamicCP.NeedsRespec()) then
                            return "Confirm (" .. tostring(GetChampionRespecCost()) .. " |t18:18:esoui/art/currency/currency_gold.dds|t)"
                        else
                            return "Confirm"
                        end
                    end,
                    tooltip = "Confirm applying the points below",
                    func = function()
                        DynamicCP.ConfirmSmartPresetsFromSettings()
                        selectedGreen = nil
                        selectedBlue = nil
                        selectedRed = nil
                    end,
                    width = "full",
                    disabled = function()
                        return (not selectedGreen or selectedGreen == "NONE") and (not selectedBlue or selectedBlue == "NONE") and (not selectedRed or selectedRed == "NONE")
                    end,
                    isDangerous = true,
                    warning = function()
                        if ((not selectedGreen or selectedGreen == "NONE") and (not selectedBlue or selectedBlue == "NONE") and (not selectedRed or selectedRed == "NONE")) then
                            return "Apply these champion points?"
                        elseif (DynamicCP.NeedsRespec()) then
                            return "Apply these champion points? (Cost: " .. tostring(GetChampionRespecCost()) .. " |t18:18:esoui/art/currency/currency_gold.dds|t)"
                        else
                            return "Apply these champion points? (Free)"
                        end
                    end,
                },
                {
                    type = "description",
                    text = function()
                        local result = ""

                        if (selectedGreen and selectedGreen ~= "NONE") then
                            local cp = DynamicCP.SMART_PRESETS.Green[selectedGreen].applyFunc()
                            local diffText, numChanges, col1, col2, slottablesText = DynamicCP.PointsStringBuilder.GenerateDiff(DynamicCP.GetCommittedCP(), cp)
                            result = result .. "|ca5d752Craft|r " .. diffText .. "\n" .. table.concat(slottablesText, "\n") .. "\n\n"
                        end

                        if (selectedBlue and selectedBlue ~= "NONE") then
                            local cp = DynamicCP.SMART_PRESETS.Blue[selectedBlue].applyFunc()
                            local diffText, numChanges, col1, col2, slottablesText = DynamicCP.PointsStringBuilder.GenerateDiff(DynamicCP.GetCommittedCP(), cp)
                            result = result .. "|c59bae7Warfare|r " .. diffText .. "\n" .. table.concat(slottablesText, "\n") .. "\n\n"
                        end

                        if (selectedRed and selectedRed ~= "NONE") then
                            local cp = DynamicCP.SMART_PRESETS.Red[selectedRed].applyFunc()
                            local diffText, numChanges, col1, col2, slottablesText = DynamicCP.PointsStringBuilder.GenerateDiff(DynamicCP.GetCommittedCP(), cp)
                            result = result .. "|ce46b2eFitness|r " .. diffText .. "\n" .. table.concat(slottablesText, "\n") .. "\n\n"
                        end

                        return result
                    end,
                },
            },
        },
    }

    DynamicCP.addonPanel = LAM:RegisterAddonPanel("DynamicCPOptions", panelData)
    LAM:RegisterOptionControls("DynamicCPOptions", optionsData)
end

function DynamicCP.OpenSettingsMenu()
    LibAddonMenu2:OpenToPanel(DynamicCP.addonPanel)
end
