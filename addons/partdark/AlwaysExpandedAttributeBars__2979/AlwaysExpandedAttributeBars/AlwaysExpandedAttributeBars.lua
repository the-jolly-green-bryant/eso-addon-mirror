-- Always Expanded Attribute Bars
-- Modified version with color customization

-- Create global namespace
AEAB = AEAB or {}
AEAB.name = "AlwaysExpandedAttributeBars"

-- Use AEAB.defaults for standard ESO colors

local ApplyTemplate = ApplyTemplateToControl

-----------------------------------------------------------
-- Attribute Bars
-----------------------------------------------------------

-- Templates - only apply to player attribute bars
ApplyTemplate(ZO_PlayerAttribute, 'ALT_PlayerAttribute')

-- Override functions only for player bars, not for NPCs
local originalUnwaveringInitializeBarValues = ZO_UnitVisualizer_UnwaveringModule.InitializeBarValues
function ZO_UnitVisualizer_UnwaveringModule:InitializeBarValues(...)
   --    if self.barControls and self.barControls[1] and self.barControls[1]:GetName():find("ZO_PlayerAttribute") then
   --     return
  --  end
      return originalUnwaveringInitializeBarValues(self, ...)
end

local originalArmorDamageInitializeBarValues = ZO_UnitVisualizer_ArmorDamage.InitializeBarValues


function ZO_UnitVisualizer_ArmorDamage:InitializeBarValues(...)  
  --  if self.barControls and self.barControls[1] and self.barControls[1]:GetName():find("ZO_PlayerAttribute") then
        return
   -- end   
   -- return originalArmorDamageInitializeBarValues(self, ...)
end

-- Disable max resource change effects
function AEAB.DisableResourceChangeEffects()
    if not AEAB.savedVars or not AEAB.savedVars.disableMaxResourceChangeEffects then return end
   
   ZO_UnitVisualizer_ShrinkExpandModule.InitializeBarValues = function() return end
   end

-- Use Custom Template for Health Bar Shields - only for player
SecurePostHook(ZO_UnitVisualizer_PowerShieldModule, 'ShowOverlay', function(_, _, info) 
    -- Only apply to player shields
    local isPlayerShield = false
    if info and info.overlayControls and info.overlayControls[1] then
        local name = info.overlayControls[1]:GetName()
        if name and string.find(name, "ZO_PlayerAttribute") then
            isPlayerShield = true
        end
    end
    
    if isPlayerShield then
        -- Apply template
        ApplyTemplate(info.overlayControls[1], 'ALT_PowerShieldBar')
        ApplyTemplate(info.overlayControls[2], 'ALT_PowerShieldBar')
        
        -- Apply shield color if custom shields are enabled
        if AEAB.savedVars and AEAB.savedVars.useCustomShieldColor and AEAB.savedVars.shieldColor then
            info.overlayControls[1]:SetColor(unpack(AEAB.savedVars.shieldColor))
            info.overlayControls[2]:SetColor(unpack(AEAB.savedVars.shieldColor))
        end
        
        -- Apply custom color to the fake health bar inside shield overlay
        if AEAB.savedVars and AEAB.savedVars.useCustomHealthColor and AEAB.savedVars.healthColor then
            -- Apply to fake health bars in shield overlays
            if info.overlayControls[1].fakeHealthBar then
                info.overlayControls[1].fakeHealthBar:SetColor(unpack(AEAB.savedVars.healthColor))
            end
            if info.overlayControls[2].fakeHealthBar then
                info.overlayControls[2].fakeHealthBar:SetColor(unpack(AEAB.savedVars.healthColor))
            end
            
            -- Also apply to original health bars
            local healthBar = ZO_PlayerAttributeHealth
            if healthBar then
                local barLeft = healthBar:GetNamedChild("BarLeft")
                local barRight = healthBar:GetNamedChild("BarRight")
                if barLeft and barRight then
                    barLeft:SetColor(unpack(AEAB.savedVars.healthColor))
                    barRight:SetColor(unpack(AEAB.savedVars.healthColor))
                end
            end
        end
    end
end)

-- Add borders to attribute bars
function AEAB:AddBorders()
  local function AddBorder(control, name, r, g, b, a)
    if control then
      local border = control:GetNamedChild(name)
      if not border then
        border = WINDOW_MANAGER:CreateControl(control:GetName() .. name, control, CT_TEXTURE)
        border:SetAnchorFill()
        border:SetTexture("EsoUI/Art/Miscellaneous/glowBorder.dds")
        border:SetBlendMode(TEX_BLEND_MODE_ADD)
        border:SetDrawLevel(1)
        border:SetColor(r, g, b, a)
      end
    end
  end
  
  -- Add borders to health bar
  AddBorder(ZO_PlayerAttributeHealth:GetNamedChild("BarLeft"), "HealthBorder", 1, 0.3, 0.3, 0.3)
  AddBorder(ZO_PlayerAttributeHealth:GetNamedChild("BarRight"), "HealthBorder", 1, 0.3, 0.3, 0.3)
  
  -- Add borders to magicka bar
  AddBorder(ZO_PlayerAttributeMagicka:GetNamedChild("Bar"), "MagickaBorder", 0.3, 0.5, 1, 0.3)
  
  -- Add borders to stamina bar
  AddBorder(ZO_PlayerAttributeStamina:GetNamedChild("Bar"), "StaminaBorder", 0.5, 0.8, 0.3, 0.3)
end

-- Apply settings when UI is loaded
local function OnPlayerActivated()
  -- Wait a bit to ensure all UI elements are loaded
  zo_callLater(function()
    if AEAB.ApplySettings then
      AEAB:ApplySettings()
      AEAB:AddBorders()
    end
  end, 1000)
end

EVENT_MANAGER:RegisterForEvent(AEAB.name.."_PlayerActivated", EVENT_PLAYER_ACTIVATED, OnPlayerActivated)