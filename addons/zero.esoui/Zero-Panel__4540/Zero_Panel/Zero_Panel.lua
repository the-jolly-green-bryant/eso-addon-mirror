ZeroPanel = ZeroPanel or {}
ZERO_PANEL = ZeroPanel

local ZeroPanel = ZeroPanel

ZeroPanel.name = "Zero_Panel"
ZeroPanel.displayName = "ZERO PANEL"
ZeroPanel.savedVarName = "ZeroPanelSavedVars"
ZeroPanel.panelId = "ZeroPanelOptions"

local VERSION_INFO = {
    release = 1,
    candidate = 0,
    change = 0,
}

local function GetVersionNumberPart(value)
    local numericValue = math.floor(tonumber(value) or 0)
    if numericValue < 0 then
        return 0
    end
    return numericValue
end

local function GetReleaseVersion(versionInfo)
    local release = GetVersionNumberPart(versionInfo and versionInfo.release)
    local candidate = GetVersionNumberPart(versionInfo and versionInfo.candidate)
    local change = GetVersionNumberPart(versionInfo and versionInfo.change)

    return string.format("R%d.%d.%d", release, candidate, change)
end

local function GetAddOnVersionNumber(versionInfo)
    local release = GetVersionNumberPart(versionInfo and versionInfo.release)
    local candidate = GetVersionNumberPart(versionInfo and versionInfo.candidate)
    local change = GetVersionNumberPart(versionInfo and versionInfo.change)

    return (release * 1000000) + (candidate * 1000) + change
end

local function GetAddOnVersionString(versionInfo)
    return string.format("%07d", GetAddOnVersionNumber(versionInfo))
end

ZeroPanel.versionInfo = VERSION_INFO
ZeroPanel.version = GetReleaseVersion(VERSION_INFO)
ZeroPanel.addOnVersion = GetAddOnVersionNumber(VERSION_INFO)
ZeroPanel.addOnVersionString = GetAddOnVersionString(VERSION_INFO)
ZeroPanel.versionDisplay = string.format("%s (%s)", ZeroPanel.version, ZeroPanel.addOnVersionString)

local ZERO_BRAND_PURPLE_HEX = "A259FF"
local ZERO_BRAND_WHITE_HEX = "FFFFFF"
local CONTROL_NAME_PREFIX = "ZeroPanelStandalone"

local function GetBrandedZeroAddonName(nameRemainder)
    if not nameRemainder or nameRemainder == "" then
        return string.format("|c%sZERO|r", ZERO_BRAND_PURPLE_HEX)
    end

    return string.format("|c%sZERO|r |c%s%s|r", ZERO_BRAND_PURPLE_HEX, ZERO_BRAND_WHITE_HEX, nameRemainder)
end

local function GetBrandedZeroAddonTag(nameRemainder)
    return string.format("|c%s[|r%s|c%s]|r", ZERO_BRAND_WHITE_HEX, GetBrandedZeroAddonName(nameRemainder), ZERO_BRAND_WHITE_HEX)
end

local function GetColorComponentsFromHex(hexColor)
    local hex = tostring(hexColor or ZERO_BRAND_WHITE_HEX):gsub("^#", "")
    if #hex ~= 6 then
        return 1, 1, 1, 1
    end

    local red = tonumber(hex:sub(1, 2), 16) or 255
    local green = tonumber(hex:sub(3, 4), 16) or 255
    local blue = tonumber(hex:sub(5, 6), 16) or 255
    return red / 255, green / 255, blue / 255, 1
end

local function ApplyColorToControl(control, hexColor)
    if not control or type(control.SetColor) ~= "function" then
        return
    end

    control:SetColor(GetColorComponentsFromHex(hexColor))
end

local function CreateOrUpdateStringId(stringIdName, value)
    if type(stringIdName) ~= "string" or stringIdName == "" then
        return
    end

    if _G[stringIdName] and type(SafeAddString) == "function" then
        SafeAddString(_G[stringIdName], value, 1)
    elseif type(ZO_CreateStringId) == "function" then
        ZO_CreateStringId(stringIdName, value)
    end
end

local ZERO_PANEL_NAME = GetBrandedZeroAddonName("Panel")
local ZERO_PANEL_TAG = GetBrandedZeroAddonTag("PANEL")
local ZERO_PANEL_SETTINGS_NAME = "Zero Panel"
local ZERO_PANEL_GITHUB_URL = "https://github.com/zero-eso/Zero_Panel"
local ZERO_PANEL_GITHUB_ISSUES_URL = ZERO_PANEL_GITHUB_URL .. "/issues"
local ZERO_PANEL_LINK_HEX = "66B5FF"
local SETTINGS_SECTION_COMMANDS_HEX = "58D7D1"
local SETTINGS_SECTION_APPEARANCE_HEX = "E3B05F"
local SETTINGS_SECTION_PANEL_HEX = "7AA2FF"
local SETTINGS_SECTION_VISIBLE_HEX = "7FD17B"
local SETTINGS_SECTION_ASSISTANTS_HEX = "E7A85B"
local SETTINGS_SECTION_ALLY_HEX = "77C7FF"
local SETTINGS_SECTION_CUSTOM_BUTTONS_HEX = "F08A5D"
local SETTINGS_SECTION_CUSTOM_SEPARATORS_HEX = "D97878"
local SETTINGS_SECTION_ORDER_HEX = "E2C56A"
local SETTINGS_SECTION_KEYBIND_DISPLAY_HEX = "7BC4FF"
local SETTINGS_SECTION_KEYBIND_COLORS_HEX = "E59374"
local ZERO_PANEL_KEYBIND_ACTION_PREFIX = "ZERO_PANEL_TRIGGER_SLOT_"
local ZERO_PANEL_KEYBIND_SLOT_COUNT = 60
local ZERO_PANEL_KEYBIND_NONE_VALUE = 0
local ZERO_PANEL_KEYBINDINGS_MENU_NAME = "Zero Panel Keybindings"
local KEYBINDINGS_LAYER_DATA_TYPE = 1
local KEYBINDINGS_CATEGORY_DATA_TYPE = 2
local ZERO_PANEL_KEYBIND_SLOT_CHOICES = {"None"}
local ZERO_PANEL_KEYBIND_SLOT_VALUES = {ZERO_PANEL_KEYBIND_NONE_VALUE}
local ZERO_PANEL_GITHUB_ISSUES_LINK_TAG = "zero_panel_issues"
local ZERO_PANEL_GITHUB_ISSUES_LINK_LABEL = "GitHub Zero_Panel Issues"
local ZERO_PANEL_GITHUB_ISSUES_LINK_TEXT = string.format(
    "|c%s|H0:%s|h%s|h|r",
    ZERO_PANEL_LINK_HEX,
    ZERO_PANEL_GITHUB_ISSUES_LINK_TAG,
    ZERO_PANEL_GITHUB_ISSUES_LINK_LABEL
)
local DEFAULT_KEYBIND_FONT_PATH = "Zero_Panel/assets/fonts/Montserrat-ExtraBold.slug"
local DEFAULT_KEYBIND_FONT_SIZE = 14
local DEFAULT_KEYBIND_FONT_EFFECT = "thick-outline"
local DEFAULT_KEYBIND_DISPLAY_ANCHOR_POINT = "TOPRIGHT"
local DEFAULT_KEYBIND_OFFSET_X = -2
local DEFAULT_KEYBIND_OFFSET_Y = 2
local DEFAULT_KEYBIND_TEXT_COLOR = {0.46, 0.98, 0.84, 1}
local DEFAULT_KEYBIND_BACKGROUND_COLOR = {0.03, 0.05, 0.08, 1}
local DEFAULT_KEYBIND_BACKGROUND_OPACITY = 72
local KEYBIND_BACKGROUND_HORIZONTAL_PADDING = 2
local KEYBIND_BACKGROUND_VERTICAL_PADDING = 0
local KEYBIND_PICKER_PROMPT_WIDTH = 260
local KEYBIND_PICKER_PROMPT_HEIGHT = 64
local KEYBIND_PICKER_PROMPT_DEFAULT_CENTER_Y_OFFSET = 120
local DEFAULT_KEYBIND_MODIFIER_COLORS = {
    ctrl = {0.95, 0.47, 0.42, 1},
    shift = {0.97, 0.84, 0.37, 1},
    alt = {0.45, 0.77, 1.00, 1},
    command = {0.78, 0.63, 1.00, 1},
}
local KEYBIND_DISPLAY_ANCHOR_CHOICES = {
    "Top Left",
    "Top",
    "Top Right",
    "Left",
    "Center",
    "Right",
    "Bottom Left",
    "Bottom",
    "Bottom Right",
}
local KEYBIND_DISPLAY_ANCHOR_VALUES = {
    "TOPLEFT",
    "TOP",
    "TOPRIGHT",
    "LEFT",
    "CENTER",
    "RIGHT",
    "BOTTOMLEFT",
    "BOTTOM",
    "BOTTOMRIGHT",
}
local KEYBIND_FONT_EFFECT_CHOICES = {
    {label = "Normal", value = "none"},
    {label = "Shadow", value = "shadow"},
    {label = "Outline", value = "outline"},
    {label = "Thick Outline", value = "thick-outline"},
    {label = "Outline + Shadow", value = "outline-shadow"},
    {label = "Thick Outline + Shadow", value = "thick-outline-shadow"},
    {label = "Soft Shadow Thin", value = "soft-shadow-thin"},
    {label = "Soft Shadow Thick", value = "soft-shadow-thick"},
}
local KEYBIND_FONT_EFFECT_LABELS = {}
local KEYBIND_FONT_EFFECT_VALUES = {}
for _, entry in ipairs(KEYBIND_FONT_EFFECT_CHOICES) do
    KEYBIND_FONT_EFFECT_LABELS[#KEYBIND_FONT_EFFECT_LABELS + 1] = entry.label
    KEYBIND_FONT_EFFECT_VALUES[#KEYBIND_FONT_EFFECT_VALUES + 1] = entry.value
end
local BUILTIN_KEYBIND_FONTS = {
    { label = "Montserrat ExtraBold", path = "Zero_Panel/assets/fonts/Montserrat-ExtraBold.slug" },
    { label = "Univers 55", path = "EsoUI/Common/Fonts/Univers55.slug" },
    { label = "Univers 57", path = "EsoUI/Common/Fonts/Univers57.slug" },
    { label = "Univers 67", path = "EsoUI/Common/Fonts/Univers67.slug" },
    { label = "Futura Condensed Light", path = "EsoUI/Common/Fonts/FTN47.slug" },
    { label = "Futura Condensed", path = "EsoUI/Common/Fonts/FTN57.slug" },
    { label = "Futura Condensed Bold", path = "EsoUI/Common/Fonts/FTN87.slug" },
    { label = "Consolas", path = "EsoUI/Common/Fonts/Consola.slug" },
    { label = "ProseAntique", path = "EsoUI/Common/Fonts/ProseAntiquePSMT.slug" },
    { label = "Skyrim Handwritten", path = "EsoUI/Common/Fonts/Handwritten_Bold.slug" },
    { label = "Trajan Pro", path = "EsoUI/Common/Fonts/TrajanPro-Regular.slug" },
}
local SETTINGS_SUBMENU_STYLES = {
    { reference = "ZeroPanelCommandsSubmenu", hex = SETTINGS_SECTION_COMMANDS_HEX },
    { reference = "ZeroPanelAppearanceSubmenu", hex = SETTINGS_SECTION_APPEARANCE_HEX },
    { reference = "ZeroPanelKeybindDisplaySubmenu", hex = SETTINGS_SECTION_KEYBIND_DISPLAY_HEX },
    { reference = "ZeroPanelKeybindColorsSubmenu", hex = SETTINGS_SECTION_KEYBIND_COLORS_HEX },
    { reference = "ZeroPanelPanelSettingsSubmenu", hex = SETTINGS_SECTION_PANEL_HEX },
    { reference = "ZeroPanelVisibleButtonsSubmenu", hex = SETTINGS_SECTION_VISIBLE_HEX },
    { reference = "ZeroPanelAssistantSubmenu", hex = SETTINGS_SECTION_ASSISTANTS_HEX },
    { reference = "ZeroPanelAllySubmenu", hex = SETTINGS_SECTION_ALLY_HEX },
    { reference = "ZeroPanelCustomButtonsSubmenu", hex = SETTINGS_SECTION_CUSTOM_BUTTONS_HEX },
    { reference = "ZeroPanelCustomSeparatorsSubmenu", hex = SETTINGS_SECTION_CUSTOM_SEPARATORS_HEX },
    { reference = "ZeroPanelButtonOrderSubmenu", hex = SETTINGS_SECTION_ORDER_HEX },
}

local function GetZeroPanelKeybindSlotLabel(slot)
    if tonumber(slot) == ZERO_PANEL_KEYBIND_NONE_VALUE then
        return "None"
    end

    return string.format("Binding Slot %02d", tonumber(slot) or 0)
end

local function GetZeroPanelKeybindSlotShortLabel(slot)
    if tonumber(slot) == ZERO_PANEL_KEYBIND_NONE_VALUE then
        return ""
    end

    return string.format("KB %02d", tonumber(slot) or 0)
end

local function GetZeroPanelKeybindActionName(slot)
    return string.format("%s%d", ZERO_PANEL_KEYBIND_ACTION_PREFIX, tonumber(slot) or 0)
end

for keybindSlot = 1, ZERO_PANEL_KEYBIND_SLOT_COUNT do
    ZERO_PANEL_KEYBIND_SLOT_CHOICES[#ZERO_PANEL_KEYBIND_SLOT_CHOICES + 1] = GetZeroPanelKeybindSlotLabel(keybindSlot)
    ZERO_PANEL_KEYBIND_SLOT_VALUES[#ZERO_PANEL_KEYBIND_SLOT_VALUES + 1] = keybindSlot
end

local DEFAULTS = {
    enabled = true,
    showOnlyWhenReticleHidden = true,
    showInHudUI = false,
    showSummonableCollectibleIcons = true,
    iconDesaturation = 0,
    locked = true,
    maxVisibleButtons = 24,
    edge = "left",
    layoutDirection = "vertical",
    buttonsPerLine = 1,
    offsetX = 12,
    offsetY = 220,
    buttonSize = 34,
    spacing = 4,
    padding = 6,
    backgroundAlpha = 72,
    buttons = {
        settings = true,
        reloadui = true,
        cycle_group_role = true,
        toggle_group_difficulty = true,
        dismiss_combat_pets = true,
        summon_banker = true,
        summon_trader = true,
        summon_smuggler = true,
        summon_armorer = true,
        summon_ragpicker = true,
        summon_ally = true,
    },
    collectibleChoices = {
        summon_banker = 0,
        summon_trader = 0,
        summon_smuggler = 0,
        summon_armorer = 0,
        summon_ragpicker = 0,
        summon_ally = -1,
    },
    customButtons = {},
    customSeparators = {},
    keybindAssignments = {},
    keybindPickerPromptPosition = {
        useSavedAnchor = false,
    },
    keybindDisplay = {
        enabled = false,
        anchorPoint = DEFAULT_KEYBIND_DISPLAY_ANCHOR_POINT,
        offsetX = DEFAULT_KEYBIND_OFFSET_X,
        offsetY = DEFAULT_KEYBIND_OFFSET_Y,
        fontPath = DEFAULT_KEYBIND_FONT_PATH,
        fontSize = DEFAULT_KEYBIND_FONT_SIZE,
        fontEffect = DEFAULT_KEYBIND_FONT_EFFECT,
        textColor = {0.46, 0.98, 0.84, 1},
        showBackground = false,
        showBackgroundBorder = true,
        backgroundColor = {0.03, 0.05, 0.08, 1},
        backgroundOpacity = DEFAULT_KEYBIND_BACKGROUND_OPACITY,
        colorizeModifiers = false,
        modifierColors = {
            ctrl = {0.95, 0.47, 0.42, 1},
            shift = {0.97, 0.84, 0.37, 1},
            alt = {0.45, 0.77, 1.00, 1},
            command = {0.78, 0.63, 1.00, 1},
        },
    },
    nextCustomButtonId = 1,
    nextCustomSeparatorId = 1,
    order = {
        101,
        102,
        103,
        104,
        105,
        106,
        107,
        108,
        109,
        110,
        111,
    },
}

local COLOR_READY = {0.92, 0.88, 0.78, 1}
local COLOR_ACTIVE = {1.00, 0.82, 0.36, 1}
local COLOR_DISABLED = {0.36, 0.37, 0.42, 1}
local BORDER_LOCKED = {0, 0, 0, 0}
local BORDER_UNLOCKED = {0.44, 0.16, 0.16, 1}
local DIVIDER_COLOR = {0.50, 0.20, 0.20, 0.78}
local DIVIDER_LAYOUT_HEIGHT = 8
local DIVIDER_LINE_HEIGHT = 2
local DEFAULT_COLLECTIBLE_CHOICE = 0
local RANDOM_COLLECTIBLE_CHOICE = -1
local ORDER_ENTRY_FIXED_HEX = "A7AFBF"
local ORDER_ENTRY_REMOVABLE_HEX = "E2C56A"
local ORDER_ENTRY_STATUS_HEX = "7E8593"

local ROLE_ORDER = {
    LFG_ROLE_TANK,
    LFG_ROLE_HEAL,
    LFG_ROLE_DPS,
}

local ROLE_ICONS = {
    [LFG_ROLE_TANK] = "/esoui/art/tutorial/gamepad/gp_lfg_tank.dds",
    [LFG_ROLE_HEAL] = "/esoui/art/tutorial/gamepad/gp_lfg_healer.dds",
    [LFG_ROLE_DPS] = "/esoui/art/tutorial/gamepad/gp_lfg_dps.dds",
}

local VETERAN_ICONS = {
    [true] = "/esoui/art/lfg/gamepad/lfg_menuicon_veteranldungeon.dds",
    [false] = "/esoui/art/lfg/gamepad/lfg_menuicon_normaldungeon.dds",
}

local SUMMONABLE_ACTION_ORDER = {
    "summon_banker",
    "summon_trader",
    "summon_smuggler",
    "summon_armorer",
    "summon_ragpicker",
    "summon_ally",
}

local SUMMONABLES = {
    summon_banker = {
        ids = {267, 397, 6376, 8994, 9743, 11097, 12413, 13517},
        categoryType = COLLECTIBLE_CATEGORY_TYPE_ASSISTANT,
        useCollectibleCategoryList = true,
        requiresSpecializedCollectibleType = true,
        dropdownReference = "ZeroPanelSummonBankerSelector",
        buttonTooltip = "Summon Banker Assistant.",
        randomTooltip = "Summon Random Banker Assistant.",
        tooltipPrefix = "Summon Banker Assistant",
        choiceLabel = "Choose Banker Assistant",
        defaultChoiceLabel = "Auto First Available",
        randomChoiceLabel = "Random",
        emptyText = "No unlocked banker assistants are available.",
        randomChoice = true,
    },
    summon_trader = {
        ids = {301, 396, 6378, 8995, 9744, 11059, 12414, 13066},
        categoryType = COLLECTIBLE_CATEGORY_TYPE_ASSISTANT,
        useCollectibleCategoryList = true,
        requiresSpecializedCollectibleType = true,
        dropdownReference = "ZeroPanelSummonTraderSelector",
        buttonTooltip = "Summon Merchant Assistant.",
        randomTooltip = "Summon Random Merchant Assistant.",
        tooltipPrefix = "Summon Merchant Assistant",
        choiceLabel = "Choose Merchant Assistant",
        defaultChoiceLabel = "Auto First Available",
        randomChoiceLabel = "Random",
        emptyText = "No unlocked merchant assistants are available.",
        randomChoice = true,
    },
    summon_smuggler = {
        ids = {300},
        categoryType = COLLECTIBLE_CATEGORY_TYPE_ASSISTANT,
        useCollectibleCategoryList = true,
        requiresSpecializedCollectibleType = true,
        dropdownReference = "ZeroPanelSummonSmugglerSelector",
        buttonTooltip = "Summon Smuggler Assistant.",
        randomTooltip = "Summon Random Smuggler Assistant.",
        tooltipPrefix = "Summon Smuggler Assistant",
        choiceLabel = "Choose Smuggler Assistant",
        defaultChoiceLabel = "Auto First Available",
        randomChoiceLabel = "Random",
        emptyText = "No unlocked smuggler assistants are available.",
        randomChoice = true,
    },
    summon_armorer = {
        ids = {9745, 10618, 11876, 13518},
        categoryType = COLLECTIBLE_CATEGORY_TYPE_ASSISTANT,
        useCollectibleCategoryList = true,
        requiresSpecializedCollectibleType = true,
        dropdownReference = "ZeroPanelSummonArmorerSelector",
        buttonTooltip = "Summon Armory Assistant.",
        randomTooltip = "Summon Random Armory Assistant.",
        tooltipPrefix = "Summon Armory Assistant",
        choiceLabel = "Choose Armory Assistant",
        defaultChoiceLabel = "Auto First Available",
        randomChoiceLabel = "Random",
        emptyText = "No unlocked armory assistants are available.",
        randomChoice = true,
    },
    summon_ragpicker = {
        ids = {10184, 10617, 11877, 13063},
        categoryType = COLLECTIBLE_CATEGORY_TYPE_ASSISTANT,
        useCollectibleCategoryList = true,
        requiresSpecializedCollectibleType = true,
        dropdownReference = "ZeroPanelSummonRagpickerSelector",
        buttonTooltip = "Summon Deconstruction Assistant.",
        randomTooltip = "Summon Random Deconstruction Assistant.",
        tooltipPrefix = "Summon Deconstruction Assistant",
        choiceLabel = "Choose Deconstruction Assistant",
        defaultChoiceLabel = "Auto First Available",
        randomChoiceLabel = "Random",
        emptyText = "No unlocked deconstruction assistants are available.",
        randomChoice = true,
    },
    summon_ally = {
        ids = {9245, 9353, 9911, 9912, 11113, 11114, 12172, 12173},
        categoryType = COLLECTIBLE_CATEGORY_TYPE_COMPANION,
        useCollectibleCategoryList = true,
        dropdownReference = "ZeroPanelSummonAllySelector",
        buttonTooltip = "Summon Ally.",
        randomTooltip = "Summon Random Ally.",
        tooltipPrefix = "Summon Ally",
        choiceLabel = "Choose Ally to Summon",
        defaultChoiceLabel = "Random",
        defaultChoiceValue = RANDOM_COLLECTIBLE_CHOICE,
        emptyText = "No unlocked allies are available.",
        randomChoice = true,
    },
}

local function GetSummonableIconProvider(actionId, fallbackIcon)
    return function()
        return ZeroPanel:GetSummonableButtonIcon(actionId, fallbackIcon)
    end
end

local PET_BUFF_IDS = {
    [23304] = true,
    [23316] = true,
    [23319] = true,
    [24613] = true,
    [24636] = true,
    [24639] = true,
    [85982] = true,
    [85986] = true,
    [85990] = true,
}

local BUTTON_DEFINITIONS = {
    {
        id = "settings",
        uniqueKey = 101,
        name = "Open Settings",
        group = "utility",
        icon = "/esoui/art/guild/gamepad/gp_guild_menuicon_customization.dds",
        tooltip = function(self)
            return string.format("Open %s Settings.", self.displayName)
        end,
        click = function(self)
            self:OpenSettings()
        end,
    },
    {
        id = "reloadui",
        uniqueKey = 102,
        name = "Reload UI",
        group = "utility",
        icon = "/esoui/art/mounts/ridingskill_ready.dds",
        tooltip = function()
            return "Reload the UI."
        end,
        click = function()
            ReloadUI()
        end,
    },
    {
        id = "cycle_group_role",
        uniqueKey = 103,
        name = "Cycle Group Role",
        group = "utility",
        icon = function()
            return ROLE_ICONS[GetSelectedLFGRole()] or ROLE_ICONS[LFG_ROLE_DPS]
        end,
        tooltip = function()
            local roleName = ZeroPanel:GetRoleName(GetSelectedLFGRole())
            if not CanUpdateSelectedLFGRole() then
                return string.format("Current Role: %s. Role Changes Are Unavailable Here.", roleName)
            end
            return string.format("Cycle Group Role. Current Role: %s.", roleName)
        end,
        isActive = function()
            return CanUpdateSelectedLFGRole()
        end,
        isUsable = function()
            return CanUpdateSelectedLFGRole()
        end,
        click = function(self)
            self:CycleGroupRole()
        end,
    },
    {
        id = "toggle_group_difficulty",
        uniqueKey = 104,
        name = "Toggle Dungeon Difficulty",
        group = "utility",
        icon = function()
            return VETERAN_ICONS[ZeroPanel:IsVeteranDungeonDifficulty()]
        end,
        tooltip = function()
            local difficultyName = ZeroPanel:GetDungeonDifficultyName()
            if not CanPlayerChangeGroupDifficulty() then
                return string.format("Current Difficulty: %s. Changes Are Unavailable Here.", difficultyName)
            end
            return string.format("Toggle Dungeon Difficulty. Current: %s.", difficultyName)
        end,
        isActive = function()
            return ZeroPanel:IsVeteranDungeonDifficulty()
        end,
        isUsable = function()
            return CanPlayerChangeGroupDifficulty()
        end,
        click = function(self)
            self:ToggleGroupDifficulty()
        end,
    },
    {
        id = "dismiss_combat_pets",
        uniqueKey = 105,
        name = "Dismiss Combat Pets",
        group = "utility",
        icon = "/esoui/art/treeicons/gamepad/gp_store_indexicon_vanitypets.dds",
        tooltip = function()
            return "Dismiss Active Combat Pets."
        end,
        isUsable = function()
            return ZeroPanel:HasDismissablePet()
        end,
        click = function(self)
            self:DismissCombatPets()
        end,
    },
    {
        id = "summon_banker",
        uniqueKey = 106,
        name = "Summon Banker",
        group = "assistants",
        collectibleActionId = "summon_banker",
        hideWhenUnavailable = true,
        icon = GetSummonableIconProvider("summon_banker", "/esoui/art/icons/mapkey/mapkey_bank.dds"),
        tooltip = function(self)
            return self:GetSummonTooltip("summon_banker")
        end,
        isUsable = function()
            return ZeroPanel:GetSelectedCollectibleId("summon_banker") ~= nil
        end,
        click = function(self)
            self:UseConfiguredCollectible("summon_banker")
        end,
    },
    {
        id = "summon_trader",
        uniqueKey = 107,
        name = "Summon Merchant",
        group = "assistants",
        collectibleActionId = "summon_trader",
        hideWhenUnavailable = true,
        icon = GetSummonableIconProvider("summon_trader", "/esoui/art/mail/gamepad/gp_mailmenu_attachitem.dds"),
        tooltip = function(self)
            return self:GetSummonTooltip("summon_trader")
        end,
        isUsable = function()
            return ZeroPanel:GetSelectedCollectibleId("summon_trader") ~= nil
        end,
        click = function(self)
            self:UseConfiguredCollectible("summon_trader")
        end,
    },
    {
        id = "summon_smuggler",
        uniqueKey = 108,
        name = "Summon Smuggler",
        group = "assistants",
        collectibleActionId = "summon_smuggler",
        hideWhenUnavailable = true,
        icon = GetSummonableIconProvider("summon_smuggler", "/esoui/art/icons/mapkey/mapkey_fence.dds"),
        tooltip = function(self)
            return self:GetSummonTooltip("summon_smuggler")
        end,
        isUsable = function()
            return ZeroPanel:GetSelectedCollectibleId("summon_smuggler") ~= nil
        end,
        click = function(self)
            self:UseConfiguredCollectible("summon_smuggler")
        end,
    },
    {
        id = "summon_armorer",
        uniqueKey = 109,
        name = "Summon Armorer",
        group = "assistants",
        collectibleActionId = "summon_armorer",
        hideWhenUnavailable = true,
        icon = GetSummonableIconProvider("summon_armorer", "/esoui/art/treeicons/gamepad/gp_collectionicon_weapona+armor.dds"),
        tooltip = function(self)
            return self:GetSummonTooltip("summon_armorer")
        end,
        isUsable = function()
            return ZeroPanel:GetSelectedCollectibleId("summon_armorer") ~= nil
        end,
        click = function(self)
            self:UseConfiguredCollectible("summon_armorer")
        end,
    },
    {
        id = "summon_ragpicker",
        uniqueKey = 110,
        name = "Summon Ragpicker",
        group = "assistants",
        collectibleActionId = "summon_ragpicker",
        hideWhenUnavailable = true,
        icon = GetSummonableIconProvider("summon_ragpicker", "/esoui/art/crafting/gamepad/gp_crafting_menuicon_deconstruct.dds"),
        tooltip = function(self)
            return self:GetSummonTooltip("summon_ragpicker")
        end,
        isUsable = function()
            return ZeroPanel:GetSelectedCollectibleId("summon_ragpicker") ~= nil
        end,
        click = function(self)
            self:UseConfiguredCollectible("summon_ragpicker")
        end,
    },
    {
        id = "summon_ally",
        uniqueKey = 111,
        name = "Summon Ally",
        group = "allies",
        collectibleActionId = "summon_ally",
        hideWhenUnavailable = true,
        icon = GetSummonableIconProvider("summon_ally", "/esoui/art/inventory/inventory_tabicon_companion_up.dds"),
        tooltip = function(self)
            return self:GetSummonTooltip("summon_ally")
        end,
        isUsable = function()
            return ZeroPanel:GetSelectedCollectibleId("summon_ally") ~= nil
        end,
        click = function(self)
            self:UseConfiguredCollectible("summon_ally")
        end,
    },
}

local DEFAULT_LAYOUT_ORDER = {
    "button:101",
    "button:102",
    "button:103",
    "button:104",
    "button:105",
    "separator:utility_assistants",
    "button:106",
    "button:107",
    "button:108",
    "button:109",
    "button:110",
    "separator:assistants_allies",
    "button:111",
}

local DEFAULT_SEPARATOR_DEFINITIONS = {
    {
        key = "separator:utility_assistants",
        orderUniqueKey = 1001,
        name = "Separator: Utility / Assistants",
        tooltip = "Separates the utility buttons from the assistant buttons.",
    },
    {
        key = "separator:assistants_allies",
        orderUniqueKey = 1002,
        name = "Separator: Assistants / Allies",
        tooltip = "Separates the assistant buttons from the ally buttons.",
    },
}

local CUSTOM_BUTTON_ORDER_KEY_BASE = 300000
local CUSTOM_SEPARATOR_ORDER_KEY_BASE = 400000

local CUSTOM_BUTTON_ACTIONS = {
    command = {
        name = "Custom Command",
        icon = "/esoui/art/tutorial/chat-notifications_up.dds",
    },
    open_settings = {
        name = "Open Zero Panel Settings",
        icon = "/esoui/art/guild/gamepad/gp_guild_menuicon_customization.dds",
        tooltip = "Open Zero Panel Settings.",
    },
    reload_ui = {
        name = "Reload UI",
        icon = "/esoui/art/mounts/ridingskill_ready.dds",
        tooltip = "Reload UI.",
    },
    cycle_group_role = {
        name = "Cycle Group Role",
        icon = function()
            return ROLE_ICONS[GetSelectedLFGRole()] or ROLE_ICONS[LFG_ROLE_DPS]
        end,
    },
    toggle_group_difficulty = {
        name = "Toggle Dungeon Difficulty",
        icon = function()
            return VETERAN_ICONS[ZeroPanel:IsVeteranDungeonDifficulty()]
        end,
    },
    dismiss_combat_pets = {
        name = "Dismiss Active Combat Pets",
        icon = "/esoui/art/treeicons/gamepad/gp_store_indexicon_vanitypets.dds",
        tooltip = "Dismiss Active Combat Pets.",
    },
    summon_banker = {
        name = "Summon Banker Assistant",
        icon = "/esoui/art/icons/mapkey/mapkey_bank.dds",
    },
    summon_trader = {
        name = "Summon Merchant Assistant",
        icon = "/esoui/art/mail/gamepad/gp_mailmenu_attachitem.dds",
    },
    summon_smuggler = {
        name = "Summon Smuggler Assistant",
        icon = "/esoui/art/icons/mapkey/mapkey_fence.dds",
    },
    summon_armorer = {
        name = "Summon Armory Assistant",
        icon = "/esoui/art/treeicons/gamepad/gp_collectionicon_weapona+armor.dds",
    },
    summon_ragpicker = {
        name = "Summon Deconstruction Assistant",
        icon = "/esoui/art/crafting/gamepad/gp_crafting_menuicon_deconstruct.dds",
    },
    summon_ally = {
        name = "Summon Ally",
        icon = "/esoui/art/inventory/inventory_tabicon_companion_up.dds",
    },
}

local CUSTOM_BUTTON_ACTION_CHOICES = {
    {"Custom Command", "command"},
    {"Open Zero Panel Settings", "open_settings"},
    {"Reload UI", "reload_ui"},
    {"Cycle Group Role", "cycle_group_role"},
    {"Toggle Dungeon Difficulty", "toggle_group_difficulty"},
    {"Dismiss Active Combat Pets", "dismiss_combat_pets"},
    {"Summon Banker Assistant", "summon_banker"},
    {"Summon Merchant Assistant", "summon_trader"},
    {"Summon Smuggler Assistant", "summon_smuggler"},
    {"Summon Armory Assistant", "summon_armorer"},
    {"Summon Deconstruction Assistant", "summon_ragpicker"},
    {"Summon Ally", "summon_ally"},
}

local CUSTOM_BUTTON_ACTION_NAMES = {}
local CUSTOM_BUTTON_ACTION_VALUES = {}
for _, entry in ipairs(CUSTOM_BUTTON_ACTION_CHOICES) do
    CUSTOM_BUTTON_ACTION_NAMES[#CUSTOM_BUTTON_ACTION_NAMES + 1] = entry[1]
    CUSTOM_BUTTON_ACTION_VALUES[#CUSTOM_BUTTON_ACTION_VALUES + 1] = entry[2]
end

local CUSTOM_BUTTON_PRESETS = {
    {
        id = "open_settings",
        name = "Open Zero Panel Settings",
        tooltip = "Create a button that opens Zero Panel settings.",
        actionType = "open_settings",
    },
    {
        id = "reload_ui",
        name = "Reload UI",
        tooltip = "Create a button that reloads the UI.",
        actionType = "reload_ui",
    },
    {
        id = "cycle_group_role",
        name = "Cycle Group Role",
        tooltip = "Create a button that cycles tank, healer, and damage roles.",
        actionType = "cycle_group_role",
    },
    {
        id = "toggle_group_difficulty",
        name = "Toggle Dungeon Difficulty",
        tooltip = "Create a button that toggles normal and veteran dungeon difficulty.",
        actionType = "toggle_group_difficulty",
    },
    {
        id = "dismiss_combat_pets",
        name = "Dismiss Active Combat Pets",
        tooltip = "Create a button that dismisses active combat pets.",
        actionType = "dismiss_combat_pets",
    },
    {
        id = "summon_banker",
        name = "Summon Banker Assistant",
        tooltip = "Create a button that summons your selected banker assistant.",
        actionType = "summon_banker",
    },
    {
        id = "summon_trader",
        name = "Summon Merchant Assistant",
        tooltip = "Create a button that summons your selected merchant assistant.",
        actionType = "summon_trader",
    },
    {
        id = "summon_smuggler",
        name = "Summon Smuggler Assistant",
        tooltip = "Create a button that summons your selected smuggler assistant.",
        actionType = "summon_smuggler",
    },
    {
        id = "summon_armorer",
        name = "Summon Armory Assistant",
        tooltip = "Create a button that summons your selected armory assistant.",
        actionType = "summon_armorer",
    },
    {
        id = "summon_ragpicker",
        name = "Summon Deconstruction Assistant",
        tooltip = "Create a button that summons your selected deconstruction assistant.",
        actionType = "summon_ragpicker",
    },
    {
        id = "summon_ally",
        name = "Summon Ally",
        tooltip = "Create a button that summons your selected ally.",
        actionType = "summon_ally",
    },
    {
        id = "toggle_compass",
        name = "Toggle Compass",
        tooltip = "Create a button that toggles the world compass.",
        actionType = "command",
        icon = "/esoui/art/icons/ability_rogue_062.dds",
        command = "/script ZO_CompassFrame:SetHidden(not ZO_CompassFrame:IsHidden())",
    },
    {
        id = "jump_to_leader",
        name = "Jump To Group Leader",
        tooltip = "Create a button that uses the jump-to-leader slash command.",
        actionType = "command",
        icon = "/esoui/art/tutorial/gamepad/gp_playermenu_icon_store.dds",
        command = "/jumptoleader",
    },
    {
        id = "whisper_target",
        name = "Whisper Current Target",
        tooltip = "Create a button that opens a whisper to your current target.",
        actionType = "command",
        icon = "/esoui/art/tutorial/chat-notifications_up.dds",
        command = "/script zo_callLater(function() local name = GetUnitDisplayName('reticleover') if name and name ~= '' then StartChatInput('/w '..name..' ') else d('No target') end end, 100)",
    },
}

local CUSTOM_BUTTON_PRESET_NAMES = {}
local CUSTOM_BUTTON_PRESET_VALUES = {}
local CUSTOM_BUTTON_PRESET_TOOLTIPS = {}
for _, entry in ipairs(CUSTOM_BUTTON_PRESETS) do
    CUSTOM_BUTTON_PRESET_NAMES[#CUSTOM_BUTTON_PRESET_NAMES + 1] = entry.name
    CUSTOM_BUTTON_PRESET_VALUES[#CUSTOM_BUTTON_PRESET_VALUES + 1] = entry.id
    CUSTOM_BUTTON_PRESET_TOOLTIPS[#CUSTOM_BUTTON_PRESET_TOOLTIPS + 1] = entry.tooltip
end

local COLLECTIBLE_BROWSER_STATUS_KEYS = {
    "all",
    "unlocked",
    "locked",
    "active",
}

local COLLECTIBLE_BROWSER_STATUS_NAMES = {
    "All Collectibles",
    "Unlocked Only",
    "Locked Only",
    "Active Only",
}

local COLLECTIBLE_BROWSER_CATEGORY_GLOBAL_NAMES = {
    "COLLECTIBLE_CATEGORY_TYPE_ASSISTANT",
    "COLLECTIBLE_CATEGORY_TYPE_COMPANION",
    "COLLECTIBLE_CATEGORY_TYPE_COSTUME",
    "COLLECTIBLE_CATEGORY_TYPE_EMOTE",
    "COLLECTIBLE_CATEGORY_TYPE_HAT",
    "COLLECTIBLE_CATEGORY_TYPE_HAIR",
    "COLLECTIBLE_CATEGORY_TYPE_FACIAL_HAIR_HORNS",
    "COLLECTIBLE_CATEGORY_TYPE_FACIAL_ACCESSORY",
    "COLLECTIBLE_CATEGORY_TYPE_HEAD_MARKING",
    "COLLECTIBLE_CATEGORY_TYPE_BODY_MARKING",
    "COLLECTIBLE_CATEGORY_TYPE_PIERCING_JEWELRY",
    "COLLECTIBLE_CATEGORY_TYPE_SKIN",
    "COLLECTIBLE_CATEGORY_TYPE_POLYMORPH",
    "COLLECTIBLE_CATEGORY_TYPE_PERSONALITY",
    "COLLECTIBLE_CATEGORY_TYPE_ABILITY_SKIN",
    "COLLECTIBLE_CATEGORY_TYPE_PLAYER_FX_OVERRIDE",
    "COLLECTIBLE_CATEGORY_TYPE_MEMENTO",
    "COLLECTIBLE_CATEGORY_TYPE_MOUNT",
    "COLLECTIBLE_CATEGORY_TYPE_VANITY_PET",
    "COLLECTIBLE_CATEGORY_TYPE_TRIBUTE_PATRON",
    "COLLECTIBLE_CATEGORY_TYPE_OUTFIT_STYLE",
    "COLLECTIBLE_CATEGORY_TYPE_HOUSE",
    "COLLECTIBLE_CATEGORY_TYPE_HOUSE_BANK",
    "COLLECTIBLE_CATEGORY_TYPE_FURNITURE",
    "COLLECTIBLE_CATEGORY_TYPE_COMBINATION_FRAGMENT",
    "COLLECTIBLE_CATEGORY_TYPE_DLC",
    "COLLECTIBLE_CATEGORY_TYPE_CHAPTER",
    "COLLECTIBLE_CATEGORY_TYPE_ACCOUNT_SERVICE",
    "COLLECTIBLE_CATEGORY_TYPE_ACCOUNT_UPGRADE",
}

local POPUP_BROWSER_PAGE_SIZE_VALUES = {4, 6, 8}
local POPUP_BROWSER_PAGE_SIZE_ENTRIES = {
    { label = "4 per page", value = 4 },
    { label = "6 per page", value = 6 },
    { label = "8 per page", value = 8 },
}
local POPUP_BROWSER_MAX_ROWS = POPUP_BROWSER_PAGE_SIZE_VALUES[#POPUP_BROWSER_PAGE_SIZE_VALUES]
local POPUP_BROWSER_ROW_HEIGHT = 36
local POPUP_BROWSER_ROW_GAP = 4

local COMMAND_FRIENDLY_TITLES = {
    ["/reloadui"] = "Reload UI.",
    ["/rl"] = "Reload UI.",
    ["/zp"] = "Open Zero Panel Settings.",
    ["/zkb"] = "Activate Zero Panel Keybind Mode.",
    ["/zb"] = "Open Zero Bar Settings.",
    ["/jumptoleader"] = "Jump To Group Leader.",
}

local COMMAND_ICON_OVERRIDES = {
    ["/reloadui"] = "/esoui/art/mounts/ridingskill_ready.dds",
    ["/rl"] = "/esoui/art/mounts/ridingskill_ready.dds",
    ["/zp"] = "/esoui/art/guild/gamepad/gp_guild_menuicon_customization.dds",
    ["/zb"] = "/esoui/art/guild/gamepad/gp_guild_menuicon_customization.dds",
    ["/jumptoleader"] = "/esoui/art/tutorial/gamepad/gp_playermenu_icon_store.dds",
}

local SLASH_COMMAND_HELP_ENTRIES = {
    {
        command = "/zp",
        description = "Open Zero Panel settings.",
    },
    {
        command = "/zkb",
        description = "Activate Keybind Mode so you can click Zero Panel buttons and bind them.",
    },
    {
        command = "/zp unlock",
        description = "Unlock the panel so it can be dragged to a new screen-edge position.",
    },
    {
        command = "/zp lock",
        description = "Lock the panel in place after you finish moving it.",
    },
    {
        command = "/zp reset",
        description = "Reset the panel position back to the default anchor.",
    },
}

local function TrimText(value)
    value = tostring(value or "")
    return value:match("^%s*(.-)%s*$")
end

local function NormalizeBrowserText(value)
    return string.lower(TrimText(value))
end

local function OpenUnsafeUrl(url)
    if type(RequestOpenUnsafeURL) == "function" then
        RequestOpenUnsafeURL(url)
    end
end

local function OnSupportLinkClicked(_, _, _, button)
    if button == MOUSE_BUTTON_INDEX_LEFT then
        OpenUnsafeUrl(ZERO_PANEL_GITHUB_ISSUES_URL)
    end
end

local function AddUniqueValue(list, seen, value)
    if value ~= nil and not seen[value] then
        seen[value] = true
        list[#list + 1] = value
    end
end

local function GetDefaultButtonLayoutKey(uniqueKey)
    return string.format("button:%s", tostring(uniqueKey))
end

local function GetCustomButtonLayoutKey(customButtonId)
    return string.format("custom_button:%s", tostring(customButtonId))
end

local function GetCustomSeparatorLayoutKey(customSeparatorId)
    return string.format("custom_separator:%s", tostring(customSeparatorId))
end

local function GetCustomButtonOrderUniqueKey(customButtonId)
    return CUSTOM_BUTTON_ORDER_KEY_BASE + tonumber(customButtonId or 0)
end

local function GetCustomSeparatorOrderUniqueKey(customSeparatorId)
    return CUSTOM_SEPARATOR_ORDER_KEY_BASE + tonumber(customSeparatorId or 0)
end

local function GetSortedNumericKeys(values)
    local keys = {}

    for key in pairs(values or {}) do
        if type(key) == "number" then
            keys[#keys + 1] = key
        end
    end

    table.sort(keys)
    return keys
end

local function GetCustomButtonPresetById(presetId)
    for _, preset in ipairs(CUSTOM_BUTTON_PRESETS) do
        if preset.id == presetId then
            return preset
        end
    end

    return nil
end

local function ClampNumber(value, minValue, maxValue)
    value = tonumber(value) or minValue
    if maxValue < minValue then
        return minValue
    end
    if value < minValue then
        return minValue
    end
    if value > maxValue then
        return maxValue
    end
    return value
end

local function NormalizeFontPath(fontPath)
    if type(fontPath) ~= "string" or fontPath == "" then
        return fontPath
    end

    local strippedPath = fontPath:match("^(.-)|%d+|[^|]*$")
    if strippedPath and strippedPath ~= "" then
        return strippedPath
    end

    strippedPath = fontPath:match("^(.-)|%d+|?$")
    if strippedPath and strippedPath ~= "" then
        return strippedPath
    end

    return fontPath
end

local function GetFontIdentity(fontPath)
    local normalizedFontPath = NormalizeFontPath(fontPath)
    if type(normalizedFontPath) ~= "string" or normalizedFontPath == "" then
        return normalizedFontPath
    end

    local identity = normalizedFontPath:gsub("\\", "/"):gsub("^/+", "")
    identity = string.lower(identity)
    identity = identity:gsub("%.otf$", ".slug")
    identity = identity:gsub("%.ttf$", ".slug")

    return identity
end

local function IsValidKeybindFontEffect(fontEffect)
    if type(fontEffect) ~= "string" or fontEffect == "" then
        return false
    end

    if fontEffect == "normal" then
        fontEffect = "none"
    end

    for _, entry in ipairs(KEYBIND_FONT_EFFECT_CHOICES) do
        if entry.value == fontEffect then
            return true
        end
    end

    return false
end

local function GetResolvedKeybindFontEffect(fontEffect)
    if fontEffect == "normal" then
        fontEffect = "none"
    end

    if IsValidKeybindFontEffect(fontEffect) then
        return fontEffect
    end

    return DEFAULT_KEYBIND_FONT_EFFECT
end

local function GetPrimaryKeybindFontEffect(fontEffect)
    local resolvedFontEffect = GetResolvedKeybindFontEffect(fontEffect)
    if resolvedFontEffect == "outline-shadow" then
        return "outline"
    elseif resolvedFontEffect == "thick-outline-shadow" then
        return "thick-outline"
    end

    return resolvedFontEffect
end

local function ShouldUseKeybindShadowOverlay(fontEffect)
    local resolvedFontEffect = GetResolvedKeybindFontEffect(fontEffect)
    return resolvedFontEffect == "outline-shadow" or resolvedFontEffect == "thick-outline-shadow"
end

local function NormalizeKeybindAnchorPoint(anchorPoint)
    local resolvedAnchorPoint = tostring(anchorPoint or ""):upper()
    for _, candidate in ipairs(KEYBIND_DISPLAY_ANCHOR_VALUES) do
        if candidate == resolvedAnchorPoint then
            return candidate
        end
    end

    return DEFAULT_KEYBIND_DISPLAY_ANCHOR_POINT
end

local function GetKeybindAnchorConstant(anchorPoint)
    return _G[NormalizeKeybindAnchorPoint(anchorPoint)] or TOPRIGHT
end

local function GetKeybindAnchorPair(anchorPoint)
    local resolvedAnchorPoint = NormalizeKeybindAnchorPoint(anchorPoint)
    local hasTop = string.find(resolvedAnchorPoint, "TOP", 1, true) ~= nil
    local hasBottom = string.find(resolvedAnchorPoint, "BOTTOM", 1, true) ~= nil
    local hasLeft = string.find(resolvedAnchorPoint, "LEFT", 1, true) ~= nil
    local hasRight = string.find(resolvedAnchorPoint, "RIGHT", 1, true) ~= nil

    if hasTop then
        if hasLeft then
            return BOTTOMLEFT, TOPLEFT
        elseif hasRight then
            return BOTTOMRIGHT, TOPRIGHT
        end

        return BOTTOM, TOP
    elseif hasBottom then
        if hasLeft then
            return TOPLEFT, BOTTOMLEFT
        elseif hasRight then
            return TOPRIGHT, BOTTOMRIGHT
        end

        return TOP, BOTTOM
    elseif resolvedAnchorPoint == "LEFT" then
        return RIGHT, LEFT
    elseif resolvedAnchorPoint == "RIGHT" then
        return LEFT, RIGHT
    end

    local anchorConstant = GetKeybindAnchorConstant(resolvedAnchorPoint)
    return anchorConstant, anchorConstant
end

local function GetKeybindAnchorOffsets(anchorPoint, offsetX, offsetY)
    local resolvedAnchorPoint = NormalizeKeybindAnchorPoint(anchorPoint)
    local resolvedOffsetX = tonumber(offsetX) or DEFAULT_KEYBIND_OFFSET_X
    local resolvedOffsetY = tonumber(offsetY) or DEFAULT_KEYBIND_OFFSET_Y

    if string.find(resolvedAnchorPoint, "TOP", 1, true) then
        resolvedOffsetY = resolvedOffsetY - 2
    elseif string.find(resolvedAnchorPoint, "BOTTOM", 1, true) then
        resolvedOffsetY = resolvedOffsetY + 2
    elseif resolvedAnchorPoint == "LEFT" then
        resolvedOffsetX = resolvedOffsetX - 2
    elseif resolvedAnchorPoint == "RIGHT" then
        resolvedOffsetX = resolvedOffsetX + 2
    end

    return resolvedOffsetX, resolvedOffsetY
end

local function GetKeybindHorizontalAlignment(anchorPoint)
    local resolvedAnchorPoint = NormalizeKeybindAnchorPoint(anchorPoint)
    if resolvedAnchorPoint == "LEFT" then
        return TEXT_ALIGN_RIGHT
    elseif resolvedAnchorPoint == "RIGHT" then
        return TEXT_ALIGN_LEFT
    elseif string.find(resolvedAnchorPoint, "LEFT", 1, true) then
        return TEXT_ALIGN_LEFT
    elseif string.find(resolvedAnchorPoint, "RIGHT", 1, true) then
        return TEXT_ALIGN_RIGHT
    end

    return TEXT_ALIGN_CENTER
end

local function GetKeybindVerticalAlignment(anchorPoint)
    local resolvedAnchorPoint = NormalizeKeybindAnchorPoint(anchorPoint)
    if string.find(resolvedAnchorPoint, "TOP", 1, true) then
        return TEXT_ALIGN_BOTTOM
    elseif string.find(resolvedAnchorPoint, "BOTTOM", 1, true) then
        return TEXT_ALIGN_TOP
    end

    return TEXT_ALIGN_CENTER
end

local function BuildKeybindFontDescriptor(fontPath, fontSize, fontEffect)
    local resolvedFontPath = NormalizeFontPath(fontPath)
    if type(resolvedFontPath) ~= "string" or resolvedFontPath == "" then
        resolvedFontPath = DEFAULT_KEYBIND_FONT_PATH
    end

    local resolvedFontSize = math.floor(tonumber(fontSize) or DEFAULT_KEYBIND_FONT_SIZE)
    resolvedFontSize = ClampNumber(resolvedFontSize, 8, 36)

    local resolvedFontEffect = GetPrimaryKeybindFontEffect(fontEffect)
    if resolvedFontEffect == "none" or resolvedFontEffect == "" then
        return string.format("%s|%d", resolvedFontPath, resolvedFontSize)
    end

    return string.format("%s|%d|%s", resolvedFontPath, resolvedFontSize, resolvedFontEffect)
end

local function BuildKeybindFontChoices(savedVars)
    local entries = {}
    local labels = {}
    local values = {}
    local seen = {}

    local function addChoice(label, value)
        local normalizedValue = NormalizeFontPath(value)
        local fontIdentity = GetFontIdentity(normalizedValue)
        if type(normalizedValue) ~= "string" or normalizedValue == "" or type(fontIdentity) ~= "string" or fontIdentity == "" or seen[fontIdentity] then
            return
        end

        seen[fontIdentity] = true
        entries[#entries + 1] = {
            label = tostring(label),
            value = normalizedValue,
        }
    end

    for _, fontEntry in ipairs(BUILTIN_KEYBIND_FONTS) do
        addChoice(fontEntry.label, fontEntry.path)
    end

    if LibFonts and type(LibFonts.FontStyle) == "table" then
        local libFontsEntries = {}
        for _, fontStyle in pairs(LibFonts.FontStyle) do
            libFontsEntries[#libFontsEntries + 1] = fontStyle
        end

        table.sort(libFontsEntries, function(left, right)
            local leftLabel = tostring((left and (left.name or left.friendlyName)) or "")
            local rightLabel = tostring((right and (right.name or right.friendlyName)) or "")
            return string.lower(leftLabel) < string.lower(rightLabel)
        end)

        for _, fontStyle in ipairs(libFontsEntries) do
            addChoice((fontStyle and (fontStyle.name or fontStyle.friendlyName)) or "LibFonts Font", fontStyle and fontStyle.path)
        end
    end

    if LibMediaProvider and type(LibMediaProvider.List) == "function" and type(LibMediaProvider.Fetch) == "function" then
        local mediaType = LibMediaProvider.MediaType and LibMediaProvider.MediaType.FONT or "font"
        local fontNames = LibMediaProvider:List(mediaType) or {}
        table.sort(fontNames, function(left, right)
            return string.lower(tostring(left)) < string.lower(tostring(right))
        end)

        for _, fontName in ipairs(fontNames) do
            addChoice(fontName, LibMediaProvider:Fetch(mediaType, fontName))
        end
    end

    if savedVars and savedVars.keybindDisplay then
        addChoice("Current Keybind Font", savedVars.keybindDisplay.fontPath)
    end

    addChoice("ESO Default", DEFAULT_KEYBIND_FONT_PATH)

    table.sort(entries, function(left, right)
        local leftLabel = string.lower(tostring((left and left.label) or ""))
        local rightLabel = string.lower(tostring((right and right.label) or ""))
        if leftLabel == rightLabel then
            local leftValue = string.lower(tostring((left and left.value) or ""))
            local rightValue = string.lower(tostring((right and right.value) or ""))
            return leftValue < rightValue
        end

        return leftLabel < rightLabel
    end)

    for _, entry in ipairs(entries) do
        labels[#labels + 1] = entry.label
        values[#values + 1] = entry.value
    end

    return labels, values
end

local function IsBoundKeyCode(keyCode)
    return keyCode ~= nil and keyCode ~= 0 and keyCode ~= KEY_INVALID
end

local function GetKeyCodeDisplayName(keyCode)
    if not IsBoundKeyCode(keyCode) then
        return ""
    end

    local keyName = ""
    if type(GetKeyName) == "function" then
        keyName = tostring(GetKeyName(keyCode) or "")
    end

    if keyName == "" and type(GetString) == "function" then
        local ok, value = pcall(GetString, "SI_KEYCODE", keyCode)
        if ok and type(value) == "string" then
            keyName = value
        end
    end

    keyName = TrimText(keyName)
    if keyName == "" or string.find(keyName, "SI_KEYCODE", 1, true) then
        keyName = tostring(keyCode)
    end

    return keyName
end

local KEYBIND_KEY_NAME_ABBREVIATIONS = {
    ["BACKSPACE"] = "Bksp",
    ["CAPS LOCK"] = "Caps",
    ["DELETE"] = "Del",
    ["END"] = "End",
    ["ENTER"] = "Ent",
    ["ESCAPE"] = "Esc",
    ["HOME"] = "Home",
    ["INSERT"] = "Ins",
    ["LEFT MOUSE BUTTON"] = "M1",
    ["MIDDLE MOUSE BUTTON"] = "M3",
    ["MOUSE BUTTON 1"] = "M1",
    ["MOUSE BUTTON 2"] = "M2",
    ["MOUSE BUTTON 3"] = "M3",
    ["MOUSE BUTTON 4"] = "M4",
    ["MOUSE BUTTON 5"] = "M5",
    ["MOUSE WHEEL DOWN"] = "MWD",
    ["MOUSE WHEEL UP"] = "MWU",
    ["PAGE DOWN"] = "PgDn",
    ["PAGE UP"] = "PgUp",
    ["PRINT SCREEN"] = "PrtSc",
    ["RETURN"] = "Ent",
    ["RIGHT MOUSE BUTTON"] = "M2",
    ["SCROLL LOCK"] = "ScrLk",
    ["SPACE"] = "Spc",
    ["TAB"] = "Tab",
}

local function NormalizeKeybindKeyName(keyName)
    local normalizedName = tostring(keyName or "")
    normalizedName = normalizedName:gsub("^SI_KEYCODE[_%s]*", "")
    normalizedName = normalizedName:gsub("^KEY[_%s]*", "")
    normalizedName = normalizedName:gsub("_", " ")
    normalizedName = normalizedName:gsub("%s+", " ")
    normalizedName = TrimText(normalizedName)

    return normalizedName
end

local function GetVerboseKeybindKeyName(keyName)
    local normalizedName = NormalizeKeybindKeyName(keyName)
    if normalizedName == "" then
        return ""
    end

    return string.upper(normalizedName)
end

local function AbbreviateKeybindKeyName(keyName)
    local normalizedName = NormalizeKeybindKeyName(keyName)
    if normalizedName == "" then
        return ""
    end

    local upperName = string.upper(normalizedName)
    if KEYBIND_KEY_NAME_ABBREVIATIONS[upperName] then
        return KEYBIND_KEY_NAME_ABBREVIATIONS[upperName]
    end

    local numberPadDigit = upperName:match("^NUM ?PAD (%d)$") or upperName:match("^NUMPAD (%d)$")
    if numberPadDigit then
        return "N" .. numberPadDigit
    end

    local numberPadSymbol = upperName:match("^NUM ?PAD ([%+%-%*/])$") or upperName:match("^NUMPAD ([%+%-%*/])$")
    if numberPadSymbol then
        return "N" .. numberPadSymbol
    end

    if upperName == "NUMPAD DECIMAL" or upperName == "NUM PAD DECIMAL" then
        return "N."
    end

    local functionKey = upperName:match("^(F%d+)$")
    if functionKey then
        return functionKey
    end

    if upperName:match("^[A-Z]$") or upperName:match("^%d$") then
        return upperName
    end

    if upperName == "ARROW UP" or upperName == "UP ARROW" then
        return "Up"
    elseif upperName == "ARROW DOWN" or upperName == "DOWN ARROW" then
        return "Dn"
    elseif upperName == "ARROW LEFT" or upperName == "LEFT ARROW" then
        return "Left"
    elseif upperName == "ARROW RIGHT" or upperName == "RIGHT ARROW" then
        return "Right"
    end

    local punctuation = {
        ["APOSTROPHE"] = "'",
        ["BACKSLASH"] = "\\",
        ["COMMA"] = ",",
        ["EQUALS"] = "=",
        ["GRAVE"] = "`",
        ["MINUS"] = "-",
        ["PERIOD"] = ".",
        ["PLUS"] = "+",
        ["RIGHT BRACKET"] = "]",
        ["LEFT BRACKET"] = "[",
        ["SEMICOLON"] = ";",
        ["SLASH"] = "/",
        ["TILDE"] = "~",
    }
    if punctuation[upperName] then
        return punctuation[upperName]
    end

    if string.find(upperName, "MOUSE", 1, true) then
        local buttonNumber = upperName:match("(%d+)")
        if buttonNumber then
            return "M" .. buttonNumber
        end
    end

    local compactName = upperName:gsub("%s+", "")
    if #compactName <= 4 then
        return compactName
    end

    local words = {}
    for word in string.gmatch(upperName, "[A-Z0-9]+") do
        words[#words + 1] = word
    end

    if #words > 1 then
        local abbreviation = {}
        for _, word in ipairs(words) do
            abbreviation[#abbreviation + 1] = word:sub(1, 1)
            if #abbreviation >= 4 then
                break
            end
        end
        return table.concat(abbreviation, "")
    end

    return compactName:sub(1, 5)
end

local function GetColorHexFromColorTable(colorTable)
    local red = ClampNumber(tonumber(colorTable and colorTable[1]) or 1, 0, 1)
    local green = ClampNumber(tonumber(colorTable and colorTable[2]) or 1, 0, 1)
    local blue = ClampNumber(tonumber(colorTable and colorTable[3]) or 1, 0, 1)
    return string.format(
        "%02X%02X%02X",
        math.floor((red * 255) + 0.5),
        math.floor((green * 255) + 0.5),
        math.floor((blue * 255) + 0.5)
    )
end

local function GetClampedWindowOffsets(control, xOffset, yOffset)
    if not control then
        return tonumber(xOffset) or 0, tonumber(yOffset) or 0
    end

    local guiWidth = GuiRoot:GetWidth() or 0
    local guiHeight = GuiRoot:GetHeight() or 0
    local maxX = math.max(0, guiWidth - (control:GetWidth() or 0))
    local maxY = math.max(0, guiHeight - (control:GetHeight() or 0))

    return ClampNumber(xOffset, 0, maxX), ClampNumber(yOffset, 0, maxY)
end

local function ResetTopLevelAnchor(control, relativePoint)
    local point = relativePoint == "right" and TOPRIGHT or TOPLEFT
    local x = control:GetLeft() or 0
    local y = control:GetTop() or 0

    if relativePoint == "right" then
        x = (GuiRoot:GetWidth() - (control:GetRight() or (x + control:GetWidth())))
    end

    x, y = GetClampedWindowOffsets(control, x, y)

    control:ClearAnchors()
    control:SetAnchor(point, GuiRoot, point, relativePoint == "right" and -x or x, y)
end

function ZeroPanel:Print(message)
    d(string.format("%s %s", ZERO_PANEL_TAG, tostring(message)))
end

function ZeroPanel:RegisterKeybindStringIds()
    for keybindSlot = 1, ZERO_PANEL_KEYBIND_SLOT_COUNT do
        local bindingLabel = GetZeroPanelKeybindSlotLabel(keybindSlot)
        if self.savedVars then
            local assignedLayoutKey = self:GetLayoutKeyForKeybindSlot(keybindSlot)
            local assignedEntry = assignedLayoutKey and self:GetLayoutCatalogByKey()[assignedLayoutKey] or nil
            if self:IsLayoutEntryBindable(assignedEntry) then
                bindingLabel = string.format("%s: %s", bindingLabel, tostring(assignedEntry.name or assignedEntry.key or "Assigned Button"))
            end
        end

        CreateOrUpdateStringId("SI_BINDING_NAME_" .. GetZeroPanelKeybindActionName(keybindSlot), bindingLabel)
    end
end

function ZeroPanel:IsActionNameMatchIndices(actionName, layerIndex, categoryIndex, actionIndex)
    if type(actionName) ~= "string" or actionName == "" or type(GetActionIndicesFromName) ~= "function" then
        return false
    end

    local expectedLayerIndex, expectedCategoryIndex, expectedActionIndex = GetActionIndicesFromName(actionName)
    return expectedLayerIndex == layerIndex and expectedCategoryIndex == categoryIndex and expectedActionIndex == actionIndex
end

function ZeroPanel:GetActionIndicesForActionName(actionName)
    if type(actionName) ~= "string" or actionName == "" or type(GetActionIndicesFromName) ~= "function" then
        return nil
    end

    local layerIndex, categoryIndex, actionIndex = GetActionIndicesFromName(actionName)
    if not layerIndex or not categoryIndex or not actionIndex then
        return nil
    end

    return layerIndex, categoryIndex, actionIndex
end

function ZeroPanel:GetRoleName(role)
    if role == LFG_ROLE_TANK then
        return "Tank"
    elseif role == LFG_ROLE_HEAL then
        return "Healer"
    elseif role == LFG_ROLE_DPS then
        return "Damage"
    end
    return "Unknown"
end

function ZeroPanel:GetCollectibleName(collectibleId)
    return zo_strformat("<<1>>", GetCollectibleName(collectibleId))
end

function ZeroPanel:GetCollectibleBrowserState()
    self.collectibleBrowserState = self.collectibleBrowserState or {
        category = "all",
        status = "unlocked",
        filter = "",
        selectedCollectibleId = 0,
        pageSize = 6,
        pageIndex = 1,
    }

    self.collectibleBrowserState.pageSize = tonumber(self.collectibleBrowserState.pageSize) or 6
    self.collectibleBrowserState.pageIndex = tonumber(self.collectibleBrowserState.pageIndex) or 1

    return self.collectibleBrowserState
end

function ZeroPanel:InvalidateCollectibleCaches()
    self.collectibleBrowserMeta = nil
end

function ZeroPanel:BuildCollectibleBrowserMeta()
    if self.collectibleBrowserMeta then
        return self.collectibleBrowserMeta
    end

    local meta = {
        categoryChoices = {"All Collectibles"},
        categoryValues = {"all"},
        entriesByCategory = {
            all = {},
        },
    }

    for _, globalName in ipairs(COLLECTIBLE_BROWSER_CATEGORY_GLOBAL_NAMES) do
        local categoryType = _G[globalName]
        if categoryType and (not COLLECTIBLE_CATEGORY_TYPE_INVALID or categoryType ~= COLLECTIBLE_CATEGORY_TYPE_INVALID) then
            local totalCollectibles = GetTotalCollectiblesByCategoryType(categoryType)
            if totalCollectibles and totalCollectibles > 0 then
                local categoryName = GetString("SI_COLLECTIBLECATEGORYTYPE", categoryType)
                if categoryName == nil or categoryName == "" then
                    categoryName = globalName:gsub("^COLLECTIBLE_CATEGORY_TYPE_", "")
                end

                local entries = {}
                for collectibleIndex = 1, totalCollectibles do
                    local collectibleId = GetCollectibleIdFromType(categoryType, collectibleIndex)
                    if collectibleId and collectibleId > 0 then
                        local collectibleName, _, collectibleIcon, _, isUnlocked, _, isActive = GetCollectibleInfo(collectibleId)
                        if collectibleName and collectibleName ~= "" then
                            local displayName = self:GetCollectibleName(collectibleId)
                            local entry = {
                                id = collectibleId,
                                name = displayName,
                                icon = collectibleIcon,
                                unlocked = isUnlocked,
                                active = isActive,
                                categoryType = categoryType,
                                categoryName = categoryName,
                                filterText = NormalizeBrowserText(string.format("%s %s %s", displayName, collectibleId, categoryName)),
                            }
                            entries[#entries + 1] = entry
                            meta.entriesByCategory.all[#meta.entriesByCategory.all + 1] = entry
                        end
                    end
                end

                if #entries > 0 then
                    table.sort(entries, function(left, right)
                        return left.name < right.name
                    end)
                    meta.entriesByCategory[categoryType] = entries
                    meta.categoryChoices[#meta.categoryChoices + 1] = string.format("%s (%d)", categoryName, #entries)
                    meta.categoryValues[#meta.categoryValues + 1] = categoryType
                end
            end
        end
    end

    table.sort(meta.entriesByCategory.all, function(left, right)
        return left.name < right.name
    end)
    meta.categoryChoices[1] = string.format("All Collectibles (%d)", #meta.entriesByCategory.all)
    self.collectibleBrowserMeta = meta
    return meta
end

function ZeroPanel:DoesCollectibleBrowserEntryMatchStatus(entry, statusKey)
    if statusKey == "unlocked" then
        return entry.unlocked
    elseif statusKey == "locked" then
        return not entry.unlocked
    elseif statusKey == "active" then
        return entry.active
    end

    return true
end

function ZeroPanel:GetCollectibleBrowserEntries()
    local meta = self:BuildCollectibleBrowserMeta()
    local state = self:GetCollectibleBrowserState()
    local entries = meta.entriesByCategory[state.category] or meta.entriesByCategory.all or {}
    local filteredEntries = {}
    local filterText = NormalizeBrowserText(state.filter)

    for _, entry in ipairs(entries) do
        local _, _, _, _, isUnlocked, _, isActive = GetCollectibleInfo(entry.id)
        entry.unlocked = isUnlocked
        entry.active = isActive
        if self:DoesCollectibleBrowserEntryMatchStatus(entry, state.status) then
            if filterText == "" or string.find(entry.filterText, filterText, 1, true) then
                filteredEntries[#filteredEntries + 1] = entry
            end
        end
    end

    return filteredEntries
end

function ZeroPanel:GetCollectibleBrowserChoiceEntries()
    local choices = {}
    local values = {}
    local entries = self:GetCollectibleBrowserEntries()

    for index, entry in ipairs(entries) do
        local statusText = entry.active and "Active" or (entry.unlocked and "Unlocked" or "Locked")
        choices[index] = string.format("%s (#%d, %s)", entry.name, entry.id, statusText)
        values[index] = entry.id
    end

    return choices, values
end

function ZeroPanel:UpdateDropdownReference(referenceName, choices, choiceValues, selectedValue)
    local control = referenceName and _G[referenceName]
    if not control or type(control.UpdateChoices) ~= "function" then
        return
    end

    control.data.choices = choices
    control.data.choicesValues = choiceValues
    control:UpdateChoices(choices, choiceValues)

    if selectedValue ~= nil and control.choices and control.choices[selectedValue] ~= nil then
        control.dropdown:SetSelectedItem(control.choices[selectedValue])
    else
        control:UpdateValue()
    end
end

function ZeroPanel:RefreshSummonableChoiceControls()
    for _, actionId in ipairs(SUMMONABLE_ACTION_ORDER) do
        local summonable = SUMMONABLES[actionId]
        if summonable and summonable.dropdownReference then
            local choices, choiceValues = self:GetCollectibleChoiceEntries(actionId)
            self:UpdateDropdownReference(summonable.dropdownReference, choices, choiceValues, self:GetCollectibleChoice(actionId))
        end
    end
end

function ZeroPanel:RequestSettingsRefresh()
    self:RefreshLayoutDirectionOptionControls()

    if not LibAddonMenu2 or not LibAddonMenu2.util or type(LibAddonMenu2.util.RequestRefreshIfNeeded) ~= "function" then
        return
    end

    local refreshControl = _G.ZeroPanelActivateKeybindPickerButton or _G.ZeroPanelCustomButtonSelector or _G.ZeroPanelCustomSeparatorSelector or self.addonPanel
    if refreshControl then
        LibAddonMenu2.util.RequestRefreshIfNeeded(refreshControl)
    end
end

function ZeroPanel:RefreshCollectibleBrowserControls()
    local state = self:GetCollectibleBrowserState()
    local choices, values = self:GetCollectibleBrowserChoiceEntries()

    if #values == 0 then
        choices = {"No collectibles match the current filter."}
        values = {0}
        state.selectedCollectibleId = 0
    else
        local hasSelectedValue = false
        for _, collectibleId in ipairs(values) do
            if collectibleId == state.selectedCollectibleId then
                hasSelectedValue = true
                break
            end
        end
        if not hasSelectedValue then
            state.selectedCollectibleId = values[1]
        end
    end

    self:UpdateDropdownReference("ZeroPanelCollectibleSelector", choices, values)
    self:RefreshCollectibleBrowserPopup()
end

local function GetTextureBrowserDisplayName(displayName, texturePath)
    local resolvedDisplayName = TrimText(displayName)
    if resolvedDisplayName ~= "" then
        return resolvedDisplayName
    end

    local fileName = tostring(texturePath or ""):match("([^/\\]+)%.dds$")
    if fileName and fileName ~= "" then
        fileName = fileName:gsub("[_+]", " ")
        return fileName
    end

    return "Texture"
end

local function AddTextureBrowserEntry(entries, seenPaths, texturePath, displayName, sourceName)
    local resolvedTexturePath = TrimText(texturePath)
    if resolvedTexturePath == "" or seenPaths[resolvedTexturePath] then
        return
    end

    local resolvedName = GetTextureBrowserDisplayName(displayName, resolvedTexturePath)
    local resolvedSource = TrimText(sourceName)
    entries[#entries + 1] = {
        path = resolvedTexturePath,
        name = resolvedName,
        source = resolvedSource ~= "" and resolvedSource or "Texture",
        filterText = NormalizeBrowserText(string.format("%s %s %s", resolvedName, resolvedTexturePath, resolvedSource)),
    }
    seenPaths[resolvedTexturePath] = true
end

local function CreatePopupLabel(name, parent, font, text)
    local label = WINDOW_MANAGER:CreateControl(name, parent, CT_LABEL)
    label:SetFont(font or "ZoFontWinH4")
    label:SetText(text or "")
    label:SetColor(0.96, 0.93, 0.84, 1)
    return label
end

local function CreatePopupBackdropEditBox(name, parent, width, height, maxChars)
    local backdrop = WINDOW_MANAGER:CreateControlFromVirtual(name .. "Backdrop", parent, "ZO_EditBackdrop")
    backdrop:SetDimensions(width, height)

    local editbox = WINDOW_MANAGER:CreateControlFromVirtual(name .. "Edit", backdrop, "ZO_DefaultEditForBackdrop")
    editbox:SetAnchor(TOPLEFT, backdrop, TOPLEFT, 2, 2)
    editbox:SetAnchor(BOTTOMRIGHT, backdrop, BOTTOMRIGHT, -2, -2)
    editbox:SetTextType(TEXT_TYPE_ALL)
    editbox:SetMaxInputChars(maxChars or 300)
    editbox:SetHandler("OnEscape", function(control)
        control:LoseFocus()
    end)

    return backdrop, editbox
end

local function CreatePopupComboBox(name, parent, width, height)
    local combobox = WINDOW_MANAGER:CreateControlFromVirtual(name, parent, "ZO_ScrollableComboBox")
    combobox:SetDimensions(width, height or 28)

    local dropdown = ZO_ComboBox_ObjectFromContainer(combobox)
    dropdown:SetSortsItems(false)
    dropdown.m_containerWidth = width

    return combobox, dropdown
end

local function ConfigurePopupComboBoxOverlay(dropdown, scrollBarInsetX)
    if not dropdown then
        return
    end

    local dropdownObject = dropdown.m_dropdownObject
    local dropdownControl = dropdownObject and dropdownObject.control
    if dropdownControl then
        dropdownControl:SetDrawLayer(DL_OVERLAY)
        dropdownControl:SetDrawTier(DT_HIGH)
        dropdownControl:SetDrawLevel(10)
    end

    local scrollBar = (dropdownObject and dropdownObject.scrollControl and dropdownObject.scrollControl.scrollbar)
        or (dropdownObject and dropdownObject.scrollbar)
    if scrollBar then
        local insetX = tonumber(scrollBarInsetX) or 0
        scrollBar:ClearAnchors()
        scrollBar:SetAnchor(TOPRIGHT, dropdownControl or scrollBar:GetParent(), TOPRIGHT, -insetX, 0)
        scrollBar:SetAnchor(BOTTOMRIGHT, dropdownControl or scrollBar:GetParent(), BOTTOMRIGHT, -insetX, 0)
    end
end

local function ClampPopupBrowserValue(value, minimumValue, maximumValue)
    local resolvedValue = tonumber(value) or minimumValue
    if resolvedValue < minimumValue then
        return minimumValue
    end
    if resolvedValue > maximumValue then
        return maximumValue
    end
    return resolvedValue
end

local function ResolvePopupBrowserPageSize(pageSize)
    local resolvedPageSize = tonumber(pageSize) or 6
    for _, allowedPageSize in ipairs(POPUP_BROWSER_PAGE_SIZE_VALUES) do
        if allowedPageSize == resolvedPageSize then
            return resolvedPageSize
        end
    end

    return POPUP_BROWSER_PAGE_SIZE_VALUES[2]
end

local function GetPopupBrowserPageCount(entryCount, pageSize)
    local resolvedPageSize = math.max(1, tonumber(pageSize) or 1)
    return math.max(1, math.ceil(math.max(0, tonumber(entryCount) or 0) / resolvedPageSize))
end

local function GetPopupBrowserPageForIndex(entryIndex, pageSize)
    local resolvedPageSize = math.max(1, tonumber(pageSize) or 1)
    if tonumber(entryIndex) == nil or entryIndex <= 0 then
        return 1
    end

    return math.floor((entryIndex - 1) / resolvedPageSize) + 1
end

local function FindPopupBrowserEntryIndex(entries, predicate)
    if type(predicate) ~= "function" then
        return 0
    end

    for entryIndex, entry in ipairs(entries or {}) do
        if predicate(entry) then
            return entryIndex
        end
    end

    return 0
end

local function RefreshPopupResultRowAppearance(row)
    if not row then
        return
    end

    if row.isSelected then
        row.backdrop:SetCenterColor(0.26, 0.22, 0.09, 0.96)
        row.backdrop:SetEdgeColor(0.79, 0.67, 0.28, 1)
        row.primaryLabel:SetColor(0.99, 0.95, 0.82, 1)
        row.secondaryLabel:SetColor(0.96, 0.88, 0.66, 1)
    elseif row.isHovered then
        row.backdrop:SetCenterColor(0.15, 0.16, 0.20, 0.96)
        row.backdrop:SetEdgeColor(0.46, 0.46, 0.50, 1)
        row.primaryLabel:SetColor(0.97, 0.94, 0.86, 1)
        row.secondaryLabel:SetColor(0.82, 0.82, 0.86, 1)
    else
        row.backdrop:SetCenterColor(0.09, 0.10, 0.13, 0.94)
        row.backdrop:SetEdgeColor(0.24, 0.24, 0.28, 1)
        row.primaryLabel:SetColor(0.94, 0.92, 0.86, 1)
        row.secondaryLabel:SetColor(0.72, 0.72, 0.76, 1)
    end
end

local function CreatePopupResultsList(name, parent, width)
    local totalHeight = 12 + (POPUP_BROWSER_MAX_ROWS * POPUP_BROWSER_ROW_HEIGHT) + ((POPUP_BROWSER_MAX_ROWS - 1) * POPUP_BROWSER_ROW_GAP)
    local list = WINDOW_MANAGER:CreateControl(name, parent, CT_CONTROL)
    list:SetDimensions(width, totalHeight)
    list:SetMouseEnabled(true)

    list.backdrop = WINDOW_MANAGER:CreateControl(name .. "Backdrop", list, CT_BACKDROP)
    list.backdrop:SetAnchorFill()
    list.backdrop:SetCenterColor(0.06, 0.07, 0.10, 0.98)
    list.backdrop:SetEdgeColor(0.32, 0.30, 0.24, 1)
    list.backdrop:SetMouseEnabled(true)

    list.rows = {}
    local previousRow
    for rowIndex = 1, POPUP_BROWSER_MAX_ROWS do
        local row = WINDOW_MANAGER:CreateControl(name .. "Row" .. rowIndex, list, CT_BUTTON)
        row:SetDimensions(width - 12, POPUP_BROWSER_ROW_HEIGHT)
        row:SetMouseEnabled(true)
        if previousRow then
            row:SetAnchor(TOPLEFT, previousRow, BOTTOMLEFT, 0, POPUP_BROWSER_ROW_GAP)
        else
            row:SetAnchor(TOPLEFT, list, TOPLEFT, 6, 6)
        end

        row.backdrop = WINDOW_MANAGER:CreateControl(name .. "Row" .. rowIndex .. "Backdrop", row, CT_BACKDROP)
        row.backdrop:SetAnchorFill()
        row.backdrop:SetMouseEnabled(false)

        row.iconBackdrop = WINDOW_MANAGER:CreateControl(name .. "Row" .. rowIndex .. "IconBackdrop", row, CT_BACKDROP)
        row.iconBackdrop:SetDimensions(28, 28)
        row.iconBackdrop:SetAnchor(LEFT, row, LEFT, 6, 0)
        row.iconBackdrop:SetCenterColor(0.02, 0.03, 0.04, 0.98)
        row.iconBackdrop:SetEdgeColor(0.24, 0.24, 0.28, 1)
        row.iconBackdrop:SetMouseEnabled(false)

        row.icon = WINDOW_MANAGER:CreateControl(name .. "Row" .. rowIndex .. "Icon", row.iconBackdrop, CT_TEXTURE)
        row.icon:SetAnchorFill()
        row.icon:SetMouseEnabled(false)

        row.primaryLabel = CreatePopupLabel(name .. "Row" .. rowIndex .. "PrimaryLabel", row, "ZoFontGame", "")
        row.primaryLabel:SetAnchor(TOPLEFT, row.iconBackdrop, TOPRIGHT, 10, 3)
        row.primaryLabel:SetWidth(width - 74)
        row.primaryLabel:SetMouseEnabled(false)

        row.secondaryLabel = CreatePopupLabel(name .. "Row" .. rowIndex .. "SecondaryLabel", row, "ZoFontGameSmall", "")
        row.secondaryLabel:SetAnchor(TOPLEFT, row.primaryLabel, BOTTOMLEFT, 0, 0)
        row.secondaryLabel:SetWidth(width - 74)
        row.secondaryLabel:SetMouseEnabled(false)

        row:SetHandler("OnClicked", function(control)
            if control.data ~= nil and list.onSelect then
                list.onSelect(control.data)
            end
        end)
        row:SetHandler("OnMouseEnter", function(control)
            control.isHovered = true
            RefreshPopupResultRowAppearance(control)
        end)
        row:SetHandler("OnMouseExit", function(control)
            control.isHovered = false
            RefreshPopupResultRowAppearance(control)
        end)

        list.rows[rowIndex] = row
        previousRow = row
    end

    list.emptyLabel = CreatePopupLabel(name .. "EmptyLabel", list, "ZoFontGame", "")
    list.emptyLabel:SetAnchor(CENTER, list, CENTER, 0, 0)
    list.emptyLabel:SetWidth(width - 24)
    list.emptyLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)

    local function HandleMouseWheel(_, delta)
        if delta == 0 or not list.onPageDelta then
            return
        end
        list.onPageDelta(delta < 0 and 1 or -1)
    end

    list:SetHandler("OnMouseWheel", HandleMouseWheel)
    list.backdrop:SetHandler("OnMouseWheel", HandleMouseWheel)

    return list
end

local function CreatePopupButton(name, parent, text, width, height)
    local button = WINDOW_MANAGER:CreateControlFromVirtual(name, parent, "ZO_DefaultButton")
    button:SetDimensions(width, height or 28)
    button:SetText(text)
    button:SetClickSound("Click")
    return button
end

function ZeroPanel:CreatePopupWindow(windowName, titleText, width, height)
    local window = WINDOW_MANAGER:CreateTopLevelWindow(windowName)
    window:SetDimensions(width, height)
    window:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    window:SetClampedToScreen(true)
    window:SetHidden(true)
    window:SetMovable(true)
    window:SetMouseEnabled(true)
    window:SetDrawLayer(DL_OVERLAY)
    window:SetDrawTier(DT_HIGH)

    window.backdrop = WINDOW_MANAGER:CreateControl(windowName .. "Backdrop", window, CT_BACKDROP)
    window.backdrop:SetAnchorFill()
    window.backdrop:SetCenterColor(0.05, 0.06, 0.08, 0.98)
    window.backdrop:SetEdgeColor(0.62, 0.56, 0.40, 1)
    window.backdrop:SetMouseEnabled(true)
    window.backdrop:SetHandler("OnMouseDown", function(_, button)
        if button == MOUSE_BUTTON_INDEX_LEFT then
            window:StartMoving()
        end
    end)
    window.backdrop:SetHandler("OnMouseUp", function(_, button)
        if button == MOUSE_BUTTON_INDEX_LEFT then
            window:StopMovingOrResizing()
        end
    end)

    window.title = CreatePopupLabel(windowName .. "Title", window, "ZoFontWinH1", titleText)
    window.title:SetAnchor(TOPLEFT, window, TOPLEFT, 24, 18)

    window.closeButton = CreatePopupButton(windowName .. "Close", window, "Close", 100, 30)
    window.closeButton:SetAnchor(TOPRIGHT, window, TOPRIGHT, -22, 16)
    window.closeButton:SetHandler("OnClicked", function()
        window:SetHidden(true)
    end)

    return window
end

function ZeroPanel:PopulatePopupDropdown(dropdown, entries, selectedPredicate, textFormatter, onSelect, emptyText)
    dropdown:ClearItems()

    local selectedItem
    for _, entry in ipairs(entries or {}) do
        local itemEntry = dropdown:CreateItemEntry(textFormatter(entry), function()
            onSelect(entry)
        end)
        dropdown:AddItem(itemEntry)
        if selectedPredicate and selectedPredicate(entry) then
            selectedItem = itemEntry
        end
    end

    if selectedItem then
        dropdown:SelectItem(selectedItem, true)
    else
        dropdown:SetSelectedItemText(emptyText or "")
    end
end

function ZeroPanel:RefreshPopupResultsList(window, entries, state, selectedPredicate, rowFormatter, onSelect, emptyText)
    if not window or not window.resultsList then
        return
    end

    local pageSize = ResolvePopupBrowserPageSize(state.pageSize)
    state.pageSize = pageSize

    local entryCount = #entries
    local pageCount = GetPopupBrowserPageCount(entryCount, pageSize)
    local selectedIndex = FindPopupBrowserEntryIndex(entries, selectedPredicate)
    if selectedIndex > 0 then
        state.pageIndex = GetPopupBrowserPageForIndex(selectedIndex, pageSize)
    end
    state.pageIndex = ClampPopupBrowserValue(state.pageIndex, 1, pageCount)

    local pageIndex = state.pageIndex
    local firstEntryIndex = ((pageIndex - 1) * pageSize) + 1
    local lastEntryIndex = math.min(entryCount, firstEntryIndex + pageSize - 1)

    window.resultsList.onSelect = function(entry)
        onSelect(entry)
    end
    window.resultsList.onPageDelta = function(pageDelta)
        if entryCount == 0 then
            return
        end

        local nextPageIndex = ClampPopupBrowserValue(pageIndex + pageDelta, 1, pageCount)
        if nextPageIndex == pageIndex then
            return
        end

        local firstPageEntry = entries[((nextPageIndex - 1) * pageSize) + 1]
        if firstPageEntry then
            onSelect(firstPageEntry)
        end
    end

    for rowIndex, row in ipairs(window.resultsList.rows) do
        local entry = rowIndex <= pageSize and entries[firstEntryIndex + rowIndex - 1] or nil
        row.data = entry
        row.isHovered = false
        row.isSelected = entry ~= nil and selectedPredicate ~= nil and selectedPredicate(entry) or false

        if entry then
            local rowData = rowFormatter(entry) or {}
            local iconPath = TrimText(rowData.icon)
            local secondaryText = TrimText(rowData.secondaryText)

            row.primaryLabel:SetText(rowData.primaryText or "")
            row.secondaryLabel:SetText(secondaryText)
            row.secondaryLabel:SetHidden(secondaryText == "")
            row.icon:SetTexture(iconPath ~= "" and iconPath or "")
            row.icon:SetHidden(iconPath == "")
            row.iconBackdrop:SetHidden(iconPath == "")
            row:SetHidden(false)
        else
            row:SetHidden(true)
        end

        RefreshPopupResultRowAppearance(row)
    end

    window.resultsList.emptyLabel:SetText(emptyText or "No results available.")
    window.resultsList.emptyLabel:SetHidden(entryCount > 0)

    if entryCount > 0 then
        window.pageInfoLabel:SetText(string.format("Showing %d-%d of %d | Page %d/%d", firstEntryIndex, lastEntryIndex, entryCount, pageIndex, pageCount))
    else
        window.pageInfoLabel:SetText("Showing 0 of 0 | Page 1/1")
    end

    window.prevPageButton:SetEnabled(entryCount > 0 and pageIndex > 1)
    window.nextPageButton:SetEnabled(entryCount > 0 and pageIndex < pageCount)
end

function ZeroPanel:GetTextureBrowserState()
    self.textureBrowserState = self.textureBrowserState or {
        filter = "",
        selectedTexturePath = "",
        pageSize = 6,
        pageIndex = 1,
    }

    self.textureBrowserState.pageSize = tonumber(self.textureBrowserState.pageSize) or 6
    self.textureBrowserState.pageIndex = tonumber(self.textureBrowserState.pageIndex) or 1

    return self.textureBrowserState
end

function ZeroPanel:BuildTextureBrowserMeta()
    if self.textureBrowserMeta then
        return self.textureBrowserMeta
    end

    local entries = {}
    local seenPaths = {}

    for _, definition in ipairs(BUTTON_DEFINITIONS) do
        AddTextureBrowserEntry(entries, seenPaths, self:GetButtonIcon(definition), definition.name, "Built-in Button")
    end

    for actionId, action in pairs(CUSTOM_BUTTON_ACTIONS) do
        local actionIcon = action.icon
        if type(actionIcon) == "function" then
            actionIcon = actionIcon(self, {})
        end
        AddTextureBrowserEntry(entries, seenPaths, actionIcon, action.name or actionId, "Custom Action")
    end

    for _, preset in ipairs(CUSTOM_BUTTON_PRESETS) do
        local presetIcon = preset.icon
        if type(presetIcon) ~= "string" or TrimText(presetIcon) == "" then
            local action = CUSTOM_BUTTON_ACTIONS[preset.actionType]
            presetIcon = action and action.icon or nil
            if type(presetIcon) == "function" then
                presetIcon = presetIcon(self, {})
            end
        end
        AddTextureBrowserEntry(entries, seenPaths, presetIcon, preset.name, "Preset")
    end

    for commandText, texturePath in pairs(COMMAND_ICON_OVERRIDES) do
        AddTextureBrowserEntry(entries, seenPaths, texturePath, commandText, "Slash Command")
    end

    local collectibleEntries = (self:BuildCollectibleBrowserMeta().entriesByCategory or {}).all or {}
    for _, entry in ipairs(collectibleEntries) do
        AddTextureBrowserEntry(entries, seenPaths, entry.icon, entry.name, entry.categoryName or "Collectible")
    end

    table.sort(entries, function(left, right)
        local leftName = string.lower(left.name or left.path or "")
        local rightName = string.lower(right.name or right.path or "")
        if leftName == rightName then
            return string.lower(left.path or "") < string.lower(right.path or "")
        end
        return leftName < rightName
    end)

    self.textureBrowserMeta = {
        entries = entries,
    }

    return self.textureBrowserMeta
end

function ZeroPanel:GetTextureBrowserEntries()
    local state = self:GetTextureBrowserState()
    local filterText = NormalizeBrowserText(state.filter)
    local filteredEntries = {}
    local hasSelectedPath = false

    for _, entry in ipairs((self:BuildTextureBrowserMeta().entries or {})) do
        if filterText == "" or string.find(entry.filterText, filterText, 1, true) then
            filteredEntries[#filteredEntries + 1] = entry
            if entry.path == state.selectedTexturePath then
                hasSelectedPath = true
            end
        end
    end

    local selectedTexturePath = TrimText(state.selectedTexturePath)
    if not hasSelectedPath and selectedTexturePath ~= "" then
        local currentEntry = {
            path = selectedTexturePath,
            name = "Current Texture",
            source = "Current Selection",
            filterText = NormalizeBrowserText(string.format("%s %s %s", "Current Texture", selectedTexturePath, "Current Selection")),
        }
        if filterText == "" or string.find(currentEntry.filterText, filterText, 1, true) then
            table.insert(filteredEntries, 1, currentEntry)
        end
    end

    return filteredEntries
end

function ZeroPanel:GetSelectedCollectibleBrowserEntry(entries)
    local state = self:GetCollectibleBrowserState()
    for _, entry in ipairs(entries or {}) do
        if entry.id == state.selectedCollectibleId then
            return entry
        end
    end

    return nil
end

function ZeroPanel:GetSelectedTextureBrowserEntry(entries)
    local state = self:GetTextureBrowserState()
    for _, entry in ipairs(entries or {}) do
        if entry.path == state.selectedTexturePath then
            return entry
        end
    end

    return nil
end

function ZeroPanel:RefreshCollectibleBrowserPopup()
    local window = self.collectibleBrowserWindow
    if not window then
        return
    end

    local state = self:GetCollectibleBrowserState()
    local meta = self:BuildCollectibleBrowserMeta()
    local categoryEntries = {}
    local statusEntries = {}
    local collectibleEntries = self:GetCollectibleBrowserEntries()
    local selectedEntry = self:GetSelectedCollectibleBrowserEntry(collectibleEntries)

    if not selectedEntry and collectibleEntries[1] then
        state.selectedCollectibleId = collectibleEntries[1].id
        selectedEntry = collectibleEntries[1]
    end

    local customButtonId = self:GetSelectedCustomButtonId()
    if customButtonId then
        window.targetLabel:SetText(string.format("Editing %s", self:GetCustomButtonDisplayName(customButtonId)))
    else
        window.targetLabel:SetText("No custom button selected.")
    end

    if not window.isUpdatingFilterText and window.filterEdit:GetText() ~= state.filter then
        window.isUpdatingFilterText = true
        window.filterEdit:SetText(state.filter)
        window.isUpdatingFilterText = false
    end

    self:PopulatePopupDropdown(window.pageSizeDropdown, POPUP_BROWSER_PAGE_SIZE_ENTRIES, function(entry)
        return entry.value == ResolvePopupBrowserPageSize(state.pageSize)
    end, function(entry)
        return entry.label
    end, function(entry)
        state.pageSize = entry.value
        self:RefreshCollectibleBrowserPopup()
    end, "Per page")

    for index, categoryLabel in ipairs(meta.categoryChoices or {}) do
        categoryEntries[#categoryEntries + 1] = {
            label = categoryLabel,
            value = meta.categoryValues[index],
        }
    end

    for index, statusLabel in ipairs(COLLECTIBLE_BROWSER_STATUS_NAMES) do
        statusEntries[#statusEntries + 1] = {
            label = statusLabel,
            value = COLLECTIBLE_BROWSER_STATUS_KEYS[index],
        }
    end

    self:PopulatePopupDropdown(window.categoryDropdown, categoryEntries, function(entry)
        return entry.value == state.category
    end, function(entry)
        return entry.label
    end, function(entry)
        state.category = entry.value
        state.selectedCollectibleId = 0
        state.pageIndex = 1
        self:RefreshCollectibleBrowserControls()
    end, "No categories available.")

    self:PopulatePopupDropdown(window.statusDropdown, statusEntries, function(entry)
        return entry.value == state.status
    end, function(entry)
        return entry.label
    end, function(entry)
        state.status = entry.value
        state.selectedCollectibleId = 0
        state.pageIndex = 1
        self:RefreshCollectibleBrowserControls()
    end, "No statuses available.")

    window.resultLabel:SetText(TrimText(state.filter) ~= "" and "Matching Collectibles" or "Collectibles")
    self:RefreshPopupResultsList(window, collectibleEntries, state, function(entry)
        return selectedEntry and entry.id == selectedEntry.id
    end, function(entry)
        local statusText = entry.active and "Active" or (entry.unlocked and "Unlocked" or "Locked")
        return {
            icon = entry.icon,
            primaryText = entry.name,
            secondaryText = string.format("%s | #%d | %s", entry.categoryName or "Collectible", entry.id, statusText),
        }
    end, function(entry)
        state.selectedCollectibleId = entry.id
        self:RefreshCollectibleBrowserPopup()
    end, "No collectibles match the current filter.")

    if selectedEntry then
        window.previewTexture:SetTexture(selectedEntry.icon or "")
        window.previewTexture:SetHidden(false)
        window.selectionName:SetText(selectedEntry.name)
        window.selectionInfo:SetText(string.format("%s\nCollectible ID: %d", selectedEntry.categoryName or "Collectible", selectedEntry.id))
    else
        window.previewTexture:SetHidden(true)
        window.selectionName:SetText("No matching collectible")
        window.selectionInfo:SetText("Adjust Category, Status, or Filter to find a collectible.")
    end

    window.applyButton:SetEnabled(selectedEntry ~= nil and self:GetSelectedCustomButtonData() ~= nil)
end

function ZeroPanel:RefreshTextureBrowserPopup()
    local window = self.textureBrowserWindow
    if not window then
        return
    end

    local state = self:GetTextureBrowserState()
    local textureEntries = self:GetTextureBrowserEntries()
    local selectedEntry = self:GetSelectedTextureBrowserEntry(textureEntries)
    local customButtonId = self:GetSelectedCustomButtonId()
    local customButtonData = self:GetSelectedCustomButtonData()

    if not selectedEntry and textureEntries[1] then
        state.selectedTexturePath = textureEntries[1].path
        selectedEntry = textureEntries[1]
    end

    if customButtonId then
        window.targetLabel:SetText(string.format("Editing %s", self:GetCustomButtonDisplayName(customButtonId)))
    else
        window.targetLabel:SetText("No custom button selected.")
    end

    if not window.isUpdatingFilterText and window.filterEdit:GetText() ~= state.filter then
        window.isUpdatingFilterText = true
        window.filterEdit:SetText(state.filter)
        window.isUpdatingFilterText = false
    end

    self:PopulatePopupDropdown(window.pageSizeDropdown, POPUP_BROWSER_PAGE_SIZE_ENTRIES, function(entry)
        return entry.value == ResolvePopupBrowserPageSize(state.pageSize)
    end, function(entry)
        return entry.label
    end, function(entry)
        state.pageSize = entry.value
        self:RefreshTextureBrowserPopup()
    end, "Per page")

    window.resultLabel:SetText(TrimText(state.filter) ~= "" and "Matching Textures" or "Textures")
    self:RefreshPopupResultsList(window, textureEntries, state, function(entry)
        return selectedEntry and entry.path == selectedEntry.path
    end, function(entry)
        return {
            icon = entry.path,
            primaryText = entry.name,
            secondaryText = string.format("%s | %s", entry.source, entry.path),
        }
    end, function(entry)
        state.selectedTexturePath = entry.path
        self:RefreshTextureBrowserPopup()
    end, "No textures match the current filter.")

    if selectedEntry then
        window.previewTexture:SetTexture(selectedEntry.path)
        window.previewTexture:SetHidden(false)
        window.selectionName:SetText(selectedEntry.name)
        window.selectionInfo:SetText(string.format("%s\n%s", selectedEntry.source, selectedEntry.path))
    else
        window.previewTexture:SetHidden(true)
        window.selectionName:SetText("No matching texture")
        window.selectionInfo:SetText("Adjust the filter to find a texture path.")
    end

    window.applyButton:SetEnabled(selectedEntry ~= nil and customButtonData ~= nil)
    window.clearButton:SetEnabled(customButtonData ~= nil and TrimText(customButtonData.icon) ~= "")
end

function ZeroPanel:RefreshTextureBrowserControls()
    self:RefreshTextureBrowserPopup()
end

function ZeroPanel:EnsureCollectibleBrowserPopup()
    if self.collectibleBrowserWindow then
        return self.collectibleBrowserWindow
    end

    local window = self:CreatePopupWindow("ZeroPanelCollectibleBrowserWindow", "Browse Collectibles", 780, 620)

    window.targetLabel = CreatePopupLabel(window:GetName() .. "TargetLabel", window, "ZoFontGameLargeBold", "")
    window.targetLabel:SetAnchor(TOPLEFT, window, TOPLEFT, 24, 56)

    window.description = CreatePopupLabel(window:GetName() .. "Description", window, "ZoFontGame", "Pick a collectible and Zero Panel will write the command and icon into the selected custom button.")
    window.description:SetAnchor(TOPLEFT, window.targetLabel, BOTTOMLEFT, 0, 10)
    window.description:SetWidth(720)

    window.categoryLabel = CreatePopupLabel(window:GetName() .. "CategoryLabel", window, "ZoFontGame", "Category")
    window.categoryLabel:SetAnchor(TOPLEFT, window.description, BOTTOMLEFT, 0, 18)
    window.categoryCombo, window.categoryDropdown = CreatePopupComboBox(window:GetName() .. "CategoryCombo", window, 330, 28)
    window.categoryCombo:SetAnchor(TOPLEFT, window.categoryLabel, BOTTOMLEFT, 0, 6)
    ConfigurePopupComboBoxOverlay(window.categoryDropdown, 2)

    window.statusLabel = CreatePopupLabel(window:GetName() .. "StatusLabel", window, "ZoFontGame", "Status")
    window.statusLabel:SetAnchor(TOPLEFT, window.description, BOTTOMLEFT, 372, 18)
    window.statusCombo, window.statusDropdown = CreatePopupComboBox(window:GetName() .. "StatusCombo", window, 170, 28)
    window.statusCombo:SetAnchor(TOPLEFT, window.statusLabel, BOTTOMLEFT, 0, 6)
    ConfigurePopupComboBoxOverlay(window.statusDropdown, 2)

    window.filterLabel = CreatePopupLabel(window:GetName() .. "FilterLabel", window, "ZoFontGame", "Filter")
    window.filterLabel:SetAnchor(TOPLEFT, window.categoryCombo, BOTTOMLEFT, 0, 18)
    window.filterBackdrop, window.filterEdit = CreatePopupBackdropEditBox(window:GetName() .. "Filter", window, 500, 30, 120)
    window.filterBackdrop:SetAnchor(TOPLEFT, window.filterLabel, BOTTOMLEFT, 0, 6)
    window.filterEdit:SetHandler("OnTextChanged", function(control)
        if window.isUpdatingFilterText then
            return
        end

        local state = self:GetCollectibleBrowserState()
        state.filter = tostring(control:GetText() or "")
        state.selectedCollectibleId = 0
        state.pageIndex = 1
        self:RefreshCollectibleBrowserControls()
    end)

    window.pageSizeLabel = CreatePopupLabel(window:GetName() .. "PageSizeLabel", window, "ZoFontGame", "Per Page")
    window.pageSizeCombo, window.pageSizeDropdown = CreatePopupComboBox(window:GetName() .. "PageSizeCombo", window, 170, 28)
    window.pageSizeCombo:SetAnchor(TOPLEFT, window.filterBackdrop, TOPRIGHT, 26, 0)
    window.pageSizeLabel:SetAnchor(BOTTOMLEFT, window.pageSizeCombo, TOPLEFT, 0, -4)
    ConfigurePopupComboBoxOverlay(window.pageSizeDropdown, 2)

    window.resultLabel = CreatePopupLabel(window:GetName() .. "ResultLabel", window, "ZoFontGame", "Collectibles")
    window.resultLabel:SetAnchor(TOPLEFT, window.filterBackdrop, BOTTOMLEFT, 0, 18)
    window.resultsList = CreatePopupResultsList(window:GetName() .. "ResultsList", window, 468)
    window.resultsList:SetAnchor(TOPLEFT, window.resultLabel, BOTTOMLEFT, 0, 6)

    window.pageInfoLabel = CreatePopupLabel(window:GetName() .. "PageInfoLabel", window, "ZoFontGame", "")
    window.pageInfoLabel:SetAnchor(TOPLEFT, window.resultsList, BOTTOMLEFT, 0, 10)
    window.pageInfoLabel:SetWidth(260)

    window.prevPageButton = CreatePopupButton(window:GetName() .. "PrevPageButton", window, "Previous", 100, 28)
    window.prevPageButton:SetAnchor(TOPRIGHT, window.resultsList, BOTTOMRIGHT, -108, 6)
    window.prevPageButton:SetHandler("OnClicked", function()
        if window.resultsList.onPageDelta then
            window.resultsList.onPageDelta(-1)
        end
    end)

    window.nextPageButton = CreatePopupButton(window:GetName() .. "NextPageButton", window, "Next", 100, 28)
    window.nextPageButton:SetAnchor(TOPRIGHT, window.resultsList, BOTTOMRIGHT, 0, 6)
    window.nextPageButton:SetHandler("OnClicked", function()
        if window.resultsList.onPageDelta then
            window.resultsList.onPageDelta(1)
        end
    end)

    window.previewSection = WINDOW_MANAGER:CreateControl(window:GetName() .. "PreviewSection", window, CT_CONTROL)
    window.previewSection:SetDimensions(244, 398)
    window.previewSection:SetAnchor(TOPLEFT, window.resultsList, TOPRIGHT, 20, 0)

    window.previewSectionBackdrop = WINDOW_MANAGER:CreateControl(window:GetName() .. "PreviewSectionBackdrop", window.previewSection, CT_BACKDROP)
    window.previewSectionBackdrop:SetAnchorFill()
    window.previewSectionBackdrop:SetCenterColor(0.06, 0.07, 0.10, 0.98)
    window.previewSectionBackdrop:SetEdgeColor(0.32, 0.30, 0.24, 1)

    window.previewSectionLabel = CreatePopupLabel(window:GetName() .. "PreviewSectionLabel", window.previewSection, "ZoFontGame", "Selected Collectible")
    window.previewSectionLabel:SetAnchor(TOPLEFT, window.previewSection, TOPLEFT, 12, 12)

    window.previewBackdrop = WINDOW_MANAGER:CreateControl(window:GetName() .. "PreviewBackdrop", window.previewSection, CT_BACKDROP)
    window.previewBackdrop:SetDimensions(96, 96)
    window.previewBackdrop:SetAnchor(TOPLEFT, window.previewSectionLabel, BOTTOMLEFT, 0, 12)
    window.previewBackdrop:SetCenterColor(0.10, 0.11, 0.15, 0.98)
    window.previewBackdrop:SetEdgeColor(0.28, 0.28, 0.32, 1)

    window.previewTexture = WINDOW_MANAGER:CreateControl(window:GetName() .. "PreviewTexture", window.previewBackdrop, CT_TEXTURE)
    window.previewTexture:SetAnchorFill()

    window.selectionName = CreatePopupLabel(window:GetName() .. "SelectionName", window.previewSection, "ZoFontGameLargeBold", "")
    window.selectionName:SetAnchor(TOPLEFT, window.previewBackdrop, BOTTOMLEFT, 0, 18)
    window.selectionName:SetWidth(220)

    window.selectionInfo = CreatePopupLabel(window:GetName() .. "SelectionInfo", window.previewSection, "ZoFontGame", "")
    window.selectionInfo:SetAnchor(TOPLEFT, window.selectionName, BOTTOMLEFT, 0, 8)
    window.selectionInfo:SetWidth(220)

    window.applyButton = CreatePopupButton(window:GetName() .. "ApplyButton", window.previewSection, "Apply Collectible", 134, 30)
    window.applyButton:SetAnchor(BOTTOMRIGHT, window.previewSection, BOTTOMRIGHT, -12, -12)
    window.applyButton:SetHandler("OnClicked", function()
        self:ApplySelectedCollectibleToCustomButton()
        self:CloseCollectibleBrowserPopup()
    end)

    window.closeButton:ClearAnchors()
    window.closeButton:SetAnchor(BOTTOMRIGHT, window.applyButton, BOTTOMLEFT, -10, 0)

    self.collectibleBrowserWindow = window
    return window
end

function ZeroPanel:EnsureTextureBrowserPopup()
    if self.textureBrowserWindow then
        return self.textureBrowserWindow
    end

    local window = self:CreatePopupWindow("ZeroPanelTextureBrowserWindow", "Browse Textures", 780, 620)

    window.targetLabel = CreatePopupLabel(window:GetName() .. "TargetLabel", window, "ZoFontGameLargeBold", "")
    window.targetLabel:SetAnchor(TOPLEFT, window, TOPLEFT, 24, 56)

    window.description = CreatePopupLabel(window:GetName() .. "Description", window, "ZoFontGame", "Pick a texture path for Icon Override. This writes an explicit icon path into the selected custom button.")
    window.description:SetAnchor(TOPLEFT, window.targetLabel, BOTTOMLEFT, 0, 10)
    window.description:SetWidth(720)

    window.filterLabel = CreatePopupLabel(window:GetName() .. "FilterLabel", window, "ZoFontGame", "Filter")
    window.filterLabel:SetAnchor(TOPLEFT, window.description, BOTTOMLEFT, 0, 18)
    window.filterBackdrop, window.filterEdit = CreatePopupBackdropEditBox(window:GetName() .. "Filter", window, 500, 30, 180)
    window.filterBackdrop:SetAnchor(TOPLEFT, window.filterLabel, BOTTOMLEFT, 0, 6)
    window.filterEdit:SetHandler("OnTextChanged", function(control)
        if window.isUpdatingFilterText then
            return
        end

        local state = self:GetTextureBrowserState()
        state.filter = tostring(control:GetText() or "")
        state.pageIndex = 1
        self:RefreshTextureBrowserControls()
    end)

    window.pageSizeLabel = CreatePopupLabel(window:GetName() .. "PageSizeLabel", window, "ZoFontGame", "Per Page")
    window.pageSizeCombo, window.pageSizeDropdown = CreatePopupComboBox(window:GetName() .. "PageSizeCombo", window, 170, 28)
    window.pageSizeCombo:SetAnchor(TOPLEFT, window.filterBackdrop, TOPRIGHT, 26, 0)
    window.pageSizeLabel:SetAnchor(BOTTOMLEFT, window.pageSizeCombo, TOPLEFT, 0, -4)
    ConfigurePopupComboBoxOverlay(window.pageSizeDropdown, 2)

    window.resultLabel = CreatePopupLabel(window:GetName() .. "ResultLabel", window, "ZoFontGame", "Textures")
    window.resultLabel:SetAnchor(TOPLEFT, window.filterBackdrop, BOTTOMLEFT, 0, 18)
    window.resultsList = CreatePopupResultsList(window:GetName() .. "ResultsList", window, 468)
    window.resultsList:SetAnchor(TOPLEFT, window.resultLabel, BOTTOMLEFT, 0, 6)

    window.pageInfoLabel = CreatePopupLabel(window:GetName() .. "PageInfoLabel", window, "ZoFontGame", "")
    window.pageInfoLabel:SetAnchor(TOPLEFT, window.resultsList, BOTTOMLEFT, 0, 10)
    window.pageInfoLabel:SetWidth(260)

    window.prevPageButton = CreatePopupButton(window:GetName() .. "PrevPageButton", window, "Previous", 100, 28)
    window.prevPageButton:SetAnchor(TOPRIGHT, window.resultsList, BOTTOMRIGHT, -108, 6)
    window.prevPageButton:SetHandler("OnClicked", function()
        if window.resultsList.onPageDelta then
            window.resultsList.onPageDelta(-1)
        end
    end)

    window.nextPageButton = CreatePopupButton(window:GetName() .. "NextPageButton", window, "Next", 100, 28)
    window.nextPageButton:SetAnchor(TOPRIGHT, window.resultsList, BOTTOMRIGHT, 0, 6)
    window.nextPageButton:SetHandler("OnClicked", function()
        if window.resultsList.onPageDelta then
            window.resultsList.onPageDelta(1)
        end
    end)

    window.previewSection = WINDOW_MANAGER:CreateControl(window:GetName() .. "PreviewSection", window, CT_CONTROL)
    window.previewSection:SetDimensions(244, 398)
    window.previewSection:SetAnchor(TOPLEFT, window.resultsList, TOPRIGHT, 20, 0)

    window.previewSectionBackdrop = WINDOW_MANAGER:CreateControl(window:GetName() .. "PreviewSectionBackdrop", window.previewSection, CT_BACKDROP)
    window.previewSectionBackdrop:SetAnchorFill()
    window.previewSectionBackdrop:SetCenterColor(0.06, 0.07, 0.10, 0.98)
    window.previewSectionBackdrop:SetEdgeColor(0.32, 0.30, 0.24, 1)

    window.previewSectionLabel = CreatePopupLabel(window:GetName() .. "PreviewSectionLabel", window.previewSection, "ZoFontGame", "Selected Texture")
    window.previewSectionLabel:SetAnchor(TOPLEFT, window.previewSection, TOPLEFT, 12, 12)

    window.previewBackdrop = WINDOW_MANAGER:CreateControl(window:GetName() .. "PreviewBackdrop", window.previewSection, CT_BACKDROP)
    window.previewBackdrop:SetDimensions(96, 96)
    window.previewBackdrop:SetAnchor(TOPLEFT, window.previewSectionLabel, BOTTOMLEFT, 0, 12)
    window.previewBackdrop:SetCenterColor(0.10, 0.11, 0.15, 0.98)
    window.previewBackdrop:SetEdgeColor(0.28, 0.28, 0.32, 1)

    window.previewTexture = WINDOW_MANAGER:CreateControl(window:GetName() .. "PreviewTexture", window.previewBackdrop, CT_TEXTURE)
    window.previewTexture:SetAnchorFill()

    window.selectionName = CreatePopupLabel(window:GetName() .. "SelectionName", window.previewSection, "ZoFontGameLargeBold", "")
    window.selectionName:SetAnchor(TOPLEFT, window.previewBackdrop, BOTTOMLEFT, 0, 18)
    window.selectionName:SetWidth(220)

    window.selectionInfo = CreatePopupLabel(window:GetName() .. "SelectionInfo", window.previewSection, "ZoFontGame", "")
    window.selectionInfo:SetAnchor(TOPLEFT, window.selectionName, BOTTOMLEFT, 0, 8)
    window.selectionInfo:SetWidth(220)

    window.applyButton = CreatePopupButton(window:GetName() .. "ApplyButton", window.previewSection, "Apply Texture", 112, 30)
    window.applyButton:SetAnchor(BOTTOMRIGHT, window.previewSection, BOTTOMRIGHT, -12, -12)
    window.applyButton:SetHandler("OnClicked", function()
        self:ApplySelectedTextureToCustomButton()
        self:CloseTextureBrowserPopup()
    end)

    window.clearButton = CreatePopupButton(window:GetName() .. "ClearButton", window.previewSection, "Clear Override", 112, 30)
    window.clearButton:SetAnchor(BOTTOMRIGHT, window.applyButton, BOTTOMLEFT, -10, 0)
    window.clearButton:SetHandler("OnClicked", function()
        self:ClearSelectedCustomButtonIconOverride()
    end)

    self.textureBrowserWindow = window
    return window
end

function ZeroPanel:OpenCollectibleBrowserPopup()
    if not self:GetSelectedCustomButtonData() then
        return
    end

    local state = self:GetCollectibleBrowserState()
    local currentCollectibleId = self:GetCollectibleIdFromCommand(self:GetSelectedCustomButtonData().command)
    if currentCollectibleId and currentCollectibleId > 0 then
        state.selectedCollectibleId = currentCollectibleId
    end

    local window = self:EnsureCollectibleBrowserPopup()
    self:RefreshCollectibleBrowserControls()
    window:SetHidden(false)
end

function ZeroPanel:CloseCollectibleBrowserPopup()
    if self.collectibleBrowserWindow then
        self.collectibleBrowserWindow:SetHidden(true)
    end
end

function ZeroPanel:OpenTextureBrowserPopup()
    local customButtonId = self:GetSelectedCustomButtonId()
    local customButtonData = self:GetSelectedCustomButtonData()
    if not customButtonId or not customButtonData then
        return
    end

    local state = self:GetTextureBrowserState()
    local currentTexturePath = TrimText(customButtonData.icon)
    if currentTexturePath == "" then
        currentTexturePath = TrimText(self:GetCustomButtonIcon(customButtonId))
    end
    state.selectedTexturePath = currentTexturePath

    local window = self:EnsureTextureBrowserPopup()
    self:RefreshTextureBrowserControls()
    window:SetHidden(false)
end

function ZeroPanel:CloseTextureBrowserPopup()
    if self.textureBrowserWindow then
        self.textureBrowserWindow:SetHidden(true)
    end
end

function ZeroPanel:ApplySelectedTextureToCustomButton()
    local customButtonData = self:GetSelectedCustomButtonData()
    local texturePath = TrimText(self:GetTextureBrowserState().selectedTexturePath)
    if not customButtonData or texturePath == "" then
        return
    end

    customButtonData.icon = texturePath
    self:RefreshPanel()
    self:RefreshCustomEditorControls()
end

function ZeroPanel:ClearSelectedCustomButtonIconOverride()
    local customButtonId = self:GetSelectedCustomButtonId()
    local customButtonData = self:GetSelectedCustomButtonData()
    if not customButtonId or not customButtonData then
        return
    end

    customButtonData.icon = ""
    self:GetTextureBrowserState().selectedTexturePath = TrimText(self:GetCustomButtonIcon(customButtonId))
    self:RefreshPanel()
    self:RefreshCustomEditorControls()
end

function ZeroPanel:GetCollectibleIdFromCommand(commandText)
    local collectibleId = tostring(commandText or ""):match("[Uu]seCollectible%s*%(%s*(%d+)")
    return tonumber(collectibleId)
end

function ZeroPanel:GetAutoCommandTitle(commandText)
    local command = TrimText(commandText)
    local lowerCommand = string.lower(command)
    if command == "" then
        return "Run Custom Command."
    end

    local collectibleId = self:GetCollectibleIdFromCommand(command)
    if collectibleId and GetCollectibleName(collectibleId) ~= "" then
        return string.format("Use %s.", self:GetCollectibleName(collectibleId))
    end

    if COMMAND_FRIENDLY_TITLES[lowerCommand] then
        return COMMAND_FRIENDLY_TITLES[lowerCommand]
    end

    if string.find(lowerCommand, "zo_compassframe:sethidden", 1, true) then
        return "Toggle Compass."
    elseif string.find(lowerCommand, "startchatinput('/w '..name", 1, true) then
        return "Whisper Current Target."
    elseif string.find(lowerCommand, "areanyitemsstolen", 1, true) then
        return "Check For Stolen Items."
    elseif string.find(lowerCommand, "selectslotability", 1, true) then
        return "Slot Purge."
    end

    local slashCommand = lowerCommand:match("^(%S+)")
    if slashCommand and COMMAND_FRIENDLY_TITLES[slashCommand] then
        return COMMAND_FRIENDLY_TITLES[slashCommand]
    elseif slashCommand then
        return string.format("Run %s.", slashCommand)
    end

    return "Run Custom Command."
end

function ZeroPanel:GetAutoCommandIcon(commandText)
    local command = TrimText(commandText)
    local lowerCommand = string.lower(command)
    local collectibleId = self:GetCollectibleIdFromCommand(command)

    if collectibleId then
        local collectibleIcon = GetCollectibleIcon(collectibleId)
        if collectibleIcon and collectibleIcon ~= "" then
            return collectibleIcon
        end
    end

    if COMMAND_ICON_OVERRIDES[lowerCommand] then
        return COMMAND_ICON_OVERRIDES[lowerCommand]
    end

    if string.find(lowerCommand, "zo_compassframe:sethidden", 1, true) then
        return "/esoui/art/icons/ability_rogue_062.dds"
    elseif string.find(lowerCommand, "startchatinput('/w '..name", 1, true) then
        return "/esoui/art/tutorial/chat-notifications_up.dds"
    end

    local slashCommand = lowerCommand:match("^(%S+)")
    return COMMAND_ICON_OVERRIDES[slashCommand] or CUSTOM_BUTTON_ACTIONS.command.icon
end

function ZeroPanel:ExecuteCommand(commandText)
    local command = TrimText(commandText)
    if command == "" then
        self:Print("That custom button does not have a command yet.")
        return
    end

    local collectibleId = self:GetCollectibleIdFromCommand(command)
    if collectibleId then
        if not IsCollectibleUnlocked(collectibleId) then
            self:Print(string.format("%s is not unlocked on this account.", self:GetCollectibleName(collectibleId)))
            return
        end

        UseCollectible(collectibleId, GAMEPLAY_ACTOR_CATEGORY_PLAYER)
        return
    end

    local slashCommand, argumentText = command:match("^(%S+)%s*(.-)$")
    local lowerSlashCommand = slashCommand and string.lower(slashCommand) or nil

    if lowerSlashCommand == "/reloadui" or lowerSlashCommand == "/rl" then
        ReloadUI()
        return
    end

    if lowerSlashCommand == "/script" then
        local loader = zo_loadstring or LoadString
        if type(loader) ~= "function" then
            self:Print("This client cannot execute /script commands from a custom button.")
            return
        end

        local compiledChunk, errorMessage = loader(argumentText or "")
        if type(compiledChunk) ~= "function" then
            self:Print(errorMessage or "The custom script could not be compiled.")
            return
        end

        local ok, runtimeError = pcall(compiledChunk)
        if not ok then
            self:Print(runtimeError or "The custom script failed to execute.")
        end
        return
    end

    local handler = slashCommand and (SLASH_COMMANDS[slashCommand] or SLASH_COMMANDS[lowerSlashCommand])
    if type(handler) == "function" then
        handler(argumentText or "")
        return
    end

    if type(DoCommand) == "function" then
        DoCommand(command)
        return
    end

    self:Print("Unable to execute that command in this client.")
end

function ZeroPanel:EnsureCustomButtons()
    self.savedVars.customButtons = self.savedVars.customButtons or {}
    self.savedVars.customSeparators = self.savedVars.customSeparators or {}

    local nextCustomButtonId = tonumber(self.savedVars.nextCustomButtonId) or 1
    for _, customButtonId in ipairs(GetSortedNumericKeys(self.savedVars.customButtons)) do
        local buttonData = self.savedVars.customButtons[customButtonId]
        buttonData.enabled = buttonData.enabled ~= false
        buttonData.actionType = buttonData.actionType or "command"
        buttonData.title = tostring(buttonData.title or "")
        buttonData.useAutoTitle = buttonData.useAutoTitle ~= false
        buttonData.icon = tostring(buttonData.icon or "")
        buttonData.command = tostring(buttonData.command or "")
        nextCustomButtonId = math.max(nextCustomButtonId, customButtonId + 1)
    end
    self.savedVars.nextCustomButtonId = nextCustomButtonId

    local nextCustomSeparatorId = tonumber(self.savedVars.nextCustomSeparatorId) or 1
    for _, customSeparatorId in ipairs(GetSortedNumericKeys(self.savedVars.customSeparators)) do
        local separatorData = self.savedVars.customSeparators[customSeparatorId]
        if type(separatorData) ~= "table" then
            separatorData = {}
            self.savedVars.customSeparators[customSeparatorId] = separatorData
        end
        separatorData.name = tostring(separatorData.name or string.format("Custom Separator %d", customSeparatorId))
        nextCustomSeparatorId = math.max(nextCustomSeparatorId, customSeparatorId + 1)
    end
    self.savedVars.nextCustomSeparatorId = nextCustomSeparatorId
end

function ZeroPanel:GetCustomButtonIds()
    return GetSortedNumericKeys(self.savedVars.customButtons)
end

function ZeroPanel:GetCustomSeparatorIds()
    return GetSortedNumericKeys(self.savedVars.customSeparators)
end

function ZeroPanel:GetSelectedCustomButtonId()
    if type(self.selectedCustomButtonId) == "number" and self.savedVars.customButtons[self.selectedCustomButtonId] then
        return self.selectedCustomButtonId
    end

    local customButtonIds = self:GetCustomButtonIds()
    self.selectedCustomButtonId = customButtonIds[1]
    return self.selectedCustomButtonId
end

function ZeroPanel:SetSelectedCustomButtonId(customButtonId)
    if type(customButtonId) == "number" and self.savedVars.customButtons[customButtonId] then
        self.selectedCustomButtonId = customButtonId
        self.selectedEditorLayoutKey = GetCustomButtonLayoutKey(customButtonId)
        self:SetSelectedLayoutOrderKey(self.selectedEditorLayoutKey)
    else
        if self.selectedEditorLayoutKey and string.find(self.selectedEditorLayoutKey, "^custom_button:", 1) then
            self.selectedEditorLayoutKey = nil
        end
        self.selectedCustomButtonId = nil
    end

    self:RefreshButtonOrderControlState()
end

function ZeroPanel:GetSelectedCustomButtonData()
    local customButtonId = self:GetSelectedCustomButtonId()
    return customButtonId and self.savedVars.customButtons[customButtonId] or nil
end

function ZeroPanel:GetSelectedCustomSeparatorId()
    if type(self.selectedCustomSeparatorId) == "number" and self.savedVars.customSeparators[self.selectedCustomSeparatorId] then
        return self.selectedCustomSeparatorId
    end

    local customSeparatorIds = self:GetCustomSeparatorIds()
    self.selectedCustomSeparatorId = customSeparatorIds[1]
    return self.selectedCustomSeparatorId
end

function ZeroPanel:SetSelectedCustomSeparatorId(customSeparatorId)
    if type(customSeparatorId) == "number" and self.savedVars.customSeparators[customSeparatorId] then
        self.selectedCustomSeparatorId = customSeparatorId
        self.selectedEditorLayoutKey = GetCustomSeparatorLayoutKey(customSeparatorId)
        self:SetSelectedLayoutOrderKey(self.selectedEditorLayoutKey)
    else
        if self.selectedEditorLayoutKey and string.find(self.selectedEditorLayoutKey, "^custom_separator:", 1) then
            self.selectedEditorLayoutKey = nil
        end
        self.selectedCustomSeparatorId = nil
    end

    self:RefreshButtonOrderControlState()
end

function ZeroPanel:GetCustomButtonAction(actionType)
    return CUSTOM_BUTTON_ACTIONS[actionType or "command"] or CUSTOM_BUTTON_ACTIONS.command
end

function ZeroPanel:GetCustomButtonResolvedTitle(customButtonId)
    local buttonData = self.savedVars.customButtons[customButtonId]
    if not buttonData then
        return "Custom Button."
    end

    local customTitle = TrimText(buttonData.title)
    if not buttonData.useAutoTitle and customTitle ~= "" then
        return customTitle
    end

    local action = self:GetCustomButtonAction(buttonData.actionType)
    if buttonData.actionType == "command" then
        return self:GetAutoCommandTitle(buttonData.command)
    elseif buttonData.actionType == "cycle_group_role" then
        local roleName = self:GetRoleName(GetSelectedLFGRole())
        if not CanUpdateSelectedLFGRole() then
            return string.format("Current Role: %s. Role Changes Are Unavailable Here.", roleName)
        end
        return string.format("Cycle Group Role. Current Role: %s.", roleName)
    elseif buttonData.actionType == "toggle_group_difficulty" then
        local difficultyName = self:GetDungeonDifficultyName()
        if not CanPlayerChangeGroupDifficulty() then
            return string.format("Current Difficulty: %s. Changes Are Unavailable Here.", difficultyName)
        end
        return string.format("Toggle Dungeon Difficulty. Current: %s.", difficultyName)
    elseif string.find(buttonData.actionType or "", "^summon_") then
        return self:GetSummonTooltip(buttonData.actionType)
    end

    return action.tooltip or action.name or "Custom Button."
end

function ZeroPanel:GetCustomButtonDisplayName(customButtonId)
    local buttonData = self.savedVars.customButtons[customButtonId]
    if not buttonData then
        return string.format("Custom Button %d", customButtonId)
    end

    local customTitle = TrimText(buttonData.title)
    if not buttonData.useAutoTitle and customTitle ~= "" then
        return string.format("Custom: %s", customTitle:gsub("%.$", ""))
    end

    local labelText
    if buttonData.actionType == "command" then
        labelText = tostring(self:GetAutoCommandTitle(buttonData.command) or ""):gsub("%.$", "")
    else
        local action = self:GetCustomButtonAction(buttonData.actionType)
        labelText = tostring((action and action.name) or "Custom Button")
    end

    if labelText == "" then
        labelText = string.format("Custom Button %d", customButtonId)
    end

    return string.format("Custom: %s", labelText)
end

function ZeroPanel:GetCustomButtonIcon(customButtonId)
    local buttonData = self.savedVars.customButtons[customButtonId]
    if not buttonData then
        return CUSTOM_BUTTON_ACTIONS.command.icon
    end

    local customIcon = TrimText(buttonData.icon)
    if customIcon ~= "" then
        return customIcon
    end

    if buttonData.actionType == "command" then
        return self:GetAutoCommandIcon(buttonData.command)
    end

    local action = self:GetCustomButtonAction(buttonData.actionType)
    if type(action.icon) == "function" then
        return action.icon(self, buttonData)
    end

    return action.icon or CUSTOM_BUTTON_ACTIONS.command.icon
end

function ZeroPanel:IsCustomButtonUsable(customButtonId)
    local buttonData = self.savedVars.customButtons[customButtonId]
    if not buttonData or buttonData.enabled == false then
        return false
    end

    if buttonData.actionType == "command" then
        local command = TrimText(buttonData.command)
        if command == "" then
            return false
        end

        local collectibleId = self:GetCollectibleIdFromCommand(command)
        if collectibleId then
            return IsCollectibleUnlocked(collectibleId)
        end

        return true
    elseif buttonData.actionType == "cycle_group_role" then
        return CanUpdateSelectedLFGRole()
    elseif buttonData.actionType == "toggle_group_difficulty" then
        return CanPlayerChangeGroupDifficulty()
    elseif buttonData.actionType == "dismiss_combat_pets" then
        return self:HasDismissablePet()
    elseif string.find(buttonData.actionType or "", "^summon_") then
        if buttonData.actionType == "summon_ally" then
            return self:GetSelectedCollectibleId("summon_ally") ~= nil
        end
        return self:GetSelectedCollectibleId(buttonData.actionType) ~= nil
    end

    return true
end

function ZeroPanel:IsCustomButtonActive(customButtonId)
    local buttonData = self.savedVars.customButtons[customButtonId]
    if not buttonData then
        return false
    end

    if buttonData.actionType == "cycle_group_role" then
        return CanUpdateSelectedLFGRole()
    elseif buttonData.actionType == "toggle_group_difficulty" then
        return self:IsVeteranDungeonDifficulty()
    elseif string.find(buttonData.actionType or "", "^summon_") then
        return false
    end

    local collectibleId = self:GetCollectibleIdFromCommand(buttonData.command)
    if collectibleId then
        local categoryType = GetCollectibleCategoryType(collectibleId)
        local activeCollectibleId = categoryType and GetActiveCollectibleByType(categoryType, GAMEPLAY_ACTOR_CATEGORY_PLAYER)
        return activeCollectibleId == collectibleId
    end

    return false
end

function ZeroPanel:ExecuteCustomButton(customButtonId)
    local buttonData = self.savedVars.customButtons[customButtonId]
    if not buttonData then
        return
    end

    if buttonData.actionType == "command" then
        self:ExecuteCommand(buttonData.command)
    elseif buttonData.actionType == "open_settings" then
        self:OpenSettings()
    elseif buttonData.actionType == "reload_ui" then
        ReloadUI()
    elseif buttonData.actionType == "cycle_group_role" then
        self:CycleGroupRole()
    elseif buttonData.actionType == "toggle_group_difficulty" then
        self:ToggleGroupDifficulty()
    elseif buttonData.actionType == "dismiss_combat_pets" then
        self:DismissCombatPets()
    elseif string.find(buttonData.actionType or "", "^summon_") then
        self:UseConfiguredCollectible(buttonData.actionType)
    end
end

function ZeroPanel:ExecuteButtonDefinition(definition)
    if not definition or not self:IsButtonEnabledBySettings(definition) or not self:IsButtonUsable(definition) then
        return false
    end

    if type(definition.click) ~= "function" then
        return false
    end

    definition.click(self)
    self:RefreshPanel()
    self:QueueHoveredTooltipRefresh()
    return true
end

function ZeroPanel:ExecuteKeybindSlot(keybindSlot)
    local resolvedKeybindSlot = tonumber(keybindSlot)
    if not resolvedKeybindSlot or resolvedKeybindSlot < 1 or resolvedKeybindSlot > ZERO_PANEL_KEYBIND_SLOT_COUNT then
        return false
    end

    local layoutKey = self:GetLayoutKeyForKeybindSlot(resolvedKeybindSlot)
    if type(layoutKey) ~= "string" or layoutKey == "" then
        return false
    end

    local entry = self:GetLayoutCatalogByKey()[layoutKey]
    if not self:IsLayoutEntryBindable(entry) then
        self:RemoveKeybindForLayoutKey(layoutKey)
        return false
    end

    return self:ExecuteButtonDefinition(entry.definition)
end

function ZeroPanel:CollectibleListContainsId(collectibleIds, collectibleId)
    if type(collectibleId) ~= "number" or collectibleId <= 0 then
        return false
    end

    for _, candidateId in ipairs(collectibleIds or {}) do
        if candidateId == collectibleId then
            return true
        end
    end

    return false
end

function ZeroPanel:GetSummonableSpecializedCollectibleType(actionId)
    local summonable = SUMMONABLES[actionId]
    if not summonable or type(GetSpecializedCollectibleType) ~= "function" then
        return nil
    end

    if summonable.specializedType ~= nil then
        return summonable.specializedType or nil
    end

    for _, collectibleId in ipairs(summonable.ids or {}) do
        local specializedType = GetSpecializedCollectibleType(collectibleId)
        if type(specializedType) == "number" and (not SPECIALIZED_COLLECTIBLE_TYPE_NONE or specializedType ~= SPECIALIZED_COLLECTIBLE_TYPE_NONE) then
            summonable.specializedType = specializedType
            return specializedType
        end
    end

    summonable.specializedType = false
    return nil
end

function ZeroPanel:GetCollectiblesForSummonAction(actionId)
    local summonable = SUMMONABLES[actionId]
    local collectibleIds = {}
    if not summonable then
        return collectibleIds
    end

    if summonable.useCollectibleCategoryList and summonable.categoryType and type(GetTotalCollectiblesByCategoryType) == "function" and type(GetCollectibleIdFromType) == "function" then
        local specializedType = self:GetSummonableSpecializedCollectibleType(actionId)
        if not summonable.requiresSpecializedCollectibleType or specializedType ~= nil then
            local totalCollectibles = GetTotalCollectiblesByCategoryType(summonable.categoryType) or 0
            local seenCollectibleIds = {}

            for collectibleIndex = 1, totalCollectibles do
                local collectibleId = GetCollectibleIdFromType(summonable.categoryType, collectibleIndex)
                if collectibleId and collectibleId > 0 and not seenCollectibleIds[collectibleId] then
                    local includeCollectible = true
                    if specializedType ~= nil and type(GetSpecializedCollectibleType) == "function" then
                        includeCollectible = GetSpecializedCollectibleType(collectibleId) == specializedType
                    end

                    if includeCollectible then
                        collectibleIds[#collectibleIds + 1] = collectibleId
                        seenCollectibleIds[collectibleId] = true
                    end
                end
            end

            if #collectibleIds > 0 then
                local orderedCollectibleIds = {}
                local orderedSet = {}
                for _, knownCollectibleId in ipairs(summonable.ids or {}) do
                    if seenCollectibleIds[knownCollectibleId] then
                        orderedCollectibleIds[#orderedCollectibleIds + 1] = knownCollectibleId
                        orderedSet[knownCollectibleId] = true
                    end
                end

                for _, collectibleId in ipairs(collectibleIds) do
                    if not orderedSet[collectibleId] then
                        orderedCollectibleIds[#orderedCollectibleIds + 1] = collectibleId
                    end
                end

                return orderedCollectibleIds
            end
        end
    end

    for _, collectibleId in ipairs(summonable.ids or {}) do
        if collectibleId and collectibleId > 0 then
            collectibleIds[#collectibleIds + 1] = collectibleId
        end
    end

    return collectibleIds
end

function ZeroPanel:GetUnlockedCollectibles(actionId)
    local unlocked = {}

    for _, collectibleId in ipairs(self:GetCollectiblesForSummonAction(actionId)) do
        if IsCollectibleUnlocked(collectibleId) then
            unlocked[#unlocked + 1] = collectibleId
        end
    end

    return unlocked
end

function ZeroPanel:HasUnlockedCollectible(actionId)
    return #self:GetUnlockedCollectibles(actionId) > 0
end

function ZeroPanel:GetCollectibleChoice(actionId)
    local summonable = SUMMONABLES[actionId]
    if not summonable then
        return nil
    end

    local defaultChoiceValue = summonable.defaultChoiceValue
    if type(defaultChoiceValue) ~= "number" then
        defaultChoiceValue = DEFAULT_COLLECTIBLE_CHOICE
    end

    self.savedVars.collectibleChoices = self.savedVars.collectibleChoices or {}
    local choice = self.savedVars.collectibleChoices[actionId]
    if choice == nil then
        choice = DEFAULTS.collectibleChoices[actionId]
        if type(choice) ~= "number" then
            choice = defaultChoiceValue
        end
        self.savedVars.collectibleChoices[actionId] = choice
    end

    if summonable.randomChoice and choice == DEFAULT_COLLECTIBLE_CHOICE and defaultChoiceValue == RANDOM_COLLECTIBLE_CHOICE then
        choice = defaultChoiceValue
        self.savedVars.collectibleChoices[actionId] = choice
    end

    if choice ~= DEFAULT_COLLECTIBLE_CHOICE and choice ~= RANDOM_COLLECTIBLE_CHOICE and not self:CollectibleListContainsId(self:GetUnlockedCollectibles(actionId), choice) then
        choice = DEFAULTS.collectibleChoices[actionId]
        if type(choice) ~= "number" then
            choice = defaultChoiceValue
        end
        self.savedVars.collectibleChoices[actionId] = choice
    end

    return choice
end

function ZeroPanel:GetCollectibleChoiceEntries(actionId)
    local summonable = SUMMONABLES[actionId]
    local choices = {}
    local choiceValues = {}
    if not summonable then
        return choices, choiceValues
    end

    local defaultChoiceValue = summonable.defaultChoiceValue
    if type(defaultChoiceValue) ~= "number" then
        defaultChoiceValue = DEFAULT_COLLECTIBLE_CHOICE
    end

    choices[1] = summonable.defaultChoiceLabel
    choiceValues[1] = defaultChoiceValue

    local baseOffset = 1
    if summonable.randomChoice and type(summonable.randomChoiceLabel) == "string" and summonable.randomChoiceLabel ~= "" then
        choices[2] = summonable.randomChoiceLabel
        choiceValues[2] = RANDOM_COLLECTIBLE_CHOICE
        baseOffset = 2
    end

    local unlocked = self:GetUnlockedCollectibles(actionId)
    for index, collectibleId in ipairs(unlocked) do
        choices[index + baseOffset] = self:GetCollectibleName(collectibleId)
        choiceValues[index + baseOffset] = collectibleId
    end

    return choices, choiceValues
end

function ZeroPanel:GetActiveCollectibleForAction(actionId)
    local summonable = SUMMONABLES[actionId]
    if not summonable or not summonable.categoryType then
        return nil
    end

    local activeCollectibleId = GetActiveCollectibleByType(summonable.categoryType, GAMEPLAY_ACTOR_CATEGORY_PLAYER)
    if type(activeCollectibleId) == "number" and activeCollectibleId > 0 then
        return activeCollectibleId
    end

    return nil
end

function ZeroPanel:GetSelectedCollectibleId(actionId)
    local summonable = SUMMONABLES[actionId]
    if not summonable then
        return nil
    end

    local unlocked = self:GetUnlockedCollectibles(actionId)
    if #unlocked == 0 then
        return nil
    end

    local choice = self:GetCollectibleChoice(actionId)
    if choice ~= DEFAULT_COLLECTIBLE_CHOICE and choice ~= RANDOM_COLLECTIBLE_CHOICE and self:CollectibleListContainsId(unlocked, choice) then
        return choice
    end

    if summonable.randomChoice and choice == RANDOM_COLLECTIBLE_CHOICE then
        local candidates = unlocked
        local activeCollectibleId = self:GetActiveCollectibleForAction(actionId)
        if #unlocked > 1 and activeCollectibleId then
            candidates = {}
            for _, collectibleId in ipairs(unlocked) do
                if collectibleId ~= activeCollectibleId then
                    candidates[#candidates + 1] = collectibleId
                end
            end
            if #candidates == 0 then
                candidates = unlocked
            end
        end

        return candidates[math.random(#candidates)]
    end

    return unlocked[1]
end

function ZeroPanel:GetPreviewCollectibleId(actionId)
    local summonable = SUMMONABLES[actionId]
    if not summonable then
        return nil
    end

    local unlocked = self:GetUnlockedCollectibles(actionId)
    if #unlocked == 0 then
        return nil
    end

    local choice = self:GetCollectibleChoice(actionId)
    if choice ~= DEFAULT_COLLECTIBLE_CHOICE and choice ~= RANDOM_COLLECTIBLE_CHOICE and self:CollectibleListContainsId(unlocked, choice) then
        return choice
    end

    local activeCollectibleId = self:GetActiveCollectibleForAction(actionId)
    if activeCollectibleId and self:CollectibleListContainsId(unlocked, activeCollectibleId) then
        return activeCollectibleId
    end

    return unlocked[1]
end

function ZeroPanel:ShouldShowSummonableCollectibleIcons()
    return self.savedVars.showSummonableCollectibleIcons ~= false
end

function ZeroPanel:GetSummonableButtonIcon(actionId, fallbackIcon)
    if not self:ShouldShowSummonableCollectibleIcons() then
        return fallbackIcon
    end

    local collectibleId = self:GetPreviewCollectibleId(actionId)
    if collectibleId and type(GetCollectibleIcon) == "function" then
        local collectibleIcon = GetCollectibleIcon(collectibleId)
        if collectibleIcon and collectibleIcon ~= "" then
            return collectibleIcon
        end
    end

    return fallbackIcon
end

function ZeroPanel:GetSummonTooltip(actionId)
    local summonable = SUMMONABLES[actionId]
    if not summonable then
        return "Summon NPC."
    end

    local choice = self:GetCollectibleChoice(actionId)
    if summonable.randomChoice and choice == RANDOM_COLLECTIBLE_CHOICE then
        return summonable.randomTooltip or summonable.buttonTooltip
    end

    if choice ~= DEFAULT_COLLECTIBLE_CHOICE and choice ~= RANDOM_COLLECTIBLE_CHOICE and IsCollectibleUnlocked(choice) then
        return string.format("%s: %s.", summonable.tooltipPrefix, self:GetCollectibleName(choice))
    end

    return summonable.buttonTooltip
end

function ZeroPanel:UseConfiguredCollectible(actionId)
    local summonable = SUMMONABLES[actionId]
    local collectibleId = self:GetSelectedCollectibleId(actionId)
    if not collectibleId then
        self:Print((summonable and summonable.emptyText) or "No unlocked summonable NPC is available for that action.")
        return
    end

    local activeCollectibleId = self:GetActiveCollectibleForAction(actionId)
    if activeCollectibleId == collectibleId then
        self:Print(string.format("%s is already active.", self:GetCollectibleName(collectibleId)))
        return
    end

    UseCollectible(collectibleId, GAMEPLAY_ACTOR_CATEGORY_PLAYER)
end

function ZeroPanel:HasDismissablePet()
    for buffIndex = 1, GetNumBuffs("player") do
        local _, _, _, buffSlot, _, _, _, _, _, _, abilityId = GetUnitBuffInfo("player", buffIndex)
        if PET_BUFF_IDS[abilityId] and buffSlot then
            return true
        end
    end

    return false
end

function ZeroPanel:DismissCombatPets()
    local dismissedAny = false

    for buffIndex = 1, GetNumBuffs("player") do
        local _, _, _, buffSlot, _, _, _, _, _, _, abilityId = GetUnitBuffInfo("player", buffIndex)
        if PET_BUFF_IDS[abilityId] and buffSlot then
            CancelBuff(buffSlot)
            dismissedAny = true
        end
    end

    if not dismissedAny then
        self:Print("No dismissable combat pets are active.")
    end
end

function ZeroPanel:CycleGroupRole()
    if not CanUpdateSelectedLFGRole() then
        return
    end

    local currentRole = GetSelectedLFGRole()
    local nextRole = ROLE_ORDER[1]

    for index, role in ipairs(ROLE_ORDER) do
        if role == currentRole then
            nextRole = ROLE_ORDER[(index % #ROLE_ORDER) + 1]
            break
        end
    end

    UpdateSelectedLFGRole(nextRole)
end

function ZeroPanel:ToggleGroupDifficulty()
    if not CanPlayerChangeGroupDifficulty() then
        return
    end

    SetVeteranDifficulty(not self:IsVeteranDungeonDifficulty())
end

function ZeroPanel:GetCurrentDungeonDifficulty()
    if type(ZO_GetEffectiveDungeonDifficulty) == "function" then
        local dungeonDifficulty = ZO_GetEffectiveDungeonDifficulty()
        if dungeonDifficulty ~= nil then
            return dungeonDifficulty
        end
    end

    local isVeteran = IsUnitUsingVeteranDifficulty("player")
    if isVeteran == true or isVeteran == 1 then
        return DUNGEON_DIFFICULTY_VETERAN
    end

    return DUNGEON_DIFFICULTY_NORMAL
end

function ZeroPanel:IsVeteranDungeonDifficulty()
    return self:GetCurrentDungeonDifficulty() == DUNGEON_DIFFICULTY_VETERAN
end

function ZeroPanel:GetDungeonDifficultyName()
    return self:IsVeteranDungeonDifficulty() and "Veteran" or "Normal"
end

function ZeroPanel:GetCatalog()
    return BUTTON_DEFINITIONS
end

function ZeroPanel:GetCatalogByKey()
    local buttonsByKey = {}

    for _, definition in ipairs(self:GetCatalog()) do
        buttonsByKey[definition.uniqueKey] = definition
    end

    return buttonsByKey
end

function ZeroPanel:CreateCustomButtonDefinition(customButtonId)
    if not self.savedVars.customButtons[customButtonId] then
        return nil
    end

    return {
        id = GetCustomButtonLayoutKey(customButtonId),
        uniqueKey = GetCustomButtonLayoutKey(customButtonId),
        name = self:GetCustomButtonDisplayName(customButtonId),
        isCustom = true,
        customButtonId = customButtonId,
        icon = function()
            return self:GetCustomButtonIcon(customButtonId)
        end,
        tooltip = function()
            return self:GetCustomButtonResolvedTitle(customButtonId)
        end,
        isUsable = function()
            return self:IsCustomButtonUsable(customButtonId)
        end,
        isActive = function()
            return self:IsCustomButtonActive(customButtonId)
        end,
        click = function(panel)
            panel:ExecuteCustomButton(customButtonId)
        end,
    }
end

function ZeroPanel:GetLayoutCatalog()
    local layoutCatalog = {}

    for _, definition in ipairs(self:GetCatalog()) do
        layoutCatalog[#layoutCatalog + 1] = {
            key = GetDefaultButtonLayoutKey(definition.uniqueKey),
            orderUniqueKey = definition.uniqueKey,
            kind = "button",
            name = definition.name,
            definition = definition,
            builtin = true,
        }
    end

    for _, separatorDefinition in ipairs(DEFAULT_SEPARATOR_DEFINITIONS) do
        layoutCatalog[#layoutCatalog + 1] = {
            key = separatorDefinition.key,
            orderUniqueKey = separatorDefinition.orderUniqueKey,
            kind = "separator",
            name = separatorDefinition.name,
            tooltip = separatorDefinition.tooltip,
            builtin = true,
        }
    end

    for _, customButtonId in ipairs(self:GetCustomButtonIds()) do
        local definition = self:CreateCustomButtonDefinition(customButtonId)
        if definition then
            layoutCatalog[#layoutCatalog + 1] = {
                key = GetCustomButtonLayoutKey(customButtonId),
                orderUniqueKey = GetCustomButtonOrderUniqueKey(customButtonId),
                kind = "button",
                name = definition.name,
                definition = definition,
                custom = true,
                customButtonId = customButtonId,
            }
        end
    end

    for _, customSeparatorId in ipairs(self:GetCustomSeparatorIds()) do
        local separatorData = self.savedVars.customSeparators[customSeparatorId]
        layoutCatalog[#layoutCatalog + 1] = {
            key = GetCustomSeparatorLayoutKey(customSeparatorId),
            orderUniqueKey = GetCustomSeparatorOrderUniqueKey(customSeparatorId),
            kind = "separator",
            name = (separatorData and separatorData.name) or string.format("Custom Separator %d", customSeparatorId),
            tooltip = "Insert a horizontal separator line at this point in the panel layout.",
            custom = true,
            customSeparatorId = customSeparatorId,
        }
    end

    return layoutCatalog
end

function ZeroPanel:GetLayoutCatalogByKey()
    local entriesByKey = {}

    for _, entry in ipairs(self:GetLayoutCatalog()) do
        entriesByKey[entry.key] = entry
    end

    return entriesByKey
end

function ZeroPanel:EnsureCollectibleChoices()
    self.savedVars.collectibleChoices = self.savedVars.collectibleChoices or {}
    for _, actionId in ipairs(SUMMONABLE_ACTION_ORDER) do
        if self.savedVars.collectibleChoices[actionId] == nil then
            self.savedVars.collectibleChoices[actionId] = DEFAULTS.collectibleChoices[actionId] or DEFAULT_COLLECTIBLE_CHOICE
        end
    end
end

function ZeroPanel:EnsureKeybindDisplaySettings()
    self.savedVars.keybindDisplay = self.savedVars.keybindDisplay or {}

    local settings = self.savedVars.keybindDisplay
    if settings.enabled == nil then
        settings.enabled = DEFAULTS.keybindDisplay.enabled
    end

    settings.anchorPoint = NormalizeKeybindAnchorPoint(settings.anchorPoint)
    settings.offsetX = ClampNumber(tonumber(settings.offsetX) or DEFAULTS.keybindDisplay.offsetX, -100, 100)
    settings.offsetY = ClampNumber(tonumber(settings.offsetY) or DEFAULTS.keybindDisplay.offsetY, -100, 100)
    settings.fontPath = NormalizeFontPath(settings.fontPath)
    if type(settings.fontPath) ~= "string" or settings.fontPath == "" then
        settings.fontPath = DEFAULT_KEYBIND_FONT_PATH
    end

    settings.fontSize = ClampNumber(math.floor(tonumber(settings.fontSize) or DEFAULTS.keybindDisplay.fontSize), 8, 36)
    if settings.fontEffect == "normal" then
        settings.fontEffect = "none"
    elseif not IsValidKeybindFontEffect(settings.fontEffect) then
        settings.fontEffect = DEFAULT_KEYBIND_FONT_EFFECT
    end

    if settings.colorizeModifiers == nil then
        settings.colorizeModifiers = DEFAULTS.keybindDisplay.colorizeModifiers
    end

    if type(settings.textColor) ~= "table" then
        settings.textColor = {
            DEFAULT_KEYBIND_TEXT_COLOR[1],
            DEFAULT_KEYBIND_TEXT_COLOR[2],
            DEFAULT_KEYBIND_TEXT_COLOR[3],
            DEFAULT_KEYBIND_TEXT_COLOR[4],
        }
    else
        settings.textColor[1] = ClampNumber(tonumber(settings.textColor[1]) or DEFAULT_KEYBIND_TEXT_COLOR[1], 0, 1)
        settings.textColor[2] = ClampNumber(tonumber(settings.textColor[2]) or DEFAULT_KEYBIND_TEXT_COLOR[2], 0, 1)
        settings.textColor[3] = ClampNumber(tonumber(settings.textColor[3]) or DEFAULT_KEYBIND_TEXT_COLOR[3], 0, 1)
        settings.textColor[4] = ClampNumber(tonumber(settings.textColor[4]) or DEFAULT_KEYBIND_TEXT_COLOR[4], 0, 1)
    end

    if settings.showBackground == nil then
        settings.showBackground = DEFAULTS.keybindDisplay.showBackground
    end

    if settings.showBackgroundBorder == nil then
        settings.showBackgroundBorder = DEFAULTS.keybindDisplay.showBackgroundBorder
    end

    if type(settings.backgroundColor) ~= "table" then
        settings.backgroundColor = {
            DEFAULT_KEYBIND_BACKGROUND_COLOR[1],
            DEFAULT_KEYBIND_BACKGROUND_COLOR[2],
            DEFAULT_KEYBIND_BACKGROUND_COLOR[3],
            DEFAULT_KEYBIND_BACKGROUND_COLOR[4],
        }
    else
        settings.backgroundColor[1] = ClampNumber(tonumber(settings.backgroundColor[1]) or DEFAULT_KEYBIND_BACKGROUND_COLOR[1], 0, 1)
        settings.backgroundColor[2] = ClampNumber(tonumber(settings.backgroundColor[2]) or DEFAULT_KEYBIND_BACKGROUND_COLOR[2], 0, 1)
        settings.backgroundColor[3] = ClampNumber(tonumber(settings.backgroundColor[3]) or DEFAULT_KEYBIND_BACKGROUND_COLOR[3], 0, 1)
        settings.backgroundColor[4] = ClampNumber(tonumber(settings.backgroundColor[4]) or DEFAULT_KEYBIND_BACKGROUND_COLOR[4], 0, 1)
    end

    settings.backgroundOpacity = ClampNumber(math.floor(tonumber(settings.backgroundOpacity) or DEFAULT_KEYBIND_BACKGROUND_OPACITY), 0, 100)

    settings.modifierColors = settings.modifierColors or {}
    for modifierId, defaultColor in pairs(DEFAULT_KEYBIND_MODIFIER_COLORS) do
        local color = settings.modifierColors[modifierId]
        if type(color) ~= "table" then
            settings.modifierColors[modifierId] = {defaultColor[1], defaultColor[2], defaultColor[3], defaultColor[4]}
        else
            settings.modifierColors[modifierId][1] = ClampNumber(tonumber(color[1]) or defaultColor[1], 0, 1)
            settings.modifierColors[modifierId][2] = ClampNumber(tonumber(color[2]) or defaultColor[2], 0, 1)
            settings.modifierColors[modifierId][3] = ClampNumber(tonumber(color[3]) or defaultColor[3], 0, 1)
            settings.modifierColors[modifierId][4] = ClampNumber(tonumber(color[4]) or defaultColor[4], 0, 1)
        end
    end
end

function ZeroPanel:GetKeybindDisplaySettings()
    self:EnsureKeybindDisplaySettings()
    return self.savedVars.keybindDisplay
end

function ZeroPanel:GetKeybindTextColor()
    local settings = self:GetKeybindDisplaySettings()
    local color = settings.textColor
    if type(color) ~= "table" then
        return DEFAULT_KEYBIND_TEXT_COLOR
    end

    return color
end

function ZeroPanel:GetKeybindBackgroundColor()
    local settings = self:GetKeybindDisplaySettings()
    local color = settings.backgroundColor
    if type(color) ~= "table" then
        return DEFAULT_KEYBIND_BACKGROUND_COLOR
    end

    return color
end

function ZeroPanel:GetKeybindFontChoices()
    return BuildKeybindFontChoices(self.savedVars)
end

function ZeroPanel:RefreshKeybindFontChoices()
    if not self.savedVars then
        return
    end

    local choices, values = self:GetKeybindFontChoices()
    self.keybindFontChoices = choices
    self.keybindFontValues = values
    self:UpdateDropdownReference("ZeroPanelKeybindDisplayFontDropdown", choices, values, NormalizeFontPath(self:GetKeybindDisplaySettings().fontPath))
end

function ZeroPanel:InvalidateKeybindDisplayCache()
    self.keybindDisplayTextCache = nil
    self.keybindDisplayTextCacheSignature = nil
end

function ZeroPanel:EnsureKeybindAssignments()
    self.savedVars.keybindAssignments = self.savedVars.keybindAssignments or {}

    local layoutByKey = self:GetLayoutCatalogByKey()
    local normalizedAssignments = {}
    local seenSlots = {}
    local orderedLayoutKeys = {}
    local seenLayoutKeys = {}

    local function AddLayoutKey(layoutKey)
        if type(layoutKey) == "string" and layoutByKey[layoutKey] and not seenLayoutKeys[layoutKey] then
            orderedLayoutKeys[#orderedLayoutKeys + 1] = layoutKey
            seenLayoutKeys[layoutKey] = true
        end
    end

    for _, entryKey in ipairs(self.savedVars.order or {}) do
        local normalizedKey
        if type(entryKey) == "number" then
            normalizedKey = GetDefaultButtonLayoutKey(entryKey)
        elseif type(entryKey) == "string" then
            normalizedKey = entryKey
        end

        AddLayoutKey(normalizedKey)
    end

    for layoutKey in pairs(self.savedVars.keybindAssignments) do
        AddLayoutKey(layoutKey)
    end

    for _, layoutKey in ipairs(orderedLayoutKeys) do
        local slot = math.floor(tonumber(self.savedVars.keybindAssignments[layoutKey]) or ZERO_PANEL_KEYBIND_NONE_VALUE)
        local entry = layoutByKey[layoutKey]
        if entry and entry.kind == "button" and slot >= 1 and slot <= ZERO_PANEL_KEYBIND_SLOT_COUNT and not seenSlots[slot] then
            normalizedAssignments[layoutKey] = slot
            seenSlots[slot] = true
        end
    end

    self.savedVars.keybindAssignments = normalizedAssignments
end

function ZeroPanel:EnsureOrder()
    local seen = {}
    local merged = {}
    local layoutByKey = self:GetLayoutCatalogByKey()

    for _, entryKey in ipairs(self.savedVars.order or {}) do
        local normalizedKey
        if type(entryKey) == "number" then
            normalizedKey = GetDefaultButtonLayoutKey(entryKey)
        elseif type(entryKey) == "string" then
            normalizedKey = entryKey
        end

        if normalizedKey and layoutByKey[normalizedKey] then
            AddUniqueValue(merged, seen, normalizedKey)
        end
    end

    for _, entryKey in ipairs(DEFAULT_LAYOUT_ORDER) do
        if layoutByKey[entryKey] then
            AddUniqueValue(merged, seen, entryKey)
        end
    end

    for _, customButtonId in ipairs(self:GetCustomButtonIds()) do
        AddUniqueValue(merged, seen, GetCustomButtonLayoutKey(customButtonId))
    end

    for _, customSeparatorId in ipairs(self:GetCustomSeparatorIds()) do
        AddUniqueValue(merged, seen, GetCustomSeparatorLayoutKey(customSeparatorId))
    end

    self.savedVars.order = merged
end

function ZeroPanel:IsButtonEnabledBySettings(definition)
    if definition.isCustom and definition.customButtonId then
        local buttonData = self.savedVars.customButtons[definition.customButtonId]
        return buttonData and buttonData.enabled ~= false
    end

    return self.savedVars.buttons[definition.id] ~= false
end

function ZeroPanel:ShouldDisplayButton(definition)
    if not self:IsButtonEnabledBySettings(definition) then
        return false
    end

    if definition.hideWhenUnavailable and definition.collectibleActionId then
        return self:HasUnlockedCollectible(definition.collectibleActionId)
    end

    return true
end

function ZeroPanel:IsButtonUsable(definition)
    if type(definition.isUsable) == "function" then
        return definition.isUsable()
    elseif definition.isUsable ~= nil then
        return definition.isUsable
    end

    return true
end

function ZeroPanel:IsButtonActive(definition)
    if type(definition.isActive) == "function" then
        return definition.isActive()
    elseif definition.isActive ~= nil then
        return definition.isActive
    end

    return false
end

function ZeroPanel:GetButtonIcon(definition)
    if type(definition.icon) == "function" then
        return definition.icon()
    end

    return definition.icon
end

function ZeroPanel:GetKeybindTooltipTextForLayoutEntry(entry)
    if not self:IsLayoutEntryBindable(entry) then
        return nil
    end

    local keybindSlot = self:GetKeybindSlotForLayoutKey(entry.key)
    if keybindSlot == ZERO_PANEL_KEYBIND_NONE_VALUE then
        return "|c7E8593Unbound|r"
    end

    local actionName = GetZeroPanelKeybindActionName(keybindSlot)
    local keyCode, mod1, mod2, mod3, mod4 = self:GetActionBindingInfoFromActionName(actionName)
    if not IsBoundKeyCode(keyCode) then
        return "|c7E8593Unbound|r"
    end

    local keyLabel = GetVerboseKeybindKeyName(GetKeyCodeDisplayName(keyCode))
    if keyLabel == "" then
        return "|c7E8593Unbound|r"
    end

    local keyColorHex = GetColorHexFromColorTable(self:GetKeybindTextColor())
    local modifierKeyCodes = {mod1, mod2, mod3, mod4}
    local seenModifiers = {}
    local seenUnknownModifierLabels = {}
    local unknownModifierLabels = {}

    for _, modifierKeyCode in ipairs(modifierKeyCodes) do
        if IsBoundKeyCode(modifierKeyCode) then
            local modifierId
            if modifierKeyCode == KEY_CTRL then
                modifierId = "ctrl"
            elseif modifierKeyCode == KEY_SHIFT then
                modifierId = "shift"
            elseif modifierKeyCode == KEY_ALT then
                modifierId = "alt"
            elseif modifierKeyCode == KEY_COMMAND then
                modifierId = "command"
            end

            if modifierId then
                seenModifiers[modifierId] = true
            else
                local unknownLabel = GetVerboseKeybindKeyName(GetKeyCodeDisplayName(modifierKeyCode))
                if unknownLabel ~= "" and not seenUnknownModifierLabels[unknownLabel] then
                    seenUnknownModifierLabels[unknownLabel] = true
                    unknownModifierLabels[#unknownModifierLabels + 1] = unknownLabel
                end
            end
        end
    end

    local formattedModifierParts = {}
    local function AddModifierPart(modifierId, fullLabel)
        if not seenModifiers[modifierId] then
            return
        end

        formattedModifierParts[#formattedModifierParts + 1] = string.format(
            "|c%s%s|r",
            GetColorHexFromColorTable(self:GetKeybindModifierColor(modifierId)),
            fullLabel
        )
    end

    AddModifierPart("ctrl", "CTRL")
    AddModifierPart("shift", "SHIFT")
    AddModifierPart("alt", "ALT")
    AddModifierPart("command", "COMMAND")

    for _, unknownLabel in ipairs(unknownModifierLabels) do
        formattedModifierParts[#formattedModifierParts + 1] = string.format("|c%s%s|r", keyColorHex, unknownLabel)
    end

    local formattedKeyLabel = string.format("|c%s%s|r", keyColorHex, keyLabel)
    if #formattedModifierParts > 0 then
        return table.concat(formattedModifierParts, "-") .. "-" .. formattedKeyLabel
    end

    return formattedKeyLabel
end

function ZeroPanel:GetButtonTooltip(definition, entry)
    local tooltipText
    if type(definition.tooltip) == "function" then
        tooltipText = definition.tooltip(self)
    else
        tooltipText = definition.tooltip or definition.name
    end

    local keybindTooltip = self:GetKeybindTooltipTextForLayoutEntry(entry)
    if keybindTooltip and keybindTooltip ~= "" then
        return string.format("%s\n\nKeyBind: %s", tostring(tooltipText or definition.name or ""), keybindTooltip)
    end

    return tooltipText
end

function ZeroPanel:GetLayoutDirection()
    if self.savedVars.layoutDirection == "horizontal" then
        return "horizontal"
    end

    return "vertical"
end

function ZeroPanel:GetLayoutDirectionDisplayName(layoutDirection)
    local resolvedLayoutDirection = layoutDirection or self:GetLayoutDirection()
    if resolvedLayoutDirection == "horizontal" then
        return "Vertical"
    end

    return "Horizontal"
end

function ZeroPanel:GetButtonsPerLineSettingName()
    if self:GetLayoutDirectionDisplayName() == "Vertical" then
        return "Buttons Per Column"
    end

    return "Buttons Per Row"
end

function ZeroPanel:GetButtonsPerLineSettingTooltip()
    if self:GetLayoutDirectionDisplayName() == "Vertical" then
        return "How many buttons fit in each vertical column before Zero Panel wraps to the next column. Separators stay in sequence and do not count toward this limit."
    end

    return "How many buttons fit in each horizontal row before Zero Panel wraps to the next row. Separators stay in sequence and do not count toward this limit."
end

function ZeroPanel:RefreshLayoutDirectionOptionControls()
    local buttonsPerLineControl = _G.ZeroPanelButtonsPerLineSlider
    if buttonsPerLineControl then
        local controlName = self:GetButtonsPerLineSettingName()
        local tooltipText = self:GetButtonsPerLineSettingTooltip()

        buttonsPerLineControl.data = buttonsPerLineControl.data or {}
        buttonsPerLineControl.data.tooltipText = tooltipText

        if buttonsPerLineControl.label and type(buttonsPerLineControl.label.SetText) == "function" then
            buttonsPerLineControl.label:SetText(controlName)
        end

        if type(buttonsPerLineControl.UpdateDisabled) == "function" then
            buttonsPerLineControl:UpdateDisabled()
        end

        if type(buttonsPerLineControl.UpdateWarning) == "function" then
            buttonsPerLineControl:UpdateWarning()
        end
    end
end

function ZeroPanel:GetButtonsPerLine()
    local buttonsPerLine = tonumber(self.savedVars.buttonsPerLine) or DEFAULTS.buttonsPerLine
    buttonsPerLine = math.floor(buttonsPerLine)
    if buttonsPerLine < 1 then
        buttonsPerLine = 1
    end
    return buttonsPerLine
end

function ZeroPanel:GetMaximumVisibleButtons()
    local maxVisibleButtons = tonumber(self.savedVars.maxVisibleButtons) or DEFAULTS.maxVisibleButtons
    maxVisibleButtons = math.floor(maxVisibleButtons)
    if maxVisibleButtons < 1 then
        maxVisibleButtons = 1
    elseif maxVisibleButtons > 60 then
        maxVisibleButtons = 60
    end
    return maxVisibleButtons
end

function ZeroPanel:NormalizeOrderedLayoutEntries(layoutEntries)
    local normalizedEntries = {}
    local previousWasSeparator = true

    for _, entry in ipairs(layoutEntries) do
        if entry.kind == "separator" then
            if not previousWasSeparator then
                normalizedEntries[#normalizedEntries + 1] = entry
                previousWasSeparator = true
            end
        elseif entry.definition and self:ShouldDisplayButton(entry.definition) then
            normalizedEntries[#normalizedEntries + 1] = entry
            previousWasSeparator = false
        end
    end

    if #normalizedEntries > 0 and normalizedEntries[#normalizedEntries].kind == "separator" then
        table.remove(normalizedEntries)
    end

    return normalizedEntries
end

function ZeroPanel:GetOrderedLayoutEntries()
    local orderedEntries = {}
    local used = {}
    local layoutByKey = self:GetLayoutCatalogByKey()

    for _, entryKey in ipairs(self.savedVars.order or {}) do
        local entry = layoutByKey[entryKey]
        if entry then
            orderedEntries[#orderedEntries + 1] = entry
            used[entry.key] = true
        end
    end

    for _, defaultEntryKey in ipairs(DEFAULT_LAYOUT_ORDER) do
        local entry = layoutByKey[defaultEntryKey]
        if entry and not used[defaultEntryKey] then
            orderedEntries[#orderedEntries + 1] = entry
            used[defaultEntryKey] = true
        end
    end

    for _, customButtonId in ipairs(self:GetCustomButtonIds()) do
        local customEntryKey = GetCustomButtonLayoutKey(customButtonId)
        local entry = layoutByKey[customEntryKey]
        if entry and not used[customEntryKey] then
            orderedEntries[#orderedEntries + 1] = entry
            used[customEntryKey] = true
        end
    end

    for _, customSeparatorId in ipairs(self:GetCustomSeparatorIds()) do
        local customEntryKey = GetCustomSeparatorLayoutKey(customSeparatorId)
        local entry = layoutByKey[customEntryKey]
        if entry and not used[customEntryKey] then
            orderedEntries[#orderedEntries + 1] = entry
        end
    end

    return self:NormalizeOrderedLayoutEntries(orderedEntries)
end

function ZeroPanel:GetLayoutItems()
    local layoutItems = {}
    local visibleButtonCount = 0
    local maxVisibleButtons = self:GetMaximumVisibleButtons()

    for _, entry in ipairs(self:GetOrderedLayoutEntries()) do
        if entry.kind == "separator" then
            if visibleButtonCount > 0 and visibleButtonCount < maxVisibleButtons then
                layoutItems[#layoutItems + 1] = {
                    kind = "divider",
                    entry = entry,
                }
            end
        elseif entry.definition then
            if visibleButtonCount >= maxVisibleButtons then
                break
            end

            layoutItems[#layoutItems + 1] = {
                kind = "button",
                definition = entry.definition,
                entry = entry,
            }
            visibleButtonCount = visibleButtonCount + 1
        end
    end

    if #layoutItems > 0 and layoutItems[#layoutItems].kind == "divider" then
        table.remove(layoutItems)
    end

    return layoutItems
end

function ZeroPanel:GetLayoutHeight(layoutItems, buttonSize, spacing, padding)
    if #layoutItems == 0 then
        return buttonSize + (padding * 2)
    end

    local height = padding * 2
    for index, item in ipairs(layoutItems) do
        height = height + (item.kind == "divider" and DIVIDER_LAYOUT_HEIGHT or buttonSize)
        if index < #layoutItems then
            height = height + spacing
        end
    end

    return height
end

function ZeroPanel:BuildPanelLayout(layoutItems, buttonSize, spacing, padding)
    if #layoutItems == 0 then
        return {}, buttonSize + (padding * 2), buttonSize + (padding * 2)
    end

    local placements = {}
    local direction = self:GetLayoutDirection()
    local buttonsPerLine = self:GetButtonsPerLine()
    local majorOffset = padding
    local minorOffset = padding
    local buttonsInCurrentLine = 0
    local maxX = padding
    local maxY = padding

    local function WrapToNextLine()
        majorOffset = padding
        minorOffset = minorOffset + buttonSize + spacing
        buttonsInCurrentLine = 0
    end

    local function RegisterPlacement(kind, item, x, y, width, height)
        placements[#placements + 1] = {
            kind = kind,
            item = item,
            x = x,
            y = y,
            width = width,
            height = height,
        }
        maxX = math.max(maxX, x + width)
        maxY = math.max(maxY, y + height)
    end

    if direction == "horizontal" then
        local rowWidth = (buttonsPerLine * buttonSize) + (math.max(0, buttonsPerLine - 1) * spacing)

        local function AdvanceToNextRow(heightUsed)
            majorOffset = padding
            minorOffset = minorOffset + heightUsed + spacing
            buttonsInCurrentLine = 0
        end

        for _, item in ipairs(layoutItems) do
            if item.kind == "divider" then
                if buttonsInCurrentLine > 0 then
                    AdvanceToNextRow(buttonSize)
                end

                local dividerY = minorOffset + math.floor((DIVIDER_LAYOUT_HEIGHT - DIVIDER_LINE_HEIGHT) / 2)
                RegisterPlacement("divider", item, padding, dividerY, rowWidth, DIVIDER_LINE_HEIGHT)
                AdvanceToNextRow(DIVIDER_LAYOUT_HEIGHT)
            else
                RegisterPlacement("button", item, majorOffset, minorOffset, buttonSize, buttonSize)
                buttonsInCurrentLine = buttonsInCurrentLine + 1

                if buttonsInCurrentLine >= buttonsPerLine then
                    AdvanceToNextRow(buttonSize)
                else
                    majorOffset = majorOffset + buttonSize + spacing
                end
            end
        end
    else
        local columnHeight = (buttonsPerLine * buttonSize) + (math.max(0, buttonsPerLine - 1) * spacing)

        local function AdvanceToNextColumn(widthUsed)
            majorOffset = padding
            minorOffset = minorOffset + widthUsed + spacing
            buttonsInCurrentLine = 0
        end

        for _, item in ipairs(layoutItems) do
            if item.kind == "divider" then
                if buttonsInCurrentLine > 0 then
                    AdvanceToNextColumn(buttonSize)
                end

                local dividerX = minorOffset + math.floor((DIVIDER_LAYOUT_HEIGHT - DIVIDER_LINE_HEIGHT) / 2)
                RegisterPlacement("divider", item, dividerX, padding, DIVIDER_LINE_HEIGHT, columnHeight)
                AdvanceToNextColumn(DIVIDER_LAYOUT_HEIGHT)
            else
                RegisterPlacement("button", item, minorOffset, majorOffset, buttonSize, buttonSize)
                buttonsInCurrentLine = buttonsInCurrentLine + 1

                if buttonsInCurrentLine >= buttonsPerLine then
                    AdvanceToNextColumn(buttonSize)
                else
                    majorOffset = majorOffset + buttonSize + spacing
                end
            end
        end
    end

    return placements, maxX + padding, maxY + padding
end

function ZeroPanel:SetSelectedLayoutOrderKey(layoutKey)
    if type(layoutKey) == "string" and self:GetLayoutCatalogByKey()[layoutKey] then
        self.selectedLayoutOrderKey = layoutKey
    else
        self.selectedLayoutOrderKey = nil
    end
end

function ZeroPanel:GetSelectedLayoutEntry()
    local layoutKey = self.selectedLayoutOrderKey
    if type(layoutKey) ~= "string" or layoutKey == "" then
        return nil
    end

    return self:GetLayoutCatalogByKey()[layoutKey]
end

function ZeroPanel:IsLayoutEntryBindable(entry)
    return type(entry) == "table" and entry.kind == "button" and type(entry.definition) == "table"
end

function ZeroPanel:IsZeroPanelKeybindActionName(actionName)
    return type(actionName) == "string" and string.find(actionName, "^" .. ZERO_PANEL_KEYBIND_ACTION_PREFIX, 1) ~= nil
end

function ZeroPanel:GetKeybindSlotForLayoutKey(layoutKey)
    self:EnsureKeybindAssignments()

    local keybindSlot = math.floor(tonumber(self.savedVars.keybindAssignments[layoutKey]) or ZERO_PANEL_KEYBIND_NONE_VALUE)
    if keybindSlot < 1 or keybindSlot > ZERO_PANEL_KEYBIND_SLOT_COUNT then
        return ZERO_PANEL_KEYBIND_NONE_VALUE
    end

    return keybindSlot
end

function ZeroPanel:GetLayoutKeyForKeybindSlot(keybindSlot)
    self:EnsureKeybindAssignments()

    local resolvedKeybindSlot = math.floor(tonumber(keybindSlot) or ZERO_PANEL_KEYBIND_NONE_VALUE)
    if resolvedKeybindSlot < 1 or resolvedKeybindSlot > ZERO_PANEL_KEYBIND_SLOT_COUNT then
        return nil
    end

    for layoutKey, assignedSlot in pairs(self.savedVars.keybindAssignments or {}) do
        if tonumber(assignedSlot) == resolvedKeybindSlot then
            return layoutKey
        end
    end

    return nil
end

function ZeroPanel:ClearKeybindAssignmentForLayoutKey(layoutKey)
    self.savedVars.keybindAssignments = self.savedVars.keybindAssignments or {}
    if self.savedVars.keybindAssignments[layoutKey] ~= nil then
        self.savedVars.keybindAssignments[layoutKey] = nil
        self:InvalidateKeybindDisplayCache()
        self:RegisterKeybindStringIds()
        self:RefreshAllButtonKeybindDisplays()
    end
end

function ZeroPanel:SetKeybindSlotForLayoutKey(layoutKey, keybindSlot)
    local entry = type(layoutKey) == "string" and self:GetLayoutCatalogByKey()[layoutKey] or nil
    if not self:IsLayoutEntryBindable(entry) then
        return
    end

    self:EnsureKeybindAssignments()

    local resolvedKeybindSlot = math.floor(tonumber(keybindSlot) or ZERO_PANEL_KEYBIND_NONE_VALUE)
    if resolvedKeybindSlot < 1 or resolvedKeybindSlot > ZERO_PANEL_KEYBIND_SLOT_COUNT then
        resolvedKeybindSlot = ZERO_PANEL_KEYBIND_NONE_VALUE
    end

    for assignedLayoutKey, assignedSlot in pairs(self.savedVars.keybindAssignments) do
        if assignedLayoutKey == layoutKey or tonumber(assignedSlot) == resolvedKeybindSlot then
            self.savedVars.keybindAssignments[assignedLayoutKey] = nil
        end
    end

    if resolvedKeybindSlot ~= ZERO_PANEL_KEYBIND_NONE_VALUE then
        self.savedVars.keybindAssignments[layoutKey] = resolvedKeybindSlot
    end

    self:InvalidateKeybindDisplayCache()
    self:RegisterKeybindStringIds()
    self:RefreshAllButtonKeybindDisplays()
end

function ZeroPanel:GetFirstAvailableKeybindSlot()
    self:EnsureKeybindAssignments()

    local usedSlots = {}
    for _, assignedSlot in pairs(self.savedVars.keybindAssignments or {}) do
        local resolvedKeybindSlot = math.floor(tonumber(assignedSlot) or ZERO_PANEL_KEYBIND_NONE_VALUE)
        if resolvedKeybindSlot >= 1 and resolvedKeybindSlot <= ZERO_PANEL_KEYBIND_SLOT_COUNT then
            usedSlots[resolvedKeybindSlot] = true
        end
    end

    for keybindSlot = 1, ZERO_PANEL_KEYBIND_SLOT_COUNT do
        if not usedSlots[keybindSlot] then
            return keybindSlot
        end
    end

    return nil
end

function ZeroPanel:GetKeybindModifierColor(modifierId)
    local settings = self:GetKeybindDisplaySettings()
    local color = settings.modifierColors and settings.modifierColors[modifierId]
    if type(color) ~= "table" then
        color = DEFAULT_KEYBIND_MODIFIER_COLORS[modifierId]
    end

    return color or DEFAULT_KEYBIND_TEXT_COLOR
end

function ZeroPanel:GetIconDesaturation()
    return ClampNumber(tonumber(self.savedVars.iconDesaturation) or DEFAULTS.iconDesaturation, 0, 100)
end

function ZeroPanel:GetActionBindingInfoFromActionName(actionName)
    if type(actionName) ~= "string" or actionName == "" then
        return nil
    end

    local function TryGetHighestPriorityBinding(bindingGetter, preferGamepad)
        if type(bindingGetter) ~= "function" then
            return nil
        end

        local keyCode, mod1, mod2, mod3, mod4 = bindingGetter(actionName, preferGamepad)
        if IsBoundKeyCode(keyCode) then
            return keyCode, mod1, mod2, mod3, mod4
        end

        return nil
    end

    local keyCode, mod1, mod2, mod3, mod4 = TryGetHighestPriorityBinding(GetIngameHighestPriorityActionBindingInfoFromName, false)
    if not IsBoundKeyCode(keyCode) then
        keyCode, mod1, mod2, mod3, mod4 = TryGetHighestPriorityBinding(GetHighestPriorityActionBindingInfoFromName, false)
    end
    if not IsBoundKeyCode(keyCode) then
        keyCode, mod1, mod2, mod3, mod4 = TryGetHighestPriorityBinding(GetIngameHighestPriorityActionBindingInfoFromName, true)
    end
    if not IsBoundKeyCode(keyCode) then
        keyCode, mod1, mod2, mod3, mod4 = TryGetHighestPriorityBinding(GetHighestPriorityActionBindingInfoFromName, true)
    end
    if IsBoundKeyCode(keyCode) then
        return keyCode, mod1, mod2, mod3, mod4
    end

    if type(GetActionIndicesFromName) ~= "function" or type(GetActionBindingInfo) ~= "function" then
        return nil
    end

    local layerIndex, categoryIndex, actionIndex = GetActionIndicesFromName(actionName)
    if not layerIndex or not categoryIndex or not actionIndex then
        return nil
    end

    local maxBindingsPerAction = type(GetMaxBindingsPerAction) == "function" and math.max(1, tonumber(GetMaxBindingsPerAction()) or 2) or 2
    for bindingIndex = 1, maxBindingsPerAction do
        keyCode, mod1, mod2, mod3, mod4 = GetActionBindingInfo(layerIndex, categoryIndex, actionIndex, bindingIndex)
        if IsBoundKeyCode(keyCode) then
            return keyCode, mod1, mod2, mod3, mod4
        end
    end

    return nil
end

function ZeroPanel:HasBoundKeyForAction(actionName)
    local keyCode = self:GetActionBindingInfoFromActionName(actionName)
    return IsBoundKeyCode(keyCode)
end

function ZeroPanel:ClearAllBindingsForAction(actionName)
    local layerIndex, categoryIndex, actionIndex = self:GetActionIndicesForActionName(actionName)
    if not layerIndex then
        return false
    end

    if type(IsProtectedFunction) == "function" and IsProtectedFunction("UnbindAllKeysFromAction") and type(CallSecureProtected) == "function" then
        CallSecureProtected("UnbindAllKeysFromAction", layerIndex, categoryIndex, actionIndex)
        return true
    elseif type(UnbindAllKeysFromAction) == "function" then
        UnbindAllKeysFromAction(layerIndex, categoryIndex, actionIndex)
        return true
    end

    if type(GetActionBindingInfo) ~= "function" then
        return false
    end

    local useSecureUnbind = type(IsProtectedFunction) == "function" and IsProtectedFunction("UnbindKeyFromAction") and type(CallSecureProtected) == "function"
    local directUnbind = type(UnbindKeyFromAction) == "function" and UnbindKeyFromAction
    local legacyUnbind = type(UnbindKeyToAction) == "function" and UnbindKeyToAction or nil
    if not useSecureUnbind and not directUnbind and not legacyUnbind then
        return false
    end

    local didClear = false
    local maxBindingsPerAction = type(GetMaxBindingsPerAction) == "function" and math.max(1, tonumber(GetMaxBindingsPerAction()) or 2) or 2
    for bindingIndex = 1, maxBindingsPerAction do
        local keyCode = GetActionBindingInfo(layerIndex, categoryIndex, actionIndex, bindingIndex)
        if IsBoundKeyCode(keyCode) then
            if useSecureUnbind then
                CallSecureProtected("UnbindKeyFromAction", layerIndex, categoryIndex, actionIndex, bindingIndex)
            elseif directUnbind then
                directUnbind(layerIndex, categoryIndex, actionIndex, bindingIndex)
            else
                legacyUnbind(layerIndex, categoryIndex, actionIndex, bindingIndex)
            end
            didClear = true
        end
    end

    return didClear
end

function ZeroPanel:ClearKeybindActionForSlot(keybindSlot)
    local resolvedKeybindSlot = math.floor(tonumber(keybindSlot) or ZERO_PANEL_KEYBIND_NONE_VALUE)
    if resolvedKeybindSlot < 1 or resolvedKeybindSlot > ZERO_PANEL_KEYBIND_SLOT_COUNT then
        return false
    end

    return self:ClearAllBindingsForAction(GetZeroPanelKeybindActionName(resolvedKeybindSlot))
end

function ZeroPanel:ClearPendingKeybindAssignment()
    self.pendingKeybindAssignment = nil
end

function ZeroPanel:ClearPendingKeybindAssignmentForLayoutKey(layoutKey)
    local pendingAssignment = self.pendingKeybindAssignment
    if pendingAssignment and pendingAssignment.layoutKey == layoutKey then
        self.pendingKeybindAssignment = nil
        return true
    end

    return false
end

function ZeroPanel:SetPendingKeybindAssignment(layoutKey, keybindSlot, actionName, bindingIndex)
    local entry = type(layoutKey) == "string" and self:GetLayoutCatalogByKey()[layoutKey] or nil
    if not self:IsLayoutEntryBindable(entry) then
        self.pendingKeybindAssignment = nil
        return
    end

    self.pendingKeybindAssignment = {
        layoutKey = layoutKey,
        keybindSlot = math.floor(tonumber(keybindSlot) or ZERO_PANEL_KEYBIND_NONE_VALUE),
        actionName = actionName,
        bindingIndex = math.max(1, math.floor(tonumber(bindingIndex) or 1)),
        entryName = tostring(entry.name or entry.key or "Selected button"),
    }
end

function ZeroPanel:FinalizePendingKeybindAssignment(layerIndex, categoryIndex, actionIndex, bindingIndex)
    local pendingAssignment = self.pendingKeybindAssignment
    if type(pendingAssignment) ~= "table" then
        return false
    end

    if not self:IsActionNameMatchIndices(pendingAssignment.actionName, layerIndex, categoryIndex, actionIndex) then
        return false
    end

    self.pendingKeybindAssignment = nil

    local entry = self:GetLayoutCatalogByKey()[pendingAssignment.layoutKey]
    if not self:IsLayoutEntryBindable(entry) then
        return false
    end

    self:SetKeybindSlotForLayoutKey(pendingAssignment.layoutKey, pendingAssignment.keybindSlot)
    self:RefreshButtonOrderControlState()
    self:RequestSettingsRefresh()
    self:Print(string.format("%s is now assigned to %s.", pendingAssignment.entryName, GetZeroPanelKeybindSlotLabel(pendingAssignment.keybindSlot)))
    return true
end

function ZeroPanel:CleanupGhostKeybindAssignments(silent)
    if self.savedVars == nil then
        return 0
    end

    self:EnsureKeybindAssignments()

    local clearedAssignments = 0
    for layoutKey, assignedSlot in pairs(self.savedVars.keybindAssignments or {}) do
        local resolvedKeybindSlot = math.floor(tonumber(assignedSlot) or ZERO_PANEL_KEYBIND_NONE_VALUE)
        if resolvedKeybindSlot < 1 or resolvedKeybindSlot > ZERO_PANEL_KEYBIND_SLOT_COUNT or not self:HasBoundKeyForAction(GetZeroPanelKeybindActionName(resolvedKeybindSlot)) then
            self.savedVars.keybindAssignments[layoutKey] = nil
            clearedAssignments = clearedAssignments + 1
        end
    end

    if clearedAssignments > 0 then
        self:InvalidateKeybindDisplayCache()
        self:RegisterKeybindStringIds()
        self:RefreshAllButtonKeybindDisplays()
        self:RefreshButtonOrderControlState()
        self:RequestSettingsRefresh()
        if not silent then
            self:Print(string.format("Cleared %d stale unbound Zero Panel keybind slot(s).", clearedAssignments))
        end
    end

    return clearedAssignments
end

function ZeroPanel:QueueGhostKeybindCleanup()
    self.ghostKeybindCleanupToken = (tonumber(self.ghostKeybindCleanupToken) or 0) + 1
    local cleanupToken = self.ghostKeybindCleanupToken

    local function RunCleanup()
        if self.ghostKeybindCleanupToken ~= cleanupToken then
            return
        end

        self:CleanupGhostKeybindAssignments(true)
    end

    if type(zo_callLater) == "function" then
        zo_callLater(RunCleanup, 200)
    else
        RunCleanup()
    end
end

function ZeroPanel:RunStartupGhostKeybindCleanup()
    if self.didRunStartupGhostKeybindCleanup then
        return
    end

    self.didRunStartupGhostKeybindCleanup = true
    self:CleanupGhostKeybindAssignments(false)
end

function ZeroPanel:GetStaleKeybindCleanupSummary()
    local summary = {
        inspectable = type(GetActionIndicesFromName) == "function" and (type(GetActionBindingInfo) == "function" or type(GetHighestPriorityActionBindingInfoFromName) == "function" or type(GetIngameHighestPriorityActionBindingInfoFromName) == "function"),
        ghostAssignments = 0,
        orphanedBindings = 0,
        total = 0,
    }

    if not summary.inspectable or self.savedVars == nil then
        return summary
    end

    self:EnsureKeybindAssignments()

    local layoutByKey = self:GetLayoutCatalogByKey()
    local assignedSlots = {}

    for layoutKey, assignedSlot in pairs(self.savedVars.keybindAssignments or {}) do
        local resolvedKeybindSlot = math.floor(tonumber(assignedSlot) or ZERO_PANEL_KEYBIND_NONE_VALUE)
        if resolvedKeybindSlot >= 1 and resolvedKeybindSlot <= ZERO_PANEL_KEYBIND_SLOT_COUNT then
            assignedSlots[resolvedKeybindSlot] = layoutKey

            local entry = layoutByKey[layoutKey]
            if not self:IsLayoutEntryBindable(entry) or not self:HasBoundKeyForAction(GetZeroPanelKeybindActionName(resolvedKeybindSlot)) then
                summary.ghostAssignments = summary.ghostAssignments + 1
            end
        else
            summary.ghostAssignments = summary.ghostAssignments + 1
        end
    end

    for keybindSlot = 1, ZERO_PANEL_KEYBIND_SLOT_COUNT do
        local layoutKey = assignedSlots[keybindSlot]
        local entry = layoutKey and layoutByKey[layoutKey] or nil
        if not self:IsLayoutEntryBindable(entry) and self:HasBoundKeyForAction(GetZeroPanelKeybindActionName(keybindSlot)) then
            summary.orphanedBindings = summary.orphanedBindings + 1
        end
    end

    summary.total = summary.ghostAssignments + summary.orphanedBindings
    return summary
end

function ZeroPanel:CanCleanupStaleKeybindSlots()
    return self:GetStaleKeybindCleanupSummary().total > 0
end

function ZeroPanel:GetCleanupStaleKeybindSlotsTooltip()
    local summary = self:GetStaleKeybindCleanupSummary()
    if not summary.inspectable then
        return "Zero Panel cannot inspect keybind state yet. Try this again after the game's keybindings finish loading."
    end

    if summary.total == 0 then
        return "No stale Zero Panel keybind slots were found."
    end

    return string.format("Clear stale Zero Panel keybind data.\n\nGhost Assignments: %d\nOrphaned Controls Bindings: %d\n\nUse this if a canceled bind, deleted custom button, or older build left a dead slot behind.", summary.ghostAssignments, summary.orphanedBindings)
end

function ZeroPanel:CleanupStaleKeybindSlots()
    local summary = self:GetStaleKeybindCleanupSummary()
    if not summary.inspectable then
        self:Print("Zero Panel cannot inspect keybind state yet. Try again after the game's keybindings finish loading.")
        return
    end

    if summary.total == 0 then
        self:Print("No stale Zero Panel keybind slots were found.")
        return
    end

    self:EnsureKeybindAssignments()

    local layoutByKey = self:GetLayoutCatalogByKey()
    local assignedSlots = {}
    local assignmentsToClear = {}
    local orphanedSlotsToClear = {}
    local clearedAssignments = 0
    local clearedBindings = 0
    local failedBindings = 0

    for layoutKey, assignedSlot in pairs(self.savedVars.keybindAssignments or {}) do
        local resolvedKeybindSlot = math.floor(tonumber(assignedSlot) or ZERO_PANEL_KEYBIND_NONE_VALUE)
        if resolvedKeybindSlot >= 1 and resolvedKeybindSlot <= ZERO_PANEL_KEYBIND_SLOT_COUNT then
            assignedSlots[resolvedKeybindSlot] = layoutKey

            local entry = layoutByKey[layoutKey]
            if not self:IsLayoutEntryBindable(entry) or not self:HasBoundKeyForAction(GetZeroPanelKeybindActionName(resolvedKeybindSlot)) then
                assignmentsToClear[#assignmentsToClear + 1] = layoutKey
            end
        else
            assignmentsToClear[#assignmentsToClear + 1] = layoutKey
        end
    end

    for _, layoutKey in ipairs(assignmentsToClear) do
        if self.savedVars.keybindAssignments[layoutKey] ~= nil then
            self.savedVars.keybindAssignments[layoutKey] = nil
            clearedAssignments = clearedAssignments + 1
        end
    end

    for keybindSlot = 1, ZERO_PANEL_KEYBIND_SLOT_COUNT do
        local layoutKey = assignedSlots[keybindSlot]
        local entry = layoutKey and layoutByKey[layoutKey] or nil
        if not self:IsLayoutEntryBindable(entry) and self:HasBoundKeyForAction(GetZeroPanelKeybindActionName(keybindSlot)) then
            orphanedSlotsToClear[#orphanedSlotsToClear + 1] = keybindSlot
        end
    end

    for _, keybindSlot in ipairs(orphanedSlotsToClear) do
        if self:ClearKeybindActionForSlot(keybindSlot) then
            clearedBindings = clearedBindings + 1
        else
            failedBindings = failedBindings + 1
        end
    end

    if clearedAssignments > 0 then
        self:InvalidateKeybindDisplayCache()
        self:RegisterKeybindStringIds()
        self:RefreshAllButtonKeybindDisplays()
    end

    if clearedAssignments > 0 or clearedBindings > 0 then
        self:RefreshButtonOrderControlState()
        self:RequestSettingsRefresh()
    end

    local resultParts = {}
    if clearedAssignments > 0 then
        resultParts[#resultParts + 1] = string.format("%d stale saved slot(s)", clearedAssignments)
    end
    if clearedBindings > 0 then
        resultParts[#resultParts + 1] = string.format("%d orphaned Controls binding(s)", clearedBindings)
    end
    if failedBindings > 0 then
        resultParts[#resultParts + 1] = string.format("%d orphaned Controls binding(s) still need manual clearing", failedBindings)
    end

    if #resultParts == 0 then
        self:Print("No stale Zero Panel keybind slots were cleared.")
    else
        self:Print("Cleared " .. table.concat(resultParts, " and ") .. ".")
    end
end

function ZeroPanel:RemoveKeybindForLayoutKey(layoutKey)
    local keybindSlot = self:GetKeybindSlotForLayoutKey(layoutKey)
    self:ClearPendingKeybindAssignmentForLayoutKey(layoutKey)
    self:ClearKeybindAssignmentForLayoutKey(layoutKey)

    if keybindSlot ~= ZERO_PANEL_KEYBIND_NONE_VALUE then
        self:ClearKeybindActionForSlot(keybindSlot)
    end

    self:RefreshButtonOrderControlState()
    self:RequestSettingsRefresh()
    return keybindSlot
end

function ZeroPanel:GetKeybindDisplayTextForSlot(keybindSlot)
    local resolvedKeybindSlot = math.floor(tonumber(keybindSlot) or ZERO_PANEL_KEYBIND_NONE_VALUE)
    if resolvedKeybindSlot < 1 or resolvedKeybindSlot > ZERO_PANEL_KEYBIND_SLOT_COUNT then
        return nil
    end

    local settings = self:GetKeybindDisplaySettings()
    local cacheSignature = tostring(settings.colorizeModifiers and 1 or 0)
    if settings.colorizeModifiers then
        cacheSignature = table.concat({
            cacheSignature,
            GetColorHexFromColorTable(self:GetKeybindModifierColor("ctrl")),
            GetColorHexFromColorTable(self:GetKeybindModifierColor("shift")),
            GetColorHexFromColorTable(self:GetKeybindModifierColor("alt")),
            GetColorHexFromColorTable(self:GetKeybindModifierColor("command")),
        }, ":")
    end

    if self.keybindDisplayTextCacheSignature ~= cacheSignature then
        self.keybindDisplayTextCacheSignature = cacheSignature
        self.keybindDisplayTextCache = {}
    end

    self.keybindDisplayTextCache = self.keybindDisplayTextCache or {}
    local cachedValue = self.keybindDisplayTextCache[resolvedKeybindSlot]
    if cachedValue ~= nil then
        return cachedValue ~= false and cachedValue or nil
    end

    local actionName = GetZeroPanelKeybindActionName(resolvedKeybindSlot)
    local keyCode, mod1, mod2, mod3, mod4 = self:GetActionBindingInfoFromActionName(actionName)
    if not IsBoundKeyCode(keyCode) then
        self.keybindDisplayTextCache[resolvedKeybindSlot] = false
        return nil
    end

    local keyLabel = AbbreviateKeybindKeyName(GetKeyCodeDisplayName(keyCode))
    if keyLabel == "" then
        self.keybindDisplayTextCache[resolvedKeybindSlot] = false
        return nil
    end

    local plainModifierParts = {}
    local formattedModifierParts = {}
    local modifierKeyCodes = {mod1, mod2, mod3, mod4}
    local seenModifiers = {}
    local seenUnknownModifierLabels = {}
    local unknownModifierLabels = {}

    for _, modifierKeyCode in ipairs(modifierKeyCodes) do
        if IsBoundKeyCode(modifierKeyCode) then
            local modifierId
            local modifierLabel

            if modifierKeyCode == KEY_CTRL then
                modifierId = "ctrl"
                modifierLabel = "C"
            elseif modifierKeyCode == KEY_SHIFT then
                modifierId = "shift"
                modifierLabel = "S"
            elseif modifierKeyCode == KEY_ALT then
                modifierId = "alt"
                modifierLabel = "A"
            elseif modifierKeyCode == KEY_COMMAND then
                modifierId = "command"
                modifierLabel = "M"
            end

            if modifierId and modifierLabel then
                seenModifiers[modifierId] = true
            else
                local unknownLabel = AbbreviateKeybindKeyName(GetKeyCodeDisplayName(modifierKeyCode))
                if unknownLabel ~= "" and not seenUnknownModifierLabels[unknownLabel] then
                    seenUnknownModifierLabels[unknownLabel] = true
                    unknownModifierLabels[#unknownModifierLabels + 1] = unknownLabel
                end
            end
        end
    end

    local function AddModifierPart(modifierId, shortLabel)
        if not seenModifiers[modifierId] then
            return
        end

        plainModifierParts[#plainModifierParts + 1] = shortLabel

        local modifierText = shortLabel
        if settings.colorizeModifiers then
            modifierText = string.format("|c%s%s|r", GetColorHexFromColorTable(self:GetKeybindModifierColor(modifierId)), shortLabel)
        end

        formattedModifierParts[#formattedModifierParts + 1] = modifierText
    end

    AddModifierPart("ctrl", "C")
    AddModifierPart("shift", "S")
    AddModifierPart("alt", "A")
    AddModifierPart("command", "M")

    for _, unknownLabel in ipairs(unknownModifierLabels) do
        plainModifierParts[#plainModifierParts + 1] = unknownLabel
        formattedModifierParts[#formattedModifierParts + 1] = unknownLabel
    end

    local plainText
    local formattedText
    if #plainModifierParts > 0 then
        plainText = table.concat(plainModifierParts, "") .. "-" .. keyLabel
        formattedText = table.concat(formattedModifierParts, "") .. "-" .. keyLabel
    else
        plainText = keyLabel
        formattedText = keyLabel
    end

    local cachedText = {
        plain = plainText,
        formatted = formattedText,
    }
    self.keybindDisplayTextCache[resolvedKeybindSlot] = cachedText
    return cachedText
end

function ZeroPanel:RefreshButtonKeybindDisplay(button, entry)
    if not button or not button.keybindLabel then
        return
    end

    entry = entry or button.layoutEntry

    local function HideKeybindLabel()
        button.keybindLabel:SetText("")
        button.keybindLabel:SetHidden(true)
        if button.keybindBackground then
            button.keybindBackground:SetHidden(true)
        end
        if button.keybindShadowLabel then
            button.keybindShadowLabel:SetText("")
            button.keybindShadowLabel:SetHidden(true)
        end
        if button.keybindColorLabel then
            button.keybindColorLabel:SetText("")
            button.keybindColorLabel:SetHidden(true)
        end
    end

    local settings = self:GetKeybindDisplaySettings()
    if not settings.enabled or not self:IsLayoutEntryBindable(entry) then
        HideKeybindLabel()
        return
    end

    local keybindSlot = self:GetKeybindSlotForLayoutKey(entry.key)
    if keybindSlot == ZERO_PANEL_KEYBIND_NONE_VALUE then
        HideKeybindLabel()
        return
    end

    local displayTextData = self:GetKeybindDisplayTextForSlot(keybindSlot)
    local plainText = displayTextData and displayTextData.plain or nil
    local formattedText = displayTextData and displayTextData.formatted or nil
    if TrimText(plainText) == "" then
        HideKeybindLabel()
        return
    end

    local labelAnchorPoint, buttonAnchorPoint = GetKeybindAnchorPair(settings.anchorPoint)
    local labelOffsetX, labelOffsetY = GetKeybindAnchorOffsets(settings.anchorPoint, settings.offsetX, settings.offsetY)
    local primaryFont = BuildKeybindFontDescriptor(settings.fontPath, settings.fontSize, settings.fontEffect)
    local plainFont = BuildKeybindFontDescriptor(settings.fontPath, settings.fontSize, "none")
    local horizontalAlignment = GetKeybindHorizontalAlignment(settings.anchorPoint)
    local verticalAlignment = GetKeybindVerticalAlignment(settings.anchorPoint)
    local fallbackHeight = math.max(18, (tonumber(settings.fontSize) or DEFAULTS.keybindDisplay.fontSize) + 2)

    button.keybindLabel:SetFont(primaryFont)
    button.keybindLabel:SetText(plainText)
    local labelWidth, labelHeight
    if type(button.keybindLabel.GetTextDimensions) == "function" then
        labelWidth, labelHeight = button.keybindLabel:GetTextDimensions()
    else
        labelWidth = type(button.keybindLabel.GetTextWidth) == "function" and button.keybindLabel:GetTextWidth() or nil
        labelHeight = type(button.keybindLabel.GetTextHeight) == "function" and button.keybindLabel:GetTextHeight() or nil
    end
    labelWidth = math.max(1, math.ceil(tonumber(labelWidth) or 0))
    labelHeight = math.max(1, math.ceil(tonumber(labelHeight) or fallbackHeight))

    if button.keybindBackground then
        local backgroundColor = self:GetKeybindBackgroundColor()
        local backgroundAlpha = ClampNumber((tonumber(settings.backgroundOpacity) or DEFAULT_KEYBIND_BACKGROUND_OPACITY) / 100, 0, 1)
        backgroundAlpha = backgroundAlpha * ClampNumber(tonumber(backgroundColor[4]) or DEFAULT_KEYBIND_BACKGROUND_COLOR[4], 0, 1)
        local borderAlpha = settings.showBackgroundBorder and 1 or 0
        if button.usable == false then
            backgroundAlpha = backgroundAlpha * 0.65
            borderAlpha = borderAlpha * 0.65
        end

        button.keybindBackground:ClearAnchors()
        button.keybindBackground:SetAnchor(TOPLEFT, button.keybindLabel, TOPLEFT, -KEYBIND_BACKGROUND_HORIZONTAL_PADDING, -KEYBIND_BACKGROUND_VERTICAL_PADDING)
        button.keybindBackground:SetAnchor(BOTTOMRIGHT, button.keybindLabel, BOTTOMRIGHT, KEYBIND_BACKGROUND_HORIZONTAL_PADDING, KEYBIND_BACKGROUND_VERTICAL_PADDING)
        button.keybindBackground:SetCenterColor(backgroundColor[1], backgroundColor[2], backgroundColor[3], backgroundAlpha)
        if self.keybindPickerActive then
            button.keybindBackground:SetEdgeColor(0.29, 0.61, 0.86, borderAlpha)
        else
            button.keybindBackground:SetEdgeColor(0.22, 0.22, 0.26, borderAlpha)
        end
        button.keybindBackground:SetHidden(not settings.showBackground)
    end

    if button.keybindShadowLabel then
        button.keybindShadowLabel:ClearAnchors()
        button.keybindShadowLabel:SetAnchor(labelAnchorPoint, button, buttonAnchorPoint, labelOffsetX + 1, labelOffsetY + 1)
        button.keybindShadowLabel:SetDimensions(labelWidth, labelHeight)
        button.keybindShadowLabel:SetFont(plainFont)
        button.keybindShadowLabel:SetHorizontalAlignment(horizontalAlignment)
        if type(button.keybindShadowLabel.SetVerticalAlignment) == "function" then
            button.keybindShadowLabel:SetVerticalAlignment(verticalAlignment)
        end
        button.keybindShadowLabel:SetColor(0, 0, 0, 0.78)
        button.keybindShadowLabel:SetAlpha(button.usable == false and 0.5 or 0.78)
        button.keybindShadowLabel:SetText(plainText)
        button.keybindShadowLabel:SetHidden(not ShouldUseKeybindShadowOverlay(settings.fontEffect))
    end

    button.keybindLabel:ClearAnchors()
    button.keybindLabel:SetAnchor(labelAnchorPoint, button, buttonAnchorPoint, labelOffsetX, labelOffsetY)
    button.keybindLabel:SetDimensions(labelWidth, labelHeight)
    button.keybindLabel:SetFont(primaryFont)
    button.keybindLabel:SetHorizontalAlignment(horizontalAlignment)
    if type(button.keybindLabel.SetVerticalAlignment) == "function" then
        button.keybindLabel:SetVerticalAlignment(verticalAlignment)
    end
    button.keybindLabel:SetColor(unpack(self:GetKeybindTextColor()))
    button.keybindLabel:SetAlpha(button.usable == false and 0.65 or 1)
    button.keybindLabel:SetText(plainText)
    button.keybindLabel:SetHidden(false)

    if button.keybindColorLabel then
        button.keybindColorLabel:ClearAnchors()
        button.keybindColorLabel:SetAnchor(labelAnchorPoint, button, buttonAnchorPoint, labelOffsetX, labelOffsetY)
        button.keybindColorLabel:SetDimensions(labelWidth, labelHeight)
        button.keybindColorLabel:SetFont(plainFont)
        button.keybindColorLabel:SetHorizontalAlignment(horizontalAlignment)
        if type(button.keybindColorLabel.SetVerticalAlignment) == "function" then
            button.keybindColorLabel:SetVerticalAlignment(verticalAlignment)
        end
        button.keybindColorLabel:SetColor(unpack(self:GetKeybindTextColor()))
        button.keybindColorLabel:SetAlpha(button.usable == false and 0.65 or 1)
        button.keybindColorLabel:SetText(formattedText)
        button.keybindColorLabel:SetHidden(not settings.colorizeModifiers)
    end
end

function ZeroPanel:RefreshAllButtonKeybindDisplays()
    for _, button in ipairs(self.buttons or {}) do
        if button and button.keybindLabel then
            if button:IsHidden() then
                button.keybindLabel:SetText("")
                button.keybindLabel:SetHidden(true)
                if button.keybindBackground then
                    button.keybindBackground:SetHidden(true)
                end
                if button.keybindShadowLabel then
                    button.keybindShadowLabel:SetText("")
                    button.keybindShadowLabel:SetHidden(true)
                end
                if button.keybindColorLabel then
                    button.keybindColorLabel:SetText("")
                    button.keybindColorLabel:SetHidden(true)
                end
            else
                self:RefreshButtonKeybindDisplay(button, button.layoutEntry)
            end
        end
    end
end

function ZeroPanel:GetLayoutOrderKeyFromSelectedData(selectedData)
    if type(selectedData) ~= "table" then
        return nil
    end

    local layoutByKey = self:GetLayoutCatalogByKey()
    local candidateTables = {selectedData}

    if type(selectedData.data) == "table" then
        candidateTables[#candidateTables + 1] = selectedData.data
    end

    for _, candidate in ipairs(candidateTables) do
        local layoutKey = candidate.value
        if type(layoutKey) == "string" and layoutByKey[layoutKey] then
            return layoutKey
        end
    end

    for _, candidate in ipairs(candidateTables) do
        local uniqueKey = tonumber(candidate.uniqueKey)
        if uniqueKey then
            for _, entry in ipairs(self:GetOrderListEntries()) do
                if tonumber(entry.uniqueKey) == uniqueKey and type(entry.value) == "string" and layoutByKey[entry.value] then
                    return entry.value
                end
            end
        end
    end

    return nil
end

function ZeroPanel:SyncEditorSelectionFromLayoutEntry(entry)
    if type(entry) ~= "table" then
        return
    end

    if entry.customButtonId ~= nil and self.savedVars.customButtons[entry.customButtonId] then
        self.selectedCustomButtonId = entry.customButtonId
        self.selectedEditorLayoutKey = entry.key
    elseif entry.customSeparatorId ~= nil and self.savedVars.customSeparators[entry.customSeparatorId] then
        self.selectedCustomSeparatorId = entry.customSeparatorId
        self.selectedEditorLayoutKey = entry.key
    elseif entry.builtin then
        self.selectedEditorLayoutKey = nil
    end
end

function ZeroPanel:HandleLayoutOrderSelection(selectedData)
    local layoutKey = self:GetLayoutOrderKeyFromSelectedData(selectedData)
    self:SetSelectedLayoutOrderKey(layoutKey)

    local entry = self:GetSelectedLayoutEntry()
    if entry then
        self:SyncEditorSelectionFromLayoutEntry(entry)
    end
end

function ZeroPanel:GetSelectedLayoutEntryFromOrderListControl()
    local orderListControl = _G.ZeroPanelLayoutOrderList
    local orderListBox = orderListControl and orderListControl.orderListBox
    local scrollListControl = orderListBox and orderListBox.scrollListControl
    if not scrollListControl then
        return nil
    end

    local selectedData = type(ZO_ScrollList_GetSelectedData) == "function" and ZO_ScrollList_GetSelectedData(scrollListControl) or nil
    if not selectedData then
        local selectedIndex = type(ZO_ScrollList_GetSelectedDataIndex) == "function" and ZO_ScrollList_GetSelectedDataIndex(scrollListControl) or nil
        local selectedEntry = selectedIndex and scrollListControl.data and scrollListControl.data[selectedIndex]
        selectedData = selectedEntry and (selectedEntry.data or selectedEntry) or nil
    end

    local layoutKey = self:GetLayoutOrderKeyFromSelectedData(selectedData)
    if type(layoutKey) ~= "string" or layoutKey == "" then
        return nil
    end

    return self:GetLayoutCatalogByKey()[layoutKey], layoutKey
end

function ZeroPanel:SyncLayoutSelectionFromOrderListControl()
    local entry, layoutKey = self:GetSelectedLayoutEntryFromOrderListControl()
    if entry and layoutKey then
        self:SetSelectedLayoutOrderKey(layoutKey)
        self:SyncEditorSelectionFromLayoutEntry(entry)
    end

    return entry
end

function ZeroPanel:GetDeleteSelectedLayoutEntry()
    local entry = self:SyncLayoutSelectionFromOrderListControl()
    if entry then
        return entry
    end

    entry = self:GetSelectedLayoutEntry()
    if entry then
        return entry
    end

    local layoutKey = self.selectedEditorLayoutKey
    if type(layoutKey) == "string" and layoutKey ~= "" then
        return self:GetLayoutCatalogByKey()[layoutKey]
    end

    return nil
end

function ZeroPanel:GetSelectedKeybindLayoutEntry()
    local entry = self:SyncLayoutSelectionFromOrderListControl()
    if entry then
        return entry
    end

    entry = self:GetSelectedLayoutEntry()
    if entry then
        return entry
    end

    local layoutKey = self.selectedEditorLayoutKey
    if type(layoutKey) == "string" and layoutKey ~= "" then
        return self:GetLayoutCatalogByKey()[layoutKey]
    end

    return nil
end

function ZeroPanel:CanAssignKeybindToSelectedLayoutEntry()
    return self:IsLayoutEntryBindable(self:GetSelectedKeybindLayoutEntry())
end

function ZeroPanel:CanBindSelectedLayoutEntry()
    local entry = self:GetSelectedKeybindLayoutEntry()
    if not self:IsLayoutEntryBindable(entry) then
        return false
    end

    return self:GetKeybindSlotForLayoutKey(entry.key) ~= ZERO_PANEL_KEYBIND_NONE_VALUE or self:GetFirstAvailableKeybindSlot() ~= nil
end

function ZeroPanel:GetSelectedLayoutEntryKeybindSlot()
    local entry = self:GetSelectedKeybindLayoutEntry()
    if not self:IsLayoutEntryBindable(entry) then
        return ZERO_PANEL_KEYBIND_NONE_VALUE
    end

    return self:GetKeybindSlotForLayoutKey(entry.key)
end

function ZeroPanel:GetSelectedLayoutEntryKeybindDescription()
    local entry = self:GetSelectedKeybindLayoutEntry()
    if not entry then
        return "Select a button row in Reorder Layout to assign a keybind slot."
    end

    local entryName = tostring(entry.name or entry.key or "Selected entry")
    if not self:IsLayoutEntryBindable(entry) then
        return string.format("%s is a separator, so it cannot have a Zero Panel keybind.", entryName)
    end

    local descriptionParts = {
        string.format("Selected Button: %s.", entryName),
        string.format("Assigned Slot: %s.", GetZeroPanelKeybindSlotLabel(self:GetKeybindSlotForLayoutKey(entry.key))),
        "Assign a slot here, or press Bind Selected Entry to auto-assign the first open slot and open Controls -> Zero Panel Keybindings.",
        "If you reuse a slot, Zero Panel will move that slot off the button that already had it.",
    }

    if entry.definition and not self:IsButtonEnabledBySettings(entry.definition) then
        descriptionParts[#descriptionParts + 1] = "This button is currently disabled in Zero Panel, so its keybind will stay inactive until you enable the button again."
    elseif entry.definition and not self:IsButtonUsable(entry.definition) then
        descriptionParts[#descriptionParts + 1] = "This button is currently unavailable, so its keybind will wait until the action becomes usable."
    end

    return table.concat(descriptionParts, "\n")
end

function ZeroPanel:SetSelectedLayoutEntryKeybindSlot(keybindSlot)
    local entry = self:GetSelectedKeybindLayoutEntry()
    if not self:IsLayoutEntryBindable(entry) then
        return
    end

    self:SetKeybindSlotForLayoutKey(entry.key, keybindSlot)
    self:RefreshButtonOrderControlState()
end

function ZeroPanel:GetBindSelectedLayoutEntryReason()
    local entry = self:GetSelectedKeybindLayoutEntry()
    if not entry then
        return "No row is selected in Reorder Layout. Click a button row there first."
    end

    local entryName = tostring(entry.name or entry.key or "Selected entry")
    if not self:IsLayoutEntryBindable(entry) then
        return string.format("%s is a separator, so it cannot have a Zero Panel keybind.", entryName)
    end

    local keybindSlot = self:GetKeybindSlotForLayoutKey(entry.key)
    if keybindSlot ~= ZERO_PANEL_KEYBIND_NONE_VALUE then
        return string.format("%s is already assigned to %s.", entryName, GetZeroPanelKeybindSlotLabel(keybindSlot))
    end

    local firstAvailableKeybindSlot = self:GetFirstAvailableKeybindSlot()
    if firstAvailableKeybindSlot then
        return string.format("%s does not have a slot yet. Bind Selected Entry will assign %s first, then open Controls -> Zero Panel Keybindings.", entryName, GetZeroPanelKeybindSlotLabel(firstAvailableKeybindSlot))
    end

    return "All Zero Panel keybind slots are already in use. Free one first, or reassign this row to an existing slot."
end

function ZeroPanel:GetBindSelectedLayoutEntryTooltip()
    return table.concat({
        "Assign or open the selected button's Zero Panel keybind slot.",
        "Current Reason: " .. self:GetBindSelectedLayoutEntryReason(),
    }, "\n")
end

function ZeroPanel:CloseSettingsMenu()
    if not SCENE_MANAGER then
        return
    end

    local gameMenuScene = type(SCENE_MANAGER.GetScene) == "function" and SCENE_MANAGER:GetScene("gameMenuInGame") or nil
    if gameMenuScene and type(gameMenuScene.GetState) == "function" and gameMenuScene:GetState() == SCENE_SHOWN then
        if type(SCENE_MANAGER.HideCurrentScene) == "function" then
            SCENE_MANAGER:HideCurrentScene()
        elseif type(SCENE_MANAGER.Hide) == "function" then
            SCENE_MANAGER:Hide("gameMenuInGame")
        end
    end
end

function ZeroPanel:RegisterKeybindingsMenuPanel()
    if self.keybindingsMenuPanelId or not KEYBOARD_OPTIONS or type(KEYBOARD_OPTIONS.currentPanelId) ~= "number" or type(ZO_GameMenu_AddControlsPanel) ~= "function" then
        return
    end

    local keybindingManager = KEYBOARD_KEYBINDING_MANAGER or KEYBINDING_MANAGER
    local keybindingList = keybindingManager and keybindingManager.list or nil

    local function installFilterOverride()
        keybindingManager = KEYBOARD_KEYBINDING_MANAGER or KEYBINDING_MANAGER
        keybindingList = keybindingManager and keybindingManager.list or nil
        if not keybindingList then
            return false
        end

        if self.keybindingsFilterOverride == nil then
            self.keybindingsFilterOverride = function(filterList)
                local scrollList = filterList and filterList.list or nil
                local masterList = filterList and filterList.masterList or nil
                if not scrollList or type(ZO_ScrollList_GetDataList) ~= "function" or type(ZO_ScrollList_Clear) ~= "function" then
                    return
                end

                local scrollData = ZO_ScrollList_GetDataList(scrollList)
                local layerHeader = nil
                local categoryHeader = nil
                local lastSI = SI_NONSTR_INGAMESHAREDSTRINGS_LAST_ENTRY
                local showZeroPanelOnly = self.keybindingsFilterMode == "zero_panel_only"
                local showAddonKeybinds = libAddonKeybinds and libAddonKeybinds.showAddonKeybinds or false

                ZO_ScrollList_Clear(scrollList)

                for _, dataEntry in ipairs(masterList or {}) do
                    if dataEntry.typeId == KEYBINDINGS_LAYER_DATA_TYPE then
                        layerHeader = dataEntry
                        categoryHeader = nil
                    elseif dataEntry.typeId == KEYBINDINGS_CATEGORY_DATA_TYPE then
                        categoryHeader = dataEntry
                    else
                        local actionName = dataEntry.data and dataEntry.data.actionName or nil
                        local insertEntry = false

                        if showZeroPanelOnly then
                            insertEntry = self:IsZeroPanelKeybindActionName(actionName)
                        else
                            insertEntry = showAddonKeybinds
                            local actionSI = type(actionName) == "string" and _G["SI_BINDING_NAME_" .. actionName] or nil
                            if type(actionSI) == "number" and actionSI < lastSI then
                                insertEntry = not insertEntry
                            end
                        end

                        if insertEntry then
                            if layerHeader then
                                scrollData[#scrollData + 1] = layerHeader
                                layerHeader = nil
                            end
                            if categoryHeader then
                                scrollData[#scrollData + 1] = categoryHeader
                                categoryHeader = nil
                            end
                            scrollData[#scrollData + 1] = dataEntry
                        end
                    end
                end
            end
        end

        keybindingList.FilterScrollList = self.keybindingsFilterOverride
        return true
    end

    local function setFilterMode(mode, forceRefresh)
        if mode ~= "zero_panel_only" then
            mode = nil
        end

        if not installFilterOverride() then
            self.keybindingsFilterMode = mode
            return
        end

        if self.keybindingsFilterMode ~= mode or forceRefresh then
            self.keybindingsFilterMode = mode
            if type(keybindingList.RefreshFilters) == "function" then
                keybindingList:RefreshFilters()
            end
        end
    end

    self.InstallKeybindingsFilterOverride = installFilterOverride
    self.SetKeybindingsFilterMode = setFilterMode

    local panelId = KEYBOARD_OPTIONS.currentPanelId
    KEYBOARD_OPTIONS.currentPanelId = panelId + 1
    KEYBOARD_OPTIONS.panelNames[panelId] = ZERO_PANEL_KEYBINDINGS_MENU_NAME

    ZO_GameMenu_AddControlsPanel({
        id = panelId,
        name = ZERO_PANEL_KEYBINDINGS_MENU_NAME,
        callback = function()
            if GAME_MENU_SCENE and KEYBINDINGS_FRAGMENT and type(GAME_MENU_SCENE.AddFragment) == "function" then
                GAME_MENU_SCENE:AddFragment(KEYBINDINGS_FRAGMENT)
            end
            setFilterMode("zero_panel_only", true)
        end,
        unselectedCallback = function()
            if GAME_MENU_SCENE and KEYBINDINGS_FRAGMENT and type(GAME_MENU_SCENE.RemoveFragment) == "function" then
                GAME_MENU_SCENE:RemoveFragment(KEYBINDINGS_FRAGMENT)
            end
            setFilterMode(nil, true)
            self.pendingKeybindActionName = nil
            self.pendingKeybindBindingIndex = nil
            self.pendingKeybindDialogToken = nil
            self:ClearPendingKeybindAssignment()
        end,
    })

    if not self.keybindingsMenuResetHookInstalled and ZO_GameMenu_InGame and ZO_GameMenu_InGame.gameMenu and ZO_GameMenu_InGame.gameMenu.navigationTree then
        ZO_PreHook(ZO_GameMenu_InGame.gameMenu.navigationTree, "Reset", function()
            setFilterMode(nil, false)
        end)
        self.keybindingsMenuResetHookInstalled = true
    end

    self.keybindingsMenuPanelId = panelId
end

function ZeroPanel:OpenKeybindingsMenu()
    self:RegisterKeybindingsMenuPanel()

    if type(self.InstallKeybindingsFilterOverride) == "function" then
        self.InstallKeybindingsFilterOverride()
    end

    if not SCENE_MANAGER then
        return false
    end

    local canShowKeybindingsFragment = GAME_MENU_SCENE and KEYBINDINGS_FRAGMENT and type(GAME_MENU_SCENE.AddFragment) == "function"
    local canChangePanels = KEYBOARD_OPTIONS and type(KEYBOARD_OPTIONS.ChangePanels) == "function" and type(self.keybindingsMenuPanelId) == "number"
    if not canShowKeybindingsFragment and not canChangePanels then
        return false
    end

    local function openPanel()
        if LibAddonMenu2 and type(LibAddonMenu2.GetAddonSettingsFragment) == "function" and type(SCENE_MANAGER.RemoveFragment) == "function" then
            local addonSettingsFragment = LibAddonMenu2:GetAddonSettingsFragment()
            if addonSettingsFragment then
                SCENE_MANAGER:RemoveFragment(addonSettingsFragment)
            end
        end

        if canShowKeybindingsFragment then
            GAME_MENU_SCENE:AddFragment(KEYBINDINGS_FRAGMENT)
        end

        if canChangePanels then
            KEYBOARD_OPTIONS:ChangePanels(self.keybindingsMenuPanelId)
        end
    end

    local gameMenuScene = type(SCENE_MANAGER.GetScene) == "function" and SCENE_MANAGER:GetScene("gameMenuInGame") or nil
    if gameMenuScene and type(gameMenuScene.GetState) == "function" and gameMenuScene:GetState() == SCENE_SHOWN then
        openPanel()
        return true
    end

    if type(SCENE_MANAGER.CallWhen) == "function" and type(SCENE_MANAGER.Show) == "function" then
        SCENE_MANAGER:CallWhen("gameMenuInGame", SCENE_SHOWN, openPanel)
        SCENE_MANAGER:Show("gameMenuInGame")
        return true
    end

    return false
end

function ZeroPanel:GetPreferredBindingIndexForAction(actionName)
    if type(actionName) ~= "string" or actionName == "" then
        return 1
    end

    if type(GetActionIndicesFromName) ~= "function" or type(GetActionBindingInfo) ~= "function" then
        return 1
    end

    local layerIndex, categoryIndex, actionIndex = GetActionIndicesFromName(actionName)
    if not layerIndex or not categoryIndex or not actionIndex then
        return 1
    end

    local maxBindingsPerAction = type(GetMaxBindingsPerAction) == "function" and math.max(1, tonumber(GetMaxBindingsPerAction()) or 2) or 2
    for bindingIndex = 1, maxBindingsPerAction do
        local keyCode = GetActionBindingInfo(layerIndex, categoryIndex, actionIndex, bindingIndex)
        if not IsBoundKeyCode(keyCode) then
            return bindingIndex
        end
    end

    return 1
end

function ZeroPanel:TryOpenPendingKeybindDialog()
    local actionName = self.pendingKeybindActionName
    if type(actionName) ~= "string" or actionName == "" then
        return false
    end

    local bindingIndex = math.max(1, math.floor(tonumber(self.pendingKeybindBindingIndex) or 1))
    local keybindingManager = KEYBOARD_KEYBINDING_MANAGER or KEYBINDING_MANAGER
    local keybindingList = keybindingManager and keybindingManager.list or nil
    local scrollList = keybindingList and keybindingList.list or nil
    if not keybindingList or not scrollList then
        return false
    end

    if type(self.SetKeybindingsFilterMode) == "function" then
        self.SetKeybindingsFilterMode("zero_panel_only", true)
    end

    if type(keybindingList.RefreshData) == "function" then
        keybindingList:RefreshData()
    elseif type(keybindingList.RefreshFilters) == "function" then
        keybindingList:RefreshFilters()
    end

    local targetData
    local scrollData = type(ZO_ScrollList_GetDataList) == "function" and ZO_ScrollList_GetDataList(scrollList) or nil
    for _, dataEntry in ipairs(scrollData or {}) do
        local rowData = dataEntry and dataEntry.data or nil
        if rowData and rowData.actionName == actionName then
            targetData = rowData
            break
        end
    end

    if not targetData then
        for _, dataEntry in ipairs(keybindingList.masterList or {}) do
            local rowData = dataEntry and dataEntry.data or nil
            if rowData and rowData.actionName == actionName then
                targetData = rowData
                break
            end
        end
    end

    if not targetData then
        return false
    end

    local function TryClickBindingButton()
        if type(ZO_ScrollList_GetDataControl) ~= "function" then
            return false
        end

        local rowControl = ZO_ScrollList_GetDataControl(scrollList, targetData)
        local bindingButtons = rowControl and rowControl.bindingButtons or nil
        local bindingButton = bindingButtons and bindingButtons[bindingIndex] or nil
        if not bindingButton or type(ZO_KeybindingListButton_OnClicked) ~= "function" then
            return false
        end

        ZO_KeybindingListButton_OnClicked(bindingButton)
        self.pendingKeybindActionName = nil
        self.pendingKeybindBindingIndex = nil
        self.pendingKeybindDialogToken = nil
        return true
    end

    if TryClickBindingButton() then
        return true
    end

    if type(ZO_ScrollList_SelectDataAndScrollIntoView) == "function" then
        ZO_ScrollList_SelectDataAndScrollIntoView(scrollList, targetData, function()
            TryClickBindingButton()
        end, true)
    end

    return false
end

function ZeroPanel:QueueKeybindDialogOpen(actionName, bindingIndex)
    if type(actionName) ~= "string" or actionName == "" then
        return
    end

    self.pendingKeybindActionName = actionName
    self.pendingKeybindBindingIndex = math.max(1, math.floor(tonumber(bindingIndex) or 1))
    self.pendingKeybindDialogToken = (tonumber(self.pendingKeybindDialogToken) or 0) + 1
    local dialogToken = self.pendingKeybindDialogToken
    local delays = {25, 100, 250, 500, 900}

    local function TryOpen()
        if self.pendingKeybindDialogToken ~= dialogToken then
            return
        end

        self:TryOpenPendingKeybindDialog()
    end

    if type(zo_callLater) == "function" then
        for _, delayMs in ipairs(delays) do
            zo_callLater(TryOpen, delayMs)
        end
    else
        TryOpen()
    end
end

function ZeroPanel:OpenKeybindingsMenuForAction(actionName, bindingIndex)
    if type(actionName) ~= "string" or actionName == "" then
        return false
    end

    if not self:OpenKeybindingsMenu() then
        return false
    end

    self:QueueKeybindDialogOpen(actionName, bindingIndex)
    return true
end

function ZeroPanel:HandleKeybindingSet(layerIndex, categoryIndex, actionIndex, bindingIndex)
    self:FinalizePendingKeybindAssignment(layerIndex, categoryIndex, actionIndex, bindingIndex)
    self:RegisterKeybindStringIds()
    self:InvalidateKeybindDisplayCache()
    self:RefreshAllButtonKeybindDisplays()
    self:RefreshButtonOrderControlState()
    self:RequestSettingsRefresh()
end

function ZeroPanel:HandleKeybindingCleared(layerIndex, categoryIndex, actionIndex, bindingIndex)
    self:RegisterKeybindStringIds()
    self:InvalidateKeybindDisplayCache()
    self:RefreshAllButtonKeybindDisplays()
    self:RefreshButtonOrderControlState()
    self:RequestSettingsRefresh()
    self:QueueGhostKeybindCleanup()
end

function ZeroPanel:CanActivateKeybindPicker()
    for _, item in ipairs(self:GetLayoutItems()) do
        if item.kind == "button" and self:IsLayoutEntryBindable(item.entry) then
            return true
        end
    end

    return false
end

function ZeroPanel:GetActivateKeybindPickerTooltip()
    if self.keybindPickerActive then
        return "KeyBinder is active. Click a Zero Panel button to assign or open its binding, or right-click the panel background to cancel."
    end

    return "Close the settings panel and activate KeyBinder mode. Zero Panel will stay visible while KeyBinder is active so you can click a button and open the correct keybinding dialog for it."
end

function ZeroPanel:GetKeybindPickerTooltip(entry)
    local entryName = tostring((entry and (entry.name or entry.key)) or "This button")
    local slot = entry and self:GetKeybindSlotForLayoutKey(entry.key) or ZERO_PANEL_KEYBIND_NONE_VALUE
    if slot == ZERO_PANEL_KEYBIND_NONE_VALUE then
        local firstAvailableKeybindSlot = self:GetFirstAvailableKeybindSlot()
        if firstAvailableKeybindSlot then
            return string.format("%s\n\nKeyBinder: click to assign %s and open its binding dialog.", entryName, GetZeroPanelKeybindSlotLabel(firstAvailableKeybindSlot))
        end

        return string.format("%s\n\nAll Zero Panel keybind slots are already in use.", entryName)
    end

    return string.format("%s\n\nKeyBinder: click to open %s for this button.", entryName, GetZeroPanelKeybindSlotLabel(slot))
end

function ZeroPanel:CancelKeybindPicker(message)
    if not self.keybindPickerActive then
        return
    end

    self.keybindPickerActive = false
    self:RefreshPanel()
    self:RefreshButtonHoverStates()
    self:RefreshKeybindPickerPromptVisibility()

    if type(message) == "string" and message ~= "" then
        self:Print(message)
    end
end

function ZeroPanel:ActivateKeybindPicker()
    if not self:CanActivateKeybindPicker() then
        self:Print("Zero Panel has no visible buttons to bind right now.")
        return
    end

    if self.keybindPickerActive then
        self:CloseSettingsMenu()
        self:RefreshPanel()
        self:RefreshKeybindPickerPromptVisibility()
        self:Print("KeyBinder is already active. Click a Zero Panel button to bind it, or use Cancel Keybind Mode when you are done.")
        return
    end

    self.keybindPickerActive = true
    self:RefreshPanel()
    self:RefreshKeybindPickerPromptVisibility()
    self:CloseSettingsMenu()
    self:Print("KeyBinder active. Click a Zero Panel button to bind it. KeyBinder stays active until you cancel it.")
end

function ZeroPanel:HandleKeybindPickerClick(control, buttonIndex)
    if not self.keybindPickerActive then
        return false
    end

    if buttonIndex == MOUSE_BUTTON_INDEX_RIGHT then
        self:CancelKeybindPicker("KeyBinder canceled.")
        return true
    end

    local entry = control and control.layoutEntry or nil
    if not self:IsLayoutEntryBindable(entry) then
        self:Print("That panel entry cannot use a Zero Panel keybind.")
        return true
    end

    local keybindSlot = self:GetKeybindSlotForLayoutKey(entry.key)
    local entryName = tostring(entry.name or entry.key or "Selected button")
    if keybindSlot == ZERO_PANEL_KEYBIND_NONE_VALUE then
        keybindSlot = self:GetFirstAvailableKeybindSlot()
        if not keybindSlot then
            self:Print("All Zero Panel keybind slots are already in use. Free one in Controls -> Zero Panel Keybindings first.")
            return true
        end
    end

    local actionName = GetZeroPanelKeybindActionName(keybindSlot)
    local bindingIndex = self:GetPreferredBindingIndexForAction(actionName)
    local actionAlreadyBound = self:HasBoundKeyForAction(actionName)
    local isNewAssignment = self:GetKeybindSlotForLayoutKey(entry.key) == ZERO_PANEL_KEYBIND_NONE_VALUE

    if isNewAssignment then
        if actionAlreadyBound then
            self:SetKeybindSlotForLayoutKey(entry.key, keybindSlot)
            self:RefreshButtonOrderControlState()
            self:RequestSettingsRefresh()
        else
            self:SetPendingKeybindAssignment(entry.key, keybindSlot, actionName, bindingIndex)
        end
    else
        self:ClearPendingKeybindAssignmentForLayoutKey(entry.key)
    end

    if isNewAssignment and not actionAlreadyBound then
        self:Print(string.format("%s will use %s after you confirm a key in Controls. KeyBinder stays active so you can bind another button afterward.", entryName, GetZeroPanelKeybindSlotLabel(keybindSlot)))
    else
        self:Print(string.format("%s is using %s. Opening its binding dialog now. KeyBinder stays active so you can bind another button afterward.", entryName, GetZeroPanelKeybindSlotLabel(keybindSlot)))
    end

    if not self:OpenKeybindingsMenuForAction(actionName, bindingIndex) then
        if isNewAssignment and not actionAlreadyBound then
            self:ClearPendingKeybindAssignmentForLayoutKey(entry.key)
            self:Print("Unable to open Zero Panel Keybindings automatically. No slot was reserved because the bind was not confirmed.")
        else
            self:Print("Unable to open Zero Panel Keybindings automatically. Open Controls -> Zero Panel Keybindings and bind that slot there.")
        end
    end

    return true
end

function ZeroPanel:BindSelectedLayoutEntry()
    local entry = self:GetSelectedKeybindLayoutEntry()
    if not self:IsLayoutEntryBindable(entry) then
        self:Print(self:GetBindSelectedLayoutEntryReason())
        return
    end

    local keybindSlot = self:GetKeybindSlotForLayoutKey(entry.key)
    local entryName = tostring(entry.name or entry.key or "Selected entry")
    if keybindSlot == ZERO_PANEL_KEYBIND_NONE_VALUE then
        keybindSlot = self:GetFirstAvailableKeybindSlot()
        if not keybindSlot then
            self:Print(self:GetBindSelectedLayoutEntryReason())
            return
        end
    end

    local actionName = GetZeroPanelKeybindActionName(keybindSlot)
    local bindingIndex = self:GetPreferredBindingIndexForAction(actionName)
    local actionAlreadyBound = self:HasBoundKeyForAction(actionName)
    local isNewAssignment = self:GetKeybindSlotForLayoutKey(entry.key) == ZERO_PANEL_KEYBIND_NONE_VALUE

    if isNewAssignment then
        if actionAlreadyBound then
            self:SetKeybindSlotForLayoutKey(entry.key, keybindSlot)
            self:RefreshButtonOrderControlState()
            self:RequestSettingsRefresh()
        else
            self:SetPendingKeybindAssignment(entry.key, keybindSlot, actionName, bindingIndex)
        end
    end

    if isNewAssignment and not actionAlreadyBound then
        self:Print(string.format("%s will use %s after you confirm a key in Controls -> Zero Panel Keybindings.", entryName, GetZeroPanelKeybindSlotLabel(keybindSlot)))
    else
        self:Print(string.format("%s is using %s. Bind it in Controls -> Zero Panel Keybindings.", entryName, GetZeroPanelKeybindSlotLabel(keybindSlot)))
    end

    if not self:OpenKeybindingsMenuForAction(actionName, bindingIndex) then
        if isNewAssignment and not actionAlreadyBound then
            self:ClearPendingKeybindAssignmentForLayoutKey(entry.key)
            self:Print("Unable to open Zero Panel Keybindings automatically. No slot was reserved because the bind was not confirmed.")
        else
            self:Print("Unable to open Zero Panel Keybindings automatically. Open Controls -> Zero Panel Keybindings and bind that slot there.")
        end
    end
end

function ZeroPanel:IsLayoutEntryRemovable(entry)
    return entry ~= nil and (entry.customButtonId ~= nil or entry.customSeparatorId ~= nil)
end

function ZeroPanel:GetButtonOrderHelpText()
    return table.concat({
        "Drag rows or use the move buttons to change the live Zero Panel order.",
        string.format("|c%sGold rows|r are removable custom buttons or custom separators.", ORDER_ENTRY_REMOVABLE_HEX),
        string.format("|c%sGray rows|r are built-in Zero Panel entries. You can reorder or hide them, but you cannot delete them.", ORDER_ENTRY_FIXED_HEX),
        "Use the KEYBINDS section's Activate KeyBinder button to close the menu, then click a live Zero Panel button to open the correct entry in Zero Panel Keybindings.",
        "If that button does not have a slot yet, KeyBinder will assign the first free Zero Panel slot before opening the binding dialog.",
        "Right-click the panel background while KeyBinder is active to cancel.",
        "Delete custom buttons or custom separators from their own editor sections below.",
        "Hidden or unavailable rows still keep their saved place here.",
    }, "\n")
end

function ZeroPanel:GetDeleteSelectedLayoutEntryReason()
    local entry = self:GetDeleteSelectedLayoutEntry()
    if not entry then
        return "No row is selected in Reorder Layout. Click a row there, or pick a custom button or custom separator so Zero Panel can target its layout entry."
    end

    local entryName = tostring(entry.name or entry.key or "Selected entry")
    if not self:IsLayoutEntryRemovable(entry) then
        local entryType = entry.kind == "separator" and "built-in separator" or "built-in button"
        return string.format("%s is a %s, so it cannot be deleted.", entryName, entryType)
    end

    if entry.customSeparatorId ~= nil then
        return string.format("%s is the selected custom separator and can be deleted.", entryName)
    elseif entry.customButtonId ~= nil then
        return string.format("%s is the selected custom button and can be deleted.", entryName)
    end

    return string.format("%s is selected and can be deleted.", entryName)
end

function ZeroPanel:GetDeleteSelectedLayoutEntryTooltip()
    return table.concat({
        "Delete the selected removable layout entry from Zero Panel.",
        "Current Reason: " .. self:GetDeleteSelectedLayoutEntryReason(),
    }, "\n")
end

function ZeroPanel:GetDeleteSelectedLayoutEntryWarning()
    local entry = self:GetDeleteSelectedLayoutEntry()
    if not self:IsLayoutEntryRemovable(entry) then
        return nil
    end

    local entryName = tostring(entry.name or entry.key or "Selected entry")
    if entry.customSeparatorId ~= nil then
        return string.format("Delete %s from Zero Panel? This removes the selected custom separator from Button Order.", entryName)
    elseif entry.customButtonId ~= nil then
        return string.format("Delete %s from Zero Panel? This removes the selected custom button from Button Order.", entryName)
    end

    return string.format("Delete %s from Zero Panel?", entryName)
end

function ZeroPanel:ApplySettingsVisualStyles()
    local buttonOrderHelp = _G.ZeroPanelButtonOrderHelp
    if buttonOrderHelp and buttonOrderHelp.desc then
        buttonOrderHelp.desc:SetFont("ZoFontGameSmall")
    end

    local supportDescription = _G.ZeroPanelSupportDescription
    if supportDescription and supportDescription.title then
        ApplyColorToControl(supportDescription.title, ZERO_PANEL_LINK_HEX)
    end

    for _, style in ipairs(SETTINGS_SUBMENU_STYLES) do
        local submenuControl = _G[style.reference]
        if submenuControl then
            if submenuControl.label then
                ApplyColorToControl(submenuControl.label, style.hex)
            end

            if submenuControl.arrow then
                ApplyColorToControl(submenuControl.arrow, style.hex)
            end
        end
    end

    self:ConfigureButtonOrderListVisualStyles()
end

function ZeroPanel:ConfigureButtonOrderListVisualStyles()
    local orderListControl = _G.ZeroPanelLayoutOrderList
    local orderListBox = orderListControl and orderListControl.orderListBox
    local scrollListControl = orderListBox and orderListBox.scrollListControl
    if scrollListControl and type(ZO_Scroll_SetUseFadeGradient) == "function" then
        ZO_Scroll_SetUseFadeGradient(scrollListControl, false)
    end
end

function ZeroPanel:RefreshButtonOrderControlState()
    self:SyncLayoutSelectionFromOrderListControl()

    local function refreshActionButton(controlReferenceName, tooltipText, warningText)
        local control = _G[controlReferenceName]
        if not control then
            return
        end

        control.data = control.data or {}
        control.data.tooltipText = tooltipText

        if control.button then
            control.button.data = control.button.data or {}
            control.button.data.tooltipText = tooltipText
        end

        if not control.zeroPanelTooltipHandlersBound then
            control:SetHandler("OnMouseEnter", ZO_Options_OnMouseEnter)
            control:SetHandler("OnMouseExit", ZO_Options_OnMouseExit)
            control.zeroPanelTooltipHandlersBound = true
        end

        if type(control.UpdateDisabled) == "function" then
            control:UpdateDisabled()
        end

        if type(control.UpdateWarning) == "function" then
            control:UpdateWarning()
        elseif control.warning then
            control.warning.data = control.warning.data or {}
            control.warning.data.tooltipText = warningText
        end
    end

    refreshActionButton("ZeroPanelActivateKeybindPickerButton", self:GetActivateKeybindPickerTooltip(), nil)
    self:ApplySettingsVisualStyles()
end

function ZeroPanel:GetLayoutEntryTooltip(entry)
    if entry.kind == "separator" then
        local tooltipText = entry.tooltip or "Insert a horizontal separator line at this point in the panel layout."
        if self:IsLayoutEntryRemovable(entry) then
            return tooltipText .. "\nDelete this custom separator from the Custom Separators section."
        end
        return tooltipText .. "\nThis built-in separator cannot be deleted."
    elseif entry.definition then
        local tooltipText = self:GetButtonTooltip(entry.definition, entry)
        if self:IsLayoutEntryRemovable(entry) then
            return tooltipText .. "\nDelete this custom button from the Custom Buttons section."
        end
        return tooltipText .. "\nThis built-in button cannot be deleted."
    end

    return ""
end

function ZeroPanel:GetOrderListEntries()
    self:EnsureOrder()

    local entries = {}
    local layoutByKey = self:GetLayoutCatalogByKey()

    for _, entryKey in ipairs(self.savedVars.order or {}) do
        local entry = layoutByKey[entryKey]
        if entry then
            local orderUniqueKey = tonumber(entry.orderUniqueKey)
            local suffix = ""
            if entry.kind == "button" and entry.definition then
                if not self:IsButtonEnabledBySettings(entry.definition) then
                    suffix = "(hidden)"
                elseif entry.definition.hideWhenUnavailable and entry.definition.collectibleActionId and not self:HasUnlockedCollectible(entry.definition.collectibleActionId) then
                    suffix = "(unavailable)"
                end
            end

            if orderUniqueKey then
                local entryColorHex = self:IsLayoutEntryRemovable(entry) and ORDER_ENTRY_REMOVABLE_HEX or ORDER_ENTRY_FIXED_HEX
                local entryText = string.format("|c%s%s|r", entryColorHex, tostring(entry.name or entry.key))
                if entry.kind == "button" then
                    local keybindSlot = self:GetKeybindSlotForLayoutKey(entry.key)
                    if keybindSlot ~= ZERO_PANEL_KEYBIND_NONE_VALUE then
                        entryText = string.format("%s |c%s[%s]|r", entryText, ORDER_ENTRY_STATUS_HEX, GetZeroPanelKeybindSlotShortLabel(keybindSlot))
                    end
                end
                if suffix ~= "" then
                    entryText = string.format("%s |c%s%s|r", entryText, ORDER_ENTRY_STATUS_HEX, suffix)
                end

                entries[#entries + 1] = {
                    uniqueKey = orderUniqueKey,
                    value = entry.key,
                    text = entryText,
                    tooltip = self:GetLayoutEntryTooltip(entry),
                }
            end
        end
    end

    return entries
end

function ZeroPanel:GetCustomButtonChoiceEntries()
    local choices = {}
    local values = {}

    for _, customButtonId in ipairs(self:GetCustomButtonIds()) do
        choices[#choices + 1] = self:GetCustomButtonDisplayName(customButtonId)
        values[#values + 1] = customButtonId
    end

    if #choices == 0 then
        choices[1] = "No custom buttons yet."
        values[1] = 0
    end

    return choices, values
end

function ZeroPanel:GetCustomSeparatorChoiceEntries()
    local choices = {}
    local values = {}

    for _, customSeparatorId in ipairs(self:GetCustomSeparatorIds()) do
        local separatorData = self.savedVars.customSeparators[customSeparatorId]
        choices[#choices + 1] = (separatorData and separatorData.name) or string.format("Custom Separator %d", customSeparatorId)
        values[#values + 1] = customSeparatorId
    end

    if #choices == 0 then
        choices[1] = "No custom separators yet."
        values[1] = 0
    end

    return choices, values
end

function ZeroPanel:RefreshCustomEditorControls()
    self:RegisterKeybindStringIds()

    local customButtonChoices, customButtonValues = self:GetCustomButtonChoiceEntries()
    local customButtonId = self:GetSelectedCustomButtonId() or 0
    self:UpdateDropdownReference("ZeroPanelCustomButtonSelector", customButtonChoices, customButtonValues, customButtonId)

    local customSeparatorChoices, customSeparatorValues = self:GetCustomSeparatorChoiceEntries()
    local customSeparatorId = self:GetSelectedCustomSeparatorId() or 0
    self:UpdateDropdownReference("ZeroPanelCustomSeparatorSelector", customSeparatorChoices, customSeparatorValues, customSeparatorId)

    self:RefreshSummonableChoiceControls()
    self:RefreshCollectibleBrowserControls()
    self:RefreshTextureBrowserControls()
    self:RefreshButtonOrderControlState()
    self:RequestSettingsRefresh()
end

function ZeroPanel:RefreshCollectibleDependentControls()
    self:InvalidateCollectibleCaches()
    self:RefreshSummonableChoiceControls()
    if self.collectibleBrowserWindow or _G.ZeroPanelCollectibleSelector then
        self:RefreshCollectibleBrowserControls()
    end
    self:RefreshPanel()
    self:RefreshButtonOrderControlState()
    self:RequestSettingsRefresh()
end

function ZeroPanel:QueueCollectibleStateRefresh()
    if self.collectibleRefreshQueued then
        return
    end

    self.collectibleRefreshQueued = true
    EVENT_MANAGER:RegisterForUpdate(self.name .. "CollectibleRefresh", 100, function()
        EVENT_MANAGER:UnregisterForUpdate(self.name .. "CollectibleRefresh")
        self.collectibleRefreshQueued = false
        self:RefreshCollectibleDependentControls()
    end)
end

function ZeroPanel:RemoveLayoutKey(layoutKey)
    local filteredOrder = {}

    for _, entryKey in ipairs(self.savedVars.order or {}) do
        if entryKey ~= layoutKey then
            filteredOrder[#filteredOrder + 1] = entryKey
        end
    end

    self.savedVars.order = filteredOrder
end

function ZeroPanel:CreateCustomButton()
    local customButtonId = tonumber(self.savedVars.nextCustomButtonId) or 1
    self.savedVars.nextCustomButtonId = customButtonId + 1
    self.savedVars.customButtons[customButtonId] = {
        enabled = true,
        actionType = "command",
        title = "",
        useAutoTitle = true,
        icon = "",
        command = "",
    }

    self.savedVars.order[#self.savedVars.order + 1] = GetCustomButtonLayoutKey(customButtonId)
    self:SetSelectedCustomButtonId(customButtonId)
    self:EnsureOrder()
    self:RefreshPanel()
    self:RefreshCustomEditorControls()
end

function ZeroPanel:DeleteSelectedCustomButton()
    local customButtonId = self:GetSelectedCustomButtonId()
    if not customButtonId then
        return
    end

    self.savedVars.customButtons[customButtonId] = nil
    local layoutKey = GetCustomButtonLayoutKey(customButtonId)
    self:RemoveKeybindForLayoutKey(layoutKey)
    self:RemoveLayoutKey(layoutKey)
    if self.selectedLayoutOrderKey == layoutKey then
        self:SetSelectedLayoutOrderKey(nil)
    end
    if self.selectedEditorLayoutKey == layoutKey then
        self.selectedEditorLayoutKey = nil
    end
    self:SetSelectedCustomButtonId(nil)
    self:EnsureOrder()
    self:RefreshPanel()
    self:RefreshCustomEditorControls()
end

function ZeroPanel:SaveSelectedCustomButton()
    local customButtonData = self:GetSelectedCustomButtonData()
    if not customButtonData then
        return
    end

    customButtonData.title = TrimText(customButtonData.title)
    customButtonData.icon = TrimText(customButtonData.icon)
    if customButtonData.actionType == "command" then
        customButtonData.command = tostring(customButtonData.command or "")
    else
        customButtonData.command = ""
    end

    self:RefreshPanel()
    self:RefreshCustomEditorControls()
end

function ZeroPanel:AddCustomSeparator()
    local customSeparatorId = tonumber(self.savedVars.nextCustomSeparatorId) or 1
    self.savedVars.nextCustomSeparatorId = customSeparatorId + 1
    self.savedVars.customSeparators[customSeparatorId] = {
        name = string.format("Custom Separator %d", customSeparatorId),
    }

    self.savedVars.order[#self.savedVars.order + 1] = GetCustomSeparatorLayoutKey(customSeparatorId)
    self:SetSelectedCustomSeparatorId(customSeparatorId)
    self:EnsureOrder()
    self:RefreshPanel()
    self:RefreshCustomEditorControls()
end

function ZeroPanel:DeleteSelectedCustomSeparator()
    local customSeparatorId = self:GetSelectedCustomSeparatorId()
    if not customSeparatorId then
        return
    end

    self.savedVars.customSeparators[customSeparatorId] = nil
    local layoutKey = GetCustomSeparatorLayoutKey(customSeparatorId)
    self:RemoveKeybindForLayoutKey(layoutKey)
    self:RemoveLayoutKey(layoutKey)
    if self.selectedLayoutOrderKey == layoutKey then
        self:SetSelectedLayoutOrderKey(nil)
    end
    if self.selectedEditorLayoutKey == layoutKey then
        self.selectedEditorLayoutKey = nil
    end
    self:SetSelectedCustomSeparatorId(nil)
    self:EnsureOrder()
    self:RefreshPanel()
    self:RefreshCustomEditorControls()
end

function ZeroPanel:CanDeleteSelectedLayoutEntry()
    return self:IsLayoutEntryRemovable(self:GetDeleteSelectedLayoutEntry())
end

function ZeroPanel:DeleteSelectedLayoutEntry()
    local entry = self:GetDeleteSelectedLayoutEntry()
    if not self:IsLayoutEntryRemovable(entry) then
        self:Print(self:GetDeleteSelectedLayoutEntryReason())
        return
    end

    if entry.customButtonId ~= nil then
        self.savedVars.customButtons[entry.customButtonId] = nil
        if self.selectedCustomButtonId == entry.customButtonId then
            self:SetSelectedCustomButtonId(nil)
        end
    elseif entry.customSeparatorId ~= nil then
        self.savedVars.customSeparators[entry.customSeparatorId] = nil
        if self.selectedCustomSeparatorId == entry.customSeparatorId then
            self:SetSelectedCustomSeparatorId(nil)
        end
    end

    self:RemoveKeybindForLayoutKey(entry.key)
    self:RemoveLayoutKey(entry.key)
    self:SetSelectedLayoutOrderKey(nil)
    if self.selectedEditorLayoutKey == entry.key then
        self.selectedEditorLayoutKey = nil
    end
    self:EnsureOrder()
    self:RefreshPanel()
    self:RefreshCustomEditorControls()
end

function ZeroPanel:ApplyCustomButtonPreset(presetId)
    local customButtonData = self:GetSelectedCustomButtonData()
    local preset = GetCustomButtonPresetById(presetId)
    if not customButtonData or not preset then
        return
    end

    customButtonData.enabled = true
    customButtonData.actionType = preset.actionType or "command"
    customButtonData.useAutoTitle = true
    customButtonData.title = ""
    customButtonData.icon = preset.icon or ""
    customButtonData.command = preset.command or ""
    self:RefreshPanel()
    self:RefreshCustomEditorControls()
end

function ZeroPanel:ApplySelectedCollectibleToCustomButton()
    local customButtonData = self:GetSelectedCustomButtonData()
    local state = self:GetCollectibleBrowserState()
    local collectibleId = tonumber(state.selectedCollectibleId) or 0
    if not customButtonData or collectibleId <= 0 then
        return
    end

    customButtonData.enabled = true
    customButtonData.actionType = "command"
    customButtonData.useAutoTitle = true
    customButtonData.title = ""
    customButtonData.icon = GetCollectibleIcon(collectibleId) or ""
    customButtonData.command = string.format("/script UseCollectible(%d, GAMEPLAY_ACTOR_CATEGORY_PLAYER)", collectibleId)
    self:RefreshPanel()
    self:RefreshCustomEditorControls()
end

function ZeroPanel:GetCustomButtonEditorDescription()
    local customButtonId = self:GetSelectedCustomButtonId()
    local customButtonData = self:GetSelectedCustomButtonData()
    if not customButtonId or not customButtonData then
        return "Create a custom button, then select it here to edit its action, icon, and hover title. Default Zero Panel buttons cannot be edited in this section."
    end

    local parts = {
        string.format("Editing custom button %d.", customButtonId),
        string.format("Current title: %s", self:GetCustomButtonResolvedTitle(customButtonId)),
    }

    local action = self:GetCustomButtonAction(customButtonData.actionType)
    parts[#parts + 1] = string.format("Action type: %s.", action.name or customButtonData.actionType)

    local command = TrimText(customButtonData.command)
    if customButtonData.actionType == "command" then
        if command ~= "" then
            parts[#parts + 1] = string.format("Command: %s.", command)
        else
            parts[#parts + 1] = "No command is configured yet."
        end
    end

    return table.concat(parts, " ")
end

function ZeroPanel:GetCustomButtonEditorTitleValue()
    local customButtonId = self:GetSelectedCustomButtonId()
    local buttonData = self:GetSelectedCustomButtonData()
    if not customButtonId or not buttonData then
        return ""
    end

    local customTitle = TrimText(buttonData.title)
    if buttonData.useAutoTitle and customTitle == "" then
        return self:GetCustomButtonResolvedTitle(customButtonId)
    end

    return customTitle
end

function ZeroPanel:ApplyAnchor()
    if not self.window then
        return
    end

    local edge = self.savedVars.edge == "right" and "right" or "left"
    local xOffset = tonumber(self.savedVars.offsetX) or DEFAULTS.offsetX
    local yOffset = tonumber(self.savedVars.offsetY) or DEFAULTS.offsetY
    local clampedXOffset, clampedYOffset = GetClampedWindowOffsets(self.window, xOffset, yOffset)

    if clampedXOffset ~= xOffset or clampedYOffset ~= yOffset then
        self.savedVars.offsetX = clampedXOffset
        self.savedVars.offsetY = clampedYOffset
    end

    self.window:ClearAnchors()
    if edge == "right" then
        self.window:SetAnchor(TOPRIGHT, GuiRoot, TOPRIGHT, -clampedXOffset, clampedYOffset)
    else
        self.window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, clampedXOffset, clampedYOffset)
    end
end

function ZeroPanel:SaveAnchor()
    if not self.window then
        return
    end

    local centerX = (self.window:GetLeft() or 0) + (self.window:GetWidth() / 2)
    local guiCenterX = GuiRoot:GetWidth() / 2
    local isRight = centerX >= guiCenterX

    self.savedVars.edge = isRight and "right" or "left"
    self.savedVars.offsetY = self.window:GetTop() or DEFAULTS.offsetY
    if isRight then
        self.savedVars.offsetX = GuiRoot:GetWidth() - (self.window:GetRight() or GuiRoot:GetWidth())
    else
        self.savedVars.offsetX = self.window:GetLeft() or DEFAULTS.offsetX
    end

    ResetTopLevelAnchor(self.window, self.savedVars.edge)
end

function ZeroPanel:ResetPosition()
    self.savedVars.edge = DEFAULTS.edge
    self.savedVars.offsetX = DEFAULTS.offsetX
    self.savedVars.offsetY = DEFAULTS.offsetY
    self:ApplyAnchor()
end

function ZeroPanel:GetDefaultKeybindPickerPromptAnchor()
    local control = self.keybindPickerPrompt
    if not control then
        return "right", 0, 0
    end

    local guiWidth = GuiRoot:GetWidth() or control:GetWidth() or KEYBIND_PICKER_PROMPT_WIDTH
    local guiHeight = GuiRoot:GetHeight() or control:GetHeight() or KEYBIND_PICKER_PROMPT_HEIGHT
    local controlWidth = control:GetWidth() or KEYBIND_PICKER_PROMPT_WIDTH
    local controlHeight = control:GetHeight() or KEYBIND_PICKER_PROMPT_HEIGHT
    local left = math.floor((guiWidth - controlWidth) / 2)
    local top = math.floor((guiHeight - controlHeight) / 2) + KEYBIND_PICKER_PROMPT_DEFAULT_CENTER_Y_OFFSET
    local centerX = left + (controlWidth / 2)
    local isRight = centerX >= (guiWidth / 2)
    local xOffset = isRight and (guiWidth - (left + controlWidth)) or left
    local clampedXOffset, clampedYOffset = GetClampedWindowOffsets(control, xOffset, top)

    return isRight and "right" or "left", clampedXOffset, clampedYOffset
end

function ZeroPanel:ApplyKeybindPickerPromptAnchor()
    local control = self.keybindPickerPrompt
    if not control then
        return
    end

    local savedPosition = type(self.savedVars.keybindPickerPromptPosition) == "table" and self.savedVars.keybindPickerPromptPosition or nil
    local useSavedAnchor = savedPosition and savedPosition.useSavedAnchor == true
    local edge, xOffset, yOffset

    if useSavedAnchor then
        edge = savedPosition.edge == "right" and "right" or "left"
        xOffset = tonumber(savedPosition.offsetX)
        yOffset = tonumber(savedPosition.offsetY)
    end

    if not xOffset or not yOffset then
        edge, xOffset, yOffset = self:GetDefaultKeybindPickerPromptAnchor()
        useSavedAnchor = false
    end

    local clampedXOffset, clampedYOffset = GetClampedWindowOffsets(control, xOffset, yOffset)
    if useSavedAnchor and (clampedXOffset ~= xOffset or clampedYOffset ~= yOffset) then
        savedPosition.offsetX = clampedXOffset
        savedPosition.offsetY = clampedYOffset
    end

    control:ClearAnchors()
    if edge == "right" then
        control:SetAnchor(TOPRIGHT, GuiRoot, TOPRIGHT, -clampedXOffset, clampedYOffset)
    else
        control:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, clampedXOffset, clampedYOffset)
    end
end

function ZeroPanel:SaveKeybindPickerPromptAnchor()
    local control = self.keybindPickerPrompt
    if not control then
        return
    end

    local savedPosition = type(self.savedVars.keybindPickerPromptPosition) == "table" and self.savedVars.keybindPickerPromptPosition or {}
    local defaultEdge, defaultXOffset, defaultYOffset = self:GetDefaultKeybindPickerPromptAnchor()
    local centerX = (control:GetLeft() or 0) + ((control:GetWidth() or KEYBIND_PICKER_PROMPT_WIDTH) / 2)
    local guiCenterX = (GuiRoot:GetWidth() or 0) / 2
    local isRight = centerX >= guiCenterX

    savedPosition.useSavedAnchor = true
    savedPosition.edge = isRight and "right" or "left"
    savedPosition.offsetY = control:GetTop() or defaultYOffset
    if isRight then
        savedPosition.offsetX = (GuiRoot:GetWidth() or 0) - (control:GetRight() or (GuiRoot:GetWidth() or 0))
    else
        savedPosition.offsetX = control:GetLeft() or defaultXOffset
    end

    self.savedVars.keybindPickerPromptPosition = savedPosition
    ResetTopLevelAnchor(control, savedPosition.edge or defaultEdge)
end

function ZeroPanel:StopKeybindPickerPromptMovement()
    if self.keybindPickerPrompt and self.isMovingKeybindPickerPrompt then
        self.keybindPickerPrompt:StopMovingOrResizing()
    end

    self.isMovingKeybindPickerPrompt = false
end

function ZeroPanel:StopWindowMovement()
    if self.window and self.isMovingWindow then
        self.window:StopMovingOrResizing()
    end

    self.isMovingWindow = false
end

function ZeroPanel:ApplyWindowLockState()
    if not self.window or not self.backdrop then
        return
    end

    if self.savedVars.locked then
        self:StopWindowMovement()
    end

    self.window:SetMovable(not self.savedVars.locked)
    self.backdrop:SetEdgeColor(unpack(self.savedVars.locked and BORDER_LOCKED or BORDER_UNLOCKED))
    self.backdrop:SetMouseEnabled(not self.savedVars.locked)
end

function ZeroPanel:IsMouseOverControl(control)
    if not control or control:IsHidden() then
        return false
    end

    if type(MouseIsOver) == "function" then
        return MouseIsOver(control)
    end

    return WINDOW_MANAGER:GetMouseOverControl() == control
end

function ZeroPanel:RefreshButtonHoverState(control)
    if not control or not control.bg then
        return
    end

    local isHovered = self:IsMouseOverControl(control)
    if isHovered then
        if self.keybindPickerActive then
            control.bg:SetCenterColor(0.15, 0.23, 0.31, 0.98)
        else
            control.bg:SetCenterColor(0.18, 0.20, 0.26, 0.98)
        end

        if self.keybindPickerActive and control.layoutEntry then
            ZO_Tooltips_ShowTextTooltip(control, RIGHT, self:GetKeybindPickerTooltip(control.layoutEntry))
        elseif control.definition then
            ZO_Tooltips_ShowTextTooltip(control, RIGHT, self:GetButtonTooltip(control.definition, control.layoutEntry))
        end
    else
        control.bg:SetCenterColor(0.12, 0.13, 0.17, 0.96)
        ZO_Tooltips_HideTextTooltip()
    end
end

function ZeroPanel:RefreshButtonHoverStates()
    local hoveredButton

    for _, button in ipairs(self.buttons or {}) do
        if button and not button:IsHidden() and button.bg then
            local isHovered = self:IsMouseOverControl(button)
            if isHovered then
                hoveredButton = button
                if self.keybindPickerActive then
                    button.bg:SetCenterColor(0.15, 0.23, 0.31, 0.98)
                else
                    button.bg:SetCenterColor(0.18, 0.20, 0.26, 0.98)
                end
            else
                button.bg:SetCenterColor(0.12, 0.13, 0.17, 0.96)
            end
        end
    end

    if hoveredButton and self.keybindPickerActive and hoveredButton.layoutEntry then
        ZO_Tooltips_ShowTextTooltip(hoveredButton, RIGHT, self:GetKeybindPickerTooltip(hoveredButton.layoutEntry))
    elseif hoveredButton and hoveredButton.definition then
        ZO_Tooltips_ShowTextTooltip(hoveredButton, RIGHT, self:GetButtonTooltip(hoveredButton.definition, hoveredButton.layoutEntry))
    else
        ZO_Tooltips_HideTextTooltip()
    end
end

function ZeroPanel:QueueHoveredTooltipRefresh()
    if type(zo_callLater) ~= "function" then
        self:RefreshButtonHoverStates()
        return
    end

    self.hoverTooltipRefreshToken = (tonumber(self.hoverTooltipRefreshToken) or 0) + 1
    local refreshToken = self.hoverTooltipRefreshToken
    local refreshDelays = {25, 125}

    for _, delayMs in ipairs(refreshDelays) do
        zo_callLater(function()
            if self.hoverTooltipRefreshToken ~= refreshToken then
                return
            end

            self:RefreshPanel()
        end, delayMs)
    end
end

function ZeroPanel:CreateWindow()
    if self.window then
        return
    end

    local window = WINDOW_MANAGER:CreateTopLevelWindow(CONTROL_NAME_PREFIX .. "Window")
    window:SetClampedToScreen(true)
    window:SetMovable(false)
    window:SetMouseEnabled(true)
    window:SetDrawTier(DT_MEDIUM)
    window:SetHandler("OnMoveStart", function()
        self.isMovingWindow = true
    end)
    window:SetHandler("OnMoveStop", function()
        local wasMoving = self.isMovingWindow
        self.isMovingWindow = false
        if wasMoving then
            self:SaveAnchor()
        end
    end)
    window:SetHandler("OnEffectivelyShown", function()
        self:RefreshVisibility()
    end)

    local backdrop = WINDOW_MANAGER:CreateControl(window:GetName() .. "Backdrop", window, CT_BACKDROP)
    backdrop:SetAnchorFill()
    backdrop:SetCenterColor(0.08, 0.09, 0.12, 0.72)
    backdrop:SetEdgeColor(unpack(self.savedVars.locked and BORDER_LOCKED or BORDER_UNLOCKED))
    backdrop:SetHandler("OnMouseDown", function(_, button)
        if button == MOUSE_BUTTON_INDEX_LEFT and not self.savedVars.locked then
            self.isMovingWindow = true
            window:StartMoving()
        end
    end)
    backdrop:SetHandler("OnMouseUp", function(_, button)
        if button == MOUSE_BUTTON_INDEX_LEFT then
            self:StopWindowMovement()
        elseif button == MOUSE_BUTTON_INDEX_RIGHT and self.keybindPickerActive then
            self:CancelKeybindPicker("KeyBinder canceled.")
        end
    end)

    self.window = window
    self.backdrop = backdrop
    self:ApplyWindowLockState()
    self.fragment = ZO_SimpleSceneFragment:New(window)

    local keybindPickerPrompt = WINDOW_MANAGER:CreateTopLevelWindow(CONTROL_NAME_PREFIX .. "KeybindPrompt")
    keybindPickerPrompt:SetDimensions(KEYBIND_PICKER_PROMPT_WIDTH, KEYBIND_PICKER_PROMPT_HEIGHT)
    keybindPickerPrompt:SetAnchor(CENTER, GuiRoot, CENTER, 0, KEYBIND_PICKER_PROMPT_DEFAULT_CENTER_Y_OFFSET)
    keybindPickerPrompt:SetClampedToScreen(true)
    keybindPickerPrompt:SetHidden(true)
    keybindPickerPrompt:SetMouseEnabled(true)
    keybindPickerPrompt:SetMovable(true)
    keybindPickerPrompt:SetDrawLayer(DL_CONTROLS)
    keybindPickerPrompt:SetDrawTier(DT_LOW)
    keybindPickerPrompt:SetHandler("OnMoveStart", function()
        self.isMovingKeybindPickerPrompt = true
    end)
    keybindPickerPrompt:SetHandler("OnMoveStop", function()
        local wasMoving = self.isMovingKeybindPickerPrompt
        self.isMovingKeybindPickerPrompt = false
        if wasMoving then
            self:SaveKeybindPickerPromptAnchor()
        end
    end)
    keybindPickerPrompt:SetHandler("OnEffectivelyShown", function(control)
        if not self.keybindPickerActive then
            control:SetMouseEnabled(false)
            control:SetHidden(true)
        end
    end)

    keybindPickerPrompt.backdrop = WINDOW_MANAGER:CreateControl(keybindPickerPrompt:GetName() .. "Backdrop", keybindPickerPrompt, CT_BACKDROP)
    keybindPickerPrompt.backdrop:SetAnchorFill()
    keybindPickerPrompt.backdrop:SetCenterColor(0.05, 0.06, 0.09, 0.9)
    keybindPickerPrompt.backdrop:SetEdgeColor(0.29, 0.61, 0.86, 0.95)
    keybindPickerPrompt.backdrop:SetHandler("OnMouseDown", function(_, button)
        if button == MOUSE_BUTTON_INDEX_LEFT then
            self.isMovingKeybindPickerPrompt = true
            keybindPickerPrompt:StartMoving()
        end
    end)
    keybindPickerPrompt.backdrop:SetHandler("OnMouseUp", function(_, button)
        if button == MOUSE_BUTTON_INDEX_LEFT then
            self:StopKeybindPickerPromptMovement()
        end
    end)

    keybindPickerPrompt.cancelButton = CreatePopupButton(keybindPickerPrompt:GetName() .. "CancelButton", keybindPickerPrompt, "Cancel Keybind Mode", 216, 30)
    keybindPickerPrompt.cancelButton:SetAnchor(CENTER, keybindPickerPrompt, CENTER, 0, 0)
    keybindPickerPrompt.cancelButton:SetHandler("OnClicked", function()
        self:CancelKeybindPicker("KeyBinder canceled.")
    end)

    self.keybindPickerPrompt = keybindPickerPrompt
    self:ApplyKeybindPickerPromptAnchor()
    self.sceneRegistration = {
        hud = false,
        hudui = false,
    }
end

function ZeroPanel:RefreshKeybindPickerPromptVisibility()
    if not self.keybindPickerPrompt then
        return
    end

    local shouldShow = self.keybindPickerActive == true
    if not shouldShow then
        self:StopKeybindPickerPromptMovement()
    elseif self.keybindPickerPrompt:IsHidden() then
        self:ApplyKeybindPickerPromptAnchor()
    end

    self.keybindPickerPrompt:SetMouseEnabled(shouldShow)
    self.keybindPickerPrompt:SetHidden(not shouldShow)
end

function ZeroPanel:UpdateSceneRegistration()
    if not self.fragment then
        return
    end

    if not self.sceneRegistration.hud then
        HUD_SCENE:AddFragment(self.fragment)
        self.sceneRegistration.hud = true
    end

    local wantsHudUi = self.savedVars.showInHudUI == true
    if wantsHudUi and not self.sceneRegistration.hudui then
        HUD_UI_SCENE:AddFragment(self.fragment)
        self.sceneRegistration.hudui = true
    elseif not wantsHudUi and self.sceneRegistration.hudui then
        HUD_UI_SCENE:RemoveFragment(self.fragment)
        self.sceneRegistration.hudui = false
    end
end

function ZeroPanel:RefreshButtonAppearance(button, definition)
    local usable = self:IsButtonUsable(definition)
    local active = usable and self:IsButtonActive(definition)

    button.icon:SetTexture(self:GetButtonIcon(definition) or "")
    if active then
        button.icon:SetColor(unpack(COLOR_ACTIVE))
    elseif usable then
        button.icon:SetColor(unpack(COLOR_READY))
    else
        button.icon:SetColor(unpack(COLOR_DISABLED))
    end
    if type(button.icon.SetDesaturation) == "function" then
        button.icon:SetDesaturation(self:GetIconDesaturation() / 100)
    end

    button.usable = usable
    button.definition = definition
    button:SetMouseEnabled(true)
    if button.frame then
        if self.keybindPickerActive then
            button.frame:SetEdgeColor(0.29, 0.61, 0.86, 1)
        else
            button.frame:SetEdgeColor(0.22, 0.22, 0.26, 1)
        end
    end
end

function ZeroPanel:RefreshPanel()
    if not self.window then
        return
    end

    local layoutItems = self:GetLayoutItems()
    local buttonSize = tonumber(self.savedVars.buttonSize) or DEFAULTS.buttonSize
    local spacing = tonumber(self.savedVars.spacing) or DEFAULTS.spacing
    local padding = tonumber(self.savedVars.padding) or DEFAULTS.padding
    local placements, panelWidth, panelHeight = self:BuildPanelLayout(layoutItems, buttonSize, spacing, padding)
    local buttonCount = 0
    for _, item in ipairs(layoutItems) do
        if item.kind == "button" then
            buttonCount = buttonCount + 1
        end
    end
    self.hasButtons = buttonCount > 0

    self.window:SetDimensions(panelWidth, panelHeight)
    self:ApplyAnchor()

    self.backdrop:SetCenterColor(0.08, 0.09, 0.12, (tonumber(self.savedVars.backgroundAlpha) or DEFAULTS.backgroundAlpha) / 100)
    self:ApplyWindowLockState()

    self.buttons = self.buttons or {}
    self.dividers = self.dividers or {}

    local buttonIndex = 0
    local dividerIndex = 0
    for _, placement in ipairs(placements) do
        if placement.kind == "divider" then
            dividerIndex = dividerIndex + 1
            local divider = self.dividers[dividerIndex]
            if not divider then
                divider = WINDOW_MANAGER:CreateControl(self.window:GetName() .. "Divider" .. dividerIndex, self.window, CT_BACKDROP)
                divider:SetMouseEnabled(false)
                self.dividers[dividerIndex] = divider
            end

            divider:ClearAnchors()
            divider:SetDimensions(placement.width, placement.height)
            divider:SetAnchor(TOPLEFT, self.window, TOPLEFT, placement.x, placement.y)
            divider:SetCenterColor(unpack(DIVIDER_COLOR))
            divider:SetEdgeColor(0, 0, 0, 0)
            divider:SetHidden(false)
        else
            buttonIndex = buttonIndex + 1
            local definition = placement.item.definition
            local button = self.buttons[buttonIndex]
            if not button then
                button = WINDOW_MANAGER:CreateControl(self.window:GetName() .. "Button" .. buttonIndex, self.window, CT_BUTTON)
                button:SetDrawTier(DT_MEDIUM)

                button.bg = WINDOW_MANAGER:CreateControl(button:GetName() .. "Backdrop", button, CT_BACKDROP)
                button.bg:SetAnchorFill()
                button.bg:SetCenterColor(0.12, 0.13, 0.17, 0.96)
                button.bg:SetEdgeColor(0.22, 0.22, 0.26, 1)
                button.bg:SetMouseEnabled(false)

                button.icon = WINDOW_MANAGER:CreateControl(nil, button, CT_TEXTURE)
                button.icon:SetAnchorFill()
                button.icon:SetDrawLevel(1)
                button.icon:SetMouseEnabled(false)

                button.frame = WINDOW_MANAGER:CreateControl(button:GetName() .. "Frame", button, CT_BACKDROP)
                button.frame:SetAnchorFill()
                button.frame:SetCenterColor(0, 0, 0, 0)
                button.frame:SetEdgeColor(0.22, 0.22, 0.26, 1)
                button.frame:SetDrawLevel(2)
                button.frame:SetMouseEnabled(false)

                button.keybindBackground = WINDOW_MANAGER:CreateControl(button:GetName() .. "KeybindBackground", self.window, CT_BACKDROP)
                button.keybindBackground:SetDrawLayer(DL_OVERLAY)
                button.keybindBackground:SetDrawTier(DT_HIGH)
                button.keybindBackground:SetDrawLevel(3)
                button.keybindBackground:SetMouseEnabled(false)
                button.keybindBackground:SetHidden(true)

                button.keybindLabel = WINDOW_MANAGER:CreateControl(button:GetName() .. "Keybind", self.window, CT_LABEL)
                button.keybindLabel:SetDrawLayer(DL_OVERLAY)
                button.keybindLabel:SetDrawTier(DT_HIGH)
                button.keybindLabel:SetDrawLevel(5)
                button.keybindLabel:SetMouseEnabled(false)
                button.keybindLabel:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
                button.keybindLabel:SetHidden(true)

                button.keybindShadowLabel = WINDOW_MANAGER:CreateControl(button:GetName() .. "KeybindShadow", self.window, CT_LABEL)
                button.keybindShadowLabel:SetDrawLayer(DL_OVERLAY)
                button.keybindShadowLabel:SetDrawTier(DT_HIGH)
                button.keybindShadowLabel:SetDrawLevel(4)
                button.keybindShadowLabel:SetMouseEnabled(false)
                button.keybindShadowLabel:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
                button.keybindShadowLabel:SetHidden(true)

                button.keybindColorLabel = WINDOW_MANAGER:CreateControl(button:GetName() .. "KeybindColor", self.window, CT_LABEL)
                button.keybindColorLabel:SetDrawLayer(DL_OVERLAY)
                button.keybindColorLabel:SetDrawTier(DT_HIGH)
                button.keybindColorLabel:SetDrawLevel(6)
                button.keybindColorLabel:SetMouseEnabled(false)
                button.keybindColorLabel:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
                button.keybindColorLabel:SetHidden(true)

                button:SetHandler("OnMouseEnter", function(control)
                    self:RefreshButtonHoverStates()
                end)
                button:SetHandler("OnMouseExit", function(control)
                    self:RefreshButtonHoverStates()
                end)
                button:SetHandler("OnClicked", function(control, buttonIndex)
                    if self.keybindPickerActive then
                        self:HandleKeybindPickerClick(control, buttonIndex)
                    else
                        self:ExecuteButtonDefinition(control.definition)
                    end
                end)

                self.buttons[buttonIndex] = button
            end

            button:ClearAnchors()
            button:SetDimensions(placement.width, placement.height)
            button:SetAnchor(TOPLEFT, self.window, TOPLEFT, placement.x, placement.y)
            button:SetHidden(false)
            button.layoutEntry = placement.item.entry
            self:RefreshButtonAppearance(button, definition)
            self:RefreshButtonKeybindDisplay(button, placement.item.entry)
        end
    end

    for index = buttonIndex + 1, #(self.buttons or {}) do
        self.buttons[index]:SetHidden(true)
        self.buttons[index].layoutEntry = nil
        if self.buttons[index].keybindBackground then
            self.buttons[index].keybindBackground:SetHidden(true)
        end
        if self.buttons[index].keybindShadowLabel then
            self.buttons[index].keybindShadowLabel:SetText("")
            self.buttons[index].keybindShadowLabel:SetHidden(true)
        end
        if self.buttons[index].keybindColorLabel then
            self.buttons[index].keybindColorLabel:SetText("")
            self.buttons[index].keybindColorLabel:SetHidden(true)
        end
        if self.buttons[index].keybindLabel then
            self.buttons[index].keybindLabel:SetText("")
            self.buttons[index].keybindLabel:SetHidden(true)
        end
    end

    for index = dividerIndex + 1, #(self.dividers or {}) do
        self.dividers[index]:SetHidden(true)
    end

    self:RefreshButtonHoverStates()
    self:RefreshVisibility()
end

function ZeroPanel:RefreshVisibility()
    if not self.window then
        return
    end

    local shouldShow = self.keybindPickerActive == true or self.savedVars.enabled
    if shouldShow and self.keybindPickerActive ~= true and self.savedVars.showOnlyWhenReticleHidden then
        shouldShow = self.reticleHidden ~= false
    end
    if shouldShow then
        shouldShow = self.hasButtons ~= false
    end

    self.window:SetHidden(not shouldShow)
    self:RefreshKeybindPickerPromptVisibility()
end

function ZeroPanel:OpenSettings()
    if self.keybindPickerActive then
        self:CancelKeybindPicker()
    end

    if self.addonPanel then
        LibAddonMenu2:OpenToPanel(self.addonPanel)
        if type(zo_callLater) == "function" then
            zo_callLater(function()
                self:InvalidateCollectibleCaches()
                self:RefreshCustomEditorControls()
                self:RefreshLayoutDirectionOptionControls()
                self:RefreshKeybindFontChoices()
                self:ApplySettingsVisualStyles()
            end, 50)
        else
            self:InvalidateCollectibleCaches()
            self:RefreshCustomEditorControls()
            self:RefreshLayoutDirectionOptionControls()
            self:RefreshKeybindFontChoices()
            self:ApplySettingsVisualStyles()
        end
    end
end

function ZeroPanel:BuildSettings()
    local LAM = LibAddonMenu2
    if not LAM then
        return
    end

    local panelData = {
        type = "panel",
        name = ZERO_PANEL_SETTINGS_NAME,
        displayName = ZERO_PANEL_SETTINGS_NAME,
        author = GetBrandedZeroAddonName(),
        version = self.versionDisplay,
        slashCommand = "/zp",
        website = ZERO_PANEL_GITHUB_URL,
        feedback = ZERO_PANEL_GITHUB_ISSUES_URL,
        registerForRefresh = true,
        registerForDefaults = true,
    }

    self.addonPanel = LAM:RegisterAddonPanel(self.panelId, panelData)
    if not self.lamPanelClosedCallback and CALLBACK_MANAGER and type(CALLBACK_MANAGER.RegisterCallback) == "function" then
        self.lamPanelClosedCallback = function(panel)
            if panel ~= self.addonPanel then
                return
            end

            self:CloseCollectibleBrowserPopup()
            self:CloseTextureBrowserPopup()
        end
        CALLBACK_MANAGER:RegisterCallback("LAM-PanelClosed", self.lamPanelClosedCallback)
    end

    local visibleButtonsControls = {}
    local keybindFontChoices, keybindFontValues = self:GetKeybindFontChoices()
    local appearanceControls = {
        {
            type = "description",
            text = "Adjust the panel layout and visual styling. Layout Direction matches the actual bar orientation, and the wrap setting below renames itself to Buttons Per Row or Buttons Per Column to match.",
            width = "full",
        },
        {
            type = "dropdown",
            name = "Layout Direction",
            tooltip = "Horizontal runs the bar left to right. Vertical stacks the bar top to bottom. The wrap setting below updates immediately to match.",
            choices = {"Horizontal", "Vertical"},
            choicesValues = {"vertical", "horizontal"},
            getFunc = function()
                return self:GetLayoutDirection()
            end,
            setFunc = function(value)
                self.savedVars.layoutDirection = value == "horizontal" and "horizontal" or "vertical"
                self:RefreshPanel()
                self:RefreshLayoutDirectionOptionControls()
            end,
            default = DEFAULTS.layoutDirection,
            width = "half",
        },
        {
            type = "slider",
            name = function()
                return self:GetButtonsPerLineSettingName()
            end,
            reference = "ZeroPanelButtonsPerLineSlider",
            tooltip = function()
                return self:GetButtonsPerLineSettingTooltip()
            end,
            min = 1,
            max = 24,
            step = 1,
            getFunc = function()
                return self:GetButtonsPerLine()
            end,
            setFunc = function(value)
                self.savedVars.buttonsPerLine = math.max(1, math.floor(tonumber(value) or DEFAULTS.buttonsPerLine))
                self:RefreshPanel()
            end,
            default = DEFAULTS.buttonsPerLine,
            width = "half",
        },
        {
            type = "dropdown",
            name = "Screen Edge",
            choices = {"Left", "Right"},
            choicesValues = {"left", "right"},
            getFunc = function()
                return self.savedVars.edge
            end,
            setFunc = function(value)
                self.savedVars.edge = value
                self:RefreshPanel()
            end,
            default = DEFAULTS.edge,
            width = "half",
        },
        {
            type = "slider",
            name = "Button Size",
            min = 24,
            max = 56,
            step = 1,
            getFunc = function()
                return self.savedVars.buttonSize
            end,
            setFunc = function(value)
                self.savedVars.buttonSize = value
                self:RefreshPanel()
            end,
            default = DEFAULTS.buttonSize,
            width = "half",
        },
        {
            type = "slider",
            name = "Spacing",
            min = 0,
            max = 12,
            step = 1,
            getFunc = function()
                return self.savedVars.spacing
            end,
            setFunc = function(value)
                self.savedVars.spacing = value
                self:RefreshPanel()
            end,
            default = DEFAULTS.spacing,
            width = "half",
        },
        {
            type = "slider",
            name = "Background Alpha",
            min = 0,
            max = 100,
            step = 1,
            getFunc = function()
                return self.savedVars.backgroundAlpha
            end,
            setFunc = function(value)
                self.savedVars.backgroundAlpha = value
                self:RefreshPanel()
            end,
            default = DEFAULTS.backgroundAlpha,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Show Assistant/Ally Icons Instead",
            tooltip = "Replaces the default Banker, Merchant, Smuggler, Armorer, Ragpicker, and Ally icons with the actual collectible image for the assistant or ally currently selected for that button.",
            getFunc = function()
                return self:ShouldShowSummonableCollectibleIcons()
            end,
            setFunc = function(value)
                self.savedVars.showSummonableCollectibleIcons = value
                self:RefreshPanel()
            end,
            default = DEFAULTS.showSummonableCollectibleIcons,
            width = "full",
        },
        {
            type = "slider",
            name = "Desaturate Icons",
            tooltip = "Reduce icon color intensity so overlaid keybind text is easier to read. 0 keeps the full icon color, while 100 makes the icons fully grayscale.",
            min = 0,
            max = 100,
            step = 1,
            getFunc = function()
                return self:GetIconDesaturation()
            end,
            setFunc = function(value)
                self.savedVars.iconDesaturation = ClampNumber(tonumber(value) or DEFAULTS.iconDesaturation, 0, 100)
                self:RefreshPanel()
            end,
            default = DEFAULTS.iconDesaturation,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Show Keybind Text Background",
            tooltip = "Adds a small background directly behind each visible keybind label so it stays readable over bright icons. This only affects on-button keybind text from the KEYBINDS section.",
            getFunc = function()
                return self:GetKeybindDisplaySettings().showBackground
            end,
            setFunc = function(value)
                self:GetKeybindDisplaySettings().showBackground = value
                self:RefreshAllButtonKeybindDisplays()
                self:RequestSettingsRefresh()
            end,
            default = DEFAULTS.keybindDisplay.showBackground,
            width = "full",
        },
        {
            type = "colorpicker",
            name = "Keybind Background Color",
            tooltip = "Choose the color of the small backdrop shown behind the keybind text.",
            getFunc = function()
                local color = self:GetKeybindBackgroundColor()
                return color[1], color[2], color[3], 1
            end,
            setFunc = function(r, g, b)
                local backgroundColor = self:GetKeybindDisplaySettings().backgroundColor
                backgroundColor[1] = ClampNumber(tonumber(r) or DEFAULT_KEYBIND_BACKGROUND_COLOR[1], 0, 1)
                backgroundColor[2] = ClampNumber(tonumber(g) or DEFAULT_KEYBIND_BACKGROUND_COLOR[2], 0, 1)
                backgroundColor[3] = ClampNumber(tonumber(b) or DEFAULT_KEYBIND_BACKGROUND_COLOR[3], 0, 1)
                self:RefreshAllButtonKeybindDisplays()
            end,
            disabled = function()
                return not self:GetKeybindDisplaySettings().showBackground
            end,
            default = DEFAULTS.keybindDisplay.backgroundColor,
            width = "half",
        },
        {
            type = "slider",
            name = "Keybind Background Opacity",
            tooltip = "Control how opaque the keybind text background appears.",
            min = 0,
            max = 100,
            step = 1,
            getFunc = function()
                return self:GetKeybindDisplaySettings().backgroundOpacity
            end,
            setFunc = function(value)
                self:GetKeybindDisplaySettings().backgroundOpacity = ClampNumber(math.floor(tonumber(value) or DEFAULT_KEYBIND_BACKGROUND_OPACITY), 0, 100)
                self:RefreshAllButtonKeybindDisplays()
            end,
            disabled = function()
                return not self:GetKeybindDisplaySettings().showBackground
            end,
            default = DEFAULTS.keybindDisplay.backgroundOpacity,
            width = "half",
        },
        {
            type = "checkbox",
            name = "Show Keybind Background Border",
            tooltip = "Adds the same style of border used by the panel buttons around the keybind text background.",
            getFunc = function()
                return self:GetKeybindDisplaySettings().showBackgroundBorder
            end,
            setFunc = function(value)
                self:GetKeybindDisplaySettings().showBackgroundBorder = value
                self:RefreshAllButtonKeybindDisplays()
            end,
            disabled = function()
                return not self:GetKeybindDisplaySettings().showBackground
            end,
            default = DEFAULTS.keybindDisplay.showBackgroundBorder,
            width = "full",
        },
    }
    local keybindDisplayControls = {
        {
            type = "description",
            text = "Show the actual key the player bound to each assigned Zero Panel slot directly on the button. Top, bottom, left, and right anchor points place the label outside the button so it can sit above or beside the icon instead of fighting with the artwork. Font choices merge built-in ESO fonts with LibFonts and LibMediaProvider when those optional libraries are installed, without duplicating entries.",
            width = "full",
        },
        {
            type = "checkbox",
            name = "Show Button Keybinds",
            getFunc = function()
                return self:GetKeybindDisplaySettings().enabled
            end,
            setFunc = function(value)
                self:GetKeybindDisplaySettings().enabled = value
                self:RefreshAllButtonKeybindDisplays()
                self:RequestSettingsRefresh()
            end,
            default = DEFAULTS.keybindDisplay.enabled,
            width = "full",
        },
        {
            type = "dropdown",
            name = "Anchor Point",
            tooltip = "Choose where the keybind sits around the button. Top, bottom, left, and right anchors place it outside the icon area for readability, while Center keeps it over the button.",
            choices = KEYBIND_DISPLAY_ANCHOR_CHOICES,
            choicesValues = KEYBIND_DISPLAY_ANCHOR_VALUES,
            getFunc = function()
                return self:GetKeybindDisplaySettings().anchorPoint
            end,
            setFunc = function(value)
                self:GetKeybindDisplaySettings().anchorPoint = NormalizeKeybindAnchorPoint(value)
                self:RefreshAllButtonKeybindDisplays()
            end,
            disabled = function()
                return not self:GetKeybindDisplaySettings().enabled
            end,
            default = DEFAULTS.keybindDisplay.anchorPoint,
            width = "half",
        },
        {
            type = "slider",
            name = "Font Size",
            tooltip = "Increase or decrease the size of the on-button keybind text. Larger sizes, especially with wider fonts or heavier effects like Thick Outline and Soft Shadow Thick, can cause the keybind text to truncate. If that happens, lower the font size again until the full binding fits cleanly.",
            min = 8,
            max = 36,
            step = 1,
            getFunc = function()
                return self:GetKeybindDisplaySettings().fontSize
            end,
            setFunc = function(value)
                self:GetKeybindDisplaySettings().fontSize = ClampNumber(math.floor(tonumber(value) or DEFAULTS.keybindDisplay.fontSize), 8, 36)
                self:RefreshAllButtonKeybindDisplays()
            end,
            disabled = function()
                return not self:GetKeybindDisplaySettings().enabled
            end,
            default = DEFAULTS.keybindDisplay.fontSize,
            width = "half",
        },
        {
            type = "slider",
            name = "X Offset",
            tooltip = "Moves the keybind text horizontally away from its selected anchor point.",
            min = -100,
            max = 100,
            step = 1,
            getFunc = function()
                return self:GetKeybindDisplaySettings().offsetX
            end,
            setFunc = function(value)
                self:GetKeybindDisplaySettings().offsetX = ClampNumber(tonumber(value) or DEFAULTS.keybindDisplay.offsetX, -100, 100)
                self:RefreshAllButtonKeybindDisplays()
            end,
            disabled = function()
                return not self:GetKeybindDisplaySettings().enabled
            end,
            default = DEFAULTS.keybindDisplay.offsetX,
            width = "half",
        },
        {
            type = "slider",
            name = "Y Offset",
            tooltip = "Moves the keybind text vertically away from its selected anchor point.",
            min = -100,
            max = 100,
            step = 1,
            getFunc = function()
                return self:GetKeybindDisplaySettings().offsetY
            end,
            setFunc = function(value)
                self:GetKeybindDisplaySettings().offsetY = ClampNumber(tonumber(value) or DEFAULTS.keybindDisplay.offsetY, -100, 100)
                self:RefreshAllButtonKeybindDisplays()
            end,
            disabled = function()
                return not self:GetKeybindDisplaySettings().enabled
            end,
            default = DEFAULTS.keybindDisplay.offsetY,
            width = "half",
        },
        {
            type = "dropdown",
            name = "Font",
            reference = "ZeroPanelKeybindDisplayFontDropdown",
            choices = keybindFontChoices,
            choicesValues = keybindFontValues,
            getFunc = function()
                return NormalizeFontPath(self:GetKeybindDisplaySettings().fontPath)
            end,
            setFunc = function(value)
                self:GetKeybindDisplaySettings().fontPath = NormalizeFontPath(value)
                self:RefreshAllButtonKeybindDisplays()
            end,
            disabled = function()
                return not self:GetKeybindDisplaySettings().enabled
            end,
            default = DEFAULTS.keybindDisplay.fontPath,
            width = "full",
        },
        {
            type = "dropdown",
            name = "Font Effect",
            tooltip = "ESO only supports one built-in font effect per font string. Zero Panel's Outline + Shadow and Thick Outline + Shadow options add an extra shadow pass behind the main text for better readability.",
            choices = KEYBIND_FONT_EFFECT_LABELS,
            choicesValues = KEYBIND_FONT_EFFECT_VALUES,
            getFunc = function()
                return self:GetKeybindDisplaySettings().fontEffect
            end,
            setFunc = function(value)
                self:GetKeybindDisplaySettings().fontEffect = IsValidKeybindFontEffect(value) and value or DEFAULT_KEYBIND_FONT_EFFECT
                self:RefreshAllButtonKeybindDisplays()
            end,
            disabled = function()
                return not self:GetKeybindDisplaySettings().enabled
            end,
            default = DEFAULTS.keybindDisplay.fontEffect,
            width = "half",
        },
        {
            type = "checkbox",
            name = "Colorize Modifiers",
            tooltip = "Color only the modifier letters in the compact binding display, such as C, S, A, and M.",
            getFunc = function()
                return self:GetKeybindDisplaySettings().colorizeModifiers
            end,
            setFunc = function(value)
                self:GetKeybindDisplaySettings().colorizeModifiers = value
                self:InvalidateKeybindDisplayCache()
                self:RefreshAllButtonKeybindDisplays()
                self:RequestSettingsRefresh()
            end,
            disabled = function()
                return not self:GetKeybindDisplaySettings().enabled
            end,
            default = DEFAULTS.keybindDisplay.colorizeModifiers,
            width = "half",
        },
        {
            type = "description",
            title = "KeyBinder",
            text = "Click Activate KeyBinder to close this menu. Then click a live Zero Panel button to assign or open its matching entry in Controls -> Zero Panel Keybindings. Right-click the panel background to cancel.",
            width = "full",
        },
        {
            type = "button",
            name = "Activate KeyBinder",
            reference = "ZeroPanelActivateKeybindPickerButton",
            tooltip = function()
                return self:GetActivateKeybindPickerTooltip()
            end,
            func = function()
                self:ActivateKeybindPicker()
            end,
            disabled = function()
                return not self:CanActivateKeybindPicker()
            end,
            width = "full",
        },
        {
            type = "button",
            name = "Clear Stale Keybind Slots",
            reference = "ZeroPanelClearStaleKeybindSlotsButton",
            tooltip = function()
                return self:GetCleanupStaleKeybindSlotsTooltip()
            end,
            func = function()
                self:CleanupStaleKeybindSlots()
            end,
            disabled = function()
                return not self:CanCleanupStaleKeybindSlots()
            end,
            width = "full",
        },
    }
    local keybindColorControls = {
        {
            type = "description",
            text = "Choose the colors used for the on-button keybind display. Key Color controls the actual bound key text, while the modifier colors only apply when Colorize Modifiers is enabled.",
            width = "full",
        },
        {
            type = "colorpicker",
            name = "Key Color",
            getFunc = function()
                return unpack(self:GetKeybindTextColor())
            end,
            setFunc = function(r, g, b, a)
                self:GetKeybindDisplaySettings().textColor = {r, g, b, a}
                self:RefreshAllButtonKeybindDisplays()
            end,
            disabled = function()
                return not self:GetKeybindDisplaySettings().enabled
            end,
            default = DEFAULTS.keybindDisplay.textColor,
            width = "half",
        },
        {
            type = "colorpicker",
            name = "CTRL Color",
            getFunc = function()
                return unpack(self:GetKeybindModifierColor("ctrl"))
            end,
            setFunc = function(r, g, b, a)
                self:GetKeybindDisplaySettings().modifierColors.ctrl = {r, g, b, a}
                self:InvalidateKeybindDisplayCache()
                self:RefreshAllButtonKeybindDisplays()
            end,
            disabled = function()
                local settings = self:GetKeybindDisplaySettings()
                return not settings.enabled or not settings.colorizeModifiers
            end,
            default = DEFAULTS.keybindDisplay.modifierColors.ctrl,
            width = "half",
        },
        {
            type = "colorpicker",
            name = "SHIFT Color",
            getFunc = function()
                return unpack(self:GetKeybindModifierColor("shift"))
            end,
            setFunc = function(r, g, b, a)
                self:GetKeybindDisplaySettings().modifierColors.shift = {r, g, b, a}
                self:InvalidateKeybindDisplayCache()
                self:RefreshAllButtonKeybindDisplays()
            end,
            disabled = function()
                local settings = self:GetKeybindDisplaySettings()
                return not settings.enabled or not settings.colorizeModifiers
            end,
            default = DEFAULTS.keybindDisplay.modifierColors.shift,
            width = "half",
        },
        {
            type = "colorpicker",
            name = "ALT Color",
            getFunc = function()
                return unpack(self:GetKeybindModifierColor("alt"))
            end,
            setFunc = function(r, g, b, a)
                self:GetKeybindDisplaySettings().modifierColors.alt = {r, g, b, a}
                self:InvalidateKeybindDisplayCache()
                self:RefreshAllButtonKeybindDisplays()
            end,
            disabled = function()
                local settings = self:GetKeybindDisplaySettings()
                return not settings.enabled or not settings.colorizeModifiers
            end,
            default = DEFAULTS.keybindDisplay.modifierColors.alt,
            width = "half",
        },
        {
            type = "colorpicker",
            name = "Command Color",
            getFunc = function()
                return unpack(self:GetKeybindModifierColor("command"))
            end,
            setFunc = function(r, g, b, a)
                self:GetKeybindDisplaySettings().modifierColors.command = {r, g, b, a}
                self:InvalidateKeybindDisplayCache()
                self:RefreshAllButtonKeybindDisplays()
            end,
            disabled = function()
                local settings = self:GetKeybindDisplaySettings()
                return not settings.enabled or not settings.colorizeModifiers
            end,
            default = DEFAULTS.keybindDisplay.modifierColors.command,
            width = "half",
        },
    }
    local panelSettingsControls = {
        {
            type = "description",
            text = "Control how Zero Panel behaves as a whole. Maximum Visible Buttons caps rendered buttons so larger layouts do not overwhelm the user. Separators do not count toward that limit.",
            width = "full",
        },
        {
            type = "checkbox",
            name = "Enable Panel",
            getFunc = function()
                return self.savedVars.enabled
            end,
            setFunc = function(value)
                self.savedVars.enabled = value
                self:RefreshPanel()
            end,
            default = DEFAULTS.enabled,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Show Only When Reticle Is Hidden",
            tooltip = "Match the classic utility-panel behavior and stay off-screen while the reticle is active.",
            getFunc = function()
                return self.savedVars.showOnlyWhenReticleHidden
            end,
            setFunc = function(value)
                self.savedVars.showOnlyWhenReticleHidden = value
                self:RefreshPanel()
            end,
            default = DEFAULTS.showOnlyWhenReticleHidden,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Show In HUD UI Scenes",
            tooltip = "Keep the panel available in HUD UI scenes like inventory-style overlays.",
            getFunc = function()
                return self.savedVars.showInHudUI
            end,
            setFunc = function(value)
                self.savedVars.showInHudUI = value
                self:UpdateSceneRegistration()
                self:RefreshPanel()
            end,
            default = DEFAULTS.showInHudUI,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Lock Position",
            tooltip = "Unlock to drag the panel in the world. It snaps to the nearest screen edge when you release it, and the border turns red while it is movable.",
            getFunc = function()
                return self.savedVars.locked
            end,
            setFunc = function(value)
                self.savedVars.locked = value
                self:RefreshPanel()
            end,
            default = DEFAULTS.locked,
            width = "half",
        },
        {
            type = "button",
            name = "Reset Position",
            func = function()
                self:ResetPosition()
                self:RefreshPanel()
            end,
            width = "half",
        },
        {
            type = "slider",
            name = "Maximum Visible Buttons",
            tooltip = "Caps how many buttons Zero Panel renders at once. This counts buttons only, not separators.",
            min = 1,
            max = 60,
            step = 1,
            getFunc = function()
                return self:GetMaximumVisibleButtons()
            end,
            setFunc = function(value)
                self.savedVars.maxVisibleButtons = math.max(1, math.min(60, math.floor(tonumber(value) or DEFAULTS.maxVisibleButtons)))
                self:RefreshPanel()
            end,
            default = DEFAULTS.maxVisibleButtons,
            width = "full",
        },
    }
    local assistantControls = {
        {
            type = "description",
            text = "Choose which unlocked assistant each summon button uses. Only unlocked options are listed.",
            width = "full",
        },
    }
    local commandControls = {
        {
            type = "description",
            text = "Available slash commands for Zero Panel.",
            width = "full",
        },
    }
    for _, commandInfo in ipairs(SLASH_COMMAND_HELP_ENTRIES) do
        commandControls[#commandControls + 1] = {
            type = "description",
            title = commandInfo.command,
            text = commandInfo.description,
            width = "full",
        }
    end
    local allyControls = {
        {
            type = "description",
            text = "Choose whether the ally button summons a random unlocked ally or one specific unlocked ally.",
            width = "full",
        },
    }
    local customButtonChoices, customButtonValues = self:GetCustomButtonChoiceEntries()
    local customSeparatorChoices, customSeparatorValues = self:GetCustomSeparatorChoiceEntries()
    self.selectedCustomButtonPresetId = self.selectedCustomButtonPresetId or CUSTOM_BUTTON_PRESET_VALUES[1]

    local customButtonControls = {
        {
            type = "description",
            text = "Create and edit custom buttons here. Only custom buttons can be modified. Default Zero Panel buttons stay read-only.",
            width = "full",
        },
        {
            type = "dropdown",
            name = "Custom Button",
            reference = "ZeroPanelCustomButtonSelector",
            choices = customButtonChoices,
            choicesValues = customButtonValues,
            getFunc = function()
                return self:GetSelectedCustomButtonId() or 0
            end,
            setFunc = function(value)
                self:SetSelectedCustomButtonId(tonumber(value))
                self:RefreshCustomEditorControls()
            end,
            disabled = function()
                return #self:GetCustomButtonIds() == 0
            end,
            width = "full",
        },
        {
            type = "description",
            title = "Custom Button Editor",
            text = function()
                return self:GetCustomButtonEditorDescription()
            end,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Enabled",
            getFunc = function()
                local buttonData = self:GetSelectedCustomButtonData()
                return buttonData and buttonData.enabled or false
            end,
            setFunc = function(value)
                local buttonData = self:GetSelectedCustomButtonData()
                if buttonData then
                    buttonData.enabled = value
                    self:RefreshPanel()
                    self:RefreshCustomEditorControls()
                end
            end,
            disabled = function()
                return self:GetSelectedCustomButtonData() == nil
            end,
            width = "half",
        },
        {
            type = "checkbox",
            name = "Use Auto-Detected Title",
            tooltip = "When enabled, Zero Panel derives the hover title from the selected action or command.",
            getFunc = function()
                local buttonData = self:GetSelectedCustomButtonData()
                return buttonData and buttonData.useAutoTitle or true
            end,
            setFunc = function(value)
                local buttonData = self:GetSelectedCustomButtonData()
                if buttonData then
                    buttonData.useAutoTitle = value
                    self:RefreshPanel()
                    self:RefreshCustomEditorControls()
                end
            end,
            disabled = function()
                return self:GetSelectedCustomButtonData() == nil
            end,
            width = "half",
        },
        {
            type = "dropdown",
            name = "Action Type",
            choices = CUSTOM_BUTTON_ACTION_NAMES,
            choicesValues = CUSTOM_BUTTON_ACTION_VALUES,
            getFunc = function()
                local buttonData = self:GetSelectedCustomButtonData()
                return buttonData and buttonData.actionType or "command"
            end,
            setFunc = function(value)
                local buttonData = self:GetSelectedCustomButtonData()
                if buttonData then
                    buttonData.actionType = value
                    if value ~= "command" then
                        buttonData.command = ""
                    end
                    self:RefreshPanel()
                    self:RefreshCustomEditorControls()
                end
            end,
            disabled = function()
                return self:GetSelectedCustomButtonData() == nil
            end,
            width = "full",
        },
        {
            type = "editbox",
            name = "Title",
            tooltip = "When auto-detected title is enabled, this shows the detected title currently in use. Turn auto-detected title off to edit it manually.",
            getFunc = function()
                return self:GetCustomButtonEditorTitleValue()
            end,
            setFunc = function(value)
                local buttonData = self:GetSelectedCustomButtonData()
                if buttonData then
                    buttonData.title = TrimText(value)
                    self:RefreshPanel()
                    self:RefreshCustomEditorControls()
                end
            end,
            disabled = function()
                local buttonData = self:GetSelectedCustomButtonData()
                return buttonData == nil or buttonData.useAutoTitle == true
            end,
            maxChars = 140,
            width = "full",
        },
        {
            type = "editbox",
            name = "Icon Override",
            tooltip = "Optional texture path. Leave this blank to use the action icon or an automatically detected collectible icon.",
            getFunc = function()
                local buttonData = self:GetSelectedCustomButtonData()
                return buttonData and buttonData.icon or ""
            end,
            setFunc = function(value)
                local buttonData = self:GetSelectedCustomButtonData()
                if buttonData then
                    buttonData.icon = TrimText(value)
                    self:RefreshPanel()
                    self:RefreshCustomEditorControls()
                end
            end,
            disabled = function()
                return self:GetSelectedCustomButtonData() == nil
            end,
            maxChars = 260,
            width = "half",
        },
        {
            type = "button",
            name = "Browse Textures",
            tooltip = "Open a popup texture picker for the Icon Override field instead of expanding more controls inline here.",
            func = function()
                self:OpenTextureBrowserPopup()
            end,
            disabled = function()
                return self:GetSelectedCustomButtonData() == nil
            end,
            width = "half",
        },
        {
            type = "editbox",
            name = "Command",
            tooltip = "Used by the Custom Command action type. Supports slash commands and /script. Browse Collectibles can fill this in for you automatically.",
            getFunc = function()
                local buttonData = self:GetSelectedCustomButtonData()
                return buttonData and buttonData.command or ""
            end,
            setFunc = function(value)
                local buttonData = self:GetSelectedCustomButtonData()
                if buttonData then
                    buttonData.command = tostring(value or "")
                    self:RefreshPanel()
                    self:RefreshCustomEditorControls()
                end
            end,
            disabled = function()
                local buttonData = self:GetSelectedCustomButtonData()
                return not buttonData or buttonData.actionType ~= "command"
            end,
            isMultiline = true,
            maxChars = 600,
            width = "half",
        },
        {
            type = "button",
            name = "Browse Collectibles",
            tooltip = "Open a popup collectible picker that writes the command and icon into the selected custom button.",
            func = function()
                self:OpenCollectibleBrowserPopup()
            end,
            disabled = function()
                return self:GetSelectedCustomButtonData() == nil
            end,
            width = "half",
        },
        {
            type = "description",
            title = "Presets",
            text = "Apply a common button preset to the selected custom button, then tweak it if needed.",
            width = "full",
        },
        {
            type = "dropdown",
            name = "Preset",
            choices = CUSTOM_BUTTON_PRESET_NAMES,
            choicesValues = CUSTOM_BUTTON_PRESET_VALUES,
            choicesTooltips = CUSTOM_BUTTON_PRESET_TOOLTIPS,
            getFunc = function()
                return self.selectedCustomButtonPresetId
            end,
            setFunc = function(value)
                self.selectedCustomButtonPresetId = value
            end,
            disabled = function()
                return self:GetSelectedCustomButtonData() == nil
            end,
            width = "full",
        },
        {
            type = "button",
            name = "Apply Preset",
            func = function()
                self:ApplyCustomButtonPreset(self.selectedCustomButtonPresetId)
            end,
            disabled = function()
                return self:GetSelectedCustomButtonData() == nil
            end,
            width = "full",
        },
        {
            type = "button",
            name = "Save",
            func = function()
                self:SaveSelectedCustomButton()
            end,
            disabled = function()
                return self:GetSelectedCustomButtonData() == nil
            end,
            width = "half",
        },
        {
            type = "button",
            name = "Delete Button",
            func = function()
                self:DeleteSelectedCustomButton()
            end,
            disabled = function()
                return self:GetSelectedCustomButtonData() == nil
            end,
            width = "half",
        },
    }

    local customSeparatorControls = {
        {
            type = "description",
            text = "Custom separators are extra horizontal lines you can insert anywhere in Button Order.",
            width = "full",
        },
        {
            type = "dropdown",
            name = "Custom Separator",
            reference = "ZeroPanelCustomSeparatorSelector",
            choices = customSeparatorChoices,
            choicesValues = customSeparatorValues,
            getFunc = function()
                return self:GetSelectedCustomSeparatorId() or 0
            end,
            setFunc = function(value)
                self:SetSelectedCustomSeparatorId(tonumber(value))
                self:RefreshCustomEditorControls()
            end,
            disabled = function()
                return #self:GetCustomSeparatorIds() == 0
            end,
            width = "full",
        },
        {
            type = "button",
            name = "Delete Selected Custom Separator",
            func = function()
                self:DeleteSelectedCustomSeparator()
            end,
            disabled = function()
                return self:GetSelectedCustomSeparatorId() == nil
            end,
            width = "full",
        },
    }
    local buttonOrderControls = {
        {
            type = "description",
            reference = "ZeroPanelButtonOrderHelp",
            text = function()
                return self:GetButtonOrderHelpText()
            end,
            width = "full",
        },
        {
            type = "orderlistbox",
            name = "Reorder Layout",
            reference = "ZeroPanelLayoutOrderList",
            tooltip = "Drag and drop rows here or use the row move buttons to reorder the live panel, including custom buttons and separators.",
            listEntries = self:GetOrderListEntries(),
            showPosition = true,
            rowSelectedCallback = function(orderListControl, _, selectedData)
                local scrollListControl = orderListControl and (orderListControl.scrollListControl or (orderListControl.orderListBox and orderListControl.orderListBox.scrollListControl)) or nil
                if not selectedData and scrollListControl and type(ZO_ScrollList_GetSelectedData) == "function" then
                    selectedData = ZO_ScrollList_GetSelectedData(scrollListControl)
                end
                self:HandleLayoutOrderSelection(selectedData)
                self:RefreshButtonOrderControlState()
            end,
            minHeight = 220,
            maxHeight = 320,
            isExtraWide = true,
            getFunc = function()
                return self:GetOrderListEntries()
            end,
            setFunc = function(sortedEntries)
                local order = {}
                for _, entry in ipairs(sortedEntries) do
                    if type(entry.value) == "string" and entry.value ~= "" then
                        order[#order + 1] = entry.value
                    end
                end
                self.savedVars.order = order
                self:EnsureOrder()
                self:RefreshPanel()
                self:RefreshCustomEditorControls()
            end,
            default = function()
                return self:GetOrderListEntries()
            end,
            width = "full",
        },
    }

    for _, actionId in ipairs(SUMMONABLE_ACTION_ORDER) do
        local currentActionId = actionId
        local summonable = SUMMONABLES[currentActionId]
        local choices, choiceValues = self:GetCollectibleChoiceEntries(currentActionId)
        local controlData = {
            type = "dropdown",
            name = summonable.choiceLabel,
            reference = summonable.dropdownReference,
            tooltip = "Only unlocked options are listed here.",
            choices = choices,
            choicesValues = choiceValues,
            getFunc = function()
                return self:GetCollectibleChoice(currentActionId)
            end,
            setFunc = function(value)
                self.savedVars.collectibleChoices[currentActionId] = value
                self:RefreshPanel()
            end,
            disabled = function()
                return #self:GetUnlockedCollectibles(currentActionId) == 0
            end,
            default = DEFAULTS.collectibleChoices[currentActionId],
            width = "full",
        }

        if currentActionId == "summon_ally" then
            allyControls[#allyControls + 1] = controlData
        else
            assistantControls[#assistantControls + 1] = controlData
        end
    end

    local options = {
        {
            type = "description",
            text = "Standalone screen-edge utility strip with reorderable buttons, configurable assistants, and a dedicated ally section.",
            width = "full",
        },
        {
            type = "description",
            title = "Support",
            reference = "ZeroPanelSupportDescription",
            text = string.format("Please report bugs and feature requests via %s.", ZERO_PANEL_GITHUB_ISSUES_LINK_TEXT),
            tooltip = "Open the GitHub issues page for Zero Panel.",
            enableLinks = OnSupportLinkClicked,
            width = "full",
        },
        {
            type = "submenu",
            name = "General",
            reference = "ZeroPanelPanelSettingsSubmenu",
            controls = panelSettingsControls,
        },
        {
            type = "submenu",
            name = "Appearance",
            reference = "ZeroPanelAppearanceSubmenu",
            controls = appearanceControls,
        },
        {
            type = "submenu",
            name = "KEYBINDS",
            reference = "ZeroPanelKeybindDisplaySubmenu",
            controls = keybindDisplayControls,
        },
        {
            type = "submenu",
            name = "Keybind Colors",
            reference = "ZeroPanelKeybindColorsSubmenu",
            controls = keybindColorControls,
        },
        {
            type = "submenu",
            name = "Default Button Visibility",
            reference = "ZeroPanelVisibleButtonsSubmenu",
            controls = visibleButtonsControls,
        },
        {
            type = "submenu",
            name = "Assistant Selection",
            reference = "ZeroPanelAssistantSubmenu",
            controls = assistantControls,
        },
        {
            type = "submenu",
            name = "Ally Selection",
            reference = "ZeroPanelAllySubmenu",
            controls = allyControls,
        },
        {
            type = "submenu",
            name = "Custom Buttons",
            reference = "ZeroPanelCustomButtonsSubmenu",
            controls = customButtonControls,
        },
        {
            type = "submenu",
            name = "Custom Separators",
            reference = "ZeroPanelCustomSeparatorsSubmenu",
            controls = customSeparatorControls,
        },
        {
            type = "button",
            name = "Add Custom Button",
            func = function()
                self:CreateCustomButton()
            end,
            width = "half",
        },
        {
            type = "button",
            name = "Add Separator",
            func = function()
                self:AddCustomSeparator()
            end,
            width = "half",
        },
        {
            type = "submenu",
            name = "BUTTON ORDER",
            reference = "ZeroPanelButtonOrderSubmenu",
            controls = buttonOrderControls,
        },
        {
            type = "submenu",
            name = "Commands",
            reference = "ZeroPanelCommandsSubmenu",
            controls = commandControls,
        },
    }

    for _, definition in ipairs(self:GetCatalog()) do
        local currentDefinition = definition
        visibleButtonsControls[#visibleButtonsControls + 1] = {
            type = "checkbox",
            name = currentDefinition.name,
            tooltip = self:GetButtonTooltip(currentDefinition),
            getFunc = function()
                return self.savedVars.buttons[currentDefinition.id] ~= false
            end,
            setFunc = function(value)
                self.savedVars.buttons[currentDefinition.id] = value
                self:RefreshPanel()
            end,
            default = DEFAULTS.buttons[currentDefinition.id],
            width = "full",
        }
    end

    LAM:RegisterOptionControls(self.panelId, options)
    self:RefreshKeybindFontChoices()
    self:RefreshLayoutDirectionOptionControls()
    self:RefreshButtonOrderControlState()
    self:ConfigureButtonOrderListVisualStyles()
end

function ZeroPanel:HandleSlashCommand(argumentText)
    local command = TrimText(argumentText)

    if command == "unlock" then
        self.savedVars.locked = false
        self:RefreshPanel()
        self:Print("Unlocked. Drag it in the world, then use /zp lock when done.")
    elseif command == "lock" then
        self.savedVars.locked = true
        self:RefreshPanel()
        self:Print("Locked.")
    elseif command == "reset" then
        self:ResetPosition()
        self:RefreshPanel()
        self:Print("Position reset.")
    else
        self:OpenSettings()
    end
end

function ZeroPanel:Initialize()
    self.savedVars = ZO_SavedVars:NewAccountWide(self.savedVarName, 1, nil, DEFAULTS)
    self.reticleHidden = true
    self:EnsureCustomButtons()
    self:EnsureCollectibleChoices()
    self:EnsureKeybindDisplaySettings()
    self:EnsureOrder()
    self:EnsureKeybindAssignments()
    self:RegisterKeybindStringIds()
    self:RegisterKeybindingsMenuPanel()
    self:CreateWindow()
    self:UpdateSceneRegistration()
    self:ApplyAnchor()
    self:BuildSettings()
    self:RefreshPanel()

    SLASH_COMMANDS["/zp"] = function(text)
        self:HandleSlashCommand(text)
    end
    SLASH_COMMANDS["/zkb"] = function()
        if self.keybindPickerActive then
            self:CancelKeybindPicker("KeyBinder canceled.")
        else
            self:ActivateKeybindPicker()
        end
    end

    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_RETICLE_HIDDEN_UPDATE, function(_, hidden)
        self.reticleHidden = hidden
        self:RefreshVisibility()
    end)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_ACTIVATED, function()
        self:RunStartupGhostKeybindCleanup()
        self:RefreshPanel()
    end)
    if EVENT_KEYBINDING_SET then
        EVENT_MANAGER:RegisterForEvent(self.name, EVENT_KEYBINDING_SET, function(_, layerIndex, categoryIndex, actionIndex, bindingIndex)
            self:HandleKeybindingSet(layerIndex, categoryIndex, actionIndex, bindingIndex)
        end)
    end
    if EVENT_KEYBINDING_CLEARED then
        EVENT_MANAGER:RegisterForEvent(self.name, EVENT_KEYBINDING_CLEARED, function(_, layerIndex, categoryIndex, actionIndex, bindingIndex)
            self:HandleKeybindingCleared(layerIndex, categoryIndex, actionIndex, bindingIndex)
        end)
    end
    if EVENT_KEYBINDINGS_LOADED then
        EVENT_MANAGER:RegisterForEvent(self.name, EVENT_KEYBINDINGS_LOADED, function()
            self:RunStartupGhostKeybindCleanup()
        end)
    end
    pcall(function()
        EVENT_MANAGER:RegisterForEvent(self.name, EVENT_COLLECTIBLE_UNLOCKED, function()
            self:QueueCollectibleStateRefresh()
        end)
    end)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_GROUP_MEMBER_JOINED, function()
        self:RefreshPanel()
    end)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_GROUP_MEMBER_LEFT, function()
        self:RefreshPanel()
    end)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_GROUP_UPDATE, function()
        self:RefreshPanel()
    end)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_VETERAN_DIFFICULTY_CHANGED, function()
        self:RefreshPanel()
    end)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_GROUP_VETERAN_DIFFICULTY_CHANGED, function()
        self:RefreshPanel()
    end)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_LEADER_UPDATE, function()
        self:RefreshPanel()
    end)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_CHAMPION_POINT_UPDATE, function(_, unitTag)
        if unitTag == nil or unitTag == "player" then
            self:RefreshPanel()
        end
    end)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_ZONE_UPDATE, function(_, unitTag)
        if unitTag == nil or unitTag == "player" or (type(ZO_Group_IsGroupUnitTag) == "function" and ZO_Group_IsGroupUnitTag(unitTag)) then
            self:RefreshPanel()
        end
    end)

    if not self.libMediaProviderCallbackRegistered and CALLBACK_MANAGER and type(CALLBACK_MANAGER.RegisterCallback) == "function" then
        CALLBACK_MANAGER:RegisterCallback("LibMediaProvider_Registered", function(mediaType)
            local expectedMediaType = LibMediaProvider and LibMediaProvider.MediaType and LibMediaProvider.MediaType.FONT or "font"
            if mediaType == expectedMediaType then
                self:RefreshKeybindFontChoices()
            end
        end)
        self.libMediaProviderCallbackRegistered = true
    end
end

local function OnAddOnLoaded(_, addonName)
    if addonName ~= ZeroPanel.name then
        return
    end

    EVENT_MANAGER:UnregisterForEvent(ZeroPanel.name, EVENT_ADD_ON_LOADED)
    ZeroPanel:Initialize()
end

EVENT_MANAGER:RegisterForEvent(ZeroPanel.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)

function ZeroPanel_HandleBindingSlot(keybindSlot)
    return ZeroPanel:ExecuteKeybindSlot(keybindSlot)
end



















