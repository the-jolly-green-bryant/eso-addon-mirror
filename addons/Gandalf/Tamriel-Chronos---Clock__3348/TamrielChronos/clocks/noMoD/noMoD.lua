-----------------------------------------------------------------------------
-- 					      									               --
-- 	Title:		 Tamriel Chronos                    					   --
--	Description: Tamriel Time and astronomical data                        --
--	Author: 	 Gandalf (@Gandalf2675)									   --
-- 					      									               --
-----------------------------------------------------------------------------

local name     = "noMoD"
local setup    = {
		  name             = name,
		  longName         = GetString(SI_TACHRONOS_MODE_noMoD),
		  description      = GetString(SI_TACHRONOS_DESC_noMoD),
		  choiceIcn        = "TamrielChronos/clocks/noMoD/dds/choiceNoMoD.dds",
		  tlc              = { x=200, y=50 },  
          supportedOptions = { 
							   timeColor = true, 
							   realTime  = true, 
							   showSecs  = true, 
							   font      = true
							 },
                  }					
local defaults =  { [name] = { 
				     scale = 1.0, 
				     p     = CENTER, 
				     p     = CENTER, 
				     x     = 0, 
				     y     = 0, 
				     secs  = true, 
				     tc    = {r=1,g=1,b=1,a=1}, 
				     real  = false,
				     font  = {type="Univers 57", size=32, style="soft-shadow-thick"} 
				  	}
           		  }

TaChronos.clocks[name] = TaChronos.clocks[name] or TaChronos.clockBaseObject:New(setup, defaults)
local clock            = TaChronos.clocks[name]
 

function clock:CreateClock()
	local wm  = GetWindowManager() 
	local cnf = TaChronos.cm:GetClockConf(self.name)
	
	-- Tamriel clock digital
	self.time   = wm:CreateControl("TaChronos_Time_"..self.name, self.base, CT_LABEL)
	self.time:SetAnchor(CENTER, self.base, CENTER, 0, 0)
	self.time:SetColor(cnf.tc.r, cnf.tc.g, cnf.tc.b, cnf.tc.a)
	self.time:SetFont(TaChronos.cm:GetFontPath(cnf.font.type).."|"..cnf.font.size.."|"..cnf.font.style)
	self.time:SetDimensions(self.x, self.y)
	self.time:SetVerticalAlignment(TEXT_ALIGN_TOP)
	self.time:SetHorizontalAlignment(TEXT_ALIGN_LEFT)	
end


function clock:UpdateClock()
	local cnf = TaChronos.cm:GetClockConf(self.name)
		
	local tString, h, m = TaChronos.sun:GetTamrielTime(cnf.secs)
	if not cnf.real then
		self.time:SetText(tString)
	else
		self.time:SetText(TaChronos.sun:GetEarthTime(cnf.secs))
	end
end

function clock:UpdateFont()
	local cnf = TaChronos.cm:GetClockConf(self.name)
	self.time:SetFont(TaChronos.cm:GetFontPath(cnf.font.type).."|"..cnf.font.size.."|"..cnf.font.style)
end

