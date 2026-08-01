NamePlater = {}
local NP = NamePlater or {}

NP.FONT_CHOICES =
{
  -- 1: Custom Font Display Name
  "OpenSans",
  "Montserrat",
  "Poppins",
  "Geist",

  -- ESO fonts
  "Univers57",
  "Univers67",
  "FTN47",
  "FTN57",
  "FTN87",
  "ProseAntiquePSMT",
  "Handwritten_Bold",
  "TrajanPro-Regular",
}

NP.FONT_VALUES =
{
  -- 2: Custom Font Location
  "NamePlater/fonts/OpenSans-ExtraBold.ttf",
  "NamePlater/fonts/MontserratAlternates.otf",
  "NamePlater/fonts/Poppins-Medium.otf",
  "NamePlater/fonts/Geist-Bold.otf",

  -- ESO Keyboard Fonts
  "EsoUI/Common/Fonts/Univers57.otf",
  "EsoUI/Common/Fonts/Univers67.otf",

  -- ESO Gamepad Fonts
  "EsoUI/Common/Fonts/FTN47.otf",
  "EsoUI/Common/Fonts/FTN57.otf",
  "EsoUI/Common/Fonts/FTN87.otf",

  -- ESO Roleplay Fonts
  "EsoUI/Common/Fonts/ProseAntiquePSMT.otf",
  "EsoUI/Common/Fonts/Handwritten_Bold.otf",
  "EsoUI/Common/Fonts/TrajanPro-Regular.otf",
}

NP.FONTSTYLE_CHOICES =
{
  "Normal",
  "Outline",
  "Outline Thicc",
  "Shadow",
  "Soft Shadow",
  "Shadow Thin",
}

NP.FONTSTYLE_VALUES =
{
  FONT_STYLE_NORMAL,
  FONT_STYLE_OUTLINE,
  FONT_STYLE_OUTLINE_THICK,
  FONT_STYLE_SHADOW,
  FONT_STYLE_SOFT_SHADOW_THICK,
  FONT_STYLE_SOFT_SHADOW_THIN,
}

NP.FONTSIZE_CHOICES =
{
  "KB_8" ,
  "KB_9" ,
  "KB_10",
  "KB_11",
  "KB_12",
  "KB_13",
  "KB_14",
  "KB_15",
  "KB_16",
  "KB_17",
  "KB GP 18",
  "KB_19",
  "KB GP 20",
  "KB_21",
  "KB GP 22",
  "KB_23",
  "KB_24",
  "KB GP 25",
  "KB_26",
  "GP_27",
  "KB_28",
  "KB GP 30",
  "KB_32",
  "KB GP 34",
  "KB GP 36",
  "KB_40",
  "GP_42",
  "GP_45",
  "KB GP 48",
  "KB GP 54",
  "GP_61",
}

NP.FONTSIZE_VALUES =
{
  "8",
  "9",
  "10",
  "11",
  "12",
  "13",
  "14",
  "15",
  "16",
  "17",
  "18",
  "19",
  "20",
  "21",
  "22",
  "23",
  "24",
  "25",
  "26",
  "27",
  "28",
  "30",
  "32",
  "34",
  "36",
  "40",
  "42",
  "45",
  "48",
  "54",
  "61", --31
}

NP.defaults =
{
  enabled = true,
  font = "EsoUI/Common/Fonts/Univers67.otf",
  style = FONT_STYLE_SOFT_SHADOW_THIN,
  size = "16",
}
