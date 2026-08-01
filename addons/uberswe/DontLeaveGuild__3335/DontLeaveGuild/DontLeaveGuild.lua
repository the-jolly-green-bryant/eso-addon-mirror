DontLeaveGuild = {}

DontLeaveGuild.name = "DontLeaveGuild"

function DontLeaveGuild:Initialize()
    DontLeaveGuild.ShowGuilds()
end

function DontLeaveGuild.OnAddOnLoaded(event, addonName)
  if addonName == DontLeaveGuild.name then
    DontLeaveGuild:Initialize()
  end
end

EVENT_MANAGER:RegisterForEvent(DontLeaveGuild.name, EVENT_ADD_ON_LOADED, DontLeaveGuild.OnAddOnLoaded)

function DontLeaveGuild.ShowGuilds()
	GUILD_HOME.keybindStripDescriptor[1].visible = function() return false end
end

ZO_PreHook(GUILD_HOME, "RefreshAll", DontLeaveGuild.ShowGuilds)

EVENT_MANAGER:RegisterForEvent(DontLeaveGuild.name, EVENT_GUILD_DATA_LOADED, DontLeaveGuild.ShowGuilds)