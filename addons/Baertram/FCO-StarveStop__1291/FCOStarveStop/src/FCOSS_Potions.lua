if FCOStarveStop == nil then FCOStarveStop = {} end
local FCOSS = FCOStarveStop

------------------------------------------------------------------------------------------------------------
-- Potions
------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------
-- Potions check functions
------------------------------------------------------------------------------------------------------------
--Function to return the remaining cooldown of a potion
function FCOSS.getPotionCD(chatOutput)
    chatOutput = chatOutput or false
    --Use libPotionBuff
    local remain, duration = FCOSS.libPB:GetPotionSlotCooldown(false)
    --Output info to the chat?
    if chatOutput then
        d("[FCOSS] Potion cooldown - remaining: " .. tostring(remain) .. ", duration: " .. tostring(duration))
    end
    return remain, duration
end

--Check the active players buffs for a potion buff
function FCOSS.checkActiveBuffsForPotion()
    --Use libPotionBuff
    local showPotionAlert = FCOSS.libPB:IsPotionBuffActive("player")
    if showPotionAlert == nil then showPotionAlert = false end
    return showPotionAlert
end