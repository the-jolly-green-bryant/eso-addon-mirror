KaleidoAchievementItems = {}

local this = KaleidoAchievementItems
this.name = "KaleidoAchievementItems"
this.version = "1.7.1"
this.author = "grin3671"

-- This table maps itemsIds (string) to their related achievementIds in various forms. Each entry contains either
-- a single achievementIds (integer) or a listOfAchievementIds (table of integers) for multi-step achievements.
local AddonData = {
  ---- Trophies
  ["54184"] = 838, -- Tamriel Beast Collector
  ["54185"] = 838, -- Tamriel Beast Collector
  ["54186"] = 838, -- Tamriel Beast Collector
  ["54187"] = 838, -- Tamriel Beast Collector
  ["54188"] = 838, -- Tamriel Beast Collector
  ["54189"] = 838, -- Tamriel Beast Collector
  ["54190"] = 838, -- Tamriel Beast Collector
  ["54195"] = 838, -- Tamriel Beast Collector
  ["54196"] = 838, -- Tamriel Beast Collector
  ["54197"] = 838, -- Tamriel Beast Collector
  ["54198"] = 838, -- Tamriel Beast Collector
  ["54199"] = 841, -- Undead Hoarder
  ["54200"] = 841, -- Undead Hoarder
  ["54201"] = 841, -- Undead Hoarder
  ["54202"] = 841, -- Undead Hoarder
  ["54203"] = 841, -- Undead Hoarder
  ["54204"] = 841, -- Undead Hoarder
  ["54205"] = 842, -- Chitin Accumulator
  ["54206"] = 842, -- Chitin Accumulator
  ["54207"] = 842, -- Chitin Accumulator
  ["54208"] = 842, -- Chitin Accumulator
  ["54209"] = 842, -- Chitin Accumulator
  ["54210"] = 842, -- Chitin Accumulator
  ["54211"] = 842, -- Chitin Accumulator
  ["54212"] = 842, -- Chitin Accumulator
  ["54213"] = 846, -- Dwarven Secrets Gatherer
  ["54214"] = 846, -- Dwarven Secrets Gatherer
  ["54215"] = 843, -- Nature Collector
  ["54216"] = 843, -- Nature Collector
  ["54217"] = 843, -- Nature Collector
  ["54218"] = 843, -- Nature Collector
  ["54219"] = 843, -- Nature Collector
  ["54220"] = 843, -- Nature Collector
  ["54221"] = 843, -- Nature Collector
  ["54222"] = 844, -- Monstrous Component Collector
  ["54223"] = 844, -- Monstrous Component Collector
  ["54224"] = 844, -- Monstrous Component Collector
  ["54225"] = 844, -- Monstrous Component Collector
  ["54226"] = 844, -- Monstrous Component Collector
  ["54227"] = 844, -- Monstrous Component Collector
  ["54228"] = 844, -- Monstrous Component Collector
  ["54229"] = 847, -- Atronach Element Collector
  ["54230"] = 847, -- Atronach Element Collector
  ["54231"] = 847, -- Atronach Element Collector
  ["54232"] = 847, -- Atronach Element Collector
  ["54233"] = 848, -- Oblivion Shard Gatherer
  ["54234"] = 848, -- Oblivion Shard Gatherer
  ["54235"] = 848, -- Oblivion Shard Gatherer
  ["54236"] = 848, -- Oblivion Shard Gatherer
  ["54237"] = 848, -- Oblivion Shard Gatherer
  ["54338"] = 838, -- Tamriel Beast Collector
  ---- Undaunted Items
  ["120034"] = 704,
  ["120035"] = 1680, -- BUG: it's can't be open in achievements if previous stages not completed
  ["120036"] = 1013,
  ["131428"] = 1698,
  ["131429"] = 1690,
  ["131430"] = 1690,
  ["131431"] = 1690,
  ["131432"] = 1690,
  ["134907"] = 1975,
  ["134908"] = 1959,
  ["141857"] = 2162,
  ["141858"] = 2152,
  ["147638"] = 2270,
  ["147645"] = 2260,
  ["153685"] = 2425,
  ["153686"] = 2425,
  ["153687"] = 2425,
  ["153750"] = 2415,
  ["159452"] = 2549,
  ["159453"] = 2539,
  ["167310"] = 2704,
  ["167334"] = 2694,
  ["171775"] = 2831,
  ["171776"] = 2841,
  ["181509"] = 3026,
  ["181510"] = 3016,
  ["184203"] = 3104,
  ["184204"] = 3114,
  ["189504"] = 3375,
  ["189505"] = 3394,
  ["193814"] = 3468,
  ["193815"] = 3529,
  ["203312"] = 3866,
  ["203313"] = 3810,
  ["212586"] = 4128,
  ["212587"] = 4109,
  ["214249"] = 4306,
  ["217971"] = 4334,
  ["217972"] = 4311,
  ---- Furnishing
  ["119872"] = 1010,
  ["119873"] = 1010,
  ["119987"] = 993,
  ["119990"] = 996,
  ["119991"] = 997,
  ["119992"] = 998,
  ["119993"] = 999,
  ["119994"] = 1000,
  ["119995"] = 1001,
  ["119996"] = 1002,
  ["119997"] = 1003,
  ["120001"] = 22,
  ["120037"] = 989,
  ["120039"] = 1009,
  ["120043"] = 494,
  ["120056"] = 867,
  ["120063"] = 618,
  ["120064"] = 61,
  ["120065"] = 617,
  ["145488"] = 2215,
  ["217601"] = 1003,
  ["217650"] = 4426,
  ---- Holidays
  -- ["147658"] = 2464, -- Festive Noise Maker (has progress, 0/10 bugged?)
  -- ["147659"] = 2465, -- Jester's Festival Joke Popper (has progress)
  -- ["153535"] = 2591, -- Bare Bones Puppet (has progress)
  ["199137"] = 3832, -- Haunted By Netches
  ["204458"] = 3827, -- Jubilee Confetti Conveyor
  ["211128"] = 4226, -- What a Hoot!
  ["212198"] = 4238, -- A Warm Winter Storm
  ---- Elsweyr
  -- ["147929"] = 2519, -- Mummified Alfiq Part (has progress)
  -- ["147930"] = 2520, -- Plague-Drenched Fabric (has progress)
  ---- Blackwood
  ["178462"] = 3917, -- Zenithar's Abbey
  ["178463"] = 3916, -- The Silent Halls
  ---- High Isle
  ["188200"] = 3918, -- Coral Haj Mota Lure
  ["188271"] = 3918, -- Coral Haj Mota Decoy
  ---- Necrom
  ["197649"] = 3723, -- Gorne
  ["198095"] = 3723, -- The Underweave
  ["197648"] = 3722, -- Tales of Tribute: Card Conjurer
  ["197830"] = 3742, -- Tales of Tribute: Memories of the Spearhead
  ---- Infinite Archive
  ["203540"] = 3926, -- 50 Maligraphic Ichors / Mount
  ["203541"] = 3927, -- 25 Disgusting Spoils / Pet
  ["203542"] = 3928, -- 20 Unreliable Archive Maps / Face Marks
  ["203543"] = 3929, -- 20 Erroneous Archive Maps / Body Marks
  ---- Infinite Archive Updates
  ["206533"] = 4062, -- 20 Archival Enigmas / Face Art
  ["206534"] = 4063, -- 20 Archival Riddles / Body Art
  ---- Gold Road
  ["207814"] = 4081, -- Silorn
  ["207815"] = 4081, -- Leftwheal Trading Post
  ---- Skill Stylist
  ["207970"] = { 4055, 4056, 4149 }, -- 10/20/30 Mosaic Skill Shred
  ["214309"] = 4294, -- 10 Harvested Soul Fragments / Soul Trap
  ["217925"] = 4446, -- 25 Phials of Tainted Blood / Eviscerate
  ["219782"] = 4447, -- 25 Shards of Writhing Bone / Caltrops
  ---- Skill Stylist Fragments
  ["211158"] = 4223, -- Silver Bolts
  ["211159"] = 4223, -- Silver Bolts
  ["211160"] = 4223, -- Silver Bolts
  ["211161"] = 4223, -- Silver Bolts
  ["211162"] = 4223, -- Silver Bolts
  ["211163"] = 4224, -- Roar
  ["211164"] = 4224, -- Roar
  ["211165"] = 4224, -- Roar
  ["211166"] = 4224, -- Roar
  ["211167"] = 4224, -- Roar
  ["211168"] = 4225, -- Annulment
  ["211169"] = 4225, -- Annulment
  ["211170"] = 4225, -- Annulment
  ["211171"] = 4225, -- Annulment
  ["211172"] = 4225, -- Annulment
  ["211308"] = 4235, -- Puncture
  ["211309"] = 4235, -- Puncture
  ["211310"] = 4235, -- Puncture
  ["211311"] = 4235, -- Puncture
  ["211312"] = 4235, -- Puncture
  ["211313"] = 4235, -- Puncture
  ["211314"] = 4236, -- Force Shock
  ["211315"] = 4236, -- Force Shock
  ["211316"] = 4236, -- Force Shock
  ["211317"] = 4236, -- Force Shock
  ["211318"] = 4236, -- Force Shock
  ["211319"] = 4236, -- Force Shock
  ["217705"] = 4444, -- Mist Form
  ["217706"] = 4444, -- Mist Form
  ["217707"] = 4444, -- Mist Form
  ["217708"] = 4444, -- Mist Form
  ["217709"] = 4444, -- Mist Form
  ---- Solstice
  ["219783"] = 4448, -- 25 Writhing Haj Mota Scales
  ["223698"] = 4479, -- 25 Worm-Touched Soul Gem // Skill Stylist II: Soul Trap
  ---- [U49] Season Zero
  ["223793"] = 4488,
  ["223794"] = 4488,
  ["223795"] = 4488,
  ["223796"] = 4488,
  ["223797"] = 4488,
  ["223798"] = 4488,
  ["223799"] = 4488,
  ["223800"] = 4488,
  ["223801"] = 4488,
  ["223802"] = 4488,
  ["223803"] = 4489,
  ["223804"] = 4489,
  ["223805"] = 4489,
  ["223806"] = 4489,
  ["223807"] = 4489,
  ["223808"] = 4489,
  ["223809"] = 4489,
  ["223810"] = 4489,
  ["223811"] = 4489,
  ["223812"] = 4489,
  ["223813"] = 4490,
  ["223814"] = 4490,
  ["223815"] = 4490,
  ["223816"] = 4490,
  ["223817"] = 4490,
  ["223818"] = 4490,
  ["223819"] = 4490,
  ["223820"] = 4490,
  ["223821"] = 4490,
  ["223822"] = 4490,
  ---- U50
  ["225219"] = 4651,
  ["225220"] = { 4652, 4654, 4655 }, -- 1/5/10
}

-- The order of itemIds matters and should match the order of the achievement criteria which is static AFAIK.
local CriterionItemList = {
  -- ["achievementId"] = { "itemId", ... }
  ["4223"] = { "211158", "211159", "211160", "211161", "211162" },
  ["4224"] = { "211163", "211164", "211165", "211166", "211167" },
  ["4225"] = { "211168", "211169", "211170", "211171", "211172" },
  ["4235"] = { "211308", "211309", "211310", "211311", "211312", "211313" },
  ["4236"] = { "211314", "211315", "211316", "211317", "211318", "211319" },
  ["4444"] = { "217705", "217706", "217707", "217708", "217709" },
  -- PTS Season Zero
  ["4488"] = { "223793", "223794", "223795", "223796", "223797", "223798", "223799", "223800", "223801", "223802" },
  ["4489"] = { "223803", "223804", "223805", "223806", "223807", "223808", "223809", "223810", "223811", "223812" },
  ["4490"] = { "223813", "223814", "223815", "223816", "223817", "223818", "223819", "223820", "223821", "223822" },
}

function this:GetAchievementId(itemLink)
  local itemId = GetItemLinkItemId(itemLink)
  local ID = AddonData[tostring(itemId)]
  if ID == nil then return end
  if type(ID) == "table" then
    local uncomplitedIndex = 1
    for index, achievementId in ipairs(ID) do
      local _, _, _, _, completed = GetAchievementInfo(achievementId)
      if completed and #ID > uncomplitedIndex then
        uncomplitedIndex = index + 1
      end
    end
    return ID[uncomplitedIndex], uncomplitedIndex, #ID
  else
    return ID
  end
end

local function Initialization()
  -- if (LibAddonMenu2) then
  --   this.addonMenu = InitializeAddonMenu()
  -- end

  if (LibCustomMenu) then
    local function AddItem(inventorySlot, slotActions)
      local valid = ZO_Inventory_GetBagAndIndex(inventorySlot)
      if not valid then return end

      local bagId, slotIndex = ZO_Inventory_GetBagAndIndex(inventorySlot)
      local itemLink = GetItemLink(bagId, slotIndex)
      local achievementId = this:GetAchievementId(itemLink)
      if achievementId then
        slotActions:AddCustomSlotAction(SI_DYEING_SWATCH_VIEW_ACHIEVEMENT, function()
          SCENE_MANAGER:HideCurrentScene()
          SYSTEMS:GetObject("achievements"):ShowAchievement(achievementId)
        end , "")
      end
    end

    LibCustomMenu:RegisterContextMenu(AddItem, LibCustomMenu.CATEGORY_LATE)
    -- NOTE: The following line should only work with the Gamepad UI due to the lack of a assignment keybind button
    LibCustomMenu:RegisterKeyStripEnter(AddItem, LibCustomMenu.CATEGORY_LATE)
  end

  local function GetItemLinkFromItemId(itemId)
    local id = tostring(tonumber(itemId, 10))
    if id == "" then return end
    return "|H0:item:" .. id .. ":0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"
  end

  local function GetAchievementTextInfo(achievementId, itemLink)
    local name, _, _, _, completed = GetAchievementInfo(achievementId)

    local itemIndexCriterion

    -- IS THIS ITEM ALREADY ACCOUNTED FOR ACHIEVEMENT
    local actionString = false
    local criterionList = CriterionItemList[tostring(achievementId)]
    if criterionList ~= nil and #criterionList == GetAchievementNumCriteria(achievementId) then
      for i, key in ipairs(criterionList) do
        local criterionItemLink = GetItemLinkFromItemId(key)
        if GetItemLinkItemId(itemLink) == GetItemLinkItemId(criterionItemLink) then
          itemIndexCritetion = i
          local criterionDesctiprion, criterionNumCompleted, criterionNumRequired = GetAchievementCriterion(achievementId, i)
          local isCriterionComplete = criterionNumCompleted >= criterionNumRequired
          if isCriterionComplete then
            actionString = ZO_ERROR_COLOR:Colorize(GetString(SI_ITEM_FORMAT_STR_ALREADY_IN_COLLECTION)) -- Already in Collection (red)
          else
            actionString = UNLOCKED_COLOR:Colorize(GetString(SI_ITEM_FORMAT_STR_ADD_TO_COLLECTION)) -- Use to add to Collection (green)
          end
        end
      end
    end

    local texts = {}
    local isList = false
    for i = 1, GetAchievementNumCriteria(achievementId) do
      local criterionDesctiprion, criterionNumCompleted, criterionNumRequired = GetAchievementCriterion(achievementId, i)
      local isCriterionComplete = criterionNumCompleted >= criterionNumRequired

      isList = criterionNumRequired == 1
      if isList then
        local text = itemIndexCritetion == i and zo_strformat("|l0:1:1:2:2:|l<<1>>|l", criterionDesctiprion) or criterionDesctiprion
        table.insert(texts, isCriterionComplete and ZO_TOOLTIP_DEFAULT_COLOR:Colorize(text) or ZO_DISABLED_TEXT:Colorize(text))
      else
        table.insert(texts, zo_strformat("<<1>>: <<2>>/<<3>>", criterionDesctiprion, isCriterionComplete and UNLOCKED_COLOR:Colorize(criterionNumCompleted) or ZO_WHITE:Colorize(criterionNumCompleted), criterionNumRequired))
      end
    end
    texts = isList and ZO_GenerateCommaSeparatedListWithoutAnd(texts) or ZO_GenerateNewlineSeparatedList(texts)

    return name, actionString, texts, isList, completed
  end

  local function AddTooltipInfo(control, itemLink, controlType)
    if not itemLink or itemLink == "" then return end
    local achievementId = this:GetAchievementId(itemLink)
    if not achievementId then return end

    local name, action, texts, isList, completed = GetAchievementTextInfo(achievementId, itemLink)

    -- DO NOT SHOW ACTION STRING IN STORE DUE INTERNAL requiredToBuyErrorText
    local _, _, relativeTo = control:GetAnchor() -- isValid, point, relativeTo, relativePoint, offsetX, offsetY
    if relativeTo then
      local owner = relativeTo:GetOwningWindow()
      if owner:GetName() == "ZO_StoreWindow" or SCENE_MANAGER:IsShowing("gamepad_store") then
        action = false
      end
    end

    if not controlType then
      -- Keyboard UI
      local r, g, b = ZO_TOOLTIP_DEFAULT_COLOR:UnpackRGB()
      control:AddVerticalPadding(20)
      if action then
        control:AddLine(zo_strformat(action), "", 1, 1, 1, CENTER, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true)
        control:AddVerticalPadding(10)
      end
      control:AddLine(GetString(SI_GROUPFINDERPLAYSTYLE8), "ZoFontWinH5", r, g, b, CENTER, MODIFY_TEXT_TYPE_NONE, CENTER, false)
      control:AddVerticalPadding(-10)
      control:AddLine(zo_strformat(name), "ZoFontHeader2", 1, 1, 1, CENTER, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true)
      control:AddLine(texts, isList and "ZoFontWinH5" or "", r, g, b, CENTER, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true)
    else
      -- Gamepad UI
      control:AddLine(' ')
      control:AddTexture(ZO_GAMEPAD_HEADER_DIVIDER_TEXTURE, control:GetStyle("dividerLine"))

      if action then
        local actionSection = control:AcquireSection(control:GetStyle("bodySection"))
        actionSection:AddLine(zo_strformat(action), control:GetStyle("bodyDescription"), control:GetStyle("whiteFontColor"))
        control:AddSection(actionSection)
      end

      control:AddLine(' ') -- vertical paddings
      control:AddLine(zo_strformat(GetString(SI_JOURNAL_PROGRESS_CATEGORY_SUBCATEGORY), GetString(SI_GROUPFINDERPLAYSTYLE8), completed and GetString(SI_ACHIEVEMENTS_TOOLTIP_COMPLETE) or GetString(SI_ACHIEVEMENTS_PROGRESS)), control:GetStyle("statValuePairStat"))
      control:AddLine(name, control:GetStyle("bodyDescription"), control:GetStyle("whiteFontColor"))

      -- Copy-past from (U48) https://github.com/esoui/esoui/blob/live/esoui/publicallingames/tooltip/achievementtooltips.lua#L109
      local numCriteria = GetAchievementNumCriteria(achievementId)
      local criteriaSection = control:AcquireSection(control:GetStyle("achievementCriteriaSection"))

      for i = 1, numCriteria do
        local description, numCompleted, numRequired = GetAchievementCriterion(achievementId, i)
        local isComplete = (numCompleted == numRequired)

        if numRequired == 1 then -- Checkbox
          criteriaSection:AddSection(control:GetCheckboxSection(zo_strformat(SI_ACHIEVEMENT_CRITERION_FORMAT, description), isComplete))
        else
          local entrySection = control:AcquireSection(control:GetStyle("topSection"))
          local statusBar = control:AcquireStatusBar(control:GetStyle("achievementCriteriaBar"))
          statusBar:SetMinMax(0, numRequired)
          statusBar:SetValue(numCompleted)
          entrySection:AddStatusBar(statusBar)
          entrySection:AddLine(zo_strformat(SI_JOURNAL_PROGRESS_BAR_PROGRESS, numCompleted, numRequired), control:GetStyle("statValuePairValueSmall"))
          entrySection:AddLine(zo_strformat(SI_ACHIEVEMENT_CRITERION_FORMAT, description))

          criteriaSection:AddSection(entrySection)
        end
      end

      control:AddSection(criteriaSection)
      control:AddLine(' ')
    end
  end

  -- NOTE: The following function taken from addon IsJusta Gamepad Tamriel Trade Centre Plugin with little adjustments
  local function IsJustaHook(control, functionName, callbackHook)
    local originalName = control[functionName]
    control[functionName] = function(object, tooltipType, ...)
      control.currentLayoutFunctionName = functionName
      local originalFunction = originalName(control, tooltipType, ...)
      local tooltipContainer = control:GetTooltipContainer(tooltipType)
      if tooltipContainer then
        local tooltipControl = tooltipContainer:GetNamedChild("TipScrollScrollChildTooltip")
        callbackHook(tooltipControl, ...)
      end
      return originalFunction -- work fine w/o it
    end
  end

  -- NOTE: The following function taken from addon MasterRecipeList with little adjustments
  local function HookItemTooltips(callback)
    -- KEYBOARD UI
    ZO_PostHook(ItemTooltip, "SetBagItem", function(control, bagId, slotIndex)
      callback(control, GetItemLink(bagId, slotIndex))
    end)
    ZO_PostHook(ItemTooltip, "SetLootItem", function(control, lootId)
      callback(control, GetLootItemLink(lootId))
    end)
    ZO_PostHook(ItemTooltip, "SetAttachedMailItem", function(control, mailId, attachmentIndex)
      callback(control, GetAttachedItemLink(mailId, attachmentIndex))
    end)
    ZO_PostHook(ItemTooltip, "SetBuybackItem", function(control, slotIndex)
      callback(control, GetBuybackItemLink(slotIndex))
    end)
    ZO_PostHook(ItemTooltip, "SetTradeItem", function(control, tradeId, slotIndex)
      callback(control, GetTradeItemLink(tradeId, slotIndex))
    end)
    ZO_PostHook(ItemTooltip, "SetStoreItem", function(control, slotIndex)
      callback(control, GetStoreItemLink(slotIndex))
    end)
    ZO_PostHook(ItemTooltip, "SetQuestReward", function(control, rewardIndex)
      callback(control, GetQuestRewardItemLink(rewardIndex))
    end)
    ZO_PostHook(ItemTooltip, "SetTradingHouseItem", function(control, slotIndex)
      callback(control, GetTradingHouseSearchResultItemLink(slotIndex))
    end)
    ZO_PostHook(ItemTooltip, "SetTradingHouseListing", function(control, slotIndex)
      callback(control, GetTradingHouseListingItemLink(slotIndex))
    end)
    ZO_PostHook(PopupTooltip, "SetLink", function(control, itemLink)
      callback(control, itemLink)
    end)

    -- GAMEPAD UI (true added to GP functions to differentiate it in AddTooltipInfo)
    IsJustaHook(GAMEPAD_TOOLTIPS, "LayoutBagItem", function(control, bagId, slotIndex)
      callback(control, GetItemLink(bagId, slotIndex), true)
    end)
    IsJustaHook(GAMEPAD_TOOLTIPS, "LayoutItem", function(control, itemLink)
      callback(control, itemLink, true)
    end)
    IsJustaHook(GAMEPAD_TOOLTIPS, "LayoutStoreWindowItem", function(control, itemData)
      -- https://github.com/esoui/esoui/blob/391c25723184ad9fd3fafb13f3adaeb2d3ff8403/esoui/publicallingames/tooltip/itemtooltips.lua#L1595
      if itemData.itemLink == "" then return end
      callback(control, itemData.itemLink, true)
    end)
    IsJustaHook(GAMEPAD_TOOLTIPS, "LayoutBuyBackItem", function(control, itemIndex)
      callback(control, GetBuybackItemLink(itemIndex))
    end)
    IsJustaHook(GAMEPAD_TOOLTIPS, "LayoutGuildStoreSearchResult", function(control, itemLink)
      callback(control, itemLink, true)
    end)
    IsJustaHook(GAMEPAD_TOOLTIPS, "LayoutItemWithStackCountSimple", function(control, itemLink)
      callback(control, itemLink, true)
    end)
  end

  HookItemTooltips(AddTooltipInfo)
end

EVENT_MANAGER:RegisterForEvent(this.name, EVENT_ADD_ON_LOADED, function(event, addonName)
  if addonName ~= this.name then return end
  EVENT_MANAGER:UnregisterForEvent(this.name, EVENT_ADD_ON_LOADED)
  Initialization()
end)


local function TestHookFunction(itemLink)
  local achievementId = this:GetAchievementId(itemLink)
  if not achievementId then return end
  AddMenuItem(GetString(SI_DYEING_SWATCH_VIEW_ACHIEVEMENT), function()
    SCENE_MANAGER:HideCurrentScene()
    SYSTEMS:GetObject("achievements"):ShowAchievement(achievementId)
  end)
  ShowMenu()
end

ZO_PostHook("ZO_Store_OnEntryClicked", function(inventorySlot, button)
  -- inventorySlot = ZO_InventorySlot_GetInventorySlotComponents(inventorySlot)
  if button == MOUSE_BUTTON_INDEX_RIGHT then
    local entryIndex = inventorySlot.index
    local entryType = select(14, GetStoreEntryInfo(entryIndex))
    if entryType == STORE_ENTRY_TYPE_ITEM then
      local itemLink = GetStoreItemLink(entryIndex)
      TestHookFunction(itemLink)
    elseif entryType == STORE_ENTRY_TYPE_COLLECTIBLE then
      -- d(GetStoreCollectibleInfo(entryIndex))
    elseif entryType == STORE_ENTRY_TYPE_ANTIQUITY_LEAD then
      -- d(GetAntiquityName(GetStoreEntryAntiquityId(entryIndex)))
    end
  end
end)
