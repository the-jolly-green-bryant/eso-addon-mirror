

function RoyalHouse:GetCurrentPlatform() 
  return RoyalHouse.enums.platforms[GetUIPlatform()]
end


function RoyalHouse:GetCurrentServerRegion()
	local serverRegion = nil
	local lastPlatform = GetCVar("LastPlatform")
	local lastRealm = GetCVar("LastRealm")
	if (lastPlatform == "Live") then
		serverRegion = "NA"
	elseif (lastPlatform == "Live-EU") then
		serverRegion = "EU"
	elseif (lastRealm:find("^NA") ~= nil) then
		serverRegion = "NA"
	elseif (lastRealm:find("^EU") ~= nil) then
		serverRegion = "EU"
	end

	return serverRegion
end


function RoyalHouse:ResetSavedVars()
  RoyalHouse.savedVars["account"] = {}
  RoyalHouse.savedVars["account"]["region"] = RoyalHouse:GetCurrentServerRegion()
  RoyalHouse.savedVars["account"]["platform"] = RoyalHouse:GetCurrentPlatform()
  RoyalHouse.savedVars["char"] = {}
  RoyalHouse.savedVars["char"]["stats"] = {}
  RoyalHouse.savedVars["char"]["equipament"] = {}
  RoyalHouse.savedVars["char"]["actionbar"] = {}
  RoyalHouse.savedVars["char"]["buffs"] = {}
  RoyalHouse.savedVars["guilds"] = {}
end


function RoyalHouse:AddCharInformationToSavedVars()
  local currentCharacterId = GetCurrentCharacterId()
  RoyalHouse.savedVars["char"]["id"] = currentCharacterId
  
  for characterIndex = 1, GetNumCharacters() do
    local characterName, characterGenderId, characterLevel, characterClassId, characterRaceId, characterAllianceId, characterId = GetCharacterInfo(characterIndex)
    
    if characterId == currentCharacterId then
      local displayName = GetDisplayName()
      local characterGender = GetGenderFromNameDescriptor(characterName)
      local className = GetClassName(characterGenderId, characterClassId)
      local allianceName = GetAllianceName(characterAllianceId)
      local raceName = GetRaceName(characterGenderId, characterRaceId)
      local championPoints = GetPlayerChampionPointsEarned()

      RoyalHouse.savedVars["char"]["name"] = characterName
      RoyalHouse.savedVars["char"]["displayName"] = displayName
      RoyalHouse.savedVars["char"]["gender"] = characterGender
      RoyalHouse.savedVars["char"]["classId"] = characterClassId
      RoyalHouse.savedVars["char"]["class"] = className
      RoyalHouse.savedVars["char"]["raceId"] = characterRaceId
      RoyalHouse.savedVars["char"]["race"] = raceName
      RoyalHouse.savedVars["char"]["allianceId"] = characterAllianceId
      RoyalHouse.savedVars["char"]["alliance"] = allianceName
      RoyalHouse.savedVars["char"]["characterLevel"] = characterLevel
      RoyalHouse.savedVars["char"]["championPoints"] = championPoints
    end
  end

  for statValue, statDescription in pairs(RoyalHouse.enums.derivedStats) do
    RoyalHouse.savedVars["char"]["stats"][statDescription] = GetPlayerStat(statValue, STAT_BONUS_OPTION_DONT_APPLY_BONUS)
  end

  for slotValue, slotDescription in pairs(RoyalHouse.enums.equippedSlots) do
		local itemLink = GetItemLink(BAG_WORN, slotValue)

    if itemLink ~= "" then
      local itemId = GetItemLinkItemId(itemLink)
      local itemIcon = GetItemLinkIcon(itemLink)
      local armorType = GetItemLinkArmorType(itemLink)
      local equipType = GetItemLinkEquipType(itemLink)
      local itemName = GetItemLinkName(itemLink)
      local itemQuality = GetItemLinkQuality(itemLink)
      local requiredChampionPoints = GetItemLinkRequiredChampionPoints(itemLink)
      local requiredLevel = GetItemLinkRequiredLevel(itemLink)
      local hasSet, setName, numBonuses, numEquipped, maxEquipped, setId = GetItemLinkSetInfo(itemLink, true)
      local traitType, traitDescription = GetItemLinkTraitInfo(itemLink)
      local traitCategory = GetItemLinkTraitCategory(itemLink)
      local weaponType = GetItemLinkWeaponType(itemLink)
      local weaponPower = GetItemLinkWeaponPower(itemLink)
      local enchantId = GetItemLinkFinalEnchantId(itemLink)
      local hasCharges, enchantHeader, enchantDescription = GetItemLinkEnchantInfo(itemLink)
      local armorRating = GetItemLinkArmorRating(itemLink, false)

      local equipamentBonus = {}

      for i = 1, numBonuses do
        local bonusRequired, bonusDescription = GetItemLinkSetBonusInfo(itemLink, NOT_EQUIPPED, i)
        equipamentBonus["bonus_"..tostring(i)] = {
          ["bonusIndex"] = i,
          ["bonusRequired"] = bonusRequired,
          ["bonusDescription"] = bonusDescription,
        }
      end

      RoyalHouse.savedVars["char"]["equipament"][slotDescription] = {
        ["itemId"] = itemId,
        ["itemIcon"] = itemIcon,
        ["itemLink"] = itemLink,
        ["armorTypeId"] = armorType,
        ["armorType"] = RoyalHouse.enums.armorTypes[armorType],
        ["armorRating"] = armorRating,
        ["equipTypeId"] = equipType,
        ["equipType"] = RoyalHouse.enums.equipeTypes[equipType],
        ["itemName"] = itemName,
        ["itemQualityId"] = itemQuality,
        ["itemQuality"] = RoyalHouse.enums.itemQualities[itemQuality],
        ["requiredChampionPoints"] = requiredChampionPoints,
        ["requiredLevel"] = requiredLevel,
        ["weaponTypeId"] = weaponType,
        ["weaponType"] = RoyalHouse.enums.weaponTypes[weaponType],
        ["weaponPower"] = weaponPower,
        ["setInfo"] = {
          ["hasSet"] = hasSet,
          ["setName"] = setName,
          ["numBonuses"] = numBonuses,
          ["numEquipped"] = numEquipped,
          ["maxEquipped"] = maxEquipped,
          ["setId"] = setId,
        },
        ["enchantInfo"] = {
          ["enchantId"] = enchantId,
          ["hasCharges"] = hasCharges,
          ["enchantHeader"] = enchantHeader,
          ["enchantDescription"] = enchantDescription,
        },
        ["traitInfo"] = {
          ["traitTypeId"] = traitType,
          ["traitType"] = RoyalHouse.enums.itemTraitTypes[traitType],
          ["traitDescription"] = traitDescription,
          ["traitCategoryId"] = traitCategory,
          ["traitCategory"] = RoyalHouse.enums.itemTraitTypeCategories[traitCategory],
        },
        ["equipamentBonus"] = equipamentBonus,
      }
    end
  end

  for categoryValue, categoryDescription in pairs(RoyalHouse.enums.hotBarCategories) do
    RoyalHouse.savedVars["char"]["actionbar"][categoryDescription] = {}

    for slotIndex = 3, 8 do
      local actionId = GetSlotBoundId(slotIndex, categoryValue)
      local abilityName = GetAbilityName(actionId)
      local abilityDescription = GetAbilityDescription(actionId)
      local abilityIcon = GetAbilityIcon(actionId)

      RoyalHouse.savedVars["char"]["actionbar"][categoryDescription][tostring(slotIndex)] = {
        ["actionId"] = actionId,
        ["abilityName"] = abilityName,
        ["abilityDescription"] = abilityDescription,
        ["abilityIcon"] = abilityIcon,
      }
    end
  end
  
  for buffIndex = 1, GetNumBuffs("player") do
    local buffName, _, _, _, _, iconFilename, _, _, _, _, abilityId = GetUnitBuffInfo("player", buffIndex)
		local abilityDescription = GetAbilityDescription(abilityId)
    RoyalHouse.savedVars["char"]["buffs"][tostring(buffIndex)] = {
      ["buffName"] = buffName,
      ["abilityId"] = abilityId,
      ["abilityDescription"] = abilityDescription,
      ["iconFilename"] = iconFilename,
    }
  end
end


function RoyalHouse:AddGuildsInformationToSavedVars() 
  local numGuilds = GetNumGuilds()
    
  for guildIndex = 1, numGuilds do
    local guildId = GetGuildId(guildIndex)
    local guildName = GetGuildName(guildId)
    local numMembers, numOnline = GetGuildInfo(guildId)
    local numRanks = GetNumGuildRanks(guildId)

    RoyalHouse.savedVars["guilds"][tostring(guildId)] = {}
    RoyalHouse.savedVars["guilds"][tostring(guildId)]["name"] = guildName
    RoyalHouse.savedVars["guilds"][tostring(guildId)]["ranks"] = {}
    RoyalHouse.savedVars["guilds"][tostring(guildId)]["members"] = {}

    for rankIndex = 1, numRanks do
      local rankName = GetGuildRankCustomName(guildId, rankIndex)

      RoyalHouse.savedVars["guilds"][tostring(guildId)]["ranks"][tostring(rankIndex)] = {
        ["rankName"] = rankName,
      }
    end

    for memberIndex = 1, numMembers do 
      local name, note, rankIndex, playerStatus, secsSinceLogoff = GetGuildMemberInfo(guildId, memberIndex)
      local hasCharacter, characterName, zoneName, classId, alliance, level, championPoints, zoneId = GetGuildMemberCharacterInfo(guildId, memberIndex)
      local characterGender = GetGenderFromNameDescriptor(characterName)
      local className = GetClassName(characterGender, classId)
      local allianceName = GetAllianceName(alliance)

      if name ~= "" then
        RoyalHouse.savedVars["guilds"][tostring(guildId)]["members"][name] = {
          ["rankIndex"] = rankIndex, 
          ["rankName"] = rankName, 
          ["characterName"] = characterName, 
          ["classId"] = classId, 
          ["className"] = className, 
          ["allianceId"] = alliance, 
          ["allianceName"] = allianceName, 
          ["level"] = level, 
          ["championPoints"] = championPoints,
          ["secsSinceLogoff"] = secsSinceLogoff,
        }
      end
    end
  end
end


function RoyalHouse:Initialize() 
  SLASH_COMMANDS["/royalhouse"] = function()
    RoyalHouse:ResetSavedVars()
    RoyalHouse:AddCharInformationToSavedVars()
    RoyalHouse:AddGuildsInformationToSavedVars()
    d("Royal House - Data saved successfully! To perform synchronization, don't forget to run the client in the addon directory.")
    ReloadUI("ingame")
  end
end


local function OnAddOnLoaded(event, addonName)
  if addonName == RoyalHouse.addonName then    
    EVENT_MANAGER:UnregisterForEvent(RoyalHouse.name, EVENT_ADD_ON_LOADED)
    RoyalHouse.savedVars = ZO_SavedVars:NewAccountWide("RoyalHouseVars", 1, nil, {})
    RoyalHouse:Initialize()
  end
end
 

EVENT_MANAGER:RegisterForEvent(RoyalHouse.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
