MARK = MARK or { }
MARK.name = "Marker"
MARK.messagePrefix = "[Marker]"
MARK.messagePrefixProfile = "[MarkerP]"
MARK.loadedZone = 0
MARK.loadedProfile = nil
MARK.donateTitle = "Donate <3"
MARK.circlePath = ""
MARK.savedVars = { }
MARK.profiles = { }
MARK.fallbackSize = 100

MARK.UI = {}
MARK.UI.ShownMenu = 1 -- 1 = ProfileView; 0 = MarkerView
MARK.UI.Edit = {
	Marker = nil,
	Profile = nil
}
MARK.UI.FilterCloseOnly = 0
MARK.UI.SelectedTexture = ""
MARK.UI.SelectedTextureHistory = {}

MARK.iconColor = { 0.9911, 0.9912, 0.9913}
MARK.coordTable = {}
MARK._v = {}

-- PERFORMANCE: Localize globals for massive speedup in loops
local EM = EVENT_MANAGER
local t_insert = table.insert
local t_concat = table.concat
local s_sub = string.sub
local s_gsub = string.gsub
local s_find = string.find
local t_tonumber = tonumber
local t_tostring = tostring
local t_type = type

function MARK.copyTable(t)
	if t_type(t) ~= "table" then return t end
    local t2 = {}
    for k,v in pairs(t) do
        if t_type(v) == "table" then
            t2[k] = MARK.copyTable(v)
        else
            t2[k] = v
        end
    end
    setmetatable(t2, getmetatable(t))
    return t2
end

function MARK.loadSavedData()
	MARK.UI.SelectedTexture = MARK.savedVars.selectedTexture or ""
	MARK.UI.SelectedTextureHistory = MARK.savedVars.selectedTextureHistory or {}
	RightMarkerViewTextureHistory1:SetNormalTexture(LibEmote.GetEmoteByIndex(MARK.UI.SelectedTextureHistory[1]).textures[1])
	RightMarkerViewTextureHistory2:SetNormalTexture(LibEmote.GetEmoteByIndex(MARK.UI.SelectedTextureHistory[2]).textures[1])
	RightMarkerViewTextureEdit:SetNormalTexture(LibEmote.GetEmoteByIndex(MARK.UI.SelectedTexture).textures[1])
end

function MARK.saveData()
	MARK.savedVars.selectedTexture = MARK.UI.SelectedTexture
	MARK.savedVars.selectedTextureHistory = MARK.UI.SelectedTextureHistory
end

function MARK.getZoneProfilesData(zone)
	local output = {}
	for profileId, profile in pairs(MARK.savedVars.profiles) do
		if profile.zone == zone then
			output[profileId] = profile
		end
	end
	return output
end

function MARK.getZoneProfile(zone)
	if MARK.savedVars.lastProfilesOfZone == nil then return nil end
	local profileId = MARK.savedVars.lastProfilesOfZone[zone]
	if profileId == nil then return end
	return MARK.getProfile(profileId)
end

function MARK.getProfile(id)
	local data = MARK.getProfileData(id)
	if data == nil then return nil end
	return MarkerProfile:new(data)
end

-- PERFORMANCE: Replaced duplicate string splitters with one optimized native loop
local function splitStringIntoChunks(text, chunkSize)
    chunkSize = chunkSize or 1000
    local chunks = {}
    if not text or text == "" then
        return chunks
    end
    for i = 1, #text, chunkSize do
        chunks[#chunks + 1] = s_sub(text, i, i + chunkSize - 1)
    end
    return chunks
end

function MARK.getProfileData(id)
	if MARK.savedVars.profiles[id] == nil then return nil end
	local copy = MARK.copyTable(MARK.savedVars.profiles[id])
	
	if copy.onLoad and copy.onLoad ~= "nil" then
		if t_type(copy.onLoad) == "table" then
			copy.onLoad = t_concat(copy.onLoad, "")
		end
	end
	if copy.onUnload and copy.onUnload ~= "nil" then
		if t_type(copy.onUnload) == "table" then
			copy.onUnload = t_concat(copy.onUnload, "")
		end
	end
	for _, v in pairs(copy.marker) do
		if v.requirement and v.requirement ~= "nil" then
			if t_type(v.requirement) == "table" then
				v.requirement = t_concat(v.requirement, "")
			end
		end
	end
	return copy
end

function MARK.saveProfileData(id, profileData)
	if profileData.onLoad and t_type(profileData.onLoad) == "string" then
		profileData.onLoad = splitStringIntoChunks(profileData.onLoad)
	end
	if profileData.onUnload and t_type(profileData.onUnload) == "string" then
		profileData.onUnload = splitStringIntoChunks(profileData.onUnload)
	end
	for _, v in pairs(profileData.marker) do
		if v.requirement and t_type(v.requirement) == "string" then
			v.requirement = splitStringIntoChunks(v.requirement)
		end
	end
	MARK.savedVars.profiles[id] = profileData
end

function MARK.zoneChange()
	local zoneId = GetUnitRawWorldPosition("player")
	if zoneId == MARK.loadedZone then return end
	MARK.loadedZone = zoneId
	MARK.loadedProfile = MARK.getZoneProfile(zoneId)
	if MARK.loadedProfile == nil then return end
	MARK.loadedProfile:load()
	MARK.notify(MARK.loadedProfile.data.name.." loaded!")
	MARK.RefreshList()
end

function MARK.reloadProfile()
	if MARK.loadedProfile == nil then return end
	local id = MARK.loadedProfile.data.id
	local name = MARK.loadedProfile.data.name
	MARK.unloadProfile(true)
	MARK.loadProfile(id)
	MARK.notify(name.." reloaded!")
end

function MARK.loadProfile(id)
	MARK.unloadProfile()
	MARK.loadedProfile = MARK.getProfile(id)
	if MARK.loadedProfile == nil then return nil end
	MARK.loadedProfile:load()
	MARK.notify(MARK.loadedProfile.data.name.." loaded!")
	MARK.RefreshList()
	MARK.AdjustRightMenuVisibility(false)
	return MARK.loadedProfile
end

function MARK.unloadProfile(notify)
	if MARK.loadedProfile == nil then return end
	if notify == true then
		MARK.notify(MARK.loadedProfile.data.name.." unloaded!")
	end
	MARK.loadedProfile:unload()
	MARK.AdjustRightMenuVisibility(false)
end

function MARK.newProfile()
	local zoneId = GetUnitRawWorldPosition("player")
	MARK.unloadProfile()
	local profile = {
		id = LibAkaUtils.uuid(),
		name = "New Profile",
		zone = zoneId,
		marker = {}
	}
	MARK.saveProfileData(profile.id, profile)
	MARK.savedVars.lastProfilesOfZone[zoneId] = profile.id
	local prf = MARK.loadProfile(id)
	MARK.RefreshList()
	return prf
end

function MARK.getMarkerIndexElms(elmsTextureNumber)
	if elmsTextureNumber == nil then return "0" end
	local text = LibEmote.GetEmoteByName("mark"..elmsTextureNumber)
	if text.name == "" then return "0" end
	return text.emoteIndex
end

function MARK.notify(str)
	LibAkaUtils.alert(str)
end

SLASH_COMMANDS["/marker"] = function ()
	MarkerUI:SetHidden(false)
	EM:RegisterForUpdate(MARK.name .. "UpdateView", 250, MARK.RefreshList)
end

SLASH_COMMANDS["/markerclear"] = function ()
	MARK.ClearAndReload()
end

SLASH_COMMANDS["/markerplace"] = function ()
	MARK.PlaceIcon3DKeybind()
end

SLASH_COMMANDS["/shareprofile"] = function ()
	local profile = MARK.loadedProfile
	if profile then
		MARK.shareprofilemessages = MARK.ShareProfileInChat(profile.data.id)
		MARK.shareprofilemessagesindex = 1
		EM:UnregisterForEvent("MarkerChatMessageEvent", EVENT_CHAT_MESSAGE_CHANNEL)
		MARK.SetChatAndCallbackWhenSent()
		EM:RegisterForEvent("MarkerChatMessageEvent", EVENT_CHAT_MESSAGE_CHANNEL, function(eid, channel, from, message)
			if s_find(message, MARK.messagePrefixProfile, 1, true) ~= nil then
				MARK.SetChatAndCallbackWhenSent()
			end
		end)
	end
end

function MARK.SetChatAndCallbackWhenSent()
	if MARK.shareprofilemessages[MARK.shareprofilemessagesindex] == nil then
		EM:UnregisterForEvent("MarkerChatMessageEvent", EVENT_CHAT_MESSAGE_CHANNEL)
		return
	end
	LibAkaUtils.setChat("/p " .. MARK.shareprofilemessages[MARK.shareprofilemessagesindex])
	MARK.shareprofilemessagesindex = MARK.shareprofilemessagesindex + 1
end

function MARK.ClearAndReload()
	for _, osiIcon in pairs(OSI.GetPositionIcons()) do
		OSI.DiscardPositionIcon(osiIcon)
	end
	MARK.notify("All position icons cleared!")
	MARK.reloadProfile()
end

function MARK.ShareProfileInChat(id)
	local profile = MARK.getProfile(id)
	local messages = {}
	if profile then
		local config = LibBase64.encode(profile:getConfig())
        -- PERFORMANCE: Clean spaces/newlines in one pass natively
		config = s_gsub(config, "[ \n]", "")
		local hash = LibCrypto.hash.sha1(config)
		
        t_insert(messages, MARK.messagePrefixProfile .. "000" .. profile.data.name)
		local temp = splitStringIntoChunks(config, 300)
		for index, value in ipairs(temp) do
			local indexString = t_tostring(index)
			if index < 10 then
				indexString = "00" .. indexString
			elseif index < 100 then
				indexString = "0" .. indexString
			end
			t_insert(messages, MARK.messagePrefixProfile .. indexString .. value)
		end
		t_insert(messages, MARK.messagePrefixProfile .. "999" .. hash)
	end
	return messages
end

MARK.tempprofile = {}
MARK.shareprofilemessagesindex = 1
MARK.shareprofilemessages = {}

function MARK.ChatHandler(channelID, from, text, isCustomerService, fromDisplayName)
	if s_find(text, MARK.messagePrefix, 1, true) ~= nil then
        -- PERFORMANCE: Standard string.sub going to the end of string implicitly
		text = s_sub(text, 9)
		local message = Marker:fromString(text, true)
		return MARK.Handler(channelID, from, LibAkaUtils.GetLink("Marker - " .. message .. " - Click here to place it.", MARK.name, function()
			MARK.notify(Marker:fromString(text))
		end), isCustomerService, fromDisplayName)
	end
	if s_find(text, MARK.messagePrefixProfile, 1, true) ~= nil then
		text = s_sub(text, 10)
		local index = t_tonumber(s_sub(text, 1, 3))
		text = s_sub(text, 4)
		if index == 0 then 
			MARK.tempprofile = {
				name = text,
				data = {}
			}
			return MARK.Handler(channelID, from, "Shared MarkerProfile -> Start", isCustomerService, fromDisplayName)
		end
		local hash = LibCrypto.hash.sha1(t_concat(MARK.tempprofile.data, ""))
		if hash == text then
			MARK.shareprofilemessagesindex = 1
			MARK.shareprofilemessages = {}
			return MARK.Handler(channelID, from, LibAkaUtils.GetLink("MarkerProfile - Click here to add it.", MARK.name, function()
				local data = LibBase64.decode(t_concat(MARK.tempprofile.data))
				local zoneId = GetUnitRawWorldPosition("player")
				MARK.unloadProfile()
				local id = LibAkaUtils.uuid()
				local profileData = {
					id = id,
					name = MARK.tempprofile.name,
					zone = zoneId,
					marker = {}
				}
				MARK.saveProfileData(id, profileData)
				MARK.savedVars.lastProfilesOfZone[zoneId] = id
				MARKEditProfile:new(id)
				MARK.UI.Edit.Profile:setConfig(data)
				MARK.UI.Edit.Profile:save()
				MARK.loadProfile(id)
				MARK.tempprofile = {}
				MARK.RefreshList()
			end), isCustomerService, fromDisplayName)
		end
		MARK.tempprofile.data[index or 1] = text
		return MARK.Handler(channelID, from, "Shared MarkerProfile -> Message " .. (index or 1), isCustomerService, fromDisplayName)
	end

	return MARK.Handler(channelID, from, text, isCustomerService, fromDisplayName)
end

function MARK.RegisterMessageListener()
	zo_callLater(function ()
		MARK.Handler = CHAT_ROUTER:GetRegisteredMessageFormatters()[EVENT_CHAT_MESSAGE_CHANNEL]
		CHAT_ROUTER:RegisterMessageFormatter(EVENT_CHAT_MESSAGE_CHANNEL, MARK.ChatHandler)
	end, 2500)
end

function MARK.combatChange(_, inCombat)
	if inCombat == true then 
		MarkerUI:SetHidden(true)
        -- PERFORMANCE: Ensure timer loop is stopped when UI auto-closes
        EM:UnregisterForUpdate(MARK.name .. "UpdateView")
	end
end

function MARK.updateSavedVars()
	if MARK.savedVars.finished == true then return end
	local savedVarsOld = ZO_SavedVars:NewAccountWide("MARK_Data", 1, nil, {})
	MARK.savedVars.radius = t_tonumber(savedVarsOld.radius) or 10000
	MARK.savedVars.delay = t_tonumber(savedVarsOld.delay) or 2000
	MARK.savedVars.minimumdelay = t_tonumber(savedVarsOld.minimumdelay) or 50
	MARK.savedVars.emotePackName = t_tostring(savedVarsOld.emotePackName) or "mark"
	MARK.savedVars.selectedTexture = t_tostring(savedVarsOld.selectedTexture) or ""
	MARK.savedVars.selectedTextureHistory = MARK.copyTable(savedVarsOld.selectedTextureHistory) or {}

	if savedVarsOld.profiles == nil then
		savedVarsOld.profiles = {}
	end
	if savedVarsOld.markers == nil then
		savedVarsOld.markers = {}
	end

	for profileId, profile in pairs(savedVarsOld.profiles) do
		local data = {
			id = t_tostring(profile.id),
			name = t_tostring(profile.name),
			zone = t_tonumber(profile.zone),
			marker = {},
			onLoad = t_tostring(profile.onLoad),
			onUnload = t_tostring(profile.onUnload)
		}
		if data.onLoad == "nil" then data.onLoad = nil end
		if data.onUnload == "nil" then data.onUnload = nil end

		local markers = {}
		for _, markerId in pairs(profile.marker) do
            local oldMarkerData = savedVarsOld.markers[markerId]
			if oldMarkerData ~= nil then
                -- PERFORMANCE: Shallow copy instead of recursive deep-copy on flat marker table data
                local marker = {}
                for k,v in pairs(oldMarkerData) do marker[k] = v end

				local index = marker.texture
				if #index ~= 5 then
					index = MARK.getMarkerIndexElms(marker.texture)
					if index == "0" then
						index = LibEmote.GetEmoteIndex(marker.texture)
						if index ~= "0" then
							marker.texture = index
						end
					else
						marker.texture = index
					end
				end
				markers[markerId] = marker
			end
		end
		data.marker = markers
		MARK.saveProfileData(data.id, data)
	end
	savedVarsOld.profiles = nil
	savedVarsOld.markers = nil
	savedVarsOld.radius = nil
	savedVarsOld.delay = nil
	savedVarsOld.minimumdelay = nil
	savedVarsOld.emotePackName = nil
	savedVarsOld.selectedTexture = nil
	savedVarsOld.selectedTextureHistory = nil
	savedVarsOld.top = nil
	savedVarsOld.height = nil
	savedVarsOld.left = nil
	savedVarsOld.width = nil
	savedVarsOld.interactionLimiterActive = nil
	savedVarsOld.lastProfilesOfZone = nil
	savedVarsOld.iconsizemultiplier = nil
	MARK.savedVars.finished = true
	d("Updated Profiles!")
end

function MARK.getEmotePackFiler()
	local name = MARK.savedVars.emotePackName
	if name == nil or name == "nil" then 
		MARK.savedVars.emotePackName = ""
		name = ""
	end
	return name
end

local function OnAddOnLoaded(eventCode, addonName)
	if (addonName ~= MARK.name) then return end

	MARK.controlPool = ZO_ControlPool:New("MarkerTemplate", MarkerTLC)
	
	MARK.savedVars = ZO_SavedVars:NewAccountWide("MARKDataNew", 1, nil, {
		radius = 10000,
		delay = 2000,
		minimumdelay = 50,
		emotePackName = "mark",
		profiles = {},
		lastProfilesOfZone = {},
		iconsizemultiplier = 100,
		showChatButton = true,
		alertDismissed = false
	})
	MARK.iconData = ZO_SavedVars:NewAccountWide("MARKIconData", 1, nil, {
		name = "|cFF0000a|r|cF50000k|r|cEB0000a|r|cE10000m|r|cD70000a|r|cCD0000t|r|cC30000s|r|cB90000u|r|cAF00000|r|cA500002|r",
		at = "@akamalamatsu02",
		sname = "akamatsu02"
	})

	MARK.updateSavedVars()
	MARK.loadSavedData()
	MARK.addonInfo = LibAkaUtils.getAddonInfo(MARK.name)

	table.setStringList({
		["SI_BINDING_NAME_MARK"] = "Place Marker",
	})
	
	EM:RegisterForEvent(MARK.name.."ZoneChange", EVENT_PLAYER_ACTIVATED, MARK.zoneChange)
	if akaUpdater and akaUpdater.init then 
		akaUpdater.init(MARK)
	end
	EM:UnregisterForEvent(MARK.name, EVENT_ADD_ON_LOADED)
	
	EM:RegisterForEvent(MARK.name.."Combat", EVENT_PLAYER_COMBAT_STATE, MARK.combatChange)

	MarkerUI:ClearAnchors()
	if MARK.savedVars.left == nil then
		MarkerUI:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
		MarkerUI:SetDimensions(600, 450)
		MARK.OnUIMove()
	else
		MarkerUI:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, MARK.savedVars.left or 0, MARK.savedVars.top or 0)
		MarkerUI:SetDimensions(MARK.savedVars.width or 600, MARK.savedVars.height or 450)
	end

	MARK.InitList()
	MARK.settings()
	MARK.AdjustRightMenuVisibility(false)

	MARK.circlePath = LibEmote.GetEmoteByName("markcircle").emoteIndex

	MARK.RegisterMessageListener()

	MARK.chatButton = LibChatMenuButton.addChatButton("MarkerChatButton", "OdySupportIcons/icons/squares/marker_lightblue.dds", "Marker", function()
        local isHidden = not MarkerUI:IsHidden()
		MarkerUI:SetHidden(isHidden)
        
        -- PERFORMANCE: Properly start/stop updates based on window visibility toggle
        if not isHidden then
		    EM:RegisterForUpdate(MARK.name .. "UpdateView", 250, MARK.RefreshList)
        else
            EM:UnregisterForUpdate(MARK.name .. "UpdateView")
        end
	end)
    
	if MARK.savedVars.showChatButton == true then
		MARK.chatButton:show()
	else
		MARK.chatButton:hide()
	end
end

EM:RegisterForEvent(MARK.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
d=d