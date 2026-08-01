local LKT = LibKeepTooltip

local Log = IMP_PVP_UI_Logger('IMP_KT_FORWARDCAMPS')

local BORDER = 8
local KEEP_TOOLTIP_NAME = ZO_ColorDef:New(GetInterfaceColor(INTERFACE_COLOR_TYPE_KEEP_TOOLTIP, KEEP_TOOLTIP_COLOR_NAME))

local KEEP_TOOLTIP_NORMAL_LINE = ZO_ColorDef:New(GetInterfaceColor(INTERFACE_COLOR_TYPE_KEEP_TOOLTIP, KEEP_TOOLTIP_COLOR_NORMAL_LINE))
local KEEP_TOOLTIP_ACCESSIBLE = ZO_ColorDef:New(GetInterfaceColor(INTERFACE_COLOR_TYPE_KEEP_TOOLTIP, KEEP_TOOLTIP_COLOR_ACCESSIBLE))
local KEEP_TOOLTIP_NOT_ACCESSIBLE = ZO_ColorDef:New(GetInterfaceColor(INTERFACE_COLOR_TYPE_KEEP_TOOLTIP, KEEP_TOOLTIP_COLOR_NOT_ACCESSIBLE))

local EVENT_NAMESPACE = 'IMP_KT_FORWARDCAMPS_EVENT_NAMESPACE'
-- ----------------------------------------------------------------------------

-- TODO: make common function
local function FormatSeconds(seconds)
	local minutes = math.floor(seconds / 60) % 60

	local remainingSeconds = seconds % 60

	if minutes == 0 then
		return string.format('%ds', remainingSeconds)
	else
		return string.format('%dm%02ds', minutes, remainingSeconds)
	end
end

-- ----------------------------------------------------------------------------

local camps = {}
local HASH = '%.6f%.6f'
local function onForwardCampsUpdated()
    local updatedCamps = {}
    for i = 1, GetNumForwardCamps(BGQUERY_LOCAL) do
        local pinType, normalizedX, normalizedY, normalizedRadius, useable = GetForwardCampPinInfo(BGQUERY_LOCAL, i)
        local hash = HASH:format(normalizedX, normalizedY)
        if camps[hash] then
            updatedCamps[hash] = camps[hash]
        else
            updatedCamps[hash] = {GetGameTimeMilliseconds(), true}
        end
    end
    camps = updatedCamps
end

local function onPlayerActivated()
    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE, EVENT_PLAYER_ACTIVATED)
    for i = 1, GetNumForwardCamps(BGQUERY_LOCAL) do
        local pinType, normalizedX, normalizedY, normalizedRadius, useable = GetForwardCampPinInfo(BGQUERY_LOCAL, i)
        local hash = HASH:format(normalizedX, normalizedY)
        camps[hash] = {GetGameTimeMilliseconds(), false}
    end
end

-- ----------------------------------------------------------------------------

local CAMP_AGE_STRING = '(|c00EE00%s|r / ~10m)'
local function AddForwardCampAgeLine(self, forwardCampIndex, battlegroundContext)
    if battlegroundContext ~= BGQUERY_LOCAL then return end

    local pinType, normalizedX, normalizedY, normalizedRadius, useable = GetForwardCampPinInfo(battlegroundContext, forwardCampIndex)
    local hash = HASH:format(normalizedX, normalizedY)

    local forwardCampPlacedData = camps[hash]
    if not forwardCampPlacedData then return end

    local ageSeconds = (GetGameTimeMilliseconds() - forwardCampPlacedData[1]) / 1000
    local age = FormatSeconds(ageSeconds)
    if not forwardCampPlacedData[2] then
        age = '>' .. age
    end

    local text = CAMP_AGE_STRING:format(age)
    LKT.AddLine(self, text, KEEP_TOOLTIP_NORMAL_LINE)
end

local function SetForwardCamp(self, forwardCampIndex, battlegroundContext, usable)
    self:Reset()

    -- CHANGED
    -- local nameControl = GetControl(self, "Name")
    -- nameControl:SetText(GetString(SI_TOOLTIP_FORWARD_CAMP))
    -- nameControl:SetColor(KEEP_TOOLTIP_NAME:UnpackRGBA())
    -- local width, height = nameControl:GetTextDimensions()
    -- self.width = width
    -- self.height = height

    -- local allianceName = GetAllianceName(GetUnitAlliance('player'))
    -- local text = zo_strformat(GetString(SI_TOOLTIP_KEEP_ALLIANCE_OWNER), allianceName)
    -- LKT.AddLine(self, text, KEEP_TOOLTIP_NORMAL_LINE)

    self.keepName = GetString(SI_TOOLTIP_FORWARD_CAMP)
    self.alliance = GetUnitAlliance('player')
    LKT.callbacks[LKT.INGRIDIENTS.HEADER](self)
    -- /CHANGED

    if WORLD_MAP_MANAGER:IsInMode(MAP_MODE_AVA_RESPAWN) then
        local tooltipText = SI_TOOLTIP_FORWARD_CAMP_RESPAWN
        local tooltipColor = KEEP_TOOLTIP_ACCESSIBLE
        if not usable then
            tooltipText = SI_TOOLTIP_KEEP_NOT_RESPAWNABLE
            tooltipColor = KEEP_TOOLTIP_NOT_ACCESSIBLE
        end
        LKT.AddLine(self, GetString(tooltipText), tooltipColor)
    end

    -- ADDED
    AddForwardCampAgeLine(self, forwardCampIndex, battlegroundContext)
    -- /ADDED

    self.width = self.width + BORDER * 2
    self.height = self.height + BORDER * 2
    self:SetDimensions(self.width, self.height)
end

function IMP_KT_ForwardCamps_Initialize()
    local function silent_error(fn, ...)
        local status, error = pcall(fn, ...)
        if error then Log(error) end

        return status
    end

    ZO_PreHook(ZO_KeepTooltip, 'SetForwardCamp', function(...)
        return silent_error(SetForwardCamp, ...)
    end)

    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_FORWARD_CAMPS_UPDATED, onForwardCampsUpdated)
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_PLAYER_ACTIVATED, onPlayerActivated)
end
