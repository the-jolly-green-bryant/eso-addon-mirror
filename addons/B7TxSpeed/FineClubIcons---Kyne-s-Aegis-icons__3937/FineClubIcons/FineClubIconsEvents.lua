FineClubIcons = FineClubIcons or {}

local LIGHTNING_ID = 133428

local function EnableLightningPos()
    FineClubIcons.EnableIcon("FalgravnL11")
    FineClubIcons.EnableIcon("FalgravnL12")
    FineClubIcons.EnableIcon("FalgravnL13")
    FineClubIcons.EnableIcon("FalgravnL14")
    FineClubIcons.EnableIcon("FalgravnL21")
    FineClubIcons.EnableIcon("FalgravnL22")
    FineClubIcons.EnableIcon("FalgravnL23")
    FineClubIcons.EnableIcon("FalgravnL24")
    FineClubIcons.EnableIcon("FalgravnL31")
    FineClubIcons.EnableIcon("FalgravnL32")
    FineClubIcons.EnableIcon("FalgravnL33")
    FineClubIcons.EnableIcon("FalgravnL34")
    FineClubIcons.EnableIcon("FalgravnL41")
    FineClubIcons.EnableIcon("FalgravnL42")
    FineClubIcons.EnableIcon("FalgravnL43")
    FineClubIcons.EnableIcon("FalgravnL44")
end

local function DisableLightningPos()
    FineClubIcons.DisableIcon("FalgravnL11")
    FineClubIcons.DisableIcon("FalgravnL12")
    FineClubIcons.DisableIcon("FalgravnL13")
    FineClubIcons.DisableIcon("FalgravnL14")
    FineClubIcons.DisableIcon("FalgravnL21")
    FineClubIcons.DisableIcon("FalgravnL22")
    FineClubIcons.DisableIcon("FalgravnL23")
    FineClubIcons.DisableIcon("FalgravnL24")
    FineClubIcons.DisableIcon("FalgravnL31")
    FineClubIcons.DisableIcon("FalgravnL32")
    FineClubIcons.DisableIcon("FalgravnL33")
    FineClubIcons.DisableIcon("FalgravnL34")
    FineClubIcons.DisableIcon("FalgravnL41")
    FineClubIcons.DisableIcon("FalgravnL42")
    FineClubIcons.DisableIcon("FalgravnL43")
    FineClubIcons.DisableIcon("FalgravnL44")
end

local function UpdateLightningPos(_,result, isError,_,_, _, _, _, _, _, hitValue, _,  _,  _,  _,  _,  abilityId,_) 
    if (abilityId == LIGHTNING_ID and result == ACTION_RESULT_BEGIN) then
        EnableLightningPos()
        zo_callLater(function() DisableLightningPos() end, 40*1000)
    end
end

function FineClubIcons.RegisterKynesAegis()
    if (not FineClubIcons.WorldIconsEnabled()) then
        FineClubIcons.debug("You must install OdySupportIcons 1.6.3+ to display in-world icons")
    else
        -- Falgravn 1st floor icons
        if (FineClubIcons.savedVariables.kynesaegis.showFalgravn1stFloorIcons) then
            FineClubIcons.EnableIcon("Falgravn1stFloorL")
            FineClubIcons.EnableIcon("Falgravn1stFloorR")
            FineClubIcons.EnableIcon("Falgravn1stFloorT")
        end
        -- Falgravn 2nd floor icons
        if (FineClubIcons.savedVariables.kynesaegis.showFalgravn2ndFloorIcons) then
            FineClubIcons.EnableIcon("Falgravn2ndFloor1")
            FineClubIcons.EnableIcon("Falgravn2ndFloor2")
            FineClubIcons.EnableIcon("Falgravn2ndFloor3")
            FineClubIcons.EnableIcon("Falgravn2ndFloor4")
            FineClubIcons.EnableIcon("Falgravn2ndFloorHR")
        end
        if (FineClubIcons.savedVariables.kynesaegis.showFalgravnLightningPos) then
            EVENT_MANAGER:RegisterForEvent(FineClubIcons.name .. "LightningPos", EVENT_COMBAT_EVENT, UpdateLightningPos)
            EVENT_MANAGER:AddFilterForEvent(FineClubIcons.name .. "LightningPos", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, LIGHTNING_ID)
        end
    end
    FineClubIcons.debug("Registered Kyne's Aegis")
end

function FineClubIcons.UnregisterKynesAegis()
    FineClubIcons.DisableIcon("Falgravn1stFloorL")
    FineClubIcons.DisableIcon("Falgravn1stFloorR")
    FineClubIcons.DisableIcon("Falgravn1stFloorT")

    DisableLightningPos()
    
    FineClubIcons.DisableIcon("Falgravn2ndFloor1")
    FineClubIcons.DisableIcon("Falgravn2ndFloor2")
    FineClubIcons.DisableIcon("Falgravn2ndFloor3")
    FineClubIcons.DisableIcon("Falgravn2ndFloor4")
    FineClubIcons.DisableIcon("Falgravn2ndFloorHR")

    FineClubIcons.debug("Unregistered Kyne's Aegis")
end
