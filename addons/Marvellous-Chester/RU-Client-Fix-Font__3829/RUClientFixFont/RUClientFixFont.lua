local RCFF = RUClientFixFont or {}

RCFF.name = "RUClientFixFont"
RCFF.version = "1.2.0"


local MEDIUM_FONT 		= "EsoUI/common/fonts/univers57cyrillic-condensed.slug" 
local BOLD_FONT 		= "esoui/common/fonts/univers67cyrillic-condensedbold.slug" 


function RCFF:Initialise()

	local manager = GetAddOnManager()

	for i = 1, manager:GetNumAddOns() do
	local name, _, _, _, _, state = manager:GetAddOnInfo(i)
	if name == self.name then
		self.version = manager:GetAddOnVersion(i)
		end
	end
	
    for key,value  in zo_insecurePairs(_G) do
        if (key):find("^Zo") and type(value) == "userdata" and value.SetFont then
		   local font = {value:GetFontInfo()}
		   -- DEFAULT USED AS REGULAR/CHAT FONT -- 
           if (font[1] == "EsoUI/Common/Fonts/Univers57.slug") or (font[1] == "EsoUI/Common/Fonts/Univers57.ttf") or (font[1] == "EsoUI/Common/Fonts/Univers57.otf") or (font[1] == "$(MEDIUM_FONT)") then
            font[1] = MEDIUM_FONT
            value:SetFont(table.concat(font, "|"))
           end
		   -- DEFAULT USED AS BOLD FONT --
		   if (font[1] == "EsoUI/Common/Fonts/Univers67.slug") or (font[1] == "EsoUI/Common/Fonts/Univers67.ttf") or (font[1] == "EsoUI/Common/Fonts/Univers67.otf") or (font[1] == "$(BOLD_FONT)") then
            font[1] = BOLD_FONT  
            value:SetFont(table.concat(font, "|"))
           end
        end
    end  
	
	local fontStyle = MEDIUM_FONT
	local fontSize = GetChatFontSize()
	local fontWeight = "soft-shadow-thin"
	local fontName = string.format("%s|$(KB_%s)|%s", fontStyle, fontSize, fontWeight)
	-- Entry Box --
	ZoFontEditChat:SetFont(fontName)
	-- Size --
    CHAT_SYSTEM:SetFontSize(CHAT_SYSTEM.GetFontSizeFromSetting())
end

function RCFF.OnLoad(event, addonName)
  if addonName ~= RCFF.name then return end
  EVENT_MANAGER:UnregisterForEvent(RCFF.name, EVENT_ADD_ON_LOADED, RCFF.OnLoad)
  RCFF:Initialise()
end

EVENT_MANAGER:RegisterForEvent(RCFF.name, EVENT_ADD_ON_LOADED, RCFF.OnLoad)