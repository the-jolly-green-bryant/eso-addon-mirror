-- Initalize RunesVoice to use as Table to store
-- the Addon in it.
if RunesVoice == nil then RunesVoice = {} end

-- Show Debug Message
function RunesVoice:debug(level, msg)
  -- Check if debugging is enabled
  if RunesVoice.variables.saved["debug_enable"] then
  -- Check if the level debugging is enabled
    if RunesVoice.variables.saved["debug_enable_"..level] then
      -- Print out Log to Chat
      CHAT_SYSTEM:AddMessage("[RV]".."["..level.."]"..msg)
    end
  end
end