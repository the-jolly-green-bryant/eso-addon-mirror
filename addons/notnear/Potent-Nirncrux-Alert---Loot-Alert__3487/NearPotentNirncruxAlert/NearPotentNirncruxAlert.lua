NEAR_PNA = {
	name 		= "NearPotentNirncruxAlert",
	title 		= "Near's Potent Nirncrux Alert",
	version 	= "2.0.2",
	author 		= "|cCC99FFnotnear|r",
	defaults	= {
		togglePotent	= true,
		toggleCustom = false,
		customColor = { r = 1, g = 1, b = 1 },
		customItems = {},
	},
}
local addon = NEAR_PNA

---Convert RGB color values to hexadecimal
---@param color table
---@return string
local function rgbToHex(color)
    -- Convert each color component to hexadecimal
    local function toHex(c)
        local hex = string.format("%X", math.floor(c * 255))
        return #hex == 1 and "0" .. hex or hex
    end

    -- Convert each color component to hexadecimal
    local hexR = toHex(color.r)
    local hexG = toHex(color.g)
    local hexB = toHex(color.b)

    -- Construct the hexadecimal color string
    local hexColor = "|c" .. hexR .. hexG .. hexB

    return hexColor
end

---@param quantity integer
---@param itemName string
---@param color string
local function announce(quantity, itemName, color)
	local looted = GetString(NPNA_Looted) .. " "
	local params = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, SOUNDS.ACHIEVEMENT_AWARDED)
	params:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_POI_DISCOVERED)
	params:SetText(looted .. quantity .. "x " .. color .. itemName)
	CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(params)
end

-------------------------------------------------------------------------------------------------------------------------------------------------
-- Alert handler
-------------------------------------------------------------------------------------------------------------------------------------------------
function addon.OnLootReceived(_,_,itemLink,quantity,_,_,self,_,_,itemId)
	local sv = addon.ASV

	if not self then return end

	local itemName = GetItemLinkName(itemLink)
	local fN = LocalizeString("<<1>>", itemName)
	local fNl = fN:lower()

	--[[ Debug ]]
	-- d('itemLink: ' .. itemLink .. '     itemId: ' .. itemId)
	-- d('itemName: ' .. itemName)
	-- d('fN: ' .. fN)
	-- d('fN lower: ' .. fNl)

	if sv.togglePotent then
		if itemId == 56863 then -- Potent Nirncrux ID: 56863
			local color = "|cFF0000"
			announce(quantity, fN, color)
		end
	end

	if sv.toggleCustom then
		for _, value in ipairs(sv.customItems) do
			if fNl == value then
				local color = rgbToHex(sv.customColor)
				announce(quantity, fN, color)
				break
			end
		end
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
-- Addon loading
-------------------------------------------------------------------------------------------------------------------------------------------------
local function OnAddonLoaded(event, name)
	if name ~= addon.name then return end
	EVENT_MANAGER:UnregisterForEvent(addon.name, EVENT_ADD_ON_LOADED)

	addon.ASV = ZO_SavedVars:NewAccountWide(addon.name .. "_Data", 2, nil, addon.defaults)

	addon.SetupSettings()
	EVENT_MANAGER:RegisterForEvent(addon.name, EVENT_LOOT_RECEIVED, addon.OnLootReceived)
end

EVENT_MANAGER:RegisterForEvent(addon.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)
