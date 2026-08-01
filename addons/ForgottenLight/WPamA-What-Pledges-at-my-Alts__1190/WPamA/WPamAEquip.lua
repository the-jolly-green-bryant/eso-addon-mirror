local WPamA = WPamA
--local nvl = WPamA.SF_Nvl
local GetIcon = WPamA.Textures.GetTexture
--=========================================================================
--================= Equipped Weapon Section ===============================
--=========================================================================
local EquipIcons = {
  Charge  = GetIcon(69, 24, true),
  Durab   = GetIcon(70, 24, true),
  TwoHand = GetIcon(48, 22, true),
  OneHand = GetIcon(49, 22, true),
  Dual    = GetIcon(50, 22, true),
}
local EquipItemLinkFormatter = "|H0:item:<<1>>:0:0:0:0:0:0:0:0:0:0:0:1:0:0:1:0:0:0|h|h"

local function GetItemLinkByItemData(ItemDataString)
  if type(ItemDataString) == "string" then
    if ItemDataString == "" then return "" end
    return zo_strformat(EquipItemLinkFormatter, ItemDataString)
  end
  return ""
end -- GetItemLinkByItemData end

local function GetItemDataFromLink(ItemLinkString)
  if type(ItemLinkString) == "string" then
    local tblDiv = {}
    string.gsub( ItemLinkString, ":(%d+)", function(s) table.insert(tblDiv, s) end )
    if tblDiv[1] and tblDiv[2] and tblDiv[3] then
      return zo_strformat("<<1>>:<<2>>:<<3>>", tblDiv[1], tblDiv[2], tblDiv[3])
    end
  end
  return ""
end

local function GetWeaponTypeByItemLink(itemLink)
  local OneHandedTypes = {
    [WEAPONTYPE_AXE] = true,
    [WEAPONTYPE_DAGGER] = true,
--  [WEAPONTYPE_SHIELD] = true,
    [WEAPONTYPE_SWORD] = true,
    [WEAPONTYPE_HAMMER] = true,
  }
  local TwoHandedTypes = {
    [WEAPONTYPE_BOW] = true,
    [WEAPONTYPE_FIRE_STAFF] = true,
    [WEAPONTYPE_FROST_STAFF] = true,
    [WEAPONTYPE_HEALING_STAFF] = true,
    [WEAPONTYPE_LIGHTNING_STAFF] = true,
    [WEAPONTYPE_TWO_HANDED_AXE] = true,
    [WEAPONTYPE_TWO_HANDED_HAMMER] = true,
    [WEAPONTYPE_TWO_HANDED_SWORD] = true,
  }
--WEAPONTYPE_NONE
--WEAPONTYPE_RUNE
  if itemLink and (itemLink ~= "") then
    local WT = GetItemLinkWeaponType(itemLink)
    if WT == WEAPONTYPE_SHIELD then
      return WEAPON_CONFIG_TYPE_ONE_HAND_AND_SHIELD
    elseif OneHandedTypes[WT] then
      return WEAPON_CONFIG_TYPE_ONE_HANDED -- = 10
    elseif TwoHandedTypes[WT] then
      return WEAPON_CONFIG_TYPE_TWO_HANDED -- = 3
    end
  end
  return WEAPON_CONFIG_TYPE_NONE -- = 0
end -- GetWeaponTypeByItemLink end

function WPamA:UpdRowModeWeaponCharge(v, r)
  local ES = self.Equipment.Iterators.ES -- ES = { [EqSlot] = equip slot's index }
  local Stats = {
         -- MAIN weapon pair
         [1] = {Link = "", Charge = -1},   [2] = {Link = "", Charge = -1, TwoHanded = false, Shield = false},
         -- BACKUP weapon pair
         [3] = {Link = "", Charge = -1},   [4] = {Link = "", Charge = -1, TwoHanded = false, Shield = false}
        }
  local function ShowWeaponPairInfo(statInd, column)
    local txt = ""
    local statMain, statOff = Stats[statInd], Stats[statInd+1]
    -- Right hand --
    local isGrayColored = false
    if (statMain.Link == "") and (statMain.Charge == 0) then -- empty slot
      isGrayColored = true
      txt = "---"
    elseif statMain.Link ~= "" then
      txt = zo_strformat("<<1>><<2>> %", EquipIcons.Charge, statMain.Charge)
    else -- data not exist
      isGrayColored = true
      txt = self.i18n.DungStNA
    end
    r.B[column]:SetColor(self:GetColor(isGrayColored and self.Colors.DungStNA or self.Colors.LabelLvl))
    self:SetScaledText(r.B[column], txt)
    -- Left hand ---
    isGrayColored = false
    if (statOff.Link == "") and (statOff.Charge == 0) then -- empty slot
      isGrayColored = true
      txt = "---"
    elseif statOff.Link ~= "" then
      if statOff.TwoHanded then
        isGrayColored = true
        txt = statMain.Charge
      else
        txt = statOff.Charge
      end
      txt = zo_strformat("<<1>><<2>> %", statOff.Shield and EquipIcons.Durab or EquipIcons.Charge, txt)
    else -- data not exist
      isGrayColored = true
      txt = self.i18n.DungStNA
    end
    r.B[column+2]:SetColor(self:GetColor(isGrayColored and self.Colors.DungStNA or self.Colors.LabelLvl))
    self:SetScaledText(r.B[column+2], txt)
    --self.SetItemToolTip(r.B[i], st.Link)
    -- Weapon type --
    if (statMain.Link == "") and (statOff.Link == "") then
      txt = " "
    elseif statOff.TwoHanded then -- 2-Hand
      txt = EquipIcons.TwoHand
    elseif statOff.Shield then -- 1-Hand and Shield
      txt = EquipIcons.OneHand
    else -- 1-Hand or Dual
      txt = EquipIcons.Dual
    end
    r.B[column+1]:SetColor(self:GetColor(self.Colors.DungStNA))
    self:SetScaledText(r.B[column+1], txt)
  end -- ShowWeaponPairInfo end
  --- MAIN weapon pair ---
  local equip = v.Equips[ ES[EQUIP_SLOT_MAIN_HAND] ]
  if equip then -- Main Hand
    local itemLink = GetItemLinkByItemData(equip.Link)
    if itemLink ~= "" then
      local wt = GetWeaponTypeByItemLink(itemLink)
      if wt == WEAPON_CONFIG_TYPE_TWO_HANDED then
        Stats[2].Charge = equip.Cond
        Stats[2].Link   = itemLink
        Stats[2].TwoHanded = true
      end
    end
    Stats[1].Charge = equip.Cond
    Stats[1].Link   = itemLink
  end
  ---
  local equip = v.Equips[ ES[EQUIP_SLOT_OFF_HAND] ]
  if equip then -- Off Hand
    if not Stats[2].TwoHanded then
      local itemLink = GetItemLinkByItemData(equip.Link)
      local wt = GetWeaponTypeByItemLink(itemLink)
      if wt == WEAPON_CONFIG_TYPE_ONE_HAND_AND_SHIELD then
        Stats[2].Shield = true
      end
      Stats[2].Charge = equip.Cond
      Stats[2].Link   = itemLink
    end
  end
  ShowWeaponPairInfo(1, 1)
  --- BACKUP weapon pair ---
  local equip = v.Equips[ ES[EQUIP_SLOT_BACKUP_MAIN] ]
  if equip then -- Backup Main Hand
    local itemLink = GetItemLinkByItemData(equip.Link)
    if itemLink ~= "" then
      local wt = GetWeaponTypeByItemLink(itemLink)
      if wt == WEAPON_CONFIG_TYPE_TWO_HANDED then
        Stats[4].Charge = equip.Cond
        Stats[4].Link   = itemLink
        Stats[4].TwoHanded = true
      end
    end
    Stats[3].Charge = equip.Cond
    Stats[3].Link   = itemLink
  end
  ---
  local equip = v.Equips[ ES[EQUIP_SLOT_BACKUP_OFF] ]
  if equip then -- Backup Off Hand
    if not Stats[4].TwoHanded then
      local itemLink = GetItemLinkByItemData(equip.Link)
      local wt = GetWeaponTypeByItemLink(itemLink)
      if wt == WEAPON_CONFIG_TYPE_ONE_HAND_AND_SHIELD then
        Stats[4].Shield = true
      end
      Stats[4].Charge = equip.Cond
      Stats[4].Link   = itemLink
    end
  end
  ShowWeaponPairInfo(3, 5)
  ---
  r.B[4]:SetText(" ") -- just an empty column
end -- UpdRowModeWeaponCharge end

function WPamA:UpdCharEquipmentData( slotIndex )
  if type(slotIndex) ~= "number" then slotIndex = 0 end
  local SV = self.SV_Main
  local CES = self.Equipment.EquipSlots
  if (slotIndex < 0) or (#CES < slotIndex) then slotIndex = 0 end
  local equip = self.CurChar.Equips
  --- update Equip Slots ---
  local startLoop = (slotIndex == 0) and 1 or slotIndex
  local endLoop   = (slotIndex == 0) and #CES or slotIndex
  for i = startLoop, endLoop do
    if not equip[i] then equip[i] = { Link = "", Cond = 0 } end
    local slotId = CES[i]
    local slotHasItem = GetWornItemInfo(BAG_WORN, slotId)
    if slotHasItem then
      --- slot has item ---
      local itemLink = GetItemLink(BAG_WORN, slotId, LINK_STYLE_DEFAULT)
      local itemData = GetItemDataFromLink(itemLink)
      if itemData ~= "" then
        equip[i].Link = itemData
        if IsItemChargeable(BAG_WORN, slotId) then
          --- item is a weapon ---
          local curCharge, maxCharge = GetChargeInfoForItem(BAG_WORN, slotId)
          equip[i].Cond = zo_floor(100 * curCharge / maxCharge)
          if SV.AutoChargeWeapon and (curCharge <= SV.AutoChargeThreshold) then
            zo_callLater( function()
                            local itemSoulGem = WPamA.Inventory.InvtItem[10].ids -- Crown Soul Gem
                            local slotSoulGem = WPamA:GetItemSlotInBag(BAG_BACKPACK, itemSoulGem)
                            if not slotSoulGem then
                              itemSoulGem = WPamA.Inventory.InvtItem[5].ids -- Soul Gem
                              slotSoulGem = WPamA:GetItemSlotInBag(BAG_BACKPACK, itemSoulGem)
                            end
                            local isInVengeance = WPamA.PlayerInZone.Veng or false
                            if isInVengeance then
                              slotSoulGem = false
                            elseif slotSoulGem then
                              local slotWeapon = WPamA.Equipment.EquipSlots[i]
                              ChargeItemWithSoulGem(BAG_WORN, slotWeapon, BAG_BACKPACK, slotSoulGem)
                              local chatTxt = zo_strformat("<<1>>: <<2>>", GetString(SI_CHARGE_WEAPON_TITLE), -- "Charge Weapon"
                                                           GetItemLink(BAG_WORN, slotWeapon, LINK_STYLE_DEFAULT) )
                              d(chatTxt)
                            else
                                -- "You must have a valid Soul Gem to charge your weapon."
                                d(GetString(SI_SOULGEMITEMCHARGINGREASON0))
                            end
                          end, 2000 )
          end
          --d( zo_strformat("[<<4>>] Charge <<1>>/<<2>> = <<3>>%", curCharge, maxCharge, equip[i].Cond, i) )
        elseif DoesItemHaveDurability(BAG_WORN, slotId) then
          --- item is an armor or shield ---
          equip[i].Cond = GetItemCondition(BAG_WORN, slotId)
          --SI_ITEMREPAIRREASON0 = "You must have valid repair kit to repair this item."
          --SI_REPAIR_KIT_TITLE = "Repair Item"
        else
          --- unknown condition / ring / neck
          equip[i].Cond = 0
        end
      end
    else
      --- slot has no item ---
      equip[i] = { Link = "", Cond = 0 }
    end
  end -- for EquipSlots
  ---
  if slotIndex == 0 then
    local m = WPamA.SV_Main.ShowMode
    if m == 48 then WPamA:UpdWindowInfo() end
  end
end -- UpdCharEquipmentData end
--=========================================================================
--============== Known Recipes & Blueprints Section =======================
--=========================================================================
local function GetCraftStationRecipeProgress(recipeArray, craftStationType)
  if not recipeArray then return "" end
  local rc = recipeArray[craftStationType]
  if not rc then return "" end
  local count = {}
  for quality = ITEM_DISPLAY_QUALITY_NORMAL, ITEM_DISPLAY_QUALITY_LEGENDARY do -- from 1 to 5
    local qualityColor = GetItemQualityColor(quality)
    local num = rc[quality] or 0
    if num == 0 then
      count[quality] = "O"
    else
      count[quality] = qualityColor:Colorize( tostring(num) )
    end
  end
  local countTable = { count[1], "/", count[2], "/", count[3], "/", count[4], "/", count[5], "/" }
  local countText = table.concat(countTable)
  countText = countText:gsub("O/","")
  local txtLen = countText:len()
  if (txtLen > 0) and (countText:sub(txtLen) == "/") then
    countText = countText:sub(1, txtLen - 1)
  end
  return countText
end -- GetCraftStationRecipeProgress end

function WPamA:ShowRecipeData(craftingStationType)
  local TradeSkillName = { -- TradeSkillType / CraftingStationType
        [CRAFTING_TYPE_BLACKSMITHING] = GetString(SI_TRADESKILLTYPE1),
        [CRAFTING_TYPE_CLOTHIER] = GetString(SI_TRADESKILLTYPE2),
        [CRAFTING_TYPE_ENCHANTING] = GetString(SI_TRADESKILLTYPE3),
        [CRAFTING_TYPE_ALCHEMY] = GetString(SI_TRADESKILLTYPE4),
        [CRAFTING_TYPE_PROVISIONING] = GetString(SI_TRADESKILLTYPE5),
        [CRAFTING_TYPE_WOODWORKING] = GetString(SI_TRADESKILLTYPE6),
        [CRAFTING_TYPE_JEWELRYCRAFTING] = GetString(SI_TRADESKILLTYPE7),
        [CRAFTING_TYPE_SCRIBING] = GetString(SI_TRADESKILLTYPE8),
        [CRAFTING_TYPE_INVALID] = "Invalidate"
  }
  local CCB = self.CurChar.CraftRecipes.Blueprints
  if type(craftingStationType) == "number" then
    local progress = GetCraftStationRecipeProgress(CCB, craftingStationType)
    d(TradeSkillName[craftingStationType] .. " : " .. progress)
  else
    for i = CRAFTING_TYPE_MIN_VALUE, CRAFTING_TYPE_MAX_VALUE do -- from 0 to 8
      local progress = GetCraftStationRecipeProgress(CCB, i)
      if progress == "" then progress = "---" end
      local name = TradeSkillName[i]
      d( zo_strformat("[<<1>>] <<2>> : <<3>>", i, name, progress) )
    end
  end
end -- ShowRecipeData end

function WPamA:UpdRowModeBlueprints(v, r)
  local BP = v.CraftRecipes.Blueprints
  for i = CRAFTING_TYPE_BLACKSMITHING, CRAFTING_TYPE_JEWELRYCRAFTING do -- from 1 to 7 (CRAFTING_TYPE_SCRIBING = 8)
    local isGrayColored = false
    local progress = GetCraftStationRecipeProgress(BP, i)
    if progress == "" then
      isGrayColored = true
      progress = "---"
    end
    r.B[i]:SetColor(self:GetColor(isGrayColored and self.Colors.DungStNA or self.Colors.LabelLvl))
    self:SetScaledText(r.B[i], progress)
  end
end -- UpdRowModeBlueprints end

function WPamA:UpdateRecipeData(recipeListIndex, recipeIndex)
  local CCR = self.CurChar.CraftRecipes.Recipes
  local CCB = self.CurChar.CraftRecipes.Blueprints
  ---
  local function UpdateRecipeByIndex(rcpListIndex, rcpIndex)
    local resultItemLink = GetRecipeResultItemLink(rcpListIndex, rcpIndex, LINK_STYLE_DEFAULT)
    local resultItemQuality = GetItemLinkDisplayQuality(resultItemLink)
    local isFurniture = IsItemLinkPlaceableFurniture(resultItemLink)
    local craftingStationType = select(7, GetRecipeInfo(rcpListIndex, rcpIndex))
    local rc
    if isFurniture then -- result is a Furniture
      rc = CCB[craftingStationType]
    else -- result is a Food or Drink
      rc = CCR[craftingStationType]
    end
    if rc then rc[resultItemQuality] = (rc[resultItemQuality] or 0) + 1 end
  end -- UpdateRecipeByIndex end
  ---
  if (type(recipeListIndex) == "number") and (type(recipeIndex) == "number") then
    UpdateRecipeByIndex(recipeListIndex, recipeIndex)
  else
    for craftingType = CRAFTING_TYPE_MIN_VALUE, CRAFTING_TYPE_MAX_VALUE do -- from 0 to 8
      CCB[craftingType] = {}
      CCR[craftingType] = {}
    end
    for recipeListIndex = 1, GetNumRecipeLists() do
      local recipeListName, numRecipes = GetRecipeListInfo(recipeListIndex)
      for recipeIndex = 1, numRecipes do
        UpdateRecipeByIndex(recipeListIndex, recipeIndex)
      end -- for recipeIndex
    end -- for recipeListIndex
  end
end -- UpdateRecipeData end

function WPamA.OnRecipeLearned(event, ...)
  if event == EVENT_MULTIPLE_RECIPES_LEARNED then
    --EVENT_MULTIPLE_RECIPES_LEARNED (integer numRecipesUnlocked)
    local numRecipesUnlocked = ...
    if numRecipesUnlocked < 1 then numRecipesUnlocked = GetNumUpdatedRecipes() end
    for index = 1, numRecipesUnlocked do
      local rcpListIndex, rcpIndex = GetUpdatedRecipeIndices(index)
      WPamA:UpdateRecipeData(rcpListIndex, rcpIndex)
    end
  elseif event == EVENT_RECIPE_LEARNED then
    --EVENT_RECIPE_LEARNED (luaindex recipeListIndex, luaindex recipeIndex)
    local rcpListIndex, rcpIndex = ...
    WPamA:UpdateRecipeData(rcpListIndex, rcpIndex)
  end
  ---
  local m = WPamA.SV_Main.ShowMode
  if m == 49 then WPamA:UpdWindowInfo() end
end -- OnRecipeLearned end
--=========================================================================
--=============== Character Timed Effects Section =========================
--=========================================================================
function WPamA:UpdateActiveTimedEffects(buffID, buffEndTime)
  if type(buffID) ~= "number" then buffID = 0 end
  if type(buffEndTime) ~= "number" then buffEndTime = 0 end
  local Iter = self.TimedEffects.Iterators
  local CCTE = self.CurChar.TimedEffects
  local TS = GetTimeStamp()
  ---
  local function GetSecUntilBuffEnd(timeSec)
    if type(timeSec) ~= "number" then return 0 end
    local sec = zo_floor( timeSec - GetFrameTimeSeconds() )
    if sec < 1 then sec = 0 end
    return sec
  end
  ---
  local function SaveActiveTimedEffect(aid, timeEnd)
    local SecUntilEnd = GetSecUntilBuffEnd(timeEnd)
    local ETS = TS + SecUntilEnd
    if     Iter.A[aid] then CCTE.AvA  = { Index = Iter.A[aid], EndTS = ETS, SecUE = SecUntilEnd }
    elseif Iter.P[aid] then CCTE.PvE  = { Index = Iter.P[aid], EndTS = ETS, SecUE = SecUntilEnd }
    elseif Iter.S[aid] then CCTE.Stat = { Index = Iter.S[aid], EndTS = ETS, SecUE = SecUntilEnd }
    end
    --[[
    d("-= WPamA Active Timed Effects =-")
    local timeLeftText = ZO_FormatTime(GetSecUntilBuffEnd(timeEnd), TIME_FORMAT_STYLE_DESCRIPTIVE_MINIMAL,
                                       TIME_FORMAT_PRECISION_TWENTY_FOUR_HOUR):gsub("m.-$","m")
    d( zo_strformat("-= AID [<<1>>] <<2>>", aid, timeLeftText) )
    --]]
  end
  ---
  if buffID > 0 then
    SaveActiveTimedEffect(buffID, buffEndTime)
    return
  end
  for i = 1, GetNumBuffs("player") do
    local BuffInfoArray = { GetUnitBuffInfo("player", i) }
    local buffName, buffSlot = BuffInfoArray[1], BuffInfoArray[4]
    if (buffSlot > 0) and (buffName ~= "") then
      local abilityId, endTime = BuffInfoArray[11], BuffInfoArray[3]
      --local startTime, iconFile = BuffInfoArray[2], BuffInfoArray[6]
      local isTrackedAbility = Iter.A[abilityId] or Iter.P[abilityId] or Iter.S[abilityId] or false
      if isTrackedAbility then SaveActiveTimedEffect(abilityId, endTime) end
    end -- an ability exists
  end -- for NumBuffs
  ---
  local m = self.SV_Main.ShowMode
  if m == 50 then self:UpdWindowInfo() end
end -- UpdateActiveTimedEffects

function WPamA.OnEffectChanged(event, changeType, effectSlot, effectName, ...)
--EVENT_EFFECT_CHANGED (*EffectResult* changeType, *integer* effectSlot, *string* effectName,
-- *string* unitTag, *number* beginTime, *number* endTime, *integer* stackCount,
-- *string* iconName, *string* deprecatedBuffType, *BuffEffectType* effectType,
-- *AbilityType* abilityType, *StatusEffectType* statusEffectType,
-- *string* unitName, *integer* unitId, *integer* abilityId, *CombatUnitType* sourceType)
  if (effectSlot < 1) or (effectName == "") then return end
  local abilityId = select(12, ...)
  local Iter = WPamA.TimedEffects.Iterators
--  local isTrackedAbility = Iter.A[abilityId] or Iter.P[abilityId] or Iter.S[abilityId] or false
  local isTrackedAbility = Iter.A[abilityId] or false
  if not isTrackedAbility then return end
  local endTime = select(3, ...)
  WPamA:UpdateActiveTimedEffects(abilityId, endTime)
  ---
  local function GetAnnounceIcon()
    local indT, indN = "AvA", 1
    if     Iter.A[abilityId] then
      indT = "AvA"
      indN = Iter.A[abilityId]
    elseif Iter.P[abilityId] then
      indT = "PvE"
      indN = Iter.P[abilityId]
    elseif Iter.S[abilityId] then
      indT = "Stat"
      indN = Iter.S[abilityId]
    end
    local TE = WPamA.TimedEffects[indT]
    local itemId = TE[indN].Link or TE[indN].ItemId[1]
    local itemLnk = zo_strformat(TE.LinkFormatter, itemId)
    local itemIcon = GetItemLinkIcon(itemLnk)
    return itemIcon
  end
  ---
  if changeType == EFFECT_RESULT_FADED then
      --- Message to player ---
      local txt = zo_strformat("<<1>>:\n<<2>>", GetString(SI_CHATCHANNELCATEGORIES50), effectName) -- Lost Effect
      local color = string.format("%02x%02x%02x", 238, 238, 200)
      txt = zo_strformat("|c<<1>><<2>>|r", color, txt)
      WPamA:PostChatMessage(txt) -- , chatChannel)
      local icon = GetAnnounceIcon() -- or GetAbilityIcon(abilityId)
      WPamA:PostScreenAnnounceMessage(txt, CSA_CATEGORY_MAJOR_TEXT, CENTER_SCREEN_ANNOUNCE_TYPE_SYSTEM_BROADCAST, icon)

  elseif changeType == EFFECT_RESULT_UPDATED then
      --- Message to player ---
      local txt = zo_strformat("<<1>>:\n<<2>>", GetString(SI_CHATCHANNELCATEGORIES49), effectName) -- Gained Effect
      local color = string.format("%02x%02x%02x", 238, 238, 200)
      txt = zo_strformat("|c<<1>><<2>>|r", color, txt)
      WPamA:PostChatMessage(txt) -- , chatChannel)
      local icon = GetAnnounceIcon() -- or GetAbilityIcon(abilityId)
      WPamA:PostScreenAnnounceMessage(txt, CSA_CATEGORY_MAJOR_TEXT, CENTER_SCREEN_ANNOUNCE_TYPE_SYSTEM_BROADCAST, icon)
  end
  ---
  local m = WPamA.SV_Main.ShowMode
  if m == 50 then WPamA:UpdWindowInfo() end
end -- OnEffectChanged end
