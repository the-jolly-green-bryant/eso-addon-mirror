
-- Crafting Quest Rewards

local addon = Unboxer
local class = addon:Namespace("rules.crafting")
local knownIds
local debug = false
local submenu = GetString("SI_QUESTTYPE", QUEST_TYPE_CRAFTING)

class.CraftingRewards = addon.classes.Rule:Subclass()
function class.CraftingRewards:New()
    return addon.classes.Rule.New(
        self, 
        {
            name          = "crafting",
            exampleItemIds = {
                55827,  -- [Cooking Supplies]
                147615, -- [Clothier's Satchel (Leather) IX]
            },
            dependencies  = { "excluded2" },
            submenu       = submenu,
            title         = GetString(SI_UNBOXER_CRAFTING_REWARDS),
            knownIds      = knownIds,
        })
end

function class.CraftingRewards:Match(data)
    
    if addon:StringContainsStringIdOrDefault(data.flavorText, SI_UNBOXER_CRAFTED_LOWER)
       and addon:StringContainsStringIdOrDefault(data.flavorText, SI_UNBOXER_REWARD_LOWER)
    then
        return true
    end
end

function class.CraftingRewards:DisableWritCreaterAutoloot(savedVars)
    if not savedVars then return end
	
    -- local displayLazyWarning
    -- if not savedVars.ignoreAuto then
        -- savedVars.ignoreAuto = true
        -- displayLazyWarning = true
    -- end
    -- if savedVars.autoLoot then
        -- savedVars.autoLoot = false
        -- displayLazyWarning = true
    -- end
    -- if savedVars.lootContainerOnReceipt then
        -- savedVars.lootContainerOnReceipt = false
        -- displayLazyWarning = true
    -- end
    return nil --displayLazyWarning
end

function class.CraftingRewards:OnAutolootSet(value)
    if not value or not WritCreater then return end
    local displayLazyWarning = self:DisableWritCreaterAutoloot(WritCreater.savedVars)
    local displayLazyWarningAccountWide = self:DisableWritCreaterAutoloot(
        WritCreater.savedVarsAccountWide and WritCreater.savedVarsAccountWide.accountWideProfile)
    if displayLazyWarning or displayLazyWarningAccountWide then
        addon.Print("Disabled autoloot settings for " .. addon.suffix .. tostring(WritCreater.settings["panel"].displayName))
    end
end

knownIds = {
  [30333]=1,[30335]=1,[30337]=1,[30338]=1,[30339]=1,[55827]=1,
  [57851]=1,[58131]=1,[58503]=1,[58504]=1,[58505]=1,[58506]=1,
  [58507]=1,[58508]=1,[58509]=1,[58510]=1,[58511]=1,[58512]=1,
  [58513]=1,[58514]=1,[58515]=1,[58516]=1,[58517]=1,[58518]=1,
  [58519]=1,[58520]=1,[58521]=1,[58522]=1,[58523]=1,[58524]=1,
  [58525]=1,[58526]=1,[58527]=1,[58528]=1,[58529]=1,[58530]=1,
  [58531]=1,[58532]=1,[58533]=1,[58534]=1,[59705]=1,[59706]=1,
  [59707]=1,[59708]=1,[59709]=1,[59710]=1,[59714]=1,[59715]=1,
  [59716]=1,[59717]=1,[59718]=1,[59719]=1,[59720]=1,[59721]=1,
  [59723]=1,[59724]=1,[59725]=1,[59735]=1,[59736]=1,[71233]=1,
  [71234]=1,[71235]=1,[71236]=1,[71237]=1,[71238]=1,[121297]=1,
  [121298]=1,[121299]=1,[121300]=1,[121301]=1,[121302]=1,[138801]=1,
  [138802]=1,[138803]=1,[138804]=1,[138805]=1,[147607]=1,[147608]=1,
  [147609]=1,[147610]=1,[147611]=1,[147612]=1,[147613]=1,[147614]=1,
  [147615]=1,[147616]=1,[203181]=1,[203199]=1,[203200]=1,[203201]=1, 
  [203205]=1,[203212]=1,[203213]=1,[203544]=1, [219791]=1,[219793]=1,
  [219795]=1, [219797]=1, [219799]=1, [219801]=1,
[219790]=1, -- Writhing Alchemy Reward Coffer
[219792]=1, -- Writhing Blacksmith Reward Coffer
[219794]=1, -- Writhing Clothier Reward Coffer
[219796]=1, -- Writhing Enchanting Reward Coffer
[219798]=1, -- Writhing Provisioning Reward Coffer
[219800]=1, -- Writhing Woodworking Reward Coffer
[224708]=1,  --Jewelrycrafting Research Box
[224711]=1,  --Nirnhorned Research Delivery
[224713]=1,  --Chef's Pack
[224718]=1,  --Expert Miner's Sack
[225340]=1, --Jewelry Crafting Research Crate

}
