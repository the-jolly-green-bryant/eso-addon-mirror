ArkasisBlocker = {}
ArkasisBlocker.name = "ArkasisBlocker"
ArkasisBlocker.version = "1.0.4"
ArkasisBlocker.potUsed = 0

local debugging = false

local function dd(msg)
    d("[" .. ArkasisBlocker.name .. "]: " .. msg)
end

local function ddd(msg)
    if debugging then
        dd(msg)
    end
end

local currentHotbar
local ArkasisSetID = 518
local ArkasisAbilityId = 142660
local IamHigh = false
local isPotion = false

local gear = {}

local NEVER = 'never'
local ALWAYS = 'always'
local MAINBAR = 'mainBar'
local OFFBAR = 'offBar'

local STATE = NEVER -- an attempt to make an ENUM
local pastState = NEVER


local FadeInTimeline
local TranslateTimeline

local FadeInAnimation
local TranslateAnimation


local settings
local defaultSettings = {
    showIndicator = true,
    debugging = false,
    incombatOnly = true,
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
        dd("Arkasis on Mainbar")
    elseif (STATE == OFFBAR) then
        dd("Arkasis on Backbar")
    elseif (STATE == ALWAYS) then
        dd("Arkasis Equipped")
    end
end

local function stateToChat()
    if pastState ~= STATE and pastState then
        printState()
    end
    pastState = STATE
end

local function toggleVisibility() -- TODO: rewrite this garbage
    if not ArkasisReticleIcon then
        return
    end
	if (STATE == MAINBAR) then
        ArkasisReticleIcon:SetHidden(false)
		ArkasisReticleIcon:SetAlpha(0)
		if currentHotbar == 0 then
			ArkasisReticleIcon:SetAlpha(0.5)
		end
    elseif (STATE == OFFBAR) then
        ArkasisReticleIcon:SetHidden(false)
		ArkasisReticleIcon:SetAlpha(0)
		if currentHotbar == 1 then
			ArkasisReticleIcon:SetAlpha(0.5)
		end
    elseif (STATE == NEVER) then
        ArkasisReticleIcon:SetHidden(true)
    elseif (STATE == ALWAYS) then
		ArkasisReticleIcon:SetHidden(true)
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

local function eval()
    local equipped = 0
    -- local totalBonus = 0
    local armorBonus = 0
    local mainBarBonus = 0
    local offBarBonus = 0

    if (gear == {}) then
        getEquippedGear()
    end

    for i, v in pairs(gear) do
        if gear[i]["isArkasis"] == true then
            equipped = equipped + 1
            if gear[i]["type"] == ITEMTYPE_ARMOR then
                armorBonus = armorBonus + 1
            elseif gear[i]["slot"] == EQUIP_SLOT_MAIN_HAND or gear[i]["slot"] == EQUIP_SLOT_OFF_HAND then
                ddd("mainbar: " .. gear[i]["weaponType"])
                if isTwoHanded(gear[i]["weaponType"]) then
                    mainBarBonus = mainBarBonus + 2
                    equipped = equipped + 1
                else
                    mainBarBonus = mainBarBonus + 1
                end
            elseif gear[i]["slot"] == EQUIP_SLOT_BACKUP_MAIN or gear[i]["slot"] == EQUIP_SLOT_BACKUP_OFF then
                ddd("backbar: " .. gear[i]["weaponType"])
                if isTwoHanded(gear[i]["weaponType"]) then
                    offBarBonus = offBarBonus + 2
                    equipped = equipped + 1
                else
                    offBarBonus = offBarBonus + 1
                end
            end
        end
    end

    if equipped <= 4 then
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

    stateToChat()

    if settings.showIndicator then
	    toggleVisibility()
    end
end

local function parseSlot(eventCode, bagId, slotIndex, isNewItem, itemSoundCategory, updateReason, stackCountChange)
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

    if gear[slotIndex] then
        gear[slotIndex].isArkasis = false
    end
    if hasSet then
        local gearItem = { link = itemLink, type = itemType, weaponType = weaponType, slot = slotIndex, isArkasis = false}
        if setId == ArkasisSetID then
            gearItem["isArkasis"] = true
            gear[slotIndex] = gearItem
        end
    end

	if ArkasisBlocker.ready then
		eval()
	end
end

local function getEquippedGear()
 --   for x = 1, #SLOTS do
    for i, v in pairs(SLOTS) do
        parseSlot(0, 0, v[1], 0, 0, 0, 0)
    end
end

local function createReticleControl()
	ArkasisReticleIcon = WINDOW_MANAGER:CreateControl("XvfooRecticleControl", ZO_ReticleContainer, CT_TEXTURE)
	ArkasisReticleIcon:ClearAnchors()
	ArkasisReticleIcon:SetAnchor(CENTER, ZO_ReticleContainer, CENTER, 50, 0)
	ArkasisReticleIcon:SetTexture("/esoui/art/treeicons/gamepad/progression_levelup_choiceofpotion.dds")
	ArkasisReticleIcon:SetDimensions(45, 45)
	ArkasisReticleIcon:SetColor(240, 240, 240, 0.5)
	ArkasisReticleIcon:SetHidden(true)
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


local function getQuickSlotItemInfo(eventCode, actionSlotIndex)
	local itemLink = GetSlotItemLink(actionSlotIndex, HOTBAR_CATEGORY_QUICKSLOT_WHEEL)
	local itemLinkItemType, itemLinkSpecializedItemType = GetItemLinkItemType(itemLink)
	if itemLinkItemType == ITEMTYPE_POTION then
		isPotion = true
	else
		isPotion = false
	end
end

local function toUseOrNotToUse()
    if STATE == NEVER then
        return false
    end

    local isInGamepadMode = IsInGamepadPreferredMode()
    local debugTraceBack = debug.traceback()
    local slotNum = isInGamepadMode and tonumber(debugTraceBack :match('keybind = "GAMEPAD_ACTION_BUTTON_(%d)')) or tonumber(debugTraceBack:match('keybind = "ACTION_BUTTON_(%d)'))

    local isCLBar
    if (currentHotbar == 1 and STATE == MAINBAR) or (currentHotbar == 0 and STATE == OFFBAR) then
        isCLBar = false
    else
        isCLBar = true
    end
    if slotNum == 8 then -- ultimate
        if IamHigh then
            ddd("Boom")
            return false
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

    if (currentHotbar == 1 and STATE == MAINBAR) or (currentHotbar == 0 and STATE == OFFBAR) then
        ddd("potion blocked: wrong bar")
        return true -- ESO won't run ability press if PreHook returns true
    elseif settings.incombatOnly and (not IsUnitInCombat("player")) and (STATE ~= NEVER) then
        ddd("potion blocked: out of combat")
        return true
    else
        -- ddd("potion fired up")
    end
    ArkasisBlocker.potUsed = GetGameTimeSeconds()
    return false
end

local function InitializeMenu()
    settings = LibSavedVars:NewAccountWide("ArkasisBlocker_SV", defaultSettings)
    debugging = settings.debugging
    local panelData = {
        type = "panel",
        name = ArkasisBlocker.name,
        author = "@Treuce",
        version = ArkasisBlocker.version,
    }
    local panelName = "Arkasis Blocker"
    local LAM = LibAddonMenu2
	LAM:RegisterAddonPanel(panelName, panelData)
    local optionsData = {
        {
            type = "description",
            text = "Arkasis blocker based on @Xorzoo's Xvfoo - The Clever Alchemist addon. https://www.esoui.com/downloads/info3508-Xvfoo-TheCleverAlchemist.html",
            width = "full"
        },
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
            name = "In-Combat only mode",
            tooltip = "Use potion only when in combat, does not allow potion use outside of combat if in arkasis.",
            getFunc = function() return settings.incombatOnly end,
            setFunc = function(value) settings.incombatOnly = value end,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Debug",
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
        currentHotbar = ACTION_BAR_ASSIGNMENT_MANAGER:GetCurrentHotbarCategory()
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

local function Initialize()
    EVENT_MANAGER:UnregisterForEvent(ArkasisBlocker.name, EVENT_ADD_ON_LOADED)

    InitializeMenu()

    if settings.showIndicator then
        createReticleControl()
        registerAnimations(ArkasisReticleIcon)
    end

    for i, v in pairs(SLOTS) do
        gear[i] = {
            id = 0,
            link = 0,
            type = 0,
            isArkasis = false,
            slot = 0
        }
    end

	currentHotbar = ACTION_BAR_ASSIGNMENT_MANAGER:GetCurrentHotbarCategory() -- get initial bar

    getEquippedGear()
    eval()
    ArkasisBlocker.ready = true

	getQuickSlotItemInfo(0, GetCurrentQuickslot()) -- if there's a potion slotted on login

	EVENT_MANAGER:RegisterForEvent(ArkasisBlocker.name, EVENT_ACTIVE_QUICKSLOT_CHANGED, getQuickSlotItemInfo)
    EVENT_MANAGER:RegisterForEvent(ArkasisBlocker.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, parseSlot)
    EVENT_MANAGER:AddFilterForEvent(ArkasisBlocker.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_WORN)
    EVENT_MANAGER:AddFilterForEvent(ArkasisBlocker.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_INVENTORY_UPDATE_REASON, INVENTORY_UPDATE_REASON_DEFAULT)
    EVENT_MANAGER:RegisterForEvent(ArkasisBlocker.name, EVENT_ACTION_SLOTS_FULL_UPDATE, onBarSwap)
    -- EVENT_MANAGER:RegisterForEvent(ArkasisBlocker.name, EVENT_COMBAT_EVENT, handleCombatEvent)
    EVENT_MANAGER:RegisterForEvent(ArkasisBlocker.name, EVENT_EFFECT_CHANGED, onEffectChanged)
    EVENT_MANAGER:AddFilterForEvent(ArkasisBlocker.name, EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, ArkasisAbilityId)
    EVENT_MANAGER:AddFilterForEvent(ArkasisBlocker.name, EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG, "player")

    EVENT_MANAGER:RegisterForEvent(ArkasisBlocker.name, EVENT_ARMORY_BUILD_RESTORE_RESPONSE, function(_, result, _) 
        if result == ARMORY_BUILD_RESTORE_RESULT_SUCCESS then 
            getEquippedGear()
            eval()
        end
    end)


	SLASH_COMMANDS["/arkasisblocker"] = getEquippedGear

    if settings.showIndicator then
        SecurePostHook(ZO_Reticle, "OnUpdate", onReticleUpdated)
    end

    
    zo_callLater(function()
            ZO_PreHook("ZO_ActionBar_CanUseActionSlots", toUseOrNotToUse)
     end, 5000)

end

local function OnAddOnLoaded(event, addonName)
	if addonName == ArkasisBlocker.name then
		Initialize()
	end
end

EVENT_MANAGER:RegisterForEvent(ArkasisBlocker.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
