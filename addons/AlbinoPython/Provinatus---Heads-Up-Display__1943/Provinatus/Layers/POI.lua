ProvinatusPOI = ZO_Object:Subclass()

local function GetPOICheckBox(Name, Property)
  if Provinatus.SavedVars.POI[Property or Name] == nil then
    Provinatus.SavedVars.POI[Property or Name] = {}
    Provinatus.SavedVars.POI[Property or Name].Enabled = false
    Provinatus.SavedVars.POI[Property or Name].ShowDiscovered = false
  end

  local CheckBox = {
    type = "checkbox",
    name = Name,
    reference = "Provinatus_" .. (Property or Name), -- Prepending avoid reference collisions
    getFunc = function()
      return Provinatus.SavedVars.POI[Property or Name].Enabled
    end,
    setFunc = function(value)
      Provinatus.SavedVars.POI[Property or Name].Enabled = value
    end,
    width = "half",
    default = false
  }

  return CheckBox
end

local function GetShowDiscovered(Name, Property)
  local ShowDiscovered = {
    type = "checkbox",
    name = PROVINATUS_SHOW_DISCOVERED,
    getFunc = function()
      return Provinatus.SavedVars.POI[Property or Name].ShowDiscovered
    end,
    setFunc = function(value)
      Provinatus.SavedVars.POI[Property or Name].ShowDiscovered = value
    end,
    width = "half",
    default = false
  }

  return ShowDiscovered
end

local function DrawPOIMenuIcon(Control, Texture)
  local POIIcon = WINDOW_MANAGER:CreateControl(nil, Control, CT_TEXTURE)
  POIIcon:SetAnchor(CENTER, Control, CENTER, 0, 0)
  POIIcon:SetTexture(Texture)
  POIIcon:SetDimensions(30, 30)
  POIIcon:SetAlpha(1)
end

local function ControlsCreated(_)
  DrawPOIMenuIcon(Provinatus_AreaOfInterest, "/esoui/art/icons/poi/poi_areaofinterest_complete.dds")
  DrawPOIMenuIcon(Provinatus_AyleidRuin, "/esoui/art/icons/poi/poi_ayleidruin_complete.dds")
  DrawPOIMenuIcon(Provinatus_Battlefield, "/esoui/art/icons/poi/poi_battlefield_complete.dds")
  DrawPOIMenuIcon(Provinatus_BoneShard, "/esoui/art/icons/poi/poi_ic_boneshard_complete.dds")
  DrawPOIMenuIcon(Provinatus_Camp, "/esoui/art/icons/poi/poi_camp_complete.dds")
  DrawPOIMenuIcon(Provinatus_Cave, "/esoui/art/icons/poi/poi_cave_complete.dds")
  DrawPOIMenuIcon(Provinatus_Cemetary, "/esoui/art/icons/poi/poi_cemetery_complete.dds")
  DrawPOIMenuIcon(Provinatus_City, "/esoui/art/icons/poi/poi_city_complete.dds")
  DrawPOIMenuIcon(Provinatus_Crafting, "/esoui/art/icons/poi/poi_crafting_complete.dds")
  DrawPOIMenuIcon(Provinatus_Crypt, "/esoui/art/icons/poi/poi_crypt_complete.dds")
  DrawPOIMenuIcon(Provinatus_DaedricEmbers, "/esoui/art/icons/poi/poi_ic_daedricembers_complete.dds")
  DrawPOIMenuIcon(Provinatus_DaedricRuin, "/esoui/art/icons/poi/poi_daedricruin_complete.dds")
  DrawPOIMenuIcon(Provinatus_DaedricShackles, "/esoui/art/icons/poi/poi_ic_daedricshackles_complete.dds")
  DrawPOIMenuIcon(Provinatus_DarkBrotherhood, "/esoui/art/icons/poi/poi_darkbrotherhood_complete.dds")
  DrawPOIMenuIcon(Provinatus_DarkEther, "/esoui/art/icons/poi/poi_ic_darkether_complete.dds")
  DrawPOIMenuIcon(Provinatus_Delve, "/esoui/art/icons/poi/poi_delve_complete.dds")
  DrawPOIMenuIcon(Provinatus_Dock, "/esoui/art/icons/poi/poi_dock_complete.dds")
  DrawPOIMenuIcon(Provinatus_Dungeon, "/esoui/art/icons/poi/poi_dungeon_complete.dds")
  DrawPOIMenuIcon(Provinatus_DwemerRuin, "/esoui/art/icons/poi/poi_dwemerruin_complete.dds")
  DrawPOIMenuIcon(Provinatus_Estate, "/esoui/art/icons/poi/poi_estate_complete.dds")
  DrawPOIMenuIcon(Provinatus_Explorable, "/esoui/art/icons/poi/poi_explorable_complete.dds")
  DrawPOIMenuIcon(Provinatus_Farm, "/esoui/art/icons/poi/poi_farm_complete.dds")
  DrawPOIMenuIcon(Provinatus_Gate, "/esoui/art/icons/poi/poi_gate_complete.dds")
  DrawPOIMenuIcon(Provinatus_GroupBoss, "/esoui/art/icons/poi/poi_groupboss_complete.dds")
  DrawPOIMenuIcon(Provinatus_GroupDelve, "/esoui/art/icons/poi/poi_groupdelve_complete.dds")
  DrawPOIMenuIcon(Provinatus_GroupInstance, "/esoui/art/icons/poi/poi_groupinstance_complete.dds")
  DrawPOIMenuIcon(Provinatus_GroupAreaOfInterest, "/esoui/art/icons/poi/poi_group_areaofinterest_complete.dds")
  DrawPOIMenuIcon(Provinatus_GroupAyliedRuin, "/esoui/art/icons/poi/poi_group_ayliedruin_complete.dds")
  DrawPOIMenuIcon(Provinatus_GroupBattleground, "/esoui/art/icons/poi/poi_group_battleground_complete.dds")
  DrawPOIMenuIcon(Provinatus_GroupCamp, "/esoui/art/icons/poi/poi_group_camp_complete.dds")
  DrawPOIMenuIcon(Provinatus_GroupCave, "/esoui/art/icons/poi/poi_group_cave_complete.dds")
  DrawPOIMenuIcon(Provinatus_GroupCemetery, "/esoui/art/icons/poi/poi_group_cemetery_complete.dds")
  DrawPOIMenuIcon(Provinatus_GroupCrypt, "/esoui/art/icons/poi/poi_group_crypt_complete.dds")
  DrawPOIMenuIcon(Provinatus_GroupDwemerRuin, "/esoui/art/icons/poi/poi_group_dwemerruin_complete.dds")
  DrawPOIMenuIcon(Provinatus_GroupEstate, "/esoui/art/icons/poi/poi_group_estate_complete.dds")
  DrawPOIMenuIcon(Provinatus_GroupGate, "/esoui/art/icons/poi/poi_group_gate_complete.dds")
  DrawPOIMenuIcon(Provinatus_GroupHouse, "/esoui/art/icons/poi/poi_group_house_owned.dds")
  DrawPOIMenuIcon(Provinatus_GroupKeep, "/esoui/art/icons/poi/poi_group_keep_complete.dds")
  DrawPOIMenuIcon(Provinatus_GroupLighthouse, "/esoui/art/icons/poi/poi_group_lighthouse_complete.dds")
  DrawPOIMenuIcon(Provinatus_GroupMine, "/esoui/art/icons/poi/poi_group_mine_complete.dds")
  DrawPOIMenuIcon(Provinatus_GroupRuin, "/esoui/art/icons/poi/poi_group_ruin_complete.dds")
  DrawPOIMenuIcon(Provinatus_Grove, "/esoui/art/icons/poi/poi_grove_complete.dds")
  DrawPOIMenuIcon(Provinatus_ICSewer, "/esoui/art/icons/poi/poi_icsewer_complete.dds")
  DrawPOIMenuIcon(Provinatus_Keep, "/esoui/art/icons/poi/poi_keep_complete.dds")
  DrawPOIMenuIcon(Provinatus_Lighthouse, "/esoui/art/icons/poi/poi_lighthouse_complete.dds")
  DrawPOIMenuIcon(Provinatus_MarkLegion, "/esoui/art/icons/poi/poi_ic_marklegion_complete.dds")
  DrawPOIMenuIcon(Provinatus_Mine, "/esoui/art/icons/poi/poi_mine_complete.dds")
  DrawPOIMenuIcon(Provinatus_MonstrousTeeth, "/esoui/art/icons/poi/poi_ic_monstrousteeth_complete.dds")
  DrawPOIMenuIcon(Provinatus_Mundus, "/esoui/art/icons/poi/poi_mundus_complete.dds")
  DrawPOIMenuIcon(Provinatus_PlanarArmor, "/esoui/art/icons/poi/poi_ic_planararmorscraps_complete.dds")
  DrawPOIMenuIcon(Provinatus_Portal, "/esoui/art/icons/poi/poi_portal_complete.dds")
  DrawPOIMenuIcon(Provinatus_RaidDungeon, "/esoui/art/icons/poi/poi_raiddungeon_complete.dds")
  DrawPOIMenuIcon(Provinatus_Ruin, "/esoui/art/icons/poi/poi_ruin_complete.dds")
  DrawPOIMenuIcon(Provinatus_Sewer, "/esoui/art/icons/poi/poi_sewer_complete.dds")
  DrawPOIMenuIcon(Provinatus_SoloInstance, "/esoui/art/icons/poi/poi_soloinstance_complete.dds")
  DrawPOIMenuIcon(Provinatus_SoloTrial, "/esoui/art/icons/poi/poi_solotrial_complete.dds")
  DrawPOIMenuIcon(Provinatus_TinyClaw, "/esoui/art/icons/poi/poi_ic_tinyclaw_complete.dds")
  DrawPOIMenuIcon(Provinatus_Tower, "/esoui/art/icons/poi/poi_tower_complete.dds")
  DrawPOIMenuIcon(Provinatus_Town, "/esoui/art/icons/poi/poi_town_complete.dds")
  DrawPOIMenuIcon(Provinatus_Wayshrine, "/esoui/art/icons/poi/poi_wayshrine_complete.dds")
end

function ProvinatusPOI:Update()
  local zoneIndex = GetCurrentMapZoneIndex()
  local Destinations = {}
  if not IsUnitInDungeon("player") then
    for poiIndex = 1, GetNumPOIs(zoneIndex) do
      local normalizedX,
        normalizedY,
        poiType,
        icon,
        isShownInCurrentMap,
        linkedCollectibleIsLocked,
        isDiscovered,
        isNearby = GetPOIMapInfo(zoneIndex, poiIndex)
      local POIType = ProvinatusPOIMapping[icon]
      if
        POIType and Provinatus.SavedVars.POI[POIType] and
          Provinatus.SavedVars.POI[POIType].Enabled and
          (not isDiscovered or Provinatus.SavedVars.POI[POIType].ShowDiscovered) and
          isShownInCurrentMap
       then
        table.insert(
          Destinations,
          {
            X = normalizedX,
            Y = normalizedY,
            Alpha = Provinatus.SavedVars.POI.Alpha,
            Width = Provinatus.SavedVars.POI.Size,
            Height = Provinatus.SavedVars.POI.Size,
            Texture = icon
          }
        )
      end
    end
  end

  Provinatus:DrawElements(self, Destinations)
end

function ProvinatusPOI:GetMenu()
  local Menu = {
    type = "submenu",
    name = PROVINATUS_POI,
    reference = "ProvinatusPOIMenu",
    icon = "/esoui/art/icons/poi/poi_areaofinterest_complete.dds",
    controls = {
      {
        type = "slider",
        name = PROVINATUS_ICON_SIZE,
        getFunc = function()
          return Provinatus.SavedVars.POI.Size
        end,
        setFunc = function(value)
          Provinatus.SavedVars.POI.Size = value
        end,
        min = 20,
        max = 150,
        step = 1,
        clampInput = true,
        decimals = 0,
        autoSelect = true,
        inputLocation = "below",
        tooltip = PROVINATUS_ICON_SIZE_TT,
        width = "half",
        default = ProvinatusConfig.POI.Size
      },
      {
        type = "slider",
        name = PROVINATUS_TRANSPARENCY,
        getFunc = function()
          return Provinatus.SavedVars.POI.Alpha * 100
        end,
        setFunc = function(value)
          Provinatus.SavedVars.POI.Alpha = value / 100
        end,
        min = 0,
        max = 100,
        step = 1,
        clampInput = true,
        decimals = 0,
        autoSelect = true,
        inputLocation = "below",
        tooltip = PROVINATUS_TRANSPARENCY_TT,
        width = "half",
        default = ProvinatusConfig.POI.Alpha * 100
      },
      GetPOICheckBox(GetString(PROVINATUS_PORTAL), "Portal"),
      GetShowDiscovered(GetString(PROVINATUS_PORTAL), "Portal"),
      GetPOICheckBox(GetString(PROVINATUS_DELVE), "Delve"),
      GetShowDiscovered(GetString(PROVINATUS_DELVE), "Delve"),
      GetPOICheckBox(GetString(PROVINATUS_EXPLORABLE), "Explorable"),
      GetShowDiscovered(GetString(PROVINATUS_EXPLORABLE), "Explorable"),
      GetPOICheckBox(GetString(PROVINATUS_GROUP_BOSS), "GroupBoss"),
      GetShowDiscovered(GetString(PROVINATUS_GROUP_BOSS), "GroupBoss"),
      GetPOICheckBox(GetString(PROVINATUS_WAYSHRINE), "Wayshrine"),
      GetShowDiscovered(GetString(PROVINATUS_WAYSHRINE), "Wayshrine"),
      {
        type = "submenu",
        name = PROVINATUS_POI_WORLD,
        controls = {
          GetPOICheckBox(GetString(PROVINATUS_AREA_OF_INTEREST), "AreaOfInterest"),
          GetShowDiscovered(GetString(PROVINATUS_AREA_OF_INTEREST), "AreaOfInterest"),
          GetPOICheckBox(GetString(PROVINATUS_AYLEID_RUIN), "AyleidRuin"),
          GetShowDiscovered(GetString(PROVINATUS_AYLEID_RUIN), "AyleidRuin"),
          GetPOICheckBox(GetString(PROVINATUS_BATTLEFIELD), "Battlefield"),
          GetShowDiscovered(GetString(PROVINATUS_BATTLEFIELD), "Battlefield"),
          GetPOICheckBox(GetString(PROVINATUS_CAMP), "Camp"),
          GetShowDiscovered(GetString(PROVINATUS_CAMP), "Camp"),
          GetPOICheckBox(GetString(PROVINATUS_CAVE), "Cave"),
          GetShowDiscovered(GetString(PROVINATUS_CAVE), "Cave"),
          GetPOICheckBox(GetString(PROVINATUS_CEMETARY), "Cemetary"),
          GetShowDiscovered(GetString(PROVINATUS_CEMETARY), "Cemetary"),
          GetPOICheckBox(GetString(PROVINATUS_CITY), "City"),
          GetShowDiscovered(GetString(PROVINATUS_CITY), "City"),
          GetPOICheckBox(GetString(PROVINATUS_CRAFTING), "Crafting"),
          GetShowDiscovered(GetString(PROVINATUS_CRAFTING), "Crafting"),
          GetPOICheckBox(GetString(PROVINATUS_CRYPT), "Crypt"),
          GetShowDiscovered(GetString(PROVINATUS_CRYPT), "Crypt"),
          GetPOICheckBox(GetString(PROVINATUS_DAEDRIC_RUIN), "DaedricRuin"),
          GetShowDiscovered(GetString(PROVINATUS_DAEDRIC_RUIN), "DaedricRuin"),
          GetPOICheckBox(GetString(PROVINATUS_DARK_BROTHERHOOK), "DarkBrotherhood"),
          GetShowDiscovered(GetString(PROVINATUS_DARK_BROTHERHOOK), "DarkBrotherhood"),
          GetPOICheckBox(GetString(PROVINATUS_DOCK), "Dock"),
          GetShowDiscovered(GetString(PROVINATUS_DOCK), "Dock"),
          GetPOICheckBox(GetString(PROVINATUS_DUNGEON), "Dungeon"),
          GetShowDiscovered(GetString(PROVINATUS_DUNGEON), "Dungeon"),
          GetPOICheckBox(GetString(PROVINATUS_DWEMER_RUIN), "DwemerRuin"),
          GetShowDiscovered(GetString(PROVINATUS_DWEMER_RUIN), "DwemerRuin"),
          GetPOICheckBox(GetString(PROVINATUS_ESTATE), "Estate"),
          GetShowDiscovered(GetString(PROVINATUS_ESTATE), "Estate"),
          GetPOICheckBox(GetString(PROVINATUS_FARM), "Farm"),
          GetShowDiscovered(GetString(PROVINATUS_FARM), "Farm"),
          GetPOICheckBox(GetString(PROVINATUS_GATE), "Gate"),
          GetShowDiscovered(GetString(PROVINATUS_GATE), "Gate"),
          GetPOICheckBox(GetString(PROVINATUS_GROVE), "Grove"),
          GetShowDiscovered(GetString(PROVINATUS_GROVE), "Grove"),
          GetPOICheckBox(GetString(PROVINATUS_KEEP), "Keep"),
          GetShowDiscovered(GetString(PROVINATUS_KEEP), "Keep"),
          GetPOICheckBox(GetString(PROVINATUS_LIGHTHOUSE), "Lighthouse"),
          GetShowDiscovered(GetString(PROVINATUS_LIGHTHOUSE), "Lighthouse"),
          GetPOICheckBox(GetString(PROVINATUS_MINE), "Mine"),
          GetShowDiscovered(GetString(PROVINATUS_MINE), "Mine"),
          GetPOICheckBox(GetString(PROVINATUS_MUNDUS_STONE), "Mundus"),
          GetShowDiscovered(GetString(PROVINATUS_MUNDUS_STONE), "Mundus"),
          GetPOICheckBox(GetString(PROVINATUS_RUIN), "Ruin"),
          GetShowDiscovered(GetString(PROVINATUS_RUIN), "Ruin"),
          GetPOICheckBox(GetString(PROVINATUS_SEWER), "Sewer"),
          GetShowDiscovered(GetString(PROVINATUS_SEWER), "Sewer"),
          GetPOICheckBox(GetString(PROVINATUS_SOLO_INSTANCE), "SoloInstance"),
          GetShowDiscovered(GetString(PROVINATUS_SOLO_INSTANCE), "SoloInstance"),
          GetPOICheckBox(GetString(PROVINATUS_SOLO_TRIAL), "SoloTrial"),
          GetShowDiscovered(GetString(PROVINATUS_SOLO_TRIAL), "SoloTrial"),
          GetPOICheckBox(GetString(PROVINATUS_TOWER), "Tower"),
          GetShowDiscovered(GetString(PROVINATUS_TOWER), "Tower"),
          GetPOICheckBox(GetString(PROVINATUS_TOWN), "Town"),
          GetShowDiscovered(GetString(PROVINATUS_TOWN), "Town")
        }
      },
      {
        type = "submenu",
        name = PROVINATUS_GROUP_POI,
        controls = {
          GetPOICheckBox(GetString(PROVINATUS_GROUP_AREA_OF_INTEREST), "GroupAreaOfInterest"),
          GetShowDiscovered(GetString(PROVINATUS_GROUP_AREA_OF_INTEREST), "GroupAreaOfInterest"),
          GetPOICheckBox(GetString(PROVINATUS_GROUP_AYLEID_RUIN), "GroupAyliedRuin"),
          GetShowDiscovered(GetString(PROVINATUS_GROUP_AYLEID_RUIN), "GroupAyliedRuin"),
          GetPOICheckBox(GetString(PROVINATUS_GROUP_BATTLEGROUND), "GroupBattleground"),
          GetShowDiscovered(GetString(PROVINATUS_GROUP_BATTLEGROUND), "GroupBattleground"),
          GetPOICheckBox(GetString(PROVINATUS_GROUP_CAMP), "GroupCamp"),
          GetShowDiscovered(GetString(PROVINATUS_GROUP_CAMP), "GroupCamp"),
          GetPOICheckBox(GetString(PROVINATUS_GROUP_CAVE), "GroupCave"),
          GetShowDiscovered(GetString(PROVINATUS_GROUP_CAVE), "GroupCave"),
          GetPOICheckBox(GetString(PROVINATUS_GROUP_CEMETARY), "GroupCemetery"),
          GetShowDiscovered(GetString(PROVINATUS_GROUP_CEMETARY), "GroupCemetery"),
          GetPOICheckBox(GetString(PROVINATUS_GROUP_CRYPT), "GroupCrypt"),
          GetShowDiscovered(GetString(PROVINATUS_GROUP_CRYPT), "GroupCrypt"),
          GetPOICheckBox(GetString(PROVINATUS_GROUP_DELVE), "GroupDelve"),
          GetShowDiscovered(GetString(PROVINATUS_GROUP_DELVE), "GroupDelve"),
          GetPOICheckBox(GetString(PROVINATUS_GROUP_DWEMER_RUIN), "GroupDwemerRuin"),
          GetShowDiscovered(GetString(PROVINATUS_GROUP_DWEMER_RUIN), "GroupDwemerRuin"),
          GetPOICheckBox(GetString(PROVINATUS_GROUP_ESTATE), "GroupEstate"),
          GetShowDiscovered(GetString(PROVINATUS_GROUP_ESTATE), "GroupEstate"),
          GetPOICheckBox(GetString(PROVINATUS_GROUP_GATE), "GroupGate"),
          GetShowDiscovered(GetString(PROVINATUS_GROUP_GATE), "GroupGate"),
          GetPOICheckBox(GetString(PROVINATUS_GROUP_HOUSE), "GroupHouse"),
          GetShowDiscovered(GetString(PROVINATUS_GROUP_HOUSE), "GroupHouse"),
          GetPOICheckBox(GetString(PROVINATUS_GROUP_KEEP), "GroupKeep"),
          GetShowDiscovered(GetString(PROVINATUS_GROUP_KEEP), "GroupKeep"),
          GetPOICheckBox(GetString(PROVINATUS_GROUP_INSTANCE), "GroupInstance"),
          GetShowDiscovered(GetString(PROVINATUS_GROUP_INSTANCE), "GroupInstance"),
          GetPOICheckBox(GetString(PROVINATUS_GROUP_LIGHTHOUSE), "GroupLighthouse"),
          GetShowDiscovered(GetString(PROVINATUS_GROUP_LIGHTHOUSE), "GroupLighthouse"),
          GetPOICheckBox(GetString(PROVINATUS_GROUP_MINE), "GroupMine"),
          GetShowDiscovered(GetString(PROVINATUS_GROUP_MINE), "GroupMine"),
          GetPOICheckBox(GetString(PROVINATUS_GROUP_RUIN), "GroupRuin"),
          GetShowDiscovered(GetString(PROVINATUS_GROUP_RUIN), "GroupRuin"),
          GetPOICheckBox(GetString(PROVINATUS_RAID_DUNGEON), "RaidDungeon"),
          GetShowDiscovered(GetString(PROVINATUS_RAID_DUNGEON), "RaidDungeon")
        }
      },
      {
        type = "submenu",
        name = PROVINATUS_IMPERIAL_CITY,
        controls = {
          GetPOICheckBox(GetString(PROVINATUS_IC_SEWER), "ICSewer"),
          GetShowDiscovered(GetString(PROVINATUS_IC_SEWER), "ICSewer"),
          GetPOICheckBox(GetString(PROVINATUS_BONESHARD), "BoneShard"),
          GetShowDiscovered(GetString(PROVINATUS_BONESHARD), "BoneShard"),
          GetPOICheckBox(GetString(PROVINATUS_DAEDRIC_EMBERS), "DaedricEmbers"),
          GetShowDiscovered(GetString(PROVINATUS_DAEDRIC_EMBERS), "DaedricEmbers"),
          GetPOICheckBox(GetString(PROVINATUS_DAEDRIC_SHACKLES), "DaedricShackles"),
          GetShowDiscovered(GetString(PROVINATUS_DAEDRIC_SHACKLES), "DaedricShackles"),
          GetPOICheckBox(GetString(PROVINATUS_DARK_ETHER), "DarkEther"),
          GetShowDiscovered(GetString(PROVINATUS_DARK_ETHER), "DarkEther"),
          GetPOICheckBox(GetString(PROVINATUS_MARK_LEGION), "MarkLegion"),
          GetShowDiscovered(GetString(PROVINATUS_MARK_LEGION), "MarkLegion"),
          GetPOICheckBox(GetString(PROVINATUS_MONSTROUS_TEETH), "MonstrousTeeth"),
          GetShowDiscovered(GetString(PROVINATUS_MONSTROUS_TEETH), "MonstrousTeeth"),
          GetPOICheckBox(GetString(PROVINATUS_PLANAR_ARMOR), "PlanarArmor"),
          GetShowDiscovered(GetString(PROVINATUS_PLANAR_ARMOR), "PlanarArmor"),
          GetPOICheckBox(GetString(PROVINATUS_TINY_CLAW), "TinyClaw"),
          GetShowDiscovered(GetString(PROVINATUS_TINY_CLAW), "TinyClaw")
        }
      }
    }
  }

  return Menu
end

function ProvinatusPOI:SetMenuIcon()
  ControlsCreated()
end
