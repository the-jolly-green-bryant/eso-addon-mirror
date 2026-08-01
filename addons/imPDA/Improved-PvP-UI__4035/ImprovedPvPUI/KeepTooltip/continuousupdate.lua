local Log = IMP_PVP_UI_Logger('IMP_KT_CONTUPDATE')

local MAP_PIN_MANAGER = ZO_WorldMap_GetPinManager()

local EVENT_NAMESPACE = 'IMP_KT_CONTINUOUSUPDATE'

local function IsOverLocalBattlegroundContextKeep()
    local foundTooltipMouseOverPins = MAP_PIN_MANAGER.foundTooltipMouseOverPins
    for i, pin in ipairs(foundTooltipMouseOverPins) do
        if pin:IsKeepOrDistrict() and IsLocalBattlegroundContext(pin:GetBattlegroundContext()) then
            return true
        end
    end

    return false
end

function IMP_KT_EnableContinuousTooltipUpdate()
    Log('Continuous update enabled')

    ZO_PostHook('ZO_WorldMap_HandlePinEnter', function()
        if not IsOverLocalBattlegroundContextKeep() then return end
        EVENT_MANAGER:RegisterForUpdate(EVENT_NAMESPACE, 1000, function()
            Log('Refresh')
            ZO_KeepTooltip:RefreshKeepInfo()
        end)
    end)

    ZO_PostHook('ZO_WorldMap_HandlePinExit', function()
        EVENT_MANAGER:UnregisterForUpdate(EVENT_NAMESPACE)
    end)
end