FontChanger = {}
local FC = FontChanger or {}

FC.FONTSTYLE_VALUES =
{
  FONT_STYLE_NORMAL,
  FONT_STYLE_OUTLINE,
  FONT_STYLE_OUTLINE_THICK,
  FONT_STYLE_SHADOW,
  FONT_STYLE_SOFT_SHADOW_THICK,
  FONT_STYLE_SOFT_SHADOW_THIN,
}

FC.FONT_SCALING_CHOICES =
{
  "x 0.1",
  "x 0.2",
  "x 0.3",
  "x 0.4",
  "x 0.5",
  "x 0.6",
  "x 0.7",
  "x 0.8",
  "x 0.9",
  "x 1",
  "x 1.1",
  "x 1.2",
  "x 1.3",
  "x 1.4",
  "x 1.5",
  "x 1.6",
  "x 1.7",
  "x 1.8",
  "x 1.9",
  "x 2",
}

FC.FONT_SCALING_VALUES =
{
  "0.1",
  "0.2",
  "0.3",
  "0.4",
  "0.5",
  "0.6",
  "0.7",
  "0.8",
  "0.9",
  "1",
  "1.1",
  "1.2",
  "1.3",
  "1.4",
  "1.5",
  "1.6",
  "1.7",
  "1.8",
  "1.9",
  "2",
}

FC.FONTSIZE_CHOICES =
{
  "Size 8" ,
  "Size 10",
  "Size 12",
  "Size 14",
  "Size 16",
  "Size 18",
  "Size 20",
  "Size 22",
  "Size 24",
  "Size 26",
  "Size 28",
  "Size 30",
  "Size 32",
  "Size 34",
  "Size 36",
  "Size 38",
  "Size 40",
  "Size 42",
  "Size 48",
  "Size 52",
  "Size 58",
  "Size 62",
  "Size 68",
  "Size 72",
}

FC.FONTSIZE_VALUES =
{
  "8" ,
  "10",
  "12",
  "14",
  "16",
  "18",
  "20",
  "22",
  "24",
  "26",
  "28",
  "30",
  "32",
  "34",
  "36",
  "38",
  "40",
  "42",
  "48",
  "52",
  "58",
  "62",
  "68",
  "72",
}

FC.defaults =
{
  default_menu_font_scale = "1",
  default_menu_bold_font_scale = "0.9",
  default_book_font_scale = "1",
  default_nameplate_size = "18",
  default_sct_size = "42",
}
