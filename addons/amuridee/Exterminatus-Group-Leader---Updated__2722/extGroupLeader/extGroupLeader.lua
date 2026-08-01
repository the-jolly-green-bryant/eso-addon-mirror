local LAM2 = LibAddonMenu2
local FAKETAG = 'EXT_GROUPLEADER_FAKE'
local AddonVersion = '2.0' -- and for LAM version too

local state = {
    Hidden = true,
    
    
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
    Mode = 'Elastic Reticle Arrows',
    Colors = 'White Orange Red',
    MinAlpha = 0.3,
    MaxAlpha = 0.9,
    MinSize = 24,
    MaxSize = 32,
    MinDistance = 0,
    MaxDistance = 128,
    PvPOnly = true,
    Mimic = false,
    
    LeaderArrowSize = false,
    LeaderArrowDistance = false,
    LeaderArrowNumeric = false
}

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
        state.Hidden = true
    else
        state.Hidden = false
        
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
    end
    
    state.Colors:Update(state)
    state.Mode:Update(state)
end

-- **************** EVENTS ****************

function extGroupLeaderUpdate()
    if state.Player == nil then return end
    
    UpdatePlayerEntity(state.Player)
    local h = NormalizeAngle(GetPlayerCameraHeading())
    if h ~= nil then state.Player.H = h end
    
    CheckLeader()
    UpdatePlayerEntity(state.Leader)
    
    if state.Leader == nil or state.Leader.X == nil or state.Leader.Y == nil then state.Leader = nil end
    if state.Leader == nil or state.Leader.Name == state.Player.Name then state.Leader = nil end
    
    UpdateReticle()
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
				ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NONE, zo_strformat("<<1>> <<2>> <<3>>", GetString(SI_EXTGL_FOLLOW_TARGET1), text , GetString(SI_EXTGL_FOLLOW_TARGET2)))
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
end

-- **************** SETTINGS ****************

local function LoadSettings()
    extGroupLeaderSettings = extGroupLeaderSettings or {}
    state.Settings = EXT_GROUPLEADER.Extend(extGroupLeaderSettings, defaultSettings)
end

local function ChangeMode(value)
    state.Settings.Mode = value
    if state.Mode then state.Mode:Unit() end
    state.Mode = EXT_GROUPLEADER.Modes[value]
    state.Mode.Init()
end

local function ChangeColors(value)
    state.Settings.Colors = value
    if state.Colors then state.Colors:Unit() end
    state.Colors = EXT_GROUPLEADER.Colors[value]
    state.Colors.Init()
end

local function CreateSettingsMenu()
	local colorYellow = "|cFFFF22"
	
	local panelData = {
		type = "panel",
		name = "extGroupLeader",
		displayName = colorYellow.."Exterminatus|r Group Leader",
		author = "|cFFC300@amuridee|r, QuadroTony, Mitazaki, Zamalek",
		version = AddonVersion,
		slashCommand = "/extGroupLeader",
		registerForRefresh = true,
		registerForDefaults = true,
	}
	local cntrlOptionsPanel = LAM2:RegisterAddonPanel("extGroupLeader_Options", panelData)

	local optionsData = {	
		[1] = {
			type = "description",
			text = colorYellow.."EXTERMINATUS|r GROUP LEADER",
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
			choices = EXT_GROUPLEADER.Colors.Plugins,
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
			type = "checkbox",
			name = GetString(SI_EXTGL_SETTING_ONLY_CYRODIIL),
			tooltip = GetString(SI_EXTGL_SETTING_ONLY_CYRODIIL_TOOLTIP),
			default = true,
			getFunc = function() return state.Settings.PvPOnly  end,
			setFunc = function(bValue) state.Settings.PvPOnly = bValue end
		},	
		[11] = {
			type = "checkbox",
			name = GetString(SI_EXTGL_SETTING_MIMIC_RETICLE),
			tooltip = GetString(SI_EXTGL_SETTING_MIMIC_RETICLE_TOOLTIP),
			default = false,
			getFunc = function() return state.Settings.Mimic end,
			setFunc = function(bValue) state.Settings.Mimic = bValue end
		},	
		[12] = {
			type = "description",
			text = colorYellow..GetString(SI_EXTGL_STYLE_LEADER_DISTANCE),
		},
		[13] = {
			type = "checkbox",
			name = GetString(SI_EXTGL_STYLE_ARROW_SIZE),
			tooltip = GetString(SI_EXTGL_STYLE_ARROW_SIZE_TOOLTIP),
			default = true,
			getFunc = function() return state.Settings.LeaderArrowSize end,
			setFunc = function(bValue) state.Settings.LeaderArrowSize = bValue end
		},	
		---[[
		[14] = {
			type = "checkbox",
			name = GetString(SI_EXTGL_STYLE_ARROW_DISTANCE),
			tooltip = GetString(SI_EXTGL_STYLE_ARROW_DISTANCE_TOOLTIP),
			default = true,
			getFunc = function() return state.Settings.LeaderArrowDistance end,
			setFunc = function(bValue) state.Settings.LeaderArrowDistance = bValue end
		},	
		[15] = {
			type = "description",
			text = colorYellow.. GetString(SI_EXTGL_SETTING_CONTRIBUTORS),
		},
		[16] = {
			type = "description",
			text = "|cFFC300[Emperor]|r @amuridee, |c22FF22[Old]|r QuadroTony, |c22FF22[EXT]|r Mitazaki, |c22FF22[EXT]|r Zamalek",
		},
		--]]
	}		
	
	LAM2:RegisterOptionControls("extGroupLeader_Options", optionsData)
end

local function OnPluginLoaded(event, addon)
	if addon ~= "extGroupLeader" then return end
    
    LoadSettings()
    CreateSettingsMenu()
    
    ChangeMode(state.Settings.Mode)
    ChangeColors(state.Settings.Colors)
        
    InitializePlugin()
    
    SLASH_COMMANDS["/glfake"] = FakeIt
    SLASH_COMMANDS["/glset"] = SetCustomLeader
end

EVENT_MANAGER:RegisterForEvent("extGroupLeader", EVENT_ADD_ON_LOADED, OnPluginLoaded)
EVENT_MANAGER:RegisterForEvent("extGroupLeader", EVENT_GROUP_MEMBER_LEFT, OnPlayerLeft)
