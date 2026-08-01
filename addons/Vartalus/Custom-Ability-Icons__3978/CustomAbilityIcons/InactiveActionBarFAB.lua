--- @class (partial) CustomAbilityIcons
local CustomAbilityIcons = CustomAbilityIcons

local FAB = FancyActionBar

--- Retrieves the active skill style for the skill found in the specified slotIndex and applies it
--- to the corresponding slot on the inactive action bar. Will only work if FancyActionBar+ is available.
--- @param slotIndex number The index of a given skill in the action bar.
--- @param hotbarCategory number The category of the hotbar in question.
function CustomAbilityIcons.ApplySkillStyleInactiveFAB(slotIndex, hotbarCategory)
    if FAB then
        local icon = CustomAbilityIcons.GetSkillStyleIcon(slotIndex, hotbarCategory)
                     or CustomAbilityIcons.GetCustomAbilityIcon(slotIndex, hotbarCategory)
        if (icon or "") ~= "" then
            slotIndex = slotIndex + CustomAbilityIcons.SLOT_INDEX_OFFSET
            --- @diagnostic disable-next-line: param-type-mismatch
            CustomAbilityIcons.ReplaceAbilityBarIcon(slotIndex, hotbarCategory, icon)
        end
    end
end

--- Decides whether icon replacement should take place or not. The only reason not to perform it, is if we've been asked to draw
--- the icons of the inactive action bar and the inactive weapon is a destruction staff.
--- @param hotbarCategory number The category of the hotbar in question.
--- @return boolean skipIconReplacement True if CustomAbilityIcons should not perform icon replacement. False otherwise.
function CustomAbilityIcons.SkipSkillIconReplacement(hotbarCategory)
    local result = false
    local activeHotbarCategory = GetActiveHotbarCategory()
    local inactiveWeapon = nil
    if activeHotbarCategory ~= hotbarCategory then
        if hotbarCategory == HOTBAR_CATEGORY_BACKUP then
            inactiveWeapon = GetItemLinkWeaponType(GetItemLink(BAG_WORN, EQUIP_SLOT_BACKUP_MAIN, LINK_STYLE_DEFAULT))
        else
            inactiveWeapon = GetItemLinkWeaponType(GetItemLink(BAG_WORN, EQUIP_SLOT_MAIN_HAND, LINK_STYLE_DEFAULT))
        end
    end
    if inactiveWeapon == WEAPONTYPE_FIRE_STAFF
       or inactiveWeapon == WEAPONTYPE_FROST_STAFF
       or inactiveWeapon == WEAPONTYPE_LIGHTNING_STAFF then
        result = true
    end
    return result
end

--- Retrieves the inactive action bar button corresponding to the specified slotIndex, provided that
--- FancyActionBar+ is available.
--- @param slotIndex number The index of a given skill in the action bar.
--- @return any btn The inactive bar button correspondign to the specified slotIndex.
function CustomAbilityIcons.GetInactiveBarButtonFAB(slotIndex)
    if FAB and FAB.buttons
       and slotIndex >= CustomAbilityIcons.SLOT_INDEX_OFFSET + CustomAbilityIcons.MIN_INDEX
       and slotIndex <= CustomAbilityIcons.SLOT_INDEX_OFFSET + CustomAbilityIcons.MAX_INDEX
    then
        return FAB.buttons[slotIndex]
    else
        return nil
    end
end
