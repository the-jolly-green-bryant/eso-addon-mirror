NAME = "Xvfoo"

Xvfoo = {}
Xvfoo.name = NAME
Xvfoo.url = "https://www.esoui.com/downloads/info3508-Xvfoo-TheCleverAlchemist.html"
Xvfoo.version = "1.1.6"
Xvfoo.potUsed = 0

local debugging = false

local function dd(msg)
    d("[" .. NAME .. "]: " .. msg)
end

local function ddd(msg)
    if debugging then
        dd(msg)
    end
end

local currentHotbar
local CleverAlchemistSetID = 225
local BalorghSetID = 397
local CleverAlchemistAbilityId = 75746
local IamHigh = false
local ZoneIsPvP = false
local isPotion = false

local gear = {}

local NEVER = 'never'
local ALWAYS = 'always'
local MAINBAR = 'mainBar'
local OFFBAR = 'offBar'

local STATE = NEVER -- an attempt to make an ENUM
local pastState = NEVER

local FullBalorgh = false

local FadeInTimeline
local TranslateTimeline

local FadeInAnimation
local TranslateAnimation

local BalorghStrategyDisabled = 'Disabled'
local BalorghStrategyBlockNonCL = 'Block Offensive Bar'
local BalorghStrategyBlockAll = 'Block'

local settings
local defaultSettings = {
    showIndicator = true,
    pvpOnly = false,
    incombatOnly = true,
    balorghStrategy = BalorghStrategyDisabled,
    debugging = false
}

local SLOTS = { -- a lot of rudimentary experimental/debug stuff here, will remove later.
    [EQUIP_SLOT_HEAD] = { EQUIP_SLOT_HEAD, 0, 'Head'},
    [EQUIP_SLOT_NECK] = { EQUIP_SLOT_NECK, 1, 'Neck' },
    [EQUIP_SLOT_CHEST] = { EQUIP_SLOT_CHEST, 2, 'Chest' },
    [EQUIP_SLOT_SHOULDERS] =  { EQUIP_SLOT_SHOULDERS, 3, 'Shoulder'},
    [EQUIP_SLOT_MAIN_HAND] = { EQUIP_SLOT_MAIN_HAND, 4, 'MainHand'},
    [EQUIP_SLOT_OFF_HAND] =  { EQUIP_SLOT_OFF_HAND, 5, 'OffHand' },
    [EQUIP_SLOT_WAIST] =  { EQUIP_SLOT_WAIST, 6, 'Belt' },
    -- [7] = { EQUIP_SLOT_WRIST, 7 , 'wut' },
    [EQUIP_SLOT_LEGS] =  { EQUIP_SLOT_LEGS, 8, 'Leg' },
    [EQUIP_SLOT_FEET] =  { EQUIP_SLOT_FEET, 9, 'Foot' },
    -- [10] = { EQUIP_SLOT_COSTUME, 10, 'disguise?' },
    [EQUIP_SLOT_RING1] =  { EQUIP_SLOT_RING1, 11, 'Ring1' },
    [EQUIP_SLOT_RING2] =  { EQUIP_SLOT_RING2, 12, 'Ring2' },
    --[13] = { EQUIP_SLOT_POISON, 13, 'poison1'},
    --[14] = { EQUIP_SLOT_BACKUP_POISON, 14, 'poison2'},
    -- [15] = { EQUIP_SLOT_RANGED, 15, 'wut'},
    [EQUIP_SLOT_HAND] = { EQUIP_SLOT_HAND, 16, 'Glove'},
    -- [17] = { EQUIP_SLOT_CLASS1, 17, 'wut'},
    -- [18] = { EQUIP_SLOT_CLASS2, 18, 'wut'},
    -- [19] = { EQUIP_SLOT_CLASS3, 19, 'wut'},
    [EQUIP_SLOT_BACKUP_MAIN] =  { EQUIP_SLOT_BACKUP_MAIN, 20, 'BackupMain' },
    [EQUIP_SLOT_BACKUP_OFF] = { EQUIP_SLOT_BACKUP_OFF, 21, 'BackupOff' }
}

local function printState()
    if (STATE == MAINBAR) then
        dd("Clever Alchemist on Mainbar")
    elseif (STATE == OFFBAR) then
        dd("Clever Alchemist on Backbar")
    elseif (STATE == NEVER) then
        dd("Not enough Clever Alchemist pieces equipped")
    elseif (STATE == ALWAYS) then
        dd("Clever Alchemist Equipped")
    end
    if FullBalorgh then
        dd("Balorgh Equiped")
    end
end

local function stateToChat()
    if pastState ~= STATE and pastState then
        printState()
    end
    pastState = STATE
end

local function toggleVisibility() -- TODO: rewrite this garbage
    if not XvfooReticleIcon then
        return
    end
	if (STATE == MAINBAR) then
        XvfooReticleIcon:SetHidden(false)
		XvfooReticleIcon:SetAlpha(0)
		if currentHotbar == 0 then
			XvfooReticleIcon:SetAlpha(0.5)
		end
    elseif (STATE == OFFBAR) then
        XvfooReticleIcon:SetHidden(false)
		XvfooReticleIcon:SetAlpha(0)
		if currentHotbar == 1 then
			XvfooReticleIcon:SetAlpha(0.5)
		end
    elseif (STATE == NEVER) then
        XvfooReticleIcon:SetHidden(true)
    elseif (STATE == ALWAYS) then
		XvfooReticleIcon:SetHidden(true)
    end
end

local function isTwoHanded(weaponType)
    if weaponType == WEAPONTYPE_HEALING_STAFF or weaponType == WEAPONTYPE_FIRE_STAFF or weaponType == WEAPONTYPE_FROST_STAFF or weaponType == WEAPONTYPE_LIGHTNING_STAFF then
        return true
    elseif weaponType == WEAPONTYPE_BOW  or weaponType == WEAPONTYPE_TWO_HANDED_AXE or weaponType == WEAPONTYPE_TWO_HANDED_HAMMER or weaponType == WEAPONTYPE_TWO_HANDED_SWORD then
        return true
    else
        return false
    end
end

function eval()
    local equipped = 0
    -- local totalBonus = 0
    local armorBonus = 0
    local mainBarBonus = 0
    local offBarBonus = 0

    local BalorghEquiped = 0

    if (gear == {}) then
        getEquippedGear()
    end

    for i, v in pairs(gear) do
        if gear[i]["isAlchemist"] == true then
            equipped = equipped + 1
            if gear[i]["type"] == ITEMTYPE_ARMOR then
                armorBonus = armorBonus + 1
            elseif gear[i]["slot"] == EQUIP_SLOT_MAIN_HAND or gear[i]["slot"] == EQUIP_SLOT_OFF_HAND then
                ddd("mainbar: " .. gear[i]["weaponType"])
                if isTwoHanded(gear[i]["weaponType"]) then
                    mainBarBonus = mainBarBonus + 2
                else
                    mainBarBonus = mainBarBonus + 1
                end
            elseif gear[i]["slot"] == EQUIP_SLOT_BACKUP_MAIN or gear[i]["slot"] == EQUIP_SLOT_BACKUP_OFF then
                ddd("backbar: " .. gear[i]["weaponType"])
                if isTwoHanded(gear[i]["weaponType"]) then
                    offBarBonus = offBarBonus + 2
                else
                    offBarBonus = offBarBonus + 1
                end
            end
        elseif gear[i]["isBalorgh"] == true then
            BalorghEquiped = BalorghEquiped + 1
        end
    end

    if equipped < 4 then
        STATE = NEVER
    elseif armorBonus >= 5 then
        STATE = ALWAYS
    elseif armorBonus <= 2 then
        STATE = NEVER
    elseif mainBarBonus == offBarBonus == 2 then
        STATE = ALWAYS
    elseif mainBarBonus + armorBonus >= 5 then
        STATE = MAINBAR
    elseif offBarBonus + armorBonus >= 5 then
        STATE = OFFBAR
    else
        STATE = NEVER
    end

    if BalorghEquiped == 2 then
        FullBalorgh = true
    end

    stateToChat()

    if settings.showIndicator then
	    toggleVisibility()
    end
end

function parseSlot(eventCode, bagId, slotIndex, isNewItem, itemSoundCategory, updateReason, stackCountChange)
    local itemLink = GetItemLink(BAG_WORN, slotIndex)
    local itemType, specializedItemType = GetItemLinkItemType(itemLink)
	local hasSet, setName, numBonuses, numNormalEquipped, maxEquipped, setId, numPerfectedEquipped = GetItemLinkSetInfo(itemLink)
    local weaponType
    if itemType == ITEMTYPE_WEAPON then
        weaponType = GetItemWeaponType(BAG_WORN, slotIndex)        
    end
    if hasSet then
        ddd("slotIndex: " .. slotIndex)
        ddd("set name: " .. setName)
        ddd("set id: " .. setId)
        ddd("itemType: " .. itemType)
        ddd("------")
    end
    if hasSet then
        local gearItem = { link = itemLink, type = itemType, weaponType = weaponType, slot = slotIndex, isAlchemist = false, isBalorgh = false }
        if setId == CleverAlchemistSetID then
            gearItem["isAlchemist"] = true
            gear[slotIndex] = gearItem
        elseif setId == BalorghSetID then
            gearItem["isBalorgh"] = true
            gear[slotIndex] = gearItem
        end
    end

	if Xvfoo.ready then
		eval()
	end
end

function getEquippedGear()
 --   for x = 1, #SLOTS do
    for i, v in pairs(SLOTS) do
        parseSlot(0, 0, v[1], 0, 0, 0, 0)
    end
end

local function createReticleControl()
	XvfooReticleIcon = WINDOW_MANAGER:CreateControl("XvfooRecticleControl", ZO_ReticleContainer, CT_TEXTURE)
	XvfooReticleIcon:ClearAnchors()
	XvfooReticleIcon:SetAnchor(CENTER, ZO_ReticleContainer, CENTER, 50, 0)
	XvfooReticleIcon:SetTexture("/esoui/art/treeicons/gamepad/progression_levelup_choiceofpotion.dds")
	XvfooReticleIcon:SetDimensions(45, 45)
	XvfooReticleIcon:SetColor(240, 240, 240, 0.5)
	XvfooReticleIcon:SetHidden(true)
end

local function registerAnimations(control)
    local isValidAnchor, point, relativeTo, relativePoint, offsetX, offsetY = control:GetAnchor()

    TranslateAnimation, TranslateTimeline = CreateSimpleAnimation(ANIMATION_TRANSLATE, control)
    TranslateAnimation:SetTranslateOffsets(offsetX, offsetY, offsetX - 15, offsetY)
    TranslateAnimation:SetDuration(70)
    TranslateAnimation:SetEasingFunction(ZO_EaseInQuadratic)

    FadeInAnimation, FadeInTimeline = CreateSimpleAnimation(ANIMATION_ALPHA, control)
    FadeInAnimation:SetAlphaValues(0, 0.5)
    FadeInAnimation:SetDuration(200)
    FadeInAnimation:SetEasingFunction(ZO_EaseOutQuadratic)    
end

local function checkIfZoneIsPvP(zoneName, subzoneName)
    if IsPlayerInAvAWorld() or IsActiveWorldBattleground() then
        ZoneIsPvP = true
    else
        ZoneIsPvP = false
    end
end

local function getQuickSlotItemInfo(eventCode, actionSlotIndex)
	local itemLink = GetSlotItemLink(actionSlotIndex, HOTBAR_CATEGORY_QUICKSLOT_WHEEL)
	local itemLinkItemType, itemLinkSpecializedItemType = GetItemLinkItemType(itemLink)
	if itemLinkItemType == ITEMTYPE_POTION then
		isPotion = true
	else
		isPotion = false
	end
    -- if itemLink ~= "" then
    --     local guildName, color, linkType, itemId = ZO_LinkHandler_ParseLink(itemLink)
    --     if isPotion then
    --         ddd(itemLink .. " is potion - [" .. itemId .. "] on slot: "  .. actionSlotIndex)
    --     else
    --         ddd(itemLink .. " is not potion - [" .. itemId .. "] on slot: "  .. actionSlotIndex)
    --     end
    -- end
end

local function toUseOrNotToUse()
    if STATE == NEVER then
        return false
    end
    local slotNum = tonumber(debug.traceback():match('keybind = "ACTION_BUTTON_(%d)')) or tonumber(debug.traceback():match('keybind = "GAMEPAD_ACTION_BUTTON_(%d)'))
    local isCLBar
    if (currentHotbar == 1 and STATE == MAINBAR) or (currentHotbar == 0 and STATE == OFFBAR) then
        isCLBar = false
    else
        isCLBar = true
    end
    if slotNum == 8 then -- ultimate
        if not FullBalorgh then
            return false -- break if no balorgh
        end
        if IamHigh then
            ddd("Boom")
            return false
        end
        if settings.balorghStrategy == BalorghStrategyDisabled then
            return false -- break if disabled
        elseif settings.balorghStrategy == BalorghStrategyBlockNonCL then
            if isCLBar then
                return false -- let through on defensive ultimate
            else
                ddd("Ultimate blocked: Clever Alchemist not active(on offensive bar)")
                return true -- block offensive ultimate
            end
        elseif settings.balorghStrategy == BalorghStrategyBlockAll then
            ddd("Ultimate blocked: Clever Alchemist not active")
            return true -- block ultimate
        end
        return false
    end
    if slotNum ~= 9 then
        -- ddd("slotNum: " .. slotNum)
        return false
    end
    -- potion
    if not isPotion then
        -- ddd("not potion")
        return false
    end

    if settings.pvpOnly and not ZoneIsPvP then
        ddd("potion fired up: not in pvp zone")
        Xvfoo.potUsed = GetGameTimeSeconds()
        return false
    end

    if (currentHotbar == 1 and STATE == MAINBAR) or (currentHotbar == 0 and STATE == OFFBAR) then
        ddd("potion blocked: wrong bar")
        return true -- ESO won't run ability press if PreHook returns true
    elseif settings.incombatOnly and (not IsUnitInCombat("player")) and (STATE ~= NEVER) then
        ddd("potion blocked: out of combat")
        return true
    else
        -- ddd("potion fired up")
    end
    Xvfoo.potUsed = GetGameTimeSeconds()
    return false
end

local function InitializeMenu()
    settings = LibSavedVars:NewAccountWide(Xvfoo.name .. "_Account", defaultSettings)
	settings:AddCharacterSettingsToggle(Xvfoo.name .. "_Characters")
    settings:MigrateFromAccountWide( { name = Xvfoo.name .. "_Account" } )
    if LSV_Data.EnableDefaultsTrimming then
        settings:EnableDefaultsTrimming()
    end
    debugging = settings.debugging
    local panelData = {
        type = "panel",
        name = Xvfoo.name,
        author = "@Xorzoo",
        version = Xvfoo.version,
        website = Xvfoo.url,
    }
    local panelName = Xvfoo.name
    local LAM = LibAddonMenu2
	LAM:RegisterAddonPanel(panelName, panelData)
    local optionsData = {
        settings:GetLibAddonMenuAccountCheckbox(),
        {
            type = "header",
            name = "Options",
            width = "full",	--or "half" (optional)
        },
        {
            type = "checkbox",
            name = "Reticle Indicator",
            tooltip = "Show alchemy bottle icon beside reticle when you have full set pieces equipped",
            getFunc = function() return settings.showIndicator end,
            setFunc = function(value) settings.showIndicator = value end,
            width = "full",
            requiresReload = true,
        },
        {
            type = "checkbox",
            name = "PvP only mode",
            tooltip = "Only activate in Cyrodiil and Battlegrounds",
            getFunc = function() return settings.pvpOnly end,
            setFunc = function(value) settings.pvpOnly = value end,
            width = "full",
            requiresReload = true
        },
        {
            type = "checkbox",
            name = "In-Combat only mode",
            tooltip = "Use potion only when in combat",
            getFunc = function() return settings.incombatOnly end,
            setFunc = function(value) settings.incombatOnly = value end,
            width = "full",
        },
        {
            type = "dropdown",
            name = "Balorgh Strategy",
            tooltip = "When you have Balorgh equiped, block use ultimate ability when Clever Alchemist buff is not active",
            choices = {BalorghStrategyBlockNonCL, BalorghStrategyBlockAll, BalorghStrategyDisabled},
            getFunc = function() return settings.balorghStrategy end,
            setFunc = function(value) settings.balorghStrategy = value end,
            width = "full",
        },
        {
            type = "header",
            width = "full",	--or "half" (optional)
        },
        {
            type = "checkbox",
            name = "Debugging",
            getFunc = function() return settings.debugging end,
            setFunc = function(value)
                settings.debugging = value
                debugging = value
            end
        }
    }
	LAM:RegisterOptionControls(panelName, optionsData)
end

local function onBarSwap(eventCode, isHotbarSwap)
    if isHotbarSwap then
        currentHotbar = 1 - currentHotbar -- switch between 0 and 1
    end
    if not FadeInTimeline then
        return
    end
    if (currentHotbar == 0 and STATE == MAINBAR) or (currentHotbar == 1 and STATE == OFFBAR) then
        FadeInTimeline:PlayForward()
    else
        FadeInTimeline:PlayBackward() -- fadeOut :P
    end
end

local function onReticleUpdated(self)
    if not TranslateTimeline then
        return
    end
    local interactionPossible = not self.interact:IsHidden()
    if (interactionPossible or PLAYER_TO_PLAYER:HasTarget() or IsGameCameraUnitHighlightedAttackable()) and (GetUnitStealthState("player") == 0) then
        TranslateTimeline:PlayForward()
    else
        TranslateTimeline:PlayBackward()
    end
end

local function handleCombatEvent(result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log)
    
end

local function onEffectChanged(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, castByPlayer)
    -- ddd("unitTag: " .. unitTag)
    if changeType == EFFECT_RESULT_GAINED then
        -- ddd("gained: " .. effectName)
        IamHigh = true
    elseif changeType == EFFECT_RESULT_FADED then
        -- ddd("faded: " .. effectName)
        IamHigh = false
    else
        -- ddd(changeType)
    end
    -- ddd("abilityId: " .. abilityId)
end

function Initialize()
    EVENT_MANAGER:UnregisterForEvent(Xvfoo.name, EVENT_ADD_ON_LOADED)

    InitializeMenu()

    if settings.showIndicator then
        createReticleControl()
        registerAnimations(XvfooReticleIcon)
    end

    for i, v in pairs(SLOTS) do
        gear[i] = {
            id = 0,
            link = 0,
            type = 0,
            isAlchemist = false,
            isBalorgh = false,
            slot = 0
        }
    end

	currentHotbar = ACTION_BAR_ASSIGNMENT_MANAGER:GetCurrentHotbarCategory() -- get initial bar

    getEquippedGear()
    eval()
    Xvfoo.ready = true

	getQuickSlotItemInfo(0, GetCurrentQuickslot()) -- if there's a potion slotted on login

	EVENT_MANAGER:RegisterForEvent(Xvfoo.name, EVENT_ACTIVE_QUICKSLOT_CHANGED, getQuickSlotItemInfo)
    EVENT_MANAGER:RegisterForEvent(Xvfoo.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, parseSlot)
    EVENT_MANAGER:AddFilterForEvent(Xvfoo.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_WORN)
    EVENT_MANAGER:AddFilterForEvent(Xvfoo.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_INVENTORY_UPDATE_REASON, INVENTORY_UPDATE_REASON_DEFAULT)
    EVENT_MANAGER:RegisterForEvent(Xvfoo.name, EVENT_ACTION_SLOTS_FULL_UPDATE, onBarSwap)
    -- EVENT_MANAGER:RegisterForEvent(Xvfoo.name, EVENT_COMBAT_EVENT, handleCombatEvent)
    EVENT_MANAGER:RegisterForEvent(Xvfoo.name, EVENT_EFFECT_CHANGED, onEffectChanged)
    EVENT_MANAGER:AddFilterForEvent(Xvfoo.name, EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, CleverAlchemistAbilityId)
    EVENT_MANAGER:AddFilterForEvent(Xvfoo.name, EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG, "player")



	SLASH_COMMANDS["/xvfoo"] = getEquippedGear

    if settings.pvpOnly then
        EVENT_MANAGER:RegisterForEvent(Xvfoo.name, EVENT_ZONE_CHANGED, checkIfZoneIsPvP)
        checkIfZoneIsPvP() -- if we are in AvA/BG on login
    end

    if settings.showIndicator then
        SecurePostHook(ZO_Reticle, "OnUpdate", onReticleUpdated)
    end

    ZO_PreHook("ZO_ActionBar_CanUseActionSlots", toUseOrNotToUse)
end

local function OnAddOnLoaded(event, addonName)
	if addonName == Xvfoo.name then
		Initialize()
	end
end

EVENT_MANAGER:RegisterForEvent(Xvfoo.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
