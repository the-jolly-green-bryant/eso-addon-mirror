HideGroup = HideGroup or {}
local HG = HideGroup
local EM = GetEventManager()

HG.name = "HideGroup"
HG.version = "2.1"

local function hideMembers(enable)
	if enable == true then
		SetCrownCrateNPCVisible(true)
		-- Only override if the hide state has changed. Otherwise, when they turn it off, it will load the no show options
		if HG.savedVariables.HideState ~= enable then
			d("Hide Group: Hiding group members")
			HG.savedVariables.GroupMemberNameplates = GetSetting(SETTING_TYPE_NAMEPLATES, NAMEPLATE_TYPE_GROUP_MEMBER_NAMEPLATES)
			HG.savedVariables.GroupMemberHealthBars = GetSetting(SETTING_TYPE_NAMEPLATES, NAMEPLATE_TYPE_GROUP_MEMBER_HEALTHBARS)
		end
		SetSetting(SETTING_TYPE_NAMEPLATES, NAMEPLATE_TYPE_GROUP_MEMBER_NAMEPLATES, tostring(NAMEPLATE_CHOICE_NEVER))
		SetSetting(SETTING_TYPE_NAMEPLATES, NAMEPLATE_TYPE_GROUP_MEMBER_HEALTHBARS, tostring(NAMEPLATE_CHOICE_NEVER))
	else
		SetCrownCrateNPCVisible(false)
		if HG.savedVariables.HideState ~= enable then
			d("Hide Group: Showing group members")
			SetSetting(SETTING_TYPE_NAMEPLATES, NAMEPLATE_TYPE_GROUP_MEMBER_NAMEPLATES, tostring(HG.savedVariables.GroupMemberNameplates))
			SetSetting(SETTING_TYPE_NAMEPLATES, NAMEPLATE_TYPE_GROUP_MEMBER_HEALTHBARS, tostring(HG.savedVariables.GroupMemberHealthBars))
		end
	end
	HG.savedVariables.HideState = enable
end

local function sCommand(opt)
	if opt == "true" or opt == "1" then
		hideMembers(true)
	elseif opt == "false" or opt == "0" then
		hideMembers(false)
	elseif opt == nil or opt == "" then
		hideMembers(not HG.savedVariables.HideState)
	else
		hideMembers(false)
	end
end

function HG.toggleHide()
	hideMembers(not HG.savedVariables.HideState)
end

function HG.init(e, addon)
	if addon ~= HG.name then return end
	EM:UnregisterForEvent(HG.name.."Load", EVENT_ADD_ON_LOADED)
	HG.defaults = {
		["GroupMemberNameplates"] = GetSetting(SETTING_TYPE_NAMEPLATES, NAMEPLATE_TYPE_GROUP_MEMBER_NAMEPLATES),
		["GroupMemberHealthBars"] = GetSetting(SETTING_TYPE_NAMEPLATES, NAMEPLATE_TYPE_GROUP_MEMBER_HEALTHBARS),
		["HideState"] = false,
	}
	HG.savedVariables = ZO_SavedVars:New("HideGroupSavedVars", 1, nil, HG.defaults, GetWorldName())
	ZO_CreateStringId('SI_BINDING_NAME_HIDEGROUP_TOGGLE', 'Show/Hide Group Members')
	SLASH_COMMANDS["/hidegroup"] = sCommand
	EM:RegisterForEvent(HG.name.."PlayerActivated", EVENT_PLAYER_ACTIVATED, function()
		if HG.savedVariables.HideState then
			hideMembers(HG.savedVariables.HideState)
		end
	end) -- For after porting

end

EM:RegisterForEvent(HG.name.."Load", EVENT_ADD_ON_LOADED, HG.init)
