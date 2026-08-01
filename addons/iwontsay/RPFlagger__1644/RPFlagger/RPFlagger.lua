local DEBUG =
function() end
-- d

local function _tr(str)
	return str
end

RPFlagger = {}

RPFlagger.LAM = LibStub:GetLibrary("LibAddonMenu-2.0")

RPFlagger.name = "RPFlagger"
RPFlagger.loadedAddons = {}

-- We can't rely on string.find and a pattern entirely, because we need a lazy match for
-- start and end, rather than a greedy match
function RPFlagger:GetSingleTag(text, tagName)
	-- '-' seems to have a special meaning
	local tagName = string.gsub(tagName, "-", ".")

	local start = string.find(text, "##" .. tagName .. ": ")
	if not start then return nil end
	
	local stop = string.find(text, " ##", start+1)
	if not stop then return nil end
	
	start = start + string.len(tagName) + 4
	
	return start, stop, string.sub(text, start, stop)
end

function RPFlagger:GetCharacterRPInfo(accountName, characterName, fun)
	-- Targeted an NPC
	if not accountName or accountName == "" then return nil end
	
	for i = 1, #self.guildList, 1 do
		local guildId = self.guildList[i]
		local memberIndex = GetGuildMemberIndexFromDisplayName(guildId, accountName)
		if memberIndex then
			local _, note = GetGuildMemberInfo(guildId, memberIndex)
			local rpInfoTxt = fun(characterName, note)
			if rpInfoTxt then return rpInfoTxt end
		end
	end
	return nil
end

function RPFlagger:help()	
	-- CHAT_SYSTEM:AddMessage("/im listrules - list the rules currently defined")
	-- CHAT_SYSTEM:AddMessage("/im dryrun    - show what the currently defined rules would do to your inventory")
end

function RPFlagger:SlashCommand(argv)
    local options = {}
    local searchResult = { string.match(argv,"^(%S*)%s*(.-)$") }
    for i,v in pairs(searchResult) do
        if (v ~= nil and v ~= "") then
            options[i] = string.lower(v)
        end
    end
	
	if #options == 0 or options[1] == "help" then
		self:help()
	else
		CHAT_SYSTEM:AddMessage("Unknown parameter '" .. argv .. "'")
	end
end

RPFlagger.UI = { }
RPFlagger.UI.Settings = { }

local Settings = RPFlagger.UI.Settings

function RPFlagger:InitializeUI()
	local panelData = {
		type = "panel",
		name = "RPFlagger",
		registerForRefresh = true,	--boolean (optional) (will refresh all options controls when a setting is changed and when the panel is shown)
	}	
		
	local mainPanel = {
		{
			type = "description",
			text = 
			GetString(SI_RPF_EXPLANATION1)
			.. "\n\n" .. 
			GetString(SI_RPF_EXPLANATION2)
			.. "\n\n" .. 
			GetString(SI_RPF_EXPLANATION3),
		},
		{
			type = "submenu",
			name = GetString(SI_RPF_SETTINGS),
			tooltip = GetString(SI_RPF_SETTINGS_TT),	--(optional)
			controls = Settings:GetControls(),
		},
	}
	
	self.UI.panel = self.LAM:RegisterAddonPanel("iwontsayRPFlagger", panelData)
	self.LAM:RegisterOptionControls("iwontsayRPFlagger", mainPanel)
end

function RPFlagger:Init()
	self.charDefaults = {
		["guildList"]		= { 1,2,3,4,5 }
	}
	
	self.charVariables = ZO_SavedVars:New(
		"RPFSavedVars",
		1,
		nil,
		self.charDefaults)

	self.guildList = self.charVariables.guildList

	self:InitializeUI()

	-- CHAT_SYSTEM:AddMessage(self.name .. " Addon Loaded.")
	-- CHAT_SYSTEM:AddMessage("Use /rpf help for an overview")
end

local function OnAddOnLoaded(eventCode, addonName)
	if addonName == RPFlagger.name then
		RPFlagger:Init()
	else
		RPFlagger.loadedAddons[addonName] = true
	end
end

local function OnPCCreated()
	Settings:PopulateUI()
end

EVENT_MANAGER:RegisterForEvent(RPFlagger.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)

-- SLASH_COMMANDS["/rpf"] = function(argv) RPFlagger:SlashCommand(argv) end

CALLBACK_MANAGER:RegisterCallback("LAM-PanelControlsCreated", OnPCCreated)
