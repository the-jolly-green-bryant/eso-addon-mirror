-- For tracking character name slots.
local charCount = 0
local RPV_StringLookup = {} -- A hack to localize incoming strings from the data file.

RPProfileViewer = {
	Name = "RPProfileViewer",
	Title = "RP Profile Viewer",
	Author = "TheBobbyLlama",
	Version = "1.0",
	hacks = {
		callbackName = "RPProfileViewer.ContextMenuHack",
		callbackInterval = 500
	}
}

-- Sorted iterator function from https://www.lua.org/pil/19.3.html
local function pairsByKeys (t, f)
	local a = {}
	for n in pairs(t) do table.insert(a, n) end
	table.sort(a, f)
	local i = 0      -- iterator variable
	local iter = function ()   -- iterator function
		i = i + 1
		if a[i] == nil then return nil
		else return a[i], t[a[i]]
		end
	end
	return iter
end

-- Converts a character name to a key by converting to lowercase and stripping out non-alphanumeric characters.
local function ConvertNameToKey(name)
	if ((name == nil) or (string.sub(name, 1, 1) == "@")) then
		return ""
	end
	
	local result = string.lower(name)
	result = string.gsub(result, "[^%dA-Za-z]", "")
	return result
end

-- Check if a character is registered to be shown in the profile window, and add them if they're eligible.
local function CheckCharacterRegistered(name)
	local characterData = RPProfileViewer.ProfileData[ConvertNameToKey(name)]
	
	if (characterData ~= nil) then
		if (characterData["name"] == nil) then
			characterData["name"] = name
		end
		return true
	else
		return false
	end
end

-- These values come from the DB as localization tokens, but I can't feed them directly into GetString.  RPV_StringLookup cheats it.
local function InitializeLocalizationHack()
	RPV_StringLookup["ALIGNMENT_LG"] = GetString(RPV_ALIGNMENT_LG);
	RPV_StringLookup["ALIGNMENT_NG"] = GetString(RPV_ALIGNMENT_NG);
	RPV_StringLookup["ALIGNMENT_CG"] = GetString(RPV_ALIGNMENT_CG);
	RPV_StringLookup["ALIGNMENT_LN"] = GetString(RPV_ALIGNMENT_LN);
	RPV_StringLookup["ALIGNMENT_N"] = GetString(RPV_ALIGNMENT_N);
	RPV_StringLookup["ALIGNMENT_CN"] = GetString(RPV_ALIGNMENT_CN);
	RPV_StringLookup["ALIGNMENT_LE"] = GetString(RPV_ALIGNMENT_LE);
	RPV_StringLookup["ALIGNMENT_NE"] = GetString(RPV_ALIGNMENT_NE);
	RPV_StringLookup["ALIGNMENT_CE"] = GetString(RPV_ALIGNMENT_CE);
	
	RPV_StringLookup["BIRTHSIGN_APPRENTICE"] = GetString(RPV_BIRTHSIGN_APPRENTICE);
	RPV_StringLookup["BIRTHSIGN_ATRONACH"] = GetString(RPV_BIRTHSIGN_ATRONACH);
	RPV_StringLookup["BIRTHSIGN_LADY"] = GetString(RPV_BIRTHSIGN_LADY);
	RPV_StringLookup["BIRTHSIGN_LORD"] = GetString(RPV_BIRTHSIGN_LORD);
	RPV_StringLookup["BIRTHSIGN_LOVER"] = GetString(RPV_BIRTHSIGN_LOVER);
	RPV_StringLookup["BIRTHSIGN_MAGE"] = GetString(RPV_BIRTHSIGN_MAGE);
	RPV_StringLookup["BIRTHSIGN_RITUAL"] = GetString(RPV_BIRTHSIGN_RITUAL);
	RPV_StringLookup["BIRTHSIGN_SERPENT"] = GetString(RPV_BIRTHSIGN_SERPENT);
	RPV_StringLookup["BIRTHSIGN_SHADOW"] = GetString(RPV_BIRTHSIGN_SHADOW);
	RPV_StringLookup["BIRTHSIGN_STEED"] = GetString(RPV_BIRTHSIGN_STEED);
	RPV_StringLookup["BIRTHSIGN_THIEF"] = GetString(RPV_BIRTHSIGN_THIEF);
	RPV_StringLookup["BIRTHSIGN_TOWER"] = GetString(RPV_BIRTHSIGN_TOWER);
	RPV_StringLookup["BIRTHSIGN_WARRIOR"] = GetString(RPV_BIRTHSIGN_WARRIOR);
end

-- Use our cheaty lookup to localize those pesky strings.
local function LocalizationHack(input)
	local result = RPV_StringLookup[input]
	
	if (result == nil) then
		return ""
	else
		return result
	end
end

-- Handler for the slash command/hotkey.  Defaults to showing local player, if applicable.
function RPProfileViewer.DispatchToggleWindow()
	local myName = GetUnitName("player")
	local profileWindow = GetControl("RPProfileWindow")

	if ((profileWindow:IsHidden()) and (CheckCharacterRegistered(myName))) then
		RPProfileViewer.ToggleWindow(myName)
	else
		RPProfileViewer.ToggleWindow()
	end
end

-- Shows the profile window, or hides it.  Shows the given character name if specified.
function RPProfileViewer.ToggleWindow(charName)
	local profileWindow = GetControl("RPProfileWindow")
	
	if (((charName ~= nil) and (charName ~= "")) or profileWindow:IsHidden() ) then
		local curCount = 0
		local charList = GetControl("RPProfileWindowCharacterListScrollChild")
		
		for k,v in pairsByKeys(RPProfileViewer.ProfileData) do
			local fullName = v["name"] -- Characters who we have names for are the ones we've seen, this will determine whether their profile is available.

			if (fullName ~= nil) then
				curCount = curCount + 1
				
				if (curCount > charCount) then
					local makeMe = CreateControlFromVirtual("Character", charList, "CharacterNameTemplate", curCount)
					local offset = 30 * charCount + 4
					makeMe:GetNamedChild("Text"):SetText(fullName)
					makeMe:SetAnchor(TOPLEFT, charList , TOPLEFT, 0, offset)
					makeMe:SetAnchor(TOPRIGHT, charList , TOPRIGHT, 0, offset)
					makeMe:GetNamedChild("Text"):SetHandler("OnClicked", function()  RPProfileViewer.ShowCharacterInfo(fullName) end )
					charCount = charCount + 1
				else
					local curControl = GetControl("Character"..curCount):GetNamedChild("Text")
					curControl:SetText(fullName)
					curControl:SetHandler("OnClicked", function()  RPProfileViewer.ShowCharacterInfo(fullName) end )
				end
			end
		end

		charCount = curCount
		
		RPProfileViewer.ShowCharacterInfo(charName)
		
        profileWindow:SetHidden(false)
		SetGameCameraUIMode(true) -- Show mouse pointer
	else
		profileWindow:SetHidden(true)
    end
end

-- Yep, it's ugly.  Forces the character panel's scroll area to match the items that are in it (trying to put them under the ScrollChild caused problems)
local function HACKScrolling(panel)
	zo_callLater(function ()
		local scrollChild = GetControl(panel .. "ScrollChild")
		local controlHolder = GetControl(panel .. "X")
		local width, height = controlHolder:GetDimensions()
		
		scrollChild:SetResizeToFitDescendents(false)
		scrollChild:SetDimensions(width, height)
	end, 10)
end

-- Helper function for sizing text fields.
local function estimateFieldSize(text, lineLength, scale)
	local linebreaks = 0
	local result = #text
	
	for w in string.gmatch(text, "\n") do
		linebreaks = linebreaks + 1
    end
	
	result = (result - linebreaks) / lineLength + linebreaks
	return scale * math.ceil(result)
end

-- Helper function for filling characteristic fields.
local function SetCharacteristicField(fieldValue, fieldId, characteristicCount, lineLength)
	local curControl = GetControl(fieldId)
	
	if ((fieldValue ~= nil) and (fieldValue ~= "")) then
		local lineCount
		curControl:SetHidden(false)
		curControl:ClearAnchors()
		lineCount = estimateFieldSize(fieldValue, lineLength, 1)
		curControl:SetAnchor(TOPLEFT, GetControl("RPProfileWindowCharacterPanelXCharacteristicsPicture"), TOPRIGHT, 8, 28 * characteristicCount)
		curControl:SetAnchor(TOPRIGHT, curControl:GetParent(), TOPRIGHT, 16, 8 + 28 * characteristicCount)
		curControl:GetNamedChild("Text"):SetText(fieldValue)
		curControl:SetDimensions(nil, 8 + 24 * lineCount)
		curControl:GetNamedChild("Text"):SetDimensions(nil, 8 + 24 * lineCount)
		return lineCount
	else
		curControl:SetHidden(true)
	end
	
	return 0
end

-- Fills in the profile window with a character's information.
function RPProfileViewer.ShowCharacterInfo(character)
	local tmpValue
	local curControl = GetControl("RPProfileWindowCharacterPanel") -- This variable will be reused a lot.
	local characterKey = ConvertNameToKey(character)
	local characterData = RPProfileViewer.ProfileData[characterKey]
	local characteristicCount = 0
	
	if (characterData ~= nil) then
		local imageFactor = 0
		curControl:SetHidden(false)
		ZO_Scroll_ResetToTop(curControl)
		-- Character name
		curControl = GetControl("RPProfileWindowCharacterPanelXCharacterName")
		curControl:SetText(characterData["name"])
		-- Image
		if (characterData["image"] ~= nil) then
			local imageControl = GetControl("RPProfileWindowCharacterPanelXCharacteristicsPicture")
			imageFactor = 1
			imageControl:SetTexture(string.format("RPProfileViewer/images/thumbs/%s/%s.dds", characterKey, characterData["image"]))
			imageControl:SetDimensions(200, 200)
		else
			local imageControl = GetControl("RPProfileWindowCharacterPanelXCharacteristicsPicture")
			imageFactor = 0
			imageControl:SetTexture("")
			imageControl:SetDimensions(0, 0)
		end
		-- Characteristics
		characteristicCount = characteristicCount + SetCharacteristicField(characterData["aliases"], "RPProfileWindowCharacterPanelXCharacteristicsAliasHolder", characteristicCount, 87 - 24 * imageFactor)
		characteristicCount = characteristicCount + SetCharacteristicField(LocalizationHack(characterData["alignment"]), "RPProfileWindowCharacterPanelXCharacteristicsAlignmentHolder", characteristicCount, 85 - 24 * imageFactor)
		characteristicCount = characteristicCount + SetCharacteristicField(LocalizationHack(characterData["birthsign"]), "RPProfileWindowCharacterPanelXCharacteristicsBirthsignHolder", characteristicCount, 85 - 24 * imageFactor)
		characteristicCount = characteristicCount + SetCharacteristicField(characterData["residence"], "RPProfileWindowCharacterPanelXCharacteristicsResidenceHolder", characteristicCount, 85 - 24 * imageFactor)
		characteristicCount = characteristicCount + SetCharacteristicField(characterData["organizations"], "RPProfileWindowCharacterPanelXCharacteristicsOrganizationHolder", characteristicCount, 81 - 24 * imageFactor)
		characteristicCount = characteristicCount + SetCharacteristicField(characterData["alliances"], "RPProfileWindowCharacterPanelXCharacteristicsAllianceHolder", characteristicCount, 85 - 24 * imageFactor)
		characteristicCount = characteristicCount + SetCharacteristicField(characterData["enemies"], "RPProfileWindowCharacterPanelXCharacteristicsEnemyHolder", characteristicCount, 87 - 24 * imageFactor)
		characteristicCount = characteristicCount + SetCharacteristicField(characterData["relationships"], "RPProfileWindowCharacterPanelXCharacteristicsRelationshipHolder", characteristicCount, 81 - 24 * imageFactor)
		curControl = GetControl("RPProfileWindowCharacterPanelXCharacteristics")
		if ((characteristicCount > 0) or (imageFactor > 0)) then
			local sizeMe = math.max(28 * characteristicCount, 200 * imageFactor)
			curControl:SetDimensions(nil, 16 + sizeMe)
		else
			curControl:SetDimensions(nil, 0)
		end
		-- Description
		tmpValue = characterData["description"]
		curControl = GetControl("RPProfileWindowCharacterPanelXDescription")
		if ((tmpValue ~= nil) and (tmpValue ~= "")) then
			local textField = curControl:GetNamedChild("Text")
			textField:SetText(tmpValue)
			curControl:SetDimensions(nil, estimateFieldSize(tmpValue, 100, 24) + 16)
			textField:SetDimensions(nil, estimateFieldSize(tmpValue, 100, 24) + 16)
			curControl:SetHidden(false)
		else
			curControl:SetDimensions(nil, nil)
			curControl:SetHidden(true)
		end
		-- OOC Info
		tmpValue = characterData["oocInfo"]
		curControl = GetControl("RPProfileWindowCharacterPanelXOOC")
		if ((tmpValue ~= nil) and (tmpValue ~= "")) then
			local textField = curControl:GetNamedChild("Text")
			textField:SetText(tmpValue)
			textField:SetTopLineIndex(0)
			curControl:SetDimensions(nil, estimateFieldSize(tmpValue, 100, 24) + 48)
			textField:SetDimensions(nil, estimateFieldSize(tmpValue, 100, 24) + 16)
			curControl:SetHidden(false)
		else
			curControl:SetDimensions(nil, nil)
			curControl:SetHidden(true)
		end
		-- Biography
		tmpValue = characterData["biography"]
		curControl = GetControl("RPProfileWindowCharacterPanelXBiography")
		if ((tmpValue ~= nil) and (tmpValue ~= "")) then
			local textField = curControl:GetNamedChild("Text")
			textField:SetText(tmpValue)
			textField:SetTopLineIndex(0)
			curControl:SetDimensions(nil, estimateFieldSize(tmpValue, 100, 24) + 72)
			textField:SetDimensions(nil, estimateFieldSize(tmpValue, 100, 24) + 20)
			curControl:SetHidden(false)
		else
			curControl:SetDimensions(nil, nil)
			curControl:SetHidden(true)
		end
		
		HACKScrolling("RPProfileWindowCharacterPanel")
	else
		curControl:SetHidden(true)
	end
end

-- Opens a browser window to the current character's profile.
function RPProfileViewer.LaunchProfileLink()
	local nameControl = GetControl("RPProfileWindowCharacterPanelXCharacterName")
	RequestOpenUnsafeURL("https://eso-profiles.net/view/" .. nameControl:GetText())
end

--Shissus ContextMenu Hack as he failed to implement this properly
function RPProfileViewer.ContextMenuHackOnUpdate()
	if RPProfileViewer.hacks.contextMenuHackUpdated == nil then
		RPProfileViewer.hacks.contextMenuHackUpdated = true
		--d("first")
	else
		--d("second")
		RPProfileViewer.AdjustContextMenus()
		EVENT_MANAGER:UnregisterForUpdate(RPProfileViewer.hacks.callbackName)
	end
end

function RPProfileViewer.AdjustContextMenus()
	local ShowPlayerContextMenu = CHAT_SYSTEM.ShowPlayerContextMenu
	CHAT_SYSTEM.ShowPlayerContextMenu = function(self, displayName, rawName)
		ShowPlayerContextMenu(self, displayName, rawName)

		-- Don't bother if we got an account name
		if ((string.sub(displayName, 1, 1) ~= "@") and (CheckCharacterRegistered(displayName))) then
			AddCustomMenuItem(GetString(RPV_RP_PROFILE), function() RPProfileViewer.ToggleWindow(displayName) end )
		end

		if ZO_Menu_GetNumMenuItems() > 0 then 
			ShowMenu() 
		end
	end
end

-- Initialization
local function OnAddOnLoaded(eventCode, addOnName)
    if (addOnName == RPProfileViewer.Name) then
		SLASH_COMMANDS["/rpprofilewindow"] = RPProfileViewer.DispatchToggleWindow
		
		local profileWindow = GetControl("RPProfileWindow")
		profileWindow:SetHidden( true )
		
		RPProfileViewer:LoadProfileData()
		InitializeLocalizationHack()
		CheckCharacterRegistered(GetUnitName("player"))
		
		--Shissus ContextMenu Hack as he failed to implement this properly
		EVENT_MANAGER:RegisterForUpdate(RPProfileViewer.hacks.callbackName, RPProfileViewer.hacks.callbackInterval, RPProfileViewer.ContextMenuHackOnUpdate)
	end
end

local function OnReticleOver()
	if IsUnitPlayer("reticleover") then
		if CheckCharacterRegistered(GetUnitName("reticleover")) then
			if ((IsPlayerInAvAWorld() == false) and (IsActiveWorldBattleground() == false)) then
				zo_callLater(function ()
					ZO_TargetUnitFramereticleoverRankIcon:SetTexture("RPProfileViewer/images/Icon-RP.dds")
				end, 10)
			end
		end
	end
end

EVENT_MANAGER:RegisterForEvent(RPProfileViewer.Name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
EVENT_MANAGER:RegisterForEvent(RPProfileViewer.Name, EVENT_RETICLE_TARGET_CHANGED, OnReticleOver)