-----------------------------------------------------------------------------
-- 					      									               --
-- 	Title:		 Tamriel Chronos                    					   --
--	Description: Tamriel Time and astronomical data                        --
--	Author: 	 Gandalf (@Gandalf2675)									   --
-- 					      									               --
-----------------------------------------------------------------------------

local name     = "monD"
local setup    = {
		  name             = name,
		  longName         = GetString(SI_TACHRONOS_MODE_monD),
		  description      = GetString(SI_TACHRONOS_DESC_monD),
		  choiceIcn        = "TamrielChronos/clocks/monD/dds/choiceMonD.dds",
		  tlc              = { x=220, y=48 },  
          supportedOptions = { 
							   timeColor = true, 
							   realTime  = true, 
							   showSecs  = true, 
							   font      = true
							 },
                  }					
local defaults =  { [name] = { 
				     scale = 1.0, 
				     p     = TOPLEFT, 
				     p     = TOPLEFT, 
				     x     = 0, 
				     y     = 0, 
				     secs  = true, 
				     tc    = {r=1,g=1,b=1,a=1}, 
				     real  = false,
				     font  = {type="Univers 57", size=32, style="soft-shadow-thick"} 
				  	}
           		  }

TaChronos.clocks[name]     = TaChronos.clocks[name] or TaChronos.clockBaseObject:New(setup, defaults)
local clock                = TaChronos.clocks[name]
local clockXshift          = 92
local clockYshift          = 12
 

function clock:CreateClock()
	local wm  = GetWindowManager() 
	local cnf = TaChronos.cm:GetClockConf(self.name)

	-- Moons 
	local masser, secunda = TaChronos.moon:GetData()
	self.masser = wm:CreateControl("TaChronos_moD_masser_"..self.name, self.base, CT_TEXTURE)
	self.masser:SetAnchor(TOPLEFT, self.base, TOPLFT, 0, 16)
	self.masser:SetAlpha(1)
	self.masser:SetTexture(masser)
	self.masser:SetDimensions(48, 48)
	self.masser:SetDrawLayer(DL_CONTROLS)
	--
	self.secunda = wm:CreateControl("TaChronos_moD_secunda_"..self.name, self.base, CT_TEXTURE)
	self.secunda:SetAnchor(TOPLEFT, self.base, TOPLEFT, 42, 0)
	self.secunda:SetAlpha(1)
	self.secunda:SetTexture(secunda)
	self.secunda:SetDimensions(48, 48)
	self.secunda:SetDrawLayer(DL_CONTROLS)
	
	-- Tamriel clock digital
	self.time   = wm:CreateControl("TaChronos_Time_"..self.name, self.base, CT_LABEL)
	self.time:SetAnchor(TOPLEFT, self.base, TOPLEFT, clockXshift, clockYshift)
	self.time:SetColor(cnf.tc.r, cnf.tc.g, cnf.tc.b, cnf.tc.a)
	self.time:SetFont(TaChronos.cm:GetFontPath(cnf.font.type).."|"..cnf.font.size.."|"..cnf.font.style)
	self.time:SetDimensions(self.x, self.y)
	self.time:SetVerticalAlignment(TEXT_ALIGN_TOP)
	self.time:SetHorizontalAlignment(TEXT_ALIGN_LEFT)	
end


function clock:UpdateClock()
	local cnf = TaChronos.cm:GetClockConf(self.name)
		
	-- Moon phases 
	local masser, secunda, rotation = TaChronos.moon:GetData()
	self.masser:SetTexture(masser)
	self.masser:SetTextureRotation(-math.rad(rotation), 0.5, 0.5)
	self.secunda:SetTexture(secunda)
	self.secunda:SetTextureRotation(-math.rad(rotation), 0.5, 0.5)

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
