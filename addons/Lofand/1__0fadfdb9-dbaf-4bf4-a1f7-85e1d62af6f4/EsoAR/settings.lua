-- EsoAR settings panel (Settings > Add-Ons > EsoAR), built on LibAddonMenu-2.0.
-- Lets the player pick a font face and size scale per text category, and tune
-- the dialogue window. Everything is applied live through EsoAR:ApplyFonts().
local LAM = LibAddonMenu2
if not LAM then return end

local L = EsoAR.L
local CATS = { "heading", "body", "dialogue", "tooltip", "chat", "book" }

local function fontChoices()
  local names, values = {}, {}
  for _, f in ipairs(EsoAR.FONTS) do
    names[#names + 1] = L["FONT_" .. f.key] or f.key
    values[#values + 1] = f.key
  end
  return names, values
end

local function buildOptions()
  local sv = EsoAR.savedVars
  local names, values = fontChoices()
  local opts = {}

  -- ----------------------------------------------------------------- text
  -- Arabic / English switches first (checked = Arabic). Applied instantly.
  opts[#opts + 1] = { type = "header", name = L.H_TEXT }
  opts[#opts + 1] = { type = "description", text = L.MENU_TEXT_HINT }
  local function switch(label, get, set, apply)
    opts[#opts + 1] = {
      type = "checkbox",
      name = label,
      getFunc = get,
      setFunc = function(v) set(v); if apply then apply() end end,
    }
  end
  switch(L.TG_TRAITS, function() return not sv.englishTraits end, function(v) sv.englishTraits = not v end, function() EsoAR:ApplyTraitNames() end)
  switch(L.TG_SETS,   function() return not sv.englishSets end,   function(v) sv.englishSets = not v end,   nil)
  switch(L.TG_DIGITS, function() return sv.arabicDigits end,      function(v) sv.arabicDigits = v end,      function() EsoAR:ApplyFonts() end)
  switch(L.TG_ZONES,  function() return not sv.englishZones end,  function(v) sv.englishZones = not v end,  nil)

  opts[#opts + 1] = { type = "description", text = L.PANEL_DESC }

  -- ---------------------------------------------------------------- fonts
  opts[#opts + 1] = { type = "header", name = L.H_FONTS }
  for _, cat in ipairs(CATS) do
    opts[#opts + 1] = {
      type = "dropdown",
      name = L["CAT_" .. cat],
      tooltip = L.FONT_TT,
      choices = names,
      choicesValues = values,
      getFunc = function() return sv.fonts[cat] end,
      setFunc = function(v) sv.fonts[cat] = v; EsoAR:ApplyFonts() end,
      default = "noto",
      scrollable = true,
    }
  end
  opts[#opts + 1] = {
    type = "button",
    name = L.APPLY_ALL,
    tooltip = L.APPLY_ALL_TT,
    func = function()
      for _, cat in ipairs(CATS) do sv.fonts[cat] = sv.fonts.heading end
      EsoAR:ApplyFonts()
    end,
  }

  -- ---------------------------------------------------------------- sizes
  opts[#opts + 1] = { type = "header", name = L.H_SIZES }
  for _, cat in ipairs(CATS) do
    opts[#opts + 1] = {
      type = "slider",
      name = L["CAT_" .. cat],
      tooltip = L.SIZE_TT,
      min = 50, max = 200, step = 5,
      getFunc = function() return sv.scale[cat] end,
      setFunc = function(v) sv.scale[cat] = v; EsoAR:ApplyFonts() end,
      default = 100,
    }
  end

  -- ------------------------------------------------------------- dialogue
  opts[#opts + 1] = { type = "header", name = L.H_DIALOGUE }
  opts[#opts + 1] = {
    type = "colorpicker",
    name = L.DLG_COLOR,
    tooltip = L.DLG_COLOR_TT,
    getFunc = function()
      local c = sv.dialogueColor
      return c.r, c.g, c.b, c.a
    end,
    setFunc = function(r, g, b, a)
      sv.dialogueColor = { r = r, g = g, b = b, a = a, custom = true }
      EsoAR:ApplyFonts()
    end,
    default = { r = 0.77, g = 0.76, b = 0.62, a = 1 },
  }
  opts[#opts + 1] = {
    type = "slider",
    name = L.DLG_WIDTH,
    tooltip = L.DLG_WIDTH_TT,
    min = 0, max = 1200, step = 20,
    getFunc = function() return sv.dialogueWidth end,
    setFunc = function(v) sv.dialogueWidth = v; EsoAR:ApplyFonts() end,
    default = 0,
  }

  -- ---------------------------------------------------------------- tools
  opts[#opts + 1] = { type = "header", name = L.H_TOOLS }
  opts[#opts + 1] = {
    type = "button",
    name = L.RESET,
    tooltip = L.RESET_TT,
    func = function()
      for _, cat in ipairs(CATS) do sv.fonts[cat] = "noto"; sv.scale[cat] = 100 end
      sv.dialogueColor = { r = 0.77, g = 0.76, b = 0.62, a = 1, custom = false }
      sv.dialogueWidth = 0
      EsoAR:ApplyFonts()
    end,
    isDangerous = true,
  }
  opts[#opts + 1] = {
    type = "button",
    name = L.RELOAD,
    tooltip = L.RELOAD_TT,
    func = function() ReloadUI() end,
  }
  opts[#opts + 1] = { type = "description", text = L.NOTE_PREGAME }
  return opts
end

function EsoAR:RegisterSettings()
  local panel = {
    type = "panel",
    name = "EsoAR",
    displayName = L.PANEL_NAME,
    author = "EsoAR",
    version = EsoAR.version,
    registerForRefresh = true,
    registerForDefaults = true,
    slashCommand = "/esoar-lam",
  }
  LAM:RegisterAddonPanel("EsoAR_SettingsPanel", panel)
  LAM:RegisterOptionControls("EsoAR_SettingsPanel", buildOptions())
end
