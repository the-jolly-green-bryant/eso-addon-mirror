KyzderpsDerps = KyzderpsDerps or {}
KyzderpsDerps.Opener = KyzderpsDerps.Opener or {}
local Opener = KyzderpsDerps.Opener

---------------------------------------------------------------------
local toLoot = {}
local toLootNames = {} -- Will be populated when a container is opened, to verify LootAll on correct container

local toLootWrithing = {} -- Names to be populated
local queuedWrithing = {} -- slotIndex of writhing event container to open, to stop LootAll from opening them after empty
local function IsWrithingDone()
    if (next(queuedWrithing)) then
        return false
    end
    return true
end


---------------------------------------------------------------------
-- Loot All items once the container is opened
---------------------------------------------------------------------
local function OnOpenLootWindow()
    -- KyzderpsDerps:dbg("update loot window")
    local title = GetLootTargetInfo()
    if (toLootNames[title]) then
        LootAll()
    elseif (toLootWrithing[title] and not IsWrithingDone()) then
        LootAll()
    end

    if (next(toLootWrithing) and IsWrithingDone()) then
        toLootWrithing = {}
        KyzderpsDerps:msg("Done looting Writhing Wall event crafting boxes")
    end
end


---------------------------------------------------------------------
-- Open the container
---------------------------------------------------------------------
local function CanOpenContainer()
    if (GetSlotCooldownInfo(1) > 0 or
        IsInteractionUsingInteractCamera() or
        SCENE_MANAGER:GetCurrentScene().name == "interact" or
        SCENE_MANAGER:GetCurrentScene().name == "mailInbox" or
        IsUnitSwimming("player") or
        IsUnitInCombat("player") or
        IsLooting()) then
        return false
    else
        return true
    end
end

local CONTAINER_TYPES = {
    [ITEMTYPE_CONTAINER] = true,
    [ITEMTYPE_CONTAINER_CURRENCY] = true,
    [ITEMTYPE_CONTAINER_STACKABLE] = true,
}

local function OpenContainer(bagId, slotIndex)
    if (not CONTAINER_TYPES[GetItemType(bagId, slotIndex)]) then
        local itemLink = GetItemLink(bagId, slotIndex, LINK_STYLE_BRACKETS)
        KyzderpsDerps:dbg("|cFF0000Not a container?! maybe event double fired: " .. itemLink)
        return
    end

    if (CanOpenContainer()) then
        KyzderpsDerps:dbg("trying to open container")
        queuedWrithing[slotIndex] = nil
        if IsProtectedFunction("UseItem") then
            CallSecureProtected("UseItem", bagId, slotIndex)
        else
            UseItem(bagId, slotIndex)
        end
    else
        KyzderpsDerps:dbg("waiting to open container")
        zo_callLater(function()
            OpenContainer(bagId, slotIndex)
        end, 1000)
    end
end

-- EVENT_INVENTORY_SINGLE_SLOT_UPDATE (number eventCode, Bag bagId, number slotIndex, boolean isNewItem, ItemUISoundCategory itemSoundCategory, number inventoryUpdateReason, number stackCountChange)
local function OnInventorySlotUpdate(_, bagId, slotIndex, isNewItem, _, _, _)
    local itemId = GetItemId(bagId, slotIndex)
    if (toLoot[itemId] and not IsItemStolen(bagId, slotIndex)) then
        toLootNames[GetItemName(bagId, slotIndex)] = true
        zo_callLater(function()
            OpenContainer(bagId, slotIndex)
        end, KyzderpsDerps.savedOptions.opener.delay)
    end
end

local function OpenAllInBackpack()
    local bagCache = SHARED_INVENTORY:GetOrCreateBagCache(BAG_BACKPACK)
    for _, item in pairs(bagCache) do
        if (toLoot[GetItemId(item.bagId, item.slotIndex)] and not IsItemStolen(item.bagId, item.slotIndex)) then
            toLootNames[GetItemName(item.bagId, item.slotIndex)] = true
            OpenContainer(item.bagId, item.slotIndex)
        end
    end
end
Opener.OpenAllInBackpack = OpenAllInBackpack

local writhingCrafting = {
    [219794] = true,
    [219800] = true,
    [219792] = true,

    [219796] = true, -- Enchanting
    [219798] = true, -- Provisioning
    [219790] = true, -- Alchemy
}
local function OpenAllWrithingCrafting()
    local bagCache = SHARED_INVENTORY:GetOrCreateBagCache(BAG_BACKPACK)
    for _, item in pairs(bagCache) do
        if (writhingCrafting[GetItemId(item.bagId, item.slotIndex)]) then
            toLootWrithing[GetItemName(item.bagId, item.slotIndex)] = true
            queuedWrithing[item.slotIndex] = true
            writhingCrafting[item.slotIndex] = true
            OpenContainer(item.bagId, item.slotIndex)
        end
    end
end
Opener.OpenAllWrithingCrafting = OpenAllWrithingCrafting


---------------------------------------------------------------------
-- Init
---------------------------------------------------------------------
local prehooked = false
function Opener.Initialize()
    KyzderpsDerps:dbg("    Initializing Opener module...")

    toLoot = {}
    toLootNames = {}
    local shouldRegister = false
    if (KyzderpsDerps.savedOptions.opener.openMirriBag) then
        toLoot[178470] = true
        shouldRegister = true
    end
    if (KyzderpsDerps.savedOptions.opener.openGunnySack) then
        toLoot[43757] = true
        shouldRegister = true
    end
    if (KyzderpsDerps.savedOptions.opener.openToxinSatchel) then
        toLoot[79675] = true
        shouldRegister = true
    end
    if (KyzderpsDerps.savedOptions.opener.openPurpleZenithar) then
        toLoot[187701] = true
        shouldRegister = true
    end
    if (KyzderpsDerps.savedOptions.opener.openZenitharCurrency) then
        toLoot[187700] = true
        shouldRegister = true
    end
    if (KyzderpsDerps.savedOptions.opener.openPelinalsBoonBox and (KyzderpsDerps.savedOptions.opener.openPelinalsBoonBoxInIC or not IsInImperialCity())) then
        toLoot[192612] = true
        shouldRegister = true
    end
    if (KyzderpsDerps.savedOptions.opener.openPurplePlunderSkull) then
        toLoot[190037] = true
        shouldRegister = true
    end
    if (KyzderpsDerps.savedOptions.opener.openCrowTouchedCoffer) then
        toLoot[133559] = true
        shouldRegister = true
    end
    if (KyzderpsDerps.savedOptions.opener.openResearchPortfolio) then
        toLoot[197790] = true
        shouldRegister = true
    end
    if (KyzderpsDerps.savedOptions.opener.openFallenPack) then
        toLoot[188144] = true
        shouldRegister = true
    end
    -- Probably don't do this, because it's stolen
    -- if (KyzderpsDerps.savedOptions.opener.openEmberWallet) then
    --     toLoot[187747] = true
    --     shouldRegister = true
    -- end

    for _, id in ipairs(KyzderpsDerps.savedOptions.opener.extraIds) do
        toLoot[id] = true
        shouldRegister = true
    end

    if (shouldRegister) then
        EVENT_MANAGER:RegisterForEvent(KyzderpsDerps.name .. "OpenerSlotUpdate", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, OnInventorySlotUpdate)
        EVENT_MANAGER:AddFilterForEvent(KyzderpsDerps.name .. "OpenerSlotUpdate", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_INVENTORY_UPDATE_REASON, INVENTORY_UPDATE_REASON_DEFAULT)

        if (not prehooked) then
            ZO_PreHook(SYSTEMS:GetObject("loot"), "UpdateLootWindow", OnOpenLootWindow)
            prehooked = true
        end
    else
        EVENT_MANAGER:UnregisterForEvent(KyzderpsDerps.name .. "OpenerSlotUpdate", EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
    end
end


---------------------------------------------------------------------
-- Settings
---------------------------------------------------------------------
function Opener.GetSettings()
    return {
        {
            type = "description",
            title = "",
            text = "Automatically open and loot all from specific containers that you obtain. You can also use |c99FF99/kdd openall|r to re-scan your inventory and open existing containers that you have set to be opened.",
            width = "full",
        },
        {
            type = "slider",
            name = "Delay before opening",
            tooltip = "Number of milliseconds to wait after obtaining a lootable container, before attempting to open it",
            min = 0,
            max = 2000,
            step = 100,
            default = 0,
            width = "full",
            getFunc = function() return KyzderpsDerps.savedOptions.opener.delay end,
            setFunc = function(value)
                KyzderpsDerps.savedOptions.opener.delay = value
            end,
        },
        {
            type = "checkbox",
            name = "Auto open Hidden Treasure Bag",
            tooltip = "When you loot a Hidden Treasure Bag from Mirri's bonus, automatically open and loot it",
            default = false,
            getFunc = function() return KyzderpsDerps.savedOptions.opener.openMirriBag end,
            setFunc = function(value)
                KyzderpsDerps.savedOptions.opener.openMirriBag = value
                Opener.Initialize()
            end,
            width = "full",
        },
        -- {
        --     type = "checkbox",
        --     name = "Auto open Hidden Wallet",
        --     tooltip = "When you loot a Hidden Wallet from Ember's bonus, automatically open and loot it",
        --     default = false,
        --     getFunc = function() return KyzderpsDerps.savedOptions.opener.openEmberWallet end,
        --     setFunc = function(value)
        --         KyzderpsDerps.savedOptions.opener.openEmberWallet = value
        --         Opener.Initialize()
        --     end,
        --     width = "full",
        -- },
        {
            type = "checkbox",
            name = "Auto open Wet Gunny Sack",
            tooltip = "When you loot a Wet Gunny Sack from fishing, automatically open and loot it",
            default = false,
            getFunc = function() return KyzderpsDerps.savedOptions.opener.openGunnySack end,
            setFunc = function(value)
                KyzderpsDerps.savedOptions.opener.openGunnySack = value
                Opener.Initialize()
            end,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Auto open Toxin Satchel",
            tooltip = "When you loot a Toxin Satchel, automatically open and loot it",
            default = false,
            getFunc = function() return KyzderpsDerps.savedOptions.opener.openToxinSatchel end,
            setFunc = function(value)
                KyzderpsDerps.savedOptions.opener.openToxinSatchel = value
                Opener.Initialize()
            end,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Auto open Zenithar's Delightful Parcel",
            tooltip = "When you loot a (purple) Zenithar's Delightful Parcel, automatically open and loot it. Will NOT loot stolen ones!",
            default = false,
            getFunc = function() return KyzderpsDerps.savedOptions.opener.openPurpleZenithar end,
            setFunc = function(value)
                KyzderpsDerps.savedOptions.opener.openPurpleZenithar = value
                Opener.Initialize()
            end,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Auto open Zenithar's Bounty",
            tooltip = "When you loot a Zenithar's Bounty (the gold bag containing currency), automatically open and loot it",
            default = false,
            getFunc = function() return KyzderpsDerps.savedOptions.opener.openZenitharCurrency end,
            setFunc = function(value)
                KyzderpsDerps.savedOptions.opener.openZenitharCurrency = value
                Opener.Initialize()
            end,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Auto open Pelinal's Boon Box",
            tooltip = "When you loot a Pelinal's Boon Box, automatically open and loot it",
            default = false,
            getFunc = function() return KyzderpsDerps.savedOptions.opener.openPelinalsBoonBox end,
            setFunc = function(value)
                KyzderpsDerps.savedOptions.opener.openPelinalsBoonBox = value
                Opener.Initialize()
            end,
            width = "full",
        },
        {
            type = "checkbox",
            name = "    ... in Imperial City",
            tooltip = "Toggles whether to open Pelinal's boxes while in Imperial City, since the boxes can contain some Tel Var",
            default = false,
            getFunc = function() return KyzderpsDerps.savedOptions.opener.openPelinalsBoonBoxInIC end,
            setFunc = function(value)
                KyzderpsDerps.savedOptions.opener.openPelinalsBoonBoxInIC = value
                Opener.Initialize()
            end,
            width = "full",
            disabled = function() return not KyzderpsDerps.savedOptions.opener.openPelinalsBoonBox end,
        },
        {
            type = "checkbox",
            name = "Auto open purple Plunder Skull",
            tooltip = "When you loot a purple Plunder Skull, automatically open and loot it",
            default = false,
            getFunc = function() return KyzderpsDerps.savedOptions.opener.openPurplePlunderSkull end,
            setFunc = function(value)
                KyzderpsDerps.savedOptions.opener.openPurplePlunderSkull = value
                Opener.Initialize()
            end,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Auto open Crow-Touched Clockwork Coffer",
            tooltip = "When you loot a Crow-Touched Clockwork Coffer, automatically open and loot it",
            default = false,
            getFunc = function() return KyzderpsDerps.savedOptions.opener.openCrowTouchedCoffer end,
            setFunc = function(value)
                KyzderpsDerps.savedOptions.opener.openCrowTouchedCoffer = value
                Opener.Initialize()
            end,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Auto open Research Portfolio",
            tooltip = "When you loot a Research Portfolio from Azandar's bonus, automatically open and loot it",
            default = false,
            getFunc = function() return KyzderpsDerps.savedOptions.opener.openResearchPortfolio end,
            setFunc = function(value)
                KyzderpsDerps.savedOptions.opener.openResearchPortfolio = value
                Opener.Initialize()
            end,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Auto open Fallen Knight's Pack",
            tooltip = "When you loot a Fallen Knight's Pack from Isobel's bonus, automatically open and loot it",
            default = false,
            getFunc = function() return KyzderpsDerps.savedOptions.opener.openFallenPack end,
            setFunc = function(value)
                KyzderpsDerps.savedOptions.opener.openFallenPack = value
                Opener.Initialize()
            end,
            width = "full",
        },
        {
            type = "description",
            title = "Additional containers to open",
            text = "You can add more IDs for containers to open here. To find the ID, link the item to chat, like |H1:item:217732:122:1:0:0:0:0:0:0:0:0:0:0:0:1:0:0:1:0:0:0|h|h, but don't send the message. Cut and paste the item link somewhere else, which will show it in plain text, and it will look something like ||H1:item:217732:122:1:0:0:0:0:0:0:0:0:0:0:0:1:0:0:1:0:0:0||h||h. The ID is the number after \"item\", in this case \"217732\". You can also find IDs by searching on a site like UESP with their item database.",
            width = "full",
        },
        {
            type = "editbox",
            name = "Additional container IDs, separated by commas",
            default = "",
            getFunc = function()
                return table.concat(KyzderpsDerps.savedOptions.opener.extraIds, ",")
            end,
            setFunc = function(value)
                local ids = {}
                for _, id in ipairs({zo_strsplit(",", value)}) do
                    id = tonumber(id)
                    if (id) then
                        table.insert(ids, id)
                    end
                end
                KyzderpsDerps.savedOptions.opener.extraIds = ids
                Opener.Initialize()
            end,
            isExtraWide = true,
            isMultiline = true,
            width = "full",
        },
    }
end
