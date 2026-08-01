tralceCollectibles = {
  name = "tralceCollectibles",

  collectibles = {
    -- Tools --
    [  336] = "Tool_FinvirsTrinket",
    [  341] = "Tool_AlmalexiasEnchantedLantern",
    [ 8006] = "Tool_AntiquariansEye",
    [ 8883] = "Tool_RelicOfTheSentinel",
    [11083] = "Tool_CartMap",
    [12269] = "Tool_EyeOfInfinite",
    -- Assistants --
    [  267] = "Asst_TythisAndromo",
    [  300] = "Asst_Pirharri",
    [  301] = "Asst_Nuzimeh",
    [ 6376] = "Asst_Ezabi",
    [ 6378] = "Asst_Fezez",
    [ 8994] = "Asst_BaronJangleplume",
    [ 8995] = "Asst_PeddlerOfPrizes",
    [ 9245] = "Comp_BastianHallix",
    [ 9353] = "Comp_MirriElendis",
    [ 9743] = "Asst_FactotumPropertySteward",
    [ 9744] = "Asst_FactotumCommerceDelegate",
    [ 9745] = "Asst_Ghrashorog",
    [ 9911] = "Comp_Ember",
    [ 9912] = "Comp_IsobelVeloise",
    [10184] = "Asst_Giladil_the_Ragpicker",
    [10617] = "Asst_Aderene",
    [10618] = "Asst_Zuqoth",
    [11059] = "Asst_Hoarfrost",
    [11097] = "Asst_Pyroclast",
    [11113] = "Comp_SharpAsNight",
    [11114] = "Comp_Azandar",
    [11876] = "Asst_Drinweth",
    [11877] = "Asst_Tzoz",
    [12172] = "Comp_Tanlorin",
    [12173] = "Comp_Zerithvar",
    [12413] = "Asst_Eri",
    [12414] = "Asst_Xyn",
    [13063] = "Asst_Siluruz",
    -- Throwables --
    [  601] = "Thro_MudBallPouch",
    [ 1108] = "Thro_CherryBlossomBranch",
    [ 6932] = "Thro_EverlastingSnowball",
    [ 1385] = "Thro_MurderousStrike",
    -- Misc --
    [ 5889] = "Meme_PrismaticBannerRibbon",
  }
}

-- Force multi-key bindings. Shamelessly stolen from EssentialHousingTools.
if not KEYBINDING_MANAGER.IsChordingAlwaysEnabled or not KEYBINDING_MANAGER:IsChordingAlwaysEnabled() then
  function KEYBINDING_MANAGER:IsChordingAlwaysEnabled()
    return true
  end
end

local function OnAddOnLoaded( eventCode, addonName )
  if (addonName ~= tralceCollectibles.name) then return end

  ZO_CreateStringId("SI_BINDING_NAME_trC_Mount_Player", "Mount Group Member")
  ZO_CreateStringId("SI_BINDING_NAME_trC_Mount_RandomFav", "Set Mount to Random Favorite")
  ZO_CreateStringId("SI_BINDING_NAME_trC_Mount_Random", "Set Mount to Random")

  EVENT_MANAGER:UnregisterForEvent(tralceCollectibles.name, EVENT_ADD_ON_LOADED)

  for id, code in pairs(tralceCollectibles.collectibles) do
    local name, _, _, _, unlocked = GetCollectibleInfo(id)
    if (unlocked) then
      ZO_CreateStringId("SI_BINDING_NAME_" .. code, zo_strformat(SI_COLLECTIBLE_NAME_FORMATTER, name))
    end
  end

end

function tralceCollectibles.PrintCooldownOrUseCollectible(collectibleID)
  local collectibleName = GetCollectibleInfo(collectibleID)
  local collectibleCurrCooldown, collectibleMaxCooldown = GetCollectibleCooldownAndDuration(collectibleID)
  if collectibleCurrCooldown > 0 then
    df("|cff0055Can't use " .. collectibleName .. " - " .. math.floor(collectibleCurrCooldown/1000).. "s/" .. collectibleMaxCooldown/1000 .. "s cooldown remaining.|r")
    if chatspamQueued == nil then
      chatspamQueued = 1
      zo_callLater(function () df("|cff0055Collectible cooldown complete!") chatspamQueued = nil end, collectibleCurrCooldown)
    end
  else
    UseCollectible(collectibleID)
  end
end

function tralceCollectibles.SetRdmMount(mountID, friendlyName)
  SetRandomMountType(mountID)
  df("|cff0055Equipping " .. friendlyName .. " Mount...|r")
end

-- Function shamelessly stolen from RidinDirty
function tralceCollectibles.DistanceToUnit(unitID)
  local _, selfX, selfY, selfH = GetUnitWorldPosition("player")
  local _, targetX, targetY, targetH = GetUnitWorldPosition(unitID)
  local nDistance = zo_distance3D(targetX, targetY, targetH, selfX, selfY, selfH) / 100
  return nDistance
end

-- Function shamelessly stolen from RidinDirty
function tralceCollectibles.MountPlayer()
  local displayNamePref = nil
  local isMountable = false
  if IsUnitDeadOrReincarnating("player") or IsUnitInCombat("player") or IsMounted() or HasPendingCompanion() then
    df("|cff0055Unable to mount|r")
    return
  end
  for iD = 1, GetGroupSize() do
    local playerID = GetGroupUnitTagByIndex(iD)
    local playerCharName = GetUnitName(playerID)
    local playerDisplayName = GetUnitDisplayName(playerID)
    local mountedState, hasEnabledGroupMount, hasFreePassengerSlot = GetTargetMountedStateInfo(playerDisplayName)
    if mountedState == MOUNTED_STATE_MOUNT_RIDER and hasEnabledGroupMount and hasFreePassengerSlot then isMountable = true else isMountable = false end
    if not ZO_ShouldPreferUserId() then displayNamePref = playerCharName else displayNamePref = playerDisplayName end
    displayNamePref = zo_strformat("<<1>>", displayNamePref)
    if playerDisplayName ~= GetUnitDisplayName("player") and IsUnitOnline(playerID) and IsUnitInGroupSupportRange(playerID) and isMountable and tralceCollectibles.DistanceToUnit(playerID) < 5.0 then
      df("|cff0055Attempting to mount|r")
      UseMountAsPassenger(playerDisplayName)
      return
    end
  end
  df("|cff0055Unable to mount|r")
end

EVENT_MANAGER:RegisterForEvent(tralceCollectibles.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)

