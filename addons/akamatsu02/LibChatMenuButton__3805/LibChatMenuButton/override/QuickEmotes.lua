QuickEmotesOverrideButton = {}
QuickEmotesOverrideButton.__index = QuickEmotesOverrideButton

local function override()
	if not QuickEmotes then return end
	if not QuickEmotes.button then return end

	local button = LibChatMenuButton.addChatButton("QuickEmotesButtonLCMB", {"EsoUI/Art/Help/help_tabIcon_emotes_up.dds", "EsoUI/Art/Help/help_tabIcon_emotes_over.dds", "EsoUI/Art/Help/help_tabIcon_emotes_down.dds"}, "QuickEmotes", function(control, button)
		if QuickEmotes.menu:IsHidden() == true then
			zo_callLater(function()
				QuickEmotes.menu:SetHidden(false)
			end, 50)
		else
			QuickEmotes.menu:SetHidden(true)
		end
	end)
	QuickEmotes.menu:SetParent(button.ui)
	QuickEmotes.menu:ClearAnchors()
	QuickEmotes.menu:SetAnchor(BOTTOMLEFT, button.ui, TOP, 0, 0)
	QuickEmotes.button:SetHidden(true)
	QuickEmotes.button = {}
	setmetatable(QuickEmotes.button, QuickEmotesOverrideButton)
	QuickEmotes.button.button = button
end

function QuickEmotesOverrideButton.SetHidden(self, bool)
	if bool then
		self.button:hide()
	else
		self.button:show()
	end
end

function QuickEmotesOverrideButton.SetAnchor(self, text)
	
end

table.insert(LibChatMenuButton.override, override)