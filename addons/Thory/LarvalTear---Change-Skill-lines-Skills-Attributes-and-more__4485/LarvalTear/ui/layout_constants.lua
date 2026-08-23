local Addon = LarvalTearMod

local LayoutConstants = {}
Addon.UI.LayoutConstants = LayoutConstants

local CARD_SUMMARY_HEIGHT = 112
local CARD_SKILL_HEIGHT = 86

LayoutConstants.Card = {
    SPACING = 10,
    HEADER_HEIGHT = 42,
    ROLE_ICON_SIZE = 20,
    TITLE_LEFT = 5,
    ORDINAL_WIDTH = 24,
    ORDINAL_GAP = 4,
    TITLE_ROLE_GAP = 8,
    SUMMARY_HEIGHT = CARD_SUMMARY_HEIGHT,
    SUMMARY_BLOCK_HEIGHT = 18,
    SUMMARY_BLOCK_GAP = 8,
    SUMMARY_VALUE_HEIGHT = 18,
    SUMMARY_TOP_PADDING = 8,
    STATUS_TOP = 30,
    SUMMARY_CHECKBOX_TOP = 50,
    SUMMARY_CHECKBOX_SECOND_COLUMN_X = 191,
    LINK_ROW_TOP = 82,
    LINK_ROW_HEIGHT = 28,
    LINK_QS_DROPDOWN_X = 0,
    LINK_FOOD_DROPDOWN_X = 191,
    LINK_DROPDOWN_WIDTH = 150,
    SKILL_SETTINGS_WIDTH = 341,
    SKILL_HEIGHT = CARD_SKILL_HEIGHT,
    ATTRIBUTE_WIDTH = 72,
    ATTRIBUTE_ROW_HEIGHT = 18,
    ATTRIBUTE_ROW_GAP = 6,
    EXPANDED_HEIGHT = CARD_SUMMARY_HEIGHT + CARD_SKILL_HEIGHT + 8 + 3,
    SKILL_SECTION_OFFSET_Y = 0,
    LIST_SCROLLBAR_GUTTER = 14,
    LIST_CONTAINER_SCROLLBAR_GAP = 4,
    LIST_SECTION_BOTTOM_EXTENSION = 10,
    -- Runtime layout prefers cardListSection:GetHeight(); this is only a fallback before controls report size.
    LIST_SECTION_FALLBACK_HEIGHT = 492,
    ACTION_MENU_WIDTH = 240,
    ACTION_MENU_ROW_HEIGHT = 32,
    ACTION_MENU_ROW_GAP = 4,
}

LayoutConstants.Dialog = {
    WIDTH = 456,
    CONFIRM_HEIGHT = 236,
    INPUT_HEIGHT = 292,
    OVERWRITE_HEIGHT = 306,
    PAGE_REORDER_HEIGHT = 456,
    OUTER_PADDING = 20,
    TITLE_HEIGHT = 30,
    TITLE_BODY_GAP = 14,
    BODY_CONFIRM_HEIGHT = 92,
    BODY_INPUT_HEIGHT = 54,
    BODY_PAGE_REORDER_HEIGHT = 72,
    BODY_INPUT_GAP = 14,
    INPUT_LABEL_HEIGHT = 20,
    INPUT_EDIT_GAP = 8,
    EDIT_HEIGHT = 32,
    INPUT_NOTE_HEIGHT = 18,
    BUTTON_ROW_HEIGHT = 32,
    BUTTON_WIDTH = 136,
    BUTTON_GAP = 10,
    BUDGET_SHORT_WIDTH = 560,
    BUDGET_SHORT_HEIGHT = 404,
    BUDGET_SHORT_BODY_HEIGHT = 260,
    BUDGET_SHORT_SUMMARY_ROW_MIN_HEIGHT = 18,
    BUDGET_SHORT_SUMMARY_ROW_GAP = 2,
    BUDGET_SHORT_EXPECTED_MIN_HEIGHT = 36,
    BUDGET_SHORT_EXPECTED_GAP = 16,
    BUDGET_SHORT_BUTTON_WIDTH = 172,
    SKILL_SNAPSHOT_WIDTH = 760,
    SKILL_SNAPSHOT_HEIGHT = 640,
    SKILL_SNAPSHOT_BODY_HEIGHT = 530,
    TRANSFORM_SKILLS_WIDTH = 920,
    TRANSFORM_SKILLS_HEIGHT = 386,
    TRANSFORM_SKILLS_BODY_HEIGHT = 250,
    BUTTON_BOTTOM_PADDING = 20,
    OVERWRITE_OPTION_HEIGHT = 30,
    -- ZO_DefaultButton's border consumes part of the gap; 10px leaves about 5px of visible space.
    OVERWRITE_OPTION_GAP = 10,
    OVERWRITE_PANEL_OFFSET_Y = -10,
    PAGE_REORDER_PANEL_HEIGHT = 230,
    PAGE_REORDER_ROW_HEIGHT = 42,
    PAGE_REORDER_ROW_GAP = 8,
    PAGE_REORDER_BUTTON_WIDTH = 64,
}

LayoutConstants.RightPaneList = {
    EQUIPMENT_ROW_HEIGHT = 18,
    CP_ROW_HEIGHT = 18,
    ROW_GAP = 1,
    CP_GROUP_GAP = 4,
    CP_ICON_SIZE = 12,
    CP_FRAME_SIZE = 14,
    EQUIPMENT_WIDTH = 340,
    EQUIPMENT_MISSING_COLOR = { 0.48, 0.50, 0.54, 1.0 },
    EQUIPMENT_MISSING_TRAIT_COLOR = { 0.38, 0.40, 0.44, 1.0 },
    EQUIPMENT_WITHDRAW_ICON_TEXTURE_PREFIX = "EsoUI/Art/Bank/bank_tabicon_withdraw",
    EQUIPMENT_DEPOSIT_ICON_TEXTURE_PREFIX = "EsoUI/Art/Bank/bank_tabicon_deposit",
    DETAIL_TITLE_HEIGHT = 22,
}

LayoutConstants.RightPaneIconStrip = {
    ROLE_ICON_SIZE = 26,
    ROLE_TOP_OFFSET = 7,
    ROLE_RIGHT_OFFSET = -62,
    CLASS_MASTERY_OFFSET_X = 31,
    TRANSFORM_ICON_SIZE = 24,
    TRANSFORM_TOP_OFFSET = 9,
    TRANSFORM_RIGHT_OFFSETS = {
        werewolf = -31,
        vampire = -2,
    },
}

LayoutConstants.RoleIconTextures = {
    [LFG_ROLE_TANK] = "EsoUI/Art/LFG/LFG_icon_tank.dds",
    [LFG_ROLE_HEAL] = "EsoUI/Art/LFG/LFG_icon_healer.dds",
    [LFG_ROLE_DPS] = "EsoUI/Art/LFG/LFG_icon_dps.dds",
}

LayoutConstants.AttributeLayouts = {
    {
        id = "health",
        shortLabelKey = "attribute.short.health",
        color = { 0.92, 0.30, 0.30, 1.0 },
    },
    {
        id = "magicka",
        shortLabelKey = "attribute.short.magicka",
        color = { 0.33, 0.62, 0.96, 1.0 },
    },
    {
        id = "stamina",
        shortLabelKey = "attribute.short.stamina",
        color = { 0.42, 0.82, 0.38, 1.0 },
    },
}
