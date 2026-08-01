-----------------------------------------------------------------------------
-- 					      									               --
-- 	Title:		 Tamriel Chronos                    					   --
--	Description: Tamriel Time and astronomical data                        --
--	Author: 	 Gandalf (@Gandalf2675)									   --
-- 					      									               --
-----------------------------------------------------------------------------

local name     = "dualD"
local setup    = {
		  name             = name,
		  longName         = GetString(SI_TACHRONOS_MODE_dualD),
		  description      = GetString(SI_TACHRONOS_DESC_dualD),
		  choiceIcn        = "TamrielChronos/clocks/dualD/dds/choiceDualD.dds",
		  tlc              = { x=200, y=200 },  
          supportedOptions = { 
							   timeColor = false, 
							   realTime  = true, 
							   showSecs  = true, 
							   font      = false
							 },
                  }					
local defaults =  { [name] = { 
				     scale = 0.6, 
				     p     = CENTER, 
				     p     = CENTER, 
				     x     = 0, 
				     y     = 0, 
				     secs  = false, 
				     tc    = {r=1,g=1,b=1,a=1}, 
				     real  = true,
				     font  = {type="Univers 67", size=24, style="soft-shadow-thin"} 
				  	}
           		  }
  
TaChronos.clocks[name]     = TaChronos.clocks[name] or TaChronos.clockBaseObject:New(setup, defaults)
local clock                = TaChronos.clocks[name]

local texDay               = "TamrielChronos/clocks/dualD/dds/dualD.dds"
local texNight             = "TamrielChronos/clocks/dualD/dds/dualDNight.dds"
local handHour             = "TamrielChronos/clocks/base/dds/handHour.dds"
local handMinute           = "TamrielChronos/clocks/base/dds/handMinute.dds"
local digitalYshift        = 0.16

	
function clock:CreateClock()
	local wm  = GetWindowManager() 
	local cnf = TaChronos.cm:GetClockConf(self.name)
		
	-- Clock face	
	self.face = wm:CreateControl("TaChronos_Face_"..self.name, self.base, CT_BACKDROP)	
	self.face:SetAnchor(CENTER, self.base, CENTER, 0, 0)
	self.face:SetAlpha(1)
	self.face:SetEdgeColor( 0.0 , 0.0, 0.0, 0.0)
	self.face:SetCenterTexture(texDay)
	self.face:SetDimensions(self.x, self.y)
	self.face:SetDrawLayer(DL_BACKGROUND)
	
	-- Moons 
	local masser, secunda = TaChronos.moon:GetData()
	self.masser = wm:CreateControl("TaChronos_dualD_masser_"..self.name, self.base, CT_TEXTURE)
	self.masser:SetAnchor(CENTER, self.base, CENTER, -14, -28)
	self.masser:SetAlpha(.8)
	self.masser:SetTexture(masser)
	self.masser:SetDimensions(self.x/400*64, self.y/400*64)
	self.masser:SetDrawLayer(DL_CONTROLS)
	--
	self.secunda = wm:CreateControl("TaChronos_dualD_secunda_"..self.name, self.base, CT_TEXTURE)
	self.secunda:SetAnchor(CENTER, self.base, CENTER, 14, -37)
	self.secunda:SetAlpha(.8)
	self.secunda:SetTexture(secunda)
	self.secunda:SetDimensions(self.x/400*64, self.y/400*64)
	self.secunda:SetDrawLayer(DL_CONTROLS)

	-- Real clock digital
	local fontT = "$(BOLD_FONT)|$(KB_24)|soft-shadow-thin"
	self.time   = wm:CreateControl("TaChronos_Time_"..self.name, self.base, CT_LABEL)
	self.time:SetColor(1, 1, 1, 1)
	self.time:SetFont(fontT)
	self.time:SetDimensions(self.x,30)
	self.time:SetVerticalAlignment(TEXT_ALIGN_CENTER)
	self.time:SetHorizontalAlignment(TEXT_ALIGN_CENTER)	
	self.time:SetAnchor(CENTER, self.base, CENTER, 0, self.y*digitalYshift)
	self.time:SetDrawLayer(DL_BACKGROUND)

	-- Tamriel clock analog 12h -- hours
	self.handH = wm:CreateControl("TaChronos_HandH_"..self.name, self.base, CT_TEXTURE)
	self.handH:SetTexture(handHour)
	self.handH:SetDimensions(self.x, self.y)
	self.handH:SetAnchor(CENTER, self.base, CENTER, 0 ,0)
	self.handH:SetDrawLayer(DL_OVERLAY)	

	-- Tamriel clock analog 12h - minutes
	self.handM = wm:CreateControl("TaChronos_HandM_"..self.name, self.base, CT_TEXTURE)
	self.handM:SetTexture(handMinute)
	self.handM:SetDimensions(self.x, self.y)
	self.handM:SetAnchor(CENTER, self.base, CENTER, 0 ,0)
	self.handM:SetDrawLayer(DL_OVERLAY)		
end


function clock:UpdateClock()
	local cnf = TaChronos.cm:GetClockConf(self.name)

	-- Moon phases 
	local masser, secunda, rotation = TaChronos.moon:GetData()
	self.masser:SetTexture(masser)
	self.masser:SetTextureRotation(-math.rad(rotation), 0.5, 0.5)
	self.secunda:SetTexture(secunda)
	self.secunda:SetTextureRotation(-math.rad(rotation), 0.5, 0.5)
	
	-- Tamriel time
	local tString, h, m, s = TaChronos.sun:GetTamrielTime(cnf.secs)		
	self.handM:SetTextureRotation(-math.rad((m+s/60)*360/60),        0.5, 0.5)
	self.handH:SetTextureRotation(-math.rad((h+m/60+s/3600)*360/12), 0.5, 0.5)

	-- Set the day/night clock face
	local tex = texDay  
	if h <= 3 then
		tex = texNight
	elseif h >= 15 then
		tex = texNight
	end
	self.face:SetCenterTexture(tex)
		
	-- Update digital time
	if not cnf.real then
		self.time:SetText(tString)
	else
		self.time:SetText(TaChronos.sun:GetEarthTime(cnf.secs))
	end
end
