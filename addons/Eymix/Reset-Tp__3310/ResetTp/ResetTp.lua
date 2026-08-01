ResetTp = {
  name = "ResetTp",
  version = "1.1",

  default = {
    trial = "CR",
  },

  sv = nil,
  svVersion = 1,
  svName = "ResetTpVars",

  TrialZoneIds = {
    ["HRC"] = 230,
    ["SO"] = 232,
    ["AA"] = 231,
    ["AS"] = 346,
    ["CR"] = 364,
    ["SS"] = 399,
    ["KA"] = 434,
    ["RG"] = 468,
    ["DSR"] = 488,
    ["DSA"] = 270,
    ["BRP"] = 378,
    ["MA"] = 250,
  }
}

local RTP = ResetTp

function RTP.OnAddOnLoaded(_, name)
  if name == RTP.name then
    RTP:Initialize()
    EVENT_MANAGER:UnregisterForEvent(RTP.name, EVENT_ADD_ON_LOADED)
  end
end

EVENT_MANAGER:RegisterForEvent(RTP.name, EVENT_ADD_ON_LOADED, RTP.OnAddOnLoaded)

function RTP:Initialize()
  ZO_CreateStringId("SI_BINDING_NAME_RESETTP", "Teleport to raid")

  SLASH_COMMANDS["/rtp"] = ResetTp.keybind
  -- Uncomment the following line to get the trial node ids
  -- SLASH_COMMANDS["/rtptrialnodeinfo"] = ResetTp.trialNodeInfo

  ResetTp.sv = ZO_SavedVars:NewAccountWide(ResetTp.svName, ResetTp.svVersion, nil, ResetTp.default)

  ResetTp.CreateSettingsWindow()
  -- I hope you're having fun reading the code :)
end

-- Travel function
function ResetTp.keybind()
  FastTravelToNode(ResetTp.TrialZoneIds[ResetTp.sv.trial])
end

-- Get node infos to fill TrialZoneIds
function ResetTp.trialNodeInfo()
  local totalNodes = GetNumFastTravelNodes()
  local i = 1
  while i <= totalNodes do
    known,  name,  normalizedX,  normalizedY,  icon,  glowIcon,  poiType,  isShownInCurrentMap,  linkedCollectibleIsLocked = GetFastTravelNodeInfo(i)
    -- Note for Maelstrom : the node 249 just doesn't work
    if (string.find(name, "Trial") or string.find(name, "Dragonstar Arena") or string.find(name, "Blackrose Prison") or string.find(name, "Maelstrom")) and not string.find(name, "Wayshrine") then
      d(name.." // Node: "..i)
    end
    i = i + 1
  end
end

-- Menu part
local LAM2 = LibAddonMenu2
function ResetTp.CreateSettingsWindow()
  local panelData = {
    type = "panel",
    name = "Reset Tp",
    displayName = "Reset Tp",
    author = "|c57fffcEymix|r",
    version = "|c57fffc1.1|r",
    slashCommand = "/rtpmenu",
  }

  local optionsData = {
    {
      type = "header",
      name = "|c57fffcR|reset |c57fffcT|rp |c57fffcS|rettings",
    },
    {
      type = "description",
      text = "You can choose what trial you want to go to below. To use the addon you can choose to use a keybind or type /rtp to teleport. Disclaimer : it costs the gold !",
    },
    {
      type = "header",
      name = "|c57fffcTrial|r",
    },
    {
      type = "dropdown",
      name = "Trial list",
      choices = {"HRC", "SO", "AA", "AS", "CR", "SS", "KA", "RG", "DSR", "DSA", "BRP", "MA"},
      getFunc = function() return ResetTp.sv.trial end,
      setFunc = function(value)
        ResetTp.sv.trial = value
      end,
      width = "full",
    },
  }

  LAM2:RegisterAddonPanel("ResetTp" .. "Menu", panelData)
  LAM2:RegisterOptionControls("ResetTp" .. "Menu", optionsData)
end
