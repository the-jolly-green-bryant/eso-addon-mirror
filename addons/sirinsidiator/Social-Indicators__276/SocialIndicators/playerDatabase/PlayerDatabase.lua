local PlayerData = SocialIndicators.PlayerData
local CharacterData = SocialIndicators.CharacterData
local LogDebug = SocialIndicators.LogDebug

local PlayerDatabase = ZO_Object:Subclass()
SocialIndicators.PlayerDatabase = PlayerDatabase

function PlayerDatabase:New(...)
	local object = ZO_Object.New(self)
	object:Initialize(...)
	return object
end

function PlayerDatabase:Initialize(saveData)
	self.saveData = saveData or {}
	if(not self.saveData.baseTime) then
		self.saveData.baseTime = GetTimeStamp()
	end
	self.baseTime = self.saveData.baseTime

	self.playerDataCache = {}
	self.players = saveData.players or {}
	saveData.players = self.players

	self.characterDataCache = {}
	self.characters = saveData.characters or {}
	saveData.characters = self.characters

	self.playerByCharacter = saveData.playerByCharacter or {}
	saveData.playerByCharacter = self.playerByCharacter

	self.charactersByPlayer = {}

	for characterName, displayName in pairs(self.playerByCharacter) do
		self:SetPlayerCharacterLink(displayName, characterName)
	end
end

function PlayerDatabase:GetPlayer(displayName)
	if(not displayName) then return nil end
	local playerData = self.playerDataCache[displayName]
	if(not playerData) then
		playerData = PlayerData:New(self, displayName, self.players[displayName])
		self.playerDataCache[displayName] = playerData
	end
	return playerData
end

function PlayerDatabase:UpdatePlayer(displayName, encodedString)
	self.players[displayName] = encodedString
end

local function SanitizeCharacterName(characterName)
	if(type(characterName) == "string") then
		return characterName:gsub("%^.*x$","")
	end
	return nil
end

function PlayerDatabase:GetCharacter(characterName)
	characterName = SanitizeCharacterName(characterName)
	if(not characterName) then return nil end

	local characterData = self.characterDataCache[characterName]
	if(not characterData) then
		characterData = CharacterData:New(self, characterName, self.characters[characterName])
		self.characterDataCache[characterName] = characterData
	end
	return characterData
end

function PlayerDatabase:UpdateCharacter(characterName, encodedString)
	characterName = SanitizeCharacterName(characterName)
	if(not characterName) then return end
	self.characters[characterName] = encodedString
end

function PlayerDatabase:SetPlayerCharacterLink(displayName, characterName)
	characterName = SanitizeCharacterName(characterName)
	if(not displayName or #displayName == 0 or not characterName or #characterName == 0) then LogDebug("invalid arguments in SetPlayerCharacterLink (%s, %s)", tostring(displayName), tostring(characterName)) return end
	local characters = self.charactersByPlayer[displayName] or {}
	characters[#characters + 1] = characterName
	self.charactersByPlayer[displayName] = characters
	self.playerByCharacter[characterName] = displayName
end

function PlayerDatabase:GetCharactersForPlayer(displayName)
	local characters = self.charactersByPlayer[displayName]
	if(characters) then
		local characterObjects = {}
		for i = 1, #characters do
			characterObjects[#characterObjects + 1] = self:GetCharacter(characters[i])
		end
		return characterObjects
	end
	return nil
end

function PlayerDatabase:GetCharacterNamesForPlayer(displayName)
	local characters = self.charactersByPlayer[displayName]
	if(characters) then
		local characterNames = {}
		for i = 1, #characters do
			characterNames[#characterNames + 1] = characters[i]
		end
		return characterNames
	end
	return nil
end

function PlayerDatabase:GetPlayerForCharacter(characterName)
	characterName = SanitizeCharacterName(characterName)
	return self:GetPlayer(self.playerByCharacter[characterName])
end

function PlayerDatabase:GetPlayerAndCharacterFromCharacterOrDisplayName(name)
	local player, character
	if(IsDecoratedDisplayName(name)) then
		player = self:GetPlayer(name)
		local characters = self.charactersByPlayer[name]
		if(characters) then
			local charTemp
			for i = 1, #characters do
				charTemp = self:GetCharacter(characters[i])
				if(not character or (charTemp and character.lastSeen < charTemp.lastSeen)) then
					character = charTemp
				end
			end
		end
	else
		character = self:GetCharacter(name)
		if(character) then
			player = character:GetPlayer()
		end
	end
	return player, character
end
