GS = GS or {}
GS.name = "Group Spy"
GS.version = "1.0"
GS.savedVars = {}
GS.default = {
	useExisting = false,
	widths = { 75,   40,    100, 50,   80,    72, 90 },
}
GS.Rows = {}
GS.dWidths = { 75,   40,    100, 50,   80,    72, 90 }
			 --cp alliance race rank gender status

GS.counter = 1
			 
GS.alliances = { 
	"|t24:24:esoui/art/stats/alliancebadge_aldmeri.dds|t", 
	"|t24:24:esoui/art/stats/alliancebadge_ebonheart.dds|t", 
	"|t24:24:esoui/art/stats/alliancebadge_daggerfall.dds|t" }
GS.allianceNames = { "Aldmeri Dominion", "Ebonheart Pact", "Daggerfall Covenant" }
GS.states  = {
	{ "In Combat", "Out of Combat" },
	{ "Dead", "Alive" },
	{ "In Group Support Range", "Outside Group Support Range" }
}
GS.stateTextures = {
	{ "esoui/art/lfg/lfg_dps_down.dds", "esoui/art/lfg/lfg_dps_up.dds" },
	{ "esoui/art/tutorial/tutorial_idexicon_death_down.dds", "esoui/art/tutorial/tutorial_idexicon_death_up.dds" },
	{ "esoui/art/treeicons/tutorial_idexicon_groups_down.dds", "esoui/art/treeicons/tutorial_idexicon_groups_up.dds" }
}
GS.genders = { "Female", "Male" }


GS.topWindow = WINDOW_MANAGER:CreateTopLevelWindow("GSTopWindow")
GS.FRAGMENT_WINDOW = ZO_FadeSceneFragment:New(GS.topWindow)
KEYBOARD_GROUP_MENU_SCENE:AddFragment(GS.FRAGMENT_WINDOW)

function GS.AddonLoaded(_, name)
	if name == "GroupSpy" then
		GS.savedVars = ZO_SavedVars:NewAccountWide("GroupSpyVars", 2, nil, GS.default)
		GS.CreateSettings()
		EVENT_MANAGER:UnregisterForEvent(GS.name, EVENT_ADD_ON_LOADED)
	end
end

function GS.OnSceneChange(sceneName, oldState, newState)
	if tostring(oldState) == "showing" then
		local b = 0
		for i = 1, #GS.savedVars.widths do
			b = b + GS.savedVars.widths[i]
		end
		local a = 0 
		for i = 1, #GS.dWidths do
			a = a + GS.dWidths[i]
		end
		ZO_SharedRightBackgroundLeft:SetAnchor(TOPLEFT,ZO_SharedRightBackground,TOPLEFT,-35-(1.15*b),-75,0)
		ZO_SharedRightBackgroundLeft:SetWidth(1024+(b*1.15))
		ZO_GroupListVeteranDifficultySettings:SetAnchor(4,ZO_GroupList,1,0-(b*0.6),-10,0)
		ZO_SharedTitle:SetAnchor(8,GuiRoot,8,30-(b*1.1),-335,0)
		ZO_DisplayName:SetAnchor(3,ZO_KeyboardFriendsList,3,0-(b*1.1),0,0)
		ZO_GroupMenu_Keyboard:SetWidth(930+(b*1.05))
	end
	if tostring(oldState) == "shown" then
		GS.InitRows()
	end
	if tostring(oldState) == "hidden" then
		ZO_SharedRightBackgroundLeft:SetAnchor(TOPLEFT,ZO_SharedRightBackground,TOPLEFT,-35,-75,0)
		ZO_SharedRightBackgroundLeft:SetWidth(1024)
		ZO_SharedTitle:SetAnchor(8,GuiRoot,8,30,-335,0)
		ZO_DisplayName:SetAnchor(3,ZO_KeyboardFriendsList,3,0,0,0)
	end
end


function GS.OnEvent(...)
	zo_callLater(GS.InitRows, 200)
end

function GS.CreateSettings()
	
	local LAM2 = LibStub:GetLibrary("LibAddonMenu-2.0")
	
	local panelData = {
			type = "panel",
			name = "GroupSpy",
			displayName = "GroupSpy",
			author = "Acer",
			version = "1.0",
			registerForRefresh = true,
		}
		
	LAM2:RegisterAddonPanel("GroupSpy", panelData)
	
	local optionsData = {
		{
			type = "header",
			name = "Group Spy Settings",
		},
        {
            type = "description",
            text = "Select which of the following columns to add to the group menu.",
        },
		{
            type = "checkbox",
            name = "Replace LVL",
            tooltip = "Replace the pre-existing LVL label to show true CP",
			default = false,
			getFunc = function() return GS.savedVars.useExisting end,
            setFunc = function(x) GS.savedVars.useExisting = x end,
        },
		{
            type = "checkbox",
            name = "CP",
            tooltip = "Show true CP",
			default = true,
			getFunc = function() return (GS.savedVars.widths[1] ~= 0) end,
            setFunc = function(x)
				if x == true then GS.savedVars.widths[1] = GS.dWidths[1]
				else GS.savedVars.widths[1] = 0 end
			end,
			warning = "Requires a reloadUI to apply!",
			width = "half",
        },
		{
            type = "checkbox",
            name = "Alliance",
            tooltip = "Show alliance",
			default = true,
			getFunc = function() return (GS.savedVars.widths[2] ~= 0) end,
            setFunc = function(x)
				if x == true then GS.savedVars.widths[2] = GS.dWidths[2]
				else GS.savedVars.widths[2] = 0 end
			end,
			warning = "Requires a reloadUI to apply!",
			width = "half",
        },
		{
            type = "checkbox",
            name = "Race",
            tooltip = "Show race",
			default = true,
			getFunc = function() return (GS.savedVars.widths[3] ~= 0) end,
            setFunc = function(x)
				if x == true then GS.savedVars.widths[3] = GS.dWidths[3]
				else GS.savedVars.widths[3] = 0 end
			end,
			warning = "Requires a reloadUI to apply!",
			width = "half",
        },
		{
            type = "checkbox",
            name = "Rank",
            tooltip = "Show alliance rank",
			default = true,
			getFunc = function() return (GS.savedVars.widths[4] ~= 0) end,
            setFunc = function(x)
				if x == true then GS.savedVars.widths[4] = GS.dWidths[4]
				else GS.savedVars.widths[4] = 0 end
			end,
			warning = "Requires a reloadUI to apply!",
			width = "half",
        },
		{
            type = "checkbox",
            name = "Gender",
            tooltip = "Show gender",
			default = true,
			getFunc = function() return (GS.savedVars.widths[5] ~= 0) end,
            setFunc = function(x)
				if x == true then GS.savedVars.widths[5] = GS.dWidths[5]
				else GS.savedVars.widths[5] = 0 end
			end,
			warning = "Requires a reloadUI to apply!",
			width = "half",
        },
		{
            type = "checkbox",
            name = "Status",
            tooltip = "Show indicators for combat, death, and support range",
			default = true,
			getFunc = function() return (GS.savedVars.widths[6] ~= 0) end,
            setFunc = function(x)
				if x == true then GS.savedVars.widths[6] = GS.dWidths[6]
				else GS.savedVars.widths[6] = 0 end
			end,
			warning = "Requires a reloadUI to apply!",
			width = "half",
        },
		{
            type = "checkbox",
            name = "Social",
            tooltip = "Show indicators for friend or ignored",
			default = true,
			getFunc = function() return (GS.savedVars.widths[7] ~= 0) end,
            setFunc = function(x)
				if x == true then GS.savedVars.widths[7] = GS.dWidths[7]
				else GS.savedVars.widths[7] = 0 end
			end,
			warning = "Requires a reloadUI to apply!",
			width = "half",
        },
		{
			type = "button",
			name = "Reload UI",
			func = function() ReloadUI() end,
		},
	}
	
	
	LAM2:RegisterOptionControls("GroupSpy", optionsData)

end

SCENE_MANAGER:GetScene("groupMenuKeyboard"):RegisterCallback("StateChange", GS.OnSceneChange)
EVENT_MANAGER:RegisterForEvent(GS.name, EVENT_ADD_ON_LOADED, GS.AddonLoaded)
-- EVENT_MANAGER:RegisterForEvent("GroupSpy", EVENT_UNIT_CREATED, RegisterDelayedRefreshOnUnitEvent)
-- EVENT_MANAGER:RegisterForEvent("GroupSpy", EVENT_UNIT_DESTROYED, RegisterDelayedRefreshOnUnitEvent)
EVENT_MANAGER:RegisterForEvent(GS.name, EVENT_GROUP_MEMBER_JOINED, GS.OnEvent)
EVENT_MANAGER:RegisterForEvent(GS.name, EVENT_GROUP_MEMBER_LEFT, GS.OnEvent)
EVENT_MANAGER:RegisterForEvent(GS.name, EVENT_LEVEL_UPDATE, GS.OnEvent)
EVENT_MANAGER:RegisterForEvent(GS.name, EVENT_CHAMPION_POINT_UPDATE, GS.OnEvent)
EVENT_MANAGER:RegisterForEvent(GS.name, EVENT_ZONE_UPDATE, GS.OnEvent)
EVENT_MANAGER:RegisterForEvent(GS.name, EVENT_GROUP_MEMBER_ROLE_CHANGED, GS.OnEvent)
EVENT_MANAGER:RegisterForEvent(GS.name, EVENT_GROUP_MEMBER_CONNECTED_STATUS, GS.OnEvent)
EVENT_MANAGER:RegisterForEvent(GS.name, EVENT_LEADER_UPDATE, GS.OnEvent)
EVENT_MANAGER:RegisterForEvent(GS.name, EVENT_GROUP_UPDATE, GS.OnEvent)
EVENT_MANAGER:RegisterForEvent(GS.name, EVENT_PLAYER_ACTIVATED, GS.OnEvent)
EVENT_MANAGER:RegisterForEvent(GS.name, EVENT_GROUP_MEMBER_ACCOUNT_NAME_UPDATED, GS.OnEvent)