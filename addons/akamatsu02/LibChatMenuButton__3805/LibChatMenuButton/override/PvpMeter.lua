PvpMeterOverrideButton = {}
PvpMeterOverrideButton.__index = PvpMeterOverrideButton

local function override()
	if not PvpMeter then return end
	if not PvpMeter.button then return end
	if not PvpMeter.label_home then return end

	local button = LibChatMenuButton.addChatButton("PvpMeterhomebuttonLCMB", {"esoui/art/guild/tabicon_home_up.dds", "esoui/art/guild/tabicon_home_over.dds", "esoui/art/guild/tabicon_home_down.dds"}, function() return GetCampaignName(GetAssignedCampaignId()) end, function(control, button) QueueForCampaign(GetAssignedCampaignId(),false) end)
	PvpMeter.label_home:SetHidden(true)
	PvpMeter.button:SetHidden(true)
	PvpMeter.button = {}
	PvpMeter.label_home = PvpMeter.button
	setmetatable(PvpMeter.button, PvpMeterOverrideButton)
	PvpMeter.button.button = button
end

function PvpMeterOverrideButton.SetHidden(self, bool)
	if bool then
		self.button:hide()
	else
		self.button:show()
	end
end

function PvpMeterOverrideButton.SetText(self, text)
	ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, text)
end

table.insert(LibChatMenuButton.override, override)