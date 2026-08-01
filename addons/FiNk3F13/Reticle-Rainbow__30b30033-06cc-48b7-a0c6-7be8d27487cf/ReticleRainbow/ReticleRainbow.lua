-- Reticle Rainbow (CONSOLE SAVE FIX + SIZE SLIDER)

local HAS = LibHarvensAddonSettings

ReticleRainbow = {}
local db
local customReticle
local glowReticle
local previewControl
local reticleRoot

-- 🔥 CUSTOM SETTINGS (Fallback falls nix gespeichert)
local BASE_SIZE = 7
local TARGET_BONUS = 40
local THICKNESS = 0.25
local GLOW_ALPHA = 0.6

-- 🔥 HIT STATE
local hitTime = 0
local effectDuration = 250

-- 🔥 DEINE IDS
local LIGHT_ATTACK_IDS = {
    [16037] = true,
    [18350] = true,
    [16165] = true,
    [16277] = true,
    [16145] = true,
    [15435] = true,
    [16688] = true,
    [21970] = true,
    [16499] = true,
}

local crosshairs = {
    "ReticleRainbow/textures/crosshair1.dds",
    "ReticleRainbow/textures/crosshair2.dds",
    "ReticleRainbow/textures/crosshair3.dds",
    "ReticleRainbow/textures/crosshair4.dds",
    "ReticleRainbow/textures/crosshair5.dds",
    "ReticleRainbow/textures/crosshair6.dds",
    "ReticleRainbow/textures/crosshair7.dds",
    "ReticleRainbow/textures/crosshair8.dds",
    "ReticleRainbow/textures/crosshair9.dds",
    "ReticleRainbow/textures/crosshair10.dds",
}

local defaults = {
    enabled = true,
    showVanilla = true,
    selectedCrosshair = 1,
    showPreview = true,

    rainbowMode = false,
    glowEnabled = true,

    -- 🔥 NEU (SLIDER)
    baseSize = BASE_SIZE,

    -- 🔥 HINZUGEFÜGT (COLORS)
    hostileColor = {r=1,g=0,b=0},
    allyColor = {r=0,g=0.6,b=1},
    neutralColor = {r=1,g=1,b=0},
}

local function GetIndex()
    local index = tonumber(db.selectedCrosshair) or 1
    if index < 1 then index = 1 end
    if index > #crosshairs then index = 1 end
    return index
end

local function SetupSavedVars()
    ReticleRainbow.savedVariables = ZO_SavedVars:NewAccountWide(
        "ReticleRainbowSavedVars",
        1,
        nil,
        defaults
    )
    db = ReticleRainbow.savedVariables
end

local function OnCombatEvent(_, result, _, _, _, _, _, sourceType, _, _, _, _, _, _, _, _, abilityId)
    if sourceType ~= COMBAT_UNIT_TYPE_PLAYER then return end
    if result ~= ACTION_RESULT_DAMAGE and result ~= ACTION_RESULT_CRITICAL_DAMAGE then return end
    if not LIGHT_ATTACK_IDS[abilityId] then return end

    hitTime = GetFrameTimeMilliseconds()
end

-- 🔥 HINZUGEFÜGT (COLOR FUNCTION)
local function GetColor()
    if not DoesUnitExist("reticleover") then
        return 1,1,1
    end

    local reaction = GetUnitReaction("reticleover")

    if reaction == UNIT_REACTION_HOSTILE then
        return db.hostileColor.r, db.hostileColor.g, db.hostileColor.b
    elseif reaction == UNIT_REACTION_PLAYER_ALLY then
        return db.allyColor.r, db.allyColor.g, db.allyColor.b
    elseif reaction == UNIT_REACTION_NEUTRAL then
        return db.neutralColor.r, db.neutralColor.g, db.neutralColor.b
    end

    return 1,1,1
end

local function UpdateCrosshair()
    if not db then return end
    local texture = crosshairs[GetIndex()]

    if customReticle then
        customReticle:SetTexture(nil)
        customReticle:SetTexture(texture)
    end

    if glowReticle then
        glowReticle:SetTexture(texture)
    end

    if previewControl then
        previewControl:SetTexture(texture)
        previewControl:SetHidden(not db.showPreview)
    end
end

local function CreateSettings()
    if not HAS or not db then return end

    local settings = HAS:AddAddon("Reticle Rainbow")

    settings:AddSetting({
        type = HAS.ST_SLIDER,
        label = "Fadenkreuz Größe (ohne Ziel)",
        min = 1,
        max = 100,
        step = 1,
        getFunction = function() return db.baseSize end,
        setFunction = function(v) db.baseSize = v end,
    })

    settings:AddSetting({
        type = HAS.ST_CHECKBOX,
        label = "Original Fadenkreuz anzeigen",
        getFunction = function() return db.showVanilla end,
        setFunction = function(v)
            db.showVanilla = v
        end,
    })

    settings:AddSetting({
        type = HAS.ST_CHECKBOX,
        label = "Custom Crosshair anzeigen",
        getFunction = function() return db.enabled end,
        setFunction = function(v)
            db.enabled = v
            if reticleRoot then
                reticleRoot:SetHidden(not v)
            end
        end,
    })

    settings:AddSetting({
        type = HAS.ST_CHECKBOX,
        label = "Rainbow Effekt",
        getFunction = function() return db.rainbowMode end,
        setFunction = function(v) db.rainbowMode = v end,
    })

    settings:AddSetting({
        type = HAS.ST_CHECKBOX,
        label = "Glow Effekt aktivieren",
        getFunction = function() return db.glowEnabled end,
        setFunction = function(v) db.glowEnabled = v end,
    })

    settings:AddSetting({
        type = HAS.ST_BUTTON,
        label = "Nächstes Crosshair",
        buttonText = "Weiter",
        clickHandler = function()
            db.selectedCrosshair = GetIndex() + 1
            if db.selectedCrosshair > #crosshairs then db.selectedCrosshair = 1 end
            UpdateCrosshair()
        end,
    })

    settings:AddSetting({
        type = HAS.ST_BUTTON,
        label = "Vorheriges Crosshair",
        buttonText = "Zurück",
        clickHandler = function()
            db.selectedCrosshair = GetIndex() - 1
            if db.selectedCrosshair < 1 then db.selectedCrosshair = #crosshairs end
            UpdateCrosshair()
        end,
    })

    -- 🔥 HINZUGEFÜGT (COLOR PICKER)
    settings:AddSetting({
        type = HAS.ST_COLOR,
        label = "Feind Farbe",
        getFunction = function() return db.hostileColor.r,db.hostileColor.g,db.hostileColor.b end,
        setFunction = function(r,g,b) db.hostileColor={r=r,g=g,b=b} end,
    })

    settings:AddSetting({
        type = HAS.ST_COLOR,
        label = "Verbündete Farbe",
        getFunction = function() return db.allyColor.r,db.allyColor.g,db.allyColor.b end,
        setFunction = function(r,g,b) db.allyColor={r=r,g=g,b=b} end,
    })

    settings:AddSetting({
        type = HAS.ST_COLOR,
        label = "Neutral Farbe",
        getFunction = function() return db.neutralColor.r,db.neutralColor.g,db.neutralColor.b end,
        setFunction = function(r,g,b) db.neutralColor={r=r,g=g,b=b} end,
    })
end

local function GetRainbowColor()
    local t = GetFrameTimeMilliseconds() / 1000
    local r = math.sin(t * 2) * 0.5 + 0.5
    local g = math.sin(t * 2 + 2) * 0.5 + 0.5
    local b = math.sin(t * 2 + 4) * 0.5 + 0.5
    return r, g, b
end

local function UpdateReticle()
    if not db then return end

    if ZO_ReticleContainer then
        local interacting = DoesUnitExist("reticleover") and not IsUnitAttackable("reticleover")

        if db.showVanilla then
            ZO_ReticleContainer:SetAlpha(1)
        else
            ZO_ReticleContainer:SetAlpha(0)
        end
    end

    if reticleRoot then
        reticleRoot:SetHidden(not db.enabled)
    end

    if not db.enabled then return end
    if IsReticleHidden() then return end

    local hasTarget = DoesUnitExist("reticleover")

    local r,g,b
    if db.rainbowMode then
        r,g,b = GetRainbowColor()
    else
        r,g,b = GetColor()
    end

    if customReticle then
        customReticle:SetHidden(false)

        local texture = crosshairs[GetIndex()]
        customReticle:SetTexture(nil)
        customReticle:SetTexture(texture)

        local base = db.baseSize or BASE_SIZE
        local targetSize = hasTarget and (base + TARGET_BONUS) or base

        local currentW = customReticle:GetWidth()
        local newSize = currentW + (targetSize - currentW) * 0.2

        customReticle:SetDimensions(newSize, newSize)

        -- 🔥 HIER ANGEWENDET
        customReticle:SetColor(r,g,b,1)

        local now = GetFrameTimeMilliseconds()
        local elapsed = now - hitTime

        if glowReticle then
            if not db.glowEnabled then
                glowReticle:SetHidden(true)
            elseif elapsed < effectDuration then
                local pulseSize = newSize * (1 + THICKNESS)

                glowReticle:SetHidden(false)
                glowReticle:SetTexture(texture)
                glowReticle:SetDimensions(pulseSize, pulseSize)
                glowReticle:SetColor(r, g, b, GLOW_ALPHA)
            else
                glowReticle:SetHidden(true)
            end
        end
    end
end

local function OnPlayerActivated()
    EVENT_MANAGER:UnregisterForEvent("ReticleRainbowActivated", EVENT_PLAYER_ACTIVATED)

    SetupSavedVars()
    CreateSettings()

    reticleRoot = WINDOW_MANAGER:CreateTopLevelWindow("RR_Root")
    reticleRoot:SetDimensions(64,64)
    reticleRoot:SetAnchor(CENTER,GuiRoot,CENTER,0,0)

    glowReticle = WINDOW_MANAGER:CreateControl(nil, reticleRoot, CT_TEXTURE)
    glowReticle:SetAnchor(CENTER, reticleRoot, CENTER, 0, 0)
    glowReticle:SetDrawLayer(DL_BACKGROUND)

    customReticle = WINDOW_MANAGER:CreateControl(nil,reticleRoot,CT_TEXTURE)
    customReticle:SetAnchor(CENTER,reticleRoot,CENTER,0,0)
    customReticle:SetDimensions(40,40)

    UpdateCrosshair()

    EVENT_MANAGER:RegisterForEvent("RR_Combat", EVENT_COMBAT_EVENT, OnCombatEvent)
    EVENT_MANAGER:RegisterForUpdate("ReticleRainbowUpdate",50,UpdateReticle)
end

EVENT_MANAGER:RegisterForEvent("ReticleRainbowActivated",EVENT_PLAYER_ACTIVATED,OnPlayerActivated)