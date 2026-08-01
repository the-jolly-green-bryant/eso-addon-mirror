CSV = CSV or {}
local CSV = CSV

----------------------
--INITIATE VARIABLES--
----------------------
CSV.name = "CyrodiilScoreViewer"
CSV.version = "0.5.0"
CSV.variableVersion = 1
CSV.defaultSettings = {
    offsetX = 100,
    offsetY = 100,
}
local EM = EVENT_MANAGER
local WM = WINDOW_MANAGER
local allianceIcons = {
    [ALLIANCE_ALDMERI_DOMINION] = "EsoUI/Art/Campaign/Gamepad/gp_overview_allianceIcon_aldmeri.dds",
    [ALLIANCE_DAGGERFALL_COVENANT] = "EsoUI/Art/Campaign/Gamepad/gp_overview_allianceIcon_daggerfall.dds",
    [ALLIANCE_EBONHEART_PACT] = "EsoUI/Art/Campaign/Gamepad/gp_overview_allianceIcon_ebonheart.dds",
}
local populationIcons = {
    [CAMPAIGN_POP_LOW] = "EsoUI/Art/Campaign/campaignBrowser_lowPop.dds",
    [CAMPAIGN_POP_MEDIUM] = "EsoUI/Art/Campaign/campaignBrowser_medPop.dds",
    [CAMPAIGN_POP_HIGH] = "EsoUI/Art/Campaign/campaignBrowser_hiPop.dds",
    [CAMPAIGN_POP_FULL] = "EsoUI/Art/Campaign/campaignBrowser_fullPop.dds",
}

--------------------
--PUBLIC FUNCTIONS--
--------------------
-- Save user's position
function CSV.SaveWindowPosition()
    CSV.savedVariables.offsetX = CSVWindow:GetLeft()
    CSV.savedVariables.offsetY = CSVWindow:GetTop()
end

-- Create window which does not contain data
function CSV.CreateWindow()
    for i, campaign in ipairs(CSV.campaigns) do
        CSV.controls[i] = {}
        CSV.controls[i][0] = {}

        -- Backdrop for campaign frame
        CSV.controls[i][0]["campaignBackdrop"] = WM:CreateControl(string.format("$(parent)%i0CampaignBackdrop", i), CSVWindow, CT_BACKDROP)
        CSV.controls[i][0]["campaignBackdrop"]:SetCenterColor(0, 0, 0, 1)
        CSV.controls[i][0]["campaignBackdrop"]:SetEdgeColor(0, 0, 0, 0)
        CSV.controls[i][0]["campaignBackdrop"]:SetDimensions(460, 130)
        CSV.controls[i][0]["campaignBackdrop"]:SetAnchor(TOPLEFT, CSVWindow, TOPLEFT, 10, 140 * (i-1) + 30 * 1.5)

        -- Campaign name
        CSV.controls[i][0]["name"] = WM:CreateControl(string.format("$(parent)%i0Name", i), CSVWindow, CT_LABEL)
        CSV.controls[i][0]["name"]:SetFont("ZoFontHeaderNoShadow")
        CSV.controls[i][0]["name"]:SetHeight(30)
        CSV.controls[i][0]["name"]:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
        CSV.controls[i][0]["name"]:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        CSV.controls[i][0]["name"]:SetAnchor(TOP, CSV.controls[i][0]["campaignBackdrop"], TOP, 0, 0)

        -- Home icon
        CSV.controls[i][0]["home"] = WM:CreateControl(string.format("$(parent)%i0HomeCampaign", i), CSVWindow, CT_TEXTURE)
        CSV.controls[i][0]["home"]:SetDimensions(30, 30)
        CSV.controls[i][0]["home"]:SetDrawLayer(DL_OVERLAY)
        CSV.controls[i][0]["home"]:SetTexture("EsoUI/Art/Campaign/campaignBrowser_homeCampaign.dds")
        CSV.controls[i][0]["home"]:SetAnchor(TOPLEFT, CSV.controls[i][0]["campaignBackdrop"], TOPLEFT, 20, 0)
        CSV.controls[i][0]["home"]:SetHidden(true)

        -- Label for end of campaign
        CSV.controls[i][0]["end"] = WM:CreateControl(string.format("$(parent)%i0End", i), CSVWindow, CT_LABEL)
        CSV.controls[i][0]["end"]:SetFont("ZoFontGameSmall")
        CSV.controls[i][0]["end"]:SetHeight(30)
        CSV.controls[i][0]["end"]:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
        CSV.controls[i][0]["end"]:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        CSV.controls[i][0]["end"]:SetAnchor(TOPRIGHT, CSV.controls[i][0]["campaignBackdrop"], TOPRIGHT, -10, 0)
        CSV.controls[i][0]["end"]:SetMouseEnabled(true)

        -- Timer icon
        CSV.controls[i][0]["timer"] = WM:CreateControl(string.format("$(parent)%i0Timer", i), CSVWindow, CT_TEXTURE)
        CSV.controls[i][0]["timer"]:SetDimensions(24, 24)
        CSV.controls[i][0]["timer"]:SetDrawLayer(DL_OVERLAY)
        CSV.controls[i][0]["timer"]:SetTexture("EsoUI/Art/Miscellaneous/timer_64.dds")
        CSV.controls[i][0]["timer"]:SetAnchor(RIGHT, CSV.controls[i][0]["end"], LEFT, -5, 0)
        CSV.controls[i][0]["timer"]:SetHandler("OnMouseEnter", function(self)
            ZO_Tooltips_ShowTextTooltip(self, BOTTOM, GetString(SI_GAMEPAD_CAMPAIGN_SCORING_DURATION_REMAINING))
        end)
        CSV.controls[i][0]["timer"]:SetHandler("OnMouseExit", function(self)
            ZO_Tooltips_HideTextTooltip()
        end)
        CSV.controls[i][0]["timer"]:SetMouseEnabled(true)

        -- Reward icon
        CSV.controls[i][0]["tier"] = {}
        for j = 1, 3 do
            CSV.controls[i][0]["tier"][j] = WM:CreateControl(string.format("$(parent)%i0Crown%i", i, j), CSVWindow, CT_TEXTURE)
            CSV.controls[i][0]["tier"][j]:SetTexture("EsoUI/Art/CharacterWindow/equipmentBonusIcon_full.dds")
            CSV.controls[i][0]["tier"][j]:SetDrawLayer(DL_OVERLAY)
            CSV.controls[i][0]["tier"][j]:SetDimensions(16, 16)
            CSV.controls[i][0]["tier"][j]:SetAnchor(LEFT, CSV.controls[i][0]["home"], RIGHT, 16 * (j-1), 0)
            CSV.controls[i][0]["tier"][j]:SetHandler("OnMouseEnter", function(self)
                ZO_Tooltips_ShowTextTooltip(self, BOTTOM, GetString(SI_CAMPAIGN_SCORING_END_OF_CAMPAIGN_REWARD_TIER))
            end)
            CSV.controls[i][0]["tier"][j]:SetHandler("OnMouseExit", function(self)
                ZO_Tooltips_HideTextTooltip()
            end)
            CSV.controls[i][0]["tier"][j]:SetMouseEnabled(true)
            CSV.controls[i][0]["tier"][j]:SetHidden(true)
        end

        -- Scores
        for j = 1, 3 do
            CSV.controls[i][j] = {}

            -- Scorebar
            CSV.controls[i][j]["scorebar"] = WM:CreateControl(string.format("$(parent)%i%iScorebar", i, j), CSVWindow, CT_STATUSBAR)
            CSV.controls[i][j]["scorebar"]:SetDimensions(440, 30)
            CSV.controls[i][j]["scorebar"]:SetAnchor(TOPLEFT, CSV.controls[i][0]["campaignBackdrop"], TOPLEFT, 10, 30 * j)

            -- Alliance icon
            CSV.controls[i][j]["allianceicon"] = WM:CreateControl(string.format("$(parent)%i%iAllianceicon", i, j), CSVWindow, CT_TEXTURE)
            CSV.controls[i][j]["allianceicon"]:SetDrawLayer(DL_OVERLAY)
            CSV.controls[i][j]["allianceicon"]:SetDimensions(24, 24)
            CSV.controls[i][j]["allianceicon"]:SetAnchor(TOP, CSV.controls[i][0]["home"], BOTTOM, 0, 30 * (j - 1) + (30 - 24) / 2)

            -- Score label
            CSV.controls[i][j]["scorelabel"] = WM:CreateControl(string.format("$(parent)%i%iScorelabel", i, j), CSVWindow, CT_LABEL)
            CSV.controls[i][j]["scorelabel"]:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
            CSV.controls[i][j]["scorelabel"]:SetVerticalAlignment(TEXT_ALIGN_CENTER)
            CSV.controls[i][j]["scorelabel"]:SetFont("ZoFontGame")
            CSV.controls[i][j]["scorelabel"]:SetDimensions(40, 30)
            CSV.controls[i][j]["scorelabel"]:SetAnchor(LEFT, CSV.controls[i][j]["allianceicon"], RIGHT, 10, 0)

            CSV.controls[i][j]["population"] = WM:CreateControl(string.format("$(parent)%i%iPopulation", i, j), CSVWindow, CT_TEXTURE)
            -- Population icon
            CSV.controls[i][j]["population"]:SetDimensions(24, 24)
            CSV.controls[i][j]["population"]:SetDrawLayer(DL_OVERLAY)
            CSV.controls[i][j]["population"]:SetAnchor(LEFT, CSV.controls[i][j]["scorelabel"], RIGHT, 10, 0)
            CSV.controls[i][j]["population"]:SetHidden(true)

            -- Underpop icon
            CSV.controls[i][j]["underpop"] = WM:CreateControl(string.format("$(parent)%i%iUnderpop", i, j), CSVWindow, CT_TEXTURE)
            CSV.controls[i][j]["underpop"]:SetTexture("EsoUI/Art/AvA/overview_icon_underdog_population.dds")
            CSV.controls[i][j]["underpop"]:SetDrawLayer(DL_OVERLAY)
            CSV.controls[i][j]["underpop"]:SetDimensions(24, 24)
            CSV.controls[i][j]["underpop"]:SetAnchor(LEFT, CSV.controls[i][j]["population"], RIGHT, 10, 0)
            CSV.controls[i][j]["underpop"]:SetHandler("OnMouseEnter", function(self)
                ZO_Tooltips_ShowTextTooltip(self, BOTTOM, GetString(SI_CAMPAIGN_SCORING_UNDERPOP_TOOLTIP_TITLE))
            end)
            CSV.controls[i][j]["underpop"]:SetHandler("OnMouseExit", function(self)
                ZO_Tooltips_HideTextTooltip()
            end)
            CSV.controls[i][j]["underpop"]:SetMouseEnabled(true)
            CSV.controls[i][j]["underpop"]:SetHidden(true)

            -- Underdog icon
            CSV.controls[i][j]["underdog"] = WM:CreateControl(string.format("$(parent)%i%iUnderdog", i, j), CSVWindow, CT_TEXTURE)
            CSV.controls[i][j]["underdog"]:SetTexture("EsoUI/Art/AvA/overview_icon_underdog_score.dds")
            CSV.controls[i][j]["underdog"]:SetDrawLayer(DL_OVERLAY)
            CSV.controls[i][j]["underdog"]:SetDimensions(24, 24)
            CSV.controls[i][j]["underdog"]:SetAnchor(LEFT, CSV.controls[i][j]["underpop"], RIGHT, 10, 0)
            CSV.controls[i][j]["underdog"]:SetHandler("OnMouseEnter", function(self)
                ZO_Tooltips_ShowTextTooltip(self, BOTTOM, GetString(SI_CAMPAIGN_SCORING_UNDERDOG_TOOLTIP_TITLE))
            end)
            CSV.controls[i][j]["underdog"]:SetHandler("OnMouseExit", function(self)
                ZO_Tooltips_HideTextTooltip()
            end)
            CSV.controls[i][j]["underdog"]:SetMouseEnabled(true)
            CSV.controls[i][j]["underdog"]:SetHidden(true)
        end
    end
end

-- Update window with fetched data
function CSV.UpdateWindow()
    -- Create window if needed
    if (#CSV.controls == 0) then
        CSV.CreateWindow()
    end

    CSVWindow:SetDimensions(480, 140 * #CSV.campaigns + 30 * 1.5)

    for i, campaign in ipairs(CSV.campaigns) do
        -- Set campaign name
        CSV.controls[i][0]["name"]:SetText(campaign.name)
        CSV.controls[i][0]["name"]:SetMouseEnabled(true)
        CSV.controls[i][0]["name"]:SetHandler("OnMouseEnter", function(self)
            ZO_Tooltips_ShowTextTooltip(self, BOTTOM, campaign.rulesetName)
        end)
        CSV.controls[i][0]["name"]:SetHandler("OnMouseExit", function(self)
            ZO_Tooltips_HideTextTooltip()
        end)

        -- Set end of campaign
        local _, secondsUntilCampaignEnd = GetSelectionCampaignTimes(campaign.selectionIndex)
        local formattedTimeString = FormatTimeSeconds(secondsUntilCampaignEnd, TIME_FORMAT_STYLE_SHOW_LARGEST_UNIT)
        CSV.controls[i][0]["end"]:SetText(formattedTimeString)
        CSV.controls[i][0]["end"]:SetHandler("OnMouseEnter", function(self)
            local _, secondsUntilCampaignEnd = GetSelectionCampaignTimes(campaign.selectionIndex)
            local formattedTimeString = FormatTimeSeconds(secondsUntilCampaignEnd, TIME_FORMAT_STYLE_DESCRIPTIVE_SHORT_SHOW_ZERO_SECS)
            ZO_Tooltips_ShowTextTooltip(self, BOTTOM, formattedTimeString)
        end)
        CSV.controls[i][0]["end"]:SetHandler("OnMouseExit", function(self)
            ZO_Tooltips_HideTextTooltip()
        end)

        -- Set visible home icon and reward icon
        if (campaign.id == GetAssignedCampaignId()) then
            CSV.controls[i][0]["home"]:SetHidden(false)
            for k = 1, 3 do
                CSV.controls[i][0]["tier"][k]:SetHidden(false)
                if (campaign.earnedTier >= k) then
                    CSV.controls[i][0]["tier"][k]:SetColor(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_BATTLEGROUND_WINNER))
                else
                    CSV.controls[i][0]["tier"][k]:SetColor(1, 1, 1, 0.15)
                end
            end
        end

        -- Set scorebar
        local max = math.max(campaign.allianceData[1].score, campaign.allianceData[2].score, campaign.allianceData[3].score)
        for j = 1, 3 do
            local r, g, b = GetInterfaceColor(INTERFACE_COLOR_TYPE_ALLIANCE, campaign.allianceData[j].alliance)
            CSV.controls[i][j]["allianceicon"]:SetTexture(allianceIcons[campaign.allianceData[j].alliance])
            CSV.controls[i][j]["population"]:SetTexture(populationIcons[campaign.allianceData[j].population])
            CSV.controls[i][j]["population"]:SetHidden(false)
            CSV.controls[i][j]["scorebar"]:SetMinMax(0, max)
            CSV.controls[i][j]["scorebar"]:SetValue(campaign.allianceData[j].score)
            CSV.controls[i][j]["scorebar"]:SetColor(r, g, b, 0.80)
            CSV.controls[i][j]["scorelabel"]:SetText(campaign.allianceData[j].score)
            if (campaign.id == GetAssignedCampaignId()) then
                CSV.controls[i][j]["underpop"]:SetHidden(false)
                CSV.controls[i][j]["underdog"]:SetHidden(false)
            end
            if campaign.allianceData[j].underpop then
                CSV.controls[i][j]["underpop"]:SetColor(1, 1, 1, 1)
            else
                CSV.controls[i][j]["underpop"]:SetColor(1, 1, 1, 0.15)
            end
            if campaign.allianceData[j].underdog then
                CSV.controls[i][j]["underdog"]:SetColor(1, 1, 1, 1)
            else
                CSV.controls[i][j]["underdog"]:SetColor(1, 1, 1, 0.15)
            end
        end
    end
end

-- Update campaign data
function CSV.GetCampaignData()
    CSV.campaigns = {}
    for selectionIndex, campaignData in pairs(CAMPAIGN_BROWSER_MANAGER.selectionCampaignList) do
        local id = campaignData.id
        local name = campaignData.name
        local selectionIndex = campaignData.selectionIndex
        local rulesetId = campaignData.rulesetId
        local rulesetType = campaignData.rulesetType
        local rulesetName = GetCampaignRulesetName(rulesetId)
        local earnedTier = GetPlayerCampaignRewardTierInfo(id)
        local underdog = GetCampaignUnderdogLeaderAlliance(id)
        local queueWaitSeconds = GetSelectionCampaignQueueWaitTime(selectionIndex)
        if rulesetType == CAMPAIGN_RULESET_TYPE_CYRODIIL then
            local campaign = {
                id = id,
                name = name,
                type = ZO_CAMPAIGN_DATA_TYPE_CAMPAIGN,
                selectionIndex = selectionIndex,
                rulesetId = rulesetId,
                rulesetType = rulesetType,
                rulesetName = rulesetName,
                queueWaitSeconds = queueWaitSeconds,
                earnedTier = earnedTier,
                allianceData = {
                    {
                        alliance = ALLIANCE_ALDMERI_DOMINION,
                        underdog = underdog == ALLIANCE_ALDMERI_DOMINION,
                        underpop = IsUnderpopBonusEnabled(id, ALLIANCE_ALDMERI_DOMINION),
                        score = GetSelectionCampaignAllianceScore(selectionIndex, ALLIANCE_ALDMERI_DOMINION),
                        potential = GetCampaignAlliancePotentialScore(id, ALLIANCE_ALDMERI_DOMINION),
                        population = campaignData.alliancePopulation1,
                    },
                    {
                        alliance = ALLIANCE_EBONHEART_PACT,
                        underdog = underdog == ALLIANCE_EBONHEART_PACT,
                        underpop = IsUnderpopBonusEnabled(id, ALLIANCE_EBONHEART_PACT),
                        score = GetSelectionCampaignAllianceScore(selectionIndex, ALLIANCE_EBONHEART_PACT),
                        potential = GetCampaignAlliancePotentialScore(id, ALLIANCE_EBONHEART_PACT),
                        population = campaignData.alliancePopulation2,
                    },
                    {
                        alliance = ALLIANCE_DAGGERFALL_COVENANT,
                        underdog = underdog == ALLIANCE_DAGGERFALL_COVENANT,
                        underpop = IsUnderpopBonusEnabled(id, ALLIANCE_DAGGERFALL_COVENANT),
                        score = GetSelectionCampaignAllianceScore(selectionIndex, ALLIANCE_DAGGERFALL_COVENANT),
                        potential = GetCampaignAlliancePotentialScore(id, ALLIANCE_DAGGERFALL_COVENANT),
                        population = campaignData.alliancePopulation3,
                    },
                },
            }
            -- Sort by score
            table.sort(campaign.allianceData, function(a, b) return a.score > b.score end)
            table.insert(CSV.campaigns, campaign)
        end
    end

end

--------------------
--INITIALIZE ADDON--
--------------------
function CSV:Initialize()
    CSV.savedVariables = ZO_SavedVars:NewAccountWide("CSVSavedVars", CSV.variableVersion, nil, CSV.defaultSettings)

    -- Initialize controls
    CSVWindow:ClearAnchors()
    CSVWindow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, CSV.savedVariables.offsetX, CSV.savedVariables.offsetY)
    CSV.controls = {}
    CSV.controls[0] = {}
    CSV.controls[0][0] = {}
    CSV.controls[0][0]["backdropCenter"] = WM:CreateControlFromVirtual("$(parent)00BackdropCenter", CSVWindow, "ZO_DefaultBackdrop")
    CSV.controls[0][0]["backdropCenter"]:SetAnchor(TOPLEFT, CSVWindow, TOPLEFT, 0, 0)

    -- Get data
    QueryCampaignSelectionData()
    CSV.GetCampaignData()
    CSV.UpdateWindow()

    -- Update data
    EM:RegisterForEvent(CSV.name, EVENT_CAMPAIGN_SELECTION_DATA_CHANGED,
        function()
            CSV.GetCampaignData()
            CSV.UpdateWindow()
        end
    )

    -- Keybind
    ZO_CreateStringId("SI_BINDING_NAME_CSV_TOGGLE", "Toggle Window")

    -- Slash commands
    SLASH_COMMANDS["/csv"] = function() CSVWindow:ToggleHidden() end
    SLASH_COMMANDS["/csvupdate"] = function() QueryCampaignSelectionData() end

    EM:UnregisterForEvent(CSV.name, EVENT_ADD_ON_LOADED)
end

function CSV.OnAddOnLoaded(event, addonName)
    if (addonName == CSV.name) then
        CSV:Initialize()
    end
end

EM:RegisterForEvent(CSV.name, EVENT_ADD_ON_LOADED, CSV.OnAddOnLoaded)