BSCScribingFavorite = BSCScribingFavorite or {}
local BSCSF = BSCScribingFavorite

BSCSF.Name = "BSCs-ScribingFavorite"
BSCSF.SavedVar = "BSCSFSaved"
BSCSF.mode = 0
BSCSF.SelectedAbilityData = nil

local defaultSV = { 
	SCAL = { }
}
function BSCSF:MakeKey(abilityId, p, s, t, customName)
    return table.concat({abilityId, p, s, t, customName or ""}, ":")
end
function BSCSF:MakeKey4(a, p, s, t)
    return string.format("%d|%d|%d|%d", a or 0, p or 0, s or 0, t or 0)
end
function BSCSF:IsInFavorite(tbl)
	return BSCSF.indexNoName and BSCSF.indexNoName[ BSCSF:MakeKey4(tbl[1], tbl[2], tbl[3], tbl[4]) ] == true
end
function BSCSF:HasAnyFavoriteCraftedAbilities()
    return BSCSF.SV_ACC and BSCSF.SV_ACC.SCAL and #BSCSF.SV_ACC.SCAL > 0
end
function BSCSF:AddToFavorite(data)
    if not BSCSF:IsInFavorite(data) then
        table.insert(BSCSF.SV_ACC.SCAL, data)
        BSCSF.index[ BSCSF:MakeKey(data[1], data[2], data[3], data[4], data[5]) ] = true
		BSCSF.indexNoName[ BSCSF:MakeKey4(data[1], data[2], data[3], data[4]) ] = true
        PlaySound(SOUNDS.SCRIBING_SCRIBE_TOOLTIP_GLOW)
    end
end
function BSCSF:RemoveFavoriteSkill(AbilityData)
    local keyToRemove = BSCSF:MakeKey(
        AbilityData[1],
        AbilityData[2],
        AbilityData[3],
        AbilityData[4],
        AbilityData[5]
    )
    local newSCAL, nCount = {}, 0
    for i = 1, #BSCSF.SV_ACC.SCAL do
        local v = BSCSF.SV_ACC.SCAL[i]
        if v then
            local k = BSCSF:MakeKey(v[1], v[2], v[3], v[4], v[5])
            if k ~= keyToRemove then
                nCount = nCount + 1
                table.insert(newSCAL, v)
            end
        end
    end
    BSCSF.SV_ACC.SCAL = newSCAL
    BSCSF.index[keyToRemove] = nil
	BSCSF.indexNoName[ BSCSF:MakeKey4(AbilityData[1], AbilityData[2], AbilityData[3], AbilityData[4]) ] = nil
    PlaySound(SOUNDS.SCRYING_ACTIVATE_BOMB)
end
-- ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////// --- Init -- //////////////////////////////////////////////////////
-- ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function BSCSF.init(event, addonName)	
	if addonName ~= BSCSF.Name then
		return 
	end
	EVENT_MANAGER:UnregisterForEvent(BSCSF.Name, 	EVENT_ADD_ON_LOADED)
	
	BSCSF.SV_ACC = ZO_SavedVars:NewAccountWide(BSCSF.SavedVar, 1, nil, defaultSV)
	BSCSF.index = {} -- key -> true
	BSCSF.indexNoName = {}
	for i = 1, #BSCSF.SV_ACC.SCAL do
		local v = BSCSF.SV_ACC.SCAL[i]
		if v then
			BSCSF.index[ BSCSF:MakeKey(v[1], v[2], v[3], v[4], v[5]) ] = true
			BSCSF.indexNoName[ BSCSF:MakeKey4(v[1], v[2], v[3], v[4]) ] = true
		end
	end	
	
	-- Keyboard
	BSCSF:InitKeyboard()
	-- Gamepad
	BSCSF:InitGamepad()	
end
EVENT_MANAGER:RegisterForEvent(BSCSF.Name, EVENT_ADD_ON_LOADED, BSCSF.init)