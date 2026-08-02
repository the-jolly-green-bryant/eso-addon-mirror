------------------------------------------------------------
-- Character Gear UI - Companion equipment
-- Version 0.4.5
-- API 101050
------------------------------------------------------------

CompanionGearUI = {}

local CompanionGearUI = CompanionGearUI

local EQUIPMENT_SLOT_TEXTURE =
    "CharacterGearUI/textur/slot_outline_khk.dds"
local EQUIPMENT_QUALITY_BORDER_TEXTURE =
    "CharacterGearUI/textur/equipment_quality_border.dds"
local OUTFIT_ICON_TEXTURE =
    "EsoUI/Art/Dye/dyes_tabicon_dye_down.dds"
local COSTUME_ICON_TEXTURE =
    "EsoUI/Art/Dye/dyes_tabicon_costumedye_down.dds"

local REFERENCE_SCREEN_WIDTH = 3440
local REFERENCE_SCREEN_HEIGHT = 1440
local MAX_SUPPORTED_SCREEN_WIDTH = 5120
local MAX_SUPPORTED_SCREEN_HEIGHT = 2160

local MIN_EQUIPMENT_SLOT_SIZE = 32
local MAX_EQUIPMENT_SLOT_SIZE = 128
local MIN_INDICATOR_FONT_SIZE = 10
local MAX_INDICATOR_FONT_SIZE = 30
local MIN_HEADER_SCALE = 0.5
local MAX_HEADER_SCALE = 2
local MIN_FIGURE_SCALE = 0.25
local MAX_FIGURE_SCALE = 3

local WEAPON_SLOT_HORIZONTAL_GAP = 17
local WEAPON_SLOT_GROUP_CENTER_Y = 543

local COMPANION_DEFAULTS =
{
    companionHeaderScale = 1.2,
    companionHeaderPositionX = 0,
    companionHeaderPositionY = 100,
    companionEquipmentSlotSize = 68,
    companionShowItemBorders = true,
    companionEquipmentIndicatorFontSize = 17,
    companionFigureScale = 1.2,
    companionFigurePositionX = 100,
    companionFigurePositionY = 220,
}

local COMPANION_SLOTS =
{
    {
        slotId = EQUIP_SLOT_HEAD,
        controlName =
            "ZO_CompanionCharacterWindow_Keyboard_TopLevelEquipmentSlotsHead",
        x = -575,
        y = -535,
        side = "right",
        outfitSlot = OUTFIT_SLOT_HEAD,
    },
    {
        slotId = EQUIP_SLOT_NECK,
        controlName =
            "ZO_CompanionCharacterWindow_Keyboard_TopLevelEquipmentSlotsNeck",
        x = 575,
        y = -535,
        side = "left",
    },
    {
        slotId = EQUIP_SLOT_SHOULDERS,
        controlName =
            "ZO_CompanionCharacterWindow_Keyboard_TopLevelEquipmentSlotsShoulder",
        x = -575,
        y = -335,
        side = "right",
        outfitSlot = OUTFIT_SLOT_SHOULDERS,
    },
    {
        slotId = EQUIP_SLOT_CHEST,
        controlName =
            "ZO_CompanionCharacterWindow_Keyboard_TopLevelEquipmentSlotsChest",
        x = 575,
        y = -335,
        side = "left",
        outfitSlot = OUTFIT_SLOT_CHEST,
    },
    {
        slotId = EQUIP_SLOT_HAND,
        controlName =
            "ZO_CompanionCharacterWindow_Keyboard_TopLevelEquipmentSlotsGlove",
        x = -575,
        y = -135,
        side = "right",
        outfitSlot = OUTFIT_SLOT_HANDS,
    },
    {
        slotId = EQUIP_SLOT_WAIST,
        controlName =
            "ZO_CompanionCharacterWindow_Keyboard_TopLevelEquipmentSlotsBelt",
        x = 575,
        y = -135,
        side = "left",
        outfitSlot = OUTFIT_SLOT_WAIST,
    },
    {
        slotId = EQUIP_SLOT_RING1,
        controlName =
            "ZO_CompanionCharacterWindow_Keyboard_TopLevelEquipmentSlotsRing1",
        x = -575,
        y = 65,
        side = "right",
    },
    {
        slotId = EQUIP_SLOT_RING2,
        controlName =
            "ZO_CompanionCharacterWindow_Keyboard_TopLevelEquipmentSlotsRing2",
        x = 575,
        y = 65,
        side = "left",
    },
    {
        slotId = EQUIP_SLOT_LEGS,
        controlName =
            "ZO_CompanionCharacterWindow_Keyboard_TopLevelEquipmentSlotsLeg",
        x = -575,
        y = 265,
        side = "right",
        outfitSlot = OUTFIT_SLOT_LEGS,
    },
    {
        slotId = EQUIP_SLOT_FEET,
        controlName =
            "ZO_CompanionCharacterWindow_Keyboard_TopLevelEquipmentSlotsFoot",
        x = 575,
        y = 265,
        side = "left",
        outfitSlot = OUTFIT_SLOT_FEET,
    },
    {
        slotId = EQUIP_SLOT_MAIN_HAND,
        controlName =
            "ZO_CompanionCharacterWindow_Keyboard_TopLevelEquipmentSlotsMainHand",
        weaponColumn = -1,
        y = WEAPON_SLOT_GROUP_CENTER_Y,
        side = "left",
        weaponOutfitIndex = 1,
    },
    {
        slotId = EQUIP_SLOT_OFF_HAND,
        controlName =
            "ZO_CompanionCharacterWindow_Keyboard_TopLevelEquipmentSlotsOffHand",
        weaponColumn = 1,
        y = WEAPON_SLOT_GROUP_CENTER_Y,
        side = "right",
        weaponOutfitIndex = 2,
    },
}

local WEAPON_SLOTS =
{
    [EQUIP_SLOT_MAIN_HAND] = true,
    [EQUIP_SLOT_OFF_HAND] = true,
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

local function GetLayoutScale()

    local screenWidth, screenHeight = GuiRoot:GetDimensions()

    return math.min(
        screenWidth / REFERENCE_SCREEN_WIDTH,
        screenHeight / REFERENCE_SCREEN_HEIGHT
    )

end

local function GetCenteredCompanionFramingTarget()

    local screenWidth, screenHeight = GuiRoot:GetDimensions()

    return screenWidth * 0.5, screenHeight * 0.55

end

local function ClampNumber(value, defaultValue, minimum, maximum)

    return zo_clamp(
        tonumber(value) or defaultValue,
        minimum,
        maximum
    )

end

local function GetSlotControl(slotData)

    return _G[slotData.controlName]

end

local function AnchorSlot(control, x, y, size, layoutScale)

    if not control then
        return
    end

    control:SetScale(1)
    control:ClearAnchors()
    control:SetAnchor(
        CENTER,
        GuiRoot,
        CENTER,
        x * layoutScale,
        y * layoutScale
    )

    local scaledSize = size * layoutScale
    control:SetDimensions(scaledSize, scaledSize)

end

local function AddSlotOutline(slotControl)

    if not slotControl then
        return
    end

    slotControl:SetNormalTexture()
    slotControl:SetPressedTexture()
    slotControl:SetDisabledTexture()
    slotControl:SetDisabledPressedTexture()

    local background =
        slotControl.CompanionGearUIBackground

    if not background then

        background = WINDOW_MANAGER:CreateControl(
            slotControl:GetName()
                .. "CompanionGearUIBackground",
            slotControl,
            CT_TEXTURE
        )
        background:SetDrawLayer(DL_BACKGROUND)
        background:SetDrawLevel(0)
        background:SetMouseEnabled(false)

        slotControl.CompanionGearUIBackground = background

    end

    background:ClearAnchors()
    background:SetAnchor(TOPLEFT, slotControl, TOPLEFT)
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
        icon:SetColor(1, 1, 1, 1)
    end

end

local function CreateQualityBorder(slotControl)

    local border =
        slotControl.CompanionGearUIQualityBorder

    if not border then

        border = WINDOW_MANAGER:CreateControl(
            slotControl:GetName()
                .. "CompanionGearUIQualityBorder",
            slotControl,
            CT_TEXTURE
        )
        border:SetTexture(
            EQUIPMENT_QUALITY_BORDER_TEXTURE
        )
        border:SetDrawLayer(DL_OVERLAY)
        border:SetDrawLevel(3)
        border:SetMouseEnabled(false)

        slotControl.CompanionGearUIQualityBorder = border

    end

    border:ClearAnchors()
    border:SetAnchor(TOPLEFT, slotControl, TOPLEFT)
    border:SetAnchor(
        BOTTOMRIGHT,
        slotControl,
        BOTTOMRIGHT
    )

    return border

end

local function CreateItemDetailControls(slotControl)

    local nameLabel =
        slotControl.CompanionGearUIItemNameLabel

    if not nameLabel then

        nameLabel = WINDOW_MANAGER:CreateControl(
            slotControl:GetName()
                .. "CompanionGearUIItemNameLabel",
            slotControl,
            CT_LABEL
        )
        nameLabel:SetDrawLayer(DL_OVERLAY)
        nameLabel:SetDrawLevel(6)
        nameLabel:SetMouseEnabled(false)
        nameLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)

        slotControl.CompanionGearUIItemNameLabel = nameLabel

    end

    local typeLabel =
        slotControl.CompanionGearUITypeLabel

    if not typeLabel then

        typeLabel = WINDOW_MANAGER:CreateControl(
            slotControl:GetName()
                .. "CompanionGearUITypeLabel",
            slotControl,
            CT_LABEL
        )
        typeLabel:SetDrawLayer(DL_OVERLAY)
        typeLabel:SetDrawLevel(6)
        typeLabel:SetMouseEnabled(false)
        typeLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        typeLabel:SetColor(1, 1, 1, 1)

        slotControl.CompanionGearUITypeLabel = typeLabel

    end

    local outfitIcon =
        slotControl.CompanionGearUIOutfitIcon

    if not outfitIcon then

        outfitIcon = WINDOW_MANAGER:CreateControl(
            slotControl:GetName()
                .. "CompanionGearUIOutfitIcon",
            slotControl,
            CT_TEXTURE
        )
        outfitIcon:SetTexture(OUTFIT_ICON_TEXTURE)
        outfitIcon:SetDrawLayer(DL_OVERLAY)
        outfitIcon:SetDrawLevel(6)
        outfitIcon:SetMouseEnabled(false)

        slotControl.CompanionGearUIOutfitIcon = outfitIcon

    end

    local costumeIcon =
        slotControl.CompanionGearUICostumeIcon

    if not costumeIcon then

        costumeIcon = WINDOW_MANAGER:CreateControl(
            slotControl:GetName()
                .. "CompanionGearUICostumeIcon",
            slotControl,
            CT_TEXTURE
        )
        costumeIcon:SetTexture(COSTUME_ICON_TEXTURE)
        costumeIcon:SetDrawLayer(DL_OVERLAY)
        costumeIcon:SetDrawLevel(6)
        costumeIcon:SetMouseEnabled(false)

        slotControl.CompanionGearUICostumeIcon = costumeIcon

    end

    return nameLabel, typeLabel, outfitIcon, costumeIcon

end

local function HideItemDetailControls(
    nameLabel,
    typeLabel,
    outfitIcon,
    costumeIcon
)

    nameLabel:SetHidden(true)
    typeLabel:SetHidden(true)
    outfitIcon:SetHidden(true)
    costumeIcon:SetHidden(true)

end

local function GetItemTypeText(itemLink, slotId)

    local equipType = GetItemLinkEquipType(itemLink)

    if WEAPON_SLOTS[slotId] then

        local weaponType = GetItemLinkWeaponType(itemLink)

        if weaponType and weaponType ~= WEAPONTYPE_NONE then
            return string.format(
                "%s %s",
                GetString("SI_EQUIPTYPE", equipType),
                GetString("SI_WEAPONTYPE", weaponType)
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

local function HasOutfitStyleOverride(outfitSlot)

    if not outfitSlot
        or not GetEquippedOutfitIndex
        or not GetOutfitSlotInfo
    then
        return false
    end

    local actorCategory =
        GAMEPLAY_ACTOR_CATEGORY_COMPANION
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

    return collectibleId ~= nil and collectibleId > 0

end

local function GetDetailOutfitSlot(
    slotData,
    weaponOutfitSlots
)

    if slotData.outfitSlot then
        return slotData.outfitSlot
    end

    if slotData.weaponOutfitIndex then
        return weaponOutfitSlots[
            slotData.weaponOutfitIndex
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

function CompanionGearUI:AddDefaults(defaults)

    for key, value in pairs(COMPANION_DEFAULTS) do
        defaults[key] = value
    end

end

function CompanionGearUI:NormalizeSavedVariables()

    local saved = self.saved

    saved.companionHeaderScale = ClampNumber(
        saved.companionHeaderScale,
        COMPANION_DEFAULTS.companionHeaderScale,
        MIN_HEADER_SCALE,
        MAX_HEADER_SCALE
    )
    saved.companionHeaderPositionX = ClampNumber(
        saved.companionHeaderPositionX,
        COMPANION_DEFAULTS.companionHeaderPositionX,
        0,
        MAX_SUPPORTED_SCREEN_WIDTH
    )
    saved.companionHeaderPositionY = ClampNumber(
        saved.companionHeaderPositionY,
        COMPANION_DEFAULTS.companionHeaderPositionY,
        0,
        MAX_SUPPORTED_SCREEN_HEIGHT
    )
    saved.companionEquipmentSlotSize = ClampNumber(
        saved.companionEquipmentSlotSize,
        COMPANION_DEFAULTS.companionEquipmentSlotSize,
        MIN_EQUIPMENT_SLOT_SIZE,
        MAX_EQUIPMENT_SLOT_SIZE
    )
    saved.companionEquipmentIndicatorFontSize =
        ClampNumber(
            saved.companionEquipmentIndicatorFontSize,
            COMPANION_DEFAULTS
                .companionEquipmentIndicatorFontSize,
            MIN_INDICATOR_FONT_SIZE,
            MAX_INDICATOR_FONT_SIZE
        )
    saved.companionFigureScale = ClampNumber(
        saved.companionFigureScale,
        COMPANION_DEFAULTS.companionFigureScale,
        MIN_FIGURE_SCALE,
        MAX_FIGURE_SCALE
    )
    saved.companionFigurePositionX = ClampNumber(
        saved.companionFigurePositionX,
        COMPANION_DEFAULTS.companionFigurePositionX,
        0,
        MAX_SUPPORTED_SCREEN_WIDTH
    )
    saved.companionFigurePositionY = ClampNumber(
        saved.companionFigurePositionY,
        COMPANION_DEFAULTS.companionFigurePositionY,
        0,
        MAX_SUPPORTED_SCREEN_HEIGHT
    )
    -- Older versions stored a companion camera-distance value. ESO only
    -- exposes target positioning for interaction cameras, not zoom.
    saved.companionCharacterDistance = nil

end

function CompanionGearUI:RemoveWindowBackground()

    local scene = COMPANION_CHARACTER_KEYBOARD_SCENE

    if scene and THIN_LEFT_PANEL_BG_FRAGMENT then
        scene:RemoveFragment(THIN_LEFT_PANEL_BG_FRAGMENT)
    end

    if ZO_SharedThinLeftPanelBackground then
        ZO_SharedThinLeftPanelBackground:SetHidden(true)
    end

    local control =
        ZO_CompanionCharacterWindow_Keyboard_TopLevel

    if control and control.PP_BG then
        control.PP_BG:SetHidden(true)
    end

end

function CompanionGearUI:ApplyHeaderLayout(layoutScale)

    local saved = self.saved
    local headerScale = ClampNumber(
        saved.companionHeaderScale,
        COMPANION_DEFAULTS.companionHeaderScale,
        MIN_HEADER_SCALE,
        MAX_HEADER_SCALE
    )
    local positionX = ClampNumber(
        saved.companionHeaderPositionX,
        COMPANION_DEFAULTS.companionHeaderPositionX,
        0,
        MAX_SUPPORTED_SCREEN_WIDTH
    )
    local positionY = ClampNumber(
        saved.companionHeaderPositionY,
        COMPANION_DEFAULTS.companionHeaderPositionY,
        0,
        MAX_SUPPORTED_SCREEN_HEIGHT
    )
    local scale = headerScale * layoutScale
    local baseX = positionX * layoutScale
    local baseY = positionY * layoutScale
    local title =
        ZO_CompanionCharacterWindow_Keyboard_TopLevelTitle
    local divider =
        ZO_CompanionCharacterWindow_Keyboard_TopLevelHeaderDivider
    local apparelText =
        ZO_CompanionCharacterWindow_Keyboard_TopLevelApparelSectionText

    if title then
        title:SetScale(scale)
        title:ClearAnchors()
        title:SetAnchor(
            TOPLEFT,
            GuiRoot,
            TOPLEFT,
            baseX + 14 * scale,
            baseY + 26 * scale
        )
        title:SetHidden(false)
    end

    if divider then
        divider:SetScale(1)
        divider:SetDimensions(300 * scale, 4 * scale)
        divider:ClearAnchors()
        divider:SetAnchor(
            TOPLEFT,
            GuiRoot,
            TOPLEFT,
            baseX,
            baseY + 63 * scale
        )
        divider:SetHidden(false)
    end

    if apparelText then

        local hidden = IsEquipSlotVisualCategoryHidden(
            EQUIP_SLOT_VISUAL_CATEGORY_APPAREL,
            GAMEPLAY_ACTOR_CATEGORY_COMPANION
        )
        local text = hidden
            and GetString(SI_CHARACTER_EQUIP_APPAREL_HIDDEN)
            or GetString(
                "SI_EQUIPSLOTVISUALCATEGORY",
                EQUIP_SLOT_VISUAL_CATEGORY_APPAREL
            )

        apparelText:SetText(text)
        apparelText:SetScale(scale)
        apparelText:ClearAnchors()
        apparelText:SetAnchor(
            TOPLEFT,
            GuiRoot,
            TOPLEFT,
            baseX + 14 * scale,
            baseY + 72 * scale
        )
        apparelText:SetHidden(false)

    end

end


function CompanionGearUI:ApplyFigureLayout(layoutScale)

    local figure =
        ZO_CompanionCharacterWindow_Keyboard_TopLevelPaperDoll

    if not figure then
        return
    end

    -- ESO already assigns the correct silhouette to this PaperDoll
    -- control whenever the active companion changes. Reuse that texture
    -- because the race lookup used by some ESO UI versions is not exposed
    -- to addons as a global API function.

    local scale = ClampNumber(
        self.saved.companionFigureScale,
        COMPANION_DEFAULTS.companionFigureScale,
        MIN_FIGURE_SCALE,
        MAX_FIGURE_SCALE
    )
    local positionX = ClampNumber(
        self.saved.companionFigurePositionX,
        COMPANION_DEFAULTS.companionFigurePositionX,
        0,
        MAX_SUPPORTED_SCREEN_WIDTH
    )
    local positionY = ClampNumber(
        self.saved.companionFigurePositionY,
        COMPANION_DEFAULTS.companionFigurePositionY,
        0,
        MAX_SUPPORTED_SCREEN_HEIGHT
    )

    figure:SetDimensions(64, 256)
    figure:SetScale(scale * layoutScale)
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

function CompanionGearUI:ApplyEquipmentLayout()

    if not self.saved then
        return
    end

    local control =
        ZO_CompanionCharacterWindow_Keyboard_TopLevel

    if not control then
        return
    end

    local layoutScale = GetLayoutScale()
    local slotSize = ClampNumber(
        self.saved.companionEquipmentSlotSize,
        COMPANION_DEFAULTS.companionEquipmentSlotSize,
        MIN_EQUIPMENT_SLOT_SIZE,
        MAX_EQUIPMENT_SLOT_SIZE
    )

    control:SetScale(1)
    control:ClearAnchors()
    control:SetAnchor(CENTER, GuiRoot, CENTER)
    control:SetDimensions(1, 1)
    control:SetMouseEnabled(false)

    self:RemoveWindowBackground()
    self:ApplyHeaderLayout(layoutScale)
    self:ApplyFigureLayout(layoutScale)

    local accessories =
        ZO_CompanionCharacterWindow_Keyboard_TopLevelAccessoriesSection
    local weapons =
        ZO_CompanionCharacterWindow_Keyboard_TopLevelWeaponsSection

    if accessories then
        accessories:SetHidden(true)
    end

    if weapons then
        weapons:SetHidden(true)
    end

    local weaponColumnOffset =
        slotSize + WEAPON_SLOT_HORIZONTAL_GAP

    for _, slotData in ipairs(COMPANION_SLOTS) do

        local slotControl = GetSlotControl(slotData)
        local positionX = slotData.x

        if slotData.weaponColumn then
            positionX =
                slotData.weaponColumn * weaponColumnOffset
        end

        AnchorSlot(
            slotControl,
            positionX,
            slotData.y,
            slotSize,
            layoutScale
        )
        AddSlotOutline(slotControl)

    end

    self:RefreshEquipmentDetails()

end

function CompanionGearUI:GetAppearanceState()

    local actorCategory =
        GAMEPLAY_ACTOR_CATEGORY_COMPANION
    local state =
    {
        hasCostume = false,
        hasHat = false,
    }

    if HasActiveCompanion
        and not HasActiveCompanion()
    then
        return state
    end

    if GetActiveCollectibleByType then

        state.hasCostume =
            GetActiveCollectibleByType(
                COLLECTIBLE_CATEGORY_TYPE_COSTUME,
                actorCategory
            ) > 0
        state.hasHat =
            GetActiveCollectibleByType(
                COLLECTIBLE_CATEGORY_TYPE_HAT,
                actorCategory
            ) > 0

    end

    return state

end

function CompanionGearUI:RefreshSingleSlotDetail(
    slotData,
    weaponOutfitSlots,
    appearanceState
)

    local slotControl = GetSlotControl(slotData)

    if not slotControl then
        return
    end

    local border = CreateQualityBorder(slotControl)
    local nameLabel,
        typeLabel,
        outfitIcon,
        costumeIcon =
            CreateItemDetailControls(slotControl)
    local itemName = GetItemName(
        BAG_COMPANION_WORN,
        slotData.slotId
    )
    local hasItem = itemName and itemName ~= ""

    if not hasItem then
        border:SetHidden(true)
        HideItemDetailControls(
            nameLabel,
            typeLabel,
            outfitIcon,
            costumeIcon
        )
        return
    end

    if self.saved.companionShowItemBorders then

        local quality = GetItemDisplayQuality(
            BAG_COMPANION_WORN,
            slotData.slotId
        )
        local color = GetItemQualityColor(quality)

        border:SetColor(color:UnpackRGBA())
        border:SetHidden(false)

    else

        border:SetHidden(true)

    end

    local fontSize = ClampNumber(
        self.saved.companionEquipmentIndicatorFontSize,
        COMPANION_DEFAULTS
            .companionEquipmentIndicatorFontSize,
        MIN_INDICATOR_FONT_SIZE,
        MAX_INDICATOR_FONT_SIZE
    )
    local typeFontSize = math.max(
        MIN_INDICATOR_FONT_SIZE,
        fontSize - 2
    )
    local nameFont = string.format(
        "$(BOLD_FONT)|%d|soft-shadow-thick",
        fontSize
    )
    local typeFont = string.format(
        "$(BOLD_FONT)|%d|soft-shadow-thick",
        typeFontSize
    )

    nameLabel:SetFont(nameFont)
    nameLabel:SetDimensions(360, fontSize + 8)
    nameLabel:ClearAnchors()

    if slotData.side == "left" then
        nameLabel:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
        nameLabel:SetAnchor(
            TOPRIGHT,
            slotControl,
            TOPLEFT,
            -10,
            2
        )
    else
        nameLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        nameLabel:SetAnchor(
            TOPLEFT,
            slotControl,
            TOPRIGHT,
            10,
            2
        )
    end

    nameLabel:SetText(
        zo_strformat(SI_TOOLTIP_ITEM_NAME, itemName)
    )

    local quality = GetItemDisplayQuality(
        BAG_COMPANION_WORN,
        slotData.slotId
    )
    local qualityColor = GetItemQualityColor(quality)

    nameLabel:SetColor(qualityColor:UnpackRGBA())
    nameLabel:SetHidden(false)

    local itemLink = GetItemLink(
        BAG_COMPANION_WORN,
        slotData.slotId,
        LINK_STYLE_DEFAULT
    )
    local typeText = GetItemTypeText(
        itemLink,
        slotData.slotId
    )

    if typeText == "" then
        typeLabel:SetHidden(true)
        outfitIcon:SetHidden(true)
        costumeIcon:SetHidden(true)
        return
    end

    typeLabel:SetFont(typeFont)
    typeLabel:SetDimensions(420, typeFontSize + 8)
    typeLabel:ClearAnchors()

    if slotData.side == "left" then
        typeLabel:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
        typeLabel:SetAnchor(
            TOPRIGHT,
            nameLabel,
            BOTTOMRIGHT,
            0,
            -2
        )
    else
        typeLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        typeLabel:SetAnchor(
            TOPLEFT,
            nameLabel,
            BOTTOMLEFT,
            0,
            -2
        )
    end

    typeLabel:SetText(typeText)
    typeLabel:SetHidden(false)

    local outfitSlot = GetDetailOutfitSlot(
        slotData,
        weaponOutfitSlots
    )
    local showOutfitIcon =
        HasOutfitStyleOverride(outfitSlot)
    local showCostumeIcon =
        HasCostumeAppearanceOverride(
            slotData.slotId,
            appearanceState
        )
    local iconSize = fontSize + 8
    local textWidth = typeLabel:GetTextWidth()
    local costumeOffset = textWidth + 8

    if showOutfitIcon then
        costumeOffset = costumeOffset + iconSize + 4
    end

    outfitIcon:SetDimensions(iconSize, iconSize)
    costumeIcon:SetDimensions(iconSize, iconSize)
    outfitIcon:ClearAnchors()
    costumeIcon:ClearAnchors()

    if slotData.side == "left" then
        outfitIcon:SetAnchor(
            RIGHT,
            typeLabel,
            RIGHT,
            -textWidth - 8,
            0
        )
        costumeIcon:SetAnchor(
            RIGHT,
            typeLabel,
            RIGHT,
            -costumeOffset,
            0
        )
    else
        outfitIcon:SetAnchor(
            LEFT,
            typeLabel,
            LEFT,
            textWidth + 8,
            0
        )
        costumeIcon:SetAnchor(
            LEFT,
            typeLabel,
            LEFT,
            costumeOffset,
            0
        )
    end

    outfitIcon:SetHidden(not showOutfitIcon)
    costumeIcon:SetHidden(not showCostumeIcon)

end

function CompanionGearUI:RefreshEquipmentDetails()

    if not self.saved then
        return
    end

    local weaponOutfitSlots = {}

    if GetOutfitSlotsForEquippedWeapons
        and (
            not HasActiveCompanion
            or HasActiveCompanion()
        )
    then
        weaponOutfitSlots =
        {
            GetOutfitSlotsForEquippedWeapons(
                GAMEPLAY_ACTOR_CATEGORY_COMPANION
            )
        }
    end

    local appearanceState = self:GetAppearanceState()

    for _, slotData in ipairs(COMPANION_SLOTS) do
        self:RefreshSingleSlotDetail(
            slotData,
            weaponOutfitSlots,
            appearanceState
        )
    end

end

function CompanionGearUI:IsSceneShowing()

    return COMPANION_CHARACTER_KEYBOARD_SCENE
        and COMPANION_CHARACTER_KEYBOARD_SCENE:IsShowing()

end

function CompanionGearUI:ApplyAll()

    self:ApplyEquipmentLayout()

end

function CompanionGearUI:ResetSettingsToDefaults()

    if not self.saved then
        return
    end

    for key, value in pairs(COMPANION_DEFAULTS) do
        self.saved[key] = value
    end

    self:NormalizeSavedVariables()
    self:ApplyAll()

    if self.host and self.host.settingsPanel then
        CALLBACK_MANAGER:FireCallbacks(
            "LAM-RefreshPanel",
            self.host.settingsPanel
        )
    end

end

function CompanionGearUI:RegisterEvents()

    if self.eventsRegistered then
        return
    end

    self.eventsRegistered = true

    local namespace = "CharacterGearUICompanion"

    local function RefreshDetailsIfVisible()

        if self:IsSceneShowing() then
            self:RefreshEquipmentDetails()
        end

    end

    local function RefreshLayoutIfVisible()

        if self:IsSceneShowing() then
            self:ApplyEquipmentLayout()
        end

    end

    EVENT_MANAGER:RegisterForEvent(
        namespace .. "Inventory",
        EVENT_INVENTORY_SINGLE_SLOT_UPDATE,
        RefreshDetailsIfVisible
    )
    EVENT_MANAGER:AddFilterForEvent(
        namespace .. "Inventory",
        EVENT_INVENTORY_SINGLE_SLOT_UPDATE,
        REGISTER_FILTER_BAG_ID,
        BAG_COMPANION_WORN
    )
    EVENT_MANAGER:RegisterForEvent(
        namespace .. "InventoryFull",
        EVENT_INVENTORY_FULL_UPDATE,
        RefreshDetailsIfVisible
    )
    EVENT_MANAGER:RegisterForEvent(
        namespace .. "ActiveCompanion",
        EVENT_ACTIVE_COMPANION_STATE_CHANGED,
        RefreshLayoutIfVisible
    )
    EVENT_MANAGER:RegisterForEvent(
        namespace .. "OutfitChanged",
        EVENT_OUTFIT_CHANGE_RESPONSE,
        RefreshDetailsIfVisible
    )
    EVENT_MANAGER:RegisterForEvent(
        namespace .. "OutfitEquipped",
        EVENT_OUTFIT_EQUIP_RESPONSE,
        RefreshDetailsIfVisible
    )
    EVENT_MANAGER:RegisterForEvent(
        namespace .. "OutfitsInitialized",
        EVENT_OUTFITS_INITIALIZED,
        RefreshDetailsIfVisible
    )
    EVENT_MANAGER:RegisterForEvent(
        namespace .. "CollectibleUpdated",
        EVENT_COLLECTIBLE_UPDATED,
        RefreshDetailsIfVisible
    )

end

function CompanionGearUI:SetupScene()

    if self.sceneSetup
        or not COMPANION_CHARACTER_KEYBOARD_SCENE
    then
        return
    end

    self.sceneSetup = true
    self:RemoveWindowBackground()

    local scene = COMPANION_CHARACTER_KEYBOARD_SCENE

    if FRAME_INTERACTION_STANDARD_RIGHT_PANEL_MEDIUM_LEFT_PANEL_FRAGMENT then
        scene:RemoveFragment(
            FRAME_INTERACTION_STANDARD_RIGHT_PANEL_MEDIUM_LEFT_PANEL_FRAGMENT
        )
    end

    if ZO_InteractionFramingFragment then
        self.centeredFramingFragment =
            ZO_InteractionFramingFragment:New(
                GetCenteredCompanionFramingTarget
            )
        scene:AddFragment(self.centeredFramingFragment)
    end

    scene:RegisterCallback(
        "StateChange",
        function(oldState, newState)

            if newState == SCENE_SHOWING
                or newState == SCENE_SHOWN
            then

                self:ApplyAll()

                zo_callLater(function()
                    if self:IsSceneShowing() then
                        self:ApplyAll()
                    end
                end, 100)

            end

        end
    )

    if COMPANION_WINDOW_KEYBOARD
        and ZO_PostHook
    then
        ZO_PostHook(
            COMPANION_WINDOW_KEYBOARD,
            "RefreshWornInventory",
            function()
                if self:IsSceneShowing() then
                    self:RefreshEquipmentDetails()
                end
            end
        )
    end

end

local function CreateSectionHeader()

    return
    {
        type = "header",
        name = GetString(
            SI_CHARACTER_GEAR_UI_COMPANION_SECTION
        ),
        width = "full",
    }

end

function CompanionGearUI:CreateSettingsControls()

    local saved = self.saved

    return
    {
        info =
        {
            {
                type = "description",
                text =
                    "|cFFFF00/cogui reset|r  "
                    .. GetString(
                        SI_CHARACTER_GEAR_UI_INFO_COMMAND_COMPANION_RESET
                    ),
                width = "full",
            },
        },
        header =
        {
            CreateSectionHeader(),
            {
                type = "slider",
                name = GetString(
                    SI_CHARACTER_GEAR_UI_COMPANION_HEADER_SCALE
                ),
                tooltip = GetString(
                    SI_CHARACTER_GEAR_UI_COMPANION_HEADER_SCALE_TOOLTIP
                ),
                min = MIN_HEADER_SCALE * 100,
                max = MAX_HEADER_SCALE * 100,
                step = 1,
                default =
                    COMPANION_DEFAULTS.companionHeaderScale
                    * 100,
                getFunc = function()
                    return math.floor(
                        saved.companionHeaderScale * 100 + 0.5
                    )
                end,
                setFunc = function(value)
                    saved.companionHeaderScale = value / 100
                    self:ApplyEquipmentLayout()
                end,
                width = "full",
            },
            {
                type = "slider",
                name = GetString(
                    SI_CHARACTER_GEAR_UI_COMPANION_HEADER_POSITION_X
                ),
                tooltip = GetString(
                    SI_CHARACTER_GEAR_UI_COMPANION_HEADER_POSITION_X_TOOLTIP
                ),
                min = 0,
                max = MAX_SUPPORTED_SCREEN_WIDTH,
                step = 1,
                default =
                    COMPANION_DEFAULTS.companionHeaderPositionX,
                getFunc = function()
                    return saved.companionHeaderPositionX
                end,
                setFunc = function(value)
                    saved.companionHeaderPositionX = value
                    self:ApplyEquipmentLayout()
                end,
                width = "full",
            },
            {
                type = "slider",
                name = GetString(
                    SI_CHARACTER_GEAR_UI_COMPANION_HEADER_POSITION_Y
                ),
                tooltip = GetString(
                    SI_CHARACTER_GEAR_UI_COMPANION_HEADER_POSITION_Y_TOOLTIP
                ),
                min = 0,
                max = MAX_SUPPORTED_SCREEN_HEIGHT,
                step = 1,
                default =
                    COMPANION_DEFAULTS.companionHeaderPositionY,
                getFunc = function()
                    return saved.companionHeaderPositionY
                end,
                setFunc = function(value)
                    saved.companionHeaderPositionY = value
                    self:ApplyEquipmentLayout()
                end,
                width = "full",
            },
        },
        slots =
        {
            CreateSectionHeader(),
            {
                type = "slider",
                name = GetString(
                    SI_CHARACTER_GEAR_UI_COMPANION_SLOT_SIZE
                ),
                tooltip = GetString(
                    SI_CHARACTER_GEAR_UI_COMPANION_SLOT_SIZE_TOOLTIP
                ),
                min = MIN_EQUIPMENT_SLOT_SIZE,
                max = MAX_EQUIPMENT_SLOT_SIZE,
                step = 1,
                default =
                    COMPANION_DEFAULTS.companionEquipmentSlotSize,
                getFunc = function()
                    return saved.companionEquipmentSlotSize
                end,
                setFunc = function(value)
                    saved.companionEquipmentSlotSize = value
                    self:ApplyEquipmentLayout()
                end,
                width = "full",
            },
        },
        borders =
        {
            CreateSectionHeader(),
            {
                type = "checkbox",
                name = GetString(
                    SI_CHARACTER_GEAR_UI_COMPANION_SHOW_ITEM_BORDERS
                ),
                tooltip = GetString(
                    SI_CHARACTER_GEAR_UI_COMPANION_SHOW_ITEM_BORDERS_TOOLTIP
                ),
                default =
                    COMPANION_DEFAULTS.companionShowItemBorders,
                getFunc = function()
                    return saved.companionShowItemBorders
                end,
                setFunc = function(value)
                    saved.companionShowItemBorders = value
                    self:RefreshEquipmentDetails()
                end,
                width = "full",
            },
            {
                type = "slider",
                name = GetString(
                    SI_CHARACTER_GEAR_UI_COMPANION_FONT_SIZE
                ),
                tooltip = GetString(
                    SI_CHARACTER_GEAR_UI_COMPANION_FONT_SIZE_TOOLTIP
                ),
                min = MIN_INDICATOR_FONT_SIZE,
                max = MAX_INDICATOR_FONT_SIZE,
                step = 1,
                default = COMPANION_DEFAULTS
                    .companionEquipmentIndicatorFontSize,
                getFunc = function()
                    return saved
                        .companionEquipmentIndicatorFontSize
                end,
                setFunc = function(value)
                    saved.companionEquipmentIndicatorFontSize =
                        value
                    self:RefreshEquipmentDetails()
                end,
                width = "full",
            },
        },
        figure =
        {
            CreateSectionHeader(),
            {
                type = "slider",
                name = GetString(
                    SI_CHARACTER_GEAR_UI_COMPANION_FIGURE_SCALE
                ),
                tooltip = GetString(
                    SI_CHARACTER_GEAR_UI_COMPANION_FIGURE_SCALE_TOOLTIP
                ),
                min = MIN_FIGURE_SCALE * 100,
                max = MAX_FIGURE_SCALE * 100,
                step = 1,
                default =
                    COMPANION_DEFAULTS.companionFigureScale
                    * 100,
                getFunc = function()
                    return math.floor(
                        saved.companionFigureScale * 100 + 0.5
                    )
                end,
                setFunc = function(value)
                    saved.companionFigureScale = value / 100
                    self:ApplyEquipmentLayout()
                end,
                width = "full",
            },
            {
                type = "slider",
                name = GetString(
                    SI_CHARACTER_GEAR_UI_COMPANION_FIGURE_POSITION_X
                ),
                tooltip = GetString(
                    SI_CHARACTER_GEAR_UI_COMPANION_FIGURE_POSITION_X_TOOLTIP
                ),
                min = 0,
                max = MAX_SUPPORTED_SCREEN_WIDTH,
                step = 1,
                default =
                    COMPANION_DEFAULTS.companionFigurePositionX,
                getFunc = function()
                    return saved.companionFigurePositionX
                end,
                setFunc = function(value)
                    saved.companionFigurePositionX = value
                    self:ApplyEquipmentLayout()
                end,
                width = "full",
            },
            {
                type = "slider",
                name = GetString(
                    SI_CHARACTER_GEAR_UI_COMPANION_FIGURE_POSITION_Y
                ),
                tooltip = GetString(
                    SI_CHARACTER_GEAR_UI_COMPANION_FIGURE_POSITION_Y_TOOLTIP
                ),
                min = 0,
                max = MAX_SUPPORTED_SCREEN_HEIGHT,
                step = 1,
                default =
                    COMPANION_DEFAULTS.companionFigurePositionY,
                getFunc = function()
                    return saved.companionFigurePositionY
                end,
                setFunc = function(value)
                    saved.companionFigurePositionY = value
                    self:ApplyEquipmentLayout()
                end,
                width = "full",
            },
        },
        character =
        {
            CreateSectionHeader(),
            {
                type = "description",
                text = GetString(
                    SI_CHARACTER_GEAR_UI_COMPANION_DISTANCE_TOOLTIP
                ),
                width = "full",
            },
        },
    }

end

function CompanionGearUI:Initialize(host)

    self.host = host
    self.saved = host.saved

    self:NormalizeSavedVariables()
    self:RegisterEvents()
    self:SetupScene()
    self:ApplyEquipmentLayout()

    zo_callLater(function()
        self:SetupScene()
        self:ApplyEquipmentLayout()
    end, 1000)

end

SLASH_COMMANDS["/cogui"] = function(text)

    local command = string.lower(text or "")
    command = command:match("^%s*(.-)%s*$")

    if command == "reset" then
        CompanionGearUI:ResetSettingsToDefaults()
    else
        d("CharacterGearUI: /cogui reset")
    end

end
