--- @class (partial) CollectiblesTrackerAllTheThings
---
--- Third-party tab registration must happen before this add-on's EVENT_ADD_ON_LOADED (file load time).
---
local CollectiblesTrackerAllTheThings = CollectiblesTrackerAllTheThings

local THIRD_PARTY_TAB_KEY = CollectiblesTrackerAllTheThings.THIRD_PARTY_TAB_KEY
local CROWN_CRATE_TAB_KEY = CollectiblesTrackerAllTheThings.THIRD_PARTY_TAB_KEY_CROWN_CRATES
local CROWN_STORE_TAB_KEY = CollectiblesTrackerAllTheThings.THIRD_PARTY_TAB_KEY_CROWN_STORE

local tabInfo =
{
    name = "CollectiblesTrackerAllTheThings",
    title = SI_COLLECTIBLES_TRACKER_ALL_THE_THINGS_TITLE,
    order = 405,
    icon = "/esoui/art/treeicons/reconstruction_tabicon_misc_",
    frameName = "CollectiblesTrackerAllTheThingsFrame",
    allowInvalid = true,
}

local dataGenerator = function ()
    return CollectiblesTrackerAllTheThings.BuildThirdPartyTabData()
end

CollectiblesTracker.RegisterThirdPartyTab(THIRD_PARTY_TAB_KEY, tabInfo, dataGenerator)

local crownStoreTabInfo =
{
    name = "CollectiblesTrackerAllTheThingsCrownStore",
    title = SI_CROWN_STORE_TITLE,
    order = 406,
    icon = "/esoui/art/treeicons/store_indexicon_promotion_",
    frameName = "CollectiblesTrackerAllTheThingsCrownStoreFrame",
    allowInvalid = true,
}

local crownStoreDataGenerator = function ()
    return CollectiblesTrackerAllTheThings.BuildCrownStoreTabData()
end

CollectiblesTracker.RegisterThirdPartyTab(CROWN_STORE_TAB_KEY, crownStoreTabInfo, crownStoreDataGenerator)

local crownCrateTabInfo =
{
    name = "CollectiblesTrackerAllTheThingsCrownCrates",
    title = SI_MAIN_MENU_CROWN_CRATES,
    order = 407,
    icon = "/esoui/art/treeicons/store_indexicon_crowncrates_",
    frameName = "CollectiblesTrackerAllTheThingsCrownCratesFrame",
    allowInvalid = true,
}

local crownCrateDataGenerator = function ()
    return CollectiblesTrackerAllTheThings.BuildCrownCrateTabData()
end

CollectiblesTracker.RegisterThirdPartyTab(CROWN_CRATE_TAB_KEY, crownCrateTabInfo, crownCrateDataGenerator)
