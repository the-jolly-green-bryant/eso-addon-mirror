-- This file is part of CyrHUD
--
-- (C) 2014 Scott Yeskie (Sasky)
--
-- This program is free software; you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation; either version 2 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.

CyrHUD = CyrHUD or {}

local function n0(val) if val == nil then return 0 end return val end

-- Setup class
CyrHUD.MovingObjective = {}
CyrHUD.MovingObjective.__index = CyrHUD.MovingObjective
CyrHUD.MovingObjective.type = "MovingObjective"

setmetatable(CyrHUD.MovingObjective, {
    __call = function (cls, ...)
        return cls.new(...)
    end,
})


local shortenObjName = function(str)
    return str:gsub(",..$", ""):gsub("%^.d$", "")
	--EN
	    :gsub("Elder Scroll of ", "")
end

----------------------------------------------
-- Creation
----------------------------------------------

CyrHUD.MovingObjective.new = function(objectiveId)
    local self = setmetatable({}, CyrHUD.MovingObjective)

    self.startMovingObjective = self.startMovingObjective or GetTimeStamp()
    self.endMovingObjective = nil
    self.objectiveId = objectiveId


    --self:update()

    return self
end

----------------------------------------------
-- Label update
----------------------------------------------

--Label fields
local L_ICON, L_UA = "img1", "img2"
local CYROCHAT_ICON = 'img4'
local L_NAME, L_ATT_SIEGE, L_DEF_SIEGE, L_TIME = "txt1", "txt2", "txt3", "txt4"
local L_LUMB, L_MINE, L_FARM = "img5", "img6", "img7"
local L_SCROLL = "img8"
local L_ICON_DEATHS_AD, L_ICON_DEATHS_EP, L_ICON_DEATHS_DC = "img12", "img13", "img14"
local L_DEATHS_AD, L_DEATHS_EP, L_DEATHS_DC = "txt11", "txt12", "txt13"
local L_KILLS_AD, L_KILLS_EP, L_KILLS_DC = "txt23", "txt24", "txt25"
local LEGEND_KILLS, LEGEND_DEATHS = "txt26", "txt27"
local L_ATT_SIEGE_ICON, L_DEF_SIEGE_ICON = "img15", "img16"
local L_CONNECTED = "img17"
local L_ARROW = "img18"
local L_HOLDER = "txt16"

local ICON_EMPEROR = "img25"
local TEXT_PLAYERNAME = "txt17"
local TEXT_RIVALNAME = "txt18"
local TEXT_PLAYERRANK = "txt19"
local TEXT_RIVALRANK = "txt20"
local TEXT_PLAYERSCORE = "txt21"
local TEXT_RIVALSCORE = "txt22"

local ICON_ASH = "img26"
local ICON_WELL = "img27"
local ICON_CHAL = "img28"
local ICON_BRK = "img29"
local ICON_SIA = "img30"
local ICON_ROE = "img31"

function CyrHUD.MovingObjective:configureLabel(label)

    local obj = CyrHUD.MovingObjective[self.objectiveId]
	
    label:exposeControls(2,4)
    


    -- Objective icon
    label:getControl(L_ICON):SetDrawLayer(2)
	
	if obj.objectiveType == OBJECTIVE_ARTIFACT_DEFENSIVE or obj.objectiveType == OBJECTIVE_ARTIFACT_OFFENSIVE then
	    label:positionControl(L_ICON, 64, 64, -14, -12) -- 40 40 -2 -2
	else
	    label:positionControl(L_ICON, 40, 40, -2, -2)
	end
	
	

    --Under attack graphic
    label:positionControl(L_UA, 40, 40, -2, -2)
    local ua = label:getControl(L_UA)
    ua:SetDrawLayer(1)
    ua:SetTexture(CyrHUD.info.underAttack)

    --Objective name
    label:positionControl(L_NAME, 150, 30, 35, 5)
	
	--Holder name
	label:positionControl(L_HOLDER, 150, 30, 35, 23)

    --Time
    label:positionControl(L_TIME, 35, 30, 245, 5)
end

function CyrHUD.SetArtifactStateData(_, artifactName, keepId, characterName, playerAlliance, objectiveControlEvent, objectiveControlState, campaignId, displayName)
   if campaignId == 0 then return end
   
   CyrHUD.ArtifactHolders = CyrHUD.ArtifactHolders or {}
   
   if objectiveControlEvent == OBJECTIVE_CONTROL_EVENT_FLAG_TAKEN then
       CyrHUD.ArtifactHolders[artifactName] = displayName 
   
   elseif objectiveControlEvent == OBJECTIVE_CONTROL_EVENT_FLAG_DROPPED then
       CyrHUD.ArtifactHolders[artifactName] = ""
	   
   elseif objectiveControlEvent == OBJECTIVE_CONTROL_EVENT_FLAG_SPAWNED then
        CyrHUD.ArtifactHolders[artifactName] = "?"
   end

end

function CyrHUD.PreSetArtifactStateData(eventCode, objectiveKeepId, objectiveObjectiveId, battlegroundContext, objectiveControlEvent, objectiveControlState, holderAlliance, lastHolderAlliance, pinType, daedricArtifactId, lastObjectiveControlState)
    if lastObjectiveControlState == OBJECTIVE_CONTROL_STATE_UNKNOWN and objectiveControlState ~= OBJECTIVE_CONTROL_STATE_UNKNOWN then
	    -- Volendrung is revealed!
		if CyrHUD.MovingObjectives[-1] then CyrHUD.MovingObjectives[-1] = nil end
		local artifactName = GetDaedricArtifactDisplayName(daedricArtifactId)
		CyrHUD.SetMovingObjective(eventCode, objectiveKeepId, objectiveObjectiveId, battlegroundContext, artifactName, OBJECTIVE_DAEDRIC_WEAPON, OBJECTIVE_CONTROL_EVENT_FLAG_SPAWNED, OBJECTIVE_CONTROL_EVENT_FLAG_SPAWNED, 0, 0, pinType)
		
    end
end

function CyrHUD.ArtifactSpawned(eventCode, daedricArtifactId)
        -- Volendrung spawned but not revealed, Volendrung seeks a wielder!
		local artifactName = GetDaedricArtifactDisplayName(daedricArtifactId)
		CyrHUD.SetMovingObjective(eventCode, nil, -1, CyrHUD.battleContext, artifactName, OBJECTIVE_DAEDRIC_WEAPON, OBJECTIVE_CONTROL_EVENT_FLAG_SPAWNED, OBJECTIVE_CONTROL_EVENT_FLAG_SPAWNED, 0, 0, MAP_PIN_TYPE_AVA_DAEDRIC_ARTIFACT_VOLENDRUNG_NEUTRAL)
end

function CyrHUD.MovingObjective:updateLabel(label)

    label:getControl(L_ICON_DEATHS_AD):SetHidden(true)
	label:getControl(L_ICON_DEATHS_EP):SetHidden(true)
	label:getControl(L_ICON_DEATHS_DC):SetHidden(true)
    label:getControl(L_DEATHS_AD):SetHidden(true)
	label:getControl(L_DEATHS_EP):SetHidden(true)
	label:getControl(L_DEATHS_DC):SetHidden(true)
    label:getControl(L_KILLS_AD):SetHidden(true)
	label:getControl(L_KILLS_EP):SetHidden(true)
	label:getControl(L_KILLS_DC):SetHidden(true)
	label:getControl(LEGEND_KILLS):SetHidden(true)
	label:getControl(LEGEND_DEATHS):SetHidden(true)
    label:getControl(L_ATT_SIEGE_ICON):SetHidden(true)
	label:getControl(L_DEF_SIEGE_ICON):SetHidden(true)
	label:getControl(L_CONNECTED):SetHidden(true)
    label:getControl(L_ARROW):SetAlpha(0)
	
	label:getControl(ICON_EMPEROR):SetHidden(true)
	label:getControl(TEXT_PLAYERNAME):SetHidden(true)
	label:getControl(TEXT_RIVALNAME):SetHidden(true)
	label:getControl(TEXT_PLAYERRANK):SetHidden(true)
	label:getControl(TEXT_RIVALRANK):SetHidden(true)
	label:getControl(TEXT_PLAYERSCORE):SetHidden(true)
	label:getControl(TEXT_RIVALSCORE):SetHidden(true)
	label:getControl(ICON_ASH):SetHidden(true)
	label:getControl(ICON_WELL):SetHidden(true)
	label:getControl(ICON_CHAL):SetHidden(true)
	label:getControl(ICON_BRK):SetHidden(true)
	label:getControl(ICON_SIA):SetHidden(true)
	label:getControl(ICON_ROE):SetHidden(true)
	
	-- 05/07/2026 performance improvement:
	-- updateLabel() runs once a second for every displayed Moving Objective
	-- row. Below, label:getControl(L_ICON), label:getControl(L_TIME), and
	-- label:getControl(L_HOLDER) were each called multiple times to fetch the
	-- exact same controls repeatedly -- each call being a method invocation
	-- plus a table index. We fetch each one once and reuse the cached
	-- reference for every subsequent use. (Same fix already applied to the
	-- equivalent pattern in PatrollingHorrors.lua.)
	local iconControl = label:getControl(L_ICON)
	local timeControl = label:getControl(L_TIME)
	local holderControl = label:getControl(L_HOLDER)

	label:getControl(L_NAME):SetHidden(false)
	iconControl:SetHidden(false)
	timeControl:SetHidden(false)

    local obj = CyrHUD.MovingObjective[self.objectiveId]
	local underAttack = obj.objectiveControlEvent == OBJECTIVE_CONTROL_EVENT_UNDER_ATTACK
	
	--objective icon
    iconControl:SetTexture(obj.texture)
	iconControl:SetColor(ZO_ColorDef:New(1,1,1,1):UnpackRGBA())
	
	if obj.objectiveType == OBJECTIVE_ARTIFACT_DEFENSIVE or obj.objectiveType == OBJECTIVE_ARTIFACT_OFFENSIVE then
	    label:positionControl(L_ICON, 64, 64, -14, -12) -- 40 40 -2 -2
	else
	    label:positionControl(L_ICON, 40, 40, -2, -2)
	end
	
    label:getControl(L_UA):SetHidden(not underAttack)
	label:getControl(L_LUMB):SetHidden(true)
	label:getControl(L_MINE):SetHidden(true)
	label:getControl(L_FARM):SetHidden(true)
    label:getControl(L_SCROLL):SetHidden(true)
	label:getControl(L_ATT_SIEGE):SetHidden(true)
	label:getControl(L_DEF_SIEGE):SetHidden(true)
	label:getControl(CYROCHAT_ICON):SetHidden(true)
	
	holderControl:SetHidden(false)
	

    --objective name
    local name = label:getControl(L_NAME)
    name:SetText(shortenObjName(obj.name))
    name:SetColor(CyrHUD.info[obj.holdingAlliance].color:UnpackRGBA())

    --objective holder name
    name = holderControl
	local _, x, y = GetObjectivePinInfo(obj.keepId, obj.objectiveId, CyrHUD.battleContext)
	
	local closestLocation = CyrHUD.GetClosestLocationName(x, y).." "
	
	local holderName
	if CyrHUD.ArtifactHolders and CyrHUD.ArtifactHolders[obj.name] then
	    holderName = CyrHUD.ArtifactHolders[obj.name]
	else
	    _, holderName = GetCarryableObjectiveHoldingCharacterInfo(obj.keepId, obj.objectiveId, CyrHUD.battleContext)
		if holderName == nil or holderName == "" then
		   _, holderName = GetCarryableObjectiveLastHoldingCharacterInfo(obj.keepId, obj.objectiveId, CyrHUD.battleContext) 
		end
	end
	
	holderName = closestLocation..holderName
	
	if obj.holdingAlliance == 0 then
	    holderName = closestLocation
	end
	
    name:SetText(holderName)
    name:SetColor(CyrHUD.colors.white:UnpackRGBA())	

    --Time
    timeControl:SetText(self:getDuration())
	if self.endMovingObjective then 
        timeControl:SetColor(CyrHUD.info[self.holdingAlliance].color:UnpackRGBA())
	else
        timeControl:SetColor(CyrHUD.info[ALLIANCE_NONE].color:UnpackRGBA())	
	end 
	
	timeControl:SetColor(CyrHUD.info[ALLIANCE_NONE].color:UnpackRGBA())

    --Background color
    label.main:SetCenterColor(self:getBGColor():UnpackRGBA())
end

----------------------------------------------
-- Model update
----------------------------------------------

function CyrHUD.MovingObjective:update()
    self.holdingAlliance, self.lastHoldingAlliance = GetCarryableObjectiveHoldingAllianceInfo(self.keepId, self.objectiveId, CyrHUD.battleContext) 
		
        if self.endMovingObjective then
            --Remove after time
            if GetDiffBetweenTimeStamps(GetTimeStamp(), self.endMovingObjective) > 15 then
                CyrHUD.MovingObjective[self.objectiveId] = nil
            end
        end
end

function CyrHUD.MovingObjective:restart()
    self.endMovingObjective = nil
end


----------------------------------------------
-- Getters
----------------------------------------------

--[[
    @return red, green, blue, alpha for background color
        all in range [0,1]
--]]
function CyrHUD.MovingObjective:getBGColor()
    if self.endMovingObjective then
        if self.holdingAlliance == GetUnitAlliance("player") then
            return CyrHUD.info.defendedColor
        end

        return CyrHUD.info.endAttackColor
    end

    -- 05/07/2026 bug fix (supersedes the earlier performance-only note here):
    -- This block originally called CyrHUD.info.newAttackColor:Lerp(...) during
    -- the first 60 seconds after an objective started moving but never
    -- returned or used the result, so the intended "flash red then fade to
    -- the normal background" effect never actually appeared. We previously
    -- removed that call entirely as dead code; now that the missing behavior
    -- has been flagged as wanted, we restore it properly by returning the
    -- interpolated color. (Same fix applied to the equivalent code in
    -- Battle.lua and PatrollingHorrors.lua.)
    local delta = GetDiffBetweenTimeStamps(GetTimeStamp(), self.startMovingObjective)

    if delta < 60 then
        return CyrHUD.info.newAttackColor:Lerp(CyrHUD.info.defaultBGColor, delta/60)
    end

    return CyrHUD.info.defaultBGColor
end

--[[
    @return elapsed time of battle event
        if an end is specified, will show total lenth
        otherwise will show current length
--]]
function CyrHUD.MovingObjective:getDuration()
    return CyrHUD.formatTime(GetDiffBetweenTimeStamps(self.endMovingObjective or GetTimeStamp(), self.startMovingObjective), false, true)
end
