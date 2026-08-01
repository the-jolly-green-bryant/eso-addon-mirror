-----------------------------------------------------------------------------
-- 					      									               --
-- 	Title:		 Tamriel Chronos                    					   --
--	Description: Tamriel Time and astronomical data                        --
--	Author: 	 Gandalf (@Gandalf2675)									   --
-- 					      									               --
-----------------------------------------------------------------------------

local name     = "dualA"
local setup    = {
		  name             = name,
		  longName         = GetString(SI_TACHRONOS_MODE_dualA),
		  description      = GetString(SI_TACHRONOS_DESC_dualA),
		  choiceIcn        = "TamrielChronos/clocks/dualA/dds/choiceDualA.dds",
		  tlc              = { x=200, y=200 },  
          supportedOptions = { 
							   timeColor = false, 
							   realTime  = false, 
							   showSecs  = false, 
							   font      = false
							 },
                  }					
local defaults =  { [name] = { 
				     scale = 0.8, 
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

local texDay               = "TamrielChronos/clocks/dualA/dds/dualA.dds"
local texNight             = "TamrielChronos/clocks/dualA/dds/dualANight.dds"
local handHour             = "TamrielChronos/clocks/base/dds/handHour.dds"
local handMinute           = "TamrielChronos/clocks/base/dds/handMinute.dds"
local analogScale          = 0.22
local analogYshift         = 0.16
  	
  	
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
	self.masser = wm:CreateControl("TaChronos_dualA_masser_"..self.name, self.base, CT_TEXTURE)
	self.masser:SetAnchor(CENTER, self.base, CENTER, -14, -28)
	self.masser:SetAlpha(.8)
	self.masser:SetTexture(masser)
	self.masser:SetDimensions(self.x/400*64, self.y/400*64)
	self.masser:SetDrawLayer(DL_CONTROLS)
	--
	self.secunda = wm:CreateControl("TaChronos_dualA_secunda_"..self.name, self.base, CT_TEXTURE)
	self.secunda:SetAnchor(CENTER, self.base, CENTER, 14, -37)
	self.secunda:SetAlpha(.8)
	self.secunda:SetTexture(secunda)
	self.secunda:SetDimensions(self.x/400*64, self.y/400*64)
	self.secunda:SetDrawLayer(DL_CONTROLS)
	
	-- Small Real clock analog 12h -- hours
	self.handHR = wm:CreateControl("TaChronos_HandHR_"..self.name, self.base, CT_TEXTURE)
	self.handHR:SetTexture(handHour)
	self.handHR:SetDimensions(self.x*analogScale*3, self.y*analogScale)
	self.handHR:SetAnchor(CENTER, self.base, CENTER, 0 ,self.y*analogYshift)
	self.handHR:SetDrawLayer(DL_CONTROLS)	
	
	-- Small Real clock analog 12h -- minutes
	self.handMR = wm:CreateControl("TaChronos_HandMR_"..self.name, self.base, CT_TEXTURE)
	self.handMR:SetTexture(handMinute)
	self.handMR:SetDimensions(self.x*analogScale*3, self.y*analogScale)
	self.handMR:SetAnchor(CENTER, self.base, CENTER, 0 ,self.y*analogYshift)
	self.handMR:SetDrawLayer(DL_CONTROLS)	
	
	-- Main Tamriel clock analog 12h -- hours
	self.handH = wm:CreateControl("TaChronos_HandH_"..self.name, self.base, CT_TEXTURE)
	self.handH:SetTexture(handHour)
	self.handH:SetDimensions(self.x, self.y)
	self.handH:SetAnchor(CENTER, self.base, CENTER, 0 ,0)
	self.handH:SetDrawLayer(DL_OVERLAY)	

	-- Main Tamriel clock analog 12h - minutes
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

	-- Set day/night clock face
	local tex = texDay  
	if h <= 3 then
		tex = texNight
	elseif h >= 15 then
		tex = texNight
	end
	self.face:SetCenterTexture(tex)
	
	-- Earth time
	local tString, h, m, s = TaChronos.sun:GetEarthTime(cnf.secs)		
	self.handMR:SetTextureRotation(-math.rad((m+s/60)*360/60),        0.5, 0.5)
	self.handHR:SetTextureRotation(-math.rad((h+m/60+s/3600)*360/12), 0.5, 0.5)
end
