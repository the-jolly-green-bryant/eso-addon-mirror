local TrueDebuffsBars = {
    name = "TrueDebuffsBars",
    version = "1.9",
    updateInterval = 100, -- Update every 100ms
    previewMode = false,
    controls = {
        buffs = {},
        debuffs = {}
    }
}

-- Positions pour le TEMPS (Autorise l'extérieur de l'icône)
local timerPositionMapping = {
    ["Top Left"] = { point = TOPLEFT, relPoint = TOPLEFT, x = 0, y = 0 },
    ["Top Right"] = { point = TOPRIGHT, relPoint = TOPRIGHT, x = 0, y = 0 },
    ["Bottom Left"] = { point = BOTTOMLEFT, relPoint = BOTTOMLEFT, x = 0, y = 0 },
    ["Bottom Right"] = { point = BOTTOMRIGHT, relPoint = BOTTOMRIGHT, x = 0, y = 0 },
    ["Center"] = { point = CENTER, relPoint = CENTER, x = 0, y = 0 },
    ["Below Center"] = { point = TOP, relPoint = BOTTOM, x = 0, y = 2 },
    ["Above Center"] = { point = BOTTOM, relPoint = TOP, x = 0, y = -2 },
    ["Left Center"] = { point = RIGHT, relPoint = LEFT, x = -4, y = 0 },
    ["Right Center"] = { point = LEFT, relPoint = RIGHT, x = 4, y = 0 }
}

-- Positions pour les STACKS (Restreintes à l'intérieur de l'icône)
local stackPositionMapping = {
    ["Top Left"] = { point = TOPLEFT, relPoint = TOPLEFT, x = 2, y = 2 },
    ["Top Right"] = { point = TOPRIGHT, relPoint = TOPRIGHT, x = -2, y = 2 },
    ["Bottom Left"] = { point = BOTTOMLEFT, relPoint = BOTTOMLEFT, x = 2, y = -2 },
    ["Bottom Right"] = { point = BOTTOMRIGHT, relPoint = BOTTOMRIGHT, x = -2, y = -2 },
    ["Center"] = { point = CENTER, relPoint = CENTER, x = 0, y = 0 }
}

-- Mapping des polices d'écriture
local fontMapping = {
    ["Medium (Default)"] = "$(MEDIUM_FONT)",
    ["Bold"] = "$(BOLD_FONT)",
    ["Antique"] = "$(ANTIQUE_FONT)",
    ["Stone Tablet"] = "$(STONE_TABLET_FONT)",
    ["Gamepad Medium"] = "$(GAMEPAD_MEDIUM_FONT)",
    ["Gamepad Bold"] = "$(GAMEPAD_BOLD_FONT)",
    ["Chat Font"] = "$(CHAT_FONT)"
}

-- Valeurs par défaut
local defaults = {
    buffX = 300,
    buffY = 500,
    debuffX = 400,
    debuffY = 500,
    buffDir = "Horizontal (Centered)",
    debuffDir = "Horizontal (Centered)",
    iconSize = 40,
    spacing = 5,
    fontStyle = "Medium (Default)",
    
    -- Valeurs par défaut pour le TEMPS
    timerBuffPos = "Below Center",
    timerDebuffPos = "Below Center",
    timerSize = 18,
    timerColor = {r = 1, g = 1, b = 1, a = 1},
    
    -- Valeurs par défaut pour les STACKS
    stackBuffPos = "Top Right",
    stackDebuffPos = "Top Right",
    stackSize = 16,
    stackColor = {r = 1, g = 0.8, b = 0, a = 1}, -- Légèrement orangé par défaut
    
    hidePermanent = false,
    hideLongBuffs = false,
    longBuffThreshold = 60
}

-- Icônes factices pour le Mode Aperçu (Preview)
local dummyBuffIcons = {
    "/esoui/art/icons/ability_warrior_010.dds",
    "/esoui/art/icons/ability_rogue_038.dds",
    "/esoui/art/icons/icon_experience_scroll.dds"
}
local dummyDebuffIcons = {
    "/esoui/art/icons/ability_debuff_snare.dds",
    "/esoui/art/icons/ability_debuff_disease.dds"
}

-- Formater le temps (secondes vers format lisible)
local function FormatTime(seconds)
    if seconds <= 0 then return "" end
    if seconds > 3600 then
        return string.format("%dh", math.floor(seconds / 3600))
    elseif seconds > 60 then
        return string.format("%dm", math.floor(seconds / 60))
    else
        return string.format("%ds", math.floor(seconds))
    end
end

-- Création / Récupération d'un contrôle d'icône depuis le "pool"
local function GetOrCreateIconControl(poolType, index)
    local pool = TrueDebuffsBars.controls[poolType]
    local parentFrame = (poolType == "buffs") and TrueDebuffsBars.buffFrame or TrueDebuffsBars.debuffFrame

    if not pool[index] then
        local ctrl = WINDOW_MANAGER:CreateControl(TrueDebuffsBars.name .. poolType .. index, parentFrame, CT_TEXTURE)
        
        -- Label pour le TEMPS
        local timerLabel = WINDOW_MANAGER:CreateControl(TrueDebuffsBars.name .. poolType .. "Timer" .. index, ctrl, CT_LABEL)
        timerLabel:SetDrawLayer(DL_OVERLAY)
        ctrl.timerLabel = timerLabel
        
        -- Label pour les STACKS
        local stackLabel = WINDOW_MANAGER:CreateControl(TrueDebuffsBars.name .. poolType .. "Stack" .. index, ctrl, CT_LABEL)
        stackLabel:SetDrawLayer(DL_OVERLAY)
        ctrl.stackLabel = stackLabel
        
        pool[index] = ctrl
    end

    local ctrl = pool[index]
    local settings = TrueDebuffsBars.savedVars
    local selectedFont = fontMapping[settings.fontStyle] or "$(MEDIUM_FONT)"

    -- Appliquer la taille de l'icône
    ctrl:SetDimensions(settings.iconSize, settings.iconSize)
    
    -- ================= PARAMÉTRAGE DU TEMPS =================
    local tFont = string.format("%s|%d|soft-shadow-thin", selectedFont, settings.timerSize)
    ctrl.timerLabel:SetFont(tFont)
    ctrl.timerLabel:SetColor(settings.timerColor.r, settings.timerColor.g, settings.timerColor.b, settings.timerColor.a)
    ctrl.timerLabel:ClearAnchors()
    
    local tPosSetting = (poolType == "buffs") and settings.timerBuffPos or settings.timerDebuffPos
    local tPos = timerPositionMapping[tPosSetting]
    if tPos then
        ctrl.timerLabel:SetAnchor(tPos.point, ctrl, tPos.relPoint, tPos.x, tPos.y)
    end
    
    -- ================= PARAMÉTRAGE DES STACKS =================
    local sFont = string.format("%s|%d|soft-shadow-thin", selectedFont, settings.stackSize)
    ctrl.stackLabel:SetFont(sFont)
    ctrl.stackLabel:SetColor(settings.stackColor.r, settings.stackColor.g, settings.stackColor.b, settings.stackColor.a)
    ctrl.stackLabel:ClearAnchors()
    
    local sPosSetting = (poolType == "buffs") and settings.stackBuffPos or settings.stackDebuffPos
    local sPos = stackPositionMapping[sPosSetting]
    if sPos then
        ctrl.stackLabel:SetAnchor(sPos.point, ctrl, sPos.relPoint, sPos.x, sPos.y)
    end
    
    ctrl:SetHidden(false)
    return ctrl
end

-- APPLIQUER LES POSITIONS (Gestion des alignements complexes)
local function ApplyAnchors(poolType, count, spacing, direction, size)
    if count == 0 then return end
    
    local pool = TrueDebuffsBars.controls[poolType]
    local parent = (poolType == "buffs") and TrueDebuffsBars.buffFrame or TrueDebuffsBars.debuffFrame
    
    if direction == "Horizontal" then direction = "Horizontal (Left to Right)" end
    local totalSpan = (count * size) + ((count - 1) * spacing)

    for i = 1, count do
        local ctrl = pool[i]
        ctrl:ClearAnchors()

        if direction == "Horizontal (Left to Right)" then
            if i == 1 then
                ctrl:SetAnchor(TOPLEFT, parent, TOPLEFT, 0, 0)
            else
                ctrl:SetAnchor(LEFT, pool[i - 1], RIGHT, spacing, 0)
            end
            
        elseif direction == "Horizontal (Right to Left)" then
            if i == 1 then
                ctrl:SetAnchor(TOPRIGHT, parent, TOPLEFT, 0, 0)
            else
                ctrl:SetAnchor(RIGHT, pool[i - 1], LEFT, -spacing, 0)
            end
            
        elseif direction == "Horizontal (Centered)" then
            if i == 1 then
                local startX = -(totalSpan / 2) + (size / 2)
                ctrl:SetAnchor(TOP, parent, TOPLEFT, startX, 0)
            else
                ctrl:SetAnchor(LEFT, pool[i - 1], RIGHT, spacing, 0)
            end
            
        elseif direction == "Vertical (Top to Bottom)" then
            if i == 1 then
                ctrl:SetAnchor(TOPLEFT, parent, TOPLEFT, 0, 0)
            else
                ctrl:SetAnchor(TOP, pool[i - 1], BOTTOM, 0, spacing)
            end
            
        elseif direction == "Vertical (Bottom to Top)" then
            if i == 1 then
                ctrl:SetAnchor(BOTTOMLEFT, parent, TOPLEFT, 0, 0)
            else
                ctrl:SetAnchor(BOTTOM, pool[i - 1], TOP, 0, -spacing)
            end
            
        elseif direction == "Vertical (Centered)" then
            if i == 1 then
                local startY = -(totalSpan / 2) + (size / 2)
                ctrl:SetAnchor(LEFT, parent, TOPLEFT, 0, startY)
            else
                ctrl:SetAnchor(TOP, pool[i - 1], BOTTOM, 0, spacing)
            end
        end
    end
end

-- Boucle principale de mise à jour des Buffs/Débuffs
function TrueDebuffsBars.UpdateBuffs()
    local shouldHide = false
    if IsReticleHidden() and not TrueDebuffsBars.previewMode then
        shouldHide = true
    end

    TrueDebuffsBars.buffFrame:SetHidden(shouldHide)
    TrueDebuffsBars.debuffFrame:SetHidden(shouldHide)

    if shouldHide then return end

    local currentTime = GetFrameTimeSeconds()
    local buffCount = 0
    local debuffCount = 0
    local settings = TrueDebuffsBars.savedVars

    if TrueDebuffsBars.previewMode then
        for i, icon in ipairs(dummyBuffIcons) do
            buffCount = buffCount + 1
            local ctrl = GetOrCreateIconControl("buffs", buffCount)
            ctrl:SetTexture(icon)
            
            ctrl.timerLabel:SetText(FormatTime(120 - (i * 10)))
            ctrl.stackLabel:SetText(i > 1 and "3" or "")
        end
        for i, icon in ipairs(dummyDebuffIcons) do
            debuffCount = debuffCount + 1
            local ctrl = GetOrCreateIconControl("debuffs", debuffCount)
            ctrl:SetTexture(icon)
            
            ctrl.timerLabel:SetText(FormatTime(15 - (i * 2)))
            ctrl.stackLabel:SetText("")
        end
    else
        for i = 1, GetNumBuffs("player") do
            local buffName, timeStarted, timeEnding, buffSlot, stackCount, iconFilename, buffType, effectType = GetUnitBuffInfo("player", i)

            if buffName and buffName ~= "" then
                local isPermanent = (timeStarted == timeEnding) or (timeEnding == 0)
                local timeLeft = isPermanent and 0 or (timeEnding - currentTime)
                
                local skipEffect = false
                if settings.hidePermanent and isPermanent then skipEffect = true end
                if settings.hideLongBuffs and not isPermanent and (timeLeft > (settings.longBuffThreshold * 60)) then skipEffect = true end
                
                if not skipEffect then
                    local isDebuff = (effectType == BUFF_EFFECT_TYPE_DEBUFF)
                    local poolType = isDebuff and "debuffs" or "buffs"
                    
                    local index
                    if isDebuff then
                        debuffCount = debuffCount + 1
                        index = debuffCount
                    else
                        buffCount = buffCount + 1
                        index = buffCount
                    end

                    local ctrl = GetOrCreateIconControl(poolType, index)
                    ctrl:SetTexture(iconFilename)

                    -- Affichage du Temps
                    local timeText = ""
                    if not isPermanent then
                        timeText = FormatTime(timeLeft)
                    end
                    ctrl.timerLabel:SetText(timeText)
                    
                    -- Affichage des Stacks
                    if stackCount > 1 then
                        ctrl.stackLabel:SetText(tostring(stackCount))
                    else
                        ctrl.stackLabel:SetText("")
                    end
                end
            end
        end
    end

    ApplyAnchors("buffs", buffCount, settings.spacing, settings.buffDir, settings.iconSize)
    ApplyAnchors("debuffs", debuffCount, settings.spacing, settings.debuffDir, settings.iconSize)

    for i = buffCount + 1, #TrueDebuffsBars.controls.buffs do
        TrueDebuffsBars.controls.buffs[i]:SetHidden(true)
    end
    for i = debuffCount + 1, #TrueDebuffsBars.controls.debuffs do
        TrueDebuffsBars.controls.debuffs[i]:SetHidden(true)
    end
end

-- Mise à jour globale des positions des frames
local function UpdateFramePositions()
    TrueDebuffsBars.buffFrame:ClearAnchors()
    TrueDebuffsBars.buffFrame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, TrueDebuffsBars.savedVars.buffX, TrueDebuffsBars.savedVars.buffY)
    
    TrueDebuffsBars.debuffFrame:ClearAnchors()
    TrueDebuffsBars.debuffFrame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, TrueDebuffsBars.savedVars.debuffX, TrueDebuffsBars.savedVars.debuffY)
end

-- Création du Menu de Paramètres avec LibAddonMenu
local function BuildMenu()
    if not LibAddonMenu2 then return end 

    local LAM = LibAddonMenu2
    local panelData = {
        type = "panel",
        name = "True (De)Buffs Bars",
        displayName = "|cff5900True (De)Buffs Bars|r",
        author = "|cff5900Toudidef|r",
        version = TrueDebuffsBars.version,
        registerForRefresh = true,
        registerForDefaults = true,
    }
    LAM:RegisterAddonPanel("TrueDebuffsBarsPanel", panelData)

    local optionsData = {
        {
            type = "checkbox", 
            name = "|c00FF00Preview Mode (Show fake buffs)|r",
            tooltip = "Turn this ON to show dummy buffs and debuffs while configuring. Turn it OFF when you are done.",
            getFunc = function() return TrueDebuffsBars.previewMode end,
            setFunc = function(value) TrueDebuffsBars.previewMode = value end,
            warning = "Don't forget to turn this OFF when you finish your setup!",
        },
        { type = "header", name = "Filters (Hide specific buffs)" },
        {
            type = "checkbox", name = "Hide Permanent Effects",
            tooltip = "Hides passives, mundus stones, and infinite buffs.",
            getFunc = function() return TrueDebuffsBars.savedVars.hidePermanent end,
            setFunc = function(value) TrueDebuffsBars.savedVars.hidePermanent = value end,
        },
        {
            type = "checkbox", name = "Hide Long Duration Effects",
            tooltip = "Hides buffs that have a long timer (e.g. food).",
            getFunc = function() return TrueDebuffsBars.savedVars.hideLongBuffs end,
            setFunc = function(value) TrueDebuffsBars.savedVars.hideLongBuffs = value end,
        },
        {
            type = "slider", name = "Long Duration Threshold (Minutes)",
            tooltip = "Any effect longer than this will be hidden.",
            min = 1, max = 120, step = 1,
            disabled = function() return not TrueDebuffsBars.savedVars.hideLongBuffs end,
            getFunc = function() return TrueDebuffsBars.savedVars.longBuffThreshold end,
            setFunc = function(value) TrueDebuffsBars.savedVars.longBuffThreshold = value end,
        },

        { type = "header", name = "Bars Positions" },
        {
            type = "slider", name =  "Buffs (X)",
            min = 0, max = 3500, step = 10,
            getFunc = function() return TrueDebuffsBars.savedVars.buffX end,
            setFunc = function(value) TrueDebuffsBars.savedVars.buffX = value; UpdateFramePositions() end,
        },
        {
            type = "slider", name =  "Buffs (Y)",
            min = 0, max = 2000, step = 10,
            getFunc = function() return TrueDebuffsBars.savedVars.buffY end,
            setFunc = function(value) TrueDebuffsBars.savedVars.buffY = value; UpdateFramePositions() end,
        },
        {
            type = "slider", name = "Debuffs (X)",
            min = 0, max = 3500, step = 10,
            getFunc = function() return TrueDebuffsBars.savedVars.debuffX end,
            setFunc = function(value) TrueDebuffsBars.savedVars.debuffX = value; UpdateFramePositions() end,
        },
        {
            type = "slider", name = "Debuffs (Y)",
            min = 0, max = 2000, step = 10,
            getFunc = function() return TrueDebuffsBars.savedVars.debuffY end,
            setFunc = function(value) TrueDebuffsBars.savedVars.debuffY = value; UpdateFramePositions() end,
        },

        { type = "header", name = "Appearences and Orientations" },
        {
            type = "dropdown", name = "Buffs orientation",
            choices = {"Horizontal (Left to Right)", "Horizontal (Right to Left)", "Horizontal (Centered)", "Vertical (Top to Bottom)", "Vertical (Bottom to Top)", "Vertical (Centered)"},
            getFunc = function() return TrueDebuffsBars.savedVars.buffDir end,
            setFunc = function(value) TrueDebuffsBars.savedVars.buffDir = value end,
        },
        {
            type = "dropdown", name = "Debuffs orientation",
            choices = {"Horizontal (Left to Right)", "Horizontal (Right to Left)", "Horizontal (Centered)", "Vertical (Top to Bottom)", "Vertical (Bottom to Top)", "Vertical (Centered)"},
            getFunc = function() return TrueDebuffsBars.savedVars.debuffDir end,
            setFunc = function(value) TrueDebuffsBars.savedVars.debuffDir = value end,
        },
        {
            type = "slider", name = "Icons size",
            min = 20, max = 100, step = 2,
            getFunc = function() return TrueDebuffsBars.savedVars.iconSize end,
            setFunc = function(value) TrueDebuffsBars.savedVars.iconSize = value end,
        },
        {
            type = "slider", name = "Spacing",
            min = 0, max = 200, step = 1,
            getFunc = function() return TrueDebuffsBars.savedVars.spacing end,
            setFunc = function(value) TrueDebuffsBars.savedVars.spacing = value end,
        },

        -- NOUVELLE GESTION DES TEXTES (Polices, Temps, Stacks)
        { type = "header", name = "Global Text Settings" },
        {
            type = "dropdown", name = "Font Style",
            choices = {"Medium (Default)", "Bold", "Antique", "Stone Tablet", "Gamepad Medium", "Gamepad Bold", "Chat Font"},
            getFunc = function() return TrueDebuffsBars.savedVars.fontStyle end,
            setFunc = function(value) TrueDebuffsBars.savedVars.fontStyle = value end,
        },

        { type = "header", name = "Timers Settings (Time Left)" },
        {
            type = "dropdown", name = "Buffs Timer Position",
            choices = {"Top Left", "Top Right", "Bottom Left", "Bottom Right", "Center", "Below Center", "Above Center", "Left Center", "Right Center"},
            getFunc = function() return TrueDebuffsBars.savedVars.timerBuffPos end,
            setFunc = function(value) TrueDebuffsBars.savedVars.timerBuffPos = value end,
        },
        {
            type = "dropdown", name = "Debuffs Timer Position",
            choices = {"Top Left", "Top Right", "Bottom Left", "Bottom Right", "Center", "Below Center", "Above Center", "Left Center", "Right Center"},
            getFunc = function() return TrueDebuffsBars.savedVars.timerDebuffPos end,
            setFunc = function(value) TrueDebuffsBars.savedVars.timerDebuffPos = value end,
        },
        {
            type = "slider", name = "Timer Text Size",
            min = 10, max = 40, step = 1,
            getFunc = function() return TrueDebuffsBars.savedVars.timerSize end,
            setFunc = function(value) TrueDebuffsBars.savedVars.timerSize = value end,
        },
        {
            type = "colorpicker", name = "Timer Color",
            getFunc = function() 
                local c = TrueDebuffsBars.savedVars.timerColor
                return c.r, c.g, c.b, c.a 
            end,
            setFunc = function(r, g, b, a)
                TrueDebuffsBars.savedVars.timerColor = {r = r, g = g, b = b, a = a}
            end,
        },

        { type = "header", name = "Stacks Settings (Charges)" },
        {
            type = "dropdown", name = "Buffs Stack Position",
            choices = {"Top Left", "Top Right", "Bottom Left", "Bottom Right", "Center"},
            getFunc = function() return TrueDebuffsBars.savedVars.stackBuffPos end,
            setFunc = function(value) TrueDebuffsBars.savedVars.stackBuffPos = value end,
        },
        {
            type = "dropdown", name = "Debuffs Stack Position",
            choices = {"Top Left", "Top Right", "Bottom Left", "Bottom Right", "Center"},
            getFunc = function() return TrueDebuffsBars.savedVars.stackDebuffPos end,
            setFunc = function(value) TrueDebuffsBars.savedVars.stackDebuffPos = value end,
        },
        {
            type = "slider", name = "Stack Text Size",
            min = 10, max = 40, step = 1,
            getFunc = function() return TrueDebuffsBars.savedVars.stackSize end,
            setFunc = function(value) TrueDebuffsBars.savedVars.stackSize = value end,
        },
        {
            type = "colorpicker", name = "Stack Color",
            getFunc = function() 
                local c = TrueDebuffsBars.savedVars.stackColor
                return c.r, c.g, c.b, c.a 
            end,
            setFunc = function(r, g, b, a)
                TrueDebuffsBars.savedVars.stackColor = {r = r, g = g, b = b, a = a}
            end,
        }
    }
    LAM:RegisterOptionControls("TrueDebuffsBarsPanel", optionsData)
end

-- Initialisation au chargement
local function OnAddOnLoaded(eventCode, addonName)
    if addonName ~= TrueDebuffsBars.name then return end
    EVENT_MANAGER:UnregisterForEvent(TrueDebuffsBars.name, EVENT_ADD_ON_LOADED)

    TrueDebuffsBars.savedVars = ZO_SavedVars:NewAccountWide("TrueDebuffsBarsSavedVars", 1, nil, defaults)

    -- Création des conteneurs principaux
    TrueDebuffsBars.buffFrame = WINDOW_MANAGER:CreateTopLevelWindow(TrueDebuffsBars.name .. "BuffFrame")
    TrueDebuffsBars.debuffFrame = WINDOW_MANAGER:CreateTopLevelWindow(TrueDebuffsBars.name .. "DebuffFrame")
    
    TrueDebuffsBars.buffFrame:SetDrawTier(DT_HIGH)
    TrueDebuffsBars.debuffFrame:SetDrawTier(DT_HIGH)
    
    UpdateFramePositions()
    BuildMenu()
    EVENT_MANAGER:RegisterForUpdate(TrueDebuffsBars.name .. "UpdateLoop", TrueDebuffsBars.updateInterval, TrueDebuffsBars.UpdateBuffs)
end

EVENT_MANAGER:RegisterForEvent(TrueDebuffsBars.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)