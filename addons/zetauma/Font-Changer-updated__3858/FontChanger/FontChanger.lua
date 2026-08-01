local FC = assert(FontChanger, "FontChanger global table not found — check load order in FontChanger.txt")

FC.name = "FontChanger"
FC.version = "1.6"

function FC:SetUIFonts()
	for key, value in zo_insecurePairs(_G) do
		if (key):find("^Zo") and type(value) == "userdata" and value.SetFont then
			local font = {value:GetFontInfo()}

			if (font[1] == "EsoUI/Common/Fonts/Univers57.slug") or (font[1] == "$(MEDIUM_FONT)") then
				font[1] = self.SV.menu_font
				font[2] = font[2] * self.SV.menu_font_scale
				if self.SV.menu_style ~= "" then font[3] = self.SV.menu_style end
				value:SetFont(table.concat(font, "|"))
			elseif (font[1] == "EsoUI/Common/Fonts/Univers67.slug") or (font[1] == "$(BOLD_FONT)") then
				font[1] = self.SV.menu_bold_font
				font[2] = font[2] * self.SV.menu_bold_font_scale
				if self.SV.menu_style ~= "" then font[3] = self.SV.menu_style end
				value:SetFont(table.concat(font, "|"))
			elseif self.SV.lore_fonts_enabled then
				if (font[1] == "EsoUI/Common/Fonts/ProseAntiquePSMT.slug") or (font[1] == "$(ANTIQUE_FONT)") then
					font[1] = self.SV.book_font
					font[2] = font[2] * self.SV.book_font_scale
					value:SetFont(table.concat(font, "|"))
				elseif (font[1] == "EsoUI/Common/Fonts/Handwritten_Bold.slug") or (font[1] == "$(HANDWRITTEN_FONT)") then
					font[1] = self.SV.letter_font
					font[2] = font[2] * self.SV.letter_font_scale
					value:SetFont(table.concat(font, "|"))
				elseif (font[1] == "EsoUI/Common/Fonts/TrajanPro-Regular.slug") or (font[1] == "$(STONE_TABLET_FONT)") then
					font[1] = self.SV.tablet_font
					font[2] = font[2] * self.SV.tablet_font_scale
					value:SetFont(table.concat(font, "|"))
				end
			elseif self.SV.gamepad_fonts_enabled then
				if (font[1] == "EsoUI/Common/Fonts/FTN47.slug") or (font[1] == "$(GAMEPAD_LIGHT_FONT)") then
					font[1] = self.SV.menu_font
					font[2] = font[2] * self.SV.menu_font_scale
					if self.SV.menu_style ~= "" then font[3] = self.SV.menu_style end
					value:SetFont(table.concat(font, "|"))
				elseif (font[1] == "EsoUI/Common/Fonts/FTN57.slug") or (font[1] == "$(GAMEPAD_MEDIUM_FONT)") then
					font[1] = self.SV.menu_font
					font[2] = font[2] * self.SV.menu_font_scale
					if self.SV.menu_style ~= "" then font[3] = self.SV.menu_style end
					value:SetFont(table.concat(font, "|"))
				elseif (font[1] == "EsoUI/Common/Fonts/FTN87.slug") or (font[1] == "$(GAMEPAD_BOLD_FONT)") then
					font[1] = self.SV.menu_bold_font
					font[2] = font[2] * self.SV.menu_bold_font_scale
					if self.SV.menu_style ~= "" then font[3] = self.SV.menu_style end
					value:SetFont(table.concat(font, "|"))
				end
			end
		end
	end
end

function FC:SetNameplateFont(style, size)
	local newFontAndSize = self.SV.nameplate_font .. "|" .. size .. "|"

	if IsInGamepadPreferredMode() then
		if not self.SV.gamepad_fonts_enabled then
			SetNameplateGamepadFont("EsoUI/Common/Fonts/FTN57.slug|30|", self.defaults.nameplate_style)
			return
		end
		local currentFont, currentStyle = GetNameplateGamepadFont()
		if currentFont ~= newFontAndSize or currentStyle ~= style then
			SetNameplateGamepadFont(newFontAndSize, style)
		end
	else
		local currentFont, currentStyle = GetNameplateKeyboardFont()
		if currentFont ~= newFontAndSize or currentStyle ~= style then
			SetNameplateKeyboardFont(newFontAndSize, style)
		end
	end
end

function FC:SetSCTFont(style, size)
	local newFontAndSize = self.SV.sct_font .. "|" .. size .. "|"

	if IsInGamepadPreferredMode() then
		if not self.SV.gamepad_fonts_enabled then
			SetSCTGamepadFont("EsoUI/Common/Fonts/FTN87.slug|52|", self.defaults.sct_style)
			return
		end
		local currentFont, currentStyle = GetSCTGamepadFont()
		if currentFont ~= newFontAndSize or currentStyle ~= style then
			SetSCTGamepadFont(newFontAndSize, style)
		end
	else
		local currentFont, currentStyle = GetSCTKeyboardFont()
		if currentFont ~= newFontAndSize or currentStyle ~= style then
			SetSCTKeyboardFont(newFontAndSize, style)
		end
	end
end

function FC:ChangeChatFonts()
	local fontSize = GetChatFontSize()
	local fontName = string.format("%s|$(KB_%s)|%s", self.SV.chat_font, fontSize, self.SV.chat_style)
	-- Entry Box --
	ZoFontEditChat:SetFont(fontName)
	-- Chat Window --
	ZoFontChat:SetFont(fontName)
	-- Force existing chat buffers to pick up the new font
	if CHAT_SYSTEM and CHAT_SYSTEM.containers then
		for _, container in pairs(CHAT_SYSTEM.containers) do
			if container.windows then
				for _, window in ipairs(container.windows) do
					if window.buffer then
						window.buffer:SetFont(fontName)
					end
				end
			end
		end
	end
	CHAT_SYSTEM:SetFontSize(CHAT_SYSTEM.GetFontSizeFromSetting())
end

function FC:HookLoreReader()
	local fontMap = {
		["$(ANTIQUE_FONT)"] = { font = "book_font", scale = "book_font_scale" },
		["$(HANDWRITTEN_FONT)"] = { font = "letter_font", scale = "letter_font_scale" },
		["$(STONE_TABLET_FONT)"] = { font = "tablet_font", scale = "tablet_font_scale" },
	}

	-- LORE_READER instance doesn't exist during EVENT_ADD_ON_LOADED; defer until all UI objects exist
	EVENT_MANAGER:RegisterForEvent(self.name .. "LoreReader", EVENT_PLAYER_ACTIVATED, function()
		EVENT_MANAGER:UnregisterForEvent(self.name .. "LoreReader", EVENT_PLAYER_ACTIVATED)
		ZO_PostHook(LORE_READER, "ApplyMedium", function(reader, medium, isGamepad)
			local titleFontName, titleFontSize, titleFontStyle,
				bodyFontName, bodyFontSize, bodyFontStyle = GetBookMediumFontInfo(medium, isGamepad)
			if not FC.SV.lore_fonts_enabled then return end
			local mapping = fontMap[bodyFontName]
			if not mapping then return end

			local newFont = FC.SV[mapping.font]
			local scale = FC.SV[mapping.scale] or 1

			local newBodySize = math.floor(bodyFontSize * scale)
			reader.firstPage.body:SetFont(ZO_CreateFontString(newFont, newBodySize, bodyFontStyle))
			reader.secondPage.body:SetFont(ZO_CreateFontString(newFont, newBodySize, bodyFontStyle))

			local newTitleSize = math.floor(titleFontSize * scale)
			reader.title:SetFont(ZO_CreateFontString(newFont, newTitleSize, titleFontStyle))
		end)
	end)
end

function FC:RestoreVanillaFonts()
	if not self.SV.vanilla_nameplate then return end
	SetNameplateKeyboardFont(self.SV.vanilla_nameplate.font, self.SV.vanilla_nameplate.style)
	SetNameplateGamepadFont(self.SV.vanilla_nameplate_gamepad.font, self.SV.vanilla_nameplate_gamepad.style)
	SetSCTKeyboardFont(self.SV.vanilla_sct.font, self.SV.vanilla_sct.style)
	SetSCTGamepadFont(self.SV.vanilla_sct_gamepad.font, self.SV.vanilla_sct_gamepad.style)
	d("[FontChanger] Nameplate and SCT fonts restored to vanilla.")
end

function FC:SetupEvents(toggle)
	if toggle then
		EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_ACTIVATED, function(...)
			self:SetNameplateFont(self.SV.nameplate_style, self.SV.nameplate_size)
			self:SetSCTFont(self.SV.sct_style, self.SV.sct_size)
		end)
		EVENT_MANAGER:RegisterForEvent(self.name, EVENT_ZONE_CHANGED, function(...)
			self:SetSCTFont(self.SV.sct_style, self.SV.sct_size)
		end)
		EVENT_MANAGER:RegisterForEvent(self.name, EVENT_GAMEPAD_PREFERRED_MODE_CHANGED, function(...)
			self:SetNameplateFont(self.SV.nameplate_style, self.SV.nameplate_size)
			self:SetSCTFont(self.SV.sct_style, self.SV.sct_size)
		end)
	else
		EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_PLAYER_ACTIVATED)
		EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_ZONE_CHANGED)
		EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_GAMEPAD_PREFERRED_MODE_CHANGED)
	end
end

local SV_VERSION = 1

function FC:Initialize()
	if self.initialized then return end
	self.initialized = true

	-- Load Saved Variables --
	self.SV = ZO_SavedVars:NewAccountWide("FontChangerSettings", SV_VERSION, "Settings", self.defaults)

	-- Capture vanilla nameplate/SCT settings before the addon overwrites them.
	-- These persist in game settings even after the addon is disabled, so we
	-- need to remember the originals to provide a reset path.
	if not self.SV.vanilla_nameplate then
		local npFont, npStyle = GetNameplateKeyboardFont()
		local npGpFont, npGpStyle = GetNameplateGamepadFont()
		self.SV.vanilla_nameplate = { font = npFont, style = npStyle }
		self.SV.vanilla_nameplate_gamepad = { font = npGpFont, style = npGpStyle }
		local sctFont, sctStyle = GetSCTKeyboardFont()
		local sctGpFont, sctGpStyle = GetSCTGamepadFont()
		self.SV.vanilla_sct = { font = sctFont, style = sctStyle }
		self.SV.vanilla_sct_gamepad = { font = sctGpFont, style = sctGpStyle }
	end

	-- Run Functions --
	self:SetupEvents(true)
	self:SetNameplateFont(self.SV.nameplate_style, self.SV.nameplate_size)
	self:SetSCTFont(self.SV.sct_style, self.SV.sct_size)
	self:SetUIFonts()
	self:ChangeChatFonts()
	self:HookLoreReader()
end

function FC.OnLoad(event, addonName)
	if addonName ~= FC.name then
		return
	end
	EVENT_MANAGER:UnregisterForEvent(FC.name, EVENT_ADD_ON_LOADED, FC.OnLoad)
	FC:Initialize()
	FC:InitializeAddonMenu()
end

EVENT_MANAGER:RegisterForEvent(FC.name, EVENT_ADD_ON_LOADED, FC.OnLoad)
