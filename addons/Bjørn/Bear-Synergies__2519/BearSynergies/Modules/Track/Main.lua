BearSynergies.Track = {
  Default = {
    left = 0,
    top = 0,
    orientation = "Horizontal",
    size = 48,

    Synergies = {
      [1] = false, -- Shackle
      [2] = false, -- Ignite
      [3] = false, -- Grave Robber
      [4] = false, -- Pure Agony
      [5] = false, -- Hidden Refresh
      [6] = false, -- Soul Leech
      [7] = false, -- Charged Lightning
      [8] = false, -- Conduit
      [9] = false, -- Nova
      [10] = false, -- Purify
      [11] = false, -- Harvest
      [12] = false, -- Icy Escape
      [13] = false, -- Feeding Frenzy
      [14] = false, -- Blood Altar
      [15] = false, -- Spiders
      [16] = false, -- Radiate
      [17] = false, -- Bone Shield
      [18] = false, -- Orb & Shards
    },
  },
}

local icons = {
  [1] = {
    ready = "esoui/art/icons/ability_dragonknight_006.dds",
    cooldown = "BearSynergies/Modules/Track/Images/Standard.dds",
  },
  [2] = {
    ready = "esoui/art/icons/ability_dragonknight_010.dds",
    cooldown = "BearSynergies/Modules/Track/Images/Talons.dds",
  },
  [3] = {
    ready = "esoui/art/icons/ability_necromancer_004.dds",
    cooldown = "BearSynergies/Modules/Track/Images/Boneyard.dds",
  },
  [4] = {
    ready = "esoui/art/icons/ability_necromancer_010_b.dds",
    cooldown = "BearSynergies/Modules/Track/Images/Totem.dds",
  },
  [5] = {
    ready = "esoui/art/icons/ability_nightblade_015.dds",
    cooldown = "BearSynergies/Modules/Track/Images/Refresh.dds",
  },
  [6] = {
    ready = "esoui/art/icons/ability_nightblade_018.dds",
    cooldown = "BearSynergies/Modules/Track/Images/Leech.dds",
  },
  [7] = {
    ready = "esoui/art/icons/ability_sorcerer_storm_atronach.dds",
    cooldown = "BearSynergies/Modules/Track/Images/Atronach.dds",
  },
  [8] = {
    ready = "esoui/art/icons/ability_sorcerer_lightning_splash.dds",
    cooldown = "BearSynergies/Modules/Track/Images/Conduit.dds",
  },
  [9] = {
    ready = "esoui/art/icons/ability_templar_nova.dds",
    cooldown = "BearSynergies/Modules/Track/Images/Nova.dds",
  },
  [10] = {
    ready = "esoui/art/icons/ability_templar_cleansing_ritual.dds",
    cooldown = "BearSynergies/Modules/Track/Images/Ritual.dds",
  },
  [11] = {
    ready = "esoui/art/icons/ability_warden_007.dds",
    cooldown = "BearSynergies/Modules/Track/Images/Harvest.dds",
  },
  [12] = {
    ready = "esoui/art/icons/ability_warden_005_b.dds",
    cooldown = "BearSynergies/Modules/Track/Images/Escape.dds",
  },
  [13] = {
    ready = "esoui/art/icons/ability_werewolf_005_b.dds",
    cooldown = "BearSynergies/Modules/Track/Images/Howl.dds",
  },
  [14] = {
    ready = "esoui/art/icons/ability_undaunted_001.dds",
    cooldown = "BearSynergies/Modules/Track/Images/Altar.dds",
  },
  [15] = {
    ready = "esoui/art/icons/ability_undaunted_003.dds",
    cooldown = "BearSynergies/Modules/Track/Images/Spider.dds",
  },
  [16] = {
    ready = "esoui/art/icons/ability_undaunted_002.dds",
    cooldown = "BearSynergies/Modules/Track/Images/Radiate.dds",
  },
  [17] = {
    ready = "esoui/art/icons/ability_undaunted_005.dds",
    cooldown = "BearSynergies/Modules/Track/Images/Shield.dds",
  },
  [18] = {
    ready = "esoui/art/icons/ability_undaunted_004.dds",
    cooldown = "BearSynergies/Modules/Track/Images/Orb.dds",
  },
}

local BS = BearSynergies
local D = BS.Data
local T = BS.Track

local cooldownIconControl = nil
local cooldownTimerControl = nil

-- Creates the UI for each cooldown
local function CreateControls()
  for i, _ in ipairs(T.SavedVariables.Synergies) do
    WINDOW_MANAGER:CreateControlFromVirtual("$(parent)Cooldown", BearSynergiesTrackUI, "BearSynergiesTrackCooldown", i)
    BearSynergiesTrackUI:GetNamedChild("Cooldown" .. i .. "Icon"):SetTexture(icons[i].ready)
    BearSynergiesTrackUI:GetNamedChild("Cooldown" .. i .. "Icon"):SetDimensions(T.SavedVariables.size, T.SavedVariables.size)
    BearSynergiesTrackUI:GetNamedChild("Cooldown" .. i .. "Timer"):SetFont("$(GAMEPAD_MEDIUM_FONT)|" .. math.floor(T.SavedVariables.size / 2) .. "|thick-outline")
  end
end

-- Resize background
local function UpdateBackGround(counter)
  if counter > 0 and T.SavedVariables.orientation == "Horizontal" then
    BearSynergiesTrackUI:GetNamedChild("Texture"):SetHidden(false)
    BearSynergiesTrackUI:GetNamedChild("Texture"):SetDimensions(counter * (T.SavedVariables.size + math.floor(T.SavedVariables.size / 10)) + math.floor(T.SavedVariables.size / 10), T.SavedVariables.size + 2 * math.floor(T.SavedVariables.size / 10))
  elseif counter > 0 and T.SavedVariables.orientation == "Vertical" then
    BearSynergiesTrackUI:GetNamedChild("Texture"):SetHidden(false)
    BearSynergiesTrackUI:GetNamedChild("Texture"):SetDimensions(T.SavedVariables.size + 2 * math.floor(T.SavedVariables.size / 10), counter * (T.SavedVariables.size + math.floor(T.SavedVariables.size / 10)) + math.floor(T.SavedVariables.size / 10))
  else BearSynergiesTrackUI:GetNamedChild("Texture"):SetHidden(true) end
end

-- Resize icon and timer
local function UpdateIconSize()
  local cooldownControl = nil
  for i, _ in ipairs(T.SavedVariables.Synergies) do
    cooldownControl = BearSynergiesTrackUI:GetNamedChild("Cooldown" .. i)

    cooldownControl:GetNamedChild("Icon"):SetDimensions(T.SavedVariables.size, T.SavedVariables.size)
    cooldownControl:GetNamedChild("Timer"):SetFont("$(GAMEPAD_MEDIUM_FONT)|" .. math.floor(T.SavedVariables.size / 2) .. "|thick-outline")
  end
end

-- Hides UI for disabled synergies, unhides UI for enabled synergies and positions them
function T.UpdateUI()
  local counter = 0
  local cooldownControl = nil

  for i, v in ipairs(T.SavedVariables.Synergies) do
    cooldownControl = BearSynergiesTrackUI:GetNamedChild("Cooldown" .. i)

    if v and T.SavedVariables.orientation == "Horizontal" then
      cooldownControl:SetHidden(false)
      cooldownControl:ClearAnchors()
      cooldownControl:SetAnchor(TOPLEFT, BearSynergiesTrackUI, TOPLEFT, math.floor(T.SavedVariables.size / 10) + counter * (T.SavedVariables.size + math.floor(T.SavedVariables.size / 10)), math.floor(T.SavedVariables.size / 10))

      counter = counter + 1
    elseif v and T.SavedVariables.orientation == "Vertical" then
      cooldownControl:SetHidden(false)
      cooldownControl:ClearAnchors()
      cooldownControl:SetAnchor(TOPLEFT, BearSynergiesTrackUI, TOPLEFT, math.floor(T.SavedVariables.size / 10), math.floor(T.SavedVariables.size / 10) + counter * (T.SavedVariables.size + math.floor(T.SavedVariables.size / 10)))

      counter = counter + 1
    else cooldownControl:SetHidden(true) end
  end

  UpdateBackGround(counter)
  UpdateIconSize()
end

-- Updates the timer for synergies on cooldown
local function UpdateCooldown(abilityId)
  cooldownIconControl = BearSynergiesTrackUI:GetNamedChild("Cooldown" .. D[abilityId].trackingNumber .. "Icon")
  cooldownTimerControl = BearSynergiesTrackUI:GetNamedChild("Cooldown" .. D[abilityId].trackingNumber .. "Timer")

  if cooldownTimerControl:GetText() ~= "0.0" then cooldownTimerControl:SetText(string.format("%.1f", tonumber(cooldownTimerControl:GetText()) - 0.1 )) end

  if cooldownTimerControl:GetText() == "0.0" then
    cooldownIconControl:SetTexture(icons[D[abilityId].trackingNumber].ready)
    cooldownTimerControl:SetColor(0, 255, 0)
    EVENT_MANAGER:UnregisterForUpdate(BS.name .. "UpdateCooldown" .. D[abilityId].trackingNumber)
  end
end

-- Initiates cooldown for synergies
local function StartCooldown(_, result, _, abilityName, _, _, _, sourceType, _, targetType, _, _, _, _, _, _, abilityId)
  if sourceType == COMBAT_UNIT_TYPE_PLAYER or sourceType == COMBAT_UNIT_TYPE_GROUP then
    BearSynergiesTrackUI:GetNamedChild("Cooldown" .. D[abilityId].trackingNumber .. "Icon"):SetTexture(icons[D[abilityId].trackingNumber].cooldown)
    BearSynergiesTrackUI:GetNamedChild("Cooldown" .. D[abilityId].trackingNumber .. "Timer"):SetText("20")
    BearSynergiesTrackUI:GetNamedChild("Cooldown" .. D[abilityId].trackingNumber .. "Timer"):SetColor(255, 0, 0)
    EVENT_MANAGER:RegisterForUpdate(BS.name .. "UpdateCooldown" .. D[abilityId].trackingNumber, 100, function() UpdateCooldown(abilityId) end)
  end
end

-- Hides/unhides the UI when a menu is opened/closed
local function ToggleUI(_, newState)
  if newState == SCENE_SHOWN then
    BearSynergiesTrackUI:SetHidden(false)
  elseif newState == SCENE_HIDDEN then
    BearSynergiesTrackUI:SetHidden(true)
  end
end

local function RestorePosition()
  BearSynergiesTrackUI:ClearAnchors()
  BearSynergiesTrackUI:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, T.SavedVariables.left, T.SavedVariables.top)
end

function T.OnMoveStop()
  T.SavedVariables.left = BearSynergiesTrackUI:GetLeft()
  T.SavedVariables.top = BearSynergiesTrackUI:GetTop()
end

function T.Initialise()
  if BS.SavedVariables.isAccountWide then
    T.SavedVariables = ZO_SavedVars:NewAccountWide(BS.svName, BS.svVersion, "Track", T.Default)
  else
    T.SavedVariables = ZO_SavedVars:NewCharacterIdSettings(BS.svName, BS.svVersion, "Track", T.Default)
  end

  CreateControls()
  RestorePosition()
  T.UpdateUI()
  T.BuildMenu()

  SCENE_MANAGER:GetScene("hud"):RegisterCallback("StateChange", ToggleUI)
  SCENE_MANAGER:GetScene("hudui"):RegisterCallback("StateChange", ToggleUI)

  for k, v in pairs(D) do
    if v.trackingNumber then
      EVENT_MANAGER:RegisterForEvent(BS.name .. "Track" .. k, EVENT_COMBAT_EVENT, StartCooldown)
      EVENT_MANAGER:AddFilterForEvent(BS.name .. "Track" .. k, EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, k)
    end
  end
end