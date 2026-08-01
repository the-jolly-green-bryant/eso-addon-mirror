local ADDON_NAME = "SaveHouse"
SaveHouse = {}

local nextEventHandleIndex = 1

-- Usage: RegisterForEvent(eventType, callback[, eventHandleName])
local function RegisterForEvent(event, callback, eventHandleName)
    if(not eventHandleName) then
        eventHandleName = ADDON_NAME .. nextEventHandleIndex
        nextEventHandleIndex = nextEventHandleIndex + 1
    end
    EVENT_MANAGER:RegisterForEvent(eventHandleName, event, callback)
    return eventHandleName
end

-- Usage: UnregisterForEvent(eventType, eventHandleName)
local function UnregisterForEvent(event, name)
    EVENT_MANAGER:UnregisterForEvent(name, event)
end

-- Usage: WrapFunction([object,] functionName, function(original, ...)
--     -- do something before
--     local returnValues = {original(...)} -- or just original(...) if there are no return values
--     -- do something after
--     return unpack(returnValues) -- can be removed when there are no return values
-- end)
local function WrapFunction(object, functionName, wrapper)
    if(type(object) == "string") then
        wrapper = functionName
        functionName = object
        object = _G
    end
    local originalFunction = object[functionName]
    object[functionName] = function(...) return wrapper(originalFunction, ...) end
end

local messages = {}
-- Usage: LogDebug(message) or LogDebug(format, arg1, arg2, ...)
local function LogDebug(message, ...)
    if CHAT_SYSTEM.primaryContainer then
        df("[%s] " .. message, ADDON_NAME, ...)
    else
        messages[#messages + 1] = {message, ...}
    end
end

do
    local eventHandle = RegisterForEvent(EVENT_PLAYER_ACTIVATED, function()
        UnregisterForEvent(event, eventHandle)
        for i = 1, #messages do
            LogDebug(messages[i])
        end
        messages = {}
    end)
end

local function OnAddonLoaded(callback)
    local eventHandle = ""
    eventHandle = RegisterForEvent(EVENT_ADD_ON_LOADED, function(event, name)
        if(name ~= ADDON_NAME) then return end
        callback()
        UnregisterForEvent(event, eventHandle)
    end)
end

OnAddonLoaded(function()
    local saveData = SaveHouse_Data or {}
    SaveHouse_Data = saveData
    if(not saveData.version) then
        saveData.version = 1
        saveData.houses = {}
    end

    local LSH = LibStub("LibSaveHouse")
    local LSC = LibStub("LibSlashCommander")

    local function GetHouseName(houseId)
        local collectibleId = GetCollectibleIdForHouse(houseId)
        local houseName = GetCollectibleInfo(collectibleId)
        return houseName
    end

    local function ShowHelp()
        d("/savehouse (or /sh) <command>")
        d("help - shows the list of available commands")
        d("list - shows all saved furniture templates")
        d("save <name> - create a template for the current house")
        d("load <name> - restores the specified template")
        d("delete <name> - deletes the template")
        d("req <name> - lists all required items in the template")
        d("clear - removes all furniture from the current house")
        d("stop - stops placing or clearing furniture")
        d("upgrade <name> - upgrades the save data format")
    end

    local function ListTemplates()
        local sortedNames = {}
        for name in pairs(saveData.houses) do
            sortedNames[#sortedNames + 1] = name
        end
        if(#sortedNames > 0) then
            table.sort(sortedNames)
            d("Houses available for restoring:")
            local hasOutdatedHomes = false
            for i = 1, #sortedNames do
                local name = sortedNames[i]
                local house = saveData.houses[name]
                local houseName = GetHouseName(house.houseId)
                local color = "|c00ff00"
                local hasOutdated, hasAmbiguous = LSH:HasOutdatedSaveData(house.furniture)
                if(hasOutdated) then
                    if(hasAmbiguous) then
                        color = "|cff0000"
                    else
                        color = "|cff7f00"
                    end
                    hasOutdatedHomes = true
                end
                df("%s%s - %s, %d items", color, name, houseName, #house.furniture)
            end
            if(hasOutdatedHomes) then
                d("Some templates use an outdated format. It's strongly recommended that you upgrade them with '/savehouse upgrade'")
            end
        else
            d("No houses stored.")
        end
    end

    local function SaveTemplate(name)
        local houseId = GetCurrentZoneHouseId()
        if(not houseId) then
            d("Not inside a house. Can't save anything.")
        elseif(saveData.houses[name]) then
            df("You already saved a house under this name. Use '/savehouse delete %s' to delete it or choose another name.", name)
        else
            d("Start saving furniture data")
            local serializedFurniture = LSH:SerializePlacedFurniture()
            saveData.houses[name] = {
                houseId = houseId,
                furniture = serializedFurniture,
            }
            d("Furniture data successfully saved")
        end
    end

    local function LoadTemplate(name)
        if(LSH.isWorking) then
            d("Action already in progress. Use '/savehouse stop' to stop it.")
        else
            local house = saveData.houses[name]
            if(not house) then
                df("No house with name '%s' stored. Use '/savehouse list' to see all available names", name)
            elseif(house.houseId ~= GetCurrentZoneHouseId()) then
                local houseName = GetHouseName(house.houseId)
                df("Need to be inside %s to load furniture", houseName)
            else
                d("Start placing available furniture")
                LSH:DeserializeAndPlaceFurniture(house.furniture):Then(function()
                    d("Finished placing all available furniture")
                end, function()
                    d("Stopped placing furniture")
                end)
            end
        end
    end

    local function DeleteTemplate(name)
        if(saveData.houses[name]) then
            saveData.houses[name] = nil
            df("Deleted house '%s'. You can still restore it by force-closing the client via alt+f4", name)
        else
            df("No house with name '%s' stored. Use '/savehouse list' to see all available names", name)
        end
    end

    local function ShowRequirements(name)
        name = name or ""
        local house = saveData.houses[name]
        if(not house) then
            df("No house with name '%s' stored. Use '/savehouse list' to see all available names", name)
        else
            local houseName = GetHouseName(house.houseId)
            local isInHouse = (house.houseId == GetCurrentZoneHouseId() and IsOwnerOfCurrentHouse())

            df("Required items for %s (%s):", name, houseName)
            local requirements = LSH:CalculateItemRequirements(house.furniture)
            local items = {}
            for name, count in pairs(requirements) do
                local effectivlyAvailable = count.available + (isInHouse and count.placed or 0)
                local color = "|cff0000"
                if(effectivlyAvailable >= count.required) then
                    color = "|c00ff00"
                elseif(effectivlyAvailable > 0) then
                    color = "|cffff00"
                end
                if(isInHouse) then
                    items[#items + 1] = string.format("%s%s: %d (%d) / %d", color, name, effectivlyAvailable, count.placed, count.required)
                else
                    items[#items + 1] = string.format("%s%s: %d / %d", color, name, effectivlyAvailable, count.required)
                end
            end
            table.sort(items)
            for i=1, #items do
                d(items[i])
            end
        end
    end

    local function ClearFurniture()
        if(LSH.isWorking) then
            d("Action already in progress. Use '/savehouse stop' to stop it.")
        else
            d("Start removing all furniture")
            LSH:ClearPlacedFurniture():Then(function()
                d("Finished removing all furniture")
            end, function()
                d("Stopped removing furniture")
            end)
        end
    end

    local function StopAction()
        LSH.stopCurrentActivity = true
    end

    local lastUpgradeName
    local function UpgradeTemplate(name)
        local house = saveData.houses[name]
        if(not house) then
            df("No house with name '%s' stored. Use '/savehouse list' to see all available names", name)
        else
            df("Checking save data for '%s'...", name)
            local hasOutdated, hasAmbiguous = LSH:HasOutdatedSaveData(house.furniture)
            if(not hasOutdated) then
                d("This template is already up to date")
            elseif(hasAmbiguous and lastUpgradeName ~= name) then
                d("This template has furniture that cannot be identified correctly. It is recommended that you go there and save it again. You can force an upgrade by using the same command again, but there will be some dataloss.")
            else
                d("Upgrading template save data")
                house.furniture = LSH:UpgradeSaveData(house.furniture)
                d("Finished. It is recommended to use /reloadui now to save the changes")
            end
        end
        lastUpgradeName = name
    end

    local TemplateNameAutoCompleteProvider = LSC.AutoCompleteProvider:Subclass()
    function TemplateNameAutoCompleteProvider:New()
        return LSC.AutoCompleteProvider.New(self)
    end
 
    function TemplateNameAutoCompleteProvider:FormatLabel(name, house)
        if(house) then
            local houseName = GetHouseName(house.houseId)
            return string.format("%s|caaaaaa - %s, %d items", name, houseName, #house.furniture)
        end
        return name
    end

    function TemplateNameAutoCompleteProvider:GetResultList()
        local results = {}
        local lookup = {}
        for name in pairs(saveData.houses) do
            local label = self:FormatLabel(name, saveData.houses[name])
            if(label ~= name) then
                lookup[label] = name
            end
            results[zo_strlower(name)] = label
        end
        self.lookup = lookup
        return results
    end

    local templateNameProvider = TemplateNameAutoCompleteProvider:New()

    local command = LSC:Register({"/savehouse", "/sh"}, ShowHelp, "Save or restore your furniture")
    local helpCommand = command:RegisterSubCommand()
    helpCommand:AddAlias("help")
    helpCommand:SetCallback(ShowHelp)
    helpCommand:SetDescription("Show list of available commands")
    local listCommand = command:RegisterSubCommand()
    listCommand:AddAlias("list")
    listCommand:SetCallback(ListTemplates)
    listCommand:SetDescription("List all templates")
    local saveCommand = command:RegisterSubCommand()
    saveCommand:AddAlias("save")
    saveCommand:SetCallback(SaveTemplate)
    saveCommand:SetDescription("Save furniture template")
    saveCommand:SetAutoComplete(templateNameProvider)
    local loadCommand = command:RegisterSubCommand()
    loadCommand:AddAlias("load")
    loadCommand:SetCallback(LoadTemplate)
    loadCommand:SetDescription("Restore furniture template")
    loadCommand:SetAutoComplete(templateNameProvider)
    local deleteCommand = command:RegisterSubCommand()
    deleteCommand:AddAlias("delete")
    deleteCommand:SetCallback(DeleteTemplate)
    deleteCommand:SetDescription("Delete furniture template")
    deleteCommand:SetAutoComplete(templateNameProvider)
    local reqCommand = command:RegisterSubCommand()
    reqCommand:AddAlias("req")
    reqCommand:SetCallback(ShowRequirements)
    reqCommand:SetDescription("Show requirements for template")
    reqCommand:SetAutoComplete(templateNameProvider)
    local clearCommand = command:RegisterSubCommand()
    clearCommand:AddAlias("clear")
    clearCommand:SetCallback(ClearFurniture)
    clearCommand:SetDescription("Remove all furniture")
    local stopCommand = command:RegisterSubCommand()
    stopCommand:AddAlias("stop")
    stopCommand:SetCallback(StopAction)
    stopCommand:SetDescription("Stop current action")
    local upgradeCommand = command:RegisterSubCommand()
    upgradeCommand:AddAlias("upgrade")
    upgradeCommand:SetCallback(UpgradeTemplate)
    upgradeCommand:SetDescription("Upgrade the save data format")
    upgradeCommand:SetAutoComplete(templateNameProvider)
end)
