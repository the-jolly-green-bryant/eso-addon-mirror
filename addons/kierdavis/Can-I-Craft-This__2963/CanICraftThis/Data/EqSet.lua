CanICraftThis.EqSet = {
  instances = {},
}
function CanICraftThis.EqSet:register(instance)
  CanICraftThis.assert(instance.name ~= nil, "instance.name ~= nil")
  CanICraftThis.assert(instance.getNumRequiredTraits ~= nil, "instance.getNumRequiredTraits ~= nil")
  instance.namePattern = CanICraftThis.literalPattern(instance.name)
  instance.writTextPattern = "set: " .. instance.namePattern
  table.insert(self.instances, instance)
end

local function always(n)
  return function(recipe) return n end
end
local function ancientDragonguard(recipe)
  if recipe.name == "Epaulets" or recipe.name == "Arm Cops" or recipe.name == "Pauldron" then
    return 3
  else
    return 6
  end
end

function CanICraftThis.EqSet:registerAll()
  self:register { name = "Ashen Grip", getNumRequiredTraits = always(2) }
  self:register { name = "Death's Wind", getNumRequiredTraits = always(2) }
  self:register { name = "Night's Silence", getNumRequiredTraits = always(2) }
  self:register { name = "Armor of the Seducer", getNumRequiredTraits = always(3) }
  self:register { name = "Torug's Pact", getNumRequiredTraits = always(3) }
  self:register { name = "Twilight's Embrace", getNumRequiredTraits = always(3) }
  self:register { name = "Hist Bark", getNumRequiredTraits = always(4) }
  self:register { name = "Magnus' Gift", getNumRequiredTraits = always(4) }
  self:register { name = "Whitestrake's Retribution", getNumRequiredTraits = always(4) }
  self:register { name = "Alessia's Bulwark", getNumRequiredTraits = always(5) }
  self:register { name = "Song of Lamae", getNumRequiredTraits = always(5) }
  self:register { name = "Vampire's Kiss", getNumRequiredTraits = always(5) }
  self:register { name = "Hunding's Rage", getNumRequiredTraits = always(6) }
  self:register { name = "Night Mother's Gaze", getNumRequiredTraits = always(6) }
  self:register { name = "Willow's Path", getNumRequiredTraits = always(6) }
  self:register { name = "Critical Riposte", getNumRequiredTraits = always(3) }
  self:register { name = "Dauntless Combatant", getNumRequiredTraits = always(3) }
  self:register { name = "Unchained Aggressor", getNumRequiredTraits = always(3) }
  self:register { name = "Oblivion's Foe", getNumRequiredTraits = always(8) }
  self:register { name = "Spectre's Eye", getNumRequiredTraits = always(8) }
  self:register { name = "Kagrenac's Hope", getNumRequiredTraits = always(8) }
  self:register { name = "Orgnum's Scales", getNumRequiredTraits = always(8) }
  self:register { name = "Eyes of Mara", getNumRequiredTraits = always(8) }
  self:register { name = "Shalidor's Curse", getNumRequiredTraits = always(8) }
  self:register { name = "Way of the Arena", getNumRequiredTraits = always(8) }
  self:register { name = "Twice-Born Star", getNumRequiredTraits = always(9) }
  self:register { name = "Armor Master", getNumRequiredTraits = always(9), dlcName = "Imperial City" }
  self:register { name = "Noble's Conquest", getNumRequiredTraits = always(5), dlcName = "Imperial City" }
  self:register { name = "Redistributor", getNumRequiredTraits = always(7), dlcName = "Imperial City" }
  self:register { name = "Law of Julianos", getNumRequiredTraits = always(6), dlcName = "Orsinium" }
  self:register { name = "Morkuldin", getNumRequiredTraits = always(9), dlcName = "Orsinium" }
  self:register { name = "Trial by Fire", getNumRequiredTraits = always(3), dlcName = "Orsinium" }
  self:register { name = "Clever Alchemist", getNumRequiredTraits = always(7), dlcName = "Thieves Guild" }
  self:register { name = "Eternal Hunt", getNumRequiredTraits = always(9), dlcName = "Thieves Guild" }
  self:register { name = "Tava's Favor", getNumRequiredTraits = always(5), dlcName = "Thieves Guild" }
  self:register { name = "Kvatch Gladiator", getNumRequiredTraits = always(5), dlcName = "Dark Brotherhood" }
  self:register { name = "Pelinal's Aptitude", getNumRequiredTraits = always(9), dlcName = "Dark Brotherhood" }
  self:register { name = "Varen's Legacy", getNumRequiredTraits = always(7), dlcName = "Dark Brotherhood" }
  self:register { name = "Fortified Brass", getNumRequiredTraits = always(4), dlcName = "Clockwork City" }
  self:register { name = "Innate Axiom", getNumRequiredTraits = always(2), dlcName = "Clockwork City" }
  self:register { name = "Mechanical Acuity", getNumRequiredTraits = always(6), dlcName = "Clockwork City" }
  self:register { name = "Assassin's Guile", getNumRequiredTraits = always(3), dlcName = "Morrowind" }
  self:register { name = "Daedric Trickery", getNumRequiredTraits = always(8), dlcName = "Morrowind" }
  self:register { name = "Shacklebreaker", getNumRequiredTraits = always(6), dlcName = "Morrowind" }
  self:register { name = "Adept Rider", getNumRequiredTraits = always(3), dlcName = "Summerset" }
  self:register { name = "Nocturnal's Favor", getNumRequiredTraits = always(9), dlcName = "Summerset" }
  self:register { name = "Sload's Semblance", getNumRequiredTraits = always(6), dlcName = "Summerset" }
  self:register { name = "Grave-Stake Collector", getNumRequiredTraits = always(7), dlcName = "Murkmire" }
  self:register { name = "Might of the Lost Legion", getNumRequiredTraits = always(4), dlcName = "Murkmire" }
  self:register { name = "Naga Shaman", getNumRequiredTraits = always(2), dlcName = "Murkmire" }
  self:register { name = "Coldharbour's Favorite", getNumRequiredTraits = always(8), dlcName = "Elsweyr" }
  self:register { name = "Senche-raht's Grit", getNumRequiredTraits = always(5), dlcName = "Elsweyr" }
  self:register { name = "Vastarie's Tutelage", getNumRequiredTraits = always(3), dlcName = "Elsweyr" }
  self:register { name = "Daring Corsair", getNumRequiredTraits = always(3), dlcName = "Dragonhold" }
  self:register { name = "New Moon Acolyte", getNumRequiredTraits = always(9), dlcName = "Dragonhold" }
  self:register { name = "Ancient Dragonguard", getNumRequiredTraits = ancientDragonguard, dlcName = "Dragonhold" }
  self:register { name = "Dragon's Appetite", getNumRequiredTraits = always(7), dlcName = "Greymoor" }
  self:register { name = "Stuhn's Favor", getNumRequiredTraits = always(5), dlcName = "Greymoor" }
  self:register { name = "Spell Parasite", getNumRequiredTraits = always(3), dlcName = "Greymoor" }
  self:register { name = "Legacy of Karth", getNumRequiredTraits = always(6), dlcName = "Markarth" }
  self:register { name = "Red Eagle's Fury", getNumRequiredTraits = always(3), dlcName = "Markarth" }
  self:register { name = "Aetherial Ascension", getNumRequiredTraits = always(9), dlcName = "Markarth" }
end

CanICraftThis.EqSet:registerAll()

function CanICraftThis.EqSet:fromWritText(writText)
  local writText = string.lower(writText)
  local instance
  for _, instance in ipairs(self.instances) do
    if string.find(writText, instance.writTextPattern) then
      return instance
    end
  end
  CanICraftThis.reportUnexpected("writ text did not match any registered EqSet: " .. writText)
  return nil
end
