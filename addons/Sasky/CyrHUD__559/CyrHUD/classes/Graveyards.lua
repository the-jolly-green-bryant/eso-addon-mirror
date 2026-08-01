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
CyrHUD.Graveyard = {}
CyrHUD.Graveyard.__index = CyrHUD.Graveyard
CyrHUD.Graveyard.type = "Graveyard"

setmetatable(CyrHUD.Graveyard, {
    __call = function (cls, ...)
        return cls.new(...)
    end,
})


local shortenGraveName = function(str)
    return str:gsub(",..$", ""):gsub("%^.d$", "")
	--EN
	    --:gsub("Elder Scroll of ", "")
end

----------------------------------------------
-- Creation
----------------------------------------------

CyrHUD.Graveyard.new = function(killLocation)
    local self = setmetatable({}, CyrHUD.Graveyard)

    self.startGraveyard = self.startGraveyard or GetTimeStamp()
    self.endGraveyard = nil
    self.name = killLocation 
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
	
function CyrHUD.Graveyard:configureLabel(label)

    local grave = CyrHUD.Graveyard[self.name]
	
    label:exposeControls(2,4)


    -- Graveyard icon
    label:getControl(L_ICON):SetDrawLayer(2)
    label:positionControl(L_ICON, 20, 20, 8, 8)

    -- Graveyard name
    label:positionControl(L_NAME, 130, 30, 35, 5) -- 150
	
	-- deaths icons
	label:getControl(L_ICON_DEATHS_AD):SetDrawLayer(1)
	label:getControl(L_ICON_DEATHS_EP):SetDrawLayer(2)
	label:getControl(L_ICON_DEATHS_DC):SetDrawLayer(2)
	label:positionControl(L_ICON_DEATHS_AD, 30, 30, 223, 4) -- 2 
	label:positionControl(L_ICON_DEATHS_EP, 30, 30, 200, 4) 
	label:positionControl(L_ICON_DEATHS_DC, 30, 30, 177, 4) 
	label:getControl(L_ICON_DEATHS_AD):SetTexture("/esoui/art/treeicons/gamepad/gp_tutorial_idexicon_death.dds")
	label:getControl(L_ICON_DEATHS_EP):SetTexture("/esoui/art/treeicons/gamepad/gp_tutorial_idexicon_death.dds")
	label:getControl(L_ICON_DEATHS_DC):SetTexture("/esoui/art/treeicons/gamepad/gp_tutorial_idexicon_death.dds")
    label:getControl(L_ICON_DEATHS_AD):SetColor(CyrHUD.info[4].color:UnpackRGBA())
	label:getControl(L_ICON_DEATHS_EP):SetColor(CyrHUD.info[4].color:UnpackRGBA())
	label:getControl(L_ICON_DEATHS_DC):SetColor(CyrHUD.info[4].color:UnpackRGBA())


    -- kills & deaths legends
	label:getControl(LEGEND_KILLS):SetDrawLayer(2)
	label:getControl(LEGEND_DEATHS):SetDrawLayer(3)
	label:positionControl(LEGEND_KILLS, 28, 28, 165, 5) 
	label:positionControl(LEGEND_DEATHS, 28, 28, 165, 20)
	label:getControl(LEGEND_KILLS):SetText("K")
    label:getControl(LEGEND_DEATHS):SetText("D")

    -- kills count
	label:getControl(L_KILLS_AD):SetDrawLayer(2)
	label:getControl(L_KILLS_EP):SetDrawLayer(3)
	label:getControl(L_KILLS_DC):SetDrawLayer(3)
	label:positionControl(L_KILLS_AD, 28, 28, 231, 5) -- 28, 28, 231, 5
	label:positionControl(L_KILLS_EP, 28, 28, 207, 5) -- 28, 28, 207, 5
	label:positionControl(L_KILLS_DC, 28, 28, 185, 5) -- 28, 28, 185, 5
    label:getControl(L_KILLS_AD):SetColor(CyrHUD.info[1].color:UnpackRGBA())
	label:getControl(L_KILLS_EP):SetColor(CyrHUD.info[2].color:UnpackRGBA())
	label:getControl(L_KILLS_DC):SetColor(CyrHUD.info[3].color:UnpackRGBA())


    -- deaths count
	label:getControl(L_DEATHS_AD):SetDrawLayer(2)
	label:getControl(L_DEATHS_EP):SetDrawLayer(3)
	label:getControl(L_DEATHS_DC):SetDrawLayer(3)
	label:positionControl(L_DEATHS_AD, 28, 28, 231, 20) -- 28, 28, 231, 5
	label:positionControl(L_DEATHS_EP, 28, 28, 207, 20) -- 28, 28, 207, 5
	label:positionControl(L_DEATHS_DC, 28, 28, 185, 20) -- 28, 28, 185, 5
    label:getControl(L_DEATHS_AD):SetColor(CyrHUD.info[1].color:UnpackRGBA())
	label:getControl(L_DEATHS_EP):SetColor(CyrHUD.info[2].color:UnpackRGBA())
	label:getControl(L_DEATHS_DC):SetColor(CyrHUD.info[3].color:UnpackRGBA())


    --Time
    label:positionControl(L_TIME, 35, 30, 245, 5)

end

function CyrHUD.SetColouredGraveyardName(label, grave) -- set graveyard coloured name
	local name = label:getControl(L_NAME)
	
	local ADscore = grave.allianceKills[1] - grave.allianceDeaths[1]
	local DCscore = grave.allianceKills[3] - grave.allianceDeaths[3]
	local EPscore = grave.allianceKills[2] - grave.allianceDeaths[2]
	
	local lowestScore = math.min(ADscore,DCscore,EPscore)
	
	if lowestScore < 0 then
	   local addThis =  math.abs(lowestScore)
	   if ADscore ~= 0 then ADscore = ADscore + addThis end
	   if DCscore ~= 0 then DCscore = DCscore + addThis end
	   if EPscore ~= 0 then EPscore = EPscore + addThis end
	end
	
	local total = ADscore + DCscore + EPscore
	
	local ADpercent = ADscore / total * 100
	local DCpercent = DCscore / total * 100
	local EPpercent = EPscore / total * 100
	

   if ADpercent == 100 or DCpercent == 100 or EPpercent == 100 then -- no need to calculate here
	  name:SetText(grave.name)
	  if ADpercent == 100 then
		  name:SetColor(CyrHUD.info[1].color:UnpackRGBA())
	  elseif EPpercent == 100 then
		  name:SetColor(CyrHUD.info[2].color:UnpackRGBA()) 
	  elseif DCpercent == 100 then
		  name:SetColor(CyrHUD.info[3].color:UnpackRGBA())
	  end
   elseif ADpercent == 0 and DCpercent == 0 and EPpercent == 0 then
		name:SetColor(CyrHUD.info[0].color:UnpackRGBA())
   
   else -- calculate graveyard name string colors
	   local battleNameArray = CyrHUD.UTF8ToCharArray(grave.name)
	   local rest = battleNameArray
	   
	   local colorLimitLetterAD = math.floor(ADpercent/100*#battleNameArray)
	   local ADstring = ""
	   if colorLimitLetterAD ~= 0 then
		   local allianceColor = GetAllianceColor(1)
		   local ADcolor = "|c"..allianceColor:ToHex()
		   local arrayTostring, newArray = CyrHUD.charArrayToString(battleNameArray,colorLimitLetterAD)			   
		   ADstring = ADcolor..arrayTostring.."|r"
		   rest = newArray
	   end
	   
	   local colorLimitLetterDC = math.floor(DCpercent/100*#battleNameArray)
	   local DCstring = ""
	   if colorLimitLetterDC ~= 0 then
		   local allianceColor = GetAllianceColor(3)
		   local DCcolor = "|c"..allianceColor:ToHex()	
		   local arrayTostring, newArray = CyrHUD.charArrayToString(rest,colorLimitLetterDC)
		   DCstring = DCcolor..arrayTostring.."|r"
		   rest = newArray
	   end
   
	   local colorLimitLetterEP = math.floor(EPpercent/100*#battleNameArray)
	   local EPstring = ""
	   if colorLimitLetterEP ~= 0 then
		   local allianceColor = GetAllianceColor(2)
		   local EPcolor = "|c"..allianceColor:ToHex()
		   local arrayTostring, newArray = CyrHUD.charArrayToString(rest,#rest)
		   EPstring = EPcolor..arrayTostring.."|r"
		   rest = newArray
	   end
	   
	   -- colourise rest
	   local fullString = ADstring..DCstring..EPstring
	   name:SetText(fullString)
   end
      
end


function CyrHUD.Graveyard:updateLabel(label)
    local grave = CyrHUD.Graveyard[self.name]
	
	-- Graveyard icon
    label:getControl(L_ICON):SetTexture(grave.texture)
	label:getControl(L_ICON):SetColor(ZO_ColorDef:New(1,1,1,1):UnpackRGBA())
    label:positionControl(L_ICON, 20, 20, 8, 8)
	
    label:getControl(L_UA):SetHidden(true)
	label:getControl(L_LUMB):SetHidden(true)
	label:getControl(L_MINE):SetHidden(true)
	label:getControl(L_FARM):SetHidden(true)
    label:getControl(L_SCROLL):SetHidden(true)
	label:getControl(L_ATT_SIEGE):SetHidden(true)
	label:getControl(L_DEF_SIEGE):SetHidden(true)
	label:getControl(CYROCHAT_ICON):SetHidden(true)
    label:getControl(L_ATT_SIEGE_ICON):SetHidden(true)
	label:getControl(L_DEF_SIEGE_ICON):SetHidden(true)
	label:getControl(L_CONNECTED):SetHidden(true)
	label:getControl(L_HOLDER):SetHidden(true)
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
	
	label:getControl(L_NAME):SetHidden(false)
	label:getControl(L_ICON):SetHidden(false)
	label:getControl(L_TIME):SetHidden(false)
	
	label:getControl(LEGEND_KILLS):SetHidden(false)
    label:getControl(LEGEND_DEATHS):SetHidden(false)

    -- Graveyard name
	CyrHUD.SetColouredGraveyardName(label,grave)

    --Time
    label:getControl(L_TIME):SetText(self:getDuration())
	if grave.endGraveyard then 
        label:getControl(L_TIME):SetColor(CyrHUD.info[grave.winningAlliance].color:UnpackRGBA())
		local name = label:getControl(L_NAME)
		name:SetText(grave.name)
		name:SetColor(CyrHUD.info[grave.winningAlliance].color:UnpackRGBA())
	else
        label:getControl(L_TIME):SetColor(CyrHUD.info[ALLIANCE_NONE].color:UnpackRGBA())	
	end 
	
	local ADdeaths = grave.allianceDeaths[1]
	local EPdeaths = grave.allianceDeaths[2]
	local DCdeaths = grave.allianceDeaths[3]
	
	local ADkills = grave.allianceKills[1]
	local EPkills = grave.allianceKills[2]
	local DCkills = grave.allianceKills[3]
	
	label:getControl(L_KILLS_AD):SetText(ADkills)
	label:getControl(L_KILLS_EP):SetText(EPkills)
	label:getControl(L_KILLS_DC):SetText(DCkills)
	
	label:getControl(L_DEATHS_AD):SetText(ADdeaths)
	label:getControl(L_DEATHS_EP):SetText(EPdeaths)
	label:getControl(L_DEATHS_DC):SetText(DCdeaths)
	
	
	
	if ADkills < 10 then
	   label:positionControl(L_KILLS_AD, 28, 28, 235, 5) 
	elseif ADkills > 99 then 
	   label:positionControl(L_KILLS_AD, 28, 28, 227, 5)
	else
	   label:positionControl(L_KILLS_AD, 28, 28, 231, 5)
	end
	
	if EPkills < 10 then
	   label:positionControl(L_KILLS_EP, 28, 28, 211, 5) 
	elseif EPkills > 99 then 
	   label:positionControl(L_KILLS_EP, 28, 28, 203, 5) 
	else
	   label:positionControl(L_KILLS_EP, 28, 28, 207, 5)
	end
	
	if DCkills < 10 then
	   label:positionControl(L_KILLS_DC, 28, 28, 189, 5)
	elseif DCkills > 99 then 
	   label:positionControl(L_KILLS_DC, 28, 28, 181, 5)
	else
	   label:positionControl(L_KILLS_DC, 28, 28, 185, 5)
	end
	
	
	
	if ADdeaths < 10 then
	   label:positionControl(L_DEATHS_AD, 28, 28, 235, 20) 
	elseif ADdeaths > 99 then 
	   label:positionControl(L_DEATHS_AD, 28, 28, 227, 20)
	else
	   label:positionControl(L_DEATHS_AD, 28, 28, 231, 20)
	end
	
	if EPdeaths < 10 then
	   label:positionControl(L_DEATHS_EP, 28, 28, 211, 20) 
	elseif EPdeaths > 99 then 
	   label:positionControl(L_DEATHS_EP, 28, 28, 203, 20) 
	else
	   label:positionControl(L_DEATHS_EP, 28, 28, 207, 20)
	end
	
	if DCdeaths < 10 then
	   label:positionControl(L_DEATHS_DC, 28, 28, 189, 20)
	elseif DCdeaths > 99 then 
	   label:positionControl(L_DEATHS_DC, 28, 28, 181, 20)
	else
	   label:positionControl(L_DEATHS_DC, 28, 28, 185, 20)
	end





    label:getControl(L_KILLS_AD):SetHidden(ADkills < 1)
	label:getControl(L_KILLS_EP):SetHidden(EPkills < 1)
	label:getControl(L_KILLS_DC):SetHidden(DCkills < 1)
	
	label:getControl(L_ICON_DEATHS_AD):SetHidden(ADdeaths + ADkills < 1)  
	label:getControl(L_ICON_DEATHS_EP):SetHidden(EPdeaths + EPkills < 1)
	label:getControl(L_ICON_DEATHS_DC):SetHidden(DCdeaths + DCkills < 1)
    label:getControl(L_DEATHS_AD):SetHidden(ADdeaths < 1)
	label:getControl(L_DEATHS_EP):SetHidden(EPdeaths < 1)
	label:getControl(L_DEATHS_DC):SetHidden(DCdeaths < 1)

    --Background color
    label.main:SetCenterColor(self:getBGColor():UnpackRGBA())
	
	-- set waypoint or rallypoint on click
	label:getControl(L_NAME):SetMouseEnabled(false)
    -- label:getControl(L_NAME):SetHandler("OnMouseUp", function(_, button, upInside, ctrl, alt, shift, command)
        -- if upInside then
		     -- if self.nX ~= nil and self.nY ~= nil  then
			    -- CyrHUD:setWaypoint(self.nX, self.nY)
			 -- end
        -- end
    -- end)
end

----------------------------------------------
-- Model update
----------------------------------------------

function CyrHUD.Graveyard:update()
		local grave = CyrHUD.Graveyard[self.name]
        if self.endGraveyard then
            --Remove after time
            if GetDiffBetweenTimeStamps(GetTimeStamp(), self.endGraveyard) > 15 then
                CyrHUD.Graveyards[self.name] = nil
				
            end
		-- end graveyard after 5mn without kill
		elseif GetDiffBetweenTimeStamps(GetTimeStamp(), grave.lastUpdate) > 300 then
 		    self.endGraveyard = GetTimeStamp()
        end		

end

function CyrHUD.Graveyard:restart()
    self.endGraveyard = nil
end


----------------------------------------------
-- Getters
----------------------------------------------

--[[
    @return red, green, blue, alpha for background color
        all in range [0,1]
--]]
function CyrHUD.Graveyard:getBGColor()
    if self.endGraveyard then
        if self.winningAlliance == GetUnitAlliance("player") then
            return CyrHUD.info.defendedColor
        end

        return CyrHUD.info.endAttackColor
    end

    -- 20/07/2026 bug fix:
    -- This is the same bug already fixed elsewhere in the addon (see the
    -- 05/07/2026 notes in Battle.lua, PatrollingHorrors.lua, and
    -- MovingObjectives.lua): CyrHUD.info.newAttackColor:Lerp(...) was called
    -- during the first 60 seconds of a graveyard's life but its result was
    -- never returned or used, so the intended "flash red then fade to the
    -- normal background" effect never actually appeared for new graveyard
    -- entries -- this branch always fell through to defaultBGColor. This one
    -- was missed in that earlier pass. Restoring the return here, and using
    -- the same delta/60 fade duration the other three use (this was the only
    -- one of the four using delta/120, i.e. a fade twice as slow, which
    -- looks like a copy/paste slip rather than an intentional difference).
    local delta = GetDiffBetweenTimeStamps(GetTimeStamp(), self.startGraveyard)

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
function CyrHUD.Graveyard:getDuration()
    return CyrHUD.formatTime(GetDiffBetweenTimeStamps(self.endGraveyard or GetTimeStamp(), self.startGraveyard), false, true)
end
