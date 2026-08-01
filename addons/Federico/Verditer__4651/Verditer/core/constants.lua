Verditer = Verditer or {}
local Verditer = Verditer

Verditer.Constants = {
  ADDON_NAME    = "Verditer",
  VERSION       = "0.9.0",
  SLASH_COMMAND = "/verditer",

  DEBUG         = false,

  SV_TABLE   = "VerditerSavedVars",
  SV_VERSION = 1,

  PROBE = {
    ROW_LIMIT        = 6000,
    CHAT_INTERVAL_MS = 500,
  },

  TEMPORAL = {
    UPDATE_NAME          = "VerditerTemporalSample",
    SAMPLE_RATE_DEFAULT  = 1000,
    TIME_WINDOW_DEFAULT  = 60,
  },

  METRICS = {
    DAMAGE_WINDOW_MS = 5000,
    SHIELD_WINDOW_MS = 5000,
  },

  POOL = {
    EVENT_CAPACITY = 4096,
  },

  GC = {
    PACING      = true,
    STEP_KB     = 2,
    INTERVAL_MS = 0,
  },

  ABILITY_KIND = {
    DMG_IN = 1,
    ABS_IN = 2,
  },

  RECAP = {
    SERVER_DELAY_MS = 2000,
    LEAD_SECONDS    = 10,
    LEAD_SAMPLE_MS  = 250,
    MAX_DEATHS      = 25,
    MAX_ATTACKS     = 6,
  },


  BRAND = {
    BLUE      = { r = 0.18,  g = 0.42,  b = 0.88,  a = 1.0 },  -- #2E6BE0 primary
    BLUE_DEEP = { r = 0.12,  g = 0.28,  b = 0.66,  a = 1.0 },  -- #1E47A8 borders
    TINT      = { r = 0.043, g = 0.063, b = 0.125, a = 1.0 },  -- #0B1020 window bg
    ACCENT    = { r = 0.435, g = 0.659, b = 1.0,   a = 1.0 },  -- #6FA8FF lines
    DANGER    = { r = 0.90,  g = 0.30,  b = 0.25,  a = 1.0 },  -- #E64D40 HP stripe
    EDGE      = { r = 0.22,  g = 0.54,  b = 1.0,   a = 1.0  },  -- vivid border
    CHROME    = { r = 0.32,  g = 0.56,  b = 1.0,   a = 0.88 },  -- inner chrome wash
  },

  PROFILER_BUDGETS_MS = {
    ["pipeline.combat_event"]             = 5.0,
    ["pipeline.combat_event.acquisition"] = 2.0,
    ["pipeline.combat_event.filter"]      = 2.0,
    ["pipeline.combat_event.processing"]  = 3.0,
    ["pipeline.render_tick"]              = 10.0,
    ["graph.sample_tick"]                 = 15.0,
    ["render.OUTCOME"]                    = 12.0,
    ["render.TYPE"]                       = 12.0,
    ["render.SURVIVAL"]                   = 12.0,
    ["render.SOURCE"]                     = 12.0,
  },
}
