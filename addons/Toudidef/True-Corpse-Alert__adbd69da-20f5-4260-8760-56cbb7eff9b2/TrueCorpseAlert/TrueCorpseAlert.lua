TrueCorpseAlert = {
    name = "True Corpse Alert",
    author = "|cff5900To|r|cb56648u|r|c906c6cd|r|c6a7391i|r|c1581fcef|r",
    version = "1.0",
    corpseUsable = false, 
    hasAbilitySlotted = false,
    isDead = false,
    inCombat = false,
    testMode = false,
}

-- Paramètres par défaut
TrueCorpseAlert.defaultSettings = {
    displayType = "Text",
    onlyInCombat = true,
    
    -- Text
    textX = 0,
    textY = -150,
    textScale = 100,
    textColor = {r = 1, g = 0, b = 0, a = 1},
    textFont = "Gamepad Bold",
    
    -- Icon
    iconTexture = "Bone pile",
    iconX = 0,
    iconY = -150,
    iconScale = 100,
}

-- Tes polices d'origine restaurées
local fonts = {
    ["Medium (Default)"] = "ZoFontGame",
    ["Bold"] = "ZoFontGameBold",
    ["Antique"] = "ZoFontGameAntique",
    ["Stone Tablet"] = "ZoFontStoneTablet",
    ["Gamepad Medium"] = "ZoFontGamepad34",
    ["Gamepad Bold"] = "ZoFontGamepad42",
    ["Chat Font"] = "ZoFontChat",
}

local iconChoices = {
    "Bone pile",
    "Cracked skull",
}

-- Chemins natifs (SANS le "/" au début pour que le jeu les lise correctement)
local iconPaths = {
    ["Bone pile"] = "esoui/art/icons/quest_bone_pile_001.dds",
    ["Cracked skull"] = "esoui/art/icons/quest_cracked_skull.dds",
}

function TrueCorpseAlert:InitializeUI()
    local wm = WINDOW_MANAGER
    
    -- Fenêtre principale
    self.control = wm:CreateTopLevelWindow("TrueCorpseAlertUI")
    self.control:SetDimensions(1, 1)
    self.control:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    
    -- Label (Texte)
    self.numLabel = wm:CreateControl("TrueCorpseAlertLabel", self.control, CT_LABEL)
    
    -- Texture (Icone)
    self.iconTex = wm:CreateControl("TrueCorpseAlertIcon", self.control, CT_TEXTURE)
    
    -- Intégration HUD natif
    local fragment = ZO_HUDFadeSceneFragment:New(self.control)
    HUD_SCENE:AddFragment(fragment)
    HUD_UI_SCENE:AddFragment(fragment)
    if SCENE_MANAGER:GetScene("gamepad_hud") then
        SCENE_MANAGER:GetScene("gamepad_hud"):AddFragment(fragment)
    end
    
    self:ApplySettingsToUI()
    self:UpdateVisibility()
end

function TrueCorpseAlert:ApplySettingsToUI()
    local settings = self.settings
    
    if settings.displayType == "Text" then
        self.iconTex:SetHidden(true)
        self.numLabel:SetHidden(false)
        
        self.numLabel:SetText("CORPSE")
        self.numLabel:SetColor(settings.textColor.r, settings.textColor.g, settings.textColor.b, settings.textColor.a)
        self.numLabel:SetFont(fonts[settings.textFont] or "ZoFontGamepad42")
        self.numLabel:SetScale(settings.textScale / 100)
        
        self.numLabel:ClearAnchors()
        self.numLabel:SetAnchor(CENTER, GuiRoot, CENTER, settings.textX, settings.textY)
        
    elseif settings.displayType == "Icon" then
        self.numLabel:SetHidden(true)
        self.iconTex:SetHidden(false)
        
        local texturePath = iconPaths[settings.iconTexture] or iconPaths["Bone pile"]
        local size = 64 * (settings.iconScale / 100)
        
        self.iconTex:SetTexture(texturePath)
        self.iconTex:SetDimensions(size, size)
        
        self.iconTex:ClearAnchors()
        self.iconTex:SetAnchor(CENTER, GuiRoot, CENTER, settings.iconX, settings.iconY)
    end
end

function TrueCorpseAlert:UpdateVisibility()
    if self.testMode then
        self.control:SetHidden(false)
        return
    end

    -- S'affiche SI on a le sort équipé ET que IsSlotUsable dit qu'un cadavre est là ET qu'on est vivant
    local shouldShow = self.hasAbilitySlotted and self.corpseUsable and (not self.isDead)
    
    -- Vérification de l'option combat
    if self.settings.onlyInCombat then
        shouldShow = shouldShow and self.inCombat
    end
    
    self.control:SetHidden(not shouldShow)
end

function TrueCorpseAlert:CheckCorpseUsability()
    local isUsable = false
    local hasAbility = false
    local dead = IsUnitDead("player")
    local combat = IsUnitInCombat("player")
    
    if not dead then
        -- Barre d'action : Slots 3 à 8
        for slot = 3, 8 do
            local texture = GetSlotTexture(slot)
            if texture then
                local tex = string.lower(texture)
                -- On cherche le nom de l'icone du sort de base (indestructible peu importe le niveau du sort)
                if tex:find("necromancer_shockingsiphon") or 
                   tex:find("necromancer_bitterharvest") or 
                   tex:find("necromancer_restoringtether") then
                   
                    hasAbility = true
                    -- Le sort s'allume en jeu (IsSlotUsable = true) = Il y a un cadavre à exploiter
                    if IsSlotUsable(slot) then
                        isUsable = true
                        break
                    end
                end
            end
        end
    end
    
    -- Met à jour l'UI uniquement s'il y a un changement d'état
    if isUsable ~= self.corpseUsable or hasAbility ~= self.hasAbilitySlotted or dead ~= self.isDead or combat ~= self.inCombat then
        self.corpseUsable = isUsable
        self.hasAbilitySlotted = hasAbility
        self.isDead = dead
        self.inCombat = combat
        self:UpdateVisibility()
    end
end

function TrueCorpseAlert:CreateSettings()
    local LAM = LibAddonMenu2
    
    local panelData = {
        type = "panel",
        name = self.name,
        displayName = "|cff5900True Corpse Alert|r",
        author = self.author,
        version = self.version,
        registerForRefresh = true,
        registerForDefaults = true,
    }
    LAM:RegisterAddonPanel("TrueCorpseAlertOptions", panelData)
    
    local function IsTextDisabled() return self.settings.displayType ~= "Text" end
    local function IsIconDisabled() return self.settings.displayType ~= "Icon" end

    local optionsData = {
        {
            type = "button",
            name = "Toggle Test Mode",
            tooltip = "Displays the element on screen to adjust its position.",
            func = function() 
                self.testMode = not self.testMode
                self:UpdateVisibility()
            end,
        },
        {
            type = "dropdown",
            name = "Display Type",
            choices = {"Text", "Icon"},
            getFunc = function() return self.settings.displayType end,
            setFunc = function(value) self.settings.displayType = value; self:ApplySettingsToUI() end,
        },
        {
            type = "checkbox",
            name = "Show Only In Combat",
            tooltip = "If enabled, the alert will not show up when you are out of combat.",
            getFunc = function() return self.settings.onlyInCombat end,
            setFunc = function(value) self.settings.onlyInCombat = value; self:UpdateVisibility() end,
        },
        
        -- ====== TEXT ======
        { type = "header", name = "Text Settings" },
        {
            type = "slider", name = "X Position", min = -1000, max = 1000, step = 10,
            getFunc = function() return self.settings.textX end,
            setFunc = function(value) self.settings.textX = value; self:ApplySettingsToUI() end, disabled = IsTextDisabled,
        },
        {
            type = "slider", name = "Y Position", min = -1000, max = 1000, step = 10,
            getFunc = function() return self.settings.textY end,
            setFunc = function(value) self.settings.textY = value; self:ApplySettingsToUI() end, disabled = IsTextDisabled,
        },
        {
            type = "slider", name = "Scale (%)", min = 50, max = 400, step = 5,
            getFunc = function() return self.settings.textScale end,
            setFunc = function(value) self.settings.textScale = value; self:ApplySettingsToUI() end, disabled = IsTextDisabled,
        },
        {
            type = "colorpicker", name = "Text Color",
            getFunc = function() return self.settings.textColor.r, self.settings.textColor.g, self.settings.textColor.b, self.settings.textColor.a end,
            setFunc = function(r, g, b, a) self.settings.textColor = {r=r, g=g, b=b, a=a}; self:ApplySettingsToUI() end, disabled = IsTextDisabled,
        },
        {
            type = "dropdown", name = "Font",
            choices = {"Medium (Default)", "Bold", "Antique", "Stone Tablet", "Gamepad Medium", "Gamepad Bold", "Chat Font"},
            getFunc = function() return self.settings.textFont end,
            setFunc = function(value) self.settings.textFont = value; self:ApplySettingsToUI() end, disabled = IsTextDisabled,
        },
        
        -- ====== ICON ======
        { type = "header", name = "Icon Settings" },
        {
            type = "dropdown", name = "Icon Choice", choices = iconChoices,
            getFunc = function() return self.settings.iconTexture end,
            setFunc = function(value) self.settings.iconTexture = value; self:ApplySettingsToUI() end, disabled = IsIconDisabled,
        },
        {
            type = "slider", name = "X Position", min = -1000, max = 1000, step = 10,
            getFunc = function() return self.settings.iconX end,
            setFunc = function(value) self.settings.iconX = value; self:ApplySettingsToUI() end, disabled = IsIconDisabled,
        },
        {
            type = "slider", name = "Y Position", min = -1000, max = 1000, step = 10,
            getFunc = function() return self.settings.iconY end,
            setFunc = function(value) self.settings.iconY = value; self:ApplySettingsToUI() end, disabled = IsIconDisabled,
        },
        {
            type = "slider", name = "Scale (%)", min = 50, max = 400, step = 5,
            getFunc = function() return self.settings.iconScale end,
            setFunc = function(value) self.settings.iconScale = value; self:ApplySettingsToUI() end, disabled = IsIconDisabled,
        },
    }
    
    LAM:RegisterOptionControls("TrueCorpseAlertOptions", optionsData)
end

function TrueCorpseAlert.OnAddOnLoaded(event, addonName)
    if addonName ~= "TrueCorpseAlert" then return end
    EVENT_MANAGER:UnregisterForEvent(TrueCorpseAlert.name, EVENT_ADD_ON_LOADED)
    
    TrueCorpseAlert.settings = ZO_SavedVars:NewAccountWide("TrueCorpseAlertSavedVars", 1, nil, TrueCorpseAlert.defaultSettings)
    
    TrueCorpseAlert:InitializeUI()
    TrueCorpseAlert:CreateSettings()
    
    EVENT_MANAGER:RegisterForUpdate(TrueCorpseAlert.name .. "Loop", 250, function() TrueCorpseAlert:CheckCorpseUsability() end)
end

EVENT_MANAGER:RegisterForEvent(TrueCorpseAlert.name, EVENT_ADD_ON_LOADED, TrueCorpseAlert.OnAddOnLoaded)

SLASH_COMMANDS["/tca"] = function()
    TrueCorpseAlert.testMode = not TrueCorpseAlert.testMode
    TrueCorpseAlert:UpdateVisibility()
    if TrueCorpseAlert.testMode then
        d("|cff5900[True Corpse Alert]|r Test Mode: ENABLED")
    else
        d("|cff5900[True Corpse Alert]|r Test Mode: DISABLED")
    end
end