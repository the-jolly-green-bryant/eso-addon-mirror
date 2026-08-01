ScroogeMcDuck = {}

ScroogeMcDuck.Deafult = {
	offsetX = 7,
	offsetY = -12
}
ScroogeMcDuck.name = "ScroogeMcDuck"
ScroogeMcDuck.version = 1.1
ScroogeMcDuck.money = 0

function ScroogeMcDuck.OnAddOnLoaded(event, addonName)
	if addonName ~= ScroogeMcDuck.name then return end
	ScroogeMcDuck:Initialize()
end

function ScroogeMcDuck:Initialize()
	EVENT_MANAGER:UnregisterForEvent(ScroogeMcDuck.name, EVENT_ADD_ON_LOADED)
	ScroogeMcDuck.savedVariables = ZO_SavedVars:New("ScroogeMcDuckSavedVariables", ScroogeMcDuck.version, nil, ScroogeMcDuck.Default)
	-- Position control based on saved vars
	ScroogeMcDuckControl:ClearAnchors()
	ScroogeMcDuckControl:SetAnchor(BOTTOMLEFT, GuiRoot, BOTTOMLEFT, ScroogeMcDuck.savedVariables.offsetX, ScroogeMcDuck.savedVariables.offsetY)
	-- Register for the update money event
	EVENT_MANAGER:RegisterForEvent(self.name, EVENT_MONEY_UPDATE, ScroogeMcDuck.OnMoneyUpdate)
	-- Get initial money
	self.money = GetCurrentMoney()
	ScroogeMcDuckControl:SetDimensions(ScroogeMcDuck:GetDimensionsForControl())
	ScroogeMcDuckControlMoneyLabel:SetText(ScroogeMcDuck:GetFormattedMoney())
end

function ScroogeMcDuck.OnMoneyUpdate(event, newMoney, oldMoney, reason)
	ScroogeMcDuck.money = newMoney
	-- Setting the dimensions will ensure the text remains on screen when the control is positioned at the right edge of the screen.
	ScroogeMcDuckControl:SetDimensions(ScroogeMcDuck:GetDimensionsForControl())
	ScroogeMcDuckControlMoneyLabel:SetText(ScroogeMcDuck.GetFormattedMoney())
end

function ScroogeMcDuck:GetFormattedMoney()
	--Number formatter from http://stackoverflow.com/questions/10989788/lua-format-integer
	local i, j, minus, int, fraction = tostring(self.money):find('([-]?)(%d+)([.]?%d*)')
	int = int:reverse():gsub("(%d%d%d)", "%1,")
	return minus .. int:reverse():gsub("^,", "") .. fraction
end

function ScroogeMcDuck:GetDimensionsForControl()
	-- Multiply the string length of the amount of money by 9.
	-- 9 is just a nice number I found that works with varying lengths.
	return (ScroogeMcDuck:GetFormattedMoney():len() * 9) + 27, 22
end

function ScroogeMcDuck.SaveLoc()
	ScroogeMcDuck.savedVariables.offsetX = ScroogeMcDuckControl:GetLeft()
	ScroogeMcDuck.savedVariables.offsetY = ScroogeMcDuckControl:GetBottom() - GuiRoot:GetBottom()
end

EVENT_MANAGER:RegisterForEvent(ScroogeMcDuck.name, EVENT_ADD_ON_LOADED, ScroogeMcDuck.OnAddOnLoaded)