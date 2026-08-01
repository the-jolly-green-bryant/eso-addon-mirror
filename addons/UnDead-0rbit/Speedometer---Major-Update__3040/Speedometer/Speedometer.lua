Speedometer = {}
Speedometer.defaults = {
	OdometerTotal = 0,
	TopSprint = 0,
	TopMounted = 0,
	SprintSpeeds = {},
	MountSpeeds = {}
}
local gps = LibGPS3
Speedometer.name = "Speedometer"
Speedometer.updateTimeInSeconds = 500
Speedometer.wasMounted = 0
Speedometer.MailTopic = ""
Speedometer.MailBody = ""
ZO_CreateStringId('SI_BINDING_NAME_SPEEDOMETER_TOGGLE_UI', "Toggle UI")

Speedometer.CurrentPosition = {}
Speedometer.LastPosition = {}
Speedometer.Points = {}

local function Format_Number(value)
	local formatted_num = string.format("%.1f", value)
	if formatted_num == string.format("%d", value) then
		formatted_num = formatted_num .. ".0"
	end
	return formatted_num
end

local function Clear_Points()
	local time  = GetGameTimeMilliseconds()
	for i = 1, 4 do
		Speedometer.Points[i] = {0, time}
	end
end

local function Was_Mounted_Check()
	if IsMounted() then
		Speedometer.wasMounted = 4

	else
		if Speedometer.wasMounted > 0 then
			Clear_Points()
			Speedometer.wasMounted = Speedometer.wasMounted - 1
		end
	end
end

local function Shift_And_Total(Traveled, Time)
	Was_Mounted_Check()
	for i = 1, 3 do
		Speedometer.Points[i+1] = Speedometer.Points[i]
	end
	Speedometer.Points[1] = {Traveled, Time}

	for i = 2, 3 do
		Traveled = Traveled + Speedometer.Points[i][1]
		Time = Time + Speedometer.Points[i][2]
	end
	return Traveled, Time
end

local function Math_Round(num, numDecimalPlaces)
	local mult = 10^(numDecimalPlaces or 0)
	return math.floor(num * mult + 0.5) / mult
end

local function Add_Odometer(Distance)
	local distanceAdded = Distance / 1000
	Speedometer.SavedVariables.OdometerTotal = Speedometer.SavedVariables.OdometerTotal + distanceAdded
	local OdoLbl, OdoValue = GetControl("SM_Odo_Label"), Math_Round(Speedometer.SavedVariables.OdometerTotal, 1)
	OdoLbl:SetText(string.format("%09.1f", OdoValue) .. " km")
end

local function Math_Distance(x1, y1, x2, y2)
	local diffX = x1 - x2
	local diffY = y1 - y2
	return math.sqrt(diffX * diffX + diffY * diffY)
end

local function Update_Labels(value)
	local SpeedLbl, PeakLbl, TypeLbl = GetControl("SM_Speed_Label"), GetControl("SM_PeakSpeed_Label"), GetControl("SM_MoveType_Label")
	local LocationLbl, Map_Name = GetControl("SM_Map_Label"), GetMapName()
	LocationLbl:SetText(Map_Name)
	SpeedLbl:SetText(Format_Number(value))

	if Speedometer.SavedVariables.MountSpeeds[Map_Name] == nil then
		Speedometer.SavedVariables.MountSpeeds[Map_Name] = 0
	end

	if Speedometer.SavedVariables.SprintSpeeds[Map_Name] == nil then
		Speedometer.SavedVariables.SprintSpeeds[Map_Name] = 0
	end

	if IsMounted() then
		if value > Speedometer.SavedVariables.MountSpeeds[Map_Name] then
			Speedometer.SavedVariables.MountSpeeds[Map_Name] = value
		end
		SMUI.SetSpeedValue(value, Speedometer.SavedVariables.MountSpeeds[Map_Name])
		PeakLbl:SetText(Format_Number(Speedometer.SavedVariables.MountSpeeds[Map_Name]))
		TypeLbl:SetText("Mounted")
	else
		if value > Speedometer.SavedVariables.SprintSpeeds[Map_Name] then
			Speedometer.SavedVariables.SprintSpeeds[Map_Name] = value
		end
		SMUI.SetSpeedValue(value, Speedometer.SavedVariables.SprintSpeeds[Map_Name])
		PeakLbl:SetText(Format_Number(Speedometer.SavedVariables.SprintSpeeds[Map_Name]))
		TypeLbl:SetText("Sprint")
	end
end

function Speedometer.Calculate()
	local x1, y1, t1 = Speedometer.CurrentPosition[1], Speedometer.CurrentPosition[2], Speedometer.CurrentPosition[3]
	local x2, y2, t2 = Speedometer.LastPosition[1], Speedometer.LastPosition[2], Speedometer.LastPosition[3]

	local Distance_Traveled = Math_Distance(x1, y1, x2, y2) * 100000
	local Time_Passed = (t1 - t2) / 1000

	if Distance_Traveled > 160 then return end
	Add_Odometer(Distance_Traveled)
	Distance_Traveled, Time_Passed = Shift_And_Total(Distance_Traveled, Time_Passed)

	local speed = Math_Round(Distance_Traveled / Time_Passed, 1)
	Update_Labels(speed)
end

function Speedometer.ResetPeaks()
	Speedometer.SavedVariables.TopMounted = 0
	Speedometer.SavedVariables.TopSprint = 0
end

function Speedometer:ToggleSpeedometer()
	Speedometer.SavedVariables.isUIHidden = not Speedometer.SavedVariables.isUIHidden
	SMUI.ShowHideUI()
end

--Call the initialization
function Speedometer.OnAddOnLoaded(event, addonName)
    if addonName == Speedometer.name then
        Speedometer:Initialize()
    end
end

--Initialize the addon
function Speedometer:Initialize()
    Speedometer.SavedVariables = ZO_SavedVars:New("SpeedometerSavedVariables", 1, nil, Speedometer.defaults)
	SMUI.CreateUI()
	Speedometer.InitialData()
	SMSettings.CreateSettings()
end

SLASH_COMMANDS["/togglespeedui"] = function ()
  Speedometer:ToggleSpeedometer()
end

function Speedometer.InitialData()
	local posX, posY = gps:LocalToGlobal(GetMapPlayerPosition("player"))
	local time  = GetGameTimeMilliseconds()
	Speedometer.CurrentPosition = {posX, posY, time}
	Speedometer.LastPosition = {posX, posY, time}
	for i = 1, 4 do
		Speedometer.Points[i] = {0, time}
	end
end

function Speedometer.UpdateData()
	if not Speedometer.SavedVariables.isUIHidden then
		local posX, posY = gps:LocalToGlobal(GetMapPlayerPosition("player"))
		local time  = GetGameTimeMilliseconds()
		Speedometer.CurrentPosition = {posX, posY, time}
		Speedometer.Calculate()
		Speedometer.LastPosition = Speedometer.CurrentPosition
	end
end



EVENT_MANAGER:RegisterForEvent(Speedometer.name, EVENT_ADD_ON_LOADED, Speedometer.OnAddOnLoaded)
EVENT_MANAGER:RegisterForUpdate(Speedometer.name, Speedometer.updateTimeInSeconds, Speedometer.UpdateData)
