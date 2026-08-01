
-- Runeboxes

local addon = Unboxer
local class = addon:Namespace("rules.collectibles")
local knownIds
local debug = false

-- Collectibles submenu
local submenu = GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_COLLECTIBLE)

local runeboxCollectibleCategoryTypes
class.Runeboxes  = addon.classes.Rule:Subclass()
function class.Runeboxes:New()
    return addon.classes.Rule.New(
        self, 
        {
            name           = "runeboxes",
            exampleItemIds = {
                96951,  -- [Runebox: Nordic Bather's Towel]
                --152154, -- [Newcomer: Flame Skin Salamander]
            },
            dependencies   = { "outfitstyles" },
            submenu        = submenu,
            title          = GetString(SI_UNBOXER_RUNEBOXES),
            tooltip        = GetString(SI_UNBOXER_RUNEBOXES_TOOLTIP),
            knownIds       = knownIds,
        })
end

function class.Runeboxes:Match(data)
    if data.collectibleCategoryType 
       and runeboxCollectibleCategoryTypes[data.collectibleCategoryType]
    then
        return true
    end
end

runeboxCollectibleCategoryTypes = {
  --[COLLECTIBLE_CATEGORY_TYPE_ABILITY_SKIN] = true, -- to check pts u44
  [COLLECTIBLE_CATEGORY_TYPE_ASSISTANT] = true,
  [COLLECTIBLE_CATEGORY_TYPE_BODY_MARKING] = true,
  [COLLECTIBLE_CATEGORY_TYPE_COSTUME] = true,
  [COLLECTIBLE_CATEGORY_TYPE_EMOTE] = true,
  [COLLECTIBLE_CATEGORY_TYPE_FACIAL_ACCESSORY] = true,
  [COLLECTIBLE_CATEGORY_TYPE_FACIAL_HAIR_HORNS] = true,
  [COLLECTIBLE_CATEGORY_TYPE_HAIR] = true,
  [COLLECTIBLE_CATEGORY_TYPE_HAT] = true,
  [COLLECTIBLE_CATEGORY_TYPE_HEAD_MARKING] = true,
  [COLLECTIBLE_CATEGORY_TYPE_MEMENTO] = true,
  [COLLECTIBLE_CATEGORY_TYPE_PERSONALITY] = true,
  [COLLECTIBLE_CATEGORY_TYPE_PIERCING_JEWELRY] = true,
  [COLLECTIBLE_CATEGORY_TYPE_POLYMORPH] = true,
  [COLLECTIBLE_CATEGORY_TYPE_SKIN] = true,
  [COLLECTIBLE_CATEGORY_TYPE_VANITY_PET] = true,
}

knownIds = {
[79329]=1,
[79330]=1,
[79331]=1,
[83516]=1,
[83517]=1,
[141742]=1,
[141743]=1,
[141744]=1,
[141745]=1,
[141746]=1,
[141747]=1,
[141748]=1,
[141749]=1,
[141750]=1,
[141751]=1,
[141915]=1,
[96391]=1,
[96392]=1,
[96393]=1,
[96395]=1,
[96951]=1,
[96952]=1,
[96953]=1,
[146041]=1,
[146042]=1,
[147285]=1,
[147286]=1,
[147492]=1,
[147493]=1,
[147494]=1,
[147495]=1,
[147496]=1,
[147497]=1,
[147498]=1,
[147499]=1,
[151930]=1,
[151931]=1,
[151932]=1,
[151933]=1,
[151934]=1,
[151938]=1,
[151939]=1,
[151940]=1,
[153486]=1,
[153487]=1,
[153488]=1,
[153489]=1,
[153490]=1,
[153491]=1,
[153492]=1,
[153536]=1,
[153537]=1,
[153636]=1,
[153637]=1,
[153638]=1,
[153704]=1,
[153705]=1,
[153706]=1,
[153707]=1,
[153708]=1,
[153709]=1,
[153710]=1,
[153711]=1,
[153712]=1,
[153713]=1,
[153714]=1,
[153715]=1,
[153716]=1,
[153717]=1,
[153718]=1,
[156626]=1,
[119692]=1,
[166468]=1,
[166469]=1,
[167303]=1,
[167305]=1,
[167937]=1,
[167938]=1,
[167939]=1,
[167940]=1,
[124658]=1,
[124659]=1,
[128359]=1,
[128360]=1,
[133550]=1,
[134678]=1,
[171330]=1,
[171471]=1,
[171472]=1,
[171473]=1,
[171477]=1,
[171478]=1,
[171532]=1,
[171533]=1,
[137962]=1,
[137963]=1,
[178695]=1,
[178696]=1,
[138783]=1,
[138784]=1,
[138785]=1,
[139464]=1,
[139465]=1,
[190035]=1,
[182487]=1,
[182517]=1,
[182518]=1,
[182519]=1,
[182591]=1,
[183194]=1,
[183195]=1,
[187679]=1,
[187680]=1,
[187681]=1,
[211127]=1,
[212177]=1,
[212178]=1,
[212179]=1,
[212199]=1,
[212235]=1,
[214258]=1,
[219747]=1,
[219748]=1,
[198322]=1,
}