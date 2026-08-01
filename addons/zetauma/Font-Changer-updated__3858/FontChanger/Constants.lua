FontChanger = {}
local FC = FontChanger

FC.DEFAULT_FONT_CHOICES = {
    "Univers57 (Vanilla UI)",
    "Univers67 (Vanilla UI Bold)",
    "Univers87 (Vanilla UI Bolder)",
    "ProseAntiquePSMT (Vanilla Book)",
    "Handwritten_Bold (Vanilla Letter)",
    "TrajanPro-Regular (Vanilla Stone Tablet)",
    "FTN47 (Vanilla Gamepad Light)",
    "FTN57 (Vanilla Gamepad Medium)",
    "FTN87 (Vanilla Gamepad Bold)",
}

FC.DEFAULT_FONT_VALUES = {
    "EsoUI/Common/Fonts/Univers57.slug",
    "EsoUI/Common/Fonts/Univers67.slug",
    "EsoUI/Common/Fonts/Univers87.slug",
    "EsoUI/Common/Fonts/ProseAntiquePSMT.slug",
    "EsoUI/Common/Fonts/Handwritten_Bold.slug",
    "EsoUI/Common/Fonts/TrajanPro-Regular.slug",
    "EsoUI/Common/Fonts/FTN47.slug",
    "EsoUI/Common/Fonts/FTN57.slug",
    "EsoUI/Common/Fonts/FTN87.slug",
}

FC.FONTSTYLE_VALUES =
{
    FONT_STYLE_NORMAL,
    FONT_STYLE_OUTLINE,
    FONT_STYLE_OUTLINE_THICK,
    FONT_STYLE_SHADOW,
    FONT_STYLE_SOFT_SHADOW_THICK,
    FONT_STYLE_SOFT_SHADOW_THIN,
}

FC.FONTSTYLE_CHOICES =
{
    "Normal",
    "Outline",
    "Outline Thick",
    "Shadow",
    "Soft Shadow Thick",
    "Soft Shadow Thin",
}

FC.FONTWEIGHT_CHOICES =
{
    "Thick Outline",
    "Shadow",
    "Soft Shadow Thick",
    "Soft Shadow Thin",
}
FC.FONTWEIGHT_VALUES =
{
    "thick-outline",
    "shadow",
    "soft-shadow-thick",
    "soft-shadow-thin",
}

FC.UI_FONTSTYLE_CHOICES =
{
    "Normal",
    "Outline",
    "Thick Outline",
    "Shadow",
    "Soft Shadow Thick",
    "Soft Shadow Thin",
}
FC.UI_FONTSTYLE_VALUES =
{
    "",
    "outline",
    "thick-outline",
    "shadow",
    "soft-shadow-thick",
    "soft-shadow-thin",
}

FC.FONTSIZE_CHOICES =
{
    "Size 8",
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
    8,
    10,
    12,
    14,
    16,
    18,
    20,
    22,
    24,
    26,
    28,
    30,
    32,
    34,
    36,
    38,
    40,
    42,
    48,
    52,
    58,
    62,
    68,
    72,
}

FC.defaults =
{
    -- fonts
    menu_font = "FontChanger/fonts/slugs/FCUI.slug",
    menu_bold_font = "FontChanger/fonts/slugs/FCUI_Bold.slug",
    chat_font = "FontChanger/fonts/slugs/FCChat.slug",
    sct_font = "FontChanger/fonts/slugs/FCUI.slug",
    nameplate_font = "FontChanger/fonts/slugs/FCUI.slug",
    book_font = "FontChanger/fonts/slugs/FCBook.slug",
    letter_font = "EsoUI/Common/Fonts/Handwritten_Bold.slug",
    tablet_font = "EsoUI/Common/Fonts/TrajanPro-Regular.slug",

    -- scales
    menu_font_scale = 1,
    menu_bold_font_scale = 1,
    book_font_scale = 1,
    letter_font_scale = 1,
    tablet_font_scale = 1,

    -- sizes
    nameplate_size = 20,
    sct_size = 32,

    -- styles
    nameplate_style = FONT_STYLE_SOFT_SHADOW_THIN,
    sct_style = FONT_STYLE_SOFT_SHADOW_THIN,
    chat_style = "thick-outline",
    menu_style = "",

    -- misc
    lore_fonts_enabled = false,
    gamepad_fonts_enabled = true,
}
