local L = CookeryWizLanguage.language

CW_QUALITY_DATA_TYPE = 3

local callbackRecipeKey = "recipes"

CookeryWizQualitySelector = {}
CookeryWizQualitySelector.name = "CookeryWizQualitySelector"
CookeryWizQualitySelector.countDownResetAmount = 4
CookeryWizQualitySelector.countDown = 4

-- purple, blue, green
CookeryWizQualitySelector.qualityTable = {
  {ITEM_QUALITY_MAGIC},
  {ITEM_QUALITY_ARCANE, ITEM_QUALITY_MAGIC},
  {ITEM_QUALITY_ARTIFACT, ITEM_QUALITY_ARCANE, ITEM_QUALITY_MAGIC},
  {ITEM_QUALITY_ARCANE},
  {ITEM_QUALITY_ARTIFACT, ITEM_QUALITY_ARCANE},
  {ITEM_QUALITY_ARTIFACT}, 
  {ITEM_QUALITY_LEGENDARY}  
}

CookeryWizQualitySelector.traceEnabled = false

local function trace(msg)
  if CookeryWizQualitySelector.traceEnabled then
    CookeryWizUtils:Trace(msg)
  end
end

---------------------------------------------------------------------
-- Function: new
--
-- This function is called to construct a new instance
---------------------------------------------------------------------
function CookeryWizQualitySelector:new()
  local o = {}
  setmetatable(o, self)
  self.__index = self
  return o  
end

---------------------------------------------------------------------
-- Function: Initialise
--
-- This function is called to initialise and setup the quality
-- selector object
---------------------------------------------------------------------
function CookeryWizQualitySelector:Initialise(callback, qualityListControl, selectedQualityControl, qualityDownButtonControl, qualityTable)
  self.callback = callback
  self:InitialiseQualitySelectedButton(selectedQualityControl)

  -- and create one for the linked control
  self.linkedQuality = CookeryWizQuality:new(nil)  
  self.linkedQuality:SetRowControl(self.selectedQualityControl)
    
  self:InitialiseQualityDownButton(qualityDownButtonControl)
  self:InitialiseQualityScrollList(qualityListControl)
  
  self.qualityTable = qualityTable  
  
end

function CookeryWizQualitySelector:InitialiseQualityDownButton(control)
  self.qualityDownButtonControl = control  
  
  control:SetHandler("OnClicked", function(control)
      trace("clicked")
      self:ShowSelector(control)
    end)
end

function CookeryWizQualitySelector:ShowSelector(control)
  self.qualityScrollList:ClearAnchors()
  local listHeight = self.qualityScrollList:GetHeight()
  local controlBottom = control:GetBottom()
  local parentHeight = GuiRoot:GetHeight()
  local left = -5
  local top = 12
  local heightDiff = parentHeight - controlBottom
  if heightDiff < listHeight then
    top = top - (listHeight - heightDiff) + 20
  end
  self.qualityScrollList:SetAnchor(TOPRIGHT, control, BOTTOMRIGHT, left, top)
  self.qualityScrollList:SetHidden(false)
end

function CookeryWizQualitySelector:InitialiseQualityScrollList(control)
  local wrapper = CookeryWizScrollList:new(control)
  wrapper:Initialise(self, control, CW_QUALITY_DATA_TYPE)
  self.qualityScrollList = control
  self.qualityScrollListWrapper = wrapper
  
  control:SetHandler("OnShow", function(control)
      --trace("OnShow")
      self:OnShow(control)
    end)
  control:SetHandler("OnHide", function(control)
      --trace("OnShow")
      self:OnHide(control)
    end)   
end

local function getQualityText(data)
  if not data then
    trace("No data item associated with quality. None selected?")
    return ""
  end  
  
  local types = {}
  local string = nil
  local orfunc = L[CWL_OR_FUNCTION]
  
  for i = #data, 1, -1 do
    if not string then
      string = GetString("SI_ITEMQUALITY", data[i])
    else
      string = orfunc(string, GetString("SI_ITEMQUALITY", data[i]))
    end
  end

  return string
end

function CookeryWizQualitySelector:InitialiseQualitySelectedButton(control)
  self.selectedQualityControl = control
  
  control:SetHandler("OnMouseEnter", function(control)
      local selectedData = self:GetSelectedQuality()
      local string = getQualityText(selectedData)
      ZO_Tooltips_ShowTextTooltip(control, TOP, string)      
    end)
  control:SetHandler("OnMouseExit", function(control)
        ZO_Tooltips_HideTextTooltip() 
    end)   
end


-- Show the tooltip for the control
function CookeryWizQualitySelector:ShowQualityToolTip(control, state)
  local data = ZO_ScrollList_GetData(control) 

  -- hmm nothing selected?
  if not data then
    trace("No data item associated with quality. None selected?")
    return
  end
  if state then
    local string = getQualityText(data:GetQualityEntry())

    ZO_Tooltips_ShowTextTooltip(control, TOP, string)
  else
    ZO_Tooltips_HideTextTooltip() 
  end
end  


function CookeryWizQualitySelector:SetHighlight(control, state)
  local highlightControl = control:GetNamedChild("Highlight")
  highlightControl:SetHidden(not state)
end

function CookeryWizQualitySelector:OnMouseUp(rowControl)

  local entry = rowControl.entry
  if not entry then
    trace("Scrollist no entry")
    return
  end
  
  local scrollList = rowControl:GetParent():GetParent()
  if not scrollList then
    trace("Scrollist not set")
    return
  end
  
  -- click event for them
  local callback = scrollList.selectCallback
  if not callback then
    trace("Scrollist]"..scrollList:GetName().."] callback not set")
    return
  end
  
  if scrollList.selectCallback.OnScrollListSelect then
    scrollList.selectCallback:OnScrollListSelect(scrollList, entry)
  end

end

function CookeryWizQualitySelector:ActionLayer(eventCode, layerIndex, activeLayerIndex)
  trace("Action layer changed")
  self.qualityScrollList:SetHidden(true)
end

function CookeryWizQualitySelector:OnShow(control)
  trace("OnShow")
  self.captureEnabled = true
  self.countDown = self.countDownResetAmount
  self:CaptureTimeEvent()
  EVENT_MANAGER:RegisterForEvent(self.name, EVENT_ACTION_LAYER_POPPED, function(...)
      self:ActionLayer(...)
      end)
  EVENT_MANAGER:RegisterForEvent(self.name, EVENT_ACTION_LAYER_PUSHED, function(...)
      self:ActionLayer(...)
      end)
end

function CookeryWizQualitySelector:OnHide(control)

  trace("OnHide")
  self.captureEnabled = false
  EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_ACTION_LAYER_POPPED)
  EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_ACTION_LAYER_PUSHED)

end

function CookeryWizQualitySelector:CaptureTimeEvent()

  if self.captureEnabled then

    local control = moc()
    
    local controlParent
    local controlGrandParent
    
    if control then
      controlParent = control:GetParent()
      if controlParent then
        controlGrandParent = controlParent:GetParent()
      end
    end
    
    if control == self.qualityScrollList or controlParent == self.qualityScrollList or controlGrandParent == self.qualityScrollList then
      self.countDown =  self.countDownResetAmount
    end
    
    if self.countDown == 0 then
      self.qualityScrollList:SetHidden(true)
    else
      zo_callLater(function()
          self:CaptureTimeEvent()
          end, 500)
      self.countDown = self.countDown -1 
    end    

  end
end

function CookeryWizQualitySelector:GetSelectedQuality()
  return self.linkedQuality:GetQualityEntry()
  --return ZO_ScrollList_GetSelectedData(self.qualityScrollControl)
end

---------------------------------------------------------------------
-- Function: SetQualityEntry
--
-- This function sets the quality entry
---------------------------------------------------------------------
function CookeryWizQualitySelector:SetSelectedQuality(qualityEntry)
  -- set the linked quality
  self.linkedQuality:SetQualityEntry(qualityEntry)
end

  
---------------------------------------------------------------------
-- Function: Enumerate
--
-- This function is called to enumerate the qualities calling a
-- custom function
---------------------------------------------------------------------
function CookeryWizQualitySelector:Enumerate(fn)
  if not fn then
    trace("No function passed to Enumerate")
    return
  end
  for key, entry in pairs(self.qualityTable) do
    fn(entry)
  end   
end

---------------------------------------------------------------------
-- Quality scroll list specific Routines
---------------------------------------------------------------------

CookeryWizQualitySelector.ingredientToolTip = nil
CookeryWizQualitySelector.qualityScrollList = nil
CookeryWizQualitySelector.qualityScrollListWrapper = nil


---------------------------------------------------------------------
-- Function: RefreshScrollList
--
-- This function is called to refresh the displayed content of the
-- quality list
---------------------------------------------------------------------
function CookeryWizQualitySelector:RefreshScrollList()
  if self.qualityScrollListWrapper then
    self.qualityScrollListWrapper:RefreshVisible()
  end
end

---------------------------------------------------------------------
-- Function: OnSortEntries
--
-- This function is called when the scrollist wants to sort the
-- data
---------------------------------------------------------------------
function CookeryWizQualitySelector:OnSortEntries(key, scrollData)
  local function SortNameAsc(entryA, entryB)
    --return entryA.data.name < entryB.data.name
    return false
  end 
  
  table.sort(scrollData, SortNameAsc) 
  self.qualityEntries = scrollData  
end

CookeryWizQualitySelector.qualityData = nil

---------------------------------------------------------------------
-- Function: PopulateQualityEntries
--
-- This function populates the scroll data
---------------------------------------------------------------------
function CookeryWizQualitySelector:PopulateQualityEntries()
  if self.qualityScrollListWrapper then
    self.qualityData = {}
    self:Enumerate(function(qualityEntry)
        local quality = CookeryWizQuality:new(qualityEntry)
        self.qualityData[#self.qualityData + 1] = quality
      end)

    
    self.qualityScrollListWrapper:Populate(false)
  end  
end

---------------------------------------------------------------------
-- Function: OnFetchEntries
--
-- This function is called when the scrollist 
-- needs the items to display
---------------------------------------------------------------------
function CookeryWizQualitySelector:OnFetchEntries(key)
  return self.qualityData
end

---------------------------------------------------------------------
-- Function: OnFetchDataType
--
-- This function is called when the scrollist 
-- needs the datatype details
---------------------------------------------------------------------
function CookeryWizQualitySelector:OnFetchDataType(key)
  if key == CW_QUALITY_DATA_TYPE then
    return CW_QUALITY_DATA_TYPE, "QualityRowTemplate", 24
  end
end

---------------------------------------------------------------------
-- Function: OnFetchCategoryDataType
--
-- This function is called when the scrollist 
-- needs the datatype for categories
-- We are not using categories for quality
---------------------------------------------------------------------
function CookeryWizQualitySelector:OnFetchCategoryDataType(key)

end