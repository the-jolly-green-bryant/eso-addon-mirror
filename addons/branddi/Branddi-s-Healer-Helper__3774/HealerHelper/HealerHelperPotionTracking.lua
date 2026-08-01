
function HealerHelper.isPotionUsable()




    local remaining, duration, global, globalSlotType = GetSlotCooldownInfo(GetCurrentQuickslot(), HOTBAR_CATEGORY_QUICKSLOT_WHEEL)

    if duration < 5000 then -- if global is less than 5000 then we aren't on potion cooldown at the current time
        return true
    else
        if remaining == 0 then
            return true
        else
            return false
        end
    end

end
