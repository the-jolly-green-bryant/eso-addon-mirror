NBUIOverrideButton = {}
NBUIOverrideButton.__index = NBUIOverrideButton

local function button1()
	if not NBUI.NB1MaxChatWin_Button then return end

	local button = LibChatMenuButton.addChatButton("NBUINBOneMaxChatWinButtonLCMB", {"/esoui/art/mainmenu/menubar_journal_up.dds", "/esoui/art/mainmenu/menubar_journal_down.dds"}, (NBUIDB or NBUI.db).NB1_Title, NBUI.NB1KeyBindToggle)
	if not (NBUIDB or NBUI.db).NB1_ChatButton then
		button:hide()
	end
	NBUI.NB1MaxChatWin_Button:SetHidden(true)
	NBUI.NB1MaxChatWin_ButtonTexture:SetHidden(true)
	NBUI.NB1MaxChatWin_Button = {}
	setmetatable(NBUI.NB1MaxChatWin_Button, NBUIOverrideButton)
	NBUI.NB1MaxChatWin_Button.button = button
end

local function button2()
	if not NBUI.NB2MaxChatWin_Button then return end

	local button = LibChatMenuButton.addChatButton("NBUINBTwoMaxChatWinButtonLCMB", {"/esoui/art/mainmenu/menubar_journal_up.dds", "/esoui/art/mainmenu/menubar_journal_down.dds"}, NBUIDB.NB2_Title, NBUI.NB2KeyBindToggle)
	if not NBUIDB.NB2_ChatButton then
		button:hide()
	end
	NBUI.NB2MaxChatWin_Button:SetHidden(true)
	NBUI.NB2MaxChatWin_ButtonTexture:SetHidden(true)
	setmetatable(NBUI.NB2MaxChatWin_Button, NBUIOverrideButton)
	NBUI.NB2MaxChatWin_Button.button = button
end

local function button3()
	if not NBUI.NB3MaxChatWin_Button then return end

	local button = LibChatMenuButton.addChatButton("NBUINBThreeMaxChatWinButtonLCMB", {"/esoui/art/mainmenu/menubar_journal_up.dds", "/esoui/art/mainmenu/menubar_journal_down.dds"}, NBUIDB.NB3_Title, NBUI.NB3KeyBindToggle)
	if not NBUIDB.NB3_ChatButton then
		button:hide()
	end
	NBUI.NB3MaxChatWin_Button:SetHidden(true)
	NBUI.NB3MaxChatWin_ButtonTexture:SetHidden(true)
	setmetatable(NBUI.NB3MaxChatWin_Button, NBUIOverrideButton)
	NBUI.NB3MaxChatWin_Button.button = button
end

local function override()
	if not NBUI then return end
	button1()
	button2()
	button3()
end

function NBUIOverrideButton.SetHidden(self, bool)
	if bool then
		self.button:hide()
	else
		self.button:show()
	end
end

table.insert(LibChatMenuButton.override, override)