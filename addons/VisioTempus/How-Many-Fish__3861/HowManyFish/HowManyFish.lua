local HMF = {
  name = "HowManyFish",
  version = "1.4.2",
  author = "VisioTempus",
  fishamount = 0,
  total_bag = 0,
  total_bank = 0,
}

-- art\icons\crafting_fishing_fish_roe.dds
-- art\icons\crafting_fishing_salmon.dds
function HMF.RestorePosition()
  local left = HMF.savedVariables.left
  local top = HMF.savedVariables.top
 
  HowManyFishControl:ClearAnchors()
  HowManyFishControl:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
end
 
function HMF.Initialize()

  HMF.fishamount = 0
  EVENT_MANAGER:RegisterForEvent(HMF.name, EVENT_LOOT_RECEIVED, HMF.LootReceivedEvent)
  EVENT_MANAGER:RegisterForEvent(HMF.name, EVENT_CLOSE_BANK, HMF.UpdateTotal)
  
  -- Retrieves how many fishes are in bagpack and bank.
  local bagIdPack = BAG_BACKPACK
  local slotBagPack = ZO_GetNextBagSlotIndex(bagIdPack)
  while slotBagPack do
    local itemLink = GetItemLink(bagIdPack, slotBagPack)
    local inventoryCount, _, _ = GetItemLinkStacks(itemLink)
    -- Reject event fishes.
    if GetItemLinkItemType(itemLink) == ITEMTYPE_FISH and GetItemLinkItemId(itemLink) ~= 100393 and GetItemLinkItemId(itemLink) ~= 100394 and GetItemLinkItemId(itemLink) ~= 100395 then
      HMF.total_bag = HMF.total_bag + inventoryCount
      --zo_callLater(function () d("Inventory : " .. itemLink .. " + " .. inventoryCount) end, 1000)
    end
    slotBagPack = ZO_GetNextBagSlotIndex(bagIdPack, slotBagPack)
  end
  
  -- Bank amount thanks to @FlatBadger code
  local fishInBank = 0
  local fishies = SHARED_INVENTORY:GenerateFullSlotData(
    function(itemdata)		
      return itemdata.itemType == ITEMTYPE_FISH
    end, 
    BAG_BANK, 
    BAG_SUBSCRIBER_BANK)

  for _, item in pairs(fishies) do
    fishInBank = fishInBank + item.stackCount
  end
  HMF.total_bank = fishInBank

  --HowManyFishControlLabelTotal:SetText(string.format("Bag : %d | Bank : %d | Sum : %d", HMF.total_bag, HMF.total_bank,  HMF.total_bag + HMF.total_bank))
  HowManyFishControlLabelBagFish:SetText(string.format("|t16:16:esoui/art/tooltips/icon_bag.dds|t : %d", HMF.total_bag))
  HowManyFishControlLabelBagRoe:SetText(string.format("Est. |t16:16:/esoui/art/icons/crafting_heavy_armor_vendor_component_002.dds|t : %d", HMF.total_bag * 0.008))
  HowManyFishControlLabelBankFish:SetText(string.format("|t16:16:esoui/art/tooltips/icon_bank.dds|t : %d", HMF.total_bank))
  HowManyFishControlLabelBankRoe:SetText(string.format("Est. |t16:16:/esoui/art/icons/crafting_heavy_armor_vendor_component_002.dds|t : %d", HMF.total_bank * 0.008))
 
  HMF.savedVariables = ZO_SavedVars:NewAccountWide("HMFSavedVariables", 1, nil, {})

  HowManyFishControl:SetHandler("OnMoveStop", function(control)
    HMF.savedVariables.left = HowManyFishControl:GetLeft()
    HMF.savedVariables.top = HowManyFishControl:GetTop()
  end)
  
  if HMF.savedVariables.amount then
    HMF.UpdateFishAmount(HMF.savedVariables.amount)
  end
  
  -- Visibility = Hide : 0, Visible : 1, auto : 2
  if HMF.savedVariables.visibility == 1 then
    HowManyFishControl:SetHidden(false)
  else
    HowManyFishControl:SetHidden(true)
  end
 
  HMF.RestorePosition()
  
  -- Visibility = Hide : 0, Visible : 1, auto : 2
  local lsc = LibSlashCommander
  if lsc then
    local cmd = lsc:Register("/hmf"
    , function() HowManyFishControl:SetHidden(not HowManyFishControl:IsHidden()) end
    , "Temporarly show/hide window")

    local sub_hide = cmd:RegisterSubCommand()
    sub_hide:AddAlias("hide")
    sub_hide:SetCallback(function() 
      HowManyFishControl:SetHidden(true)
      HMF.savedVariables.visibility = 0
    end)
    sub_hide:SetDescription("Hide window")
    
    local sub_show = cmd:RegisterSubCommand()
    sub_show:AddAlias("show")
    sub_show:SetCallback(function() 
      HowManyFishControl:SetHidden(false)
      HMF.savedVariables.visibility = 1
    end)
    sub_show:SetDescription("Show window")
    
    local sub_auto = cmd:RegisterSubCommand()
    sub_auto:AddAlias("auto")
    sub_auto:SetCallback(function() 
      HMF.savedVariables.visibility = 2
    end)
    sub_auto:SetDescription("Show only when pointing fishing hole")

    local sub_reset = cmd:RegisterSubCommand()
    sub_reset:AddAlias("reset")
    sub_reset:SetCallback(function()
      HMF.fishamount = 0
      HowManyFishControlLabelFish:SetText(string.format("|t16:16:esoui/art/icons/crafting_fishing_perch.dds|t  : %d", HMF.fishamount))
      HowManyFishControlLabelRoe:SetText(string.format("Est. |t16:16:/esoui/art/icons/crafting_heavy_armor_vendor_component_002.dds|t : %d", HMF.fishamount * 0.008))HMF.savedVariables.amount = 0
    end)
    sub_reset:SetDescription("Reset number of fish to 0")
  else
  
    SLASH_COMMANDS["/hmf"] = function(input)
      local cmd = input:match("(.-)$")
      if(cmd and cmd ~= "") then
        if cmd == "show" then
          HowManyFishControl:SetHidden(false)
          HMF.savedVariables.visibility = 1
        elseif cmd == "hide" then
          HowManyFishControl:SetHidden(true)
          HMF.savedVariables.visibility = 0
        elseif cmd == "auto" then
          HMF.savedVariables.visibility = 2
        elseif cmd == "reset" then
          HMF.ResetFishAmount()
        end
      else
        HowManyFishControl:SetHidden(not HowManyFishControl:IsHidden())
      end
    end
	  
  end

end

function HMF.LootReceivedEvent(_, _, itemLink, quantity, _, _, self, _, _, itemId)

	if self == false then
		return
	end

	if GetItemLinkItemType(itemLink) == ITEMTYPE_FISH then
    HMF.UpdateFishAmount(1)
    HMF.savedVariables.amount = HMF.fishamount
	end
  
end

function HMF.UpdateTotal(_, _)

  HMF.total_bag = 0
  HMF.total_bank = 0

	-- Retrieves how many fishes are in bagpack and bank.
  local bagIdPack = BAG_BACKPACK
  local slotBagPack = ZO_GetNextBagSlotIndex(bagIdPack)
  while slotBagPack do
    local itemLink = GetItemLink(bagIdPack, slotBagPack)
    local inventoryCount, _, _ = GetItemLinkStacks(itemLink)
    -- Reject event fishes.
    if GetItemLinkItemType(itemLink) == ITEMTYPE_FISH and GetItemLinkItemId(itemLink) ~= 100393 and GetItemLinkItemId(itemLink) ~= 100394 and GetItemLinkItemId(itemLink) ~= 100395 then
      HMF.total_bag = HMF.total_bag + inventoryCount
      --zo_callLater(function () d("Inventory : " .. itemLink .. " + " .. inventoryCount) end, 1000)
    end
    slotBagPack = ZO_GetNextBagSlotIndex(bagIdPack, slotBagPack)
  end
  
  -- Bank amount thanks to @FlatBadger code
  local fishInBank = 0
  local fishies = SHARED_INVENTORY:GenerateFullSlotData(
    function(itemdata)		
      return itemdata.itemType == ITEMTYPE_FISH
    end, 
    BAG_BANK, 
    BAG_SUBSCRIBER_BANK)

  for _, item in pairs(fishies) do
    fishInBank = fishInBank + item.stackCount
  end
  HMF.total_bank = fishInBank
  
  --HowManyFishControlLabelTotal:SetText(string.format("Bag : %d | Bank : %d | Sum : %d", HMF.total_bag, HMF.total_bank,  HMF.total_bag + HMF.total_bank))
  HowManyFishControlLabelBagFish:SetText(string.format("|t16:16:esoui/art/tooltips/icon_bag.dds|t : %d", HMF.total_bag))
  HowManyFishControlLabelBagRoe:SetText(string.format("Est. |t16:16:/esoui/art/icons/crafting_heavy_armor_vendor_component_002.dds|t : %d", HMF.total_bag * 0.008))HowManyFishControlLabelBankFish:SetText(string.format("|t16:16:esoui/art/tooltips/icon_bank.dds|t : %d", HMF.total_bank))
  HowManyFishControlLabelBankRoe:SetText(string.format("Est. |t16:16:/esoui/art/icons/crafting_heavy_armor_vendor_component_002.dds|t : %d", HMF.total_bank * 0.008))
  
end

function HMF.UpdateFishAmount(amount)
  HMF.fishamount = HMF.fishamount + amount
  HowManyFishControlLabelFish:SetText(string.format("|t16:16:esoui/art/icons/crafting_fishing_perch.dds|t  : %d", HMF.fishamount))
  HowManyFishControlLabelRoe:SetText(string.format("Est. |t16:16:/esoui/art/icons/crafting_heavy_armor_vendor_component_002.dds|t : %d", HMF.fishamount * 0.008))
  
  HMF.total_bag = HMF.total_bag + amount
  --HowManyFishControlLabelTotal:SetText(string.format("Bag : %d | Bank : %d | Sum : %d", HMF.total_bag, HMF.total_bank,  HMF.total_bag + HMF.total_bank))
  HowManyFishControlLabelBagFish:SetText(string.format("|t16:16:esoui/art/tooltips/icon_bag.dds|t : %d", HMF.total_bag))
  HowManyFishControlLabelBagRoe:SetText(string.format("Est. |t16:16:/esoui/art/icons/crafting_heavy_armor_vendor_component_002.dds|t : %d", HMF.total_bag * 0.008))HowManyFishControlLabelBankFish:SetText(string.format("|t16:16:esoui/art/tooltips/icon_bank.dds|t : %d", HMF.total_bank))
  HowManyFishControlLabelBankRoe:SetText(string.format("Est. |t16:16:/esoui/art/icons/crafting_heavy_armor_vendor_component_002.dds|t : %d", HMF.total_bank * 0.008))
end

function HMF.ResetFishAmount()
  HMF.fishamount = 0
  HowManyFishControlLabelFish:SetText(string.format("|t16:16:esoui/art/icons/crafting_fishing_perch.dds|t  : %d", HMF.fishamount))
  HowManyFishControlLabelRoe:SetText(string.format("Est. |t16:16:/esoui/art/icons/crafting_heavy_armor_vendor_component_002.dds|t : %d", HMF.fishamount * 0.008))
  HMF.savedVariables.amount = 0
end

 
-- Then we create an event handler function which will be called when the "addon loaded" event
-- occurs. We'll use this to initialize our addon after all of its resources are fully loaded.
function HMF.OnAddOnLoaded(event, addonName)
  -- The event fires each time *any* addon loads - but we only care about when our own addon loads.
  if addonName == HMF.name then
    HMF.Initialize()
    --unregister the event again as our addon was loaded now and we do not need it anymore to be run for each other addon that will load
    EVENT_MANAGER:UnregisterForEvent(HMF.name, EVENT_ADD_ON_LOADED)
    
    -- Call ZO_PreHookHandler and not SetHandler to prevent overwriting another handler
    ZO_PreHookHandler(RETICLE.interact, "OnEffectivelyShown", HMF.ManageInteraction)
    ZO_PreHookHandler(RETICLE.interact, "OnHide", HMF.ManageInteraction)
    
  end
end

function HMF.ManageInteraction()
  
  local action, interactableName, _, _, additionalInfo = GetGameCameraInteractableActionInfo()
  
  -- If auto is active
  if HMF.savedVariables.visibility == 2 then
    if action then
      if additionalInfo == ADDITIONAL_INTERACT_INFO_FISHING_NODE then
        HowManyFishControl:SetHidden(false)
      end
    else
      HowManyFishControl:SetHidden(true)
    end
  end
  
end
 
-- Finally, we'll register our event handler function to be called when the proper event occurs.
-->This event EVENT_ADD_ON_LOADED will be called for EACH of the addns/libraries enabled, this is why there needs to be a check against the addon name within your callback function! Else the very first addon loaded would run your code + all following addons too.
EVENT_MANAGER:RegisterForEvent(HMF.name, EVENT_ADD_ON_LOADED, HMF.OnAddOnLoaded)