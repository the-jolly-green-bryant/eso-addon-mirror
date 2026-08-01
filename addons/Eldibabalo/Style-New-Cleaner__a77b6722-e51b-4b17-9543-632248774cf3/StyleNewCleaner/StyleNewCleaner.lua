local SNC = {
    name = "StyleNewCleaner",
}

StyleNewCleaner = SNC

function SNC:Print(msg)
    if type(d) == "function" then
        d(msg)
    end
end

function SNC:ClearOutfitStyleNewFlags()
    if type(ClearCollectibleNewStatus) ~= "function" then
        self:Print("[SNC] ClearCollectibleNewStatus not available on this client.")
        return 0
    end
    if not ZO_COLLECTIBLE_DATA_MANAGER or type(ZO_COLLECTIBLE_DATA_MANAGER.GetAllCollectibleDataObjects) ~= "function" then
        self:Print("[SNC] Collectible manager is not available.")
        return 0
    end

    local categoryFilters = {}
    local collectibleFilters = {}
    if ZO_CollectibleCategoryData and type(ZO_CollectibleCategoryData.IsOutfitStylesCategory) == "function" then
        table.insert(categoryFilters, ZO_CollectibleCategoryData.IsOutfitStylesCategory)
    end
    if ZO_CollectibleData and type(ZO_CollectibleData.IsNew) == "function" then
        table.insert(collectibleFilters, ZO_CollectibleData.IsNew)
    end

    local dataObjects = ZO_COLLECTIBLE_DATA_MANAGER:GetAllCollectibleDataObjects(categoryFilters, collectibleFilters, false) or {}
    local cleared = 0
    local removedNotifications = 0
    for _, collectibleData in ipairs(dataObjects) do
        if collectibleData and type(collectibleData.GetId) == "function" then
            local collectibleId = collectibleData:GetId()
            if collectibleId and collectibleId > 0 then
                pcall(ClearCollectibleNewStatus, collectibleId)
                cleared = cleared + 1
                if type(RemoveCollectibleNotification) == "function" and type(collectibleData.GetNotificationId) == "function" then
                    local notificationId = collectibleData:GetNotificationId()
                    if notificationId and notificationId > 0 then
                        pcall(RemoveCollectibleNotification, notificationId)
                        removedNotifications = removedNotifications + 1
                    end
                end
            end
        end
    end

    self:Print(string.format("[SNC] Cleared NEW style markers: %d | Removed notifications: %d", cleared, removedNotifications))
    return cleared
end

function SNC:BuildKeybindStrip()
    if self.keybindStripDescriptor then
        return
    end
    self.keybindStripDescriptor = {
        alignment = KEYBIND_STRIP_ALIGN_LEFT,
        {
            name = "Clear New Styles",
            keybind = "UI_SHORTCUT_RIGHT_STICK",
            callback = function()
                self:ClearOutfitStyleNewFlags()
            end,
        },
    }
end

function SNC:AttachToRestyleScene()
    if self.sceneHooked then
        return true
    end
    if not GAMEPAD_RESTYLE_ROOT_SCENE or type(GAMEPAD_RESTYLE_ROOT_SCENE.RegisterCallback) ~= "function" then
        return false
    end

    self:BuildKeybindStrip()
    GAMEPAD_RESTYLE_ROOT_SCENE:RegisterCallback("StateChange", function(_, newState)
        if newState == SCENE_SHOWING then
            pcall(function()
                KEYBIND_STRIP:AddKeybindButtonGroup(self.keybindStripDescriptor)
            end)
        elseif newState == SCENE_HIDDEN then
            pcall(function()
                KEYBIND_STRIP:RemoveKeybindButtonGroup(self.keybindStripDescriptor)
            end)
        end
    end)
    self.sceneHooked = true
    return true
end

function SNC:TryAttachWithRetry()
    if self:AttachToRestyleScene() then
        return
    end
    zo_callLater(function()
        self:TryAttachWithRetry()
    end, 2000)
end

function SNC:Initialize()
    if self.initialized then
        return
    end

    SLASH_COMMANDS["/snc"] = function()
        self:ClearOutfitStyleNewFlags()
    end
    SLASH_COMMANDS["/clearstylesnew"] = function()
        self:ClearOutfitStyleNewFlags()
    end

    self:TryAttachWithRetry()
    self.initialized = true
    self:Print("[SNC] Loaded. Use /snc or R3 in Outfit Styles.")
end

local function SNC_OnAddOnLoaded(_, addonName)
    if addonName ~= SNC.name then
        return
    end
    EVENT_MANAGER:UnregisterForEvent(SNC.name, EVENT_ADD_ON_LOADED)
    SNC:Initialize()
end

EVENT_MANAGER:RegisterForEvent(SNC.name, EVENT_ADD_ON_LOADED, SNC_OnAddOnLoaded)

