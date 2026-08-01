local localizedStrings = {
  ["en"] = {
    CHROMA_NOT_ENABLED_WARNING = "|cff0000Warning|r: The |c44d62cRazer Chroma™|r system is not enabled.",
    ALLIANCE_SETTINGS = "Alliance Settings",
    ALLIANCE_HEADER = "Alliance Background",
    BATTLEGROUNDS_HEADER = "Battlegrounds Background",
    USE_CUSTOM_X_COLOR = "Use custom <<1>> color",
    CUSTOM_X_COLOR = "Custom <<1>> color",
    BACKGROUND_COLOR = "Background Color",
    BACKGROUND = "background",
    USE_DURING_BATTLEGROUND = "Use this color during battlegrounds matches",
    NOTIFICATION_COLORS = "Notification Colors",
    DEATH_EFFECT = "death effect",
    DEATH_KEYBINDS = "death keybinds",
    DEATH_KEYBINDS_HEADER = "Individual Death Keybinds",
    KEYBIND_READY = "<<1>> ready",
    KEYBINDS = {
      ACTION_BUTTON_8 = "ultimate",
      ACTION_BUTTON_9 = "quickslot",
      DEATH_PRIMARY = "death primary",
      DEATH_SECONDARY = "death secondary",
      DEATH_TERTIARY = "death tertiary",
      DEATH_DECLINE = "death decline",
      DEATH_RECAP_TOGGLE = "death recap toggle",
      DEATH_RECAP_HIDE = "death recap hide",
    },
    ALLIANCES = {
      [ALLIANCE_ALDMERI_DOMINION] = {
        TOOLTIP = "Typically a shade of yellow.",
      },
      [ALLIANCE_EBONHEART_PACT] = {
        TOOLTIP = "Typically a shade of red.",
      },
      [ALLIANCE_DAGGERFALL_COVENANT] = {
        TOOLTIP = "Typically a shade of blue.",
      },
    },
    BATTLEGROUND_ALLIANCES = {
      [BATTLEGROUND_ALLIANCE_FIRE_DRAKES] = {
        TOOLTIP = "Typically a shade of orange.",
      },
      [BATTLEGROUND_ALLIANCE_PIT_DAEMONS] = {
        TOOLTIP = "Typically a shade of green.",
      },
      [BATTLEGROUND_ALLIANCE_STORM_LORDS] = {
        TOOLTIP = "Typically a shade of purple.",
      },
    },
  },
}

local function sharedStrings()
  return {
    ALLIANCES = {
      [ALLIANCE_ALDMERI_DOMINION] = {
        NAME = GetString(SI_ALLIANCE1),
      },
      [ALLIANCE_EBONHEART_PACT] = {
        NAME = GetString(SI_ALLIANCE2),
      },
      [ALLIANCE_DAGGERFALL_COVENANT] = {
        NAME = GetString(SI_ALLIANCE3),
      },
    },
    BATTLEGROUND_ALLIANCES = {
      [BATTLEGROUND_ALLIANCE_FIRE_DRAKES] = {
        NAME = GetString(SI_BATTLEGROUNDALLIANCE1),
      },
      [BATTLEGROUND_ALLIANCE_PIT_DAEMONS] = {
        NAME = GetString(SI_BATTLEGROUNDALLIANCE2),
      },
      [BATTLEGROUND_ALLIANCE_STORM_LORDS] = {
        NAME = GetString(SI_BATTLEGROUNDALLIANCE3),
      },
    },
  }
end

local function mergeTables(base, special)
  local merged = {}
  for k,b in pairs(base) do
    merged[k] = b
  end
  for k,s in pairs(special) do
    if s then
      local o = merged[k]
      if type(s) == "table" and type(o) == "table" then
        s = mergeTables(o, s)
      end
      merged[k] = s
    end
  end
  return merged
end

ChromaConfig.stringCache = {}
function ChromaConfig:GetStrings()
  local lang = GetCVar("language.2")
  local cached = ChromaConfig.stringCache[lang]
  if cached then return cached end

  local strings = localizedStrings[lang]
  if not strings then strings = localizedStrings["en"] end
  cached = mergeTables(sharedStrings(), strings)
  ChromaConfig.stringCache[lang] = cached
  return cached
end
