BearSynergies.Block = {
  Default = {
    isLokke = false,
    isAlkosh = false,
    isResource = false,
    resourceThreshold = 50,
    blockDO = true,

    [67717] = true, -- Shackle
    [32974] = true, -- Ignite
    [115567] = true, -- Grave Robber
    [118610] = true, -- Pure Agony
    [37729] = true, -- Hidden Refresh
    [25170] = true, -- Soul Leech
    [121059] = true, -- Charged Lightning
    [43769] = true, -- Conduit
    [94973] = true, -- Blessed Shards
    [95928] = true, -- Holy Shards
    [48939] = true, -- Supernova
    [31603] = true, -- Gravity Crush
    [22270] = true, -- Purify
    [85572] = true, -- Harvest
    [88892] = true, -- Icy Escape
    [58813] = true, -- Feeding Frenzy
    [39519] = true, -- Blood Funnel
    [41966] = true, -- Blood Feast
    [39451] = true, -- Spawn Broodling
    [41997] = true, -- Black Widow
    [42019] = true, -- Arachnophobia
    [41838] = true, -- Radiate
    [39379] = true, -- Bone Wall
    [42198] = true, -- Spinal Surge
    [39301] = true, -- Combustion
    [63507] = true, -- Healing Combustion
    [71951] = true, -- Sigil of Defense
    [71953] = true, -- Sigil of Haste
    [71949] = true, -- Sigil of Healing
    [71902] = true, -- Sigil of Power
    [112909] = true, -- Sigil of Resurrection
    [112872] = true, -- Sigil of Sustain
    [56667] = true, -- Destructive Outbreak
    -- [] = true, -- Remove Bolt
    -- [] = true, -- Celestial Purge
    -- [] = true, -- Levitate
    -- [] = true, -- Power Switch
    [103489] = true, -- Gateway
    -- [] = true, -- Malevolent Core
    -- [] = true, -- Shed Hoarfrost
    [104036] = true, -- Welkynar's Light
    [104111] = true, -- Wind of the Welkynar
    -- [] = true, -- Time Breach
  },
}

local BS = BearSynergies
local B = BS.Block

local imperfLokke = "|H1:item:149795:370:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"
local perfLokke = "|H1:item:150996:370:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"
local alkosh = "|H1:item:73058:370:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"

-- Checks whether or not Tooth of Lokkestiiz is equipped.
local function GetLokke()
  if B.SavedVariables.isLokke == false then return true end

  local imperfEquipped, perfEquipped = 0
  local _, _, _, imperfEquipped = GetItemLinkSetInfo(imperfLokke, true)
  local _, _, _, perfEquipped = GetItemLinkSetInfo(perfLokke, true)

  -- If Lokke Mode is enabled but no Lokke pieces are equipped don't block synergies
  if (imperfEquipped == 0) and (perfEquipped == 0) then return true end
  if (imperfEquipped == 5) or (perfEquipped == 5) then return true
  else return false end
end

-- Checks whether or not Roar of Alkosh is equipped.
local function GetAlkosh()
  if B.SavedVariables.isAlkosh == false then return true end

  local alkoshEquipped = 0
  local _, _, _, alkoshEquipped = GetItemLinkSetInfo(alkosh, true)

  -- If Alkosh Mode is enabled but no Alkosh pieces are equipped don't block synergies
  if alkoshEquipped == 0 then return true end
  if alkoshEquipped == 5 then return true 
  else return false end
end

-- Checks resource percentage and compares with defined options value
local function IsResourceLow()
  if B.SavedVariables.isResource == false then return true end

  local stamCurrent, stamMax = GetUnitPower("player", POWERTYPE_STAMINA)
  local magCurrent, magMax = GetUnitPower("player", POWERTYPE_MAGICKA)
  local percentage = 100

  if stamMax > magMax then
    percentage = stamCurrent / stamMax * 100
  else
    percentage = magCurrent / magMax * 100
  end

  if percentage <= B.SavedVariables.resourceThreshold then return true
  else return false end
end

-- This function runs before synergy prompt on-screen and determines whether or not the prompt appears
-- If the intercept function returns true the target function won't run
local function Intercept()
  local synergyName, iconFilename = GetSynergyInfo()
  local synergyId = BS.GetSynergyId(synergyName)

  if synergyName and iconFilename then
    if B.SavedVariables[synergyId] ~= nil then
      if B.SavedVariables[synergyId] == false then return true end
    else return false end -- Always allow unknown synergy

    if B.SavedVariables.blockDO and synergyId == 56667 then
      LibDialog:ShowDialog(BS.name .. "DODialog", "DOConfirmation")
      return false
    end

    if not GetLokke() then SHARED_INFORMATION_AREA:SetHidden(SYNERGY, true) return true end
    if not GetAlkosh() then SHARED_INFORMATION_AREA:SetHidden(SYNERGY, true) return true end
    if not IsResourceLow() then SHARED_INFORMATION_AREA:SetHidden(SYNERGY, true) return true end
  end
end

local function BarswapRefresh(_, didBarswap)
  if didBarswap then SYNERGY:OnSynergyAbilityChanged() end
end

function B.Initialise()
  if BS.SavedVariables.isAccountWide then
    B.SavedVariables = ZO_SavedVars:NewAccountWide(BS.svName, BS.svVersion, "Block", B.Default)
  else
    B.SavedVariables = ZO_SavedVars:NewCharacterIdSettings(BS.svName, BS.svVersion, "Block", B.Default)
  end

  -- Confirmation dialog for Destructive Outbreak
  LibDialog:RegisterDialog(BS.name .. "DODialog", "DOConfirmation", "|cFF0000Warning!|r", "Destructive Outbreak can kill the group! Press Confirm to continue.")

  ZO_PreHook(SYNERGY, "OnSynergyAbilityChanged", Intercept)
  B.BuildMenu()

  EVENT_MANAGER:RegisterForEvent(BS.name .. "Block", EVENT_ACTION_SLOTS_ACTIVE_HOTBAR_UPDATED, BarswapRefresh)
end