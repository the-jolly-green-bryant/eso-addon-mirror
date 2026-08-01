LibExoYsUtilities = LibExoYsUtilities or {} 

local LibExoY = LibExoYsUtilities 
local EM = GetEventManager()  


--[[ ----------- ]]
--[[ -- Group -- ]]
--[[ ----------- ]]

-- how is it with companions of other players in group? 
-- GetNumCompanionsInGroup() 

local function GetGroupMemberListDefault()
    return { TagAsKey = {}, IdAsKey = {} } 
end

local GroupMemberList = GetGroupMemberListDefault()

local function IdentifyGroupMember(event, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)
    if changeType == EFFECT_RESULT_GAINED then 
        GroupMemberList.TagAsKey[unitTag] = unitId
        GroupMemberList.IdAsKey[unitId] = unitTag 
    end 
end 

--[[ Exposed Functions for GroupMemberList ]]

function LibExoY.GetUnitIdByTag( tag ) 
    return GroupMemberList.TagAsKey[tag] 
end 


function LibExoY.GetUnitTagById( id ) 
    return GroupMemberList.IdAsKey[id]
end


--[[ ---------------- ]]
--[[ -- Initialize -- ]]
--[[ ---------------- ]]

local function Initialize()
    
    --- GroupMember
    LibExoY.RegisterCombatStart( function() GroupMemberList = GetGroupMemberListDefault() end)
    EM:RegisterForEvent(LibExoY.name.."Unit_Groupmember", EVENT_EFFECT_CHANGED, IdentifyGroupMember )
    EM:AddFilterForEvent(LibExoY.name.."Unit_Groupmember", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")
    
end
  
LibExoY.Units_InitFunc = Initialize
  
  