-- ReticleUtils.lua: Pure functions for reticle display logic

local ReticleUtils = {}

---Extract guild name from caption like "Guild Trader (RNGezus)" -> "RNGezus"
---@param caption string
---@return string|nil
function ReticleUtils.ExtractGuildNameFromCaption(caption)
    if not caption then
        return nil
    end

    -- Match pattern "Guild Trader (GuildName)" or similar
    local guildName = caption:match("%((.+)%)")
    return guildName
end

SmartTrader.ReticleUtils = ReticleUtils
