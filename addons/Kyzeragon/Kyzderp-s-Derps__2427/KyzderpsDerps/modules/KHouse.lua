KyzderpsDerps = KyzderpsDerps or {}
KyzderpsDerps.KHouse = KyzderpsDerps.KHouse or {}
local KHouse = KyzderpsDerps.KHouse


-------------------------------------------------------------------------------
-- For my alt account
-------------------------------------------------------------------------------
local function PortToKyzersHouse()
    if (GetWorldName() == "EU Megaserver") then
        KyzderpsDerps:msg(string.format("Porting to @code65536's primary"))
        JumpToHouse("@code65536")
        return
    end

    local KYZ_HOUSE = 46
    KyzderpsDerps:msg(string.format("Porting to @Kyzeragon's %s...", GetCollectibleName(GetCollectibleIdForHouse(KYZ_HOUSE))))
    if (GetUnitDisplayName("player") == "@Kyzeragon") then
        RequestJumpToHouse(KYZ_HOUSE)
    else
        JumpToSpecificHouse("@Kyzeragon", KYZ_HOUSE)
    end
end


-------------------------------------------------------------------------------
-- Finds a house by matching with the collectible name
-------------------------------------------------------------------------------
local function FindHouseByName(word)
    word = string.lower(word)
    for houseId = 1, 200 do
        local houseName = GetCollectibleName(GetCollectibleIdForHouse(houseId))
        if (houseName and houseName ~= "") then
            -- Match
            if (string.find(string.lower(houseName), word, 1, true)) then
                return houseId
            end
        end
    end
    return nil
end


-------------------------------------------------------------------------------
-- Handles command
-------------------------------------------------------------------------------
local function PortToHouse(argString)
    local args = {}
    local length = 0
    for word in argString:gmatch("%S+") do
        table.insert(args, word)
        length = length + 1
    end

    -- I could let this flow through the logic below but lazy
    if (length == 0) then
        if (KyzderpsDerps.savedOptions.general.experimental) then
            PortToKyzersHouse()
        else
            KyzderpsDerps:msg("Porting to your primary residence...")
            RequestJumpToHouse(GetHousingPrimaryHouse())
        end
        return
    end

    -- First determine if the first arg is a name
    local name = nil
    local houseId = -1
    local toFindString = ""
    local outside = false
    if (string.sub(args[1], 1, 1) == "@") then
        name = args[1]
        if (length > 1) then
            houseId = FindHouseByName(args[2])
            if (houseId == nil) then
                KyzderpsDerps:msg("Couldn't find a house matching " .. args[2])
                return
            end
        end -- else it's the primary
    else
        -- Your own house, so search
        houseId = FindHouseByName(args[1])
        if (houseId == nil) then
            KyzderpsDerps:msg("Couldn't find a house matching " .. args[1])
            return
        end

        if (length > 1 and (args[2] == "out" or args[2] == "outside")) then
            outside = true
        end
    end

    -- If you put your own name for some reason (prob from Kyzerg tho)
    if (name and string.lower(name) == string.lower(GetUnitDisplayName("player"))) then
        name = nil
    end

    KyzderpsDerps:msg(string.format("Attempting to port %s %s %s%s...",
        (outside) and "outside" or "to",
        (name == nil) and "your" or (name .. "'s"),
        (houseId == -1) and "primary residence" or GetCollectibleName(GetCollectibleIdForHouse(houseId)),
        (houseId == -1) and "" or string.format(" (ID %d)", houseId)
    ))

    if (name == nil) then
        RequestJumpToHouse(houseId, outside) 
    elseif (houseId == -1) then
        JumpToHouse(name)
    else
        JumpToSpecificHouse(name, houseId)
    end
end
KHouse.PortToHouse = PortToHouse


-------------------------------------------------------------------------------
-- Initialize
-------------------------------------------------------------------------------
function KHouse.Initialize()
    SLASH_COMMANDS["/khouse"] = PortToHouse
end
