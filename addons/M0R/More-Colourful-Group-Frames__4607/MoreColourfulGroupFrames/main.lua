-- for the dead status, look at https://github.com/esoui/esoui/blob/8158526eb4a7c050257898774874d25714191ba1/esoui/ingame/unitframes/unitframes.lua#L1819
MoreColourfulGroupFrames = {}
MoreColourfulGroupFrames.name = "MoreColourfulGroupFrames"

local function loadAddon()
	local defaultVars = {
		colours = {
			[LFG_ROLE_TANK] = {"4bacc6", "205867"}, -- light blue preset
			[LFG_ROLE_HEAL] = {"D37B00", "FCBD00"}, -- yellow preset
			[LFG_ROLE_DPS] = {"722323", "da3030"}, -- red preset
			[LFG_ROLE_INVALID] = {"AD72FF", "7438D2"}, -- purple preset
			Companion = {"006666", "009966"}, -- green preset
			Player = {"FF7DD2", "DC258D"}, -- pink
		},
		showResStatus = true,
		colourizeResStatus = true,
		resDeadColour = "ff0000",
		beingRessedColour = "ffff00",
		resPendingColour = "00ff00",
		uniquePlayerRoleColour = false,
	}
	local vars = ZO_SavedVars:NewAccountWide("MoreColourfulGroupFramesVars", 1, nil, defaultVars, nil, "$InstallationWide")

	local grads = {}
	for i,v in pairs(vars.colours) do
		grads[i] = {ZO_ColorDef:New(v[1]), ZO_ColorDef:New(v[2])}
	end 

	local resColours = {
		dead = ZO_ColorDef:New(vars.resDeadColour),
		beingRessed = ZO_ColorDef:New(vars.beingRessedColour),
		pending = ZO_ColorDef:New(vars.resPendingColour),
	}

	local deadText = GetString(SI_UNIT_FRAME_STATUS_DEAD)
	local beingRessedText = "Being Ressed"
	local pendingText = "Res Pending"

	if vars.colourizeResStatus then resColours.deadText = resColours.dead:Colorize(deadText) else resColours.deadText = deadText end
	if vars.colourizeResStatus then resColours.beingRessedText = resColours.beingRessed:Colorize(beingRessedText) else resColours.beingRessedText = beingRessedText end
	if vars.colourizeResStatus then resColours.pendingText = resColours.pending:Colorize(pendingText) else resColours.pendingText = pendingText end




	local function setColour(groupFrame, grad)
		groupFrame.healthBar:SetColor(COMBAT_MECHANIC_FLAGS_HEALTH, grad)

		for i,v in pairs(groupFrame.attributeVisualizer.visualModules) do
			local fakeHealthGradient = grad
			v.layoutData.fakeHealthGradientOverride = fakeHealthGradient
			if v.attributeInfo and v.attributeInfo[ATTRIBUTE_HEALTH] and v.attributeInfo[ATTRIBUTE_HEALTH].overlayControls then
				for _, overlay in pairs(v.attributeInfo[ATTRIBUTE_HEALTH].overlayControls) do
					-- TODO: add the other stuff from https://github.com/esoui/esoui/blob/live/esoui/ingame/unitattributevisualizer/modules/powershield.lua#L186
					ZO_StatusBar_SetGradientColor(overlay.fakeHealthBar, fakeHealthGradient)
				end
			end
		end
	end

	SecurePostHook(ZO_UnitFrameObject, "UpdatePowerBar", function(self, index, powerType, cur, max, forceInit) 
		if not powerType == COMBAT_MECHANIC_FLAGS_HEALTH then return end
		if self.style == "ZO_CompanionRaidUnitFrame" or self.style == "ZO_CompanionUnitFrame" or self.style == "ZO_CompanionGroupUnitFrame" then -- or ZO_CompanionUnitFrame
			-- update companion stuff here
			setColour(self, grads["Companion"])
		elseif self.style == "ZO_RaidUnitFrame" or self.style == "ZO_GroupUnitFrame" then -- or ZO_GroupUnitFrame
			local role = GetGroupMemberSelectedRole(self.unitTag)
			if vars.uniquePlayerRoleColour and AreUnitsEqual(self.unitTag, 'player') then
				role = "Player"
			end
			local grad = grads[role]
			setColour(self, grad)
		end
	end)

	EVENT_MANAGER:RegisterForEvent("MoreColourfulGroupFrames", EVENT_GROUP_MEMBER_ROLE_CHANGED, function(_, unitTag, role)
		if vars.uniquePlayerRoleColour and AreUnitsEqual(unitTag, 'player') then
			role = "Player"
		end
		local grad = grads[role]
		if UNIT_FRAMES then
			local frame = UNIT_FRAMES:GetFrame(unitTag)
			if frame and grad then
				setColour(frame, grad)
			end
		end
	end)
	


	-- dead status stuff
	local function setStatusText(self) -- maybe not the most efficient way, but its prob fine
		local statusLabel = self.statusLabel
		if statusLabel then
			local beingRessed = IsUnitBeingResurrected(self.unitTag)
			local isResPending = DoesUnitHaveResurrectPending(self.unitTag)
			if beingRessed then
				statusLabel:SetText(resColours.beingRessedText)
			elseif isResPending then
				statusLabel:SetText(resColours.pendingText)
			else
				statusLabel:SetText(resColours.deadText)
			end
		end
	end



	local function deathloop(self)
		if (not DoesUnitExist(self.unitTag)) or (not vars.showResStatus) then
			EVENT_MANAGER:UnregisterForUpdate("MoreColourfulGroupFrames Res " .. self.unitTag)
			return
		end
		if IsUnitDead(self.unitTag) then
			setStatusText(self)
		else
			EVENT_MANAGER:UnregisterForUpdate("MoreColourfulGroupFrames Res " .. self.unitTag)
		end
	end


	SecurePostHook(ZO_UnitFrameObject, "UpdateStatus", function(self, isDead, isOnline, isPending) 
		if not vars.showResStatus then return end
		if isDead then
			setStatusText(self)
			EVENT_MANAGER:RegisterForUpdate("MoreColourfulGroupFrames Res "..self.unitTag, 100, function() deathloop(self) end)
		else
			EVENT_MANAGER:UnregisterForUpdate("MoreColourfulGroupFrames Res " .. self.unitTag)
		end
	end)

	if LibAddonMenu2 then MoreColourfulGroupFrames.createSettings(vars, grads, resColours) end
	MoreColourfulGroupFrames.vars = vars

end

EVENT_MANAGER:RegisterForEvent("MoreColourfulGroupFrames", EVENT_ADD_ON_LOADED, function(event, addonName)
	if addonName ~= "MoreColourfulGroupFrames" then return end
	EVENT_MANAGER:UnregisterForEvent("MoreColourfulGroupFrames", EVENT_ADD_ON_LOADED)
	loadAddon()
end)