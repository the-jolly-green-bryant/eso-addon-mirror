-- Initalize RunesVoice to use as Table to store
-- the Addon in it.
if RunesVoice == nil then RunesVoice = {} end

-- Import LibAddonMenu
local LAM = LibStub("LibAddonMenu-2.0")

-- Handle EVENT_ADDON_ON_LOAD events
-- If name is Addons name initalize this Addon
function RunesVoice:onLoaded(event, name)
  -- Check if this Addon is loaded
  if name ~= "RunesVoice" then return end
  -- Initalize Variables
  self.variables.saved = ZO_SavedVars:New("RunesVoiceVariables", self.variables.version, nil, self.variables.defaults)
  -- Initalize ZO_QueuedSoundPlayer
  self.soundPlayer = ZO_QueuedSoundPlayer:New()
  self.soundPlayer:SetFinishedAllSoundsCallback(function() self:onAllSoundsFinished() end)
  -- Register AddonMenu
  LAM:RegisterAddonPanel("RVO", self.menu[1][1])
	LAM:RegisterOptionControls("RVO", self.menu[1][2])
end

-- Handle EVENT_LOOT_RECIEVED events
-- Add Sound to the PlayerQueue when triggerd
function RunesVoice:onLootRecieved(eventCode, receivedBy, itemName, quantity, itemSound, lootType, isSelf, isPickpocketLoot, questItemIcon, itemId)
  slotId = getItemSlotId(itemName)
	-- Check if a Rune is looted
	if (GetItemType(BAG_BACKPACK, slotId) == ITEMTYPE_ENCHANTING_RUNE_ASPECT or GetItemType(BAG_BACKPACK, slotId) == ITEMTYPE_ENCHANTING_RUNE_POTENCY or GetItemType(BAG_BACKPACK, slotId) == ITEMTYPE_ENCHANTING_RUNE_ESSENCE) then
		-- Get associated Sound
    soundName, soundLength = GetRunestoneSoundInfo(BAG_BACKPACK, slotId)
    -- Add Sound to the QueuePlayer
    RunesVoice:debug("info", "Add Sound: "..soundName.." (length: "..soundLength..".")
		self.soundPlayer:PlaySound(soundName, soundLength)
	end
end

-- Handle FinishedAllSounds event
function RunesVoice:onAllSoundsFinished()
  -- Log when player has played all sounds in queue
  RunesVoice:debug("info", "All sounds played.")
end

-- Handle EVENT_CRAFT_COMPLETED event
function RunesVoice:onCraftCompleted()
  -- Check if enchanting animation is shown and the user enabled RapidChant
  if SCENE_MANAGER:IsShowing("enchanting") and self.variables.saved.rach_enable then
    -- Cancle the animation
    CALLBACK_MANAGER:FireCallbacks("CraftingAnimationsStopped")
    RunesVoice:debug("info", "Crafting completed. Cancle animations.")
  end
end

-- Get SlotId by name
function getItemSlotId(itemName)
	-- Get maximum bag size
	local n = GetBagSize(BAG_BACKPACK)
	-- Loop through all bag slot
	for i = 0, n, 1 do
    -- Check if current item in bag slot is wanted
		if GetItemLink(BAG_BACKPACK , i) == itemName then
      -- return bag slot
			return i
		end
	end
	-- Item wasn't found return -1
  -- error
  RunesVoice:debug("warning", "Item: "..itemName.." was not found.")
	return -1
end

-- Register EventListener for
-- onLoaded to start the Addon
EVENT_MANAGER:RegisterForEvent("RunesVoiceOnLoad", EVENT_ADD_ON_LOADED, function(event, name) RunesVoice:onLoaded(event, name) end)
-- onLootRecieved to play a Sound when Rune is picked up
EVENT_MANAGER:RegisterForEvent("RunesVoiceLootReceived", EVENT_LOOT_RECEIVED, function(event, receivedBy, itemName, quantity, itemSound, lootType, isSelf, isPickpocketLoot, questItemIcon, itemId) RunesVoice:onLootRecieved(event, receivedBy, itemName, quantity, itemSound, lootType, isSelf, isPickpocketLoot, questItemIcon, itemId) end)
-- onCraftCompleted to skip the animation when enchanting is completed
EVENT_MANAGER:RegisterForEvent("RunesVoiceCraftCompleted", EVENT_CRAFT_COMPLETED, function(event, craftSkill) RunesVoice:onCraftCompleted() end)
