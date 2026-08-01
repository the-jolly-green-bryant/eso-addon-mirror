FTS = {}
local FTS = FTS

FTS.name = "FastTravelSpendings"
FTS.version = "1.1.0"

FTS.defaults = {
    goldSpent = 0,
    tier1 = 250,
    tier2 = 500,
    tier3 = 750,
    useText = true,
    threshold = 1000,
}

local travelCost = 0
local goldBeforeTravel = 0
local hasStartedWayshrineTravel = false

-- Color definitions (feel free to override with your own!)
FTS.Green = ZO_ColorDef:New(0.0, 0.5, 0.0)
FTS.Orange = ZO_ColorDef:New(1.0, 0.5, 0.0)
FTS.Red = ZO_ColorDef:New(1.0, 0.0, 0.0)

-- Lerps between green over orange to red based on the set tiers
local function GetCostColor(cost)
    local a
    if cost > FTS.SV.tier3 then
        return FTS.Red
    elseif cost > FTS.SV.tier2 then
        a = zo_saturate((cost - FTS.SV.tier2) / (FTS.SV.tier3 - FTS.SV.tier2))
        return FTS.Orange:Lerp(FTS.Red, a)
    elseif cost > FTS.SV.tier1 then
        a = zo_saturate((cost - FTS.SV.tier1) / (FTS.SV.tier2 - FTS.SV.tier1))
        return FTS.Green:Lerp(FTS.Orange, a)
    else
        return FTS.Green
    end
end

-- Overrides the recalling dialog text to include our gold wasted tally
ESO_Dialogs["RECALL_CONFIRM"].mainText.text = function(dialog)
    local cooldown = GetRecallCooldown()
    local destination = dialog.data.nodeIndex
    local cost = GetRecallCost(destination)
    local currency = GetRecallCurrency(destination)
    local canAffordRecall = cost <= GetCurrencyAmount(currency, CURRENCY_LOCATION_CHARACTER)

    local spentGoldText = zo_strformat(FTS_GOLD_SPENT_TOTAL, ZO_CurrencyControl_FormatCurrencyAndAppendIcon(FTS.SV.goldSpent, false, CURT_MONEY))
    
    if cooldown == 0 or cost == 0 then
        if canAffordRecall then
            return GetString(SI_FAST_TRAVEL_DIALOG_MAIN_TEXT) .. "\n\n" .. spentGoldText
        else
            return GetString(SI_FAST_TRAVEL_DIALOG_CANT_AFFORD) .. "\n\n" .. spentGoldText
        end
    else
        if canAffordRecall then
            return GetString(SI_FAST_TRAVEL_DIALOG_PREMIUM) .. "\n\n" .. spentGoldText
        else
            return GetString(SI_FAST_TRAVEL_DIALOG_CANT_AFFORD_PREMIUM) .. "\n\n" .. spentGoldText
        end
    end
end

-- Hook to swap a money amount for our "Way too much" text
local AddMoney_Original = InformationTooltip.AddMoney
local function AddMoney(self, tooltip, cost, text, notEnough)
    ZO_ItemTooltip_AddMoney(tooltip, cost, text, hasEnough)
    
    if text == SI_TOOLTIP_RECALL_COST then
        local moneyLine = GetControl(tooltip, "SellPrice")
        local currencyControl = GetControl(moneyLine, "Currency")
        currencyControl:SetColor(GetCostColor(cost):UnpackRGB())
        
        if FTS.SV.useText and cost >= FTS.SV.threshold then
            currencyControl:SetText(GetString(FTS_TOO_EXPENSIVE))
        end
    end
end
InformationTooltip.AddMoney = AddMoney


-- Hook to get when we initiate a recall to a wayshrine. Gets called a both recalling and at travel from WS to WS
local FastTravelToNode_Original = FastTravelToNode
function FastTravelToNode(nodeIndex, ...)    
    goldBeforeTravel = GetCurrencyAmount(CURT_MONEY, CURRENCY_LOCATION_CHARACTER)
    hasStartedWayshrineTravel = true
    FastTravelToNode_Original(nodeIndex, ...)
end


-- Every time after a loading screen, check if the player has less money than before.
-- The player also has to have used the FastTravelToNode() (= not jumped to a player)
local function OnPlayerActivated()
    if goldBeforeTravel ~= GetCurrencyAmount(CURT_MONEY, CURRENCY_LOCATION_CHARACTER) and goldBeforeTravel ~= 0 and hasStartedWayshrineTravel then
        FTS.SV.goldSpent = FTS.SV.goldSpent + travelCost
        CHAT_ROUTER:AddSystemMessage(zo_strformat(FTS_REPORT, ZO_CurrencyControl_FormatCurrencyAndAppendIcon(travelCost, false, CURT_MONEY)))
    end  
    
    travelCost = 0
    hasStartedWayshrineTravel = false
end

-- Just before the loading screen, save the cost of recalling as it gets deducted just after the loading screen is shown
local function OnPlayerDeactivated()
    travelCost = GetRecallCost()
end


-- Chat command
function FTS.Command(text)
    if text == "reset" then
        ZO_Dialogs_ShowDialog("FTS_RESET_CONFIRMATION")
        return
    end
    
    CHAT_ROUTER:AddSystemMessage(zo_strformat(FTS_GOLD_SPENT_TOTAL, ZO_CurrencyControl_FormatCurrencyAndAppendIcon(FTS.SV.goldSpent, false, CURT_MONEY)))
end

local function InitializeAddonMenu()
    local previewLabel
    local previewValue = 146

    -- Actually updates the only visual changes from below
    local function UpdateSliders()
        FTS_Tier1Slider.slider:SetMinMax(0, FTS.SV.tier2 - 1)
        FTS_Tier1Slider.maxText:SetText(FTS.SV.tier2 - 1)
        FTS_Tier1Slider.minText:SetText(0)
        
        FTS_Tier2Slider.slider:SetMinMax(FTS.SV.tier1 + 1, FTS.SV.tier3 - 1)
        FTS_Tier2Slider.maxText:SetText(FTS.SV.tier3 - 1)
        FTS_Tier2Slider.minText:SetText(FTS.SV.tier1 + 1)
        
        FTS_Tier3Slider.slider:SetMinMax(FTS.SV.tier2 + 1, 1000)
        FTS_Tier3Slider.maxText:SetText(1000)
        FTS_Tier3Slider.minText:SetText(FTS.SV.tier2 + 1)
    end
    
    -- Update functions if a slider gets moved
    local function OnUpdate_Tier1Slider(self, value)
        local _, max = FTS_Tier2Slider.slider:GetMinMax()
        FTS_Tier2Slider.slider:SetMinMax(value + 1, max)
        FTS_Tier2Slider.minText:SetText(value + 1)
    end 
    local function OnUpdate_Tier2Slider(self, value)        
        FTS_Tier1Slider.slider:SetMinMax(0, value - 1)
        FTS_Tier1Slider.maxText:SetText(value - 1)
        
        FTS_Tier3Slider.slider:SetMinMax(value + 1, 1000)
        FTS_Tier3Slider.minText:SetText(value + 1)
    end
    local function OnUpdate_Tier3Slider(self, value)
        local min = FTS_Tier2Slider.slider:GetMinMax()  
        FTS_Tier2Slider.slider:SetMinMax(min, value - 1)
        FTS_Tier2Slider.maxText:SetText(value - 1)

    end
    
    local optionsData = {}
	local panelData = {
		type = "panel",
		name = "Fast Travel Spendings",
		displayName = "Fast Travel Spendings",
		author = "MrPikPik",
		version = FTS.version,
		website = 'https://www.esoui.com/downloads/info2798-FastTravelSpendings.html#donate',
		donation = function()
			SCENE_MANAGER:Show('mailSend')
			zo_callLater(function() 
				ZO_MailSendToField:SetText("@MrPikPik")
				ZO_MailSendSubjectField:SetText("Thank you for making addons!")
				ZO_MailSendBodyField:SetText("I like using your addon 'Fast Travel Spendings'")
				ZO_MailSendBodyField:TakeFocus()
			end, 250)
		end,
		registerForRefresh = true,
		registerForDefaults = true
	}

    -- Tier 1 slider
	table.insert(optionsData, {
		type = "slider",
		name = GetString(FTS_OPTIONS_TIER_1),
		tooltip = GetString(FTS_OPTIONS_TIER_1_TT),
        min = 0,
        max = 1000,
		default = FTS.defaults.tier1,
		getFunc = function()
            return FTS.SV.tier1
        end,
		setFunc = function(newValue)
            FTS.SV.tier1 = newValue
            UpdateSliders()
        end,
        reference = "FTS_Tier1Slider"
	})
    
    -- Tier 2 slider
	table.insert(optionsData, {
		type = "slider",
		name = GetString(FTS_OPTIONS_TIER_2),
		tooltip = GetString(FTS_OPTIONS_TIER_2_TT),
        min = 0,
        max = 1000,
		default = FTS.defaults.tier2,
		getFunc = function()
            return FTS.SV.tier2
        end,
		setFunc = function(newValue)
            FTS.SV.tier2 = newValue
            UpdateSliders()
        end,
        reference = "FTS_Tier2Slider"
	})
    
    -- Tier 3 slider
	table.insert(optionsData, {
		type = "slider",
		name = GetString(FTS_OPTIONS_TIER_3),
		tooltip = GetString(FTS_OPTIONS_TIER_3_TT),
        min = 0,
        max = 1000,
		default = FTS.defaults.tier3,
		getFunc = function()
            return FTS.SV.tier3
        end,
		setFunc = function(newValue)
            FTS.SV.tier3 = newValue
            UpdateSliders()
        end,
        reference = "FTS_Tier3Slider"
	})
    
    -- Description/Explanation
	table.insert(optionsData, {
		type = "description",
		text = GetString(FTS_OPTIONS_DESCRIPTION),
	})
    
    -- Divider
    table.insert(optionsData, {
        type = "divider",
    })
    
    -- useText checkbox
    table.insert(optionsData, {
        type = "checkbox",
        name = GetString(FTS_OPTIONS_TEXT),
        tooltip = GetString(FTS_OPTIONS_TEXT_TT),
        default = FTS.defaults.useText,
        getFunc = function() return FTS.SV.useText end,
        setFunc = function(newValue) FTS.SV.useText = newValue end,
    })
    
    -- Threshold slider
	table.insert(optionsData, {
		type = "slider",
		name = GetString(FTS_OPTIONS_TIER_4),
		tooltip = GetString(FTS_OPTIONS_TIER_4_TT),
        disabled = function() return not FTS.SV.useText end,
        min = 0,
        max = 1250,
		default = FTS.defaults.threshold,
		getFunc = function()
            return FTS.SV.threshold
        end,
		setFunc = function(newValue)
            FTS.SV.threshold = newValue
        end,
	})
    
    -- Divider
    table.insert(optionsData, {
        type = "divider",
    })
    
    -- Preview
	table.insert(optionsData, {
		type = "slider",
		name = GetString(FTS_OPTIONS_PREVIEW),
        min = 0,
        max = 1250,
		default = 146,
		getFunc = function()
            return previewValue
        end,
		setFunc = function(newValue)
            previewValue = newValue
        end,
        reference = "FTS_Preview"
	})
    
    -- Divider
    table.insert(optionsData, {
        type = "divider",
    })
    
    -- Empty space, so the button is a bit "out of the way"
    table.insert(optionsData, {
        type = "description",
        text = "\r\n\r\n\r\n\r\n"
    })
      
    -- Reset button
    table.insert(optionsData, {
        type = "button",
        name = GetString(FTS_OPTIONS_RESET),
        tooltip = GetString(FTS_RESET),
        func = function() ZO_Dialogs_ShowDialog("FTS_RESET_CONFIRMATION") end,
   })
    
    local optionsPanel = LibAddonMenu2:RegisterAddonPanel(FTS.name, panelData)
	LibAddonMenu2:RegisterOptionControls(FTS.name, optionsData)
    
    -- Setting up interactivity between option controls
    local finalizeOptionsMenu = function(control)
        if control ~= optionsPanel then return end
        if not previewLabel then
            previewLabel = WINDOW_MANAGER:CreateControl(nil, FTS_Preview, CT_LABEL)
            previewLabel:SetAnchor(RIGHT, FTS_Preview.slider, LEFT, -10, 0)
            previewLabel:SetFont("ZoFontGame")
            previewLabel:SetText(ZO_CurrencyControl_FormatCurrencyAndAppendIcon(146, false, CURT_MONEY))
            previewLabel:SetColor(GetCostColor(146):UnpackRGB())
        end
        
        -- Preview slider affecting value on change
        ZO_PostHookHandler(FTS_Preview.slider, "OnValueChanged", function(self, value)
            if value > FTS.SV.threshold and FTS.SV.useText then
                previewLabel:SetText(GetString(FTS_TOO_EXPENSIVE))
            else
                previewLabel:SetText(ZO_CurrencyControl_FormatCurrencyAndAppendIcon(value, false, CURT_MONEY))
            end
            previewLabel:SetColor(GetCostColor(value):UnpackRGB())
        end)
        
        -- Nicer sliders, dynamically moving mins and maxes based on the other sliders
        ZO_PostHookHandler(FTS_Tier1Slider.slider, "OnValueChanged", OnUpdate_Tier1Slider)
        ZO_PostHookHandler(FTS_Tier2Slider.slider, "OnValueChanged", OnUpdate_Tier2Slider)
        ZO_PostHookHandler(FTS_Tier3Slider.slider, "OnValueChanged", OnUpdate_Tier3Slider)
        
        -- Initialize the min max values
        UpdateSliders()
        
        -- Finish! :D
        CALLBACK_MANAGER:UnregisterCallback("LAM-PanelControlsCreated", finalizeOptionsMenu)
    end
    CALLBACK_MANAGER:RegisterCallback("LAM-PanelControlsCreated", finalizeOptionsMenu)
end

local function OnAddonLoaded(event, addonName)
    if addonName ~= FTS.name then return end
    EVENT_MANAGER:UnregisterForEvent(FTS.name, EVENT_ADD_ON_LOADED) 
     
    -- Creating saved vars
    FTS.SV = ZO_SavedVars:NewAccountWide("FTSSavedVariables", 1.0, nil, FTS.defaults)

    -- Reset dialog
    ESO_Dialogs["FTS_RESET_CONFIRMATION"] = {
		title = { text = GetString(FTS_RESETDIALOG_TITLE) },
		mainText =  { text = GetString(FTS_RESETDIALOG_TEXT) },
		buttons = {
			[1] = {
				text = GetString(FTS_RESETDIALOG_YES),
				callback = function(dialog)
                    FTS.SV.goldSpent = 0
                    CHAT_ROUTER:AddSystemMessage(GetString(FTS_RESET))
                end
			},
			[2] = { text = GetString(FTS_RESETDIALOG_NO) },
		}
	}
    
    EVENT_MANAGER:RegisterForEvent(FTS.name, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
    EVENT_MANAGER:RegisterForEvent(FTS.name, EVENT_PLAYER_DEACTIVATED, OnPlayerDeactivated)
    
    -- Chat command
    SLASH_COMMANDS["/fasttravelspendings"] = FTS.Command
  
    -- Optional settings menu if LAM is installed
    if LibAddonMenu2 then
        InitializeAddonMenu()
    end
end
EVENT_MANAGER:RegisterForEvent(FTS.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)