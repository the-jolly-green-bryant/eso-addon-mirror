--[[
	Addon: Taos Group Tools
	Author: TProg Taonnor
	Created by @Taonnor
]]--

--[[
	Local variables
]]--
local ANIMATION_DURATION = 125 -- ms
local GROUP_FRAME_CORNER = 20 -- px

local DEAD_ICON = "esoui/art/icons/poi/poi_groupboss_complete.dds"
local SNEAK_ICON = "esoui/art/icons/poi/poi_areaofinterest_complete.dds"
local LEADER_ICON = "esoui/art/unitframes/groupIcon_leader.dds"

local _logger = nil
local _settingsHandler = TGT_SettingsHandler
local _playerHandler = TGT_PlayerHandler

local _name = "TGT-GroupFrames"
local _isActive = false
local _isCreated = false
local _controlColors = nil
local _groupControls = {}

--[[
	Table TGT_GroupFrames
]]--
TGT_GroupFrames = {}
TGT_GroupFrames.__index = TGT_GroupFrames

--[[
	===============
    PRIVATE METHODS
    ===============
]]--

--[[
	Stops ultimate frame animation
]]--
local function StopUltimateReadyAnimations(frame)
    local ultimateReadyBurstTexture = frame:GetNamedChild("UltimateTracker"):GetNamedChild("ReadyBurst")
    local ultimateReadyLoopTexture = frame:GetNamedChild("UltimateTracker"):GetNamedChild("ReadyLoop")

    if frame.UltimateReadyBurstTimeline then
        frame.UltimateReadyBurstTimeline:Stop()
        frame.UltimateReadyLoopTimeline:Stop()
    end
    
    ultimateReadyBurstTexture:SetHidden(true)
    ultimateReadyLoopTexture:SetHidden(true)
end

--[[
	Starts ultimate frame animation
]]--
local function PlayUltimateReadyAnimations(frame)
    local ultimateReadyBurstTexture = frame:GetNamedChild("UltimateTracker"):GetNamedChild("ReadyBurst")
    local ultimateReadyLoopTexture = frame:GetNamedChild("UltimateTracker"):GetNamedChild("ReadyLoop")

    if not frame.UltimateReadyBurstTimeline then
        frame.UltimateReadyBurstTimeline = ANIMATION_MANAGER:CreateTimelineFromVirtual("UltimateReadyBurst", ultimateReadyBurstTexture)
        frame.UltimateReadyLoopTimeline = ANIMATION_MANAGER:CreateTimelineFromVirtual("UltimateReadyLoop", ultimateReadyLoopTexture)

        local function OnStop(self)
            if self:GetProgress() == 1.0 then
                ultimateReadyBurstTexture:SetHidden(true)
                frame.UltimateReadyLoopTimeline:PlayFromStart()
                ultimateReadyLoopTexture:SetHidden(false)
            end
        end
        frame.UltimateReadyBurstTimeline:SetHandler("OnStop", OnStop)
    end

    if not frame.UltimateReadyBurstTimeline:IsPlaying() and not frame.UltimateReadyLoopTimeline:IsPlaying() then
        ultimateReadyBurstTexture:SetHidden(false)
        frame.UltimateReadyBurstTimeline:PlayFromStart()
    end
end

--[[
	Updates frame colors
]]--
local function UpdateFrameColors(player)
    local frame = player.Frame
    local shieldTracker = frame:GetNamedChild("ShieldTracker"):GetNamedChild("StatusBar")
    local healthTracker = frame:GetNamedChild("HealthTracker"):GetNamedChild("StatusBar")
    local staminaTracker = frame:GetNamedChild("StaminaTracker"):GetNamedChild("StatusBar")
    local magickaTracker = frame:GetNamedChild("MagickaTracker"):GetNamedChild("StatusBar")

    local isPlayerTimedOut = player.LastMapPingTimestamp ~= 0 and player.IsPlayerTimedOut
    local isPlayerOffline = player.IsPlayerOnline == false
    local isPlayerDead = player.IsPlayerDead

    -- Labels
    if (isPlayerTimedOut) then
		frame:GetNamedChild("NameLabel"):SetColor(0.5, 0.5, 0.5, 1)
        frame:GetNamedChild("HealthLabel"):SetColor(0.5, 0.5, 0.5, 1)
        frame:GetNamedChild("StaminaLabel"):SetColor(0.5, 0.5, 0.5, 1)
        frame:GetNamedChild("MagickaLabel"):SetColor(0.5, 0.5, 0.5, 1)
	elseif (isPlayerOffline) then
		frame:GetNamedChild("NameLabel"):SetColor(0.5, 0.5, 0.5, 1)
        frame:GetNamedChild("HealthLabel"):SetColor(0.5, 0.5, 0.5, 1)
        frame:GetNamedChild("StaminaLabel"):SetColor(0.5, 0.5, 0.5, 1)
        frame:GetNamedChild("MagickaLabel"):SetColor(0.5, 0.5, 0.5, 1)
	elseif (isPlayerDead) then
        frame:GetNamedChild("NameLabel"):SetColor(1.0, 0.0, 0.0, 1)
        frame:GetNamedChild("HealthLabel"):SetColor(0.5, 0.5, 0.5, 1)
        frame:GetNamedChild("StaminaLabel"):SetColor(0.5, 0.5, 0.5, 1)
        frame:GetNamedChild("MagickaLabel"):SetColor(0.5, 0.5, 0.5, 1)
    else
        if (_settingsHandler.SavedVariables.ShowUltimateInsteadHaelth) then
            if (player.RelativeUltimate == 100) then
                local color = _controlColors.UltimateReadyColor.Background
                local labelColor = _controlColors.UltimateReadyColor.Label

                healthTracker:SetColor(color.R, color.G, color.B, color.A)
                frame:GetNamedChild("NameLabel"):SetColor(labelColor.R, labelColor.G, labelColor.B, labelColor.A)
                frame:GetNamedChild("HealthLabel"):SetColor(labelColor.R, labelColor.G, labelColor.B, labelColor.A)
            else
                local color = _controlColors.UltimateProgrColor.Background
                local labelColor = _controlColors.UltimateProgrColor.Label

                healthTracker:SetColor(color.R, color.G, color.B, color.A)
                frame:GetNamedChild("NameLabel"):SetColor(labelColor.R, labelColor.G, labelColor.B, labelColor.A)
                frame:GetNamedChild("HealthLabel"):SetColor(labelColor.R, labelColor.G, labelColor.B, labelColor.A)
            end
        else
            -- Ultimate Animation
            if (player.RelativeUltimate == 100) then
                PlayUltimateReadyAnimations(frame)
            else
                StopUltimateReadyAnimations(frame)
            end
            
            -- There is only one shield color
            local shieldColor = _controlColors.ShieldColor.Background
            shieldTracker:SetColor(shieldColor.R, shieldColor.G, shieldColor.B, shieldColor.A)

            if (player.RelativeHealth == 100) then
                local color = _controlColors.HealthReadyColor.Background
                local labelColor = _controlColors.HealthReadyColor.Label

                healthTracker:SetColor(color.R, color.G, color.B, color.A)
                frame:GetNamedChild("NameLabel"):SetColor(labelColor.R, labelColor.G, labelColor.B, labelColor.A)
                frame:GetNamedChild("HealthLabel"):SetColor(labelColor.R, labelColor.G, labelColor.B, labelColor.A)
            else
                local color = _controlColors.HealthProgrColor.Background
                local labelColor = _controlColors.HealthProgrColor.Label

                healthTracker:SetColor(color.R, color.G, color.B, color.A)
                frame:GetNamedChild("NameLabel"):SetColor(labelColor.R, labelColor.G, labelColor.B, labelColor.A)
                frame:GetNamedChild("HealthLabel"):SetColor(labelColor.R, labelColor.G, labelColor.B, labelColor.A)
            end
        end
        
        if (player.RelativeStamina == 100) then
            local color = _controlColors.StamReadyColor.Background
            local labelColor = _controlColors.StamReadyColor.Label

            staminaTracker:SetColor(color.R, color.G, color.B, color.A)
            frame:GetNamedChild("StaminaLabel"):SetColor(labelColor.R, labelColor.G, labelColor.B, labelColor.A)
        else
            local color = _controlColors.StamProgrColor.Background
            local labelColor = _controlColors.StamProgrColor.Label

            staminaTracker:SetColor(color.R, color.G, color.B, color.A)
            frame:GetNamedChild("StaminaLabel"):SetColor(labelColor.R, labelColor.G, labelColor.B, labelColor.A)
        end

        if (player.RelativeMagicka == 100) then
            local color = _controlColors.MagiReadyColor.Background
            local labelColor = _controlColors.MagiReadyColor.Label

            magickaTracker:SetColor(color.R, color.G, color.B, color.A)
            frame:GetNamedChild("MagickaLabel"):SetColor(labelColor.R, labelColor.G, labelColor.B, labelColor.A)
        else
            local color = _controlColors.MagiProgrColor.Background
            local labelColor = _controlColors.MagiProgrColor.Label

            magickaTracker:SetColor(color.R, color.G, color.B, color.A)
            frame:GetNamedChild("MagickaLabel"):SetColor(labelColor.R, labelColor.G, labelColor.B, labelColor.A)
        end

	end

    -- Combat edge
    -- Additional conditions; for example the player cannot be in combat, if hes dead
    local isPlayerInCombat = 
        player.IsPlayerInCombat and not isPlayerTimedOut and not isPlayerOffline and not isPlayerDead

    if (_settingsHandler.SavedVariables.CombatActive[GROUP_FRAMES] and isPlayerInCombat) then
        frame:GetNamedChild("Edge"):SetEdgeColor(0.8, 0.03, 0.03, 0.8)
    else
        frame:GetNamedChild("Edge"):SetEdgeColor(0, 0, 0, 0.8)
    end
end

--[[
	Updates tracker icons
]]--
local function UpdateFrameTrackerIcons(player)
    local frame = player.Frame
    
    if (frame ~= nil) then
        frame:GetNamedChild("BuffTracker1"):GetNamedChild("Icon"):SetTexture(GetAbilityIcon(_settingsHandler.SavedVariables.TrackedBuffs[GROUP_FRAMES].TrackedBuff1AbilityId))
        frame:GetNamedChild("BuffTracker2"):GetNamedChild("Icon"):SetTexture(GetAbilityIcon(_settingsHandler.SavedVariables.TrackedBuffs[GROUP_FRAMES].TrackedBuff2AbilityId))
        frame:GetNamedChild("BuffTracker3"):GetNamedChild("Icon"):SetTexture(GetAbilityIcon(_settingsHandler.SavedVariables.TrackedBuffs[GROUP_FRAMES].TrackedBuff3AbilityId))
        frame:GetNamedChild("BuffTracker4"):GetNamedChild("Icon"):SetTexture(GetAbilityIcon(_settingsHandler.SavedVariables.TrackedBuffs[GROUP_FRAMES].TrackedBuff4AbilityId))
    end
end

--[[
	UpdateBuffTracker updates buff tracker
]]--
local function UpdateBuffTracker(buffTracker, buffAbilityId, buffActive)
    if (buffActive) then
        buffTracker:GetNamedChild("Overlay"):SetHidden(true)
    else
        buffTracker:GetNamedChild("Overlay"):SetHidden(false)
    end
end

--[[
	Updates player frame and set corect status icons
]]--
local function UpdateFrameStatusIcons(player)
    local style = _settingsHandler.SavedVariables.Style[GROUP_FRAMES]

    if (style ~= 3) then -- Does not shows indicators on style 3
        local frame = player.Frame

        if (player.IsPlayerDead) then
            frame:GetNamedChild("PlayerStatusIndicator1"):SetTexture(DEAD_ICON)
            frame:GetNamedChild("PlayerStatusIndicator1"):SetColor(1,0,0,1)
            frame:GetNamedChild("PlayerStatusIndicator1"):SetHidden(false)
        elseif (IsUnitBeingResurrected(player.PingTag)) then
            frame:GetNamedChild("PlayerStatusIndicator1"):SetTexture(DEAD_ICON)
            frame:GetNamedChild("PlayerStatusIndicator1"):SetColor(0,0,1,1)
            frame:GetNamedChild("PlayerStatusIndicator1"):SetHidden(false)
        elseif (DoesUnitHaveResurrectPending(player.PingTag)) then
            frame:GetNamedChild("PlayerStatusIndicator1"):SetTexture(DEAD_ICON)
            frame:GetNamedChild("PlayerStatusIndicator1"):SetColor(0,1,0,1)
            frame:GetNamedChild("PlayerStatusIndicator1"):SetHidden(false)
        elseif (player.FoodBuffActive and _settingsHandler.SavedVariables.ShowFoodBuff) then
            frame:GetNamedChild("PlayerStatusIndicator1"):SetTexture(player.FoodBuffIcon)
            frame:GetNamedChild("PlayerStatusIndicator1"):SetColor(1,1,1,1)
            frame:GetNamedChild("PlayerStatusIndicator1"):SetHidden(false)
        else
            frame:GetNamedChild("PlayerStatusIndicator1"):SetHidden(true)
        end

        if (IsUnitGroupLeader(player.PingTag)) then
            frame:GetNamedChild("PlayerStatusIndicator2"):SetTexture(LEADER_ICON)
            frame:GetNamedChild("PlayerStatusIndicator2"):SetColor(1,1,1,1)
            frame:GetNamedChild("PlayerStatusIndicator2"):SetHidden(false)
        else
            frame:GetNamedChild("PlayerStatusIndicator2"):SetHidden(true)
        end
    end
end

--[[
	Gets sub group for player
]]--
local function GetPlayerSubGroup(player)
    for i,groupControl in pairs(_groupControls) do
        if (groupControl.SubGroup.GroupIdentifer == player.GroupIdentifer) then
            return groupControl
        end
	end

    -- If no specialized SubGroup found, use default group
    return _groupControls["MainGroup"]
end

--[[
	Gets next free frame from given frames
]]--
local function GetUnusedFrame(frames, player)
    for index,frame in ipairs(frames) do
        if (frame.Player == nil or frame.Player.PlayerName == player.PlayerName) then
            return index-1, frame
        end
    end 

    return nil
end

--[[
	AdjustGroupFrame adjusts group width to frame
]]--
local function AdjustGroupFrame(groupControl)
    local frames = groupControl.SubGroup.GroupMemberFrames
    local anchorFrame = frames[1]
    local anchorBotFrame = frames[1]

    for i,frame in ipairs(frames) do
        if (frame.Player ~= nil) then
            if ((i - 1) % 4 == 0) then
                anchorFrame = frame
            end
            
            if (i <= 4) then
                anchorBotFrame = frame
            end
	    end
    end
    
    local groupFrameWidth = math.abs(groupControl:GetLeft() - anchorFrame:GetRight()) + GROUP_FRAME_CORNER
    local groupFrameHeight = math.abs(groupControl:GetTop() - anchorBotFrame:GetBottom()) + GROUP_FRAME_CORNER
    groupControl:SetDimensions(groupFrameWidth, groupFrameHeight)

    groupControl.Header:ClearAnchors()
    groupControl.Header:SetAnchor(TOPLEFT, groupControl, TOPLEFT, 0, 0)
    groupControl.Header:SetAnchor(BOTTOMRIGHT, anchorFrame, TOPRIGHT, 0, 0)
   
end

--[[
	Setup player frame and set it to the player
]]--
local function SetupPlayerFrame(player)
    local groupControl = GetPlayerSubGroup(player)
    local index, nextFreeFrame = GetUnusedFrame(groupControl.SubGroup.GroupMemberFrames, player)
    
    if (nextFreeFrame ~= nil) then
        if (groupControl:IsHidden()) then
		    groupControl:SetHidden(false)
	    end
        
        local subGroupFrames = groupControl.SubGroup.GroupMemberFrames

        -- Set anchor
        nextFreeFrame:ClearAnchors()

        if (index == 0) then
            nextFreeFrame:SetAnchor(TOPLEFT, groupControl.SubGroup, TOPLEFT, 0, 3)
        elseif (index % 4 == 0) then
            nextFreeFrame:SetAnchor(TOPLEFT, subGroupFrames[index - 3], TOPRIGHT, 3, 0)
        else
		    nextFreeFrame:SetAnchor(TOPLEFT, subGroupFrames[index], BOTTOMLEFT, 0, 3)
	    end
        
        player.Frame = nextFreeFrame
        nextFreeFrame.Player = player

        UpdateFrameTrackerIcons(player)
    else
        _logger:logError("GroupFrames -> SetupPlayerFrame; SetupPlayerFrame cannot find free frame for player", player.PlayerName)
    end

    AdjustGroupFrame(groupControl)
end

--[[
	Sets role icon to ultimate tracker
]]--
local function SetRoleIcon(player)
    local frame = player.Frame
    local isDps, isHeal, isTank = GetGroupMemberRoles(player.PingTag)

    if (isDps) then
        frame:GetNamedChild("UltimateTracker"):GetNamedChild("Icon"):SetTexture("EsoUI/Art/LFG/LFG_dps_down.dds")
    elseif (isHeal) then
        frame:GetNamedChild("UltimateTracker"):GetNamedChild("Icon"):SetTexture("EsoUI/Art/LFG/LFG_healer_down.dds")
    else
        frame:GetNamedChild("UltimateTracker"):GetNamedChild("Icon"):SetTexture("EsoUI/Art/LFG/LFG_tank_down.dds")
    end
end

--[[
	Format health label
]]--
local function SetFormattedHealthLabel(player)
    local frame = player.Frame
    local healthBarFormat = _settingsHandler.SavedVariables.HealthBarFormat
    
    if (_settingsHandler.SavedVariables.ShowUltimateInsteadHaelth) then
        frame:GetNamedChild("HealthLabel"):SetText(zo_strformat("<<1>> %", player.RelativeUltimate))
    else
        if (healthBarFormat == 1) then
            frame:GetNamedChild("HealthLabel"):SetText("")
        elseif (healthBarFormat == 2) then
            frame:GetNamedChild("HealthLabel"):SetText(zo_strformat("<<1>>/<<2>>", player.CurentHealth, player.CurrentHealthPool))
        elseif (healthBarFormat == 3) then
            local shortCurrentHealth = string.format("%.0f", player.CurentHealth / 1000)
            local shortHealthPool = string.format("%.0f", player.CurrentHealthPool / 1000)
            frame:GetNamedChild("HealthLabel"):SetText(zo_strformat("<<1>>k/<<2>>k", shortCurrentHealth, shortHealthPool))
        elseif (healthBarFormat == 4) then
            frame:GetNamedChild("HealthLabel"):SetText(zo_strformat("<<1>> %", player.RelativeHealth))
        else
            -- Should not happen
            frame:GetNamedChild("HealthLabel"):SetText("")
        end
    end
end

--[[
	Updates ultimate tracker
]]--
local function UpdateUltimateTracker(player)
    local frame = player.Frame
    local relativeUltimate = player.RelativeUltimate
    local ultimateTracker = frame:GetNamedChild("UltimateTracker")
    local ultimateBar = ultimateTracker:GetNamedChild("UltimateBar")

    if (_settingsHandler.SavedVariables.ShowUltimateInsteadHaelth) then
        ultimateBar:SetHeight(0)
    else
        -- Set progress
        if (relativeUltimate > 0) then
            local ultimateTrackerHeight = ultimateTracker:GetHeight()
            local yOffset = zo_floor(ultimateTrackerHeight * (1 - (relativeUltimate / 100)))
            ultimateBar:SetHeight(yOffset)
        else
            ultimateBar:SetHeight(ultimateTracker:GetHeight())
        end
    end
end

--[[
	Updates player buffs
]]--
local function UpdatePlayerBuffs(player)
	if (player and player.Frame) then
        local frame = player.Frame
        
        local buffId1 = _settingsHandler.SavedVariables.TrackedBuffs[GROUP_FRAMES].TrackedBuff1AbilityId
        local buffId2 = _settingsHandler.SavedVariables.TrackedBuffs[GROUP_FRAMES].TrackedBuff2AbilityId
        local buffId3 = _settingsHandler.SavedVariables.TrackedBuffs[GROUP_FRAMES].TrackedBuff3AbilityId
        local buffId4 = _settingsHandler.SavedVariables.TrackedBuffs[GROUP_FRAMES].TrackedBuff4AbilityId

        local buff1Active = player.Buffs[buffId1] ~= nil and player.Buffs[buffId1].isActive
        local buff2Active = player.Buffs[buffId2] ~= nil and player.Buffs[buffId2].isActive
        local buff3Active = player.Buffs[buffId3] ~= nil and player.Buffs[buffId3].isActive
        local buff4Active = player.Buffs[buffId4] ~= nil and player.Buffs[buffId4].isActive

        UpdateBuffTracker(frame:GetNamedChild("BuffTracker1"), buffId1, buff1Active)
        UpdateBuffTracker(frame:GetNamedChild("BuffTracker2"), buffId2, buff2Active)
        UpdateBuffTracker(frame:GetNamedChild("BuffTracker3"), buffId3, buff3Active)
        UpdateBuffTracker(frame:GetNamedChild("BuffTracker4"), buffId4, buff4Active)

    end
end

--[[
	Updates player frame
]]--
local function UpdatePlayerFrame(player)
    if (player.Frame == nil) then
        SetupPlayerFrame(player)
    end

    local frame = player.Frame

    if (frame ~= nil) then
        if (player.UltimateGroup ~= nil) then
            local abilityId = player.UltimateGroup.GroupAbilityId
            if (frame.AbilityId ~= abilityId) then
                frame.AbilityId = abilityId
                frame:GetNamedChild("UltimateTracker"):GetNamedChild("Icon"):SetTexture(GetAbilityIcon(abilityId))
            end
        else
            if (frame.AbilityId ~= 0) then
                frame.AbilityId = 0
                SetRoleIcon(player)
            end
        end
        
        local playerName = player.PlayerName
        if (_settingsHandler.SavedVariables.AccountNames) then
            playerName = GetUnitDisplayName(player.PingTag)
        end

        frame:GetNamedChild("NameLabel"):SetText(playerName)

        if (player.IsPlayerOnline and not player.IsPlayerDead) then
            
            SetFormattedHealthLabel(player)
            frame:GetNamedChild("StaminaLabel"):SetText(zo_strformat("<<1>> %", player.RelativeStamina))
            frame:GetNamedChild("MagickaLabel"):SetText(zo_strformat("<<1>> %", player.RelativeMagicka))

            if (_settingsHandler.SavedVariables.ShowUltimateInsteadHaelth) then
                ZO_StatusBar_SmoothTransition(frame:GetNamedChild("HealthTracker"):GetNamedChild("StatusBar"), player.RelativeUltimate, 100, false)
                ZO_StatusBar_SmoothTransition(frame:GetNamedChild("ShieldTracker"):GetNamedChild("StatusBar"), 0, 100, false)
            else
                ZO_StatusBar_SmoothTransition(frame:GetNamedChild("HealthTracker"):GetNamedChild("StatusBar"), player.RelativeHealth, 100, false)
                ZO_StatusBar_SmoothTransition(frame:GetNamedChild("ShieldTracker"):GetNamedChild("StatusBar"), player.RelativeShield, 100, false)
            end
            ZO_StatusBar_SmoothTransition(frame:GetNamedChild("StaminaTracker"):GetNamedChild("StatusBar"), player.RelativeStamina, 100, false)
            ZO_StatusBar_SmoothTransition(frame:GetNamedChild("MagickaTracker"):GetNamedChild("StatusBar"), player.RelativeMagicka, 100, false)
        else
            if (_settingsHandler.SavedVariables.ShowUltimateInsteadHaelth) then
                frame:GetNamedChild("HealthLabel"):SetText("-")
            else
                frame:GetNamedChild("HealthLabel"):SetText("-/-")
            end

            frame:GetNamedChild("StaminaLabel"):SetText("-")
            frame:GetNamedChild("MagickaLabel"):SetText("-")
            
            ZO_StatusBar_SmoothTransition(frame:GetNamedChild("HealthTracker"):GetNamedChild("StatusBar"), 0, 100, false)
            ZO_StatusBar_SmoothTransition(frame:GetNamedChild("ShieldTracker"):GetNamedChild("StatusBar"), 0, 100, false)
            ZO_StatusBar_SmoothTransition(frame:GetNamedChild("StaminaTracker"):GetNamedChild("StatusBar"), 0, 100, false)
            ZO_StatusBar_SmoothTransition(frame:GetNamedChild("MagickaTracker"):GetNamedChild("StatusBar"), 0, 100, false)
        end
        
        UpdateUltimateTracker(player)
        UpdatePlayerBuffs(player)
        UpdateFrameColors(player)
        UpdateFrameStatusIcons(player)
        
        if (frame:IsHidden()) then
		    frame:SetHidden(false)
	    end
    end
end

--[[
	SetUiConfiguration Updates UI configuration
]]--
local function SetUiConfiguration()
    local style = _settingsHandler.SavedVariables.Style[GROUP_FRAMES]
    local frameWidth = _settingsHandler.SavedVariables.GroupFramesBarWidth

    for id, groupControl in pairs(_groupControls) do
        local frames = groupControl.SubGroup.GroupMemberFrames

        for j,frame in ipairs(frames) do
            frame:SetWidth(frameWidth)

            if (style == 3) then
                frame:GetNamedChild("PlayerStatusIndicator1"):SetHidden(true)
                frame:GetNamedChild("PlayerStatusIndicator2"):SetHidden(true)

                frame:GetNamedChild("BuffTracker1"):SetHidden(true)
                frame:GetNamedChild("BuffTracker2"):SetHidden(true)
                frame:GetNamedChild("BuffTracker3"):SetHidden(true)
                frame:GetNamedChild("BuffTracker4"):SetHidden(true)

                frame:GetNamedChild("StaminaTracker"):SetHidden(true)
                frame:GetNamedChild("MagickaTracker"):SetHidden(true)
                frame:GetNamedChild("StaminaLabel"):SetHidden(true)
                frame:GetNamedChild("MagickaLabel"):SetHidden(true)
                
                frame:GetNamedChild("HealthLabel"):SetVerticalAlignment(TEXT_ALIGN_CENTER)
                frame:GetNamedChild("NameLabel"):SetVerticalAlignment(TEXT_ALIGN_CENTER)
                frame:GetNamedChild("HealthTracker"):SetHeight(30)
                frame:GetNamedChild("ShieldTracker"):SetHeight(30)
                frame:GetNamedChild("UltimateTracker"):SetDimensions(30, 30)
                frame:SetHeight(30)
            elseif (style == 2) then

                frame:GetNamedChild("BuffTracker1"):SetHidden(true)
                frame:GetNamedChild("BuffTracker2"):SetHidden(true)
                frame:GetNamedChild("BuffTracker3"):SetHidden(true)
                frame:GetNamedChild("BuffTracker4"):SetHidden(true)

                frame:GetNamedChild("StaminaTracker"):SetHidden(true)
                frame:GetNamedChild("MagickaTracker"):SetHidden(true)
                frame:GetNamedChild("StaminaLabel"):SetHidden(true)
                frame:GetNamedChild("MagickaLabel"):SetHidden(true)
                
                frame:GetNamedChild("HealthLabel"):SetVerticalAlignment(TEXT_ALIGN_BOTTOM)
                frame:GetNamedChild("NameLabel"):SetVerticalAlignment(TEXT_ALIGN_BOTTOM)
                frame:GetNamedChild("HealthTracker"):SetHeight(40)
                frame:GetNamedChild("ShieldTracker"):SetHeight(40)
                frame:GetNamedChild("UltimateTracker"):SetDimensions(40, 40)
                frame:SetHeight(40)
            else
                frame:GetNamedChild("BuffTracker1"):SetHidden(false)
                frame:GetNamedChild("BuffTracker2"):SetHidden(false)
                frame:GetNamedChild("BuffTracker3"):SetHidden(false)
                frame:GetNamedChild("BuffTracker4"):SetHidden(false)

                frame:GetNamedChild("StaminaTracker"):SetHidden(false)
                frame:GetNamedChild("MagickaTracker"):SetHidden(false)
                frame:GetNamedChild("StaminaLabel"):SetHidden(false)
                frame:GetNamedChild("MagickaLabel"):SetHidden(false)
                
                frame:GetNamedChild("HealthLabel"):SetVerticalAlignment(TEXT_ALIGN_BOTTOM)
                frame:GetNamedChild("NameLabel"):SetVerticalAlignment(TEXT_ALIGN_BOTTOM)
                frame:GetNamedChild("HealthTracker"):SetHeight(40)
                frame:GetNamedChild("ShieldTracker"):SetHeight(40)
                frame:GetNamedChild("UltimateTracker"):SetDimensions(40, 40)
                frame:SetHeight(80)
            end
        end

        AdjustGroupFrame(groupControl)
    end
end

--[[
	HideZosUI sets hidden on standard controls
]]--
local function HideZosUI()
    local isActive = _settingsHandler.SavedVariables.IsGroupFramesEnabled
    local doHideFrames = _settingsHandler.SavedVariables.HideZosGroupFrames

    if (isActive and doHideFrames and GetIsUnitGrouped()) then
        ZO_UnitFramesGroups:SetHidden(true)
    end
end

--[[
	Sets visibility of labels
]]--
local function RefreshList()
    local functionTimestamp = GetGameTimeMilliseconds()

    SetUiConfiguration()
    HideZosUI()

    local players = _playerHandler.GetGroupPlayers()

    for i,player in pairs(players) do
        UpdatePlayerFrame(player)
    end

    _logger:logTrace("TGT_GroupFrames -> RefreshList", GetGameTimeMilliseconds() - functionTimestamp)
end

--[[
	Updates player
]]--
local function UpdatePlayer(player)
	if (player) then
        UpdatePlayerFrame(player)
    end
end

--[[
	Gets flag that checks group players
]]--
local function HasGroupPlayers(groupControl)
    local frames = groupControl.SubGroup.GroupMemberFrames
    local hasGroupPlayers = false

    for i,frame in ipairs(frames) do
        if (frame.Player ~= nil) then
            hasGroupPlayers = true
            break
        end
    end

    return hasGroupPlayers
end

--[[
	SetControlHidden sets hidden on control
]]--
local function SetControlHidden()
    if (_isCreated) then
        local framesHidden = true
        if (_settingsHandler.SavedVariables.IsGroupFramesEnabled) then
            if (GetIsUnitGrouped()) then
			    framesHidden = CurrentHudHiddenState()
            end
        end

        for id, frame in pairs(_groupControls) do
            if (HasGroupPlayers(frame)) then
                frame:SetHidden(framesHidden)
            else
                frame:SetHidden(true)
            end
        end
    end
end

--[[
	Clears player
]]--
local function ClearPlayer(player)
    if (player) then
        for i,groupControl in pairs(_groupControls) do
            local frames = groupControl.SubGroup.GroupMemberFrames
            local removed = false

            for j,frame in ipairs(frames) do
                if (frame.Player ~= nil) then
                    if (frame.Player.PlayerName == player.PlayerName) then
                        removed = true

                        local framePlayer = frame.Player
                        framePlayer.Frame = nil
                        frame:SetHidden(true)
                        frame.Player = nil
                    elseif (removed) then
                        local framePlayer = frame.Player
                        framePlayer.Frame = frames[j-1]
                        frames[j-1].Player = framePlayer
                        UpdatePlayerFrame(framePlayer)

                        frame:SetHidden(true)
                        frame.Player = nil
                    end
                else
                    frame:SetHidden(true)
                end
            end

            AdjustGroupFrame(groupControl)
            SetControlHidden()
        end
    end
end

--[[
	ChangePlayerSubGroup Clears player from old group and reconnects player on new group
]]--
local function ChangePlayerSubGroup(player)
    ClearPlayer(player)
    UpdatePlayerFrame(player)
end

--[[
	SetControlMovable sets the Movable and MouseEnabled flag in UI elements
]]--
local function SetControlMovable()
    local isMovable = _settingsHandler.SavedVariables.Movable

    for id, frame in pairs(_groupControls) do
        frame:GetNamedChild("MovableControl"):SetHidden(isMovable == false)
        frame:SetMovable(isMovable)
	    frame:SetMouseEnabled(isMovable)
    end
end

--[[
	RestorePosition sets TGT_GroupFrames on settings position
]]--
local function RestorePosition()
    for id, frame in pairs(_groupControls) do
        local frameX = _settingsHandler.SavedVariables.GroupFrameGroups[id].PosX
        local frameY = _settingsHandler.SavedVariables.GroupFrameGroups[id].PosY

        frame:ClearAnchors()
        frame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, frameX, frameY)
    end
end

--[[
	SetControlScale sets the Scale in UI elements
]]--
local function SetControlScale()
    local scale = _settingsHandler.SavedVariables.Scale[GROUP_FRAMES]

    for id, frame in pairs(_groupControls) do
        frame:SetScale(scale)
    end
end

--[[
	SetBufftrackerIcons sets configurated buffs Bufftracker Icons
]]--
local function SetBufftrackerIcons()
    local players = _playerHandler.GetGroupPlayers()

    for i,player in pairs(players) do
        UpdateFrameTrackerIcons(player)
    end
end

--[[
	SetSubGroupName sets configurated sub group name
]]--
local function SetSubGroupName(subGroupIdentifier, name)
    for id, frame in pairs(_groupControls) do
        if (frame.SubGroup.GroupIdentifer == subGroupIdentifier) then
            frame.Header:SetText(name)
            break
        end
    end
end

--[[
	CreateAndAddSubGroup creates sub group and their frames
]]--
local function CreateAndAddSubGroup(groupFrame, groupIdentifer, groupName)
    groupFrame.Header = groupFrame:GetNamedChild("SubGroupHeader")
    groupFrame.SubGroup = groupFrame:GetNamedChild("GroupMembers")
    groupFrame.SubGroup.GroupIdentifer = groupIdentifer
    groupFrame.SubGroup.GroupMemberFrames = {}

    local subGroup = groupFrame.SubGroup
    local subGroupFrames = groupFrame.SubGroup.GroupMemberFrames

    for i=0, (GROUP_SIZE_MAX - 1), 1 do
        local nextFreeFrame = i + 1
        local frame = CreateControlFromVirtual("$(parent)PlayerFrame", subGroup, "GroupMemberFrame", nextFreeFrame)
        
        local glowAnimation = ZO_AlphaAnimation:New(frame:GetNamedChild("UltimateTracker"):GetNamedChild("Glow"))
        glowAnimation:SetMinMaxAlpha(0, 1)
        frame.GlowAnimation = glowAnimation

        local button = frame:GetNamedChild("UltimateTracker"):GetNamedChild("Button")
        button:SetHandler("OnClicked", function() TGT_GroupFrames_OnSubGroupButtonClicked(button, frame) end)

        frame:SetHidden(true)

        subGroupFrames[nextFreeFrame] = frame
    end
    
    groupFrame.Header:SetText(groupName)
    groupFrame:SetHidden(true)

    _groupControls[groupFrame.SubGroup.GroupIdentifer] = groupFrame
end

--[[
	Creates group controls
]]--
local function CreateGroupControls()
    local frameGroups = _settingsHandler.SavedVariables.GroupFrameGroups
    CreateAndAddSubGroup(TGT_GroupFramesMainGroupControl, "MainGroup", frameGroups["MainGroup"].Name)
    CreateAndAddSubGroup(TGT_GroupFramesSubGroup1Control, "SubGroup1", frameGroups["SubGroup1"].Name)
    CreateAndAddSubGroup(TGT_GroupFramesSubGroup2Control, "SubGroup2", frameGroups["SubGroup2"].Name)
    CreateAndAddSubGroup(TGT_GroupFramesSubGroup3Control, "SubGroup3", frameGroups["SubGroup3"].Name)
    CreateAndAddSubGroup(TGT_GroupFramesSubGroup4Control, "SubGroup4", frameGroups["SubGroup4"].Name)
    CreateAndAddSubGroup(TGT_GroupFramesSubGroup5Control, "SubGroup5", frameGroups["SubGroup5"].Name)
end

--[[
	SetControlColor sets control color
]]--
local function SetControlColors(part)
    if (part == GROUP_FRAMES) then
        local shieldColor = _settingsHandler.SavedVariables.ModuleColors[part].ShieldColor
        local ultimateReadyColor = _settingsHandler.SavedVariables.ModuleColors[part].UltimateReadyColor
        local ultimateProgrColor = _settingsHandler.SavedVariables.ModuleColors[part].UltimateProgrColor
        local healthReadyColor = _settingsHandler.SavedVariables.ModuleColors[part].HealthReadyColor
        local healthProgrColor = _settingsHandler.SavedVariables.ModuleColors[part].HealthProgrColor
        local stamReadyColor = _settingsHandler.SavedVariables.ModuleColors[part].StaminaReadyColor
        local stamProgrColor = _settingsHandler.SavedVariables.ModuleColors[part].StaminaProgrColor
        local magiReadyColor = _settingsHandler.SavedVariables.ModuleColors[part].MagickaReadyColor
        local magiProgrColor = _settingsHandler.SavedVariables.ModuleColors[part].MagickaProgrColor

        _controlColors = {
            ["ShieldColor"] = { ["Background"] = shieldColor, ["Label"] = GetAdjustedLabelColor(shieldColor) },
            ["UltimateReadyColor"] = { ["Background"] = ultimateReadyColor, ["Label"] = GetAdjustedLabelColor(ultimateReadyColor) },
            ["UltimateProgrColor"] = { ["Background"] = ultimateProgrColor, ["Label"] = GetAdjustedLabelColor(ultimateProgrColor) },
            ["HealthReadyColor"] = { ["Background"] = healthReadyColor, ["Label"] = GetAdjustedLabelColor(healthReadyColor) },
            ["HealthProgrColor"] = { ["Background"] = healthProgrColor, ["Label"] = GetAdjustedLabelColor(healthProgrColor) },
            ["StamReadyColor"] = { ["Background"] = stamReadyColor, ["Label"] = GetAdjustedLabelColor(stamReadyColor) },
            ["StamProgrColor"] = { ["Background"] = stamProgrColor, ["Label"] = GetAdjustedLabelColor(stamProgrColor) },
            ["MagiReadyColor"] = { ["Background"] = magiReadyColor, ["Label"] = GetAdjustedLabelColor(magiReadyColor) },
            ["MagiProgrColor"] = { ["Background"] = magiProgrColor, ["Label"] = GetAdjustedLabelColor(magiProgrColor) }
        }
    end
end

--[[
	SetControlActive sets hidden on control
]]--
local function SetControlActive()
    SetControlHidden()
    HideZosUI()

    -- Get isActive from settings
    local isActive = _settingsHandler.SavedVariables.IsGroupFramesEnabled

    if (_isActive ~= isActive) then
        _isActive = isActive

        if (isActive) then
            -- Workaround: To avoid "Too many anchors processed" error; Thank you ZOS for stealing hours of my life!
            if (_isCreated == false) then
                _isCreated = true
                CreateGroupControls()
            end
            
            SetUiConfiguration()
            SetControlColors(GROUP_FRAMES)
            SetControlMovable()
            RestorePosition()
            SetBufftrackerIcons()
            SetControlScale()
            
            CALLBACK_MANAGER:RegisterCallback(TGT_STYLE_CHANGED, SetUiConfiguration)
            CALLBACK_MANAGER:RegisterCallback(TGT_PLAYER_DATA_OFFLINE_CHANGED, UpdatePlayer)
            CALLBACK_MANAGER:RegisterCallback(TGT_PLAYER_DATA_REMOTE_CHANGED, UpdatePlayer)
            CALLBACK_MANAGER:RegisterCallback(TGT_PLAYER_DATA_BUFFS_CHANGED, UpdatePlayerBuffs)
            CALLBACK_MANAGER:RegisterCallback(TGT_PLAYER_DATA_CLEAR, ClearPlayer)
            CALLBACK_MANAGER:RegisterCallback(TGT_PLAYER_DATA_SUB_GROUP_CHANGED, ChangePlayerSubGroup)
            CALLBACK_MANAGER:RegisterCallback(TGT_MOVABLE_CHANGED, SetControlMovable)
            CALLBACK_MANAGER:RegisterCallback(TGT_COLOR_SETTINGS_CHANGED, SetControlColors)
            CALLBACK_MANAGER:RegisterCallback(TAO_HUD_HIDDEN_STATE_CHANGED, SetControlHidden)
            CALLBACK_MANAGER:RegisterCallback(TGT_GROUP_BUFFS_ABILITY_IDS_CHANGED, SetBufftrackerIcons)
            CALLBACK_MANAGER:RegisterCallback(TGT_SCALING_CHANGED, SetControlScale)
            CALLBACK_MANAGER:RegisterCallback(TGT_SUB_GROUP_NAME_CHANGED, SetSubGroupName)
            CALLBACK_MANAGER:RegisterCallback(TGT_GROUP_FRAMES_SETTINGS_CHANGED, RefreshList)
        else
            CALLBACK_MANAGER:UnregisterCallback(TGT_STYLE_CHANGED, SetUiConfiguration)
            CALLBACK_MANAGER:UnregisterCallback(TGT_PLAYER_DATA_OFFLINE_CHANGED, UpdatePlayer)
            CALLBACK_MANAGER:UnregisterCallback(TGT_PLAYER_DATA_REMOTE_CHANGED, UpdatePlayer)
            CALLBACK_MANAGER:UnregisterCallback(TGT_PLAYER_DATA_BUFFS_CHANGED, UpdatePlayerBuffs)
            CALLBACK_MANAGER:UnregisterCallback(TGT_PLAYER_DATA_CLEAR, ClearPlayer)
            CALLBACK_MANAGER:UnregisterCallback(TGT_PLAYER_DATA_SUB_GROUP_CHANGED, ChangePlayerSubGroup)
            CALLBACK_MANAGER:UnregisterCallback(TGT_MOVABLE_CHANGED, SetControlMovable)
            CALLBACK_MANAGER:UnregisterCallback(TGT_COLOR_SETTINGS_CHANGED, SetControlColors)
            CALLBACK_MANAGER:UnregisterCallback(TAO_HUD_HIDDEN_STATE_CHANGED, SetControlHidden)
            CALLBACK_MANAGER:UnregisterCallback(TGT_GROUP_BUFFS_ABILITY_IDS_CHANGED, SetBufftrackerIcons)
            CALLBACK_MANAGER:UnregisterCallback(TGT_SCALING_CHANGED, SetControlScale)
            CALLBACK_MANAGER:UnregisterCallback(TGT_SUB_GROUP_NAME_CHANGED, SetSubGroupName)
            CALLBACK_MANAGER:UnregisterCallback(TGT_GROUP_FRAMES_SETTINGS_CHANGED, RefreshList)
        end
    end
end

--[[
	OnSetSubGroup sets sub group for player
]]--
local function OnSetSubGroup(groupIdentifer, frame)
    CALLBACK_MANAGER:UnregisterCallback(TGT_SET_SUB_GROUP, OnSetSubGroup)

    if (groupIdentifer ~= nil and frame.Player) then
        _playerHandler.SetPlayerSubGroup(groupIdentifer, frame.Player)
    else
        _logger:logError("GroupFrames -> OnSetSubGroup invalid", groupIdentifer, frame.Player)
    end
end

--[[
	==============
    PUBLIC METHODS
    ==============
]]--

--[[
	OnMoveStop saves current TGT_GroupFrames position to settings
]]--
function TGT_GroupFrames_OnMoveStop(frame)
    _settingsHandler.SavedVariables.GroupFrameGroups[frame.SubGroup.GroupIdentifer].PosX = frame:GetLeft()
    _settingsHandler.SavedVariables.GroupFrameGroups[frame.SubGroup.GroupIdentifer].PosY = frame:GetTop()
end

--[[
	TGT_GroupFrames_OnSubGroupButtonClicked shows sub group menu
]]--
function TGT_GroupFrames_OnSubGroupButtonClicked(button, frame)
    if (button ~= nil and frame ~= nil) then
        CALLBACK_MANAGER:RegisterCallback(TGT_SET_SUB_GROUP, OnSetSubGroup)
        FireCallbacksAsync(TGT_SHOW_SUB_GROUP_MENU, button, frame)
    else
        _logger:logError("TGT_GroupFrames_OnSubGroupButtonClicked invalid", button, frame)
    end
end

--[[
	Initialize initializes TGT_GroupFrames
]]--
function TGT_GroupFrames.Initialize()
    _logger = TGT_LOGGER

    CALLBACK_MANAGER:RegisterCallback(TGT_SENDING_CHANGED, SetControlActive)
    CALLBACK_MANAGER:RegisterCallback(TGT_IS_ZONE_CHANGED, SetControlActive)
    CALLBACK_MANAGER:RegisterCallback(TGT_PLAYER_ACTIVATED, SetControlActive)
    CALLBACK_MANAGER:RegisterCallback(TAO_UNIT_GROUPED_CHANGED, SetControlActive)
    CALLBACK_MANAGER:RegisterCallback(TGT_GROUP_FRAMES_ENABLED_CHANGED, SetControlActive)
    
    _logger:logTrace("TGT_GroupFrames -> Initialized")
end