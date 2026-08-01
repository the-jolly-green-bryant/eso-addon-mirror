local LAM2 = LibAddonMenu2
local FAKETAG = 'MERLINS_REZHELPER_FAKE'
local AddonVersion = '2.1.0'
local NextPlayer = ''

local state = {
    Hidden = true,
	ForceBeam = false,
    SetCloseIcon = false,

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

    Settings = nil,

    Constants = {
        GameReticleSize = 58
    }
}

local defaultSettings = {
    Mode = 'Satnav',
    Colors = 'Green Orange Red',
    MinAlpha = 0.5,
    MaxAlpha = 0.9,
    MinSize = 50,
    MaxSize = 60,
    MinDistance = 0,
    MaxDistance = 128,
    PvPOnly = false,
    Mimic = true,

  	Debug = false,
  	RangeLimit = false,
  	CloseIcon = true,
  	Sound = 'DUEL_WON',

    LeaderArrowSize = false,
    LeaderArrowDistance = true,
    LeaderArrowNumeric = false
}

local lightReference = nil

-- **************** UTILS ****************

local function NormalizeAngle(c)
    if c > math.pi then return c - 2 * math.pi end
    if c < -math.pi then return c + 2 * math.pi end
    return c
end

-- **************** ENTITIES ****************

local function UpdatePlayerEntity(entity)
    if entity == nil then return end
    if entity.Tag == FAKETAG then return end

    entity.X, entity.Y, entity.Z = GetMapPlayerPosition(entity.Tag)
    entity.Zone = GetUnitZone(entity.Tag)
    entity.Name = GetUnitName(entity.Tag)
end

local function CheckLeader()
    if state.Leader and state.Leader.Custom then return end

	local newLeader = GetGroupLeaderUnitTag()
    if newLeader == nil or newLeader == '' then
        state.Leader = nil
    elseif state.Leader == nil or state.Leader.Tag ~= newLeader then
        state.Leader = {
            Tag = newLeader
        }
    end
end

-- **************** UI ****************

local function UpdateReticle()
    if state.Player == nil then return end

    if (state.Leader == nil) or
       (state.Settings.PvPOnly and not IsInAvAZone()) or
       (state.Settings.Mimic and ZO_ReticleContainer:IsHidden() == true) or
       (IsUnitGrouped('player') == false) then
        -- state.Hidden = true
		HideLight()
    else
        -- state.Hidden = false

        state.DX = state.Player.X - state.Leader.X
        state.DY = state.Player.Y - state.Leader.Y
        state.D = math.sqrt((state.DX * state.DX) + (state.DY * state.DY))

        state.Angle = NormalizeAngle(state.Player.H - math.atan2( state.DX, state.DY ))
        state.Linear = state.Angle / math.pi
        state.AbsoluteLinear = math.abs(state.Linear)

        state.Alpha = state.Settings.MinAlpha + (state.Settings.MaxAlpha - state.Settings.MinAlpha) * state.AbsoluteLinear;

        if state.Settings.LeaderArrowSize then
            state.Size = state.Settings.MinSize + (state.Settings.MaxSize - state.Settings.MinSize) * (math.tanh(state.D * 40 - 1) + 1.0) / 2.0;
        else
            state.Size = state.Settings.MinSize + (state.Settings.MaxSize - state.Settings.MinSize) * state.AbsoluteLinear;
        end
        if state.Settings.LeaderArrowDistance then
            state.Distance = state.Settings.MinDistance + (state.Settings.MaxDistance - state.Settings.MinDistance) * (math.tanh(state.D * 40 - 1) + 1.0) / 2.0;
        else
            state.Distance = state.Settings.MinDistance + (state.Settings.MaxDistance - state.Settings.MinDistance) * state.AbsoluteLinear;
        end

		ShowLight()
    end

    state.Colors:Update(state)
    state.Mode:Update(state)
end

function CreateLight()
	if state.Settings.Beam == true then
		local wm = GetWindowManager()
		lightReference = wm:CreateTopLevelWindow("playerPosition")
		lightReference:SetDrawTier(0)
		lightReference:SetDrawLayer(0)
		lightReference:SetDrawLevel(0)
		lightReference.texture = wm:CreateControl("light", lightReference, CT_TEXTURE)
		lightReference.texture:SetTexture("MerlinsRezHelper/textures/Beam.dds")
		lightReference:Create3DRenderSpace()
		lightReference.texture:Create3DRenderSpace()
		lightReference.texture:Set3DLocalDimensions(1, 256)
		lightReference.texture:SetDrawLevel(3)
		lightReference.texture:SetColor(1,1,1,1)
		lightReference.texture:SetParent(lightReference)
		lightReference:Set3DRenderSpaceOrigin(0,0,0)
		HideLight()
	end
end

function TestLight()
	--TTTest()
	d("Testing - /reloadui to remove the beam strip. No beam visible? Then this area is not supported yet.")

	local x, y, z = GetMapPlayerPosition("player")
	CalcLightPos(x, y)
	lightReference:SetHidden(false)
	state.ForceBeam = true
end

function ShowLight()
	if state.Settings.Beam == true then
		if (Lib3D ~= nil and state.Leader ~= nil and state.Leader.X ~= nil and state.Leader.Y ~= nil and state.Hidden ~= true) then
			CalcLightPos(state.Leader.X, state.Leader.Y)
			lightReference:SetHidden(false)
		end
	end
end

function CalcLightPos(x, y)
	-- Parent Frame
	local Wx, Wz = Lib3D:GlobalToWorld(Lib3D:GetCurrentWorldOriginAsGlobal())
	lightReference:Set3DRenderSpaceOrigin(Wx, 0, Wz)

	-- Beam
	local worldX, worldZ = nil, nil
	worldX, worldZ = Lib3D:LocalToWorld(x, y)
	local _, height, _ = Lib3D:GetCameraRenderSpacePosition()
	if worldX ~= nil and worldZ ~= nil then
		worldX, _, worldZ = WorldPositionToGuiRender3DPosition(worldX * 100, 0, worldZ * 100)
	end
	lightReference.texture:Set3DRenderSpaceOrigin(worldX, height, worldZ)

	-- Ausrichtung
	local heading = GetPlayerCameraHeading()
	if heading > math.pi then
		heading = heading - 2 * math.pi
	end
	lightReference.texture:Set3DRenderSpaceOrientation(0, heading, 0)
end

function TTTest()
	local playerX, playerY = GetMapPlayerPosition("player")
	if playerX ~= nil and playerY ~= nil and playerX ~= 0 and playerY ~= 0 then
		local x, y = nil, nil
		local _, worldX, height, worldY = GetUnitWorldPosition("player")
		x, y = Lib3D:LocalToWorld(playerX, playerY)
		worldX, worldHeight, worldY = WorldPositionToGuiRender3DPosition(worldX, height, worldY)
		if x ~= nil and y ~= nil then
			x, height, y = WorldPositionToGuiRender3DPosition(x * 100, height, y * 100)
		end
		--lightReference.texture:Set3DRenderSpaceOrigin(worldX, worldHeight, worldY)
		--lightReference.texture:Set3DRenderSpaceOrigin(x, height, y)
	end
end

function HideLight()
	if lightReference ~= nil and state.Hidden ~= false and state.ForceBeam == false then
		lightReference:SetHidden(true)
	end
end

-- **************** EVENTS ****************

-- onUpdate trigger
function merlinsRezHelperUpdate()
    if state.Player == nil then return end

	  -- 2Do check for nearest group member and set "as leader"
    GetClosestMember()

    UpdatePlayerEntity(state.Player)
    local h = NormalizeAngle(GetPlayerCameraHeading())
    if h ~= nil then state.Player.H = h end

    CheckLeader()
    UpdatePlayerEntity(state.Leader)

    if state.Leader == nil or state.Leader.X == nil or state.Leader.Y == nil then state.Leader = nil end
    if state.Leader == nil or state.Leader.Name == state.Player.Name then state.Leader = nil end

    UpdateReticle()
end

function GetClosestMember()

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

	-- if in group
	if IsUnitGrouped('player') == true then

		-- foreach groupmember

		for xmemberid = 1, GetGroupSize(), 1 do

      currentTag = GetGroupUnitTagByIndex(xmemberid)
      currentName = GetUnitName(currentTag)

			-- if death and online and in the same zone OR debug
			if ((IsUnitDead(currentTag) and
				IsUnitBeingResurrected(currentTag)==false and
				DoesUnitHaveResurrectPending(currentTag)==false and
				IsUnitReincarnating(currentTag)==false and
        IsUnitOnline(currentTag)==true and
        GetUnitZone(currentTag) == GetUnitZone("player") and
				(GetUnitName("player") ~= GetUnitName(currentTag))
				) or state.Settings.Debug == true
				) then

				-- get position
				currentDistance = CalcDistance(currentTag);
        -- d(currentDistance)

        -- dont show location of to far away members
        if (currentDistance<maxDistance or state.Settings.RangeLimit ~= true) and currentDistance ~= 0 and currentDistance ~= nil then
          -- some one in range is dead and its not you
  				someoneIsDead = true

  				-- override if its closer
					if currentDistance<closestDistance then
						closestPlayer = currentName
						closestDistance = currentDistance

            if (currentDistance<closeDistance and state.Settings.CloseIcon == true) then
                state.SetCloseIcon = true
            else
                state.SetCloseIcon = false
            end

					end

        end

			end
		end

		if someoneIsDead then
			state.Hidden = false
		else
			state.Hidden = true
		end

		if (closestPlayer ~= '') and (NextPlayer ~= closestPlayer) then
			NextPlayer = closestPlayer
			SetCustomLeader(closestPlayer)
		end

		-- hide if mouse shown / on menu interface
		if (state.Settings.Mimic and ZO_ReticleContainer:IsHidden() == true) then
			state.Hidden = true
		end

	end

end

function CalcDistance(memberTag)

	playerX, playerY, playerZ = GetMapPlayerPosition('player')
	memberX, memberY, memberZ = GetMapPlayerPosition(memberTag)
	calcDX = playerX - memberX
	calcDY = playerY - memberY

	return math.sqrt((calcDX * calcDX) + (calcDY * calcDY))

end

local function FakeIt(text)
    state.Leader = {
        Tag = 'player'
    }
    UpdatePlayerEntity(state.Leader)
    state.Leader.Tag = FAKETAG
    state.Leader.Name = FAKETAG
    state.Leader.Custom = true

    --d("Leader faked.")
	ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NONE, GetString(SI_EXTGL_LEADER_FAKED))
end

function OnSetTargettedLeader()
    SetCustomLeader(GetUnitNameHighlightedByReticle())
end

-- Slash command for custom follow target ( /glset = set to default group leader - /glset <charname> = set to custom person )
function SetCustomLeader(text)
    if IsUnitGrouped('player') == false then
        --d("You must be in a group to set a follow target.")
		ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NONE, GetString(SI_GROUPELECTIONFAILURE8))
        return
    end
    if text == "" then
        state.Leader.Custom = false
    else
        for xmemberid = 1, GetGroupSize(), 1 do
            if string.lower(text) == string.lower(GetUnitName(GetGroupUnitTagByIndex(xmemberid))) then
                --d("Successfully set '" .. text .. "' as follow target.")
				ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS[state.Settings.Sound], zo_strformat("<<1>> <<2>> <<3>>", GetString(SI_EXTGL_FOLLOW_TARGET1), text , GetString(SI_EXTGL_FOLLOW_TARGET2)))
                state.Leader = {
                        Tag = GetGroupUnitTagByIndex(xmemberid)
                }
                UpdatePlayerEntity(state.Leader)
                state.Leader.Tag = GetGroupUnitTagByIndex(xmemberid)
                state.Leader.Name = GetUnitName(GetGroupUnitTagByIndex(xmember))
                state.Leader.Custom = true
            else
                --d("ZERO MATCH ON - ".. text .. " = " .. GetUnitName(GetGroupUnitTagByIndex(xmemberid)))
            end
		end
	   if not state.Leader.Custom then
			--d("Could not find anyone named '" .. text .. "' in your group.")
			ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NONE, zo_strformat("<<1>> <<2>> <<3>>", GetString(SI_EXTGL_NO_TARGET_FOUND1), text , GetString(SI_EXTGL_NO_TARGET_FOUND2)))
        end
    end
end

--Find out if your follow target has left the group and if so notify and set leader to nil
local function OnPlayerLeft(leftmemberName, reason, wasLocalPlayer)
    if IsUnitGrouped('player') == false then return end -- Ignore if you just left the group
    if state.Leader == nil then return end

    local doesCustomExist = false
    for xmemberid = 1, GetGroupSize() , 1 do
        if GetGroupUnitTagByIndex(xmemberid) == state.Leader.Tag then
            doesCustomExist = true
        end
    end
    if not doesCustomExist then
        --d("Your follow target has left the group. Now following group leader.")
		ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NONE, GetString(SI_EXTGL_FOLLOW_TARGET_LEFT))
        state.Leader = nil
    end
end

local function InitializePlugin()
    state.Player = {
        Tag = 'player'
    }
	CreateLight()
end

-- **************** SETTINGS ****************

local function LoadSettings()
    merlinsRezHelperSettings = merlinsRezHelperSettings or {}
    state.Settings = MERLINS_REZHELPER.Extend(merlinsRezHelperSettings, defaultSettings)
end

local function ChangeMode(value)
    state.Settings.Mode = value
    if state.Mode then state.Mode:Unit() end
    state.Mode = MERLINS_REZHELPER.Modes[value]
    state.Mode.Init()
end

local function ChangeColors(value)
    state.Settings.Colors = value
    if state.Colors then state.Colors:Unit() end
    state.Colors = MERLINS_REZHELPER.Colors[value]
    state.Colors.Init()
end

local function CreateSettingsMenu()
	local colorYellow = "|cFFFF22"

	local panelData = {
		type = "panel",
		name = "Merlins Rez Helper",
		displayName = colorYellow.."Merlin's|r Rez Helper",
		author = "@Just_Merlin",
		version = AddonVersion,
		slashCommand = "/merlinsRezHelper",
		registerForRefresh = true,
		registerForDefaults = true,
	}
	local cntrlOptionsPanel = LAM2:RegisterAddonPanel("merlinsRezHelper_Options", panelData)

	local optionsData = {
		[1] = {
			type = "description",
			text = colorYellow.."Merlin's|r Rez Helper",
		},
		[2] = {
			type = "dropdown",
			name = GetString(SI_EXTGL_STYLE_MODE),
			choices = {"Elastic Reticle Arrows", "Satnav", "Reticle Satnav"},
			default = "Elastic Reticle Arrows",
			getFunc = function() return state.Settings.Mode end,
			setFunc = function(bValue) ChangeMode(bValue) end,
		},
		[3] = {
			type = "dropdown",
			name = GetString(SI_EXTGL_STYLE_COLOR),
			tooltip = GetString(SI_EXTGL_STYLE_COLOR_TOOLTIP),
			choices = MERLINS_REZHELPER.Colors.Plugins,
			default = "Always White",
			getFunc = function() return state.Settings.Colors end,
			setFunc = function(bValue) ChangeColors(bValue) end
		},
		[4] = {
			type = "slider",
			name = GetString(SI_EXTGL_STYLE_TARGET_OPACITY),
			tooltip = GetString(SI_EXTGL_STYLE_TARGET_OPACITY_TOOLTIP),
			min = 0,
			max = 100,
			step = 1,
			default = 50,
			getFunc = function() return (state.Settings.MinAlpha * 100)  end,
			setFunc = function(iValue) state.Settings.MinAlpha = (iValue / 100) end,
		},
		[5] = {
			type = "slider",
			name = GetString(SI_EXTGL_STYLE_BEHIND_OPACITY),
			tooltip = GetString(SI_EXTGL_STYLE_BEHIND_OPACITY_TOOLTIP),
			min = 0,
			max = 100,
			step = 1,
			default = 50,
			getFunc = function() return state.Settings.MaxAlpha * 100 end,
			setFunc = function(iValue) state.Settings.MaxAlpha = (iValue / 100) end,
		},
		[6] = {
			type = "slider",
			name = GetString(SI_EXTGL_STYLE_TARGET_SIZE),
			tooltip = GetString(SI_EXTGL_STYLE_TARGET_SIZE_TOOLTIP),
			min = 0,
			max = 64,
			step = 2,
			default = 32,
			getFunc = function() return state.Settings.MinSize end,
			setFunc = function(iValue) state.Settings.MinSize = iValue end,
		},
		[7] = {
			type = "slider",
			name = GetString(SI_EXTGL_STYLE_BEHIND_SIZE),
			tooltip = GetString(SI_EXTGL_STYLE_BEHIND_SIZE_TOOLTIP),
			min = 0,
			max = 64,
			step = 2,
			default = 48,
			getFunc = function() return state.Settings.MaxSize end,
			setFunc = function(iValue) state.Settings.MaxSize = iValue end,
		},
		[8] = {
			type = "slider",
			name = GetString(SI_EXTGL_STYLE_TARGET_DISTANCE),
			tooltip = GetString(SI_EXTGL_STYLE_TARGET_DISTANCE_TOOLTIP),
			min = 0,
			max = 512,
			step = 1,
			default = 256,
			getFunc = function() return state.Settings.MinDistance end,
			setFunc = function(iValue) state.Settings.MinDistance = iValue end,
		},
		[9] = {
			type = "slider",
			name = GetString(SI_EXTGL_STYLE_BEHIND_DISTANCE),
			tooltip = GetString(SI_EXTGL_STYLE_BEHIND_DISTANCE_TOOLTIP),
			min = 0,
			max = 512,
			step = 1,
			default = 256,
			getFunc = function() return state.Settings.MaxDistance end,
			setFunc = function(iValue) state.Settings.MaxDistance = iValue end,
		},
		[10] = {
			type = "dropdown",
			name = GetString(SI_EXTGL_STYLE_SOUND),
			choices = {"NONE", "DUEL_WON", "ELDER_SCROLL_CAPTURED_BY_ALDMERI", "SKILL_XP_DARK_ANCHOR_CLOSED", "VOICE_CHAT_MENU_CHANNEL_JOINED"},
			default = "DUEL_WON",
			getFunc = function() return state.Settings.Sound end,
			setFunc = function(selected)
					state.Settings.Sound = selected
					PlaySound(SOUNDS[selected])
				end,
		},
		[11] = {
			type = "checkbox",
			name = GetString(SI_EXTGL_STYLE_BEAM),
			tooltip = GetString(SI_EXTGL_STYLE_BEAM_TOOLTIP),
			default = true,
			getFunc = function() return state.Settings.Beam end,
			setFunc = function(bValue) state.Settings.Beam = bValue end
		},
		[12] = {
			type = "checkbox",
			name = GetString(SI_EXTGL_STYLE_DEBUG),
			tooltip = GetString(SI_EXTGL_STYLE_DEBUG_TOOLTIP),
			default = false,
			getFunc = function() return state.Settings.Debug end,
			setFunc = function(bValue) state.Settings.Debug = bValue end
		},
		[13] = {
			type = "description",
			text = colorYellow..GetString(SI_EXTGL_STYLE_LEADER_DISTANCE),
		},
		[14] = {
			type = "checkbox",
			name = GetString(SI_EXTGL_STYLE_ARROW_SIZE),
			tooltip = GetString(SI_EXTGL_STYLE_ARROW_SIZE_TOOLTIP),
			default = true,
			getFunc = function() return state.Settings.LeaderArrowSize end,
			setFunc = function(bValue) state.Settings.LeaderArrowSize = bValue end
		},
		[15] = {
			type = "checkbox",
			name = GetString(SI_EXTGL_STYLE_ARROW_DISTANCE),
			tooltip = GetString(SI_EXTGL_STYLE_ARROW_DISTANCE_TOOLTIP),
			default = true,
			getFunc = function() return state.Settings.LeaderArrowDistance end,
			setFunc = function(bValue) state.Settings.LeaderArrowDistance = bValue end
		},
		[16] = {
			type = "checkbox",
			name = GetString(SI_EXTGL_STYLE_CLOSE_ICON),
			tooltip = GetString(SI_EXTGL_STYLE_CLOSE_ICON_TOOLTIP),
			default = true,
			getFunc = function() return state.Settings.CloseIcon end,
			setFunc = function(bValue) state.Settings.CloseIcon = bValue end
		},
		[17] = {
			type = "checkbox",
			name = GetString(SI_EXTGL_STYLE_RANGE_LIMIT).." (Beta)",
			tooltip = GetString(SI_EXTGL_STYLE_RANGE_LIMIT_TOOLTIP),
			default = false,
			getFunc = function() return state.Settings.RangeLimit end,
			setFunc = function(bValue) state.Settings.RangeLimit = bValue end
		},
	}

	LAM2:RegisterOptionControls("merlinsRezHelper_Options", optionsData)
end

local function OnPluginLoaded(event, addon)
	if addon ~= "merlinsRezHelper" then return end

    LoadSettings()
    CreateSettingsMenu()

    ChangeMode(state.Settings.Mode)
    ChangeColors(state.Settings.Colors)

    InitializePlugin()

    -- SLASH_COMMANDS["/glfake"] = FakeIt
    -- SLASH_COMMANDS["/glset"] = SetCustomLeader
    SLASH_COMMANDS["/beam"] = TestLight
end


EVENT_MANAGER:RegisterForEvent("merlinsRezHelper", EVENT_ADD_ON_LOADED, OnPluginLoaded)
EVENT_MANAGER:RegisterForEvent("merlinsRezHelper", EVENT_GROUP_MEMBER_LEFT, OnPlayerLeft)
