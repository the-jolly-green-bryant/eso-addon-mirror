AutoDestroy = {}
AutoDestroy.name = "AutoDestroy"

local AD = AutoDestroy

local defaultSavedVariables = {
    autoDestroyEnabled = false,
    destroyMaps = false,
    itemsList = {}, 
}

local queuedEnvelopes = {}
local queuedEnvelopeKeys = {}
local isInCombat = false


local TREASURE_ENVELOPES = {
    [224681] = true,
}


local NAMES = {}
for boxId, _ in pairs(TREASURE_ENVELOPES) do
    local itemLink = ("|H1:item:%d:0:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:10000:0|h|h"):format(boxId)
    local name = GetItemLinkName(itemLink)
    NAMES[name] = true
end

local TRASHURE = {
       --Stonefalls
       [43655] = true,
	   [43656] = true,
	   [43657] = true,
	   [43658] = true,
	   [43659] = true,
	   [43660] = true,
	   --Grathwood
	   [43631] = true,
	   [43632] = true,
	   [43633] = true,
	   [43634] = true,
	   [43635] = true,
	   [43636] = true,
	   --Deshaan
	   [43661] = true,
	   [43662] = true,
	   [43663] = true,
	   [43664] = true,
	   [43665] = true,
	   [43666] = true,
	   --Malabal Tor
	   [43643] = true,
	   [43644] = true,
	   [43645] = true,
	   [43646] = true,
	   [43647] = true,
	   [43648] = true,
	   --Khenarti Roost
	   [43695] = true,
	   [43696] = true,
	   [43697] = true,
	   [43698] = true,
	   --Auridon
	   [43625] = true,
	   [43626] = true,
	   [43627] = true,
	   [43628] = true,
	   [43629] = true,
	   [43630] = true,
	   --Greenshade
	   [43637] = true,
	   [43638] = true,
	   [43639] = true,
	   [43640] = true,
	   [43641] = true,
	   [43642] = true,
	   --Reapers March
	   [43649] = true,
	   [43650] = true,
	   [43651] = true,
	   [43652] = true,
	   [43653] = true,
	   [43654] = true,
	   --Bleakrock
	   [43699] = true,
	   [43700] = true,
	   --Bal Foyen
	   [43701] = true,
	   [43702] = true,
	   --Shadowfen
	   [43667] = true,
	   [43668] = true,
	   [43669] = true,
	   [43670] = true,
	   [43671] = true,
	   [43672] = true,
	   --Eastmarch
	   [43673] = true,
	   [43674] = true,
	   [43675] = true,
	   [43676] = true,
	   [43677] = true,
	   [43678] = true,
	   --Rift
	   [43679] = true,
	   [43680] = true,
	   [43681] = true,
	   [43682] = true,
	   [43683] = true,
	   [43684] = true,
	   --Stros Mkai
	   [43691] = true,
	   [43692] = true,
	   --Betnikh
	   [43693] = true,
	   [43694] = true,
	   --Glenumbra
	   [43507] = true,
	   [43525] = true,
	   [43527] = true,
	   [43600] = true,
	   [43509] = true,
	   [43526] = true,
	   --Stormhaven
	   [43601] = true,
	   [43602] = true,
	   [43603] = true,
	   [43604] = true,
	   [43605] = true,
	   [43606] = true,
	   --Rivenspire
	   [43607] = true,
	   [43608] = true,
	   [43609] = true,
	   [43610] = true,
	   [43611] = true,
	   [43612] = true,
	   --Alikr
	   [43613] = true,
	   [43614] = true,
	   [43615] = true,
	   [43616] = true,
	   [43617] = true,
	   [43618] = true,
	   --Bangkorai
	   [43619] = true,
	   [43620] = true,
	   [43621] = true,
	   [43622] = true,
	   [43623] = true,
	   [43624] = true,
	   --Coldharbour
	   [43685] = true,
	   [43686] = true,
	   [43687] = true,
	   [43688] = true,
	   [43689] = true,
	   [43690] = true,
	   --Cyrodiil
	   [43703] = true,
	   [43704] = true,
	   [43705] = true,
	   [43706] = true,
	   [43707] = true,
	   [43708] = true,
	   [43709] = true,
	   [43710] = true,
	   [43711] = true,
	   [43712] = true,
	   [43713] = true,
	   [43714] = true,
	   [43715] = true,
	   [43716] = true,
	   [43717] = true,
	   [43718] = true,
	   [43719] = true,
	   [43720] = true,
	   --Craglorn
	   [43721] = true,
	   [43722] = true,
	   [43723] = true,
	   [43724] = true,
	   [43725] = true,
	   [43726] = true,
	   --Wrothgar
	   [43727] = true,
	   [43728] = true,
	   [43729] = true,
	   [43730] = true,
	   [43731] = true,
	   [43732] = true,
	   --Hews Bane
	   [43733] = true,
	   [43734] = true,
	   --Gold Coast
	   [43735] = true,
	   [43736] = true,
	   --Vvardenfell
	   [43737] = true,
	   [43738] = true,
	   [43739] = true,
	   [43740] = true,
	   [43741] = true,
	   [43742] = true,
	   --Clockwork City
	   [43746] = true,
	   [43747] = true,
	   --Summerset
	   [43748] = true,
	   [43749] = true,
	   [43750] = true,
	   [43751] = true,
	   [43752] = true,
	   [43753] = true,
	   --Murkmire
	   [145510] = true,
	   [145512] = true,
	   --Northen Elsweyr
	   [151613] = true,
	   [151614] = true,
	   [151615] = true,
	   [151616] = true,
	   [151617] = true,
	   [151618] = true,
	   --Southern Elsweyr
	   [156716] = true,
	   [156715] = true,
	   --Western Skyrim
	   [166040] = true,
	   [166041] = true,
	   [166042] = true,
	   [166043] = true,
	   --Blackreach
	   [166038] = true,
	   [166039] = true,
	   --Arktzand
	   [171475] = true,
	   --Reach
	   [171474] = true,
	   --Blackwood
	   -- [175547] = true,       
	   -- [175548] = true,
	   -- [175549] = true,
	   -- [175550] = true,
	   -- [175551] = true,
	   -- [175552] = true,
	   --Deadlands
	   -- [183005] = true,
	   -- [183006] = true,
	   --High Isle
	   -- [187671] = true,
	   -- [187672] = true,
	   -- [187673] = true,
	   -- [187674] = true,
	   -- [187675] = true,
	   -- [187676] = true,
	   --Galen
	    [192370] = true,
	    [192371] = true,
	   --Telvanni Peninsula
	   -- [198097] = true,
	   -- [198098] = true,
	   -- [198099] = true,
	   -- [198100] = true,
	   --Apocrypha
	   -- [198101] = true,
	   -- [198102] = true,
	   --West Weald
	   -- [207964] = true,
	   -- [207965] = true,
	   -- [207966] = true,
	   -- [207967] = true,
	   -- [207968] = true,
	   -- [207969] = true,
	   --Solstice
	   -- [217926] = true,
	   -- [217927] = true,
	   -- [217928] = true,
	   -- [223773] = true,
	   -- [223774] = true,
	   -- [223772] = true,
	   
}

local BAG_IDS = {
    [BAG_BACKPACK] = true,
}

function AD.OnLootUpdated()
    local name, _, _, _ = GetLootTargetInfo()
    if name == "" or not NAMES[name] then return end
    LootAll()
end


function AD.TryOpenOrQueueContainer(bagId, slotIndex)

    if not AD.Settings.destroyMaps then
        return
    end


    local itemLink = GetItemLink(bagId, slotIndex)
    if itemLink == "" then return end

    local itemId = GetItemLinkItemId(itemLink)
    if not TREASURE_ENVELOPES[itemId] then return end

    if isInCombat then
        local key = tostring(bagId) .. ":" .. tostring(slotIndex)
        if not queuedEnvelopeKeys[key] then
            table.insert(queuedEnvelopes, {bagId = bagId, slotIndex = slotIndex, key = key})
            queuedEnvelopeKeys[key] = true
        end
        return
    end

    local remaining = GetItemCooldownInfo(bagId, slotIndex)
	if remaining > 0 then
		zo_callLater(function()
			AD.TryOpenOrQueueContainer(bagId, slotIndex)
		end, remaining + 50)
	else
		CallSecureProtected("UseItem", bagId, slotIndex)
	end
end

function AD.ProcessQueuedEnvelopes()
    for _, slot in ipairs(queuedEnvelopes) do
        CallSecureProtected("UseItem", slot.bagId, slot.slotIndex)
    end
    queuedEnvelopes = {}
    queuedEnvelopeKeys = {}
	
	EVENT_MANAGER:UnregisterForUpdate(AutoDestroy.name .. "FinalCheck")
	EVENT_MANAGER:RegisterForUpdate(AutoDestroy.name .. "FinalCheck", 1000, function()
		for slotIndex = 0, GetBagSize(BAG_BACKPACK) - 1 do
			AD.TryOpenOrQueueContainer(BAG_BACKPACK, slotIndex)
		end
		EVENT_MANAGER:UnregisterForUpdate(AutoDestroy.name .. "FinalCheck")
	end)
end

function AD.OnCombatState(_, inCombat)
    isInCombat = inCombat
    if not inCombat then
        AD.ProcessQueuedEnvelopes()
    end
end

function AD.DestroyItem(bagId, slotIndex)
	if not AD.Settings.autoDestroyEnabled then
		return
	end

	local itemLink = GetItemLink(bagId, slotIndex)
	if not itemLink or itemLink == "" then
		return
	end

	local itemId = GetItemLinkItemId(itemLink)
	local stored = AD.Settings.itemsList[itemId]

	if stored then
		if stored == itemLink then
			DestroyItem(bagId, slotIndex)
			return
		end
	end

		if AD.Settings.destroyMaps and TRASHURE[itemId] then
			DestroyItem(bagId, slotIndex)
		end
	end

function AD.ScanAndDestroy()

    for bagId, _ in pairs(BAG_IDS) do
        local numSlots = GetBagSize(bagId)
        for slotIndex = 0, numSlots - 1 do
            AD.DestroyItem(bagId, slotIndex)
        end
    end

end

function AD.OnInventoryUpdated()
	if not AD.Settings.autoDestroyEnabled then
		return
	end

    AD.ScanAndDestroy()
end

function AD.OnSingleSlotUpdated(_, bagId, slotIndex, isNewItem, itemSoundCategory, inventoryUpdateReason, stackCountChange, triggeredByCharacterName, triggeredByDisplayName, isLastUpdateForMessage, bonusDropSource)
    if not BAG_IDS[bagId] then return end

    AD.TryOpenOrQueueContainer(bagId, slotIndex)
    AD.DestroyItem(bagId, slotIndex)
end

function AD.ShowConfirmationDialog(itemLink)
    if not itemLink or itemLink == "" then return end

    local itemId = GetItemLinkItemId(itemLink)
    local itemName = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetItemLinkName(itemLink))

    local dialogParams = {
        callback = function(...)
            AD.Settings.itemsList[itemId] = itemLink
            AD.ScanAndDestroy()
        end,
        mainText = ('You are about to |cFF0000DESTROY|r |cFFFFFF"%s"|r, it will be also marked for permanent destroy. You can remove it from the list in addon settings later. Are you sure?'):format(itemName)
    }

    ZO_Dialogs_ShowDialog('AUTO_DESTROY_CONFIRMATION_DIALOG', dialogParams)
end

function AD.RegisterDialog()
	ZO_CreateStringId("AUTO_DESTROY_DIALOG_HEADER", "Auto Destroy")


	ESO_Dialogs["AUTO_DESTROY_CONFIRMATION_DIALOG"] =
	{
		gamepadInfo =
		{
			dialogType = GAMEPAD_DIALOGS.BASIC,
		},
		title =
		{
			text = AUTO_DESTROY_DIALOG_HEADER,
		},
		mainText =
		{
			text = function(dialog)
				return dialog.data.mainText
			end,
		},
		mustChoose = true,
		buttons =
		{
			[1] =
			{
				text = SI_DIALOG_ACCEPT,
				callback = function(dialog)
					dialog.data.callback()
				end,
			},
			[2] =
			{
				text = SI_DIALOG_CANCEL,
			},
		},
		finishedCallback = function(dialog)
			if dialog.data.finishingCallback then
				dialog.data.finishingCallback()
			end
		end,
	}
end

function AD.RegisterContextMenu()

	ZO_CreateStringId("SI_BINDING_NAME_SOMETHING", "Auto Destroy")

		local function AddItem(inventorySlot, slotActions)
			local bagId, slotIndex = ZO_Inventory_GetBagAndIndex(inventorySlot)
			if not bagId then return end

			slotActions:AddCustomSlotAction(SI_BINDING_NAME_SOMETHING, function()
				local itemLink = GetItemLink(bagId, slotIndex)
				if not itemLink then return end

				AD.ShowConfirmationDialog(itemLink)
			end , "")
		end

	LibCustomMenu:RegisterContextMenu(AddItem, LibCustomMenu.CATEGORY_LATE)

end


function AD.OnAddonLoaded(event, addonName)
    if addonName ~= AutoDestroy.name then return end
	
	AD.Settings = ZO_SavedVars:NewAccountWide("AutoDestroy_SV", 1, nil, defaultSavedVariables)
	
	EVENT_MANAGER:UnregisterForEvent(AD.name, EVENT_ADD_ON_LOADED)
	
	AD.RegisterDialog()	
	AD.RegisterContextMenu()

    -- Register for inventory update events
    EVENT_MANAGER:RegisterForEvent(AD.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, AD.OnSingleSlotUpdated)
	EVENT_MANAGER:RegisterForEvent(AD.name, EVENT_INVENTORY_FULL_UPDATE, AD.OnInventoryUpdated)
	EVENT_MANAGER:RegisterForEvent(AD.name, EVENT_PLAYER_COMBAT_STATE, AD.OnCombatState)
	 
    local myPanel = AD.SetupSettings()

    CALLBACK_MANAGER:RegisterCallback("LAM-PanelOpened", function(panel)
        if panel ~= myPanel then return end
        AD.RefreshDropdown()
    end)

    if AD.Settings.autoDestroyEnabled then
        AD.ScanAndDestroy()
    end
	
	ZO_PreHook(SYSTEMS:GetObject("loot"), "UpdateLootWindow", AD.OnLootUpdated)
end

EVENT_MANAGER:RegisterForEvent(AD.name, EVENT_ADD_ON_LOADED, AD.OnAddonLoaded)
