Nvk3UT = Nvk3UT or {}

local function _nvk3ut_is_enabled(key)
    return (Nvk3UT and Nvk3UT.sv and Nvk3UT.sv.features and Nvk3UT.sv.features[key]) and true or false
end

local function getCompletedData()
    return Nvk3UT and Nvk3UT.CompletedData
end

local U = Nvk3UT and Nvk3UT.Utils

local NVK3_DONE = 84003
local ICON_PATH_COMPLETED = "/esoui/art/guild/tabicon_history_up.dds"
local ICON_PATH_COMPLETED_RECENT = "/esoui/art/journal/journal_tabicon_quest_up.dds"
local COMPLETED_LOOKUP_KEY = "NVK3UT_COMPLETED_ROOT"

local function sanitizePlainName(name)
    if U and U.StripLeadingIconTag then
        name = U.StripLeadingIconTag(name)
    end
    return name
end

local compProvide_lastTs, compProvide_lastCount = 0, -1

local function _isDebug()
    local utils = (Nvk3UT and Nvk3UT.Utils) or Nvk3UT_Utils
    if utils and type(utils.IsDebugEnabled) == "function" then
        return utils.IsDebugEnabled()
    end
    local diagnostics = (Nvk3UT and Nvk3UT.Diagnostics) or Nvk3UT_Diagnostics
    if diagnostics and type(diagnostics.IsDebugEnabled) == "function" then
        return diagnostics:IsDebugEnabled()
    end
    local root = Nvk3UT
    if root and type(root.IsDebugEnabled) == "function" then
        return root:IsDebugEnabled()
    end
    return false
end

local function _debugLog(...)
    if not _isDebug() then
        return
    end
    if U and U.d then
        U.d(...)
    end
end

local function _formatCompletedTooltipLine(data, points, iconTag)
    local name = data and (data.name or data.text)
    if not name and data and data.categoryData then
        name = data.categoryData.name or data.categoryData.text
    end
    local label = zo_strformat("<<1>>", name or "")
    local value = ZO_CommaDelimitNumber(points or 0)
    local prefix = iconTag or ""
    if prefix ~= "" then
        return string.format("%s%s - %s", prefix, label, value)
    end
    return string.format("%s - %s", label, value)
end

local function _extractYearFromKey(key, last50Key)
    if type(key) ~= "number" then
        return nil
    end
    if last50Key and key == last50Key then
        return nil
    end
    local month = key % 100
    if month < 1 or month > 12 then
        return nil
    end
    local year = math.floor(key / 100)
    if year < 1 then
        return nil
    end
    return year
end

local function _completedPointsForKey(key)
    local Comp = getCompletedData()
    if not (Comp and Comp.SummaryCountAndPointsForKey) then
        return 0
    end
    local ok, count, points = pcall(Comp.SummaryCountAndPointsForKey, key)
    if ok then
        if type(points) == "number" then
            return points
        end
        if type(count) == "number" then
            return count
        end
    end
    return 0
end

local function _collectOrderedChildren(node)
    local ordered = {}
    if not node then
        return ordered
    end

    if node.GetNumChildren and node.GetChildByIndex then
        local count = node:GetNumChildren()
        for idx = 1, (count or 0) do
            local child = node:GetChildByIndex(idx)
            if child ~= nil then
                ordered[#ordered + 1] = child
            end
        end
    end

    if (#ordered == 0) and node.GetChildren then
        local raw = node:GetChildren()
        if type(raw) == "table" then
            for idx = 1, #raw do
                local child = raw[idx]
                if child ~= nil then
                    ordered[#ordered + 1] = child
                end
            end
        end
    end

    return ordered
end

-- Collect tooltip payloads whenever the completed tree is rebuilt/refreshed so the
-- summary tooltip reflects the on-screen ordering and point totals.
local function _updateCompletedTooltip(ach)
    if not ach then
        return
    end

    local Comp = getCompletedData()
    local parentNode = ach._nvkCompletedNode
    if not (parentNode and parentNode.GetData) then
        return
    end

    local parentData = parentNode:GetData()
    if not parentData then
        return
    end

    local orderedChildren = _collectOrderedChildren(parentNode)
    if #orderedChildren == 0 and type(ach._nvkCompletedChildren) == "table" then
        for idx = 1, #ach._nvkCompletedChildren do
            orderedChildren[#orderedChildren + 1] = ach._nvkCompletedChildren[idx]
        end
    elseif #orderedChildren > 0 then
        ach._nvkCompletedChildren = orderedChildren
    end

    local iconHoliday = (U and U.GetIconTagForTexture and U.GetIconTagForTexture(ICON_PATH_COMPLETED)) or ""
    local iconRecent = (U and U.GetIconTagForTexture and U.GetIconTagForTexture(ICON_PATH_COMPLETED_RECENT)) or ""

    local detailLines = {}
    parentData.isNvkCompleted = true
    parentData.nvkSummaryTooltipText = nil

    local constants = Comp and Comp.Constants and Comp.Constants()
    local last50Key = constants and constants.LAST50_KEY
    local yearTotals, years, monthlyCount = {}, {}, 0

    for idx = 1, #orderedChildren do
        local node = orderedChildren[idx]
        local data = node and node.GetData and node:GetData()
        if data then
            data.isNvkCompleted = true
            local key = data.nvkCompletedKey or data.subcategoryIndex
            if key then
                local points = _completedPointsForKey(key)
                local iconTag = iconHoliday
                if last50Key and key == last50Key then
                    iconTag = iconRecent
                end
                local line = _formatCompletedTooltipLine(data, points, iconTag)
                data.nvkSummaryTooltipText = line
                local year = _extractYearFromKey(key, last50Key)
                if year then
                    monthlyCount = monthlyCount + 1
                    if yearTotals[year] == nil then
                        yearTotals[year] = points or 0
                        years[#years + 1] = year
                    else
                        yearTotals[year] = (yearTotals[year] or 0) + (points or 0)
                    end
                elseif line then
                    detailLines[#detailLines + 1] = line
                end
            else
                data.nvkSummaryTooltipText = nil
            end
        end
    end

    local parentLines = {}
    for idx = 1, #detailLines do
        parentLines[#parentLines + 1] = detailLines[idx]
    end

    table.sort(years, function(a, b)
        return a > b
    end)

    local yearLineCount = 0
    for idx = 1, #years do
        local year = years[idx]
        local total = yearTotals[year] or 0
        if total > 0 then
            local line = string.format("%d - %s", year, ZO_CommaDelimitNumber(total))
            if iconHoliday ~= "" then
                line = iconHoliday .. line
            end
            parentLines[#parentLines + 1] = line
            yearLineCount = yearLineCount + 1
        end
    end

    if #parentLines > 0 then
        parentData.nvkSummaryTooltipText = table.concat(parentLines, "\n")
    end

    if _isDebug() then
        _debugLog(
            "[Nvk3UT][Completed][TooltipData]",
            string.format("months=%d years=%d", monthlyCount, yearLineCount)
        )
    end
end

local function AddCompletedCategory(AchClass)
    local orgAddTopLevelCategory = AchClass.AddTopLevelCategory

    function AchClass:AddTopLevelCategory(...)
        local result = orgAddTopLevelCategory(self, ...)
        if not _nvk3ut_is_enabled("completed") then
            return result
        end

        local Comp = getCompletedData()
        if not (Comp and Comp.GetSubcategoryList) then
            return result
        end

        local lookup, tree = self.nodeLookupData, self.categoryTree
        if not (lookup and tree) then
            return result
        end

        if lookup[COMPLETED_LOOKUP_KEY] then
            local existing = lookup[COMPLETED_LOOKUP_KEY]
            if existing and not self._nvkCompletedNode then
                self._nvkCompletedNode = existing
            end
            return result
        end

        local nodeTemplate = "ZO_IconHeader"
        local subTemplate = "ZO_TreeLabelSubCategory"

        local parentNode = self:AddCategory(
            lookup,
            tree,
            nodeTemplate,
            nil,
            NVK3_DONE,
            (GetString and GetString(SI_NVK3UT_JOURNAL_CATEGORY_COMPLETED)) or "Abgeschlossen",
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

        lookup[COMPLETED_LOOKUP_KEY] = parentNode
        self._nvkCompletedNode = parentNode
        self._nvkCompletedChildren = {}

        local parentData = parentNode.GetData and parentNode:GetData()
        if parentData then
            parentData.isNvkCompleted = true
            parentData.nvkSummaryTooltipText = nil
            local plainParent = parentData.name
                or parentData.text
                or (GetString and GetString(SI_NVK3UT_JOURNAL_CATEGORY_COMPLETED))
                or "Abgeschlossen"
            parentData.nvkPlainName = parentData.nvkPlainName or sanitizePlainName(plainParent)
        end

        local names, ids = Comp.GetSubcategoryList()
        if type(names) ~= "table" or type(ids) ~= "table" then
            names, ids = {}, {}
        end

        for index = 1, #ids do
            local node = self:AddCategory(lookup, tree, subTemplate, parentNode, ids[index], names[index], true)
            if node then
                self._nvkCompletedChildren[#self._nvkCompletedChildren + 1] = node
                local data = node.GetData and node:GetData()
                if data then
                    data.isNvkCompleted = true
                    data.nvkSummaryTooltipText = nil
                    data.nvkCompletedKey = ids[index]
                    local plainName = names[index]
                    data.nvkPlainName = data.nvkPlainName or sanitizePlainName(plainName)
                end
            end
        end

        _updateCompletedTooltip(self)

        if self.refreshGroups then
            self.refreshGroups:RefreshAll("FullUpdate")
        end

        return result
    end
end

local function OverrideOnCategorySelected(AchClass)
    local org = AchClass.OnCategorySelected

    function AchClass:OnCategorySelected(data, saveExpanded)
        if _nvk3ut_is_enabled("completed") and data and data.categoryIndex == NVK3_DONE then
            self:HideSummary()
            self:UpdateCategoryLabels(data, true, false)
            _updateCompletedTooltip(self)
            if Nvk3UT and Nvk3UT.UI and Nvk3UT.UI.UpdateStatus then
                Nvk3UT.UI.UpdateStatus()
            end
            return
        end

        local result = org(self, data, saveExpanded)
        if Nvk3UT and Nvk3UT.UI and Nvk3UT.UI.UpdateStatus then
            Nvk3UT.UI.UpdateStatus()
        end
        return result
    end
end

local function OverrideGetCategoryInfoFromData(AchClass)
    local org = AchClass.GetCategoryInfoFromData

    function AchClass:GetCategoryInfoFromData(data, parentData)
        if _nvk3ut_is_enabled("completed") and data and data.categoryIndex == NVK3_DONE then
            local Comp = getCompletedData()
            local key = data.subcategoryIndex or (Comp and Comp.Constants and Comp.Constants().LAST50_KEY)
            if key and Comp and Comp.SummaryCountAndPointsForKey then
                local num, pts = Comp.SummaryCountAndPointsForKey(key)
                return num, pts, 0, 0, 0, 0
            end
        end
        return org(self, data, parentData)
    end
end

local function Override_ZO_GetAchievementIds()
    local base = ZO_GetAchievementIds

    function ZO_GetAchievementIds(categoryIndex, subcategoryIndex, numAchievements, considerSearchResults)
        if categoryIndex == NVK3_DONE then
            local Comp = getCompletedData()
            local key = subcategoryIndex or (Comp and Comp.Constants and Comp.Constants().LAST50_KEY)
            if key and Comp and Comp.ListForKey then
                local list = Comp.ListForKey(key) or {}
                if _isDebug() then
                    local now = U and U.now and U.now() or GetTimeStamp()
                    if (now - compProvide_lastTs) > 0.5 or #list ~= compProvide_lastCount then
                        compProvide_lastTs = now
                        compProvide_lastCount = #list
                        _debugLog(
                            "[Nvk3UT][Completed][Provide] list",
                            string.format(
                                "data={count:%d, searchFiltered:%s}",
                                #list,
                                tostring(considerSearchResults and true or false)
                            )
                        )
                    end
                end
                return list
            end
        end
        return base(categoryIndex, subcategoryIndex, numAchievements, considerSearchResults)
    end
end

local function OverrideOnAchievementUpdated(AchClass)
    local org = AchClass.OnAchievementUpdated

    function AchClass:OnAchievementUpdated(id)
        local data = self.categoryTree and self.categoryTree:GetSelectedData()
        if _nvk3ut_is_enabled("completed") and data and data.categoryIndex == NVK3_DONE then
            local Comp = getCompletedData()
            if Comp and Comp.Rebuild then
                Comp.Rebuild()
            end
            self:UpdateCategoryLabels(data, true, false)
            _updateCompletedTooltip(self)
            if Nvk3UT and Nvk3UT.UI and Nvk3UT.UI.UpdateStatus then
                Nvk3UT.UI.UpdateStatus()
            end
            return
        end
        return org(self, id)
    end
end

function Nvk3UT.EnableCompletedCategory()
    local AchClass = getmetatable(ACHIEVEMENTS).__index
    AddCompletedCategory(AchClass)
    OverrideOnCategorySelected(AchClass)
    OverrideGetCategoryInfoFromData(AchClass)
    Override_ZO_GetAchievementIds()
    OverrideOnAchievementUpdated(AchClass)
end
