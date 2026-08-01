YADE_enwordlib = ZO_Object:Subclass()

function YADE_enwordlib:New( ... )
    local result = ZO_Object.New( self )
    result:Initialize( ... )
    return result
end

function YADE_enwordlib:Initialize()

  self.THROWS_A = "throws a "
  self.SIDES_SCORES  = "-sided dice and scores "
  
end