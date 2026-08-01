AutoConsume = {}
AutoConsume.name = "AutoConsume"
AutoConsume.savedVariables = nil
AutoConsume.ready = false

local AC = AutoConsume

local AC_HUD = {
    panel  = nil,
    rows   = {},
    active = {},
}

--------------------------------------------------
-- DEFAULTS
--------------------------------------------------

local DEFAULTS = {
    autoFood    = false,
    foodID      = nil,
    foodMinutes = 10,

    autoXP   = false,
    xpItemID = nil,

    autoAP   = false,
    apItemID = nil,

    bagScanned      = false,

    hudEnabled    = true,
    hudPosX       = 900,
    hudPosY       = 500,
    hudIconSize   = 40,
    hudHorizontal = false,
}

--------------------------------------------------
-- KNOWN BUFF NAMES
--------------------------------------------------
local XP_BUFF_NAMES = {
    "increased experience",
}

local AP_BUFF_NAMES = {
    "alliance skill gain",
}

local XP_ITEM_NAMES = {
    ["psijic ambrosia"]                    = true,
    ["mythic aetherial ambrosia"]          = true,
    ["aetherial ambrosia"]                 = true,
    ["crown experience scroll"]            = true,
    ["major gold coast experience scroll"] = true,
    ["grand gold coast experience scroll"] = true,
    ["experience scroll"]                  = true,
    ["anniversary experience scroll"]      = true,
    ["minor experience scroll"]            = true,
    ["standard experience scroll"]         = true,
    ["major experience scroll"]            = true,
}

local AP_ITEM_NAMES = {
    ["colovian war torte"]                   = true,
    ["molten war torte"]                     = true,
    ["white-gold war torte"]                 = true,
    ["alliance war skill line scroll"]        = true,
    ["alliance war skill line scroll, major"] = true,
    ["alliance war skill line scroll, grand"] = true,
}

--------------------------------------------------
-- TIMER NAMES
--------------------------------------------------
local TIMER_FOOD = "AutoConsume_FoodTimer"
local TIMER_XP   = "AutoConsume_XPTimer"
local TIMER_AP   = "AutoConsume_APTimer"

--------------------------------------------------
-- HELPERS
--------------------------------------------------

local function IsPlayerBusy()
    return IsUnitDeadOrReincarnating("player")
        or IsUnitSwimming("player")
        or IsUnitInCombat("player")
end

local function FindItemSlot(itemID)
    if not itemID then return nil end
    for slotId = 0, GetBagSize(BAG_BACKPACK) - 1 do
        if GetItemId(BAG_BACKPACK, slotId) == itemID then
            if CanInteractWithItem(BAG_BACKPACK, slotId) then
                return slotId
            end
        end
    end
    return nil
end

--------------------------------------------------
-- FOOD BUFF ABILITY IDs
--------------------------------------------------
local FOOD_BUFF_ABILITY_IDS = {
    -- Drinks
    [61322]=true,[61325]=true,[61328]=true,[61335]=true,[61340]=true,
    [61345]=true,[61350]=true,[66125]=true,[66132]=true,[66137]=true,
    [66141]=true,[66586]=true,[66590]=true,[66594]=true,[68416]=true,
    [72816]=true,[72965]=true,[72968]=true,[72971]=true,[84700]=true,
    [84704]=true,[84720]=true,[84731]=true,[84732]=true,[84733]=true,
    [84735]=true,[85497]=true,[86559]=true,[86560]=true,[86673]=true,
    [86674]=true,[86677]=true,[86678]=true,[86746]=true,[86747]=true,
    [86791]=true,[89957]=true,[92433]=true,[92476]=true,[100488]=true,
    [127531]=true,[127572]=true,
    -- Food
    [17407]=true,[17577]=true,[17581]=true,[17608]=true,[17614]=true,
    [61218]=true,[61255]=true,[61257]=true,[61259]=true,[61260]=true,
    [61261]=true,[61294]=true,[66128]=true,[66130]=true,[66551]=true,
    [66568]=true,[66576]=true,[68411]=true,[72819]=true,[72822]=true,
    [72824]=true,[72956]=true,[72959]=true,[72961]=true,[84678]=true,
    [84681]=true,[84709]=true,[84725]=true,[84736]=true,[85484]=true,
    [86749]=true,[86787]=true,[86789]=true,[89955]=true,[89971]=true,
    [92435]=true,[92437]=true,[92474]=true,[92477]=true,[100498]=true,
    [100502]=true,[107748]=true,[107789]=true,[127537]=true,[127578]=true,
    [127596]=true,[127619]=true,[127736]=true,[148633]=true,
    [267468]=true,
}

local function GetFoodBuffTimeLeft()
    if not AC.savedVariables then return 0 end
    if not AC.savedVariables.foodID then return 0 end
    local numBuffs = GetNumBuffs("player")
    for i = 1, numBuffs do
        local buffName, _, timeEnding, _, _, _, effectType, _, abilityType, _, abilityId = GetUnitBuffInfo("player", i)
        if timeEnding and timeEnding > 0 and effectType ~= BUFF_EFFECT_TYPE_DEBUFF then
            if FOOD_BUFF_ABILITY_IDS[abilityId] or abilityType == ABILITY_TYPE_INTERACTIVES then
                return math.max(0, timeEnding - GetGameTimeSeconds())
            end
        end
    end
    return 0
end

local function HasActiveBuff(nameList)
    local numBuffs = GetNumBuffs("player")
    for i = 1, numBuffs do
        local buffName, _, timeEnding = GetUnitBuffInfo("player", i)
        if buffName and timeEnding and timeEnding > 0 then
            local lower = buffName:lower()
            for _, match in ipairs(nameList) do
                if lower:find(match, 1, true) then
                    return true, timeEnding
                end
            end
        end
    end
    return false, 0
end

local function Notify(msg)
    d("|cffffff AutoConsume:|r |cffff00" .. msg .. "|r")
end

local function GetItemNameByID(itemID)
    if not itemID then return "None" end
    for slotId = 0, GetBagSize(BAG_BACKPACK) - 1 do
        if GetItemId(BAG_BACKPACK, slotId) == itemID then
            local name = GetItemName(BAG_BACKPACK, slotId)
            if name and name ~= "" then return name end
        end
    end
    return "None"
end

--------------------------------------------------
-- BAG SCAN
--------------------------------------------------

local cachedFoodChoices = { "None" }
local cachedFoodVals    = { 0 }
local cachedXPChoices   = { "None" }
local cachedXPVals      = { 0 }
local cachedAPChoices   = { "None" }
local cachedAPVals      = { 0 }

local function ScanBag()
    cachedFoodChoices = { "None" }
    cachedFoodVals    = { 0 }
    cachedXPChoices   = { "None" }
    cachedXPVals      = { 0 }
    cachedAPChoices   = { "None" }
    cachedAPVals      = { 0 }

    local seen = {}
    for slotId = 0, GetBagSize(BAG_BACKPACK) - 1 do
        local id    = GetItemId(BAG_BACKPACK, slotId)
        local name  = GetItemName(BAG_BACKPACK, slotId)
        local itype = GetItemType(BAG_BACKPACK, slotId)
        if id and id ~= 0 and name and name ~= "" and not seen[id] then
            local lower = name:lower()
            if XP_ITEM_NAMES[lower] then
                cachedXPChoices[#cachedXPChoices + 1] = name
                cachedXPVals[#cachedXPVals + 1]       = id
                seen[id] = true
            elseif AP_ITEM_NAMES[lower] then
                cachedAPChoices[#cachedAPChoices + 1] = name
                cachedAPVals[#cachedAPVals + 1]       = id
                seen[id] = true
            elseif itype == ITEMTYPE_FOOD or itype == ITEMTYPE_DRINK then
                cachedFoodChoices[#cachedFoodChoices + 1] = name
                cachedFoodVals[#cachedFoodVals + 1]       = id
                seen[id] = true
            end
        end
    end
end

--------------------------------------------------
-- PENDING SELECTIONS
--------------------------------------------------
local pending = {
    foodID   = nil,
    xpItemID = nil,
    apItemID = nil,
}

--------------------------------------------------
-- FOOD
--------------------------------------------------

function AC:ForceCheckFood()
    if not AC.savedVariables.autoFood then return end
    if not AC.savedVariables.foodID then return end
    if IsPlayerBusy() then
        zo_callLater(function() AC:ForceCheckFood() end, 3000)
        return
    end
    local slotId = FindItemSlot(AC.savedVariables.foodID)
    if slotId then
        CallSecureProtected("UseItem", BAG_BACKPACK, slotId)
    else
        local secsLeft = GetFoodBuffTimeLeft()
        local minsLeft = secsLeft / 60
        if minsLeft > AC.savedVariables.foodMinutes then
            local recheckMs = math.max(10000, (secsLeft - AC.savedVariables.foodMinutes * 60 - 5) * 1000)
            EVENT_MANAGER:UnregisterForUpdate(TIMER_FOOD)
            EVENT_MANAGER:RegisterForUpdate(TIMER_FOOD, recheckMs, function()
                AC:CheckFood()
            end)
        end
    end
end

function AC:CheckFood()
    if not AC.savedVariables.autoFood then return end
    if not AC.savedVariables.foodID then return end

    local secsLeft = GetFoodBuffTimeLeft()
    local minsLeft = secsLeft / 60

    if minsLeft > AC.savedVariables.foodMinutes then
        local recheckMs = math.max(10000, (secsLeft - AC.savedVariables.foodMinutes * 60 - 5) * 1000)
        EVENT_MANAGER:UnregisterForUpdate(TIMER_FOOD)
        EVENT_MANAGER:RegisterForUpdate(TIMER_FOOD, recheckMs, function()
            AC:CheckFood()
        end)
        return
    end

    if IsPlayerBusy() then
        zo_callLater(function() AC:CheckFood() end, 3000)
        return
    end

    local slotId = FindItemSlot(AC.savedVariables.foodID)
    if slotId then
        CallSecureProtected("UseItem", BAG_BACKPACK, slotId)
    end
end

--------------------------------------------------
-- XP SCROLL
--------------------------------------------------

function AC:CheckXP()
    if not AC.savedVariables.autoXP then return end
    if not AC.savedVariables.xpItemID then return end

    local active = HasActiveBuff(XP_BUFF_NAMES)
    if not active then
        if not IsPlayerBusy() then
            local slotId = FindItemSlot(AC.savedVariables.xpItemID)
            if slotId then
                CallSecureProtected("UseItem", BAG_BACKPACK, slotId)
            end
        end
    end

    -- Poll every 3 seconds
    EVENT_MANAGER:UnregisterForUpdate(TIMER_XP)
    EVENT_MANAGER:RegisterForUpdate(TIMER_XP, 3000, function()
        AC:CheckXP()
    end)
end

--------------------------------------------------
-- WAR TORTE (AP BOOST)
--------------------------------------------------

function AC:CheckAP()
    if not AC.savedVariables.autoAP then return end
    if not AC.savedVariables.apItemID then return end

    local active = HasActiveBuff(AP_BUFF_NAMES)
    if not active then
        if not IsPlayerBusy() then
            local slotId = FindItemSlot(AC.savedVariables.apItemID)
            if slotId then
                CallSecureProtected("UseItem", BAG_BACKPACK, slotId)
            end
        end
    end

    -- Poll every 3 seconds
    EVENT_MANAGER:UnregisterForUpdate(TIMER_AP)
    EVENT_MANAGER:RegisterForUpdate(TIMER_AP, 3000, function()
        AC:CheckAP()
    end)
end

--------------------------------------------------
-- CHECK ALL
--------------------------------------------------

function AC:CheckAll()
    if not AC.ready then return end
    zo_callLater(function()
        AC:CheckFood()
        AC:CheckXP()
        AC:CheckAP()
    end, 8000)
end

--------------------------------------------------
-- SETTINGS
--------------------------------------------------

function AC:CreateSettings()
    local LAM = LibAddonMenu2
    if not LAM then return end

    ScanBag()

    pending.foodID   = AC.savedVariables.foodID
    pending.xpItemID = AC.savedVariables.xpItemID
    pending.apItemID = AC.savedVariables.apItemID

    local panelData = {
        type                = "panel",
        name                = "AutoConsume",
        displayName         = "AutoConsume",
        author              = "user562",
        version             = "3.2",
        registerForRefresh  = true,
        registerForDefaults = true,
    }

    AC.lamPanel = LAM:RegisterAddonPanel("AutoConsume_Settings", panelData)

    local options = {

        -- ── SCAN BAG ──────────────────────────────────────────
        {
            type    = "button",
            name    = "|cff8800Scan Bag|r",
            tooltip = "Will ReloadUI",
            func    = function()
                ScanBag()
                pending.foodID   = AC.savedVariables.foodID
                pending.xpItemID = AC.savedVariables.xpItemID
                pending.apItemID = AC.savedVariables.apItemID
                AC.savedVariables.bagScanned = true
                zo_callLater(function()
                    ReloadUI()
                end, 500)
            end,
        },

        -- ── DIVIDER ───────────────────────────────────────────
        { type = "divider" },

        -- ── FOOD ──────────────────────────────────────────────
        { type = "header", name = "Food/Drink" },

        {
            type    = "checkbox",
            name    = "Auto-consume",
            getFunc = function() return AC.savedVariables.autoFood end,
            setFunc = function(val)
                AC.savedVariables.autoFood = val
                if val then AC:ForceCheckFood() end
            end,
        },
        {
            type    = "slider",
            name    = "Minutes remaining before re-eating",
            min     = 1,
            max     = 30,
            step    = 1,
            getFunc = function() return AC.savedVariables.foodMinutes end,
            setFunc = function(val)
                AC.savedVariables.foodMinutes = val
            end,
        },
        {
            type          = "dropdown",
            name          = "Food/Drink",
            tooltip       = "Scroll to pick your food/drink. Press Scan Bag first if your item is missing.",
            choices       = cachedFoodChoices,
            choicesValues = cachedFoodVals,
            getFunc       = function() return pending.foodID or 0 end,
            setFunc       = function(val)
                pending.foodID = (val == 0) and nil or val
            end,
        },
        {
            type    = "button",
            name    = "|c00ff00Confirm|r",
            func    = function()
                AC.savedVariables.foodID = pending.foodID
                Notify("Food/Drink set to: |c00ff00" .. GetItemNameByID(pending.foodID))
                AC:ForceCheckFood()
            end,
        },

        -- ── DIVIDER ───────────────────────────────────────────
        { type = "divider" },

        -- ── XP ────────────────────────────────────────────────
        { type = "header", name = "XP Bonus" },

        {
            type    = "checkbox",
            name    = "Auto-Use",
            getFunc = function() return AC.savedVariables.autoXP end,
            setFunc = function(val)
                AC.savedVariables.autoXP = val
                if val then AC:CheckXP() end
            end,
        },
        {
            type          = "dropdown",
            name          = "XP Item",
            tooltip       = "Scroll to pick your XP bonus. Press Scan Bag first if your item is missing.",
            choices       = cachedXPChoices,
            choicesValues = cachedXPVals,
            getFunc       = function() return pending.xpItemID or 0 end,
            setFunc       = function(val)
                pending.xpItemID = (val == 0) and nil or val
            end,
        },
        {
            type    = "button",
            name    = "|c00ff00Confirm|r",
            func    = function()
                AC.savedVariables.xpItemID = pending.xpItemID
                Notify("XP Item set to: |c00ff00" .. GetItemNameByID(pending.xpItemID))
                AC:CheckXP()
            end,
        },

        -- ── DIVIDER ───────────────────────────────────────────
        { type = "divider" },

        -- ── AP BONUS ──────────────────────────────────────────
        { type = "header", name = "AP Bonus" },

        {
            type    = "checkbox",
            name    = "Auto-Use",
            getFunc = function() return AC.savedVariables.autoAP end,
            setFunc = function(val)
                AC.savedVariables.autoAP = val
                if val then AC:CheckAP() end
            end,
        },
        {
            type          = "dropdown",
            name          = "AP Item",
            tooltip       = "Scroll to pick your AP bonus item. Press Scan Bag first if your item is missing.",
            choices       = cachedAPChoices,
            choicesValues = cachedAPVals,
            getFunc       = function() return pending.apItemID or 0 end,
            setFunc       = function(val)
                pending.apItemID = (val == 0) and nil or val
            end,
        },
        {
            type    = "button",
            name    = "|c00ff00Confirm|r",
            func    = function()
                AC.savedVariables.apItemID = pending.apItemID
                Notify("AP Item set to: |c00ff00" .. GetItemNameByID(pending.apItemID))
                AC:CheckAP()
            end,
        },

        -- ── DIVIDER ───────────────────────────────────────────
        { type = "divider" },

        -- ── SHOW BUFFS ON SCREEN ──────────────────────────────
        { type = "header", name = "Show Buffs" },
        {
            type    = "checkbox",
            name    = "Enable",
            getFunc = function() return AC.savedVariables.hudEnabled end,
            setFunc = function(val)
                AC.savedVariables.hudEnabled = val
                if AC_HUD.updateScenes then
                    AC_HUD.updateScenes()
                elseif AC_HUD.panel then
                    AC_HUD.panel:SetHidden(not val)
                end
            end,
        },
        {
            type          = "dropdown",
            name          = "Layout",
            choices       = { "Vertical", "Horizontal" },
            getFunc       = function() return AC.savedVariables.hudHorizontal and "Horizontal" or "Vertical" end,
            setFunc       = function(val)
                AC.savedVariables.hudHorizontal = (val == "Horizontal")
            end,
        },
        {
            type    = "slider",
            name    = "Icon Size",
            min     = 20,
            max     = 100,
            step    = 2,
            getFunc = function() return AC.savedVariables.hudIconSize end,
            setFunc = function(val)
                AC.savedVariables.hudIconSize = val
            end,
        },
        {
            type    = "slider",
            name    = "Horizontal Position",
            min     = 0,
            max     = 3000,
            step    = 10,
            getFunc = function() return AC.savedVariables.hudPosX end,
            setFunc = function(val)
                AC.savedVariables.hudPosX = val
                if AC_HUD.panel then
                    AC_HUD.panel:ClearAnchors()
                    AC_HUD.panel:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT,
                        AC.savedVariables.hudPosX, AC.savedVariables.hudPosY)
                end
            end,
        },
        {
            type    = "slider",
            name    = "Vertical Position",
            min     = 0,
            max     = 2000,
            step    = 10,
            getFunc = function() return AC.savedVariables.hudPosY end,
            setFunc = function(val)
                AC.savedVariables.hudPosY = val
                if AC_HUD.panel then
                    AC_HUD.panel:ClearAnchors()
                    AC_HUD.panel:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT,
                        AC.savedVariables.hudPosX, AC.savedVariables.hudPosY)
                end
            end,
        },
    }

    LAM:RegisterOptionControls("AutoConsume_Settings", options)
end

--------------------------------------------------
-- EVENT_EFFECT_CHANGED
--------------------------------------------------

function AC:OnEffectChanged(eventCode, changeType, effectSlot, effectName,
    unitTag, beginTime, endTime, stackCount, iconName, buffType,
    effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceUnitType)

    if unitTag ~= "player" then return end
    if not AC.ready then return end

    AC:HUDOnEffect(changeType, effectSlot, effectName, effectType, abilityType, iconName, endTime, beginTime, abilityId)

    if changeType ~= EFFECT_RESULT_FADED then return end

    local lower = (effectName or ""):lower()

    for _, match in ipairs(XP_BUFF_NAMES) do
        if lower:find(match, 1, true) then
            zo_callLater(function() AC:CheckXP() end, 1500)
            return
        end
    end

    for _, match in ipairs(AP_BUFF_NAMES) do
        if lower:find(match, 1, true) then
            zo_callLater(function() AC:CheckAP() end, 1500)
            return
        end
    end

    if AC.savedVariables and AC.savedVariables.foodID then
        if FOOD_BUFF_ABILITY_IDS[abilityId] or abilityType == ABILITY_TYPE_INTERACTIVES then
            zo_callLater(function() AC:ForceCheckFood() end, 1500)
            return
        end
    end
end

--------------------------------------------------
-- LOAD
--------------------------------------------------

local function OnAddonLoaded(event, addonName)
    if addonName ~= AC.name then return end

    AC.savedVariables = ZO_SavedVars:New(
        "AutoConsume_SavedVars",
        2,
        nil,
        DEFAULTS
    )

    AC:CreateSettings()
    AC:HUDInit()

    EVENT_MANAGER:RegisterForEvent(
        AC.name,
        EVENT_EFFECT_CHANGED,
        function(...) AC:OnEffectChanged(...) end
    )

    EVENT_MANAGER:AddFilterForEvent(
        AC.name,
        EVENT_EFFECT_CHANGED,
        REGISTER_FILTER_UNIT_TAG, "player"
    )

    EVENT_MANAGER:RegisterForEvent(AC.name, EVENT_PLAYER_ACTIVATED, function()
        AC.ready = true
        AC:CheckAll()
        AC:HUDInit()
        AC:HUDScan()
        EVENT_MANAGER:RegisterForUpdate("AutoConsume_HUDRefresh", 500, function()
            AC:HUDRefresh()
        end)
        if AC.savedVariables.bagScanned then
            AC.savedVariables.bagScanned = false
            Notify("Bag scanned.")
        end
    end)

    EVENT_MANAGER:RegisterForEvent(AC.name, EVENT_PLAYER_REINCARNATED, function()
        if not AC.ready then return end
        zo_callLater(function() AC:CheckAll() end, 3000)
    end)

    EVENT_MANAGER:UnregisterForEvent(AC.name, EVENT_ADD_ON_LOADED)
end

EVENT_MANAGER:RegisterForEvent(AC.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)

--------------------------------------------------
-- HUD
-- Shows icons for active food, XP, and AP buffs.
--------------------------------------------------

local AC_HUD_PLACEHOLDER = nil -- moved to top of file

local HUD_ICON_SIZE = 40
local HUD_SIDE_MARGIN = 4

local HUD_ORANGE_THRESHOLD = 0.50
local HUD_RED_THRESHOLD    = 0.25

local function GetHUDTimerColor(remaining, totalDuration)
    if totalDuration <= 0 then return 0.2, 1.0, 0.2 end
    local pct = remaining / totalDuration
    if pct <= HUD_RED_THRESHOLD then
        return 1.0, 0.2, 0.2
    elseif pct <= HUD_ORANGE_THRESHOLD then
        return 1.0, 0.55, 0.0
    else
        return 0.2, 1.0, 0.2
    end
end
local HUD_DELVE_BUFF_ID = 66282

local function AcHudIsFood(abilityId, buffName)
    if FOOD_BUFF_ABILITY_IDS[abilityId] then return true end
    if abilityId and ABILITY_TYPE_INTERACTIVES and abilityId == ABILITY_TYPE_INTERACTIVES then return true end
    return false
end

local function AcHudIsXP(buffName)
    local lower = (buffName or ""):lower()
    for _, match in ipairs(XP_BUFF_NAMES) do
        if lower:find(match, 1, true) then return true end
    end
    return false
end

local function AcHudIsAP(buffName)
    local lower = (buffName or ""):lower()
    for _, match in ipairs(AP_BUFF_NAMES) do
        if lower:find(match, 1, true) then return true end
    end
    return false
end

local function AcHudIsDelve(abilityId)
    return abilityId == HUD_DELVE_BUFF_ID
end

local function AcHudCreateRow(parent, index)
    local iconSize = 40 -- placeholder, resized in HUDRefresh
    local row = WINDOW_MANAGER:CreateControl(nil, parent, CT_CONTROL)
    row:SetAnchor(TOPLEFT, parent, TOPLEFT, 0, 0)
    row:SetDimensions(iconSize, iconSize)

    local icon = WINDOW_MANAGER:CreateControl(nil, row, CT_TEXTURE)
    icon:SetDimensions(iconSize, iconSize)
    icon:SetAnchor(LEFT, row, LEFT, 0, 0)
    row.icon = icon

    local timer = WINDOW_MANAGER:CreateControl(nil, row, CT_LABEL)
    timer:SetFont(string.format("EsoUI/Common/Fonts/univers67.otf|%d|soft-shadow-thick", 12))
    timer:SetAnchor(BOTTOM, row, BOTTOM, 0, 0)
    timer:SetColor(1, 1, 1, 1)
    timer:SetHidden(true)
    row.timer = timer

    row:SetHidden(true)
    return row
end

function AC:HUDInit()
    if AC_HUD.panel then return end

    AC_HUD.panel = WINDOW_MANAGER:CreateTopLevelWindow("AutoConsume_HUDPanel")
    AC_HUD.panel:SetClampedToScreen(true)
    AC_HUD.panel:SetDrawLayer(DL_BACKGROUND)
    AC_HUD.panel:SetDrawTier(DT_LOW)
    AC_HUD.panel:SetDimensions(HUD_ICON_SIZE, HUD_ICON_SIZE * 4 + HUD_SIDE_MARGIN * 3)
    AC_HUD.panel:ClearAnchors()
    AC_HUD.panel:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT,
        AC.savedVariables.hudPosX,
        AC.savedVariables.hudPosY)
    AC_HUD.panel:SetHidden(true)

    AC_HUD.hudFragment = ZO_HUDFadeSceneFragment:New(AC_HUD.panel)

    local function UpdateHUDScenes()
        if not AC_HUD.hudFragment then return end
        local valid_scenes = {"hud", "hudui"}

        for _, s_name in ipairs(valid_scenes) do
            local scene = SCENE_MANAGER:GetScene(s_name)
            if scene then
                scene:RemoveFragment(AC_HUD.hudFragment)
            end
        end

        if AC.savedVariables.hudEnabled then
            for _, s_name in ipairs(valid_scenes) do
                local scene = SCENE_MANAGER:GetScene(s_name)
                if scene then
                    scene:AddFragment(AC_HUD.hudFragment)
                end
            end
        end

        local cur_scene = SCENE_MANAGER:GetCurrentScene()
        if not AC.savedVariables.hudEnabled then
            AC_HUD.panel:SetHidden(true)
        else
            local should_show = cur_scene and cur_scene:HasFragment(AC_HUD.hudFragment)
            AC_HUD.panel:SetHidden(not should_show)
        end
    end

    AC_HUD.updateScenes = UpdateHUDScenes
    AC_HUD.hadEntries = false

    AC_HUD.rows = {}
    for i = 1, 4 do
        AC_HUD.rows[i] = AcHudCreateRow(AC_HUD.panel, i)
    end
end

function AC:HUDScan()
    AC_HUD.active = {}
    if not AC.savedVariables.hudEnabled then return end
    local numBuffs = GetNumBuffs("player")
    for i = 1, numBuffs do
        local buffName, startTime, endTime, buffSlot, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, abilityId = GetUnitBuffInfo("player", i)
        if buffName and buffName ~= "" and endTime and endTime > 0 and effectType ~= BUFF_EFFECT_TYPE_DEBUFF then
            local bType = nil
            if AC.savedVariables.foodID and AcHudIsFood(abilityId, buffName) then
                bType = "food"
            elseif AC.savedVariables.xpItemID and AcHudIsXP(buffName) then
                bType = "xp"
            elseif AC.savedVariables.apItemID and AcHudIsAP(buffName) then
                bType = "ap"
            elseif AcHudIsDelve(abilityId) then
                bType = "delve"
            end
            if bType then
                AC_HUD.active[i] = {
                    icon      = iconName,
                    endTime   = endTime,
                    startTime = startTime,
                    buffType  = bType,
                }
            end
        end
    end
end

function AC:HUDOnEffect(changeType, effectSlot, buffName, effectType, abilityType, iconName, endTime, startTime, abilityId)
    if not AC.savedVariables.hudEnabled then return end
    if changeType == EFFECT_RESULT_GAINED or changeType == EFFECT_RESULT_UPDATED then
        if effectType == BUFF_EFFECT_TYPE_DEBUFF then return end
        local bType = nil
        if AC.savedVariables.foodID and AcHudIsFood(abilityId, buffName) then
            bType = "food"
        elseif AC.savedVariables.xpItemID and AcHudIsXP(buffName) then
            bType = "xp"
        elseif AC.savedVariables.apItemID and AcHudIsAP(buffName) then
            bType = "ap"
        elseif AcHudIsDelve(abilityId) then
            bType = "delve"
        end
        if bType then
            AC_HUD.active[effectSlot] = {
                icon      = iconName,
                endTime   = endTime,
                startTime = startTime,
                buffType  = bType,
            }
        end
    elseif changeType == EFFECT_RESULT_FADED then
        AC_HUD.active[effectSlot] = nil
    end
end

function AC:HUDRefresh()
    if not AC_HUD.panel then return end
    if not AC.savedVariables.hudEnabled then
        AC_HUD.panel:SetHidden(true)
        return
    end

    AC:HUDScan()

    local now        = GetGameTimeSeconds()
    local iconSize   = AC.savedVariables.hudIconSize
    local horizontal = AC.savedVariables.hudHorizontal

    -- Collect entries from active table
    local foodEntry, xpEntry, apEntry, delveEntry = nil, nil, nil, nil
    for slot, entry in pairs(AC_HUD.active) do
        if entry.buffType == "food"  and not foodEntry  then foodEntry  = entry end
        if entry.buffType == "xp"    and not xpEntry    then xpEntry    = entry end
        if entry.buffType == "ap"    and not apEntry    then apEntry    = entry end
        if entry.buffType == "delve" and not delveEntry then delveEntry = entry end
    end

    local entries = {}
    if foodEntry  then entries[#entries+1] = foodEntry  end
    if xpEntry    then entries[#entries+1] = xpEntry    end
    if apEntry    then entries[#entries+1] = apEntry    end
    if delveEntry then entries[#entries+1] = delveEntry end

    local offset = 0
    for i = 1, 4 do
        local row   = AC_HUD.rows[i]
        local entry = entries[i]
        if entry then
            local remaining = math.max(0, entry.endTime - now)

            row:ClearAnchors()
            if horizontal then
                row:SetAnchor(TOPLEFT, AC_HUD.panel, TOPLEFT, offset, 0)
            else
                row:SetAnchor(TOPLEFT, AC_HUD.panel, TOPLEFT, 0, offset)
            end
            row:SetDimensions(iconSize, iconSize)
            row.icon:SetDimensions(iconSize, iconSize)
            row.icon:SetTexture(entry.icon)
            row.icon:SetHidden(false)

            if remaining <= 60 then
                local totalDur = entry.endTime - entry.startTime
                local tr, tg, tb = GetHUDTimerColor(remaining, totalDur)
                row.timer:SetFont(string.format("EsoUI/Common/Fonts/univers67.otf|%d|soft-shadow-thick",
                    math.max(10, math.floor(iconSize * 0.55))))
                row.timer:SetText(string.format("%ds", math.ceil(remaining)))
                row.timer:SetColor(tr, tg, tb, 1)
                row.timer:SetHidden(false)
            else
                row.timer:SetHidden(true)
            end

            row:SetHidden(false)
            offset = offset + iconSize + HUD_SIDE_MARGIN
        else
            row:SetHidden(true)
        end
    end

    if #entries > 0 then
        if horizontal then
            AC_HUD.panel:SetDimensions(offset, iconSize)
        else
            AC_HUD.panel:SetDimensions(iconSize, offset)
        end
        if AC_HUD.hadEntries == false then
            AC_HUD.hadEntries = true
            if AC_HUD.updateScenes then AC_HUD.updateScenes() end
        end
    else
        if AC_HUD.hadEntries ~= false then
            AC_HUD.hadEntries = false
        end
        AC_HUD.panel:SetHidden(true)
    end
end
