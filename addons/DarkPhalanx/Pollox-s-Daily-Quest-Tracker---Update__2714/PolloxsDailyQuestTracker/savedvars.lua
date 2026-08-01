local SV = {}
DQT.SV = SV

-- Call this before using the object
function SV:init()
	-- load account-wide saved variables
	self.savedVarsPerAccount = ZO_SavedVars:NewAccountWide("PolloxsDailyQuestTracker_SavedVarsAccount", 1, nil, self:getAccountDefaults())
	
	--[[ load saved variables for each character
		 character id -> saved variables for that character
	--]]
	self.savedVarsPerChar = {}
	
	for _, character in ipairs(DQT.Utils:getCharacters()) do
		-- Load a different set of variables for each character, and use character id as the key
		self.savedVarsPerChar[character.id] = ZO_SavedVars:New("PolloxsDailyQuestTracker_SavedVarsChar",
			1, nil, DQT.SV:getCharDefaults(), nil, nil, character.name, character.id, ZO_SAVED_VARS_CHARACTER_ID_KEY)
	end
	
	-- get the latest timer info for this character
	DQT.Timer:init()
end

--[[
	Get account wide saved variables
	
	windowProperties = {x, y, width, height}
	charactersToShow: characterId -> shouldShow
	sectionsToShow: sectionName -> shouldShow
--]]
function SV:getAccountWide()
	return self.savedVarsPerAccount
end

--[[
	Get per character saved variables. See also getSavedVarsForChar.
	
	@return characterId -> saved variables
--]]
function SV:getPerChar()
	return self.savedVarsPerChar
end

--[[
	Get per character saved variables
	
	questStatuses:
		quest name -> (time added (in utc), completed (boolean))
	questTimers:
		TIMER_TYPE -> reset time (in utc)
		if entry is missing, reset time is unknown
--]]
function SV:getForChar(characterId)
	return self.savedVarsPerChar[characterId]
end

-- Get default account-wide settings
function SV:getAccountDefaults()
	-- get default window properties
	local x, y = DQTWindow:GetScreenRect()
	local width, height = DQTWindow:GetDimensions()
	
	local windowProperties = {
		x = x,
		y = y,
		width = width,
		height = height
	}
	
	------ get default settings ------
	-- by default, show all characters
	local charactersToShow = {}
	
	for _, character in ipairs(DQT.Utils:getCharacters()) do
		charactersToShow[character.id] = true
	end
	
	-- by default, hide all sections
	local sectionsToShow = {}
	
	for _, section in ipairs(DQT.Info.QuestSections) do
		sectionsToShow[section:getName()] = false
	end
	
	return {
		windowProperties = windowProperties,
		settings = {
			sectionsToShow = sectionsToShow,
			charactersToShow = charactersToShow
		}
	}
end

-- Get default per character data
function SV:getCharDefaults()
	return {
		questStatuses = {},
		questTimers = {}
	}
end