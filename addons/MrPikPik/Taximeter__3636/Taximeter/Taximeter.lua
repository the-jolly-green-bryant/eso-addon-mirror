TXM = {}
local TXM = TXM

local TAXIMETER_UNIT_KILOMETERS = 1
local TAXIMETER_UNIT_MILES = 2

TXM.name = "Taximeter"
TXM.version = "1.0"

TXM.defaults = {
	fare = 2000,
	base = 2500,
	time = 1000,
	countTime = true,
	countHeight = false,
	unit = TAXIMETER_UNIT_KILOMETERS,
}

local function GetFormattedGold(amount)
	return ZO_CurrencyControl_FormatCurrencyAndAppendIcon(amount, false, CURT_MONEY)
end

Taximeter = ZO_Object:Subclass()

function Taximeter:New(control)
	local taximeter = ZO_Object.New(self)
	taximeter:Initialize(control)
	return taximeter
end

function Taximeter:Initialize(control)
	self.control = control
	
	-- Just to be initialized, will be loaded with right values on EVENT_PLAYER_ACTIVATED
	self.fare = TXM.defaults.fare
	self.base = TXM.defaults.base
	self.time = TXM.defaults.time
	self.countTime = TXM.defaults.countTime
	self.countHeight = TXM.defaults.countHeight
	
	self.currentRideDistance = 0
	self.currentRideTime = 0
	
	self.lastPassenger = ""
	
	SLASH_COMMANDS["/taximeter"] = function() self:ToggleVisiblity() end
    --SCENE_MANAGER:RegisterTopLevel(self.control, false)
	
	-- Last initializations can only be done once player has activated
	EVENT_MANAGER:RegisterForEvent(self.control:GetName(), EVENT_PLAYER_ACTIVATED, function()
		self:RegisterForEvents()
		self:UpdateFares()
		self:UpdateCurrentRideFares()
	end)
end

function Taximeter:RegisterForEvents()
	EVENT_MANAGER:RegisterForUpdate(self.control:GetName(), nil, function() self:OnUpdate() end)
end


-- Main update loop
local lastTimestamp
local lastx, lasty, lastz
local hadPassenger = false
function Taximeter:OnUpdate()
	if not lastTimestamp then lastTimestamp = GetGameTimeSeconds() end
	if not lastx then _, lastx, lasty, lastz = GetUnitWorldPosition("player") end
	
	local currentTimestamp = GetGameTimeSeconds()
	local delta = currentTimestamp - lastTimestamp
	local _, x, y, z = GetUnitWorldPosition("player")
	
	-- Get traveled distance in ESO units (100 ESO units equals 1 ESO meter)
	local distance = 0
	if TXM.SV.countHeight then
		distance = zo_distance3D(lastx, lasty, lastz, x, y, z)
	else
		distance = zo_distance(lastx, lastz, x, z)
	end
	
	local hasPassenger = self:HasPassenger()
	
	-- Passenger mounting/dismounting detection
	if hasPassenger then
		if hadPassenger == false then
			hadPassenger = true

			self:Reset()
			
			-- Auto show the window if a passenger mounts
			if self.control:IsHidden() then
				self.control:SetHidden(false)
			end
		end
	else
		if hadPassenger == true then
			hadPassenger = false
		end
	end
	
	-- Fare addition
	if hasPassenger then
		self.currentRideTime = self.currentRideTime + delta
		self.currentRideDistance = self.currentRideDistance + distance
		
		self:UpdateCurrentRideFares()
	end
	
	--Update values
	lastTimestamp = currentTimestamp
	lastx = x
	lasty = y
	lastz = z
end

-- Updates fare values (triggered by changing values in the settings)
function Taximeter:UpdateFares()
	self.base = TXM.SV.base
	self.fare = TXM.SV.fare
	self.time = TXM.SV.time
	self.countHeight = TXM.SV.countHeight
	self.countTime = TXM.SV.countTime
	
	-- Set time fare to 0 if counting time fare is set to false, so we still get the ride time :)
	if not self.countTime then
		self.time = 0
	end
	
	self.control:GetNamedChild("BaseAmount"):SetText(GetFormattedGold(self.base) .. " ×")
	self.control:GetNamedChild("FareAmount"):SetText(GetFormattedGold(self.fare) .. " ×")
	self.control:GetNamedChild("TimeAmount"):SetText(GetFormattedGold(self.time) .. " ×")
end

-- Updates the current values for traveled distance and time spent
function Taximeter:UpdateCurrentRideFares()
	if self.lastPassenger == "" and self:GetCurrentPassengerUserID() ~= nil then
		self.lastPassenger = self:GetCurrentPassengerUserID()
		self.control:GetNamedChild("TitleHeading"):SetText(zo_strformat("Taximeter: <<1>>", self.lastPassenger))
	end
	
	local div = 100000 -- Kilometers
	local unit = "km"
	if TXM.SV.unit == TAXIMETER_UNIT_MILES then
		div = 160900 -- Miles
		unit = "mi"
	end
	
	local distance = self.currentRideDistance / div
	local minutes = self.currentRideTime / 60
	
	self.control:GetNamedChild("BaseTotal"):SetText("= " .. GetFormattedGold(self.base))
	self.control:GetNamedChild("FareMult"):SetText(string.format("%.3f %s", distance, unit))
	self.control:GetNamedChild("TimeMult"):SetText(string.format("%.2f min", minutes))
	self.control:GetNamedChild("FareTotal"):SetText("= " .. GetFormattedGold(math.floor(self.fare * distance)))
	self.control:GetNamedChild("TimeTotal"):SetText("= " .. GetFormattedGold(math.floor(self.time * minutes)))
	
	local total = self.base + math.floor(self.fare * distance) + math.floor(self.time * minutes)
	self.control:GetNamedChild("TotalTotal"):SetText("= " .. GetFormattedGold(total))
end

-- Assumes the mount has only 1 slot for passengers
function Taximeter:HasPassenger()
	local mountedState, inGroupMount, hasFreeSlot = GetTargetMountedStateInfo(GetDisplayName())
	return mountedState == MOUNTED_STATE_MOUNT_RIDER and inGroupMount and not hasFreeSlot
end

-- Potentially buggy if there are multiple taxis in group! If so, the lowest group unittag would be returned.
-- Also this function isn't realiable at all :pepega:
function Taximeter:GetCurrentPassengerUserID()
	for i = 1, GROUP_SIZE_MAX do
		local userId = GetUnitDisplayName("group"..i)
		local mountedState = GetTargetMountedStateInfo(userId)
		if mountedState == MOUNTED_STATE_MOUNT_PASSENGER then
			return userId
		end
	end
end

-- Reset values to 0
function Taximeter:Reset()
	self.control:GetNamedChild("TitleHeading"):SetText("Taximeter")
	self.lastPassenger = ""
	self.currentRideDistance = 0
	self.currentRideTime = 0
	
	self:UpdateCurrentRideFares()
end

-- If codEnabled is true, it opens the mail sending interface with everything ready to send.
-- Addons can only send plain text messages, to user input is required.
-- If codEnabled is false, it sends plain text mail.
function Taximeter:SendBill(userId, codEnabled)
	local div = 100000 -- Kilometers
	local unit = "km"
	if TXM.SV.unit == TAXIMETER_UNIT_MILES then
		div = 160900 -- Miles
		unit = "mi"
	end
	
	local distance = self.currentRideDistance / div
	local minutes = self.currentRideTime / 60
	local total = self.base + math.floor(self.fare * distance) + math.floor(self.time * minutes)

	local body = zo_strformat(
[[Hello <<1>>,

you recently used my taxi services. Please fulfil the bill over <<2>> Gold.
The amount consists of the following:
 - Base fare: <<3>> Gold
 - Distance fare: <<4>> 
 - Time fare: <<5>>
 
Kind Regards
<<6>>]],
		userId,		-- 1
		total,		-- 2
		self.base,	-- 3
		zo_strformat("<<1>> Gold (<<2>><<3>> at <<4>> Gold/<<3>>)", math.floor(self.fare * distance), string.format("%.2f", distance), unit, self.fare), --4
		zo_strformat("<<1>> Gold (<<2>> at <<3>> Gold/min)", math.floor(self.time * minutes), ZO_FormatTime(self.currentRideTime, TIME_FORMAT_STYLE_COLONS, TIME_FORMAT_PRECISION_SECONDS), self.time), --5
		GetDisplayName()	-- 6
	)
	
	if codEnabled then
		SCENE_MANAGER:Show('mailSend')
		zo_callLater(function() 
			ZO_MailSendToField:SetText(userId)
			ZO_MailSendSubjectField:SetText("Taxi Bill")
			ZO_MailSendBodyField:SetText(body)
			--ZO_MailSend_SetCoDMode() -- Unfortunately you cannot send pure money requests without an item attached :')
			--QueueCOD(total)
			ZO_MailSendBodyField:TakeFocus()
		end, 250)
	else
		SendMail(userId, "Taxi Bill", body) 
	end
end

function Taximeter:ToggleVisiblity()
    --if self.control:IsHidden() then d("Showing Taximeter") end
	
	self.control:SetHidden(not self.control:IsHidden())
	self:UpdateFares()
	SCENE_MANAGER:ToggleTopLevel(self.control)
end


-- XML Handlers

function Taximeter_Initialize(control)
	TAXIMETER = Taximeter:New(control)
end

function Taximeter_ToggleWindow()
	TAXIMETER:ToggleVisiblity()
end

function Taximeter_Reset()
	TAXIMETER:Reset()
end

function Taximeter_SendBill()
	TAXIMETER:SendBill(TAXIMETER.lastPassenger, true)
end

-- ------


local function InitializeAddonMenu()
    local optionsData = {}
	local panelData = {
		type = "panel",
		name = "Taximeter",
		displayName = "Taximeter - Multirider Taxi Utility",
		author = "MrPikPik",
		version = TXM.version,
		website = 'https://www.esoui.com/downloads/info3636-Taximeter.html#donate',
		donation = function()
			SCENE_MANAGER:Show('mailSend')
			zo_callLater(function() 
				ZO_MailSendToField:SetText("@MrPikPik")
				ZO_MailSendSubjectField:SetText("Thank you for making addons!")
				ZO_MailSendBodyField:SetText("I like using your addon 'Taximeter'")
				ZO_MailSendBodyField:TakeFocus()
			end, 250)
		end,
		registerForRefresh = true,
		registerForDefaults = true
	}
	
    -- Base fare
	table.insert(optionsData, {
		type = "slider",
		name = GetString(TXM_BASE_FARE),
		tooltip = GetString(TXM_BASE_FARE_TT),
        min = 0,
        max = 10000,
		default = TXM.defaults.base,
		getFunc = function()
            return TXM.SV.base
        end,
		setFunc = function(newValue)
            TXM.SV.base = newValue
			TAXIMETER:UpdateFares()
        end,
	})
    
	 -- Distance fare
	table.insert(optionsData, {
		type = "slider",
		name = GetString(TXM_DIST_FARE),
		tooltip = GetString(TXM_DIST_FARE_TT),
        min = 0,
        max = 5000,
		default = TXM.defaults.fare,
		getFunc = function()
            return TXM.SV.fare
        end,
		setFunc = function(newValue)
            TXM.SV.fare = newValue
			TAXIMETER:UpdateFares()
        end,
	})
	
	
	-- Enable time fare
    table.insert(optionsData, {
		type = "checkbox",
		name = GetString(TXM_COUNT_TIME),
		tooltip = GetString(TXM_COUNT_TIME_TT),
		default = TXM.defaults.countTime,
		getFunc = function()
			return TXM.SV.countTime
		end,
		setFunc = function(newValue)
            TXM.SV.countTime = newValue
			TAXIMETER:UpdateFares()
        end,
	})
	
	-- Time fare
	table.insert(optionsData, {
		type = "slider",
		name = GetString(TXM_TIME_FARE),
		tooltip = GetString(TXM_TIME_FARE_TT),
		disabled = function()
			return TXM.SV.countTime == false
		end,
        min = 0,
        max = 5000,
		default = TXM.defaults.time,
		getFunc = function()
            return TXM.SV.time
        end,
		setFunc = function(newValue)
            TXM.SV.time = newValue
			TAXIMETER:UpdateFares()
        end,
	})
	

	-- Enable height delta in distance fare
    table.insert(optionsData, {
		type = "checkbox",
		name = GetString(TXM_COUNT_HEIGHT),
		tooltip = GetString(TXM_COUNT_HEIGHT_TT),
		default = TXM.defaults.countHeight,
		getFunc = function()
			return TXM.SV.countHeight
		end,
		setFunc = function(newValue)
            TXM.SV.countHeight = newValue
        end,
	})
	
	-- Distance display
	table.insert(optionsData, {
		type = "dropdown",
		name = GetString(TXM_DIST_FARE_UNIT),
		tooltip = GetString(TXM_DIST_FARE_UNIT_TT),
		choices = {
            GetString(TXM_DIST_FARE_KM),
            GetString(TXM_DIST_FARE_MI)
        },
		getFunc = function() 
			if TXM.SV.unit == TAXIMETER_UNIT_KILOMETERS then 
				return GetString(TXM_DIST_FARE_KM)
			elseif TXM.SV.unit == TAXIMETER_UNIT_MILES then
				return GetString(TXM_DIST_FARE_MI)				
			end
		end,
		setFunc = function(newValue)
			if newValue == GetString(TXM_DIST_FARE_KM) then 
				TXM.SV.unit = TAXIMETER_UNIT_KILOMETERS
			elseif newValue == GetString(TXM_DIST_FARE_MI) then
				TXM.SV.unit = TAXIMETER_UNIT_MILES
			end
			TAXIMETER:UpdateFares()
		end,
		default = TXM.defaults.unit,
	})

    local optionsPanel = LibAddonMenu2:RegisterAddonPanel(TXM.name .. "Settings", panelData)
	LibAddonMenu2:RegisterOptionControls(TXM.name .. "Settings", optionsData)
end

local function OnAddonLoaded(event, addonName)
    if addonName ~= TXM.name then return end
    EVENT_MANAGER:UnregisterForEvent(TXM.name, EVENT_ADD_ON_LOADED) 
     
	-- Creating saved vars
	TXM.SV = ZO_SavedVars:NewAccountWide("TXMSavedVariables", 1.0, nil, TXM.defaults)
	
	InitializeAddonMenu()
end
EVENT_MANAGER:RegisterForEvent(TXM.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)