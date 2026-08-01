local FC = FontChanger or {}
local LAM2 = LibAddonMenu2

FC.name = "FontChanger"
FC.version = "0.9 Alpha"

local REGULAR_FONT = "FontChanger/Fonts/RegularFont.ttf"
local REGULAR_FONT_BOLD = "FontChanger/Fonts/RegularFont_Bold.ttf"
local CHAT_FONT = "FontChanger/Fonts/ChatFont.ttf"
local BOOK_FONT = "FontChanger/Fonts/ScriptureFont.ttf"

function FC:SetUIFonts()
    for key,value  in zo_insecurePairs(_G) do
        if (key):find("^Zo") and type(value) == "userdata" and value.SetFont then
		   local font = {value:GetFontInfo()}
		   -- DEFAULT USED AS REGULAR/CHAT FONT -- 
           if font[1] == "EsoUI/Common/Fonts/Univers57.otf" then
            font[1] = REGULAR_FONT
			-- Default Size: 1 --
            font[2] = font[2] * self.SV.menu_font_scale
            value:SetFont(table.concat(font, "|"))
           end
		   -- DEFAULT USED AS BOLD FONT --
           if font[1] == "EsoUI/Common/Fonts/Univers67.otf" then
            font[1] = REGULAR_FONT_BOLD
			-- Default Size: 0.9 --
            font[2] = font[2] * self.SV.menu_bold_font_scale
            value:SetFont(table.concat(font, "|"))
           end
		   -- DEFAULT USED AS ANTIQUE FONT --
           if font[1] == "EsoUI/Common/Fonts/ProseAntiquePSMT.otf" then
            font[1] = BOOK_FONT
			-- Default Size: 0.9 --
            font[2] = font[2] * self.SV.book_font_scale
            value:SetFont(table.concat(font, "|"))
           end
		   	-- DEFAULT USED AS HANDWRITTEN FONT --
           if font[1] == "EsoUI/Common/Fonts/Handwritten_Bold.otf" then
            font[1] = BOOK_FONT
			-- Default Size: 1 --
            font[2] = font[2] * self.SV.book_font_scale
            value:SetFont(table.concat(font, "|"))
           end
		   -- DEFAULT USED AS STONE TABLET FONT --
           if font[1] == "EsoUI/Common/Fonts/TrajanPro-Regular.otf" then
            font[1] = BOOK_FONT
			-- Default Size: 1 --
            font[2] = font[2] * self.SV.book_font_scale
            value:SetFont(table.concat(font, "|"))
           end
		   	-- DEFAULT USED AS GAMEPAD_LIGHT_FONT --
           if font[1] == "EsoUI/Common/Fonts/FTN47.otf" then
            font[1] = REGULAR_FONT
			-- Default Size: 1 --
            font[2] = font[2] * self.SV.menu_font_scale
            value:SetFont(table.concat(font, "|"))
           end
		   -- DEFAULT USED AS GAMEPAD_MEDIUM_FONT --
           if font[1] == "EsoUI/Common/Fonts/FTN57.otf" then
            font[1] = REGULAR_FONT
			-- Default Size: 1 --
            font[2] = font[2] * self.SV.menu_font_scale
            value:SetFont(table.concat(font, "|"))
           end
		   -- DEFAULT USED AS GAMEPAD_BOLD_FONT --
           if font[1] == "EsoUI/Common/Fonts/FTN87.otf" then
            font[1] = REGULAR_FONT_BOLD
			-- Default Size: 1 --
            font[2] = font[2] * self.SV.menu_font_scale
            value:SetFont(table.concat(font, "|"))
           end
        end
    end
end

function FC:SetWorldFonts()
  local fp, fs
  -- Gamepad Mode -- 
  if IsInGamepadPreferredMode() then
    fp, fs = GetNameplateGamepadFont()

    if fp ~= font or fs ~= style then
      SetNameplateGamepadFont(REGULAR_FONT .. "|" .. self.SV.nameplate_size .. "|", FONT_STYLE_NORMAL)
	  SetSCTGamepadFont(REGULAR_FONT .. "|" .. self.SV.sct_size .. "|", FONT_STYLE_SOFT_SHADOW_THICK)
    end
  -- Keyboard Mode --
  else
    fp, fs = GetNameplateKeyboardFont()

    if fp ~= font or fs ~= style then
      SetNameplateKeyboardFont(REGULAR_FONT .. "|" .. self.SV.nameplate_size .. "|", FONT_STYLE_NORMAL)
	  SetSCTKeyboardFont(REGULAR_FONT .. "|" .. self.SV.sct_size .. "|", FONT_STYLE_SOFT_SHADOW_THICK)
    end
  end
end

function FC:ChangeChatFonts()
	    -- Entry Box --
        ZoFontEditChat:SetFont(CHAT_FONT .. "|".. GetChatFontSize() .. "|", FONT_STYLE_SHADOW)
		-- Chat Window --
        ZoFontChat:SetFont(CHAT_FONT .. "|" .. GetChatFontSize() .. "|", FONT_STYLE_SOFT_SHADOW_THIN)
		-- Size --
        CHAT_SYSTEM:SetFontSize(CHAT_SYSTEM.GetFontSizeFromSetting())
end

function FC:SetDefaults()
  -- Set Defaults --
  if self.SV.menu_font_scale == nil then
	 self.SV.menu_font_scale = self.SV.default_menu_font_scale
  end
  if self.SV.menu_bold_font_scale == nil then
	 self.SV.menu_bold_font_scale = self.SV.default_menu_bold_font_scale
  end
  if self.SV.book_font_scale == nil then
	 self.SV.book_font_scale = self.SV.default_book_font_scale
  end
  if self.SV.nameplate_size == nil then
	 self.SV.nameplate_size = self.SV.default_nameplate_size
  end
  if self.SV.sct_size == nil then
	 self.SV.sct_size = self.SV.default_sct_size
  end
end

function FC:SetupEvents(toggle)
  -- EVENT_ZONE_CHANGED --
  if toggle then
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_ACTIVATED,  function(...) self:SetWorldFonts() end)
  else
    EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_PLAYER_ACTIVATED)
  end
end

function FC:Initialise()
  local manager = GetAddOnManager()

  for i = 1, manager:GetNumAddOns() do
    local name, _, _, _, _, state = manager:GetAddOnInfo(i)
    if name == self.name then
      self.version = manager:GetAddOnVersion(i)
    end
  end
  
  -- Load Saved Variables --
  self.SV = ZO_SavedVars:NewAccountWide("FontChangerSettings", self.version, "Settings", self.defaults)
  
  -- Run Functions --
  self:SetupEvents(true)
  self:SetDefaults()
  self:SetUIFonts()
  self:SetWorldFonts()
  self:ChangeChatFonts()
end

function FC.OnLoad(event, addonName)
  if addonName ~= FC.name then return end
  EVENT_MANAGER:UnregisterForEvent(FC.name, EVENT_ADD_ON_LOADED, FC.OnLoad)
  FC:InitialiseAddonMenu()
  FC:Initialise()
end

EVENT_MANAGER:RegisterForEvent(FC.name, EVENT_ADD_ON_LOADED, FC.OnLoad)