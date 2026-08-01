-- Beltalowda 3D Objects Parent Control
-- Simplified version of RdK's Moving3DObjects system
-- Provides a parent control for 3D render space objects

Beltalowda = Beltalowda or {}
Beltalowda.Util = Beltalowda.Util or {}
Beltalowda.Util.Objects3D = Beltalowda.Util.Objects3D or {}

local Objects3D = Beltalowda.Util.Objects3D
local ADDON_NAME = "Beltalowda3DObjects"

Objects3D.state = {}
Objects3D.state.initialized = false
Objects3D.state.parentControl = nil
Objects3D.state.registeredControls = {}

local wm = GetWindowManager()

--[[
    Initialize the 3D objects system
    Creates a parent top-level window for 3D controls
]]--
function Objects3D.Initialize()
    if Objects3D.state.initialized then
        return
    end
    
    -- Try to use XML-defined parent control first
    local xmlParent = _G["Beltalowda_LeaderBeam_Parent"]
    if xmlParent then
        Objects3D.state.parentControl = xmlParent
        Objects3D.state.parentControl:Create3DRenderSpace()
        Objects3D.state.parentControl:SetDrawTier(0)
        Objects3D.state.parentControl:SetDrawLayer(0)
        Objects3D.state.parentControl:SetDrawLevel(0)
        Objects3D.state.parentControl:SetHidden(false)
    else
        -- Fallback: Create a parent top level window for 3D objects
        Objects3D.state.parentControl = wm:CreateTopLevelWindow(ADDON_NAME .. "_Parent")
        Objects3D.state.parentControl:Create3DRenderSpace()
        Objects3D.state.parentControl:SetDrawTier(0)
        Objects3D.state.parentControl:SetDrawLayer(0)
        Objects3D.state.parentControl:SetDrawLevel(0)
        Objects3D.state.parentControl:SetHidden(false)
    end
    
    Objects3D.state.initialized = true
end

--[[
    Get the default parent control for 3D objects
]]--
function Objects3D.GetDefaultParent()
    if not Objects3D.state.initialized then
        Objects3D.Initialize()
    end
    return Objects3D.state.parentControl
end

--[[
    Register a texture control with the 3D system
    This allows the control to be managed by the parent
]]--
function Objects3D.RegisterTextureControl(control)
    if control ~= nil and control.GetType ~= nil and type(control.GetType) == "function" and control:GetType() == CT_TEXTURE then
        local found = false
        for i = 1, #Objects3D.state.registeredControls do
            if Objects3D.state.registeredControls[i] == control then
                found = true
                break
            end
        end
        
        if not found then
            -- Re-parent the control to the 3D parent (RdK does this!)
            control:SetParent(Objects3D.state.parentControl)
            table.insert(Objects3D.state.registeredControls, control)
            -- Store original draw level
            control.origDrawLevel = control:GetDrawLevel()
        end
    end
end

--[[
    Unregister a texture control from the 3D system
]]--
function Objects3D.UnregisterTextureControl(control)
    if control ~= nil and control.GetType ~= nil and type(control.GetType) == "function" and control:GetType() == CT_TEXTURE then
        for i = #Objects3D.state.registeredControls, 1, -1 do
            if Objects3D.state.registeredControls[i] == control then
                -- Restore original draw level
                if control.origDrawLevel then
                    control:SetDrawLevel(control.origDrawLevel)
                end
                table.remove(Objects3D.state.registeredControls, i)
                break
            end
        end
    end
end
