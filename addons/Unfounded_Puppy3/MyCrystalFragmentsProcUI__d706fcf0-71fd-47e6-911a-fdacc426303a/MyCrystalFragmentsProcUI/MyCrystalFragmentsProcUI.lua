local ADDON_NAME = "MyCrystalFragmentsProcUI"

MyCrystalFragmentsProcUI = MyCrystalFragmentsProcUI or {}

------------------------------------------------------------
-- Ability IDs
------------------------------------------------------------
local ABILITY_HURRICANE = 23231
local ABILITY_BOUND_ARMAMENTS = 203447
local ABILITY_CRYSTAL_FRAGMENTS = 46327

------------------------------------------------------------
-- UI settings
------------------------------------------------------------
local ICON_SIZE = 60
local DISPLAY_TIME = 500 -- ms (Bound / Crystal)
local HURRICANE_COUNTDOWN_TIME = 3 -- seconds

------------------------------------------------------------
-- Bound Armaments stack tracking
------------------------------------------------------------
local lastBoundArmamentsStacks = 0

------------------------------------------------------------
-- Icon controls
------------------------------------------------------------
local iconHurricaneUI, iconHurricane, labelHurricane = nil, nil, nil
local iconHurricaneButton = nil

local iconBoundUI, iconBound, labelBound = nil, nil, nil
local iconBoundButton = nil

local iconCrystalUI, iconCrystal = nil, nil
local iconCrystalButton = nil

------------------------------------------------------------
-- Create a single icon UI (with optional label)
------------------------------------------------------------
local function CreateIcon(name, offsetY, withLabel)
    local ui = WINDOW_MANAGER:CreateTopLevelWindow(name)
    ui:SetDimensions(ICON_SIZE, ICON_SIZE)

    ui:SetAnchor(TOP, GuiRoot, TOP, 0, offsetY)
    ui:SetDrawLayer(DL_OVERLAY)
    ui:SetHidden(true)

    local icon = WINDOW_MANAGER:CreateControl(name .. "_Texture", ui, CT_TEXTURE)
    icon:SetDimensions(ICON_SIZE, ICON_SIZE)
    icon:SetAnchorFill(ui)
    icon:SetHidden(false)

    local label = nil
    if withLabel then
        label = WINDOW_MANAGER:CreateControl(name .. "_Label", ui, CT_LABEL)
        label:SetFont("$(BOLD_FONT)|30|outline")
        label:SetColor(1, 1, 1, 1)
        label:SetAnchor(CENTER, ui, CENTER, 0, 0)
        label:SetText("")
    end

    --------------------------------------------------------
    -- Hurricane → B ボタン
    --------------------------------------------------------
    if name == "MyCF_Hurricane" then
        local button = WINDOW_MANAGER:CreateControl(name .. "_Button", ui, CT_TEXTURE)
        button:SetDimensions(24, 24)
        button:SetAnchor(BOTTOMRIGHT, ui, BOTTOMRIGHT, -2, -2)
        button:SetTexture("EsoUI/Art/Buttons/Gamepad/Xbox/nav_xbone_b.dds")
        button:SetHidden(true)
        iconHurricaneButton = button
    end

    --------------------------------------------------------
    -- Bound Armaments → X ボタン
    --------------------------------------------------------
    if name == "MyCF_Bound" then
        local button = WINDOW_MANAGER:CreateControl(name .. "_Button", ui, CT_TEXTURE)
        button:SetDimensions(24, 24)
        button:SetAnchor(BOTTOMRIGHT, ui, BOTTOMRIGHT, -2, -2)
        button:SetTexture("EsoUI/Art/Buttons/Gamepad/Xbox/nav_xbone_x.dds")
        button:SetHidden(true)
        iconBoundButton = button
    end

    --------------------------------------------------------
    -- Crystal Fragments → RB ボタン
    --------------------------------------------------------
    if name == "MyCF_Crystal" then
        local button = WINDOW_MANAGER:CreateControl(name .. "_Button", ui, CT_TEXTURE)
        button:SetDimensions(24, 24)
        button:SetAnchor(BOTTOMRIGHT, ui, BOTTOMRIGHT, -2, -2)
        button:SetTexture("EsoUI/Art/Buttons/Gamepad/Xbox/nav_xbone_rb.dds")
        button:SetHidden(true)
        iconCrystalButton = button
    end

    return ui, icon, label
end

------------------------------------------------------------
-- Create all 3 icons
------------------------------------------------------------
local function CreateUI()
    iconHurricaneUI, iconHurricane, labelHurricane = CreateIcon("MyCF_Hurricane", 200, true)
    iconBoundUI,     iconBound,     labelBound     = CreateIcon("MyCF_Bound",     260, true)
    iconCrystalUI,   iconCrystal                   = CreateIcon("MyCF_Crystal",   320, false)
end

------------------------------------------------------------
-- Show icon (generic)
------------------------------------------------------------
local function ShowIcon(ui, icon, label, texture, text)
    if not ui or not icon then return end
    if not texture or type(texture) ~= "string" or texture == "" then return end

    icon:SetTexture(texture)
    ui:SetHidden(false)
    ui:SetAlpha(1)

    if label then
        label:SetText(text or "")
    end

    zo_callLater(function()
        ui:SetHidden(true)
    end, DISPLAY_TIME)
end

------------------------------------------------------------
-- EVENT_EFFECT_CHANGED
------------------------------------------------------------
local function OnEffectChanged(
    eventCode, changeType, effectSlot, effectName, unitTag,
    beginTime, endTime, stackCount, iconName,
    buffType, effectType, abilityType, statusEffectType,
    unitName, unitId, abilityId, sourceType
)

    if unitTag ~= "player" then return end

    --------------------------------------------------------
    -- Hurricane（終了3秒前から3秒間表示）
    --------------------------------------------------------
    if abilityId == ABILITY_HURRICANE then
        if changeType == EFFECT_RESULT_GAINED then
            MyCrystalFragmentsProcUI.hurricaneEnd = endTime
            MyCrystalFragmentsProcUI.hurricaneIcon = iconName
            MyCrystalFragmentsProcUI.hurricaneActive = true
        end

        if changeType == EFFECT_RESULT_FADED then
            MyCrystalFragmentsProcUI.hurricaneActive = false
            iconHurricaneUI:SetHidden(true)
            if iconHurricaneButton then iconHurricaneButton:SetHidden(true) end
        end

        return
    end

    --------------------------------------------------------
    -- Bound Armaments（スタックした瞬間に通知）
    --------------------------------------------------------
    if abilityId == ABILITY_BOUND_ARMAMENTS then
        local stacks = stackCount or 0

        if changeType == EFFECT_RESULT_FADED then
            lastBoundArmamentsStacks = 0
            return
        end

        if stacks > lastBoundArmamentsStacks then
            ShowIcon(iconBoundUI, iconBound, labelBound, iconName, tostring(stacks))

            if iconBoundButton then
                iconBoundButton:SetHidden(false)
            end
        end

        lastBoundArmamentsStacks = stacks
        return
    end

    --------------------------------------------------------
    -- Crystal Fragments Ready（Proc発生）
    --------------------------------------------------------
    if abilityId == ABILITY_CRYSTAL_FRAGMENTS then
        if changeType == EFFECT_RESULT_GAINED then
            ShowIcon(iconCrystalUI, iconCrystal, nil, iconName)

            if iconCrystalButton then
                iconCrystalButton:SetHidden(false)
            end
        end
        return
    end
end

------------------------------------------------------------
-- Update (for Hurricane countdown)
------------------------------------------------------------
local function OnUpdate()
    if not MyCrystalFragmentsProcUI.hurricaneActive then return end
    if not MyCrystalFragmentsProcUI.hurricaneEnd then return end

    local now = GetFrameTimeSeconds()
    local remain = MyCrystalFragmentsProcUI.hurricaneEnd - now

    if remain <= HURRICANE_COUNTDOWN_TIME and remain > 0 then
        local count = math.ceil(remain)

        iconHurricane:SetTexture(MyCrystalFragmentsProcUI.hurricaneIcon)
        labelHurricane:SetText(tostring(count))
        iconHurricaneUI:SetHidden(false)

        if iconHurricaneButton then
            iconHurricaneButton:SetHidden(false)
        end

        if remain <= 0 then
            iconHurricaneUI:SetHidden(true)
            if iconHurricaneButton then iconHurricaneButton:SetHidden(true) end
            MyCrystalFragmentsProcUI.hurricaneActive = false
        end
    end
end

------------------------------------------------------------
-- AddOn Loaded
------------------------------------------------------------
local function OnAddOnLoaded(event, addonName)
    if addonName ~= ADDON_NAME then return end

    CreateUI()

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_EFFECT_CHANGED, OnEffectChanged)
    EVENT_MANAGER:RegisterForUpdate(ADDON_NAME .. "_Update", 100, OnUpdate)

    d("MyCrystalFragmentsProcUI Loaded")
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
