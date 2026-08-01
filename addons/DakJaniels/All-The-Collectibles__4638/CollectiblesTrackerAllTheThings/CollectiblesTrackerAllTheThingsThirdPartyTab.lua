--- @class (partial) CollectiblesTrackerAllTheThings
---
--- Third-party tab registration must happen before this add-on's EVENT_ADD_ON_LOADED (file load time).
---
local CollectiblesTrackerAllTheThings = CollectiblesTrackerAllTheThings

local THIRD_PARTY_TAB_KEY = "ctath"

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
