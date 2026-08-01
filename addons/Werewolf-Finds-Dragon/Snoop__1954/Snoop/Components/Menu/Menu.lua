local obj = Snoop

function obj.SetupMenu(db)
  obj.LAM = LibStub("LibAddonMenu-2.0")

  obj.panelData         = {
    type                = "panel",
    name                = obj.strings.name,
    author              = "Werewolf Finds Dragon",
    version             = "001",
    registerForRefresh  = true,
    registerForDefaults = true
  }

  obj.optionsData = {
    {
      type        = "header",
      name        = ("|caaaaff%s|r %s"):format(obj.strings.name, obj.strings.options)
    },

    {
      type        = "checkbox",
      name        = obj.strings.gold.." "..obj.strings.reports,
      tooltip     = obj.strings.goldDesc,
      getFunc     = function() return db.gold       end,
      setFunc     = function(val)     db.gold = val end,
      default     = obj.Defaults.gold
    },

    {
      type        = "checkbox",
      name        = obj.strings.loot.." "..obj.strings.reports,
      tooltip     = obj.strings.lootDesc,
      getFunc     = function() return db.loot       end,
      setFunc     = function(val)     db.loot = val end,
      default     = obj.Defaults.loot
    },

    {
      type        = "checkbox",
      name        = obj.strings.count.." "..obj.strings.reports,
      tooltip     = obj.strings.countDesc,
      getFunc     = function() return db.count       end,
      setFunc     = function(val)     db.count = val end,
      default     = obj.Defaults.count
    },

    {
      type        = "checkbox",
      name        = obj.strings.party.." "..obj.strings.reports,
      tooltip     = obj.strings.partyDesc,
      getFunc     = function() return db.party       end,
      setFunc     = function(val)     db.party = val end,
      default     = obj.Defaults.party
    },

    {
      type        = "checkbox",
      name        = obj.strings.craft.." "..obj.strings.reports,
      tooltip     = obj.strings.craftDesc,
      getFunc     = function() return db.craft       end,
      setFunc     = function(val)     db.craft = val end,
      default     = obj.Defaults.craft
    },

    {
      type        = "checkbox",
      name        = obj.strings.show,
      tooltip     = obj.strings.showDesc,
      getFunc     = function() return db.show       end,
      setFunc     = function(val)     db.show = val end,
      default     = obj.Defaults.show
    },

    {
      type        = "colorpicker",
      name        = obj.strings.colorGold,
      tooltip     = obj.strings.colorGoldDesc,
      getFunc     = function() return    db.goldR, db.goldG, db.goldB end,
      setFunc     = function(r, g, b, a) db.goldR, db.goldG, db.goldB = r, g, b end,
      default     = {r = obj.Defaults.goldR, g = obj.Defaults.goldG, b = obj.Defaults.goldB}
    },

    {
      type        = "colorpicker",
      name        = obj.strings.colorLost,
      tooltip     = obj.strings.colorLostDesc,
      getFunc     = function() return    db.lostR, db.lostG, db.lostB end,
      setFunc     = function(r, g, b, a) db.lostR, db.lostG, db.lostB = r, g, b end,
      default     = {r = obj.Defaults.lostR, g = obj.Defaults.lostG, b = obj.Defaults.lostB}
    },

    {
      type        = "colorpicker",
      name        = obj.strings.colorLoot,
      tooltip     = obj.strings.colorLootDesc,
      getFunc     = function() return    db.lootR, db.lootG, db.lootB end,
      setFunc     = function(r, g, b, a) db.lootR, db.lootG, db.lootB = r, g, b end,
      default     = {r = obj.Defaults.lootR, g = obj.Defaults.lootG, b = obj.Defaults.lootB}
    },

    {
      type        = "colorpicker",
      name        = obj.strings.colorParty,
      tooltip     = obj.strings.colorPartyDesc,
      getFunc     = function() return    db.partyR, db.partyG, db.partyB end,
      setFunc     = function(r, g, b, a) db.partyR, db.partyG, db.partyB = r, g, b end,
      default     = {r = obj.Defaults.partyR, g = obj.Defaults.partyG, b = obj.Defaults.partyB}
    },

    {
      type        = "colorpicker",
      name        = obj.strings.colorCraft,
      tooltip     = obj.strings.colorCraftDesc,
      getFunc     = function() return    db.craftR, db.craftG, db.craftB end,
      setFunc     = function(r, g, b, a) db.craftR, db.craftG, db.craftB = r, g, b end,
      default     = {r = obj.Defaults.craftR, g = obj.Defaults.craftG, b = obj.Defaults.craftB}
    }
  }

  obj.LAM:RegisterAddonPanel(    "Snoop_Options", obj.panelData)
  obj.LAM:RegisterOptionControls("Snoop_Options", obj.optionsData)
end