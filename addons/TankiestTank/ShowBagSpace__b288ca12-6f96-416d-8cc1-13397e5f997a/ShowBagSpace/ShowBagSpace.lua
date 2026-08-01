local SBS = {}

SBS.name = "ShowBagSpace"

SBS.defaults = {
    layoutVersion = 34,

    showHud = true,
    hideHudInMenus = true,
    showBagIcon = true,

    hudX = 1750,
    hudY = 470,

    showBox = false,
    boxOffsetX = 0,
    boxOffsetY = 0,
    boxWidth = 145,
    boxHeight = 125,
    boxOpacity = 100,

    countOffsetX = 35,
    countOffsetY = 30,
    countScale = 8,

    iconOffsetX = -25,
    iconOffsetY = 5,
    iconSize = 56,

    boxR = 0,
    boxG = 0,
    boxB = 0,
    boxA = 1,

    textR = 1,
    textG = 1,
    textB = 1,
    textA = 1,

    iconR = 1,
    iconG = 1,
    iconB = 1,
    iconA = 1,
}

SBS.inMenu = false

local COUNT_LABEL_WIDTH = 400
local COUNT_LABEL_HEIGHT = 40

local function ApplyMissingDefaults()
    for key, value in pairs(SBS.defaults) do
        if SBS.saved[key] == nil then
            SBS.saved[key] = value
        end
    end

    if SBS.saved.layoutVersion ~= SBS.defaults.layoutVersion then
        SBS.saved.layoutVersion = SBS.defaults.layoutVersion

        SBS.saved.hudX = SBS.defaults.hudX
        SBS.saved.hudY = SBS.defaults.hudY

        SBS.saved.showBox = SBS.defaults.showBox
        SBS.saved.boxOffsetX = SBS.defaults.boxOffsetX
        SBS.saved.boxOffsetY = SBS.defaults.boxOffsetY
        SBS.saved.boxWidth = SBS.defaults.boxWidth
        SBS.saved.boxHeight = SBS.defaults.boxHeight
        SBS.saved.boxOpacity = SBS.defaults.boxOpacity

        SBS.saved.countOffsetX = SBS.defaults.countOffsetX
        SBS.saved.countOffsetY = SBS.defaults.countOffsetY
        SBS.saved.countScale = SBS.defaults.countScale

        SBS.saved.iconOffsetX = SBS.defaults.iconOffsetX
        SBS.saved.iconOffsetY = SBS.defaults.iconOffsetY
        SBS.saved.iconSize = SBS.defaults.iconSize
    end
end

local function IsInMenu()
    if SCENE_MANAGER and SCENE_MANAGER.GetCurrentScene then
        local scene = SCENE_MANAGER:GetCurrentScene()
        if scene and scene.GetName then
            local name = scene:GetName()
            return name ~= "hud" and name ~= "hudui"
        end
    end
    return false
end

local function GetBagUsed()
    if GetNumBagUsedSlots then
        return GetNumBagUsedSlots(BAG_BACKPACK) or 0
    end
    return 0
end

local function GetBagMax()
    if GetBagSize then
        return GetBagSize(BAG_BACKPACK) or 0
    end
    return 0
end

local function SetCountLabelPosition(label, x, y)
    label:ClearAnchors()
    label:SetAnchor(TOPLEFT, SBS.window, TOPLEFT, x, y)
    label:SetDimensions(COUNT_LABEL_WIDTH, COUNT_LABEL_HEIGHT)
    label:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    label:SetVerticalAlignment(TEXT_ALIGN_TOP)
end

local function UpdateDisplay()
    if not SBS.window then return end

    SBS.inMenu = IsInMenu()

    local shouldHide = not SBS.saved.showHud
    if SBS.saved.hideHudInMenus and SBS.inMenu then
        shouldHide = true
    end

    SBS.window:SetHidden(shouldHide)

    SBS.window:ClearAnchors()
    SBS.window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, SBS.saved.hudX, SBS.saved.hudY)
    SBS.window:SetDimensions(2200, 1200)

    SBS.box:ClearAnchors()
    SBS.box:SetAnchor(TOPLEFT, SBS.window, TOPLEFT, SBS.saved.boxOffsetX, SBS.saved.boxOffsetY)
    SBS.box:SetDimensions(SBS.saved.boxWidth, SBS.saved.boxHeight)
    SBS.box:SetHidden(not SBS.saved.showBox)
    SBS.box:SetCenterColor(SBS.saved.boxR, SBS.saved.boxG, SBS.saved.boxB, SBS.saved.boxOpacity / 100)
    SBS.box:SetEdgeColor(1, 1, 1, 1)

    SBS.icon:ClearAnchors()
    SBS.icon:SetAnchor(TOPLEFT, SBS.window, TOPLEFT, SBS.saved.iconOffsetX, SBS.saved.iconOffsetY)
    SBS.icon:SetDimensions(SBS.saved.iconSize, SBS.saved.iconSize)
    SBS.icon:SetHidden(not SBS.saved.showBagIcon)
    SBS.icon:SetColor(SBS.saved.iconR, SBS.saved.iconG, SBS.saved.iconB, SBS.saved.iconA)

    local used = GetBagUsed()
    local max = GetBagMax()
    local text = tostring(used) .. " / " .. tostring(max)

    SetCountLabelPosition(SBS.countShadow1, SBS.saved.countOffsetX + 4, SBS.saved.countOffsetY + 4)
    SBS.countShadow1:SetScale(SBS.saved.countScale)
    SBS.countShadow1:SetText(text)

    SetCountLabelPosition(SBS.countShadow2, SBS.saved.countOffsetX + 2, SBS.saved.countOffsetY + 2)
    SBS.countShadow2:SetScale(SBS.saved.countScale)
    SBS.countShadow2:SetText(text)

    SetCountLabelPosition(SBS.count, SBS.saved.countOffsetX, SBS.saved.countOffsetY)
    SBS.count:SetScale(SBS.saved.countScale)
    SBS.count:SetText(text)
    SBS.count:SetColor(SBS.saved.textR, SBS.saved.textG, SBS.saved.textB, SBS.saved.textA)
end

local function MakeCountLabel(name, parent, text, scale)
    local label = WINDOW_MANAGER:CreateControl(name, parent, CT_LABEL)
    label:SetAnchor(TOPLEFT, parent, TOPLEFT, 0, 0)
    label:SetDimensions(COUNT_LABEL_WIDTH, COUNT_LABEL_HEIGHT)
    label:SetFont("ZoFontGamepadBold")
    label:SetScale(scale)
    label:SetText(text)
    label:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    label:SetVerticalAlignment(TEXT_ALIGN_TOP)
    return label
end

local function CreateUI()
    SBS.window = WINDOW_MANAGER:CreateTopLevelWindow("ShowBagSpaceWindow")
    SBS.window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, SBS.saved.hudX, SBS.saved.hudY)
    SBS.window:SetDimensions(2200, 1200)
    SBS.window:SetHidden(false)
    SBS.window:SetDrawLayer(DL_OVERLAY)
    SBS.window:SetDrawLevel(999)

    SBS.box = WINDOW_MANAGER:CreateControl("ShowBagSpaceBox", SBS.window, CT_BACKDROP)

    SBS.icon = WINDOW_MANAGER:CreateControl("ShowBagSpaceIcon", SBS.window, CT_TEXTURE)
    SBS.icon:SetTexture("/esoui/art/mainmenu/menubar_inventory_up.dds")

    SBS.countShadow1 = MakeCountLabel("ShowBagSpaceCountShadow1", SBS.window, "0 / 0", SBS.saved.countScale)
    SBS.countShadow1:SetColor(0, 0, 0, 1)

    SBS.countShadow2 = MakeCountLabel("ShowBagSpaceCountShadow2", SBS.window, "0 / 0", SBS.saved.countScale)
    SBS.countShadow2:SetColor(0, 0, 0, 1)

    SBS.count = MakeCountLabel("ShowBagSpaceCount", SBS.window, "0 / 0", SBS.saved.countScale)

    UpdateDisplay()
end

local function ResetSettings()
    for key, value in pairs(SBS.defaults) do
        SBS.saved[key] = value
    end
    UpdateDisplay()
end

local function ResetAdvancedSettings()
    local keys = {
        "showBox",
        "boxOffsetX",
        "boxOffsetY",
        "boxWidth",
        "boxHeight",
        "boxOpacity",
        "boxR",
        "boxG",
        "boxB",
        "boxA",
        "textR",
        "textG",
        "textB",
        "textA",
        "iconR",
        "iconG",
        "iconB",
        "iconA",
    }

    for _, key in ipairs(keys) do
        SBS.saved[key] = SBS.defaults[key]
    end

    UpdateDisplay()
end

local function AddColorSetting(panel, label, tooltip, rKey, gKey, bKey, aKey)
    panel:AddSetting({
        type = LibHarvensAddonSettings.ST_COLOR,
        label = label,
        tooltip = tooltip,
        getFunction = function()
            return SBS.saved[rKey], SBS.saved[gKey], SBS.saved[bKey], SBS.saved[aKey]
        end,
        setFunction = function(r, g, b, a)
            SBS.saved[rKey] = r
            SBS.saved[gKey] = g
            SBS.saved[bKey] = b

            if a ~= nil then
                SBS.saved[aKey] = a
            end

            UpdateDisplay()
        end,
        default = {
            r = SBS.defaults[rKey],
            g = SBS.defaults[gKey],
            b = SBS.defaults[bKey],
            a = SBS.defaults[aKey],
        },
    })
end

local function RegisterSceneCallbacks()
    if not SCENE_MANAGER or not SCENE_MANAGER.GetScene then return end

    local sceneNames = {
        "hud", "hudui", "gameMenuInGame", "inventory", "gamepad_inventory_root",
        "gamepad_inventory", "map", "skills", "character", "journal", "mail",
        "bank", "tradinghouse", "gamepad_main_menu", "gamepad_map_root",
        "gamepad_skills_root", "gamepad_character_root", "gamepad_journal_root",
    }

    for _, sceneName in ipairs(sceneNames) do
        local scene = SCENE_MANAGER:GetScene(sceneName)
        if scene and scene.RegisterCallback then
            scene:RegisterCallback("StateChange", function()
                UpdateDisplay()
            end)
        end
    end
end

local function CreateSettings()
    if not LibHarvensAddonSettings then return end

    local panel = LibHarvensAddonSettings:AddAddon("ShowBagSpace", {
        allowDefaults = true,
    })

    panel:AddSetting({
        type = LibHarvensAddonSettings.ST_DESCRIPTION,
        text = "ShowBagSpace is a lightweight Xbox/controller inventory HUD. It displays your backpack space as used / max.",
    })

    panel:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = "Show HUD",
        tooltip = "Show or hide the ShowBagSpace HUD.",
        getFunction = function() return SBS.saved.showHud end,
        setFunction = function(value)
            SBS.saved.showHud = value
            UpdateDisplay()
        end,
        default = true,
    })

    panel:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = "Hide HUD While In Menus",
        tooltip = "Hide the ShowBagSpace HUD while viewing game menus.",
        getFunction = function() return SBS.saved.hideHudInMenus end,
        setFunction = function(value)
            SBS.saved.hideHudInMenus = value
            UpdateDisplay()
        end,
        default = true,
    })

    panel:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = "Show Bag Icon",
        tooltip = "Show or hide the inventory bag icon.",
        getFunction = function() return SBS.saved.showBagIcon end,
        setFunction = function(value)
            SBS.saved.showBagIcon = value
            UpdateDisplay()
        end,
        default = true,
    })

    panel:AddSetting({
        type = LibHarvensAddonSettings.ST_SLIDER,
        label = "HUD X Position",
        tooltip = "Move the full ShowBagSpace HUD left or right.",
        min = -100,
        max = 1900,
        step = 10,
        getFunction = function() return SBS.saved.hudX end,
        setFunction = function(value)
            SBS.saved.hudX = value
            UpdateDisplay()
        end,
        default = 1750,
    })

    panel:AddSetting({
        type = LibHarvensAddonSettings.ST_SLIDER,
        label = "HUD Y Position",
        tooltip = "Move the full ShowBagSpace HUD up or down.",
        min = 0,
        max = 900,
        step = 10,
        getFunction = function() return SBS.saved.hudY end,
        setFunction = function(value)
            SBS.saved.hudY = value
            UpdateDisplay()
        end,
        default = 470,
    })

    panel:AddSetting({
        type = LibHarvensAddonSettings.ST_SLIDER,
        label = "Count Text X Offset",
        tooltip = "Move the count text inside the HUD.",
        min = -1000,
        max = 1900,
        step = 5,
        getFunction = function() return SBS.saved.countOffsetX end,
        setFunction = function(value)
            SBS.saved.countOffsetX = value
            UpdateDisplay()
        end,
        default = 35,
    })

    panel:AddSetting({
        type = LibHarvensAddonSettings.ST_SLIDER,
        label = "Count Text Y Offset",
        tooltip = "Move the count text inside the HUD.",
        min = -500,
        max = 900,
        step = 5,
        getFunction = function() return SBS.saved.countOffsetY end,
        setFunction = function(value)
            SBS.saved.countOffsetY = value
            UpdateDisplay()
        end,
        default = 30,
    })

    panel:AddSetting({
        type = LibHarvensAddonSettings.ST_SLIDER,
        label = "Count Text Size",
        tooltip = "Change the size of the inventory count text.",
        min = 2,
        max = 14,
        step = 0.5,
        getFunction = function() return SBS.saved.countScale end,
        setFunction = function(value)
            SBS.saved.countScale = value
            UpdateDisplay()
        end,
        default = 8,
    })

    panel:AddSetting({
        type = LibHarvensAddonSettings.ST_SLIDER,
        label = "Bag Icon X Offset",
        tooltip = "Move the bag icon inside the HUD.",
        min = -1000,
        max = 1900,
        step = 5,
        getFunction = function() return SBS.saved.iconOffsetX end,
        setFunction = function(value)
            SBS.saved.iconOffsetX = value
            UpdateDisplay()
        end,
        default = -25,
    })

    panel:AddSetting({
        type = LibHarvensAddonSettings.ST_SLIDER,
        label = "Bag Icon Y Offset",
        tooltip = "Move the bag icon inside the HUD.",
        min = -500,
        max = 900,
        step = 5,
        getFunction = function() return SBS.saved.iconOffsetY end,
        setFunction = function(value)
            SBS.saved.iconOffsetY = value
            UpdateDisplay()
        end,
        default = 5,
    })

    panel:AddSetting({
        type = LibHarvensAddonSettings.ST_SLIDER,
        label = "Bag Icon Size",
        tooltip = "Change the size of the inventory bag icon.",
        min = 24,
        max = 260,
        step = 4,
        getFunction = function() return SBS.saved.iconSize end,
        setFunction = function(value)
            SBS.saved.iconSize = value
            UpdateDisplay()
        end,
        default = 56,
    })

    panel:AddSetting({
        type = LibHarvensAddonSettings.ST_SECTION,
        label = "Advanced Settings",
    })

    panel:AddSetting({
        type = LibHarvensAddonSettings.ST_BUTTON,
        label = "Reset Advanced Settings",
        buttonText = "Reset Advanced",
        tooltip = "Reset advanced ShowBagSpace visual settings.",
        clickHandler = function()
            ResetAdvancedSettings()
        end,
    })

    panel:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = "Show UI Box",
        tooltip = "Show a background box behind the ShowBagSpace HUD.",
        getFunction = function() return SBS.saved.showBox end,
        setFunction = function(value)
            SBS.saved.showBox = value
            UpdateDisplay()
        end,
        default = false,
    })

    panel:AddSetting({
        type = LibHarvensAddonSettings.ST_SLIDER,
        label = "UI Box X Offset",
        tooltip = "Move only the UI box left or right.",
        min = -1000,
        max = 1900,
        step = 5,
        getFunction = function() return SBS.saved.boxOffsetX end,
        setFunction = function(value)
            SBS.saved.boxOffsetX = value
            UpdateDisplay()
        end,
        default = 0,
    })

    panel:AddSetting({
        type = LibHarvensAddonSettings.ST_SLIDER,
        label = "UI Box Y Offset",
        tooltip = "Move only the UI box up or down.",
        min = -500,
        max = 900,
        step = 5,
        getFunction = function() return SBS.saved.boxOffsetY end,
        setFunction = function(value)
            SBS.saved.boxOffsetY = value
            UpdateDisplay()
        end,
        default = 0,
    })

    panel:AddSetting({
        type = LibHarvensAddonSettings.ST_SLIDER,
        label = "UI Box Width",
        tooltip = "Change the width of the UI box.",
        min = 50,
        max = 600,
        step = 10,
        getFunction = function() return SBS.saved.boxWidth end,
        setFunction = function(value)
            SBS.saved.boxWidth = value
            UpdateDisplay()
        end,
        default = 145,
    })

    panel:AddSetting({
        type = LibHarvensAddonSettings.ST_SLIDER,
        label = "UI Box Height",
        tooltip = "Change the height of the UI box.",
        min = 30,
        max = 300,
        step = 10,
        getFunction = function() return SBS.saved.boxHeight end,
        setFunction = function(value)
            SBS.saved.boxHeight = value
            UpdateDisplay()
        end,
        default = 125,
    })

    panel:AddSetting({
        type = LibHarvensAddonSettings.ST_SLIDER,
        label = "UI Box Opacity",
        tooltip = "Change the opacity of the UI box.",
        min = 0,
        max = 100,
        step = 5,
        unit = "%",
        getFunction = function() return SBS.saved.boxOpacity end,
        setFunction = function(value)
            SBS.saved.boxOpacity = value
            UpdateDisplay()
        end,
        default = 100,
    })

    AddColorSetting(panel, "UI Box Color", "Change the color of the UI box.", "boxR", "boxG", "boxB", "boxA")
    AddColorSetting(panel, "Count Text Color", "Change the color of the inventory count text.", "textR", "textG", "textB", "textA")
    AddColorSetting(panel, "Bag Icon Color", "Change the tint color of the bag icon.", "iconR", "iconG", "iconB", "iconA")

    panel:AddSetting({
        type = LibHarvensAddonSettings.ST_SECTION,
        label = "Reset All Settings",
    })

    panel:AddSetting({
        type = LibHarvensAddonSettings.ST_BUTTON,
        label = "Reset All Settings",
        buttonText = "Reset Settings",
        tooltip = "Reset all ShowBagSpace settings to default.",
        clickHandler = function()
            ResetSettings()
        end,
    })

    panel:AddSetting({
        type = LibHarvensAddonSettings.ST_DESCRIPTION,
        text = "Made by Tankiest Tank",
    })
end

local function OnInventoryChanged()
    UpdateDisplay()
end

local function OnMenuWatcher()
    local nowInMenu = IsInMenu()
    if nowInMenu ~= SBS.inMenu then
        SBS.inMenu = nowInMenu
        UpdateDisplay()
    end
end

local function Start()
    SBS.saved = ZO_SavedVars:NewAccountWide("ShowBagSpaceSavedVars", 1, nil, SBS.defaults)
    ApplyMissingDefaults()

    if not SBS.window then
        CreateUI()
    end

    CreateSettings()
    RegisterSceneCallbacks()
    UpdateDisplay()

    EVENT_MANAGER:RegisterForEvent("ShowBagSpaceInventorySlotUpdate", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, OnInventoryChanged)
    EVENT_MANAGER:RegisterForUpdate("ShowBagSpaceMenuWatcher", 100, OnMenuWatcher)
    EVENT_MANAGER:RegisterForUpdate("ShowBagSpaceRefresh", 2000, function()
        UpdateDisplay()
    end)
end

EVENT_MANAGER:RegisterForEvent("ShowBagSpaceStart", EVENT_PLAYER_ACTIVATED, Start)