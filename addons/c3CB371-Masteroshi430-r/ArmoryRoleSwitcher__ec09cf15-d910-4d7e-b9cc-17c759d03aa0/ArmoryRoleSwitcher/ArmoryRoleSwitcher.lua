ArmoryRoleSwitcher = {}
ArmoryRoleSwitcher.name = "ArmoryRoleSwitcher"

function ArmoryRoleSwitcher.go(eventCode, result, buildIndex) 
 if not IsPlayerActivated() then return end
 if result ~= ARMORY_BUILD_RESTORE_RESULT_SUCCESS then return end
 
 local iconIndex = GetArmoryBuildIconIndex(buildIndex)
 local actualRole = GetSelectedLFGRole()
 local buildName = GetArmoryBuildName(buildIndex)
 
 if iconIndex == 1 and actualRole ~= LFG_ROLE_DPS then
        UpdateSelectedLFGRole(LFG_ROLE_DPS)
		d("[ARS] "..zo_strformat(SI_TOOLTIP_ITEM_ROLE_FORMAT, GetString(SI_LFGROLE1)).." ("..buildName..")") 
 elseif iconIndex == 2 and actualRole ~= LFG_ROLE_HEAL then
        UpdateSelectedLFGRole(LFG_ROLE_HEAL)
		d("[ARS] "..zo_strformat(SI_TOOLTIP_ITEM_ROLE_FORMAT, GetString(SI_LFGROLE4)).." ("..buildName..")") 
 elseif iconIndex == 3 and actualRole ~= LFG_ROLE_TANK then
        UpdateSelectedLFGRole(LFG_ROLE_TANK)
		d("[ARS] "..zo_strformat(SI_TOOLTIP_ITEM_ROLE_FORMAT, GetString(SI_LFGROLE2)).." ("..buildName..")") 
 end



end

EVENT_MANAGER:RegisterForEvent(ArmoryRoleSwitcher.name, EVENT_ARMORY_BUILD_RESTORE_RESPONSE, ArmoryRoleSwitcher.go)

