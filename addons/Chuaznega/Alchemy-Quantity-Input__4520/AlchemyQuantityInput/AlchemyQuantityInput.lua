-- ============================================================
-- AlchemyQuantityInput.lua  –  ESO Update 49 (API 101049)
-- ============================================================

local ADDON_NAME   = "AlchemyQuantityInput"
local topLevel     = nil
local editBox      = nil
local spinnerCtrl  = nil
local spinnerObj   = nil
local displayLabel = nil
local isUpdating   = false
local isSetup      = false
local lastValue    = 1   -- guarda último valor válido

local TEXT_R, TEXT_G, TEXT_B = 0.894, 0.859, 0.863  -- #e4dbdc

local SPINNER_CTRL_NAMES = {
    "ZO_AlchemyTopLevelSlotContainerSpinner",
    "ZO_AlchemyTopLevelCraftQuantitySpinner",
    "ZO_AlchemyTopLevelQuantitySpinner",
    "ZO_AlchemyCraftQuantitySpinner",
}

local function FindSpinnerControl()
    for _, name in ipairs(SPINNER_CTRL_NAMES) do
        if _G[name] then return _G[name] end
    end
    return nil
end

local function FindSpinnerObject(ctrl)
    if ctrl and ctrl.object then return ctrl.object end
    if ALCHEMY then
        for _, k in ipairs({"craftSpin","quantitySpinner","m_craftSpin"}) do
            if ALCHEMY[k] then return ALCHEMY[k] end
        end
        for _, v in pairs(ALCHEMY) do
            if type(v) == "table"
            and type(v.GetValue) == "function"
            and type(v.SetValue) == "function" then
                return v
            end
        end
    end
    return nil
end

local function GetCurrentValue()
    if spinnerObj then
        local ok, v = pcall(function() return spinnerObj:GetValue() end)
        if ok and tonumber(v) then return tonumber(v) end
    end
    if displayLabel then
        local n = tonumber(displayLabel:GetText())
        if n then return n end
    end
    return lastValue
end

local function SetEditText(val)
    lastValue = val
    isUpdating = true
    editBox:SetText(tostring(val))
    isUpdating = false
end

local function ApplyValueToSpinner(rawText)
    local value = tonumber(rawText)
    if not value or value < 1 then return end
    value = math.floor(value)
    lastValue = value
    if spinnerObj then
        isUpdating = true
        pcall(function() spinnerObj:SetValue(value) end)
        isUpdating = false
    end
    if displayLabel and not displayLabel:IsHidden() then
        displayLabel:SetHidden(true)
    end
end

local function ReleaseFocus()
    if editBox then
        editBox:LoseFocus()
    end
    if topLevel then
        topLevel:SetKeyboardEnabled(false)
    end
end

local function EnsureControls()
    if topLevel then return end

    topLevel = WINDOW_MANAGER:CreateTopLevelWindow("AlchemyQuantityInputTL")
    topLevel:SetDimensions(58, 28)
    topLevel:SetDrawLayer(DL_OVERLAY)
    topLevel:SetDrawLevel(7)
    topLevel:SetMouseEnabled(true)
    topLevel:SetMovable(false)
    topLevel:SetClampedToScreen(true)
    topLevel:SetHidden(true)
    -- Teclado desabilitado por padrão; só habilitamos ao clicar
    topLevel:SetKeyboardEnabled(false)

    local bg = WINDOW_MANAGER:CreateControl(nil, topLevel, CT_BACKDROP)
    bg:SetAnchorFill(topLevel)
    bg:SetCenterColor(0.08, 0.07, 0.09, 0.92)
    bg:SetEdgeColor(TEXT_R, TEXT_G, TEXT_B, 0.65)
    bg:SetEdgeTexture("", 1, 1, 1, 0)
    bg:SetMouseEnabled(false)

    editBox = WINDOW_MANAGER:CreateControl("AlchemyQuantityInputEB", topLevel, CT_EDITBOX)
    editBox:SetAnchor(TOPLEFT,     topLevel, TOPLEFT,     3,  2)
    editBox:SetAnchor(BOTTOMRIGHT, topLevel, BOTTOMRIGHT, -3, -2)
    editBox:SetFont("ZoFontWinH4")
    editBox:SetColor(TEXT_R, TEXT_G, TEXT_B, 1)
    editBox:SetMaxInputChars(6)
    editBox:SetMouseEnabled(true)

    editBox:SetHandler("OnTextChanged", function(self)
        if isUpdating then return end
        local txt = self:GetText()
        -- Só aplica se tiver dígito(s)
        if txt ~= "" and tonumber(txt) then
            ApplyValueToSpinner(txt)
        end
    end)

    editBox:SetHandler("OnFocusLost", function(self)
        -- Restaurar o último valor válido se o campo ficou vazio/inválido
        local v = tonumber(self:GetText())
        if not v or v < 1 then
            SetEditText(lastValue)
        end
        -- Devolver teclado ao jogo
        topLevel:SetKeyboardEnabled(false)
    end)

    editBox:SetHandler("OnEnter", function(self)
        local v = tonumber(self:GetText())
        if v and v >= 1 then lastValue = math.floor(v) end
        ReleaseFocus()
    end)

    editBox:SetHandler("OnEscapePressed", function(self)
        -- Cancelar: restaurar valor anterior
        SetEditText(lastValue)
        ReleaseFocus()
    end)

    -- Clique na caixa: habilitar teclado ANTES de TakeFocus
    topLevel:SetHandler("OnMouseDown", function()
        topLevel:SetKeyboardEnabled(true)
        editBox:TakeFocus()
    end)

    editBox:SetHandler("OnMouseDown", function(self)
        topLevel:SetKeyboardEnabled(true)
        self:TakeFocus()
    end)
end

local function RepositionTopLevel()
    if not topLevel or not spinnerCtrl then return end
    local ref = displayLabel or spinnerCtrl
    local l, t, r, b = ref:GetScreenRect()
    if not l then
        local cx, cy = spinnerCtrl:GetCenter()
        l, t = cx - 29, cy - 14
    end
    topLevel:ClearAnchors()
    topLevel:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, l, t)
end

local function SetupEditBox()
    spinnerCtrl = FindSpinnerControl()
    if not spinnerCtrl then return end

    spinnerObj   = FindSpinnerObject(spinnerCtrl)
    displayLabel = spinnerCtrl:GetNamedChild("Display")

    if displayLabel then
        displayLabel:SetHidden(true)
        displayLabel:SetMouseEnabled(false)
    end

    EnsureControls()
    RepositionTopLevel()
    topLevel:SetHidden(false)

    if spinnerObj and not spinnerObj._aqiPatched then
        local orig = spinnerObj.SetValue
        if type(orig) == "function" then
            spinnerObj.SetValue = function(self, value, ...)
                orig(self, value, ...)
                if not isUpdating and editBox then
                    local v = tonumber(value)
                    if v then SetEditText(math.floor(v)) end
                end
                if displayLabel then displayLabel:SetHidden(true) end
            end
            spinnerObj._aqiPatched = true
        end
    end

    local cur = GetCurrentValue()
    SetEditText(cur)
    isSetup = true
end

local function TeardownEditBox()
    isSetup = false
    ReleaseFocus()
    if topLevel then topLevel:SetHidden(true) end
    if displayLabel then displayLabel:SetHidden(false) end
end

local function TrySetupWithRetry(attempt)
    attempt = attempt or 1
    if isSetup then return end
    SetupEditBox()
    if not isSetup and attempt < 6 then
        zo_callLater(function() TrySetupWithRetry(attempt + 1) end, 250 * attempt)
    end
end

local function OnAlchemySceneStateChange(_, newState)
    if newState == SCENE_SHOWING then
        TrySetupWithRetry(1)
    elseif newState == SCENE_HIDING or newState == SCENE_HIDDEN then
        TeardownEditBox()
    end
end

local function OnCraftingStationInteract(_, craftingType)
    if craftingType == CRAFTING_TYPE_ALCHEMY then
        TrySetupWithRetry(1)
    end
end

SLASH_COMMANDS["/aqi"] = function()
    d("[AQI] === Diagnóstico ===")
    d("  Setup: " .. tostring(isSetup) .. " | lastValue: " .. tostring(lastValue))
    for _, name in ipairs(SPINNER_CTRL_NAMES) do
        d("  " .. (_G[name] and "[OK] " or "[--] ") .. name)
    end
    if spinnerCtrl then
        local cx, cy = spinnerCtrl:GetCenter()
        d("  Spinner: (" .. math.floor(cx) .. "," .. math.floor(cy) .. ")")
    end
    if editBox then
        d("  EditBox: '" .. editBox:GetText() .. "' mouse=" .. tostring(editBox:IsMouseEnabled()))
    end
    if topLevel then
        local l,t,r,b = topLevel:GetScreenRect()
        d("  TopLevel: hidden=" .. tostring(topLevel:IsHidden())
          .. " kb=" .. tostring(topLevel:IsKeyboardEnabled())
          .. " pos=(" .. math.floor(l or 0) .. "," .. math.floor(t or 0) .. ")")
    end
    d("[AQI] =================")
end

local function OnAddOnLoaded(_, addonName)
    if addonName ~= ADDON_NAME then return end

    local function RegisterScene()
        local scene = SCENE_MANAGER:GetScene("alchemy")
        if scene then
            scene:RegisterCallback("StateChange", OnAlchemySceneStateChange)
            return true
        end
        return false
    end

    if not RegisterScene() then
        EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_Login", EVENT_PLAYER_ACTIVATED,
            function()
                EVENT_MANAGER:UnregisterForEvent(ADDON_NAME .. "_Login", EVENT_PLAYER_ACTIVATED)
                RegisterScene()
            end)
    end

    EVENT_MANAGER:RegisterForEvent(
        ADDON_NAME, EVENT_CRAFTING_STATION_INTERACT, OnCraftingStationInteract
    )
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)