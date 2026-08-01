local DEBUG =
function() end
-- d

local function _tr(str)
	return str
end

local RPF = RPFlagger
local SE  = RPF.UI.Settings

local numGuilds = 5

local namesList = nil
local selectedName = "(invalid)"
local selectedIndex = 1

function SE:GetControls()
	return {
		{
			type = "dropdown",
			name = GetString(SI_RPF_GUILDORDER),
			tooltip = GetString(SI_RPF_GUILDORDER_TT),
			choices = { "(invalid)" },
			getFunc = function() return SE:GetSelectedEntry() end,
			setFunc = function(value) SE:SetSelectedEntry(value) end,
			reference = "IWONTSAY_RPF_CHO_ORDER",
		},
		{
			type = "button",
			name = GetString(SI_RPF_MOVEUP),
			width = "half",
			disabled = function() return SE:GetBtnMoveUpDisabled() end,
			func = function() return SE:BtnMoveUpClicked() end,
		},
		{
			type = "button",
			name = GetString(SI_RPF_MOVEDN),
			width = "half",
			disabled = function() return SE:GetBtnMoveDnDisabled() end,
			func = function() return SE:BtnMoveDnClicked() end,
		},
	}
end

function SE:GetSelectedEntry()
	return selectedName
end

function SE:SetSelectedEntry(value)
	DEBUG("--- SetSelectedEntry: " .. value)
	selectedName = value
	for i = 1, #namesList, 1 do
		if selectedName == namesList[i] then 
			selectedIndex = i
			break
		end
	end
end

function SE:moveEntry(direction)
	local tmp = RPF.guildList[selectedIndex]
	RPF.guildList[selectedIndex] = RPF.guildList[selectedIndex + direction]
	RPF.guildList[selectedIndex + direction] = tmp
	
	self:UpdateOrderList(selectedName)
end

function SE:GetBtnMoveUpDisabled()
	return selectedIndex < 2
end

function SE:BtnMoveUpClicked()
	self:moveEntry(-1)
end

function SE:GetBtnMoveDnDisabled()
	return not namesList or selectedIndex >= #namesList
end

function SE:BtnMoveDnClicked()
	self:moveEntry(1)
end

function SE:UpdateOrderList(preselectedName)
	namesList = { }
	for i = 1, numGuilds, 1 do
		local guildname = GetGuildName(RPF.guildList[i])
		if guildname ~= "" then namesList[#namesList + 1] = guildname end
	end
	
	selectedName = preselectedName or namesList[1]
	
	IWONTSAY_RPF_CHO_ORDER:UpdateChoices(namesList)
	IWONTSAY_RPF_CHO_ORDER:UpdateValue(false, selectedName)
	IWONTSAY_RPF_CHO_ORDER:UpdateValue(false)
end

function SE:PopulateUI()
	-- fired because of someone else?
	if not IWONTSAY_RPF_CHO_ORDER then return end
	
	DEBUG("--- PopulateUI")

	SE:UpdateOrderList(nil)
end
