local UT = UnknownTracker or {}

-- async
local async = LibAsync
local task = async:Create("UT_UNIQUE_NSYNC_NAME")

-- constants
local VERBOSE_DATA = false    -- optional to show names of recipes/furniture/stylepages/runeboxes (dont need names)
local ITEMID_START = 16000    -- this should remain the lowest         16424     High Elf Motif itemId
local ITEMID_END =  250000    -- this is likely to increase            141907    Legendary: Alinor Grape Stomping Tub

-- temporary lists
local motifData = {}          -- motifData[bookId/itemId] = { chapters = false },         (and name with verbose on)
local recipeData = {}         -- list[itemId] = 1                                         (or name with verbose on)
local furnitureData = {}      -- same as recipe
local stylepageData = {}      -- same as recipe
local runeboxData = {}        -- same as recipe
local affixData = {}
local focusData = {}
local signatureData = {}
local currentItemId           -- itemid iterator

local function FindMotif(itemLink, itemType, linkName)
  -- 1: Find out if this itemId is a relevant motif (excluding crown motifs/chapters)

  if itemType == ITEMTYPE_RACIAL_STYLE_MOTIF and GetItemLinkBindType(itemLink) == BIND_TYPE_NONE then

    -- chapters usually follow motif book, peek ahead to see if they have matching motifNo's thereby
    -- confirming its a book with chapters (can skip ahead also)
    local motifNo = tonumber(string.match(linkName, "%d+"))
    local motifNoPeek = tonumber(string.match(GetItemLinkName(("|H1:item:%d:299:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"):format(currentItemId+1)), "%d+"))
    local chapters = false

    if motifNo == motifNoPeek then
      chapters = true
    end

    motifData[currentItemId] = VERBOSE_DATA and {chapters=chapters, name=string.match(linkName, ":%s(.*)")} or {chapters=chapters}

    -- skip chapters
    if chapters then
      currentItemId = currentItemId + NonContiguousCount(UT.CHAPTERS)
    end

    return true
  end

  return false
end

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

local function FindStylepageOrRunebox(itemLink, itemType, linkName)
  -- 3 types of style pages for event
  -- unsure if all detected, going to impersario certainly has correct icons for UT
  -- [Style Page: Prophet's Hood]         147301 normal drops
  -- [Bound Style Page: Prophet's Hood]   147333 from the impressario event merchant
  -- [Event Style Page: Prophet's Hood]   147435
  
  -- Update 7.0 Blackwood: Collectible = stylepage, Container = runebox
  if itemType == ITEMTYPE_CONTAINER or itemType == ITEMTYPE_COLLECTIBLE then
    local linkIcon = GetItemLinkIcon(itemLink)

    if linkIcon == UT.STYLEPAGE_ICON_PATH1 or linkIcon == UT.STYLEPAGE_ICON_PATH2 then
      stylepageData[currentItemId] = VERBOSE_DATA and linkName or 1
    end
    if linkIcon == UT.RUNEBOX_ICON_PATH1 then
      runeboxData[currentItemId] = VERBOSE_DATA and linkName or 1
    end
    return true
  end

  return false
end

-- better style of functions, can be reused for IsValidAndWhoKnowsIt() monstrosity tbc
local function IsScribingAffix(itemType, specializedType)
  return itemType == ITEMTYPE_SCRIBINGX and specializedType == SPECIALIZED_ITEMTYPE_AFFIXX
end

local function IsScribingFocus(itemType, specializedType)
  return itemType == ITEMTYPE_SCRIBINGX and specializedType == SPECIALIZED_ITEMTYPE_FOCUSX
end

local function IsScribingSignature(itemType, specializedType)
  return itemType == ITEMTYPE_SCRIBINGX and specializedType == SPECIALIZED_ITEMTYPE_SIGNATUREX
end

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
  motifData[82038] = nil          -- Grim Harlequin Style (ingame version doesnt drop...yet)
  --motifData[130026] = nil       -- refabricated/clockwork *now drops in vHoF 16/11/2019*

end

local function UpdateDataDump()
  UTDataDump.motifData = motifData
  UTDataDump.recipeData = recipeData
  UTDataDump.furnitureData = furnitureData
  UTDataDump.stylepageData = stylepageData
  UTDataDump.runeboxData = runeboxData
  UTDataDump.affixData = affixData
  UTDataDump.focusData = focusData
  UTDataDump.signatureData = signatureData

  motifData = {}
  recipeData = {}
  furnitureData = {}
  stylepageData = {}
  runeboxData = {}
  affixData = {}
  focusData = {}
  signatureData = {}
end

local function AsyncIteration()
  local itemLink = ("|H1:item:%d:299:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"):format(currentItemId)
  local itemType, specializedType = GetItemLinkItemType(itemLink)
  local linkName = GetItemLinkName(itemLink)

  FindMotif(itemLink, itemType, linkName)
  FindRecipeOrFurniture(itemLink, itemType, linkName)
  FindStylepageOrRunebox(itemLink, itemType, linkName)

  if IsScribingAffix(itemType, specializedType) then
    --d(tostring(currentItemId) .. itemLink .. " " .. tostring(itemType) .. " " .. tostring(specializedType))
    affixData[currentItemId] = VERBOSE_DATA and linkName or 1
  end

  if IsScribingFocus(itemType, specializedType) then
    --d(tostring(currentItemId) .. itemLink .. " " .. tostring(itemType) .. " " .. tostring(specializedType))
    focusData[currentItemId] = VERBOSE_DATA and linkName or 1
  end

  if IsScribingSignature(itemType, specializedType) then
    --d(tostring(currentItemId) .. itemLink .. " " .. tostring(itemType) .. " " .. tostring(specializedType))
    signatureData[currentItemId] = VERBOSE_DATA and linkName or 1
  end

end

local function AsyncCompleted()
  FixProblematicMotifs()
  UpdateDataDump()

  d("   Motifs: " .. tostring(NonContiguousCount(UTDataDump.motifData)))
  d("   Recipes: " .. tostring(NonContiguousCount(UTDataDump.recipeData)))
  d("   Furniture: " .. tostring(NonContiguousCount(UTDataDump.furnitureData)))
  d("   Style Pages: " .. tostring(NonContiguousCount(UTDataDump.stylepageData)))
  d("   Runeboxes: " .. tostring(NonContiguousCount(UTDataDump.runeboxData)))
  d("   Scribing:" ..   " Affix: " .. tostring(NonContiguousCount(UTDataDump.affixData)) ..
                        " Focus: " .. tostring(NonContiguousCount(UTDataDump.focusData)) ..
                        " Signature: " .. tostring(NonContiguousCount(UTDataDump.signatureData))
  )
  d("Unknown Tracker: ...Finished")
  UTOpts.APIVersion = GetAPIVersion()
  UTOpts.AddOnVersion = UnknownTracker.AddOnVersion

  UT:SetupEvents(true)

  UT:CheckMotifs()
  UT:CheckRecipesAndFurniture()
  UT:CheckStylePagesAndRuneboxes()
  UT:CheckScribing()
end

function UT:BuildDataDump()
  self:SetupEvents(false)

  -- APIVersion and AddOnVersion SV updated when datadump finish()
  if UTOpts.APIVersion ~= GetAPIVersion() then
    d("UnknownTracker: API " .. tostring(GetAPIVersion()) .. "... Updating")
  elseif UTOpts.AddOnVersion ~= UnknownTracker.AddOnVersion then
    d("UnknownTracker: v0." .. tostring(UnknownTracker.AddOnVersion) .. "... Updating")
  else
    d("Unknown Tracker v0." .. tostring(UnknownTracker.AddOnVersion) .. " [API " .. tostring(GetAPIVersion()) .. "]: Force Rescan...")
  end

  currentItemId = ITEMID_START

  -- iterate itemids asynchronously then call AsyncCompleted to finish up
  task:Call(function(task)

    task:Call(AsyncIteration)
    currentItemId = currentItemId + 1

    return currentItemId < ITEMID_END
  end):Then(AsyncCompleted)

end