--	----------------------------------------------------------------------
--	CurrencyManager by CaseyOmah
--	----------------------------------------------------------------------
--
-- 	Description:	This module contains the functions required to manage
-- 					automatic handling of the Bankable ESO Currencies on
--					your characters based on Max/Step/Min.
--
--	----------------------------------------------------------------------

-- Addon Common Definitions
local ADDON_NAME 		= "CurrencyManager"
local ADDON_AUTHOR 		= "CaseyOmah"
local ADDON_WEBSITE		= "https://www.esoui.com/downloads/info3366-CurrencyManager.html"
local ADDON_VERSION		= "0.1.3"
-- Version = MajorVersion.MinorVersion.MiniFixes

local colorGold = "|cffff24"
local colorTelVarStones = "|c769ae4"
local colorAlliancePoints = "|c53ca56"
local colorWritVouchers = "|cffff90"

local characterVar = {}
local charSettings = {}

-- Default Setting is to take no action allowing the User to define Currency Transfer Rules
local STRING_NONE = GetString(CM_CHAR_VAR_NONE)
local defaultCharacterVariables = {
		accountWide 					= true,
		goldManagementType				= STRING_NONE,
		goldMax							= 5000,
		goldMin							= 5000,
		goldStep						= 1,
		telVarStonesManagementType		= STRING_NONE,
		telVarStonesMax					= 100,
		telVarStonesMin					= 100,
		telVarStonesStep				= 1,
		alliancePointsManagementType	= STRING_NONE,
		alliancePointsMax				= 5000,
		alliancePointsMin				= 5000,
		alliancePointsStep				= 1,
		writVouchersManagementType		= STRING_NONE,
		writVouchersMax					= 0,
		writVouchersMin					= 0,
		writVouchersStep				= 1,
}

-- From: http://wiki.esoui.com/Globals#CurrencyType

-- CurrencyType
-- ------------
-- CURT_ALLIANCE_POINTS
-- CURT_CHAOTIC_CREATIA
-- CURT_CROWNS
-- CURT_CROWN_GEMS
-- CURT_MONEY
-- CURT_NONE
-- CURT_STYLE_STONES
-- CURT_TELVAR_STONES
-- CURT_WRIT_VOUCHERS 


local function Transfer(chosen)

	local colorWithdraw = "|cff3333"
	local colorDeposit  = "|c00ff99"
	local Avail = GetString(CM_POST_AVAIL)
	local Bag = 0
	local Bank = 0
	local Color = ""
	local Curt = ""
	local MaxHold = 0
	local MinHold = 0
	local Money = ""
	local Step = 0
	local Type = ""
	
	if chosen == "Gold" then
		Bag = GetCurrentMoney()
		Bank = GetBankedMoney()
		Color = "|cffff24"
		Curt = CURT_MONEY
		Money = " " .. GetString(CM_GOLD)
		MaxHold = characterVar.goldMax
		MinHold = characterVar.goldMin
		Step = characterVar.goldStep
		Type = characterVar.goldManagementType
	else
		if chosen == "TelVarStones" then
			Color = "|c769ae4"
			Curt = CURT_TELVAR_STONES
			Money = " " .. GetString(CM_TEL_VAR)
			MaxHold = characterVar.telVarStonesMax
			MinHold = characterVar.telVarStonesMin
			Step = characterVar.telVarStonesStep
			Type = characterVar.telVarStonesManagementType
		elseif chosen == "AlliancePoints" then
			Color = "|c53ca56"
			Curt = CURT_ALLIANCE_POINTS
			Money = " " .. GetString(CM_AP)
			MaxHold = characterVar.alliancePointsMax
			MinHold = characterVar.alliancePointsMin
			Step = characterVar.alliancePointsStep
			Type = characterVar.alliancePointsManagementType
		elseif chosen == "WritVouchers" then
			Color = "|cffff90"
			Curt = CURT_WRIT_VOUCHERS
			Money = " " .. GetString(CM_WRIT_VOUCHER)
			MaxHold = characterVar.writVouchersMax
			MinHold = characterVar.writVouchersMin
			Step = characterVar.writVouchersStep
			Type = characterVar.writVouchersManagementType
		end
		if Curt ~= "" then
			Bag = GetCarriedCurrencyAmount(Curt)
			Bank = GetBankedCurrencyAmount(Curt)
		end
		MaxHold = tonumber(MaxHold)
		MinHold = tonumber(MinHold)
		Step = tonumber(Step)
	end

	--  Transfer type.
	--	Initialize variable for transfer amount.
	local transferAmount = 0
	
	
	--	Get transfer amount based on management type
	if Type == GetString(CM_CHAR_VAR_FIXED) then					--	Fixed management:
		if Bag < MinHold then
			transferAmount = Bag - MinHold
		elseif Bag > MaxHold then
			transferAmount = Bag - MaxHold
		else
			transferAmount = 0
		end
	elseif Type == GetString(CM_CHAR_VAR_EMPTY) then				--	Empty management:
		transferAmount = Bag
		Step = 1
	else																					--	None, no management:
		transferAmount = 0
	end

	--	Using the transfer amount value(+/-) request a deposit or a withdrawal
	if transferAmount < 0 then
		transferAmount = math.abs(transferAmount)
		if transferAmount > Bank then
			d(GetString(CM_PRE_ONLY) .. Bank .. Avail)
			transferAmount = Bank
		end
		transferAmount = math.ceil( transferAmount / Step ) * Step
		if transferAmount > 0 then
			WithdrawCurrencyFromBank(Curt, transferAmount)
			d(colorWithdraw .. GetString(CM_PRE_WITHDREW) .. ZO_Currency_FormatPlatform(Curt, transferAmount, ZO_CURRENCY_FORMAT_AMOUNT_ICON) .. Color .. Money .. colorWithdraw .. GetString(CM_FROM_YOUR_BANK))
		end
	else
		transferAmount = math.ceil( transferAmount / Step ) * Step
		if transferAmount > 0 then
			DepositCurrencyIntoBank(Curt, transferAmount)
			d(colorDeposit .. GetString(CM_PRE_DEPOSITED) .. ZO_Currency_FormatPlatform(Curt, transferAmount, ZO_CURRENCY_FORMAT_AMOUNT_ICON) .. Color .. Money .. colorDeposit .. GetString(CM_INTO_YOUR_BANK))			
		end
	end
end

local function CreateSettingsMenu()

	local LAM = LibAddonMenu2 or LibStub("LibAddonMenu-2.0")

	local panelData = {
		type = "panel",
		name = "Currency Manager",
		displayName = "|c4a9300" .. GetString(CM_ADDON_LONG_NAME) .. "|r",
		author = ADDON_AUTHOR,
		version = ADDON_VERSION,
		slashCommand = "/curman",
		registerForRefresh = true,
		registerForDefaults = true,
		website = ADDON_WEBSITE
	}
	LAM:RegisterAddonPanel("CurrencyManagerPanel", panelData)

	local optionsData = {
		
		{
            type = "description",
			text = ZO_HIGHLIGHT_TEXT:Colorize(GetString(CM_ADDON_DESCRIPTION)),
            width = "full"
        },

		-- Account Wide Settings
		-- divider
        {	type = "divider", width = "full" },
		{
			type = "checkbox",
			name = GetString(CM_ACCOUNT_WIDE_TITLE),
			tooltip = GetString(CM_ACCOUNT_WIDE_TIP),
			default = defaultCharacterVariables.accountWide,
			getFunc = 	function() 
							return charSettings.byChar.accountWide
						end,
			setFunc = 	function(value) 
							charSettings.byChar.accountWide = value 
						end,
			requiresReload = true
		},
		-- divider
        {	type = "divider", width = "full" },
        {
            type = "description",
			text = ZO_HIGHLIGHT_TEXT:Colorize(GetString(CM_MANAGEMENT_TYPE_OPTIONS)),
            width = "full"
        },
		{
            type = "description",
            text = "|c5cb700" .. GetString(CM_CHAR_VAR_NONE) .. "|r" .. GetString(CM_MAN_TYPE_NONE_DESC),
            width = "full"
        },
		{
            type = "description",
            text = "|c5cb700" .. GetString(CM_CHAR_VAR_FIXED) .. "|r" .. GetString(CM_MAN_TYPE_FIXED_DESC),
            width = "full"
        },
        {
            type = "description",
            text = "|c5cb700" .. GetString(CM_CHAR_VAR_EMPTY) .. "|r" .. GetString(CM_MAN_TYPE_EMPTY_DESC),
            width = "full"
        },
		
		-- Gold Management
		-- divider
        {	type = "divider", width = "full" },
		{
			type = "dropdown",
			name = colorGold .. GetString(CM_GOLD) .. "|r" .. GetString(CM_POST_MANAGEMENT_TYPE),
			tooltip = GetString(CM_MANAGEMENT_TYPE_TIP),
			default = defaultCharacterVariables.goldManagementType,
			choices = {GetString(CM_CHAR_VAR_NONE), GetString(CM_CHAR_VAR_FIXED), GetString(CM_CHAR_VAR_EMPTY)},
		 
			getFunc = 	function()
							return characterVar.goldManagementType
						end,
			setFunc = 	function(choice)
							characterVar.goldManagementType = choice
						end
		},
		{
			type = "editbox",
			name = GetString(CM_PRE_SEL) .. GetString(CM_MAX) .. colorGold .. GetString(CM_GOLD) .. "|r" .. GetString(CM_POST_AMOUNT_TIP),
			tooltip = GetString(CM_PRE_TIP) .. GetString(CM_MAXIMUM) .. GetString(CM_GOLD) .. GetString(CM_POST_AMOUNT_TIP),
			textType= "numeric",
			default = defaultCharacterVariables.goldMax,
			
			getFunc = 	function() 
							return characterVar.goldMax 
						end,
			setFunc = 	function(choice)
							characterVar.goldMax = tonumber(choice)
						end
		},
		{
			type = "editbox",
			name = colorGold .. GetString(CM_GOLD) .. "|r" .. GetString(CM_POST_STEP_TIP),
			tooltip = GetString(CM_PRE_TIP) .. GetString(CM_AMOUNT) .. GetString(CM_GOLD) .. GetString(CM_POST_STEP_TIP),
			textType= "numeric",
			default = defaultCharacterVariables.goldStep,
			
			getFunc = 	function() 
							return characterVar.goldStep 
						end,
			setFunc = 	function(choice)
							characterVar.goldStep = tonumber(choice)
						end
		},
		{
			type = "editbox",
			name = GetString(CM_MIN) .. colorGold .. GetString(CM_GOLD) .. "|r" .. GetString(CM_POST_AMOUNT_TIP),
			tooltip = GetString(CM_PRE_TIP) .. GetString(CM_MINIMUM) .. GetString(CM_GOLD) .. GetString(CM_POST_AMOUNT_TIP),
			textType= "numeric",
			default = defaultCharacterVariables.goldMin,
			
			getFunc = 	function() 
							return characterVar.goldMin
						end,
			setFunc = 	function(choice)
							characterVar.goldMin = tonumber(choice)
						end
		},
		
		-- Tel Var Stones Management
		-- divider
        {	type = "divider", width = "full" },
		{
			type = "dropdown",
			name = colorTelVarStones .. GetString(CM_TEL_VAR) .. "|r" .. GetString(CM_POST_MANAGEMENT_TYPE),
			tooltip = GetString(CM_MANAGEMENT_TYPE_TIP),
			default = defaultCharacterVariables.telVarStonesManagementType,
			choices = {GetString(CM_CHAR_VAR_NONE), GetString(CM_CHAR_VAR_FIXED), GetString(CM_CHAR_VAR_EMPTY)},
		 
			getFunc = 	function()
							return characterVar.telVarStonesManagementType
						end,
			setFunc = 	function(choice)
							characterVar.telVarStonesManagementType = choice
						end
		},
		{
			type = "editbox",
			name = GetString(CM_MAX) .. colorTelVarStones .. GetString(CM_TEL_VAR) .. "|r" .. GetString(CM_POST_AMOUNT_TIP),
			tooltip = GetString(CM_PRE_TIP) .. GetString(CM_MAXIMUM) .. GetString(CM_TEL_VAR) .. GetString(CM_POST_AMOUNT_TIP),
			textType= "numeric",
			default = defaultCharacterVariables.telVarStonesMax,
			
			getFunc = 	function() 
							return characterVar.telVarStonesMax 
						end,
			setFunc = 	function(choice)
							characterVar.telVarStonesMax = tonumber(choice)
						end
		},
		{
			type = "editbox",
			name = colorTelVarStones .. GetString(CM_TEL_VAR) .. "|r" .. GetString(CM_POST_STEP_TIP),
			tooltip = GetString(CM_PRE_TIP) .. GetString(CM_AMOUNT) .. GetString(CM_TEL_VAR) .. GetString(CM_POST_STEP_TIP),
			textType= "numeric",
			default = defaultCharacterVariables.telVarStonesStep,
			
			getFunc = 	function() 
							return characterVar.telVarStonesStep 
						end,
			setFunc = 	function(choice)
							characterVar.telVarStonesStep = tonumber(choice)
						end
		},
		{
			type = "editbox",
			name = GetString(CM_PRE_SEL) .. GetString(CM_MIN) .. colorTelVarStones .. GetString(CM_TEL_VAR) .. "|r" .. GetString(CM_POST_AMOUNT_TIP),
			tooltip = GetString(CM_PRE_TIP) .. GetString(CM_MINIMUM) .. GetString(CM_TEL_VAR) .. GetString(CM_POST_AMOUNT_TIP),
			textType= "numeric",
			default = defaultCharacterVariables.telVarStonesMin,
			
			getFunc = 	function() 
							return characterVar.telVarStonesMin
						end,
			setFunc = 	function(choice)
							characterVar.telVarStonesMin = tonumber(choice)
						end
		},
		{
            type = "description",
			text = GetString(CM_TELVAR_DESCRIPTION),
            width = "full"
        },
		
		-- Alliance Points Management
		-- divider
        {	type = "divider", width = "full" },
		{
			type = "dropdown",
			name = colorAlliancePoints .. GetString(CM_AP) .. "|r" .. GetString(CM_POST_MANAGEMENT_TYPE),
			tooltip = GetString(CM_MANAGEMENT_TYPE_TIP),
			default = defaultCharacterVariables.alliancePointsManagementType,
			choices = {GetString(CM_CHAR_VAR_NONE), GetString(CM_CHAR_VAR_FIXED), GetString(CM_CHAR_VAR_EMPTY)},
		 
			getFunc = 	function()
							return characterVar.alliancePointsManagementType
						end,
			setFunc = 	function(choice)
							characterVar.alliancePointsManagementType = choice
						end
		},
		{
			type = "editbox",
			name = GetString(CM_MAX) .. colorAlliancePoints .. GetString(CM_AP) .. "|r" .. GetString(CM_POST_AMOUNT_TIP),
			tooltip = GetString(CM_PRE_TIP) .. GetString(CM_MAXIMUM) .. GetString(CM_AP) .. GetString(CM_POST_AMOUNT_TIP),
			textType= "numeric",
			default = defaultCharacterVariables.alliancePointsMax,
			
			getFunc = 	function() 
							return characterVar.alliancePointsMax 
						end,
			setFunc = 	function(choice)
							characterVar.alliancePointsMax = tonumber(choice)
						end
		},
		{
			type = "editbox",
			name = colorAlliancePoints .. GetString(CM_AP) .. "|r" .. GetString(CM_POST_STEP_TIP),
			tooltip = GetString(CM_PRE_TIP) .. GetString(CM_STEP) .. GetString(CM_AP) .. GetString(CM_POST_STEP_TIP),
			textType= "numeric",
			default = defaultCharacterVariables.alliancePointsStep,
			
			getFunc = 	function() 
							return characterVar.alliancePointsStep 
						end,
			setFunc = 	function(choice)
							characterVar.alliancePointsStep = tonumber(choice)
						end
		},
		{
			type = "editbox",
			name = GetString(CM_MIN) .. colorAlliancePoints .. GetString(CM_AP) .. "|r" .. GetString(CM_POST_AMOUNT_TIP),
			tooltip = GetString(CM_PRE_TIP) .. GetString(CM_MINIMUM) .. GetString(CM_AP) .. GetString(CM_POST_AMOUNT_TIP),
			textType= "numeric",
			default = defaultCharacterVariables.alliancePointsMin,
			
			getFunc = 	function() 
							return characterVar.alliancePointsMin
						end,
			setFunc = 	function(choice)
							characterVar.alliancePointsMin = tonumber(choice)
						end
		},
		
		-- Writ Voucher Management
		-- divider
        {	type = "divider", width = "full" },
		{
			type = "dropdown",
			name = colorWritVouchers .. GetString(CM_WRIT_VOUCHER) .. "|r" .. GetString(CM_POST_MANAGEMENT_TYPE),
			tooltip = GetString(CM_MANAGEMENT_TYPE_TIP),
			default = defaultCharacterVariables.writVouchersManagementType,
			choices = {GetString(CM_CHAR_VAR_NONE), GetString(CM_CHAR_VAR_FIXED), GetString(CM_CHAR_VAR_EMPTY)},
		 
			getFunc = 	function()
							return characterVar.writVouchersManagementType
						end,
			setFunc = 	function(choice)
							characterVar.writVouchersManagementType = choice
						end
		},
		{
			type = "editbox",
			name = GetString(CM_MAX) .. colorWritVouchers .. GetString(CM_WRIT_VOUCHER) .. "|r" .. GetString(CM_POST_AMOUNT_TIP),
			tooltip = GetString(CM_PRE_TIP) .. GetString(CM_MAXIMUM) .. GetString(CM_WRIT_VOUCHER) .. GetString(CM_POST_AMOUNT_TIP),
			textType= "numeric",
			default = defaultCharacterVariables.writVouchersMax,
			
			getFunc = 	function() 
							return characterVar.writVouchersMax 
						end,
			setFunc = 	function(choice)
							characterVar.writVouchersMax = tonumber(choice)
						end
		},
		{
			type = "editbox",
			name = colorWritVouchers .. GetString(CM_WRIT_VOUCHER) .. "|r" .. GetString(CM_POST_STEP_TIP),
			tooltip = GetString(CM_PRE_TIP) .. GetString(CM_STEP) .. GetString(CM_WRIT_VOUCHER) .. GetString(CM_POST_STEP_TIP),
			textType= "numeric",
			default = defaultCharacterVariables.writVouchersStep,
			
			getFunc = 	function() 
							return characterVar.writVouchersStep 
						end,
			setFunc = 	function(choice)
							characterVar.writVouchersStep = tonumber(choice)
						end
		},
		{
			type = "editbox",
			name = GetString(CM_MIN) .. colorWritVouchers .. GetString(CM_WRIT_VOUCHER) .. "|r" .. GetString(CM_POST_AMOUNT_TIP),
			tooltip = GetString(CM_PRE_TIP) .. GetString(CM_MINIMUM) .. GetString(CM_WRIT_VOUCHER) .. GetString(CM_POST_AMOUNT_TIP),
			textType= "numeric",
			default = defaultCharacterVariables.writVouchersMin,
			
			getFunc = 	function() 
							return characterVar.writVouchersMin
						end,
			setFunc = 	function(choice)
							characterVar.writVouchersMin = tonumber(choice)
						end
		},
		-- divider
        {	type = "divider", width = "full" }
	}
	LAM:RegisterOptionControls("CurrencyManagerPanel", optionsData)
end


local function OnBankOpen(event, bagId)

	if IsHouseBankBag(bagId) then
		-- House Storage Coffer, it has no interface for currency transfer
		return
	else
		Transfer("Gold")
		Transfer("TelVarStones")
		Transfer("AlliancePoints")
		Transfer("WritVouchers")
	end
end

local function getSettings()
	if not charSettings.byChar.accountWide then
		return charSettings.byChar
	else
		return charSettings.byAccount
	end
end


local function Initialize()
	--	Connect with Account Wide saved Variables
	--  ZO_SavedVars:NewAccountWide(savedVariableTable, version, namespace, defaults, profile, displayName) 
	charSettings.byAccount = ZO_SavedVars:NewAccountWide("CurrencyManagerSettings", 3, nil, defaultCharacterVariables)

	--	Connect with Character Based saved Variables
	--  ZO_SavedVars:NewCharacterNameSettings(savedVariableTable, version, namespace, defaults, profile)
	--  ZO_SavedVars:NewCharacterIdSettings(savedVariableTable, version, namespace, defaults, profile)
	--  Note: 
	--  NewCharacterNameSettings saves readable char name in the addon saved var file
	--  NewCharacterIdSettings saves a numeric id instead of the char name in the addon saved var file
	charSettings.byChar = ZO_SavedVars:NewCharacterNameSettings("CurrencyManagerSettings", 3, nil, defaultCharacterVariables)

	-- Use Character or Account Wide Settings
	characterVar = getSettings()
	
	--	Generate Settings Menu
	CreateSettingsMenu()

	--	Register listener(s) for event(s)
	EVENT_MANAGER:RegisterForEvent("CurrencyManagerBankOpen", EVENT_OPEN_BANK, OnBankOpen)

	--	Cleanup:
	--	After our event has loaded, do not need to listen for further calls.
	EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)

end


local function OnAddOnLoaded(event, addonLoading)
	if addonLoading == ADDON_NAME then
		Initialize()
	end
end
EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
