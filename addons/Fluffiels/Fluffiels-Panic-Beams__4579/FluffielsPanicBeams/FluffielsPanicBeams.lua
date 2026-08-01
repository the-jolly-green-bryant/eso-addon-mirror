local LAM2
local LCM
local AddonVersion = '1.09'
local addonName = "FluffielsPanicBeams"
local FPBLib = FLUFFIELS_PANICBEAMS

local FPB = {
	defaultSettings = {
		Mode = 'Satnav',
		Colors = 'Green Orange Red',
		MinAlpha = 0.5,
		MaxAlpha = 0.9,
		MinSize = 50,
		MaxSize = 60,
		MinDistance = 0,
		MaxDistance = 128,
		RangeLimit = false,
		CloseIcon = false,
		Sound = 'NONE',
		ArrowEnabled = true,
		FollowTheCrown = true,
		ISeeDeadPeople = true,
		LowHPBeam = true,
		LowHPThreshold = 50,

		LeaderArrowSize = false,
		LeaderArrowDistance = false,
		LeaderArrowNumeric = false,
	},
	
	Settings = nil,
	MAX_GROUP_BEAMS = 11,
	CYRO_MAX_DISTANCE = 0.015,
	groupBeams = {},
	
	state = {
		Hidden = true,
		SetCloseIcon = false,
		debug = false,
		NextPlayer = '',
		BFF = nil,

		Angle = 0,
		Linear = 0,
		AbsoluteLinear = 0,
		DX = 0,
		DY = 0,

		Color = { R = 1, G = 1, B = 1 },
		Alpha = 0,
		Size = 0,

		Colors = nil,
		Mode = nil,

		Leader = nil,
		Player = nil,

		Constants = {
			GameReticleSize = 58
		},
	},
}
FPBLib.state = FPB.state

function FPB.OnPluginLoaded(event, addon)
	if addon ~= addonName then return end

    FPB.Settings = ZO_SavedVars:New("FluffielsPanicBeamsVars", 1, nil, FPB.defaultSettings)
	
	LAM2 = LibAddonMenu2
	
    FPB.CreateSettingsMenu()
    FPB.ChangeMode(FPB.Settings.Mode)
    FPB.ChangeColors(FPB.Settings.Colors)
    FPB.InitializePlugin()
	
	EVENT_MANAGER:RegisterForEvent(addonName, EVENT_GROUP_MEMBER_LEFT, FPB.OnPlayerLeft)
	
	EVENT_MANAGER:RegisterForUpdate(addonName, 0, FPB.Update)
	
	EVENT_MANAGER:RegisterForEvent("FluffielsPanicBeamsHP", EVENT_POWER_UPDATE,
		function(_, unitTag, _, powerType, current, max)
			if FPB.Settings == nil then return end
			if powerType ~= POWERTYPE_HEALTH then return end
			FPB.UpdateGroupBeams()
		end
	)
	EVENT_MANAGER:AddFilterForEvent("FluffielsPanicBeamsHP", EVENT_POWER_UPDATE,
		REGISTER_FILTER_UNIT_TAG_PREFIX, "group"
	)
	EVENT_MANAGER:RegisterForEvent("FluffielsPanicBeamsDeath", EVENT_UNIT_DEATH_STATE_CHANGED,
		function(_, unitTag, isDead)
			if FPB.Settings == nil then return end
			FPB.UpdateGroupBeams()
		end
	)
	EVENT_MANAGER:AddFilterForEvent("FluffielsPanicBeamsDeath", EVENT_UNIT_DEATH_STATE_CHANGED,
		REGISTER_FILTER_UNIT_TAG_PREFIX, "group"
	)
	
	LCM = LibCustomMenu
    if LCM then
        LCM:RegisterGroupListContextMenu(FPB.OnContextMenu, LCM.CATEGORY_LATE)
    end
	
	SLASH_COMMANDS["/crown"] = function()
		FPB.Settings.FollowTheCrown = not FPB.Settings.FollowTheCrown
		if FPB.Settings.FollowTheCrown then
			d("Follow The Crown: ON")
		else
			d("Follow The Crown: OFF")
		end
		FPB.UpdateGroupBeams()
	end
	
	SLASH_COMMANDS["/lowhp"] = function()
		FPB.Settings.LowHPBeam = not FPB.Settings.LowHPBeam
		if FPB.Settings.LowHPBeam then
			d("Low HP Beams: ON")
		else
			d("Low HP Beams: OFF")
		end
		FPB.UpdateGroupBeams()
	end
	
	SLASH_COMMANDS["/bff"] = function()
		FPB.state.BFF = nil
		d("Removed Beam Friend Forever")
	end

end

function FPB.OnContextMenu(data)
	if not data or not data.displayName then return end
	
	local unitTag = FPB.GetUnitTag(data.displayName)
	if not unitTag then return end
	if unitTag == 'player' then return end
	
	if FPB.state.BFF == nil or FPB.state.BFF ~= unitTag then
		AddCustomMenuItem("Set Beam Friend Forever", function() FPB.state.BFF = unitTag end)
	else
		AddCustomMenuItem("Remove Beam Friend Forever", function() FPB.state.BFF = nil end)
	end
end

-- **************** UTILS ****************

function FPB.GetUnitTag(displayName)
    for i = 1, GetGroupSize() do
        local unitTag = GetGroupUnitTagByIndex(i)
        if GetUnitDisplayName(unitTag) == displayName then
            return unitTag
        end
    end
    return nil
end
FPBLib.GetUnitTag = FPB.GetUnitTag

function FPB.NormalizeAngle(c)
    if c > math.pi then return c - 2 * math.pi end
    if c < -math.pi then return c + 2 * math.pi end
    return c
end

function FPB.UpdatePlayerEntity(entity)
    if entity == nil then return end

    entity.X, entity.Y, entity.Z = GetMapPlayerPosition(entity.Tag)
    entity.Zone = GetUnitZone(entity.Tag)
    entity.Name = GetUnitName(entity.Tag)
end

function FPB.CheckLeader()
    if FPB.state.Leader and FPB.state.Leader.Custom then return end

	local newLeader = GetGroupLeaderUnitTag()
    if newLeader == nil or newLeader == '' then
        FPB.state.Leader = nil
    elseif FPB.state.Leader == nil or FPB.state.Leader.Tag ~= newLeader then
        FPB.state.Leader = {
            Tag = newLeader
        }
    end
end

function FPB.UpdateReticle()
    if FPB.state.Player == nil then return end
	
    if (FPB.state.Leader == nil) or ZO_ReticleContainer:IsHidden() or (not IsUnitGrouped('player')) then
		
    else
        FPB.state.DX = FPB.state.Player.X - FPB.state.Leader.X
        FPB.state.DY = FPB.state.Player.Y - FPB.state.Leader.Y
        FPB.state.D = math.sqrt((FPB.state.DX * FPB.state.DX) + (FPB.state.DY * FPB.state.DY))

        FPB.state.Angle = FPB.NormalizeAngle(FPB.state.Player.H - math.atan2( FPB.state.DX, FPB.state.DY ))
        FPB.state.Linear = FPB.state.Angle / math.pi
        FPB.state.AbsoluteLinear = math.abs(FPB.state.Linear)

        FPB.state.Alpha = FPB.Settings.MinAlpha + (FPB.Settings.MaxAlpha - FPB.Settings.MinAlpha) * FPB.state.AbsoluteLinear;

        if FPB.Settings.LeaderArrowSize then
            FPB.state.Size = FPB.Settings.MinSize + (FPB.Settings.MaxSize - FPB.Settings.MinSize) * (math.tanh(FPB.state.D * 40 - 1) + 1.0) / 2.0;
        else
            FPB.state.Size = FPB.Settings.MinSize + (FPB.Settings.MaxSize - FPB.Settings.MinSize) * FPB.state.AbsoluteLinear;
        end
        if FPB.Settings.LeaderArrowDistance then
            FPB.state.Distance = FPB.Settings.MinDistance + (FPB.Settings.MaxDistance - FPB.Settings.MinDistance) * (math.tanh(FPB.state.D * 40 - 1) + 1.0) / 2.0;
        else
            FPB.state.Distance = FPB.Settings.MinDistance + (FPB.Settings.MaxDistance - FPB.Settings.MinDistance) * FPB.state.AbsoluteLinear;
        end
    end

    FPB.state.Colors:Update(FPB.state)
    FPB.state.Mode:Update(FPB.state)
end

function FPB.CreateLight()
    local wm = GetWindowManager()
    for i = 1, FPB.MAX_GROUP_BEAMS do
        local beam = {}
        beam.window = wm:CreateTopLevelWindow("groupBeamPosition" .. i)
        beam.window:SetDrawTier(0)
        beam.window:SetDrawLayer(0)
        beam.window:SetDrawLevel(0)
        beam.texture = wm:CreateControl("groupBeamLight" .. i, beam.window, CT_TEXTURE)
		beam.texture:SetTexture("FluffielsPanicBeams/textures/Beam1.dds")
        beam.window:Create3DRenderSpace()
        beam.texture:Create3DRenderSpace()
        beam.texture:Set3DLocalDimensions(3, 256)
        beam.texture:SetDrawLevel(3)
        beam.texture:SetColor(1, 0.5, 0, 0.8)
        beam.texture:Set3DRenderSpaceUsesDepthBuffer(true)
        beam.texture:SetParent(beam.window)
        beam.window:Set3DRenderSpaceOrigin(0,0,0)
        beam.window:SetHidden(true)
        beam.unitTag = nil
        beam.state = nil
        FPB.groupBeams[i] = beam
    end
end

function FPB.ApplyBeamStyle(beam, beamState)
    if beamState == "dead" then
		beam.texture:SetTexture("FluffielsPanicBeams/textures/Beam2.dds")
        beam.texture:Set3DLocalDimensions(1, 256)
        beam.texture:SetColor(1, 0, 0, 1)
    elseif beamState == "beingRevived" then
		beam.texture:SetTexture("FluffielsPanicBeams/textures/Beam2.dds")
        beam.texture:Set3DLocalDimensions(1, 256)
        beam.texture:SetColor(1, 1, 0, 1)
    elseif beamState == "rezPending" then
		beam.texture:SetTexture("FluffielsPanicBeams/textures/Beam2.dds")
        beam.texture:Set3DLocalDimensions(1, 256)
        beam.texture:SetColor(0, 1, 0, 1)
    elseif beamState == "lowHP" then
		beam.texture:SetTexture("FluffielsPanicBeams/textures/Beam1.dds")
        beam.texture:Set3DLocalDimensions(2, 256)
        beam.texture:SetColor(1, 0.5, 0, 0.8)
    elseif beamState == "leader" then
		beam.texture:SetTexture("FluffielsPanicBeams/textures/Beam1.dds")
        beam.texture:Set3DLocalDimensions(2, 256)
        beam.texture:SetColor(0, 0.5, 1, 0.8)
	elseif beamState == "bff" then
		beam.texture:SetTexture("FluffielsPanicBeams/textures/Beam1.dds")
        beam.texture:Set3DLocalDimensions(2, 256)
        beam.texture:SetColor(0.26, 0.80, 0.96, 0.8)
    end
    beam.state = beamState
end

function FPB.HideAllGroupBeams()
    for i = 1, FPB.MAX_GROUP_BEAMS do
        if FPB.groupBeams[i] then
            FPB.groupBeams[i].window:SetHidden(true)
            FPB.groupBeams[i].unitTag = nil
            FPB.groupBeams[i].state = nil
        end
    end
end

function FPB.CalcGroupBeamPos(beam, unitTag)
    local _, wX, wY, wZ = GetUnitRawWorldPosition(unitTag)
    if wX == nil or wY == nil or wZ == nil then return end

    local rX, rY, rZ = WorldPositionToGuiRender3DPosition(wX, wY, wZ)
    
    beam.window:Set3DRenderSpaceOrigin(0, 0, 0)
    beam.texture:Set3DRenderSpaceOrigin(rX, rY, rZ)

    local heading = GetPlayerCameraHeading()
    if heading > math.pi then
        heading = heading - 2 * math.pi
    end
    beam.texture:Set3DRenderSpaceOrientation(0, heading, 0)
end

function FPB.UpdateGroupBeams()
	if not IsUnitGrouped('player') and not FPB.state.debug then
        FPB.HideAllGroupBeams()
       return
    end

    local threshold = FPB.Settings.LowHPThreshold / 100
    local leaderTag = GetGroupLeaderUnitTag()
    local beamIndex = 1

    for i = 1, GetGroupSize() do
        local unitTag = GetGroupUnitTagByIndex(i)

        if GetUnitName(unitTag) ~= GetUnitName('player') and
           IsUnitOnline(unitTag) and
           GetUnitZone(unitTag) == GetUnitZone('player') then

            local beamState = nil

            if IsUnitDead(unitTag) then
                if FPB.Settings.ISeeDeadPeople then
                    if IsUnitBeingResurrected(unitTag) and FPB.InRange(unitTag) then
						beamState = "beingRevived"
                    elseif DoesUnitHaveResurrectPending(unitTag) and FPB.InRange(unitTag) then
						beamState = "rezPending"
                    else
						if FPB.InRange(unitTag) then 
							beamState = "dead"
						end
                    end
                elseif FPB.Settings.FollowTheCrown and unitTag == leaderTag then
                    beamState = "leader"
                end
            else
                local current, max = GetUnitPower(unitTag, POWERTYPE_HEALTH)
                if FPB.Settings.LowHPBeam and max > 0 and (current / max) < threshold then
					if FPB.InRange(unitTag) then 
						beamState = "lowHP"
					end
                elseif FPB.Settings.FollowTheCrown and unitTag == leaderTag then
                    beamState = "leader"
                elseif FPB.state.BFF ~= nil and unitTag == FPB.state.BFF then
					beamState = "bff"
				end
            end

            if beamState ~= nil and beamIndex <= FPB.MAX_GROUP_BEAMS then
                local beam = FPB.groupBeams[beamIndex]
                beam.unitTag = unitTag
                FPB.ApplyBeamStyle(beam, beamState)
				local ok = pcall(FPB.CalcGroupBeamPos, beam, unitTag)
                if ok then
                    beam.window:SetHidden(false)
                    beamIndex = beamIndex + 1
                else
                    beam.window:SetHidden(true)
                end
            end
        end
    end

    for i = beamIndex, FPB.MAX_GROUP_BEAMS do
        FPB.groupBeams[i].window:SetHidden(true)
        FPB.groupBeams[i].unitTag = nil
        FPB.groupBeams[i].state = nil
    end
	
	if FPB.state.debug then
		local beam = FPB.groupBeams[1]
		beam.unitTag = 'player'
		FPB.ApplyBeamStyle(beam, "leader")
		local ok = pcall(FPB.CalcGroupBeamPos, beam, "player")
		beam.window:SetHidden(false)
	end
end

function FPB.InRange(unitTag)
	if FPB.Settings.RangeLimit then
		if IsInCyrodiil() then
			distance = FPB.CalcDistance(unitTag)
			if ((distance ~= nil) and (distance ~= 0) and (distance > FPB.CYRO_MAX_DISTANCE)) then
				return false
			end
		end
	end
	return true
end

-- **************** EVENTS ****************

-- onUpdate trigger
function FPB.Update()
    if FPB.state.Player == nil then return end

    FPB.GetClosestMember()

    FPB.UpdatePlayerEntity(FPB.state.Player)
    local h = FPB.NormalizeAngle(GetPlayerCameraHeading())
    if h ~= nil then FPB.state.Player.H = h end

    FPB.CheckLeader()
    FPB.UpdatePlayerEntity(FPB.state.Leader)

    if FPB.state.Leader == nil or FPB.state.Leader.X == nil or FPB.state.Leader.Y == nil then FPB.state.Leader = nil end
    if FPB.state.Leader == nil or FPB.state.Leader.Name == FPB.state.Player.Name then FPB.state.Leader = nil end

    FPB.UpdateReticle()

    FPB.UpdateGroupBeams()
end

function FPB.GetClosestMember()
    if not FPB.Settings.ArrowEnabled then
        FPB.state.Hidden = true
        return
    end
    local currentTag
    local currentName
    local currentDistance
    local closestPlayer = ''
    local someoneIsDead = false
    local closestDistance = 1000000
    local maxDistance = 0.1
    local closeDistance = 0.002
	if (IsInAvAZone()) then
        closeDistance = (closeDistance/10)
        maxDistance = (maxDistance/10)
    end

    if IsUnitGrouped('player') then
        for i = 1, GetGroupSize(), 1 do
			currentTag = GetGroupUnitTagByIndex(i)
			currentName = GetUnitName(currentTag)
            if ((IsUnitDead(currentTag) and (not IsUnitBeingResurrected(currentTag)) and
                (not DoesUnitHaveResurrectPending(currentTag)) and (not IsUnitReincarnating(currentTag)) and
                IsUnitOnline(currentTag) and GetUnitZone(currentTag) == GetUnitZone("player") and
                (GetUnitName("player") ~= GetUnitName(currentTag)))) then
				
				currentDistance = FPB.CalcDistance(currentTag)
				if (currentDistance<maxDistance or FPB.Settings.RangeLimit ~= true) and currentDistance ~= 0 and currentDistance ~= nil then
					someoneIsDead = true
					if currentDistance<closestDistance then
						closestPlayer = currentName
						closestDistance = currentDistance
						FPB.state.SetCloseIcon = (currentDistance<closeDistance and FPB.Settings.CloseIcon)
					end
				end
			end
		end
		
		if someoneIsDead and FPB.InRange(currentTag) then
			FPB.state.Hidden = false
		else
			FPB.state.Hidden = true
		end
		
		if (closestPlayer ~= '') and (FPB.state.NextPlayer ~= closestPlayer) then
			FPB.state.NextPlayer = closestPlayer
			FPB.SetCustomLeader(closestPlayer)
		end
		
		-- hide if mouse shown / on menu interface
		if ZO_ReticleContainer:IsHidden() then
			FPB.state.Hidden = true
		end
	end
end

function FPB.CalcDistance(memberTag)

	local playerX, playerY, playerZ = GetMapPlayerPosition('player')
	local memberX, memberY, memberZ = GetMapPlayerPosition(memberTag)
	local calcDX = playerX - memberX
	local calcDY = playerY - memberY

	return math.sqrt((calcDX * calcDX) + (calcDY * calcDY))
end

function FPB.SetCustomLeader(text)
    if not IsUnitGrouped('player') then
        --d("You must be in a group to set a follow target.")
		ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NONE, GetString(SI_GROUPELECTIONFAILURE8))
        return
    end
    if text == "" then
        FPB.state.Leader.Custom = false
    else
        for i = 1, GetGroupSize(), 1 do
            if string.lower(text) == string.lower(GetUnitName(GetGroupUnitTagByIndex(i))) then
                --d("Successfully set '" .. text .. "' as follow target.")
				ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS[FPB.Settings.Sound], zo_strformat("<<1>> <<2>> <<3>>", "Successfully set ", text , " as follow target."))
                FPB.state.Leader = {
                        Tag = GetGroupUnitTagByIndex(i)
                }
                FPB.UpdatePlayerEntity(FPB.state.Leader)
                FPB.state.Leader.Tag = GetGroupUnitTagByIndex(i)
                FPB.state.Leader.Name = GetUnitName(GetGroupUnitTagByIndex(i))
                FPB.state.Leader.Custom = true
            else
                --d("ZERO MATCH ON - ".. text .. " = " .. GetUnitName(GetGroupUnitTagByIndex(i)))
            end
		end
	   if not FPB.state.Leader.Custom then
			--d("Could not find anyone named '" .. text .. "' in your group.")
			ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NONE, zo_strformat("<<1>> <<2>> <<3>>", "Couldn't find ", text , " in your group."))
        end
    end
end

function FPB.OnPlayerLeft(leftmemberName, reason, wasLocalPlayer)
    if not IsUnitGrouped('player') then
		FPB.state.BFF = nil
		return
	end -- Ignore if you just left the group
    if FPB.state.Leader == nil and FPB.state.BFF == nil then return end

    local doesCustomExist = false
	local doesBFFExist = false
    for i = 1, GetGroupSize() , 1 do
        if FPB.state.Leader ~= nil and GetGroupUnitTagByIndex(i) == FPB.state.Leader.Tag then
            doesCustomExist = true
        end
		if FPB.state.BFF ~= nil and GetGroupUnitTagByIndex(i) == FPB.state.BFF then
			doesBFFExist = true
		end
    end
	
	if not doesBFFExist then
		if FPB.state.BFF ~= nil then
			ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NONE, "Your Beam Friend Forever has left the group. Sadge.")
		end
		FPB.state.BFF = nil
	end
	
    if not doesCustomExist then
		ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NONE, "Your follow target has left the group. Now following Rez Target.")
        FPB.state.Leader = nil
    end
end

function FPB.InitializePlugin()
    FPB.state.Player = {
        Tag = 'player'
    }
	FPB.CreateLight()
end

function FPB.ChangeMode(value)
    FPB.Settings.Mode = value
    if FPB.state.Mode then FPB.state.Mode:Unit() end
    FPB.state.Mode = FPBLib.Modes[value]
    FPB.state.Mode.Init()
end

function FPB.ChangeColors(value)
    FPB.Settings.Colors = value
    if FPB.state.Colors then FPB.state.Colors:Unit() end
    FPB.state.Colors = FPBLib.Colors[value]
    FPB.state.Colors.Init()
end

function FPB.CreateSettingsMenu()
	if LAM2 == nil then return end
	
	local colorCyan    = "|c42cbf4"
	local colorBlue    = "|c0066ff"
	local colorRed     = "|cff2200"
	local colorYellow  = "|cffdd00"
	local colorGreen   = "|c44ff44"
	local colorGrey    = "|ccccccc"
	local colorOrange  = "|cff6600"
	local colorDefault    = "|r"

	local panelData = {
		type = "panel",
		name = "Fluffiels' Panic Beams",
		displayName = colorCyan.."Fluffiels' Panic Beams",
		author = "@Fluffiels",
		version = AddonVersion,
		slashCommand = "/fluffielsPanicBeams",
		registerForRefresh = true,
		registerForDefaults = true,
	}
	local cntrlOptionsPanel = LAM2:RegisterAddonPanel("FluffielsPanicBeams_Options", panelData)

	local optionsData = {
		{
			type = "description",
			text = "This addon will help you find group members easily in different situations.",
		},
		{
			type = "header",
			name = "General Settings",
		},
		{
			type = "checkbox",
			name = "Arrow",
			tooltip = "Enable or disable the arrow.",
			default = true,
			getFunc = function() return FPB.Settings.ArrowEnabled end,
			setFunc = function(bValue) FPB.Settings.ArrowEnabled = bValue end
		},
		{
			type = "description",
			text = "An arrow that shows the direction of the closest dead group member.",
		},
		{
			type = "divider",
		},
		{
            type = "checkbox",
            name = "Follow The Crown",
            tooltip = "Enable or disable the blue beam. Slash command to toggle: /crown",
            default = true,
            getFunc = function() return FPB.Settings.FollowTheCrown end,
            setFunc = function(value)
                FPB.Settings.FollowTheCrown = value
                FPB.UpdateGroupBeams()
            end,
        },
		{
			type = "description",
			text = "Shows a " .. colorBlue .. "blue" .. colorDefault .. " beam that will follow the group leader at all times. /crown to toggle.",
		},
		{
			type = "divider",
		},
		{
            type = "checkbox",
            name = "I See Dead People",
            tooltip = "Enable or disable dead group members beams.",
            default = true,
            getFunc = function() return FPB.Settings.ISeeDeadPeople end,
            setFunc = function(value)
                FPB.Settings.ISeeDeadPeople = value
                FPB.UpdateGroupBeams()
            end,
        },
		{
			type = "description",
			text = "Shows a beam on dead group members. " .. colorRed .. "Red" .. colorDefault .. " = dead. " .. colorYellow .. "Yellow" .. colorDefault .. " = Being revived. " .. colorGreen .. "Green" .. colorDefault .. " = Pending ressurection.",
		},
		{
			type = "divider",
		},
		{
            type = "checkbox",
            name = "Low HP Beam",
            tooltip = "Enable or disable the orange low HP beams. Slash command to toggle: /lowhp",
            default = true,
            getFunc = function() return FPB.Settings.LowHPBeam end,
            setFunc = function(value)
                FPB.Settings.LowHPBeam = value
                FPB.UpdateGroupBeams()
            end,
        },
		{
			type = "description",
			text = "Shows an " .. colorOrange .. "orange" .. colorDefault .. " beam on group members with low HP. /lowhp to toggle.",
		},
		{
			type = "description",
			text = "",
		},
		{
			type = "header",
			name = "Other Settings",
		},
		{
            type = "checkbox",
            name = "Range Limit",
            tooltip = "Shows visuals for close players only in Cyrodiil.",
            default = true,
            getFunc = function() return FPB.Settings.RangeLimit end,
            setFunc = function(value)
                FPB.Settings.RangeLimit = value
                FPB.UpdateGroupBeams()
            end,
        },
		{
			type = "description",
			text = "While in Cyrodiil, shows visuals only for close players. 'Follow The Crown' is not limited by this setting.",
		},
		{
            type = "slider",
            name = "Low HP Threshold %",
            tooltip = "Show an orange beam when a group member falls below this HP percentage.",
            min = 10,
            max = 90,
            step = 5,
            default = 50,
            getFunc = function() return FPB.Settings.LowHPThreshold end,
            setFunc = function(value)
                FPB.Settings.LowHPThreshold = value
                FPB.UpdateGroupBeams()
            end,
			disabled = function() return not FPB.Settings.LowHPBeam end,
        },
		{
			type = "divider",
		},
		{
			type = "submenu",
			name = "Arrow Settings",
			controls = {
				{
					type = "dropdown",
					name = "Mode",
					choices = {"Satnav", "Elastic Reticle Arrows", "Reticle Satnav"},
					default = "Satnav",
					getFunc = function() return FPB.Settings.Mode end,
					setFunc = function(bValue) FPB.ChangeMode(bValue) end,
				},
				{
					type = "dropdown",
					name = "Colors",
					tooltip = "The color style of the Rez Target reticle.",
					choices = FPBLib.Colors.Plugins,
					default = FPB.defaultSettings.Colors,
					getFunc = function() return FPB.Settings.Colors end,
					setFunc = function(bValue) FPB.ChangeColors(bValue) end
				},
				{
					type = "slider",
					name = "Targetted Opacity",
					tooltip = "The arrows will be this opaque (as a percentage) when you are facing the Rez Target.",
					min = 0,
					max = 100,
					step = 1,
					default = 50,
					getFunc = function() return (FPB.Settings.MinAlpha * 100)  end,
					setFunc = function(iValue) FPB.Settings.MinAlpha = (iValue / 100) end,
				},
				{
					type = "slider",
					name = "Behind Opacity",
					tooltip = "The arrows will be this opaque (as a percentage) when the Rez Target is directly behind you.",
					min = 0,
					max = 100,
					step = 1,
					default = 50,
					getFunc = function() return FPB.Settings.MaxAlpha * 100 end,
					setFunc = function(iValue) FPB.Settings.MaxAlpha = (iValue / 100) end,
				},
				{
					type = "slider",
					name = "Targetted Size",
					tooltip = "The arrows will be this size when you are facing the Rez Target.",
					min = 0,
					max = 64,
					step = 2,
					default = 32,
					getFunc = function() return FPB.Settings.MinSize end,
					setFunc = function(iValue) FPB.Settings.MinSize = iValue end,
				},
				{
					type = "slider",
					name = "Behind Size",
					tooltip = "The arrows will be this size when the Rez Target is directly behind you.",
					min = 0,
					max = 64,
					step = 2,
					default = 48,
					getFunc = function() return FPB.Settings.MaxSize end,
					setFunc = function(iValue) FPB.Settings.MaxSize = iValue end,
				},
				{
					type = "slider",
					name = "Targetted Distance",
					tooltip = "The arrows will be this distance from the reticle when you are facing the Rez Target.",
					min = 0,
					max = 512,
					step = 1,
					default = 256,
					getFunc = function() return FPB.Settings.MinDistance end,
					setFunc = function(iValue) FPB.Settings.MinDistance = iValue end,
				},
				{
					type = "slider",
					name = "Behind Distance",
					tooltip = "The arrows will be this distance from the reticle when Rez Target is directly behind you.",
					min = 0,
					max = 512,
					step = 1,
					default = 256,
					getFunc = function() return FPB.Settings.MaxDistance end,
					setFunc = function(iValue) FPB.Settings.MaxDistance = iValue end,
				},
				{
					type = "dropdown",
					name = "Sound Effect",
					tooltip = "Choose a sound alert notification when a group member dies.",
					choices = {"NONE", "DUEL_WON", "ELDER_SCROLL_CAPTURED_BY_ALDMERI", "SKILL_XP_DARK_ANCHOR_CLOSED", "VOICE_CHAT_MENU_CHANNEL_JOINED"},
					default = "NONE",
					getFunc = function() return FPB.Settings.Sound end,
					setFunc = function(selected)
							FPB.Settings.Sound = selected
							PlaySound(SOUNDS[selected])
						end,
				},
				{
					type = "description",
					text = "Rez Target Distance",
				},
				{
					type = "checkbox",
					name = "Arrow Size",
					tooltip = "Uses the arrow size to represent the Rez Target distance.",
					default = true,
					getFunc = function() return FPB.Settings.LeaderArrowSize end,
					setFunc = function(bValue) FPB.Settings.LeaderArrowSize = bValue end
				},
				{
					type = "checkbox",
					name = "Arrow Distance",
					tooltip = "Uses the arrow distance to represent the Rez Target distance.",
					default = true,
					getFunc = function() return FPB.Settings.LeaderArrowDistance end,
					setFunc = function(bValue) FPB.Settings.LeaderArrowDistance = bValue end
				},
				{
					type = "checkbox",
					name = "Close Icon",
					tooltip = "Change icon if you are really close to a dead player. This is to prevent that you will stand on a player and you do not notice it.",
					default = true,
					getFunc = function() return FPB.Settings.CloseIcon end,
					setFunc = function(bValue) FPB.Settings.CloseIcon = bValue end
				},
			},
		},
	}

	LAM2:RegisterOptionControls("FluffielsPanicBeams_Options", optionsData)
end

EVENT_MANAGER:RegisterForEvent(addonName, EVENT_ADD_ON_LOADED, FPB.OnPluginLoaded)