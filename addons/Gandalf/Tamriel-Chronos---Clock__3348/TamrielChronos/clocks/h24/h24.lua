-----------------------------------------------------------------------------
-- 					      									               --
-- 	Title:		 Tamriel Chronos                    					   --
--	Description: Tamriel Time and astronomical data                        --
--	Author: 	 Gandalf (@Gandalf2675)									   --
-- 					      									               --
-----------------------------------------------------------------------------

local name     = "h24"
local setup    = {
		  name             = name,
		  longName         = GetString(SI_TACHRONOS_MODE_h24),
		  description      = GetString(SI_TACHRONOS_DESC_h24),
		  choiceIcn        = "TamrielChronos/clocks/h24/dds/choiceH24.dds",
		  tlc              = { x=200, y=200 },  
          supportedOptions = { 
							   timeColor = false, 
							   realTime  = true, 
							   showSecs  = true, 
							   font      = false
							 },
                  }					
local defaults =  { [name] = { 
				     scale = 0.72, 
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

local tex_base             = "TamrielChronos/clocks/h24/dds/"
local clockDay             = tex_base.."clockDay.dds"
local clockDay2103         = tex_base.."clockDay2103.dds"
local clockNight2202       = tex_base.."clockNight2202.dds"
local clockNight2301       = tex_base.."clockNight2301.dds"
local clockNight2400       = tex_base.."clockNight2400.dds"	

local handDay			   = tex_base.."handDay.dds"
local handNight			   = tex_base.."handNight.dds"

local digitalYshift        = 0.15

  	
function clock:CreateClock()
	local wm  = GetWindowManager() 
	local cnf = TaChronos.cm:GetClockConf(self.name)
		
	-- Clock face	
	self.face = wm:CreateControl("TaChronos_Face_"..self.name, self.base, CT_BACKDROP)	
	self.face:SetAnchor(CENTER, self.base, CENTER, 0, 0)
	self.face:SetAlpha(1)
	self.face:SetEdgeColor( 0.0 , 0.0, 0.0, 0.0)
	self.face:SetCenterTexture(clockDay)
	self.face:SetDimensions(self.x, self.y)
	self.face:SetDrawLayer(DL_BACKGROUND)
			
	-- Moons 
	local masser, secunda = TaChronos.moon:GetData()
	self.masser = wm:CreateControl("TaChronos_h_24_masser_"..self.name, self.base, CT_TEXTURE)
	self.masser:SetAnchor(CENTER, self.base, CENTER, -14, -28)
	self.masser:SetAlpha(.8)
	self.masser:SetTexture(masser)
	self.masser:SetDimensions(self.x/400*64, self.y/400*64)
	self.masser:SetDrawLayer(DL_CONTROLS)
	--
	self.secunda = wm:CreateControl("TaChronos_h24_secunda_"..self.name, self.base, CT_TEXTURE)
	self.secunda:SetAnchor(CENTER, self.base, CENTER, 14, -37)
	self.secunda:SetAlpha(.8)
	self.secunda:SetTexture(secunda)
	self.secunda:SetDimensions(self.x/400*64, self.y/400*64)
	self.secunda:SetDrawLayer(DL_CONTROLS)
	
	-- Tamriel clock digital
	local fontT = "$(BOLD_FONT)|$(KB_24)|soft-shadow-thin"
	self.time   = wm:CreateControl("TaChronos_Time_"..self.name, self.base, CT_LABEL)
	self.time:SetColor(1, 1, 1, 1)
	self.time:SetFont(fontT)
	self.time:SetDimensions(self.x,30)
	self.time:SetVerticalAlignment(TEXT_ALIGN_CENTER)
	self.time:SetHorizontalAlignment(TEXT_ALIGN_CENTER)	
	self.time:SetAnchor(CENTER, self.base, CENTER, 0, self.y*digitalYshift)

	-- Tamriel clock analog 24h
	self.handD = wm:CreateControl("TaChronos_HandD_"..self.name, self.base, CT_TEXTURE)
	self.handD:SetTexture(handDay)
	self.handD:SetDimensions(self.x, self.y)
	self.handD:SetAnchor(CENTER, self.base, CENTER, 0 ,0)
	self.handD:SetDrawLayer(DL_OVERLAY)	
end


function clock:UpdateClock()
	local cnf = TaChronos.cm:GetClockConf(self.name)

	-- Moon phases 
	local masser, secunda, rotation = TaChronos.moon:GetData()
	self.masser:SetTexture(masser)
	self.masser:SetTextureRotation(-math.rad(rotation), 0.5, 0.5)
	self.secunda:SetTexture(secunda)
	self.secunda:SetTextureRotation(-math.rad(rotation), 0.5, 0.5)

	-- Update digital time
	local tString, h, m, s = TaChronos.sun:GetTamrielTime(cnf.secs)		
	if not cnf.real then
		self.time:SetText(tString)
	else
		self.time:SetText(TaChronos.sun:GetEarthTime(cnf.secs))
	end
	
	-- Update Tamriel analog 24h clock
	local rad = (h*60+m+s*1/60)*math.rad(0.25)  -- rad per min: 360/24/60 
	self.handD:SetTextureRotation(-rad, 0.5, 0.5)

	-- Set day/night clock face
	if h >= 21 and h < 22 then
		self.face:SetCenterTexture(clockDay2103) 
	elseif h >= 22 and h < 23 then
		self.face:SetCenterTexture(clockNight2202) 
	elseif h >= 23 and h < 24 then
		self.face:SetCenterTexture(clockNight2301) 
	elseif h >= 00 and h < 01 then
		self.face:SetCenterTexture(clockNight2400) 	
	elseif h >= 01 and h < 02 then
		self.face:SetCenterTexture(clockNight2301) 
	elseif h >= 02 and h < 03 then
		self.face:SetCenterTexture(clockNight2202) 
	elseif h >= 03 and h < 04 then
		self.face:SetCenterTexture(clockDay2103) 
	else	
		self.face:SetCenterTexture(clockDay) 
	end
		
	-- Set day/night clock hand
	if h < 22 and h >=3 then
		self.handD:SetTexture(handDay)
	else
		self.handD:SetTexture(handNight)	
	end
end


function clock:ScaleClock(scale)
	self.time:SetAnchor(CENTER, self.base, CENTER, 0, self.y*digitalYshift*scale)
end

