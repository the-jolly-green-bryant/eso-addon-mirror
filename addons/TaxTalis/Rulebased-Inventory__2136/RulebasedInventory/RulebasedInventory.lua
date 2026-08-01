-----------------------------------------------------------------------------------
-- Addon Name: Rulebased Inventory
-- Creator: TaxTalis
-- Addon Ideal: user-defined rule-based actions for inventory application
-- Addon Creation Date: September 11, 2018
--
-- File Name: RulebasedInventory.lua
-- File Description: This file contains the main definition of RulebasedInventory (RbI)
-- Load Order Requirements: First
-- 
-----------------------------------------------------------------------------------
RulebasedInventory = {
	class = {},
	extensions = {},
}
local RbI = RulebasedInventory
RbI.startTime = GetGameTimeMilliseconds()

-- MAJOR.MINOR.PATCH
-- MAJOR version when user updating is loosing settings or ruledefinitions getting unsound or a major rewrite has taken place,
-- MINOR version when functionality in a backwards-compatible manner is modified, and
-- PATCH version when backwards-compatible bug fixes were made

RbI.name = "RulebasedInventory"
RbI.title = "Rulebased Inventory"
RbI.author = "TaxTalis, demawi, otac0n"
RbI.savedVariableVersion = 2 -- for characters saves
RbI.savedGlobalVariableVersion = 2  -- account-wide save
RbI.addonVersion = "2.32"
RbI.website = 'https://www.esoui.com/downloads/fileinfo.php?id=2136'
RbI.websiteComments = 'https://www.esoui.com/downloads/fileinfo.php?id=2136#comments'
RbI.wikiLink = 'https://gitlab.com/taxtalis/rulebased-inventory/-/wikis/Home'
RbI.discord = 'https://discord.gg/Y68mA3fkky'

RbI.testrun = false  -- Menu+Task
RbI.allowAction = {
	StartMessage = true,
	FinalMessage = true,
	ActionMessage = true,
	SummaryMessage = true
} -- ActionQueue+Event+Task

RbI.CONTEXT_MENU_ENTRY = "RbI: Inspect Item"
RbI.FIT_ALL = 1
RbI.FIT_ANY = 2

RbI.NaN = 0/0 -- the only value with: (value < 0 or value >= 0) == false, so we should return this value, when a number is not available
RbI.isNaN = function(value)
	return type(value) == "number" and value ~= value
end
RbI.equals = function(value1, value2)
	if(RbI.isNaN(value1) and RbI.isNaN(value2)) then return true end
	return value1 == value2
end

function RbI.Import(data)
	if(data == nil) then
		error("Data isn't ready for import yet")
	end
	return data
end
-- from FCOIS_API: Is the gamepad mode enabled in the game:
-- We are in gamepad mode so check if the addon Advanced Disable Controller UI is enabled
-- and the setting to use the gamepad mode in this addon is OFF
-- fcoisControllerUICheck == true: FCOIS will work properly. You can use the API functions now
-- fcoisControllerUICheck == false: FCOIS won't work properly! Do NOT call any API functions and abort here now
function RbI.FcoisControllerUICheck()
	return (FCOIS == nil or IsInGamepadPreferredMode() == false or FCOIS.CheckIfADCUIAndIsNotUsingGamepadMode())
end

function RbI.RenameRule(from, to)
	RbI.ruleEnvironment.RenameUserRule(from, to)

	-- update persistence refererences
	RbI.RuleSet.RenameRuleReferences(from, to)
	RbI.Profile.RenameRuleReferences(from, to)
	for _, charSetting in pairs(RbI.class.CharacterSetting.GetAll()) do
		charSetting.RenameRule(from, to)
	end
end

function RbI.RenameTask(from, to)
	for _, characterSetting in pairs(RbI.characters) do
		local raw = characterSetting.GetRaw()
		if(raw.profile[from]) then
			raw.profile[to] = raw.profile[from]
			raw.profile[from] = nil
		end
	end
	for _, profile in pairs(RbI.account.profiles) do
		if(profile[from]) then
			profile[to] = profile[from]
			profile[from] = nil
		end
	end
end

-- rename (or delete)
-- safe copy only when exists, so when calling twice it stays fine
function RbI.rename(table, from, to)
	if (from == to) then return end
	local data = table[from]
	if (data ~= nil) then
		if (to ~= nil) then
			table[to] = data
		end
		table[from] = nil
	end
end

local inits = {}
function RbI.addInitialize(fn) inits[#inits+1] = fn end
EVENT_MANAGER:RegisterForEvent(RbI.name, EVENT_ADD_ON_LOADED, function(event, addonName)
	if addonName == RbI.name then
		RbI.account = RbI.class.AccountSetting.Load().GetRaw()
		local thisCharacterSetting, allCharactersSettings = RbI.class.CharacterSetting.LoadAll()
		RbI.character = thisCharacterSetting.GetRaw()
		RbI.characters = allCharactersSettings

		for _, fn in pairs(inits) do fn() end inits = nil RbI.addInitialize = nil

		RbI.tasks.Initialize()

		RbI.precompileAll()

		RbI.Profile = RbI.Profile().Initialize(RbI.character, RbI.account.profiles)
		RbI.RuleSet = RbI.RuleSet().Initialize(RbI.character.profile, RbI.account.ruleSets)
		RbI.RuleSet.Validate()
		RbI.Profile.Load(RbI.Profile.GetCurrentProfileName())
		RbI.extensions.LoadProvider()

		RbI.menu.Initialize()
		RbI.InitializeContextMenu()
		RbI.InitializeOutput()

		RbI.extensions.InitializeMasterWritHandling()
		RbI.RegisterForEvents()
	end
end)

function RbI.precompileConstant(name, content)
	if(RbI.account.settings.casesensitiverules == false) then
		content = string.lower(content)
	end
	local compiledFunc, err = zo_loadstring('return {' .. content..'}')
	if(err) then
		return function()
			local errorTable = {
				message = "The constant: '"..name.."' has a syntax error!",
				ruleContent = content,
				addition = err,
			}
			error(errorTable)
		end, err
	end
	return compiledFunc()
end
function RbI.precompileAll()
	-- precompile/load constants
	local constants = {}
	RbI.constants = constants
	for name, definition in pairs(RbI.account.constants) do
		constants[name:lower()] = RbI.precompileConstant(name, definition.content)
	end

	-- precompile/load rules
	RbI.rules.user = {}
	for name, content in pairs(RbI.account.rules) do
		if (RbI.rules.user[name:lower()]) then
			error("Because of the internal lowercase rule references, we found at least two rules with the same name: '" .. name:lower() .. "'. Please log out and rename them in the RulebasedInventory.lua-savefile.")
		end
		RbI.PersistentRule(name, content)
	end
end

if(FCOIS) then
	RbI.fcois = {
		getNameByNr = function(iconNr)
			return FCOIS.GetIconText(iconNr) or FCOIS.localizationVars.fcois_loc["options_icon" .. tostring(iconNr) .. "_" .. FCOIS.localizationVars.iconEndStrArray[iconNr]]
		end,
		getNameById = function(iconId)
			return RbI.fcois.getNameByNr(RbI.dataTypeStatic["fcoisMark"][iconId])
		end,
		getNrById = function(iconId)
			return RbI.dataType["fcoisMark"][iconId]
		end,
		getIdByNr = function(iconNr)
			return RbI.dataTypeStatic["fcoisMarkIds"][iconNr]
		end
	}
end

-- Returns unified language independent name (de/fr capitalize the first character within GetUnitName or SI_UNIT_NAME formatting, en does not)
RbI.GetUnitName = function(tag)
	return zo_strformat("<<C:1>>", GetUnitName(tag))
end
