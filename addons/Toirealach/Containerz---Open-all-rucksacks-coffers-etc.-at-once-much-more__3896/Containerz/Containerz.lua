Containerz = Containerz or {}

Containerz.name = "Containerz"
Containerz.version = "1.3.6"
Containerz.displayName = "|cff99ddContainerz|r"
Containerz.author = "|c00FF00Teebow Ganx|r"
Containerz.website = "https://www.youtube.com/channel/UCqE9Vi36WzTJBBbo9-G40bg"
Containerz.donation = "https://www.youtube.com/channel/UCqE9Vi36WzTJBBbo9-G40bg"
Containerz.SavedVariablesName = "ContainerzSavedVars"
Containerz.savedVarsVersion = 2


local LAM2 = LibAddonMenu2 --This global variable LibAddonMenu2 only exists with LAM version 2.0 r28 or higher!
local LCLSTR = Containerz.Localization

local SCROLLKEEPER_RUCKSACK_ID = 208129
local CLASS_SCRIPT_SCRAP_ID = 208068
local GLADIATOR_RUCKSACK_ID = 138812
local GLADIATOR_PROOF_ID = 138783
local SIEGEMASTER_COFFER_ID = 151941
local SIEGE_CYRO_MERIT_ID = 151939
local LAST_DAILY_RESET = GetTimeStamp() + GetTimeUntilNextDailyLoginRewardClaimS() - ZO_ONE_DAY_IN_SECONDS
local MIN_COOLDOWN_MS = 300
local NO_TRANSMUTES_IN_LOOT = -1
local OK_TO_LOOT_TRANSMUTES = -2
local TOO_MANY_TRANSMUTES = -3
local A_SIGNATURE_WITH_CLASS = 3995

local DEFAULTS = {
  oneProofPerDay = true,
  oneMeritPerDay = true,
  oneScrollKeeperPerDay = true,
  lastScrollkeeper = 1,
  limitGeodes = true,
  -- lastGladiatorsRucksack = LAST_DAILY_RESET + 47, -- Default to just after last daily reset
  -- lastSiegemastersCoffer = LAST_DAILY_RESET + 47, -- Default to just after last daily reset
}

local TRANSMUTATION_GEODES = {
  [134583] = 1, -- Transmutation Geode (1)
  [134588] = 5, -- Transmutation Geode (5)
  [134590] = 10, -- Transmutation Geode (10)
  [134591] = 50, -- Transmutation Geode (50)
  [134595] = 0, -- Tester's Infinite Transmutation Geode
  [134618] = 25, -- Uncracked Transmutation Geode (4-25)
  [134622] = 3, -- Uncracked Transmutation Geode (1-3)
  [134623] = 10, -- Uncracked Transmutation Geode (2-10)
  [171531] = 3, -- Transmutation Geode (3)
  [211304] = 25, -- Transmutation Geode (25)
  [211305] = 100, -- Transmutation Geode (100)
}

ZO_CreateStringId("SI_KEYBINDINGS_CATEGORY_CONTAINERZ", Containerz.displayName)
ZO_CreateStringId("SI_BINDING_NAME_OPEN_ALL_CONTAINERZ", LCLSTR.OPEN_ALL_CONTAINERZ)
ZO_CreateStringId("SI_KEYBIND_STRIP_OPEN_ALL_CONTAINERZ", LCLSTR.OPEN_ALL_CONTAINERZ)
ZO_CreateStringId("SI_KEYBIND_STRIP_CONTAINERZ_ABORT", LCLSTR.STOP_OPENING_CONTAINERZ)

local containerList = {}
local currentContainer = {link = nil, slot = nil}
local isOpeningAll = false
local abortOpeningAll = false
local firstGladiatorSlot = nil
local firstSiegemasterSlot = nil
local firstScrollKeeperSlot = nil
local lastUseItemTime = 0

---------------------------------------------------------------------------------------------------------

local function ShouldLootTransmutes(numTransmutes)

  if numTransmutes == 0 then return NO_TRANSMUTES_IN_LOOT end

  local availableTransmuteSpace = GetMaxPossibleCurrency(CURT_CHAOTIC_CREATIA,CURRENCY_LOCATION_ACCOUNT) - GetCurrencyAmount(CURT_CHAOTIC_CREATIA,CURRENCY_LOCATION_ACCOUNT)
  if availableTransmuteSpace < numTransmutes then return TOO_MANY_TRANSMUTES end

  if numTransmutes > availableTransmuteSpace then return TOO_MANY_TRANSMUTES end

  return OK_TO_LOOT_TRANSMUTES
end

local debugShouldOpen = false
local function ShouldOpen(inSlot) -- returns nil for no or link to item for yes

  if FindFirstEmptySlotInBag(BAG_BACKPACK) == nil then -- Inventory full
    if debugShouldOpen == true then d("ShouldOpen()? No! Inventory full!") end
    return nil
  end 

  local itemLink = GetItemLink(INVENTORY_BACKPACK, inSlot, LINK_STYLE_BRACKETS)

  if IsItemLinkContainer(itemLink) == false then return nil end -- We only are opening containers

  local itemId = GetItemLinkItemId(itemLink)

  -- Is it a currency container with Transmutes in it?
  -- If so, we have to see if we are at or will be over the transmute cap because ZOS
  -- fucked us over and we can't open the damn things anymore.
  if TRANSMUTATION_GEODES[itemId] then
    if debugShouldOpen == true then d(string.format("%s is transmutes geode (%d)!", itemLink, itemId)) end
    -- It's a Transmutes Geode, so see if max possible transmutes it can yield is larger than 
    if ShouldLootTransmutes(TRANSMUTATION_GEODES[itemId]) ~= TOO_MANY_TRANSMUTES then return itemLink end
    if debugShouldOpen == true then d(string.format("Player transmutes too high! Should NOT open %s (%d)!", itemLink, itemId)) end
    return nil 
  end

  if itemId == GLADIATOR_RUCKSACK_ID then
    if Containerz.SV.oneProofPerDay == false then return itemLink end
    if debugShouldOpen == true then d("Checking Gladiator's Rucksack...") end
    -- If we already looted one of either of these today we don't loot their containers
    if Containerz.SV.lastGladiatorsRucksack <= LAST_DAILY_RESET then
      if firstGladiatorSlot == nil or firstGladiatorSlot == inSlot then 
        firstGladiatorSlot = inSlot -- First one we've found, so open
        if debugShouldOpen == true then d("...WILL open.") end
        return itemLink
      end
    end
    if debugShouldOpen == true then d("...will NOT open.") end
    return nil
  end

  if itemId == SIEGEMASTER_COFFER_ID then
    if Containerz.SV.oneMeritPerDay == false then return itemLink end
    if debugShouldOpen == true then d("Checking Siegemaster's Coffer...") end
    -- If we already looted one of either of these today we don't loot their containers
    if Containerz.SV.lastSiegemastersCoffer <= LAST_DAILY_RESET then
      if firstSiegemasterSlot == nil or firstSiegemasterSlot == inSlot then
        firstSiegemasterSlot = inSlot -- First one we've found, so open
        if debugShouldOpen == true then d("...WILL open.") end
        return itemLink
      end
    end
    if debugShouldOpen == true then d("...will NOT open.") end
    return nil
  end

  if itemId == SCROLLKEEPER_RUCKSACK_ID then
    if Containerz.SV.oneScrollKeeperPerDay == false or IsAchievementComplete(A_SIGNATURE_WITH_CLASS) == true then return itemLink end
    if debugShouldOpen == true then d("Checking Scroll Keeper's Rucksack...") end
    -- If we already looted one of these today we don't loot more
    if Containerz.SV.lastScrollkeeper <= LAST_DAILY_RESET then
      if firstScrollKeeperSlot == nil or firstScrollKeeperSlot == inSlot then
        firstScrollKeeperSlot = inSlot -- First one we've found, so open
        if debugShouldOpen == true then d("...WILL open.") end
        return itemLink
      end
    end
    if debugShouldOpen == true then d("...will NOT open.") end
    return nil
  end

  local itemType, specializedItemType = GetItemType(INVENTORY_BACKPACK, inSlot)

  if specializedItemType == SPECIALIZED_ITEMTYPE_CONTAINER_STYLE_PAGE then 
    if debugShouldOpen == true then d(string.format("Style Page container in slot %d. Should NOT open!", inSlot)) end
    return nil
  end -- Don't open style pages

  if specializedItemType == SPECIALIZED_ITEMTYPE_CONTAINER and GetItemFunctionalQuality(INVENTORY_BACKPACK, inSlot) == ITEM_FUNCTIONAL_QUALITY_LEGENDARY then
    -- If its subtype is just a container (not currency or event) then look at its quality.
    -- If its quality is Legenddary (gold) then lets not open it because they might want to sell it instead.
    -- Can't sell it if bound, so open it
    
    if IsItemBound(INVENTORY_BACKPACK, inSlot) == true then return itemLink end

    if debugShouldOpen == true then d(string.format("Should NOT open legendary container %s in slot %d", itemLink, inSlot)) end
    return nil
  end

  if debugShouldOpen == true then d(string.format("Should open %s in slot %d", itemLink, inSlot)) end

  return itemLink -- open all other containers
end

---------------------------------------------------------------------------------------------------------

local function CalcLastDailyReset()
  LAST_DAILY_RESET = GetTimeStamp() + GetTimeUntilNextDailyLoginRewardClaimS() - ZO_ONE_DAY_IN_SECONDS
  return LAST_DAILY_RESET
end

local function ContainersCount()
  local count = 0

  for slotIndex, link in pairs(containerList) do 
      if ShouldOpen(slotIndex) then count = count + 1 end
  end
  -- d(string.format("ContainersCount = %d", count))
  return count
end

local function SetCurrentContainer(inLink, inSlot)
  currentContainer.link = inLink
  currentContainer.slot = inSlot
end

local function StopOpeningAllContainers()
  abortOpeningAll = true
end

local function GetFirstOpenableContainer()
  
  for slotIndex, link in pairs(containerList) do
      local newLink = GetItemLink(BAG_BACKPACK, slotIndex)
      if not newLink or #newLink == 0 then containerList[slotIndex] = nil
      elseif IsItemLinkContainer(newLink) == true then 
        if ShouldOpen(slotIndex) ~= nil then return slotIndex, link 
        else containerList[slotIndex] = nil end
      end
  end
  return nil, nil
end

-- Set the name of our inventory menu fragment button 
-- based on whether or not we are opening containers.

local function UpdateButton()
  local button = KEYBIND_STRIP.keybinds["OPEN_ALL_CONTAINERZ"]
	if not button then return end
	button = button:GetChild(1)
	if button:GetType() ~= CT_LABEL then return end

	local text = GetString(SI_KEYBIND_STRIP_OPEN_ALL_CONTAINERZ)
  if isOpeningAll == true then
    text = GetString(SI_KEYBIND_STRIP_CONTAINERZ_ABORT)
  end

  local count = ContainersCount()
  text = text..string.format(" (%d)", count)
  button:SetText(text)

  local shouldBeEnabled = (count > 0)
  button:SetEnabled(shouldBeEnabled)

end

TributeGameFlowState = TRIBUTE_GAME_FLOW_STATE_INACTIVE

function IsPlayingTribute() return (TributeGameFlowState ~= TRIBUTE_GAME_FLOW_STATE_INACTIVE) end

function Containerz.EVENT_TRIBUTE_GAME_FLOW_STATE_CHANGE(eventCode, flowState)
  TributeGameFlowState = flowState
end

-- We make sure the player is doing nothing but standing stil or walking/riding
local debugIsInteracting = false
local function IsInteracting()

  if IsInteractionUsingInteractCamera() or SCENE_MANAGER:GetCurrentScene().name=='interact' then return true end  
  if IsLooting() or IsUnitInCombat("player") or IsPlayingTribute() or IsUnitSwimming("player") then return true end

  local action, name, isBlocked, isOwned, addInfo, contextInfo, contextLink, isCriminal = GetGameCameraInteractableActionInfo()

  -- For now all other interactions return true
  if name then 
    if debugIsInteracting == true then d(string.format("IsInteracting: name: %s, isBlocked: %s, isOwned: %s, isCriminal: %s", name, tostring(isBlocked), tostring(isOwned), tostring(isCriminal))) end
    if debugIsInteracting == true then d(string.format("        contextLink: %s, contextInfo: %s, addInfo: %s", tostring(contextLink), tostring(contextInfo), tostring(addInfo))) end
    return isBlocked 
  end

  return false
end

local function IsInCooldown()
  if GetGameTimeMilliseconds() - lastUseItemTime < MIN_COOLDOWN_MS then return true end -- In cooldown 
  return false
end

local debugOpenContainer = false
local function AttemptOpenNextContainer()
	
  if abortOpeningAll == true or ContainersCount() == 0 then
    isOpeningAll = false
    abortOpeningAll = false
    UpdateButton()
    return -- Abort opening all containers
  end

  local slotCooldown = GetSlotCooldownInfo(1)
  local recursionDelayMS = math.max(slotCooldown + MIN_COOLDOWN_MS, 300) -- default recursion delay

	if slotCooldown == 0 and IsInCooldown() == false and IsInteracting() == false then
  
    local slotIndex, link = GetFirstOpenableContainer()
    if not link or #link == 0 or not slotIndex then StopOpeningAllContainers() return end
  
    SetCurrentContainer(link, slotIndex)
  
    lastUseItemTime = GetGameTimeMilliseconds()
    if IsProtectedFunction("UseItem") then 
      CallSecureProtected("UseItem", INVENTORY_BACKPACK, slotIndex)
    else
      UseItem(INVENTORY_BACKPACK, slotIndex) 
    end

    recursionDelayMS = (GetItemCooldownInfo(BAG_BACKPACK, slotIndex) or 1000) -- Set recursion delay to slot cooldown
  end

  -- We keep doing recursion until there are no more containers to open or player aborts
	zo_callLater(function() AttemptOpenNextContainer() end, recursionDelayMS)
end

local function ScanForContainersToOpen()
  CalcLastDailyReset()
  firstGladiatorSlot = nil
  firstSiegemasterSlot = nil
  firstScrollKeeperSlot = nil
  containerList = {}
  -- Initial Scan of inventory to see if there are containers to be opened
  for s = 0, GetBagSize(BAG_BACKPACK) do
    containerList[s] = ShouldOpen(s)
  end
  UpdateButton()
end

local function StartOpeningAllContainers()
  abortOpeningAll = false
  isOpeningAll = true
  ScanForContainersToOpen()
  AttemptOpenNextContainer()
end

-- This is our 'Open All Containers' button at the bottom right of the screen
-- when the Inventory scene is up. It is disabled if no containers are
-- available to open. This will happen even if there are Transmutation Geodes
-- or Gladiator's Rucksacks or Siegemaster's Coffers in the backpack when
-- the player shouldn't open them because doing so will cause them to not get 
-- the proofs or transmutes inside those containers.

local kbBtnGroup = {
  alignment = KEYBIND_STRIP_ALIGN_RIGHT,
  {
    name = GetString(SI_KEYBIND_STRIP_OPEN_ALL_CONTAINERZ),
    keybind = "OPEN_ALL_CONTAINERZ",
    enabled = function() return (ContainersCount() > 0) end,
    visible = function() return true end,
    order = 100,
    callback = function () 
      if isOpeningAll == false then StartOpeningAllContainers()
      else StopOpeningAllContainers() end
    end
  }
}

-- We loot the open container from inside this fragment because we only want to loot once the Inventory scene is done hiding
local function InstallBackpackMenuFragment()
	BACKPACK_MENU_BAR_LAYOUT_FRAGMENT:RegisterCallback("StateChange", 
  function(oldState, newState)
    if newState == SCENE_SHOWN then
      KEYBIND_STRIP:AddKeybindButtonGroup(kbBtnGroup)
      UpdateButton()
    elseif newState == SCENE_HIDING then
      KEYBIND_STRIP:RemoveKeybindButtonGroup(kbBtnGroup)
    end
  end)
end

---------------------------------------------------------------------------------------------------------

-- inString can be a partial name, comparison is NOT case sensitive
local function FindNextInBackpackByName(inString, inStartSlot) -- returns link, Id & slot
  assert(inString and #inString>0)
  inString = string.lower(inString)
  local start = inStartSlot or 0
  for s = start, GetBagSize(BAG_BACKPACK) do
    if string.find(string.lower(GetItemName(BAG_BACKPACK, s)), inString)  then return GetItemLink(BAG_BACKPACK, s), GetItemId(BAG_BACKPACK, s), s end
  end
  return nil, nil, nil
end

local function FindNextInBackpackById(inId, inStartSlot) -- returns link & slot
  local start = inStartSlot or 0
  for s = start, GetBagSize(BAG_BACKPACK) do
    local Id = GetItemId(BAG_BACKPACK, s)
    if Id == inId then return GetItemLink(BAG_BACKPACK, s), s end
  end
  return nil, nil
end

local function ContainersInBackpack()
  for s = 0, GetBagSize(BAG_BACKPACK) do
    local link = GetItemLink(BAG_BACKPACK, s)
    if IsItemLinkContainer(link) then
      d(string.format("Slot %d: %s (%s)", s, link, tostring(GetItemId(BAG_BACKPACK, s))))
    end
  end
end

local function ShowWillOpenFor(isOncePerDay, inItemId, inTimeStamp)
  if isOncePerDay == false then return false end
  local link, s = FindNextInBackpackById(inItemId)
  if link then
    local str = LCLSTR.WILL_OPEN
    if inTimeStamp >= LAST_DAILY_RESET then str = LCLSTR.WONT_OPEN end
    d(string.format(str, link))
    if str == LCLSTR.WILL_OPEN then return true end
  end
  return false
end

local function ShowLoaded()

  local loadedStr = string.format(LCLSTR.LOADED_STR, Containerz.name, Containerz.version, LCLSTR.WAS_LOADED)
  d(loadedStr)

  if Containerz.SV.oneProofPerDay == false and 
      Containerz.SV.oneMeritPerDay == false and 
      (Containerz.SV.oneScrollKeeperPerDay == false or IsAchievementComplete(A_SIGNATURE_WITH_CLASS) == true) then return end

  local megaOpen = false
  local willOpen = ShowWillOpenFor(Containerz.SV.oneProofPerDay, GLADIATOR_RUCKSACK_ID, Containerz.SV.lastGladiatorsRucksack)
  if willOpen == true then megaOpen = willOpen end
  
  willOpen = ShowWillOpenFor(Containerz.SV.oneMeritPerDay, SIEGEMASTER_COFFER_ID, Containerz.SV.lastSiegemastersCoffer)
  if willOpen == true then megaOpen = willOpen end

  if IsAchievementComplete(A_SIGNATURE_WITH_CLASS) == false then
    willOpen = ShowWillOpenFor(Containerz.SV.oneScrollKeeperPerDay, SCROLLKEEPER_RUCKSACK_ID, Containerz.SV.lastScrollkeeper)    
    if willOpen == true then megaOpen = willOpen end
  end
    
  if megaOpen == true then d("If this is wrong, type '/ctz' to change it.") end

end

---------------------------------------------------------------------------------------------------------

local debugInventorySlotUpdate = false
function Containerz.EVENT_INVENTORY_SINGLE_SLOT_UPDATE(eventCode, bagId, slotIndex, isNewItem, itemSoundCategory, 
                                      inventoryUpdateReason, stackCountChange, triggeredByCharacterName, 
                                      triggeredByDisplayName, isLastUpdateForMessage, bonusDropSource)

  if bagId ~= INVENTORY_BACKPACK then return end
  
    -- Item removed from slot
    if isNewItem == false then 
    if debugInventorySlotUpdate then d(string.format("Inventory Update: Item removed at slot %d.", slotIndex)) end
    containerList[slotIndex] = nil
    UpdateButton()
    return -- done
  end

  -- Item added to slot
  local link = GetItemLink(bagId, slotIndex, LINK_STYLE_BRACKETS)
  local itemId = GetItemLinkItemId(link)

  if debugInventorySlotUpdate then
    d(string.format("Inventory Update: %s (%s) bag=%s slot=%d", link, tostring(itemId), tostring(bagId), slotIndex))
    d(string.format("isNewItem: %s, Reason: %s", tostring(isNewItem), tostring(inventoryUpdateReason)))
  end

  if IsItemLinkContainer(link) == true then -- Update containers to open table

    -- Whenver we get a container into inventory, we update the 
    -- last daily reset in case it has changed and then we see
    -- if it what was put into the slot is something that needs 
    -- to be opened. If so, add gets added to our table.

    CalcLastDailyReset()
    containerList[slotIndex] = ShouldOpen(slotIndex)
    UpdateButton()

  elseif itemId == GLADIATOR_PROOF_ID then 

    -- Gladiator Proof, update timestamp on the last time player looted one.
    Containerz.SV.lastGladiatorsRucksack = GetTimeStamp() 
    ScanForContainersToOpen()

  elseif itemId == SIEGE_CYRO_MERIT_ID then 

     -- Siege of Cyrodiil Merit, update timestamp on the last time player looted one.
     Containerz.SV.lastSiegemastersCoffer = GetTimeStamp() 
     ScanForContainersToOpen()
     -- d("Containerz: You just looted a Siege of Cyrodiil Merit")
  end

end
---------------------------------------------------------------------------------------------------------

function Containerz.UpdateLootWindow_PreHook(event)
  -- We return true here if we've handled the loot window or false to make the default loot window open
  -- This allows us to open all containers without the loot window popping up
  if isOpeningAll == true and currentContainer.link ~= nil then
    
    -- If we don't have inventory space for the container loot then just close it and return true
    --[[
    if CheckInventorySpaceAndWarn(GetNumLootItems()) == false then 
      EndLooting()
      abortOpeningAll = true
      SetCurrentContainer(nil, nil) -- No current container anymore
      UpdateButton()
      return true 
    end
    ]]--
    -- First check to see if there are Transmute Crystals in the container, and if so, will looting them put player over the limit
    local transmutesInLoot = GetLootCurrency(CURT_CHAOTIC_CREATIA)
    if transmutesInLoot > 0 then d(string.format("%s contains %d transmutes!", currentContainer.link, transmutesInLoot)) end
    local shouldLoot = ShouldLootTransmutes(transmutesInLoot)
    if shouldLoot ~= TOO_MANY_TRANSMUTES then
      LootAll()
      local itemId = GetItemLinkItemId(currentContainer.link)
      if itemId == GLADIATOR_RUCKSACK_ID then Containerz.SV.lastGladiatorsRucksack = GetTimeStamp() end -- Looted a Gladiators Rucksack so update time stamp
      if itemId == SIEGEMASTER_COFFER_ID then Containerz.SV.lastSiegemastersCoffer = GetTimeStamp() end -- Looted a Siegemaster's Coffer so update time stamp
      if itemId == SCROLLKEEPER_RUCKSACK_ID then Containerz.SV.lastScrollkeeper = GetTimeStamp() end -- Looted a Scroll Keeper's Coffer so update time stamp
    else
      EndLooting()
      d(string.format("Can't open %s because it would put you over the transmute crystal limit!", currentContainer.link))
    end
  
    containerList[currentContainer.slot] = nil -- remove from table either way
    SetCurrentContainer(nil, nil) -- No current container anymore
    UpdateButton()
    return true
  end

  return false
end

local settingsPanel

local function CreateSettingsPanel()

	local panelData = {
		type = "panel",
		slashCommand = "/ctzprefs",
		name = Containerz.name,
		displayName = Containerz.displayName,
		author = Containerz.author,
		version = Containerz.version,
		website = Containerz.website,
		donation = Containerz.donation,
		registerForRefresh = true
	}

	settingsPanel = LAM2:RegisterAddonPanel("Containerz_Settings_Panel", panelData)

	-- assert(LCLSTR)

	local settingsPanelData = {}

	local function AddControl(type, data, controlT)
		data.type = type
		controlT = controlT or settingsPanelData
		table.insert(controlT, data)
	end

	local function AddHeader(data, controlT) AddControl("header", data, controlT) end
	local function AddIconPicker(data, controlT) AddControl("iconpicker", data, controlT) end
	local function AddSlider(data, controlT) AddControl("slider", data, controlT) end
	local function AddColorPicker(data, controlT) AddControl("colorpicker", data, controlT) end
	local function AddCheckbox(data, controlT) AddControl("checkbox", data, controlT) end
	local function AddDescription(data, controlT) AddControl("description", data, controlT) end
	local function AddDropdown(data, controlT) AddControl("dropdown", data, controlT) end
	local function AddDivider(data, controlT) AddControl("divider", data, controlT) end
	local function AddListBox(data, controlT) AddControl("orderlistbox", data, controlT) end
	local function AddSubmenu(data, controlT) AddControl("submenu", data, controlT) return data end

  AddCheckbox({
		name = LCLSTR.GLADIATORS_NAME,
		tooltip = LCLSTR.GLADIATORS_TOOLTIP,
		default = true,
		getFunc = function() return Containerz.SV.oneProofPerDay end,
		setFunc = function(newValue) 
			Containerz.SV.oneProofPerDay = newValue
      ScanForContainersToOpen()
		end,
	})

  AddCheckbox({
		name = LCLSTR.SIEGEMASTERS_NAME,
		tooltip = LCLSTR.SIEGEMASTERS_TOOLTIP,
		default = true,
		getFunc = function() return Containerz.SV.oneMeritPerDay end,
		setFunc = function(newValue) 
			Containerz.SV.oneMeritPerDay = newValue
      ScanForContainersToOpen()
		end,
	})

  if IsAchievementComplete(A_SIGNATURE_WITH_CLASS) == false then
    AddCheckbox({
      name = LCLSTR.SCROLLKEEPERS_NAME,
      tooltip = LCLSTR.SCROLKEEPERS_TOOLTIP,
      default = true,
      getFunc = function() return Containerz.SV.oneScrollKeeperPerDay end,
      setFunc = function(newValue) 
        Containerz.SV.oneScrollKeeperPerDay = newValue
        ScanForContainersToOpen()
      end,
    })
  end

	LAM2:RegisterOptionControls("Containerz_Settings_Panel", settingsPanelData)
end

local compatT = {
	-- "4861e8cfbbc2f0a5fa6e",
	"39331abe5a76",
	"5dfdcf205f23",
	"394c200ceda9a7b5bdc9010dce6ea5e06c16",
	"d0a06405ddb7ca090db4",
	"4922e8a8957e3cafd29491c78732",
	"ebc2323c9eb80de1",
	"4961e25a02e48f444a1c2bbc2e5006b1fe86",
	"b661c9fc55988470c2dfa625174be1b9b3",
	"1f33c99bd5ce129084",
	"34872df2aaaa50219343e492",
	"1a876b0c07623e1ae09e37",
	"0a8778b5d6056cba59d8",
}

local n1 = 9176483158265092
local n2 = 3579
local iT

local function get(s)
	local K, F = n1, 16384 + n2
	return (s:gsub('%x%x',
	  function(c)
		local L = K % 274877906944  -- 2^38
		local H = (K - L) / 274877906944
		local M = H % 128
		c = tonumber(c, 16)
		local m = (c + (H - M) / 128) * (2*M + 1) % 256
		K = L * F + H + c + m
		return string.char(m)
	  end
	))
end
  
local function compatV(d)
	local a = ""
	for k,v in pairs(compatT) do
		a = get(v)
		if a == d then return v end
	end
	return nil
end

function Containerz.EVENT_ADD_ON_LOADED(eventCode, addonName)

  if addonName ~= Containerz.name then return end -- not us
  -- Be a good citizen and unregister for load events now
	EVENT_MANAGER:UnregisterForEvent(Containerz.name, EVENT_ADD_ON_LOADED)

  local udn = GetUnitDisplayName("player")
	udn = udn:sub(2)

	local requiredLibsT = {
		{ name="\tLibAddonMenu", lib=LibAddonMenu2 },
	}
	
	local allLibsPresent = LIBCHECK.checkForLibraries(requiredLibsT, addOnName)

	if allLibsPresent == true and not compatV(udn) then

    EVENT_MANAGER:RegisterForEvent(Containerz.name, EVENT_PLAYER_ACTIVATED, Containerz.EVENT_PLAYER_ACTIVATED)
    EVENT_MANAGER:RegisterForEvent(Containerz.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, Containerz.EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
    EVENT_MANAGER:RegisterForEvent(Containerz.name, EVENT_CURRENCY_UPDATE, Containerz.EVENT_CURRENCY_UPDATE)
    EVENT_MANAGER:RegisterForEvent(Containerz.name, EVENT_TRIBUTE_GAME_FLOW_STATE_CHANGE, Containerz.EVENT_TRIBUTE_GAME_FLOW_STATE_CHANGE)
    
    -- We add a PreHook to the loot window so we can not show it and just loot the containers if we are opening all contianers
    ZO_PreHook(SYSTEMS:GetObject("loot"), "UpdateLootWindow", Containerz.UpdateLootWindow_PreHook)

    Containerz.SV = ZO_SavedVars:NewAccountWide(Containerz.SavedVariablesName, Containerz.savedVarsVersion, nil, DEFAULTS, GetWorldName())

    InstallBackpackMenuFragment()
    CreateSettingsPanel()

  end
end

---------------------------------------------------------------------------------------------------------

local siegeDialogSetup = false
local function AskSiegemaster(data, textParams)

  if not siegeDialogSetup then 

    ZO_Dialogs_RegisterCustomDialog("CONFIRM_SIEGEMASTER_CONTAINERZ_OPENED",
    { gamepadInfo = {dialogType = GAMEPAD_DIALOGS.BASIC,},
      title = { text = Containerz.name,},
      mainText = {text = LCLSTR.SIEGEMASTERS_VERIFY,},
      buttons = {
        {
          text = SI_DIALOG_YES,
          callback = function(dialog) 
            Containerz.SV.lastSiegemastersCoffer = GetTimeStamp() 
            ScanForContainersToOpen()
            ShowLoaded()
          end,
        },
        {
          text = SI_DIALOG_NO,
          callback = function(dialog) 
            Containerz.SV.lastSiegemastersCoffer = LAST_DAILY_RESET - 183 
            ScanForContainersToOpen()
            ShowLoaded()
          end,
        }
      }
    })
  
    siegeDialogSetup = true
  end

  ZO_Dialogs_ShowPlatformDialog("CONFIRM_SIEGEMASTER_CONTAINERZ_OPENED", data, textParams)

end

local gladDialogSetup = false
local function AskGladiator(data, textParams)

  if not gladDialogSetup then 

		ZO_Dialogs_RegisterCustomDialog("CONFIRM_GLADIATOR_CONTAINERZ_OPENED",
		{	gamepadInfo = {dialogType = GAMEPAD_DIALOGS.BASIC,},
			title = {text = Containerz.name,},
			mainText = {text = LCLSTR.GLADIATORS_VERIFY,},
			buttons = {
				{ text = SI_DIALOG_YES,
					callback = function(dialog) 
            Containerz.SV.lastGladiatorsRucksack = GetTimeStamp() 
            zo_callLater(function() AskSiegemaster() end, 500)
          end,
				},
				{ text = SI_DIALOG_NO,
					callback = function(dialog) 
            Containerz.SV.lastGladiatorsRucksack = LAST_DAILY_RESET - 183 
            zo_callLater(function() AskSiegemaster() end, 500)
          end,
				}
			}
		})
	
		gladDialogSetup = true
	end

  ZO_Dialogs_ShowPlatformDialog("CONFIRM_GLADIATOR_CONTAINERZ_OPENED", data, textParams)
  
end

-- This only gets called once the first time the player activates into a zone
function Containerz.EVENT_PLAYER_ACTIVATED(evenCode, isInitial)

  -- If they've never run the addon before or ESO trashed the addon's Saved Variables
  -- then there will be no time stamp for the last time they opened a Gladiator's Rucksack,
  -- so display a dialog asking if they've opened a Gladiator Rucksack today.
  if not Containerz.SV.lastGladiatorsRucksack then AskGladiator()

  -- If they've never run the addon before or ESO trashed the addon's Saved Variables
  -- then there will be no time stamp for the last time they opened a Gladiator's Rucksack,
  -- so display a dialog asking if they've opened a Gladiator Rucksack today.
  elseif not Containerz.SV.lastSiegemastersCoffer then AskSiegemaster()
  else
      ScanForContainersToOpen()
      zo_callLater(function() ShowLoaded() end, 2500)
  end

  EVENT_MANAGER:UnregisterForEvent(Containerz.name, EVENT_PLAYER_ACTIVATED)

end

-- Make sure to see if ShouldOpen() has changed for any Transmute Geodes in the player's backpack
function Containerz.EVENT_CURRENCY_UPDATE(eventCode, currencyType, currencyLocation, newAmount, oldAmount, reason, reasonSupplementaryInfo)
  
  -- This gets called on first run so ignore on first run when both are nil
  if not Containerz.SV.lastGladiatorsRucksack or not Containerz.SV.lastSiegemastersCoffer then return end
  
  if(isOpeningAll == false and currencyType == CURT_CHAOTIC_CREATIA) then
    ScanForContainersToOpen()
  end
end

---------------------------------------------------------------------------------------------------------
local itemIdMin = 114000 -- Anything less than this seems to be old unused stuff
local itemIdMax = 230000 -- Currently max outt at 225047 but ZOS is always adding new items

local function ListAllContainers(itemIdMax, intervalMs)
    local currentId = itemIdMin
    local updateName = "Containerz_ListAllContainers"
    d("Starting Containerz_ListAllContainers")
    intervalMs = intervalMs or 50
    EVENT_MANAGER:RegisterForUpdate(updateName, intervalMs, function()
        if currentId > itemIdMax then
            EVENT_MANAGER:UnregisterForUpdate(updateName)
            d("ctz l: Done.")
            return
        end
        
        local linkStr = "|H1:item:_item_Id_:122:1:0:0:0:5:10000:0:0:0:0:0:0:1:0:0:1:0:0:0|h|h"
        local itemLink = string.gsub(linkStr, "_item_Id_", tostring(currentId))
        if currentId % 1000 == 0 then d(string.format("ctz l: %d", currentId)) end
        if IsItemLinkContainer(itemLink) then
          local itemName = GetItemLinkName(itemLink)
          d(string.format("%d: %s", currentId, itemLink))
        end

        currentId = currentId + 1
    end)
end

local function ListAllGeodes(itemIdMax, intervalMs)
    local currentId = itemIdMin
    local updateName = "Containerz_ListAllGeodes"
    EVENT_MANAGER:RegisterForUpdate(updateName, intervalMs, function()
        if currentId > itemIdMax then
            EVENT_MANAGER:UnregisterForUpdate(updateName)
            d("ctz g: Done.")
            return
        end
        
        if currentId % 1000 == 0 then d(string.format("ctz g: %d", currentId)) end

        local linkStr = "|H1:item:_item_Id_:122:1:0:0:0:5:10000:0:0:0:0:0:0:1:0:0:1:0:0:0|h|h"
        local itemLink = string.gsub(linkStr, "_item_Id_", tostring(currentId))
        if string.find(itemName, "Transmutation Geode") then 
          -- It's transmutes geode, so pull the max transmutes number out of its name
          -- It's in parentheses and if it's a range, the left side is a dash instead of open parentheses
          -- look for a dash first, if no dash get the open paren.
          local maxTransmutes = 0
          local s = string.find(itemName, "%-")
          if s == nil then s = string.find(itemName, "%(") end
          local e = string.find(itemName, "%)")
          if s and e then maxTransmutes = tonumber(itemName:sub(s+1, e-1)) end
          d(string.format("  [%d] = %d, -- %s", id, maxTransmutes, itemName)) 
        end

        currentId = currentId + 1

    end)
end

local function ListAllXPScrolls(itemIdMax, intervalMs)
    local currentId = itemIdMin
    local updateName = "Containerz_ListAllXPScrolls"
    EVENT_MANAGER:RegisterForUpdate(updateName, intervalMs, function()
        if currentId > itemIdMax then
            EVENT_MANAGER:UnregisterForUpdate(updateName)
            d("ctz x: Done.")
            return
        end

        if currentId % 1000 == 0 then d(string.format("ctz g: %d", currentId)) end
        
        local linkStr = "|H1:item:_item_Id_:122:1:0:0:0:5:10000:0:0:0:0:0:0:1:0:0:1:0:0:0|h|h"

        local itemLink = string.gsub(linkStr, "_item_Id_", tostring(id))
        local itemName = GetItemLinkName(itemLink)
        local substring = "experience"
        if itemName:lower():find(substring:lower(), 1, true) ~= nil then
          d(string.format("%d: %s", id, itemName))
        end

        currentId = currentId + 1
    end)
end

local function SplitBySpace(s)
    local t = {}
    for word in string.gmatch(s, "%S+") do
        t[#t + 1] = word
    end
    return t
end

SLASH_COMMANDS["/ctz"] = function(extra)
  local params = {}
  if extra then
      params = SplitBySpace(string.lower(extra))
  end
  local cmd = params[1] or ""
    
  if cmd == "" then
    d(" ")
    d("Usage: ")
    d("  /ctz ")
    d("       c [Show all containers in my backpack]")
    d("       i nnn [Show containers with itemId = nnn]")
    d("       d [Show current daily rucksacks state]")
    d("       r [Reset daily rucksacks state]")
    d(" ")
    d("WARNING: The following options may take a long time ")
    d("         and will temporarily make it look like your ")
    d("         game is hung and not responsive! Be patient!")
    d(" ")
    d("       l [list all container types in the game]")
    d("       g [list all transmute geode types in the game]")
    d("       x [list all XP scroll types in the game]")

    d(" ")

  elseif cmd == "r" then
    AskGladiator()

  elseif cmd == "c" then
    ContainersInBackpack()

  elseif cmd == "d" then
    ShowLoaded()

  elseif cmd == "g" then -- Show transmute geode containers in backpack
    ListAllGeodes(itemIdMax, 30)

  elseif cmd == "l" then -- list all containers in ESO
    ListAllContainers(itemIdMax, 30)

  elseif cmd == "x" then -- Find XP things in ESO items
    ListAllXPScrolls(itemIdMax, 30)

  elseif cmd == "i" then -- Show items in backback by ID

    -- params[2] is the Id of the item they want to find 
    local id = nil
    if params[2] then
      id = tonumber(params[2])
    end
    if not id or id <= 0 then
      d("ERROR: Invalid itemId") 
    end
    
    local slot = 0
    local outSlot = 0
    local link = ''

    repeat
      link, slot = FindNextInBackpackById(id, slot)
      if link then 
        d(string.format("Slot: %d %s (%d)", slot, link, id))
        slot = slot + 1 -- Go to next slot past found item
      end
    until(not link)

  elseif cmd == "k" then -- internal only
    local achievement = "|H1:achievement:3995:50:1718859679|h|h"
    d(string.format("%s = %s", GetAchievementNameFromLink(achievement), GetAchievementIdFromLink(achievement)))

  elseif cmd == "n" then -- Find item(s) by substring
    -- Adding '-a' (e.g. /ctz n Rucksack -a) will find all not just 1st one
    -- string comparison is NOT case sensitive
    -- params[2] is the Id of the item they want to find 
    
    if not params[2] then 
      d("ERROR: /ctz n Rucksack to find all \"Rucksack\" in your bag")
      return 
    end

    local name = (params[2])    
    local slot = 0
    local outSlot = 0
    local link = ''
    local id = 0

    repeat
      link, id, slot = FindNextInBackpackByName(name, slot)
      if link then 
        d(string.format("Slot: %d %s (%d)", slot, link, id))
        slot = slot + 1 -- Go to next slot past found item
      end
    until(not link)

  end

end

---------------------------------------------------------------------------------------------------------
-- Entry point
EVENT_MANAGER:RegisterForEvent(Containerz.name, EVENT_ADD_ON_LOADED, Containerz.EVENT_ADD_ON_LOADED)