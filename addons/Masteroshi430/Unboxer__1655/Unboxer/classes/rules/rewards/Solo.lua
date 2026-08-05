
-- Solo activites (e.g. non-repeatable solo quests, level-up rewards, etc.)

local addon = Unboxer
local class = addon:Namespace("rules.rewards")
local rules = addon.classes.rules
local knownIds
local debug = false
local staticDlcs
local submenu = GetString(SI_UNBOXER_QUEST_REWARDS)

class.Solo = addon.classes.Rule:Subclass()
function class.Solo:New()
    return addon.classes.Rule.New(
        self, 
        {
            name           = "solo",
            exampleItemIds = {
                126012, -- [Waterlogged Strong Box]
                203568,  -- [Blackwood Coffer]
                146037, -- [Recovered Murkmire Weapon]
            },
            dependencies   = { "crafting", "excluded3", "festival", "furnisher", "materials", "legerdemain", "pvp", "trial", "vendorgear", "shadowysupplier", "solorepeatable", "telvar", "fortunes" },
            submenu        = submenu,
            title          = GetString(SI_UNBOXER_SOLO),
            knownIds       = knownIds
        })
end

function class.Solo:Match(data)
    
    -- -- All the vendor-supplied "Unidentified" weapon and armor boxes are already matched
    -- -- because of the "vendorGear" dependency in the constructor.
    -- -- Any others are zone quest drops, so match them here.
    -- if data.quality > ITEM_FUNCTIONAL_QUALITY_NORMAL
       -- and (addon:StringContainsStringIdOrDefault(data.name, SI_UNBOXER_UNIDENTIFIED_LOWER)
            -- or addon:StringContainsStringIdOrDefault(data.name, SI_UNBOXER_UNIDENTIFIED2_LOWER))
    -- then
        -- return true
    -- end
  
    -- -- Matches containers like 81226 [Unidentified Craglorn Weapon] and 87704 [Serpent's Celestial Recompense],
    -- -- which have no flavor text.  This is needed to keep them from being categorized as PTS containers.
    -- if data.flavorText == "" and string.find(data.icon, "quest_container_001") 
       -- and data.quality < ITEM_FUNCTIONAL_QUALITY_ARTIFACT
    -- then
        -- return true
    -- end
    
    -- if addon:StringContainsStringIdOrDefault(data.name, SI_UNBOXER_UNKNOWN_ITEM_PATTERN) -- "Unknown Item" boxes
       -- or addon:StringContainsStringIdOrDefault(data.flavorText, SI_UNBOXER_UNKNOWN_ITEM_LOWER)
       -- or addon:StringContainsStringIdOrDefault(data.flavorText, SI_UNBOXER_UNKNOWN_ITEM_LOWER)
       -- or addon:StringContainsStringIdOrDefault(data.name, SI_UNBOXER_STRONG_BOX_LOWER) -- "strongbox" items
       -- or addon:StringContainsStringIdOrDefault(data.name, SI_UNBOXER_STRONG_BOX2_LOWER)
       -- or data.flavorText == GetString(SI_UNBOXER_LEGACY_QUEST_FLAVOR) -- "This large box has some unknown item inside."
       -- or self:MatchDlcNameText(data.name)
       -- or self:MatchDlcNameText(data.flavorText)
    -- then
        -- return true
    -- end
    
    -- -- Fix for untranslated text not matching
    -- if string.find(data.icon, "quest_container_") and not string.find(data.icon, "quest_container_[0-9]") then
        -- return true
    -- end
end

function class.Solo:MatchDlcNameText(text)
    -- for _, dlc in ipairs(self:GetDlcs()) do
        -- if string.find(text, dlc.name) or string.find(text, dlc.zoneName) then
            -- return true
        -- end
    -- end
end


function class.Solo:GetDlcs()
    if staticDlcs then return staticDlcs end
    
    local dlcType=COLLECTIBLE_CATEGORY_TYPE_DLC
    local dlcCollectibles = {}
    staticDlcs = {}
    for index=1,GetTotalCollectiblesByCategoryType(dlcType) do
        local collectibleId = GetCollectibleIdFromType(dlcType, index)
        local name = LocaleAwareToLower(zo_strformat("<<1>>", GetCollectibleName(collectibleId)))
        dlcCollectibles[collectibleId] = name
    end
    local zoneIndex = 1
    local misses = 0 -- keep track of how many empty zone names are found
    while true do
        local zoneName = GetZoneNameByIndex(zoneIndex)
        if(zoneName == "") then -- if more than 10 zone names come up empty, assume we are done. allows for a few to go missing due to not being translated.
            misses = misses + 1
            if misses > 10 then
                break
            end
        end
        local zoneId = GetZoneId(zoneIndex)
        local parentZoneId = GetParentZoneId(zoneId)
        local collectibleId = GetCollectibleIdForZone(zoneIndex)
        if collectibleId and dlcCollectibles[collectibleId] and zoneId == parentZoneId then
            zoneName = LocaleAwareToLower(zo_strformat("<<1>>", zoneName))
            local collectibleName = dlcCollectibles[collectibleId]
            table.insert(staticDlcs, {
                    ["collectibleId"] = collectibleId,
                    ["name"] = collectibleName,
                    ["zoneIndex"] = zoneIndex,
                    ["zoneName"] = zoneName,
                })
        end
        zoneIndex = zoneIndex + 1
    end
    return staticDlcs
end

knownIds = {
  [45003]=1,[45004]=1,[54986]=1,[55263]=1,[55358]=1,[55947]=1,
  [55948]=1,[56865]=1,[73757]=1,[73758]=1,[73759]=1,[73760]=1,
  [73761]=1,[73762]=1,[73763]=1,[73764]=1,[73765]=1,[73766]=1,
  [73767]=1,[73768]=1,[73769]=1,[73770]=1,[77528]=1,[77529]=1,
  [77530]=1,[77531]=1,[77532]=1,[77533]=1,[77535]=1,[77536]=1,
  [77537]=1,[77538]=1,[77539]=1,[77540]=1,[77541]=1,[77542]=1,
  [77543]=1,[77544]=1,[77545]=1,[77546]=1,[77573]=1,[77574]=1,
  [78002]=1,[81226]=1,[81227]=1,[81601]=1,[87710]=1,[87711]=1,
  [87712]=1,[87713]=1,[87714]=1,[87715]=1,[87716]=1,[87717]=1,
  [87718]=1,[87719]=1,[87720]=1,[87721]=1,[87722]=1,[87723]=1,
  [87724]=1,[87725]=1,[87726]=1,[87727]=1,[87728]=1,[87729]=1,
  [87730]=1,[87731]=1,[87732]=1,[87733]=1,[87734]=1,[87735]=1,
  [87736]=1,[87737]=1,[87738]=1,[87739]=1,[87740]=1,[87741]=1,
  [87742]=1,[87743]=1,[87744]=1,[87745]=1,[87746]=1,[94085]=1,
  [94086]=1,[96969]=1,[126012]=1,[134969]=1,[138790]=1,[140287]=1,
  [140288]=1,[140289]=1,[140290]=1,[140291]=1,[140292]=1,[140293]=1,
  [140294]=1,[140295]=1,[140296]=1,[145546]=1,[145558]=1,[145559]=1,
  [145560]=1,[145561]=1,[145562]=1,[145563]=1,[145564]=1,[145565]=1,
  [145566]=1,[145567]=1,[145568]=1,[146037]=1,[152242]=1,[157507]=1,
  [178698]=1, [203568]=1, [203566]=1, [203567]=1, [203569]=1, [203570]=1,
  [203571]=1, [203572]=1, [203573]=1, [203575]=1, [203180]=1, [217725]=1, 
  [188135]=1,
[190933]=1,
[217602]=1,
[217659]=1,
[217666]=1,
[217667]=1,
[217668]=1,
[217669]=1,
[217670]=1,
[217671]=1,
[217672]=1,
[217673]=1,
[217674]=1,
[217676]=1,
[217677]=1,
[217678]=1,
[217679]=1,
[217680]=1,
[217681]=1,
[217682]=1,
[217617]=1,
[207956]=1, -- West Weald Supply Cache
[227003]=1, --Azrashul's Legacy Rumor Box
[227004]=1, --Azrashul's Legacy Rumor Box
[227009]=1, --House Tirethi in Danger Rumor Box
[227010]=1, --House Tirethi in Danger Rumor Box
[227011]=1, --Secret Chili Ingredients Rumor Box
[227012]=1, --Secret Chili Ingredients Rumor Box
[227013]=1, --Somber News Rumor Box
[227014]=1, --Somber News Rumor Box
[227016]=1, --Letter-Crossed Lovers Rumor Jewelry Box
[227017]=1, --Mysterious Dreamer Rumor Box
[227019]=1, --Bumps in the Night Rumor Box
[227020]=1, --Bumps in the Night Rumor Box
[227022]=1, --Figures of Note Rumor Jewelry Box
[227028]=1, --Maormer Business Rumor Coffer
[227029]=1, --Maormer Business Rumor Coffer
[227030]=1, --Runaway Property Rumor Box
[227031]=1, --May the Gold Leaf Guide You Rumor Box
[227032]=1, --May the Gold Leaf Guide You Rumor Box
[227033]=1, --May the Gold Leaf Guide You Rumor Box
[227301]=1, --Fellowship of Honest Toil Rumor Bag
}
