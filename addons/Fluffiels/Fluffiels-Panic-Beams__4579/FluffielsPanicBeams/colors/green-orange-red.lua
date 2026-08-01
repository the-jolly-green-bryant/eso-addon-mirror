local LIB = "Green Orange Red"
local gor = FLUFFIELS_PANICBEAMS.Colors[LIB]

if not gor then
    
    gor = FLUFFIELS_PANICBEAMS.Colors:Register(LIB)
    
    local function Hue2Rgb(p, q, t)
        if t < 0   then t = t + 1 end
        if t > 1   then t = t - 1 end
        if t < 1/6 then return p + (q - p) * 6 * t end
        if t < 1/2 then return q end
        if t < 2/3 then return p + (q - p) * (2/3 - t) * 6 end
        return p
    end
    
    local function Hsl2Rgb(h, s, l)
        if s == 0 then return l, l, l end
    
        local q
        if l < 0.5 then q = l * (1 + s) else q = l + s - l * s end
        local p = 2 * l - q

        return Hue2Rgb(p, q, h + 1/3), Hue2Rgb(p, q, h), Hue2Rgb(p, q, h - 1/3)
    end
    
    function gor:Init()
        
    end
    
    function gor:Unit()
        
    end
    
    function gor:Update(state)
        
        if not state.Hidden then
            local h = 0.3 - (state.AbsoluteLinear * 0.3)
            state.Color.R, state.Color.G, state.Color.B = Hsl2Rgb(h, 1.0, 0.5)
        end
        
    end
    
end