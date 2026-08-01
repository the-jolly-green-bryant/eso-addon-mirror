SoraUltimatePair = SoraUltimatePair or {}

local SUP = SoraUltimatePair
local ADDON_NAME = "SoraUltimatePair"
local SAVED_VERSION = 61

local defaults = {
    hidden = false,
    locked = false,
    hideDefaultUltimate = true,
    updateIntervalMs = 1000,
    panels = {
        front = { left = nil, top = nil },
        back = { left = nil, top = nil },
    },
}

local WINDOW_WIDTH = 318
local WINDOW_HEIGHT = 78

local BAR_WIDTH = 118
local BAR_HEIGHT = 26

local VALUE_X = 78
local VALUE_Y = 33
local VALUE_WIDTH = 100
local VALUE_GAP = 8
local BAR_X = VALUE_X + VALUE_WIDTH + VALUE_GAP

local TITLE_FONT = "$(BOLD_FONT)|18|thin-outline"
local VALUE_FONT = "$(BOLD_FONT)|25|thin-outline"
local SMALL_FONT = "$(BOLD_FONT)|15|thin-outline"

local PANEL = {
    back = {
        title = "[ B ]",
        badge = "裏",
        yOffset = -44,
        color = {
            bg = {0.045, 0.020, 0.070, 0.90},
            edge = {0.86, 0.38, 1.00, 1.00},
            title = {1.00, 0.78, 1.00, 1.00},
            fill = {0.64, 0.24, 0.95, 0.92},
            ready = {1.00, 0.50, 1.00, 0.96},
            accent = {0.78, 0.20, 1.00, 0.95},
        },
    },
    front = {
        title = "[ F ]",
        badge = "表",
        yOffset = 44,
        color = {
            bg = {0.075, 0.035, 0.00, 0.90},
            edge = {1.00, 0.62, 0.12, 1.00},
            title = {1.00, 0.74, 0.30, 1.00},
            fill = {0.92, 0.50, 0.08, 0.92},
            ready = {1.00, 0.66, 0.10, 0.96},
            accent = {1.00, 0.47, 0.05, 0.95},
        },
    },
}

local function Chat(message)
    d("|cFFD37ASoraUltimatePair|r: " .. tostring(message))
end

local function Trim(value)
    if not value then return "" end
    return tostring(value):match("^%s*(.-)%s*$") or ""
end

local function GetPetMissingText()
    local lang = ""

    if GetCVar then
        local ok, result = pcall(GetCVar, "language.2")
        if ok and result then
            lang = string.lower(tostring(result))
        end
    end

    -- Keep Japanese only for Japanese clients.
    -- Chinese and all other clients use English here.
    if lang:find("ja", 1, true) or lang:find("jp", 1, true) then
        return "[ペットが出ていない]"
    end

    return "[Pet is not summoned]"
end

local function FormatUltimateValue(current, cost)
    current = tonumber(current) or 0
    cost = tonumber(cost) or 0

    current = math.floor(current + 0.5)
    cost = math.floor(cost + 0.5)

    if cost <= 0 then
        if current > 999 then
            return tostring(current) .. "/???"
        end
        return string.format("%3d/???", current)
    end

    if current > 999 or cost > 999 then
        return tostring(current) .. "/" .. tostring(cost)
    end

    return string.format("%3d/%3d", current, cost)
end

local function GetScreenSizeSafe()
    local w, h = GuiRoot:GetDimensions()
    w = tonumber(w) or 1920
    h = tonumber(h) or 1080
    return w, h
end

local function ClampPosition(left, top)
    local screenW, screenH = GetScreenSizeSafe()

    left = tonumber(left)
    top = tonumber(top)

    if not left or not top then
        return nil, nil
    end

    if left < -WINDOW_WIDTH or top < -WINDOW_HEIGHT or left > screenW or top > screenH then
        return nil, nil
    end

    local maxLeft = math.max(0, screenW - WINDOW_WIDTH)
    local maxTop = math.max(0, screenH - WINDOW_HEIGHT)

    if left < 0 then left = 0 end
    if top < 0 then top = 0 end
    if left > maxLeft then left = maxLeft end
    if top > maxTop then top = maxTop end

    return math.floor(left + 0.5), math.floor(top + 0.5)
end

function SUP.RegisterBindingStrings()
    ZO_CreateStringId("SI_BINDING_NAME_SORA_ULTIMATE_PAIR_TOGGLE", "Sora Ultimate Pair: Show/Hide")
    ZO_CreateStringId("SI_BINDING_NAME_SORA_ULTIMATE_PAIR_CENTER", "Sora Ultimate Pair: Center")
end

local function GetCurrentUltimate()
    if not GetUnitPower then return 0 end

    local ok, current = pcall(function()
        return GetUnitPower("player", POWERTYPE_ULTIMATE)
    end)

    if not ok then
        current = 0
    end

    current = tonumber(current) or 0
    return math.floor(current + 0.5)
end

local function GetActiveHotbarCategory()
    local activeCategory = HOTBAR_CATEGORY_PRIMARY

    if GetActiveWeaponPairInfo then
        local ok, pair = pcall(GetActiveWeaponPairInfo)
        if ok then
            if ACTIVE_WEAPON_PAIR_BACKUP ~= nil and pair == ACTIVE_WEAPON_PAIR_BACKUP then
                activeCategory = HOTBAR_CATEGORY_BACKUP
            elseif ACTIVE_WEAPON_PAIR_MAIN ~= nil and pair == ACTIVE_WEAPON_PAIR_MAIN then
                activeCategory = HOTBAR_CATEGORY_PRIMARY
            end
        end
    end

    return activeCategory
end

local function GetBackbarCategory()
    local activeCategory = GetActiveHotbarCategory()
    if activeCategory == HOTBAR_CATEGORY_BACKUP then
        return HOTBAR_CATEGORY_PRIMARY
    end
    return HOTBAR_CATEGORY_BACKUP
end

local function TryGetSlotBoundId(slotIndex, hotbarCategory)
    if not GetSlotBoundId then return 0 end
    local ok, boundId = pcall(GetSlotBoundId, slotIndex, hotbarCategory)
    if ok and boundId and boundId ~= 0 then
        return boundId
    end
    return 0
end

local function GetUltimateSlotInfo(kind)
    local ultimateSlot = ACTION_BAR_ULTIMATE_SLOT_INDEX or 7
    local category = HOTBAR_CATEGORY_PRIMARY

    if kind == "front" then
        category = GetActiveHotbarCategory()
    else
        category = GetBackbarCategory()
    end

    -- ESO's ultimate button is commonly slot 8 even when ACTION_BAR_ULTIMATE_SLOT_INDEX is 7.
    local slotIndex = ultimateSlot + 1
    local abilityId = TryGetSlotBoundId(slotIndex, category)

    if not abilityId or abilityId == 0 then
        slotIndex = ultimateSlot
        abilityId = TryGetSlotBoundId(slotIndex, category)
    end

    return slotIndex, category, abilityId or 0
end

local function TryGetAbilityCost(abilityId)
    if not abilityId or abilityId == 0 then return 0 end
    if not GetAbilityCost then return 0 end

    local function ExtractCost(ok, a, b, c)
        if not ok then return 0 end
        if type(a) == "number" and a > 0 then return math.floor(a + 0.5) end
        if type(b) == "number" and b > 0 then return math.floor(b + 0.5) end
        if type(c) == "number" and c > 0 then return math.floor(c + 0.5) end
        return 0
    end

    if COMBAT_MECHANIC_FLAGS_ULTIMATE ~= nil then
        local ok, a, b, c = pcall(GetAbilityCost, abilityId, COMBAT_MECHANIC_FLAGS_ULTIMATE)
        local cost = ExtractCost(ok, a, b, c)
        if cost > 0 then return cost end
    end

    local ok, a, b, c = pcall(GetAbilityCost, abilityId)
    local cost = ExtractCost(ok, a, b, c)
    if cost > 0 then return cost end

    return 0
end

local function TryGetSlotCost(slotIndex, category)
    if not slotIndex or not category then return 0 end
    if not GetSlotAbilityCost then return 0 end

    local ok, a, b, c = pcall(GetSlotAbilityCost, slotIndex, category)
    if not ok then return 0 end

    if type(a) == "number" and a > 0 then return math.floor(a + 0.5) end
    if type(b) == "number" and b > 0 then return math.floor(b + 0.5) end
    if type(c) == "number" and c > 0 then return math.floor(c + 0.5) end

    return 0
end

local function IsWardenBearIcon(icon)
    icon = string.lower(tostring(icon or ""))
    return icon:find("ability_warden_018", 1, true) ~= nil
end

local function GetUltimateInfo(kind)
    local slotIndex, category, abilityId = GetUltimateSlotInfo(kind)
    local cost = TryGetAbilityCost(abilityId)

    local name = ""
    local icon = ""

    -- Prefer the actual slotted data. This is important for persistent pet ultimates.
    if slotIndex and category and GetSlotName then
        local ok, result = pcall(GetSlotName, slotIndex, category)
        if ok and result then name = result end
    end

    if slotIndex and category and GetSlotTexture then
        local ok, result = pcall(GetSlotTexture, slotIndex, category)
        if ok and result and result ~= "" then icon = result end
    end

    if (not name or name == "") and abilityId and abilityId ~= 0 and GetAbilityName then
        local ok, result = pcall(GetAbilityName, abilityId)
        if ok and result then name = result end
    end

    if (not icon or icon == "") and abilityId and abilityId ~= 0 and GetAbilityIcon then
        local ok, result = pcall(GetAbilityIcon, abilityId)
        if ok and result and result ~= "" then icon = result end
    end

    if cost <= 0 then
        cost = TryGetSlotCost(slotIndex, category)
    end

    local wardenBearMissingPet = cost <= 0 and IsWardenBearIcon(icon)

    return abilityId or 0, cost or 0, name or "", icon or "", wardenBearMissingPet
end
local function GetUltimateSlotInfoForCategory(category)
    local ultimateSlot = ACTION_BAR_ULTIMATE_SLOT_INDEX or 7
    category = category or HOTBAR_CATEGORY_PRIMARY

    -- ESO's ultimate button is commonly slot 8 even when ACTION_BAR_ULTIMATE_SLOT_INDEX is 7.
    local slotIndex = ultimateSlot + 1
    local abilityId = TryGetSlotBoundId(slotIndex, category)

    if not abilityId or abilityId == 0 then
        slotIndex = ultimateSlot
        abilityId = TryGetSlotBoundId(slotIndex, category)
    end

    return slotIndex, category, abilityId or 0
end

local function GetUltimateInfoForCategory(category)
    local slotIndex, hotbarCategory, abilityId = GetUltimateSlotInfoForCategory(category)
    local cost = TryGetAbilityCost(abilityId)

    local name = ""
    local icon = ""

    if slotIndex and hotbarCategory and GetSlotName then
        local ok, result = pcall(GetSlotName, slotIndex, hotbarCategory)
        if ok and result then name = result end
    end

    if slotIndex and hotbarCategory and GetSlotTexture then
        local ok, result = pcall(GetSlotTexture, slotIndex, hotbarCategory)
        if ok and result and result ~= "" then icon = result end
    end

    if (not name or name == "") and abilityId and abilityId ~= 0 and GetAbilityName then
        local ok, result = pcall(GetAbilityName, abilityId)
        if ok and result then name = result end
    end

    if (not icon or icon == "") and abilityId and abilityId ~= 0 and GetAbilityIcon then
        local ok, result = pcall(GetAbilityIcon, abilityId)
        if ok and result and result ~= "" then icon = result end
    end

    if cost <= 0 then
        cost = TryGetSlotCost(slotIndex, hotbarCategory)
    end

    local wardenBearMissingPet = cost <= 0 and IsWardenBearIcon(icon)

    return abilityId or 0, cost or 0, name or "", icon or "", wardenBearMissingPet
end

-- SUP_COLOR_FOLLOWING_HELPERS_V4
-- The displayed [ F ] / [ B ] panels still use the original current/inactive bar behavior.
-- Color seeding, however, uses the actual fixed ESO bars:
-- primary/main-hand Ultimate = amber, backup Ultimate = violet.
-- This prevents /reloadui on the backup bar from teaching the wrong color.
local function SUP_NormalizeUltimateIconStem(icon)
    if type(icon) ~= "string" or icon == "" then return "" end

    icon = icon:gsub("\\", "/")
    icon = string.lower(icon)

    local fileName = icon:match("([^/]+)$")
    if not fileName then return "" end

    local stem = fileName:gsub("%.dds$", "")

    local changed = true
    while changed do
        local old = stem

        stem = stem:gsub("_a$", "")
        stem = stem:gsub("_b$", "")
        stem = stem:gsub("_c$", "")

        stem = stem:gsub("_purple$", "")
        stem = stem:gsub("_red$", "")
        stem = stem:gsub("_blue$", "")
        stem = stem:gsub("_green$", "")
        stem = stem:gsub("_gold$", "")
        stem = stem:gsub("_orange$", "")
        stem = stem:gsub("_white$", "")
        stem = stem:gsub("_black$", "")
        stem = stem:gsub("_pink$", "")
        stem = stem:gsub("_yellow$", "")
        stem = stem:gsub("_cyan$", "")
        stem = stem:gsub("_lilac$", "")
        stem = stem:gsub("_violet$", "")

        changed = stem ~= old
    end

    return stem
end

local function SUP_GetUltimateColorKey(abilityId, abilityName, icon)
    abilityId = tonumber(abilityId) or 0

    if abilityId ~= 0 then
        return "id:" .. tostring(abilityId)
    end

    local stem = SUP_NormalizeUltimateIconStem(icon)
    if stem ~= "" then
        return "icon:" .. stem
    end

    if type(abilityName) == "string" and abilityName ~= "" then
        return "name:" .. abilityName
    end

    return nil
end

local function SUP_ColorByName(colorName, fallback)
    if colorName == "amber" then
        return PANEL.front.color
    elseif colorName == "violet" then
        return PANEL.back.color
    end

    return fallback
end

local function SUP_SeedActualBarUltimateColors()
    if not SUP.saved then return end

    local primaryAbilityId, _, primaryName, primaryIcon = GetUltimateInfoForCategory(HOTBAR_CATEGORY_PRIMARY)
    local backupAbilityId, _, backupName, backupIcon = GetUltimateInfoForCategory(HOTBAR_CATEGORY_BACKUP)

    local primaryKey = SUP_GetUltimateColorKey(primaryAbilityId, primaryName, primaryIcon)
    local backupKey = SUP_GetUltimateColorKey(backupAbilityId, backupName, backupIcon)

    if not primaryKey or not backupKey or primaryKey == backupKey then
        return
    end

    SUP.saved.ultimateIdentityColorMapV4 = SUP.saved.ultimateIdentityColorMapV4 or {}
    local map = SUP.saved.ultimateIdentityColorMapV4

    -- Actual fixed bar assignment always wins for the currently slotted pair.
    -- This is intentional so stale saved data cannot survive a reload or a bar edit.
    map[primaryKey] = "amber"
    map[backupKey] = "violet"
end

local function SUP_ResolveUltimateIdentityColor(abilityId, abilityName, icon, fallback)
    if not SUP.saved then return fallback end

    local key = SUP_GetUltimateColorKey(abilityId, abilityName, icon)
    if not key then return fallback end

    local map = SUP.saved.ultimateIdentityColorMapV4
    if not map then return fallback end

    return SUP_ColorByName(map[key], fallback)
end


function SUP.IsGameplayHudVisible()
    if SUP.forceVisibleForEdit then
        return true
    end

    if SUP.saved and SUP.saved.hidden then
        return false
    end

    if IsGameCameraActive then
        local ok, active = pcall(IsGameCameraActive)
        if ok and active == false then
            return false
        end
    end

    if SCENE_MANAGER and SCENE_MANAGER.GetCurrentScene then
        local scene = SCENE_MANAGER:GetCurrentScene()
        if scene and scene.GetName then
            local sceneName = scene:GetName()
            if sceneName and sceneName ~= "" then
                if sceneName ~= "hud" and sceneName ~= "hudui" then
                    return false
                end
            end
        end
    end

    return true
end

function SUP.ApplyVisibility()
    local shouldShow = SUP.IsGameplayHudVisible()

    if SUP.panels then
        for _, panel in pairs(SUP.panels) do
            if panel.window then
                panel.window:SetHidden(not shouldShow)
            end
        end
    end

    return shouldShow
end

local function SUP_GetUpdateIntervalMs()
    local value = nil

    if SUP.saved then
        value = tonumber(SUP.saved.updateIntervalMs)
    end

    if not value then
        value = defaults.updateIntervalMs
    end

    if value < 100 then value = 100 end
    if value > 2000 then value = 2000 end

    return math.floor(value + 0.5)
end

function SUP.RegisterUpdateLoop()
    EVENT_MANAGER:UnregisterForUpdate(ADDON_NAME .. "_Update")
    EVENT_MANAGER:RegisterForUpdate(ADDON_NAME .. "_Update", SUP_GetUpdateIntervalMs(), function()
        SUP.Update()
    end)
end

function SUP.SetUpdateIntervalMs(value)
    value = tonumber(value) or defaults.updateIntervalMs

    if value < 100 then value = 100 end
    if value > 2000 then value = 2000 end

    value = math.floor(value + 0.5)

    if SUP.saved then
        SUP.saved.updateIntervalMs = value
    end

    if SUP.RegisterUpdateLoop then
        SUP.RegisterUpdateLoop()
    end

    if SUP.Update then
        SUP.Update()
    end
end

function SUP.SetHidden(hidden)
    SUP.saved.hidden = hidden and true or false

    if SUP.saved.hidden then
        SUP.forceVisibleForEdit = false
    end

    SUP.ApplyVisibility()
end

function SUP.Toggle()
    SUP.forceVisibleForEdit = false
    SUP.SetHidden(not SUP.saved.hidden)
end

function SUP.ApplyLock()
    local canMove = not SUP.saved.locked or SUP.forceVisibleForEdit

    if SUP.panels then
        for _, panel in pairs(SUP.panels) do
            if panel.window then
                panel.window:SetMovable(canMove)
                panel.window:SetMouseEnabled(canMove)
            end
        end
    end
end

function SUP.ToggleLock()
    SUP.saved.locked = not SUP.saved.locked
    SUP.ApplyLock()

    if SUP.saved.locked then
        Chat("固定しました。 /sult lock で解除できます。")
    else
        Chat("移動できるようにしました。/sult edit 中にドラッグできます。")
    end
end

function SUP.ToggleEditMode()
    SUP.forceVisibleForEdit = not SUP.forceVisibleForEdit

    if SUP.forceVisibleForEdit then
        SUP.saved.hidden = false
        Chat("編集モードです。位置を調整したら /sult edit で戻してね。")
    else
        Chat("編集モードを終了しました。")
    end

    SUP.ApplyLock()
    SUP.ApplyVisibility()
end

function SUP.SetDefaultPosition(kind, save)
    local panel = SUP.panels and SUP.panels[kind]
    if not panel or not panel.window then return end

    local config = PANEL[kind]

    panel.window:ClearAnchors()
    panel.window:SetAnchor(CENTER, GuiRoot, CENTER, 0, config.yOffset)

    if save and SUP.saved and SUP.saved.panels and SUP.saved.panels[kind] then
        SUP.saved.panels[kind].left = math.floor(panel.window:GetLeft() + 0.5)
        SUP.saved.panels[kind].top = math.floor(panel.window:GetTop() + 0.5)
    end
end

function SUP.ApplySavedPosition(kind)
    local panel = SUP.panels and SUP.panels[kind]
    if not panel or not panel.window then return end

    local savedPos = SUP.saved and SUP.saved.panels and SUP.saved.panels[kind]
    local left, top = nil, nil

    if savedPos then
        left, top = ClampPosition(savedPos.left, savedPos.top)
    end

    panel.window:ClearAnchors()

    if left and top then
        panel.window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
        SUP.saved.panels[kind].left = left
        SUP.saved.panels[kind].top = top
    else
        SUP.SetDefaultPosition(kind, true)
    end
end

function SUP.SaveCurrentPosition(kind)
    local panel = SUP.panels and SUP.panels[kind]
    if not panel or not panel.window then return end

    SUP.saved.panels[kind] = SUP.saved.panels[kind] or { left = nil, top = nil }

    local left = math.floor(panel.window:GetLeft() + 0.5)
    local top = math.floor(panel.window:GetTop() + 0.5)

    left, top = ClampPosition(left, top)

    if left and top then
        SUP.saved.panels[kind].left = left
        SUP.saved.panels[kind].top = top
    else
        SUP.SetDefaultPosition(kind, true)
    end
end

function SUP.ResetPositions()
    if not SUP.saved.panels then
        SUP.saved.panels = {}
    end

    SUP.saved.panels.front = { left = nil, top = nil }
    SUP.saved.panels.back = { left = nil, top = nil }

    SUP.SetDefaultPosition("back", true)
    SUP.SetDefaultPosition("front", true)
    SUP.ApplyVisibility()

    Chat("表/裏ULTを中央付近に戻しました。")
end

local function CreateLabel(parent, text, font, x, y, width, height)
    local label = WINDOW_MANAGER:CreateControl(nil, parent, CT_LABEL)
    label:SetAnchor(TOPLEFT, parent, TOPLEFT, x, y)
    label:SetDimensions(width, height)
    label:SetFont(font)
    label:SetColor(1, 1, 1, 1)
    label:SetText(text)
    label:SetDrawLayer(DL_OVERLAY)
    return label
end

function SUP.SetPanelRoundedFrameColor(panel, r, g, b, a)
    if not panel then return end

    a = a or 1.0

    local function SetPiece(control, alphaMul)
        if control and control.SetCenterColor then
            control:SetCenterColor(r, g, b, a * (alphaMul or 1.0))
        end
        if control and control.SetEdgeColor then
            control:SetEdgeColor(0, 0, 0, 0)
        end
    end

    SetPiece(panel.roundTop, 1.00)
    SetPiece(panel.roundBottom, 1.00)
    SetPiece(panel.roundLeft, 1.00)
    SetPiece(panel.roundRight, 1.00)

    SetPiece(panel.roundCornerTLH, 0.75)
    SetPiece(panel.roundCornerTLV, 0.75)
    SetPiece(panel.roundCornerTRH, 0.75)
    SetPiece(panel.roundCornerTRV, 0.75)
    SetPiece(panel.roundCornerBLH, 0.75)
    SetPiece(panel.roundCornerBLV, 0.75)
    SetPiece(panel.roundCornerBRH, 0.75)
    SetPiece(panel.roundCornerBRV, 0.75)
end
function SUP.CreatePanel(kind)
    local config = PANEL[kind]
    local color = config.color
    SUP.HideRoundedFrame(panel) -- keep square frame

    local panel = {
        kind = kind,
        config = config,
    }

    local win = WINDOW_MANAGER:CreateTopLevelWindow("SoraUltimatePair_" .. kind)
    panel.window = win

    win:SetDimensions(WINDOW_WIDTH, WINDOW_HEIGHT)
    win:SetAnchor(CENTER, GuiRoot, CENTER, 0, config.yOffset)
    win:SetMovable(not SUP.saved.locked)
    win:SetMouseEnabled(not SUP.saved.locked)
    win:SetClampedToScreen(true)
    win:SetHidden(true)

    win:SetHandler("OnMoveStop", function()
        SUP.SaveCurrentPosition(kind)
        zo_callLater(function() SUP.BringFrontPanelToTop() end, 0)
    end)

    local bg = WINDOW_MANAGER:CreateControl(nil, win, CT_BACKDROP)
    bg:SetAnchorFill(win)
    bg:SetCenterColor(color.bg[1], color.bg[2], color.bg[3], color.bg[4])
    bg:SetEdgeColor(color.edge[1], color.edge[2], color.edge[3], color.edge[4])
    bg:SetEdgeTexture("", 1, 1, 1, 1)
    panel.bg = bg

    -- SUP_FRONT_READY_GLOW_CREATE
    -- 発動可能時の表側専用グロー。裏側では表示しない。
    local readyGlow = WINDOW_MANAGER:CreateControl(nil, win, CT_BACKDROP)
    readyGlow:SetAnchor(TOPLEFT, win, TOPLEFT, -2, -2)
    readyGlow:SetDimensions(WINDOW_WIDTH + 4, WINDOW_HEIGHT + 4)
    readyGlow:SetCenterColor(1.00, 0.70, 0.08, 0.08)
    readyGlow:SetEdgeColor(1.00, 0.78, 0.10, 0.95)
    readyGlow:SetEdgeTexture("", 1, 1, 1, 1)
    readyGlow:SetDrawLayer(DL_BACKGROUND)
    readyGlow:SetHidden(true)
    panel.readyGlow = readyGlow

    local readyGlowLine = WINDOW_MANAGER:CreateControl(nil, win, CT_BACKDROP)
    readyGlowLine:SetAnchor(TOPLEFT, win, TOPLEFT, 0, 0)
    readyGlowLine:SetDimensions(WINDOW_WIDTH, 3)
    readyGlowLine:SetCenterColor(1.00, 0.86, 0.20, 0.95)
    readyGlowLine:SetEdgeColor(0, 0, 0, 0)
    readyGlowLine:SetEdgeTexture("", 1, 1, 1, 1)
    readyGlowLine:SetDrawLayer(DL_OVERLAY)
    readyGlowLine:SetHidden(true)
    panel.readyGlowLine = readyGlowLine

    -- SUP_FRONT_READY_GLOW_STRONG_CREATE
    -- 外側にふわっと広がる3層グロー
    local readyGlowFar = WINDOW_MANAGER:CreateControl(nil, win, CT_BACKDROP)
    readyGlowFar:SetAnchor(TOPLEFT, win, TOPLEFT, -10, -10)
    readyGlowFar:SetDimensions(WINDOW_WIDTH + 20, WINDOW_HEIGHT + 20)
    readyGlowFar:SetCenterColor(1.00, 0.70, 0.08, 0.035)
    readyGlowFar:SetEdgeColor(1.00, 0.72, 0.08, 0.34)
    readyGlowFar:SetEdgeTexture("", 1, 1, 1, 1)
    readyGlowFar:SetDrawLayer(DL_BACKGROUND)
    readyGlowFar:SetHidden(true)
    panel.readyGlowFar = readyGlowFar

    local readyGlowMid = WINDOW_MANAGER:CreateControl(nil, win, CT_BACKDROP)
    readyGlowMid:SetAnchor(TOPLEFT, win, TOPLEFT, -7, -7)
    readyGlowMid:SetDimensions(WINDOW_WIDTH + 14, WINDOW_HEIGHT + 14)
    readyGlowMid:SetCenterColor(1.00, 0.70, 0.08, 0.055)
    readyGlowMid:SetEdgeColor(1.00, 0.76, 0.10, 0.54)
    readyGlowMid:SetEdgeTexture("", 1, 1, 1, 1)
    readyGlowMid:SetDrawLayer(DL_BACKGROUND)
    readyGlowMid:SetHidden(true)
    panel.readyGlowMid = readyGlowMid

    local readyGlowNear = WINDOW_MANAGER:CreateControl(nil, win, CT_BACKDROP)
    readyGlowNear:SetAnchor(TOPLEFT, win, TOPLEFT, -4, -4)
    readyGlowNear:SetDimensions(WINDOW_WIDTH + 8, WINDOW_HEIGHT + 8)
    readyGlowNear:SetCenterColor(1.00, 0.70, 0.08, 0.075)
    readyGlowNear:SetEdgeColor(1.00, 0.84, 0.18, 0.78)
    readyGlowNear:SetEdgeTexture("", 1, 1, 1, 1)
    readyGlowNear:SetDrawLayer(DL_BACKGROUND)
    readyGlowNear:SetHidden(true)
    panel.readyGlowNear = readyGlowNear

    local accent = WINDOW_MANAGER:CreateControl(nil, win, CT_BACKDROP)
    accent:SetAnchor(TOPLEFT, win, TOPLEFT, 3, 3)
    accent:SetDimensions(5, WINDOW_HEIGHT - 6)
    accent:SetCenterColor(color.accent[1], color.accent[2], color.accent[3], color.accent[4])
    accent:SetEdgeColor(color.edge[1], color.edge[2], color.edge[3], 1)
    accent:SetEdgeTexture("", 1, 1, 1, 1)
    panel.accent = accent

    local topLine = WINDOW_MANAGER:CreateControl(nil, win, CT_BACKDROP)
    topLine:SetAnchor(TOPLEFT, win, TOPLEFT, 3, 3)
    topLine:SetDimensions(WINDOW_WIDTH - 6, 2)
    topLine:SetCenterColor(color.edge[1], color.edge[2], color.edge[3], 0.80)
    topLine:SetEdgeColor(0, 0, 0, 0)
    topLine:SetEdgeTexture("", 1, 1, 1, 1)
    panel.topLine = topLine

    -- SUP_ROUNDED_FRAME_PATCH
    -- 外枠を四辺に分けて、角を少し抜く疑似角丸フレーム
    local roundTop = WINDOW_MANAGER:CreateControl(nil, win, CT_BACKDROP)
    roundTop:SetAnchor(TOPLEFT, win, TOPLEFT, 11, 1)
    roundTop:SetDimensions(WINDOW_WIDTH - 22, 2)
    roundTop:SetCenterColor(color.edge[1], color.edge[2], color.edge[3], 0.95)
    roundTop:SetEdgeColor(0, 0, 0, 0)
    roundTop:SetEdgeTexture("", 1, 1, 1, 1)
    panel.roundTop = roundTop

    local roundBottom = WINDOW_MANAGER:CreateControl(nil, win, CT_BACKDROP)
    roundBottom:SetAnchor(BOTTOMLEFT, win, BOTTOMLEFT, 11, -1)
    roundBottom:SetDimensions(WINDOW_WIDTH - 22, 2)
    roundBottom:SetCenterColor(color.edge[1], color.edge[2], color.edge[3], 0.95)
    roundBottom:SetEdgeColor(0, 0, 0, 0)
    roundBottom:SetEdgeTexture("", 1, 1, 1, 1)
    panel.roundBottom = roundBottom

    local roundLeft = WINDOW_MANAGER:CreateControl(nil, win, CT_BACKDROP)
    roundLeft:SetAnchor(TOPLEFT, win, TOPLEFT, 1, 11)
    roundLeft:SetDimensions(2, WINDOW_HEIGHT - 22)
    roundLeft:SetCenterColor(color.edge[1], color.edge[2], color.edge[3], 0.95)
    roundLeft:SetEdgeColor(0, 0, 0, 0)
    roundLeft:SetEdgeTexture("", 1, 1, 1, 1)
    panel.roundLeft = roundLeft

    local roundRight = WINDOW_MANAGER:CreateControl(nil, win, CT_BACKDROP)
    roundRight:SetAnchor(TOPRIGHT, win, TOPRIGHT, -1, 11)
    roundRight:SetDimensions(2, WINDOW_HEIGHT - 22)
    roundRight:SetCenterColor(color.edge[1], color.edge[2], color.edge[3], 0.95)
    roundRight:SetEdgeColor(0, 0, 0, 0)
    roundRight:SetEdgeTexture("", 1, 1, 1, 1)
    panel.roundRight = roundRight

    local roundCornerTLH = WINDOW_MANAGER:CreateControl(nil, win, CT_BACKDROP)
    roundCornerTLH:SetAnchor(TOPLEFT, win, TOPLEFT, 5, 4)
    roundCornerTLH:SetDimensions(7, 2)
    roundCornerTLH:SetCenterColor(color.edge[1], color.edge[2], color.edge[3], 0.70)
    roundCornerTLH:SetEdgeColor(0, 0, 0, 0)
    roundCornerTLH:SetEdgeTexture("", 1, 1, 1, 1)
    panel.roundCornerTLH = roundCornerTLH

    local roundCornerTLV = WINDOW_MANAGER:CreateControl(nil, win, CT_BACKDROP)
    roundCornerTLV:SetAnchor(TOPLEFT, win, TOPLEFT, 4, 5)
    roundCornerTLV:SetDimensions(2, 7)
    roundCornerTLV:SetCenterColor(color.edge[1], color.edge[2], color.edge[3], 0.70)
    roundCornerTLV:SetEdgeColor(0, 0, 0, 0)
    roundCornerTLV:SetEdgeTexture("", 1, 1, 1, 1)
    panel.roundCornerTLV = roundCornerTLV

    local roundCornerTRH = WINDOW_MANAGER:CreateControl(nil, win, CT_BACKDROP)
    roundCornerTRH:SetAnchor(TOPRIGHT, win, TOPRIGHT, -5, 4)
    roundCornerTRH:SetDimensions(7, 2)
    roundCornerTRH:SetCenterColor(color.edge[1], color.edge[2], color.edge[3], 0.70)
    roundCornerTRH:SetEdgeColor(0, 0, 0, 0)
    roundCornerTRH:SetEdgeTexture("", 1, 1, 1, 1)
    panel.roundCornerTRH = roundCornerTRH

    local roundCornerTRV = WINDOW_MANAGER:CreateControl(nil, win, CT_BACKDROP)
    roundCornerTRV:SetAnchor(TOPRIGHT, win, TOPRIGHT, -4, 5)
    roundCornerTRV:SetDimensions(2, 7)
    roundCornerTRV:SetCenterColor(color.edge[1], color.edge[2], color.edge[3], 0.70)
    roundCornerTRV:SetEdgeColor(0, 0, 0, 0)
    roundCornerTRV:SetEdgeTexture("", 1, 1, 1, 1)
    panel.roundCornerTRV = roundCornerTRV

    local roundCornerBLH = WINDOW_MANAGER:CreateControl(nil, win, CT_BACKDROP)
    roundCornerBLH:SetAnchor(BOTTOMLEFT, win, BOTTOMLEFT, 5, -4)
    roundCornerBLH:SetDimensions(7, 2)
    roundCornerBLH:SetCenterColor(color.edge[1], color.edge[2], color.edge[3], 0.70)
    roundCornerBLH:SetEdgeColor(0, 0, 0, 0)
    roundCornerBLH:SetEdgeTexture("", 1, 1, 1, 1)
    panel.roundCornerBLH = roundCornerBLH

    local roundCornerBLV = WINDOW_MANAGER:CreateControl(nil, win, CT_BACKDROP)
    roundCornerBLV:SetAnchor(BOTTOMLEFT, win, BOTTOMLEFT, 4, -5)
    roundCornerBLV:SetDimensions(2, 7)
    roundCornerBLV:SetCenterColor(color.edge[1], color.edge[2], color.edge[3], 0.70)
    roundCornerBLV:SetEdgeColor(0, 0, 0, 0)
    roundCornerBLV:SetEdgeTexture("", 1, 1, 1, 1)
    panel.roundCornerBLV = roundCornerBLV

    local roundCornerBRH = WINDOW_MANAGER:CreateControl(nil, win, CT_BACKDROP)
    roundCornerBRH:SetAnchor(BOTTOMRIGHT, win, BOTTOMRIGHT, -5, -4)
    roundCornerBRH:SetDimensions(7, 2)
    roundCornerBRH:SetCenterColor(color.edge[1], color.edge[2], color.edge[3], 0.70)
    roundCornerBRH:SetEdgeColor(0, 0, 0, 0)
    roundCornerBRH:SetEdgeTexture("", 1, 1, 1, 1)
    panel.roundCornerBRH = roundCornerBRH

    local roundCornerBRV = WINDOW_MANAGER:CreateControl(nil, win, CT_BACKDROP)
    roundCornerBRV:SetAnchor(BOTTOMRIGHT, win, BOTTOMRIGHT, -4, -5)
    roundCornerBRV:SetDimensions(2, 7)
    roundCornerBRV:SetCenterColor(color.edge[1], color.edge[2], color.edge[3], 0.70)
    roundCornerBRV:SetEdgeColor(0, 0, 0, 0)
    roundCornerBRV:SetEdgeTexture("", 1, 1, 1, 1)
    panel.roundCornerBRV = roundCornerBRV

    SUP.SetPanelRoundedFrameColor(panel, color.edge[1], color.edge[2], color.edge[3], color.edge[4])

    local iconBackdrop = WINDOW_MANAGER:CreateControl(nil, win, CT_BACKDROP)
    iconBackdrop:SetAnchor(TOPLEFT, win, TOPLEFT, 7, 11)
    iconBackdrop:SetDimensions(56, 56)
    iconBackdrop:SetCenterColor(0, 0, 0, 0.72)
    iconBackdrop:SetEdgeColor(color.edge[1], color.edge[2], color.edge[3], 0.85)
    iconBackdrop:SetEdgeTexture("", 1, 1, 1, 1)
    iconBackdrop:SetHidden(true)
    panel.iconBackdrop = iconBackdrop

    local icon = WINDOW_MANAGER:CreateControl(nil, win, CT_TEXTURE)
    icon:SetAnchor(TOPLEFT, win, TOPLEFT, 14, 18)
    icon:SetDimensions(42, 42)
    icon:SetDrawLayer(DL_OVERLAY)
    icon:SetHidden(true)
    panel.icon = icon

    local iconFrameOuter = WINDOW_MANAGER:CreateControl(nil, win, CT_BACKDROP)
    iconFrameOuter:SetAnchor(TOPLEFT, win, TOPLEFT, 6, 10)
    iconFrameOuter:SetDimensions(58, 58)
    iconFrameOuter:SetCenterColor(0, 0, 0, 0.00)
    iconFrameOuter:SetEdgeColor(color.edge[1], color.edge[2], color.edge[3], 1.00)
    iconFrameOuter:SetEdgeTexture("", 1, 1, 1, 1)
    iconFrameOuter:SetDrawLayer(DL_CONTROLS)
    iconFrameOuter:SetHidden(true)
    panel.iconFrameOuter = iconFrameOuter

    local iconFrameInner = WINDOW_MANAGER:CreateControl(nil, win, CT_BACKDROP)
    iconFrameInner:SetAnchor(TOPLEFT, win, TOPLEFT, 9, 13)
    iconFrameInner:SetDimensions(52, 52)
    iconFrameInner:SetCenterColor(0, 0, 0, 0.00)
    iconFrameInner:SetEdgeColor(color.edge[1], color.edge[2], color.edge[3], 0.00)
    iconFrameInner:SetEdgeTexture("", 1, 1, 1, 1)
    iconFrameInner:SetDrawLayer(DL_CONTROLS)
    iconFrameInner:SetHidden(true)
    panel.iconFrameInner = iconFrameInner

    local title = CreateLabel(win, config.title, TITLE_FONT, VALUE_X, 6, 225, 24)
    title:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    title:SetColor(color.title[1], color.title[2], color.title[3], color.title[4])
    panel.title = title

    local text = CreateLabel(win, "000/000", VALUE_FONT, VALUE_X, VALUE_Y, VALUE_WIDTH, 32)
    text:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    text:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    panel.text = text

    local barBg = WINDOW_MANAGER:CreateControl(nil, win, CT_BACKDROP)
    barBg:SetAnchor(TOPLEFT, win, TOPLEFT, BAR_X, 36)
    barBg:SetDimensions(BAR_WIDTH, BAR_HEIGHT)
    barBg:SetCenterColor(0.08, 0.08, 0.10, 0.95)
    barBg:SetEdgeColor(color.edge[1], color.edge[2], color.edge[3], 0.90)
    barBg:SetEdgeTexture("", 1, 1, 1, 1)
    panel.barBg = barBg

    local fill = WINDOW_MANAGER:CreateControl(nil, barBg, CT_BACKDROP)
    fill:SetAnchor(LEFT, barBg, LEFT, 0, 0)
    fill:SetDimensions(1, BAR_HEIGHT)
    fill:SetCenterColor(color.fill[1], color.fill[2], color.fill[3], color.fill[4])
    fill:SetEdgeColor(0, 0, 0, 0)
    fill:SetEdgeTexture("", 1, 1, 1, 1)
    panel.fill = fill

    SUP.panels[kind] = panel
    SUP.ApplySavedPosition(kind)

    -- SUP_RESTORE_SQUARE_HIDE_ROUNDED
    -- 疑似角丸パーツはギザギザ感が出るので非表示。普通の四角外枠に戻す。
    local roundedParts = {
        panel.roundTop,
        panel.roundBottom,
        panel.roundLeft,
        panel.roundRight,
        panel.roundCornerTLH,
        panel.roundCornerTLV,
        panel.roundCornerTRH,
        panel.roundCornerTRV,
        panel.roundCornerBLH,
        panel.roundCornerBLV,
        panel.roundCornerBRH,
        panel.roundCornerBRV,
    }

    for _, control in ipairs(roundedParts) do
        if control then
            control:SetHidden(true)
            control:SetAlpha(0)
        end
    end
end

function SUP.SetPanelIconVisible(panel, visible, texture)
    if texture and texture ~= "" and panel.icon then
        panel.icon:SetTexture(texture)
    end

    if panel.icon then panel.icon:SetHidden(not visible) end
    if panel.iconBackdrop then panel.iconBackdrop:SetHidden(not visible) end
    if panel.iconFrameOuter then panel.iconFrameOuter:SetHidden(not visible) end
    if panel.iconFrameInner then panel.iconFrameInner:SetHidden(true) end
end

function SUP.HideRoundedFrame(panel)
    if not panel then return end

    local roundedParts = {
        panel.roundTop,
        panel.roundBottom,
        panel.roundLeft,
        panel.roundRight,
        panel.roundCornerTLH,
        panel.roundCornerTLV,
        panel.roundCornerTRH,
        panel.roundCornerTRV,
        panel.roundCornerBLH,
        panel.roundCornerBLV,
        panel.roundCornerBRH,
        panel.roundCornerBRV,
    }

    for _, control in ipairs(roundedParts) do
        if control then
            control:SetHidden(true)
            control:SetAlpha(0)
        end
    end
end
function SUP.UpdatePanel(kind)
    local panel = SUP.panels and SUP.panels[kind]
    if not panel then return end

    local config = PANEL[kind]
    local color = config.color
    SUP.HideRoundedFrame(panel) -- keep square frame

    local current = GetCurrentUltimate()
    local abilityId, cost, abilityName, icon = GetUltimateInfo(kind)

    if abilityId == 0 or cost == 0 then
        panel.title:SetText(config.title .. " Not found")
        panel.title:SetFont(SMALL_FONT)
        panel.text:SetText(FormatUltimateValue(current, 0))
        panel.fill:SetHidden(true)
        SUP.SetPanelIconVisible(panel, false)
        panel.bg:SetEdgeColor(0.65, 0.45, 0.45, 0.9)
        return
    end

    panel.title:SetFont(TITLE_FONT)

    local ratio = current / cost
    if ratio < 0 then ratio = 0 end
    if ratio > 1 then ratio = 1 end

    local fillWidth = math.floor(BAR_WIDTH * ratio)

    if fillWidth < 1 then
        panel.fill:SetHidden(true)
    else
        panel.fill:SetHidden(false)
        panel.fill:SetDimensions(fillWidth, BAR_HEIGHT)
    end

    SUP.SetPanelIconVisible(panel, icon ~= nil and icon ~= "", icon)

    if abilityName and abilityName ~= "" then
        panel.title:SetText(config.title .. ": " .. abilityName)
    else
        panel.title:SetText(config.title)
    end

    panel.text:SetText(FormatUltimateValue(current, cost))

    if current >= cost then
        panel.bg:SetEdgeColor(color.ready[1], color.ready[2], color.ready[3], 1.0)
        panel.fill:SetCenterColor(color.ready[1], color.ready[2], color.ready[3], color.ready[4])
    else
        panel.bg:SetEdgeColor(color.edge[1], color.edge[2], color.edge[3], color.edge[4])
        panel.fill:SetCenterColor(color.fill[1], color.fill[2], color.fill[3], color.fill[4])
    end
end

SUP.defaultOriginalAlpha = SUP.defaultOriginalAlpha or {}
SUP.defaultOriginalHidden = SUP.defaultOriginalHidden or {}
SUP.defaultOriginalMouse = SUP.defaultOriginalMouse or {}
SUP.defaultControlCache = SUP.defaultControlCache or nil
SUP.defaultNextScanMs = SUP.defaultNextScanMs or 0

local function AddControlIfValid(list, seen, control)
    if control and (control.SetHidden or control.SetAlpha) and not seen[control] then
        seen[control] = true
        table.insert(list, control)
    end
end

local function AddNamedChild(list, seen, control, childName)
    if control and control.GetNamedChild then
        local ok, child = pcall(function()
            return control:GetNamedChild(childName)
        end)
        if ok and child then
            AddControlIfValid(list, seen, child)
        end
    end
end

local function AddControlAndChildren(list, seen, control)
    AddControlIfValid(list, seen, control)

    local childNames = {
        "Value",
        "Duration",
        "BG",
        "Frame",
        "Icon",
        "CooldownIcon",
        "Button",
        "Text",
        "Status",
        "Glow",
        "ActivationHighlight",
    }

    for _, childName in ipairs(childNames) do
        AddNamedChild(list, seen, control, childName)
    end
end

local function AddPossibleControlTree(list, seen, seenObjects, obj, depth)
    if not obj or depth > 4 then return end

    local objType = type(obj)

    if objType == "userdata" then
        AddControlAndChildren(list, seen, obj)
        return
    end

    if objType ~= "table" then return end

    if obj.SetHidden or obj.SetAlpha then
        AddControlAndChildren(list, seen, obj)
    end

    if seenObjects[obj] then return end
    seenObjects[obj] = true

    local keys = {
        "control",
        "button",
        "slot",
        "slotControl",
        "overlay",
        "icon",
        "Icon",
        "cooldownIcon",
        "CooldownIcon",
        "frame",
        "Frame",
        "duration",
        "Duration",
        "value",
        "Value",
        "bg",
        "BG",
        "status",
        "Status",
        "glow",
        "Glow",
        "activationHighlight",
        "ActivationHighlight",
    }

    for _, key in ipairs(keys) do
        local ok, child = pcall(function()
            return obj[key]
        end)
        if ok and child then
            AddPossibleControlTree(list, seen, seenObjects, child, depth + 1)
        end
    end
end

local function AddNamedControl(list, seen, seenObjects, controlName)
    if not controlName or controlName == "" then return end

    if GetControl then
        local ok, control = pcall(GetControl, controlName)
        if ok and control then
            AddControlAndChildren(list, seen, control)
            AddPossibleControlTree(list, seen, seenObjects, control, 0)
        end
    end

    if _G and _G[controlName] then
        AddControlAndChildren(list, seen, _G[controlName])
        AddPossibleControlTree(list, seen, seenObjects, _G[controlName], 0)
    end
end

function SUP.CollectDefaultUltimateControls()
    local now = 0

    if GetFrameTimeMilliseconds then
        now = GetFrameTimeMilliseconds()
    elseif GetGameTimeSeconds then
        now = GetGameTimeSeconds() * 1000
    end

    if SUP.defaultControlCache and now < (SUP.defaultNextScanMs or 0) then
        return SUP.defaultControlCache
    end

    local list = {}
    local seen = {}
    local seenObjects = {}

    local ultimateSlot = 8

    if ZO_ActionBar_GetButton then
        pcall(function()
            AddPossibleControlTree(list, seen, seenObjects, ZO_ActionBar_GetButton(ultimateSlot), 0)
        end)
    end

    if ACTION_BAR_ASSIGNABLE_BUTTONS then
        AddPossibleControlTree(list, seen, seenObjects, ACTION_BAR_ASSIGNABLE_BUTTONS[ultimateSlot], 0)
    end

    local standardNames = {
        "ActionButton8",
        "ActionButton8Icon",
        "ActionButton8CooldownIcon",
        "ActionButton8BG",
        "ActionButton8Status",
        "ActionButton8ActivationHighlight",
        "ActionButton8Glow",
        "ActionButton8Frame",

        "ZO_ActionBar1Button8",
        "ZO_ActionBar1Button8Icon",
        "ZO_ActionBar1Button8CooldownIcon",
        "ZO_ActionBar1Button8BG",
        "ZO_ActionBar1Button8Status",
        "ZO_ActionBar1Button8ActivationHighlight",
        "ZO_ActionBar1Button8Glow",
        "ZO_ActionBar1Button8Frame",

        "ZO_ActionButton8",
        "ZO_ActionButton8Icon",
        "ZO_ActionButton8CooldownIcon",

        "ZO_ActionBarUltimateButton",
        "ZO_ActionBar1UltimateButton",
        "ZO_UltimateAbility",
        "ZO_UltimateAbilityButton",
        "ZO_ActionBar1Ultimate",
        "ZO_ActionBarUltimate",

        "FancyActionBarButton8",
        "FancyActionBarButton8Icon",
        "FancyActionBarButton8CooldownIcon",
        "FancyActionBar_Button8",
        "FancyActionBar_Button8Icon",
        "FancyActionBar_Button8CooldownIcon",
        "FAB_ActionButton8",
        "FAB_ActionButton8Icon",
        "FAB_ActionButton8CooldownIcon",
    }

    for _, name in ipairs(standardNames) do
        AddNamedControl(list, seen, seenObjects, name)
    end

    if FancyActionBar then
        if FancyActionBar.constants and FancyActionBar.constants.ult then
            if FancyActionBar.constants.ult.value then
                FancyActionBar.constants.ult.value.show = false
            end
            if FancyActionBar.constants.ult.duration then
                FancyActionBar.constants.ult.duration.show = false
            end
        end

        local fabUltSlots = {
            8,
            "8",
            "ult",
            "ultimate",
            "ULT",
            "Ultimate",
            "playerUltimate",
            "frontUltimate",
        }

        local fabTables = {
            "buttons",
            "activeButtons",
            "overlays",
            "ultOverlays",
            "ultOverlay",
            "ultimateOverlay",
            "ultimate",
            "ult",
        }

        for _, tableName in ipairs(fabTables) do
            local ok, tableValue = pcall(function()
                return FancyActionBar[tableName]
            end)

            if ok and tableValue then
                for _, slotKey in ipairs(fabUltSlots) do
                    local okSlot, slotValue = pcall(function()
                        return tableValue[slotKey]
                    end)

                    if okSlot and slotValue then
                        AddPossibleControlTree(list, seen, seenObjects, slotValue, 0)
                    end
                end
            end
        end
    end

    SUP.defaultControlCache = list
    SUP.defaultNextScanMs = now + 250

    return list
end

local function SetControlInvisible(control, invisible)
    if not control then return end

    if invisible then
        if SUP.defaultOriginalAlpha[control] == nil and control.GetAlpha then
            local ok, alpha = pcall(function() return control:GetAlpha() end)
            SUP.defaultOriginalAlpha[control] = (ok and alpha ~= nil) and alpha or 1
        end

        if SUP.defaultOriginalHidden[control] == nil and control.IsHidden then
            local ok, hidden = pcall(function() return control:IsHidden() end)
            SUP.defaultOriginalHidden[control] = (ok and hidden ~= nil) and hidden or false
        end

        if SUP.defaultOriginalMouse[control] == nil and control.IsMouseEnabled then
            local ok, mouse = pcall(function() return control:IsMouseEnabled() end)
            SUP.defaultOriginalMouse[control] = (ok and mouse ~= nil) and mouse or true
        end

        pcall(function() control:SetAlpha(0) end)
        pcall(function() control:SetHidden(true) end)
        pcall(function() control:SetMouseEnabled(false) end)
    else
        local alpha = SUP.defaultOriginalAlpha[control]
        if alpha == nil then alpha = 1 end

        local hidden = SUP.defaultOriginalHidden[control]
        if hidden == nil then hidden = false end

        local mouse = SUP.defaultOriginalMouse[control]
        if mouse == nil then mouse = true end

        pcall(function() control:SetAlpha(alpha) end)
        pcall(function() control:SetHidden(hidden) end)
        pcall(function() control:SetMouseEnabled(mouse) end)
    end
end

function SUP.ApplyDefaultUltimateVisibility()
    local hide = SUP.saved and SUP.saved.hideDefaultUltimate

    local ok, controls = pcall(SUP.CollectDefaultUltimateControls)
    if not ok then
        SUP.defaultControlCache = {}
        return
    end

    for _, control in ipairs(controls or {}) do
        pcall(SetControlInvisible, control, hide)
    end
end


-- SUP_EVENT_DRIVEN_DEFAULT_HIDE
-- Standard/FAB+ Ultimate hiding is applied on load/hotbar changes, not every UI update.
function SUP.RefreshDefaultUltimateVisibility(reason)
    SUP.defaultControlCache = nil

    if SUP.ApplyDefaultUltimateVisibility then
        SUP.ApplyDefaultUltimateVisibility()
    end
end

function SUP.QueueDefaultUltimateVisibilityRefresh(reason)
    if not SUP.saved or not SUP.saved.hideDefaultUltimate then
        return
    end

    -- Some action bar controls are recreated slightly after UI/hotbar events.
    zo_callLater(function() SUP.RefreshDefaultUltimateVisibility(reason) end, 100)
    zo_callLater(function() SUP.RefreshDefaultUltimateVisibility(reason) end, 500)
    zo_callLater(function() SUP.RefreshDefaultUltimateVisibility(reason) end, 1500)
end

function SUP.ToggleDefaultUltimate()
    SUP.saved.hideDefaultUltimate = not SUP.saved.hideDefaultUltimate
    SUP.defaultControlCache = nil
    SUP.ApplyDefaultUltimateVisibility()
    SUP.QueueDefaultUltimateVisibilityRefresh("toggle")

    if SUP.saved.hideDefaultUltimate then
        Chat("標準/FAB+側のULT表示を隠します。")
    else
        Chat("標準/FAB+側のULT表示を戻します。")
    end
end


function SUP.SetFrontReadyGlow(panel, enabled, color)
    if not panel then return end

    local function HideAll()
        if panel.readyGlow then panel.readyGlow:SetHidden(true) end
        if panel.readyGlowLine then panel.readyGlowLine:SetHidden(true) end
        if panel.readyGlowFar then panel.readyGlowFar:SetHidden(true) end
        if panel.readyGlowMid then panel.readyGlowMid:SetHidden(true) end
        if panel.readyGlowNear then panel.readyGlowNear:SetHidden(true) end
    end

    -- 表側だけ光らせる。裏側では絶対に非表示。
    if panel.kind ~= "front" then
        HideAll()
        return
    end

    if not enabled then
        HideAll()
        return
    end

    color = color or PANEL.front.color

    local pulse = 0.78
    local pulseSlow = 0.72

    if GetFrameTimeMilliseconds then
        local t = GetFrameTimeMilliseconds()
        pulse = 0.76 + 0.24 * math.sin(t / 180)
        pulseSlow = 0.70 + 0.24 * math.sin(t / 340)
    end

    local r = color.ready[1]
    local g = color.ready[2]
    local b = color.ready[3]

    -- 範囲は狭いまま、面の明るさを上げる。境界線は透明。
    if panel.readyGlowFar then
        panel.readyGlowFar:SetHidden(false)
        panel.readyGlowFar:SetAlpha(0.82 + 0.16 * pulseSlow)
        panel.readyGlowFar:SetCenterColor(r, g, b, 0.105)
        panel.readyGlowFar:SetEdgeColor(r, g, b, 0.00)
    end

    if panel.readyGlowMid then
        panel.readyGlowMid:SetHidden(false)
        panel.readyGlowMid:SetAlpha(0.90 + 0.10 * pulse)
        panel.readyGlowMid:SetCenterColor(r, g, b, 0.135)
        panel.readyGlowMid:SetEdgeColor(r, g, b, 0.00)
    end

    if panel.readyGlowNear then
        panel.readyGlowNear:SetHidden(false)
        panel.readyGlowNear:SetAlpha(0.96 + 0.04 * pulse)
        panel.readyGlowNear:SetCenterColor(r, g, b, 0.165)
        panel.readyGlowNear:SetEdgeColor(r, g, b, 0.00)
    end

    if panel.readyGlow then
        panel.readyGlow:SetHidden(false)
        panel.readyGlow:SetAlpha(1.00)
        panel.readyGlow:SetCenterColor(r, g, b, 0.180)
        panel.readyGlow:SetEdgeColor(r, g, b, 0.00)
    end

    -- 上ラインはかなり明るくする
    if panel.readyGlowLine then
        panel.readyGlowLine:SetHidden(false)
        panel.readyGlowLine:SetAlpha(1.00)
        panel.readyGlowLine:SetCenterColor(r, g, b, 1.00)
        panel.readyGlowLine:SetEdgeColor(0, 0, 0, 0)
        panel.readyGlowLine:SetDimensions(WINDOW_WIDTH, 5)
    end
end
function SUP.BringFrontPanelToTop()
    if not SUP.panels then return end

    local frontPanel = SUP.panels.front
    if not frontPanel or not frontPanel.window then return end

    if frontPanel.window.IsHidden then
        local ok, hidden = pcall(function()
            return frontPanel.window:IsHidden()
        end)

        if ok and hidden then
            return
        end
    end

    -- ESOの通常ウィンドウ順だけを戻す。
    -- SetDrawLayer / SetDrawTier 系は使わないので、前みたいに全部消える事故を避ける。
    if frontPanel.window.BringWindowToTop then
        pcall(function()
            frontPanel.window:BringWindowToTop()
        end)
    end
end
function SUP.Update()
    if not SUP.panels then return end

    -- Default/FAB+ Ultimate hiding is event-driven.
    local visible = SUP.ApplyVisibility()
    if not visible then return end

    SUP.BringFrontPanelToTop() -- keep front panel above

    local current = GetCurrentUltimate()

    local backAbilityId, backCost, backName, backIcon, backBearMissingPet = GetUltimateInfo("back")
    local frontAbilityId, frontCost, frontName, frontIcon, frontBearMissingPet = GetUltimateInfo("front")

    SUP_SeedActualBarUltimateColors()
    local backIdentityColor = SUP_ResolveUltimateIdentityColor(backAbilityId, backName, backIcon, PANEL.back.color)
    local frontIdentityColor = SUP_ResolveUltimateIdentityColor(frontAbilityId, frontName, frontIcon, PANEL.front.color)

    local sameUltimate = false

    if backAbilityId and frontAbilityId and backAbilityId ~= 0 and frontAbilityId ~= 0 then
        if backAbilityId == frontAbilityId then
            sameUltimate = true
        end
    end

    if not sameUltimate then
        if backName and frontName and backName ~= "" and frontName ~= "" then
            if backName == frontName and tonumber(backCost or 0) == tonumber(frontCost or 0) then
                sameUltimate = true
            end
        end
    end

    if not sameUltimate then
        if backIcon and frontIcon and backIcon ~= "" and frontIcon ~= "" then
            if backIcon == frontIcon and tonumber(backCost or 0) == tonumber(frontCost or 0) then
                sameUltimate = true
            end
        end
    end

    local commonColor = {
        bg = {0.045, 0.025, 0.075, 0.92},
        edge = {0.86, 0.46, 1.00, 1.00},
        title = {1.00, 0.82, 1.00, 1.00},
        fill = {0.60, 0.34, 1.00, 0.92},
        ready = {1.00, 0.62, 1.00, 0.96},
    }

    local function ShowPetMissingPanel(kind, abilityName, icon)
        local panel = SUP.panels and SUP.panels[kind]
        if not panel then return end

        local color = commonColor

        panel.bg:SetCenterColor(color.bg[1], color.bg[2], color.bg[3], color.bg[4])
        panel.bg:SetEdgeColor(color.edge[1], color.edge[2], color.edge[3], color.edge[4])

        if panel.topLine then
            panel.topLine:SetCenterColor(color.edge[1], color.edge[2], color.edge[3], 0.80)
        end

        if panel.accent then
            panel.accent:SetCenterColor(color.edge[1], color.edge[2], color.edge[3], 0.95)
            panel.accent:SetEdgeColor(color.edge[1], color.edge[2], color.edge[3], 1.00)
        end

        if panel.barBg then
            panel.barBg:SetEdgeColor(color.edge[1], color.edge[2], color.edge[3], 0.90)
        end

        if panel.iconBackdrop then
            panel.iconBackdrop:SetEdgeColor(color.edge[1], color.edge[2], color.edge[3], 0.85)
        end

        if panel.iconFrameOuter then
            panel.iconFrameOuter:SetEdgeColor(color.edge[1], color.edge[2], color.edge[3], 1.00)
        end

        if panel.iconFrameInner then
            panel.iconFrameInner:SetHidden(true)
        end

        panel.title:SetFont(TITLE_FONT)
        panel.title:SetColor(color.title[1], color.title[2], color.title[3], color.title[4])
        panel.title:SetText(GetPetMissingText())
        panel.text:SetText("")
        panel.fill:SetHidden(true)
        SUP.SetPanelIconVisible(panel, icon ~= nil and icon ~= "", icon)
        SUP.SetFrontReadyGlow(panel, false, color)
    end

    local function UpdatePanelDisplay(kind, abilityId, cost, abilityName, icon, titleOverride, colorOverride)
        local panel = SUP.panels and SUP.panels[kind]
        if not panel then return end

        local config = PANEL[kind]
        local color = colorOverride or config.color
        local titleBase = titleOverride or config.title

        panel.bg:SetCenterColor(color.bg[1], color.bg[2], color.bg[3], color.bg[4])

        if panel.topLine then
            panel.topLine:SetCenterColor(color.edge[1], color.edge[2], color.edge[3], 0.80)
        end

        if panel.accent then
            panel.accent:SetCenterColor(color.edge[1], color.edge[2], color.edge[3], 0.95)
            panel.accent:SetEdgeColor(color.edge[1], color.edge[2], color.edge[3], 1.00)
        end

        if panel.barBg then
            panel.barBg:SetEdgeColor(color.edge[1], color.edge[2], color.edge[3], 0.90)
        end

        if panel.iconBackdrop then
            panel.iconBackdrop:SetEdgeColor(color.edge[1], color.edge[2], color.edge[3], 0.85)
        end

        if panel.iconFrameOuter then
            panel.iconFrameOuter:SetEdgeColor(color.edge[1], color.edge[2], color.edge[3], 1.00)
        end

        if panel.iconFrameInner then
            panel.iconFrameInner:SetEdgeColor(color.edge[1], color.edge[2], color.edge[3], 0.00)
            panel.iconFrameInner:SetHidden(true)
        end

        if abilityId == 0 or cost == 0 then
            panel.title:SetText(titleBase .. ": 未検出")
            panel.title:SetFont(SMALL_FONT)
            panel.title:SetColor(color.title[1], color.title[2], color.title[3], color.title[4])
            panel.text:SetText(FormatUltimateValue(current, 0))
            panel.fill:SetHidden(true)
            SUP.SetPanelIconVisible(panel, false)
            panel.bg:SetEdgeColor(0.65, 0.45, 0.45, 0.9)
            SUP.SetFrontReadyGlow(panel, false, color)
            return
        end

        panel.title:SetFont(TITLE_FONT)
        panel.title:SetColor(color.title[1], color.title[2], color.title[3], color.title[4])

        local ratio = current / cost
        if ratio < 0 then ratio = 0 end
        if ratio > 1 then ratio = 1 end

        local fillWidth = math.floor(BAR_WIDTH * ratio)

        if fillWidth < 1 then
            panel.fill:SetHidden(true)
        else
            panel.fill:SetHidden(false)
            panel.fill:SetDimensions(fillWidth, BAR_HEIGHT)
        end

        SUP.SetPanelIconVisible(panel, icon ~= nil and icon ~= "", icon)

        if abilityName and abilityName ~= "" then
            panel.title:SetText(titleBase .. " " .. abilityName)
        else
            panel.title:SetText(titleBase)
        end

        panel.text:SetText(FormatUltimateValue(current, cost))

        local isReady = current >= cost

        if isReady then
            panel.bg:SetEdgeColor(color.ready[1], color.ready[2], color.ready[3], 1.0)
            panel.fill:SetCenterColor(color.ready[1], color.ready[2], color.ready[3], color.ready[4])
        else
            panel.bg:SetEdgeColor(color.edge[1], color.edge[2], color.edge[3], color.edge[4])
            panel.fill:SetCenterColor(color.fill[1], color.fill[2], color.fill[3], color.fill[4])
        end

        SUP.SetFrontReadyGlow(panel, isReady, color)
    end

    if (frontBearMissingPet or backBearMissingPet) and not SUP.forceVisibleForEdit then
        local sharedName = frontName
        local sharedIcon = frontIcon

        if backBearMissingPet and not frontBearMissingPet then
            sharedName = backName
            sharedIcon = backIcon
        end

        local backPanel = SUP.panels.back
        if backPanel and backPanel.window then
            backPanel.window:SetHidden(true)
            SUP.SetFrontReadyGlow(backPanel, false, PANEL.back.color)
        end

        local frontPanel = SUP.panels.front
        if frontPanel and frontPanel.window then
            frontPanel.window:SetHidden(false)
        end

        ShowPetMissingPanel("front", sharedName, sharedIcon)
        return
    end

    if sameUltimate and not SUP.forceVisibleForEdit then
        -- 同じアルティメットなら、下側の表パネルだけ残す。
        local backPanel = SUP.panels.back
        if backPanel and backPanel.window then
            backPanel.window:SetHidden(true)
            SUP.SetFrontReadyGlow(backPanel, false, PANEL.back.color)
        end

        local frontPanel = SUP.panels.front
        if frontPanel and frontPanel.window then
            frontPanel.window:SetHidden(false)
        end

        UpdatePanelDisplay("front", frontAbilityId, frontCost, frontName, frontIcon, "[ S ]", commonColor)
    else
        -- 違うアルティメット、または編集モード中は両方表示。
        local backPanel = SUP.panels.back
        if backPanel and backPanel.window then
            backPanel.window:SetHidden(false)
        end

        local frontPanel = SUP.panels.front
        if frontPanel and frontPanel.window then
            frontPanel.window:SetHidden(false)
        end

        UpdatePanelDisplay("back", backAbilityId, backCost, backName, backIcon, nil, backIdentityColor)
        UpdatePanelDisplay("front", frontAbilityId, frontCost, frontName, frontIcon, nil, frontIdentityColor)
    end
end
function SUP.CreateSettingsPanel()
    local LAM = LibAddonMenu2

    if not LAM then
        return
    end

    if SUP.settingsPanelCreated then
        return
    end

    SUP.settingsPanelCreated = true

    -- Lock movement is not exposed in the settings panel.
    -- Movement is controlled by Edit mode.
    if SUP.saved then
        SUP.saved.locked = false
        if SUP.ApplyLock then SUP.ApplyLock() end
    end

    local panelData = {
        type = "panel",
        name = "Sora Ultimate Pair",
        displayName = "Sora Ultimate Pair",
        author = "sora0v0",
        version = "1.0.61",
        registerForRefresh = true,
        registerForDefaults = false,
    }

    local options = {
        {
            type = "description",
            text = "Displays front-bar and back-bar Ultimate information in a compact custom UI.",
            width = "full",
        },
        {
            type = "checkbox",
            name = "Show UI",
            tooltip = "Show or hide Sora Ultimate Pair.",
            getFunc = function()
                return not SUP.saved.hidden
            end,
            setFunc = function(value)
                SUP.forceVisibleForEdit = false

                if SUP.SetHidden then
                    SUP.SetHidden(not value)
                else
                    SUP.saved.hidden = not value
                    if SUP.ApplyVisibility then SUP.ApplyVisibility() end
                end
            end,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Edit mode",
            tooltip = "Enable movement/editing. Turn this off during normal gameplay.",
            getFunc = function()
                return SUP.forceVisibleForEdit == true
            end,
            setFunc = function(value)
                if value ~= (SUP.forceVisibleForEdit == true) then
                    if SUP.ToggleEditMode then
                        SUP.ToggleEditMode()
                    else
                        SUP.forceVisibleForEdit = value
                        if SUP.ApplyVisibility then SUP.ApplyVisibility() end
                        if SUP.ApplyLock then SUP.ApplyLock() end
                    end
                end
            end,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Hide default Ultimate display",
            tooltip = "Hide the default ESO/Fancy Action Bar+ Ultimate display where supported.",
            getFunc = function()
                return SUP.saved.hideDefaultUltimate == true
            end,
            setFunc = function(value)
                SUP.saved.hideDefaultUltimate = value and true or false
                SUP.defaultControlCache = nil

                if SUP.QueueDefaultUltimateVisibilityRefresh then
                    SUP.QueueDefaultUltimateVisibilityRefresh("settings")
                elseif SUP.ApplyDefaultUltimateVisibility then
                    SUP.ApplyDefaultUltimateVisibility()
                end
            end,
            width = "full",
        },
        {
            type = "slider",
            name = "Update interval",
            tooltip = "How often the fallback UI refresh runs. Lower values feel more responsive after opening/closing UI panels, but may use a little more CPU. Default: 1000 ms.",
            min = 100,
            max = 2000,
            step = 50,
            getFunc = function()
                return SUP_GetUpdateIntervalMs()
            end,
            setFunc = function(value)
                SUP.SetUpdateIntervalMs(value)
            end,
            default = defaults.updateIntervalMs,
            width = "full",
        },
        {
            type = "button",
            name = "Center panels",
            tooltip = "Reset the front/back panels to the center area.",
            func = function()
                if SUP.ResetPositions then
                    SUP.ResetPositions()
                end
            end,
            width = "half",
        },
        {
            type = "button",
            name = "Show and center",
            tooltip = "Useful if the panels are hidden or moved off screen.",
            func = function()
                if SUP.SetHidden then
                    SUP.SetHidden(false)
                else
                    SUP.saved.hidden = false
                end

                if SUP.ResetPositions then
                    SUP.ResetPositions()
                elseif SUP.ApplyVisibility then
                    SUP.ApplyVisibility()
                end
            end,
            width = "half",
        },
        {
            type = "description",
            text = "Slash commands are still available: /sult, /sult edit, /sult center, /sult default.",
            width = "full",
        },
    }

    LAM:RegisterAddonPanel("SoraUltimatePairOptions", panelData)
    LAM:RegisterOptionControls("SoraUltimatePairOptions", options)
end
function SUP.RegisterSlashCommands()
    SLASH_COMMANDS["/sult"] = function(arg)
        arg = string.lower(Trim(arg))

        if arg == "lock" then
            SUP.ToggleLock()
        elseif arg == "reset" or arg == "center" then
            SUP.ResetPositions()
        elseif arg == "show" then
            SUP.forceVisibleForEdit = false
            SUP.SetHidden(false)
            Chat("表示しました。")
        elseif arg == "hide" then
            SUP.SetHidden(true)
            Chat("非表示にしました。")
        elseif arg == "edit" then
            SUP.ToggleEditMode()
        elseif arg == "default" then
            SUP.ToggleDefaultUltimate()
        else
            SUP.Toggle()
        end
    end

    SLASH_COMMANDS["/sfu"] = SLASH_COMMANDS["/sult"]
    SLASH_COMMANDS["/sbu"] = SLASH_COMMANDS["/sult"]
end


local function GetSavedVariablesNamespace()
    local worldName = GetWorldName()
    if worldName and worldName ~= "" then
        return worldName
    end

    return "Default"
end

function SUP.Initialize()
    SUP.saved = ZO_SavedVars:NewAccountWide("SoraUltimatePairSavedVariables", SAVED_VERSION, GetSavedVariablesNamespace(), defaults)
    SUP.saved.panels = SUP.saved.panels or {}
    SUP.saved.panels.front = SUP.saved.panels.front or { left = nil, top = nil }
    SUP.saved.panels.back = SUP.saved.panels.back or { left = nil, top = nil }
    SUP.saved.locked = false -- settings panel movement mode

    if SUP.saved.hideDefaultUltimate == nil then
        SUP.saved.hideDefaultUltimate = defaults.hideDefaultUltimate
    end

    if SUP.saved.updateIntervalMs == nil then
        SUP.saved.updateIntervalMs = defaults.updateIntervalMs
    else
        SUP.saved.updateIntervalMs = SUP_GetUpdateIntervalMs()
    end

    SUP.panels = {}

    SUP.RegisterBindingStrings()
    SUP.CreatePanel("back")
    SUP.CreatePanel("front")
    SUP.ApplyLock()
    SUP.RegisterSlashCommands()
    zo_callLater(function()
        if SUP.CreateSettingsPanel then SUP.CreateSettingsPanel() end
    end, 500)
    SUP.ApplyVisibility()
    SUP.defaultControlCache = nil
    SUP.QueueDefaultUltimateVisibilityRefresh("initialize")

    SUP.RegisterUpdateLoop()

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_PLAYER_ACTIVATED, function()
        SUP.defaultControlCache = nil
        SUP.QueueDefaultUltimateVisibilityRefresh("player_activated")
        SUP.Update()
    end)

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ACTION_SLOTS_ACTIVE_HOTBAR_UPDATED, function()
        SUP.defaultControlCache = nil
        SUP.QueueDefaultUltimateVisibilityRefresh("active_hotbar_updated")
        zo_callLater(function() SUP.Update() end, 100)
    end)

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ACTION_SLOTS_ALL_HOTBARS_UPDATED, function()
        SUP.defaultControlCache = nil
        SUP.QueueDefaultUltimateVisibilityRefresh("all_hotbars_updated")
        zo_callLater(function() SUP.Update() end, 100)
    end)

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_POWER_UPDATE, function(eventCode, unitTag, powerIndex, powerType)
        local currentUltimate = GetUnitPower("player", POWERTYPE_ULTIMATE) or 0

        if SUP.lastUltimatePower == currentUltimate then
            return
        end

        SUP.lastUltimatePower = currentUltimate
        SUP.Update()
    end)

    EVENT_MANAGER:AddFilterForEvent(
        ADDON_NAME,
        EVENT_POWER_UPDATE,
        REGISTER_FILTER_UNIT_TAG, "player",
        REGISTER_FILTER_POWER_TYPE, POWERTYPE_ULTIMATE
    )

    Chat("Loaded. /sult edit, /sult center, /sult default")
end

local function OnAddOnLoaded(event, addonName)
    if addonName ~= ADDON_NAME then return end

    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
    SUP.Initialize()
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)