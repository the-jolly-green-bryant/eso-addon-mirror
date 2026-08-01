local L = sidWarTools.Localization
local RegisterForEvent = sidWarTools.RegisterForEvent
local WrapFunction = sidWarTools.WrapFunction

local function InitializeCampaignBrowserOverview()
    local cb = CAMPAIGN_BROWSER
    local CAMPAIGN_RULESET_TYPE_ALL = 0
    local ALL_CAMPAIGNS_RULESET_ID = 0
    local CAMPAIGN_DATA = 1

    ZO_CreateStringId(("SI_CAMPAIGNRULESETTYPE%d"):format(CAMPAIGN_RULESET_TYPE_ALL), L["ALL_CAMPAIGNS_LABEL"])

    local CAMPAIGN_RULESET_TYPE_ALL_KEYBOARD_ICONS = {
        up = "EsoUI/Art/LFG/LFG_indexIcon_allianceWar_up.dds",
        down = "EsoUI/Art/LFG/LFG_indexIcon_allianceWar_down.dds",
        over = "EsoUI/Art/LFG/LFG_indexIcon_allianceWar_over.dds",
    }
    local CAMPAIGN_RULESET_TYPE_ALL_GAMEPAD_ICON = "EsoUI/Art/LFG/Gamepad/LFG_activityIcon_cyrodiil.dds"

    WrapFunction("ZO_CampaignBrowser_GetKeyboardIconsForRulesetType", function(originalZO_CampaignBrowser_GetKeyboardIconsForRulesetType, rulesetType)
        if(rulesetType == CAMPAIGN_RULESET_TYPE_ALL) then
            return CAMPAIGN_RULESET_TYPE_ALL_KEYBOARD_ICONS
        end
        return originalZO_CampaignBrowser_GetKeyboardIconsForRulesetType(rulesetType)
    end)

    WrapFunction("ZO_CampaignBrowser_GetGamepadIconForRulesetType", function(originalZO_CampaignBrowser_GetGamepadIconForRulesetType, rulesetType)
        if(rulesetType == CAMPAIGN_RULESET_TYPE_ALL) then
            return CAMPAIGN_RULESET_TYPE_ALL_GAMEPAD_ICON
        end
        return originalZO_CampaignBrowser_GetGamepadIconForRulesetType(rulesetType)
    end)

    WrapFunction(ZO_CampaignBrowser_Manager, "GetActiveCampaignRulesetsByType", function(originalGetActiveCampaignRulesetsByType, self)
        local campaignRulesetsByType = originalGetActiveCampaignRulesetsByType(self)
        if(not campaignRulesetsByType[CAMPAIGN_RULESET_TYPE_ALL]) then
            campaignRulesetsByType[CAMPAIGN_RULESET_TYPE_ALL] = {ALL_CAMPAIGNS_RULESET_ID}
        end
        return campaignRulesetsByType
    end)

    WrapFunction(cb, "FilterScrollList", function(originalFilterScrollList, self)
        if(self.rulesetIdFilter == ALL_CAMPAIGNS_RULESET_ID) then
            ZO_ClearNumericallyIndexedTable(self.filteredList)
            for _, campaignData in ipairs(self.masterList) do
                table.insert(self.filteredList, ZO_ScrollList_CreateDataEntry(ZO_CAMPAIGN_DATA_TYPE_CAMPAIGN, campaignData))
            end
        else
            originalFilterScrollList(self)
        end
    end)

    WrapFunction("GetCampaignRulesetName", function(originalFunction, rulesetId)
        return rulesetId == ALL_CAMPAIGNS_RULESET_ID and L["ALL_CAMPAIGNS_LABEL"] or originalFunction(rulesetId)
    end)

    WrapFunction("GetCampaignRulesetDescription", function(originalFunction, rulesetId)
        return rulesetId == ALL_CAMPAIGNS_RULESET_ID and L["ALL_CAMPAIGNS_RULES"] or originalFunction(rulesetId)
    end)

    -- refresh data on first open in order to get our new entry to be selected
    SCENE_MANAGER:CallWhen(CAMPAIGN_BROWSER_SCENE:GetName(), SCENE_SHOWING, function()
        cb:RefreshData()
    end)

    WrapFunction(cb, "Row_OnMouseEnter", function(originalFunction, self, control)
        originalFunction(self, control)
        if(self.mouseOverRow and self.rulesetIdFilter == ALL_CAMPAIGNS_RULESET_ID) then
            local data = ZO_ScrollList_GetData(self.mouseOverRow)
            if(data and data.type == CAMPAIGN_DATA) then
                local id = data.rulesetId
                local text = zo_strformat("<<X:1>>\n<<X:2>>", GetCampaignRulesetName(id), GetCampaignRulesetDescription(id))
                self.rules:SetText(text)
            end
        end
    end)

    WrapFunction(cb, "Row_OnMouseExit", function(originalFunction, self, control)
        originalFunction(self, control)
        if(self.rulesetIdFilter == ALL_CAMPAIGNS_RULESET_ID) then
            self.rules:SetText(GetCampaignRulesetDescription(ALL_CAMPAIGNS_RULESET_ID))
        end
    end)

    function cb:SelectAssignedCampainRulesetNode()
        if self.tree then
            local START_AT_ROOT = nil
            self.tree:ExecuteOnSubTree(START_AT_ROOT, function(node)
                if node:GetTemplate() == "ZO_RulesetEntry" then
                    local nodeData = node:GetData()
                    if nodeData.rulesetId == ALL_CAMPAIGNS_RULESET_ID then
                        self.tree:SelectNode(node)
                        return true
                    end
                end
            end)
        end
    end
end

local function Initialize(saveData)
    if(saveData.campaignBrowserOverview) then
        InitializeCampaignBrowserOverview()
    end
end

sidWarTools.InitializeCampaignBrowser = Initialize
