IsTargetGuildie = {}
IsTargetGuildie.name = "IsTargetGuildie"
IsTargetGuildie.version = "2026.07.06"
IsTargetGuildie.defaults = {
	iconsOnly = false,
}

function IsTargetGuildie.CreateConfiguration()
	
	local LAM = LibAddonMenu2
	

	local panelData = {
		type = "panel",
		name = IsTargetGuildie.name,
		author = "|c3CB371@Masteroshi430|r",
		version = IsTargetGuildie.version,
		registerForDefaults = true,
		registerForRefresh = true,
	}

	LAM:RegisterAddonPanel(IsTargetGuildie.name.."Config", panelData)

	local controlData = {

		[1] = {
			type = "checkbox",
			name = GetString(SI_NO).." "..GetString(SI_CUSTOMER_SERVICE_ASK_FOR_HELP_GUILD_NAME).." "..GetString(SI_GRAPHICS_OPTIONS_VIDEO_CATEGORY_DISPLAY),       
			tooltip = GetString(SI_NO).." "..GetString(SI_CUSTOMER_SERVICE_ASK_FOR_HELP_GUILD_NAME).." "..GetString(SI_GRAPHICS_OPTIONS_VIDEO_CATEGORY_DISPLAY),
			getFunc = function() return IsTargetGuildie.vars.iconsOnly end,
			setFunc = function(value) IsTargetGuildie.vars.iconsOnly = value end,
			default = IsTargetGuildie.defaults.iconsOnly,
		},
	}

LAM:RegisterOptionControls(IsTargetGuildie.name.."Config", controlData)

end

-- Cache resolved hex colors for the ESO-derived branch only. ESO's chat
-- category colors are static for the session, so caching them avoids the
-- ZO_ColorDef:New()/ToHex() allocation on every mouseover. pChat colors
-- are NOT cached: the user can change them live in pChat's own settings,
-- and we have no hook to invalidate a cache when that happens. That's
-- fine performance-wise too, since the pChat branch is just a table
-- index + string.sub - there's no ZO_ColorDef allocation to save there.
local esoColorCache = {}

local function getGuildColor(guildIndex)

	local usingPChatColors = pChat and not pChat.db.useESOcolors

	if usingPChatColors then  -- use pChat colors when available
	    local HEX
		if guildIndex == 1 then
			   HEX = pChat.db.colours[24] 
		elseif guildIndex == 2 then
			   HEX = pChat.db.colours[26] 
		elseif guildIndex == 3 then
			   HEX = pChat.db.colours[28]  
		elseif guildIndex == 4 then
			   HEX = pChat.db.colours[30]
		elseif guildIndex == 5 then
			   HEX = pChat.db.colours[32] 
	    end	
		return string.sub(HEX, 3)
	end

	local cached = esoColorCache[guildIndex]
	if cached then return cached end

	local chatCategory -- if no pChat get ESO colors 
	if guildIndex == 1 then
	      chatCategory = CHAT_CATEGORY_GUILD_1 
	elseif guildIndex == 2 then
	      chatCategory = CHAT_CATEGORY_GUILD_2
	elseif guildIndex == 3 then
	      chatCategory = CHAT_CATEGORY_GUILD_3  
	elseif guildIndex == 4 then
	      chatCategory = CHAT_CATEGORY_GUILD_4 
	elseif guildIndex == 5 then
	      chatCategory = CHAT_CATEGORY_GUILD_5 
	end

	local guildColorR, guildColorG, guildColorB = GetChatCategoryColor(chatCategory)
	local guildColorDef = ZO_ColorDef:New(guildColorR, guildColorG, guildColorB, 1)
	local hexColor = guildColorDef:ToHex()

	esoColorCache[guildIndex] = hexColor
    return hexColor 
end


local function getGuildIcons(displayName)
	local guildIconsString = ""
	for i = 1, GetNumGuilds() do
		local guildId = GetGuildId(i)
		local isInGuild = GetGuildMemberIndexFromDisplayName(guildId, displayName)
			if isInGuild then
				 local guildName = GetGuildName(guildId)
				 if IsTargetGuildie.vars.iconsOnly then guildName = "" end
				 local hexColor = getGuildColor(i)
				 guildIconsString = guildIconsString.."|c"..hexColor..zo_iconFormatInheritColor("/esoui/art/treeicons/gamepad/gp_tutorial_idexicon_guilds.dds",24,24)..guildName.."|r" 
			end		
	end
	
	return guildIconsString
end



function IsTargetGuildie.go() 
	if not IsPlayerActivated() then return end
	if not UNIT_FRAMES then return end
	if GetUnitType("reticleover") ~= UNIT_TYPE_PLAYER then return end

	local displayName = GetUnitDisplayName("reticleover")
	if not IsGuildMate(displayName) then return end

	local originalText = ZO_TargetUnitFramereticleoverName:GetText()
	
	if string.find(originalText,"/esoui/art/treeicons/gamepad/gp_tutorial_idexicon_guilds.dds") then
	   return
	end


	local newText = originalText..getGuildIcons(displayName)
	ZO_TargetUnitFramereticleoverName:SetText(newText)
end

-- Debounce reticle-target-changed: zo_callLater can't be cancelled, so
-- rapidly sweeping over several units (crowds, PvP, cities) previously
-- queued a go() call for EVERY intermediate target, each one still doing
-- the full IsPlayerActivated/GetUnitType/IsGuildMate/GetUnitDisplayName
-- work 10ms later even though only the last target still matters. A
-- generation counter lets stale, superseded calls bail out immediately.
local reticleChangeGeneration = 0

local function OnReticleTargetChanged()
	reticleChangeGeneration = reticleChangeGeneration + 1
	local thisGeneration = reticleChangeGeneration
	zo_callLater(function()
		if thisGeneration == reticleChangeGeneration then
			IsTargetGuildie.go()
		end
	end, 10)
end

local function OnAddonLoaded(event, addonName)

	if addonName == IsTargetGuildie.name then
       IsTargetGuildie.vars = ZO_SavedVars:NewAccountWide("ITGVars", 2, nil, IsTargetGuildie.defaults)
       IsTargetGuildie.CreateConfiguration()
       EVENT_MANAGER:RegisterForEvent(IsTargetGuildie.name, EVENT_RETICLE_TARGET_CHANGED, OnReticleTargetChanged)	   
	end
end	


EVENT_MANAGER:RegisterForEvent(IsTargetGuildie.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)


