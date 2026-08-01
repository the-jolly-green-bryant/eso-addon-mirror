Nvk3UT = Nvk3UT or {}

local Summary = {}
Nvk3UT.RecentSummary = Summary

local Diagnostics = Nvk3UT and Nvk3UT.Diagnostics
local Utils = Nvk3UT and Nvk3UT.Utils
local Data = Nvk3UT and Nvk3UT.RecentData

local EVENT_NAMESPACE = "Nvk3UT_RecentSummary"

local state = {
    parent = nil,
    container = nil,
    scrollList = nil,
    scene = nil,
    sceneCallback = nil,
    dataTypeRegistered = false,
}

local eventsRegistered = false

local function safeCall(func, ...)
    local SafeCall = Nvk3UT and Nvk3UT.SafeCall
    if type(SafeCall) == "function" then
        return SafeCall(func, ...)
    end

    if type(func) ~= "function" then
        return nil
    end

    local results = { pcall(func, ...) }
    if not results[1] then
        return nil
    end

    table.remove(results, 1)
    return unpack(results)
end

local function logShim(action)
    if Diagnostics and Diagnostics.Debug then
        Diagnostics.Debug("RecentSummary SHIM -> %s", tostring(action))
    end
end

local function isDebugEnabled()
    local utils = Utils or Nvk3UT_Utils
    if utils and type(utils.IsDebugEnabled) == "function" then
        return utils.IsDebugEnabled()
    end
    return false
end

local ROW_TYPE_ID = 1
local MAX_RECENT_ENTRIES = 15

local function resolveSummaryInset()
    if ZO_AchievementsContents and type(ZO_AchievementsContents.GetNamedChild) == "function" then
        local inset = ZO_AchievementsContents:GetNamedChild("SummaryInset")
        if inset then
            return inset
        end
    end

    if state.parent and type(state.parent.GetNamedChild) == "function" then
        local ok, inset = pcall(state.parent.GetNamedChild, state.parent, "SummaryInset")
        if ok and inset then
            return inset
        end
    end

    return state.parent
end

local function resolveTopAnchor(parent)
    if parent and type(parent.GetNamedChild) == "function" then
        local ok, total = pcall(parent.GetNamedChild, parent, "Total")
        if ok and total then
            return total
        end
    end
    return parent
end

local function resolveBottomAnchor(summaryInset)
    if summaryInset and type(summaryInset.GetNamedChild) == "function" then
        local ok, recent = pcall(summaryInset.GetNamedChild, summaryInset, "Recent")
        if ok and recent then
            return recent
        end
    end
    return summaryInset
end

local function ensureScrollList()
    if state.scrollList then
        return state.scrollList
    end

    local summaryInset = resolveSummaryInset()
    if not summaryInset then
        return nil
    end

    local wm = WINDOW_MANAGER
    if not wm or type(wm.CreateControlFromVirtual) ~= "function" then
        return nil
    end

    local control = wm:CreateControlFromVirtual("Nvk3UT_RecentList", summaryInset, "ZO_ScrollList")

    if not control then
        return nil
    end

    control:SetWidth(542)

    local topAnchor = resolveTopAnchor(summaryInset)
    local bottomAnchor = resolveBottomAnchor(summaryInset)
    control:ClearAnchors()
    if topAnchor then
        control:SetAnchor(TOPLEFT, topAnchor, BOTTOMLEFT, 0, 10)
    end
    if bottomAnchor then
        control:SetAnchor(BOTTOMLEFT, bottomAnchor, TOPLEFT, 0, -10)
    end

    state.container = control
    state.scrollList = control

    return control
end

local function goToAchievement(rowControl)
    if not rowControl then
        return
    end

    local rowData = ZO_ScrollList_GetData(rowControl)
    if not rowData then
        return
    end

    local achievements = (SYSTEMS and SYSTEMS:GetObject("achievements")) or ACHIEVEMENTS
    if not achievements then
        return
    end

    local achievementId = rowData.achievementId
    local categoryIndex, subCategoryIndex = GetCategoryInfoFromAchievementId(achievementId)
    if not achievements:OpenCategory(categoryIndex, subCategoryIndex) then
        if achievements.contentSearchEditBox and achievements.contentSearchEditBox:GetText() ~= "" then
            achievements.contentSearchEditBox:SetText("")
            ACHIEVEMENTS_MANAGER:ClearSearch(true)
        end
    end
    if achievements:OpenCategory(categoryIndex, subCategoryIndex) then
        if not achievements.achievementsById then
            return
        end
        local parentAchievementIndex = achievements:GetBaseAchievementId(achievementId)
        if not achievements.achievementsById[parentAchievementIndex] then
            achievements:ResetFilters()
        end
        if achievements.achievementsById[parentAchievementIndex] then
            achievements.achievementsById[parentAchievementIndex]:Expand()
            ZO_Scroll_ScrollControlIntoCentralView(achievements.contentList, achievements.achievementsById[parentAchievementIndex]:GetControl())
        end
    end
end

local function setupDataRow(rowControl, rowData)
    if not (rowControl and rowData) then
        return
    end

    local label = rowControl.GetNamedChild and rowControl:GetNamedChild("Text") or rowControl
    if label and label.SetText then
        local name = GetAchievementInfo(rowData.achievementId)
        label:SetText(zo_strformat("<<1>>", name))
    end

    rowControl:SetHandler("OnMouseDoubleClick", function()
        goToAchievement(rowControl)
    end)

    rowControl:SetHandler("OnMouseUp", function(control, button, upInside)
        if button == MOUSE_BUTTON_INDEX_RIGHT and upInside then
            ClearMenu()
            AddCustomMenuItem(GetString(SI_ITEM_ACTION_LINK_TO_CHAT), function()
                ZO_LinkHandler_InsertLink(ZO_LinkHandler_CreateChatLink(GetAchievementLink, rowData.achievementId))
            end)
            AddCustomMenuItem((GetString and GetString(SI_NVK3UT_JOURNAL_CONTEXT_OPEN)) or "Öffnen", function()
                goToAchievement(rowControl)
            end)
            ShowMenu(control)
        end
    end)
end

local function ensureData()
    if Data then
        safeCall(Data.InitSavedVars, Data)
        safeCall(Data.BuildInitial, Data)
        safeCall(Data.RegisterEvents, Data)
    end
end

local function ensureSceneCallback()
    if state.sceneCallback then
        return
    end

    if not (SCENE_MANAGER and type(SCENE_MANAGER.GetScene) == "function") then
        return
    end

    local scene = SCENE_MANAGER:GetScene("achievements")
    if not scene then
        return
    end

    local function onStateChange(_, newState)
        if newState == SCENE_SHOWING then
            Summary:Refresh()
        end
    end

    scene:RegisterCallback("StateChange", onStateChange)
    state.scene = scene
    state.sceneCallback = onStateChange
end

local function ensureAchievementEvents()
    if eventsRegistered then
        return
    end

    local em = GetEventManager()
    if not em then
        return
    end

    local function onAchievementsUpdated(_eventCode)
        if SCENE_MANAGER and type(SCENE_MANAGER.IsShowing) == "function" and SCENE_MANAGER:IsShowing("achievements") then
            safeCall(Summary.Refresh, Summary)
        end
    end

    local function onAchievementUpdated(_eventCode, achievementId)
        local recentData = Nvk3UT and Nvk3UT.RecentData
        if recentData and type(recentData.Touch) == "function" then
            safeCall(recentData.Touch, recentData, achievementId)
        end
    end

    local function onAchievementAwarded(_eventCode, _, _, achievementId)
        local recentData = Nvk3UT and Nvk3UT.RecentData
        if recentData and type(recentData.Clear) == "function" then
            safeCall(recentData.Clear, recentData, achievementId)
        end
    end

    em:RegisterForEvent(EVENT_NAMESPACE, EVENT_ACHIEVEMENTS_UPDATED, onAchievementsUpdated)
    em:RegisterForEvent(EVENT_NAMESPACE, EVENT_ACHIEVEMENT_UPDATED, onAchievementUpdated)
    em:RegisterForEvent(EVENT_NAMESPACE, EVENT_ACHIEVEMENT_AWARDED, onAchievementAwarded)

    eventsRegistered = true
end

local function setupScrollList()
    local scrollList = ensureScrollList()
    if not scrollList then
        return nil
    end

    if not state.dataTypeRegistered then
        ZO_ScrollList_AddDataType(scrollList, ROW_TYPE_ID, "ZO_SelectableLabel", 24, setupDataRow)
        state.dataTypeRegistered = true
    end

    return scrollList
end

local function fetchRecentAchievementIds()
    if not Data then
        return {}
    end

    local ids = safeCall(Data.List, Data, MAX_RECENT_ENTRIES)
    if type(ids) ~= "table" then
        return {}
    end

    return ids
end

local function updateScrollList()
    local scrollList = setupScrollList()
    if not scrollList then
        return nil
    end

    local dataList = ZO_ScrollList_GetDataList(scrollList)
    if not dataList then
        return scrollList
    end

    ZO_ScrollList_Clear(scrollList)

    local ids = fetchRecentAchievementIds()
    for index = 1, #ids do
        local achievementId = tonumber(ids[index]) or ids[index]
        if achievementId then
            local rowData = { achievementId = achievementId }
            dataList[#dataList + 1] = ZO_ScrollList_CreateDataEntry(ROW_TYPE_ID, rowData, 1)
        end
    end

    ZO_ScrollList_Commit(scrollList)

    if isDebugEnabled() then
        Utils.d(string.format("[RecentSummary] Updated %d entries", #ids))
    end

    return scrollList
end

---Initialize the recent summary container.
---@param parentOrContainer any
---@return any
function Summary:Init(parentOrContainer)
    state.parent = parentOrContainer

    ensureData()
    setupScrollList()
    updateScrollList()
    ensureSceneCallback()
    ensureAchievementEvents()

    return state.container or state.scrollList
end

---Refresh the recent summary entries.
---@return any
function Summary:Refresh()
    return updateScrollList()
end

---Set the visibility of the recent summary container.
---@param isVisible boolean
function Summary:SetVisible(isVisible)
    local container = ensureScrollList()
    if container and container.SetHidden then
        container:SetHidden(isVisible == false)
    end
end

---Fetch the measured height of the summary container.
---@return number
function Summary:GetHeight()
    local container = state.container or state.scrollList
    if container and container.GetHeight then
        return container:GetHeight()
    end
    return 0
end

function Nvk3UT.EnableRecentSummary(...)
    logShim("Init")
    if type(Summary.Init) ~= "function" then
        return nil
    end

    local result = safeCall(Summary.Init, Summary, ...)
    ensureAchievementEvents()
    return result
end

function Nvk3UT.RefreshRecentSummary(...)
    logShim("Refresh")
    if type(Summary.Refresh) ~= "function" then
        return nil
    end
    return safeCall(Summary.Refresh, Summary, ...)
end

function Nvk3UT.SetRecentSummaryVisible(...)
    logShim("SetVisible")
    if type(Summary.SetVisible) ~= "function" then
        return nil
    end
    return safeCall(Summary.SetVisible, Summary, ...)
end

function Nvk3UT.GetRecentSummaryHeight(...)
    if type(Summary.GetHeight) ~= "function" then
        return 0
    end
    local height = safeCall(Summary.GetHeight, Summary, ...)
    return tonumber(height) or 0
end

return Summary
