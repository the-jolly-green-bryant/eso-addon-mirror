--[[
Saved variables file aka Worth

Values that are saved will be kept in a "ledger" while the current set of values will be called a "session"
The ledger will load when the character loads and saved when exited or requested

]]--

local MWSaved = {}
MWG.MWSaved = MWSaved

MWSaved.VersionNumber = 16

MWSaved.DefaultVariables = {
	WindowProperties = {
		x = MW_DEFAULT_X_POS,
		y = MW_DEFAULT_Y_POS,
		width = MW_DEFAULT_WIDTH,
		height = MW_DEFAULT_HEIGHT,
	},
	
  LoadLedgerOnInit = true,
  TrackGold = true,
  TrackAPoints = true,
  TrackTelvar = true,
  TrackExperience = true,
  TrackRate = true,
  RateMinutes = 5,
  
  
  -- Ledger, but only need In and Out
  Gold = {
  Income =  { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, },
  Expense = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, },
  },

  APoints = {
  Income =  { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, },
  Expense = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, },
  },

  Telvar = {
  Income =  { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, },
  Expense = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, },
  },

  Experience = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, },
}


-- Initialize function should be called before using any saved variables or saving variables
function MWSaved:Initialize()
  
	-- Load account-wide saved variables, only one account and one save per account
  -- So all money is tracked at once even among multiple characters
	MWSaved.SavedVariables = ZO_SavedVars:NewAccountWide("MoneyWhereSavedValues", MWSaved.VersionNumber, nil, MWSaved:LoadAccountDefaults())
  
end

function MWSaved:GetAccountVariables()
  return MWSaved.SavedVariables  
end


function MWSaved:SaveAccountVariables()
	local x, y = MWWindow:GetScreenRect()
	local width, height = MWWindow:GetDimensions()
	
	MWSaved.SavedVariables.WindowProperties.x = x
	MWSaved.SavedVariables.WindowProperties.y = y
	MWSaved.SavedVariables.WindowProperties.width = width
	MWSaved.SavedVariables.WindowProperties.height = height
  
  --[[ These should have been saved by writing directly from options panel
  MWSaved.SavedVariables.LoadLedgerOnInit = true
  MWSaved.SavedVariables.TrackGold = true
  MWSaved.SavedVariables.TrackAPoints = true
  MWSaved.SavedVariables.TrackTelvar = true
  MWSaved.SavedVariables.TrackExperience = true
  MWSaved.SavedVariables.TrackRate = true
  MWSaved.SavedVariables.RateMinutes = 5
  ]]--
  
  for cnt, value in ipairs(MWG.MoneyWhere.GoldGroups.Income) do
    MWSaved.SavedVariables.Gold.Income[cnt] = MWG.MoneyWhere.GoldGroups.Income[cnt]
    MWSaved.SavedVariables.Gold.Expense[cnt] = MWG.MoneyWhere.GoldGroups.Expense[cnt]
    MWSaved.SavedVariables.APoints.Income[cnt] = MWG.MoneyWhere.APointsGroups.Income[cnt]
    MWSaved.SavedVariables.APoints.Expense[cnt] = MWG.MoneyWhere.APointsGroups.Expense[cnt]
    MWSaved.SavedVariables.Telvar.Income[cnt] = MWG.MoneyWhere.TelvarGroups.Income[cnt]
    MWSaved.SavedVariables.Telvar.Expense[cnt] = MWG.MoneyWhere.TelvarGroups.Expense[cnt]
  end
  
  -- save experience
  for cnt, value in ipairs(MWG.MoneyWhere.ExperienceGroup) do
    MWSaved.SavedVariables.Experience[cnt] = MWG.MoneyWhere.ExperienceGroup[cnt]
  end
  
  
  CHAT_SYSTEM:AddMessage("MoneyWhere saved session to Ledger, overwrote")

end

function MWSaved:SaveAddAccountVariables()
	local x, y = MWWindow:GetScreenRect()
	local width, height = MWWindow:GetDimensions()
	
  MWSaved.SavedVariables.LoadLedgerOnInit = true
	MWSaved.SavedVariables.WindowProperties.x = x
	MWSaved.SavedVariables.WindowProperties.y = y
	MWSaved.SavedVariables.WindowProperties.width = width
	MWSaved.SavedVariables.WindowProperties.height = height
  
  --[[ These should have been saved by writing directly from options panel
  MWSaved.SavedVariables.TrackGold = true
  MWSaved.SavedVariables.TrackAPoints = true
  MWSaved.SavedVariables.TrackTelvar = true
  MWSaved.SavedVariables.TrackExperience = true
  MWSaved.SavedVariables.TrackRate = true
  MWSaved.SavedVariables.RateMinutes = 5
  ]]--

  for cnt, value in ipairs(MWG.MoneyWhere.GoldGroups.Income) do
    MWSaved.SavedVariables.Gold.Income[cnt] = MWSaved.SavedVariables.Gold.Income[cnt] + MWG.MoneyWhere.GoldGroups.Income[cnt]
    MWSaved.SavedVariables.Gold.Expense[cnt] = MWSaved.SavedVariables.Gold.Expense[cnt] + MWG.MoneyWhere.GoldGroups.Expense[cnt]
    MWSaved.SavedVariables.APoints.Income[cnt] = MWSaved.SavedVariables.APoints.Income[cnt] + MWG.MoneyWhere.APointsGroups.Income[cnt]
    MWSaved.SavedVariables.APoints.Expense[cnt] = MWSaved.SavedVariables.APoints.Expense[cnt] + MWG.MoneyWhere.APointsGroups.Expense[cnt]
    MWSaved.SavedVariables.Telvar.Income[cnt] = MWSaved.SavedVariables.Telvar.Income[cnt] + MWG.MoneyWhere.TelvarGroups.Income[cnt]
    MWSaved.SavedVariables.Telvar.Expense[cnt] = MWSaved.SavedVariables.Telvar.Expense[cnt] + MWG.MoneyWhere.TelvarGroups.Expense[cnt]
  end
  
  -- save experience
  for cnt, value in ipairs(MWG.MoneyWhere.ExperienceGroup) do
    MWSaved.SavedVariables.Experience[cnt] = MWSaved.SavedVariables.Experience[cnt] + MWG.MoneyWhere.ExperienceGroup[cnt]
  end
  
  CHAT_SYSTEM:AddMessage("MoneyWhere added session to Ledger")

end


function MWSaved:ResetSavedVariables()
	-- get default window properties so saved must be called when window is valid
	MWSaved.SavedVariables.WindowProperties.x = MW_DEFAULT_X_POS
	MWSaved.SavedVariables.WindowProperties.y = MW_DEFAULT_Y_POS
	MWSaved.SavedVariables.WindowProperties.width = MW_DEFAULT_WIDTH
	MWSaved.SavedVariables.WindowProperties.height = MW_DEFAULT_HEIGHT
  
  -- Track all values
  MWSaved.SavedVariables.LoadLedgerOnInit = true

  MWSaved.SavedVariables.TrackGold = true
  MWSaved.SavedVariables.TrackAPoints = true
  MWSaved.SavedVariables.TrackTelvar = true
  MWSaved.SavedVariables.TrackExperience = true
  MWSaved.SavedVariables.TrackRate = true
  MWSaved.SavedVariables.RateMinutes = 5
  
	------ zero all currencies ------
  for icnt, values in ipairs(MWSaved.SavedVariables.Gold.Income) do
    MWSaved.SavedVariables.Gold.Income[icnt] = 0
    MWSaved.SavedVariables.Gold.Expense[icnt] = 0
    MWSaved.SavedVariables.APoints.Income[icnt] = 0
    MWSaved.SavedVariables.APoints.Expense[icnt] = 0
    MWSaved.SavedVariables.Telvar.Income[icnt] = 0
    MWSaved.SavedVariables.Telvar.Expense[icnt] = 0
  end
  
  -- experience
  for cnt, value in ipairs(MWG.MoneyWhere.ExperienceGroup) do
    MWSaved.SavedVariables.Experience[cnt] = 0
  end
  
  CHAT_SYSTEM:AddMessage("MoneyWhere set Ledger to zero")
end


function MWSaved:LoadAccountDefaults()
	MWSaved.DefaultVariables.WindowProperties.x = MW_DEFAULT_X_POS
	MWSaved.DefaultVariables.WindowProperties.y = MW_DEFAULT_Y_POS
	MWSaved.DefaultVariables.WindowProperties.width = MW_DEFAULT_WIDTH
	MWSaved.DefaultVariables.WindowProperties.height = MW_DEFAULT_HEIGHT
  
  -- Track all values
  MWSaved.DefaultVariables.LoadLedgerOnInit = true
  MWSaved.DefaultVariables.TrackGold = true
  MWSaved.DefaultVariables.TrackAPoints = true
  MWSaved.DefaultVariables.TrackTelvar = true
  MWSaved.DefaultVariables.TrackExperience = true
  MWSaved.DefaultVariables.TrackRate = true
  MWSaved.DefaultVariables.RateMinutes = 5
  
	------ zero all currencies ------
  for icnt, values in ipairs(MWSaved.DefaultVariables.Gold.Income) do
    MWSaved.DefaultVariables.Gold.Income[icnt] = 0
    MWSaved.DefaultVariables.Gold.Expense[icnt] = 0
    MWSaved.DefaultVariables.APoints.Income[icnt] = 0
    MWSaved.DefaultVariables.APoints.Expense[icnt] = 0
    MWSaved.DefaultVariables.Telvar.Income[icnt] = 0
    MWSaved.DefaultVariables.Telvar.Expense[icnt] = 0
  end
  
  -- experience
  for cnt, value in ipairs(MWG.MoneyWhere.ExperienceGroup) do
    MWSaved.DefaultVariables.Experience[cnt] = 0
  end
  
	return MWSaved.DefaultVariables
end


