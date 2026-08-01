-- Create namespace
DsRGuildUnknownData = {}
local DsRGuildUnknownData = DsRGuildUnknownData  or {}

-- async
local async = LibAsync
local task  = async:Create("DSRTRACKER_UNIQUE_NSYNC_NAME")

-- constants
local VERBOSE_DATA = false    -- optional to show names of recipes/furniture/stylepages/runeboxes (dont need names)
local ITEMID_START = 16000    -- this should remain the lowest         16424     High Elf Motif itemId
local ITEMID_END   = 250000   -- this is likely to increase            141907    Legendary: Alinor Grape Stomping Tub

-- temporary lists
local motifData     = {}      -- motifData[bookId/itemId] = { chapters = false },         (and name with verbose on)
local recipeData    = {}      -- list[itemId] = 1                                         (or name with verbose on)
local furnitureData = {}      -- same as recipe
local stylepageData = {}      -- same as recipe
local runeboxData   = {}      -- same as recipe
local affixData     = {}
local focusData     = {}
local signatureData = {}
local currentItemId           -- itemid iterator

-------------------------------------------------------------------------------------------------------------------------------------------------
local function FindMotif(itemLink, itemType, linkName)
  if itemType == ITEMTYPE_RACIAL_STYLE_MOTIF and GetItemLinkBindType(itemLink) == BIND_TYPE_NONE then
    local motifNo = tonumber(string.match(linkName, "%d+"))
    local motifNoPeek = tonumber(string.match(GetItemLinkName(("|H1:item:%d:299:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"):format(currentItemId+1)), "%d+"))
    local chapters = false

    if motifNo == motifNoPeek then
      chapters = true
    end

    motifData[currentItemId] = VERBOSE_DATA and {chapters=chapters, name=string.match(linkName, ":%s(.*)")} or {chapters=chapters}

    if chapters then
      currentItemId = currentItemId + NonContiguousCount(DsRGuildUnknownDefaults.CHAPTERS)
    end

    return true
  end

  return false
end

-------------------------------------------------------------------------------------------------------------------------------------------------
local function FindRecipeOrFurniture(itemLink, itemType, linkName)
  if itemType == ITEMTYPE_RECIPE then
    if IsItemLinkFurnitureRecipe(itemLink) then
      furnitureData[currentItemId] = VERBOSE_DATA and linkName or 1
    else
      recipeData[currentItemId] = VERBOSE_DATA and linkName or 1
    end
    return true
  end

  return false
end

-------------------------------------------------------------------------------------------------------------------------------------------------
local function FindStylepageOrRunebox(itemLink, itemType, linkName)
  -- 3 types of style pages for event
  -- unsure if all detected, going to impersario certainly has correct icons for UT
  -- [Style Page: Prophet's Hood]         147301 normal drops
  -- [Bound Style Page: Prophet's Hood]   147333 from the impressario event merchant
  -- [Event Style Page: Prophet's Hood]   147435
  
  if itemType == ITEMTYPE_CONTAINER or itemType == ITEMTYPE_COLLECTIBLE then
    local linkIcon = GetItemLinkIcon(itemLink)

    if linkIcon == DsRGuildUnknownDefaults.STYLEPAGE_ICON_PATH1 or linkIcon == DsRGuildUnknownDefaults.STYLEPAGE_ICON_PATH2 then
      stylepageData[currentItemId] = VERBOSE_DATA and linkName or 1
    end
    if linkIcon == DsRGuildUnknownDefaults.RUNEBOX_ICON_PATH1 then
      runeboxData[currentItemId] = VERBOSE_DATA and linkName or 1
    end
    return true
  end

  return false
end

-------------------------------------------------------------------------------------------------------------------------------------------------
local function IsScribingAffix(itemType, specializedType)
  return itemType == ITEMTYPE_SCRIBINGX and specializedType == SPECIALIZED_ITEMTYPE_AFFIXX
end

-------------------------------------------------------------------------------------------------------------------------------------------------
local function IsScribingFocus(itemType, specializedType)
  return itemType == ITEMTYPE_SCRIBINGX and specializedType == SPECIALIZED_ITEMTYPE_FOCUSX
end

-------------------------------------------------------------------------------------------------------------------------------------------------
local function IsScribingSignature(itemType, specializedType)
  return itemType == ITEMTYPE_SCRIBINGX and specializedType == SPECIALIZED_ITEMTYPE_SIGNATUREX
end

-------------------------------------------------------------------------------------------------------------------------------------------------
local function FixProblematicMotifs()

  -- Motif Problems:
  --    Every motif has a crown version with a different itemId
  --    Crown Motif Grim Harlequin has non crown version (has chapters), it is only a crown motif book (no chapters)
  --    Soul Shriven added manually because its BIND_TYPE_ON_PICKUP (current method of detecting crown motifs)
  --    Non-Crown and Crown Pyondonium(sp) motif has Crown chapters too
  --    FR has two motif 28's RaGada and Elder Argonians (shouldnt matter now using itemId instead of motifNo as key)
  --    *update: now drops in vhof* Crown Motif 53 Tseaci has 3 different names !!! (refabricated/clockwork/tsaesci)

  local PROBLEMMOTIFS = {
    -- Manually add Crown Motifs (possibly need to add others)
    [82053] = { chapters=false, name="Grim Harlequin Style" },
    [96954] = { chapters=false, name="Frostcaster Style" },
    [132532] = { chapters=false, name="Tsaesci Style" },

    -- Other
    [71765] = { chapters=false, name="Soul Shriven Style" },
    [140278] = { chapters=false, name="Crown Crafting Motif 64" }, -- Askedal from forum
  }

  for k, v in pairs(PROBLEMMOTIFS) do
    motifData[k] = v
  end

  -- some motifs just dont exist
  motifData[82038] = nil  -- Grim Harlequin Style (ingame version doesnt drop...yet)
end

local function UpdateDataDump()
  DsRGuildUnknownDD.motifData     = motifData
  DsRGuildUnknownDD.recipeData    = recipeData
  DsRGuildUnknownDD.furnitureData = furnitureData
  DsRGuildUnknownDD.stylepageData = stylepageData
  DsRGuildUnknownDD.runeboxData   = runeboxData
  DsRGuildUnknownDD.affixData     = affixData
  DsRGuildUnknownDD.focusData     = focusData
  DsRGuildUnknownDD.signatureData = signatureData

  motifData     = {}
  recipeData    = {}
  furnitureData = {}
  stylepageData = {}
  runeboxData   = {}
  affixData     = {}
  focusData     = {}
  signatureData = {}
end

-------------------------------------------------------------------------------------------------------------------------------------------------
local function AsyncIteration()
  local itemLink = ("|H1:item:%d:299:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"):format(currentItemId)
  local itemType, specializedType = GetItemLinkItemType(itemLink)
  local linkName = GetItemLinkName(itemLink)

  FindMotif(itemLink, itemType, linkName)
  FindRecipeOrFurniture(itemLink, itemType, linkName)
  FindStylepageOrRunebox(itemLink, itemType, linkName)

  if IsScribingAffix(itemType, specializedType) then
    affixData[currentItemId] = VERBOSE_DATA and linkName or 1
  end

  if IsScribingFocus(itemType, specializedType) then
    focusData[currentItemId] = VERBOSE_DATA and linkName or 1
  end

  if IsScribingSignature(itemType, specializedType) then
    signatureData[currentItemId] = VERBOSE_DATA and linkName or 1
  end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
local function AsyncCompleted()
  FixProblematicMotifs()
  UpdateDataDump()

  CHAT_SYSTEM:Maximize()

  if DsRGuildUnknownOpts.APIVersion ~= GetAPIVersion() then
    d("|c9fb6cd[DsR-Unkown]|r: API " .. tostring(GetAPIVersion()) .. "... Updating")
  elseif DsRGuildUnknownOpts.AddOnVersion ~= DsRVersion.AddOnVersion then
    d("|c9fb6cd[DsR-Unkown]|r: v" .. tostring(DsRVersion.AddOnVersion) .. "... Updating")
  else
    d("|c9fb6cd[DsR-Unkown]|r: v" .. tostring(DsRVersion.AddOnVersion) .. " [API " .. tostring(GetAPIVersion()) .. "]: Force Rescan...")
  end

  d("|cFF0000->|r |c35fc38" .. DsR.Localization[DsR.language].SI_ITEMTYPE8              .. ":|r " .. tostring(NonContiguousCount(DsRGuildUnknownDD.motifData)))
  d("|cFF0000->|r |c35fc38" .. DsR.Localization[DsR.language].SI_ITEMTYPE29             .. ":|r " .. tostring(NonContiguousCount(DsRGuildUnknownDD.recipeData)))
  d("|cFF0000->|r |c35fc38" .. DsR.Localization[DsR.language].SI_ITEMTYPE61             .. ":|r " .. tostring(NonContiguousCount(DsRGuildUnknownDD.furnitureData)))
  d("|cFF0000->|r |c35fc38" .. DsR.Localization[DsR.language].SI_SPECIALIZEDITEMTYPE82  .. ":|r " .. tostring(NonContiguousCount(DsRGuildUnknownDD.stylepageData)))
  d("|cFF0000->|r |c35fc38" .. DsR.Localization[DsR.language].DsRGuildUnknown_Runeboxes .. ":|r " .. tostring(NonContiguousCount(DsRGuildUnknownDD.runeboxData)))
  d("|cFF0000->|r |c35fc38" .. DsR.Localization[DsR.language].SI_SCRIBING_TITLE         .. ":|r"  ..   " Affix: " .. tostring(NonContiguousCount(DsRGuildUnknownDD.affixData)) ..
                        " Focus: "     .. tostring(NonContiguousCount(DsRGuildUnknownDD.focusData)) ..
                        " Signature: " .. tostring(NonContiguousCount(DsRGuildUnknownDD.signatureData))
  )
  d("|c9fb6cd[DsR-Unkown]|r: ..." .. GetString(DsRGuildCrafting_PrecraftFinish))
  DsRGuildUnknownOpts.APIVersion   = GetAPIVersion()
  DsRGuildUnknownOpts.AddOnVersion = DsRVersion.AddOnVersion

  DsRGuildUnknown:SetupEvents(true)

  DsRGuildUnknown:CheckMotifs()
  DsRGuildUnknown:CheckRecipesAndFurniture()
  DsRGuildUnknown:CheckStylePagesAndRuneboxes()
  DsRGuildUnknown:CheckScribing()
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildUnknownData:BuildDataDump()
  DsRGuildUnknown:SetupEvents(false)

  currentItemId = ITEMID_START

  task:Call(function(task)
    task:Call(AsyncIteration)
    currentItemId = currentItemId + 1
    return currentItemId < ITEMID_END
  end):Then(AsyncCompleted)
end