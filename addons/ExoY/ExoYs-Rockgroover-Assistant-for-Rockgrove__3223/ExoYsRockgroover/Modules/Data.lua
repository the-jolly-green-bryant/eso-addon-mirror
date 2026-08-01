Rockgroover = Rockgroover or {}
local ERG = Rockgroover

--Bomber Display
--achievement_ava_artifact_kill100plus_with_artifact_one_session
--achievement_u24_kill_dragon_minions


local displayList = {
  "healthFrame",
}

function ERG.GetDisplayList()
  return displayList
end

local moduleList = {
  "notifications",
  "profiles",
  "units",
}

function ERG.GetModuleList()
  return moduleList
end

local encounterList = {
  "trash",
    --TODO Snake
  "oaxiltso",
  "bahsei",
    --TODO AshTitan
  "xalvakka",
}

function ERG.GetEncounterList()
  return encounterList
end

function ERG.GetAllMainLists()
  local allLists = {}
  for _, module in ipairs( moduleList ) do
    table.insert(allLists, module)
  end
  for _, encounter in ipairs( encounterList ) do
    table.insert(allLists, encounter)
  end
  for _, display in ipairs( displayList ) do
    table.insert(allLists, display)
  end
  return allLists
end

local encounterIcons = {
  ["trash"] = "/esoui/art/icons/achievement_u30_zone_meta.dds",
  ["oaxiltso"] = "/esoui/art/icons/achievement_u30_vtrial_b1_hardmode.dds",
  ["bahsei"] = "/esoui/art/icons/achievement_u30_vtrial_b2_hardmode.dds",
  ["ashTitan"] = "/esoui/art/icons/achievement_u29_dun2_vet_bosses.dds",
  ["xalvakka"] = "/esoui/art/icons/achievement_u30_vtrial_all_hardmode.dds",
}

function ERG.GetEncounterIcons()
  return encounterIcons
end

local bossList = {
  "oaxiltso",
  "bahsei",
  "xalvakka",
}

function ERG.GetBossList()
  return bossList
end

local bossHpList = {
  [19086236] = "oaxiltso", --normal
  [62872740] = "oaxiltso", --69858592
  [125745480] = "oaxiltso", --hm --139717184
  [21812840] = "bahsei", --normal
  [65201356] = "bahsei",  --72445952
  [123882576] = "bahsei", --hm --137647312
  [25084768] = "xalvakka", --normal
  [53558256] = "xalvakka", --59509168
  [214233024] = "xalvakka", --hm --238036672
  --[589395] = "oaxiltso",    -- TestBoss(Slimecraw)
}

function ERG.GetBossHpList()
  return bossHpList
end

local hardmodeHpList = {
  [139717184] = true, --oaxiltso
  [123882576] = true, --bahsei
  [238036672] = true, --xalvakka
}

function ERG.GetHardmodeHpList()
  return hardmodeHpList
end

local damageResults = {
  ACTION_RESULT_DAMAGE,
  ACTION_RESULT_CRITICAL_DAMAGE,
  ACTION_RESULT_DOT_TICK,
  ACTION_RESULT_DOT_TICK_CRITICAL,
  ACTION_RESULT_BLOCK,
}

function ERG.GetDamageResults()
  return damageResults
end


local soundList = {
  "None",
  "OBJECTIVE_DISCOVERED",
  "DUEL_START",
  "CHAMPION_POINTS_COMMITTED",
}

function ERG.GetSoundList()
  return soundList
end


local notificationDesignationList = {
  ["OnTextAlert"] = ERG_ALERT_TEXT,
  ["OnCastAlert"] = ERG_ALERT_CAST,
  ["OnBannerAlert"] = ERG_ALERT_BANNER,
}

function ERG.GetNotificationDesignationList()
  return notificationDesignationList
end


local welcomeMessageList = {
    ERG_WELCOME_1,
    ERG_WELCOME_2,
    ERG_WELCOME_3,
}

function ERG.GetWelcomeMessageList()
  return welcomeMessageList
end

local npcChannelList = {
  CHAT_CHANNEL_MONSTER_EMOTE,
  CHAT_CHANNEL_MONSTER_SAY,
  CHAT_CHANNEL_MONSTER_WHISPER,
  CHAT_CHANNEL_MONSTER_YELL,
}

function ERG.GetNPCChannelList()
  return npcChannelList
end

local behemothSubtitleList = {
  ERG_SUBTITLE_BEHEMOTH_1,
  ERG_SUBTITLE_BEHEMOTH_2,
  ERG_SUBTITLE_BEHEMOTH_3,
  ERG_SUBTITLE_BEHEMOTH_4,
}

function ERG.GetBehemothSubtitleList()
  return behemothSubtitleList
end

local xalvakkaStairsSubtitleList = {
  ERG_SUBTITLE_XALVAKKA_STAIRS_1,
  ERG_SUBTITLE_XALVAKKA_STAIRS_2
}

function ERG.GetXalvakkaStairsSubtitleList()
  return xalvakkaStairsSubtitleList
end


local eventParameterNames = {
  [EVENT_COMBAT_EVENT] = {
    --"event" = 1,
    --"result" = 2,
    --"isError" = 3,
    --"abilityName" = 4,
    --"abilityGraphic" = 5,
    --"abilityActionSlotType" = 6,
    --"sourceName" = 7,
    --"sourceType" = 8,
    --"targetName" = 9,
    ["targetType"] = 10,
    --"hitValue" = 11,
    --"powerType" = 12,
    --"damageType" = 13,
    --"log" = 14,
    ["sourceUnitId"] = 15,
    --"targetUnitId" = 16,
    ["abilityId"] = 17,
    --"overflow" = 18,
 },
  [EVENT_EFFECT_CHANGED] = {
    --"event" = 1
    ["changeType"] = 2,
    --"effectSlot" = 3,
    --"effectName" = 4,
    ["unitTag"] = 5,
    --"beginTime" = 6,
    --"endTime" = 7,
    --"stackCount" = 8,
    --"iconName" = 9,
    --"buffType" = 10,
    --"effectType" = 11,
    --"abilityType" = 12,
    --"statusEffectType" = 13,
    --"unitName" = 14,
    --"unitId" = 15,
    --"abilityId" = 16,
    --"sourceType" = 17,
  },
}

function ERG.GetEventParameterNames( event )
  return eventParameterNames[event]
end
