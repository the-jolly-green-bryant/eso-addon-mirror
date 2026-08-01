local GS = GetString


local function updateRoleColor()
	if not CSPS.role or CSPS.role == LFG_ROLE_INVALID then CSPSWindowRoleIcon:SetColor(CSPS.colors.white:UnpackRGB()) return end
	if CSPS.role == GetSelectedLFGRole() then
		CSPSWindowRoleIcon:SetColor(CSPS.colors.green:UnpackRGB())
	else
		CSPSWindowRoleIcon:SetColor(CSPS.colors.orange:UnpackRGB())
	end
end

function CSPS.showRole()
	CSPS.role = CSPS.role or LFG_ROLE_INVALID
	local roleIcons = {
		[LFG_ROLE_DPS] = "lfg_roleicon_dps",  
		[LFG_ROLE_HEAL] = "lfg_roleicon_healer",   
		[LFG_ROLE_TANK] = "lfg_roleicon_tank",
		[LFG_ROLE_INVALID] = "lfg_menuicon_currentgroup"
	}
	CSPSWindowRoleIcon:SetTexture(string.format("esoui/art/lfg/gamepad/%s.dds", roleIcons[CSPS.role] or roleIcons[LFG_ROLE_INVALID]))
	updateRoleColor()
end

function CSPS.showRoleTooltip(control)
	ZO_Tooltips_ShowTextTooltip(control, RIGHT, (not CSPS.role or CSPS.role == LFG_ROLE_INVALID) and GS(SI_ALLIANCE0) or GS("SI_LFGROLE", CSPS.role))
end

function CSPS.applyRole()
	if CanUpdateSelectedLFGRole() and CSPS.role and CSPS.role ~= LFG_ROLE_INVALID then 
		UpdateSelectedLFGRole(CSPS.role) 

		PREFERRED_ROLES:RefreshRoles()
		ZO_ACTIVITY_FINDER_ROOT_MANAGER:UpdateLocationData()
		if GROUP_FINDER_KEYBOARD then 
			GROUP_FINDER_KEYBOARD.applicationsManagementContent:RefreshListing() 
		elseif GROUP_FINDER_APPLICATION_LIST_SCREEN_GAMEPAD then
			GROUP_FINDER_APPLICATION_LIST_SCREEN_GAMEPAD:RefreshListing()
		end
		PREFERRED_ROLES:FireCallbacks("LFGRoleChanged")
	end
end

function CSPS.changeRole()
	local groupRoles = {LFG_ROLE_DPS,  LFG_ROLE_HEAL,  LFG_ROLE_TANK}
	
	ClearMenu()
	for _, role in ipairs(groupRoles) do
		AddCustomMenuItem(GS("SI_LFGROLE", role), 
			function() 
				CSPS.role = role
				CSPS.showRole()
			end)
	end
	AddCustomMenuItem(GS(SI_ALLIANCE0), function() CSPS.role = LFG_ROLE_INVALID CSPS.showRole() end) 
	AddCustomMenuItem("-", function() end) 
	AddCustomMenuItem(GS(SI_APPLY), CSPS.applyRole)
	ShowMenu() 
end


function CSPS.getCurrentRole()
	CSPS.role = GetSelectedLFGRole()
	CSPS.showRole()
end

function CSPS.InitializeRoleMenu()
	CSPS.getCurrentRole()
	EVENT_MANAGER:RegisterForEvent(CSPS.name.."_RoleChange", EVENT_GROUP_MEMBER_ROLE_CHANGED, function(_, unitTag, newRole)
		if unitTag == "player" then updateRoleColor() end
	end)
	
	PREFERRED_ROLES:RegisterCallback("LFGRoleChanged", updateRoleColor)
end

-- UpdateSelectedLFGRole(*[LFGRole|#LFGRole]* _role_)
-- GetSelectedLFGRole()