--[[
	Addon: Taos Group Tools
	Author: TProg Taonnor
	Created by @Taonnor
]]--

--[[
	Global callbacks
]]--
TGT_SENDING_CHANGED = "TGT-SendDataChanged"
TGT_GROUP_ULTIMATE_ENABLED_CHANGED = "TGT-GroupUltimateEnabledChanged"
TGT_STYLE_CHANGED = "TGT-StyleChanged"
TGT_MOVABLE_CHANGED = "TGT-MovableChanged"
TGT_IS_ZONE_CHANGED = "TGT-IsZoneChanged"
TGT_VISIBLE_OFFSET_CHANGED = "TGT-VisibleOffsetChanged"
TGT_STATIC_ULTIMATE_ID_CHANGED = "TGT-StaticUltimateIDChanged"
TGT_SWIMLANE_ULTIMATE_GROUP_ID_CHANGED = "TGT-SwimlaneUltimateGroupIdChanged"
TGT_SWIMLANES_CHANGED = "TGT-SwimlanesChanged"
TGT_SCALING_CHANGED = "TGT-SwimlaneScalingChanged"
TGT_LEADER_ICON_ACTIVE_CHANGED = "TGT-IconActiveChanged"
TGT_LEADER_ICON_PROPERTIES_CHANGED = "TGT-IconPropertiesChanged"
TGT_ARROW_ACTIVE_CHANGED = "TGT-ArrowActiveChanged"
TGT_GROUP_INVITE_ENABLED_CHANGED = "TGT-GroupInviteEnabledChanged"
TGT_GROUP_DPSHPS_ENABLED_CHANGED = "TGT-GroupDpsHpsEnabledChanged"
TGT_GROUP_DPSHPS_PART_CHANGED = "TGT-DpsHpsPartStyleChanged"
TGT_GROUP_RESOURCES_ENABLED_CHANGED = "TGT-GroupResourcesEnabledChanged"
TGT_GROUP_BUFFS_ENABLED_CHANGED = "TGT-GroupBuffsEnabledChanged"
TGT_GROUP_BUFFS_ABILITY_IDS_CHANGED = "TGT-GroupBuffsAbilityIdsChanged"
TGT_GROUP_FRAMES_ENABLED_CHANGED = "TGT-GroupFramesEnabledChanged"
TGT_GROUP_FRAMES_SETTINGS_CHANGED = "TGT-GroupFramesSettingsChanged"
TGT_SUB_GROUP_NAME_CHANGED = "TGT-SuBgroupNameChanged"
TGT_GROUP_DETO_ENABLED_CHANGED = "TGT-GroupDetoEnabledChanged"
TGT_GROUP_DETO_HEADER_CHANGED = "TGT-GroupDetoHeaderChanged"
TGT_GROUP_DETO_SIZE_CHANGED = "TGT-GroupDetoSizeChanged"
TGT_COMPASS_ACTIVE_CHANGED = "TGT-CompassActiveChanged"
TGT_COMPASS_RADIUS_CHANGED = "TGT-CompassRadiusChanged"
TGT_COMPASS_FONT_CHANGED = "TGT-CompassFontChanged"
TGT_COMPASS_FLAT_CHANGED = "TGT-CompassFlatChanged"
TGT_COMPASS_ZOS_COMPASS_CHANGED = "TGT-ZosCompassChanged"
TGT_GROUP_PURGE_ENABLED_CHANGED = "TGT-GroupPurgeEnabledChanged"
TGT_GROUP_PURGE_HEADER_CHANGED = "TGT-GroupPurgeHeaderChanged"
TGT_GROUP_PURGE_SIZE_CHANGED = "TGT-GroupPurgeSizeChanged"
TGT_GROUP_SPEED_ENABLED_CHANGED = "TGT-GroupSpeedEnabledChanged"
TGT_GROUP_SPEED_HEADER_CHANGED = "TGT-GroupSpeedHeaderChanged"
TGT_GROUP_SPEED_SIZE_CHANGED = "TGT-GroupSpeedSizeChanged"
TGT_GROUP_EARTHGORE_ENABLED_CHANGED = "TGT-GroupPurgeEnabledChanged"
TGT_GROUP_EARTHGORE_HEADER_CHANGED = "TGT-GroupPurgeHeaderChanged"
TGT_GROUP_EARTHGORE_SIZE_CHANGED = "TGT-GroupPurgeSizeChanged"
TGT_COLOR_SETTINGS_CHANGED = "TGT-ColorSettingsChanged"

--[[
	Global values
]]--
GROUP_ULTIMATE = "TGT-GroupUltimate"
GROUP_ULTIMATE_SELECTOR = "TGT-UltimateSelector"
GROUP_STATS = "TGT-GroupStats"
GROUP_FRAMES = "TGT-GroupFrames"
GROUP_LEADER = "TGT-GroupLeader"
GROUP_DETONATION = "TGT-GroupDeto"
GROUP_PURGE = "TGT-GroupPurge"
GROUP_SPEED = "TGT-GroupSpeed"
GROUP_EARTHGORE = "TGT-GroupEarthgore"

--[[
	Local variables
]]--
local SETTINGS_VERSION = 13

local _logger = nil

local _name = "TGT-SettingsHandler"
local _settingsName = "TaosGroupToolSettings"

--[[
	Table TGT_SettingsHandler
]]--
TGT_SettingsHandler = {}
TGT_SettingsHandler.__index = TGT_SettingsHandler

--[[
	Table Members
]]--
TGT_SettingsHandler.SavedVariables = nil
TGT_SettingsHandler.Icons = {
    [1] = { name = GetString(TGT_OPTIONS_ICONS_DEFAULT), path = "esoui/art/compass/groupleader.dds" },
    [2] = { name = GetString(TGT_OPTIONS_ICONS_OUROSBOROS), path = "esoui/art/gammaadjust/gamma_referenceimage1.dds" },
    [3] = { name = GetString(TGT_OPTIONS_ICONS_CP), path = "esoui/art/menubar/gamepad/gp_playermenu_icon_champion.dds" },
    [4] = { name = GetString(TGT_OPTIONS_ICONS_SKILL), path = "esoui/art/menubar/gamepad/gp_playermenu_icon_skills.dds" },
    [5] = { name = GetString(TGT_OPTIONS_ICONS_STORE), path = "esoui/art/menubar/gamepad/gp_playermenu_icon_store.dds" },
    [6] = { name = GetString(TGT_OPTIONS_ICONS_CROWN), path = "esoui/art/menubar/gamepad/gp_playermenu_icon_crowncrates.dds" },
    [7] = { name = GetString(TGT_OPTIONS_ICONS_EMP), path = "esoui/art/campaign/gamepad/gp_overview_menuicon_emperor.dds" },
    [8] = { name = GetString(TGT_OPTIONS_ICONS_CS), path = "esoui/art/campaign/campaignbrowser_indexicon_normal_down.dds" },
    [9] = { name = GetString(TGT_OPTIONS_ICONS_SB), path = "esoui/art/lfg/lfg_tabicon_mygroup_down.dds" },
    [10] = { name = GetString(TGT_OPTIONS_ICONS_QUEST), path = "esoui/art/floatingmarkers/quest_icon.dds" },
    [11] = { name = GetString(TGT_OPTIONS_ICONS_ARCH), path = "esoui/art/journal/journal_tabicon_achievements_down.dds" },
    [12] = { name = GetString(TGT_OPTIONS_ICONS_INTEREST), path = "esoui/art/icons/poi/poi_areaofinterest_complete.dds" },
    [13] = { name = GetString(TGT_OPTIONS_ICONS_GB), path = "esoui/art/icons/poi/poi_groupboss_complete.dds" },
    [14] = { name = GetString(TGT_OPTIONS_ICONS_FG), path = "esoui/art/icons/servicemappins/servicepin_fightersguild.dds" },
    [15] = { name = GetString(TGT_OPTIONS_ICONS_MG), path = "esoui/art/icons/servicemappins/servicepin_magesguild.dds" },
    [16] = { name = GetString(TGT_OPTIONS_ICONS_AD), path = "esoui/art/stats/alliancebadge_aldmeri.dds" },
    [17] = { name = GetString(TGT_OPTIONS_ICONS_DC), path = "esoui/art/stats/alliancebadge_daggerfall.dds" },
    [18] = { name = GetString(TGT_OPTIONS_ICONS_EP), path = "esoui/art/stats/alliancebadge_ebonheart.dds" },
}
TGT_SettingsHandler.CompassFonts = {
    [1] = { name = GetString(TGT_OPTIONS_COMPASS_FONT_STANDARD), fontName = "StandardMediumCompassFont" },
    [2] = { name = GetString(TGT_OPTIONS_COMPASS_FONT_STANDARD_BOLD), fontName = "StandardBoldCompassFont" },
    [3] = { name = GetString(TGT_OPTIONS_COMPASS_FONT_GAMEPAD_LIGHT), fontName = "GamepadLightCompassFont" },
    [4] = { name = GetString(TGT_OPTIONS_COMPASS_FONT_GAMEPAD_MEDIUM), fontName = "GamepadMediumCompassFont" },
    [5] = { name = GetString(TGT_OPTIONS_COMPASS_FONT_GAMEPAD_BOLD), fontName = "GamepadBoldCompassFont" },
    [6] = { name = GetString(TGT_OPTIONS_COMPASS_FONT_ANTIQUE), fontName = "AntiqueCompassfont" },
    [7] = { name = GetString(TGT_OPTIONS_COMPASS_FONT_HANDWRITTEN), fontName = "HandwrittenCompassfont" },
    [8] = { name = GetString(TGT_OPTIONS_COMPASS_FONT_STONETABLE), fontName = "StoneTableCompassfont" },
}

--[[
	==============
    PUBLIC METHODS
    ==============
]]--

--[[
	Sets SetStyleSettings and fires TGT_STYLE_CHANGED callbacks
]]--
function TGT_SettingsHandler.SetStyleSettings(part, style)
    local numberStyle = tonumber(style)

    if (numberStyle == 1 or numberStyle == 2 or numberStyle == 3) then
        TGT_SettingsHandler.SavedVariables.Style[part] = numberStyle

        FireCallbacksAsync(TGT_STYLE_CHANGED)
    end
end

--[[
	Sets SetScaleSettings and fires TGT_SCALING_CHANGED callbacks
]]--
function TGT_SettingsHandler.SetScaleSettings(part, scaling)
    TGT_SettingsHandler.SavedVariables.Scale[part] = scaling
    FireCallbacksAsync(TGT_SCALING_CHANGED)
end

--[[
	Sets OnlyAvaSettings and fires TGT_IS_ZONE_CHANGED callbacks
]]--
function TGT_SettingsHandler.SetOnlyAvaSettings(part, onlyAva)
    TGT_SettingsHandler.SavedVariables.OnlyAva[part] = onlyAva
    FireCallbacksAsync(TGT_IS_ZONE_CHANGED)
end

--[[
	Sets VisibleOffsetSettings and fires TGT_VISIBLE_OFFSET_CHANGED callbacks
]]--
function TGT_SettingsHandler.SetVisibleOffsetSettings(part, visibleOffset)
    TGT_SettingsHandler.SavedVariables.VisibleOffset[part] = visibleOffset
    FireCallbacksAsync(TGT_VISIBLE_OFFSET_CHANGED)
end

--[[
	Sets CombatActive settings
]]--
function TGT_SettingsHandler.SetCombatActiveSettings(part, isCombatActive)
    TGT_SettingsHandler.SavedVariables.CombatActive[part] = isCombatActive
end

--[[
	Sets MovableSettings and fires TGT_MOVABLE_CHANGED callbacks
]]--
function TGT_SettingsHandler.SetMovableSettings(movable)
    TGT_SettingsHandler.SavedVariables.Movable = movable
    FireCallbacksAsync(TGT_MOVABLE_CHANGED)
end

--[[
	Sets StaticUltimateID Settings and fires TGT_STATIC_ULTIMATE_ID_CHANGED callbacks
]]--
function TGT_SettingsHandler.SetStaticUltimateIDSettings(staticUltimateID)
    TGT_SettingsHandler.SavedVariables.StaticUltimateID[GetUnitName("player")] = staticUltimateID
    FireCallbacksAsync(TGT_STATIC_ULTIMATE_ID_CHANGED, staticUltimateID)
end

--[[
	Gets StaticUltimateID
]]--
function TGT_SettingsHandler.GetStaticUltimateIDSettings()
	local foundUltimate = TGT_SettingsHandler.SavedVariables.StaticUltimateID[GetUnitName("player")]
	
	-- If not found, return default
	if (foundUltimate ~= nil) then
		return foundUltimate
	else
		return TGT_SettingsHandler.SavedVariables.StaticUltimateID["Default"]
	end
end

--[[
	Sets StaticUltimateIDSettings and fires TGT_SWIMLANE_ULTIMATE_GROUP_ID_CHANGED callbacks
]]--
function TGT_SettingsHandler.SetSwimlaneUltimateGroupIdSettings(swimlane, ultimateGroup)
    TGT_SettingsHandler.SavedVariables.SwimlaneUltimateGroupIds[swimlane] = ultimateGroup.GroupAbilityId
    FireCallbacksAsync(TGT_SWIMLANE_ULTIMATE_GROUP_ID_CHANGED, swimlane, ultimateGroup)
end

--[[
	Sets StaticUltimateIDSettings and fires TGT_SWIMLANE_ULTIMATE_GROUP_ID_CHANGED callbacks
]]--
function TGT_SettingsHandler.SetSwimlanesSettings(swimlanes)
    TGT_SettingsHandler.SavedVariables.Swimlanes = swimlanes
    FireCallbacksAsync(TGT_SWIMLANES_CHANGED)
end

--[[
	Sets IsSortingActive settings
]]--
function TGT_SettingsHandler.SetIsSortingActiveSettings(isSortingActive)
    TGT_SettingsHandler.SavedVariables.IsSortingActive = isSortingActive
end

--[[
	Gets SimpleList visible in connection with selected style
]]--
function TGT_SettingsHandler.IsSimpleListVisible()
    return tonumber(TGT_SettingsHandler.SavedVariables.Style[GROUP_ULTIMATE]) == 1 and TGT_SettingsHandler.IsControlsVisible()
end

--[[
	Gets SwimlaneList visible in connection with selected style
]]--
function TGT_SettingsHandler.IsSwimlaneListVisible()
    return tonumber(TGT_SettingsHandler.SavedVariables.Style[GROUP_ULTIMATE]) == 2 and TGT_SettingsHandler.IsControlsVisible()
end

--[[
	Gets CompactSwimlaneList visible in connection with selected style
]]--
function TGT_SettingsHandler.IsCompactSwimlaneListVisible()
    return tonumber(TGT_SettingsHandler.SavedVariables.Style[GROUP_ULTIMATE]) == 3 and TGT_SettingsHandler.IsControlsVisible()
end

--[[
	Gets CompactSwimlaneList visible in connection with selected style
]]--
function TGT_SettingsHandler.IsControlsVisible()
    if (TGT_SettingsHandler.SavedVariables ~= nil) then
        if (TGT_SettingsHandler.SavedVariables.IsGroupUltimateEnabled and TGT_SettingsHandler.SavedVariables.IsSendingDataActive) then
            if (TGT_SettingsHandler.SavedVariables.OnlyAva[GROUP_ULTIMATE]) then
                return IsPlayerInAvAWorld() or IsActiveWorldBattleground()
            else
                return true
            end
        else
            return false
        end
    else
        return false
    end
end

--[[
	Sets IsLeaderIconActive settings and fires TGT_ICON_CHANGED callbacks
]]--
function TGT_SettingsHandler.SetIsLeaderIconActiveSettings(iconActive)
    TGT_SettingsHandler.SavedVariables.IsLeaderIconActive = iconActive
    FireCallbacksAsync(TGT_LEADER_ICON_ACTIVE_CHANGED)
end

--[[
	Sets SetIconSettings settings and fires TGT_LEADER_ICON_PROPERTIES_CHANGED callbacks
]]--
function TGT_SettingsHandler.SetIconSettings(iconIndex)
    local latestIndex = #TGT_SettingsHandler.Icons

    if (iconIndex >= 1 and iconIndex <= latestIndex) then
        TGT_SettingsHandler.SavedVariables.Icon = iconIndex
        FireCallbacksAsync(TGT_LEADER_ICON_PROPERTIES_CHANGED)
    end
end

--[[
	Sets SetIconSizeSettings settings and fires TGT_LEADER_ICON_PROPERTIES_CHANGED callbacks
]]--
function TGT_SettingsHandler.SetIconSizeSettings(iconSize)
    TGT_SettingsHandler.SavedVariables.IconSize = iconSize
    FireCallbacksAsync(TGT_LEADER_ICON_PROPERTIES_CHANGED)
end

--[[
	Sets IsLeaderArrowActive settings and fires TGT_ARROW_ACTIVE_CHANGED callbacks
]]--
function TGT_SettingsHandler.SetIsLeaderArrowActiveSettings(arrowActive)
    TGT_SettingsHandler.SavedVariables.IsLeaderArrowActive = arrowActive
    FireCallbacksAsync(TGT_ARROW_ACTIVE_CHANGED)
end

--[[
	Sets IsCustomizedCompassActive settings and fires TGT_COMPASS_ACTIVE_CHANGED callbacks
]]--
function TGT_SettingsHandler.SetIsCustomizedCompassActiveSettings(active)
    TGT_SettingsHandler.SavedVariables.IsCustomizedCompassActive = active
    FireCallbacksAsync(TGT_COMPASS_ACTIVE_CHANGED)
end

--[[
	Sets HideStandardCompass settings and fires TGT_COMPASS_ZOS_COMPASS_CHANGED callbacks
]]--
function TGT_SettingsHandler.SetHideStandardCompassSettings(active)
    TGT_SettingsHandler.SavedVariables.HideStandardCompass = active
    FireCallbacksAsync(TGT_COMPASS_ZOS_COMPASS_CHANGED)
end

--[[
	Sets CompassRadius settings and fires TGT_COMPASS_RADIUS_CHANGED callbacks
]]--
function TGT_SettingsHandler.SetCompassRadiusSettings(radius)
    TGT_SettingsHandler.SavedVariables.CompassRadius = radius
    FireCallbacksAsync(TGT_COMPASS_RADIUS_CHANGED)
end

--[[
	Sets CompassFont settings and fires TGT_COMPASS_FONT_CHANGED callbacks
]]--
function TGT_SettingsHandler.SetCompassFontSettings(index)
    local latestIndex = #TGT_SettingsHandler.CompassFonts

    if (index >= 1 and index <= latestIndex) then
        TGT_SettingsHandler.SavedVariables.CompassFont = index
        FireCallbacksAsync(TGT_COMPASS_FONT_CHANGED)
    end
end

--[[
	Sets CompassFontSize settings and fires TGT_COMPASS_FONT_CHANGED callbacks
]]--
function TGT_SettingsHandler.SetCompassFontSizeSettings(value)
    TGT_SettingsHandler.SavedVariables.CompassFontSize = value
    FireCallbacksAsync(TGT_COMPASS_FONT_CHANGED)
end

--[[
	Sets CompassFontSize settings and fires TGT_COMPASS_FLAT_CHANGED callbacks
]]--
function TGT_SettingsHandler.SetCompassFlatCompassSettings(value)
    TGT_SettingsHandler.SavedVariables.FlatCompass = value
    FireCallbacksAsync(TGT_COMPASS_FLAT_CHANGED)
end

--[[
	Sets CircleDistance settings
]]--
function TGT_SettingsHandler.SetCircleDistanceSettings(value)
    TGT_SettingsHandler.SavedVariables.CircleDistance = value
end

--[[
	Sets LeaderArrowDistance settings
]]--
function TGT_SettingsHandler.SetLeaderArrowDistanceSettings(value)
    TGT_SettingsHandler.SavedVariables.LeaderArrowDistance = value
end

--[[
	Sets MinDistance settings
]]--
function TGT_SettingsHandler.SetMinDistanceSettings(value)
    TGT_SettingsHandler.SavedVariables.MinDistance = value
end

--[[
	Sets MaxDistance settings
]]--
function TGT_SettingsHandler.SetMaxDistanceSettings(value)
    TGT_SettingsHandler.SavedVariables.MaxDistance = value
end

--[[
	Sets InviteString settings
]]--
function TGT_SettingsHandler.SetInviteString(inviteString)
    TGT_SettingsHandler.SavedVariables.InviteString = inviteString

    if (inviteString ~= nil and inviteString ~= "") then
        TGT_InviteHandler.SetInviteString(inviteString)
    else
        d(GetString(TGT_UI_AUTOINVITE_TEXT_ERROR))
    end
end

--[[
	Sets MaxGroupSize settings
]]--
function TGT_SettingsHandler.SetMaxGroupSizeSettings(maxGroupSize)
    TGT_SettingsHandler.SavedVariables.MaxGroupSize = maxGroupSize
end

--[[
	Sets AutoKick settings
]]--
function TGT_SettingsHandler.SetAutoKick(autoKick)
    TGT_SettingsHandler.SavedVariables.AutoKick = autoKick

    if (autoKick) then
        TGT_InviteHandler.StartAutoKick()
    else
        TGT_InviteHandler.StopAutoKick()
    end
end

--[[
	Sets AutoKickTimeout settings
]]--
function TGT_SettingsHandler.SetAutoKickTimeoutSettings(timeout)
    TGT_SettingsHandler.SavedVariables.AutoKickTimeout = timeout
end

--[[
	IsSimpleDpsHpsListVisible Gets visible in connection with selected style
]]--
function TGT_SettingsHandler.IsSimpleDpsHpsListVisible()
    if (TGT_SettingsHandler.SavedVariables ~= nil) then
        return tonumber(TGT_SettingsHandler.SavedVariables.Style[GROUP_STATS]) == 1 and TGT_SettingsHandler.IsDpsHpsControlsVisible()
    else
        return false
    end
end

--[[
	IsBarListVisible Gets visible in connection with selected style
]]--
function TGT_SettingsHandler.IsBarListVisible()
    if (TGT_SettingsHandler.SavedVariables ~= nil) then
        return tonumber(TGT_SettingsHandler.SavedVariables.Style[GROUP_STATS]) == 2 and TGT_SettingsHandler.IsDpsHpsControlsVisible()
    else
        return false
    end
end

--[[
	Gets IsDpsHpsControlsVisible visible in connection with only ava / enabled / disabled
]]--
function TGT_SettingsHandler.IsDpsHpsControlsVisible()
    if (TGT_SettingsHandler.SavedVariables ~= nil) then
        if (TGT_SettingsHandler.SavedVariables.IsGroupHpsDpsEnabled and TGT_SettingsHandler.SavedVariables.IsSendingDataActive) then
            if (TGT_SettingsHandler.SavedVariables.OnlyAva[GROUP_STATS]) then
                return IsPlayerInAvAWorld() or IsActiveWorldBattleground()
            else
                return true
            end
        else
            return false
        end
    else
        return false
    end
end

--[[
	Sets DpsHpsVisibleOption and fires TGT_GROUP_DPSHPS_PART_CHANGED callbacks
]]--
function TGT_SettingsHandler.SetDpsHpsVisibleOptionSettings(style)
    local numberStyle = tonumber(style)

    if (numberStyle == 1 or numberStyle == 2 or numberStyle == 3) then
        TGT_SettingsHandler.SavedVariables.DpsHpsVisibleOption = numberStyle

        FireCallbacksAsync(TGT_GROUP_DPSHPS_PART_CHANGED)
    end
end

--[[
	Sets TrackedBuff1AbilityId and fires TGT_GROUP_BUFFS_ABILITY_IDS_CHANGED callbacks
]]--
function TGT_SettingsHandler.SetTrackedBuff1AbilityIdSettings(part, abilityId)
    TGT_SettingsHandler.SavedVariables.TrackedBuffs[part].TrackedBuff1AbilityId = abilityId
    FireCallbacksAsync(TGT_GROUP_BUFFS_ABILITY_IDS_CHANGED)
end

--[[
	Sets TrackedBuff2AbilityId and fires TGT_GROUP_BUFFS_ABILITY_IDS_CHANGED callbacks
]]--
function TGT_SettingsHandler.SetTrackedBuff2AbilityIdSettings(part, abilityId)
    TGT_SettingsHandler.SavedVariables.TrackedBuffs[part].TrackedBuff2AbilityId = abilityId
    FireCallbacksAsync(TGT_GROUP_BUFFS_ABILITY_IDS_CHANGED)
end

--[[
	Sets TrackedBuff3AbilityId and fires TGT_GROUP_BUFFS_ABILITY_IDS_CHANGED callbacks
]]--
function TGT_SettingsHandler.SetTrackedBuff3AbilityIdSettings(part, abilityId)
    TGT_SettingsHandler.SavedVariables.TrackedBuffs[part].TrackedBuff3AbilityId = abilityId
    FireCallbacksAsync(TGT_GROUP_BUFFS_ABILITY_IDS_CHANGED)
end

--[[
	Sets TrackedBuff4AbilityId and fires TGT_GROUP_BUFFS_ABILITY_IDS_CHANGED callbacks
]]--
function TGT_SettingsHandler.SetTrackedBuff4AbilityIdSettings(part, abilityId)
    TGT_SettingsHandler.SavedVariables.TrackedBuffs[part].TrackedBuff4AbilityId = abilityId
    FireCallbacksAsync(TGT_GROUP_BUFFS_ABILITY_IDS_CHANGED)
end

--[[
	Fires TGT_GROUP_FRAMES_SETTINGS_CHANGED callbacks
]]--
function TGT_SettingsHandler.OnGroupFramesSettingsChanged()
    FireCallbacksAsync(TGT_GROUP_FRAMES_SETTINGS_CHANGED)
end

--[[
	Fires TGT_COLOR_SETTINGS_CHANGED callbacks
]]--
function TGT_SettingsHandler.OnColorSettingsChanged(part)
    FireCallbacksAsync(TGT_COLOR_SETTINGS_CHANGED, part)
end

--[[
	Sets SoundOnReady settings
]]--
function TGT_SettingsHandler.SetSoundOnReadySettings(index, sound)
    TGT_SettingsHandler.SavedVariables.SoundOnReady = { index, sound }
end

--[[
	Sets SetSoundOnThrown Settings
]]--
function TGT_SettingsHandler.SetSoundOnThrownSettings(index, sound)
    TGT_SettingsHandler.SavedVariables.SoundOnThrown = { index, sound }
end

--[[
	Sets SubGroup Name settings and fires TGT_SUB_GROUP_NAME_CHANGED callbacks
]]--
function TGT_SettingsHandler.SetSubGroupName(subGroup, name)
    TGT_SettingsHandler.SavedVariables.GroupFrameGroups[subGroup].Name = name
    FireCallbacksAsync(TGT_SUB_GROUP_NAME_CHANGED, subGroup, name)
end

--[[
	Sets IsGroupDetoHeaderVisible settings and fires TGT_GROUP_DETO_HEADER_CHANGED callbacks
]]--
function TGT_SettingsHandler.SetIsGroupDetoHeaderVisible(value)
    TGT_SettingsHandler.SavedVariables.IsGroupDetoHeaderVisible = value
    FireCallbacksAsync(TGT_GROUP_DETO_HEADER_CHANGED)
end

--[[
	Sets GroupDetoSize settings and fires TGT_GROUP_DETO_SIZE_CHANGED callbacks
]]--
function TGT_SettingsHandler.SetGroupDetoSize(width, height)
    TGT_SettingsHandler.SavedVariables.GroupDetoSize = { ["Width"] = width, ["Height"] = height }
    FireCallbacksAsync(TGT_GROUP_DETO_SIZE_CHANGED)
end

--[[
	Sets IsGroupPurgeHeaderVisible settings and fires TGT_GROUP_PURGE_HEADER_CHANGED callbacks
]]--
function TGT_SettingsHandler.SetIsGroupPurgeHeaderVisible(value)
    TGT_SettingsHandler.SavedVariables.IsGroupPurgeHeaderVisible = value
    FireCallbacksAsync(TGT_GROUP_PURGE_HEADER_CHANGED)
end

--[[
	Sets GroupPurgeSize settings and fires TGT_GROUP_PURGE_SIZE_CHANGED callbacks
]]--
function TGT_SettingsHandler.SetGroupPurgeSize(width, height)
    TGT_SettingsHandler.SavedVariables.GroupPurgeSize = { ["Width"] = width, ["Height"] = height }
    FireCallbacksAsync(TGT_GROUP_PURGE_SIZE_CHANGED)
end

--[[
	Sets IsGroupSpeedHeaderVisible settings and fires TGT_GROUP_SPEED_HEADER_CHANGED callbacks
]]--
function TGT_SettingsHandler.SetIsGroupSpeedHeaderVisible(value)
    TGT_SettingsHandler.SavedVariables.IsGroupSpeedHeaderVisible = value
    FireCallbacksAsync(TGT_GROUP_SPEED_HEADER_CHANGED)
end

--[[
	Sets GroupSpeedSize settings and fires TGT_GROUP_SPEED_SIZE_CHANGED callbacks
]]--
function TGT_SettingsHandler.SetGroupSpeedSize(width, height)
    TGT_SettingsHandler.SavedVariables.GroupSpeedSize = { ["Width"] = width, ["Height"] = height }
    FireCallbacksAsync(TGT_GROUP_SPEED_SIZE_CHANGED)
end

--[[
	Sets IsGroupEarthgoreHeaderVisible settings and fires TGT_GROUP_EARTHGORE_HEADER_CHANGED callbacks
]]--
function TGT_SettingsHandler.SetIsGroupEarthgoreHeaderVisible(value)
    TGT_SettingsHandler.SavedVariables.IsGroupEarthgoreHeaderVisible = value
    FireCallbacksAsync(TGT_GROUP_EARTHGORE_HEADER_CHANGED)
end

--[[
	Sets GroupEarthgoreSize settings and fires TGT_GROUP_EARTHGORE_SIZE_CHANGED callbacks
]]--
function TGT_SettingsHandler.SetGroupEarthgoreSize(width, height)
    TGT_SettingsHandler.SavedVariables.GroupEarthgoreSize = { ["Width"] = width, ["Height"] = height }
    FireCallbacksAsync(TGT_GROUP_EARTHGORE_SIZE_CHANGED)
end

--[[
	Sets IsSendingDataActive and fires TGT_SENDING_CHANGED callbacks
]]--
function TGT_SettingsHandler.SetSendingDataSettings(isEnabled)
    TGT_SettingsHandler.SavedVariables.IsSendingDataActive = isEnabled
    FireCallbacksAsync(TGT_SENDING_CHANGED)
end

--[[
	Sets IsGroupUltimateEnabled settings and fires TGT_GROUP_ULTIMATE_ENABLED_CHANGED callbacks
]]--
function TGT_SettingsHandler.SetIsGroupUltimateEnabledSettings(isEnabled)
    TGT_SettingsHandler.SavedVariables.IsGroupUltimateEnabled = isEnabled
    FireCallbacksAsync(TGT_GROUP_ULTIMATE_ENABLED_CHANGED)
end

--[[
	Sets IsGroupInviteEnabled settings
]]--
function TGT_SettingsHandler.SetIsGroupInviteEnabledSettings(isEnabled)
    TGT_SettingsHandler.SavedVariables.IsGroupInviteEnabled = isEnabled
    FireCallbacksAsync(TGT_GROUP_INVITE_ENABLED_CHANGED)
end

--[[
	Sets IsGroupInviteEnabled settings and fires TGT_GROUP_DPSHPS_ENABLED_CHANGED callbacks
]]--
function TGT_SettingsHandler.SetIsGroupHpsDpsEnabledSettings(isEnabled)
    TGT_SettingsHandler.SavedVariables.IsGroupHpsDpsEnabled = isEnabled
    FireCallbacksAsync(TGT_GROUP_DPSHPS_ENABLED_CHANGED)
end

--[[
	Sets IsGroupResourcesEnabled settings and fires TGT_GROUP_RESOURCES_ENABLED_CHANGED callbacks
]]--
function TGT_SettingsHandler.SetIsGroupResourcesEnabledSettings(isEnabled)
    TGT_SettingsHandler.SavedVariables.IsGroupResourcesEnabled = isEnabled
    FireCallbacksAsync(TGT_GROUP_RESOURCES_ENABLED_CHANGED)
end

--[[
	Sets IsGroupBuffsEnabled settings and fires TGT_GROUP_BUFFS_ENABLED_CHANGED callbacks
]]--
function TGT_SettingsHandler.SetIsGroupBuffsEnabledSettings(isEnabled)
    TGT_SettingsHandler.SavedVariables.IsGroupBuffsEnabled = isEnabled
    FireCallbacksAsync(TGT_GROUP_BUFFS_ENABLED_CHANGED)
end

--[[
	Sets IsGroupFramesEnabled settings and fires TGT_GROUP_FRAMES_ENABLED_CHANGED callbacks
]]--
function TGT_SettingsHandler.SetIsGroupFramesEnabledSettings(isEnabled)
    TGT_SettingsHandler.SavedVariables.IsGroupFramesEnabled = isEnabled
    FireCallbacksAsync(TGT_GROUP_FRAMES_ENABLED_CHANGED, isEnabled)
end

--[[
	Sets IsGroupDetoEnabled settings and fires TGT_GROUP_DETO_ENABLED_CHANGED callbacks
]]--
function TGT_SettingsHandler.SetIsGroupDetoEnabledSettings(isEnabled)
    TGT_SettingsHandler.SavedVariables.IsGroupDetoEnabled = isEnabled
    FireCallbacksAsync(TGT_GROUP_DETO_ENABLED_CHANGED, isEnabled)
end

--[[
	Sets IsGroupSpeedEnabled settings and fires TGT_GROUP_SPEED_ENABLED_CHANGED callbacks
]]--
function TGT_SettingsHandler.SetIsGroupSpeedEnabledSettings(isEnabled)
    TGT_SettingsHandler.SavedVariables.IsGroupSpeedEnabled = isEnabled
    FireCallbacksAsync(TGT_GROUP_SPEED_ENABLED_CHANGED, isEnabled)
end

--[[
	Sets IsGroupPurgeEnabled settings and fires TGT_GROUP_PURGE_ENABLED_CHANGED callbacks
]]--
function TGT_SettingsHandler.SetIsGroupPurgeEnabledSettings(isEnabled)
    TGT_SettingsHandler.SavedVariables.IsGroupPurgeEnabled = isEnabled
    FireCallbacksAsync(TGT_GROUP_PURGE_ENABLED_CHANGED, isEnabled)
end

--[[
	Sets IsGroupEarthgoreEnabled settings and fires TGT_GROUP_EARTHGORE_ENABLED_CHANGED callbacks
]]--
function TGT_SettingsHandler.SetIsGroupEarthgoreEnabledSettings(isEnabled)
    TGT_SettingsHandler.SavedVariables.IsGroupEarthgoreEnabled = isEnabled
    FireCallbacksAsync(TGT_GROUP_EARTHGORE_ENABLED_CHANGED, isEnabled)
end

--[[
	Initialize loads SavedVariables
]]--
function TGT_SettingsHandler.Initialize()
    _logger = TGT_LOGGER

    TGT_SettingsHandler.SavedVariables = ZO_SavedVars:NewAccountWide(_settingsName, SETTINGS_VERSION, nil, TGT_DEFAULTS)
    
    _logger:logTrace("TGT_SettingsHandler -> Initialized")
end