local ItemConditionAlert = {}
ItemConditionAlert = _G["ItemConditionAlert"]
ItemConditionAlert.frwordlib = {}

ItemConditionAlert.frwordlib = ZO_Object:Subclass()

function ItemConditionAlert.frwordlib:New( ... )
    local result = ZO_Object.New( self )
    result:Initialize( ... )
    return result
end

function ItemConditionAlert.frwordlib:Initialize()

  self.valid = false --TODO: Translate all variables to French then set this value to "true" to enable French translation
  
  
end
