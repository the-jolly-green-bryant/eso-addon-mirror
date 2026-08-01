PearlsTracker = PearlsTracker or {}
local PT = PearlsTracker

local ultiGain = 0

function PT.IsPearlsEquiped()
    _, _, _, numNormalEquipped, _, _ = GetItemLinkSetInfo("|H0:item:171437:364:50:0:0:0:0:0:0:0:0:0:0:0:2048:0:0:0:0:0:0|h|h", true)
    if numNormalEquipped >= 1 then
        return true
    end
    return false
end

function PT.UpdateUI()
    local magicka, maxMagicka = GetUnitPower("player", POWERTYPE_MAGICKA)
    local stamina, maxStamina = GetUnitPower("player", POWERTYPE_STAMINA)

    -- assume mainResource is magicka
    local mainResource = magicka
    local mainMaxResource = maxMagicka

    -- check if stamina is the main resource, if yes, overwrite mainResource & mainMaxResource
    if maxStamina > maxMagicka then
        mainResource = stamina
        mainMaxResource = maxStamina
    end

    -- calculate resource percentage
    local percentage = math.floor(100 * mainResource / mainMaxResource + 0.5)

    local color
    if percentage < PT.PEARLS_PROC_PERCENTAGE then
        color = PT.SV.colors.belowThreshold
    else
        color = PT.SV.colors.aboveThreshold
    end

    if PT.SV.background.outline then
        PT.icon.SetBackgroundOutlineColor(unpack(color))
    else
        PT.icon.SetBackgroundOutlineColor(0, 0, 0, PT.SV.background.opacity / 100)
    end
        --PearlsTrackerPanel_Icon_Background:SetCenterColor(unpack(edgeColor))

    PT.icon.SetResourceColor(unpack(color))
    PT.icon.SetResourceValue(percentage)
    PT.icon.SetUltiGainValue(ultiGain)
end

function PT.OnUpdate()
    if PT.isEquipped then
        PT.UpdateUI()
    end
end

function PT.OnUltiGain(_, _, _, _, _, _, _, _, _, _, hitValue, _, _, _, _, _, _, _)
    ultiGain = ultiGain + hitValue
end

function PT.RegisterOnUpdate()
    EVENT_MANAGER:RegisterForUpdate(PT.name .. "Update", PT.SV.updateInterval, PT.OnUpdate )
end
function PT.UnregisterOnUpdate()
    EVENT_MANAGER:UnregisterForUpdate(PT.name .. "Update")
end

function PT.OnCombatStateUpdate(_, inCombat)
    if inCombat then
        if PT.SV.ResetUltiGainOnEnterCombat then
            ultiGain = 0
        end
    end
end

function PT.RegisterCombatStateUpdate()
    EVENT_MANAGER:RegisterForEvent(PT.name .. "CombatStateUpdate", EVENT_PLAYER_COMBAT_STATE, PT.OnCombatStateUpdate)
end
function PT.UnregisterCombatStateUpdate()
    EVENT_MANAGER:UnregisterForEvent(PT.name .. "CombatStateUpdate", EVENT_PLAYER_COMBAT_STATE)
end

function PT.RegisterUltiGain()
    EVENT_MANAGER:RegisterForEvent(PT.name .. "UltiGain", EVENT_COMBAT_EVENT, PT.OnUltiGain)
    EVENT_MANAGER:AddFilterForEvent(PT.name .. "UltiGain", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, PT.PEARLS_ABILITY_ID)
    EVENT_MANAGER:AddFilterForEvent(PT.name .. "UltiGain", EVENT_COMBAT_EVENT, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
end
function PT.UnregisterUltiGain()
    EVENT_MANAGER:UnregisterForEvent(PT.name .. "UltiGain", EVENT_COMBAT_EVENT)
end

function PT.RegisterOnEquip()
    EVENT_MANAGER:RegisterForEvent(PT.name.."OnEquip", EVENT_COMBAT_EVENT, PT.OnEquip)
    EVENT_MANAGER:AddFilterForEvent(PT.name.."OnEquip", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, PT.PEARLS_EQUIP_ID)
end
function PT.UnregisterOnEquip()
    EVENT_MANAGER:UnregisterForEvent(PT.name.."OnEquip", EVENT_COMBAT_EVENT)
end

function PT.Enable()
    PT.icon.Restore()

    PT.RegisterOnEquip()
    PT.RegisterOnUpdate()
    PT.RegisterCombatStateUpdate()

    if not PT.SV.ultiGain.hide then
        PT.RegisterUltiGain()
    end

    PT.isEquipped = PT.IsPearlsEquiped()
    if PT.isEquipped then
        PT.icon.Hide(false)
    end
end
function PT.Disable()
    PT.UnregisterOnEquip()
    PT.UnregisterOnUpdate()
    PT.UnregisterCombatStateUpdate()
    PT.UnregisterUltiGain()

    PT.icon.Hide(true)

end

function PT.OnEquip(event, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
    PT.isEquipped = PT.IsPearlsEquiped()
    PT.icon.Hide(not PT.isEquipped)
end

function PT.OnAddOnLoaded(_, addonName)
    if addonName == PT.name then
        EVENT_MANAGER:UnregisterForEvent(PT.name, EVENT_ADD_ON_LOADED)

        -- load saved variables ( global )
        PT.SV = ZO_SavedVars:NewAccountWide(PT.savedVariableTable, PT.variableVersion, nil, PT.defaultVariables, GetWorldName())

        if PT.SV.enabled then
            PT.Enable()
        end

        -- create the LibAddonMenu entry
        PT.menu.createAddonMenu()
    end
end

EVENT_MANAGER:RegisterForEvent(PT.name, EVENT_ADD_ON_LOADED, PT.OnAddOnLoaded)