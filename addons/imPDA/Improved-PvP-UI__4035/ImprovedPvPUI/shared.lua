local addon = {}

local MISSING_ICON = '/esoui/art/icons/icon_missing.dds'
-- local ROOT_PATH = '/esoui/art/mappins/'  -- '/esoui/art/compass/'
local ROOT_PATH = 'ImprovedPvPUI/icons/'

local KEEP_ICONS = {
    [KEEPTYPE_KEEP] = ROOT_PATH .. 'ava_largekeep_neutral.dds',
    [KEEPTYPE_TOWN] = ROOT_PATH .. 'ava_town_neutral.dds',
    [KEEPTYPE_OUTPOST] = ROOT_PATH .. 'ava_outpost_neutral.dds',
}

local RESOURCE_ICONS = {
    [RESOURCETYPE_FOOD] = ROOT_PATH .. 'ava_farm_neutral.dds',
    [RESOURCETYPE_ORE] = ROOT_PATH .. 'ava_mine_neutral.dds',
    [RESOURCETYPE_WOOD] = ROOT_PATH .. 'ava_lumbermill_neutral.dds',
}

function addon.GetKeepIcon(keepId, alliance, size)
    local texture
    local keepType = GetKeepType(keepId)

    if keepType == KEEPTYPE_RESOURCE then
        local resourceType = GetKeepResourceType(keepId)
        texture = RESOURCE_ICONS[resourceType]
    else
        texture = KEEP_ICONS[keepType]
    end

    if not texture then return MISSING_ICON end
    size = size or 32

    return GetAllianceColor(alliance):Colorize(zo_iconFormatInheritColor(texture, size, size))
end

function addon.SecondsToTime(seconds)
	local minutes = math.floor(seconds / 60) % 60
	local hours = math.floor(seconds / 60 / 60)

	local remainingSeconds = seconds % 60

	if hours == 0 then
		return string.format('%d:%02d', minutes, remainingSeconds)
	else
		return string.format('%d:%02d:%02d', hours, minutes, remainingSeconds)
	end
end

-- ----------------------------------------------------------------------------

local function _chatSystemExists()
	return CHAT_SYSTEM and CHAT_SYSTEM.containers and CHAT_SYSTEM.containers[1] and CHAT_SYSTEM.containers[1].windows
end

function addon.GetTabNames()
	local tabNames = {}

	if _chatSystemExists() then
		for i = 1, #CHAT_SYSTEM.containers[1].windows do
			tabNames[i] = CHAT_SYSTEM.containers[1]:GetTabName(i)
		end
	end

	return tabNames
end

function addon.GetTabValues()
    local tabValues = {}

    if _chatSystemExists() then
		for i = 1, #CHAT_SYSTEM.containers[1].windows do
			tabValues[i] = i
		end
	end

	return tabValues
end

function addon.RefreshTabDropdownMenu(reference)
	local control = GetWindowManager():GetControlByName(reference)

	if control then
		control:UpdateChoices(addon.GetTabNames(), addon.GetTabValues())
	end
end

function addon.SendMessageToChat(message, tabNumber, addTimestamp, timestampFormat)
    -- TODO color?
    if addTimestamp == nil then addTimestamp = true end
    if timestampFormat == nil then timestampFormat = '%T' end

	if not _chatSystemExists() then return end

	if addTimestamp then
		local time = os.date(timestampFormat, GetTimeStamp())
		message = string.format("[%s] %s", time, message)
	end

	CHAT_SYSTEM.containers[1].windows[tabNumber].buffer:AddMessage(message)
    -- TODO rewrite to be compatable with chat addons
end

IMP_PVP_UI_SHARED = addon