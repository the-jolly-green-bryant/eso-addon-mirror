-- ActionDurationReminder Integration for DovahMova
-- Fixes nil concatenation error by patching string concatenation operator
--
-- BUG: Models.lua:899 tries to do: reason = reason .. 'text'
-- But reason is nil because optEffectOf returns only 1 value
-- SOLUTION: Make string .. nil return "" .. 'text' instead of crashing

local DovahMova_ActionDurationReminderIntegration = {}
DovahMova_ActionDurationReminderIntegration.name = "ActionDurationReminderUA"
DovahMova_ActionDurationReminderIntegration.isInitialized = false

function DovahMova_ActionDurationReminderIntegration:Initialize()
    self:ApplyPatches()
    return true
end

function DovahMova_ActionDurationReminderIntegration:ApplyPatches()
    -- Get the string metatable
    local stringmt = getmetatable("")
    
    if not stringmt then
        return -- Cannot patch without string metatable
    end
    
    -- Store the original __concat operator
    local original_concat = stringmt.__concat
    
    -- Create a safe concat that handles nil
    stringmt.__concat = function(a, b)
        -- If either operand is nil, convert to empty string
        if a == nil then a = "" end
        if b == nil then b = "" end
        
        -- Call original concat
        if original_concat then
            return original_concat(a, b)
        else
            -- Fallback to default behavior
            return tostring(a) .. tostring(b)
        end
    end
    
    self.isInitialized = true
end

function DovahMova_ActionDurationReminderIntegration:GetInfo()
    return {
        name = self.name,
        initialized = self.isInitialized,
        compatible = true,
        message = "Патч string concatenation для захисту від nil"
    }
end

-- Register with DovahMova
if DovahMova and DovahMova.RegisterIntegration then
    DovahMova:RegisterIntegration("ActionDurationReminder", DovahMova_ActionDurationReminderIntegration)
end

-- Initialize immediately (before ADR loads)
DovahMova_ActionDurationReminderIntegration:Initialize()

_G["DovahMova_ActionDurationReminderIntegration"] = DovahMova_ActionDurationReminderIntegration
