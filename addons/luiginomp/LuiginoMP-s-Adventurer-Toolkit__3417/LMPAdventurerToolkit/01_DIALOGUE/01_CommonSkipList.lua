COMMON_SKIP_LIST = {}
local systemName = "Common Skip List"
function COMMON_SKIP_LIST.GetName() return systemName end

local dialogueSkipList = {
    --Don't Skip
    --Names
    {"Bastian Hallix", false}
    ,{"Mirri Elendis", false}
    ,{"Isobel Veloise", false}
    ,{"Ember", false}
    ,{"Prelate Sabinus", false}
    --Titles
    ,{"Banker", false}
    ,{"Guild Trader", false}
    ,{"Innkeeper", false}
    ,{"Navigator", false}

    --Skip
    --Names
    ,{"Alchemist Delivery Crate", true}
    ,{"Amminus Varo",true}
    ,{"Blacksmith Delivery Crate", true}
    ,{"Clothier Delivery Crate", true}
    ,{"Consumables Crafting Writs", true}
    ,{"Enchanter Delivery Crate", true}
    ,{"Equipment Crafting Writs", true}
    ,{"Fasaria",true}
    ,{"Jewelry Crafting Delivery Crate", true}
    ,{"Petronius Galenus", true}
    ,{"Provisioner Delivery Crate", true}
    ,{"Woodworker Delivery Crate", true}
    --Titles
    ,{"Achievement Furnisher", true}
    ,{"Alchemist", true}
    ,{"Armorer", true}
    ,{"Blacksmith", true}
    ,{"Bergama Festival Chief", true}
    ,{"Betnikh Festival Chief", true}
    ,{"Brewer", true}
    ,{"Carpenter", true}
    ,{"Clothier", true}
    ,{"Charity Writ Coordinator", true}
    ,{"Chef", true}
    ,{"Daily Job Broker", true}
    ,{"Enchanter", true}
    ,{"Event Merchant", true}
    ,{"Event Merchant's Assistant", true}
    ,{"Grocer", true}
    ,{"Hissmir Festival Chief", true}
    ,{"Home Goods Furnisher", true}
    ,{"Leatherworker", true}
    ,{"Merchant", true}
    ,{"Mystic", true}
    ,{"New Life Herald", true}
    ,{"Rawl'ka Festival Chief", true}
    ,{"Stablemaster", true}
    ,{"Tailor", true}
    ,{"Temple of the Eight Festival Chief", true}
    ,{"Traveling Festival Merchant", true}
    ,{"Weaponsmith", true}
    ,{"Woodworker", true}
    ,{"Zenithar Priest", true}
}

function COMMON_SKIP_LIST.GetDialogueSkipList() return dialogueSkipList end
DIALOGUE_SKIPPER.AddToSkipSystemList(COMMON_SKIP_LIST)