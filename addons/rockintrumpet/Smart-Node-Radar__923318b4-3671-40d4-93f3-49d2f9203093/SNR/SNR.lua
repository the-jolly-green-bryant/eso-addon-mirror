SNR = {}

-- THE FIX: Improved Renderer with 3D validation
local function RefreshMarkers()
    local zoneId = GetZoneId(GetUnitZoneIndex("player"))
    
    -- Using the Global table check you mentioned
    local MM = _G["MoreMarkers"]
    
    -- If the library is missing or hasn't fully initialized, wait and retry
    if not MM or not MM.AddMarker then
        zo_callLater(function() RefreshMarkers() end, 5000)
        return
    end

    if SNR.db and SNR.db[zoneId] then
        for _, pos in pairs(SNR.db[zoneId]) do
            -- Use the direct MoreMarkers call with 3D verification
            -- Texture: Crafting icon; Color: Gold {1, 0.9, 0, 1}
            MM.AddMarker(pos.x, pos.y, pos.z, "esoui/art/icons/poi/poi_crafting_complete.dds", {1, 0.9, 0, 1})
        end
    end
end

local function RecordNode()
    local zoneId, x, y, z = GetUnitRawWorldPosition("player")
    -- Grid key to avoid overlapping icons (approx 2 meters)
    local nodeKey = string.format("%d_%d_%d", math.floor(x/400), math.floor(y/400), math.floor(z/400))
    
    if not SNR.db then SNR.db = {} end
    if not SNR.db[zoneId] then SNR.db[zoneId] = {} end
    
    if not SNR.db[zoneId][nodeKey] then
        SNR.db[zoneId][nodeKey] = {x=x, y=y, z=z}
        d("|c00FF00[SNR]|r Node Recorded!")
        RefreshMarkers()
    end
end

local function OnLootReceived(_, itemSoundCategory)
    -- Sound IDs 12 (Interact) and 15 (Harvest) are standard for PS5 nodes
    if itemSoundCategory == 12 or itemSoundCategory == 15 then
        RecordNode()
    end
end

local function OnLoaded(_, addonName)
    -- This MUST match your folder name "SNR"
    if addonName == "SNR" then
        SNR.db = ZO_SavedVars:NewAccountWide("SmartNodeRadar_Data", 1, nil, {})
        
        EVENT_MANAGER:RegisterForEvent("SNR_Loot", EVENT_LOOT_RECEIVED, OnLootReceived)
        EVENT_MANAGER:RegisterForEvent("SNR_Zone", EVENT_PLAYER_ACTIVATED, RefreshMarkers)
        
        -- Slash Command
        SLASH_COMMANDS["/snr"] = function() 
            d("[SNR] Manual record triggered...")
            RecordNode() 
        end
        
        d("|cFFFF00[SNR] System Online|r")
        
        -- Initial check for markers
        zo_callLater(RefreshMarkers, 5000)
        
        EVENT_MANAGER:UnregisterForEvent("SNR_Init", EVENT_ADD_ON_LOADED)
    end
end

EVENT_MANAGER:RegisterForEvent("SNR_Init", EVENT_ADD_ON_LOADED, OnLoaded)