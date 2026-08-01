Chalutier =
{
    name            = "Chalutier",
    currentState    = 0,
    angle           = 0,
    swimming        = false,
    SavedVariables  = nil,
    state           = {},
    defaults        = {}
}
Chalutier.defaults  = {
    enabled = true,
    posx        = 0,
    posy        = 0,
    anchor      = 3,
    anchorRel   = 3,
    colors      = {
        [ 0] = { icon = "idle", text = "Idle",  r = 1, g = 1, b = 1, a = 1 },
        [ 1] = { icon = "idle", text = "Looking Away", r = 0.3, g = 0, b = 0.3, a = 1 },
        [ 2] = { icon = "looking", text = "Looking at Fishing Hole", r = 0.3961, g = 0.2706, b = 0, a = 1 },
        [ 3] = { icon = "depleted", text = "Fishing Hole Depleted", r = 0, g = 0.3, b = 0.3, a = 1 },
        [ 5] = { icon = "nobait", text = "No Bait Equipped", r = 1, g = 0.8, b = 0, a = 1 },
        [ 6] = { icon = "fishing", text = "Fishing", r = 0.2980, g = 0.6118, b = 0.8392, a = 1 },
        [ 7] = { icon = "reelin", text = "Reel In!", r = 0, g = 0.8, b = 0, a = 1 },
        [ 8] = { icon = "loot", text = "Loot Menu", r = 0, g = 0, b = 0.8, a = 1 },
        [ 9] = { icon = "invfull", text = "Inventory Full", r = 0, g = 0, b = 0.2, a = 1 },
        [14] = { icon = "fight", text = "Fighting", r = 0.8, g = 0, b = 0, a = 1 },
        [15] = { icon = "dead", text = "Dead", r = 0.2, g = 0.2, b = 0.2, a = 1 }
    }
}

--local logger = LibDebugLogger(Chalutier.name)
local LAM2 = LibAddonMenu2

local function _setState()
    Chalutier.UI.blocInfo:SetColor(Chalutier.SavedVariables.colors[FishingStateMachine:getState()].r, Chalutier.SavedVariables.colors[FishingStateMachine:getState()].g, Chalutier.SavedVariables.colors[FishingStateMachine:getState()].b, Chalutier.SavedVariables.colors[FishingStateMachine:getState()].a)
    Chalutier.UI.Icon:SetTexture("Chalutier/textures/" .. Chalutier.SavedVariables.colors[FishingStateMachine:getState()].icon .. ".dds")
end

local function _createUI()
    Chalutier.UI = WINDOW_MANAGER:CreateControl(nil, GuiRoot, CT_TOPLEVELCONTROL)
    Chalutier.UI:SetMouseEnabled(true)
    Chalutier.UI:SetClampedToScreen(true)
    Chalutier.UI:SetMovable(true)
    Chalutier.UI:SetDimensions(64, 92)
    Chalutier.UI:SetDrawLevel(0)
    Chalutier.UI:SetDrawLayer(DL_MAX_VALUE-1)
    Chalutier.UI:SetDrawTier(DT_MAX_VALUE-1)
    Chalutier.UI:SetHidden(false)

    Chalutier.UI:ClearAnchors()
    Chalutier.UI:SetAnchor(Chalutier.SavedVariables.anchorRel, GuiRoot, Chalutier.SavedVariables.anchor, Chalutier.SavedVariables.posx, Chalutier.SavedVariables.posy)

    Chalutier.UI.blocInfo = WINDOW_MANAGER:CreateControl(nil, Chalutier.UI, CT_TEXTURE)
    Chalutier.UI.blocInfo:SetDimensions(64, 6)
    Chalutier.UI.blocInfo:SetAnchor(TOP, Chalutier.UI, TOP, 0, blocInfo)
    Chalutier.UI.blocInfo:SetHidden(false)
    Chalutier.UI.blocInfo:SetDrawLevel(0)
    Chalutier.UI.blocInfo:SetDrawLayer(DL_MAX_VALUE)
    Chalutier.UI.blocInfo:SetDrawTier(DT_MAX_VALUE)

    Chalutier.UI.Icon = WINDOW_MANAGER:CreateControl(nil, Chalutier.UI, CT_TEXTURE)
    Chalutier.UI.Icon:SetBlendMode(TEX_BLEND_MODE_ALPHA)
    Chalutier.UI.Icon:SetDimensions(64, 64)
    Chalutier.UI.Icon:SetAnchor(TOPLEFT, Chalutier.UI, TOPLEFT, 0, 18)
    Chalutier.UI.Icon:SetHidden(false)
    Chalutier.UI.Icon:SetDrawLevel(0)
    Chalutier.UI.Icon:SetDrawLayer(DL_MAX_VALUE)
    Chalutier.UI.Icon:SetDrawTier(DT_MAX_VALUE)

    _setState()

    Chalutier.UI:SetHandler("OnMoveStop", function()
        _, Chalutier.SavedVariables.anchorRel, _, Chalutier.SavedVariables.anchor, Chalutier.SavedVariables.posx, Chalutier.SavedVariables.posy, _ = Chalutier.UI:GetAnchor()
    end, Chalutier.name)

    Chalutier.fragment = ZO_HUDFadeSceneFragment:New(Chalutier.UI)
    HUD_SCENE:AddFragment(Chalutier.fragment)
    HUD_UI_SCENE:AddFragment(Chalutier.fragment)
    LOOT_SCENE:AddFragment(Chalutier.fragment)
end


local function _createMenu()
    local panelName = "ChalutierSettingsPanel"

    local panelData = {
        type = "panel",
        name = Chalutier.name,
        displayName = Chalutier.name,
        author = "Provision, Sem",
        registerForRefresh = true,
        registerForDefaults = true,
    }
    local panel = LAM2:RegisterAddonPanel(panelName, panelData)


    panel:SetHandler("OnEffectivelyHidden", function()
        _, Chalutier.SavedVariables.anchorRel, _, Chalutier.SavedVariables.anchor, Chalutier.SavedVariables.posx, Chalutier.SavedVariables.posy, _ = Chalutier.UI:GetAnchor()
        if Chalutier.SavedVariables.enabled == true then
            HUD_SCENE:AddFragment(Chalutier.fragment)
            HUD_UI_SCENE:AddFragment(Chalutier.fragment)
            LOOT_SCENE:AddFragment(Chalutier.fragment)
        else
            HUD_SCENE:RemoveFragment(Chalutier.fragment)
            HUD_UI_SCENE:RemoveFragment(Chalutier.fragment)
            LOOT_SCENE:RemoveFragment(Chalutier.fragment)
            Chalutier.UI:SetHidden(true)
        end
    end)

    local optionsData = {
        {
            type = "checkbox",
            name = "Set Chalutier visibility:",
            default = Chalutier.SavedVariables.enabled,
            disabled = false,
            getFunc = function() return Chalutier.SavedVariables.enabled end,
            setFunc = function(value)
                if Chalutier.SavedVariables.enabled == true then
                    HUD_SCENE:RemoveFragment(Chalutier.fragment)
                    HUD_UI_SCENE:RemoveFragment(Chalutier.fragment)
                    LOOT_SCENE:RemoveFragment(Chalutier.fragment)
                    Chalutier.SavedVariables.enabled = false
                else
                    HUD_SCENE:AddFragment(Chalutier.fragment)
                    HUD_UI_SCENE:AddFragment(Chalutier.fragment)
                    LOOT_SCENE:AddFragment(Chalutier.fragment)
                    Chalutier.SavedVariables.enabled = true
                end
            end
        },
        {
            type = "button",
            name = "Show Chalutier now",
            func = function()
                HUD_UI_SCENE:AddFragment(Chalutier.fragment)
                Chalutier.UI:SetHidden(false)
            end,
            width = "half",
            requiresReload = false,
        },
        {
            type = "button",
            name = "Move to top left corner",
            default = true,
            disabled = false,
            func = function()
                Chalutier.SavedVariables.anchor, Chalutier.SavedVariables.anchorRel = 3, 3
                Chalutier.SavedVariables.posx, Chalutier.SavedVariables.posy = 0, 0
                Chalutier.UI:ClearAnchors()
                Chalutier.UI:SetAnchor(Chalutier.SavedVariables.anchorRel, GuiRoot, Chalutier.SavedVariables.anchor, Chalutier.SavedVariables.posx, Chalutier.SavedVariables.posy)
            end,
            width = "half",
            requiresReload = false,
        },
        {
            type = "header",
            name = "State Colors"
        },
    }

    for k,v in pairs(Chalutier.defaults.colors) do
        local def = Chalutier.defaults.colors[k]
        local sav = Chalutier.SavedVariables.colors[k]
        optionsData[#optionsData + 1] = {
            type = "colorpicker",
            name = def.text,
            getFunc = function()
                return sav.r, sav.g, sav.b, sav.a
            end,
            setFunc = function(r,g,b,a)
                sav.r, sav.g, sav.b, sav.a = r, g, b, a
                Chalutier.SavedVariables.colors[k] = sav
                Chalutier.UI.blocInfo:SetColor(sav.r, sav.g, sav.b, sav.a)
            end,
            default = {["r"] = def.r, ["g"] = def.g, ["b"] = def.b, ["a"] = def.a},
            requiresReload = true,
        }
    end

    LAM2:RegisterOptionControls(panelName, optionsData)
end

local function _onAddOnLoad(eventCode, addOnName)
    if (Chalutier.name ~= addOnName) then return end
    EVENT_MANAGER:UnregisterForEvent(Chalutier.name, EVENT_ADD_ON_LOADED)

    Chalutier.SavedVariables = ZO_SavedVars:NewAccountWide("ChalutierSV", 2, nil, Chalutier.defaults)
    Chalutier.CallbackManager = ZO_CallbackObject:New()

    _createUI()
    _createMenu()

    FishingStateMachine:registerOnStateChange(_setState)
end

EVENT_MANAGER:RegisterForEvent(Chalutier.name, EVENT_ADD_ON_LOADED, function(...) _onAddOnLoad(...) end)
