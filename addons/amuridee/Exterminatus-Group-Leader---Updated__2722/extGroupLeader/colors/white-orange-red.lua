local LIB = "White Orange Red"
local wor = EXT_GROUPLEADER.Colors[LIB]

if not wor then
    
    wor = EXT_GROUPLEADER.Colors:Register(LIB)
    
    function wor:Init()
        
    end
    
    function wor:Unit()
        
    end
    
    function wor:Update(state)
        
        if not state.Hidden then
            state.Color.R = 1
            state.Color.G = 1 - state.AbsoluteLinear
            state.Color.B = 1 - math.min(state.AbsoluteLinear, 0.05) * 20
        end
        
    end
    
end