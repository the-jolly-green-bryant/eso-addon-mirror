local LIB = "Always White"
local white = FLUFFIELS_PANICBEAMS.Colors[LIB]

if not white then
    
    white = FLUFFIELS_PANICBEAMS.Colors:Register(LIB)
    
    function white:Init()
        
    end
    
    function white:Unit()
        
    end
    
    function white:Update(state)
       
        state.Color.R = 1
        state.Color.G = 1
        state.Color.B = 1
        
    end
    
end