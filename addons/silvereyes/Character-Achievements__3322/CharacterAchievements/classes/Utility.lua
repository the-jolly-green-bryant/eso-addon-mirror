--[[ 
    ===================================
            UTILITY FUNCTIONS
    ===================================
  ]]
  
local addon = CharacterAchievements
local debug = false

-- STATIC CLASS
addon.Utility = ZO_Object:Subclass()

--[[ Outputs formatted message to chat window if debugging is turned on ]]
function addon.Utility.Debug(output, force)
    if not force and not addon.debugMode then
        return
    end
    if addon.chat then
        addon.chat.Print(output)
    else
        d(output)
    end
end