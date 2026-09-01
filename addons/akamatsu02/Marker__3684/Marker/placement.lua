MARK = MARK or {}

-- PERFORMANCE: Localize globals used in placement functions
local getPlayerPos = GetUnitRawWorldPosition
local getUuid = LibAkaUtils.uuid

function MARK.triggerMarkerPlace()
	local markerId = MARK.PlaceIconKeybind()
	MARK.ItemClickEdit({id = markerId})
end

function MARK.placeMarkerInProfileHere(size, texture)
	local _, x, y, z = getPlayerPos("player")
	return MARK.placeMarkerInProfile(x, y, z, size, texture)
end

function MARK.placeMarkerInProfile(x, y, z, size, texture)
	local profile = MARK.loadedProfile
	if profile == nil then 
        d("No Profile selected") 
        return 
    end
    
	return profile:setMarker({
		id = getUuid(),
		texture = texture,
		x = x or 0,
		y = y or 0,
		z = z or 0,
		size = size or MARK.fallbackSize
	})
end

function MARK.PlaceIconKeybind()
	local texture = nil
	if MARK.UI.SelectedTexture ~= "" then
		texture = MARK.UI.SelectedTexture
	end
	local markerId = MARK.placeMarkerInProfileHere(nil, texture)
	return markerId
end

function MARK.PlaceIcon3DKeybind()
	local texture = nil
	if MARK.UI.SelectedTexture ~= "" then
		texture = MARK.UI.SelectedTexture
	end
	PreviewMarker:new(texture)
end

-- PERFORMANCE FIX: Cached intermediate table lookups. 
-- Reduces hash lookups from 3 to 1 per level.
function MARK.getPlacedMarkerAt(x, y, z)
	local tx = MARK.coordTable[x]
	if not tx then return nil end
    
	local ty = tx[y]
	if not ty then return nil end
    
	return ty[z]
end

-- PERFORMANCE FIX: Cached intermediate table lookups.
function MARK.isPlacingAllowed(x, y, z, id)
	local tx = MARK.coordTable[x]
	if not tx then return true end
    
	local ty = tx[y]
	if not ty then return true end
    
	local tz = ty[z]
	if not tz or tz == id then return true end
    
	return false
end

-- PERFORMANCE FIX & BUG FIX: Cached intermediate tables.
-- Fixed bug where passing `id = nil` failed to clear the coordinate because of the `== nil` check.
function MARK.setPlacingPosition(x, y, z, id)
	local tx = MARK.coordTable[x]
	if not tx then 
		tx = {}
		MARK.coordTable[x] = tx
	end
    
	local ty = tx[y]
	if not ty then 
		ty = {}
		tx[y] = ty
	end
    
    -- Directly assign the ID (or nil to clear it). 
    -- This fixes the bug where coordinates were never freed when a marker was hidden.
	ty[z] = id
end