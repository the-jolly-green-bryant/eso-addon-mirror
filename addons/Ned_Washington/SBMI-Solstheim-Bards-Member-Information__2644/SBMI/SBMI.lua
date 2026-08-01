local SBMI = SBMI
local DBGN = DBGN

function SBMI:Initialize()
  local DefXY = self.DefXY
-- Initialization of saved variables
  local defaults = {
    WinFilters = {
      X = DefXY.WinFN.X,
      Y = DefXY.WinFN.Y,
    },
    WinFiltersSh = {
      X = DefXY.WinFS.X,
      Y = DefXY.WinFS.Y,
    },
    WinFiltersPP = {
      X = DefXY.WinFP.X,
      Y = DefXY.WinFP.Y,
    },
    Filters = {
-- Main flags
      Forum = 1,
      Proff = 1,
      Discord = 1,
      Vamp  = 1,
      WW    = 1,
      House = 1,
-- Status
      M1From = "",
      M1To = "",
      M2From = "",
      M2To = "",
      PenaltyCmp = 1,
      PenaltyVal = 1,
-- Craft
      BlkVal = 1,
      WWrVal = 1,
      CltVal = 1,
      JewVal = 1,
      EnchVal = 1,
      AlchVal = 1,
      ProvVal = 1,
      AmbrVal = 1,
-- PvE
      PvE_RL   = 1,
      PvE_DD   = 1,
      PvE_Heal = 1,
      PvE_Tank = 1,
      PvE_Stat = 1,
-- Trials
      TrlDung = 1,
      TrlCmp = 1,
      TrlVal = 1,
      TrlDD   = false,
      TrlHeal = false,
      TrlTank = false,
-- Dungeons
      DungSel = 1,
      DungVal = 1,
      DungCmp = 1,
-- Attestation
      HealCmp = 1,
      HealVal = 1,
      TankCmp = 1,
      TankVal = 1,
      DDFrom = "",
      DDTo = "",
    },
  }
  self.SV = ZO_SavedVars:NewAccountWide("SBMISavedVars", 1, nil, defaults)
-- Register main guild
  self.RegGuildResult = DBGN:RegisterGuildType(self.GetGuildSB())
end

function SBMI.OnAddOnLoaded(event, addonName)
  if addonName == SBMI.Name then
    SBMI:Initialize()
    SBMI:CreateOptionsPanel()
    EVENT_MANAGER:UnregisterForEvent(SBMI.Name, EVENT_ADD_ON_LOADED)
  end
end

EVENT_MANAGER:RegisterForEvent(SBMI.Name, EVENT_ADD_ON_LOADED, SBMI.OnAddOnLoaded)