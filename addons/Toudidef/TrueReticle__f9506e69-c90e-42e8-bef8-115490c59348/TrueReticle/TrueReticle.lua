local TrueReticle = {}
local ADDON_NAME = "TrueReticle"
local savedVariables
local MyCustomReticle = nil

local defaults = {
    reticle_choice = "Default",
}

local reticle_choices = {
    "Default",
    "Cross",
    "green_cross",
    "Dot",
    "BigDot",
    "Circle",
    "Halo",

}

-- --- FONCTIONS DE SECURITE MODIFIEES ---

-- Cette fonction réduit la taille à 0 (invisible par taille)
local function SafeSetScaleZero(control)
    if control then -- Si le contrôle existe
        -- On ne change la taille que si elle n'est pas déjà à 0
        if control:GetScale() ~= 0 then
            control:SetScale(0)
        end
    end
end

-- Cette fonction remet la taille normale à 1
local function SafeSetScaleNormal(control)
    if control then
        if control:GetScale() ~= 1 then
            control:SetScale(1)
        end
        -- Par sécurité, on s'assure aussi que l'alpha est visible
        if control:GetAlpha() < 1 then
            control:SetAlpha(1)
        end
    end
end

-- Fonction pour changer le réticule
local function UpdateReticle(reticleName)
    if not MyCustomReticle then return end

    if reticleName == "Default" then
        -- Mode par défaut : on cache le nôtre, on restaure la taille normale des autres
        MyCustomReticle:SetHidden(true)
        
        SafeSetScaleNormal(ZO_ReticleContainerReticle)
        SafeSetScaleNormal(ZO_ReticleContainerCombatLock)
    else
        -- Mode Custom : on affiche le nôtre
        MyCustomReticle:SetHidden(false)
        
        local texturePath = string.format("/TrueReticle/reticles/%s.dds", string.lower(reticleName))
        MyCustomReticle:SetTexture(texturePath)
        
        -- On réduit la taille des réticules du jeu à 0
        SafeSetScaleZero(ZO_ReticleContainerReticle)      -- Le point central
        SafeSetScaleZero(ZO_ReticleContainerCombatLock)   -- Les crochets de combat
        
        -- NOTE: On ne touche pas à ZO_ReticleContainerStealthIcon (l'oeil reste visible)
    end
end

function TrueReticle:Initialize()
    savedVariables = ZO_SavedVars:NewAccountWide("TrueReticleSavedVars", 1, nil, defaults)

    -- Création de la texture
    MyCustomReticle = WINDOW_MANAGER:CreateControl("TrueReticle_Texture", ZO_ReticleContainer, CT_TEXTURE)
    MyCustomReticle:SetAnchor(CENTER, ZO_ReticleContainer, CENTER, 0, 0)
    MyCustomReticle:SetDimensions(32, 32)
    MyCustomReticle:SetDrawTier(DT_HIGH)

    self:InitializeSettingsMenu()

    -- --- BOUCLE DE CONTROLE ---
    -- On vérifie régulièrement (toutes les 50ms) si le jeu a essayé de remettre la taille.
    -- Si c'est le cas, on force la taille à 0.
    EVENT_MANAGER:RegisterForUpdate(ADDON_NAME.."_Loop", 50, function()
        if savedVariables.reticle_choice ~= "Default" then
            
            -- 1. Le réticule principal -> Taille 0
            SafeSetScaleZero(ZO_ReticleContainerReticle)
            
            -- 2. Les crochets de cible (Combat Lock) -> Taille 0
            SafeSetScaleZero(ZO_ReticleContainerCombatLock)
            
            -- L'œil de discrétion n'est pas listé ici, donc il reste visible.
        end
    end)

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_PLAYER_ACTIVATED, function()
        UpdateReticle(savedVariables.reticle_choice)
    end)
end

function TrueReticle:InitializeSettingsMenu()
    local panelData = {
        type = "panel",
        name = "TrueReticle",
        displayName = "TrueReticle Settings",
        author = "Toudidef",
        version = "1.0.0",
        slashCommand = "/truereticle",
        registerForRefresh = true,
    }

    local optionsPanel = LibAddonMenu2:RegisterAddonPanel("TrueReticlePanel", panelData)

    local optionsData = {
        {
            type = "dropdown",
            name = "Reticle Style",
            choices = reticle_choices,
            getFunc = function() return savedVariables.reticle_choice end,
            setFunc = function(choice)
                savedVariables.reticle_choice = choice
                UpdateReticle(choice)
            end,
            width = "full",
        },
    }

    LibAddonMenu2:RegisterOptionControls("TrueReticlePanel", optionsData)
end

function TrueReticle.OnAddOnLoaded(event, addonName)
    if addonName == ADDON_NAME then
        TrueReticle:Initialize()
        EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
    end
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, TrueReticle.OnAddOnLoaded)