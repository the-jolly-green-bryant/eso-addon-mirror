CraftingExperience = {}
CraftingExperience.name      = 'CraftingExperience'
CraftingExperience.author    = 't31os'
CraftingExperience.version   = '1.0.1'
CraftingExperience.defaults  = {feedback = 'Default',pending = '',}
CraftingExperience.configVer = 1

function CraftingExperience.OnStart_Crafting( eventCode, craftingType )
	
	local ESOparentControl = ''
	
	-- Determine appropriate control - Blacksmithing, Woodworking, Clothing and Jewelry share a top level control
	if craftingType == CRAFTING_TYPE_BLACKSMITHING or 
	   craftingType == CRAFTING_TYPE_CLOTHIER or 
	   craftingType == CRAFTING_TYPE_WOODWORKING or 
	   craftingType == CRAFTING_TYPE_JEWELRYCRAFTING 
	then
		ESOparentControl = 'ZO_SmithingTopLevel'
	elseif craftingType == CRAFTING_TYPE_ALCHEMY then 
		ESOparentControl = 'ZO_AlchemyTopLevel'
	elseif craftingType == CRAFTING_TYPE_ENCHANTING then
		ESOparentControl = 'ZO_EnchantingTopLevel'
	elseif craftingType == CRAFTING_TYPE_PROVISIONING then
		ESOparentControl = 'ZO_ProvisionerTopLevel'
	else 
		return
	end
	
	local skillType, skillIndex = GetCraftingSkillLineIndices( craftingType )
	local skillName, skillRank  = GetSkillLineInfo( skillType, skillIndex )
	
	--local lastRankXp, nextRankXP, currentXP = GetSkillLineXPInfo(skillType, skillIndex)
	--local numAbilities = GetNumSkillAbilities(skillType, skillIndex)
	
	-- You do not get inspiration at max rank
	if skillRank >= 50 then 
		return
	end
		
	local pendMessage = ''
	
	if '' == CraftingExperience.settings.pending then
		pendMessage = GetString( CE_Pending_Craft_Message )
	else
		pendMessage = CraftingExperience.settings.pending
	end
		
	if 'Chat' == CraftingExperience.settings.feedback then
		
		d( pendMessage )
		return

	else
	
		-- Add the output control to the appropriate skillinfo parent control
		local parentControl = WINDOW_MANAGER:GetControlByName( ESOparentControl .. 'SkillInfo' )
	
		CraftingExperienceUILabel:SetText( pendMessage )
		CraftingExperienceUI:SetAnchor( TOPLEFT, parentControl, BOTTOMLEFT )
		CraftingExperienceUI:SetHidden( false );
		
	end
	
end

function CraftingExperience.OnEnd_Crafting()
	
	if not CraftingExperienceUI:IsHidden() then 
		CraftingExperienceUI:SetHidden( true )
	end
	
end

function CraftingExperience.OnExperience_Update( a, skillType, skillIndex, lastRankXP, nextRankXP, currentXP)
	
	-- If not a crafting skill, end execution here
	if skillType ~= SKILL_TYPE_TRADESKILL then return end
	
	-- Prepare xp message
	local inspiration_gained = string.format( '|cFACC2E%s:|r +%d xp' , GetString( CE_Inspiration_Gained_Text ), GetLastCraftingResultTotalInspiration() )
	
	if 'Chat' == CraftingExperience.settings.feedback then
		d( inspiration_gained )
	else
		-- Update label
		CraftingExperienceUILabel:SetText( inspiration_gained );
	end
	
end

function CraftingExperience.OnAddon_loaded( eventCode, addOnName )

	-- If not this addon, end execution here
	if addOnName ~= CraftingExperience.name then return end
	
	-- Saved variable for this addon
	CraftingExperience.settings = ZO_SavedVars:NewAccountWide( "CraftingExperienceSettings" , CraftingExperience.configVer, nil, CraftingExperience.defaults, nil );
	
	-- Setup the settings panel
	CraftingExperience.CreateSettingsPanel()
	
	-- Event hook - When a crafting station interaction has started
	EVENT_MANAGER:RegisterForEvent( CraftingExperience.name, EVENT_CRAFTING_STATION_INTERACT, CraftingExperience.OnStart_Crafting )
	
	-- Event hook - When a crafting station interaction has ended
	EVENT_MANAGER:RegisterForEvent( CraftingExperience.name, EVENT_END_CRAFTING_STATION_INTERACT, CraftingExperience.OnEnd_Crafting )
	
	-- Event hook - When XP is granted for a skill
	EVENT_MANAGER:RegisterForEvent( CraftingExperience.name, EVENT_SKILL_XP_UPDATE, CraftingExperience.OnExperience_Update );

end

EVENT_MANAGER:RegisterForEvent( CraftingExperience.name, EVENT_ADD_ON_LOADED , CraftingExperience.OnAddon_loaded );