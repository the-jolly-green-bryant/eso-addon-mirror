local lib = ZO_ObjectPool:Subclass()


--self.pinManagers[pinType]:ReleaseObject(lookup[pinTag])
--local pin, pinKey = self.pinManagers[pinType]:AcquireObject()
function lib:New()
    local factory = function(pool) 
      --return lib:GetUnusedPin(layout) or QP_MapPin:New(layout) 
    end
    
    local reset = function(pin)
      --pin:ClearData()
      --pin.m_Control:SetHidden(true)
    end
    
    local pinManager = ZO_ObjectPool.New(self, factory, reset)
    --pinManager.m_Layout = layout
    --pinManager:UpdateSize()
    return pinManager
end

DEGLLore_WorldMapPins = lib