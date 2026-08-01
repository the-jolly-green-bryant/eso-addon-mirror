local ADDON_NAME = "HousePreviewHotkey"
local HousePreviewHotkey = {}
HousePreviewHotkey.name = ADDON_NAME

-- Default saved variables (three slots)
local defaults = {
    slot1 = 18,  -- Gardner House (personal favorite; it's small and not a popular purchase)
    slot2 = nil,
    slot3 = nil,
}

-- Alphabetized list with verified house IDs as of 2026-02-14 <3
local houseList = {
    { name = "Agony's Ascent", id = 93 },
    { name = "Ald Velothi Harbor House", id = 44 },
    { name = "Alinor Crest Townhouse", id = 59 },
    { name = "Amaya Lake Lodge", id = 43 },
    { name = "Ancient Anchor Berth", id = 95 },
    { name = "Antiquarian's Alpine Gallery", id = 81 },
    { name = "Autumn's-Gate", id = 28 },
    { name = "Barbed Hook Private Room", id = 4 },
    { name = "Bastion Sanguinaris", id = 79 },
    { name = "Bismuth Steam Baths", id = 117 },
    { name = "Black Vine Villa", id = 7 },
    { name = "Blackwood", id = 88 },
    { name = "Bouldertree Refuge", id = 14 },
    { name = "Captain Margaux's Place", id = 16 },
    { name = "Castle Skingrad", id = 116 },
    { name = "Cliffshade", id = 8 },
    { name = "Coldharbour Surreal Estate", id = 47 },
    { name = "Colossal Aldmeri Grotto", id = 60 },
    { name = "Cradle of the Worm Colossus", id = 122 },
    { name = "Cyrodilic Jungle House", id = 25 },
    { name = "Daggerfall Overlook", id = 38 },
    { name = "Dawnshadow", id = 24 },
    { name = "Domus Phrasticus", id = 26 },
    { name = "Druidspring Conservatory", id = 123 },
    { name = "Earthtear Cavern", id = 41 },
    { name = "Ebonheart Chateau", id = 39 },
    { name = "Elinhir Private Arena", id = 66 },
    { name = "Emissary's Enclave", id = 101 },
    { name = "Enchanted Snow Globe Home", id = 63 },
    { name = "Exorcised Coven Cottage", id = 49 },
    { name = "Flaming Nix Deluxe Garret", id = 6 },
    { name = "Fogbreak Lighthouse", id = 98 },
    { name = "Forgemaster Falls", id = 75 },
    { name = "Forsaken Stronghold", id = 33 },
    { name = "Frostvault Chasm", id = 65 },
    { name = "Gardner House", id = 18 },
    { name = "Gladesong Arboretum", id = 105 },
    { name = "Golden Gryphon Garret", id = 58 },
    { name = "Grand Psijic Villa", id = 62 },
    { name = "Grand Topal Hideaway", id = 40 },
    { name = "Grymharth's Woe", id = 29 },
    { name = "Hakkvild's High Hall", id = 48 },
    { name = "Hammerdeath Bungalow", id = 31 },
    { name = "Hiddenspring Cottage", id = 120 },
    { name = "Highhallow Hold", id = 96 },
    { name = "House of the Silent Magnifico", id = 35 },
    { name = "Humblemud", id = 10 },
    { name = "Hunding's Palatial Hall", id = 36 },
    { name = "Hunter's Glade", id = 61 },
    { name = "Jode's Embrace", id = 69 },
    { name = "Journey's End Lodgings", id = 100 },
    { name = "Kragenhome", id = 19 },
    { name = "Kthendral Deep Mines", id = 113 },
    { name = "Kushalit Sanctuary", id = 85 },
    { name = "Lakemire Xanmeer Manor", id = 64 },
    { name = "Linchal Grand Manor", id = 46 },
    { name = "Lucky Cat Landing", id = 73 },
    { name = "Mathiisen Manor", id = 9 },
    { name = "Merryvine Estate", id = 110 },
    { name = "Moonmirth House", id = 22 },
    { name = "Moon-Sugar Meadow", id = 71 },
    { name = "Mournoth Keep", id = 32 },
    { name = "Old Mistveil Manor", id = 30 },
    { name = "Ossa Accentium", id = 92 },
    { name = "Pantherfang Chapel", id = 89 },
    { name = "Pariah's Pinnacle", id = 54 },
    { name = "Pilgrim's Rest", id = 87 },
    { name = "Potentate's Retreat", id = 74 },
    { name = "Princely Dawnlight Palace", id = 57 },
    { name = "Proudspire Manor", id = 78 },
    { name = "Quondam Indorilia", id = 21 },
    { name = "Ravenhurst", id = 17 },
    { name = "Rosewine Retreat", id = 109 },
    { name = "Saint Delyn Penthouse", id = 42 },
    { name = "Seaveil Spire", id = 94 },
    { name = "Serenity Falls Estate", id = 37 },
    { name = "Shadow Queen's Labyrinth", id = 102 },
    { name = "Shalidor's Shrouded Realm", id = 82 },
    { name = "Shattered Mirror Isle", id = 115 },
    { name = "Sisters of the Sands Apartment", id = 5 },
    { name = "Sleek Creek House", id = 23 },
    { name = "Snowmelt Suite", id = 77 },
    { name = "Snugpod", id = 13 },
    { name = "Stay-Moist Mansion", id = 12 },
    { name = "Stillwaters Retreat", id = 80 },
    { name = "Stone Eagle Aerie", id = 83 },
    { name = "Strident Springs Demesne", id = 27 },
    { name = "Sugar Bowl Suite", id = 68 },
    { name = "Sweetwater Cascades", id = 91 },
    { name = "Sword-Singer's Redoubt", id = 103 },
    { name = "Tel Galen", id = 45 },
    { name = "The Ample Domicile", id = 11 },
    { name = "The Erstwhile Sanctuary", id = 56 },
    { name = "The Fair Winds", id = 99 },
    { name = "The Gorinir Estate", id = 15 },
    { name = "The Orbservatory Prior", id = 55 },
    { name = "The Sleepy Sloth", id = 118 },
    { name = "Theater of the Ancestors", id = 119 },
    { name = "Thieves' Oasis", id = 76 },
    { name = "Tower of Unutterable Truths", id = 106 },
    { name = "Twin Arches", id = 34 },
    { name = "Varlaisvea Ayleid Ruins", id = 86 },
    { name = "Velothi Reverie", id = 20 },
    { name = "Willowpond Haven", id = 107 },
    { name = "Wraithhome", id = 72 },
    { name = "Zhan Khaj Crest", id = 108 },
}
table.sort(houseList, function(a, b) return a.name < b.name end)

-- Helper to get house name from ID (just in case I missed a typo)
local function GetHouseName(id)
    for _, house in ipairs(houseList) do
        if house.id == id then return house.name end
    end
    return "Unknown House"
end

-- Preview/jump function for a given slot
local function PreviewSlot(slot)
    local slotKey = "slot" .. slot
    local id = HousePreviewHotkey.saved[slotKey]
    if id then
        local houseName = GetHouseName(id)
        d(string.format("|cFFFF00[HousePreviewHotkey]|r Jumping to Slot %d: %s (ID %d)", slot, houseName, id))
        PlaySound(SOUNDS.QUICKSLOT_SET)
        RequestJumpToHouse(id)
    end
end

-- Global functions for keybinds
function HOUSEPREVIEWHOTKEY_SLOT1()
    PreviewSlot(1)
end

function HOUSEPREVIEWHOTKEY_SLOT2()
    PreviewSlot(2)
end

function HOUSEPREVIEWHOTKEY_SLOT3()
    PreviewSlot(3)
end

-- Create settings menu with three independent dropdowns
function HousePreviewHotkey:CreateSettings()
    local LAM = LibAddonMenu2
    if not LAM then return end

    local panelData = {
        type = "panel",
        name = "House Preview Hotkey",
        displayName = "|cFFFF00House Preview Hotkey|r",
        author = "@TwinLamps (PC/NA)",
        version = "1.0",
        registerForRefresh = true,
        registerForDefaults = true,
    }

    LAM:RegisterAddonPanel("HousePreviewHotkeyPanel", panelData)

    -- Shared list of house names for lighter code
    local choices = {}
    for _, item in ipairs(houseList) do
        table.insert(choices, item.name)
    end

    local options = {
        {
            type = "description",
            text = "Assign houses to each hotkey slot, and bind keys in Controls → Keybindings.\n\nTo Preview you must not own the home! From a Preview you can walk back out to reset survey nodes.",
            width = "full",
        },
        {
            type = "dropdown",
            name = "Slot 1",
            choices = choices,
            getFunc = function()
                return GetHouseName(HousePreviewHotkey.saved.slot1)
            end,
            setFunc = function(name)
                for _, v in ipairs(houseList) do
                    if v.name == name then
                        HousePreviewHotkey.saved.slot1 = v.id
                        break
                    end
                end
            end,
            scrollable = true,
            width = "full",
        },
        {
            type = "dropdown",
            name = "Slot 2",
            choices = choices,
            getFunc = function()
                return GetHouseName(HousePreviewHotkey.saved.slot2)
            end,
            setFunc = function(name)
                for _, v in ipairs(houseList) do
                    if v.name == name then
                        HousePreviewHotkey.saved.slot2 = v.id
                        break
                    end
                end
            end,
            scrollable = true,
            width = "full",
        },
        {
            type = "dropdown",
            name = "Slot 3",
            choices = choices,
            getFunc = function()
                return GetHouseName(HousePreviewHotkey.saved.slot3)
            end,
            setFunc = function(name)
                for _, v in ipairs(houseList) do
                    if v.name == name then
                        HousePreviewHotkey.saved.slot3 = v.id
                        break
                    end
                end
            end,
            scrollable = true,
            width = "full",
        },
    }

    LAM:RegisterOptionControls("HousePreviewHotkeyPanel", options)
end

-- Initialize addon
function HousePreviewHotkey.OnAddOnLoaded(event, addonName)
    if addonName ~= ADDON_NAME then return end

    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)

    HousePreviewHotkey.saved = ZO_SavedVars:NewAccountWide(
        "HousePreviewHotkey_Saved",
        1,
        GetWorldName(),
        defaults
    )

    HousePreviewHotkey:CreateSettings()

    -- Register string IDs for keybind names in Controls menu
    ZO_CreateStringId("SI_BINDING_NAME_HOUSEPREVIEWHOTKEY_SLOT1", "Slot 1")
    ZO_CreateStringId("SI_BINDING_NAME_HOUSEPREVIEWHOTKEY_SLOT2", "Slot 2")
    ZO_CreateStringId("SI_BINDING_NAME_HOUSEPREVIEWHOTKEY_SLOT3", "Slot 3")
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, HousePreviewHotkey.OnAddOnLoaded)