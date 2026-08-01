local LIB = "Always White"
local white = MERLINS_REZHELPER.Colors[LIB]

if not white then
    
    white = MERLINS_REZHELPER.Colors:Register(LIB)
    
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