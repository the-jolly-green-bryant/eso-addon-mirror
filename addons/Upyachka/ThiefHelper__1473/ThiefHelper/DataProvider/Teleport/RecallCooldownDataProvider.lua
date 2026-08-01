-- Used to provide cooldown time for teleport.
RecallCooldownDataProvider = Up_DataProvider:new {
    Cooldown = 0 -- Actual cooldown time.
}

-- Overriden method Up_DataProvider:initialize().
function RecallCooldownDataProvider:initialize()
    self.Cooldown = GetRecallCooldown()
    local function updateCooldownTime()
        self.Cooldown = GetRecallCooldown()
    end

    EVENT_MANAGER:RegisterForUpdate("RecallCooldownDataProvider", 1000, updateCooldownTime) -- 1 second is enough.
end

-- Overriden method Up_DataProvider:getText(addon).
function RecallCooldownDataProvider:getText(addon)
    if self.Cooldown == 0 then
        return nil -- return nothing to avoid displaying with zero time.
    end
    -- TODO settings attributes for all parameters
    local textureString = zo_iconFormat("esoui\\art\\icons\\poi\\poi_wayshrine_complete.dds", 32, 32)
    local timeString = ZO_FormatTimeMilliseconds(self.Cooldown, TIME_FORMAT_STYLE_SHOW_LARGEST_UNIT)
    return string.format("%s %s", textureString, timeString)
end
