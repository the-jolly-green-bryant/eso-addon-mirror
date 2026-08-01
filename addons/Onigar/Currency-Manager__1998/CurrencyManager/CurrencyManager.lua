--	----------------------------------------------------------------------
--	CurrencyManager by Onigar
--	----------------------------------------------------------------------
--
-- 	Description:	This module contains the functions required to manage
-- 					automatic handling of the Bankable ESO Currencies on
--					your characters based on defined rules.
--
--	Fixed:			Each time you visit a Bank interface, your character's
-- 					specific Currency will be set to a user defined amount.
--
--	Empty:		    For characters you choose to not keep in your bag any 
--					of a specific ESO Currency.
--
--	None:		    For characters you choose to not have any management for
--                  a specific ESO Currency.
--
--  Future:			note: check for TBD in comments
--					how to display the text value of a var like currencyName
--					add localisation
--
--	----------------------------------------------------------------------

-- Addon Common Definitions
local ADDON_NAME 		= "CurrencyManager"
local ADDON_AUTHOR 		= "Onigar"
local ADDON_WEBSITE		= "http://www.esoui.com/downloads/info1998-CurrencyManager.html#info"
local ADDON_VERSION		= "1.15.0"
-- Version = MajorVersion.MinorVersion.MiniFixes
local ADDON_SAVED_VARIABLES_VERSION	= 4
-- Should there be a need to restructure the Saved Variables file then this can be used to
-- help manage the saved data changes (and hopefully) without information loss.

local colorWithdraw = "|cff3333"
local colorDeposit  = "|c00ff99"
local colorGold     = "|cffff24"
local colorTelVar   = "|c769ae4"
local colorAP       = "|c53ca56"
local colorWrit     = "|cffff90"

local characterVar = {}
local charSettings = {}

-- Default Setting is to take no action allowing the User to define Currency Transfer Rules
-- Setting Account Wide to "true" seems sensible
local STRING_NONE = GetString(CM_CHAR_VAR_NONE)
local defaultCharacterVariables = {
		accountWide 					= true,
		goldManagementType				= STRING_NONE,
		goldFixedAmount					= 5000,
		telVarStonesManagementType		= STRING_NONE,
		telVarStonesFixedAmount			= 100,
		alliancePointsManagementType	= STRING_NONE,
		alliancePointsFixedAmount		= 50000,
		writVouchersManagementType		= STRING_NONE,
		writVouchersFixedAmount			= 0,
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


local function TransferGold()

	--	Initialize variable for transfer amount.
	local transferAmount = 0
	--	Get amount character has in bag
	local goldBag = GetCurrentMoney()
	--	Get amount in bank
	local goldBank = GetBankedMoney()
	
	
	--	Get transfer amount based on management type
	if characterVar.goldManagementType == GetString(CM_CHAR_VAR_FIXED) then					--	Fixed management:
		transferAmount = goldBag - characterVar.goldFixedAmount
	elseif characterVar.goldManagementType == GetString(CM_CHAR_VAR_EMPTY) then				--	Empty management:
		transferAmount = goldBag
	else																					--	None, no management:
		transferAmount = 0
	end

	--	Using the transfer amount value(+/-) request a deposit or a withdrawal
	if transferAmount < 0 then
		transferAmount = math.abs(transferAmount)
		if transferAmount > goldBank then
			d(GetString(CM_PRE_ONLY) .. goldBank .. GetString(CM_POST_GOLD_AVAILABLE))
			transferAmount = goldBank
		end
		WithdrawCurrencyFromBank(CURT_MONEY, transferAmount)
		if transferAmount > 0 then
			d(colorWithdraw .. GetString(CM_PRE_WITHDREW) .. ZO_Currency_FormatPlatform(CURT_MONEY, transferAmount, ZO_CURRENCY_FORMAT_AMOUNT_ICON) .. colorGold .. GetString(CM_POST_GOLD) .. colorWithdraw .. GetString(CM_FROM_YOUR_BANK))
		end
	else
		DepositCurrencyIntoBank(CURT_MONEY, transferAmount)
		if transferAmount > 0 then
			d(colorDeposit .. GetString(CM_PRE_DEPOSITED) .. ZO_Currency_FormatPlatform(CURT_MONEY, transferAmount, ZO_CURRENCY_FORMAT_AMOUNT_ICON) .. colorGold .. GetString(CM_POST_GOLD) .. colorDeposit .. GetString(CM_INTO_YOUR_BANK))			
		end
	end
end


local function TransferTelVarStones()

	--	Initialize variable for transfer amount.
	local transferAmount = 0
	--	Get amount character has in bag
	local telVarStonesBag = GetCarriedCurrencyAmount(CURT_TELVAR_STONES)
	--	Get amount in bank
	local telVarStonesBank = GetBankedCurrencyAmount(CURT_TELVAR_STONES)

	--	Get transfer amount based on management type
	if characterVar.telVarStonesManagementType == GetString(CM_CHAR_VAR_FIXED) then			--	Fixed management:
		transferAmount = telVarStonesBag - characterVar.telVarStonesFixedAmount
	elseif characterVar.telVarStonesManagementType == GetString(CM_CHAR_VAR_EMPTY) then		--	Empty management:
		transferAmount = telVarStonesBag
	else																					--	None, no management:
		transferAmount = 0
	end

	--	Using the transfer amount value(+/-) request a deposit or a withdrawal
	if transferAmount < 0 then
		transferAmount = math.abs(transferAmount)
		if transferAmount > telVarStonesBank then
			d(GetString(CM_PRE_ONLY) .. telVarStonesBank .. GetString(CM_POST_TEL_VAR_AVAILABLE))
			transferAmount = telVarStonesBank
		end
		WithdrawCurrencyFromBank(CURT_TELVAR_STONES, transferAmount)
		if transferAmount > 0 then
			d(colorWithdraw .. GetString(CM_PRE_WITHDREW) .. ZO_Currency_FormatPlatform(CURT_TELVAR_STONES, transferAmount, ZO_CURRENCY_FORMAT_AMOUNT_ICON) .. colorTelVar .. GetString(CM_POST_TEL_VAR) .. colorWithdraw .. GetString(CM_FROM_YOUR_BANK))
		end
	else
		DepositCurrencyIntoBank(CURT_TELVAR_STONES, transferAmount)
		if transferAmount > 0 then
			d(colorDeposit .. GetString(CM_PRE_DEPOSITED) .. ZO_Currency_FormatPlatform(CURT_TELVAR_STONES, transferAmount, ZO_CURRENCY_FORMAT_AMOUNT_ICON) .. colorTelVar .. GetString(CM_POST_TEL_VAR) .. colorDeposit .. GetString(CM_INTO_YOUR_BANK))
		end
	end
end


local function TransferAlliancePoints()

	--	Initialize variable for transfer amount.
	local transferAmount = 0
	--	Get amount character has in bag
	local alliancePointsBag = GetCarriedCurrencyAmount(CURT_ALLIANCE_POINTS)
	--	Get amount in bank
	local alliancePointsBank = GetBankedCurrencyAmount(CURT_ALLIANCE_POINTS)

	--	Get transfer amount based on management type
	if characterVar.alliancePointsManagementType == GetString(CM_CHAR_VAR_FIXED) then		--	Fixed management:
		transferAmount = alliancePointsBag - characterVar.alliancePointsFixedAmount
	elseif characterVar.alliancePointsManagementType == GetString(CM_CHAR_VAR_EMPTY) then	--	Empty management:
		transferAmount = alliancePointsBag
	else																					--	None, no management:
		transferAmount = 0
	end

	--	Using the transfer amount value(+/-) request a deposit or a withdrawal
	if transferAmount < 0 then
		transferAmount = math.abs(transferAmount)
		if transferAmount > alliancePointsBank then
			d(GetString(CM_PRE_ONLY) .. alliancePointsBank .. GetString(CM_POST_AP_AVAILABLE))
			transferAmount = alliancePointsBank
		end
		WithdrawCurrencyFromBank(CURT_ALLIANCE_POINTS, transferAmount)
		if transferAmount > 0 then
			d(colorWithdraw .. GetString(CM_PRE_WITHDREW) .. ZO_Currency_FormatPlatform(CURT_ALLIANCE_POINTS, transferAmount, ZO_CURRENCY_FORMAT_AMOUNT_ICON) .. colorAP .. GetString(CM_POST_AP) .. colorWithdraw .. GetString(CM_FROM_YOUR_BANK))
		end
	else
		DepositCurrencyIntoBank(CURT_ALLIANCE_POINTS, transferAmount)
		if transferAmount > 0 then
			d(colorDeposit .. GetString(CM_PRE_DEPOSITED) .. ZO_Currency_FormatPlatform(CURT_ALLIANCE_POINTS, transferAmount, ZO_CURRENCY_FORMAT_AMOUNT_ICON) .. colorAP .. GetString(CM_POST_AP) .. colorDeposit .. GetString(CM_INTO_YOUR_BANK))
		end
	end
end


local function TransferWritVouchers()

	--	Initialize variable for transfer amount.
	local transferAmount = 0
	--	Get amount character has in bag
	local writVouchersBag = GetCarriedCurrencyAmount(CURT_WRIT_VOUCHERS)
	--	Get amount in bank
	local writVouchersBank = GetBankedCurrencyAmount(CURT_WRIT_VOUCHERS)

	--	Get transfer amount based on management type
	if characterVar.writVouchersManagementType == GetString(CM_CHAR_VAR_FIXED) then			--	Fixed management:
		transferAmount = writVouchersBag - characterVar.writVouchersFixedAmount
	elseif characterVar.writVouchersManagementType == GetString(CM_CHAR_VAR_EMPTY) then		--	Empty management:
		transferAmount = writVouchersBag
	else																					--	None, no management:
		transferAmount = 0
	end

	--	Using the transfer amount value(+/-) request a deposit or a withdrawal
	if transferAmount < 0 then
		transferAmount = math.abs(transferAmount)
		if transferAmount > writVouchersBank then
			d(GetString(CM_PRE_ONLY) .. writVouchersBank .. GetString(CM_POST_WRIT_VOUCH_AVAILABLE))
			transferAmount = writVouchersBank
		end
		WithdrawCurrencyFromBank(CURT_WRIT_VOUCHERS, transferAmount)
		if transferAmount > 0 then
			d(colorWithdraw .. GetString(CM_PRE_WITHDREW) .. ZO_Currency_FormatPlatform(CURT_WRIT_VOUCHERS, transferAmount, ZO_CURRENCY_FORMAT_AMOUNT_ICON) .. colorWrit .. GetString(CM_POST_WRIT_VOUCHERS) .. colorWithdraw .. GetString(CM_FROM_YOUR_BANK))
		end
	else
		DepositCurrencyIntoBank(CURT_WRIT_VOUCHERS, transferAmount)
		if transferAmount > 0 then
			d(colorDeposit .. GetString(CM_PRE_DEPOSITED) .. ZO_Currency_FormatPlatform(CURT_WRIT_VOUCHERS, transferAmount, ZO_CURRENCY_FORMAT_AMOUNT_ICON) .. colorWrit .. GetString(CM_POST_WRIT_VOUCHERS) .. colorDeposit .. GetString(CM_INTO_YOUR_BANK))
		end
	end
end


local function CreateSettingsMenu()

	local LAM = LibAddonMenu2

	local panelData = {
		type = "panel",
		-- name = the title you see in the list of addons when displayed by "Settings, Addons" 
		name = "Oni's " .. GetString(CM_ADDON_LONG_NAME),
		-- displayName = the title at the top of the addon panel
		displayName = "|c4a9300" .. GetString(CM_ADDON_LONG_NAME) .. "|r",
		author = ADDON_AUTHOR,
		version = ADDON_VERSION,
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
							return charSettings.byAccount.accountWide
						end,
			setFunc = 	function(value) 
							charSettings.byAccount.accountWide = value 
						end,
			requiresReload = true,
		},
		
		-- Gold Management
		-- divider
        {	type = "divider", width = "full" },
		{
			type = "dropdown",
			name = colorGold .. GetString(CM_PRE_GOLD_TITLE) .. "|r" .. GetString(CM_POST_MANAGEMENT_TYPE),
			tooltip = GetString(CM_MANAGEMENT_TYPE_TIP),
			default = defaultCharacterVariables.goldManagementType,
			choices = {GetString(CM_CHAR_VAR_FIXED), GetString(CM_CHAR_VAR_EMPTY), GetString(CM_CHAR_VAR_NONE)},
		 
			getFunc = 	function()
							return characterVar.goldManagementType
						end,
			setFunc = 	function(choice)
							characterVar.goldManagementType = choice
						end,
		},
		{
			type = "editbox",
			name = colorGold .. GetString(CM_PRE_GOLD_TITLE) .. "|r" .. GetString(CM_POST_FIXED_AMOUNT),
			tooltip = GetString(CM_GOLD_FIXED_AMOUNT_TIP),
			default = defaultCharacterVariables.goldFixedAmount,
			
			getFunc = 	function() 
							return characterVar.goldFixedAmount 
						end,
			setFunc = 	function(choice)
							characterVar.goldFixedAmount = choice
						end,
		},
		
		-- Tel Var Stones Management
		-- divider
        {	type = "divider", width = "full" },
		{
			type = "dropdown",
			name = colorTelVar .. GetString(CM_PRE_TEL_VAR_TITLE) .. "|r" .. GetString(CM_POST_MANAGEMENT_TYPE),
			tooltip = GetString(CM_MANAGEMENT_TYPE_TIP),
			default = defaultCharacterVariables.telVarStonesManagementType,
			choices = {GetString(CM_CHAR_VAR_FIXED), GetString(CM_CHAR_VAR_EMPTY), GetString(CM_CHAR_VAR_NONE)},
		 
			getFunc = 	function()
							return characterVar.telVarStonesManagementType
						end,
			setFunc = 	function(choice)
							characterVar.telVarStonesManagementType = choice
						end,
		},
		{
			type = "editbox",
			name = colorTelVar .. GetString(CM_PRE_TEL_VAR_TITLE) .. "|r" .. GetString(CM_POST_FIXED_AMOUNT),
			tooltip = GetString(CM_TEL_VAR_FIXED_AMOUNT_TIP),
			default = defaultCharacterVariables.telVarStonesFixedAmount,
			
			getFunc = 	function() 
							return characterVar.telVarStonesFixedAmount 
						end,
			setFunc = 	function(choice)
							characterVar.telVarStonesFixedAmount = choice
						end,
		},
		{
            type = "description",
            text = GetString(CM_TEL_VAR_MULTIPLIER_NOTE),
            width = "full"
        },
		
		-- Alliance Points Management
		-- divider
        {	type = "divider", width = "full" },
		{
			type = "dropdown",


			name = colorAP .. GetString(CM_AP_TITLE) .. "|r" .. GetString(CM_POST_MANAGEMENT_TYPE),
			tooltip = GetString(CM_MANAGEMENT_TYPE_TIP),
			default = defaultCharacterVariables.alliancePointsManagementType,
			choices = {GetString(CM_CHAR_VAR_FIXED), GetString(CM_CHAR_VAR_EMPTY), GetString(CM_CHAR_VAR_NONE)},
		 
			getFunc = 	function()
							return characterVar.alliancePointsManagementType
						end,
			setFunc = 	function(choice)
							characterVar.alliancePointsManagementType = choice
						end,
		},
		{
			type = "editbox",
			name = colorAP .. GetString(CM_AP_TITLE) .. "|r" .. GetString(CM_POST_FIXED_AMOUNT),
--			tooltip = GetString(CM_AP_FIXED_AMOUNT_TIP),
			tooltip = GetString(CM_TEST_TEXT),
			default = defaultCharacterVariables.alliancePointsFixedAmount,
			
			getFunc = 	function() 
							return characterVar.alliancePointsFixedAmount 
						end,
			setFunc = 	function(choice)
							characterVar.alliancePointsFixedAmount = choice
						end,
		},
		
		-- Writ Voucher Management
		-- divider
        {	type = "divider", width = "full" },
		{
			type = "dropdown",
			name = colorWrit .. GetString(CM_WRIT_VOUCHER_TITLE) .. "|r" .. GetString(CM_POST_MANAGEMENT_TYPE),
			tooltip = GetString(CM_MANAGEMENT_TYPE_TIP),
			default = defaultCharacterVariables.writVouchersManagementType,
			choices = {GetString(CM_CHAR_VAR_FIXED), GetString(CM_CHAR_VAR_EMPTY), GetString(CM_CHAR_VAR_NONE)},
		 
			getFunc = 	function()
							return characterVar.writVouchersManagementType
						end,
			setFunc = 	function(choice)
							characterVar.writVouchersManagementType = choice
						end,
		},
		{
			type = "editbox",
			name = colorWrit .. GetString(CM_WRIT_VOUCHER_TITLE) .. "|r" .. GetString(CM_POST_FIXED_AMOUNT),
			tooltip = GetString(CM_WRIT_FIXED_AMOUNT_TIP),
			default = defaultCharacterVariables.writVouchersFixedAmount,
			
			getFunc = 	function() 
							return characterVar.writVouchersFixedAmount 
						end,
			setFunc = 	function(choice)
							characterVar.writVouchersFixedAmount = choice
						end,
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
            text = "|c5cb700" .. GetString(CM_CHAR_VAR_FIXED) .. "|r" .. GetString(CM_MAN_TYPE_FIXED_DESC),
            width = "full"
        },
        {
            type = "description",
            text = "|c5cb700" .. GetString(CM_CHAR_VAR_EMPTY) .. "|r" .. GetString(CM_MAN_TYPE_EMPTY_DESC),
            width = "full"
        },
		{
            type = "description",
            text = "|c5cb700" .. GetString(CM_CHAR_VAR_NONE) .. "|r" .. GetString(CM_MAN_TYPE_NONE_DESC),
            width = "full"
        },
		-- divider
        {	type = "divider", width = "full" },
	}
	LAM:RegisterOptionControls("CurrencyManagerPanel", optionsData)
end


local function OnBankOpen(event, bagId)

	if IsHouseBankBag(bagId) then
		-- House Storage Coffer, it has no interface for currency transfer
		return
	else
		TransferGold()
		TransferTelVarStones()
		TransferAlliancePoints()
		TransferWritVouchers()
	end
end

-- get all characters for this account for i = 1, GetNumCharacters() do
--    local c = zo_strformat("<<1>>", GetCharacterInfo(i))
--    allCharacters[i] = c
--  end

local function getSettings()
	if charSettings.byAccount.accountWide then
		return charSettings.byAccount
	else
		return charSettings.byChar
	end
end


local function Initialize()

	--	Connect with Account Wide saved Variables
	--  ZO_SavedVars:NewAccountWide(savedVariableTable, version, namespace, defaults, profile, displayName) 
	charSettings.byAccount = ZO_SavedVars:NewAccountWide("CurrencyManagerSettings", ADDON_SAVED_VARIABLES_VERSION, nil, defaultCharacterVariables, GetWorldName())

	--	Connect with Character Based saved Variables
	--  ZO_SavedVars:NewCharacterNameSettings(savedVariableTable, version, namespace, defaults, profile)
	--  ZO_SavedVars:NewCharacterIdSettings(savedVariableTable, version, namespace, defaults, profile)
	--  Note: 
	--  NewCharacterNameSettings saves readable char name in the addon saved var file
	--  NewCharacterIdSettings saves a numeric id instead of the char name in the addon saved var file
	charSettings.byChar = ZO_SavedVars:NewCharacterNameSettings("CurrencyManagerSettings", ADDON_SAVED_VARIABLES_VERSION, nil, defaultCharacterVariables, GetWorldName())

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
