local KRT = KwibusRandomThings
local EM = EVENT_MANAGER
local WM = WINDOW_MANAGER
local ADDON_NAME = KRT.name

local EnsureTable = KRT.EnsureTable
local IsNonEmptyString = KRT.IsNonEmptyString
local DebounceNextFrame = KRT.DebounceNextFrame
local RGBToHex = KRT.RGBToHex

-- Module-local defaults wrapper 
local DEFAULTS = { kac = {
    enabled = true,
  } }

KRT.KAC = {
    id = "kac",
    defaults = DEFAULTS.kac,
  autoConfirmHooked = false,
}

function KRT.KAC:SV() return KRT.sv and KRT.sv.kac end

function KRT.KAC:Initialize()
  local sv = self:SV()
  if not sv then return end

  if self.autoConfirmHooked then return end
  self.autoConfirmHooked = true

  local function hook()
    zo_callLater(function()
      local sv2 = self:SV()
      if not (sv2 and sv2.enabled) then return end

      if ZO_Dialog1 and ZO_Dialog1.textParams and ZO_Dialog1.textParams.mainTextParams then
        for _, v in pairs(ZO_Dialog1.textParams.mainTextParams) do
          -- 1. zo_strupper handles Cyrillic (unlike string.upper)
          -- 2. v ~= zo_strlower ensures it actually contains letters (ignores "123")
          -- 3. not string.find ensures it's a single word (ignores ALL-CAPS multi-word item names)
          if type(v) == "string" and v == zo_strupper(v) and v ~= zo_strlower(v) and not string.find(v, " ") then
            if ZO_Dialog1EditBox and ZO_Dialog1EditBox.SetText then
              ZO_Dialog1EditBox:SetText(v)
              ZO_Dialog1EditBox:LoseFocus()
            end
          end
        end
      end
    end, 10)
  end

  ZO_PreHook("ZO_Dialogs_ShowDialog", hook)
end


-- =========================================================

local function SV() return KRT.sv end

function KRT.KAC:GetLAMSubmenu()
    return {
      type = "submenu",
      name = "Kwibus Confirm",
      controls = {
        { type = "checkbox", name = "Enable Auto-Confirm",
          tooltip = "Automatically fills in 'CONFIRM' or similar text when destructive dialogs appear.",
          getFunc = function() return SV().kac.enabled end,
          setFunc = function(v) SV().kac.enabled = v end,
          width = "full",
        },
      },
    }
end

KRT:RegisterModule(KRT.KAC)
