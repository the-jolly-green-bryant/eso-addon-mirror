local LtoRuF = LinkstoRuFonts or {}

LtoRuF.name = "LinkstoRuFonts"
LtoRuF.version = "1.0"

local REGULAR_FONT 		= "esoui/common/fonts/univers57cyrillic-condensed.slug"
local REGULAR_FONT_BOLD		= "esoui/common/fonts/univers67cyrillic-condensedbold.slug"
local NAMEPLATE_FONT		= "esoui/common/fonts/univers57cyrillic-condensed.slug"
local SCT_FONT 			= "esoui/common/fonts/univers67cyrillic-condensedbold.slug"
local CHAT_FONT 		= "esoui/common/fonts/univers57cyrillic-condensed.slug"
local BOOK_FONT 		= "esoui/common/fonts/proseantiquepsmtcyrilic.slug"
local LETTER_FONT		= "esoui/common/fonts/handwrittencyrillic_bold.slug"
local STONE_TABLET_FONT         = "esoui/common/fonts/trajanprocyrillic-regular.slug" 


function LtoRuF:RuUIFonts()

    for key,value  in zo_insecurePairs(_G) do
        if (key):find("^Zo") and type(value) == "userdata" and value.SetFont then
		   local font = {value:GetFontInfo()}
		   -- DEFAULT USED AS REGULAR/CHAT FONT -- 
           if (font[1] == "EsoUI/Common/Fonts/Univers57.slug") or (font[1] == "EsoUI/Common/Fonts/Univers57.ttf") or (font[1] == "EsoUI/Common/Fonts/Univers57.otf") or (font[1] == "$(MEDIUM_FONT)") then
            font[1] = REGULAR_FONT
            value:SetFont(table.concat(font, "|"))
           end
		   -- DEFAULT USED AS BOLD FONT --
           if (font[1] == "EsoUI/Common/Fonts/Univers67.slug") or (font[1] == "EsoUI/Common/Fonts/Univers67.ttf") or (font[1] == "EsoUI/Common/Fonts/Univers67.otf") or (font[1] == "$(BOLD_FONT)") then
            font[1] = REGULAR_FONT_BOLD
            value:SetFont(table.concat(font, "|"))
           end
		   -- DEFAULT USED AS ANTIQUE FONT --
           if (font[1] == "EsoUI/Common/Fonts/ProseAntiquePSMT.slug") or (font[1] == "EsoUI/Common/Fonts/ProseAntiquePSMT.ttf") or (font[1] == "EsoUI/Common/Fonts/ProseAntiquePSMT.otf") or (font[1] == "$(ANTIQUE_FONT)") then
            font[1] = BOOK_FONT
            value:SetFont(table.concat(font, "|"))
           end
		   -- DEFAULT USED AS HANDWRITTEN FONT --
           if (font[1] == "EsoUI/Common/Fonts/Handwritten_Bold.slug") or (font[1] == "EsoUI/Common/Fonts/Handwritten_Bold.ttf") or (font[1] == "EsoUI/Common/Fonts/Handwritten_Bold.otf") or(font[1] == "$(HANDWRITTEN_FONT)") then
            font[1] = LETTER_FONT
            value:SetFont(table.concat(font, "|"))
           end
		   -- DEFAULT USED AS STONE TABLET FONT --
           if (font[1] == "EsoUI/Common/Fonts/TrajanPro-Regular.slug") or (font[1] == "EsoUI/Common/Fonts/TrajanPro-Regular.ttf") or (font[1] == "EsoUI/Common/Fonts/TrajanPro-Regular.otf") or (font[1] == "$(STONE_TABLET_FONT)") then
            font[1] = STONE_TABLET_FONT
            value:SetFont(table.concat(font, "|"))
           end
                   -- DEFAULT USED AS GAMEPAD_LIGHT_FONT --
           if (font[1] == "EsoUI/Common/Fonts/FTN47.slug") or (font[1] == "EsoUI/Common/Fonts/FTN47.ttf") or (font[1] == "EsoUI/Common/Fonts/FTN47.otf") or (font[1] == "$(GAMEPAD_LIGHT_FONT)") then
            font[1] = REGULAR_FONT
            value:SetFont(table.concat(font, "|"))
           end
		   -- DEFAULT USED AS GAMEPAD_MEDIUM_FONT --
           if (font[1] == "EsoUI/Common/Fonts/FTN57.slug") or (font[1] == "EsoUI/Common/Fonts/FTN57.ttf") or (font[1] == "EsoUI/Common/Fonts/FTN57.otf") or (font[1] == "$(GAMEPAD_MEDIUM_FONT)") then
            font[1] = REGULAR_FONT
            value:SetFont(table.concat(font, "|"))
           end
		   -- DEFAULT USED AS GAMEPAD_BOLD_FONT --
           if (font[1] == "EsoUI/Common/Fonts/FTN87.slug") or (font[1] == "EsoUI/Common/Fonts/FTN87.ttf") or (font[1] == "EsoUI/Common/Fonts/FTN87.otf") or (font[1] == "$(GAMEPAD_BOLD_FONT)") then
            font[1] = REGULAR_FONT_BOLD
            value:SetFont(table.concat(font, "|"))
           end
        end
    end
end

function LtoRuF:Initialise()

     local manager = GetAddOnManager()
    
     for i = 1, manager:GetNumAddOns() do
        local name, _, _, _, _, state = manager:GetAddOnInfo(i)
        if name == self.name then
           self.version = manager:GetAddOnVersion(i)
        end
    end
    self:RuUIFonts()
    local fontStyle = CHAT_FONT
    local fontSize = GetChatFontSize()
    local fontWeight = "thick-outline"
    local fontName = string.format("%s|$(KB_%s)|%s", fontStyle, fontSize, fontWeight)
     -- Entry Box --
    ZoFontEditChat:SetFont(fontName)
     -- load chat size in game settings --
    CHAT_SYSTEM:SetFontSize(CHAT_SYSTEM.GetFontSizeFromSetting())
end

function LtoRuF.OnLoad(event, addonName)
  if addonName ~= LtoRuF.name then return end
  EVENT_MANAGER:UnregisterForEvent(LtoRuF.name, EVENT_ADD_ON_LOADED, LtoRuF.OnLoad)
  LtoRuF:Initialise()
end

EVENT_MANAGER:RegisterForEvent(LtoRuF.name, EVENT_ADD_ON_LOADED, LtoRuF.OnLoad)