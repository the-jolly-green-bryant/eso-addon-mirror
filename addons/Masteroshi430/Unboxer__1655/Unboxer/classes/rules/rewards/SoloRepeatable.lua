
-- Repeatable activites (e.g. dailies, Rewards for the Worthy, etc.)

local addon = Unboxer
local class = addon:Namespace("rules.rewards")
local rules = addon.classes.rules
local knownIds, excludedIds
local debug = false
local staticDlcs, skillLineNameStrings
local submenu = GetString(SI_UNBOXER_QUEST_REWARDS)

class.SoloRepeatable = addon.classes.Rule:Subclass()
function class.SoloRepeatable:New()
    return addon.classes.Rule.New(
        self, 
        {
            name          = "solorepeatable",
            exampleItemIds = {
                96387,  -- [Undaunted Merits]
                151620, -- [Elsweyr Daily Merit Coffer]
                121220, -- [Yokudan Coffer of Distinction]
            },
            dependencies  = { "crafting", "excluded3", "festival", "furnisher", "materials", "legerdemain", "pvp", "trial", "vendorgear", "telvar", "fortunes" },
            submenu       = submenu,
            title         = GetString(SI_UNBOXER_REPEATABLE),
            knownIds      = knownIds
        })
end

function class.SoloRepeatable:Match(data)
    
    -- if string.find(data.icon, "justice_stolen_case_001") -- strong boxes
       -- or data.bindType ~= BIND_TYPE_ON_PICKUP 
       -- or excludedIds[data.itemId]
    -- then 
        -- return
    -- end
    
    -- if self:MatchDailyQuestText(data.name) -- Daily reward containers
       -- or self:MatchDailyQuestText(data.flavorText)
       -- or addon:StringContainsStringIdOrDefault(data.name, SI_UNBOXER_COFFER_LOWER) -- "coffer"
       -- or addon:StringContainsStringIdOrDefault(data.name, SI_UNBOXER_COFFER2_LOWER)
       -- or addon:StringContainsStringIdOrDefault(data.flavorText, SI_UNBOXER_GIFT_FROM_LOWER) -- "gift from" boxes
       -- or addon:StringContainsStringIdOrDefault(data.flavorText, SI_UNBOXER_GIFT_FROM2_LOWER)
       -- or self:MatchGuildSkillLineName(data.name) -- Matches "Merit" for guild skill tree lines
    -- then
        -- return true
    -- end
end

function class.SoloRepeatable:MatchGuildSkillLineName(text)
    -- for _, stringId in ipairs(skillLineNameStrings) do
        -- if addon:StringContainsStringIdOrDefault(text, stringId) then
            -- return true
        -- end
    -- end
end

function class.SoloRepeatable:MatchDailyQuestText(text)
    return addon:StringContainsStringIdOrDefault(text, SI_UNBOXER_REWARD_LOWER)
           or addon:StringContainsStringIdOrDefault(text, SI_UNBOXER_DAILY_LOWER)
           or addon:StringContainsStringIdOrDefault(text, SI_UNBOXER_DAILY2_LOWER)
           or addon:StringContainsStringIdOrDefault(text, SI_UNBOXER_JOB_LOWER)
           or addon:StringContainsStringIdOrDefault(text, SI_UNBOXER_JOB2_LOWER)
end

skillLineNameStrings = {
    SI_UNBOXER_UNDAUNTED_LOWER,
    SI_UNBOXER_DARK_BROTHERHOOD_LOWER,
    SI_UNBOXER_THIEVES_GUILD_LOWER,
    SI_UNBOXER_MAGES_GUILD_LOWER,
    SI_UNBOXER_FIGHTERS_GUILD_LOWER,
    SI_UNBOXER_PSIJIC_ORDER_LOWER,
}

excludedIds = {
  [56865] = 1, -- [Nirnhoned Coffer], awarded from Craglorn story quest, not repeatable
  [81601] = 1, -- [Nirnhoned Coffer], awarded from Craglorn story quest, not repeatable
}

knownIds = {
  [55452]=1,[71312]=1,[74679]=1,[74680]=1,[77526]=1,[77556]=1,
  [79669]=1,[79674]=1,[94087]=1,[94088]=1,[94121]=1,[94122]=1,
  [95826]=1,[95827]=1,[96385]=1,[96386]=1,[96387]=1,[121220]=1,
  [126030]=1,[126031]=1,[126032]=1,[126033]=1,[133225]=1,[133559]=1,
  [133560]=1,[138800]=1,[141741]=1,[147287]=1,[151620]=1,[151623]=1,
  [153606]=1,[153842]=1,[153843]=1,[153844]=1,[153845]=1,[153846]=1,
  [153847]=1,[153848]=1,[153849]=1,[153850]=1,[153851]=1,[153852]=1,
  [153853]=1,[153854]=1,[153863]=1,[153864]=1,[156831]=1,[156832]=1,
  [156842]=1,[165575]=1,[165576]=1,[165577]=1,[166478]=1,[170223]=1,
  [170224]=1,[170225]=1,[170226]=1,[178407]=1,[178408]=1,[182936]=1,
  [183008]=1,[203721]=1,[203809]=1,[203810]=1,[203811]=1,[203812]=1,
  [203813]=1,[203814]=1,[203815]=1,[203816]=1,[203817]=1,[203819]=1,
  [203820]=1,[203821]=1,[203822]=1,[203823]=1,[203610]=1,[207980]=1,
  [207981]=1,[207982]=1,[197818]=1,[197819]=1,[197820]=1,[217657]=1,
  [217658]=1,[217731]=1,[217732]=1,[203747]=1,[203748]=1,[203749]=1,
  [203750]=1,[203751]=1,[203752]=1,[203753]=1,[203754]=1,[203755]=1,
  [203756]=1,[203757]=1,[203758]=1,[203759]=1,[203760]=1,[203761]=1,
  [203762]=1,[203763]=1,[203764]=1,[203765]=1,[203766]=1,[203767]=1,
  [203768]=1,[203769]=1,[203770]=1,[203771]=1,[203772]=1,[203773]=1,
  [203774]=1,[203775]=1,[203776]=1,[203777]=1,[203778]=1,[203779]=1,
  [203774]=1,[203775]=1,[203776]=1,[203777]=1,[203778]=1,[203779]=1,
  [203780]=1,[203781]=1,[203782]=1,[203783]=1,[203784]=1,[203785]=1,
  [203786]=1,[203787]=1,[203788]=1,[203789]=1,[203790]=1,[203791]=1,
  [203792]=1,[203793]=1,[203794]=1,[203795]=1,[203796]=1,[203797]=1,
  [203798]=1,[203799]=1,[203800]=1,[203801]=1,[203802]=1,[203803]=1,
  [203804]=1,[203805]=1,[203806]=1,[203807]=1,[211131]=1,[211132]=1,
  [211133]=1,[211134]=1,[211135]=1,[211136]=1,[211137]=1,[211138]=1,
  [211139]=1,[211140]=1,[211141]=1,[211142]=1,[211143]=1,[211144]=1,
  [211145]=1,[211146]=1,[211147]=1,[211148]=1,[211149]=1,[211150]=1,
  [211151]=1,[211152]=1,[211153]=1,[211154]=1,[211155]=1,[211156]=1,
  [211157]=1,[217906]=1,[217907]=1,[217908]=1,[203731]=1,[188136]=1,
  [188137]=1,[188138]=1,
[188136]=1,
[188137]=1,
[188138]=1,
[190948]=1,
[190949]=1,
[190952]=1,
[199814]=1,
[203731]=1,
[204436]=1,
[204445]=1,
[204446]=1,
[204447]=1,
[204448]=1,
[204449]=1,
[217621]=1,
[224107]=1,  --Curated Tamriel Reward Coffer
[224108]=1,  --Curated Dungeon Reward Coffer
[224110]=1,  --Night Market Daily Reward Coffer
[224292]=1,  --Exceptional Glittering Goad Reward Coffer
[224295]=1,  --Glittering Goad Reward Coffer
[224297]=1,  --Exceptional Thousand Eyes Reward Coffer
[224298]=1,  --Thousand Eyes Reward Coffer
[224300]=1,  --Exceptional Ruckus Reward Coffer
[224301]=1,  --Ruckus Reward Coffer
[224674]=1,  --Curated Glittering Goad Coffer
[224675]=1,  --Curated Thousand Eyes Coffer
[224676]=1,  --Curated The Ruckus Coffer
[224678]=1,  --Travel Box
[224679]=1,  --Commendation Gift Box
[224703]=1,  --Rogue's Potion Box
[224705]=1,  --Poison Satchel
[224724]=1,  --Scribing Pack 
[224673]=1,  --Trade bar satchel
[225206]=1, --Curated Bahraha's Curse Coffer
[225207]=1, --Thieves Guild Daily Coffer
[225221]=1, --Curated Bahraha's Curse Coffer
[225227]=1, --Curated Coffer from Holgunn One-Eye
[225228]=1, --Curated Coffer from Battlereeve Urcelmo
[225229]=1, --Curated Coffer from Lady Arabelle Davaux
[225252]=1, --Curated Coldharbour's Favorite Item
[225253]=1, --Curated Coldharbour's Favorite Item
[225262]=1, --Curated Trial by Fire Item
[225263]=1, --Curated Trial by Fire Item
[225453]=1, --Curated Coffer from Holgunn One-Eye
[225454]=1, --Curated Coffer from Lady Arabelle Davaux
[225455]=1, --Curated Coffer from Battlereeve Urcelmo
}