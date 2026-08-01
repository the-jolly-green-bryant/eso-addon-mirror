local obj = SmartBags

function obj.SetupMenu(db)
  obj.LAM = LibStub("LibAddonMenu-2.0")

  obj.panelData         = {
    type                = "panel",
    name                = obj.strings.name,
    author              = "Werewolf Finds Dragon",
    version             = "002",
    registerForRefresh  = true,
    registerForDefaults = true
  }

  obj.optionsData = {
    {
      type        = "header",
      name        = ("%s %s"):format(obj.Color(obj.strings.name, "aaaaff"), obj.strings.options)
    },

    {
      type        = "checkbox",
      name        = obj.strings.unlock,
      tooltip     = obj.strings.unlockDesc,
      getFunc     = function() return db.unlock       end,
      setFunc     = function(val)     db.unlock = val end,
      default     = obj.Defaults.unlock
    },

    {
      type        = "checkbox",
      name        = obj.strings.auto,
      tooltip     = obj.strings.autoDesc,
      getFunc     = function() return db.auto       end,
      setFunc     = function(val)     db.auto = val end,
      default     = obj.Defaults.auto
    },
    {
      type        = "checkbox",
      name        = obj.strings.smart,
      tooltip     = obj.strings.smartDesc,
      getFunc     = function() return db.smart       end,
      setFunc     = function(val)     db.smart = val end,
      default     = obj.Defaults.smart
    },

    {
      type        = "slider",
      name        = obj.strings.warn,
      tooltip     = obj.strings.warnDesc,
      min         = 0,
      max         = 100,
      step        = 1,
      getFunc     = function() return db.warn       end,
      setFunc     = function(val)     db.warn = val end,
      default     = obj.Defaults.warn
    },

    {
      type        = "slider",
      name        = obj.strings.alpha,
      tooltip     = obj.strings.alphaDesc,
      min         = 0,
      max         = 1.0,
      step        = 0.1,
      getFunc     = function() return db.alpha                                 end,
      setFunc     = function(val)     db.alpha = val SmartBagsUI:SetAlpha(val) end,
      default     = obj.Defaults.alpha
    },

    {
      type        = "colorpicker",
      name        = obj.strings.colorBase,
      tooltip     = obj.strings.colorBaseDesc,
      getFunc     = function() return    db.baseR, db.baseG, db.baseB end,
      setFunc     = function(r, g, b, a) db.baseR, db.baseG, db.baseB = r, g, b end,
      default     = {r = obj.Defaults.baseR, g = obj.Defaults.baseG, b = obj.Defaults.baseB}
    },

    {
      type        = "colorpicker",
      name        = obj.strings.colorWarn,
      tooltip     = obj.strings.colorWarnDesc,
      getFunc     = function() return     db.warnR, db.warnG, db.warnB end,
      setFunc     = function(r, g, b, a)  db.warnR, db.warnG, db.warnB = r, g, b end,
      default     = {r = obj.Defaults.warnR, g = obj.Defaults.warnG, b = obj.Defaults.warnB}
    },

    {
      type        = "colorpicker",
      name        = obj.strings.colorFull,
      tooltip     = obj.strings.colorFullDesc,
      getFunc     = function() return    db.fullR, db.fullG, db.fullB end,
      setFunc     = function(r, g, b, a) db.fullR, db.fullG, db.fullB = r, g, b end,
      default     = {r = obj.Defaults.fullR, g = obj.Defaults.fullG, b = obj.Defaults.fullB}
    }
  }

  obj.LAM:RegisterAddonPanel(    "SmartBags_Options", obj.panelData)
  obj.LAM:RegisterOptionControls("SmartBags_Options", obj.optionsData)
end