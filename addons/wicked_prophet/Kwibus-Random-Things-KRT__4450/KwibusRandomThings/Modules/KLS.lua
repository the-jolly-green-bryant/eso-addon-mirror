local KRT = KwibusRandomThings
local EM = EVENT_MANAGER
local WM = WINDOW_MANAGER
local ADDON_NAME = KRT.name

local EnsureTable = KRT.EnsureTable
local IsNonEmptyString = KRT.IsNonEmptyString
local DebounceNextFrame = KRT.DebounceNextFrame
local RGBToHex = KRT.RGBToHex

-- Module-local defaults wrapper
local DEFAULTS = { kls = {
    enabled = false,
    promptToEnglishOnTrial = true,
    promptBackToRussian = true,
    swapBackDelayMs = 300000, -- 5 minutes
    englishCode = "en",
    russianCode = "ru",
    debug = false,
  } }

KRT.KLS = {
    id = "kls",
    defaults = DEFAULTS.kls,
  TIMER_NAME = ADDON_NAME .. "_KLS_Timer",
  wasInTrial = false,
  trialZoneIds = {
    [114]  = true, [108]  = true, [14]   = true, [725]  = true,
    [975]  = true, [1000] = true, [1051] = true, [1121] = true,
    [1196] = true, [1263] = true, [1344] = true, [1420] = true, [1478] = true,
  },
}

function KRT.KLS:SV() return KRT.sv and KRT.sv.kls end
function KRT.KLS:Dbg(msg) local sv = self:SV(); if sv and sv.debug then d("[KLS] " .. tostring(msg)) end end

function KRT.KLS:AttemptSwapBackPrompt()
  EM:UnregisterForUpdate(self.TIMER_NAME)
  local sv = self:SV()
  if not (sv and sv.enabled and sv.promptBackToRussian) then return end
  if GetCVar("language.2") == sv.englishCode then
    ZO_Dialogs_ShowDialog("KRT_LANG_SWAP_BACK")
  end
end

function KRT.KLS:OnPlayerActivated()
  local sv = self:SV()
  if not (sv and sv.enabled) then return end
  local zoneId = GetZoneId(GetUnitZoneIndex("player"))
  local isTrial = self.trialZoneIds[zoneId] or false

  if isTrial then
    EM:UnregisterForUpdate(self.TIMER_NAME)
    self.wasInTrial = true
    if sv.promptToEnglishOnTrial and GetCVar("language.2") ~= sv.englishCode then
      ZO_Dialogs_ShowDialog("KRT_LANG_SWAP_EN")
    end
  else
    if self.wasInTrial then
      self.wasInTrial = false
      local delay = tonumber(sv.swapBackDelayMs) or DEFAULTS.kls.swapBackDelayMs
      EM:RegisterForUpdate(self.TIMER_NAME, delay, function() self:AttemptSwapBackPrompt() end)
    end
  end
end

function KRT.KLS:Initialize()
  ZO_Dialogs_RegisterCustomDialog("KRT_LANG_SWAP_EN", {
    title = { text = "Trial Detected" },
    mainText = { text = "You are entering a Trial. Swap language to English?" },
    buttons = {
      [1] = { text = "Yes", callback = function()
        local sv = self:SV(); if sv then SetCVar("language.2", sv.englishCode or "en") end
      end },
      [2] = { text = "No" },
    },
  })

  ZO_Dialogs_RegisterCustomDialog("KRT_LANG_SWAP_BACK", {
    title = { text = "Trial Finished" },
    mainText = { text = "You left the Trial a while ago. Swap back to Russian?" },
    buttons = {
      [1] = { text = "Yes", callback = function()
        local sv = self:SV(); if sv then SetCVar("language.2", sv.russianCode or "ru") end
      end },
      [2] = { text = "No" },
    },
  })

  EM:RegisterForEvent(ADDON_NAME .. "_KLS_Activated", EVENT_PLAYER_ACTIVATED, function()
    self:OnPlayerActivated()
  end)
end

-- =========================================================

local function SV() return KRT.sv end

function KRT.KLS:GetLAMSubmenu()
    return {
      type = "submenu",
      name = "Kwibus Language Swap",
      controls = {
        { type = "checkbox", name = "Enable LanguageSwap",
          getFunc = function() return SV().kls.enabled end,
          setFunc = function(v) SV().kls.enabled = v end,
          width = "full",
        },
        { type = "checkbox", name = "Prompt to swap to English on trial entry",
          getFunc = function() return SV().kls.promptToEnglishOnTrial end,
          setFunc = function(v) SV().kls.promptToEnglishOnTrial = v end,
          width = "full",
          disabled = function() return not SV().kls.enabled end,
        },
        { type = "checkbox", name = "Prompt to swap back to Russian after leaving",
          getFunc = function() return SV().kls.promptBackToRussian end,
          setFunc = function(v) SV().kls.promptBackToRussian = v end,
          width = "full",
          disabled = function() return not SV().kls.enabled end,
        },
        { type = "slider", name = "Swap-back delay (seconds)", min = 5, max = 900, step = 5,
          getFunc = function() return math.floor((SV().kls.swapBackDelayMs or 300000) / 1000) end,
          setFunc = function(v) SV().kls.swapBackDelayMs = v * 1000 end,
          width = "full",
          disabled = function() return not SV().kls.enabled end,
        },
        { type = "checkbox", name = "KLS debug",
          getFunc = function() return SV().kls.debug end,
          setFunc = function(v) SV().kls.debug = v end,
          width = "full",
          disabled = function() return not SV().kls.enabled end,
        },
      },
    }
end

KRT:RegisterModule(KRT.KLS)

