local LIB = "Satnav"
local satnav = EXT_GROUPLEADER.Modes[LIB]
local arrow, right, ui;

if not satnav then
   
    satnav = EXT_GROUPLEADER.Modes:Register(LIB)
    
    function satnav:Init()
        
        ui = EXT_GROUPLEADER.UI
        arrow = ui:RequestTextureFrames({
            { Texture = "satnav/up.dds", Movable = true }
        })
        arrow:SetAnchor(TOP, BOTTOM, 0, 0)
        
    end
    
    function satnav:Unit()
        
        arrow = nil
        
    end
    
    function satnav:Update(state)
        
        if state.Hidden then
            arrow:SetAlpha(0)
            return
        end
        
        arrow:SetTextureRotation((math.pi * 2) - state.Angle)
        arrow:SetDimensions(state.Size)
        arrow:SetColor(state.Color)
        arrow:SetAlpha(state.Alpha)
        
    end
    
end