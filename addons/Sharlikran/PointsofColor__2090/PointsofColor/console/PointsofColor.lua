poc = {}
poc.appName = "PointsofColor"
poc.version = "2.65"

----------------------------------------
-- Declarations
----------------------------------------
local SAVEDVARIABLES_VERSION = 3
local eso_root = "esoui/art/"
local ui_root = "PointsofColor/"

local poi_textures_complete = {
  { "poi_areaofinterest_complete.dds", 64 },
  { "poi_ayleidruin_complete.dds", 64 },
  { "poi_ayliedruin_complete.dds", 64 },
  { "poi_battlefield_complete.dds", 64 },
  { "poi_camp_complete.dds", 64 },
  { "poi_cave_complete.dds", 64 },
  { "poi_cemetary_complete.dds", 64 },
  { "poi_cemetery_complete.dds", 64 },
  { "poi_city_complete.dds", 64 },
  { "poi_crafting_complete.dds", 64 },
  { "poi_crypt_complete.dds", 64 },
  { "poi_daedricruin_complete.dds", 64 },
  { "poi_darkbrotherhood_complete.dds", 64 },
  { "poi_delve_complete.dds", 64 },
  { "poi_dock_complete.dds", 64 },
  { "poi_dungeon_complete.dds", 64 },
  { "poi_dwemerruin_complete.dds", 64 },
  { "poi_estate_complete.dds", 64 },
  { "poi_explorable_complete.dds", 64 },
  { "poi_farm_complete.dds", 64 },
  { "poi_gate_complete.dds", 64 },
  { "poi_groupboss_complete.dds", 64 },
  { "poi_groupdelve_complete.dds", 64 },
  { "poi_groupinstance_complete.dds", 64 },
  { "poi_group_areaofinterest_complete.dds", 64 },
  { "poi_group_ayliedruin_complete.dds", 64 },
  { "poi_group_battleground_complete.dds", 64 },
  { "poi_group_camp_complete.dds", 64 },
  { "poi_group_cave_complete.dds", 64 },
  { "poi_group_cemetery_complete.dds", 64 },
  { "poi_group_crypt_complete.dds", 64 },
  { "poi_group_dwemerruin_complete.dds", 64 },
  { "poi_group_estate_complete.dds", 64 },
  { "poi_group_gate_complete.dds", 64 },
  { "poi_group_house_owned.dds", 64 },
  { "poi_group_keep_complete.dds", 64 },
  { "poi_group_lighthouse_complete.dds", 64 },
  { "poi_group_mine_complete.dds", 64 },
  { "poi_group_ruin_complete.dds", 64 },
  { "poi_grove_complete.dds", 64 },
  { "poi_horserace_complete.dds", 64 },
  { "poi_icsewer_complete.dds", 64 },
  { "poi_ic_boneshard_complete.dds", 64 },
  { "poi_ic_daedricembers_complete.dds", 64 },
  { "poi_ic_daedricshackles_complete.dds", 64 },
  { "poi_ic_darkether_complete.dds", 64 },
  { "poi_ic_marklegion_complete.dds", 64 },
  { "poi_ic_monstrousteeth_complete.dds", 64 },
  { "poi_ic_planararmorscraps_complete.dds", 64 },
  { "poi_ic_tinyclaw_complete.dds", 64 },
  { "poi_keep_complete.dds", 64 },
  { "poi_lighthouse_complete.dds", 64 },
  { "poi_mine_compete.dds", 64 },
  { "poi_mine_complete.dds", 64 },
  { "poi_mundus_complete.dds", 64 },
  { "poi_mushromtower_complete.dds", 64 },
  { "poi_portal_complete.dds", 64 },
  { "poi_publicdungeon_complete.dds", 64 },
  { "poi_raiddungeon_complete.dds", 64 },
  { "poi_ruin_complete.dds", 64 },
  { "poi_sewer_complete.dds", 64 },
  { "poi_soloinstance_complete.dds", 64 },
  { "poi_solotrial_complete.dds", 64 },
  { "poi_tower_complete.dds", 64 },
  { "poi_town_complete.dds", 64 },
  { "poi_wayshrine_complete.dds", 64 },
  { "poi_wayshrine_oneway_complete.dds", 64 },
  { "poi_u26_nord_boat_pattern_complete.dds", 64 },
  { "poi_endlessdungeon_complete.dds", 64 },
  { "poi_group_portal_complete.dds", 64 },
  { "poi_u26_dwemergear_complete.dds", 64 },
  { "poi_u26_nord_boat_complete.dds", 64 },
}

local poi_textures_incomplete = {
  { "poi_areaofinterest_incomplete.dds", 64 },
  { "poi_ayleidruin_incomplete.dds", 64 },
  { "poi_ayliedruin_incomplete.dds", 64 },
  { "poi_battlefield_incomplete.dds", 64 },
  { "poi_camp_incomplete.dds", 64 },
  { "poi_cave_incomplete.dds", 64 },
  { "poi_cemetary_incomplete.dds", 64 },
  { "poi_cemetery_incomplete.dds", 64 },
  { "poi_city_incomplete.dds", 64 },
  { "poi_crafting_incomplete.dds", 64 },
  { "poi_crypt_incomplete.dds", 64 },
  { "poi_daedricruin_incomplete.dds", 64 },
  { "poi_darkbrotherhood_incomplete.dds", 64 },
  { "poi_delve_incomplete.dds", 64 },
  { "poi_dock_incomplete.dds", 64 },
  { "poi_dungeon_incomplete.dds", 64 },
  { "poi_dwemerruin_incomplete.dds", 64 },
  { "poi_estate_incomplete.dds", 64 },
  { "poi_explorable_incomplete.dds", 64 },
  { "poi_farm_incomplete.dds", 64 },
  { "poi_gate_incomplete.dds", 64 },
  { "poi_groupboss_incomplete.dds", 64 },
  { "poi_groupdelve_incomplete.dds", 64 },
  { "poi_groupinstance_incomplete.dds", 64 },
  { "poi_group_areaofinterest_incomplete.dds", 64 },
  { "poi_group_ayliedruin_incomplete.dds", 64 },
  { "poi_group_battleground_incomplete.dds", 64 },
  { "poi_group_camp_incomplete.dds", 64 },
  { "poi_group_cave_incomplete.dds", 64 },
  { "poi_group_cemetery_incomplete.dds", 64 },
  { "poi_group_crypt_incomplete.dds", 64 },
  { "poi_group_dwemerruin_incomplete.dds", 64 },
  { "poi_group_estate_incomplete.dds", 64 },
  { "poi_group_gate_incomplete.dds", 64 },
  { "poi_group_house_unowned.dds", 64 },
  { "poi_group_keep_incomplete.dds", 64 },
  { "poi_group_lighthouse_incomplete.dds", 64 },
  { "poi_group_mine_incomplete.dds", 64 },
  { "poi_group_ruin_incomplete.dds", 64 },
  { "poi_grove_incomplete.dds", 64 },
  { "poi_horserace_incomplete.dds", 64 },
  { "poi_icsewer_incomplete.dds", 64 },
  { "poi_ic_boneshard_incomplete.dds", 64 },
  { "poi_ic_daedricembers_incomplete.dds", 64 },
  { "poi_ic_daedricshackles_incomplete.dds", 64 },
  { "poi_ic_darkether_incomplete.dds", 64 },
  { "poi_ic_marklegion_incomplete.dds", 64 },
  { "poi_ic_monstrousteeth_incomplete.dds", 64 },
  { "poi_ic_planararmorscraps_incomplete.dds", 64 },
  { "poi_ic_tinyclaw_incomplete.dds", 64 },
  { "poi_keep_incomplete.dds", 64 },
  { "poi_lighthouse_incomplete.dds", 64 },
  { "poi_mine_incompete.dds", 64 },
  { "poi_mine_incomplete.dds", 64 },
  { "poi_mundus_incomplete.dds", 64 },
  { "poi_mushromtower_incomplete.dds", 64 },
  { "poi_portal_incomplete.dds", 64 },
  { "poi_publicdungeon_incomplete.dds", 64 },
  { "poi_raiddungeon_incomplete.dds", 64 },
  { "poi_ruin_incomplete.dds", 64 },
  { "poi_sewer_incomplete.dds", 64 },
  { "poi_soloinstance_incomplete.dds", 64 },
  { "poi_solotrial_incomplete.dds", 64 },
  { "poi_tower_incomplete.dds", 64 },
  { "poi_town_incomplete.dds", 64 },
  { "poi_wayshrine_incomplete.dds", 64 },
  { "poi_wayshrine_oneway_incomplete.dds", 64 },
  { "poi_endlessdungeon_incomplete.dds", 64 },
  { "poi_group_portal_incomplete.dds", 64 },
  { "poi_u26_dwemergear_incomplete.dds", 64 },
  { "poi_u26_nord_boat_incomplete.dds", 64 },
  { "poi_u26_nord_boat_pattern_incomplete.dds", 64 },
}

local service_textures = {
  { "ic_boneshard_complete.dds", 64 },
  { "ic_darkether_complete.dds", 64 },
  { "ic_marklegion_complete.dds", 64 },
  { "ic_monstrousteeth_complete.dds", 64 },
  { "ic_planararmorscraps_complete.dds", 64 },
  { "ic_tinyclaw_complete.dds", 64 },
  { "servicepin_alchemy.dds", 64 },
  { "servicepin_armory.dds", 64 },
  { "servicepin_bank.dds", 64 },
  { "servicepin_caravan.dds", 64 },
  { "servicepin_clothier.dds", 64 },
  { "servicepin_dock.dds", 64 },
  { "servicepin_dyestation.dds", 64 },
  { "servicepin_enchanting.dds", 64 },
  { "servicepin_event.dds", 64 },
  { "servicepin_fence.dds", 64 },
  { "servicepin_fightersguild.dds", 64 },
  { "servicepin_furnishings.dds", 64 },
  { "servicepin_guildkiosk.dds", 64 },
  { "servicepin_inn.dds", 64 },
  { "servicepin_jewelrycrafting.dds", 64 },
  { "servicepin_magesguild.dds", 64 },
  { "servicepin_museum.dds", 64 },
  { "servicepin_outfitstation.dds", 64 },
  { "servicepin_outfitter.dds", 64 },
  { "servicepin_respecaltar.dds", 64 },
  { "servicepin_shadowysupplier.dds", 64 },
  { "servicepin_smithy.dds", 64 },
  { "servicepin_stable.dds", 64 },
  { "servicepin_thievesguild.dds", 64 },
  { "servicepin_transmute.dds", 64 },
  { "servicepin_undaunted.dds", 64 },
  { "servicepin_vendor.dds", 64 },
  { "servicepin_woodworking.dds", 64 },
  { "servicepin_fargraveportal.dds", 64 },
  { "servicepin_talesoftribute.dds", 64 },
  { "servicepin_antiquities.dds", 64 },
}

local poi_glow_textures = {
  { "poi_cave_glow.dds", 64 },
  { "poi_darkbrotherhood_glow.dds", 64 },
  { "poi_delve_glow.dds", 64 },
  { "poi_dungeon_glow.dds", 64 },
  { "poi_endlessdungeon_glow.dds", 64 },
  { "poi_group_house_glow.dds", 64 },
  { "poi_groupdelve_glow.dds", 64 },
  { "poi_groupinstance_glow.dds", 64 },
  { "poi_publicdungeon_glow.dds", 64 },
  { "poi_raiddungeon_glow.dds", 64 },
  { "poi_ruin_glow.dds", 64 },
  { "poi_sewer_glow.dds", 64 },
  { "poi_soloinstance_glow.dds", 64 },
  { "poi_solotrial_glow.dds", 64 },
  { "poi_wayshrine_glow.dds", 64 },
}

local defaults = {
  show_poi_glow_textures = false,
  use_less_saturation_textures = false,
}

----------------------------------------
-- Functions
----------------------------------------
local function RedirectTextures(eso_folder, poc_folder, textures_table)
  local eso_textures_folder = eso_root .. eso_folder
  local poc_textures_folder = ui_root .. poc_folder
  for i = 1, #textures_table do
    RedirectTexture(eso_textures_folder .. textures_table[i][1], poc_textures_folder .. textures_table[i][1])
  end
end

local function NormalizeSavedVarsVersion(svTable)
  if not svTable or not svTable.Default then return end

  local displayName = GetDisplayName()
  local accountData = svTable.Default[displayName] and svTable.Default[displayName]["$AccountWide"]
  if not accountData then return end

  local rawVersion = accountData.version
  if rawVersion == nil then
    accountData.version = 2
    return
  end

  if rawVersion == SAVEDVARIABLES_VERSION then return end

  local isVersionEmptyString = rawVersion == ""
  local isVersionString = type(rawVersion) == "string"

  if isVersionEmptyString then
    accountData.version = 2
  elseif isVersionString then
    local major = tonumber(rawVersion:match("^(%d+)"))
    if major then
      accountData.version = math.floor(major)
    else
      accountData.version = 2
    end
  elseif type(rawVersion) ~= "number" then
    accountData.version = 2
  end
end

local function OnAddOnLoaded(eventCode, addOnName)
  if addOnName ~= poc.appName then
    return
  end

  NormalizeSavedVarsVersion(PointsofColor_SavedVariables)

  poc.SV = ZO_SavedVars:NewAccountWide("PointsofColor_SavedVariables", SAVEDVARIABLES_VERSION, nil, defaults)

  if poc.SV.use_less_saturation_textures then
    ui_root = ui_root .. "less_saturation/"
  else
    ui_root = ui_root .. "normal_textures/"
  end

  RedirectTextures("icons/poi/", "poi_textures/", poi_textures_complete)
  RedirectTextures("icons/poi/", "poi_textures/", poi_textures_incomplete)
  RedirectTextures("icons/servicemappins/", "service_textures/", service_textures)

  RedirectTexture(eso_root .. "icons/servicemappins/servicepin_buildstation.dds", ui_root .. "other_textures/mapkey_buildstation.dds")
  RedirectTexture(eso_root .. "icons/servicetooltipicons/gamepad/gp_servicetooltipicon_buildstation.dds", ui_root .. "other_textures/mapkey_buildstation.dds")

  RedirectTexture(eso_root .. "icons/worldeventunits/dragon_fly.dds", ui_root .. "other_textures/dragon_fly.dds")
  RedirectTexture(eso_root .. "icons/worldeventunits/dragon_fly_damaged.dds", ui_root .. "other_textures/dragon_fly_damaged.dds")
  RedirectTexture(eso_root .. "icons/worldeventunits/dragon_fly_combat_animated.dds", ui_root .. "other_textures/dragon_fly_combat_animated.dds")
  RedirectTexture(eso_root .. "icons/worldeventunits/dragon_fly_combat_damaged_animated.dds", ui_root .. "other_textures/dragon_fly_combat_damaged_animated.dds")

  RedirectTexture(eso_root .. "icons/mapkey/mapkey_buildstation.dds", ui_root .. "other_textures/mapkey_buildstation.dds")

  -- Tooltip Icons
  RedirectTexture(eso_root .. "icons/servicetooltipicons/servicetooltipicon_buildstation.dds", ui_root .. "other_textures/mapkey_buildstation_32.dds")

  -- Mapkeys
  RedirectTexture(eso_root .. "icons/mapkey/mapkey_alchemist.dds", ui_root .. "service_textures/servicepin_alchemy.dds")
  RedirectTexture(eso_root .. "icons/mapkey/mapkey_antiquities.dds", ui_root .. "service_textures/servicepin_antiquities.dds")
  RedirectTexture(eso_root .. "icons/mapkey/mapkey_areaofinterest.dds", ui_root .. "poi_textures/poi_areaofinterest_complete.dds")
  RedirectTexture(eso_root .. "icons/mapkey/mapkey_bank.dds", ui_root .. "service_textures/servicepin_bank.dds")
  RedirectTexture(eso_root .. "icons/mapkey/mapkey_buildstation.dds", ui_root .. "other_textures/mapkey_buildstation.dds")
  RedirectTexture(eso_root .. "icons/mapkey/mapkey_caravan.dds", ui_root .. "service_textures/servicepin_caravan.dds")
  RedirectTexture(eso_root .. "icons/mapkey/mapkey_clothier.dds", ui_root .. "service_textures/servicepin_clothier.dds")
  RedirectTexture(eso_root .. "icons/mapkey/mapkey_crafting.dds", ui_root .. "poi_textures/poi_crafting_complete.dds")
  RedirectTexture(eso_root .. "icons/mapkey/mapkey_darkbrotherhood.dds", ui_root .. "poi_textures/poi_darkbrotherhood_complete.dds")
  RedirectTexture(eso_root .. "icons/mapkey/mapkey_delve.dds", ui_root .. "poi_textures/poi_delve_complete.dds")
  RedirectTexture(eso_root .. "icons/mapkey/mapkey_dock.dds", ui_root .. "service_textures/servicepin_dock.dds")
  RedirectTexture(eso_root .. "icons/mapkey/mapkey_dungeon.dds", ui_root .. "poi_textures/poi_dungeon_complete.dds")
  RedirectTexture(eso_root .. "icons/mapkey/mapkey_dyestation.dds", ui_root .. "service_textures/servicepin_dyestation.dds")
  RedirectTexture(eso_root .. "icons/mapkey/mapkey_enchanter.dds", ui_root .. "service_textures/servicepin_enchanting.dds")
  RedirectTexture(eso_root .. "icons/mapkey/mapkey_endlessdungeon.dds", ui_root .. "poi_textures/poi_endlessdungeon_complete.dds")
  RedirectTexture(eso_root .. "icons/mapkey/mapkey_events.dds", ui_root .. "service_textures/servicepin_event.dds")
  RedirectTexture(eso_root .. "icons/mapkey/mapkey_fence.dds", ui_root .. "service_textures/servicepin_fence.dds")
  RedirectTexture(eso_root .. "icons/mapkey/mapkey_fightersguild.dds", ui_root .. "service_textures/servicepin_fightersguild.dds")
  RedirectTexture(eso_root .. "icons/mapkey/mapkey_furnishings.dds", ui_root .. "service_textures/servicepin_furnishings.dds")
  RedirectTexture(eso_root .. "icons/mapkey/mapkey_groupboss.dds", ui_root .. "poi_textures/poi_groupboss_complete.dds")
  RedirectTexture(eso_root .. "icons/mapkey/mapkey_groupdelve.dds", ui_root .. "poi_textures/poi_groupdelve_complete.dds")
  RedirectTexture(eso_root .. "icons/mapkey/mapkey_groupinstance.dds", ui_root .. "poi_textures/poi_groupinstance_complete.dds")
  RedirectTexture(eso_root .. "icons/mapkey/mapkey_guildkiosk.dds", ui_root .. "service_textures/servicepin_guildkiosk.dds")
  RedirectTexture(eso_root .. "icons/mapkey/mapkey_housing.dds", ui_root .. "poi_textures/poi_group_house_owned.dds")
  RedirectTexture(eso_root .. "icons/mapkey/mapkey_inn.dds", ui_root .. "service_textures/servicepin_inn.dds")
  RedirectTexture(eso_root .. "icons/mapkey/mapkey_jewelrycrafting.dds", ui_root .. "service_textures/servicepin_jewelrycrafting.dds")
  RedirectTexture(eso_root .. "icons/mapkey/mapkey_magesguild.dds", ui_root .. "service_textures/servicepin_magesguild.dds")
  RedirectTexture(eso_root .. "icons/mapkey/mapkey_mine.dds", ui_root .. "poi_textures/poi_mine_complete.dds")
  RedirectTexture(eso_root .. "icons/mapkey/mapkey_mundus.dds", ui_root .. "poi_textures/poi_mundus_complete.dds")
  RedirectTexture(eso_root .. "icons/mapkey/mapkey_outfitstation.dds", ui_root .. "service_textures/servicepin_outfitstation.dds")
  RedirectTexture(eso_root .. "icons/mapkey/mapkey_portal.dds", ui_root .. "poi_textures/poi_portal_complete.dds")
  RedirectTexture(eso_root .. "icons/mapkey/mapkey_raiddungeon.dds", ui_root .. "poi_textures/poi_raiddungeon_complete.dds")
  RedirectTexture(eso_root .. "icons/mapkey/mapkey_respecaltar.dds", ui_root .. "service_textures/servicepin_respecaltar.dds")
  RedirectTexture(eso_root .. "icons/mapkey/mapkey_skyshard_complete.dds", ui_root .. "other_textures/completiontypeicon_skyshard.dds")
  RedirectTexture(eso_root .. "icons/mapkey/mapkey_smithy.dds", ui_root .. "service_textures/servicepin_smithy.dds")
  RedirectTexture(eso_root .. "icons/mapkey/mapkey_soloinstance.dds", ui_root .. "poi_textures/poi_soloinstance_complete.dds")
  RedirectTexture(eso_root .. "icons/mapkey/mapkey_solotrial.dds", ui_root .. "poi_textures/poi_solotrial_complete.dds")
  RedirectTexture(eso_root .. "icons/mapkey/mapkey_stables.dds", ui_root .. "service_textures/servicepin_stable.dds")
  RedirectTexture(eso_root .. "icons/mapkey/mapkey_thievesguild.dds", ui_root .. "service_textures/servicepin_thievesguild.dds")
  RedirectTexture(eso_root .. "icons/mapkey/mapkey_undaunted.dds", ui_root .. "service_textures/servicepin_undaunted.dds")
  RedirectTexture(eso_root .. "icons/mapkey/mapkey_vendor.dds", ui_root .. "service_textures/servicepin_vendor.dds")
  RedirectTexture(eso_root .. "icons/mapkey/mapkey_wayshrine.dds", ui_root .. "poi_textures/poi_wayshrine_complete.dds")
  RedirectTexture(eso_root .. "icons/mapkey/mapkey_woodworker.dds", ui_root .. "service_textures/servicepin_woodworking.dds")

  -- Zone Story
  RedirectTexture(eso_root .. "zonestories/completiontypeicon_delve.dds", ui_root .. "poi_textures/poi_delve_complete.dds")
  RedirectTexture(eso_root .. "zonestories/completiontypeicon_groupboss.dds", ui_root .. "poi_textures/poi_groupboss_complete.dds")
  RedirectTexture(eso_root .. "zonestories/completiontypeicon_groupdelve.dds", ui_root .. "poi_textures/poi_groupdelve_complete.dds")
  RedirectTexture(eso_root .. "zonestories/completiontypeicon_lorebooks.dds", ui_root .. "other_textures/completiontypeicon_lorebooks.dds")
  RedirectTexture(eso_root .. "zonestories/completiontypeicon_mundusstone.dds", ui_root .. "poi_textures/poi_mundus_complete.dds")
  RedirectTexture(eso_root .. "zonestories/completiontypeicon_pointofinterest.dds", ui_root .. "other_textures/completiontypeicon_pointofinterest.dds")
  RedirectTexture(eso_root .. "zonestories/completiontypeicon_priorityquest.dds", ui_root .. "other_textures/completiontypeicon_priorityquest.dds")
  RedirectTexture(eso_root .. "zonestories/completiontypeicon_publicdungeon.dds", ui_root .. "poi_textures/poi_dungeon_complete.dds")
  RedirectTexture(eso_root .. "zonestories/completiontypeicon_setstation.dds", ui_root .. "poi_textures/poi_crafting_complete.dds")
  RedirectTexture(eso_root .. "zonestories/completiontypeicon_skyshard.dds", ui_root .. "other_textures/completiontypeicon_skyshard.dds")
  RedirectTexture(eso_root .. "zonestories/completiontypeicon_strikinglocales.dds", ui_root .. "poi_textures/poi_areaofinterest_complete.dds")
  RedirectTexture(eso_root .. "zonestories/completiontypeicon_wayshrine.dds", ui_root .. "poi_textures/poi_wayshrine_complete.dds")
  RedirectTexture(eso_root .. "zonestories/completiontypeicon_worldevents.dds", ui_root .. "poi_textures/poi_portal_complete.dds")

  if not poc.SV.show_poi_glow_textures then
    for i = 1, #poi_glow_textures do
      RedirectTexture(eso_root .. "icons/poi/" .. poi_glow_textures[i][1], ui_root .. "poc_textures/blank.dds")
    end
  end
end

----------------------------------------
-- Main
----------------------------------------
EVENT_MANAGER:RegisterForEvent(poc.appName, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
