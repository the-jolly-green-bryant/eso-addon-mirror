DungeonFinderPlus = DungeonFinderPlus or {}
local DFP = DungeonFinderPlus

-- ───────────────── Lokalisierungs-Funktion ─────────────────
local function L(k)
  return (DFP.i18n and DFP.i18n.L and DFP.i18n.L(k)) or k
end

-- ───────────────── Settings-Panel Initialisierung ─────────────────
function DFP.SettingsInit()
  -- SavedVars vorhanden?
  if not DFP.sv then
    d("[DungeonFinderPlus] ERROR: SavedVars not loaded before SettingsInit!")
    return
  end

  -- LibAddonMenu2 vorhanden?
  local LAM = LibAddonMenu2
  if not LAM then
    d("[DungeonFinderPlus] ERROR: LibAddonMenu2 not found!")
    d("[DungeonFinderPlus] Install from: www.esoui.com/downloads/info7-LibAddonMenu.html")
    return
  end

  -- Default-Werte (lokal für diese Funktion)
  local defaults = { autoPledge = { enabled = true } }

  -- autoPledge-Struktur sicherstellen
  DFP.sv.autoPledge = DFP.sv.autoPledge or {}
  if DFP.sv.autoPledge.enabled == nil then
    DFP.sv.autoPledge.enabled = defaults.autoPledge.enabled
  end

  -- ───────────────── Panel-Definition ─────────────────
  local panelData = {
    type = "panel",
    name = L("panel_name"),
    author = DFP.author or "Unknown",
    version = DFP.version or "?.?.?",
    registerForRefresh = true,
    registerForDefaults = true,
  }

  -- ───────────────── Optionen-Definition ─────────────────
  local options = {
    {
      type = "checkbox",
      name = L("opt_auto_pledge"),
      tooltip = L("opt_auto_pledge_tip"),
      getFunc = function()
        -- Defensive Guards
        if not DFP.sv then return true end
        if not DFP.sv.autoPledge then return true end
        return DFP.sv.autoPledge.enabled ~= false
      end,
      setFunc = function(value)
        -- Defensive Guards
        if not DFP.sv then return end
        if not DFP.sv.autoPledge then DFP.sv.autoPledge = {} end
        DFP.sv.autoPledge.enabled = value
      end,
      width = "full",
      default = defaults.autoPledge.enabled,
    },
  }

  -- ───────────────── Panel registrieren ─────────────────
  LAM:RegisterAddonPanel("DungeonFinderPlus_SettingsPanel", panelData)
  LAM:RegisterOptionControls("DungeonFinderPlus_SettingsPanel", options)
end
