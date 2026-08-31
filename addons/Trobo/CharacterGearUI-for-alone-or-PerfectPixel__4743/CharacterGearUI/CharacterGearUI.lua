------------------------------------------------------------
-- Character Gear UI
-- Version 0.4.6
-- API 101050 / 101051
--
-- Equipment quality borders, condition and level warnings are
-- adapted from Wykkyd Equipment Borders by Ravalox Darkshire
-- with the item-level feature originally contributed by @BalticBlues.
------------------------------------------------------------

local LAM2 = LibAddonMenu2

CharacterGearUI = CharacterGearUI or {}
local addon = CharacterGearUI
local companion = addon.CompanionGearUI
local perfectPixel = _G.PP

addon.name = "CharacterGearUI"
addon.version = "0.4.6"

local DEFAULT_BACKGROUND_OFFSET_Y = -85
local DEFAULT_UI_SCALE = 1.12
local DEFAULT_POSITION_X = 0
local DEFAULT_POSITION_Y = 85
local MAX_SUPPORTED_SCREEN_WIDTH = 5120
local MAX_SUPPORTED_SCREEN_HEIGHT = 2160

local MIN_POSITION_X = 0
local MAX_POSITION_X = MAX_SUPPORTED_SCREEN_WIDTH
local MIN_POSITION_Y = -MAX_SUPPORTED_SCREEN_HEIGHT / 2
local MAX_POSITION_Y = MAX_SUPPORTED_SCREEN_HEIGHT / 2

local ORIGINAL_LEFT_BACKGROUND_WIDTH = 1024
local TRIMMED_LEFT_BACKGROUND_WIDTH = 560

local DEFAULT_ATTRIBUTE_FONT_SIZE = 17
local MIN_ATTRIBUTE_FONT_SIZE = 6
local MAX_ATTRIBUTE_FONT_SIZE = 18

local REFERENCE_SCREEN_WIDTH = 3440
local REFERENCE_SCREEN_HEIGHT = 1440

local EQUIPMENT_SLOT_TEXTURE =
    "CharacterGearUI/textur/slot_outline_khk.dds"
local EQUIPMENT_QUALITY_BORDER_TEXTURE =
    "CharacterGearUI/textur/equipment_quality_border.dds"
local OUTFIT_ICON_TEXTURE =
    "EsoUI/Art/Dye/dyes_tabicon_dye_down.dds"
local COSTUME_ICON_TEXTURE =
    "EsoUI/Art/Dye/dyes_tabicon_costumedye_down.dds"

local PREVIEW_CONTROLS =
{
    ZO_SharedWideLeftPanelBackground,
    ZO_Character,
    ZO_CharacterWindowStats,
    ZO_SharedRightPanelBackground,
    ZO_PlayerInventory,
}

local EQUIPMENT_SLOT_REFERENCE_SIZE = 128
local DEFAULT_EQUIPMENT_SLOT_SIZE = 68
local MIN_EQUIPMENT_SLOT_SIZE = 32
local MAX_EQUIPMENT_SLOT_SIZE = 128
local ACTIVE_WEAPON_HIGHLIGHT_SCALE = 1.75
local ACTIVE_WEAPON_HIGHLIGHT_OPTICAL_OFFSET = 2

local WEAPON_SLOT_HORIZONTAL_GAP = 17
local WEAPON_SLOT_VERTICAL_GAP = 14
local WEAPON_SLOT_GROUP_CENTER_Y = 543

local WEAPON_SWAP_MAX_SCALE = 2
local WEAPON_SWAP_POSITION_X = 575

local DEFAULT_HEADER_POSITION_X = 0
local DEFAULT_HEADER_POSITION_Y = 100
local DEFAULT_HEADER_SCALE = 1.2

local MIN_HEADER_POSITION_X = 0
local MAX_HEADER_POSITION_X = MAX_SUPPORTED_SCREEN_WIDTH
local MIN_HEADER_POSITION_Y = 0
local MAX_HEADER_POSITION_Y = MAX_SUPPORTED_SCREEN_HEIGHT

local DEFAULT_COSTUME_POSITION_X = -575
local DEFAULT_COSTUME_POSITION_Y = 543
local MIN_COSTUME_POSITION_X =
    -MAX_SUPPORTED_SCREEN_WIDTH / 2
local MAX_COSTUME_POSITION_X =
    MAX_SUPPORTED_SCREEN_WIDTH / 2
local MIN_COSTUME_POSITION_Y =
    -MAX_SUPPORTED_SCREEN_HEIGHT / 2
local MAX_COSTUME_POSITION_Y =
    MAX_SUPPORTED_SCREEN_HEIGHT / 2

local DEFAULT_FIGURE_POSITION_X = 100
local DEFAULT_FIGURE_POSITION_Y = 220
local DEFAULT_FIGURE_SCALE = 1.2

local MIN_FIGURE_POSITION_X = 0
local MAX_FIGURE_POSITION_X = MAX_SUPPORTED_SCREEN_WIDTH
local MIN_FIGURE_POSITION_Y = 0
local MAX_FIGURE_POSITION_Y = MAX_SUPPORTED_SCREEN_HEIGHT
local MIN_FIGURE_SCALE = 0.25
local MAX_FIGURE_SCALE = 3.0

local DEFAULT_CHARACTER_DISTANCE = 2
local MIN_CHARACTER_DISTANCE = 1.0
local MAX_CHARACTER_DISTANCE = 2.99

local ATTRIBUTE_WINDOW_WIDTH = 303
local ATTRIBUTE_WINDOW_HEIGHT = 520
local ATTRIBUTE_FIRST_ENTRY_OFFSET_X = 10
local PERFECT_PIXEL_ATTRIBUTE_CONTENT_OFFSET_Y = 30

local DEFAULT_SHOW_ITEM_BORDERS = true
local DEFAULT_SHOW_ITEM_CONDITION = true
local DEFAULT_SHOW_WEAPON_CHARGE = true
local DEFAULT_SHOW_ITEM_LEVEL = true
local DEFAULT_EQUIPMENT_INDICATOR_FONT_SIZE = 17
local DEFAULT_COLOR_DOLL_RED = true
local DEFAULT_REPAIR_WARNING_THRESHOLD = 25
local DEFAULT_WEAPON_CHARGE_WARNING_THRESHOLD = 25
local DEFAULT_ITEM_LEVEL_WARNING_THRESHOLD = 5

local MIN_REPAIR_WARNING_THRESHOLD = 1
local MAX_REPAIR_WARNING_THRESHOLD = 100
local MIN_WEAPON_CHARGE_WARNING_THRESHOLD = 1
local MAX_WEAPON_CHARGE_WARNING_THRESHOLD = 100
local MIN_ITEM_LEVEL_WARNING_THRESHOLD = 1
local MAX_ITEM_LEVEL_WARNING_THRESHOLD = 10
local MIN_EQUIPMENT_INDICATOR_FONT_SIZE = 10
local MAX_EQUIPMENT_INDICATOR_FONT_SIZE = 30
local MAX_EQUIPMENT_CHAMPION_POINTS = 160

local WEAPON_CHARGE_SLOTS =
{
    [EQUIP_SLOT_MAIN_HAND] = true,
    [EQUIP_SLOT_OFF_HAND] = true,
    [EQUIP_SLOT_BACKUP_MAIN] = true,
    [EQUIP_SLOT_BACKUP_OFF] = true,
}

local EQUIPMENT_INDICATOR_SLOTS =
{
    {
        slotId = EQUIP_SLOT_HEAD,
        controlName = "ZO_CharacterEquipmentSlotsHead",
        x = -575,
        y = -535,
    },
    {
        slotId = EQUIP_SLOT_CHEST,
        controlName = "ZO_CharacterEquipmentSlotsChest",
        x = 575,
        y = -335,
    },
    {
        slotId = EQUIP_SLOT_SHOULDERS,
        controlName = "ZO_CharacterEquipmentSlotsShoulder",
        x = -575,
        y = -335,
    },
    {
        slotId = EQUIP_SLOT_FEET,
        controlName = "ZO_CharacterEquipmentSlotsFoot",
        x = 575,
        y = 265,
    },
    {
        slotId = EQUIP_SLOT_HAND,
        controlName = "ZO_CharacterEquipmentSlotsGlove",
        x = -575,
        y = -135,
    },
    {
        slotId = EQUIP_SLOT_LEGS,
        controlName = "ZO_CharacterEquipmentSlotsLeg",
        x = -575,
        y = 265,
    },
    {
        slotId = EQUIP_SLOT_WAIST,
        controlName = "ZO_CharacterEquipmentSlotsBelt",
        x = 575,
        y = -135,
    },
    {
        slotId = EQUIP_SLOT_RING1,
        controlName = "ZO_CharacterEquipmentSlotsRing1",
        x = -575,
        y = 65,
    },
    {
        slotId = EQUIP_SLOT_RING2,
        controlName = "ZO_CharacterEquipmentSlotsRing2",
        x = 575,
        y = 65,
    },
    {
        slotId = EQUIP_SLOT_NECK,
        controlName = "ZO_CharacterEquipmentSlotsNeck",
        x = 575,
        y = -535,
    },
    {
        slotId = EQUIP_SLOT_COSTUME,
        controlName = "ZO_CharacterEquipmentSlotsCostume",
        isCostume = true,
    },
    {
        slotId = EQUIP_SLOT_MAIN_HAND,
        controlName = "ZO_CharacterEquipmentSlotsMainHand",
        weaponColumn = -1,
        weaponRow = -1,
    },
    {
        slotId = EQUIP_SLOT_OFF_HAND,
        controlName = "ZO_CharacterEquipmentSlotsOffHand",
        weaponColumn = 1,
        weaponRow = -1,
    },
    {
        slotId = EQUIP_SLOT_BACKUP_MAIN,
        controlName = "ZO_CharacterEquipmentSlotsBackupMain",
        weaponColumn = -1,
        weaponRow = 1,
    },
    {
        slotId = EQUIP_SLOT_BACKUP_OFF,
        controlName = "ZO_CharacterEquipmentSlotsBackupOff",
        weaponColumn = 1,
        weaponRow = 1,
    },
    {
        slotId = EQUIP_SLOT_POISON,
        controlName = "ZO_CharacterEquipmentSlotsPoison",
        weaponColumn = 0,
        weaponRow = -1,
        qualityOnly = true,
    },
    {
        slotId = EQUIP_SLOT_BACKUP_POISON,
        controlName = "ZO_CharacterEquipmentSlotsBackupPoison",
        weaponColumn = 0,
        weaponRow = 1,
        qualityOnly = true,
    },
}

local ITEM_DETAIL_SLOTS =
{
    {
        slotId = EQUIP_SLOT_HEAD,
        controlName = "ZO_CharacterEquipmentSlotsHead",
        side = "right",
        outfitSlot = OUTFIT_SLOT_HEAD,
    },
    {
        slotId = EQUIP_SLOT_SHOULDERS,
        controlName = "ZO_CharacterEquipmentSlotsShoulder",
        side = "right",
        outfitSlot = OUTFIT_SLOT_SHOULDERS,
    },
    {
        slotId = EQUIP_SLOT_HAND,
        controlName = "ZO_CharacterEquipmentSlotsGlove",
        side = "right",
        outfitSlot = OUTFIT_SLOT_HANDS,
    },
    {
        slotId = EQUIP_SLOT_RING1,
        controlName = "ZO_CharacterEquipmentSlotsRing1",
        side = "right",
    },
    {
        slotId = EQUIP_SLOT_LEGS,
        controlName = "ZO_CharacterEquipmentSlotsLeg",
        side = "right",
        outfitSlot = OUTFIT_SLOT_LEGS,
    },
    {
        slotId = EQUIP_SLOT_OFF_HAND,
        controlName = "ZO_CharacterEquipmentSlotsOffHand",
        side = "right",
        weaponOutfitIndex = 2,
    },
    {
        slotId = EQUIP_SLOT_BACKUP_OFF,
        controlName = "ZO_CharacterEquipmentSlotsBackupOff",
        side = "right",
        weaponOutfitIndex = 4,
    },
    {
        slotId = EQUIP_SLOT_NECK,
        controlName = "ZO_CharacterEquipmentSlotsNeck",
        side = "left",
    },
    {
        slotId = EQUIP_SLOT_CHEST,
        controlName = "ZO_CharacterEquipmentSlotsChest",
        side = "left",
        outfitSlot = OUTFIT_SLOT_CHEST,
    },
    {
        slotId = EQUIP_SLOT_WAIST,
        controlName = "ZO_CharacterEquipmentSlotsBelt",
        side = "left",
        outfitSlot = OUTFIT_SLOT_WAIST,
    },
    {
        slotId = EQUIP_SLOT_RING2,
        controlName = "ZO_CharacterEquipmentSlotsRing2",
        side = "left",
    },
    {
        slotId = EQUIP_SLOT_FEET,
        controlName = "ZO_CharacterEquipmentSlotsFoot",
        side = "left",
        outfitSlot = OUTFIT_SLOT_FEET,
    },
    {
        slotId = EQUIP_SLOT_MAIN_HAND,
        controlName = "ZO_CharacterEquipmentSlotsMainHand",
        side = "left",
        weaponOutfitIndex = 1,
    },
    {
        slotId = EQUIP_SLOT_BACKUP_MAIN,
        controlName = "ZO_CharacterEquipmentSlotsBackupMain",
        side = "left",
        weaponOutfitIndex = 3,
    },
}

local COSTUME_AFFECTED_SLOTS =
{
    [EQUIP_SLOT_HEAD] = true,
    [EQUIP_SLOT_SHOULDERS] = true,
    [EQUIP_SLOT_HAND] = true,
    [EQUIP_SLOT_LEGS] = true,
    [EQUIP_SLOT_CHEST] = true,
    [EQUIP_SLOT_WAIST] = true,
    [EQUIP_SLOT_FEET] = true,
}

------------------------------------------------------------
-- Defaults
------------------------------------------------------------

addon.defaults =
{
    scale = DEFAULT_UI_SCALE,
    positionX = DEFAULT_POSITION_X,
    positionY = DEFAULT_POSITION_Y,
    attributeFontSize = DEFAULT_ATTRIBUTE_FONT_SIZE,
    equipmentSlotSize = DEFAULT_EQUIPMENT_SLOT_SIZE,
    headerPositionX = DEFAULT_HEADER_POSITION_X,
    headerPositionY = DEFAULT_HEADER_POSITION_Y,
    headerScale = DEFAULT_HEADER_SCALE,
    costumePositionX = DEFAULT_COSTUME_POSITION_X,
    costumePositionY = DEFAULT_COSTUME_POSITION_Y,
    figurePositionX = DEFAULT_FIGURE_POSITION_X,
    figurePositionY = DEFAULT_FIGURE_POSITION_Y,
    figureScale = DEFAULT_FIGURE_SCALE,
    characterDistance = DEFAULT_CHARACTER_DISTANCE,
    showItemBorders = DEFAULT_SHOW_ITEM_BORDERS,
    showItemCondition = DEFAULT_SHOW_ITEM_CONDITION,
    showWeaponCharge = DEFAULT_SHOW_WEAPON_CHARGE,
    showItemLevel = DEFAULT_SHOW_ITEM_LEVEL,
    equipmentIndicatorFontSize =
        DEFAULT_EQUIPMENT_INDICATOR_FONT_SIZE,
    colorDollRed = DEFAULT_COLOR_DOLL_RED,
    repairWarningThreshold =
        DEFAULT_REPAIR_WARNING_THRESHOLD,
    weaponChargeWarningThreshold =
        DEFAULT_WEAPON_CHARGE_WARNING_THRESHOLD,
    itemLevelWarningThreshold =
        DEFAULT_ITEM_LEVEL_WARNING_THRESHOLD,
}

-- Keep the player defaults separate. The companion module adds its own
-- defaults to the shared SavedVariables table below, but /cgui reset
-- must not overwrite the companion settings.
addon.playerDefaults = {}

for key, value in pairs(addon.defaults) do
    addon.playerDefaults[key] = value
end

if companion and companion.AddDefaults then
    companion.AddDefaults(addon.defaults)
end

------------------------------------------------------------
-- SavedVariables
------------------------------------------------------------

local function NormalizeSavedNumber(
    saved,
    key,
    defaultValue,
    minimum,
    maximum
)

    saved[key] = zo_clamp(
        tonumber(saved[key]) or defaultValue,
        minimum,
        maximum
    )

end

function addon.InitializeSavedVariables()

    local legacySaved = ZO_SavedVars:NewAccountWide(
        "CharacterGearUISaved",
        1,
        nil,
        nil
    )

    addon.saved = ZO_SavedVars:NewAccountWide(
        "CharacterGearUISaved",
        1,
        GetWorldName(),
        addon.defaults
    )

    if not addon.saved.serverSettingsMigrated then

        for key in pairs(addon.defaults) do
            if legacySaved[key] ~= nil then
                addon.saved[key] = legacySaved[key]
            end
        end

        addon.saved.serverSettingsMigrated = true

    end

    -- Remove the obsolete enable switch from existing SavedVariables.
    addon.saved.enabled = nil

    NormalizeSavedNumber(
        addon.saved,
        "scale",
        DEFAULT_UI_SCALE,
        1,
        2
    )
    NormalizeSavedNumber(
        addon.saved,
        "positionX",
        DEFAULT_POSITION_X,
        MIN_POSITION_X,
        MAX_POSITION_X
    )
    NormalizeSavedNumber(
        addon.saved,
        "positionY",
        DEFAULT_POSITION_Y,
        MIN_POSITION_Y,
        MAX_POSITION_Y
    )
    NormalizeSavedNumber(
        addon.saved,
        "attributeFontSize",
        DEFAULT_ATTRIBUTE_FONT_SIZE,
        MIN_ATTRIBUTE_FONT_SIZE,
        MAX_ATTRIBUTE_FONT_SIZE
    )
    NormalizeSavedNumber(
        addon.saved,
        "equipmentSlotSize",
        DEFAULT_EQUIPMENT_SLOT_SIZE,
        MIN_EQUIPMENT_SLOT_SIZE,
        MAX_EQUIPMENT_SLOT_SIZE
    )
    NormalizeSavedNumber(
        addon.saved,
        "headerPositionX",
        DEFAULT_HEADER_POSITION_X,
        MIN_HEADER_POSITION_X,
        MAX_HEADER_POSITION_X
    )
    NormalizeSavedNumber(
        addon.saved,
        "headerPositionY",
        DEFAULT_HEADER_POSITION_Y,
        MIN_HEADER_POSITION_Y,
        MAX_HEADER_POSITION_Y
    )
    NormalizeSavedNumber(
        addon.saved,
        "headerScale",
        DEFAULT_HEADER_SCALE,
        0.5,
        2
    )
    NormalizeSavedNumber(
        addon.saved,
        "costumePositionX",
        DEFAULT_COSTUME_POSITION_X,
        MIN_COSTUME_POSITION_X,
        MAX_COSTUME_POSITION_X
    )
    NormalizeSavedNumber(
        addon.saved,
        "costumePositionY",
        DEFAULT_COSTUME_POSITION_Y,
        MIN_COSTUME_POSITION_Y,
        MAX_COSTUME_POSITION_Y
    )
    NormalizeSavedNumber(
        addon.saved,
        "figurePositionX",
        DEFAULT_FIGURE_POSITION_X,
        MIN_FIGURE_POSITION_X,
        MAX_FIGURE_POSITION_X
    )
    NormalizeSavedNumber(
        addon.saved,
        "figurePositionY",
        DEFAULT_FIGURE_POSITION_Y,
        MIN_FIGURE_POSITION_Y,
        MAX_FIGURE_POSITION_Y
    )
    NormalizeSavedNumber(
        addon.saved,
        "figureScale",
        DEFAULT_FIGURE_SCALE,
        MIN_FIGURE_SCALE,
        MAX_FIGURE_SCALE
    )

    -- ESO treats the exact camera factor 3.00 as a special boundary
    -- and can reset it to a much smaller distance. Keep the stored value
    -- inside the safe range used by the settings slider.
    NormalizeSavedNumber(
        addon.saved,
        "characterDistance",
        DEFAULT_CHARACTER_DISTANCE,
        MIN_CHARACTER_DISTANCE,
        MAX_CHARACTER_DISTANCE
    )
    NormalizeSavedNumber(
        addon.saved,
        "repairWarningThreshold",
        DEFAULT_REPAIR_WARNING_THRESHOLD,
        MIN_REPAIR_WARNING_THRESHOLD,
        MAX_REPAIR_WARNING_THRESHOLD
    )
    NormalizeSavedNumber(
        addon.saved,
        "weaponChargeWarningThreshold",
        DEFAULT_WEAPON_CHARGE_WARNING_THRESHOLD,
        MIN_WEAPON_CHARGE_WARNING_THRESHOLD,
        MAX_WEAPON_CHARGE_WARNING_THRESHOLD
    )
    NormalizeSavedNumber(
        addon.saved,
        "itemLevelWarningThreshold",
        DEFAULT_ITEM_LEVEL_WARNING_THRESHOLD,
        MIN_ITEM_LEVEL_WARNING_THRESHOLD,
        MAX_ITEM_LEVEL_WARNING_THRESHOLD
    )
    NormalizeSavedNumber(
        addon.saved,
        "equipmentIndicatorFontSize",
        DEFAULT_EQUIPMENT_INDICATOR_FONT_SIZE,
        MIN_EQUIPMENT_INDICATOR_FONT_SIZE,
        MAX_EQUIPMENT_INDICATOR_FONT_SIZE
    )

end

------------------------------------------------------------
-- Helper
------------------------------------------------------------

local function SafeScale(control, scale)

    if control then
        control:SetScale(scale)
    end

end

local function CenterWeaponSwapText()

    local swapButton = ZO_CharacterWeaponSwap

    if not swapButton then
        return
    end

    swapButton:SetNormalOffset(-1, 0)
    swapButton:SetPressedOffset(-1, 0)
    swapButton:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    swapButton:SetVerticalAlignment(TEXT_ALIGN_CENTER)

end

local originalStatsScrollChildHeight = nil

local function FixStatsScrollbar(scale)

    local scrollChild = ZO_CharacterWindowStatsScrollScrollChild

    if not scrollChild then
        return
    end

    if not originalStatsScrollChildHeight then
        originalStatsScrollChildHeight = scrollChild:GetHeight()
    end

    local correction = 2 / scale

    scrollChild:SetHeight(
        originalStatsScrollChildHeight - correction
    )

end

local function GetEquipmentLayoutScale()

    local screenWidth, screenHeight = GuiRoot:GetDimensions()

    return math.min(
        screenWidth / REFERENCE_SCREEN_WIDTH,
        screenHeight / REFERENCE_SCREEN_HEIGHT
    )

end

local function AnchorEquipmentControl(
    control,
    offsetX,
    offsetY,
    size,
    layoutScale
)

    if not control then
        return
    end

    control:SetScale(1)
    control:ClearAnchors()
    control:SetAnchor(
        CENTER,
        GuiRoot,
        CENTER,
        offsetX * layoutScale,
        offsetY * layoutScale
    )

    if size then
        local scaledSize = size * layoutScale
        control:SetDimensions(scaledSize, scaledSize)
    end

end

local function AddSlotOutline(slotControl)

    if not slotControl then
        return
    end

    -- ESO draws the native button textures above parts of the Icon control.
    -- Clear them so the dark center of the slot texture cannot tint the item.
    slotControl:SetNormalTexture()
    slotControl:SetPressedTexture()
    slotControl:SetDisabledTexture()
    slotControl:SetDisabledPressedTexture()

    local background = slotControl.CharacterGearUIBackground

    if not background then

        background = WINDOW_MANAGER:CreateControl(
            slotControl:GetName() .. "CharacterGearUIBackground",
            slotControl,
            CT_TEXTURE
        )

        background:SetDrawLayer(DL_BACKGROUND)
        background:SetDrawLevel(0)
        background:SetMouseEnabled(false)

        slotControl.CharacterGearUIBackground = background

    end

    background:ClearAnchors()
    background:SetAnchor(
        TOPLEFT,
        slotControl,
        TOPLEFT
    )
    background:SetAnchor(
        BOTTOMRIGHT,
        slotControl,
        BOTTOMRIGHT
    )
    background:SetTexture(EQUIPMENT_SLOT_TEXTURE)
    background:SetHidden(false)

    local icon = slotControl:GetNamedChild("Icon")

    if icon then
        icon:SetDrawLayer(DL_CONTROLS)
        icon:SetDrawLevel(2)
    end

end

local function SetAttributeLabelFont(label, fontSize)

    if not label then
        return
    end

    label:SetFont(
        string.format(
            "$(BOLD_FONT)|%d|soft-shadow-thick",
            fontSize
        )
    )

end

function addon.ApplyAttributeFontSize()

    local scrollChild = ZO_CharacterWindowStatsScrollScrollChild

    if not scrollChild then
        return
    end

    local fontSize = zo_clamp(
        addon.saved.attributeFontSize,
        MIN_ATTRIBUTE_FONT_SIZE,
        MAX_ATTRIBUTE_FONT_SIZE
    )

    local rowHeight = math.max(24, fontSize + 6)
    local headerFontSize = math.min(
        fontSize + 2,
        MAX_ATTRIBUTE_FONT_SIZE
    )
    local contentOffsetY = 0

    if ZO_Character.PP_BG then
        contentOffsetY =
            PERFECT_PIXEL_ATTRIBUTE_CONTENT_OFFSET_Y
    end

    local firstStatEntry = nil

    for index = 1, scrollChild:GetNumChildren() do

        local entry = scrollChild:GetChild(index)

        if entry then
            local nameLabel = entry:GetNamedChild("Name")
            local valueLabel = entry:GetNamedChild("Value")
            local pendingBonusLabel = entry:GetNamedChild("PendingBonus")
            local comparisonValueLabel = entry:GetNamedChild("ComparisonValue")
            local headerLabel = entry:GetNamedChild("Header")

            SetAttributeLabelFont(nameLabel, fontSize)
            SetAttributeLabelFont(valueLabel, fontSize)
            SetAttributeLabelFont(pendingBonusLabel, fontSize)
            SetAttributeLabelFont(comparisonValueLabel, fontSize)
            SetAttributeLabelFont(headerLabel, headerFontSize)

            if entry.statEntry then

                if not firstStatEntry then
                    firstStatEntry = entry
                end

                entry:SetHeight(rowHeight)
            end
        end

    end

    if firstStatEntry then

        firstStatEntry:ClearAnchors()
        firstStatEntry:SetAnchor(
            TOP,
            scrollChild,
            TOP,
            ATTRIBUTE_FIRST_ENTRY_OFFSET_X,
            contentOffsetY
        )

    end

end

------------------------------------------------------------
-- Equipment Layout
------------------------------------------------------------

function addon.ApplyFigureLayout(layoutScale)

    local figure = ZO_CharacterPaperDoll

    if not figure then
        return
    end

    local positionX = zo_clamp(
        addon.saved.figurePositionX,
        MIN_FIGURE_POSITION_X,
        MAX_FIGURE_POSITION_X
    )
    local positionY = zo_clamp(
        addon.saved.figurePositionY,
        MIN_FIGURE_POSITION_Y,
        MAX_FIGURE_POSITION_Y
    )
    local figureScale = zo_clamp(
        addon.saved.figureScale,
        MIN_FIGURE_SCALE,
        MAX_FIGURE_SCALE
    )

    local silhouetteTexture =
        GetUnitSilhouetteTexture("player")

    if silhouetteTexture and silhouetteTexture ~= "" then
        figure:SetTexture(silhouetteTexture)
    end

    figure:SetDimensions(64, 256)
    figure:SetScale(figureScale * layoutScale)
    figure:ClearAnchors()
    figure:SetAnchor(
        TOP,
        GuiRoot,
        TOPLEFT,
        positionX * layoutScale,
        positionY * layoutScale
    )
    figure:SetColor(1, 1, 1, 1)
    figure:SetAlpha(1)
    figure:SetDrawLayer(DL_CONTROLS)
    figure:SetDrawLevel(1)
    figure:SetHidden(false)

end

function addon.ApplyEquipmentLayout()

    local layoutScale = GetEquipmentLayoutScale()
    local slotSize = zo_clamp(
        addon.saved.equipmentSlotSize,
        MIN_EQUIPMENT_SLOT_SIZE,
        MAX_EQUIPMENT_SLOT_SIZE
    )
    local headerScale = zo_clamp(
        addon.saved.headerScale,
        0.5,
        2.0
    )
    local headerPositionX = zo_clamp(
        addon.saved.headerPositionX,
        MIN_HEADER_POSITION_X,
        MAX_HEADER_POSITION_X
    )
    local headerPositionY = zo_clamp(
        addon.saved.headerPositionY,
        MIN_HEADER_POSITION_Y,
        MAX_HEADER_POSITION_Y
    )
    local costumePositionX = zo_clamp(
        addon.saved.costumePositionX,
        MIN_COSTUME_POSITION_X,
        MAX_COSTUME_POSITION_X
    )
    local costumePositionY = zo_clamp(
        addon.saved.costumePositionY,
        MIN_COSTUME_POSITION_Y,
        MAX_COSTUME_POSITION_Y
    )

    -- ZO_Character remains the owner of the original ESO slots, but it no
    -- longer occupies a visible panel of its own.
    ZO_Character:SetScale(1)
    ZO_Character:ClearAnchors()
    ZO_Character:SetAnchor(CENTER, GuiRoot, CENTER)
    ZO_Character:SetDimensions(1, 1)
    ZO_Character:SetMouseEnabled(false)

    addon.ApplyFigureLayout(layoutScale)

    if ZO_CharacterAccessoriesSection then
        ZO_CharacterAccessoriesSection:SetHidden(true)
    end

    if ZO_CharacterWeaponsSection then
        ZO_CharacterWeaponsSection:SetHidden(true)
    end

    local headerSection = ZO_CharacterHeaderSection
    local title = ZO_CharacterHeaderSectionTitle
    local divider = ZO_CharacterHeaderSectionDivider
    local apparelText = ZO_CharacterApparelSectionText

    if headerSection then
        headerSection:SetHidden(false)
        headerSection:SetScale(headerScale)
        headerSection:ClearAnchors()
        headerSection:SetAnchor(
            TOPLEFT,
            GuiRoot,
            TOPLEFT,
            headerPositionX * layoutScale,
            headerPositionY * layoutScale
        )
        headerSection:SetDimensions(
            330 * layoutScale,
            100 * layoutScale
        )
    end

    if title then
        title:ClearAnchors()
        title:SetAnchor(
            TOPLEFT,
            headerSection,
            TOPLEFT,
            14 * layoutScale,
            26 * layoutScale
        )
    end

    if divider then
        divider:ClearAnchors()
        divider:SetAnchor(
            TOPLEFT,
            headerSection,
            TOPLEFT,
            0,
            63 * layoutScale
        )
        divider:SetDimensions(
            300 * layoutScale,
            4 * layoutScale
        )
        divider:SetHidden(false)
    end

    if apparelText and divider then
        apparelText:SetScale(headerScale)
        apparelText:ClearAnchors()
        apparelText:SetAnchor(
            TOPLEFT,
            divider,
            BOTTOMLEFT,
            14 * layoutScale,
            5 * layoutScale
        )
        apparelText:SetHidden(false)
    end

    local weaponColumnOffset =
        slotSize + WEAPON_SLOT_HORIZONTAL_GAP

    local weaponRowOffset =
        (
            slotSize
            + WEAPON_SLOT_VERTICAL_GAP
        ) / 2

    local weaponTopRowY =
        WEAPON_SLOT_GROUP_CENTER_Y - weaponRowOffset

    local weaponBottomRowY =
        WEAPON_SLOT_GROUP_CENTER_Y + weaponRowOffset

    for _, slotData in ipairs(EQUIPMENT_INDICATOR_SLOTS) do

        local control = _G[slotData.controlName]
        local x = slotData.x
        local y = slotData.y

        if slotData.isCostume then
            x = costumePositionX
            y = costumePositionY
        elseif slotData.weaponColumn ~= nil then
            x = slotData.weaponColumn * weaponColumnOffset
            y = slotData.weaponRow < 0
                and weaponTopRowY
                or weaponBottomRowY
        end

        AnchorEquipmentControl(
            control,
            x,
            y,
            slotSize,
            layoutScale
        )

        AddSlotOutline(control)

        local highlight = control:GetNamedChild("Highlight")

        if highlight then
            local highlightSize =
                slotSize
                * ACTIVE_WEAPON_HIGHLIGHT_SCALE
                * layoutScale
            local highlightOffset =
                ACTIVE_WEAPON_HIGHLIGHT_OPTICAL_OFFSET
                * (
                    slotSize
                    / EQUIPMENT_SLOT_REFERENCE_SIZE
                )
                * layoutScale

            highlight:SetDimensions(
                highlightSize,
                highlightSize
            )
            highlight:ClearAnchors()
            highlight:SetAnchor(
                CENTER,
                control,
                CENTER,
                highlightOffset,
                highlightOffset
            )
        end

    end

    local weaponSwap = ZO_CharacterWeaponSwap

    if weaponSwap then
        local weaponSwapScale =
            WEAPON_SWAP_MAX_SCALE
            * layoutScale
            * (
                slotSize
                / EQUIPMENT_SLOT_REFERENCE_SIZE
            )

        weaponSwap:SetScale(weaponSwapScale)
        weaponSwap:ClearAnchors()
        weaponSwap:SetAnchor(
            CENTER,
            GuiRoot,
            CENTER,
            WEAPON_SWAP_POSITION_X * layoutScale,
            WEAPON_SLOT_GROUP_CENTER_Y * layoutScale
        )
    end

    CenterWeaponSwapText()

    if addon.RefreshEquipmentIndicators then
        addon.RefreshEquipmentIndicators()
    end

end

------------------------------------------------------------
-- Equipment Borders, Condition, Charge and Level
------------------------------------------------------------

local function CreateEquipmentIndicatorControls(slotControl)

    local border = slotControl.CharacterGearUIQualityBorder

    if not border then

        border = WINDOW_MANAGER:CreateControl(
            slotControl:GetName()
                .. "CharacterGearUIQualityBorder",
            slotControl,
            CT_TEXTURE
        )
        border:SetTexture(
            EQUIPMENT_QUALITY_BORDER_TEXTURE
        )
        border:SetDrawLayer(DL_OVERLAY)
        border:SetDrawLevel(3)
        border:SetMouseEnabled(false)

        slotControl.CharacterGearUIQualityBorder = border

    end

    border:ClearAnchors()
    border:SetAnchor(
        TOPLEFT,
        slotControl,
        TOPLEFT
    )
    border:SetAnchor(
        BOTTOMRIGHT,
        slotControl,
        BOTTOMRIGHT
    )

    local conditionLabel =
        slotControl.CharacterGearUIConditionLabel

    if not conditionLabel then

        conditionLabel = WINDOW_MANAGER:CreateControl(
            slotControl:GetName()
                .. "CharacterGearUIConditionLabel",
            slotControl,
            CT_LABEL
        )
        conditionLabel:SetDrawLayer(DL_OVERLAY)
        conditionLabel:SetDrawLevel(5)
        conditionLabel:SetMouseEnabled(false)
        conditionLabel:SetHorizontalAlignment(
            TEXT_ALIGN_RIGHT
        )
        conditionLabel:SetVerticalAlignment(
            TEXT_ALIGN_CENTER
        )

        slotControl.CharacterGearUIConditionLabel =
            conditionLabel

    end

    local levelLabel = slotControl.CharacterGearUILevelLabel

    if not levelLabel then

        levelLabel = WINDOW_MANAGER:CreateControl(
            slotControl:GetName()
                .. "CharacterGearUILevelLabel",
            slotControl,
            CT_LABEL
        )
        levelLabel:SetDrawLayer(DL_OVERLAY)
        levelLabel:SetDrawLevel(5)
        levelLabel:SetMouseEnabled(false)
        levelLabel:SetHorizontalAlignment(
            TEXT_ALIGN_RIGHT
        )
        levelLabel:SetVerticalAlignment(
            TEXT_ALIGN_CENTER
        )

        slotControl.CharacterGearUILevelLabel = levelLabel

    end

    return border, conditionLabel, levelLabel

end

local function StyleEquipmentIndicatorLabels(
    slotControl,
    conditionLabel,
    levelLabel,
    fontSize
)

    local slotPixelSize = math.max(
        1,
        slotControl:GetWidth()
    )
    local sizeRatio =
        slotPixelSize / EQUIPMENT_SLOT_REFERENCE_SIZE
    fontSize = zo_clamp(
        math.floor(fontSize + 0.5),
        MIN_EQUIPMENT_INDICATOR_FONT_SIZE,
        MAX_EQUIPMENT_INDICATOR_FONT_SIZE
    )
    local labelHeight = fontSize + 6
    local labelOffset = math.max(
        1,
        3 * sizeRatio
    )

    local font = string.format(
        "$(BOLD_FONT)|%d|soft-shadow-thick",
        fontSize
    )

    conditionLabel:SetFont(font)
    conditionLabel:SetDimensions(
        slotPixelSize,
        labelHeight
    )
    conditionLabel:ClearAnchors()
    conditionLabel:SetAnchor(
        BOTTOMRIGHT,
        slotControl,
        BOTTOMRIGHT,
        -labelOffset,
        labelOffset
    )

    levelLabel:SetFont(font)
    levelLabel:SetDimensions(
        slotPixelSize,
        labelHeight
    )
    levelLabel:ClearAnchors()
    levelLabel:SetAnchor(
        TOPRIGHT,
        slotControl,
        TOPRIGHT,
        -labelOffset,
        -labelOffset
    )

end

local function StylePoisonStackCount(
    slotControl,
    fontSize
)

    local stackCountLabel =
        slotControl:GetNamedChild("StackCount")

    if not stackCountLabel then
        return
    end

    local slotPixelSize = math.max(
        1,
        slotControl:GetWidth()
    )
    local sizeRatio =
        slotPixelSize / EQUIPMENT_SLOT_REFERENCE_SIZE

    fontSize = zo_clamp(
        math.floor(fontSize + 0.5),
        MIN_EQUIPMENT_INDICATOR_FONT_SIZE,
        MAX_EQUIPMENT_INDICATOR_FONT_SIZE
    )

    local labelHeight = fontSize + 6
    local labelOffset = math.max(
        1,
        3 * sizeRatio
    )
    local font = string.format(
        "$(BOLD_FONT)|%d|soft-shadow-thick",
        fontSize
    )

    stackCountLabel:SetFont(font)
    stackCountLabel:SetDimensions(
        slotPixelSize,
        labelHeight
    )
    stackCountLabel:SetHorizontalAlignment(
        TEXT_ALIGN_RIGHT
    )
    stackCountLabel:SetVerticalAlignment(
        TEXT_ALIGN_CENTER
    )
    stackCountLabel:SetColor(1, 1, 1, 1)
    stackCountLabel:SetDrawLayer(DL_OVERLAY)
    stackCountLabel:SetDrawLevel(6)
    stackCountLabel:ClearAnchors()
    stackCountLabel:SetAnchor(
        BOTTOMRIGHT,
        slotControl,
        BOTTOMRIGHT,
        -labelOffset,
        labelOffset
    )

end

local function SetEquipmentWarningColor(
    label,
    difference,
    warningThreshold
)

    if difference >= 2 * warningThreshold then
        label:SetColor(1, 0.25, 0.21, 1)
    elseif difference >= warningThreshold then
        label:SetColor(1, 1, 0.21, 1)
    else
        label:SetColor(1, 1, 1, 1)
    end

end

local function SetLowValueWarningColor(
    label,
    value,
    warningThreshold
)

    if value <= warningThreshold / 2 then
        label:SetColor(1, 0.25, 0.21, 1)
    elseif value <= warningThreshold then
        label:SetColor(1, 1, 0.21, 1)
    else
        label:SetColor(1, 1, 1, 1)
    end

end

local function GetWeaponChargePercent(slotId)

    if not WEAPON_CHARGE_SLOTS[slotId]
        or not IsItemChargeable(BAG_WORN, slotId)
    then
        return nil
    end

    local currentCharge, maximumCharge =
        GetChargeInfoForItem(BAG_WORN, slotId)

    if not maximumCharge or maximumCharge <= 0 then
        return nil
    end

    return zo_clamp(
        math.floor(
            currentCharge / maximumCharge * 100 + 0.5
        ),
        0,
        100
    )

end

local function GetEquipmentLevelText(slotId)

    local requiredChampionPoints =
        GetItemRequiredChampionPoints(
            BAG_WORN,
            slotId
        )

    if requiredChampionPoints
        and requiredChampionPoints > 0
    then
        return
            "CP" .. tostring(requiredChampionPoints),
            GetUnitChampionPoints("player")
                - requiredChampionPoints,
            requiredChampionPoints
                >= MAX_EQUIPMENT_CHAMPION_POINTS
    end

    local requiredLevel = GetItemRequiredLevel(
        BAG_WORN,
        slotId
    )

    if requiredLevel and requiredLevel > 0 then
        return
            tostring(requiredLevel),
            GetUnitLevel("player") - requiredLevel,
            false
    end

    return "", 0, false

end

local function CreateItemDetailControls(slotControl)

    local nameLabel = slotControl.CharacterGearUIItemNameLabel

    if not nameLabel then

        nameLabel = WINDOW_MANAGER:CreateControl(
            slotControl:GetName()
                .. "CharacterGearUIItemNameLabel",
            slotControl,
            CT_LABEL
        )
        nameLabel:SetDrawLayer(DL_OVERLAY)
        nameLabel:SetDrawLevel(6)
        nameLabel:SetMouseEnabled(false)
        nameLabel:SetHorizontalAlignment(
            TEXT_ALIGN_LEFT
        )
        nameLabel:SetVerticalAlignment(
            TEXT_ALIGN_CENTER
        )

        slotControl.CharacterGearUIItemNameLabel =
            nameLabel

    end

    local armorTypeLabel =
        slotControl.CharacterGearUIArmorTypeLabel

    if not armorTypeLabel then

        armorTypeLabel = WINDOW_MANAGER:CreateControl(
            slotControl:GetName()
                .. "CharacterGearUIArmorTypeLabel",
            slotControl,
            CT_LABEL
        )
        armorTypeLabel:SetDrawLayer(DL_OVERLAY)
        armorTypeLabel:SetDrawLevel(6)
        armorTypeLabel:SetMouseEnabled(false)
        armorTypeLabel:SetHorizontalAlignment(
            TEXT_ALIGN_LEFT
        )
        armorTypeLabel:SetVerticalAlignment(
            TEXT_ALIGN_CENTER
        )
        armorTypeLabel:SetColor(1, 1, 1, 1)

        slotControl.CharacterGearUIArmorTypeLabel =
            armorTypeLabel

    end

    local outfitIcon =
        slotControl.CharacterGearUIOutfitIcon

    if not outfitIcon then

        outfitIcon = WINDOW_MANAGER:CreateControl(
            slotControl:GetName()
                .. "CharacterGearUIOutfitIcon",
            slotControl,
            CT_TEXTURE
        )
        outfitIcon:SetTexture(
            OUTFIT_ICON_TEXTURE
        )
        outfitIcon:SetDrawLayer(DL_OVERLAY)
        outfitIcon:SetDrawLevel(6)
        outfitIcon:SetMouseEnabled(false)

        slotControl.CharacterGearUIOutfitIcon =
            outfitIcon

    end

    local setCountLabel =
        slotControl.CharacterGearUISetCountLabel

    if not setCountLabel then

        setCountLabel = WINDOW_MANAGER:CreateControl(
            slotControl:GetName()
                .. "CharacterGearUISetCountLabel",
            slotControl,
            CT_LABEL
        )
        setCountLabel:SetDrawLayer(DL_OVERLAY)
        setCountLabel:SetDrawLevel(6)
        setCountLabel:SetMouseEnabled(false)
        setCountLabel:SetHorizontalAlignment(
            TEXT_ALIGN_LEFT
        )
        setCountLabel:SetVerticalAlignment(
            TEXT_ALIGN_CENTER
        )
        setCountLabel:SetColor(1, 1, 1, 1)

        slotControl.CharacterGearUISetCountLabel =
            setCountLabel

    end

    local costumeIcon =
        slotControl.CharacterGearUICostumeIcon

    if not costumeIcon then

        costumeIcon = WINDOW_MANAGER:CreateControl(
            slotControl:GetName()
                .. "CharacterGearUICostumeIcon",
            slotControl,
            CT_TEXTURE
        )
        costumeIcon:SetTexture(
            COSTUME_ICON_TEXTURE
        )
        costumeIcon:SetDrawLayer(DL_OVERLAY)
        costumeIcon:SetDrawLevel(6)
        costumeIcon:SetMouseEnabled(false)

        slotControl.CharacterGearUICostumeIcon =
            costumeIcon

    end

    return
        nameLabel,
        armorTypeLabel,
        outfitIcon,
        setCountLabel,
        costumeIcon

end

local function HasOutfitStyleOverride(outfitSlot)

    if not outfitSlot then
        return false
    end

    local actorCategory =
        GAMEPLAY_ACTOR_CATEGORY_PLAYER
    local outfitIndex =
        GetEquippedOutfitIndex(actorCategory)

    if not outfitIndex or outfitIndex <= 0 then
        return false
    end

    local collectibleId = GetOutfitSlotInfo(
        actorCategory,
        outfitIndex,
        outfitSlot
    )

    return collectibleId ~= nil
        and collectibleId > 0

end

local function GetItemDetailTypeText(itemLink, slotId)

    local equipType = GetItemLinkEquipType(itemLink)

    if WEAPON_CHARGE_SLOTS[slotId] then

        local weaponType =
            GetItemLinkWeaponType(itemLink)

        if weaponType
            and weaponType ~= WEAPONTYPE_NONE
        then
            return string.format(
                "%s %s",
                GetString("SI_EQUIPTYPE", equipType),
                GetString(
                    "SI_WEAPONTYPE",
                    weaponType
                )
            )
        end

    end

    local armorType = GetItemLinkArmorType(itemLink)

    if armorType and armorType ~= ARMORTYPE_NONE then
        return string.format(
            "%s %s",
            GetString("SI_EQUIPTYPE", equipType),
            GetString("SI_ARMORTYPE", armorType)
        )
    end

    if equipType == EQUIP_TYPE_RING
        or equipType == EQUIP_TYPE_NECK
    then
        return GetString("SI_EQUIPTYPE", equipType)
    end

    return ""

end

local function GetItemDetailOutfitSlot(
    detailData,
    weaponOutfitSlots
)

    if detailData.outfitSlot then
        return detailData.outfitSlot
    end

    if detailData.weaponOutfitIndex then
        return weaponOutfitSlots[
            detailData.weaponOutfitIndex
        ]
    end

    return nil

end

local function HasCostumeAppearanceOverride(
    slotId,
    appearanceState
)

    if slotId == EQUIP_SLOT_HEAD
        and appearanceState.hasHat
    then
        return true
    end

    return appearanceState.hasCostume
        and COSTUME_AFFECTED_SLOTS[slotId] == true

end

function addon.RefreshItemDetail(
    detailData,
    weaponOutfitSlots,
    appearanceState
)

    local slotControl = _G[detailData.controlName]

    if not slotControl or not addon.saved then
        return
    end

    local nameLabel,
        armorTypeLabel,
        outfitIcon,
        setCountLabel,
        costumeIcon =
            CreateItemDetailControls(slotControl)

    local itemName = GetItemName(
        BAG_WORN,
        detailData.slotId
    )
    local hasItem = itemName and itemName ~= ""

    if not hasItem then
        nameLabel:SetHidden(true)
        armorTypeLabel:SetHidden(true)
        outfitIcon:SetHidden(true)
        setCountLabel:SetHidden(true)
        costumeIcon:SetHidden(true)
        return
    end

    local fontSize = zo_clamp(
        addon.saved.equipmentIndicatorFontSize,
        MIN_EQUIPMENT_INDICATOR_FONT_SIZE,
        MAX_EQUIPMENT_INDICATOR_FONT_SIZE
    )
    local detailFont = string.format(
        "$(BOLD_FONT)|%d|soft-shadow-thick",
        fontSize
    )
    local armorFontSize = math.max(
        MIN_EQUIPMENT_INDICATOR_FONT_SIZE,
        fontSize - 2
    )
    local armorFont = string.format(
        "$(BOLD_FONT)|%d|soft-shadow-thick",
        armorFontSize
    )

    nameLabel:SetFont(detailFont)
    nameLabel:SetDimensions(360, fontSize + 8)
    nameLabel:ClearAnchors()

    if detailData.side == "left" then
        nameLabel:SetHorizontalAlignment(
            TEXT_ALIGN_RIGHT
        )
        nameLabel:SetAnchor(
            TOPRIGHT,
            slotControl,
            TOPLEFT,
            -10,
            2
        )
    else
        nameLabel:SetHorizontalAlignment(
            TEXT_ALIGN_LEFT
        )
        nameLabel:SetAnchor(
            TOPLEFT,
            slotControl,
            TOPRIGHT,
            10,
            2
        )
    end

    nameLabel:SetText(
        zo_strformat(
            SI_TOOLTIP_ITEM_NAME,
            itemName
        )
    )

    local quality = GetItemDisplayQuality(
        BAG_WORN,
        detailData.slotId
    )

    if quality then
        local qualityColor =
            GetItemQualityColor(quality)

        nameLabel:SetColor(
            qualityColor:UnpackRGBA()
        )
    else
        nameLabel:SetColor(1, 1, 1, 1)
    end

    nameLabel:SetHidden(false)

    local itemLink = GetItemLink(
        BAG_WORN,
        detailData.slotId,
        LINK_STYLE_DEFAULT
    )
    local detailTypeText =
        GetItemDetailTypeText(
            itemLink,
            detailData.slotId
        )
    local hasDetailType = detailTypeText ~= ""

    if hasDetailType then

        armorTypeLabel:SetFont(armorFont)
        armorTypeLabel:SetDimensions(
            420,
            armorFontSize + 8
        )
        armorTypeLabel:ClearAnchors()

        if detailData.side == "left" then
            armorTypeLabel:SetHorizontalAlignment(
                TEXT_ALIGN_RIGHT
            )
            armorTypeLabel:SetAnchor(
                TOPRIGHT,
                nameLabel,
                BOTTOMRIGHT,
                0,
                -2
            )
        else
            armorTypeLabel:SetHorizontalAlignment(
                TEXT_ALIGN_LEFT
            )
            armorTypeLabel:SetAnchor(
                TOPLEFT,
                nameLabel,
                BOTTOMLEFT,
                0,
                -2
            )
        end

        armorTypeLabel:SetText(detailTypeText)
        armorTypeLabel:SetHidden(false)

        local iconSize = fontSize + 8

        outfitIcon:SetDimensions(
            iconSize,
            iconSize
        )
        costumeIcon:SetDimensions(
            iconSize,
            iconSize
        )
        outfitIcon:ClearAnchors()
        costumeIcon:ClearAnchors()

        local outfitSlot = GetItemDetailOutfitSlot(
            detailData,
            weaponOutfitSlots
        )
        local showOutfitIcon =
            HasOutfitStyleOverride(outfitSlot)
        local showCostumeIcon =
            HasCostumeAppearanceOverride(
                detailData.slotId,
                appearanceState
            )
        local textWidth =
            armorTypeLabel:GetTextWidth()
        local costumeIconOffset =
            textWidth + 8

        if showOutfitIcon then
            costumeIconOffset =
                costumeIconOffset + iconSize + 4
        end

        if detailData.side == "left" then
            outfitIcon:SetAnchor(
                RIGHT,
                armorTypeLabel,
                RIGHT,
                -textWidth - 8,
                0
            )
            costumeIcon:SetAnchor(
                RIGHT,
                armorTypeLabel,
                RIGHT,
                -costumeIconOffset,
                0
            )
        else
            outfitIcon:SetAnchor(
                LEFT,
                armorTypeLabel,
                LEFT,
                textWidth + 8,
                0
            )
            costumeIcon:SetAnchor(
                LEFT,
                armorTypeLabel,
                LEFT,
                costumeIconOffset,
                0
            )
        end

        outfitIcon:SetHidden(
            not showOutfitIcon
        )
        costumeIcon:SetHidden(
            not showCostumeIcon
        )

        local hasSet,
            setName,
            numBonuses,
            numNormalEquipped,
            maxEquipped,
            setId,
            numPerfectedEquipped =
                GetItemLinkSetInfo(itemLink)

        if hasSet
            and maxEquipped
            and maxEquipped > 0
        then

            local totalEquipped = zo_min(
                (numNormalEquipped or 0)
                    + (numPerfectedEquipped or 0),
                maxEquipped
            )

            setCountLabel:SetFont(armorFont)
            setCountLabel:SetDimensions(
                420,
                armorFontSize + 8
            )
            setCountLabel:ClearAnchors()

            if detailData.side == "left" then
                setCountLabel:SetHorizontalAlignment(
                    TEXT_ALIGN_RIGHT
                )
                setCountLabel:SetAnchor(
                    TOPRIGHT,
                    armorTypeLabel,
                    BOTTOMRIGHT,
                    0,
                    -2
                )
            else
                setCountLabel:SetHorizontalAlignment(
                    TEXT_ALIGN_LEFT
                )
                setCountLabel:SetAnchor(
                    TOPLEFT,
                    armorTypeLabel,
                    BOTTOMLEFT,
                    0,
                    -2
                )
            end

            setCountLabel:SetText(
                string.format(
                    "%d/%d",
                    totalEquipped,
                    maxEquipped
                )
            )
            setCountLabel:SetColor(1, 1, 1, 1)
            setCountLabel:SetHidden(false)

        else

            setCountLabel:SetHidden(true)

        end

    else

        armorTypeLabel:SetHidden(true)
        outfitIcon:SetHidden(true)
        setCountLabel:SetHidden(true)
        costumeIcon:SetHidden(true)

    end

end

function addon.RefreshItemDetails()

    local weaponOutfitSlots =
    {
        GetOutfitSlotsForEquippedWeapons(
            GAMEPLAY_ACTOR_CATEGORY_PLAYER
        )
    }
    local actorCategory =
        GAMEPLAY_ACTOR_CATEGORY_PLAYER
    local appearanceState =
    {
        hasCostume =
            GetActiveCollectibleByType(
                COLLECTIBLE_CATEGORY_TYPE_COSTUME,
                actorCategory
            ) > 0,
        hasHat =
            GetActiveCollectibleByType(
                COLLECTIBLE_CATEGORY_TYPE_HAT,
                actorCategory
            ) > 0,
    }

    for _, detailData in ipairs(ITEM_DETAIL_SLOTS) do
        addon.RefreshItemDetail(
            detailData,
            weaponOutfitSlots,
            appearanceState
        )
    end

end

function addon.RefreshEquipmentIndicators()

    if not addon.saved then
        return
    end

    local repairWarningThreshold = zo_clamp(
        addon.saved.repairWarningThreshold,
        MIN_REPAIR_WARNING_THRESHOLD,
        MAX_REPAIR_WARNING_THRESHOLD
    )
    local weaponChargeWarningThreshold = zo_clamp(
        addon.saved.weaponChargeWarningThreshold,
        MIN_WEAPON_CHARGE_WARNING_THRESHOLD,
        MAX_WEAPON_CHARGE_WARNING_THRESHOLD
    )
    local itemLevelWarningThreshold = zo_clamp(
        addon.saved.itemLevelWarningThreshold,
        MIN_ITEM_LEVEL_WARNING_THRESHOLD,
        MAX_ITEM_LEVEL_WARNING_THRESHOLD
    )
    local fontSize = zo_clamp(
        addon.saved.equipmentIndicatorFontSize,
        MIN_EQUIPMENT_INDICATOR_FONT_SIZE,
        MAX_EQUIPMENT_INDICATOR_FONT_SIZE
    )
    local colorDollRed = false

    for _, slotData in ipairs(
        EQUIPMENT_INDICATOR_SLOTS
    ) do

        local slotControl = _G[slotData.controlName]

        if slotControl then

            local border,
                conditionLabel,
                levelLabel =
                    CreateEquipmentIndicatorControls(
                        slotControl
                    )

            StyleEquipmentIndicatorLabels(
                slotControl,
                conditionLabel,
                levelLabel,
                fontSize
            )

            if slotData.qualityOnly then
                StylePoisonStackCount(
                    slotControl,
                    fontSize
                )
            end

            local itemName = GetItemName(
                BAG_WORN,
                slotData.slotId
            )
            local hasItem =
                itemName and itemName ~= ""

            if hasItem then

                local quality = GetItemDisplayQuality(
                    BAG_WORN,
                    slotData.slotId
                )

                if quality then
                    local qualityColor =
                        GetItemQualityColor(quality)

                    border:SetColor(
                        qualityColor:UnpackRGBA()
                    )
                else
                    border:SetColor(1, 1, 1, 1)
                end

                border:SetHidden(
                    not addon.saved.showItemBorders
                )

                local hasDurability =
                    DoesItemHaveDurability(
                        BAG_WORN,
                        slotData.slotId
                    )
                local condition = 100

                if hasDurability then
                    condition = GetItemCondition(
                        BAG_WORN,
                        slotData.slotId
                    )
                end

                if hasDurability then

                    conditionLabel:SetText(
                        tostring(condition) .. "%"
                    )
                    SetEquipmentWarningColor(
                        conditionLabel,
                        100 - condition,
                        repairWarningThreshold
                    )
                    conditionLabel:SetHidden(
                        not addon.saved.showItemCondition
                    )

                else

                    local chargePercent =
                        GetWeaponChargePercent(
                            slotData.slotId
                        )

                    if chargePercent ~= nil then

                        conditionLabel:SetText(
                            tostring(chargePercent) .. "%"
                        )
                        SetLowValueWarningColor(
                            conditionLabel,
                            chargePercent,
                            weaponChargeWarningThreshold
                        )
                        conditionLabel:SetHidden(
                            not addon.saved.showWeaponCharge
                        )

                    else

                        conditionLabel:SetHidden(true)

                    end

                end

                if hasDurability
                    and condition
                        <= repairWarningThreshold
                then
                    colorDollRed = true
                end

                local levelText,
                    levelDifference,
                    isMaximumChampionItemLevel =
                    GetEquipmentLevelText(
                        slotData.slotId
                    )

                levelLabel:SetText(levelText)

                if isMaximumChampionItemLevel then
                    local maximumLevelColor =
                        GetItemQualityColor(
                            ITEM_DISPLAY_QUALITY_MAGIC
                        )

                    levelLabel:SetColor(
                        maximumLevelColor:UnpackRGBA()
                    )
                else
                    SetEquipmentWarningColor(
                        levelLabel,
                        levelDifference,
                        itemLevelWarningThreshold
                    )
                end

                levelLabel:SetHidden(
                    slotData.qualityOnly
                        or not addon.saved.showItemLevel
                        or levelText == ""
                )

            else

                border:SetHidden(true)
                conditionLabel:SetHidden(true)
                levelLabel:SetHidden(true)

            end

        end

    end

    addon.RefreshItemDetails()

    local doll = ZO_CharacterPaperDoll

    if doll then

        if addon.saved.colorDollRed and colorDollRed then
            doll:SetColor(1, 0, 0, 0.75)
        else
            doll:SetColor(1, 1, 1, 1)
        end

    end

end

function addon.RegisterEquipmentIndicatorEvents()

    local eventNamespace =
        addon.name .. "EquipmentIndicators"

    local function RefreshIfVisible()

        if addon.previewActive
            or (
                addon.inventoryScene
                and addon.inventoryScene:IsShowing()
            )
        then
            addon.RefreshEquipmentIndicators()
        end

    end

    EVENT_MANAGER:RegisterForEvent(
        eventNamespace .. "Inventory",
        EVENT_INVENTORY_SINGLE_SLOT_UPDATE,
        RefreshIfVisible
    )
    EVENT_MANAGER:AddFilterForEvent(
        eventNamespace .. "Inventory",
        EVENT_INVENTORY_SINGLE_SLOT_UPDATE,
        REGISTER_FILTER_BAG_ID,
        BAG_WORN,
        REGISTER_FILTER_INVENTORY_UPDATE_REASON,
        INVENTORY_UPDATE_REASON_DEFAULT
    )

    EVENT_MANAGER:RegisterForEvent(
        eventNamespace .. "Level",
        EVENT_LEVEL_UPDATE,
        RefreshIfVisible
    )
    EVENT_MANAGER:AddFilterForEvent(
        eventNamespace .. "Level",
        EVENT_LEVEL_UPDATE,
        REGISTER_FILTER_UNIT_TAG,
        "player"
    )
    EVENT_MANAGER:RegisterForEvent(
        eventNamespace .. "Champion",
        EVENT_CHAMPION_POINT_UPDATE,
        RefreshIfVisible
    )
    EVENT_MANAGER:AddFilterForEvent(
        eventNamespace .. "Champion",
        EVENT_CHAMPION_POINT_UPDATE,
        REGISTER_FILTER_UNIT_TAG,
        "player"
    )
    EVENT_MANAGER:RegisterForEvent(
        eventNamespace .. "Activated",
        EVENT_PLAYER_ACTIVATED,
        RefreshIfVisible
    )

    EVENT_MANAGER:RegisterForEvent(
        eventNamespace .. "OutfitChanged",
        EVENT_OUTFIT_CHANGE_RESPONSE,
        RefreshIfVisible
    )
    EVENT_MANAGER:RegisterForEvent(
        eventNamespace .. "OutfitEquipped",
        EVENT_OUTFIT_EQUIP_RESPONSE,
        RefreshIfVisible
    )
    EVENT_MANAGER:RegisterForEvent(
        eventNamespace .. "OutfitsInitialized",
        EVENT_OUTFITS_INITIALIZED,
        RefreshIfVisible
    )
    EVENT_MANAGER:RegisterForEvent(
        eventNamespace .. "CollectibleUpdated",
        EVENT_COLLECTIBLE_UPDATED,
        RefreshIfVisible
    )

end

------------------------------------------------------------
-- Attribute Window Background
------------------------------------------------------------

function addon.ApplyNormalAttributeBackground()

    local background = ZO_SharedWideLeftPanelBackground
    local statsWindow = ZO_CharacterWindowStats

    if not background or not statsWindow then
        return
    end

    background:SetScale(1)
    background:ClearAnchors()
    background:SetAnchor(
        TOPLEFT,
        statsWindow,
        TOPLEFT,
        -10,
        -15
    )
    background:SetAnchor(
        BOTTOMRIGHT,
        statsWindow,
        BOTTOMRIGHT,
        35,
        15
    )

    local rightTexture = background:GetNamedChild("Right")
    local leftTexture = background:GetNamedChild("Left")

    local textureHeight = math.max(
        724,
        background:GetHeight() + 150
    )

    if rightTexture then
        rightTexture:SetDimensions(64, textureHeight)
    end

    if leftTexture then

        local textureWidth = math.min(
            ORIGINAL_LEFT_BACKGROUND_WIDTH,
            math.max(
                TRIMMED_LEFT_BACKGROUND_WIDTH,
                background:GetWidth() + 80
            )
        )

        local croppedLeft = 1
            - (
                textureWidth
                / ORIGINAL_LEFT_BACKGROUND_WIDTH
            )

        leftTexture:SetDimensions(
            textureWidth,
            textureHeight
        )
        leftTexture:SetTextureCoords(
            croppedLeft,
            1,
            0,
            1
        )

    end

    if addon.previewActive
        or (
            addon.inventoryScene
            and addon.inventoryScene:IsShowing()
        )
    then
        background:SetHidden(false)
    end

end

function addon.ApplyPerfectPixelAttributeBackground()

    local statsWindow = ZO_CharacterWindowStats
    local perfectPixelBackground = ZO_Character.PP_BG

    if not perfectPixelBackground then
        return false
    end

    if addon.inventoryScene
        and WIDE_LEFT_PANEL_BG_FRAGMENT
    then
        addon.inventoryScene:RemoveFragment(
            WIDE_LEFT_PANEL_BG_FRAGMENT
        )
    end

    if ZO_SharedWideLeftPanelBackground then
        ZO_SharedWideLeftPanelBackground:SetHidden(true)
    end

    perfectPixelBackground:SetScale(1)
    perfectPixelBackground:ClearAnchors()
    perfectPixelBackground:SetAnchor(
        TOPLEFT,
        statsWindow,
        TOPLEFT,
        -10,
        -10
    )
    perfectPixelBackground:SetAnchor(
        BOTTOMRIGHT,
        statsWindow,
        BOTTOMRIGHT,
        10,
        10
    )

    if addon.previewActive
        or (
            addon.inventoryScene
            and addon.inventoryScene:IsShowing()
        )
    then
        perfectPixelBackground:SetHidden(false)
    end

    return true

end

function addon.ApplyAttributeBackground()

    if not addon.ApplyPerfectPixelAttributeBackground() then
        addon.ApplyNormalAttributeBackground()
    end

end

------------------------------------------------------------
-- Character Camera
------------------------------------------------------------

function addon.GetCharacterDistance()

    return zo_clamp(
        tonumber(addon.saved.characterDistance)
            or DEFAULT_CHARACTER_DISTANCE,
        MIN_CHARACTER_DISTANCE,
        MAX_CHARACTER_DISTANCE
    )

end

function addon.ApplyCharacterDistance()

    local distance = addon.GetCharacterDistance()

    if addon.characterDistanceFragment then
        addon.characterDistanceFragment.lookAtDistanceFactor =
            distance
    end

    if addon.previewCameraActive
        or (
            addon.inventoryScene
            and addon.inventoryScene:IsShowing()
        )
    then
        SetFrameLocalPlayerLookAtDistanceFactor(distance)
        RequestReframeLocalPlayerInGameCamera()
    end

end

function addon.EnsureCharacterCamera()

    local inventoryScene = addon.inventoryScene

    if not inventoryScene then
        return
    end

    inventoryScene:AddFragment(FRAME_PLAYER_FRAGMENT)
    inventoryScene:AddFragment(
        addon.characterDistanceFragment
    )

    addon.ApplyCharacterDistance()
    RequestReframeLocalPlayerInGameCamera()

end

function addon.EnablePreviewCamera()

    local screenWidth, screenHeight = GuiRoot:GetDimensions()
    local normalizedX, normalizedY = NormalizeUICanvasPoint(
        screenWidth * 0.5,
        screenHeight * 0.55
    )

    SetFrameLocalPlayerTarget(
        normalizedX,
        normalizedY
    )
    SetFrameLocalPlayerLookAtDistanceFactor(
        addon.GetCharacterDistance()
    )
    SetFrameLocalPlayerInGameCamera(true)

    addon.previewCameraActive = true

    RequestReframeLocalPlayerInGameCamera()

end

function addon.DisablePreviewCamera()

    if not addon.previewCameraActive then
        return
    end

    SetFrameLocalPlayerInGameCamera(false)
    SetFrameLocalPlayerLookAtDistanceFactor(nil)

    addon.previewCameraActive = false

end

function addon.SetupInventoryScene()

    local inventoryScene = SCENE_MANAGER:GetScene("inventory")

    addon.inventoryScene = inventoryScene
    addon.characterDistanceFragment =
        ZO_CharacterFramingLookAtDistance:New(
            addon.GetCharacterDistance()
        )

    -- PerfectPixel can remove FRAME_PLAYER_FRAGMENT when its "No Spin"
    -- option or an item preview is used. The fragment is retained only while
    -- the inventory is visible, so the normal game camera is unaffected.
    if perfectPixel then
        ZO_PreHook(
            inventoryScene,
            "RemoveFragment",
            function(scene, fragment)

                if fragment == FRAME_PLAYER_FRAGMENT
                    and scene:IsShowing()
                then
                    return true
                end

            end
        )
    end

    inventoryScene:RegisterCallback(
        "StateChange",
        function(oldState, newState)

            if newState == SCENE_SHOWING then

                addon.ApplyEquipmentLayout()
                addon.ScaleCharacter()
                addon.EnsureCharacterCamera()

                zo_callLater(function()

                    if inventoryScene:IsShowing() then
                        addon.ApplyEquipmentLayout()
                        addon.ScaleCharacter()
                        addon.EnsureCharacterCamera()
                    end

                end, 100)

            end

        end
    )

    inventoryScene:AddFragment(
        addon.characterDistanceFragment
    )
    inventoryScene:AddFragment(FRAME_PLAYER_FRAGMENT)

end

------------------------------------------------------------
-- Attribute Window Position
------------------------------------------------------------

function addon.ApplyCharacterPosition()

    local statsWindow = ZO_CharacterWindowStats

    if not statsWindow then
        return
    end

    statsWindow:ClearAnchors()
    statsWindow:SetAnchor(
        LEFT,
        GuiRoot,
        LEFT,
        addon.saved.positionX,
        DEFAULT_BACKGROUND_OFFSET_Y + addon.saved.positionY
    )

    statsWindow:SetDimensions(
        ATTRIBUTE_WINDOW_WIDTH,
        ATTRIBUTE_WINDOW_HEIGHT
    )

end

------------------------------------------------------------
-- Settings Preview
------------------------------------------------------------

function addon.ShowCharacterPreview()

    if addon.previewActive then
        return
    end

    addon.previewActive = true
    addon.previewHiddenStates = {}

    for _, control in ipairs(PREVIEW_CONTROLS) do

        addon.previewHiddenStates[control] = control:IsHidden()
        control:SetHidden(false)

    end

    addon.ScaleCharacter()
    addon.EnablePreviewCamera()

    local updateEvenIfHidden = true
    PLAYER_INVENTORY:UpdateList(
        INVENTORY_BACKPACK,
        updateEvenIfHidden
    )
    PLAYER_INVENTORY:UpdateFreeSlots(INVENTORY_BACKPACK)

end

function addon.HideCharacterPreview()

    if not addon.previewActive then
        return
    end

    addon.DisablePreviewCamera()

    for control, wasHidden in pairs(addon.previewHiddenStates) do
        control:SetHidden(wasHidden)

    end

    addon.previewHiddenStates = nil
    addon.previewActive = false

end

------------------------------------------------------------
-- Character Window
------------------------------------------------------------

function addon.ScaleCharacter()

    local scale = addon.saved.scale

    SafeScale(ZO_CharacterWindowStats, scale)

    addon.ApplyEquipmentLayout()
    addon.ApplyCharacterPosition()
    addon.ApplyAttributeBackground()
    addon.ApplyAttributeFontSize()
    CenterWeaponSwapText()
    FixStatsScrollbar(scale)

end

------------------------------------------------------------
-- Slash Commands
------------------------------------------------------------

function addon.ResetSettingsToDefaults()

    for key, value in pairs(addon.playerDefaults) do
        addon.saved[key] = value
    end

    addon.ScaleCharacter()
    addon.ApplyCharacterDistance()

end

function addon.RegisterSlashCommands()

    SLASH_COMMANDS["/cgui"] = function(text)

        local command = string.lower(text or "")
        command = command:match("^%s*(.-)%s*$")

        if command == "" then
            LAM2:OpenToPanel(addon.settingsPanel)

        elseif command == "reset" then

            addon.ResetSettingsToDefaults()

        else

            d("CharacterGearUI: /cgui | /cgui reset")

        end

    end

end

------------------------------------------------------------
-- Settings Menu
------------------------------------------------------------

function addon.CreateSettingsMenu()

    local panelData =
    {
        type = "panel",
        name = "Character Gear UI",
        displayName = "Character Gear UI",
        author = "@Trobo",
        version = addon.version,
        registerForRefresh = true,
        registerForDefaults = true,
    }

    addon.settingsPanel = LAM2:RegisterAddonPanel(
        "CharacterGearUIPanel",
        panelData
    )

    local options =
    {
        {
            type = "checkbox",
            name = GetString(SI_CHARACTER_GEAR_UI_PREVIEW),
            tooltip = GetString(SI_CHARACTER_GEAR_UI_PREVIEW_TOOLTIP),
            default = false,

            getFunc = function()
                return addon.previewActive == true
            end,

            setFunc = function(value)

                if value then
                    addon.ShowCharacterPreview()
                else
                    addon.HideCharacterPreview()
                end

            end,

            width = "full",
        },

        {
            type = "slider",
            name = GetString(SI_CHARACTER_GEAR_UI_SLOT_SIZE),
            tooltip = GetString(
                SI_CHARACTER_GEAR_UI_SLOT_SIZE_TOOLTIP
            ),
            min = MIN_EQUIPMENT_SLOT_SIZE,
            max = MAX_EQUIPMENT_SLOT_SIZE,
            step = 1,
            default = DEFAULT_EQUIPMENT_SLOT_SIZE,

            getFunc = function()
                return addon.saved.equipmentSlotSize
            end,

            setFunc = function(value)
                addon.saved.equipmentSlotSize = value
                addon.ApplyEquipmentLayout()
            end,

            width = "full",
        },

        {
            type = "slider",
            name = GetString(
                SI_CHARACTER_GEAR_UI_CHARACTER_DISTANCE
            ),
            tooltip = GetString(
                SI_CHARACTER_GEAR_UI_CHARACTER_DISTANCE_TOOLTIP
            ),
            min = 100,
            max = 299,
            step = 1,
            default = DEFAULT_CHARACTER_DISTANCE * 100,

            getFunc = function()
                return math.floor(
                    addon.GetCharacterDistance() * 100
                        + 0.5
                )
            end,

            setFunc = function(value)
                addon.saved.characterDistance = zo_clamp(
                    value / 100,
                    MIN_CHARACTER_DISTANCE,
                    MAX_CHARACTER_DISTANCE
                )
                addon.ApplyCharacterDistance()
            end,

            width = "full",
        },

        {
            type = "slider",
            name = GetString(SI_CHARACTER_GEAR_UI_HEADER_SCALE),
            tooltip = GetString(
                SI_CHARACTER_GEAR_UI_HEADER_SCALE_TOOLTIP
            ),
            min = 50,
            max = 200,
            step = 1,
            default = DEFAULT_HEADER_SCALE * 100,

            getFunc = function()
                return math.floor(
                    addon.saved.headerScale * 100
                )
            end,

            setFunc = function(value)
                addon.saved.headerScale = value / 100
                addon.ApplyEquipmentLayout()
            end,

            width = "full",
        },

        {
            type = "slider",
            name = GetString(
                SI_CHARACTER_GEAR_UI_HEADER_POSITION_X
            ),
            tooltip = GetString(
                SI_CHARACTER_GEAR_UI_HEADER_POSITION_X_TOOLTIP
            ),
            min = MIN_HEADER_POSITION_X,
            max = MAX_HEADER_POSITION_X,
            step = 1,
            default = DEFAULT_HEADER_POSITION_X,

            getFunc = function()
                return addon.saved.headerPositionX
            end,

            setFunc = function(value)
                addon.saved.headerPositionX = value
                addon.ApplyEquipmentLayout()
            end,

            width = "full",
        },

        {
            type = "slider",
            name = GetString(
                SI_CHARACTER_GEAR_UI_HEADER_POSITION_Y
            ),
            tooltip = GetString(
                SI_CHARACTER_GEAR_UI_HEADER_POSITION_Y_TOOLTIP
            ),
            min = MIN_HEADER_POSITION_Y,
            max = MAX_HEADER_POSITION_Y,
            step = 1,
            default = DEFAULT_HEADER_POSITION_Y,

            getFunc = function()
                return addon.saved.headerPositionY
            end,

            setFunc = function(value)
                addon.saved.headerPositionY = value
                addon.ApplyEquipmentLayout()
            end,

            width = "full",
        },

        {
            type = "slider",
            name = GetString(SI_CHARACTER_GEAR_UI_FIGURE_SCALE),
            tooltip = GetString(
                SI_CHARACTER_GEAR_UI_FIGURE_SCALE_TOOLTIP
            ),
            min = MIN_FIGURE_SCALE * 100,
            max = MAX_FIGURE_SCALE * 100,
            step = 1,
            default = DEFAULT_FIGURE_SCALE * 100,

            getFunc = function()
                return math.floor(
                    addon.saved.figureScale * 100
                        + 0.5
                )
            end,

            setFunc = function(value)
                addon.saved.figureScale = value / 100
                addon.ApplyEquipmentLayout()
            end,

            width = "full",
        },

        {
            type = "slider",
            name = GetString(
                SI_CHARACTER_GEAR_UI_FIGURE_POSITION_X
            ),
            tooltip = GetString(
                SI_CHARACTER_GEAR_UI_FIGURE_POSITION_X_TOOLTIP
            ),
            min = MIN_FIGURE_POSITION_X,
            max = MAX_FIGURE_POSITION_X,
            step = 1,
            default = DEFAULT_FIGURE_POSITION_X,

            getFunc = function()
                return addon.saved.figurePositionX
            end,

            setFunc = function(value)
                addon.saved.figurePositionX = value
                addon.ApplyEquipmentLayout()
            end,

            width = "full",
        },

        {
            type = "slider",
            name = GetString(
                SI_CHARACTER_GEAR_UI_FIGURE_POSITION_Y
            ),
            tooltip = GetString(
                SI_CHARACTER_GEAR_UI_FIGURE_POSITION_Y_TOOLTIP
            ),
            min = MIN_FIGURE_POSITION_Y,
            max = MAX_FIGURE_POSITION_Y,
            step = 1,
            default = DEFAULT_FIGURE_POSITION_Y,

            getFunc = function()
                return addon.saved.figurePositionY
            end,

            setFunc = function(value)
                addon.saved.figurePositionY = value
                addon.ApplyEquipmentLayout()
            end,

            width = "full",
        },

        {
            type = "slider",
            name = GetString(SI_CHARACTER_GEAR_UI_SCALE),
            tooltip = GetString(SI_CHARACTER_GEAR_UI_SCALE_TOOLTIP),
            min = 100,
            max = 200,
            step = 1,
            default = DEFAULT_UI_SCALE * 100,

            getFunc = function()
                return math.floor(addon.saved.scale * 100)
            end,

            setFunc = function(value)
                addon.saved.scale = value / 100
                addon.ScaleCharacter()
            end,

            width = "full",
        },

        {
            type = "slider",
            name = GetString(SI_CHARACTER_GEAR_UI_ATTRIBUTE_FONT_SIZE),
            tooltip = GetString(SI_CHARACTER_GEAR_UI_ATTRIBUTE_FONT_SIZE_TOOLTIP),
            min = MIN_ATTRIBUTE_FONT_SIZE,
            max = MAX_ATTRIBUTE_FONT_SIZE,
            step = 1,
            default = DEFAULT_ATTRIBUTE_FONT_SIZE,

            getFunc = function()
                return addon.saved.attributeFontSize
            end,

            setFunc = function(value)
                addon.saved.attributeFontSize = value
                addon.ApplyAttributeFontSize()
                FixStatsScrollbar(addon.saved.scale)
            end,

            width = "full",
        },

        {
            type = "slider",
            name = GetString(SI_CHARACTER_GEAR_UI_POSITION_X),
            tooltip = GetString(SI_CHARACTER_GEAR_UI_POSITION_X_TOOLTIP),
            min = MIN_POSITION_X,
            max = MAX_POSITION_X,
            step = 1,
            default = DEFAULT_POSITION_X,

            getFunc = function()
                return addon.saved.positionX
            end,

            setFunc = function(value)
                addon.saved.positionX = value
                addon.ScaleCharacter()
            end,

            width = "full",
        },

        {
            type = "slider",
            name = GetString(SI_CHARACTER_GEAR_UI_POSITION_Y),
            tooltip = GetString(SI_CHARACTER_GEAR_UI_POSITION_Y_TOOLTIP),
            min = MIN_POSITION_Y,
            max = MAX_POSITION_Y,
            step = 1,
            default = DEFAULT_POSITION_Y,

            getFunc = function()
                return addon.saved.positionY
            end,

            setFunc = function(value)
                addon.saved.positionY = value
                addon.ScaleCharacter()
            end,

            width = "full",
        },

        {
            type = "checkbox",
            name = GetString(
                SI_CHARACTER_GEAR_UI_SHOW_ITEM_BORDERS
            ),
            tooltip = GetString(
                SI_CHARACTER_GEAR_UI_SHOW_ITEM_BORDERS_TOOLTIP
            ),
            default = DEFAULT_SHOW_ITEM_BORDERS,

            getFunc = function()
                return addon.saved.showItemBorders
            end,

            setFunc = function(value)
                addon.saved.showItemBorders = value
                addon.RefreshEquipmentIndicators()
            end,

            width = "full",
        },

        {
            type = "checkbox",
            name = GetString(
                SI_CHARACTER_GEAR_UI_SHOW_ITEM_CONDITION
            ),
            tooltip = GetString(
                SI_CHARACTER_GEAR_UI_SHOW_ITEM_CONDITION_TOOLTIP
            ),
            default = DEFAULT_SHOW_ITEM_CONDITION,

            getFunc = function()
                return addon.saved.showItemCondition
            end,

            setFunc = function(value)
                addon.saved.showItemCondition = value
                addon.RefreshEquipmentIndicators()
            end,

            width = "full",
        },

        {
            type = "checkbox",
            name = GetString(
                SI_CHARACTER_GEAR_UI_SHOW_ITEM_LEVEL
            ),
            tooltip = GetString(
                SI_CHARACTER_GEAR_UI_SHOW_ITEM_LEVEL_TOOLTIP
            ),
            default = DEFAULT_SHOW_ITEM_LEVEL,

            getFunc = function()
                return addon.saved.showItemLevel
            end,

            setFunc = function(value)
                addon.saved.showItemLevel = value
                addon.RefreshEquipmentIndicators()
            end,

            width = "full",
        },

        {
            type = "checkbox",
            name = GetString(
                SI_CHARACTER_GEAR_UI_COLOR_DOLL_RED
            ),
            tooltip = GetString(
                SI_CHARACTER_GEAR_UI_COLOR_DOLL_RED_TOOLTIP
            ),
            default = DEFAULT_COLOR_DOLL_RED,

            getFunc = function()
                return addon.saved.colorDollRed
            end,

            setFunc = function(value)
                addon.saved.colorDollRed = value
                addon.RefreshEquipmentIndicators()
            end,

            width = "full",
        },

        {
            type = "slider",
            name = GetString(
                SI_CHARACTER_GEAR_UI_REPAIR_WARNING_THRESHOLD
            ),
            tooltip = GetString(
                SI_CHARACTER_GEAR_UI_REPAIR_WARNING_THRESHOLD_TOOLTIP
            ),
            min = MIN_REPAIR_WARNING_THRESHOLD,
            max = MAX_REPAIR_WARNING_THRESHOLD,
            step = 1,
            default = DEFAULT_REPAIR_WARNING_THRESHOLD,

            getFunc = function()
                return addon.saved.repairWarningThreshold
            end,

            setFunc = function(value)
                addon.saved.repairWarningThreshold = value
                addon.RefreshEquipmentIndicators()
            end,

            width = "full",
        },

        {
            type = "slider",
            name = GetString(
                SI_CHARACTER_GEAR_UI_ITEM_LEVEL_WARNING_THRESHOLD
            ),
            tooltip = GetString(
                SI_CHARACTER_GEAR_UI_ITEM_LEVEL_WARNING_THRESHOLD_TOOLTIP
            ),
            min = MIN_ITEM_LEVEL_WARNING_THRESHOLD,
            max = MAX_ITEM_LEVEL_WARNING_THRESHOLD,
            step = 1,
            default =
                DEFAULT_ITEM_LEVEL_WARNING_THRESHOLD,

            getFunc = function()
                return addon.saved.itemLevelWarningThreshold
            end,

            setFunc = function(value)
                addon.saved.itemLevelWarningThreshold = value
                addon.RefreshEquipmentIndicators()
            end,

            width = "full",
        },

        {
            type = "checkbox",
            name = GetString(
                SI_CHARACTER_GEAR_UI_SHOW_WEAPON_CHARGE
            ),
            tooltip = GetString(
                SI_CHARACTER_GEAR_UI_SHOW_WEAPON_CHARGE_TOOLTIP
            ),
            default = DEFAULT_SHOW_WEAPON_CHARGE,

            getFunc = function()
                return addon.saved.showWeaponCharge
            end,

            setFunc = function(value)
                addon.saved.showWeaponCharge = value
                addon.RefreshEquipmentIndicators()
            end,

            width = "full",
        },

        {
            type = "slider",
            name = GetString(
                SI_CHARACTER_GEAR_UI_WEAPON_CHARGE_WARNING_THRESHOLD
            ),
            tooltip = GetString(
                SI_CHARACTER_GEAR_UI_WEAPON_CHARGE_WARNING_THRESHOLD_TOOLTIP
            ),
            min = MIN_WEAPON_CHARGE_WARNING_THRESHOLD,
            max = MAX_WEAPON_CHARGE_WARNING_THRESHOLD,
            step = 1,
            default =
                DEFAULT_WEAPON_CHARGE_WARNING_THRESHOLD,

            getFunc = function()
                return addon.saved.weaponChargeWarningThreshold
            end,

            setFunc = function(value)
                addon.saved.weaponChargeWarningThreshold = value
                addon.RefreshEquipmentIndicators()
            end,

            width = "full",
        },

        {
            type = "slider",
            name = GetString(
                SI_CHARACTER_GEAR_UI_EQUIPMENT_INDICATOR_FONT_SIZE
            ),
            tooltip = GetString(
                SI_CHARACTER_GEAR_UI_EQUIPMENT_INDICATOR_FONT_SIZE_TOOLTIP
            ),
            min = MIN_EQUIPMENT_INDICATOR_FONT_SIZE,
            max = MAX_EQUIPMENT_INDICATOR_FONT_SIZE,
            step = 1,
            default =
                DEFAULT_EQUIPMENT_INDICATOR_FONT_SIZE,

            getFunc = function()
                return
                    addon.saved.equipmentIndicatorFontSize
            end,

            setFunc = function(value)
                addon.saved.equipmentIndicatorFontSize =
                    value
                addon.RefreshEquipmentIndicators()
            end,

            width = "full",
        },

        {
            type = "slider",
            name = GetString(
                SI_CHARACTER_GEAR_UI_COSTUME_POSITION_X
            ),
            tooltip = GetString(
                SI_CHARACTER_GEAR_UI_COSTUME_POSITION_X_TOOLTIP
            ),
            min = MIN_COSTUME_POSITION_X,
            max = MAX_COSTUME_POSITION_X,
            step = 1,
            default = DEFAULT_COSTUME_POSITION_X,

            getFunc = function()
                return addon.saved.costumePositionX
            end,

            setFunc = function(value)
                addon.saved.costumePositionX = value
                addon.ApplyEquipmentLayout()
            end,

            width = "full",
        },

        {
            type = "slider",
            name = GetString(
                SI_CHARACTER_GEAR_UI_COSTUME_POSITION_Y
            ),
            tooltip = GetString(
                SI_CHARACTER_GEAR_UI_COSTUME_POSITION_Y_TOOLTIP
            ),
            min = MIN_COSTUME_POSITION_Y,
            max = MAX_COSTUME_POSITION_Y,
            step = 1,
            default = DEFAULT_COSTUME_POSITION_Y,

            getFunc = function()
                return addon.saved.costumePositionY
            end,

            setFunc = function(value)
                addon.saved.costumePositionY = value
                addon.ApplyEquipmentLayout()
            end,

            width = "full",
        },
    }

    local flatOptions = options
    local companionSettings = {}

    if companion
        and companion.CreateSettingsControls
    then
        companionSettings =
            companion.CreateSettingsControls()
    end

    local function MergeControls(primary, additional)

        if additional then
            for _, control in ipairs(additional) do
                table.insert(primary, control)
            end
        end

        return primary

    end

    options =
    {
        flatOptions[1],

        {
            type = "submenu",
            name = GetString(
                SI_CHARACTER_GEAR_UI_SUBMENU_INFO
            ),
            controls = MergeControls(
            {
                {
                    type = "description",
                    text =
                        "|t40:40:"
                        .. COSTUME_ICON_TEXTURE
                        .. "|t  "
                        .. GetString(
                            SI_CHARACTER_GEAR_UI_INFO_COSTUME_ICON
                        ),
                    width = "full",
                },
                {
                    type = "description",
                    text =
                        "|t40:40:"
                        .. OUTFIT_ICON_TEXTURE
                        .. "|t  "
                        .. GetString(
                            SI_CHARACTER_GEAR_UI_INFO_OUTFIT_ICON
                        ),
                    width = "full",
                },
                {
                    type = "header",
                    name = GetString(
                        SI_CHARACTER_GEAR_UI_INFO_SLASH_COMMANDS
                    ),
                    width = "full",
                },
                {
                    type = "description",
                    text =
                        "|cFFFF00/cgui|r  "
                        .. GetString(
                            SI_CHARACTER_GEAR_UI_INFO_COMMAND_OPEN
                        ),
                    width = "full",
                },
                {
                    type = "description",
                    text =
                        "|cFFFF00/cgui reset|r  "
                        .. GetString(
                            SI_CHARACTER_GEAR_UI_INFO_COMMAND_RESET
                        ),
                    width = "full",
                },
            }, companionSettings.info),
        },

        {
            type = "submenu",
            name = GetString(
                SI_CHARACTER_GEAR_UI_SUBMENU_EQUIPMENT_HEADER
            ),
            controls = MergeControls(
            {
                flatOptions[4],
                flatOptions[5],
                flatOptions[6],
            }, companionSettings.header),
        },

        {
            type = "submenu",
            name = GetString(
                SI_CHARACTER_GEAR_UI_SUBMENU_CHARACTER_STATS
            ),
            controls =
            {
                flatOptions[10],
                flatOptions[11],
                flatOptions[12],
                flatOptions[13],
            },
        },

        {
            type = "submenu",
            name = GetString(
                SI_CHARACTER_GEAR_UI_SUBMENU_EQUIPMENT_SLOTS
            ),
            controls = MergeControls(
            {
                flatOptions[2],
                flatOptions[23],
                flatOptions[24],
            }, companionSettings.slots),
        },

        {
            type = "submenu",
            name = GetString(
                SI_CHARACTER_GEAR_UI_SUBMENU_EQUIPMENT_BORDERS
            ),
            controls = MergeControls(
            {
                flatOptions[14],
                flatOptions[22],
                flatOptions[15],
                flatOptions[20],
                flatOptions[16],
                flatOptions[17],
                flatOptions[18],
                flatOptions[21],
                flatOptions[19],
            }, companionSettings.borders),
        },

        {
            type = "submenu",
            name = GetString(
                SI_CHARACTER_GEAR_UI_SUBMENU_WHITE_FIGURE
            ),
            controls = MergeControls(
            {
                flatOptions[7],
                flatOptions[8],
                flatOptions[9],
            }, companionSettings.figure),
        },

        {
            type = "submenu",
            name = GetString(
                SI_CHARACTER_GEAR_UI_SUBMENU_CHARACTER
            ),
            controls = MergeControls(
            {
                flatOptions[3],
            }, companionSettings.character),
        },
    }

    LAM2:RegisterOptionControls("CharacterGearUIPanel", options)

    local function IsCharacterGearUIPanel(panel)

        if panel == addon.settingsPanel then
            return true
        end

        return panel
            and panel.GetName
            and panel:GetName() == "CharacterGearUIPanel"

    end

    CALLBACK_MANAGER:RegisterCallback(
        "LAM-PanelClosed",
        function(panel)

            if IsCharacterGearUIPanel(panel) then
                addon.HideCharacterPreview()
            end

        end
    )

end

------------------------------------------------------------
-- Initialize
------------------------------------------------------------

function addon.Initialize()

    addon.InitializeSavedVariables()

    if perfectPixel and ZO_Character.PP_BG then
        PREVIEW_CONTROLS[#PREVIEW_CONTROLS + 1] =
            ZO_Character.PP_BG
    end

    if companion and companion.Initialize then
        companion.Initialize(addon)
    end

    addon.CreateSettingsMenu()
    addon.RegisterSlashCommands()
    addon.SetupInventoryScene()
    addon.RegisterEquipmentIndicatorEvents()
    addon.ApplyEquipmentLayout()

    zo_callLater(function()
        addon.ScaleCharacter()
        addon.ApplyEquipmentLayout()
    end, 1000)

end

------------------------------------------------------------
-- Event
------------------------------------------------------------

local function OnAddonLoaded(event, addonName)

    if addonName ~= addon.name then
        return
    end

    EVENT_MANAGER:UnregisterForEvent(
        addon.name,
        EVENT_ADD_ON_LOADED
    )

    addon.Initialize()

end


EVENT_MANAGER:RegisterForEvent(
    addon.name,
    EVENT_ADD_ON_LOADED,
    OnAddonLoaded
)
