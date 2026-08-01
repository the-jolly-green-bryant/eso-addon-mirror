local stringsEN = {
    --LAM settings
    FCOCURSOR_LAM_HEADER_EXCHANGE_CURSOR    =   "Exchange cursors",
    FCOCURSOR_LAM_EXCHANGE_DEFAULT_CURSOR   =   "Exchange the default cursor",
    FCOCURSOR_LAM_EXCHANGE_DEFAULT_CURSOR_TT =  "Exchange the default cursor with another cursor",
    FCOCURSOR_LAM_HEADER_CURSOR_VISUALS    =    "Visual cursor changes",
    FCOCURSOR_LAM_CURSOR_GLOW    =              "Glow around the cursor",
    FCOCURSOR_LAM_CURSOR_GLOW_TT    =           "Show a glowing effect around the cursor",
    FCOCURSOR_LAM_CURSOR_GLOW_COLOR =           "Glow color - Center",
    FCOCURSOR_LAM_CURSOR_GLOW_COLOR_TT  =       "The color for the glow - center",
    FCOCURSOR_LAM_CURSOR_GLOW_COLOR_EDGE =      "Glow color - Edge",
    FCOCURSOR_LAM_CURSOR_GLOW_COLOR_EDGE_TT  =  "The color for the glow - edge",
    FCOCURSOR_LAM_CURSOR_GLOW_SIZE_X =          "Glow size X",
    FCOCURSOR_LAM_CURSOR_GLOW_SIZE_X_TT =       "The size of the cursor glow (width)",
    FCOCURSOR_LAM_CURSOR_GLOW_SIZE_Y =          "Glow size Y",
    FCOCURSOR_LAM_CURSOR_GLOW_SIZE_Y_TT =       "The size of the cursor glow (height)",

    --Cursor types for the dropdown
    FCOCURSOR_LAM_CURSOR_TYPE_default = "Default cursor",
    FCOCURSOR_LAM_CURSOR_TYPE_resizeEW = "East-West Resize",
    FCOCURSOR_LAM_CURSOR_TYPE_resizeNS = "North-South Resize",
    FCOCURSOR_LAM_CURSOR_TYPE_resizeNESW = "Northeast-Southwest Resize",
    FCOCURSOR_LAM_CURSOR_TYPE_resizeNWSE = "Northwest-Southeast Resize",
    FCOCURSOR_LAM_CURSOR_TYPE_icon = "Icon",
    FCOCURSOR_LAM_CURSOR_TYPE_uiHand = "UI Hand",
    FCOCURSOR_LAM_CURSOR_TYPE_erase = "Eraser",
    FCOCURSOR_LAM_CURSOR_TYPE_fill = "Fill",
    FCOCURSOR_LAM_CURSOR_TYPE_fillMultiple = "Fill Multiple",
    FCOCURSOR_LAM_CURSOR_TYPE_paint = "Paint",
    FCOCURSOR_LAM_CURSOR_TYPE_sample = "Sample",
    FCOCURSOR_LAM_CURSOR_TYPE_pan = "Pan",
    FCOCURSOR_LAM_CURSOR_TYPE_rotate = "Rotate",
    FCOCURSOR_LAM_CURSOR_TYPE_nextLeft = "Next Left",
    FCOCURSOR_LAM_CURSOR_TYPE_nextRight = "Next Right",
    FCOCURSOR_LAM_CURSOR_TYPE_preview = "Preview",
    FCOCURSOR_LAM_CURSOR_TYPE_championWorldStar = "Champion World Star",
    FCOCURSOR_LAM_CURSOR_TYPE_championCombatStar = "Champion Combat Star",
    FCOCURSOR_LAM_CURSOR_TYPE_championConditioningStar = "Champion Conditioning Star",
    FCOCURSOR_LAM_CURSOR_TYPE_doNotCare = "Do not care",
}

for stringId, stringValue in pairs(stringsEN) do
   ZO_CreateStringId(stringId, stringValue)
   SafeAddVersion(stringId, 1)
end