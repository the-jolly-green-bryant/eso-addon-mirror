KalsCrown = {
	name = "KalsCrown",

	defaults = {
		enabled = true,
		showSelf = true,
		showEveryone = true,
		showLeader = true,
		showHealers = true,
		showTanks = true,

		highlightSelf = false,
		highlightEveryone = false,
		highlightLeader = true,
		highlightHealers = false,
		highlightTanks = false,

		selfSize = 75,
		generalSize = 75,
		leaderSize = 75,
		healerSize = 75,
		tankSize = 75,

		selfOffset = 350,
		generalOffset = 350,
		leaderOffset = 350,
		healerOffset = 350,
		tankOffset = 350,
	},

	roleIcons = {
		[LFG_ROLE_DPS] = "/esoui/art/lfg/lfg_icon_dps.dds",
		[LFG_ROLE_TANK] = "/esoui/art/lfg/lfg_icon_tank.dds",
		[LFG_ROLE_HEAL] = "/esoui/art/lfg/lfg_icon_healer.dds",
		[LFG_ROLE_INVALID] = "esoui/art/icons/mapkey/mapkey_groupleader.dds",
	},

	icons = {},
	animated = {},
	members = {},

	topControl = nil,
	window = nil,
}

local MemberIcon = KalsCrown.members

function KalsCrown.OnAddOnLoaded( eventCode, addonName )
	if (addonName ~= KalsCrown.name) then return end

	--KalsCrown.vars = ZO_SavedVars:NewCharacterIdSettings("KalsCrownSavedVariables", 1, nil, KalsCrown.defaults, GetWorldName())
	KalsCrown.vars = ZO_SavedVars:NewAccountWide("KalsCrownSavedVariables", 1, nil, KalsCrown.defaults, nil, "$InstallationWide")
	KalsCrown.CreateUI()
	KalsCrown.setupMenu()

	EVENT_MANAGER:UnregisterForEvent(KalsCrown.name, EVENT_ADD_ON_LOADED)
	EVENT_MANAGER:RegisterForEvent(KalsCrown.name, EVENT_PLAYER_ACTIVATED, KalsCrown.CheckActivation)
	EVENT_MANAGER:RegisterForEvent(KalsCrown.name.."Group", EVENT_GROUP_UPDATE, KalsCrown.UpdateGroup)
	EVENT_MANAGER:RegisterForEvent(KalsCrown.name.."RoleChange", EVENT_GROUP_MEMBER_ROLE_CHANGED, KalsCrown.RoleChanged)
end

function KalsCrown.RoleChanged(eventCode, tag, role)
	if(MemberIcon[tag]) then
		KalsCrown.RebuildMemberData(KalsCrown.window, tag)
		if(IsUnitPlayer(tag)) then
			KalsCrown.RebuildMemberData(KalsCrown.window, "player")
		end
	end
end

function KalsCrown.UpdateGroup()
	local groupSize = GetGroupSize()
	for i = 0, GROUP_SIZE_MAX do
		local tag = "group"..i
		if(i == 0) then
			tag = "player"
		end
		if(not MemberIcon[tag]) then
			MemberIcon[tag] = {}
		end
		if(i <= groupSize) then
			if(tag == "player" or not AreUnitsEqual("player", tag)) then
				MemberIcon[tag].unit = tag
				MemberIcon[tag].active = true
				KalsCrown.RebuildMemberData(KalsCrown.window, tag)
			else
				if(MemberIcon[tag].control) then
					MemberIcon[tag].control:SetHidden(true)
					MemberIcon[tag].highlight:SetHidden(true)
				end
			end
		else
			if(MemberIcon[tag].control) then
				MemberIcon[tag].control:SetHidden(true)
				MemberIcon[tag].highlight:SetHidden(true)
			end
		end
	end
	KalsCrown.RebuildMemberData(KalsCrown.window, "player")
end

function KalsCrown.ReloadGroup()
	for i = 0, GetGroupSize() do
		local tag = "group"..i
		if(i == 0) then
			tag = "player"
		end
		if(MemberIcon[tag]) then
			if(tag == "player" or not AreUnitsEqual("player", tag)) then
				KalsCrown.FindMemberInfo(tag)
			end
		end
	end
end

-- Returns ifAnim, Icon
function KalsCrown.GetIcon(user, role)
	local static = KalsCrown.icons[user] or HodorReflexes.player.GetIconForUserId(user)
	local anim = KalsCrown.animated[user] or HodorReflexes.anim.users[user]
	if(anim) then
		return true, anim
	else
		return false, static or KalsCrown.roleIcons[role]
	end
end

function KalsCrown.CreateUI()
	local window = GetWindowManager()
	KalsCrown.topControl = window:CreateControl("KalsCrownTopControl", GuiRoot, CT_CONTROL)
	KalsCrown.topControl:Create3DRenderSpace()

	KalsCrown.window = window:CreateTopLevelWindow("KalsCrownWindow")
	KalsCrown.window:SetClampedToScreen(true)
	KalsCrown.window:SetMouseEnabled(false)
	KalsCrown.window:SetMovable(false)
	KalsCrown.window:ClearAnchors()
	KalsCrown.window:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
	KalsCrown.window:SetDimensions(GuiRoot:GetWidth(), GuiRoot:GetHeight())
	KalsCrown.window:SetDrawLayer(0)
	KalsCrown.window:SetDrawLevel(0)
	KalsCrown.window:SetDrawTier(0)

	local frag = ZO_HUDFadeSceneFragment:New(KalsCrown.window)
	HUD_UI_SCENE:AddFragment(frag)
	HUD_SCENE:AddFragment(frag)
end

function KalsCrown.onUpdate()
	local matrix = {}
	local dims = {}
	local zorder = {}
	local ztotal = 0
	Set3DRenderSpaceToCurrentCamera( KalsCrown.topControl:GetName() )
	-- Math I don't really fully understand, credit: @Lamierina7
	local cX, cY, cZ = GuiRender3DPositionToWorldPosition(KalsCrown.topControl:Get3DRenderSpaceOrigin())
	local fX, fY, fZ = KalsCrown.topControl:Get3DRenderSpaceForward()
	local rX, rY, rZ = KalsCrown.topControl:Get3DRenderSpaceRight()
	local uX, uY, uZ = KalsCrown.topControl:Get3DRenderSpaceUp()
	matrix.i11 = -( uY * fZ - uZ * fY )
	matrix.i12 = -( rZ * fY - rY * fZ )
	matrix.i13 = -( rY * uZ - rZ * uY )
	matrix.i21 = -( uZ * fX - uX * fZ )
	matrix.i22 = -( rX * fZ - rZ * fX )
	matrix.i23 = -( rZ * uX - rX * uZ )
	matrix.i31 = -( uX * fY - uY * fX )
	matrix.i32 = -( rY * fX - rX * fY )
	matrix.i33 = -( rX * uY - rY * uX )
	matrix.i41 = -( uZ * fY * cX + uY * fX * cZ + uX * fZ * cY - uX * fY * cZ - uY * fZ * cX - uZ * fX * cY )
	matrix.i42 = -( rX * fY * cZ + rY * fZ * cX + rZ * fX * cY - rZ * fY * cX - rY * fX * cZ - rX * fZ * cY )
	matrix.i43 = -( rZ * uY * cX + rY * uX * cZ + rX * uZ * cY - rX * uY * cZ - rY * uZ * cX - rZ * uX * cY )
	-- Dimensions of the GUI
	dims.uiW, dims.uiH = GuiRoot:GetDimensions()
	local groupSize = GetGroupSize()
	for i = 1, GROUP_SIZE_MAX do
		local tag = "group" .. i
		if(i <= groupSize) then
			local z, control = KalsCrown.UpdateMemberIcon(matrix, dims, KalsCrown.window, tag)
			z = zo_floor(z)
			if(z >= 0) then
				zorder[1 + z] = control
				ztotal = ztotal+1
			end
		else
			if(MemberIcon[tag]) then
				if(MemberIcon[tag].control) then
					MemberIcon[tag].control:SetHidden(true)
				end
			end
		end
	end

	-- Remove
	local z, control = KalsCrown.UpdateMemberIcon(matrix, dims, KalsCrown.window, "player")
	if(z >= 0) then
		zorder[1 + z] = control
		ztotal = ztotal+1
	end

	if(ztotal > 0) then
		local keys = {}
		for k in pairs(zorder) do
			table.insert(keys, k)
		end
		table.sort(keys)
		for _, k in ipairs(keys) do
			zorder[k]:SetDrawLevel(ztotal)
			ztotal = ztotal-1
		end
	end

end

function KalsCrown.StartUpdating()
	EVENT_MANAGER:UnregisterForUpdate(KalsCrown.name.."Update")
	EVENT_MANAGER:RegisterForUpdate(KalsCrown.name.."Update", 10, KalsCrown.onUpdate)
	KalsCrown.onUpdate()
end

function KalsCrown.CheckActivation(eventCode)
	--local id = GetUnitDisplayName(GetGroupLeaderUnitTag())
	--local icon = KalsCrown.GetIcon(id)
	--SetFloatingMarkerInfo(MAP_PIN_TYPE_GROUP_LEADER, 50, icon)

	KalsCrown.UpdateGroup()
	KalsCrown.StartUpdating()
end

SLASH_COMMANDS["/kalscrown"] = function()
	KalsCrown.UpdateGroup()
	KalsCrown.StartUpdating()
end

EVENT_MANAGER:RegisterForEvent(KalsCrown.name, EVENT_ADD_ON_LOADED, KalsCrown.OnAddOnLoaded)
