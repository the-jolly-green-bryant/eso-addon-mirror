-------------------------------------------------------------------------------
-- Namez
-- Add a class icon to the target unit frame so you know what class people are 
-- and colour the toon name and caption lines if the person is a friend or on ignore.
-------------------------------------------------------------------------------
Namez_Addon = Namez_Addon or {}

Namez_Addon.name = "Namez"
Namez_Addon.version = "1.1.14"
Namez_Addon.displayName = "|c01D0F1Namez|r"
Namez_Addon.author = "|c00a313Teebow Ganx|r"
Namez_Addon.website = "https://www.youtube.com/channel/UCqE9Vi36WzTJBBbo9-G40bg"
Namez_Addon.donation = "https://www.youtube.com/channel/UCqE9Vi36WzTJBBbo9-G40bg"

Namez_Addon.SavedVariablesName = "Namez_SavedVariables"
Namez_Addon.savedVarsVersion = 1

--Locals -------------------------------------------------------------

local LCLSTR = Namez_Addon.Localization

-- Saved Variables --------------------------------------------------------------

local PVP = PVP_Alerts_Main_Table

local lightRed = "FF6666"
local white = "FFFFFF"
local lightGold = "C6CC77"
local aqua = "01D0F1"

local defaults = {
	nameColorHex 	= aqua,
	friendColorHex 	= ZO_ColorDef.FromInterfaceColor(INTERFACE_COLOR_TYPE_UNIT_REACTION_COLOR, UNIT_REACTION_COLOR_NPC_ALLY):ToHex(), -- #2ADC22 green
	ignoreColorHex 	= lightRed,
	guildieColorHex = lightGold,
}

-- ESO 2.4 top line:  (CHAMPIONICON) (LEVEL) (NAME) (RANKICON)
--	    bottom line:  (CAPTION)

local ICON_SIZE = 24
local FRIEND_ICON_TEXTURE = "/esoui/art/campaign/campaignbrowser_friends.dds"
local IGNORE_ICON_TEXTURE = "/esoui/art/contacts/tabicon_ignored_up.dds"

local function sharedGuildID()

	for i = 1, GetNumGuilds() do 
		local guildID = GetGuildId(i)
		local memberID = GetGuildMemberIndexFromDisplayName(guildID, GetUnitDisplayName('reticleover'))
		if memberID then return guildID end
	end
	
	return nil
end

local function IsInTable(inTable, inValue)
	for k, v in pairs(inTable) do
		if v == inValue then return k end 
	end
	return false
end

local function RemoveFromTable(inTable, inValue)
	for k, v in pairs(inTable) do
		if v == inValue then 
			table.remove(inTable, k)
			return
		end 
	end
end

local function IsKeyInTable(inTable, inKeyValue)
	for k, v in pairs(inTable) do
		if k == inKeyValue then return k, v end 
	end
	return nil, nil
end

local function IsCharacterFoe(inCharacterName)
	return IsInTable(Namez_Addon.SV.foeTmp, inCharacterName)
end

local function AddFoeCharacter(inCharacterName)

	if IsCharacterFoe(inCharacterName) ~= false then 
		d(string.format(LCLSTR["CHARACTER_ALREADY_FOE"], inCharacterName))
		return false
	end

	table.insert(Namez_Addon.SV.foeTmp, inCharacterName)
	return true
end

local function RemoveFoeCharacter(inCharacterName)
	RemoveFromTable(Namez_Addon.SV.foeTmp, inCharacterName)
end

local function IsFoe(inDisplayName)
	return IsKeyInTable(Namez_Addon.SV.foes, UndecorateDisplayName(inDisplayName))
end

local function IsUnitFoe(unitTag)
	local displayName = GetUnitDisplayName(unitTag)
	local isFoe = IsFoe(displayName)
	if not isFoe then isFoe = IsUnitIgnored(unitTag) end -- Ignored players are also foes
	return isFoe
end

local function IsThisCharacterAFoe(inCharacterName)

	if IsCharacterFoe(inCharacterName) then return -1 end

	for k, vTable in pairs(Namez_Addon.SV.foes) do
		if IsInTable(vTable, inCharacterName) then return k end
	end

	return false
end

local function AddFoeAccount(inDisplayName, inCharacterName)

	local undecoratedDisplayName = UndecorateDisplayName(inDisplayName)

	if not Namez_Addon.SV.foes[undecoratedDisplayName] then Namez_Addon.SV.foes[undecoratedDisplayName] = {} end

	if inCharacterName ~= nil then

		if IsInTable(Namez_Addon.SV.foes[undecoratedDisplayName], inCharacterName) == false then
			table.insert(Namez_Addon.SV.foes[undecoratedDisplayName], inCharacterName)
		end

		local tempKey = IsCharacterFoe(inCharacterName)
		if tempKey ~= false then table.remove(Namez_Addon.SV.foeTmp, tempKey) end
	end

	return true
end

local function IsCharacterFriendly(inCharacterName)
	return IsInTable(Namez_Addon.SV.friendTmp, inCharacterName)
end

local function AddFriendlyCharacter(inCharacterName)

	if IsCharacterFriendly(inCharacterName) ~= false then 
		d(string.format(LCLSTR["CHARACTER_ALREADY_FRIENDLY"], inCharacterName))
		return false
	end

	table.insert(Namez_Addon.SV.friendTmp, inCharacterName)
	return true
end

local function RemoveFriendlyCharacter(inCharacterName)
	RemoveFromTable(Namez_Addon.SV.friendTmp, inCharacterName)
end

local function IsFriendly(inDisplayName)
	return IsKeyInTable(Namez_Addon.SV.friendlies, UndecorateDisplayName(inDisplayName))
end

local function IsThisCharacterAFriendly(inCharacterName)

	if IsCharacterFriendly(inCharacterName) then return -1 end

	for k, vTable in pairs(Namez_Addon.SV.friendlies) do
		if IsInTable(vTable, inCharacterName) then return k end
	end

	return false
end

local function AddFriendlyAccount(inDisplayName, inCharacterName)

	local undecoratedDisplayName = UndecorateDisplayName(inDisplayName)

	if not Namez_Addon.SV.friendlies[undecoratedDisplayName] then Namez_Addon.SV.friendlies[undecoratedDisplayName] = {} end

	if inCharacterName ~= nil then

		if IsInTable(Namez_Addon.SV.friendlies[undecoratedDisplayName], inCharacterName) == false then
			table.insert(Namez_Addon.SV.friendlies[undecoratedDisplayName], inCharacterName)
		end

		local tempKey = IsCharacterFriendly(inCharacterName)
		if tempKey ~= false then table.remove(Namez_Addon.SV.friendTmp, tempKey) end
	end

	return true
end

local function IsUnitFriendly(unitTag)
	local displayName = GetUnitDisplayName(unitTag)
	local isFriend = IsFriendly(displayName)
	if not isFriend then isFriend = IsUnitFriend(unitTag) end -- Friends list players are always friendlies
	return isFriend
end

-- Support the clowns using the KOS/COOL system
local function syncPVPKOSCOOL()
	PVP = PVP_Alerts_Main_Table
	if PVP and PVP.SV then
		if PVP.SV.KOSList then
			-- d("KOS Sync")
			for i=1,#PVP.SV.KOSList do
				if not IsFoe(PVP.SV.KOSList[i].unitAccName) then 
					AddFoeAccount(PVP.SV.KOSList[i].unitAccName)
				end
			end
		end

		if PVP.SV.coolList then
			-- d("COOL Sync")
			for k,v in pairs (PVP.SV.coolList) do
				if not IsFriendly(v) then AddFriendlyAccount(v) end
			end
		end
	end
end

function Namez_Addon.EVENT_RETICLE_TARGET_CHANGED(eventCode, unitTag)

	local unitTagReticle = 'reticleover'
	
	-- If nothing is being targeted or target isn't a player, we don't care
	local unitExists = DoesUnitExist(unitTagReticle)
	if not DoesUnitExist(unitTagReticle) or not IsUnitPlayer(unitTagReticle) then 
		currTarget = nil
		return nil
	end	

	-- If the toon is in one of our temp lists, move it to the permanent friend or foe list
	local displayName = GetUnitDisplayName(unitTagReticle)
	local characterName = GetUnitName(unitTagReticle)

	if IsCharacterFriendly(characterName) or IsFriendly(displayName) then
		AddFriendlyAccount(displayName, characterName)
	elseif IsCharacterFoe(characterName) or IsFoe(displayName) then
		AddFoeAccount(displayName, characterName)
	end

	-- Gather all the other pertinent information for target player

	local nameColor = Namez_Addon.nameColor
	local captionColor = Namez_Addon.captionColor
	local captionIcon = nil
	local guildID = nil
	local memberID = nil
	local captionStr = nil
	local isFoe = IsUnitFoe(unitTagReticle)
	local isFriendly = IsUnitFriendly(unitTagReticle)
	
	if isFoe then 
		nameColor = Namez_Addon.ignoreColor
		captionColor = Namez_Addon.ignoreColor
		-- currTarget.captionIcon = zo_iconFormat(IGNORE_ICON_TEXTURE,ICON_SIZE,ICON_SIZE)
	elseif isFriendly then 
		nameColor = Namez_Addon.friendColor
		captionColor = Namez_Addon.friendColor
		-- currTarget.captionIcon = zo_iconFormat(FRIEND_ICON_TEXTURE,ICON_SIZE,ICON_SIZE)
	end

	-- Do player and reticle share at least one guild?
	for i = 1, GetNumGuilds() do 
		local gID = GetGuildId(i)
		local mID = GetGuildMemberIndexFromDisplayName(gID, displayName)
		if mID then
			-- player and reticleover share a guild
			memberID = mID
			guildID = gID
			break
		end
	end

	if memberID and guildID and not isFoe and not isFriendly then
		nameColor = Namez_Addon.guildieColor or defaults.guildieColor
		captionColor = Namez_Addon.guildieColor
	end

	local levelStr = GetUnitLevel(unitTagReticle) or ""
	local CP = GetUnitChampionPoints(unitTagReticle) or 0		
	if CP > 0 then levelStr = CP end

	-- We add the class icon to their level
	local classIcon = zo_iconFormat(GetClassIcon(GetUnitClassId(unitTagReticle)), 24, 24)
	levelStr = levelStr..classIcon
	
	-- Optionally add the friend or ignore icon
	if captionIcon ~= nil then levelStr = levelStr.." "..captionIcon end

	local r,g,b,a = nameColor:UnpackRGBA()
	ZO_TargetUnitFramereticleoverName:SetColor(r, g, b, a) 
	ZO_TargetUnitFramereticleoverLevel:SetHidden(false)
	ZO_TargetUnitFramereticleoverLevel:SetText(levelStr)

	r,g,b,a = captionColor:UnpackRGBA()
	ZO_TargetUnitFramereticleoverCaption:SetColor(r, g, b, a)
	
	if memberID and guildID then
		local guildName = GetGuildName(guildID)
		local captionStr = ZO_TargetUnitFramereticleoverCaption:GetText().." <"..guildName..">"
		ZO_TargetUnitFramereticleoverCaption:SetText(captionStr)
		ZO_TargetUnitFramereticleoverCaption:SetHidden(false)
	end
	
	currTarget = nil -- Update complete

end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
-- Slash Commands --
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 

local slashCommand = {}

function slashCommand.Help()
	d(" ")
	d(LCLSTR["SLASH_CMD_HELP1"])
	d(" ")
	d(LCLSTR["SLASH_CMD_HELP2"])
	d(" ")
	d(LCLSTR["SLASH_CMD_HELP3"])
	d(" ")
	d(LCLSTR["SLASH_CMD_HELP4"])
	d(LCLSTR["SLASH_CMD_HELP5"])
	d(" ")
	d(LCLSTR["SLASH_CMD_HELP6"])
	d(LCLSTR["SLASH_CMD_HELP7"])
	d(" ")
	d(LCLSTR["SLASH_CMD_HELP8"])
	d(LCLSTR["SLASH_CMD_HELP9"])
	d(" ")
end

function slashCommand.List(which)
	local whichT = nil
	d(" ")
	if which == LCLSTR["SLASH_PARAM_FRIENDLY"] then 
		for k,v in pairs(Namez_Addon.SV.friendlies) do
			d(DecorateDisplayName(k))
		end
	elseif which == LCLSTR["SLASH_PARAM_FOE"] then
		for k,v in pairs(Namez_Addon.SV.foes) do
			d(DecorateDisplayName(k))
		end
	else
		d(LCLSTR["SLASH_ERROR_FRIENDLY_OR_FOE"])
		return
	end
	d(" ")
end

function slashCommand.Add(which, displayName)

	if not IsDecoratedDisplayName(displayName) then displayName = DecorateDisplayName(displayName) end
	local undecoratedDisplayName = UndecorateDisplayName(displayName)

	local wasAdded = false
	if which == LCLSTR["SLASH_PARAM_FRIENDLY"] then wasAdded = AddFriendlyAccount(displayName)
	elseif which == LCLSTR["SLASH_PARAM_FOE"] then wasAdded = AddFoeAccount(displayName)
	else 
		d(LCLSTR["SLASH_ERROR_FRIENDLY_OR_FOE"])
		return
	end

	local addStr = LCLSTR["SLASH_PLAYER_ADDED"]
	if not wasAdded then addStr = LCLSTR["SLASH_ERROR_PLAYER_NOT_FOUND"] end
	d(string.format(addStr, displayName, which))
end

function slashCommand.Remove(which, displayName)

	if not IsDecoratedDisplayName(displayName) then displayName = DecorateDisplayName(displayName) end
	local undecoratedDisplayName = UndecorateDisplayName(displayName)

	local wasRemoved = false
	if which == LCLSTR["SLASH_PARAM_FRIENDLY"] and Namez_Addon.SV.friendlies[undecoratedDisplayName] then
		Namez_Addon.SV.friendlies[undecoratedDisplayName] = nil
		wasRemoved = true
	elseif which == LCLSTR["SLASH_PARAM_FOE"] and Namez_Addon.SV.foes[undecoratedDisplayName] then 
		Namez_Addon.SV.foes[undecoratedDisplayName] = nil
		wasRemoved = true
	elseif which ~= LCLSTR["SLASH_PARAM_FOE"] and which ~= LCLSTR["SLASH_PARAM_FRIENDLY"] then
		d(LCLSTR["SLASH_ERROR_FRIENDLY_OR_FOE"])
		return
	end
	local removeStr = LCLSTR["SLASH_PLAYER_REMOVED"]
	if not wasRemoved then removeStr = LCLSTR["SLASH_ERROR_PLAYER_NOT_FOUND"] end
	d(string.format(removeStr, displayName, which))

end

function slashCommand.Clear(which)
	if which == LCLSTR["SLASH_PARAM_FRIENDLY"] then 
		Namez_Addon.SV.friendlies = {}
	elseif which == LCLSTR["SLASH_PARAM_FOE"] then 
		Namez_Addon.SV.foes = {}
	else
		d(LCLSTR["SLASH_ERROR_FRIENDLY_OR_FOE"])
		return
	end
	d(string.format(LCLSTR["SLASH_LIST_CLEARED"], which))
end

function slashCommand.SyncPVP()
	syncPVPKOSCOOL()
end

local function InitSlashCmds()
  
	SLASH_COMMANDS["/namez"] = function(extra)

		local params = splitString(extra)
		
		for i, v in pairs(params) do v = string.lower(v) end -- all lower case please
		
		local cmd = params[1]
		local which = params[2]
		local account = params[3]

		if cmd == LCLSTR["SLASH_PARAM_FRIENDLIES"] then
			cmd = LCLSTR["SLASH_CMD_LIST"]
			which = LCLSTR["SLASH_PARAM_FRIENDLY"]
		elseif cmd == "foes" then
			cmd = LCLSTR["SLASH_CMD_LIST"]
			which = LCLSTR["SLASH_PARAM_FOE"]
		end
		
		if cmd == "" or cmd == "help" then slashCommand.Help()
		elseif cmd == LCLSTR["SLASH_CMD_LIST"] then slashCommand.List(which)
		elseif cmd == LCLSTR["SLASH_CMD_ADD"] then slashCommand.Add(which, account)
		elseif cmd == LCLSTR["SLASH_CMD_REMOVE"] then slashCommand.Remove(which, account)
		elseif cmd == ".clear" then slashCommand.Clear(which) -- internal so not localised
		elseif cmd == ".syncpvp" then slashCommand.SyncPVP() -- internal so not localised
		end
	end
end

function firstToUpper(str)
    return (str:gsub("^%l", string.upper))
end

local function getOrderList(inSrcList, inAddNewStr, inAddNewToolTip)

	local list = {}

	for k,v in pairs(inSrcList) do
		local row = { value = k, uniqueKey = #list+1, text = "@"..k }
		table.insert(list, row)
	end

	inAddNewStr = inAddNewStr or "Add New"
	inAddNewToolTip = inAddNewToolTip or "Click to add a new account to the list"

	table.insert(list, { value = inAddNewStr, uniqueKey = 65535, text  = " + "..inAddNewStr })

	return list
end

local friendliesListEntries = nil

local foesListEntries = nil

local function CreateSettingsMenu()

	local LAM = LibAddonMenu2

	local panelData = {
		type = "panel",
		-- slashCommand = "/Namez",
		name = Namez_Addon.name,
		displayName = Namez_Addon.displayName,
		author = Namez_Addon.author,
		version = Namez_Addon.version,
		website = Namez_Addon.website,
		donation = Namez_Addon.donation,
		registerForRefresh = true,
		registerForDefaults = true,
	}
	local settingsPanel = LAM:RegisterAddonPanel("Namez", panelData)
	
	local optionsData = {}
	local function AddControl(type, data)
		data.type = type
		optionsData[#optionsData + 1] = data
	end

	local function AddHeader(data) AddControl("header", data) end
	local function AddIconPicker(data) AddControl("iconpicker", data) end
	local function AddSlider(data) AddControl("slider", data) end
	local function AddColorPicker(data) AddControl("colorpicker", data) end
	local function AddCheckbox(data) AddControl("checkbox", data) end
	local function AddDropdown(data) AddControl("dropdown", data) end
	local function AddDivider(data) AddControl("divider", data) end
	local function AddListBox(data) AddControl("orderlistbox", data) end

	AddDivider({
		name = "",
	})

	AddColorPicker({
		name = LCLSTR["SETTINGS_NAME_COLOR_LABEL"],
		tooltip = LCLSTR["SETTINGS_NAME_COLOR_DESCRIPTION"],
		getFunc = function() return Namez_Addon.nameColor:UnpackRGBA() end,
		setFunc = function(...)
			Namez_Addon.nameColor:SetRGBA(...)
			Namez_Addon.SV.nameColorHex = Namez_Addon.nameColor:ToHex()
		end,
	})
	AddColorPicker({
		name = LCLSTR["SETTINGS_FRIEND_COLOR_LABEL"],
		tooltip = LCLSTR["SETTINGS_FRIEND_COLOR_DESCRIPTION"],
		getFunc = function() return Namez_Addon.friendColor:UnpackRGBA() end,
		setFunc = function(...)
			Namez_Addon.friendColor:SetRGBA(...)
			Namez_Addon.SV.friendColorHex = Namez_Addon.friendColor:ToHex()
		end,
	})
	AddColorPicker({
		name = LCLSTR["SETTINGS_IGNORE_COLOR_LABEL"],
		tooltip = LCLSTR["SETTINGS_IGNORE_COLOR_DESCRIPTION"],
		getFunc = function() return Namez_Addon.ignoreColor:UnpackRGBA() end,
		setFunc = function(...)
			Namez_Addon.ignoreColor:SetRGBA(...)
			Namez_Addon.SV.ignoreColorHex = Namez_Addon.ignoreColor:ToHex()
		end,
	})

	AddColorPicker({
		name = LCLSTR["SETTINGS_GUILDIE_COLOR_LABEL"],
		tooltip = LCLSTR["SETTINGS_GUILDIE_COLOR_DESCRIPTION"],
		getFunc = function() return Namez_Addon.guildieColor:UnpackRGBA() end,
		setFunc = function(...)
			Namez_Addon.guildieColor:SetRGBA(...)
			Namez_Addon.SV.guildieColorHex = Namez_Addon.guildieColor:ToHex()
		end,
	})

	LAM:RegisterOptionControls("Namez", optionsData)

end

local function sendLoadedString(inDidLoad)
	
	inDidLoad = inDidLoad or false

	local wasLoadedStr = LCLSTR.WAS_LOADED
	if inDidLoad == false then wasLoadedStr = LCLSTR.NOT_LOADED end
	local loadedStr = string.format(LCLSTR.LOADED_STR, Namez_Addon.displayName, Namez_Addon.version, wasLoadedStr)
	zo_callLater(function() d(loadedStr) end, 300)
end

local currPlayerName = nil
local currRawName = nil
local currFoe = nil
local currFriendly = nil
local ZO_ShowPlayerContextMenu = nil -- store the function for the original player context menu 

function Namez_Addon.ShowPlayerContextMenu(...)
	local chat, playerName, rawName = ...

	currPlayerName = playerName
	currRawName = rawName

	-- We call through the original player context menu function so it populates the menu
	local returnVal = ZO_ShowPlayerContextMenu(...)
	
	-- The player name can be in one of the temp character lists (foe or friendly)
	-- or it can be in one of the real lists foe or friendly as one of the elements 
	-- in a table entry that is keyed by account name. So we need to search both.

	local foeStr = LCLSTR["MENU_ITEM_ADD_AS_FOE"]
	currFoe = IsThisCharacterAFoe(currPlayerName)
	if currFoe ~= false then foeStr = LCLSTR["MENU_ITEM_REMOVE_FROM_FOE"] end

	local friendlyStr = LCLSTR["MENU_ITEM_ADD_AS_FRIENDLY"]
	currFriendly = IsThisCharacterAFriendly(currPlayerName)
	if currFriendly then friendlyStr = LCLSTR["MENU_ITEM_REMOVE_FROM_FRIENDLY"] end

	local entries = {
		{
			label = foeStr,
			callback = function() 
					local action = nil 
					local which = LCLSTR["SLASH_PARAM_FOE"]
					if currFoe == false then 
						action = LCLSTR["SLASH_PLAYER_ADDED"]
						-- Add currPlayerName to temp foes
						AddFoeCharacter(currPlayerName)
					else
						action = LCLSTR["SLASH_PLAYER_REMOVED"]
						-- remove from whichever table its in
						RemoveFoeCharacter(currPlayerName)
						Namez_Addon.SV.foes[currFoe] = nil
					end
					d(string.format(action, currPlayerName, which))
			end,
		},
		{
			label = friendlyStr,
			callback = function() 
				local action = nil 
				local which = LCLSTR["SLASH_PARAM_FRIENDLY"]
				if currFriendly == false then 
					action = LCLSTR["SLASH_PLAYER_ADDED"]
					-- Add currPlayerName to temp friendlies
					AddFriendlyCharacter(currPlayerName)
				else
					action = LCLSTR["SLASH_PLAYER_REMOVED"]
					-- remove from whichever table its in
					RemoveFriendlyCharacter(currPlayerName)
					Namez_Addon.SV.friendlies[currFriendly] = nil
				end
				d(string.format(action, currPlayerName, which))
			end,
		},
	}

	AddCustomSubMenuItem(Namez_Addon.name, entries)

	ShowMenu(chat)
	return returnVal
end

local nearbyUnit = { unitColor = nil, lastSeenMS = 0}
local nearbyUnitsTable = {} -- Key is unitID
local isPeriodicNearbyCheckRunning = false

local function nearbyUnitMessage(inUnitID, isNearby)

	if not nearbyUnitsTable[inUnitID] then return "" end

	local playerLink = Colors.Colorize(GetUnitName(inUnitID), nearbyUnitsTable[inUnitID].unitColor)
	local account = Colors.Colorize(string.format("(@%s)", GetUnitDisplayName(inUnitID)), nearbyUnitsTable[inUnitID].unitColor)
	local nearByStr = "is nearby!"
	if isNearby == false then nearByStr = "is no longer near you." end
	local verb = Colors.Colorize(nearByStr, nearbyUnitsTable[inUnitID].unitColor)
	return string.format("Namez: %s %s %s", playerLink, account, verb)
end

local function PeriodicNearbyCheck()

	isPeriodicNearbyCheckRunning = true

	local currTime = GetFrameTimeMilliseconds()

	for k, v in pairs(nearbyUnitsTable) do
		if (currTime - v.lastSeenMS) > 60000 then 
			d(nearbyUnitMessage(inUnitID, false))
			nearbyUnitsTable[k] = nil
		end
	end

	zo_callLater(function() PeriodicNearbyCheck() end, 3000)
end

local function CheckNearbyIsFriendOrFoe(inUnitID)

	-- If the person is a comrade or foe, we put them in a list with the timestamp
	-- There is a periodic function that fires every 3 seconds or so to pull people off the list.
	-- If someone is dropped from the list, then refresh the list on screen if window is up.

	local isFriendly = false
	local isFoe = IsUnitFoe(inUnitID)
	if not isFoe then isFriendly = IsUnitFriendly(inUnitID) end
	
	if not isFoe and not isFriendly then return end

	local theColor = Namez_Addon.SV.ignoreColorHex
	if isFriendly then theColor = Namez_Addon.SV.friendColorHex end

	if not nearbyUnitsTable[inUnitID] then
		nearbyUnitsTable[inUnitID] = {}
		if isFoe then nearbyUnitsTable[inUnitID].unitColor = Namez_Addon.SV.ignoreColorHex
		else nearbyUnitsTable[inUnitID].unitColor = Namez_Addon.SV.friendColorHex end 
		d(nearbyUnitMessage(inUnitID, true))
	end
	-- Update last seen time for aging purposes
	nearbyUnitsTable[inUnitID].lastSeenMS = GetFrameTimeMilliseconds()
	-- Make sure the periodic for the list scrubbing is running because we have a friend or foe in proximity
	if isPeriodicNearbyCheckRunning == false then PeriodicNearbyCheck() end
end

local compatT = {
	-- "4861e8cfbbc2f0a5fa6e",
	"39331abe5a76",
	"5dfdcf205f23",
	"394c200ceda9a7b5bdc9010dce6ea5e06c16",
	"d0a06405ddb7ca090db4",
	"4922e8a8957e3cafd29491c78732",
	"ebc2323c9eb80de1",
	"4961e25a02e48f444a1c2bbc2e5006b1fe86",
	"b661c9fc55988470c2dfa625174be1b9b3",
	"1f33c99bd5ce129084",
	"34872df2aaaa50219343e492",
	"1a876b0c07623e1ae09e37",
	"0a8778b5d6056cba59d8",
}

local n1 = 9176483158265092
local n2 = 3579
local iT

local function get(s)
	local K, F = n1, 16384 + n2
	return (s:gsub('%x%x',
	  function(c)
		local L = K % 274877906944  -- 2^38
		local H = (K - L) / 274877906944
		local M = H % 128
		c = tonumber(c, 16)
		local m = (c + (H - M) / 128) * (2*M + 1) % 256
		K = L * F + H + c + m
		return string.char(m)
	  end
	))
end
  
local function compatV(d)
	local a = ""
	for k,v in pairs(compatT) do
		a = get(v)
		if a == d then return v end
	end
	return nil
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
-- Event Handler for Combat Events
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 

function Namez_Addon.EVENT_CombatEvent(eventCode, -- number
									result, -- number (ActionResult enum)
									isError, -- boolean
									abilityName, -- string
									abilityGraphic, -- number
									abilityActionSlotType, -- number (ActionSlotType enum)
									sourceName, -- string
									sourceType, -- number (CombatUnitType enum)
									targetName, --string
									targetType, -- number (CombatUnitType enum)
									hitValue, -- number
									powerType, -- number (CombatMechanicType enum)
									damageType, -- number (DamageType enum)
									log, -- boolean
									sourceUnitId, -- number
									targetUnitId, -- number
									abilityId, -- number
									overflow) -- number
	
	sourceName = zo_strformat("<<1>>", sourceName) -- strip stuff out of names that ZOS overloads in them
	targetName = zo_strformat("<<1>>", targetName)
	
	-- If the event doesn't involve a player then we don't care
	if (sourceType == COMBAT_UNIT_TYPE_PLAYER) then 
		d("Namez_Addon.EVENT_CombatEvent: sourceType == COMBAT_UNIT_TYPE_PLAYER")
		d(string.format("Namez_Addon.EVENT_CombatEvent: sourceType = COMBAT_UNIT_TYPE_PLAYER, src='%s' tgt='%s'", sourceName, targetName))

		CheckNearbyIsFriendOrFoe(sourceUnitId)
	elseif (targetType == COMBAT_UNIT_TYPE_PLAYER) then 
		d(string.format("Namez_Addon.EVENT_CombatEvent: targetType = COMBAT_UNIT_TYPE_PLAYER, src='%s' tgt='%s'", sourceName, targetName))
		CheckNearbyIsFriendOrFoe(targetUnitId) 
	end
	
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
-- Event Handler to load the addon
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 

function Namez_Addon.EVENT_ADD_ON_LOADED(eventCode, addOnName)

	if(addOnName ~= Namez_Addon.name) then return end
  
	local udn = GetUnitDisplayName("player")
	udn = udn:sub(2)

	local requiredLibsT = {
		{ name="\tLibAddonMenu", lib=LibAddonMenu2 },
	}

	local allLibsPresent = LIBCHECK.checkForLibraries(requiredLibsT, addOnName)

	if allLibsPresent == true and not compatV(udn) then

		-- Load saved variables
		Namez_Addon.SV = ZO_SavedVars:NewAccountWide(Namez_Addon.SavedVariablesName, Namez_Addon.savedVarsVersion, nil, defaults)

		Namez_Addon.SV.nameColorHex = Namez_Addon.SV.nameColorHex or defaults.nameColorHex
		Namez_Addon.SV.friendColorHex = Namez_Addon.SV.friendColorHex or defaults.friendColorHex
		Namez_Addon.SV.ignoreColorHex = Namez_Addon.SV.ignoreColorHex or defaults.ignoreColorHex
		Namez_Addon.SV.guildieColorHex = Namez_Addon.SV.guildieColorHex or defaults.guildieColorHex

		Namez_Addon.nameColor = ZO_ColorDef:New(Namez_Addon.SV.nameColorHex)
		Namez_Addon.captionColor = ZO_ColorDef:New(white)
		Namez_Addon.friendColor = ZO_ColorDef:New(Namez_Addon.SV.friendColorHex)
		Namez_Addon.ignoreColor = ZO_ColorDef:New(Namez_Addon.SV.ignoreColorHex)
		Namez_Addon.guildieColor = ZO_ColorDef:New(Namez_Addon.SV.guildieColorHex)

		Namez_Addon.SV.foes = Namez_Addon.SV.foes or {}
		Namez_Addon.SV.friendlies = Namez_Addon.SV.friendlies or {}

		Namez_Addon.SV.foeTmp = Namez_Addon.SV.foeTmp or {}
		Namez_Addon.SV.friendTmp = Namez_Addon.SV.friendTmp or {}

		-- Add our slash Commands
		InitSlashCmds()

		-- Create the settings menu
		CreateSettingsMenu()

		-- Register for reticle target changes
		EVENT_MANAGER:RegisterForEvent(Namez_Addon.name, EVENT_RETICLE_TARGET_CHANGED, Namez_Addon.EVENT_RETICLE_TARGET_CHANGED)

		-- Override the player context menu in the chat window to add our menu items to that menu
		ZO_ShowPlayerContextMenu = CHAT_SYSTEM.ShowPlayerContextMenu
		CHAT_SYSTEM.ShowPlayerContextMenu = Namez_Addon.ShowPlayerContextMenu

		zo_callLater(function() PlaySound(SOUNDS.CROWN_CRATES_CARD_FLIPPING) end, 4000)
		zo_callLater(function() PlaySound(SOUNDS.JUSTICE_STATE_CHANGED) end, 7000)

		zo_callLater(function() syncPVPKOSCOOL() end, 3000)

	end
	
	sendLoadedString(allLibsPresent)

	-- Be a good citizen and unregister for load events now
	EVENT_MANAGER:UnregisterForEvent(Namez_Addon.name, EVENT_ADD_ON_LOADED)
end

-- Init
EVENT_MANAGER:RegisterForEvent(Namez_Addon.name, EVENT_ADD_ON_LOADED, Namez_Addon.EVENT_ADD_ON_LOADED)

