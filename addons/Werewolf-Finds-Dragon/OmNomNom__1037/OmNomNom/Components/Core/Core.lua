omNomNomAddon = { foodText = {}, drinkText = {} }

local obj, db, playerName, lom = omNomNomAddon

function obj.onLoad(_, addon)
  if addon ~= "OmNomNom" then return end

  if LibStub then
    obj.lom = LibStub:GetLibrary("LibOmniMessage-3.0")
  end

  lom        = obj.lom
  playerName = GetUnitName("player")

  obj.foodText.khajiit   = playerName.." is a touch peckish, yes?"
  obj.drinkText.khajiit  = "This one is disturbingly sober."
  obj.foodText.highelf   = "I feel a base urge for fine dining."
  obj.drinkText.highelf  = "I could use a spot of tea."
  obj.foodText.woodelf   = "I could go for a leg of meat. Any kind."
  obj.drinkText.woodelf  = "I'd love a cuppa right now."
  obj.foodText.argonian  = "I'm so hungry I'd eat an alit."
  obj.drinkText.argonian = "I'm so thirsty I'd drink the sea."
  obj.foodText.darkelf   = "Again, I hunger. I should eat."
  obj.drinkText.darkelf  = "My throat is as dry as the ashlands."
  obj.foodText.nord      = "I could eat a horker-sized sweetroll!"
  obj.drinkText.nord     = "I'm not drunk enough for this!"
  obj.foodText.orc       = "I want a hearty meal."
  obj.drinkText.orc      = "Time to grog up!"
  obj.foodText.redguard  = "My stomach rumbles like a volcano."
  obj.drinkText.redguard = "My mouth is as dry as the sands."
  obj.foodText.breton    = "I feel rather famished."
  obj.drinkText.breton   = "I'd go for a pint right now."
  obj.foodText.imperial  = "I'm hungry, I'll eat something."
  obj.drinkText.imperial = "I'm thirsty, I'll drink something."

  obj.defaultsDB = {
    addonState             = true,
    [playerName]           = {
      foodText             = obj.foodText[ GetUnitRace("player"):lower():gsub("%s+", "")],
      drinkText            = obj.drinkText[GetUnitRace("player"):lower():gsub("%s+", "")]
    }
  }

  omNomNomAddonDB = omNomNomAddonDB or obj.defaultsDB
  db              = omNomNomAddonDB
  db[playerName]  = db[playerName]  or obj.defaultsDB[playerName]

  obj.buffNames                      = {
    ["increase max health"]                    = "food",
    ["increase max stamina"]                   = "food",
    ["increase max magicka"]                   = "food",
    ["increase max health & magicka"]          = "food",
    ["increase max health & stamina"]          = "food",
    ["increase max magicka & stamina"]         = "food",
    ["increase max health, magicka & stamina"] = "food",

    ["health recovery"]                    = "drink",
    ["stamina recovery"]                   = "drink",
    ["magicka recovery"]                   = "drink",
    ["health & magicka recovery"]          = "drink",
    ["health & stamina recovery"]          = "drink",
    ["magicka & stamina recovery"]         = "drink",
    ["health, magicka & stamina recovery"] = "drink",
  }

  obj.eventHandler(true)

  EVENT_MANAGER:UnregisterForEvent("OmNomNom_OnLoad")
end

function obj.checkSated(_, changeType, _, effectName, unitTag)
  if unitTag == "player" and changeType == 2 and type(effectName) == "string" then else return end

  local dbVal = db[playerName][(obj.buffNames[(effectName or ""):lower()] or "").."Text"]

  if not dbVal then return end

  obj.lom:Alert(dbVal)
end

function obj.eventHandler(load, reset)
  if reset or db.addonState then
    EVENT_MANAGER:RegisterForEvent("OmNomNom_Event", EVENT_EFFECT_CHANGED, obj.checkSated)
  elseif not db.addonState and not load then
    EVENT_MANAGER:UnregisterForEvent("OmNomNom_Event")
  end
end

function obj.debugTest(itemType)
  obj.checkSated(nil, 2, nil, itemType, "player")
end

EVENT_MANAGER:RegisterForEvent("OmNomNom_OnLoad", EVENT_ADD_ON_LOADED, obj.onLoad)