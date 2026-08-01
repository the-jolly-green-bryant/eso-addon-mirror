local L = CookeryWizLanguage.language

CookeryWizScrollList = {}
CookeryWizScrollList.scrollList = nil
CookeryWizScrollList.callback = nil
CookeryWizScrollList.categoriesEnabled = false
CookeryWizScrollList.key = nil
CookeryWizScrollList.dataTypeId = nil
CookeryWizScrollList.categoryDataTypeId = nil

CookeryWizScrollList.traceEnabled = false

local function trace(msg)
    if CookeryWizScrollList.traceEnabled then
      d(GetTimeString()..":"..msg)
    end
end

---------------------------------------------------------------------
-- Main CookeryWizScrollList functions
---------------------------------------------------------------------

---------------------------------------------------------------------
-- Function: new
--
-- This function is called to construct a new instance
---------------------------------------------------------------------
function CookeryWizScrollList:new()
  local o = {}  
  setmetatable(o, self)
  self.__index = self
  return o  
end

---------------------------------------------------------------------
-- Main CookeryWizScrollList functions
---------------------------------------------------------------------

---------------------------------------------------------------------
-- Function: OnExpandButtonInitialized
--
-- This function is called when the GUI expand control
-- is intialised
---------------------------------------------------------------------
function CookeryWizScrollList:OnExpandButtonInitialized(control)

  control:SetHandler("OnMouseEnter", function()
      ZO_Tooltips_ShowTextTooltip(control, TOP, L[CWL_BUTTON_TOOLTIP_EXPAND])      
    end)
  control:SetHandler("OnMouseExit", function()
        ZO_Tooltips_HideTextTooltip()      
    end)  
  control:SetHandler("OnClicked", function()
        self:OnExpandButtonClicked(control)
    end)
end

---------------------------------------------------------------------
-- Function: OnCollapseButtonInitialized
--
-- This function is called when the GUI collapse control
-- is intialised
---------------------------------------------------------------------
function CookeryWizScrollList:OnCollapseButtonInitialized(control)
  
  control:SetHandler("OnMouseEnter", function()
      ZO_Tooltips_ShowTextTooltip(control, TOP, L[CWL_BUTTON_TOOLTIP_COLLAPSE])
    end)
  control:SetHandler("OnMouseExit", function()
        ZO_Tooltips_HideTextTooltip()      
    end)  
  control:SetHandler("OnClicked", function()
        self:OnCollapseButtonClicked(control)
    end) 
end

---------------------------------------------------------------------
-- Function: OnExpandButtonClicked
--
-- This function is called when the GUI expand button
-- is clicked
---------------------------------------------------------------------
function CookeryWizScrollList:OnExpandButtonClicked(control)
  local rowControl = control:GetParent()
  local entry = rowControl.entry
  if not entry then
    trace("ExpandButton Missing entry")
    return
  end
  entry:SetIsCollapsed(false)
  local callback = entry:GetCallback()
  if callback and callback.OnExpand then
    callback:OnExpand(self.key, entry)
  end  
end

---------------------------------------------------------------------
-- Function: OnCollapseButtonClicked
--
-- This function is called when the GUI collapse button
-- is clicked
---------------------------------------------------------------------
function CookeryWizScrollList:OnCollapseButtonClicked(control)
  local rowControl = control:GetParent()
  local entry = rowControl.entry
  if not entry then
    trace("CollapseButton Missing entry")
    return
  end
  entry:SetIsCollapsed(true)
  local callback = entry:GetCallback()
  if callback and callback.OnCollapse then
    callback:OnCollapse(self.key, entry)
  end 
end

---------------------------------------------------------------------
-- Function: RefreshVisible
--
-- This function is called to refresh what is being shown
---------------------------------------------------------------------
function CookeryWizScrollList:RefreshVisible()
  if self.scrollList then
    ZO_ScrollList_Commit(self.scrollList)
  end
end
---------------------------------------------------------------------
-- Function: Initialise
--
-- This function is called when the GUI scroll list control is
-- initialised
---------------------------------------------------------------------
function CookeryWizScrollList:Initialise(callback, scrollList, key)
  if not callback or not scrollList or not key then
    trace("parameters cannot be nil")
    return
  end  
  
  if not callback.OnFetchDataType then
    trace("Callback for OnFetchDataType missing")
    return
  end

  self.callback = callback
  self.scrollList = scrollList
  self.key = key
  
  
  -- It is important to note that rows are reused. This is an efficient way of optimising memory usage
  -- However, the row control will have left over data and settings from the previous time it was used
  -- This means you cannot rely on defaults and must explicitly clear/set them

 	local function InitializeRow(rowControl, entry)
    -- Store the entry object with the row control so we can fetch it later at will
    entry:SetRowControl(rowControl)
    rowControl.entry = entry
  end
  
 	local function SelectedStockpileRow(rowControl, entry)
    --d("Selected")
  end
  
	local function DestroyRow(rowControl) 
    if rowControl.entry then
      rowControl.entry:SetRowControl(nil)
      rowControl.entry = nil
    end
    ZO_ObjectPool_DefaultResetControl(rowControl)
	end  
  
	local function HideRow(rowControl, entry)
    --if entry then
      --trace("Hidden row with entry")
    --else
      --trace("Hidden row")
    --end
    -- Clear the entry object with the row contol so nothing is changed via GUI events
    if rowControl.entry then
      rowControl.entry:SetRowControl(nil)
      rowControl.entry = nil
    end
	end  
  
  ZO_ScrollList_Initialize(scrollList)

  local dataTypeId, template, height = callback:OnFetchDataType(key)
  self.dataTypeId = dataTypeId
  
  ZO_ScrollList_AddDataType(scrollList, dataTypeId, template, height, InitializeRow, HideRow, nil, DestroyRow)
  
  if callback.OnFetchCategoryDataType then
    self.categoriesEnabled = true
    dataTypeId, template, height = callback:OnFetchCategoryDataType(key)
    if dataTypeId then
      self.categoryDataTypeId = dataTypeId
      ZO_ScrollList_AddDataType(scrollList, dataTypeId, template, height, InitializeRow, HideRow, nil, DestroyRow)
    end
  end
  ZO_ScrollList_EnableSelection(scrollList, "ZO_ThinListHighlight")
  ZO_ScrollList_SetAutoSelect(scrollList, false)
	ZO_ScrollList_AddResizeOnScreenResize(scrollList) 
  
end

---------------------------------------------------------------------
-- Function: Populate
--
-- This function is called when the GUI scroll list control 
-- needs to be repopulated
---------------------------------------------------------------------
function CookeryWizScrollList:Populate(selected)
  trace("Populate entries["..self.key.."]")
  
  local callback = self.callback
  local listControl = self.scrollList
  
  if not listControl then
    trace("No listControl specified")
    return
  end
  
  local entries = callback:OnFetchEntries(self.key)
  if not entries then
    trace("No scroll list entries")
    return
  end

  -- try and retain position in scroll list if already populated
  --self:SavePlayerTop()
  
	local scrollData = ZO_ScrollList_GetDataList(listControl)
	ZO_ScrollList_Clear(listControl)
  
  -- Enumerate the entries
  for key, entry in pairs(entries) do 
    local dataEntry = ZO_ScrollList_CreateDataEntry(entry:GetDataType(), entry)
    scrollData[#scrollData+1] = dataEntry 
  end

  self:Sort()
 
  if selected then
    ZO_ScrollList_SelectDataAndScrollIntoView(listControl, selected)
  end
  
end

---------------------------------------------------------------------
-- Function: Sort
--
-- This function is called to sort the entries in the scrolllist
---------------------------------------------------------------------
function CookeryWizScrollList:Sort()
  
  local callback = self.callback
  if not callback then
    trace("No callback object")
    return
  end
  
  if not callback.OnSortEntries then
    return
  end
  
  local listControl = self.scrollList
  if not listControl then
    trace("No listControl specified")
    return
  end
  
  -- sort the scroll data
  local scrollData = ZO_ScrollList_GetDataList(listControl)  
  callback:OnSortEntries(self.key, scrollData)
  
  ZO_ScrollList_Commit(listControl)   
  ZO_ScrollList_RefreshVisible(listControl)
  
end

---------------------------------------------------------------------
-- Function: Clear
--
-- This function is called to clear the entries from the scrolllist
---------------------------------------------------------------------
function CookeryWizScrollList:Clear()
  local listControl = self.scrollList
  if not listControl then
    return
  end

	ZO_ScrollList_Clear(listControl)
  ZO_ScrollList_Commit(listControl)   
  ZO_ScrollList_RefreshVisible(listControl)  
end