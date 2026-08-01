Nvk3UT = Nvk3UT or {}

local function _nvk3ut_is_enabled(key)
  return (Nvk3UT and Nvk3UT.sv and Nvk3UT.sv.features and Nvk3UT.sv.features[key]) and true or false
end

local function getTodoModule()
    return Nvk3UT and Nvk3UT.TodoData
end

local U = Nvk3UT and Nvk3UT.Utils

local NVK3_TODO = 84002
local TODO_LOOKUP_KEY = "NVK3UT_TODO_ROOT"
local todoProvide_lastTs = 0
local todoProvide_lastCount = 0

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

local function sanitizePlainName(name)
  if U and U.StripLeadingIconTag then
    name = U.StripLeadingIconTag(name)
  end
  return name
end

-- Add one 'To-Do-Liste' header with subcategories for each basegame top category

local function _todoCollectOpenSummary(topId)
  local Todo = getTodoModule()
  if not topId or not Todo or type(Todo.ListOpenForTop) ~= "function" then
    return 0, 0
  end

  local ok, ids = pcall(Todo.ListOpenForTop, topId, false)
  if not ok or type(ids) ~= "table" then
    return 0, 0
  end

  local num = #ids
  local points = 0
  for index = 1, num do
    local id = ids[index]
    local infoOk, _name, _desc, score = pcall(GetAchievementInfo, id)
    if infoOk then
      points = points + (score or 0)
    end
  end

  return num, points
end

local function _formatTodoTooltipLine(data, points, iconTag)
  local name = data and (data.name or data.text)
  if not name and data and data.categoryData then
    name = data.categoryData.name or data.categoryData.text
  end
  local label = zo_strformat("<<1>>", name or "")
  local prefix = iconTag or ""
  if prefix ~= "" then
    return string.format("%s%s - %s", prefix, label, ZO_CommaDelimitNumber(points or 0))
  end
  return string.format("%s - %s", label, ZO_CommaDelimitNumber(points or 0))
end

local function _updateTodoTooltip(ach)
  if not ach then
    return
  end
  local parentNode = ach._nvkTodoNode
  local children = ach._nvkTodoChildren
  if not parentNode or not parentNode.GetData then
    return
  end

  local parentData = parentNode:GetData()
  if not parentData then
    return
  end
  parentData.nvkSummaryTooltipText = nil

  local lines = {}
  local orderedChildren = {}
  if parentNode.GetChildren then
    local actualChildren = parentNode:GetChildren()
    if type(actualChildren) == "table" then
      for idx = 1, #actualChildren do
        orderedChildren[#orderedChildren + 1] = actualChildren[idx]
      end
    end
  end
  if #orderedChildren == 0 and type(children) == "table" then
    for idx = 1, #children do
      orderedChildren[#orderedChildren + 1] = children[idx]
    end
  end
  ach._nvkTodoChildren = orderedChildren

  for idx = 1, #orderedChildren do
    local node = orderedChildren[idx]
    local data = node and node.GetData and node:GetData()
    if data and (data.nvkTodoTopId or data.subcategoryIndex or data.categoryIndex) then
      local topId = data.nvkTodoTopId or data.subcategoryIndex or data.categoryIndex
      data.nvkTodoTopId = topId
      local count, points = _todoCollectOpenSummary(topId)
      if count > 0 then
        local iconTag = (U and U.GetAchievementCategoryIconTag and U.GetAchievementCategoryIconTag(topId)) or ""
        local line = _formatTodoTooltipLine(data, points, iconTag)
        data.isNvkTodo = true
        data.nvkTodoOpenCount = count
        data.nvkTodoOpenPoints = points
        data.nvkSummaryTooltipText = line
        lines[#lines + 1] = line
      else
        data.nvkSummaryTooltipText = nil
      end
    elseif data then
      data.nvkSummaryTooltipText = nil
    end
  end

  parentData.isNvkTodo = true
  if #lines > 0 then
    parentData.nvkSummaryTooltipText = table.concat(lines, "\n")
  end
end

local function AddTodoCategory(AchClass)
  local orgAddTopLevelCategory = AchClass.AddTopLevelCategory
  function AchClass:AddTopLevelCategory(...)
    local result = orgAddTopLevelCategory(self, ...)
    if not _nvk3ut_is_enabled("todo") then
      return result
    end

    local lookup, tree = self.nodeLookupData, self.categoryTree
    if not (lookup and tree) then
      return result
    end

    if lookup[TODO_LOOKUP_KEY] then
      local node = lookup[TODO_LOOKUP_KEY]
      if node and not self._nvkTodoNode then
        self._nvkTodoNode = node
      end
      return result
    end

    local nodeTemplate = "ZO_IconHeader"
    local subTemplate = "ZO_TreeLabelSubCategory"
    local label = (GetString and GetString(SI_NVK3UT_JOURNAL_CATEGORY_TODO)) or "To-Do-Liste"

    local parentNode = self:AddCategory(
      lookup,
      tree,
      nodeTemplate,
      nil,
      NVK3_TODO,
      label,
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

    lookup[TODO_LOOKUP_KEY] = parentNode
    self._nvkTodoNode = parentNode
    self._nvkTodoChildren = {}
    local _row = parentNode.GetData and parentNode:GetData()
    if _row then
      _row.isNvkTodo = true
      _row.nvkSummaryTooltipText = nil
      _row.nvkPlainName = _row.nvkPlainName or sanitizePlainName(label)
    end

    local Todo = getTodoModule()
    local numTop = GetNumAchievementCategories and GetNumAchievementCategories() or 0
    for top = 1, numTop do
      local ok, topName, nSub, nAch = pcall(GetAchievementCategoryInfo, top)
      if ok and ((nSub and nSub > 0) or (nAch and nAch > 0)) then
        local openCount, openPoints = 0, 0
        if Todo and Todo.ListOpenForTop then
          openCount, openPoints = _todoCollectOpenSummary(top)
        end
        if openCount > 0 then
          local node = self:AddCategory(lookup, tree, subTemplate, parentNode, top, topName, true)
          if node then
            self._nvkTodoChildren[#self._nvkTodoChildren + 1] = node
            local data = node.GetData and node:GetData()
            if data then
              data.isNvkTodo = true
              data.nvkTodoOpenCount = openCount
              data.nvkTodoOpenPoints = openPoints
              data.nvkTodoTopId = top
              data.nvkSummaryTooltipText = nil
              data.nvkPlainName = data.nvkPlainName or sanitizePlainName(topName)
            end
          end
        end
      end
    end

    _updateTodoTooltip(self)

    if self.refreshGroups then
      self.refreshGroups:RefreshAll("FullUpdate")
    end
    return result
  end
end

local function OverrideOnCategorySelected(AchClass)
  local org = AchClass.OnCategorySelected
  function AchClass.OnCategorySelected(...)
    if not _nvk3ut_is_enabled("todo") then
      return org(...)
    end
    local self, data, saveExpanded = ...
    if _nvk3ut_is_enabled("todo") and data and data.categoryIndex == NVK3_TODO then
      self:HideSummary()
      self:UpdateCategoryLabels(data, true, false)
      _updateTodoTooltip(self)
    else
      return org(...)
    end
  end
end

local function OverrideGetCategoryInfoFromData(AchClass)
  local org = AchClass.GetCategoryInfoFromData
  function AchClass.GetCategoryInfoFromData(...)
    if not _nvk3ut_is_enabled("todo") then
      return org(...)
    end
    local self, data, parentData = ...
    if _nvk3ut_is_enabled("todo") and data and data.categoryIndex == NVK3_TODO then
      local Todo = getTodoModule()
      if not (Todo and Todo.ListOpenForTop and Todo.ListAllOpen) then
        return org(...)
      end
      local ids
      if data.subcategoryIndex then
        ids = Todo.ListOpenForTop(data.subcategoryIndex, true)
      else
        ids = Todo.ListAllOpen(0, true)
      end
      local num, pts = #ids, 0
      for i = 1, num do
        local _, _, _, p = GetAchievementInfo(ids[i])
        pts = pts + (p or 0)
      end
      return num, pts, 0, 0, 0, 0
    end
    return org(...)
  end
end

local function Override_ZO_GetAchievementIds()
  local base = ZO_GetAchievementIds
  function ZO_GetAchievementIds(categoryIndex, subcategoryIndex, numAchievements, considerSearchResults)
    if categoryIndex == NVK3_TODO then
      local Todo = getTodoModule()
      if not (Todo and Todo.ListOpenForTop and Todo.ListAllOpen) then
        return base(categoryIndex, subcategoryIndex, numAchievements, considerSearchResults)
      end
      if subcategoryIndex then
        local __res = Todo.ListOpenForTop(subcategoryIndex, considerSearchResults)
        local utils = (Nvk3UT and Nvk3UT.Utils) or Nvk3UT_Utils
        local __now = (utils and utils.now and utils.now() or 0)
        if
          isDebugEnabled()
          and ((__now - todoProvide_lastTs) > 0.5 or #__res ~= todoProvide_lastCount)
        then
          todoProvide_lastTs = __now
          todoProvide_lastCount = #__res
          debugLog(
            "[Nvk3UT][ToDo][Provide] list data={count:%d, searchFiltered:%s}",
            #__res,
            tostring(considerSearchResults and true or false)
          )
        end
        return __res
      else
        local __res = Todo.ListAllOpen(0, considerSearchResults)
        local utils = (Nvk3UT and Nvk3UT.Utils) or Nvk3UT_Utils
        local __now = (utils and utils.now and utils.now() or 0)
        if
          isDebugEnabled()
          and ((__now - todoProvide_lastTs) > 0.5 or #__res ~= todoProvide_lastCount)
        then
          todoProvide_lastTs = __now
          todoProvide_lastCount = #__res
          debugLog(
            "[Nvk3UT][ToDo][Provide] list data={count:%d, searchFiltered:%s}",
            #__res,
            tostring(considerSearchResults and true or false)
          )
        end
        return __res
      end
    end
    return base(categoryIndex, subcategoryIndex, numAchievements, considerSearchResults)
  end
end

local function OverrideOnAchievementUpdated(AchClass)
  local org = AchClass.OnAchievementUpdated
  function AchClass.OnAchievementUpdated(...)
    local self, id = ...
    local data = self.categoryTree:GetSelectedData()
    if _nvk3ut_is_enabled("todo") and data and data.categoryIndex == NVK3_TODO then
      self:UpdateCategoryLabels(data, true, false)
      _updateTodoTooltip(self)
    else
      return org(...)
    end
  end
end

function Nvk3UT.EnableTodoCategory()
  local AchClass = getmetatable(ACHIEVEMENTS).__index
  AddTodoCategory(AchClass)
  OverrideOnCategorySelected(AchClass)
  OverrideGetCategoryInfoFromData(AchClass)
  Override_ZO_GetAchievementIds()
  OverrideOnAchievementUpdated(AchClass)
end
