YADE_dewordlib = ZO_Object:Subclass()

function YADE_dewordlib:New( ... )
    local result = ZO_Object.New( self )
    result:Initialize( ... )
    return result
end

function YADE_dewordlib:Initialize()

  self.THROWS_A = "wirft einen "
  self.SIDES_SCORES  = "-seitigen Wuerfel und wirft eine "
  
end