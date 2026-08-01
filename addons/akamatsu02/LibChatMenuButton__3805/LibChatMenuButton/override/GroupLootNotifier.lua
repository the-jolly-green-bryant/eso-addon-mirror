GLNOverrideButton = {}
GLNOverrideButton.__index = GLNOverrideButton

local function override()
	if not GLN then return end
	if GLN.Name ~= "GroupLootNotifier" then return end
	if not GLN_ToogleButton then return end
	local ToolTip=	'|t16:16:/GroupLootNotifier/lmb.dds|t'	.."|c4B8BFE".." Post notable items list\n"
				..	'|t16:16:/GroupLootNotifier/rmb.dds|t'	.."|c4B8BFE".." Post all looted items list\n"
				..	'|t16:16:/GroupLootNotifier/mmb.dds|t'	.."|c4B8BFE".." Clear looted items list"
	local handler = GLN_ToogleButton:GetHandler("OnMouseUp")
	local button = LibChatMenuButton.addChatButton("GLNToogleButtonLCMB", {'/esoui/art/tradinghouse/tradinghouse_listings_tabicon_up.dds', '/esoui/art/tradinghouse/tradinghouse_listings_tabicon_over.dds'}, ToolTip, handler)
	local settings = ZO_SavedVars:NewAccountWide("GLN_Settings", 2, nil, Defaults)
	if not (settings.LogLoot and settings.Enable) then
		button:hide()
	end
	GLN_ToogleButton:SetHidden(true)
	GLN_ToogleButton = {}
	setmetatable(GLN_ToogleButton, GLNOverrideButton)
	GLN_ToogleButton.button = button
end

function GLNOverrideButton.SetHidden(self, bool)
	if bool then
		self.button:hide()
	else
		self.button:show()
	end
end

table.insert(LibChatMenuButton.override, override)