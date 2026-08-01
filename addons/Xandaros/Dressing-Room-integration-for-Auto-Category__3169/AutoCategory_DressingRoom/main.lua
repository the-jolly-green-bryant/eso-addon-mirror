local function dressingroom(...)
    if not DressingRoom then return false end

    local args = {...}
    local gearSet = DressingRoom.sv.gearSet

    if #args == 0 then
        -- TODO
        for i, _ in ipairs(gearSet) do
            args[i] = i
        end
    end

    for _, set in ipairs(args) do
        if type(set) ~= "number" then
            error(string.format("error: dressingroom: argument must be a number"))
        end

        if set <= #gearSet then
            local itemId = GetItemUniqueId(AutoCategory.checkingItemBagId, AutoCategory.checkingItemSlotIndex)
            for item, _ in pairs(gearSet[set]) do
                if item == Id64ToString(itemId) then
                    return true
                end
            end
        end
    end
    return false
end

local function initialize()
    if not AutoCategory then return end

    AutoCategory.Environment.dressingroom = dressingroom
end

local function onAddonLoaded(event, name)
    if name == "AutoCategory_DressingRoom" then
        initialize()
    end
end

EVENT_MANAGER:RegisterForEvent("AutoCategory_DressingRoom", EVENT_ADD_ON_LOADED, onAddonLoaded)
