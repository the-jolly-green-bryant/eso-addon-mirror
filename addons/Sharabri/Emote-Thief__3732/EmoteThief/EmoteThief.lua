EmoteThief = {
	name = "EmoteThief",
	version = 2,
	variableVersion = 2,
}

EmoteThief.SV_TYPE_ACCOUNTWIDE = 0
EmoteThief.SV_TYPE_PERCHARACTER = 1
EmoteThief.SV_TYPE_PERSERVER = 2

local savedVariables = {}

local SettingsSV
local EmoteListSV

local emote_list_default = {
	emotes = {
		{"bluelute", 8080, 5}, -- minstrel lute
		{"tambourine", 8080, 7}, -- minstrel drum
		{"flute2", 8080, 6}, -- minstrel flute
		{"harp", 10913, 5}, -- passion's muse lute
		{"balance", 10913, 91}, -- passion's muse stretch
		{"plantlight", 10913, 98}, -- passion's muse ritual
		{"fireorb", 774, 151}, -- deadlands firewalker doom
		{"jestercheer", 773, 25}, -- jester cheer
		{"breathefire", 773, 178}, -- jester spit
		{"kneelwithbook", 775, 102}, -- scholar kneel
		{"telescope", 6927, 110}, -- swashbuckler search
		{"read2books", 1234, 10}, -- telvanni magister read
		{"jugglelight", 1234, 194}, -- telvanni magister juggleflame
		{"playwithlight", 1234, 98}, -- telvanni magister ritual
		{"crouchwithtorch", 5884, 101}, -- treasure hunter crouch
		{"readwithtorch", 5884, 10}, -- treasure hunter read
		{"summonskull", 4725, 151}, -- worm wizard doom
		{"summonskeleton", 4725, 98}, -- worm wizard ritual
		{"maniacal", 9650, 190}, -- maniacal jester idle2 
		{"stoneorb", 11875, 151}, -- master of schemes doom
	}
}

local ResetPersonality, PersonalityChangeResult, RegisterEmoteCommand

function ResetPersonality()
	zo_callLater(
		function()
			if SettingsSV.saved_personality == nil then return end
			EVENT_MANAGER:RegisterForEvent("EmoteThief_CheckChange", EVENT_COLLECTIBLE_USE_RESULT, PersonalityChangeResult)
			if SettingsSV.saved_personality ~= 0 then
				UseCollectible(SettingsSV.saved_personality)
			else
				UseCollectible(GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_PERSONALITY))
			end
		end,
	500)
end

function PersonalityChangeResult(_, blockReason, isAttemptingActivation)
	EVENT_MANAGER:UnregisterForEvent("EmoteThief_CheckChange", EVENT_COLLECTIBLE_USE_RESULT)
	if blockReason == COLLECTIBLE_USAGE_BLOCK_REASON_ITERATION_BEGIN then
		SettingsSV.saved_personality = nil
	else
		ResetPersonality()
	end
end

local savedX, savedY, savedZ
local function HasPlayerMoved()
	local x, y, z = GetUnitWorldPosition("player")
	if savedX ~= nil and savedY ~= nil and savedZ ~= nil then
		if x ~= savedX or y ~= savedY or z ~= savedZ then
			savedX, savedY, savedZ = nil
			return true
		end
	end
	savedX, savedY, savedZ = x, y, z
	return false
end

local function EndEmoteChecks()
	ResetPersonality()
	EVENT_MANAGER:UnregisterForUpdate("EmoteThief_CheckEmoteEnd")
	EVENT_MANAGER:UnregisterForEvent("EmoteThief_CrouchCheck", EVENT_STEALTH_STATE_CHANGED)
end

local function CheckEmoteEnd()
	if HasPlayerMoved() or SCENE_MANAGER:GetScene("stats").state == "shown" then
		EndEmoteChecks()
	end
end

local function OnStealthStateChanged(_, UnitID, _)
	if UnitID == "player" then
		EndEmoteChecks()
	end
end

local function PlayEmote(emote)
	EVENT_MANAGER:UnregisterForEvent("EmoteThief_PlayEmote", EVENT_PERSONALITY_CHANGED)
	PlayEmoteByIndex(emote)
	EVENT_MANAGER:RegisterForEvent("EmoteThief_CrouchCheck", EVENT_STEALTH_STATE_CHANGED, OnStealthStateChanged)
	EVENT_MANAGER:RegisterForUpdate("EmoteThief_CheckEmoteEnd", 250, CheckEmoteEnd)
end

local function OnPlayerActivated()
	if SettingsSV.saved_personality == nil then return end
	ResetPersonality()
end

function EmoteThief:NewSavedVar(name, svType, default)
	if svType == EmoteThief.SV_TYPE_ACCOUNTWIDE then
		savedVariables[name] = ZO_SavedVars:NewAccountWide(EmoteThief.name .. "SV", EmoteThief.variableVersion, name, default)
		return savedVariables[name]
	elseif svType == EmoteThief.SV_TYPE_PERCHARACTER then
		savedVariables[name] = ZO_SavedVars:NewCharacterIdSettings(EmoteThief.name .. "SV", EmoteThief.variableVersion, name, default)
		return savedVariables[name]
	elseif svType == EmoteThief.SV_TYPE_PERSERVER then
		savedVariables[name] = ZO_SavedVars:NewAccountWide(EmoteThief.name .. "SV", EmoteThief.variableVersion, name, {["EU"] = default, ["NA"] = default})
		local server = GetWorldName():gsub(" Megaserver", "")
		return savedVariables[name][server]
	end
end

function RegisterEmoteCommand(command_name, collectible, emote)
	if SLASH_COMMANDS["/" .. command_name] ~= nil then
		d("Command already exists.")
		return false
	end
	if GetCollectibleCategoryType(collectible) ~= COLLECTIBLE_CATEGORY_TYPE_PERSONALITY then
		d("Collectible is not a personality.")
		return false
	end
	if not (IsCollectibleOwnedByDefId(collectible)) then
		d("Personality not owned.")
		return false
	end
	SLASH_COMMANDS["/" .. command_name] = function()
		local current_personality = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_PERSONALITY)
		if collectible == current_personality then
			PlayEmoteByIndex(emote)
			return
		end
		if SettingsSV.saved_personality == nil then 
			SettingsSV.saved_personality = current_personality
		end
		EVENT_MANAGER:RegisterForEvent("EmoteThief_PlayEmote", EVENT_PERSONALITY_CHANGED, function() PlayEmote(emote) end)
		UseCollectible(collectible)
	end
	return true
end

SLASH_COMMANDS["/searchpersonality"] = function (arg)
	local range = 100000
	local i = 1
	while i <= range do
		local name = GetCollectibleName(i)
		local cattype = GetCollectibleCategoryType(i)
		if cattype == COLLECTIBLE_CATEGORY_TYPE_PERSONALITY and string.find(string.lower(name), string.lower(arg)) then
			d(zo_strformat("<<1>> #<<2>>", name, i))
			local overriddencommands = {GetCollectiblePersonalityOverridenEmoteSlashCommandNames(i)}
			local j = 1
			while j <= 1000 do
				local slashcommand = GetEmoteSlashNameByIndex(j)
				for _, overriddencommand in pairs(overriddencommands) do
					if slashcommand == overriddencommand then
						d("||            " .. zo_strformat("<<1>> #<<2>>", slashcommand, j))
					end
				end
				j = j + 1
			end
		end
		i = i + 1
	end
end

local function RegisterCommands()
	SLASH_COMMANDS["/stealemote"] = function (raw_args)
		local args = {}
		local message = "|cdf4200Usage: /stealemote <command name> <personality ID> <emote index>|r"
		for arg in raw_args:gmatch("%w+") do table.insert(args, arg) end
		if #args ~= 3 then
			d(message)
			return
		end
		local commandname = args[1]
		local personalityID = tonumber(args[2])
		local emoteindex = tonumber(args[3])
		if personalityID == nil or emoteindex == nil then
			d(message)
			return
		end
		table.insert(EmoteListSV.emotes, {commandname, personalityID, emoteindex})
		if RegisterEmoteCommand(commandname, personalityID, emoteindex) then
			d("New command: /" .. commandname .. " added.")
		end
	end

	SLASH_COMMANDS["/removeemote"] = function (command)
		for i, emote in ipairs(EmoteListSV.emotes) do
			if emote[1] == command then
				EmoteListSV.emotes[i] = nil
				SLASH_COMMANDS["/" .. command] = nil
				d("Command /" .. command .. " removed.")
				return
			end
		end
		d("You can't return what wasn't stolen :)")
	end
end

local function Initialize()
	for _, value in ipairs(EmoteListSV.emotes) do
		RegisterEmoteCommand(value[1], value[2], value[3])
	end
end

local function OnAddOnLoaded(event, addonName)
	if addonName ~= EmoteThief.name then return end
	EVENT_MANAGER:UnregisterForEvent(EmoteThief.name, EVENT_ADD_ON_LOADED)
	SettingsSV = EmoteThief:NewSavedVar("Settings", EmoteThief.SV_TYPE_PERCHARACTER, {saved_personality = nil})
	EmoteListSV = EmoteThief:NewSavedVar("EmoteList", EmoteThief.SV_TYPE_ACCOUNTWIDE, emote_list_default)
	Initialize()
	RegisterCommands()
	EVENT_MANAGER:RegisterForEvent(EmoteThief.name, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
end

EVENT_MANAGER:RegisterForEvent(EmoteThief.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
