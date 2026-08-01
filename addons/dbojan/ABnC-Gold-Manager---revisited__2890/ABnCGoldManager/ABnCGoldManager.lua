--	----------------------------------------------------------------------
--	Title: Alt Bank 'n Craft - Gold Manager
--	Author: Serunati
--	Sub-Title: Gold Manager
--	Version: 1.3.100009
--	(PackageVersion.ModuleVersion.ESOAPIVersion)
--	----------------------------------------------------------------------
--
-- 	Description:	This module contains the functions required to manage
-- 					automatic handling of gold on your characters based on
-- 					defined rules.
--
--	- Automatic:	Each time you return to the bank, your character will
-- 					leave with a preset amount which scales with your level.
-- 					This is a work in progress to account for having enough
-- 					'ready gold' on hand for a random quest bribe etc.
--
--	- Fixed:		Each time you return to the bank, your character's gold
-- 					will be set to a user set amount.
--
--	- None:			Don't transfer any money to bank.
--
--	- Withdraw:		Withdraw all gold from the bank.
--
--	- Crafting:		For characters that are crafting/bank/mules, the
-- 					assumption is that any gold they have will be from selling
-- 					items they craft for skill advancement or gold making.
-- 					Either way they do not leave the city and dump all their
-- 					gold into the account bank on each visit.
--	----------------------------------------------------------------------


--changed default from automatic to crafing
--fixed spelling of automaticAmount

local name = "ABnCGoldManager"
local characterVar = {}

local defaultPerCharacterVariables = {
		managementMethod	= "Crafting",
		automaticAmount		= 0,
		fixedAmount			= 400
}



local function UpdateAutomaticAmount()
	characterVar.automaticAmount = GetUnitLevel("Player") * 50
end


local function TransferGold()
	--	Initialize variable for transfer amount.
	local transferAmount = 0

	--	Get amount of gold character is carrying.
	local bagGold = GetCurrentMoney()
	--	Get amount of gold in bank.
	local bankGold = GetBankedMoney()

	--	Update ending gold value.
	if characterVar.managementMethod == "Automatic" then		--	Automatic method:
		--	- Automatic management method.
		UpdateAutomaticAmount()
		transferAmount = bagGold - characterVar.automaticAmount
	elseif characterVar.managementMethod == "Crafting" then
		--	- Crafting management method
		transferAmount = bagGold
	elseif characterVar.managementMethod == "None" then
		--	- Set transfer amount to 0
		transferAmount = 0
	elseif characterVar.managementMethod == "Withdraw" then
		--	- Withdraw all the money
		if bankGold > 0 then transferAmount = -bankGold end --set it to negative, exact amount of money in the bank. you have to have some money in the bank
	else
		--	- Fixed method:
		transferAmount = bagGold - characterVar.fixedAmount
	end

	--	Based on transferGold's value(+/-) call for a deposit or withdrawal.


	if transferAmount < 0  then --transfer is negative, withdraw from the bank. bank has to have more than 0 gold
		transferAmount = math.abs(transferAmount)
		if transferAmount > bankGold then --asked for more than in the bank, lower it to bank amount
			d("Only " .. bankGold .. " available in bank.")
			transferAmount = bankGold
		end
		WithdrawMoneyFromBank(transferAmount)
		d("Withdrew: " .. transferAmount .. " gold.")

	elseif transferAmount > 0 then  --transfer is positive number, so deposit.
		DepositMoneyIntoBank(transferAmount)
		d("Deposited: " .. transferAmount .. " gold.")
	end




--auto deposit telvar stones, alliance points and writ wouchers to the bank. start of the block. add [[ below this to start comment block

local my_currency
local my_carried

my_carried = 0
my_currency = CURT_TELVAR_STONES
my_carried = GetCarriedCurrencyAmount(my_currency)
if my_carried > 0 then
 DepositCurrencyIntoBank( my_currency, my_carried )
 d("Deposited telvar stones: " .. my_carried )
end

my_carried = 0
my_currency = CURT_ALLIANCE_POINTS
my_carried = GetCarriedCurrencyAmount(my_currency)
if my_carried > 0 then
 DepositCurrencyIntoBank( my_currency, my_carried )
 d("Deposited alliance points: " .. my_carried )
end

my_carried = 0
my_currency = CURT_WRIT_VOUCHERS
my_carried = GetCarriedCurrencyAmount(my_currency)
if my_carried > 0 then
 DepositCurrencyIntoBank( my_currency, my_carried )
 d("Deposited writ vouchers: " .. my_carried )
end

--end of the block. add ]] above this to start comment block





end


local function CreateSettingsMenu()

   local panelData = {
      type = "panel",
      name = "ABnC Gold Manager",
      displayName = "ABnC Gold Manager",
      author = "Serunati",
      version = "0.1.100008",
      registerForRefresh = true,
      registerForDefaults = true,
   }
   local LAM = LibStub("LibAddonMenu-2.0")
   LAM:RegisterAddonPanel("ABnCGold", panelData)

   local optionsData = {
      {
         type = "dropdown",
         name = "Management Method",
         tooltip = "Select the gold management method you want to use.",
         choices = {"Automatic", "Fixed", "Crafting", "None", "Withdraw"},
         getFunc = function() return characterVar.managementMethod end,
         setFunc = 	function(choice)
						characterVar.managementMethod = choice
					end,
      },
	  {
		  type = "editbox",
		  name = "Fixed Amount:",
		  tootip = "Enter the amount of gold to keep when using 'Fixed' management.",
		  getFunc = function() return characterVar.fixedAmount end,
		  setFunc = function(choice)
		  				characterVar.fixedAmount = choice
		  			end,
	  },
   }
   LAM:RegisterOptionControls("ABnCGold", optionsData)

end


local function OnBankOpen(event)
	TransferGold()
end


local function Initialize()
	--	Connect with saved Variables
	characterVar = ZO_SavedVars:New("ABnCGold_Character", 2, nil, defaultPerCharacterVariables)

	--	Setup Settings Menu
	CreateSettingsMenu()

	--	Register listener(s) for event(s)
	EVENT_MANAGER:RegisterForEvent("ABnCGold_BankOpen", EVENT_OPEN_BANK, OnBankOpen)

	--	Cleanup:
	--	-	After our event has loaded, we do not need to listen for further calls.
	EVENT_MANAGER:UnregisterForEvent(name, EVENT_ADD_ON_LOADED)

end


local function OnAddOnLoaded(event, addonLoading)
	if addonLoading == name then
		Initialize()
	end
end
EVENT_MANAGER:RegisterForEvent(name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
