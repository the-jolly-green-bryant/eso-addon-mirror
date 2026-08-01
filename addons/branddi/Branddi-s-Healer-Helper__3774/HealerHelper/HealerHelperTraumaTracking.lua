function HealerHelper.VisualTraumaAdded(event, unitTag, unitAttributeVisual, statType, attributeType, powerType, value, maxValue)
	if not DoesUnitExist(unitTag) then return end
	if not ZO_Group_IsGroupUnitTag(unitTag) then return end
	--if unitTag == nil then return end

	if unitAttributeVisual == ATTRIBUTE_VISUAL_TRAUMA then
        --if HealerHelper.savedVars.debugToChat then d("add trauma for ".. unitTag .. " ".. value) end
        HealerHelper.addTrauma(unitTag)
	end

end

function HealerHelper.VisualTraumaUpdated(event, unitTag, unitAttributeVisual, statType, attributeType, powerType, oldValue, newValue, oldMaxValue, newMaxValue)
	if not DoesUnitExist(unitTag) then return end
	if not ZO_Group_IsGroupUnitTag(unitTag) then return end
	--if unitTag == nil then return end

	if unitAttributeVisual == ATTRIBUTE_VISUAL_TRAUMA then
        --if HealerHelper.savedVars.debugToChat then d("update trauma for ".. unitTag .. " ".. newValue) end
        HealerHelper.addTrauma(unitTag)
	end

end

function HealerHelper.VisualTraumaRemoved(event, unitTag, unitAttributeVisual, statType, attributeType, powerType, value, maxValue)
	if not DoesUnitExist(unitTag) then return end
	if not ZO_Group_IsGroupUnitTag(unitTag) then return end
	--if unitTag == nil then return end

	if unitAttributeVisual == ATTRIBUTE_VISUAL_TRAUMA then
        --if HealerHelper.savedVars.debugToChat then d("remove trauma for ".. unitTag .. " ".. value) end
        HealerHelper.removeTrauma(unitTag)
	end

end

local PURGE_UNIT_TAG       = 3
local PURGE_TRAUMA_ACTIVE  = 8
local PURGE_AT_NAME        = 5

function HealerHelper.addTrauma(unitTag)
    --d("addTrauma("..unitTag..")")
    if unitTag == "" then return end
    for i = 1, 12 do
        if HealerHelper.purgeMembers[i][PURGE_UNIT_TAG] == unitTag then
            HealerHelper.purgeMembers[i][PURGE_TRAUMA_ACTIVE] = true
            --d("addTrauma("..unitTag..") found")
        end
    end
end

function HealerHelper.removeTrauma(unitTag)
    --d("removeTrauma("..unitTag..")")
    if unitTag == "" then return end
    for i = 1, 12 do
        if HealerHelper.purgeMembers[i][PURGE_UNIT_TAG] == unitTag then
            HealerHelper.purgeMembers[i][PURGE_TRAUMA_ACTIVE] = false
            --d("removeTrauma("..unitTag..") found")
        end
    end
end

function HealerHelper.isTraumaActiveAndOnWho()
    if HealerHelper.savedVars.traumaEnabled == false then
        return false, ""
    end
    local found = 0
    local name = ""
    for i = 1, 12 do
        if  HealerHelper.purgeMembers[i][PURGE_TRAUMA_ACTIVE] then
            --d("trauma on "..i)

            found = found + 1
            name =  HealerHelper.purgeMembers[i][PURGE_AT_NAME]
        end
    end

    if found == 1 then
        if name ~= nil then

            name = " ".. name
            --d("trauma found with name '".. name.."'")
            return true, name
        else
            --d("trauma found with no name")
            return true, ""
        end

    elseif found > 1 then
        --d("trauma found x ".. found)
        name = " x" .. found
        return true, name
    else
        return false, ""
    end

end


HealerHelper.TraumaTrackingEnable = false

function HealerHelper.InitialiseTraumaTracking()
    if HealerHelper.TraumaTrackingEnable == false then

        EVENT_MANAGER:RegisterForEvent(HealerHelper.name.."_TraumaAdded", EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED, HealerHelper.VisualTraumaAdded)
        EVENT_MANAGER:RegisterForEvent(HealerHelper.name.."_TraumaUpdated", EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED, HealerHelper.VisualTraumaUpdated)
        EVENT_MANAGER:RegisterForEvent(HealerHelper.name.."_TraumaRemoved", EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED, HealerHelper.VisualTraumaRemoved)

        HealerHelper.TraumaTrackingEnable = true
    end
end

function HealerHelper.DeinitialiseTraumaTracking()
    if HealerHelper.TraumaTrackingEnable == true then

        EVENT_MANAGER:UnregisterForEvent(HealerHelper.name.."_TraumaAdded", EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED)
        EVENT_MANAGER:UnregisterForEvent(HealerHelper.name.."_TraumaUpdated", EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED)
        EVENT_MANAGER:UnregisterForEvent(HealerHelper.name.."_TraumaRemoved", EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED)

        HealerHelper.TraumaTrackingEnable = false
    end
end