-- UI/Nvk3UT_ChatAchievementContext.lua
-- TODO(EVENTS_REFACTOR): Move initialization into the future Events bootstrap once available.

Nvk3UT = Nvk3UT or {}

local ChatContext = {}
Nvk3UT.ChatAchievementContext = ChatContext

local function debug(fmt, ...)
    local diag = Nvk3UT and Nvk3UT.Diagnostics
    if diag and type(diag.Debug) == "function" then
        diag.Debug("[ChatAchievementContext] " .. tostring(fmt), ...)
    end
end

local function getAchievementsSystem()
    if SYSTEMS and type(SYSTEMS.GetObject) == "function" then
        local ok, result = pcall(SYSTEMS.GetObject, SYSTEMS, "achievements")
        if ok and result then
            return result
        end
    end

    return ACHIEVEMENTS
end

local function showAchievementsScene()
    local sceneManager = SCENE_MANAGER
    if sceneManager and type(sceneManager.Show) == "function" then
        sceneManager:Show("achievements")
        return true
    end

    if MAIN_MENU_KEYBOARD and type(MAIN_MENU_KEYBOARD.ShowScene) == "function" then
        MAIN_MENU_KEYBOARD:ShowScene("achievements")
        return true
    end

    return false
end

local SCROLL_RETRY_MS = 33
local DEFAULT_SCROLL_TIMEOUT_MS = 1000

local function scrollQueuedAchievementIntoView(timeoutMs)
    local achievements = getAchievementsSystem()
    local sceneManager = SCENE_MANAGER
    if not achievements or not sceneManager or type(sceneManager.IsShowing) ~= "function" then
        return
    end

    if not sceneManager:IsShowing("achievements") then
        return
    end

    local retryInterval = SCROLL_RETRY_MS
    local maxDuration = type(timeoutMs) == "number" and timeoutMs or DEFAULT_SCROLL_TIMEOUT_MS
    if maxDuration < retryInterval then
        maxDuration = retryInterval
    end

    local attempts = 0
    local maxAttempts = math.ceil(maxDuration / retryInterval)

    local function tryScroll()
        if not sceneManager:IsShowing("achievements") then
            return
        end

        local queuedId = achievements.queuedScrollToAchievement
        local byId = type(achievements.achievementsById) == "table" and achievements.achievementsById or nil
        local entry = byId and byId[queuedId]
        local control = entry and (entry.control or (type(entry.GetControl) == "function" and entry:GetControl()))
        if not control and entry and entry.node then
            control = entry.node.control
        end

        local container = achievements.contentList or achievements.scrollContainer or achievements.listContainer or achievements.listControl
        if not container and type(achievements.GetContentList) == "function" then
            local ok, result = pcall(achievements.GetContentList, achievements)
            if ok and result then
                container = result
            end
        end
        if not container and type(achievements.GetScrollContainer) == "function" then
            local ok, result = pcall(achievements.GetScrollContainer, achievements)
            if ok and result then
                container = result
            end
        end
        if not container and control and type(control.GetParent) == "function" then
            local parent = control:GetParent()
            if parent and type(parent.GetParent) == "function" then
                local grandParent = parent:GetParent()
                if grandParent then
                    container = grandParent
                end
            end
        end
        if control and container then
            if type(ZO_Scroll_ScrollControlIntoCentralView) == "function" then
                pcall(ZO_Scroll_ScrollControlIntoCentralView, container, control)
            elseif type(ZO_Scroll_ScrollIntoView) == "function" then
                pcall(ZO_Scroll_ScrollIntoView, container, control)
            end
            return
        end

        attempts = attempts + 1
        if attempts >= maxAttempts then
            return
        end

        if type(zo_callLater) == "function" then
            zo_callLater(tryScroll, retryInterval)
        end
    end

    tryScroll()
end

local function openAchievementFallback(achievementId)
    local numeric = tonumber(achievementId)
    if not numeric or numeric <= 0 then
        return false
    end

    local achievements = getAchievementsSystem()
    if not achievements then
        return false
    end

    local sceneManager = SCENE_MANAGER
    local wasShowing = sceneManager and type(sceneManager.IsShowing) == "function" and sceneManager:IsShowing("achievements")

    showAchievementsScene()

    local handled = false
    if type(achievements.ShowAchievement) == "function" then
        local ok, result = pcall(achievements.ShowAchievement, achievements, numeric)
        handled = ok and result ~= false
    end

    if not handled then
        local manager = rawget(_G, "ACHIEVEMENTS_MANAGER")
        if manager and type(manager.ShowAchievement) == "function" then
            local ok, result = pcall(manager.ShowAchievement, manager, numeric)
            handled = ok and result ~= false
        end
    end

    if wasShowing or (sceneManager and type(sceneManager.IsShowing) == "function" and sceneManager:IsShowing("achievements")) then
        scrollQueuedAchievementIntoView(DEFAULT_SCROLL_TIMEOUT_MS)
    end

    debug("open fallback used for %d", numeric)

    return handled or true
end

local function openAchievement(achievementId)
    if type(ZO_Achievements_OpenToAchievement) == "function" then
        local ok, result = pcall(ZO_Achievements_OpenToAchievement, achievementId)
        if ok and result ~= false then
            return true
        end
    end

    local achievements = getAchievementsSystem()
    if achievements and type(achievements.OpenToAchievement) == "function" then
        local ok, result = pcall(achievements.OpenToAchievement, achievements, achievementId)
        if ok and result ~= false then
            return true
        end
    end

    return openAchievementFallback(achievementId)
end

local function isFavorite(achievementId)
    local state = Nvk3UT and Nvk3UT.AchievementState
    if state and type(state.IsFavorited) == "function" then
        local ok, result = pcall(state.IsFavorited, achievementId)
        if ok then
            return result and true or false
        end
    end

    local fav = Nvk3UT and Nvk3UT.FavoritesData
    if fav and type(fav.IsFavorited) == "function" then
        local ok, result = pcall(fav.IsFavorited, achievementId)
        if ok then
            return result and true or false
        end
    end

    return false
end

local function setFavorite(achievementId, shouldFavorite)
    local state = Nvk3UT and Nvk3UT.AchievementState
    if state and type(state.SetFavorited) == "function" then
        local ok, result = pcall(state.SetFavorited, achievementId, shouldFavorite, "ChatAchievementContext:Toggle")
        if ok then
            return result
        end
    end

    local fav = Nvk3UT and Nvk3UT.FavoritesData
    if fav and type(fav.SetFavorited) == "function" then
        local ok, result = pcall(fav.SetFavorited, achievementId, shouldFavorite, "ChatAchievementContext:Toggle")
        if ok then
            return result
        end
    end

    return false
end

local function refreshAfterFavoriteChange()
    local runtime = Nvk3UT and Nvk3UT.TrackerRuntime
    if runtime and type(runtime.QueueDirty) == "function" then
        pcall(runtime.QueueDirty, runtime, "achievement")
    end

    local rebuild = Nvk3UT and Nvk3UT.Rebuild
    if rebuild and type(rebuild.ForceAchievementRefresh) == "function" then
        pcall(rebuild.ForceAchievementRefresh, "ChatAchievementContext:ToggleFavorite")
    end

    local ui = Nvk3UT and Nvk3UT.UI
    if ui and type(ui.UpdateStatus) == "function" then
        pcall(ui.UpdateStatus)
    end
end

local function hasLibCustomMenu()
    if type(AddCustomMenuItem) == "function" then
        return true
    end

    local lib = rawget(_G, "LibCustomMenu")
    if type(lib) == "table" and type(lib.AddCustomMenuItem) == "function" then
        return true
    end

    if type(LibStub) == "function" then
        local ok, instance = pcall(LibStub, "LibCustomMenu", true)
        if ok and type(instance) == "table" and type(instance.AddCustomMenuItem) == "function" then
            return true
        end
    end

    return false
end

local function addMenuEntry(label, callback)
    if type(label) ~= "string" or label == "" or type(callback) ~= "function" then
        return false
    end

    if type(AddCustomMenuItem) ~= "function" then
        return false
    end

    local optionType = MENU_ADD_OPTION_LABEL or MENU_OPTION_LABEL or 1
    local ok = pcall(AddCustomMenuItem, label, callback, optionType)
    if not ok then
        return false
    end

    return true
end

local function appendMenuEntries(achievementId)
    if not achievementId then
        return false
    end

    local addedAny = false

    if addMenuEntry(GetString(SI_NVK3UT_JOURNAL_CONTEXT_OPEN_ACHIEVEMENT), function()
        openAchievement(achievementId)
    end) then
        addedAny = true
    end

    local favoriteNow = isFavorite(achievementId)
    local toggleLabelId =
        favoriteNow and SI_NVK3UT_JOURNAL_CONTEXT_REMOVE_FAVORITE or SI_NVK3UT_JOURNAL_CONTEXT_ADD_FAVORITE
    if addMenuEntry(GetString(toggleLabelId), function()
        local desired = not favoriteNow
        local changed = setFavorite(achievementId, desired)
        if changed ~= false then
            refreshAfterFavoriteChange()
        end
    end) then
        addedAny = true
    end

    return addedAny
end

local function OnLinkMouseUpContext(link, button, text, linkStyle, linkType, data1, ...)
    if button ~= MOUSE_BUTTON_INDEX_RIGHT or linkType ~= "achievement" then
        ChatContext._pendingId = nil
        return
    end

    local numericId = tonumber(data1)
    if numericId and numericId > 0 then
        ChatContext._pendingId = numericId
    else
        ChatContext._pendingId = nil
    end
end

local function OnShowMenuPreHook(control)
    local achievementId = ChatContext._pendingId
    if not achievementId then
        return false
    end

    ChatContext._pendingId = nil

    appendMenuEntries(achievementId)

    return false
end

function ChatContext.Init()
    if ChatContext._initialized then
        return
    end
    ChatContext._initialized = true

    if not hasLibCustomMenu() then
        return
    end

    local handler = rawget(_G, "LINK_HANDLER")
    if type(handler) ~= "table" or type(handler.RegisterCallback) ~= "function" or handler.LINK_MOUSE_UP_EVENT == nil then
        return
    end

    if ChatContext._callbackRegistered then
        return
    end

    handler:RegisterCallback(handler.LINK_MOUSE_UP_EVENT, OnLinkMouseUpContext)

    if not ChatContext._showMenuHooked then
        ZO_PreHook("ShowMenu", OnShowMenuPreHook)
        ChatContext._showMenuHooked = true
    end

    ChatContext._callbackRegistered = true
end

return ChatContext
