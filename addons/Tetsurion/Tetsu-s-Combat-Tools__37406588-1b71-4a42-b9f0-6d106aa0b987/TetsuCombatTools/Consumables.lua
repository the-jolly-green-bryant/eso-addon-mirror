TetsuCombatTools = TetsuCombatTools or {}
local T = TetsuCombatTools

local ADDON = "TetsuCombatToolsCons"

local FOOD_EMPTY = "/esoui/art/icons/quest_food_001.dds"
local POT_EMPTY = "/esoui/art/icons/icon_potion_empty.dds"

local COL_OK = { 0.35, 0.85, 0.40, 1 }
local COL_WARN = { 0.95, 0.78, 0.20, 1 }
local COL_DEAD = { 0.82, 0.22, 0.20, 1 }
local COL_DIM = { 0.45, 0.45, 0.45, 0.75 }

local FOOD_MIN_DUR = 15 * 60
local FOOD_MAX_DUR = 4 * 60 * 60
local POT_MIN_DUR = 8
local POT_MAX_DUR = 90

local root
local foodIcon
local foodLab
local potIcon
local potLab
local built = false
local ticking = false
local hadFood = false
local lastFoodId = 0
local potUntil = 0
local potIconHold = nil

local function Vars()
    return T.savedVars
end

local function L(key, fallback)
    local loc = T.L or {}
    return loc[key] or fallback or key
end

local function ConsOn()
    local v = Vars()
    return v and v.consEnabled ~= false
end

local function InCombat()
    if not IsUnitInCombat then return false end
    local ok, v = pcall(IsUnitInCombat, "player")
    return ok and v and true or false
end

local function SceneIsShowing(scene)
    if not scene or not scene.IsShowing then return false end
    local ok, showing = pcall(function()
        return scene:IsShowing()
    end)
    return ok and showing and true or false
end

local function WorldHudOpen()
    if HUD_SCENE or HUD_UI_SCENE then
        return SceneIsShowing(HUD_SCENE) or SceneIsShowing(HUD_UI_SCENE)
    end
    return true
end

local function NowFrame()
    if GetFrameTimeSeconds then
        return GetFrameTimeSeconds()
    end
    return GetTimeStamp()
end

local function Scale()
    local v = Vars()
    local p = v and tonumber(v.consScale) or 100
    if p < 50 then p = 50 end
    if p > 180 then p = 180 end
    return p / 100
end

local function FoodWarnSec()
    local v = Vars()
    local m = v and tonumber(v.consFoodWarn) or 5
    if m < 1 then m = 1 end
    if m > 15 then m = 15 end
    return m * 60
end

local function PotWarnSec()
    local v = Vars()
    local s = v and tonumber(v.consPotWarn) or 10
    if s < 5 then s = 5 end
    if s > 20 then s = 20 end
    return s
end

local function PotCombatOnly()
    local v = Vars()
    return v and v.consPotCombat == true
end

local function TexLooks(tex, needle)
    if type(tex) ~= "string" then return false end
    return string.find(string.lower(tex), needle, 1, true) ~= nil
end

local function FormatLeft(sec)
    sec = math.floor(sec + 0.5)
    if sec < 0 then sec = 0 end
    local h = math.floor(sec / 3600)
    local m = math.floor((sec % 3600) / 60)
    local s = sec % 60
    if h > 0 then
        return string.format("%d:%02d:%02d", h, m, s)
    end
    return string.format("%d:%02d", m, s)
end

local function ScoreFood(dur, icon, canClickOff)
    if dur < FOOD_MIN_DUR or dur > FOOD_MAX_DUR then return 0 end
    local n = 10
    if canClickOff then n = n + 8 end
    if TexLooks(icon, "food") or TexLooks(icon, "drink") or TexLooks(icon, "provision") then
        n = n + 12
    end
    if TexLooks(icon, "potion") then n = n - 6 end
    if TexLooks(icon, "scroll") or TexLooks(icon, "xp") then n = n - 10 end
    return n
end

-- Action-bar cooldown APIs return milliseconds. A leftover GCD of 50ms
-- used to be treated as 0:50 because we only divided values above 200.
local function MsToSec(v)
    v = tonumber(v) or 0
    if v <= 0 then return 0 end
    return v / 1000
end

local function QuickCat()
    return HOTBAR_CATEGORY_QUICKSLOT_WHEEL
end

-- Slot CD without wheel category is a skill slot. Even WITH the category the
-- game reports GCD on every skill (isGlobal=true, ~1000ms). Ignore those.
local function SlotCooldown(slot)
    local cat = QuickCat()
    if not GetSlotCooldownInfo or not slot or not cat then return 0, 0, true end
    local ok, remain, duration, isGlobal = pcall(GetSlotCooldownInfo, slot, cat)
    if not ok then return 0, 0, true end
    return MsToSec(remain), MsToSec(duration), isGlobal and true or false
end

local function ItemUseRemain(link)
    if not link or not GetItemLinkOnUseAbilityInfo then return 0, 0 end
    local ok, has, _h, _d, cooldown, _s, _a, _b, _c, remainCd = pcall(GetItemLinkOnUseAbilityInfo, link)
    if not ok or not has then return 0, 0 end
    return MsToSec(remainCd), MsToSec(cooldown)
end

local function SlotLink(slot)
    local cat = QuickCat()
    if not GetSlotItemLink or not slot or not cat then return nil end
    local ok, link = pcall(GetSlotItemLink, slot, cat)
    if ok and type(link) == "string" and link ~= "" then return link end
    return nil
end

local function SlotTex(slot, link)
    local cat = QuickCat()
    if GetSlotTexture and slot and cat then
        local ok, tex = pcall(GetSlotTexture, slot, cat)
        if ok and type(tex) == "string" and tex ~= "" then return tex end
    end
    if link and GetItemLinkIcon then
        local ok, tex = pcall(GetItemLinkIcon, link)
        if ok and type(tex) == "string" and tex ~= "" then return tex end
    end
    return nil
end

local function IsPotionLink(link)
    if not link or link == "" then return false end
    if GetItemLinkItemType then
        local ok, t = pcall(GetItemLinkItemType, link)
        if ok and ITEMTYPE_POTION and t == ITEMTYPE_POTION then return true end
    end
    local low = string.lower(link)
    return string.find(low, "potion", 1, true) ~= nil
end

local function LooksLikePotionCd(left, dur)
    -- Essence / crafted potion share CD is ~45s. GCD is ~1s.
    if left < 0.4 then return false end
    if left <= 2.2 then return false end
    if dur > 0 and dur < 8 then return false end
    if dur > 90 then return false end
    return true
end

local function ScanPotion()
    local now = NowFrame()
    if not QuickCat() then
        local left = potUntil - now
        if left > 0.2 then return { icon = potIconHold, left = left } end
        return nil
    end
    local slot
    if GetCurrentQuickslot then
        local ok, s = pcall(GetCurrentQuickslot)
        if ok then slot = s end
    end
    if not slot then
        local left = potUntil - now
        if left > 0.2 then return { icon = potIconHold, left = left } end
        return nil
    end
    local link = SlotLink(slot)
    local icon = SlotTex(slot, link)
    if not (IsPotionLink(link) or TexLooks(icon, "potion")) then
        potUntil = 0
        potIconHold = nil
        return nil
    end

    local left, dur, isGlobal = SlotCooldown(slot)
    local useLeft, useDur = ItemUseRemain(link)
    local picked, pickedDur = 0, 0
    if LooksLikePotionCd(useLeft, useDur) then
        picked, pickedDur = useLeft, useDur
    elseif (not isGlobal) and LooksLikePotionCd(left, dur) then
        picked, pickedDur = left, dur
    end

    if picked > 0.4 then
        -- Do not let a 1s GCD overwrite a live ~45s potion CD.
        local stickyLeft = potUntil - now
        if picked <= 2.2 and stickyLeft > 3 then
            picked = stickyLeft
        else
            potUntil = now + picked
            potIconHold = icon or potIconHold
        end
    end

    local show = potUntil - now
    if show > 0.2 then
        return { icon = icon or potIconHold, left = show }
    end
    potUntil = 0
    return nil
end

local function Scan()
    local food
    local foodScore = 0
    local n = 0
    if GetNumBuffs then
        local ok, num = pcall(GetNumBuffs, "player")
        if ok then n = tonumber(num) or 0 end
    end
    local now = NowFrame()
    for i = 1, n do
        local name, started, ending, _slot, _stack, icon, _bt, effectType, _at, _st, abilityId, canClickOff, castByPlayer
        local ok = pcall(function()
            name, started, ending, _slot, _stack, icon, _bt, effectType, _at, _st, abilityId, canClickOff, castByPlayer = GetUnitBuffInfo("player", i)
        end)
        if ok and ending and started then
            if not effectType or effectType == BUFF_EFFECT_TYPE_BUFF or effectType == 1 then
                local dur = ending - started
                local left = ending - now
                if left > 0.2 and dur > 0 then
                    local fs = ScoreFood(dur, icon, canClickOff)
                    if fs > foodScore then
                        foodScore = fs
                        food = {
                            id = tonumber(abilityId) or 0,
                            icon = icon,
                            left = left,
                            name = name,
                        }
                    end
                end
            end
        end
    end
    if foodScore < 8 then food = nil end
    return food
end

local function AttachFragment(control)
    if not control then return end
    local frag
    if ZO_HUDFadeSceneFragment then
        frag = ZO_HUDFadeSceneFragment:New(control)
    elseif ZO_SimpleSceneFragment then
        frag = ZO_SimpleSceneFragment:New(control)
    end
    if not frag then return end
    if HUD_SCENE and HUD_SCENE.AddFragment then
        pcall(function() HUD_SCENE:AddFragment(frag) end)
    end
    if HUD_UI_SCENE and HUD_UI_SCENE.AddFragment then
        pcall(function() HUD_UI_SCENE:AddFragment(frag) end)
    end
end

local function Layout()
    if not root then return end
    local v = Vars()
    local ox = v and tonumber(v.consOffsetX) or 0
    local oy = v and tonumber(v.consOffsetY)
    if oy == nil then oy = 220 end
    local sc = Scale()
    local icon = math.floor(36 * sc + 0.5)
    local gap = math.floor(18 * sc + 0.5)
    local cell = icon + 8
    local width = cell * 2 + gap
    local height = icon + math.floor(22 * sc + 0.5)
    root:ClearAnchors()
    root:SetAnchor(CENTER, GuiRoot, CENTER, ox, oy)
    root:SetDimensions(width, height)

    if foodIcon then
        foodIcon:ClearAnchors()
        foodIcon:SetAnchor(TOP, root, TOP, -((cell + gap) / 2), 0)
        foodIcon:SetDimensions(icon, icon)
    end
    if foodLab then
        foodLab:ClearAnchors()
        foodLab:SetAnchor(TOP, foodIcon, BOTTOM, 0, 2)
        pcall(function()
            foodLab:SetFont(sc >= 1.2 and "ZoFontGamepad27" or "ZoFontGamepad22")
        end)
    end
    if potIcon then
        potIcon:ClearAnchors()
        potIcon:SetAnchor(TOP, root, TOP, (cell + gap) / 2, 0)
        potIcon:SetDimensions(icon, icon)
    end
    if potLab then
        potLab:ClearAnchors()
        potLab:SetAnchor(TOP, potIcon, BOTTOM, 0, 2)
        pcall(function()
            potLab:SetFont(sc >= 1.2 and "ZoFontGamepad27" or "ZoFontGamepad22")
        end)
    end
end

local function PaintSlot(icon, lab, data, warnSec, emptyTex)
    if not icon or not lab then return end
    if data and data.left and data.left > 0 then
        icon:SetTexture((data.icon and data.icon ~= "") and data.icon or emptyTex)
        icon:SetColor(1, 1, 1, 1)
        lab:SetText(FormatLeft(data.left))
        if data.left <= warnSec then
            lab:SetColor(COL_WARN[1], COL_WARN[2], COL_WARN[3], 1)
        else
            lab:SetColor(COL_OK[1], COL_OK[2], COL_OK[3], 1)
        end
    else
        icon:SetTexture(emptyTex)
        icon:SetColor(COL_DIM[1], COL_DIM[2], COL_DIM[3], COL_DIM[4])
        lab:SetText("—")
        lab:SetColor(COL_DEAD[1], COL_DEAD[2], COL_DEAD[3], 1)
    end
end

local function PlayFoodGone()
    local v = Vars()
    if not v or v.consFoodSound ~= true then return end
    if SOUNDS and SOUNDS.GENERAL_ALERT_ERROR then
        pcall(PlaySound, SOUNDS.GENERAL_ALERT_ERROR)
    elseif PlaySound then
        pcall(PlaySound, "General_Alert_Error")
    end
end

local function Paint()
    if not root then return end
    local food = Scan()
    local pot = ScanPotion()
    if hadFood and not food then
        PlayFoodGone()
    end
    hadFood = food and true or false
    if food and food.id ~= 0 then lastFoodId = food.id end
    PaintSlot(foodIcon, foodLab, food, FoodWarnSec(), FOOD_EMPTY)
    local showPot = true
    if PotCombatOnly() and not InCombat() then
        showPot = false
    end
    if potIcon then potIcon:SetHidden(not showPot) end
    if potLab then potLab:SetHidden(not showPot) end
    if showPot then
        PaintSlot(potIcon, potLab, pot, PotWarnSec(), POT_EMPTY)
    end
end

local function ApplyShown()
    if not root then return end
    root:SetHidden(not (ConsOn() and WorldHudOpen()))
end

local function Tick()
    if not ConsOn() then
        if root then root:SetHidden(true) end
        return
    end
    ApplyShown()
    if root and not root:IsHidden() then
        Paint()
    end
end

local function StartTick()
    if ticking then return end
    ticking = true
    EVENT_MANAGER:RegisterForUpdate(ADDON .. "Tick", 500, Tick)
end

local function Build()
    if built then return end
    local wm = GetWindowManager()
    if not wm then return end
    root = wm:CreateTopLevelWindow(ADDON .. "Root")
    if not root then
        root = wm:CreateControl(ADDON .. "Root", GuiRoot, CT_TOPLEVELCONTROL)
    end
    root:SetParent(GuiRoot)
    root:SetHidden(true)
    root:SetClampedToScreen(true)
    root:SetMouseEnabled(false)
    root:SetDrawLayer(DL_CONTROLS)
    root:SetDrawLevel(3)

    foodIcon = wm:CreateControl(ADDON .. "Food", root, CT_TEXTURE)
    foodLab = wm:CreateControl(ADDON .. "FoodLab", root, CT_LABEL)
    foodLab:SetFont("ZoFontGamepad22")
    foodLab:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    potIcon = wm:CreateControl(ADDON .. "Pot", root, CT_TEXTURE)
    potLab = wm:CreateControl(ADDON .. "PotLab", root, CT_LABEL)
    potLab:SetFont("ZoFontGamepad22")
    potLab:SetHorizontalAlignment(TEXT_ALIGN_CENTER)

    AttachFragment(root)
    built = true
    Layout()
    Paint()
    ApplyShown()
end

function T.ConsRefresh()
    if not ConsOn() then
        if root then root:SetHidden(true) end
        return
    end
    if not built then Build() end
    Layout()
    Paint()
    ApplyShown()
    StartTick()
end

function T.ConsStart()
    EVENT_MANAGER:RegisterForEvent(ADDON, EVENT_PLAYER_COMBAT_STATE, function()
        T.ConsRefresh()
    end)
    EVENT_MANAGER:RegisterForEvent(ADDON, EVENT_PLAYER_ACTIVATED, function()
        T.ConsRefresh()
    end)
    if EVENT_ACTIVE_QUICKSLOT_CHANGED then
        EVENT_MANAGER:RegisterForEvent(ADDON .. "Qs", EVENT_ACTIVE_QUICKSLOT_CHANGED, function()
            if ConsOn() then Paint() end
        end)
    end
    local function OnLayer()
        ApplyShown()
    end
    if EVENT_ACTION_LAYER_PUSHED then
        EVENT_MANAGER:RegisterForEvent(ADDON .. "LayerP", EVENT_ACTION_LAYER_PUSHED, OnLayer)
    end
    if EVENT_ACTION_LAYER_POPPED then
        EVENT_MANAGER:RegisterForEvent(ADDON .. "LayerO", EVENT_ACTION_LAYER_POPPED, OnLayer)
    end
    if SCENE_MANAGER and SCENE_MANAGER.RegisterCallback then
        pcall(function()
            SCENE_MANAGER:RegisterCallback("SceneStateChanged", OnLayer)
        end)
    end
    Build()
    T.ConsRefresh()
end
