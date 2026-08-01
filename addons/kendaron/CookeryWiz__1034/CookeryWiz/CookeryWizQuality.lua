
CookeryWizQuality = {}


function CookeryWizQuality:new(qualityEntry)
  o = {}
  o.qualityEntry = qualityEntry
  setmetatable(o, self)
  self.__index = self      
  return o
end

---------------------------------------------------------------------
-- Function: GetDataType
--
-- This function returns the scroll list template data type
---------------------------------------------------------------------
function CookeryWizQuality:GetDataType()
  return CW_QUALITY_DATA_TYPE
end

---------------------------------------------------------------------
-- Function: GetQualityEntry
--
-- This function returns the quality entry
---------------------------------------------------------------------
function CookeryWizQuality:GetQualityEntry()
  return self.qualityEntry
end

---------------------------------------------------------------------
-- Function: SetQualityEntry
--
-- This function sets the quality entry
---------------------------------------------------------------------
function CookeryWizQuality:SetQualityEntry(qualityEntry)
  self.qualityEntry = qualityEntry

  self:UpdateRowControlData()

end

---------------------------------------------------------------------
-- Quality scroll list specific routines
---------------------------------------------------------------------

CookeryWizQuality.rowControl = nil

CookeryWizQuality.controls = nil

---------------------------------------------------------------------
-- Function: SetRowControl
--
-- This function sets the row control associated with this object
---------------------------------------------------------------------
function CookeryWizQuality:SetRowControl(rowControl)
  self.rowControl = rowControl
  if rowControl then
    local controls = {}
    controls[#controls + 1] = rowControl:GetNamedChild("Right") 
    controls[#controls + 1] = rowControl:GetNamedChild("Middle") 
    controls[#controls + 1] = rowControl:GetNamedChild("Left")    
    self.controls = controls
    self:UpdateRowControlData()
  else

  end
end

---------------------------------------------------------------------
-- Function: UpdateRowControlData
--
-- This function updates the data in the row control associated with this object
---------------------------------------------------------------------
function CookeryWizQuality:UpdateRowControlData()
  if self.rowControl and self.qualityEntry then
    local rowControl  = self.rowControl

    local controls = self.controls
    -- purple, blue, green
    local controlCount = #controls
    for i = 1, controlCount do
        local quality = self.qualityEntry[i]
        local control = controls[i]
        if quality then
          local backDropControl = control:GetNamedChild("BD")
          backDropControl:SetCenterColor(GetInterfaceColor(INTERFACE_COLOR_TYPE_ITEM_QUALITY_COLORS, quality))
          control:SetHidden(false)
        else
          control:SetHidden(true)
        end
    end  
  else
    d("No rowcontrol")
  end
end

