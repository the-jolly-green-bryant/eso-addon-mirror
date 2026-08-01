GuardHelper = {}
local GuardHelper = GuardHelper

local GUARD_STATUS_DOWN    = 0 -- guard is not up
local GUARD_STATUS_LOST    = 1 -- guard was lost from the intended target (stays here for 10 seconds then switches to none for blinking)
local GUARD_STATUS_UP      = 2 -- guard is up
local GUARD_STATUS_UP_WRONG_TARGET = 3 -- guard is up but on the wrong person


local TARGET_STATUS_NOT_SET = 0
local TARGET_STATUS_SET = 1
local TARGET_STATUS_NOT_VALID = 2

local BLINK_TIME = 5000 -- how long we blink for in milliseconds
local BLINK_DELAY = 250 -- lenght of each blink in milliseconds

GuardHelper.shouldCastGuard = false
GuardHelper.targetStatus = TARGET_STATUS_NOT_SET


GuardHelper.guardBlocked = false

GuardHelper.guardLostTime = GetGameTimeMilliseconds()

GuardHelper.name = "GuardHelper"
GuardHelper.version = "1.0.1"

GuardHelper.accountWideDefaults = {
    accountWide = true,
}





GuardHelper.defaults = {
    offsetX = 200,
    offsetY = 200,
    overrideReticleHidden = false,
    bothBarsRequired = true,

	blinking = true,


	arrowToGuardTargetWhenGuardOff = true,
	arrowToGuardTargetWhenGuardOn = true,

	circle16mAroundGuardTarget = false,

    displayGuardedTargetAtName = true,
    displayIntendedGuardedTargetAtName = true,

    preventCastingGuardOnUnintendedTarget = false,
    preventRemovingGuardFromIntendedTarget = false,
    
    
    targetAsFirstSuccessfulGuard = true,
}

--[[
	--80923 -- Cancel Guard by range
	--80947 -- Cancel Guard, Mythic Guard by range
	--80983 -- Cancel Guard, Stalwart Guard by range
--]]

GuardHelper.blockingSkills = {
      mysticGuard = 61536,
      removeMysticGuard = 81415,
      guard = 61511,
      removeGuard = 78338,
      stalwartGuard = 61529,
      removeStalwartGuard = 81420
    }

function GuardHelper.blockGuard ()
    if GuardHelper.guardBlocked==false then

        GuardHelper.guardBlocked=true
        LibSkillBlocker.RegisterSkillBlock(GuardHelper.name, GuardHelper.blockingSkills.mysticGuard)
        LibSkillBlocker.RegisterSkillBlock(GuardHelper.name, GuardHelper.blockingSkills.removeMysticGuard)

        LibSkillBlocker.RegisterSkillBlock(GuardHelper.name, GuardHelper.blockingSkills.guard)
        LibSkillBlocker.RegisterSkillBlock(GuardHelper.name, GuardHelper.blockingSkills.removeGuard)

        LibSkillBlocker.RegisterSkillBlock(GuardHelper.name, GuardHelper.blockingSkills.stalwartGuard)
        LibSkillBlocker.RegisterSkillBlock(GuardHelper.name, GuardHelper.blockingSkills.removeStalwartGuard)
    end
end

function GuardHelper.unblockGuard ()
    if GuardHelper.guardBlocked==true then

        GuardHelper.guardBlocked=false
        LibSkillBlocker.UnregisterSkillBlock(GuardHelper.name, GuardHelper.blockingSkills.mysticGuard)
        LibSkillBlocker.UnregisterSkillBlock(GuardHelper.name, GuardHelper.blockingSkills.removeMysticGuard)

        LibSkillBlocker.UnregisterSkillBlock(GuardHelper.name, GuardHelper.blockingSkills.guard)
        LibSkillBlocker.UnregisterSkillBlock(GuardHelper.name, GuardHelper.blockingSkills.removeGuard)

        LibSkillBlocker.UnregisterSkillBlock(GuardHelper.name, GuardHelper.blockingSkills.stalwartGuard)
        LibSkillBlocker.UnregisterSkillBlock(GuardHelper.name, GuardHelper.blockingSkills.removeStalwartGuard)
    end
end

function GuardHelper.isGuardAbility(abilityId)
    return (abilityId == GuardHelper.blockingSkills.mysticGuard) or
     (abilityId == GuardHelper.blockingSkills.removeMysticGuard) or
     (abilityId == GuardHelper.blockingSkills.guard) or
     (abilityId == GuardHelper.blockingSkills.removeGuard) or
     (abilityId == GuardHelper.blockingSkills.stalwartGuard) or
     (abilityId == GuardHelper.blockingSkills.removeStalwartGuard)
end

function GuardHelper.isGuardSkillSlotted()
    local hasGuardFrontbar = false
    local hasGuardBackbar = false
    for hotbarSlot = 2, 7 do
        if GuardHelper.isGuardAbility(GetSlotBoundId(hotbarSlot, HOTBAR_CATEGORY_PRIMARY)) then
            hasGuardFrontbar = true
        end 
        if GuardHelper.isGuardAbility(GetSlotBoundId(hotbarSlot, HOTBAR_CATEGORY_BACKUP)) then
            hasGuardBackbar = true
        end
    end
    
    if GuardHelper.SV.bothBarsRequired then
        return hasGuardFrontbar and hasGuardBackbar
    else
        return hasGuardFrontbar or hasGuardBackbar
    end
end

function GuardHelper.getDisplayName(rawName)
    local name = rawName
    -- Group members
    for i = 1, GetGroupSize() do
        if GetRawUnitName("group"..i) == rawName then
            name = GetUnitDisplayName("group"..i)

        end
    end

    return name
end

GuardHelper.guardTankAtName = ""

function GuardHelper.GuardRemoveTarget()
    GuardHelper.guardTankAtName = ""
    d("GuardHelper: No guard target")
    GuardHelper.targetStatus = TARGET_STATUS_NOT_SET
    GuardHelper.status = GUARD_STATUS_DOWN
    GuardHelper.unblockGuard()
    return true
end

function GuardHelper.GuardChangeTankTarget()
    for i=1, 12 do
		local searchBy = "group"..i
		if DoesUnitExist("group"..i) then
            if GetGroupMemberSelectedRole(searchBy) == 2 then -- tank
                local atName = GetUnitDisplayName(searchBy)
                -- tank
                if (atName == GuardHelper.guardTankAtName) then
                else
                    GuardHelper.guardTankAtName = atName
                    d("GuardHelper: Guard Tank changed to:"..GuardHelper.guardTankAtName)
                    GuardHelper.targetStatus = TARGET_STATUS_SET
                    return true
                end
            end
        end
    end
    d("GuardHelper: no alternate Tank was found.  Current guard target remains:"..GuardHelper.guardTankAtName)
    return false
end


local GuardHelperIcon = ZO_Object:Subclass()

function GuardHelperIcon:New(control)
	local obj = ZO_Object.New(self)
	obj:Initialize(control)
	return obj
end

GuardHelper.target = ""
GuardHelper.ability = 0
GuardHelper.lastTarget = ""
GuardHelper.dropped = false
GuardHelper.status = GUARD_STATUS_DOWN
GuardHelper.addonActive = false
GuardHelper.targetStatus = TARGET_STATUS_NOT_SET

function GuardHelperIcon:Initialize(control)
	self.control = control
	self.icon = control:GetNamedChild("Icon")
    self.desc = control:GetNamedChild("Desc")
	self.text = control:GetNamedChild("Text")
 
	control:ClearAnchors()
	control:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, GuardHelper.SV.offsetX, GuardHelper.SV.offsetY)

	self.timeline = ANIMATION_MANAGER:CreateTimelineFromVirtual("GuardHelperAnimation", control)
	self.fadeOutDelay = 0 -- not used???
	




	EVENT_MANAGER:RegisterForEvent(control:GetName(), EVENT_ABILITY_LIST_CHANGED, function() self:UpdateAddonActive() end)
	EVENT_MANAGER:RegisterForEvent(control:GetName(), EVENT_SKILL_RESPEC_RESULT,  function() self:UpdateAddonActive() end)


	self:UpdateAddonActive() -- will launch addon if needed

	self:Update()
	self:UpdateContextualFading()
end


function GuardHelperIcon:activateAddon()
    if GuardHelper.addonActive==false then
        GuardHelper.addonActive=true

        EVENT_MANAGER:RegisterForUpdate(GuardHelper.name .. "Update", 100, function()
            self:Update()
        end)

        EVENT_MANAGER:RegisterForEvent(GuardHelper.name.."61511" , EVENT_COMBAT_EVENT, function(eventCode,result,isError,abilityName,abilityGraphic,abilityActionSlotType,sourceName,sourceType,targetName,targetType,hitValue,powerType,damageType,combatEventLog,sourceUnitId,targetUnitId,abilityId)
            self:CombatEvent(eventCode,result,isError,abilityName,abilityGraphic,abilityActionSlotType,sourceName,sourceType,targetName,targetType,hitValue,powerType,damageType,combatEventLog,sourceUnitId,targetUnitId,abilityId)
        end)
        EVENT_MANAGER:AddFilterForEvent(GuardHelper.name.."61511", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 61511, REGISTER_FILTER_IS_ERROR, false)

        EVENT_MANAGER:RegisterForEvent(GuardHelper.name.."61529" , EVENT_COMBAT_EVENT, function(eventCode,result,isError,abilityName,abilityGraphic,abilityActionSlotType,sourceName,sourceType,targetName,targetType,hitValue,powerType,damageType,combatEventLog,sourceUnitId,targetUnitId,abilityId)
            self:CombatEvent(eventCode,result,isError,abilityName,abilityGraphic,abilityActionSlotType,sourceName,sourceType,targetName,targetType,hitValue,powerType,damageType,combatEventLog,sourceUnitId,targetUnitId,abilityId)
        end)
        EVENT_MANAGER:AddFilterForEvent(GuardHelper.name.."61529", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 61529, REGISTER_FILTER_IS_ERROR, false)

        EVENT_MANAGER:RegisterForEvent(GuardHelper.name.."61536" , EVENT_COMBAT_EVENT, function(eventCode,result,isError,abilityName,abilityGraphic,abilityActionSlotType,sourceName,sourceType,targetName,targetType,hitValue,powerType,damageType,combatEventLog,sourceUnitId,targetUnitId,abilityId)
            self:CombatEvent(eventCode,result,isError,abilityName,abilityGraphic,abilityActionSlotType,sourceName,sourceType,targetName,targetType,hitValue,powerType,damageType,combatEventLog,sourceUnitId,targetUnitId,abilityId)
        end)

        EVENT_MANAGER:AddFilterForEvent(GuardHelper.name.."61536", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 61536, REGISTER_FILTER_IS_ERROR, false)

        EVENT_MANAGER:RegisterForEvent(GuardHelper.name.."80923" , EVENT_COMBAT_EVENT, function(eventCode,result,isError,abilityName,abilityGraphic,abilityActionSlotType,sourceName,sourceType,targetName,targetType,hitValue,powerType,damageType,combatEventLog,sourceUnitId,targetUnitId,abilityId)
            self:CombatEvent(eventCode,result,isError,abilityName,abilityGraphic,abilityActionSlotType,sourceName,sourceType,targetName,targetType,hitValue,powerType,damageType,combatEventLog,sourceUnitId,targetUnitId,abilityId)
        end)
        EVENT_MANAGER:AddFilterForEvent(GuardHelper.name.."80923", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 80923, REGISTER_FILTER_IS_ERROR, false)

        EVENT_MANAGER:RegisterForEvent(GuardHelper.name.."80947" , EVENT_COMBAT_EVENT, function(eventCode,result,isError,abilityName,abilityGraphic,abilityActionSlotType,sourceName,sourceType,targetName,targetType,hitValue,powerType,damageType,combatEventLog,sourceUnitId,targetUnitId,abilityId)
            self:CombatEvent(eventCode,result,isError,abilityName,abilityGraphic,abilityActionSlotType,sourceName,sourceType,targetName,targetType,hitValue,powerType,damageType,combatEventLog,sourceUnitId,targetUnitId,abilityId)
        end)
        EVENT_MANAGER:AddFilterForEvent(GuardHelper.name.."80947", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 80947, REGISTER_FILTER_IS_ERROR, false)


        EVENT_MANAGER:RegisterForEvent(GuardHelper.name.."80983" , EVENT_COMBAT_EVENT, function(eventCode,result,isError,abilityName,abilityGraphic,abilityActionSlotType,sourceName,sourceType,targetName,targetType,hitValue,powerType,damageType,combatEventLog,sourceUnitId,targetUnitId,abilityId)
            self:CombatEvent(eventCode,result,isError,abilityName,abilityGraphic,abilityActionSlotType,sourceName,sourceType,targetName,targetType,hitValue,powerType,damageType,combatEventLog,sourceUnitId,targetUnitId,abilityId)
        end)
        EVENT_MANAGER:AddFilterForEvent(GuardHelper.name.."80983", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 80983, REGISTER_FILTER_IS_ERROR, false)


        EVENT_MANAGER:RegisterForEvent(GuardHelper.name , EVENT_RETICLE_HIDDEN_UPDATE, function() self:UpdateContextualFading() end)

        EVENT_MANAGER:RegisterForEvent(GuardHelper.name , EVENT_ACTIVE_WEAPON_PAIR_CHANGED, function() self:UpdateContextualFading() end)
        EVENT_MANAGER:RegisterForEvent(GuardHelper.name , EVENT_ACTION_SLOT_ABILITY_USED, function(event, slotIndex) self:OnSkillCast(slotIndex) end)

        EVENT_MANAGER:RegisterForEvent(GuardHelper.name , EVENT_RETICLE_TARGET_CHANGED, function(eventCode)
            self:OnReticleTargetChanged(eventCode)
        end)


	end
end

function GuardHelperIcon:deactivateAddon()

    if GuardHelper.addonActive==true then
        GuardHelper.addonActive=false

	    EVENT_MANAGER:UnregisterForUpdate(GuardHelper.name .. "Update")

        EVENT_MANAGER:UnregisterForEvent(GuardHelper.name.."61511", EVENT_COMBAT_EVENT)
        EVENT_MANAGER:UnregisterForEvent(GuardHelper.name.."61529", EVENT_COMBAT_EVENT)
        EVENT_MANAGER:UnregisterForEvent(GuardHelper.name.."61536", EVENT_COMBAT_EVENT)
        EVENT_MANAGER:UnregisterForEvent(GuardHelper.name.."80923", EVENT_COMBAT_EVENT)
        EVENT_MANAGER:UnregisterForEvent(GuardHelper.name.."80947", EVENT_COMBAT_EVENT)
        EVENT_MANAGER:UnregisterForEvent(GuardHelper.name.."80983", EVENT_COMBAT_EVENT)



        EVENT_MANAGER:UnregisterForEvent(GuardHelper.name , EVENT_RETICLE_HIDDEN_UPDATE)
        EVENT_MANAGER:UnregisterForEvent(GuardHelper.name , EVENT_ACTIVE_WEAPON_PAIR_CHANGED)
        EVENT_MANAGER:UnregisterForEvent(GuardHelper.name , EVENT_ACTION_SLOT_ABILITY_USED)
        EVENT_MANAGER:UnregisterForEvent(GuardHelper.name , EVENT_RETICLE_TARGET_CHANGED)

        LibGuardArrow.HideArrow()

	end
end



function GuardHelperIcon:OnReticleTargetChanged(eventCode)
   self:Update()
   --d("target changed")
end

function GuardHelperIcon:CombatEvent(eventCode,result,isError,abilityName,abilityGraphic,abilityActionSlotType,sourceName,sourceType,targetName,targetType,hitValue,powerType,damageType,combatEventLog,sourceUnitId,targetUnitId,abilityId)
    --function GuardHelperIcon:CombatEvent(result, sourceName, targetName, abilityId)

    --if not (targetName == GetRawUnitName("player") or sourceName == GetRawUnitName("player")) then return end

    --if not (targetType == COMBAT_UNIT_TYPE_PLAYER) or (sourceType == COMBAT_UNIT_TYPE_PLAYER) then return end


    if result == ACTION_RESULT_EFFECT_GAINED then
        if abilityId == 61511 or abilityId == 61529 or abilityId == 61536 then
            GuardHelper.dropped = false
            GuardHelper.ability = abilityId
            
            if targetType == COMBAT_UNIT_TYPE_PLAYER then
                --this happens when someone guards you
            else
                local atname = "@notfound"
                for i=1, 12 do
                    if targetName == GetRawUnitName("group"..i) then
                        atname = GetUnitDisplayName("group"..i)
                    end
                end
                if GuardHelper.SV.targetAsFirstSuccessfulGuard and GuardHelper.targetStatus == TARGET_STATUS_NOT_SET and not (atname == "@notfound") then
                    GuardHelper.guardTankAtName = atname
                    GuardHelper.targetStatus=TARGET_STATUS_SET
                    d("GuardHelper: First guard target set: "..GuardHelper.guardTankAtName)
                    d("GuardHelper: use /guardnone to remove target and select someone else")
                end
                if atname == GuardHelper.guardTankAtName then
                    GuardHelper.status = GUARD_STATUS_UP
                else
                    GuardHelper.status = GUARD_STATUS_UP_WRONG_TARGET
                end
                GuardHelper.target = atname--targetName
				GuardHelper.lastTarget = atname--targetName
				self:UpdateContextualFading()
            end
        end
    elseif result == ACTION_RESULT_EFFECT_FADED then
        if abilityId == 80923 or abilityId == 80947 or abilityId == 80983 then
            GuardHelper.target = ""
            GuardHelper.ability = 0
            
            if GuardHelper.dropped then
                GuardHelper.status = GUARD_STATUS_DOWN
            elseif targetType == COMBAT_UNIT_TYPE_PLAYER then
				-- Since U35, the "guard loss" is a skill cast by the game on the player, regardless the cause of loss
				if GuardHelper.lastTarget == GuardHelper.guardTankAtName then
                    GuardHelper.status = GUARD_STATUS_LOST
                    GuardHelper.guardLostTime = GetGameTimeMilliseconds()
				    zo_callLater(function() self:ResetLostGuardToGuardDown() end, BLINK_TIME)
				else
				    GuardHelper.status = GUARD_STATUS_DOWN
				end
            end
        end
    end
	
	self:Update()
end

function GuardHelperIcon:OnSkillCast(slotIndex)
    if GuardHelper.isGuardAbility(GetSlotBoundId(slotIndex)) then
        if GuardHelper.target ~= "" then
            GuardHelper.dropped = true -- Manually dropped guard by casting the cancel skill
        end
    end
end


function GuardHelperIcon:ResetLostGuardToGuardDown()
    -- reset lost guard to down guard after 5 seconds
	if GuardHelper.status == GUARD_STATUS_LOST then
		GuardHelper.status = GUARD_STATUS_DOWN
		self:Update()
	end
end


function GuardHelperIcon:ShouldContextuallyShow()
	if GuardHelper.isGuardSkillSlotted() then
	    if IsReticleHidden() then
	        if GuardHelper.overrideReticleHidden then
	            return true
	        else
	            return false
	        end
	    else
		    return true
		end
	end

	return false
end


function GuardHelperIcon:UpdateAddonActive()
    if GuardHelper.isGuardSkillSlotted() then
        self:activateAddon()
    else
        self:deactivateAddon()
    end
    self:UpdateContextualFading()
end


function GuardHelperIcon:UpdateContextualFading()
    local shouldContextuallyShow = self:ShouldContextuallyShow()
    if shouldContextuallyShow ~= self.isContextuallyShown then
        if shouldContextuallyShow then
            self.timeline:PlayForward()

        else
            self.timeline:PlayBackward()
            LibGuardArrow.HideArrow()

        end
        self.isContextuallyShown = shouldContextuallyShow
    end
end


function GuardHelper.DistanceToTank()

    local offtankSearchBy=""

    for i=1, 12 do

		local searchBy = "group"..i
		if DoesUnitExist("group"..i) then
		    if not IsUnitDead("group"..i) then

                    if GetUnitDisplayName(searchBy) == GuardHelper.guardTankAtName then
                        offtankSearchBy = searchBy

                    end

            end
        end
    end
    if offtankSearchBy=="" then
        return nil, nil, nil, nil
    end

    local playerZone, playerX, playerY, playerZ = GetUnitRawWorldPosition( "player" )
    local zone, tankX, tankY, tankZ = GetUnitRawWorldPosition( offtankSearchBy )

    local range = -100
    if offtankSearchBy == "" then
    else
        if playerZone == zone then
            local ta = (playerX-tankX)
            local tb = (playerZ-tankZ)
            if ta == 0 then
                ta= 0.001
            end
            if tb == 0 then
                tb = 0.001
            end

            local tc = math.sqrt(ta*ta + tb*tb)
            if tc==0 then
                tc = 0.001
            end

            range = tc
        end
    end

    return range/100, tankX, tankZ, tankY

end

GuardHelper.icons16meters = {}

function GuardHelper.Show16meters()

    -- will show 15m when guard is down, and 16m when guard is up
    GuardHelper.Hide16meters()
    if GuardHelper.SV.circle16mAroundGuardTarget then


        local distance, tankX, tankY, tankHeight = GuardHelper.DistanceToTank()
        if tankX == nil then

        else
            local distance = 1500 -- 15 m
            if GuardHelper.status == GUARD_STATUS_UP then
                distance = 1600 -- 16m
            end

            local icon_1 = OSI.CreatePositionIcon(tankX,tankHeight,tankY+distance, "odysupporticons/icons/squares/squaretwo_blue.dds",iconSize, {1, 1, 1})
            local icon_2 = OSI.CreatePositionIcon(tankX,tankHeight,tankY-distance, "odysupporticons/icons/squares/squaretwo_blue.dds",iconSize, {1, 1, 1})
            local icon_3 = OSI.CreatePositionIcon(tankX+distance,tankHeight,tankY, "odysupporticons/icons/squares/squaretwo_blue.dds",iconSize, {1, 1, 1})
            local icon_4 = OSI.CreatePositionIcon(tankX-distance,tankHeight,tankY, "odysupporticons/icons/squares/squaretwo_blue.dds",iconSize, {1, 1, 1})

            local fortyfiveangles = distance / math.sqrt(2)

            local icon_5 = OSI.CreatePositionIcon(tankX-fortyfiveangles,tankHeight,tankY-fortyfiveangles, "odysupporticons/icons/squares/squaretwo_blue.dds",iconSize, {1, 1, 1})
            local icon_6 = OSI.CreatePositionIcon(tankX-fortyfiveangles,tankHeight,tankY+fortyfiveangles, "odysupporticons/icons/squares/squaretwo_blue.dds",iconSize, {1, 1, 1})
            local icon_7 = OSI.CreatePositionIcon(tankX+fortyfiveangles,tankHeight,tankY+fortyfiveangles, "odysupporticons/icons/squares/squaretwo_blue.dds",iconSize, {1, 1, 1})
            local icon_8 = OSI.CreatePositionIcon(tankX+fortyfiveangles,tankHeight,tankY-fortyfiveangles, "odysupporticons/icons/squares/squaretwo_blue.dds",iconSize, {1, 1, 1})

            GuardHelper.icons16meters["icon_1"] = icon_1
            GuardHelper.icons16meters["icon_2"] = icon_2
            GuardHelper.icons16meters["icon_3"] = icon_3
            GuardHelper.icons16meters["icon_4"] = icon_4
            GuardHelper.icons16meters["icon_5"] = icon_5
            GuardHelper.icons16meters["icon_6"] = icon_6

            GuardHelper.icons16meters["icon_7"] = icon_7
            GuardHelper.icons16meters["icon_8"] = icon_8

        end
    end
end


function GuardHelper.Hide16meters()
    if not (GuardHelper.icons16meters["icon_1"]) then

        return
    end
    OSI.DiscardPositionIcon(GuardHelper.icons16meters["icon_1"])
    GuardHelper.icons16meters["icon_1"]=nil

    OSI.DiscardPositionIcon(GuardHelper.icons16meters["icon_2"])
    GuardHelper.icons16meters["icon_2"]=nil

    OSI.DiscardPositionIcon(GuardHelper.icons16meters["icon_3"])
    GuardHelper.icons16meters["icon_3"]=nil

    OSI.DiscardPositionIcon(GuardHelper.icons16meters["icon_4"])
    GuardHelper.icons16meters["icon_4"]=nil

    OSI.DiscardPositionIcon(GuardHelper.icons16meters["icon_5"])
    GuardHelper.icons16meters["icon_5"]=nil


    OSI.DiscardPositionIcon(GuardHelper.icons16meters["icon_6"])
    GuardHelper.icons16meters["icon_6"]=nil


    OSI.DiscardPositionIcon(GuardHelper.icons16meters["icon_7"])
    GuardHelper.icons16meters["icon_7"]=nil


    OSI.DiscardPositionIcon(GuardHelper.icons16meters["icon_8"])
    GuardHelper.icons16meters["icon_8"]=nil

end


function GuardHelperIcon:Update()


    local name = zo_strformat("<<1>>", GuardHelper.target)
    local texture = "GuardHelper/icons/guard_red.dds"

	local description = "Guard down"


    local distanceToTank, tankX, tankY, tankHeight = GuardHelper.DistanceToTank()
    if tankX == nil then
        LibGuardArrow.HideArrow()
        GuardHelper.unblockGuard()
    else
        LibGuardArrow.SetTarget1XY(tankX, tankY)
    end

	local targetDisplayName = GuardHelper.getDisplayName(GuardHelper.target)


	if GuardHelper.status == GUARD_STATUS_UP then
	    if GuardHelper.SV.preventRemovingGuardFromIntendedTarget then
	        --d("1-block")
	        GuardHelper.blockGuard()
	    else
	        GuardHelper.unblockGuard()
	    end

	    name = zo_strformat("<<1>>", targetDisplayName)
        description = string.format("Guarding %.1fm", distanceToTank)
       texture = "GuardHelper/icons/guard_green.dds"
       LibGuardArrow.ApplyColorGreen()
	end

	if GuardHelper.status == GUARD_STATUS_UP_WRONG_TARGET then
        GuardHelper.unblockGuard()

	    name = zo_strformat("<<1>>", targetDisplayName)
	    if  GuardHelper.guardTankAtName == "" then
        else
        	description = "Wrong Target"
        end
        LibGuardArrow.ApplyColorRed()
        texture = "GuardHelper/icons/guard_orange.dds"
	end

    if GuardHelper.status == GUARD_STATUS_LOST then

        texture = "GuardHelper/icons/guard_red.dds"
        if GuardHelper.SV.blinking then
            local diftime = GetGameTimeMilliseconds() - GuardHelper.guardLostTime
            local increment = math.floor(diftime / BLINK_DELAY)
            local mod = increment % 2
            if mod==0 then
                texture = "GuardHelper/icons/guard_reddrop.dds"
            end
        end
		description = "Guard Lost"
		LibGuardArrow.ApplyColorRed()
    end

    local reticleAtname = ""
    local reticleName = GetUnitNameHighlightedByReticle()
    for i=1, 12 do
        if reticleName.."^Fx" == GetRawUnitName("group"..i) or  reticleName.."^Mx" == GetRawUnitName("group"..i) then
            local groupname = GetUnitDisplayName("group"..i)
            if groupname == nil then
            else
                reticleAtname = groupname
            end
        end
    end

    if (GuardHelper.status == GUARD_STATUS_LOST or GuardHelper.status == GUARD_STATUS_DOWN) then
        if tankX == nil or tankY==nil then
            LibGuardArrow.HideArrow()
        else
            if GuardHelper.targetStatus == TARGET_STATUS_SET then

                if GuardHelper.SV.arrowToGuardTargetWhenGuardOff then
		            LibGuardArrow.ShowArrow()
		        else
		            LibGuardArrow.HideArrow()
		        end
		    else
		        LibGuardArrow.HideArrow()
		    end
		end
	else
	    if GuardHelper.SV.arrowToGuardTargetWhenGuardOn then
	        if tankX == nil or tankY==nil then
                LibGuardArrow.HideArrow()
            else
                if GuardHelper.targetStatus == TARGET_STATUS_SET then
                    LibGuardArrow.ShowArrow()
                else
                    LibGuardArrow.HideArrow()
                end
            end
	    else
            LibGuardArrow.HideArrow()
        end
    end

    if reticleAtname == GuardHelper.guardTankAtName and (GuardHelper.status == GUARD_STATUS_LOST or GuardHelper.status == GUARD_STATUS_DOWN) then
        GuardHelper.unblockGuard()
        if GuardHelper.targetStatus == TARGET_STATUS_SET then
            if distanceToTank~=nil then
                if (distanceToTank>=0 and distanceToTank <=15) then -- not exactly sure why this can be nil sometimes, but it happened
                    local current, max, effectiveMax = GetUnitPower("player", POWERTYPE_STAMINA)
                    if current < 3200 then
                        description = "Low stam"
                        texture = "GuardHelper/icons/guard_greenred.dds"
                        LibGuardArrow.ApplyColorRed()
                        GuardHelper.shouldCastGuard=false
                    else
                        description = "Cast Now"
                        GuardHelper.shouldCastGuard=true
                        LibGuardArrow.ApplyColorBlue()
                        texture = "GuardHelper/icons/guard_blue.dds"
                    end
                else
                    description = "Too far"
                    LibGuardArrow.ApplyColorRed()
                    texture = "GuardHelper/icons/guard_bluered.dds"
                    GuardHelper.shouldCastGuard=false
                end
            else
                description = "Too far"
                LibGuardArrow.ApplyColorRed()
                texture = "GuardHelper/icons/guard_bluered.dds"
                GuardHelper.shouldCastGuard=false
            end
            --d("distance to tank:"..distanceToTank.."m")
        else
            GuardHelper.shouldCastGuard=false
        end
    else
        if (GuardHelper.status == GUARD_STATUS_LOST or GuardHelper.status == GUARD_STATUS_DOWN) then
            if GuardHelper.SV.preventCastingGuardOnUnintendedTarget then
                if GuardHelper.targetStatus == TARGET_STATUS_SET then
                    --d("2-block")
                    GuardHelper.blockGuard()
                else
                    GuardHelper.unblockGuard()
                end
            else
                GuardHelper.unblockGuard()
            end
	    end

        GuardHelper.shouldCastGuard=false

    end

    if GuardHelper.SV.displayGuardedTargetAtName and (GuardHelper.status == GUARD_STATUS_UP or GuardHelper.status == GUARD_STATUS_UP_WRONG_TARGET) then

        self.text:SetText(name)
    elseif GuardHelper.SV.displayIntendedGuardedTargetAtName and not (GuardHelper.status == GUARD_STATUS_UP or GuardHelper.status == GUARD_STATUS_UP_WRONG_TARGET) then
        self.text:SetText(GuardHelper.guardTankAtName)
    else
        self.text:SetText("")
    end


	if  GuardHelper.targetStatus == TARGET_STATUS_NOT_SET then
	    if GuardHelper.SV.targetAsFirstSuccessfulGuard then
	    	description = "Guard someone to select"
	        name = "Target"
	        self.text:SetText(name)

	    else
	        description = "No target setup use:"
	        name = "/guardtank"
	        self.text:SetText(name)
	    end
	end


    if texture == "GuardHelper/icons/guard_red.dds" then
        LibGuardArrow.ApplyColorRed()
    end
    self.icon:SetTexture(texture)
	self.desc:SetText(description)

	GuardHelper.Show16meters()
end


function GuardHelper_OnInitialized(control)
	local GUARD_STATUS = GuardHelperIcon:New(control)
	GuardHelper.widget = GUARD_STATUS
end

function GuardHelper.OnMoveStop(control)
	GuardHelper.SV.offsetX = control:GetLeft()
	GuardHelper.SV.offsetY = control:GetTop()
end




function GuardHelper.OnAddonLoaded(event, addonName)
    if addonName ~= GuardHelper.name then return end
    EVENT_MANAGER:UnregisterForEvent(GuardHelper.name, EVENT_ADD_ON_LOADED)


    GuardHelper.DS = ZO_SavedVars:NewAccountWide("GuardHelperSavedVariables", 1.0, nil, GuardHelper.accountWideDefaults)
    
    if GuardHelper.DS.accountWide then
		GuardHelper.SV = ZO_SavedVars:NewAccountWide("GuardHelperSavedVariables", 1.0, nil, GuardHelper.defaults)
	else
		GuardHelper.SV = ZO_SavedVars:New("GuardHelperSavedVariables", 1.0, nil, GuardHelper.defaults)
	end

    GuardHelper.setupMenu()

    LibGuardArrow.CreateTexture()
    local arrowColor = {1, 1, 1, 1} -- white

    local arrowScale = 0.75
    LibGuardArrow.ApplyStyle("GuardHelper/icons/arrow1.dds", arrowColor, arrowScale)

    SLASH_COMMANDS["/guardtank"] = GuardHelper.GuardChangeTankTarget
    SLASH_COMMANDS["/guardnone"] = GuardHelper.GuardRemoveTarget


	GuardHelper_OnInitialized(GuardHelperWindow)
end
EVENT_MANAGER:RegisterForEvent(GuardHelper.name, EVENT_ADD_ON_LOADED, GuardHelper.OnAddonLoaded)