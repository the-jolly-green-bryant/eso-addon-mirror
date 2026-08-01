AIGL = {}
local AIGL = AIGL

AIGL.name = "AddedInfoGuildLogins"
AIGL.version = "1.3"

AIGL.accountWideDefaults = {
	accountWide = true
}

AIGL.defaults = {
    suppressInDungeon = true,
    show = {
        [1] = false,
        [2] = false,
        [3] = false,
        [4] = false,
        [5] = false,
    },
	colorText = true
}

function OnGuildMemberStatusChange(eventCode, guildId, displayName, oldStatus, newStatus)
	-- If a friend that is also in one of your guilds logs on/off, don't show, as ESO already shows it anyways. Same goes for if you log in/out.
    if IsFriend(displayName) or displayName == GetUnitDisplayName("player") then return end

    local wasOnline = oldStatus ~= PLAYER_STATUS_OFFLINE
    local isOnline = newStatus ~= PLAYER_STATUS_OFFLINE

    -- if online status changed
    if wasOnline ~= isOnline then
        -- Loop trough the player's guilds
        for i = 1, GetNumGuilds() do
            -- If the guild is supposed to be shown, show it
            if (GetGuildId(i) == guildId) and AIGL.SV.show[i] then
                if not (IsUnitInDungeon("player") and AIGL.SV.suppressInDungeon) then
                    AIGL.ShowLoginMessage(guildId, displayName, i, isOnline)
                end
            end
        end
    end
end

function AIGL.ShowLoginMessage(guildId, displayName, guildIndex, isOnline)
    local _, characterName = GetGuildMemberCharacterInfo(guildId, GetGuildMemberIndexFromDisplayName(guildId, displayName))

    local channel = CHAT_CHANNEL_GUILD_1
    if guildIndex == 1 then
        channel = CHAT_CHANNEL_GUILD_1
    elseif guildIndex == 2 then
        channel = CHAT_CHANNEL_GUILD_2
    elseif guildIndex == 3 then
        channel = CHAT_CHANNEL_GUILD_3
    elseif guildIndex == 4 then
        channel = CHAT_CHANNEL_GUILD_4
    elseif guildIndex == 5 then
        channel = CHAT_CHANNEL_GUILD_5
    end
    
    local guildChannelLink = ZO_LinkHandler_CreateLink(GetGuildName(guildId), nil, CHANNEL_LINK_TYPE,  channel)
    local displayNameLink = ZO_LinkHandler_CreateDisplayNameLink(displayName)
    local characterNameLink = ZO_LinkHandler_CreateCharacterLink(characterName)
	
    local text
    if isOnline then
        if characterName ~= "" then
            text = zo_strformat(SI_FRIENDS_LIST_FRIEND_CHARACTER_LOGGED_ON, displayNameLink, characterNameLink)
        else
            text = zo_strformat(SI_FRIENDS_LIST_FRIEND_LOGGED_ON, displayNameLink)
        end
    else
        if characterName ~= "" then
            text = zo_strformat(SI_FRIENDS_LIST_FRIEND_CHARACTER_LOGGED_OFF, displayNameLink, characterNameLink)
        else
            text = zo_strformat(SI_FRIENDS_LIST_FRIEND_LOGGED_OFF, displayNameLink)
        end
    end
    
	local cat = CHAT_CATEGORY_SYSTEM
	
    -- Category (=color) for the message
	if AIGL.SV.colorText then
		if guildIndex == 1 then
			cat = CHAT_CATEGORY_GUILD_1
		elseif guildIndex == 2 then
			cat = CHAT_CATEGORY_GUILD_2
		elseif guildIndex == 3 then
			cat = CHAT_CATEGORY_GUILD_3
		elseif guildIndex == 4 then
			cat = CHAT_CATEGORY_GUILD_4
		elseif guildIndex == 5 then
			cat = CHAT_CATEGORY_GUILD_5
		end
	end
	
	KEYBOARD_CHAT_SYSTEM:OnFormattedChatMessage(guildChannelLink .. " " .. text, cat)
end


-- Initializes
function InitializeAddonMenu()
    local optionsData = {}
	local panelData = {
		type = "panel",
		name = "Added Info - Guild Logins",
		displayName = "Added Info - Guild Logins (AIGL)",
		author = "MrPikPik",
		version = AIGL.version,
		website = 'https://www.esoui.com/downloads/info2642-AddedInfo-GuildLogins.html#donate',
		donation = function()
			SCENE_MANAGER:Show('mailSend')
			zo_callLater(function() 
				ZO_MailSendToField:SetText("@MrPikPik")
				ZO_MailSendSubjectField:SetText("Thank you for making addons!")
				ZO_MailSendBodyField:SetText("I like using your addon 'Added Info - Guild Logins'")
				ZO_MailSendBodyField:TakeFocus()
			end, 250)
		end,
		registerForRefresh = true,
		registerForDefaults = true
	}
 
    -- Description
	table.insert(optionsData, {
		type = "description",
		text = GetString(AIGL_OPTIONS_DESCRIPTION),
	})
    
    -- Options header
	table.insert(optionsData, {
		type = "header",
		name = GetString(AIGL_OPTIONS_HEADER),
	})
    
    -- Account wide setting
	table.insert(optionsData, {
		type = "checkbox",
		name = GetString(AIGL_OPTIONS_ACCOUNTWIDE_SETTINGS),
		tooltip = GetString(AIGL_OPTIONS_ACCOUNTWIDE_SETTINGS_TT),
		requiresReload = true,
		default = AIGL.accountWideDefaults.accountWide,
		getFunc = function() return AIGL.DS.accountWide end,
		setFunc = function(newValue) AIGL.DS.accountWide = newValue end,
	})
    
    -- Divider
    table.insert(optionsData, {
		type = "divider",
	})
    
    -- Hide in dungeon
	table.insert(optionsData, {
		type = "checkbox",
		name = GetString(AIGL_OPTIONS_HIDE_IN_DUNGEON),
		tooltip = GetString(AIGL_OPTIONS_HIDE_IN_DUNGEON_TT),
		default = AIGL.defaults.suppressInDungeon,
		getFunc = function() return AIGL.SV.suppressInDungeon end,
		setFunc = function(newValue) AIGL.SV.suppressInDungeon = newValue end,
	})
	
	 -- Colorize
	table.insert(optionsData, {
		type = "checkbox",
		name = GetString(AIGL_OPTIONS_COLORIZE),
		tooltip = GetString(AIGL_OPTIONS_COLORIZE_TT),
		default = AIGL.defaults.colorText,
		getFunc = function() return AIGL.SV.colorText end,
		setFunc = function(newValue) AIGL.SV.colorText = newValue end,
	})
    
    -- Divider
    table.insert(optionsData, {
		type = "divider",
	})
    
    -- Settings Description
	table.insert(optionsData, {
		type = "description",
		text = GetString(AIGL_OPTIONS_GUILD),
	})
    
    -- Guild toggles
    for i = 1, GetNumGuilds() do
        table.insert(optionsData, {
            type = "checkbox",
            name = function()
				local cat = CHAT_CATEGORY_GUILD_1
				if i == 1 then
					cat = CHAT_CATEGORY_GUILD_1
				elseif i == 2 then
					cat = CHAT_CATEGORY_GUILD_2
				elseif i == 3 then
					cat = CHAT_CATEGORY_GUILD_3
				elseif i == 4 then
					cat = CHAT_CATEGORY_GUILD_4
				elseif i == 5 then
					cat = CHAT_CATEGORY_GUILD_5
				end
				local r, g, b = GetChatCategoryColor(cat)
				return ZO_ColorDef:New(r, g, b):Colorize(GetGuildName(GetGuildId(i)))
			end,
            default = true,
            getFunc = function() return AIGL.SV.show[i] end,
            setFunc = function(newValue) AIGL.SV.show[i] = newValue end,
        })
    end
    
    local optionsPanel = LibAddonMenu2:RegisterAddonPanel(AIGL.name, panelData)
	LibAddonMenu2:RegisterOptionControls(AIGL.name, optionsData)
end

local function OnAddonLoaded(event, addonName)
    if addonName ~= AIGL.name then return end
    EVENT_MANAGER:UnregisterForEvent(AIGL.name, EVENT_ADD_ON_LOADED) 
     
    -- Creating saved vars
    AIGL.DS = ZO_SavedVars:NewAccountWide("AIGLSavedVariables", 1.0, nil, AIGL.accountWideDefaults)
    
    if AIGL.DS.accountWide then
		AIGL.SV = ZO_SavedVars:NewAccountWide("AIGLSavedVariables", 1.0, nil, AIGL.defaults)
	else
		AIGL.SV = ZO_SavedVars:New("AIGLSavedVariables", 1.0, nil, AIGL.defaults)
	end
    
    EVENT_MANAGER:RegisterForEvent(AIGL.name, EVENT_GUILD_MEMBER_PLAYER_STATUS_CHANGED, OnGuildMemberStatusChange)
    InitializeAddonMenu()
end
EVENT_MANAGER:RegisterForEvent(AIGL.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)