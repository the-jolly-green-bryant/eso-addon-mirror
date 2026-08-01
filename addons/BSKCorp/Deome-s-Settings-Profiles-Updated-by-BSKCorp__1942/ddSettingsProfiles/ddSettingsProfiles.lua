--------------------------------------------------------------------------------------------------
--------------------------------   BSKCorp's Settings Profiles (Deome's updated')   ------------------
local									VERSION = "1.11"										--
--		
--      Updated to work with Dragonbones DLC. 2018 BSKCorp																						--
--		Added additional settings and updated with Morrowind Patch								--
--		2017 T. Miller (@trymi) - godkills@gmail.com											--
--		https://github.com/TroyMiller/ElderScrollsPlugins/tree/master/ddSettingsProfiles        --
--		Deome did the hardwork, I just added the fields to the framework						--

--------------------------------   Deome's Settings Profiles   -----------------------------------
---------------------------------------   Deome's License   --------------------------------------
--																								--
-- 		Copyright (c) 2015 D. Deome (@deome) - heydeome@gmail.com								--
--																								--
-- 		This software is provided 'as-is', without any express or implied						--
-- 		warranty. In no event will the authors be held liable for any damages					--
-- 		arising from the use of this software.													--
--																								--
-- 		Permission is granted to anyone to use this software for any purpose,					--
-- 		including commercial applications, and to alter it and redistribute it					--
-- 		freely, subject to the following restrictions:											--
--																								--
-- 			1. The origin of this software must not be misrepresented; you must not				--
-- 			claim that you wrote the original software. If you use this software				--
-- 			or any substantial part in a product, an acknowledgment in the product 				--
-- 			documentation is required.															--
--																								--
-- 			2. Altered source versions must be plainly marked as such, and must not be			--
-- 			misrepresented as being the original software.										--
--																								--
-- 			3. This notice may not be removed or altered from any source distribution.			--
--																								--
-------------------------------------   ZO Obligatory Spam   -------------------------------------
--																								--
-- 		"This Add-on is not created by, affiliated with or sponsored by ZeniMax 		  		--
--		Media Inc. or its affiliates. The Elder Scrolls® and related logos are registered 	 	--
--		trademarks of ZeniMax Media Inc. in the United States and/or other countries. 			--
--		All rights reserved."																	--
--																								--
--------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------


--------------------------------------------------------------------------------------------------
----------------------------------------   Libraries   -------------------------------------------
--------------------------------------------------------------------------------------------------

local LIB_LAM2 = LibStub("LibAddonMenu-2.0")


--------------------------------------------------------------------------------------------------
----------------------------------------   Namespace   -------------------------------------------
--------------------------------------------------------------------------------------------------

ddSettingsProfiles = {
	["Name"] 					= "ddSettingsProfiles",
	["Version"] 				= VERSION,
	["SavedVarsVersion"] 		= 1,
	["Locale"] 					= GetCVar('Language.2') or "en",
	["Profiles"]				= {},
	["Options"] = {
		["Init"] 				= function() end,
		["SaveProfile"]			= {},
		["LoadProfile"]			= {},
		["Notify"]				= {},
		["Debug"]				= {},
	},
	["SaveProfile"] 			= function() end,
	["LoadProfile"] 			= function() end,
	["GetProfileIndex"]			= function() end,
	["DisplayMsg"] 				= function() end,
	["Init"] 					= function() end,
	["OnAddonLoaded"]			= function() end,
	["mControls"] 				= function() end,
	["mPanel"] 					= function() end,
}


--------------------------------------------------------------------------------------------------
----------------------------------------   Constants   -------------------------------------------
--------------------------------------------------------------------------------------------------

local ADDON_NAME 	= ddSettingsProfiles.Name
local SV_VERSION	= ddSettingsProfiles.SavedVarsVersion
local LOCALE		= ddSettingsProfiles.Locale
local Options		= ddSettingsProfiles.Options
local LAME_PANEL	= nil
 
--------------------------------------------------------------------------------------------------
-------------------------------   Modular Controls by @Deome   -----------------------------------
--																								--
--						 ----  For LibAddonMenu 2.0 by Seerah  ----								--
--				----   With gratitude and credit for this wonderful library   ----				--
--																								--
--------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------
--			    -- Modular Controls allow even more customization for LAM2 --					--
--					        -- (which already offers so much!) --								--
--		  -- and make plugins, updates, and common settings simple for everyone --				--
--------------------------------------------------------------------------------------------------


--------------------------------------------------------------------------------------------------
------------------------------------   LAM2 Panel Layout   ---------------------------------------
--------------------------------------------------------------------------------------------------

function ddSettingsProfiles:mControls()
	local controls = {
		self.Options.SaveProfile:Init(),
		self.Options.LoadProfile:Init(),
--		self.Options.Notify:Init(),
--		self.Options.Debug:Init(),
	}
	return controls
end

function ddSettingsProfiles:mPanel()
	local panel = {
		type = "panel",
		name = GetString(DDSP_LAM2_NAME),
		displayName = GetString(DDSP_LAM2_NAME),
		author = GetString(DDSP_LAM2_AUTHOR),
		version = self.Version,
		registerForRefresh = true,
		registerForDefaults = true,
	}
	return panel
end


--------------------------------------------------------------------------------------------------	
----------------------------------   LAM2 Modular Controls   -------------------------------------	
--------------------------------------------------------------------------------------------------	

function ddSettingsProfiles.Options:Init()
	self.LoadProfile:Init()
	self.SaveProfile:Init()
	self.Notify:Init()
	self.Debug:Init()
end

function ddSettingsProfiles.Options.SaveProfile:Init()
	self.type = "editbox"
	self.name = GetString(DDSP_LAM2_SAVE_PROFILE_NAME)
	self.tooltip = GetString(DDSP_LAM2_SAVE_PROFILE_TIP)
	self.isMultiline = false
	self.width = "full"
	
	self.default = ""
	self.getFunc = function() return self.value or self.default end
	self.setFunc = function(value) if value ~= "" or "None" then self.value = value; ddSettingsProfiles:SaveProfile(value) end end
	
	return self
end

function ddSettingsProfiles.Options.LoadProfile:Init()
	self.type = "dropdown"
	self.name = GetString(DDSP_LAM2_LOAD_PROFILE_NAME)
	self.tooltip = GetString(DDSP_LAM2_LOAD_PROFILE_TIP)
	self.width = "full"
	
	self.choices = ddSettingsProfiles.profileIndex
	self.default = "None"
	self.getFunc = function() return self.value or self.default end
	self.setFunc = function(value) if value ~= "None" then self.value = value; ddSettingsProfiles:LoadProfile(value) end end
	return self
end

function ddSettingsProfiles.Options.Notify:Init()
	self.type = "checkbox"
	self.name = GetString(DDSP_LAM2_NOTIFY_NAME)
	self.tooltip = GetString(DDSP_LAM2_NOTIFY_TIP)
	self.width = "full"
	
	self.default = true
	self.getFunc = function() return self.value or self.default end
	self.setFunc = function(value) self.value = value end
	return self
end

function ddSettingsProfiles.Options.Debug:Init()
	self.type = "checkbox"
	self.name = GetString(DDSP_LAM2_DEBUG_NAME)
	self.tooltip = GetString(DDSP_LAM2_DEBUG_TIP)
	self.width = "full"
	
	self.default = true
	self.getFunc = function() return self.value or self.default end
	self.setFunc = function(value) self.value = value end
	return self
end


--------------------------------------------------------------------------------------------------
----------------------------------------   Functions   -------------------------------------------
--------------------------------------------------------------------------------------------------

function ddSettingsProfiles:SetColorFromControl(colorControl, profileColorSetting)
	local optionControl = colorControl:GetParent()
	local data = optionControl.data
	local texture = colorControl:GetNamedChild("Texture") 
	local r, g, b = profileColorSetting[1], profileColorSetting[2], profileColorSetting[3]

	texture:SetColor(r, g, b, 1)
	data.currentRed, data.currentGreen, data.currentBlue = r, g, b
	CHAT_SYSTEM:SetChannelCategoryColor(data.chatChannelCategory, r, g, b)
	SetChatCategoryColor(data.chatChannelCategory, r, g, b)
end

function ddSettingsProfiles:SetCheckbox(control, profileValue)
	local checkboxControl = GetControl(control, "Checkbox")
	local boolValue = control.data.value
	
	if profileValue ~= boolValue then
		checkboxControl:GetHandler("OnClicked")(checkboxControl, button)
	end
end

function ddSettingsProfiles:SetDropdown(control, profileIndex)
	local dropdownControl 	= GetControl(control, "Dropdown")
	local sortedItems		= dropdownControl.m_comboBox.m_sortedItems
	
	sortedItems[profileIndex].callback()
end

function ddSettingsProfiles:SetSlider(control, profileValue)
	local sliderControl = GetControl(control, "Slider")
	
	sliderControl:SetValue(profileValue)
end

function ddSettingsProfiles:SaveProfile(profileName)
	self.Profiles[profileName] = {}
	KEYBOARD_OPTIONS:UpdateAllPanelOptions(1)

--Setting value to array index
	--Used for Options_Combat_ShowActionBar and Options_Combat_ShowResourceBars
	t = {3,2,1}
	
	--Used for Options_Nameplates_PlayerHBDimmed
	t1 = {[3]=1, [2]=2}

	--Used for Options_Nameplates_FriendlyNPCHBDimmed,Options_Nameplates_FriendlyPlayerHBDimmed,Options_Nameplates_NeutralNPCHBDimmed,Options_Nameplates_EnemyNPCHBDimmed,Options_Nameplates_EnemyPlayerHBDimmed
	t2 = {[8]=1, [3]=2, [9]=3, [2]=4,}
	
	--Used for Options_Nameplates_AllianceIndicators
	t3 = {[1]=1, [7]=2, [6]=3, [4]=4,}

	--Used for Options_Nameplates_xxxxx_HB
	t4 = {[1]=1, [8]=2, [3]=3, [9]=4, [2]=5,}


	local optionsSettings = {
--[[	
		["Options_Video_DisplayMode"] 					= Options_Video_DisplayMode.data.value,
		["Options_Video_Resolution"] 					= Options_Video_Resolution.data.value,
		["Options_Video_VSync"] 						= Options_Video_VSync.data.value,
		["Options_Video_Anti_Aliasing"] 				= Options_Video_Anti_Aliasing.data.value,
		["Options_Video_Gamma_Adjustment"] 				= Options_Video_Gamma_Adjustment.data.value,
		["Options_Video_CustomScale"] 					= Options_Video_CustomScale.data.value,
		["Options_Video_Graphics_Quality"] 				= Options_Video_Graphics_Quality.data.value,
		["Options_Video_Texture_Resolution"] 			= Options_Video_Texture_Resolution.data.value,
		["Options_Video_Sub_Sampling"] 					= Options_Video_Sub_Sampling.data.value,
		["Options_Video_Shadows"] 						= Options_Video_Shadows.data.value,
		["Options_Video_Reflection_Quality"] 			= Options_Video_Reflection_Quality.data.value,
		["Options_Video_Maximum_Particle_Systems"] 		= Options_Video_Maximum_Particle_Systems.data.value,
		["Options_Video_Particle_Suppression_Distance"] = Options_Video_Particle_Suppression_Distance.data.value,
		["Options_Video_View_Distance"] 				= Options_Video_View_Distance.data.value,
		["Options_Video_Ambient_Occlusion"] 			= Options_Video_Ambient_Occlusion.data.value,
		["Options_Video_Bloom"] 						= Options_Video_Bloom.data.value,
		["Options_Video_Depth_Of_Field"] 				= Options_Video_Depth_Of_Field.data.value,
		["Options_Video_Distortion"] 					= Options_Video_Distortion.data.value,
		["Options_Video_God_Rays"] 						= Options_Video_God_Rays.data.value,
		["Options_Video_Ability_Magelight"] 			= Options_Video_Ability_Magelight.data.value,
		["Options_Video_Clutter_2D"] 					= Options_Video_Clutter_2D.data.value,
		
		["Options_Audio_MasterVolume"] 					= Options_Audio_MasterVolume.data.value,
		["Options_Audio_MusicEnabled"] 					= Options_Audio_MusicEnabled.data.value,
		["Options_Audio_MusicVolume"] 					= Options_Audio_MusicVolume.data.value,
		["Options_Audio_SoundEnabled"] 					= Options_Audio_SoundEnabled.data.value,
		["Options_Audio_AmbientVolume"] 				= Options_Audio_AmbientVolume.data.value,
		["Options_Audio_SFXVolume"] 					= Options_Audio_SFXVolume.data.value,
		["Options_Audio_FootstepsVolume"] 				= Options_Audio_FootstepsVolume.data.value,
		["Options_Audio_VOVolume"] 						= Options_Audio_VOVolume.data.value,
		["Options_Audio_UISoundVolume"] 				= Options_Audio_UISoundVolume.data.value,
		["Options_Audio_OutputSection"] 				= Options_Audio_OutputSection.data.value,
		["Options_Audio_BackgroundAudio"] 				= Options_Audio_BackgroundAudio.data.value,
]]	

--Gather Gameplay Options
		["Options_Gameplay_MonsterTells"] 				= Options_Gameplay_MonsterTells.data.value,
		["Options_Gameplay_DodgeDoubleTap"] 			= Options_Gameplay_DodgeDoubleTap.data.value,
		["Options_Gameplay_RollDodgeTime"] 				= Options_Gameplay_RollDodgeTime.data.value,
		["Options_Gameplay_ClampGroundTarget"] 			= Options_Gameplay_ClampGroundTarget.data.value,
		["Options_Gameplay_PreventAttackingInnocents"] 	= Options_Gameplay_PreventAttackingInnocents.data.value,
		["Options_Gameplay_UseAoeLoot"] 				= Options_Gameplay_UseAoeLoot.data.value,
		["Options_Gameplay_UseAutoLoot"]				= Options_Gameplay_UseAutoLoot.data.value,
		["Options_Gameplay_UseAutoLoot_Stolen"] 		= Options_Gameplay_UseAutoLoot_Stolen.data.value,
		["Options_Gameplay_DefaultSoulGem"] 			= Options_Gameplay_DefaultSoulGem.data.currentChoice + 1,
		["Options_Gameplay_TutorialEnabled"] 			= Options_Gameplay_TutorialEnabled.data.value,		
		["Options_Gameplay_HideMountStaminaUpgrade"] 	= Options_Gameplay_HideMountStaminaUpgrade.data.value,
		["Options_Gameplay_HideMountSpeedUpgrade"] 		= Options_Gameplay_HideMountSpeedUpgrade.data.value,
		["Options_Gameplay_HideMountInventoryUpgrade"] 	= Options_Gameplay_HideMountInventoryUpgrade.data.value,
		["Options_Gameplay_FootInverseKinematics"]		= Options_Gameplay_FootInverseKinematics.data.value,
		["Options_Gameplay_MonsterTells"]				= Options_Gameplay_MonsterTells.data.value,
		["Options_Gameplay_QuickCastGroundAbilities"]	= Options_Gameplay_QuickCastGroundAbilities.data.value,
		["Options_Gamepad_Preferred"]					= Options_Gamepad_Preferred.data.value,
		["Options_Gameplay_AutoAddToCraftBag"]			= Options_Gameplay_AutoAddToCraftBag.data.value,
		["Options_Gameplay_ToggleLootHistory"]			= Options_Gameplay_ToggleLootHistory.data.value,

--Gather Interface Options
		["Options_Interface_PrimaryPlayerNameKeyboard"] = Options_Interface_PrimaryPlayerNameKeyboard.data.currentChoice + 1,
		["Options_Interface_ShowRaidLives"] 			= Options_Interface_ShowRaidLives.data.currentChoice + 1,
		["UI_Settings_ShowQuestTracker"] 				= UI_Settings_ShowQuestTracker.data.value,
		["Options_Interface_CompassQuestGivers"] 		= Options_Interface_CompassQuestGivers.data.value,
		["Options_Interface_CompassActiveQuests"] 		= Options_Interface_CompassActiveQuests.data.currentChoice + 1,
		["Options_Interface_ShowWeaponIndicator"] 		= Options_Interface_ShowWeaponIndicator.data.value,
		["Options_Interface_ShowArmorIndicator"] 		= Options_Interface_ShowArmorIndicator.data.value,
		["Options_Interface_ChatBubblesEnabled"] 		= Options_Interface_ChatBubblesEnabled.data.value,
		["Options_Interface_ChatBubblesSpeed"] 			= Options_Interface_ChatBubblesSpeed.data.value,
		["Options_Interface_ChatBubblesEnabledRestrictToContacts"] = Options_Interface_ChatBubblesEnabledRestrictToContacts.data.value,
		["Options_Interface_ChatBubblesEnabledForLocalPlayer"] = Options_Interface_ChatBubblesEnabledForLocalPlayer.data.value,
		["Options_Interface_ChatBubblesSayChannel"] 	= Options_Interface_ChatBubblesSayChannel.data.value,
		["Options_Interface_ChatBubblesYellChannel"] 	= Options_Interface_ChatBubblesYellChannel.data.value,
		["Options_Interface_ChatBubblesWhisperChannel"] = Options_Interface_ChatBubblesWhisperChannel.data.value,
		["Options_Interface_ChatBubblesGroupChannel"] 	= Options_Interface_ChatBubblesGroupChannel.data.value,
		["Options_Interface_ChatBubblesEmoteChannel"] 	= Options_Interface_ChatBubblesEmoteChannel.data.value,
		["Options_Interface_FramerateCheck"] 			= Options_Interface_FramerateCheck.data.value,
		["Options_Interface_LatencyCheck"] 				= Options_Interface_LatencyCheck.data.value,
		["Options_Interface_FramerateLatencyLockCheck"] = Options_Interface_FramerateLatencyLockCheck.data.value,

--Gather Social Options	
		["Options_Social_TextSize"] 					= GetChatFontSize(),
		["Options_Social_MinAlpha"] 					= zo_round(CHAT_SYSTEM:GetMinAlpha() * 100),
		["Options_Social_UseProfanityFilter"] 			= Options_Social_UseProfanityFilter.data.value,
		["Options_Social_ReturnCursorOnChatFocus"] 		= Options_Social_ReturnCursorOnChatFocus.data.value,
		["Options_Social_LeaderboardsNotification"] 	= Options_Social_LeaderboardsNotification.data.value,
		["Options_Social_AutoDeclineDuelInvites"] 		= Options_Social_AutoDeclineDuelInvites.data.value,
		["Options_Social_ChatColor_Say"] 				= { CHAT_SYSTEM:GetCategoryColorFromChannel(CHAT_CHANNEL_SAY) },
		["Options_Social_ChatColor_Yell"] 				= { CHAT_SYSTEM:GetCategoryColorFromChannel(CHAT_CHANNEL_YELL) },
		["Options_Social_ChatColor_WhisperIncoming"] 	= { CHAT_SYSTEM:GetCategoryColorFromChannel(CHAT_CHANNEL_WHISPER) },
		["Options_Social_ChatColor_WhisperOutoing"] 	= { CHAT_SYSTEM:GetCategoryColorFromChannel(CHAT_CHANNEL_WHISPER_SENT) },
		["Options_Social_ChatColor_Group"] 				= { CHAT_SYSTEM:GetCategoryColorFromChannel(CHAT_CHANNEL_PARTY) },
		["Options_Social_ChatColor_Zone"] 				= { CHAT_SYSTEM:GetCategoryColorFromChannel(CHAT_CHANNEL_ZONE) },
		["Options_Social_ChatColor_Zone_English"] 		= { CHAT_SYSTEM:GetCategoryColorFromChannel(CHAT_CHANNEL_ZONE_LANGUAGE_1) },
		["Options_Social_ChatColor_Zone_French"] 		= { CHAT_SYSTEM:GetCategoryColorFromChannel(CHAT_CHANNEL_ZONE_LANGUAGE_2) },
		["Options_Social_ChatColor_Zone_German"] 		= { CHAT_SYSTEM:GetCategoryColorFromChannel(CHAT_CHANNEL_ZONE_LANGUAGE_3) },
		["Options_Social_ChatColor_NPC"] 				= { CHAT_SYSTEM:GetCategoryColorFromChannel(CHAT_CHANNEL_MONSTER_SAY) },
		["Options_Social_ChatColor_Emote"] 				= { CHAT_SYSTEM:GetCategoryColorFromChannel(CHAT_CHANNEL_EMOTE) },
		["Options_Social_ChatColor_System"] 			= { CHAT_SYSTEM:GetCategoryColorFromChannel(CHAT_CHANNEL_SYSTEM) },
		["Options_Social_ChatColor_Guild1"] 			= { CHAT_SYSTEM:GetCategoryColorFromChannel(CHAT_CHANNEL_GUILD_1) },
		["Options_Social_ChatColor_Officer1"] 			= { CHAT_SYSTEM:GetCategoryColorFromChannel(CHAT_CHANNEL_OFFICER_1) },
		["Options_Social_ChatColor_Guild2"] 			= { CHAT_SYSTEM:GetCategoryColorFromChannel(CHAT_CHANNEL_GUILD_2) },
		["Options_Social_ChatColor_Officer2"] 			= { CHAT_SYSTEM:GetCategoryColorFromChannel(CHAT_CHANNEL_OFFICER_2) },
		["Options_Social_ChatColor_Guild3"] 			= { CHAT_SYSTEM:GetCategoryColorFromChannel(CHAT_CHANNEL_GUILD_3) },
		["Options_Social_ChatColor_Officer3"] 			= { CHAT_SYSTEM:GetCategoryColorFromChannel(CHAT_CHANNEL_OFFICER_3) },
		["Options_Social_ChatColor_Guild4"] 			= { CHAT_SYSTEM:GetCategoryColorFromChannel(CHAT_CHANNEL_GUILD_4) },
		["Options_Social_ChatColor_Officer4"] 			= { CHAT_SYSTEM:GetCategoryColorFromChannel(CHAT_CHANNEL_OFFICER_4) },
		["Options_Social_ChatColor_Guild5"] 			= { CHAT_SYSTEM:GetCategoryColorFromChannel(CHAT_CHANNEL_GUILD_5) },
		["Options_Social_ChatColor_Officer5"] 			= { CHAT_SYSTEM:GetCategoryColorFromChannel(CHAT_CHANNEL_OFFICER_5) },
	
--Gather NamePlate Options
		["Options_Nameplates_AllNameplates"] 			= Options_Nameplates_AllNameplates.data.value,
		["Options_Nameplates_ShowPlayerTitles"] 		= Options_Nameplates_ShowPlayerTitles.data.value,
		["Options_Nameplates_ShowPlayerGuilds"] 		= Options_Nameplates_ShowPlayerGuilds.data.value,
		["Options_Nameplates_Player"] 					= Options_Nameplates_Player.data.value,
		["Options_Nameplates_PlayerDimmed"] 			= Options_Nameplates_PlayerDimmed.data.value,
		["Options_Nameplates_GroupMember"] 				= Options_Nameplates_GroupMember.data.value,
		["Options_Nameplates_GroupMemberDimmed"] 		= Options_Nameplates_GroupMemberDimmed.data.value,
		["Options_Nameplates_FriendlyNPC"] 				= Options_Nameplates_FriendlyNPC.data.value,
		["Options_Nameplates_FriendlyNPCDimmed"] 		= Options_Nameplates_FriendlyNPCDimmed.data.value,
		["Options_Nameplates_FriendlyPlayer"] 			= Options_Nameplates_FriendlyPlayer.data.value,
		["Options_Nameplates_FriendlyPlayerDimmed"]		= Options_Nameplates_FriendlyPlayerDimmed.data.value,
		["Options_Nameplates_NeutralNPC"] 				= Options_Nameplates_NeutralNPC.data.value,
		["Options_Nameplates_NeutralNPCDimmed"] 		= Options_Nameplates_NeutralNPCDimmed.data.value,
		["Options_Nameplates_EnemyNPC"] 				= Options_Nameplates_EnemyNPC.data.value,
		["Options_Nameplates_EnemyNPCDimmed"] 			= Options_Nameplates_EnemyNPCDimmed.data.value,
		["Options_Nameplates_EnemyPlayer"] 				= Options_Nameplates_EnemyPlayer.data.value,
		["Options_Nameplates_EnemyPlayerDimmed"] 		= Options_Nameplates_EnemyPlayerDimmed.data.value,
		["Options_Nameplates_AllHB"] 					= Options_Nameplates_AllHB.data.value,
		["Options_Nameplates_HealthbarChaseBar"] 		= Options_Nameplates_HealthbarChaseBar.data.value,
		["Options_Nameplates_HealthbarFrameBorder"] 	= Options_Nameplates_HealthbarFrameBorder.data.value,
		["Options_Nameplates_HealthbarAlignment"] 		= Options_Nameplates_HealthbarAlignment.data.currentChoice - 9,
		["Options_Nameplates_PlayerHB"] 				= t4[Options_Nameplates_PlayerHB.data.currentChoice],
		["Options_Nameplates_PlayerHBDimmed"] 			= t1[Options_Nameplates_PlayerHBDimmed.data.currentChoice],
		["Options_Nameplates_GroupMemberHB"] 			= t4[Options_Nameplates_GroupMemberHB.data.currentChoice],
		["Options_Nameplates_GroupMemberHBDimmed"]		= t2[Options_Nameplates_GroupMemberHBDimmed.data.currentChoice],
		["Options_Nameplates_FriendlyNPCHB"] 			= t4[Options_Nameplates_FriendlyNPCHB.data.currentChoice],
		["Options_Nameplates_FriendlyNPCHBDimmed"] 		= t2[Options_Nameplates_FriendlyNPCHBDimmed.data.currentChoice],
		["Options_Nameplates_FriendlyPlayerHB"] 		= t4[Options_Nameplates_FriendlyPlayerHB.data.currentChoice],
		["Options_Nameplates_FriendlyPlayerHBDimmed"] 	= t2[Options_Nameplates_FriendlyPlayerHBDimmed.data.currentChoice],
		["Options_Nameplates_NeutralNPCHB"] 			= t4[Options_Nameplates_NeutralNPCHB.data.currentChoice],
		["Options_Nameplates_NeutralNPCHBDimmed"] 		= t2[Options_Nameplates_NeutralNPCHBDimmed.data.currentChoice],
		["Options_Nameplates_EnemyNPCHB"] 				= t4[Options_Nameplates_EnemyNPCHB.data.currentChoice],
		["Options_Nameplates_EnemyNPCHBDimmed"] 		= t2[Options_Nameplates_EnemyNPCHBDimmed.data.currentChoice],
		["Options_Nameplates_EnemyPlayerHB"] 			= t4[Options_Nameplates_EnemyPlayerHB.data.currentChoice],
		["Options_Nameplates_EnemyPlayerHBDimmed"] 		= t2[Options_Nameplates_EnemyPlayerHBDimmed.data.currentChoice],
		["Options_Nameplates_AllianceIndicators"] 		= t3[Options_Nameplates_AllianceIndicators.data.currentChoice],
		["Options_Nameplates_GroupIndicators"] 			= Options_Nameplates_GroupIndicators.data.value,
		["Options_Nameplates_ResurrectIndicators"] 		= Options_Nameplates_ResurrectIndicators.data.value,
		["Options_Nameplates_FollowerIndicators"] 		= Options_Nameplates_FollowerIndicators.data.value,
		["Options_Nameplates_TargetGlowIntensity"] 		= Options_Nameplates_TargetGlowIntensity.data.value,
		["Options_Nameplates_GlowThickness"] 			= Options_Nameplates_GlowThickness.data.value,
		["Options_Nameplates_InteractableGlowIntensity"] = Options_Nameplates_InteractableGlowIntensity.data.value,



--Gather Combat Options

		["Options_Combat_ShowActionBar"] 				= t[Options_Combat_ShowActionBar.data.currentChoice],
		["Options_Combat_ShowResourceBars"] 			= t[Options_Combat_ShowResourceBars.data.currentChoice],
		["Options_Combat_ResourceNumbers"] 				= Options_Combat_ResourceNumbers.data.currentChoice + 1,
		["Options_Combat_ActiveCombatTips"] 			= Options_Combat_ActiveCombatTips.data.currentChoice + 1,
		["Options_Combat_UltimateNumber"] 				= Options_Combat_UltimateNumber.data.value,
		["Options_Combat_SCTEnabled"] 					= Options_Combat_SCTEnabled.data.value,
		["Options_Combat_SCTOutgoingEnabled"] 			= Options_Combat_SCTOutgoingEnabled.data.value,
		["Options_Combat_SCTOutgoingDamageEnabled"] 	= Options_Combat_SCTOutgoingDamageEnabled.data.value,
		["Options_Combat_SCTOutgoingDoTEnabled"] 		= Options_Combat_SCTOutgoingDoTEnabled.data.value,
		["Options_Combat_SCTOutgoingHealingEnabled"] 	= Options_Combat_SCTOutgoingHealingEnabled.data.value,
		["Options_Combat_SCTOutgoingHoTEnabled"] 		= Options_Combat_SCTOutgoingHoTEnabled.data.value,
		["Options_Combat_SCTOutgoingStatusEffectsEnabled"]	= Options_Combat_SCTOutgoingStatusEffectsEnabled.data.value,
		["Options_Combat_SCTOutgoingPetDamageEnabled"] 	= Options_Combat_SCTOutgoingPetDamageEnabled.data.value,
		["Options_Combat_SCTOutgoingPetDoTEnabled"] 	= Options_Combat_SCTOutgoingPetDoTEnabled.data.value,
		["Options_Combat_SCTOutgoingPetHealingEnabled"] = Options_Combat_SCTOutgoingPetHealingEnabled.data.value,
		["Options_Combat_SCTOutgoingPetHoTEnabled"] 	= Options_Combat_SCTOutgoingPetHoTEnabled.data.value,
		["Options_Combat_SCTIncomingEnabled"] 			= Options_Combat_SCTIncomingEnabled.data.value,
		["Options_Combat_SCTIncomingDamageEnabled"] 	= Options_Combat_SCTIncomingDamageEnabled.data.value,
		["Options_Combat_SCTIncomingDoTEnabled"] 		= Options_Combat_SCTIncomingDoTEnabled.data.value,
		["Options_Combat_SCTIncomingHealingEnabled"] 	= Options_Combat_SCTIncomingHealingEnabled.data.value,
		["Options_Combat_SCTIncomingHoTEnabled"] 		= Options_Combat_SCTIncomingHoTEnabled.data.value,
		["Options_Combat_SCTIncomingStatusEffectsEnabled"] 	= Options_Combat_SCTIncomingStatusEffectsEnabled.data.value,
		["Options_Combat_SCTIncomingPetDamageEnabled"] 	= Options_Combat_SCTIncomingPetDamageEnabled.data.value,
		["Options_Combat_SCTIncomingPetDoTEnabled"] 	= Options_Combat_SCTIncomingPetDoTEnabled.data.value,
		["Options_Combat_Buffs_AllEnabled"] 			= Options_Combat_Buffs_AllEnabled.data.currentChoice + 1,
		["Options_Combat_Buffs_SelfBuffs"] 				= Options_Combat_Buffs_SelfBuffs.data.value,
		["Options_Combat_Buffs_SelfDebuffs"] 			= Options_Combat_Buffs_SelfDebuffs.data.value,
		["Options_Combat_Buffs_TargetDebuffs"] 			= Options_Combat_Buffs_TargetDebuffs.data.value,
		["Option_Combat_Buffs_Debuffs_Enabled_For_Target_From_Others"] 	= Option_Combat_Buffs_Debuffs_Enabled_For_Target_From_Others.data.value,
		["Options_Combat_Buffs_LongEffects"] 			= Options_Combat_Buffs_LongEffects.data.value,
		["Options_Combat_Buffs_PermanentEffects"] 		= Options_Combat_Buffs_PermanentEffects.data.value,
	}




	self.Profiles[profileName] = optionsSettings
	self:DisplayMsg(zo_strformat(GetString(DDSP_PROFILE_SAVED), profileName), false)
end

function ddSettingsProfiles:LoadProfile(profileName)
	local profile = self.Profiles[profileName]
--[[
	self:SetDropdown(Options_Video_DisplayMode, profile.Options_Video_DisplayMode)
	self:SetDropdown(Options_Video_Resolution, profile.Options_Video_Resolution)
	self:SetCheckbox(Options_Video_VSync, profile.Options_Video_VSync)
	self:SetCheckbox(Options_Video_Anti_Aliasing, profile.Options_Video_Anti_Aliasing)
	self:SetSlider(Options_Video_Gamma_Adjustment, profile.Options_Video_Gamma_Adjustment)
	self:SetSlider(Options_Video_CustomScale, profile.Options_Video_CustomScale)
	self:SetDropdown(Options_Video_Graphics_Quality, profile.Options_Video_Graphics_Quality)
	self:SetDropdown(Options_Video_Texture_Resolution, profile.Options_Video_Texture_Resolution)
	self:SetDropdown(Options_Video_Sub_Sampling, profile.Options_Video_Sub_Sampling)
	self:SetDropdown(Options_Video_Shadows, profile.Options_Video_Shadows)
	self:SetDropdown(Options_Video_Reflection_Quality, profile.Options_Video_Reflection_Quality)
	self:SetSlider(Options_Video_Maximum_Particle_Systems, profile.Options_Video_Maximum_Particle_Systems)
	self:SetSlider(Options_Video_Particle_Suppression_Distance, profile.Options_Video_Particle_Suppression_Distance)
	self:SetSlider(Options_Video_View_Distance, profile.Options_Video_View_Distance)

	self:SetCheckbox(Options_Video_Ambient_Occlusion, profile.Options_Video_Ambient_Occlusion)
	self:SetCheckbox(Options_Video_Bloom, profile.Options_Video_Bloom)
	self:SetCheckbox(Options_Video_Depth_Of_Field, profile.Options_Video_Depth_Of_Field)
	self:SetCheckbox(Options_Video_Distortion, profile.Options_Video_Distortion)
	self:SetCheckbox(Options_Video_God_Rays, profile.Options_Video_God_Rays)
	self:SetCheckbox(Options_Video_Ability_Magelight, profile.Options_Video_Ability_Magelight)
	self:SetCheckbox(Options_Video_Clutter_2D, profile.Options_Video_Clutter_2D)

	self:SetSlider(Options_Audio_MasterVolume, profile.Options_Audio_MasterVolume)
	self:SetCheckbox(Options_Audio_MusicEnabled, profile.Options_Audio_MusicEnabled)
	self:SetSlider(Options_Audio_MusicVolume, profile.Options_Audio_MusicVolume)
	self:SetCheckbox(Options_Audio_SoundEnabled, profile.Options_Audio_SoundEnabled)
	self:SetSlider(Options_Audio_AmbientVolume, profile.Options_Audio_AmbientVolume)
	self:SetSlider(Options_Audio_SFXVolume, profile.Options_Audio_SFXVolume)
	self:SetSlider(Options_Audio_FootstepsVolume, profile.Options_Audio_FootstepsVolume)
	self:SetSlider(Options_Audio_VOVolume, profile.Options_Audio_VOVolume)
	self:SetSlider(Options_Audio_UISoundVolume, profile.Options_Audio_UISoundVolume)
	self:SetCheckbox(Options_Audio_BackgroundAudio, profile.Options_Audio_BackgroundAudio)
]]

--Load Gameplay
	self:SetCheckbox(Options_Gameplay_MonsterTells, profile.Options_Gameplay_MonsterTells)
	self:SetCheckbox(Options_Gameplay_DodgeDoubleTap, profile.Options_Gameplay_DodgeDoubleTap)
	self:SetSlider(Options_Gameplay_RollDodgeTime, profile.Options_Gameplay_RollDodgeTime)
	self:SetCheckbox(Options_Gameplay_ClampGroundTarget, profile.Options_Gameplay_ClampGroundTarget)
	self:SetCheckbox(Options_Gameplay_PreventAttackingInnocents, profile.Options_Gameplay_PreventAttackingInnocents)
	self:SetCheckbox(Options_Gameplay_UseAoeLoot, profile.Options_Gameplay_UseAoeLoot)
	self:SetCheckbox(Options_Gameplay_UseAutoLoot, profile.Options_Gameplay_UseAutoLoot)
	self:SetCheckbox(Options_Gameplay_UseAutoLoot_Stolen, profile.Options_Gameplay_UseAutoLoot_Stolen)
	self:SetDropdown(Options_Gameplay_DefaultSoulGem, profile.Options_Gameplay_DefaultSoulGem)
	self:SetCheckbox(Options_Gameplay_TutorialEnabled, profile.Options_Gameplay_TutorialEnabled)
	self:SetCheckbox(Options_Gameplay_HideMountStaminaUpgrade, profile.Options_Gameplay_HideMountStaminaUpgrade)
	self:SetCheckbox(Options_Gameplay_HideMountSpeedUpgrade, profile.Options_Gameplay_HideMountSpeedUpgrade)
	self:SetCheckbox(Options_Gameplay_HideMountInventoryUpgrade, profile.Options_Gameplay_HideMountInventoryUpgrade)
	self:SetCheckbox(Options_Gameplay_FootInverseKinematics, profile.Options_Gameplay_FootInverseKinematics)
	self:SetCheckbox(Options_Gameplay_MonsterTells, profile.Options_Gameplay_MonsterTells)
	self:SetCheckbox(Options_Gameplay_QuickCastGroundAbilities, profile.Options_Gameplay_QuickCastGroundAbilities)
	self:SetCheckbox(Options_Gamepad_Preferred, profile.Options_Gamepad_Preferred)
	self:SetCheckbox(Options_Gameplay_AutoAddToCraftBag, profile.Options_Gameplay_AutoAddToCraftBag)
	self:SetCheckbox(Options_Gameplay_ToggleLootHistory, profile.Options_Gameplay_ToggleLootHistory)

--Load Interface
	self:SetDropdown(Options_Interface_PrimaryPlayerNameKeyboard, profile.Options_Interface_PrimaryPlayerNameKeyboard)
	self:SetDropdown(Options_Interface_ShowRaidLives, profile.Options_Interface_ShowRaidLives)
	self:SetCheckbox(UI_Settings_ShowQuestTracker, profile.UI_Settings_ShowQuestTracker)
	self:SetCheckbox(Options_Interface_CompassQuestGivers, profile.Options_Interface_CompassQuestGivers)
	self:SetDropdown(Options_Interface_CompassActiveQuests, profile.Options_Interface_CompassActiveQuests)
 	self:SetCheckbox(Options_Interface_ShowWeaponIndicator, profile.Options_Interface_ShowWeaponIndicator)
	self:SetCheckbox(Options_Interface_ShowArmorIndicator, profile.Options_Interface_ShowArmorIndicator)
	self:SetCheckbox(Options_Interface_ChatBubblesEnabled, profile.Options_Interface_ChatBubblesEnabled)
	self:SetSlider(Options_Interface_ChatBubblesSpeed, profile.Options_Interface_ChatBubblesSpeed)
	self:SetCheckbox(Options_Interface_ChatBubblesEnabledRestrictToContacts, profile.Options_Interface_ChatBubblesEnabledRestrictToContacts)
	self:SetCheckbox(Options_Interface_ChatBubblesEnabledForLocalPlayer, profile.Options_Interface_ChatBubblesEnabledForLocalPlayer)
	self:SetCheckbox(Options_Interface_ChatBubblesSayChannel, profile.Options_Interface_ChatBubblesSayChannel)
	self:SetCheckbox(Options_Interface_ChatBubblesYellChannel, profile.Options_Interface_ChatBubblesYellChannel)
	self:SetCheckbox(Options_Interface_ChatBubblesWhisperChannel, profile.Options_Interface_ChatBubblesWhisperChannel)
	self:SetCheckbox(Options_Interface_ChatBubblesGroupChannel, profile.Options_Interface_ChatBubblesGroupChannel)
	self:SetCheckbox(Options_Interface_ChatBubblesEmoteChannel, profile.Options_Interface_ChatBubblesEmoteChannel)
	self:SetCheckbox(Options_Interface_FramerateCheck, profile.Options_Interface_FramerateCheck)
	self:SetCheckbox(Options_Interface_LatencyCheck, profile.Options_Interface_LatencyCheck)
	self:SetCheckbox(Options_Interface_FramerateLatencyLockCheck, profile.Options_Interface_FramerateLatencyLockCheck)

--Load Social
	self:SetSlider(Options_Social_TextSize, profile.Options_Social_TextSize)
	self:SetSlider(Options_Social_MinAlpha, profile.Options_Social_MinAlpha)
	self:SetCheckbox(Options_Social_UseProfanityFilter, profile.Options_Social_UseProfanityFilter)
	self:SetCheckbox(Options_Social_ReturnCursorOnChatFocus, profile.Options_Social_ReturnCursorOnChatFocus)
	self:SetCheckbox(Options_Social_LeaderboardsNotification, profile.Options_Social_LeaderboardsNotification)
	self:SetCheckbox(Options_Social_AutoDeclineDuelInvites, profile.Options_Social_AutoDeclineDuelInvites)
	self:SetColorFromControl(Options_Social_ChatColor_SayColor, profile.Options_Social_ChatColor_Say)
	self:SetColorFromControl(Options_Social_ChatColor_YellColor, profile.Options_Social_ChatColor_Yell)
	self:SetColorFromControl(Options_Social_ChatColor_WhisperIncomingColor, profile.Options_Social_ChatColor_WhisperIncoming)
	self:SetColorFromControl(Options_Social_ChatColor_WhisperOutoingColor, profile.Options_Social_ChatColor_WhisperOutoing)
	self:SetColorFromControl(Options_Social_ChatColor_GroupColor, profile.Options_Social_ChatColor_Group)
	self:SetColorFromControl(Options_Social_ChatColor_ZoneColor, profile.Options_Social_ChatColor_Zone)
	self:SetColorFromControl(Options_Social_ChatColor_Zone_EnglishColor, profile.Options_Social_ChatColor_Zone_English)
	self:SetColorFromControl(Options_Social_ChatColor_Zone_FrenchColor, profile.Options_Social_ChatColor_Zone_French)
	self:SetColorFromControl(Options_Social_ChatColor_Zone_GermanColor, profile.Options_Social_ChatColor_Zone_German)
	self:SetColorFromControl(Options_Social_ChatColor_NPCColor, profile.Options_Social_ChatColor_NPC)
	self:SetColorFromControl(Options_Social_ChatColor_EmoteColor, profile.Options_Social_ChatColor_Emote)
	self:SetColorFromControl(Options_Social_ChatColor_SystemColor, profile.Options_Social_ChatColor_System)
	self:SetColorFromControl(Options_Social_ChatColor_Guild1Color, profile.Options_Social_ChatColor_Guild1)
	self:SetColorFromControl(Options_Social_ChatColor_Officer1Color, profile.Options_Social_ChatColor_Officer1)
	self:SetColorFromControl(Options_Social_ChatColor_Guild2Color, profile.Options_Social_ChatColor_Guild2)
	self:SetColorFromControl(Options_Social_ChatColor_Officer2Color, profile.Options_Social_ChatColor_Officer2)
	self:SetColorFromControl(Options_Social_ChatColor_Guild3Color, profile.Options_Social_ChatColor_Guild3)
	self:SetColorFromControl(Options_Social_ChatColor_Officer3Color, profile.Options_Social_ChatColor_Officer3)	
	self:SetColorFromControl(Options_Social_ChatColor_Guild4Color, profile.Options_Social_ChatColor_Guild4)
	self:SetColorFromControl(Options_Social_ChatColor_Officer4Color, profile.Options_Social_ChatColor_Officer4)
	self:SetColorFromControl(Options_Social_ChatColor_Guild5Color, profile.Options_Social_ChatColor_Guild5)
	self:SetColorFromControl(Options_Social_ChatColor_Officer5Color, profile.Options_Social_ChatColor_Officer5)	

--Load NamePlate
	self:SetCheckbox(Options_Nameplates_AllNameplates, profile.Options_Nameplates_AllNameplates)
	self:SetCheckbox(Options_Nameplates_ShowPlayerTitles, profile.Options_Nameplates_ShowPlayerTitles)
	self:SetCheckbox(Options_Nameplates_ShowPlayerGuilds, profile.Options_Nameplates_ShowPlayerGuilds)
	self:SetCheckbox(Options_Nameplates_Player, profile.Options_Nameplates_Player)
	self:SetCheckbox(Options_Nameplates_PlayerDimmed, profile.Options_Nameplates_PlayerDimmed)
	self:SetCheckbox(Options_Nameplates_GroupMember, profile.Options_Nameplates_GroupMember)
	self:SetCheckbox(Options_Nameplates_GroupMemberDimmed, profile.Options_Nameplates_GroupMemberDimmed)
	self:SetCheckbox(Options_Nameplates_FriendlyNPC, profile.Options_Nameplates_FriendlyNPC)
	self:SetCheckbox(Options_Nameplates_FriendlyNPCDimmed, profile.Options_Nameplates_FriendlyNPCDimmed)
	self:SetCheckbox(Options_Nameplates_FriendlyPlayer, profile.Options_Nameplates_FriendlyPlayer)
	self:SetCheckbox(Options_Nameplates_FriendlyPlayerDimmed, profile.Options_Nameplates_FriendlyPlayerDimmed)
	self:SetCheckbox(Options_Nameplates_NeutralNPC, profile.Options_Nameplates_NeutralNPC)
	self:SetCheckbox(Options_Nameplates_NeutralNPCDimmed, profile.Options_Nameplates_NeutralNPCDimmed)
	self:SetCheckbox(Options_Nameplates_EnemyNPC, profile.Options_Nameplates_EnemyNPC)
	self:SetCheckbox(Options_Nameplates_EnemyNPCDimmed, profile.Options_Nameplates_EnemyNPCDimmed)
	self:SetCheckbox(Options_Nameplates_EnemyPlayer, profile.Options_Nameplates_EnemyPlayer)
	self:SetCheckbox(Options_Nameplates_EnemyPlayerDimmed, profile.Options_Nameplates_EnemyPlayerDimmed)

	self:SetCheckbox(Options_Nameplates_AllHB, profile.Options_Nameplates_AllHB)
	self:SetCheckbox(Options_Nameplates_HealthbarChaseBar, profile.Options_Nameplates_HealthbarChaseBar)
	self:SetCheckbox(Options_Nameplates_HealthbarFrameBorder, profile.Options_Nameplates_HealthbarFrameBorder)

	self:SetDropdown(Options_Nameplates_PlayerHB, profile.Options_Nameplates_PlayerHB)

	self:SetDropdown(Options_Nameplates_GroupMemberHB, profile.Options_Nameplates_GroupMemberHB)
	self:SetDropdown(Options_Nameplates_GroupMemberHBDimmed, profile.Options_Nameplates_GroupMemberHBDimmed)
	self:SetDropdown(Options_Nameplates_FriendlyNPCHB, profile.Options_Nameplates_FriendlyNPCHB)
	self:SetDropdown(Options_Nameplates_FriendlyPlayerHB, profile.Options_Nameplates_FriendlyPlayerHB)
	self:SetDropdown(Options_Nameplates_NeutralNPCHB, profile.Options_Nameplates_NeutralNPCHB)
	self:SetDropdown(Options_Nameplates_EnemyNPCHB, profile.Options_Nameplates_EnemyNPCHB)
	self:SetDropdown(Options_Nameplates_EnemyPlayerHB, profile.Options_Nameplates_EnemyPlayerHB)
	self:SetDropdown(Options_Nameplates_HealthbarAlignment, profile.Options_Nameplates_HealthbarAlignment)


	self:SetDropdown(Options_Nameplates_FriendlyPlayerHBDimmed, profile.Options_Nameplates_FriendlyPlayerHBDimmed)
	self:SetDropdown(Options_Nameplates_NeutralNPCHBDimmed, profile.Options_Nameplates_NeutralNPCHBDimmed)
	self:SetDropdown(Options_Nameplates_EnemyNPCHBDimmed, profile.Options_Nameplates_EnemyNPCHBDimmed)
	self:SetDropdown(Options_Nameplates_FriendlyNPCHBDimmed, profile.Options_Nameplates_FriendlyNPCHBDimmed)
	self:SetDropdown(Options_Nameplates_PlayerHBDimmed, profile.Options_Nameplates_PlayerHBDimmed)
	self:SetDropdown(Options_Nameplates_EnemyPlayerHBDimmed, profile.Options_Nameplates_EnemyPlayerHBDimmed)
	self:SetDropdown(Options_Nameplates_AllianceIndicators, profile.Options_Nameplates_AllianceIndicators)

	self:SetCheckbox(Options_Nameplates_GroupIndicators, profile.Options_Nameplates_GroupIndicators)
	self:SetCheckbox(Options_Nameplates_ResurrectIndicators, profile.Options_Nameplates_ResurrectIndicators)
	self:SetCheckbox(Options_Nameplates_FollowerIndicators, profile.Options_Nameplates_FollowerIndicators)
	self:SetSlider(Options_Nameplates_GlowThickness, profile.Options_Nameplates_GlowThickness)
	self:SetSlider(Options_Nameplates_TargetGlowIntensity, profile.Options_Nameplates_TargetGlowIntensity)
	self:SetSlider(Options_Nameplates_InteractableGlowIntensity, profile.Options_Nameplates_InteractableGlowIntensity)

--Load Combat
	self:SetDropdown(Options_Combat_ShowActionBar, profile.Options_Combat_ShowActionBar)
	self:SetDropdown(Options_Combat_ShowResourceBars, profile.Options_Combat_ShowResourceBars)
	self:SetDropdown(Options_Combat_ResourceNumbers, profile.Options_Combat_ResourceNumbers)
	self:SetDropdown(Options_Combat_ActiveCombatTips, profile.Options_Combat_ActiveCombatTips)
	self:SetCheckbox(Options_Combat_UltimateNumber, profile.Options_Combat_UltimateNumber)

	self:SetCheckbox(Options_Combat_SCTEnabled, profile.Options_Combat_SCTEnabled)
	self:SetCheckbox(Options_Combat_SCTOutgoingEnabled, profile.Options_Combat_SCTOutgoingEnabled)
	self:SetCheckbox(Options_Combat_SCTOutgoingDamageEnabled, profile.Options_Combat_SCTOutgoingDamageEnabled)
	self:SetCheckbox(Options_Combat_SCTOutgoingDoTEnabled, profile.Options_Combat_SCTOutgoingDoTEnabled)
	self:SetCheckbox(Options_Combat_SCTOutgoingHealingEnabled, profile.Options_Combat_SCTOutgoingHealingEnabled)
	self:SetCheckbox(Options_Combat_SCTOutgoingHoTEnabled, profile.Options_Combat_SCTOutgoingHoTEnabled)
	self:SetCheckbox(Options_Combat_SCTOutgoingStatusEffectsEnabled, profile.Options_Combat_SCTOutgoingStatusEffectsEnabled)
	self:SetCheckbox(Options_Combat_SCTOutgoingPetDamageEnabled, profile.Options_Combat_SCTOutgoingPetDamageEnabled)
	self:SetCheckbox(Options_Combat_SCTOutgoingPetDoTEnabled, profile.Options_Combat_SCTOutgoingPetDoTEnabled)
	self:SetCheckbox(Options_Combat_SCTOutgoingPetHealingEnabled, profile.Options_Combat_SCTOutgoingPetHealingEnabled)
	self:SetCheckbox(Options_Combat_SCTOutgoingPetHoTEnabled, profile.Options_Combat_SCTOutgoingPetHoTEnabled)
	self:SetCheckbox(Options_Combat_SCTIncomingEnabled, profile.Options_Combat_SCTIncomingEnabled)
	self:SetCheckbox(Options_Combat_SCTIncomingDamageEnabled, profile.Options_Combat_SCTIncomingDamageEnabled)
	self:SetCheckbox(Options_Combat_SCTIncomingDoTEnabled, profile.Options_Combat_SCTIncomingDoTEnabled)
	self:SetCheckbox(Options_Combat_SCTIncomingHealingEnabled, profile.Options_Combat_SCTIncomingHealingEnabled)
	self:SetCheckbox(Options_Combat_SCTIncomingHoTEnabled, profile.Options_Combat_SCTIncomingHoTEnabled)
	self:SetCheckbox(Options_Combat_SCTIncomingStatusEffectsEnabled, profile.Options_Combat_SCTIncomingStatusEffectsEnabled)
	self:SetCheckbox(Options_Combat_SCTIncomingPetDamageEnabled, profile.Options_Combat_SCTIncomingPetDamageEnabled)
	self:SetCheckbox(Options_Combat_SCTIncomingPetDoTEnabled, profile.Options_Combat_SCTIncomingPetDoTEnabled)

	self:SetDropdown(Options_Combat_Buffs_AllEnabled, profile.Options_Combat_Buffs_AllEnabled)
	self:SetCheckbox(Options_Combat_Buffs_SelfBuffs, profile.Options_Combat_Buffs_SelfBuffs)
	self:SetCheckbox(Options_Combat_Buffs_SelfDebuffs, profile.Options_Combat_Buffs_SelfDebuffs)
	self:SetCheckbox(Options_Combat_Buffs_TargetDebuffs, profile.Options_Combat_Buffs_TargetDebuffs)
	self:SetCheckbox(Option_Combat_Buffs_Debuffs_Enabled_For_Target_From_Others, profile.Option_Combat_Buffs_Debuffs_Enabled_For_Target_From_Others)
	self:SetCheckbox(Options_Combat_Buffs_LongEffects, profile.Options_Combat_Buffs_LongEffects)
	self:SetCheckbox(Options_Combat_Buffs_PermanentEffects, profile.Options_Combat_Buffs_PermanentEffects)


	
	KEYBOARD_OPTIONS:UpdateAllPanelOptions(1)
	self:DisplayMsg(zo_strformat(GetString(DDSP_PROFILE_LOADED), profileName), false)
end

function ddSettingsProfiles:GetProfileIndex()
	local choices = { "None" }
	local player = GetDisplayName()
	
	if ddSettingsProfiles_SV and
	ddSettingsProfiles_SV["Default"] and
	ddSettingsProfiles_SV["Default"][player] then
		for profile, data in pairs(ddSettingsProfiles_SV["Default"][player]["$AccountWide"]) do
			if type(data) == "table" then
				table.insert(choices, profile)
			end
		end
	end
	
	self.profileIndex = choices
end

function ddSettingsProfiles:DisplayMsg(msgString, boolDebug)												
	local Debug = self.Options.Debug.getFunc()
	local Notify = self.Options.Notify.getFunc()
	
	if Debug and 
	boolDebug then
		d(GetString(DDSP_DEBUG) .. msgString)																	

	elseif Notify and
	not boolDebug then
		d(GetString(DDSP_MONIKER) .. msgString)
		
	else
		return
	end
end

function ddSettingsProfiles:Init()
	self:DisplayMsg(GetString(DDSP_LOADED), true)
end

function ddSettingsProfiles.OnAddonLoaded(eventCode, addonName)
	if addonName ~= ADDON_NAME then
		return
	else
		ddSettingsProfiles.Profiles = ZO_SavedVars:NewAccountWide("ddSettingsProfiles_SV", SV_VERSION, nil, {} )
		ddSettingsProfiles:GetProfileIndex()
		ddSettingsProfiles.Options:Init()

		LAME_PANEL = LIB_LAM2:RegisterAddonPanel("ddSP_LAM", ddSettingsProfiles:mPanel())
		LIB_LAM2:RegisterOptionControls("ddSP_LAM", ddSettingsProfiles:mControls())
		
		KEYBOARD_OPTIONS:UpdateAllPanelOptions(1)
		
		ddSettingsProfiles:Init()
		EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
	end
end


EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, ddSettingsProfiles.OnAddonLoaded)
--------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------