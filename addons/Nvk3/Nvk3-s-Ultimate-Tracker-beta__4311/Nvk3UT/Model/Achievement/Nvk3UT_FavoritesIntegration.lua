Nvk3UT = Nvk3UT or {}
local function _nvk3ut_is_enabled(key)
  return (Nvk3UT and Nvk3UT.sv and Nvk3UT.sv.features and Nvk3UT.sv.features[key]) and true or false
end

local function resolveFavoritesScope()
    local root = Nvk3UT and Nvk3UT.sv
    local general = root and root.General
    local scope = general and general.favScope
    if type(scope) == "string" and scope ~= "" then
        return scope
    end
    return "account"
end

local function getFavoritesModule()
    return Nvk3UT and Nvk3UT.FavoritesData
end

local function getAchievementState()
    return Nvk3UT and Nvk3UT.AchievementState
end

local hasPrunedCompletedFavorites = false

local U = Nvk3UT.Utils

local function isDebugEnabled()
    local utils = (Nvk3UT and Nvk3UT.Utils) or Nvk3UT_Utils
    if utils and type(utils.IsDebugEnabled) == "function" then
        local ok, enabled = pcall(utils.IsDebugEnabled)
        if ok and enabled ~= nil then
            return enabled == true
        end
    end

    local diagnostics = (Nvk3UT and Nvk3UT.Diagnostics) or Nvk3UT_Diagnostics
    if diagnostics and type(diagnostics.IsDebugEnabled) == "function" then
        local ok, enabled = pcall(function()
            return diagnostics:IsDebugEnabled()
        end)
        if ok and enabled ~= nil then
            return enabled == true
        end
    end

    local root = Nvk3UT
    if root and type(root.IsDebugEnabled) == "function" then
        local ok, enabled = pcall(function()
            return root:IsDebugEnabled()
        end)
        if ok and enabled ~= nil then
            return enabled == true
        end
    end

    return false
end

local function debugLog(fmt, ...)
    if not isDebugEnabled() then
        return
    end

    local utils = (Nvk3UT and Nvk3UT.Utils) or Nvk3UT_Utils
    local ok, message = pcall(string.format, tostring(fmt or ""), ...)
    if not ok then
        message = tostring(fmt)
    end

    if utils and type(utils.d) == "function" then
        utils.d(message)
        return
    end

    if type(d) == "function" then
        d(message)
    elseif type(print) == "function" then
        print(message)
    end
end
local favProvide_lastTs, favProvide_lastCount = 0, -1

local NVK3_FAVORITES_KEY = "Nvk3UT_Favorites"
local ICON_PATH_FAVORITES = "/esoui/art/guild/guild_rankicon_leader_large.dds"
local FAVORITES_LOOKUP_KEY = "NVK3UT_FAVORITES_ROOT"

local function ForceAchievementRefresh(context)
    local Rebuild = Nvk3UT and Nvk3UT.Rebuild
    if Rebuild and Rebuild.ForceAchievementRefresh then
        Rebuild.ForceAchievementRefresh(context)
    end
end

local _liveRefreshFavoritesIfActive

local function _getAchievementsScrollList()
    local achievements = ACHIEVEMENTS
    if not achievements then
        return nil
    end

    local list = achievements.list or achievements.contentList or achievements.scrollList or achievements.listControl
    if not list and type(achievements.GetList) == "function" then
        local ok, result = pcall(achievements.GetList, achievements)
        if ok and result then
            list = result
        end
    end

    return list
end

local function _captureScrollState(list)
    if not list then
        return nil
    end

    local scrollBar = list.scrollBar
    if scrollBar and scrollBar.GetValue then
        local ok, value = pcall(scrollBar.GetValue, scrollBar)
        if ok then
            return { kind = "scrollBar", control = scrollBar, value = value }
        end
    end

    if type(list.GetVerticalScroll) == "function" then
        local ok, value = pcall(list.GetVerticalScroll, list)
        if ok then
            return { kind = "vertical", control = list, value = value }
        end
    end

    if type(list.GetScrollPosition) == "function" then
        local ok, value = pcall(list.GetScrollPosition, list)
        if ok then
            return { kind = "position", control = list, value = value }
        end
    end

    return nil
end

local function _restoreScrollState(state)
    if not state then
        return
    end

    if state.kind == "scrollBar" then
        local bar = state.control
        if bar and bar.SetValue then
            pcall(bar.SetValue, bar, state.value)
        end
    elseif state.kind == "vertical" then
        local control = state.control
        if control and control.SetVerticalScroll then
            pcall(control.SetVerticalScroll, control, state.value)
        end
    elseif state.kind == "position" then
        local control = state.control
        if control and control.SetScrollPosition then
            pcall(control.SetScrollPosition, control, state.value)
        end
    end
end

local function _extractAchievementIdFromData(data)
    if type(data) ~= "table" then
        return nil
    end

    return data.id or data.achievementId or data.achievementID or data.achievement or data.achievementIndex
end

local function _captureSelectionState(list)
    if not (list and ZO_ScrollList_GetSelectedData) then
        return nil
    end

    local selectedEntry = ZO_ScrollList_GetSelectedData(list)
    if type(selectedEntry) ~= "table" then
        return nil
    end

    local entryData = selectedEntry.data or selectedEntry
    local id = _extractAchievementIdFromData(entryData)
    local index
    if ZO_ScrollList_GetSelectedIndex then
        index = ZO_ScrollList_GetSelectedIndex(list)
    end

    return { id = id, index = index }
end

local function _restoreSelectionState(list, state)
    if not (list and state and ZO_ScrollList_GetDataList) then
        return
    end

    local targetIndex = state.index
    local targetId = state.id

    if targetId then
        local entries = ZO_ScrollList_GetDataList(list)
        if type(entries) == "table" then
            for index = 1, #entries do
                local entry = entries[index]
                local data = entry and (entry.data or entry)
                if data and _extractAchievementIdFromData(data) == targetId then
                    targetIndex = index
                    break
                end
            end
        end
    end

    if targetIndex and targetIndex > 0 and ZO_ScrollList_SetSelectedIndex then
        ZO_ScrollList_SetSelectedIndex(list, targetIndex)
    end
end

local _isRefreshingFavorites = false

local function _shouldRefreshFavorites()
    if not _nvk3ut_is_enabled("favorites") then
        return false
    end

    local achievements = ACHIEVEMENTS
    if not achievements then
        return false
    end

    local tree = achievements.categoryTree
    if not (tree and tree.GetSelectedData) then
        return false
    end

    local selectedData = tree:GetSelectedData()
    if not (selectedData and selectedData.categoryIndex == NVK3_FAVORITES_KEY) then
        return false
    end

    return true, achievements, tree, selectedData
end

local function _reselectFavoritesCategory(achievements, tree, data)
    local nodeLookup = achievements and (achievements.nodeLookupData or (tree and tree.nodeLookupData))
    local node = nodeLookup and nodeLookup[FAVORITES_LOOKUP_KEY]
    if node and tree and tree.SelectNode then
        local selectedNode = tree.GetSelectedNode and tree:GetSelectedNode()
        if selectedNode ~= node then
            pcall(tree.SelectNode, tree, node)
            return
        end
    end

    if achievements and achievements.OnCategorySelected then
        pcall(achievements.OnCategorySelected, achievements, data, true)
    end
end

_liveRefreshFavoritesIfActive = function()
    if _isRefreshingFavorites then
        return
    end

    local shouldRefresh, achievements, tree, data = _shouldRefreshFavorites()
    if not shouldRefresh then
        return
    end

    _isRefreshingFavorites = true

    local list = _getAchievementsScrollList()
    local scrollState = _captureScrollState(list)
    local selectionState = _captureSelectionState(list)

    _reselectFavoritesCategory(achievements, tree, data)

    if achievements and achievements.RefreshVisible then
        pcall(achievements.RefreshVisible, achievements)
    elseif achievements and achievements.RefreshVisibleCategory then
        pcall(achievements.RefreshVisibleCategory, achievements)
    end

    if list then
        _restoreScrollState(scrollState)
        _restoreSelectionState(list, selectionState)
    end

    _isRefreshingFavorites = false
end

local function sanitizePlainName(name)
  if U and U.StripLeadingIconTag then
    name = U.StripLeadingIconTag(name)
  end
  return name
end

local function _countFavorites()
    local Fav = getFavoritesModule()
    if not (Fav and Fav.GetAllFavorites) then
        return 0
    end
    local scope = resolveFavoritesScope()
    local iterator, state, key = Fav.GetAllFavorites(scope)
    if type(iterator) ~= "function" then
        return 0
    end

    local count = 0
    for _, flagged in iterator, state, key do
        if flagged then
            count = count + 1
        end
    end

    return count
end

local function _updateFavoritesTooltip(ach)
    if not ach then
        return
    end
    local node = ach._nvkFavoritesNode
    local data
    if node and node.GetData then
        data = node:GetData()
    end
    data = data or ach._nvkFavoritesData
    if not data then
        return
    end

    local count = _countFavorites()
    local name = data.name
        or data.text
        or (data.categoryData and data.categoryData.name)
        or (GetString and GetString(SI_NVK3UT_JOURNAL_CATEGORY_FAVORITES))
        or "Favoriten"
    local label = zo_strformat("<<1>>", name)
    local iconTag = (U and U.GetIconTagForTexture and U.GetIconTagForTexture(ICON_PATH_FAVORITES)) or ""
    local displayLabel = (iconTag ~= "" and (iconTag .. label)) or label
    local line = string.format("%s - %s", displayLabel, ZO_CommaDelimitNumber(count or 0))
    data.isNvkFavorites = true
    data.nvkSummaryTooltipText = line
    ach._nvkFavoritesData = data
end

local function AddFavoritesTopCategory(AchievementsClass)
    local orgAddTopLevelCategory = AchievementsClass.AddTopLevelCategory
    function AchievementsClass:AddTopLevelCategory(...)
        local result = orgAddTopLevelCategory(self, ...)
        if not _nvk3ut_is_enabled("favorites") then
            return result
        end

        local lookup, tree = self.nodeLookupData, self.categoryTree
        if not (lookup and tree) then
            return result
        end

        if lookup[FAVORITES_LOOKUP_KEY] then
            local node = lookup[FAVORITES_LOOKUP_KEY]
            if node and not self._nvkFavoritesNode then
                self._nvkFavoritesNode = node
            end
            return result
        end

        local parentNode =
            self:AddCategory(
                lookup,
                tree,
                "ZO_IconChildlessHeader",
                nil,
                NVK3_FAVORITES_KEY,
                (GetString and GetString(SI_NVK3UT_JOURNAL_CATEGORY_FAVORITES)) or "Favoriten",
                false,
                nil,
                nil,
                nil,
                true,
                true
            )
        if not parentNode then
            return result
        end

        lookup[FAVORITES_LOOKUP_KEY] = parentNode
        self._nvkFavoritesNode = parentNode
        local row = parentNode.GetData and parentNode:GetData()
        if row then
            row.isNvkFavorites = true
            row.nvkSummaryTooltipText = nil
            row.isNvk3Fav = true
            local plain = row.name
                or row.text
                or (GetString and GetString(SI_NVK3UT_JOURNAL_CATEGORY_FAVORITES))
                or "Favoriten"
            row.nvkPlainName = row.nvkPlainName or sanitizePlainName(plain)
            self._nvkFavoritesData = row
        end

        _updateFavoritesTooltip(self)
        if self.refreshGroups then
            self.refreshGroups:RefreshAll("FullUpdate")
        end

        return result
    end
end

local function OverrideOnCategorySelected(AchievementsClass)
    local org = AchievementsClass.OnCategorySelected
    function AchievementsClass.OnCategorySelected(...)
                if not _nvk3ut_is_enabled("favorites") then return org(...) end
        local ACH, data, saveExpanded = ...
        if data.categoryIndex == NVK3_FAVORITES_KEY then
            ACH:HideSummary()
            ACH.UpdateCategoryLabels(...)
            _updateFavoritesTooltip(ACH)
        else
            return org(...)
        end
    end
end

local function _wrapFavoritesMutation(methodName, evaluateChanged)
    local Fav = getFavoritesModule()
    if not Fav then
        return
    end

    local original = Fav[methodName]
    if type(original) ~= "function" then
        return
    end

    Fav[methodName] = function(...)
        local results = { original(...) }
        local shouldRefresh = evaluateChanged and evaluateChanged(results)
        if shouldRefresh then
            _liveRefreshFavoritesIfActive()
        end
        return unpack(results)
    end
end

local function _ensureFavoritesMutationHooks()
    local Fav = getFavoritesModule()
    if not Fav or Fav._nvkFavoritesRefreshHooked then
        return
    end

    Fav._nvkFavoritesRefreshHooked = true

    _wrapFavoritesMutation("SetFavorited", function(results)
        return results[1] == true
    end)

    _wrapFavoritesMutation("RemoveFavorite", function(results)
        return results[1] == true
    end)

    _wrapFavoritesMutation("ToggleFavorited", function(results)
        return results[2] == true
    end)
end

local function OverrideGetCategoryInfoFromData(AchievementsClass)
    local org = AchievementsClass.GetCategoryInfoFromData
    function AchievementsClass.GetCategoryInfoFromData(...)
                if not _nvk3ut_is_enabled("favorites") then return org(...) end
        local ACH, data, parentData = ...
        if data.categoryIndex == NVK3_FAVORITES_KEY then
            local Fav = getFavoritesModule()
            if not (Fav and Fav.GetAllFavorites) then
                return org(...)
            end
            local num, earned, total = 0, 0, 0
            local __scope = resolveFavoritesScope()
            for id, flagged in Fav.GetAllFavorites(__scope) do
                if flagged then
                    num = num + 1
                    local _, _, points, _, completed = GetAchievementInfo(id)
                    total = total + (points or 0)
                    if completed then
                        earned = earned + (points or 0)
                    end
                end
            end
            local hidesPoints = total == 0
            return num, earned, total, hidesPoints
        else
            return org(...)
        end
    end
end

local function OverrideOnAchievementUpdated(AchievementsClass)
    local org = AchievementsClass.OnAchievementUpdated
    function AchievementsClass.OnAchievementUpdated(...)
        local ACH, id = ...
        local data = ACH.categoryTree:GetSelectedData()
        if _nvk3ut_is_enabled("favorites") and data and data.categoryIndex == NVK3_FAVORITES_KEY then
            local isFav = false
            local state = getAchievementState()
            if state and state.IsFavorited then
                local ok, result = pcall(state.IsFavorited, id)
                if ok and result then
                    isFav = true
                end
            end

            if not isFav then
                local Fav = getFavoritesModule()
                if Fav and Fav.IsFavorited then
                    local ok, result = pcall(Fav.IsFavorited, id, resolveFavoritesScope())
                    if ok and result then
                        isFav = true
                    end
                end
            end

            if isFav and ZO_ShouldShowAchievement(ACH.categoryFilter.filterType, id) then
                ACH:UpdateCategoryLabels(data, true, false)
                _updateFavoritesTooltip(ACH)
            end
        else
            return org(...)
        end
    end
end

local function Override_ZO_GetAchievementIds()
    local org = ZO_GetAchievementIds
    local idToName = {}
    local gender = GetUnitGender("player")
    local function nameOf(id)
        local name = GetAchievementInfo(id)
        name = zo_strformat(name, gender)
        idToName[id] = name
        return name
    end
    local function sortByName(a,b) return (idToName[a] or nameOf(a)) < (idToName[b] or nameOf(b)) end
    function ZO_GetAchievementIds(...)
        local categoryIndex, subcategoryIndex, numAchievements, considerSearchResults = ...
        if categoryIndex == NVK3_FAVORITES_KEY then
            local result = {}
            local Fav = getFavoritesModule()
            if not (Fav and Fav.GetAllFavorites) then
                return result
            end
            local searchResults = considerSearchResults and ACHIEVEMENTS_MANAGER:GetSearchResults()
            if searchResults then
                local GetCategoryInfoFromAchievementId = GetCategoryInfoFromAchievementId
                local __scope = resolveFavoritesScope()
                for id, flagged in Fav.GetAllFavorites(__scope) do
                    if flagged then
                        local cIdx, scIdx, aIdx = GetCategoryInfoFromAchievementId(id)
                        local r = searchResults[cIdx]
                        if r then
                            r = r[scIdx or ZO_ACHIEVEMENTS_ROOT_SUBCATEGORY]
                            if r and r[aIdx] then
                                result[#result + 1] = id
                            end
                        end
                    end
                end
            else
                local __scope = resolveFavoritesScope()
                for id, flagged in Fav.GetAllFavorites(__scope) do
                    if flagged then
                        result[#result + 1] = id
                    end
                end
            end
            table.sort(result, sortByName)
            local utils = (Nvk3UT and Nvk3UT.Utils) or Nvk3UT_Utils
            local now = (utils and utils.now and utils.now() or 0)
            if isDebugEnabled() and ((now - favProvide_lastTs) > 0.5 or #result ~= favProvide_lastCount) then
                favProvide_lastTs = now
                favProvide_lastCount = #result
                debugLog("[Nvk3UT][Favorites][Provide] list data={count:%d, searchFiltered:%s}", #result, tostring(considerSearchResults and true or false))
            end
            return result
        else
            return org(...)
        end
    end
end

local function HookAchievementContext()
    local AchClass
    local function HookAchClass(class)
        if AchClass then return end
        AchClass = class
        local orgOnClicked = AchClass.OnClicked
        function AchClass:OnClicked(...)
            local button = ...
            if button == MOUSE_BUTTON_INDEX_LEFT then
                return orgOnClicked(self, ...)
            elseif button == MOUSE_BUTTON_INDEX_RIGHT and IsChatSystemAvailableForCurrentPlatform() then
                local orgShowMenu = ShowMenu
                function ShowMenu(...)
                    ShowMenu = orgShowMenu
                    if not ACHIEVEMENTS.control:IsHidden() then
                        local id = ACHIEVEMENTS:GetBaseAchievementId(self:GetId())
                        local __scope = resolveFavoritesScope()
                        local isFav = false
                        local state = getAchievementState()
                        if state and state.IsFavorited then
                            local ok, result = pcall(state.IsFavorited, id)
                            if ok and result then
                                isFav = true
                            end
                        end
                        if not isFav then
                            local Fav = getFavoritesModule()
                            if Fav and Fav.IsFavorited then
                                local ok, result = pcall(Fav.IsFavorited, id, __scope)
                                if ok and result then
                                    isFav = true
                                elseif id ~= self:GetId() then
                                    ok, result = pcall(Fav.IsFavorited, self:GetId(), __scope)
                                    isFav = ok and result and true or false
                                end
                            end
                        end
                        debugLog("[Nvk3UT][Favorites][Menu] open data={id:%d, isFav:%s}", id, tostring(isFav))
                        if isFav then
                            AddCustomMenuItem(
                                (GetString and GetString(SI_NVK3UT_JOURNAL_CONTEXT_REMOVE_FAVORITE))
                                    or "Von Favoriten entfernen",
                                function()
                                -- remove entire line of series
                                local chainId = id
                                while chainId ~= 0 do
                                    local state = getAchievementState()
                                    if state and state.SetFavorited then
                                        local ok = pcall(state.SetFavorited, chainId, false, "FavoritesIntegration:ContextRemove")
                                        if not ok then
                                            local Fav = getFavoritesModule()
                                            if Fav and Fav.SetFavorited then
                                                Fav.SetFavorited(chainId, false, "FavoritesIntegration:ContextRemove", __scope)
                                            end
                                        end
                                    else
                                        local Fav = getFavoritesModule()
                                        if Fav and Fav.SetFavorited then
                                            Fav.SetFavorited(chainId, false, "FavoritesIntegration:ContextRemove", __scope)
                                        end
                                    end
                                    chainId = GetNextAchievementInLine(chainId)
                                end
                                debugLog("[Nvk3UT][Favorites][Toggle] remove data={rootId:%d}", ACHIEVEMENTS:GetBaseAchievementId(self:GetId()))
                                if ACHIEVEMENTS and ACHIEVEMENTS.refreshGroups then ACHIEVEMENTS.refreshGroups:RefreshAll("FullUpdate") end
                                ForceAchievementRefresh("FavoritesIntegration:RemoveFromMenu")
                                _liveRefreshFavoritesIfActive()
                                _updateFavoritesTooltip(ACHIEVEMENTS)
                                if Nvk3UT.UI and Nvk3UT.UI.UpdateStatus then Nvk3UT.UI.UpdateStatus() end
                            end)
                        else
                            AddCustomMenuItem(
                                (GetString and GetString(SI_NVK3UT_JOURNAL_CONTEXT_ADD_FAVORITE)) or "Zu Favoriten hinzufügen",
                                function()
                                local state = getAchievementState()
                                if state and state.SetFavorited then
                                    local ok = pcall(state.SetFavorited, id, true, "FavoritesIntegration:ContextAdd")
                                    if not ok then
                                        local Fav = getFavoritesModule()
                                        if Fav and Fav.SetFavorited then
                                            Fav.SetFavorited(id, true, "FavoritesIntegration:ContextAdd", __scope)
                                        end
                                    end
                                else
                                    local Fav = getFavoritesModule()
                                    if Fav and Fav.SetFavorited then
                                        Fav.SetFavorited(id, true, "FavoritesIntegration:ContextAdd", __scope)
                                    end
                                end
                                debugLog("[Nvk3UT][Favorites][Toggle] add data={id:%d, scope:%s}", id, tostring(__scope))
                                ForceAchievementRefresh("FavoritesIntegration:AddFromMenu")
                                _liveRefreshFavoritesIfActive()
                                _updateFavoritesTooltip(ACHIEVEMENTS)
                                if Nvk3UT.UI and Nvk3UT.UI.UpdateStatus then Nvk3UT.UI.UpdateStatus() end
                            end)
                        end
                    end
                    return ShowMenu(...)
                end
                return orgOnClicked(self, ...)
            end
        end
    end
    local orgFactory = ACHIEVEMENTS.achievementPool.m_Factory
    ACHIEVEMENTS.achievementPool.m_Factory = function(...)
        local ach = orgFactory(...)
        if ach and not AchClass then HookAchClass(getmetatable(ach).__index) end
        return ach
    end
end

function Nvk3UT.EnableFavorites()
    if not hasPrunedCompletedFavorites then
        hasPrunedCompletedFavorites = true
        local Fav = getFavoritesModule()
        if Fav and Fav.PruneCompletedFavorites then
            -- TODO(Events-Migration): Move this call into Events/Nvk3UT_AchievementEventHandler.lua during SWITCH token.
            local ok, removed = pcall(Fav.PruneCompletedFavorites)
            local removedCount = (ok and tonumber(removed)) or 0
            if removedCount > 0 then
                local runtime = Nvk3UT and Nvk3UT.TrackerRuntime
                if runtime and type(runtime.QueueDirty) == "function" then
                    pcall(runtime.QueueDirty, runtime, "achievement")
                end
            end
        end
    end

    local AchievementsClass = getmetatable(ACHIEVEMENTS).__index
    AddFavoritesTopCategory(AchievementsClass)
    OverrideOnCategorySelected(AchievementsClass)
    OverrideGetCategoryInfoFromData(AchievementsClass)
    OverrideOnAchievementUpdated(AchievementsClass)
    Override_ZO_GetAchievementIds()
    HookAchievementContext()
    _ensureFavoritesMutationHooks()
end
