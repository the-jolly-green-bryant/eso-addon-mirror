local SBMI = SBMI
local DBGN = DBGN
SBMI.LAM = LibAddonMenu2
SBMI.MainMenuPanel = nil

local function nvl(a, b) if a == nil then return b end return a end

function SBMI:CreateOptionsPanel()
  local SV = self.SV
  local Lng0 = self.i18n
  local Lng1 = DBGN.i18n
  local Guild = self.GetGuildSB()
  local DefXY = self.DefXY
  local OptPanel = {
    type = "panel",
    name = "SBMI",
    author = "[EU] |c779cff@ForgottenLight|r, |c779cff@Ned_Washington|r, |c779cff@Ph0enix21|r",
    version = SBMI.Version,
    registerForRefresh = true,
    registerForDefaults = true,
  } -- OptPanel end
--===========================================--
--== Section with static elements of panel ==--
--===========================================--
  local SBMIOptions = {
--    { type = "header",
--      name = ZO_HIGHLIGHT_TEXT:Colorize(Lng1.OptGeneralHdr),
--    },
--    { type = "divider",
--      width = "full",
--    },
-- FILTER WINDOW SECTION --
    { type = "description",
      text = Lng1.Section_1 .. DBGN:GetActiveSectionsString(1),
    },
		{ type = "slider",
      name = Lng1.Shift_X,
      tooltip = Lng1.Shift_X,
      min = DefXY.WinFN.X - DefXY.WinFN.DX,
      max = DefXY.WinFN.X + DefXY.WinFN.DX,
      getFunc = function() return SV.WinFilters.X end,
      setFunc = function(Val) SV.WinFilters.X = Val; DBGN:MoveWinFilters(Guild.UI_Fl, SV.WinFilters, SV.WinFiltersSh, SV.WinFiltersPP) end,
      default = DefXY.WinFN.X,
		},
		{ type = "slider",
      name = Lng1.Shift_Y,
      tooltip = Lng1.Shift_Y,
      min = DefXY.WinFN.Y - DefXY.WinFN.DY,
      max = DefXY.WinFN.Y + DefXY.WinFN.DY,
      getFunc = function() return SV.WinFilters.Y end,
      setFunc = function(Val) SV.WinFilters.Y = Val; DBGN:MoveWinFilters(Guild.UI_Fl, SV.WinFilters, SV.WinFiltersSh, SV.WinFiltersPP) end,
      default = DefXY.WinFN.Y,
		},
    { type = "description",
      text = Lng1.Section_2 .. DBGN:GetActiveSectionsString(2),
    },
		{ type = "slider",
      name = Lng1.Shift_X,
      tooltip = Lng1.Shift_X,
      min = DefXY.WinFS.X - DefXY.WinFS.DX,
      max = DefXY.WinFS.X + DefXY.WinFS.DX,
      getFunc = function() return SV.WinFiltersSh.X end,
      setFunc = function(Val) SV.WinFiltersSh.X = Val; DBGN:MoveWinFilters(Guild.UI_Fl, SV.WinFilters, SV.WinFiltersSh, SV.WinFiltersPP) end,
      default = DefXY.WinFS.X,
		},
		{ type = "slider",
      name = Lng1.Shift_Y,
      tooltip = Lng1.Shift_Y,
      min = DefXY.WinFS.Y - DefXY.WinFS.DY,
      max = DefXY.WinFS.Y + DefXY.WinFS.DY,
      getFunc = function() return SV.WinFiltersSh.Y end,
      setFunc = function(Val) SV.WinFiltersSh.Y = Val; DBGN:MoveWinFilters(Guild.UI_Fl, SV.WinFilters, SV.WinFiltersSh, SV.WinFiltersPP) end,
      default = DefXY.WinFS.Y,
		},
    { type = "description",
      text = Lng1.Section_3 .. DBGN:GetActiveSectionsString(3),
    },
		{ type = "slider",
      name = Lng1.Shift_X,
      tooltip = Lng1.Shift_X,
      min = DefXY.WinFP.X - DefXY.WinFP.DX,
      max = DefXY.WinFP.X + DefXY.WinFP.DX,
      getFunc = function() return SV.WinFiltersPP.X end,
      setFunc = function(Val) SV.WinFiltersPP.X = Val; DBGN:MoveWinFilters(Guild.UI_Fl, SV.WinFilters, SV.WinFiltersSh, SV.WinFiltersPP) end,
      default = DefXY.WinFP.X,
		},
		{ type = "slider",
      name = Lng1.Shift_Y,
      tooltip = Lng1.Shift_Y,
      min = DefXY.WinFP.Y - DefXY.WinFP.DY,
      max = DefXY.WinFP.Y + DefXY.WinFP.DY,
      getFunc = function() return SV.WinFiltersPP.Y end,
      setFunc = function(Val) SV.WinFiltersPP.Y = Val; DBGN:MoveWinFilters(Guild.UI_Fl, SV.WinFilters, SV.WinFiltersSh, SV.WinFiltersPP) end,
      default = DefXY.WinFP.Y,
		},
  } -- SBMIOptions end

  -- Register Option Controls
  self.MainMenuPanel = self.LAM:RegisterAddonPanel("SBMI_Panel", OptPanel)
  self.LAM:RegisterOptionControls("SBMI_Panel", SBMIOptions)
end -- -= CreateOptionsPanel end =-