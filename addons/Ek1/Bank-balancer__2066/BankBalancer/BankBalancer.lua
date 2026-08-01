local BankBalancer = {
	Author = "Ek1",
	Description = "When accessing a bank balances the gold between characters and bank so that roughly half of all gold is kept in the bank.",
	Version = "4.0-180709",
	License = "BY-SA = Creative Commons Attribution-ShareAlike 4.0 International License"
}
local ADDON_NAME = "BankBalancer"

--[[
Funktions and triggers that are used from API
EVENT_OPEN_BANK (number eventCode, Bag bankBag)
TransferCurrency(number CurrencyType currencyType, number amount, number CurrencyLocation fromLocation, number CurrencyLocation toLocation)
]]
function BankBalancer.balance(eventCode, bankBag)

	local total = GetBankedCurrencyAmount(CURT_MONEY) + GetCarriedCurrencyAmount(CURT_MONEY)
	local charactersShare = math.floor (total / GetNumCharacters() )
	
	if charactersShare < GetCarriedCurrencyAmount(CURT_MONEY) then
		-- Carrying too much cash, counting how much should be depoisited to bank 
		local Pankkiin = GetCarriedCurrencyAmount(CURT_MONEY) - charactersShare
		TransferCurrency(CURT_MONEY, Pankkiin, CURRENCY_LOCATION_CHARACTER, CURRENCY_LOCATION_BANK)
		d("BankBalancer:  " .. Pankkiin .. " ".. GetUnitName('player') .. " => Bank" )
	end
	-- Using double if instead of if-else as then we can forget fractions
	if  GetCarriedCurrencyAmount(CURT_MONEY) < charactersShare then
		-- Carrying too little cash, counting how much should be withdrawing from bank
		local Pankista = charactersShare - GetCarriedCurrencyAmount(CURT_MONEY)
		TransferCurrency(CURT_MONEY, Pankista, CURRENCY_LOCATION_BANK, CURRENCY_LOCATION_CHARACTER)
		d("BankBalancer:  " .. Pankista .. " Bank => " .. GetUnitName('player') )
	end
end
-- Registering the event to event manager
EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_OPEN_BANK, BankBalancer.balance)