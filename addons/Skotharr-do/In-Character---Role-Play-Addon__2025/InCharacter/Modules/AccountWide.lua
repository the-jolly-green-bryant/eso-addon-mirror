--[[
Title:   Account-Wide Data
Version: 1.1.3
Author:  @Skotharr-do [PC/EU]
--]]

IC.AccountWide = {}

local accountWide = {
	icVersion = 1,
	accounts = {}
}

local function FindCharactersByAccount(accountName)
	local accounts = accountWide.accounts;
	if IC.Utility.IsTable(accounts[accountName]) and IC.Utility.IsTable(accounts[accountName].characters) then
		return accounts[accountName].characters
	end
	return nil
end

local function AcquireAccount(accountName)
	local accounts = accountWide.accounts
	accounts[accountName] = IC.Utility.ReturnTable(accounts[accountName])
	return accounts[accountName]
end

local function AcquireCharacter(accountName, characterName)
	local account = AcquireAccount(accountName)
	account.characters = IC.Utility.ReturnTable(account.characters)
	account.characters[characterName] = IC.Utility.ReturnTable(account.characters[characterName])
	return account.characters[characterName]
end

function IC.AccountWide.ReadCharacterNames(accountName)
	local namelist = ''
	local characters = FindCharactersByAccount(accountName)
	if characters ~= nil then
		-- convert to index-based array
		local characterNames = {}
		for void, character in pairs(characters) do
			table.insert(characterNames, character.name)
		end
		-- sort by names
		table.sort(characterNames, function(a, b) return a < b end)

		-- collect all found character names
		for void, name in ipairs(characterNames) do
			namelist = namelist..name..', '
		end

		-- remove trailing comma
		if namelist:len() > 0 then
			namelist = namelist:sub(1, namelist:len() - 2)
		end
	end
	return namelist
end

function IC.AccountWide.FindAccountName(characterName)
	for accountName, account in pairs(accountWide.accounts) do
		if IC.Utility.IsTable(account.characters) then
			local character = account.characters[characterName]
			if character ~= nil then
				return accountName
			end
		end
	end
	return nil
end

function IC.AccountWide.WriteCharacter(accountName, characterName, characterDescription)
	local currentTime = os.time()
	local account = AcquireAccount(accountName)
	account.time = currentTime
	account.name = accountName
	local character = AcquireCharacter(accountName, characterName)
	character.time = currentTime
	character.name = characterName
	character.description = characterDescription
end

function IC.AccountWide.ReadCharacter(accountName, characterName)
	-- search for character
	if accountName == nil then
		for void, account in pairs(accountWide.accounts) do
			if IC.Utility.IsTable(account.characters) then
				local character = account.characters[characterName]
				if character ~= nil then
					return character
				end
			end
		end

	-- get character by account
	else
		local characters = FindCharactersByAccount(accountName)
		if characters ~= nil and IC.Utility.IsTable(characters[characterName]) then
			return accountWide.accounts[accountName].characters[characterName]
		end
	end
	return nil
end

function IC.AccountWide.Initialize()
	accountWide = ZO_SavedVars:NewAccountWide(IC.Addon.SAVED_VARIABLES_NAME, IC.Addon.SAVED_VARIABLES_VERSION, nil, accountWide, nil)
end