local GA = GuildAlert
local EH = GA.EventHandlers
local UI = GA.UI
local Util = GA.Util
local Setup = GA.Setup


local ANNOUNCEMENT_PREFIX = "Alert:"
local ANNOUNCEMENT_DELAY = 3000
local MAX_LINE_LENGTH = 60


------[[ Events : Handlers ]]------


function EH.OnAddOnLoaded( event, addonName )

	if addonName == GA.ADDON.NAME then
		EVENT_MANAGER:UnregisterForEvent( GA.ADDON.NAME, EVENT_ADD_ON_LOADED )
		Setup.Initialize()
	end

end


function EH.OnPlayerActivated( event )

	if not GA.Initialized then
		GA.Initialized = true
		Setup.InitializeSettingsMenu()
	end

end


function EH.OnGuildDescriptionChanged( event, guildId )

	if not GA.Vars.EnableAnnouncements and not GA.Vars.EnableChatMessages then return end

	local name = GetGuildName( guildId )
	local desc = GetGuildDescription( guildId )
	if nil == name or nil == desc then return end

	local alertTitle = name .. " |cff0000Alert|r"
	local msgs = { }
	local indexEnd
	local _, indexStart = string.find( string.lower( desc ), string.lower( ANNOUNCEMENT_PREFIX ), 1, true )

	while nil ~= indexStart do

		indexStart = indexStart + 1
		indexEnd = string.find( desc, "\n", indexStart, true )

		local msg = string.sub( desc, indexStart, indexEnd and indexEnd - 1 or nil )
		while nil ~= msg and "" ~= msg and "\n" ~= msg do

			table.insert( msgs, string.sub( msg, 1, MAX_LINE_LENGTH ) )
			msg = string.sub( msg, MAX_LINE_LENGTH + 1 )

		end

		indexStart = indexEnd

	end

	if 0 < #msgs then

		if GA.Vars.EnableChatMessages then
			local timeString = ZO_FormatClockTime()
			d( alertTitle .. " (" .. ( timeString or "now" ) .. ")" )
		end

		if GA.Vars.EnableAnnouncements then
			UI.Announce( alertTitle )
		end

		local delay = ANNOUNCEMENT_DELAY

		for _, m in ipairs( msgs ) do

			if GA.Vars.EnableChatMessages then
				d( m )
			end

			if GA.Vars.EnableAnnouncements then
				zo_callLater( function() UI.Announce( m ) end, delay )
				delay = delay + ANNOUNCEMENT_DELAY
			end

		end

	end

end


------[[ Events : Registrations ]]------


EVENT_MANAGER:RegisterForEvent( GA.ADDON.NAME, EVENT_ADD_ON_LOADED, EH.OnAddOnLoaded )
EVENT_MANAGER:RegisterForEvent( GA.ADDON.NAME, EVENT_PLAYER_ACTIVATED, EH.OnPlayerActivated )
EVENT_MANAGER:RegisterForEvent( GA.ADDON.NAME, EVENT_GUILD_DESCRIPTION_CHANGED, EH.OnGuildDescriptionChanged )
