

-------------------------------------------------------------------------------------------------
-- Create Tables used in the addon --
-------------------------------------------------------------------------------------------------
LootIt = {}
LootIt.lootPositionPool = {}	-- Holds used positions for custom position pool
-- Used to hold items for debugging
LootIt.debug = {}
LootIt.debugMode = false

-------------------------------------------------------------------------------------------------
--  Initialize Variables --
-------------------------------------------------------------------------------------------------
LootIt.name 		= "LootIt"
-------------------------------------------------------------------------------------------------
LootIt.version 		= 1.0 -- leave to prevent resetting saved vars --
-------------------------------------------------------------------------------------------------
LootIt.RealVersion  = 1.7
-------------------------------------------------------------------------------------------------

-- When looting gold, even with loot consolidation on you still get individual gold updates
-- for each stack of gold you loot, these hold the values for a few milliseconds to add them up
-- so we can display the total gold looted/lost
local GoldGainHold = 0
local GoldLostHold = 0

-------------------------------------------------------------------------------------------------
--  Colors  --
-------------------------------------------------------------------------------------------------
local colorRed 			= "|cFF0000" 	-- Red
local colorYellow 		= "|cFFFF00" 	-- yellow 


-------------------------------------------------------------------------------------------------
--  Textures  --
-------------------------------------------------------------------------------------------------
-- Rank up texture, displays inline with text to show a rank up. I did it this way, inline, so that we
-- could still display the skill/abilities normal texture in the texture window
local RankUpTexture = "|t32:32:/esoui/art/progression/progression_crafting_unlocked_down.dds|t"

-- Holds the default texture pack and any registered texture packs
LootIt.tTexturePacks = {
	Default = {	
		["DisplayName"] 			= "Default",
		["CHARACTER_XP"]			= "LootIt/Textures/LootIt_XP_Texture.dds",
		["GOLD"]					= "/esoui/art/icons/item_generic_coinbag.dds",
		[SKILL_TYPE_ARMOR] 			= "/esoui/art/progression/progression_indexicon_armor_up.dds",
		[SKILL_TYPE_AVA] 			= "/esoui/art/progression/progression_indexicon_ava_up.dds",
		[SKILL_TYPE_CLASS] 			= "/esoui/art/progression/progression_indexicon_class_up.dds",
		[SKILL_TYPE_GUILD]			= "/esoui/art/progression/progression_indexicon_guilds_up.dds",
		[SKILL_TYPE_NONE] 			= "/esoui/art/charactercreate/unavailable_overlay.dds",
		[SKILL_TYPE_RACIAL] 		= "/esoui/art/progression/progression_indexicon_race_up.dds",
		[SKILL_TYPE_TRADESKILL] 	= "/esoui/art/progression/progression_indexicon_tradeskills_up.dds",
		[SKILL_TYPE_WEAPON] 		= "/esoui/art/progression/progression_indexicon_weapons_up.dds",
		[SKILL_TYPE_WORLD]  		= "/esoui/art/progression/progression_indexicon_world_up.dds",
	
		-- Armor
		["Light Armor"]			= "/esoui/art/progression/progression_indexicon_armor_up.dds",
		["Medium Armor"]		= "/esoui/art/progression/progression_indexicon_armor_up.dds",
		["Heavy Armor"]			= "/esoui/art/progression/progression_indexicon_armor_up.dds",
		
		-- AVA:  None
		-- Class Sorcerer: These textures are not necessary, this is an example of how to override them
		["Dark Magic"] 			= "/esoui/art/progression/progression_indexicon_class_up.dds",
		["Daedric Summoning"]	= "/esoui/art/progression/progression_indexicon_class_up.dds",
		["Storm Calling"] 		= "/esoui/art/progression/progression_indexicon_class_up.dds",
		
		-- GUILD: None
		
		-- Racial: High Elf Skills: This textures are not necessary, this is an example of how to override them
		["High Elf Skills"] 	= "/esoui/art/progression/progression_indexicon_race_up.dds",
	
		-- Tradeskills
		["Alchemy"]				= "/esoui/art/progression/icon_alchemist.dds",
		["Blacksmithing"]		= "/esoui/art/icons/servicemappins/servicepin_smithy.dds",
		["Clothing"]			= "/esoui/art/icons/servicemappins/servicepin_outfitter.dds",
		["Enchanting"]			= "/esoui/art/crafting/enchantment_tabicon_essence_up.dds",
		["Provisioning"]		= "/esoui/art/crafting/provisioner_indexicon_beer_up.dds",
		["Woodworking"]			= "/esoui/art/icons/servicemappins/servicepin_woodworking.dds",

		-- Weapon
		["Two Handed"]			= "/esoui/art/progression/icon_2handed.dds",
		["One Hand and Shield"]	= "/esoui/art/progression/icon_1handed.dds",
		["Dual Wield"]			= "/esoui/art/progression/icon_dualwield.dds",
		["Bow"]					= "/esoui/art/progression/icon_bows.dds",
		["Destruction Staff"]	= "/esoui/art/progression/icon_firestaff.dds",
		["Restoration Staff"]	= "/esoui/art/progression/icon_healstaff.dds",

		-- World
		["Soul Magic"]			= "/esoui/art/progression/progression_indexicon_world_up.dds",
	},
}
-- Default to the "Default" texture pack
local tCurTexturePack = LootIt.tTexturePacks["Default"]

local LootItPlayerDefault = {
-- Holds ability xp
	["AbilityXp"] 			= {},
	
-- Loot Window Settings --
	["LOOTWINDOW"]		 	= true,
	["SHOWLOOTWINDOW"]		= false,
	["LOOTWINDOWOFFSETX"] 	= 0,
	["LOOTWINDOWOFFSETY"] 	= 0,
	["LOOTDIRECTION"]		= "Up",
	["LOOTWINDOWSIZE"]		= "Medium",
	["LOOTWINDOWWIDTH"]		= 200,
	["LOOTWINDOWHEIGHT"]	= 32,
	["FONTSIZE"]			= 16,
	["FONT"]				= "Antique",
	
-- Things to be displayed in Loot Window	
	["SHOWITEMSLOOTED"]		= true,
	["SHOWITEMQUANITY"]		= true,
	["SHOWCHARXPGAINS"]		= true,
	["SHOWSKILLXPGAINS"]	= false,
	["SHOWABILITYXPGAINS"]	= false,
	["SHOWGOLDGAINLOSS"]	= true,
	["SHOWABILITYSKILLNAMES"]	= true,
	
-- Last selected texture pack
-- Not always current texture pack, if they reloadui & the last custom texture pack
-- does not get re-registered for any reason, but it does fix itself when the 
-- settings menu is loaded for the first time or when the pack is re-registered.
	["LASTCUSTOMTEXTUREPACK"] 	= "Default",
	
-- Animation Times
	["ITEMFADEINTIME"]		= 50,
	["ITEMVISIBLETIME"]		= 7000,
	["ITEMTRANSLATETIME"]	= 700,
	["ITEMFADEDURATION"]	= 300,
}



------------------------------------------------------------------------------
-- Get Custom Texture														--
-- Checks to see if there is a custom texture current texture pack if not 	--
-- returns nil, and the functions that call this handle loading the default --
-- texture. Had to be done there instead of here because they each grab 	--
-- a default texture from different places..I.E. abilities use the games	--
-- built in texture returned by a function, where skills grab a default 	--
-- texture from the default table											--
------------------------------------------------------------------------------
-- _Name refers to the more specific version of the texture, for example	--
-- the name of an ability after it is morphed or a specific skill name		--
-- _BroadName refers to the less specific name, for example the ability name--
-- before an ability is morphed or the SkillType a skill belongs to			--
------------------------------------------------------------------------------
local function GetCustomTexture(_Name, _BroadName)
	if not tCurTexturePack then return end
	
	if tCurTexturePack[_Name] then
		return tCurTexturePack[_Name]
	elseif tCurTexturePack[_BroadName] then
		return tCurTexturePack[_BroadName]
	end
end
------------------------------------------------------------------------------
-- Looted Money   (called from: EVENT_MONEY_UPDATE) 						--
------------------------------------------------------------------------------
-- When gold is looted from multiple corpses (even with consolidate loot on) you still get updates
-- for each stack of gold separately. This stores each stack of gold you receive for a few milliseconds --
-- and adds them up so all of the gold you pick up can be displayed together in one stack --
local function MoneyUpdate( _EventCode, _NewMoney, _OldMoney, _Reason) 
	if not LootIt.SavedVariables["SHOWGOLDGAINLOSS"]  then return end
	
	local goldAmount = (_NewMoney - _OldMoney)

	local texture = LootIt.tTexturePacks.Default["GOLD"]
	local customTexture = GetCustomTexture("GOLD")
	
	if customTexture then 
		texture = customTexture
	end
	
	if goldAmount > 0 then
		-- If the gold holder is empty then we need to start a new (delayed) gold loot event --
		if GoldGainHold == 0 then
			zo_callLater(function() 
				local currencyString = zo_strformat(SI_MONEY_FORMAT, ZO_CurrencyControl_FormatCurrency(GoldGainHold))
				LootIt.SetUpControl(currencyString, texture)
				
				GoldGainHold = 0
				end, 300)
		end
		-- Put the gold into a temporary holder so we can add it up --
		GoldGainHold = GoldGainHold + goldAmount
	elseif goldAmount < 0 then
		-- If the gold holder is empty then we need to start a new (delayed) gold loot event --
		if GoldLostHold == 0 then
			zo_callLater(function() 
				local currencyString = zo_strformat(SI_MONEY_FORMAT, ZO_CurrencyControl_FormatCurrency(GoldLostHold))
				LootIt.SetUpControl(currencyString, texture)
				GoldLostHold = 0
				end, 300)
		end
		-- Put the gold into a temporary holder so we can add it up --
		GoldLostHold = GoldLostHold + goldAmount
	end
end
--## EVENT_LOOT_RECEIVED (integer eventCode, string receivedBy, string itemName, integer quantity, integer itemSound, integer lootType, boolean self, boolean isPickpocketLoot, string questItemIcon, integer itemId) 

local function LootReceived(eventCode, receivedBy, itemLink, quantity, itemSound, lootType, self)
	if not LootIt.SavedVariables["SHOWITEMSLOOTED"] then return end
	
    local fReceivedBy = zo_strformat(SI_UNIT_NAME, receivedBy)
	local fPlayerName = zo_strformat(SI_UNIT_NAME, GetUnitName("player"))
	
    if fReceivedBy ~= fPlayerName then return end
	
	local sIcon, iSellPrice, bMeetsUsageRequirement, iEquipType, iItemStyle = GetItemLinkInfo(itemLink)
	local iQuality = GetItemLinkQuality(itemLink)
	local sItemName = GetItemQualityColor(iQuality):Colorize(zo_strformat(SI_TOOLTIP_ITEM_NAME, GetItemLinkName(itemLink)))
	
	local labelText
	if LootIt.SavedVariables["SHOWITEMQUANITY"] and quantity > 1 then
		labelText = "("..quantity..") ".. sItemName
	else
		labelText = sItemName
	end
	
	LootIt.SetUpControl(labelText, sIcon)
end

local function SkillXpUpdate(eventCode, skillType, skillIndex, reason, rank, previousXP, currentXP) 
	if not LootIt.SavedVariables["SHOWSKILLXPGAINS"] then return end
	
	local xpGain = currentXP - previousXP
    local skillName = GetSkillLineInfo(skillType, skillIndex) 
	local labelText = xpGain.." XP "
	
	if LootIt.SavedVariables["SHOWABILITYSKILLNAMES"] then
		labelText = labelText..skillName
	end
	
	-- If there is a custom texture, use it. If not grab the default texture
	local texture = GetCustomTexture(skillName, skillType)
	if not customTexture then
		if LootIt.tTexturePacks.Default[skillName] then
			texture = LootIt.tTexturePacks.Default[skillName]
		else
			texture = LootIt.tTexturePacks.Default[skillType]
		end
	end
	
	LootIt.SetUpControl(labelText, texture) 
end
local function SkillRankUpdate(eventCode, skillType, skillIndex, rank) 
	if not LootIt.SavedVariables["SHOWSKILLXPGAINS"] then return end
	
    local skillName = GetSkillLineInfo(skillType, skillIndex) 
	local texture = LootIt.tTexturePacks.Default[skillType]
	
	-- If there is a custom texture, use it. If not grab the default texture
	local texture = GetCustomTexture(skillName)
	if not texture then
		if LootIt.tTexturePacks.Default[skillName] then
			texture = LootIt.tTexturePacks.Default[skillName]
		else
			texture = LootIt.tTexturePacks.Default[skillType]
		end
	end
	
	local labelText = RankUpTexture.." "..skillName.." Rank "..rank
	
	LootIt.SetUpControl(labelText, texture) 
end
local function AbilityXpUpdate(eventCode, progressionIndex, lastRankXP, nextRankXP, currentXP, atMorph)
	if not LootIt.SavedVariables["SHOWABILITYXPGAINS"] then return end
	
	local xpGain
    local baseName, morph, rank  = GetAbilityProgressionInfo(progressionIndex)
    local abilityName, texture, abilityIndex = GetAbilityProgressionAbilityInfo(progressionIndex, morph, rank) 

	if LootIt.SavedVariables[abilityName] then
		xpGain = currentXP - LootIt.SavedVariables[abilityName]
	else
		xpGain = currentXP
	end
	LootIt.SavedVariables[abilityName] = currentXP
	
	local customTexture = GetCustomTexture(abilityName, baseName)
	if customTexture then
		texture = customTexture
	end
	
	local labelText = xpGain.." XP "
	if LootIt.SavedVariables["SHOWABILITYSKILLNAMES"] then
		labelText = labelText..abilityName
	end
	
	LootIt.SetUpControl(labelText, texture) 
end
local function AbilityRankUpdate(eventCode, progressionIndex, rank, maxRank, morph) 
	if not LootIt.SavedVariables["SHOWABILITYXPGAINS"] then return end
	
    local baseName, morph, rank  = GetAbilityProgressionInfo(progressionIndex)
    local abilityName, texture, abilityIndex = GetAbilityProgressionAbilityInfo(progressionIndex, morph, rank) 
	
	local customTexture = GetCustomTexture(abilityName, baseName)
	if customTexture then
		texture = customTexture
	end
	local labelText = RankUpTexture.." "..abilityName.." Rank "..rank
	
	LootIt.SetUpControl(labelText, texture) 
end
local function XpGained(eventCode, reason, level, previousExperience, currentExperience)
	if not LootIt.SavedVariables["SHOWCHARXPGAINS"] then return end
	
	local xpGain = currentExperience - previousExperience
    local labelText = xpGain
	local texture = LootIt.tTexturePacks.Default["CHARACTER_XP"]
	local texture = LootIt.tTexturePacks.Default["CHARACTER_XP"]
	local customTexture = GetCustomTexture("CHARACTER_XP")
	
	if customTexture then 
		texture = customTexture
	end
	
	LootIt.SetUpControl(labelText, texture) 
end

function LootIt.SetTexturePack(_DisplayName)
	if LootIt.tTexturePacks[_DisplayName] then
		tCurTexturePack = LootIt.tTexturePacks[_DisplayName]
	else
		tCurTexturePack = LootIt.tTexturePacks.default
	end
end
-------------------------------------------------------------------------------------------------
--  OnAddOnLoaded  --
-------------------------------------------------------------------------------------------------
local function OnAddOnLoaded(_event, _sAddonName)
	if _sAddonName == LootIt.name then
		LootIt:Initialize()
	end
end

-------------------------------------------------------------------------------------------------
--  Initialize Function --
-------------------------------------------------------------------------------------------------
function LootIt:Initialize()
	-- Get saved variables (char specific) --
	self.SavedVariables = ZO_SavedVars:New("LootItSavedVars", LootIt.version, nil, LootItPlayerDefault)
	
	-- Save a reference to the main loot window, its background, & reload saved position
	LootIt.LootWindow = LootItLootWindow
	LootIt.LootWindowBg = LootItLootWindow
	
	local winWidth = LootIt.SavedVariables["LOOTWINDOWWIDTH"]
	local winHeight = LootIt.SavedVariables["LOOTWINDOWHEIGHT"]
	LootIt.LootWindow:SetDimensions(winWidth, winHeight)
	
	-- reload loot window position
	LootIt.SetSavedAnchorLootWindow()
	
	-- Create loot pool for loot item windows (this is for the individual loot item windows) --
	LootIt.LootPool = ZO_ControlPool:New("LootItItemWindow", nil, "LootItItemWindow")
	
	-- Create the settings menu
	LootIt.CreateSettingsMenu()
	
	-- Register Events --
    --EVENT_MANAGER:RegisterForEvent(LootIt.name, EVENT_MAIL_ATTACHMENT_REMOVED , OnMailRecieved) 
    EVENT_MANAGER:RegisterForEvent(LootIt.name, EVENT_LOOT_RECEIVED , LootReceived) 
    EVENT_MANAGER:RegisterForEvent(LootIt.name, EVENT_MONEY_UPDATE, MoneyUpdate) 
	EVENT_MANAGER:RegisterForEvent(LootIt.name, EVENT_EXPERIENCE_GAIN, XpGained)
	EVENT_MANAGER:RegisterForEvent(LootIt.name, EVENT_SKILL_XP_UPDATE, SkillXpUpdate)
	EVENT_MANAGER:RegisterForEvent(LootIt.name, EVENT_ABILITY_PROGRESSION_XP_UPDATE, AbilityXpUpdate)
	EVENT_MANAGER:RegisterForEvent(LootIt.name, EVENT_SKILL_RANK_UPDATE, SkillRankUpdate)
	EVENT_MANAGER:RegisterForEvent(LootIt.name, EVENT_ABILITY_PROGRESSION_RANK_UPDATE , AbilityRankUpdate)
	  
	EVENT_MANAGER:UnregisterForEvent(LootIt.name, EVENT_ADD_ON_LOADED)
end
--[[
local function OnMailRecieved(integer eventCode, attachmentSlot) 

end
--]]
-------------------------------------------------------------------------------------------------
--  Register Events --
-------------------------------------------------------------------------------------------------
EVENT_MANAGER:RegisterForEvent(LootIt.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)




