local LSD

local GroupSetTracker = GroupSetTracker
GroupSetTracker.GROUP_SETS = {}

function GroupSetTracker.GetGroupSets()
    LSD = LibSetDetection
    if not LSD then
        d("|cFF4500[DebuffTracker] Error: LibSetDetection is STILL not found!|r")
        return {}
    end

    GroupSetTracker.GROUP_SETS = {}

    local availableUnitTags = LSD.GetAvailableUnitTags()
    for _, unitTag in ipairs(availableUnitTags) do
		if unitTag ~= "player" then
			local setData = LSD.GetUnitSetData(unitTag)
			if setData and next(setData) then
				GROUP_SETS[unitTag] = {}
				for setId, data in pairs(setData) do
					GROUP_SETS[unitTag][setId] = {
						activeType = data.activeType,
						numEquip = {
							body = data.numEquip.body or 0,
							front = data.numEquip.front or 0,
							back = data.numEquip.back or 0
						},
						setName = LSD.GetSetName(setId),
						maxEquip = data.maxEquip
					}
				end
			end
		end
    end

    return GroupSetTracker.GROUP_SETS
end

function GroupSetTracker.OnDataUpdate(unitTag, localPlayer, numEquipData, activeData)
    if not LSD then LSD = LibSetDetection end
    if not unitTag or unitTag == "" then return end
    GroupSetTracker.GROUP_SETS[unitTag] = {}
    for setId, _ in pairs(activeData) do
        local numBody, numFront, numBack = LSD.GetUnitSetNumEquip(unitTag, setId)
        GroupSetTracker.GROUP_SETS[unitTag][setId] = {
            activeType = LSD.GetUnitSetActiveType(unitTag, setId),
            numEquip = {
                body = numBody,
                front = numFront,
                back = numBack
            },
            setName = LSD.GetSetName(setId),
            maxEquip = LSD.GetSetMaxEquip(setId)
        }
    end
end

local function InitializeGroupSetTracker()
    EVENT_MANAGER:UnregisterForEvent("GroupSetTracker_Initialized", EVENT_ADD_ON_LOADED)
    LSD = LibSetDetection
    if not LSD then
        d("|cFF4500[DebuffTracker] Error: LibSetDetection is STILL missing!|r")
        return
    end

    LSD.RegisterEvent(LSD_EVENT_DATA_UPDATE, "GroupSetTracker_Update", GroupSetTracker.OnDataUpdate, LSD_UNIT_TYPE_GROUP)
    GroupSetTracker.GetGroupSets()
end

EVENT_MANAGER:RegisterForEvent("GroupSetTracker_Initialized", EVENT_ADD_ON_LOADED, function(_, addonName)
    if addonName == "DebuffTracker" then
        zo_callLater(InitializeGroupSetTracker, 1000)
    end
end)

return GroupSetTracker
