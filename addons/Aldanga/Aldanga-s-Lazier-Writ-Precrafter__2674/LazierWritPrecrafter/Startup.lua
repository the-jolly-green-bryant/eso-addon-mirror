LazierWritPrecrafter = ZO_Object:Subclass()

LazierWritPrecrafter.NAME = "LazierWritPrecrafter"
LazierWritPrecrafter.Modules = {}
LazierWritPrecrafter.savedVariables = {}

local QUEUE_SIZE = 37

function LazierWritPrecrafter:Initialize()
    self.Modules.Queue = LazierCrafterQueue:New()
    self:ConsoleCommands()
    self.Settings = LazierWritPrecrafterSettings:New()
end

function LazierWritPrecrafter:OnAddOnLoaded(event, addonName)
    if (addonName ~= self.NAME) then
        return
    end

    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
    self:Initialize()
end

function LazierWritPrecrafter:SetCraftingQueue(multiplier)
    local queue = {}
    for profession, enabled in pairs(self.Settings:GetSettings().professions) do
        if enabled then table.insert(queue, profession) end
    end
    if #queue == 0 then
        d("No professions are selected. Could not queue items.")
        return 
    end
    for k, v in pairs(queue) do
        self.Modules.Queue:AddProfession(v, multiplier)
    end
end

function LazierWritPrecrafter:GetMultiplierAndQueue(args, bagSpace, force)
    local multiplier
    if args == "" then
        if multiplier == 0 and not force then d("Not enough bag space to queue a rotation.") return end
        multiplier = math.floor(bagSpace / QUEUE_SIZE)
    else
        multiplier = tonumber(args) or 1
    end
    if multiplier == 0 then d("Cannot queue zero rotations.") return end
    local multiplierMessage = multiplier .. (multiplier == 1 and ' rotation' or ' rotations')
    d("Queuing " .. multiplierMessage .. " (" .. multiplier * QUEUE_SIZE .. " items).")
    self:SetCraftingQueue(multiplier)
end

function LazierWritPrecrafter:ConsoleCommands()
    SLASH_COMMANDS["/scq"] = function(args)
        local bagSpace = GetNumBagFreeSlots(BAG_BACKPACK)
        if bagSpace < QUEUE_SIZE then
            d("Not enough bag space to queue a rotation. If you want to force queuing, use the /scqf command.")
            return
        end
        self:GetMultiplierAndQueue(args, bagSpace)
    end
    SLASH_COMMANDS["/scqf"] = function(args)
        local bagSpace = GetNumBagFreeSlots(BAG_BACKPACK)
        self:GetMultiplierAndQueue(args, bagSpace, true)
    end
    SLASH_COMMANDS["/clearqueue"] = function()
        self.Modules.Queue:Clear()
    end
end

EVENT_MANAGER:RegisterForEvent(
    LazierWritPrecrafter.NAME,
    EVENT_ADD_ON_LOADED,
    function(...)
        LazierWritPrecrafter:OnAddOnLoaded(...)
    end
)
