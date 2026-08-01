
-- Vendor Equipment Boxes

local addon = Unboxer
local class = addon:Namespace("rules.vendor")
local rules = addon.classes.rules
local knownIds
local debug = false
local submenu = GetString(SI_GAMEPAD_VENDOR_CATEGORY_HEADER)

class.VendorGear = addon.classes.Rule:Subclass()
function class.VendorGear:New()
    local instance = addon.classes.Rule.New(
        self, 
        {
            name          = "vendorgear",
            exampleItemIds = {
                55330,  -- [Secret Light Armor]
                117924, -- [Superb Imperial Reward]
                118541, -- [Unknown Rift Item]
                126100, -- [Unknown Battleground Bow]
            },
            dependencies  = { "excluded2" },
            title         = GetString(SI_UNBOXER_VENDOR_GEAR),
            submenu       = submenu,
            knownIds      = knownIds,
        })
    instance.soloRepeatable = rules.rewards.SoloRepeatable:New()
    return instance
end

function class.VendorGear:Match(data)
    
    -- if self.soloRepeatable:MatchDailyQuestText(data.name)
       -- or self.soloRepeatable:MatchDailyQuestText(data.flavorText)
    -- then
        -- return
    -- end
    
    -- -- Match various known vendors
    -- if string.find(data.icon, 'zonebag')                                                          -- Regional Equipment Vendor
       -- or addon:StringContainsStringIdOrDefault(data.flavorText, SI_UNBOXER_RENOWNED_LOWER)          -- Regional Equipment Vendor (backup in case icon changes)
       -- or addon:StringContainsStringIdOrDefault(data.name, SI_UNBOXER_BATTLEGROUND_LOWER)            -- Battlegrounds Equipment Vendor
       -- or (addon:StringContainsStringIdOrDefault(data.name, SI_UNBOXER_JEWELRY_BOX_LOWER) 
           -- and data.bindType == BIND_TYPE_ON_PICKUP)                                                 -- Tel-Var Jewelry Merchant (legacy)
       -- or addon:StringContainsStringIdOrDefault(data.name, SI_UNBOXER_EQUIPMENT_BOX_LOWER)           -- Tel-Var Equipment Vendor (current)
       -- or addon:StringContainsStringIdOrDefault(data.name, SI_UNBOXER_EQUIPMENT_BOX2_LOWER)
       -- or addon:StringContainsStringIdOrDefault(data.name, SI_UNBOXER_ARMOR_BOX_LOWER)
       -- or addon:StringContainsStringIdOrDefault(data.flavorText, SI_UNBOXER_CP160_ADVENTURERS_LOWER) -- Tel-Var Equipment Vendor (legacy)
       -- or addon:StringContainsStringIdOrDefault(data.flavorText, SI_UNBOXER_COMMON_LOWER)            -- Legacy "Unidentified" gear
       -- or addon:StringContainsStringIdOrDefault(data.flavorText, SI_UNBOXER_OFFENSIVE_LOWER)         -- Elite Gear Vendor 
       -- or addon:StringContainsStringIdOrDefault(data.flavorText, SI_UNBOXER_DEFENSIVE_LOWER)         -- Elite Gear Vendor
    -- then
        -- return true
    -- end
    
    -- -- Match generic leveling containers like 55328	[Secret Heavy Armor], which have no flavor text
    -- if data.flavorText == "" and string.find(data.icon, "quest_container_001") 
       -- and data.quality < ITEM_FUNCTIONAL_QUALITY_ARTIFACT
       -- and self:MatchGenericEquipmentText(data.name)
    -- then
        -- return true
    -- end
end

function class.VendorGear:MatchGenericEquipmentText(text)
    -- local stringIds = { 
        -- SI_UNBOXER_1H_WEAPON_LOWER, SI_UNBOXER_2H_WEAPON_LOWER, SI_UNBOXER_METAL_WEAPON_LOWER,
        -- SI_UNBOXER_WOOD_WEAPON_LOWER, SI_UNBOXER_ACCESSORY_LOWER, SI_UNBOXER_HEAVY_ARMOR_LOWER,
        -- SI_UNBOXER_LIGHT_ARMOR_LOWER, SI_UNBOXER_MEDIUM_ARMOR_LOWER, SI_UNBOXER_STAFF_LOWER,
        -- SI_UNBOXER_EQUIPMENT_LOWER
    -- }
    -- for _, stringId in ipairs(stringIds) do
        -- if addon:StringContainsStringIdOrDefault(text, stringId) then
            -- return true
        -- end
    -- end
end

knownIds = {
  [44778]=1,[44779]=1,[44780]=1,[44781]=1,[44782]=1,[44783]=1,
  [44784]=1,[44785]=1,[44786]=1,[44787]=1,[44789]=1,[44790]=1,
  [44791]=1,[44792]=1,[44793]=1,[44794]=1,[44795]=1,[44796]=1,
  [44797]=1,[44798]=1,[44891]=1,[44892]=1,[54394]=1,[54395]=1,
  [54396]=1,[54397]=1,[54398]=1,[54518]=1,[54519]=1,[54520]=1,
  [54521]=1,[54522]=1,[54523]=1,[54524]=1,[54525]=1,[54526]=1,
  [54527]=1,[54528]=1,[54529]=1,[54530]=1,[54531]=1,[54532]=1,
  [54533]=1,[54534]=1,[54535]=1,[54536]=1,[54537]=1,[54538]=1,
  [54539]=1,[54540]=1,[54541]=1,[54542]=1,[54543]=1,[54544]=1,
  [54545]=1,[54546]=1,[54547]=1,[54548]=1,[54549]=1,[54550]=1,
  [54551]=1,[54552]=1,[54553]=1,[54554]=1,[54555]=1,[54556]=1,
  [54557]=1,[54558]=1,[54559]=1,[54560]=1,[54561]=1,[54562]=1,
  [54563]=1,[54564]=1,[54565]=1,[54566]=1,[54567]=1,[54568]=1,
  [54569]=1,[54570]=1,[54571]=1,[54572]=1,[54573]=1,[54574]=1,
  [54575]=1,[54576]=1,[54577]=1,[54578]=1,[54580]=1,[54581]=1,
  [54582]=1,[54583]=1,[54584]=1,[54585]=1,[54586]=1,[54587]=1,
  [54588]=1,[54589]=1,[54590]=1,[54593]=1,[54594]=1,[54595]=1,
  [54596]=1,[54597]=1,[54598]=1,[54600]=1,[54601]=1,[54602]=1,
  [54603]=1,[54604]=1,[54605]=1,[54607]=1,[54608]=1,[54609]=1,
  [54610]=1,[54611]=1,[54613]=1,[54614]=1,[54615]=1,[54616]=1,
  [54617]=1,[54618]=1,[54619]=1,[54620]=1,[54621]=1,[54622]=1,
  [54623]=1,[54624]=1,[54625]=1,[54626]=1,[54627]=1,[54628]=1,
  [54732]=1,[54733]=1,[54734]=1,[54735]=1,[54736]=1,[54737]=1,
  [54738]=1,[54739]=1,[54740]=1,[54741]=1,[54742]=1,[54743]=1,
  [54744]=1,[54745]=1,[54746]=1,[54747]=1,[54748]=1,[54749]=1,
  [54750]=1,[54751]=1,[54752]=1,[54753]=1,[54754]=1,[54755]=1,
  [54756]=1,[54757]=1,[54758]=1,[54759]=1,[54760]=1,[54761]=1,
  [54762]=1,[54763]=1,[54764]=1,[54765]=1,[54766]=1,[54767]=1,
  [54768]=1,[54769]=1,[54770]=1,[54771]=1,[54772]=1,[54773]=1,
  [54774]=1,[54775]=1,[54776]=1,[54777]=1,[54778]=1,[54779]=1,
  [54780]=1,[54781]=1,[55278]=1,[55279]=1,[55280]=1,[55281]=1,
  [55282]=1,[55283]=1,[55284]=1,[55285]=1,[55286]=1,[55287]=1,
  [55288]=1,[55289]=1,[55290]=1,[55291]=1,[55292]=1,[55293]=1,
  [55294]=1,[55295]=1,[55296]=1,[55297]=1,[55298]=1,[55299]=1,
  [55300]=1,[55301]=1,[55302]=1,[55303]=1,[55304]=1,[55305]=1,
  [55306]=1,[55307]=1,[55308]=1,[55309]=1,[55310]=1,[55311]=1,
  [55312]=1,[55313]=1,[55314]=1,[55315]=1,[55316]=1,[55317]=1,
  [55328]=1,[55329]=1,[55330]=1,[55331]=1,[55332]=1,[55353]=1,
  [55354]=1,[69416]=1,[69418]=1,[69562]=1,[69563]=1,[69564]=1,
  [69565]=1,[69566]=1,[69567]=1,[69568]=1,[69569]=1,[69570]=1,
  [69571]=1,[69572]=1,[69573]=1,[71228]=1,[71229]=1,[71230]=1,
  [71231]=1,[71232]=1,[76873]=1,[76874]=1,[76875]=1,[76876]=1,
  [76877]=1,[79494]=1,[79495]=1,[79496]=1,[79497]=1,[79498]=1,
  [79499]=1,[79500]=1,[79501]=1,[79506]=1,[79507]=1,[79508]=1,
  [79509]=1,[79510]=1,[79511]=1,[79512]=1,[79513]=1,[79514]=1,
  [79515]=1,[79516]=1,[79517]=1,[79518]=1,[79519]=1,[79520]=1,
  [79521]=1,[79522]=1,[79523]=1,[79524]=1,[79525]=1,[79526]=1,
  [79527]=1,[79528]=1,[79529]=1,[79530]=1,[79531]=1,[79532]=1,
  [79533]=1,[79534]=1,[79535]=1,[79536]=1,[79537]=1,[79538]=1,
  [79539]=1,[79540]=1,[79541]=1,[79542]=1,[82121]=1,[82122]=1,
  [82123]=1,[82124]=1,[82125]=1,[82126]=1,[117643]=1,[117644]=1,
  [117645]=1,[117646]=1,[117647]=1,[117648]=1,[117649]=1,[117650]=1,
  [117651]=1,[117652]=1,[117924]=1,[118530]=1,[118531]=1,[118532]=1,
  [118533]=1,[118534]=1,[118535]=1,[118536]=1,[118537]=1,[118538]=1,
  [118539]=1,[118540]=1,[118541]=1,[118542]=1,[118543]=1,[118544]=1,
  [118545]=1,[118546]=1,[126093]=1,[126094]=1,[126095]=1,[126096]=1,
  [126097]=1,[126098]=1,[126099]=1,[126100]=1,[126101]=1,[126102]=1,
  [126103]=1,[126104]=1,[126105]=1,[175799]=1,[175800]=1,[175801]=1,
  [175802]=1,[184116]=1,[184117]=1,[184118]=1,[184177]=1,[184178]=1,
[184179]=1,
[184208]=1,
[184251]=1,
[190116]=1,
[190334]=1,
[190335]=1,
[190336]=1,
[190366]=1,
[193849]=1,
[194356]=1,
[194357]=1,
[194358]=1,
[198713]=1,
[198798]=1,
[198854]=1,
[199140]=1,
[199141]=1,
[199142]=1,
[199713]=1,
[199714]=1,
[199715]=1,
[199716]=1,
[199717]=1,
[199718]=1,
[199719]=1,
[199720]=1,
[199721]=1,
[199723]=1,
[199724]=1,
[203095]=1,
[203096]=1,
[203097]=1,
[203098]=1,
[203099]=1,
[203100]=1,
[203101]=1,
[203102]=1,
[203103]=1,
[203104]=1,
[203105]=1,
[203106]=1,
[203107]=1,
[203108]=1,
[204450]=1,
[204451]=1,
[204452]=1,
[204484]=1,
[211278]=1,
[211279]=1,
[211281]=1,
[211282]=1,
[211287]=1,
[211288]=1,
[211289]=1,
[211290]=1,
[211291]=1,
[211292]=1,
[211293]=1,
[211294]=1,
[211295]=1,
[211296]=1,
[212216]=1,
[212217]=1,
[212218]=1,
[212220]=1,
[212221]=1,
[212222]=1,
[212233]=1,
[212239]=1,
[212250]=1,
[212390]=1,
[212391]=1,
[212392]=1,
[214299]=1,
[214300]=1,
[214301]=1,
[214302]=1,
[214303]=1,
[214304]=1,
[214305]=1,
[214306]=1,
[214307]=1,
[214308]=1,
[214317]=1,
}