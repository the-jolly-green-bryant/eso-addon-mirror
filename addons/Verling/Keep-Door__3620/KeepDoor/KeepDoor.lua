local LMP         = LibMapPins
local ADDON_NAME  = "KeepDoor"
local KD_ICO      = "KeepDoor/kdpic.dds"

local KD_LAYOUT  = {
    level   = 50,
    size    = 20,
    texture = KD_ICO,
}
local KD_TOOLTIP = {
    tooltip = ZO_MAP_TOOLTIP_MODE.INFORMATION,
    creator = function( pin )
        InformationTooltip:AddLine( "Keep Door" )
    end,
}
local KD_DATA    = {
    ["cyrodiil/ava_whole"] = {                   -- +
		{ x = 0.2310, y = 0.1642 }, -- Yorden
		{ x = 0.1846, y = 0.3280 }, -- Рейлис
		{ x = 0.2740, y = 0.2857 }, -- Болотный туман
		{ x = 0.4908, y = 0.1188 }, -- Коготь Дракона
		{ x = 0.4060, y = 0.2838 }, -- Элесвелл
		{ x = 0.3390, y = 0.4280 }, -- Эш
		{ x = 0.2345, y = 0.5680 }, -- Бриндл
		{ x = 0.4120, y = 0.5635 }, -- Робек
		{ x = 0.4075, y = 0.7660 }, -- Черный Сапог
		{ x = 0.4990, y = 0.6750 }, -- Фарегил
		{ x = 0.5745, y = 0.7615 }, -- Бладмейн
		{ x = 0.5705, y = 0.5572 }, -- Алессия
		{ x = 0.7670, y = 0.5830 }, -- Дрейклоу
		{ x = 0.6530, y = 0.4290 }, -- Синей дороги
		{ x = 0.5802, y = 0.2890 }, -- Чалман
		{ x = 0.7025, y = 0.3128 }, -- Арриус
		{ x = 0.8450, y = 0.3385 }, -- Фаррагут
		{ x = 0.7225, y = 0.1905 }, -- Гребень королей
							 }
                   }
				   
EVENT_MANAGER:RegisterForEvent( ADDON_NAME, EVENT_ADD_ON_LOADED, function( _, addonName )
	if addonName ~= ADDON_NAME then return end
    EVENT_MANAGER:UnregisterForEvent( ADDON_NAME, EVENT_ADD_ON_LOADED )
    local store = ZO_SavedVars:New( "KDSet", 1, nil, { showDoor = true } )
    local pinId = LMP:AddPinType( ADDON_NAME, function( pinManager )
        local mapName = LMP:GetZoneAndSubzone( true )
        local pins    = KD_DATA[mapName]
---        CHAT_SYSTEM:AddMessage(mapName.. "==<map<zone==")
        if pins then
            for _, pinInfo in ipairs( pins ) do
                LMP:CreatePin( ADDON_NAME, pinInfo, pinInfo.x, pinInfo.y )
            end
        end
    end, nil, KD_LAYOUT, KD_TOOLTIP )
    LMP:AddPinFilter( pinId, "|t24:24:" .. KD_ICO .. "|t Keep Door", false, store, "showDoor" )
end )
