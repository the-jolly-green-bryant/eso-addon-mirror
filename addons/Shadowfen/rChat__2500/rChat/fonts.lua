--[[
Author: Ayantir
Filename: fonts.lua
Version: 5
]]--

local LMP = LibMediaProvider

LMP:Register("font", "ESO Standard Font", "EsoUI/Common/Fonts/univers57.slug")
LMP:Register("font", "ESO Book Font", "EsoUI/Common/Fonts/ProseAntiquePSMT.slug")
LMP:Register("font", "ESO Tablet Font", "EsoUI/Common/Fonts/TrajanPro-Regular.slug")
-- LMP:Register("font", "ESO Gamepad Font"] = "EsoUI/Common/Fonts/FuturaStd-Condensed.slug"  -- Too hard to read.

--[[
Font file for rChat
Feel free to add your fonts here, but usage is at your own risk
Font MUST be a .slug file. It doesn't need to be installed on the system
"/" must be used for directories, not "\"
ex :
LMP:Register("font", "Font Name", "rChat/fonts/Path/to/your/font.slug")
]]--

-- rChat core fonts

LMP:Register("font", "Arvo", "rChat/fonts/Arvo/Arvo-Regular.slug")
LMP:Register("font", "DejaVuSans", "rChat/fonts/DejaVu/DejaVuSans.slug")
LMP:Register("font", "DejaVuSansCondensed", "rChat/fonts/DejaVu/DejaVuSansCondensed.slug")
LMP:Register("font", "DejaVuSansMono", "rChat/fonts/DejaVu/DejaVuSansMono.slug")
LMP:Register("font", "DejaVuSerif", "rChat/fonts/DejaVu/DejaVuSerif.slug")
LMP:Register("font", "DroidSans", "rChat/fonts/Droid_Sans/DroidSans.slug")
LMP:Register("font", "OpenSans", "rChat/fonts/OpenSans/OpenSans-Regular.slug")
LMP:Register("font", "OpenSans Semibold", "rChat/fonts/OpenSans/OpenSans-Semibold.slug")
LMP:Register("font", "Prociono", "rChat/fonts/Prociono/Prociono-Regular.slug")
LMP:Register("font", "PT_Sans", "rChat/fonts/PT_Sans/PTSans-Regular.slug")
LMP:Register("font", "Ubuntu", "rChat/fonts/Ubuntu/Ubuntu-Regular.slug")
LMP:Register("font", "Ubuntu Medium", "rChat/fonts/Ubuntu/Ubuntu-Medium.slug")
LMP:Register("font", "Vollkorn", "rChat/fonts/Vollkorn/Vollkorn-Regular.slug")
LMP:Register("font", "RuEsoChat", "rChat/fonts/RuEsoChat/RuEsoChat.slug")
LMP:Register("font", "OpenDyslexic", "rChat/fonts/OpenDyslexic/OpenDyslexicAlta-Regular.slug")

-- Google Fonts Roboto: https://fonts.google.com/specimen/Roboto
LMP:Register("font", "Roboto", "rChat/fonts/Roboto/Roboto-Regular.slug")
LMP:Register("font", "Roboto Medium", "rChat/fonts/Roboto/Roboto-Medium.slug")

-- Google Fonts Roboto Condensed: https://fonts.google.com/specimen/Roboto+Condensed
LMP:Register("font", "Roboto Condensed", "rChat/fonts/Roboto/RobotoCondensed-Regular.slug")

-- Personalized fonts :
