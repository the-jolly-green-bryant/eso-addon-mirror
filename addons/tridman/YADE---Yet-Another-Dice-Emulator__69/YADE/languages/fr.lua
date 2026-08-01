YADE_frwordlib = ZO_Object:Subclass()

function YADE_frwordlib:New( ... )
    local result = ZO_Object.New( self )
    result:Initialize( ... )
    return result
end

function YADE_frwordlib:Initialize()

  self.THROWS_A = "lance un de a "
  self.SIDES_SCORES  = " faces et sort un "
  
end