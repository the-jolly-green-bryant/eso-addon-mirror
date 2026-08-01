-----------------------------------------------------------------------------
-- 					      									               --
-- 	Title:		 Tamriel Chronos                    					   --
--	Description: Tamriel Time and astronomical data                        --
--	Author: 	 Gandalf (@Gandalf2675)									   --
-- 					      									               --
-----------------------------------------------------------------------------

local name     = "e24"
local setup    = {
		  name             = name,
		  longName         = GetString(SI_TACHRONOS_MODE_e24),
		  description      = GetString(SI_TACHRONOS_DESC_e24),
		  choiceIcn        = "TamrielChronos/clocks/e24/dds/choiceE24.dds",
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

local tex_base             = "TamrielChronos/clocks/e24/dds/"
local clockDay             = tex_base.."baseDay.dds"
local clockNight           = tex_base.."baseNight.dds"

local clockScale           = tex_base.."scale.dds"

local nightsDay            = tex_base.."nightsDay.dds"
local nightsNight          = tex_base.."nightsNight.dds"	

local handDay			   = tex_base.."handDay.dds"
local handNight			   = tex_base.."handNight.dds"

local digitalYshift        = 0.15

local SECONDS_PER_TAMRIEL_NIGHT = TaChronos.const.SECONDS_PER_TAMRIEL_NIGHT

  	
function clock:CreateClock()
	local wm  = GetWindowManager() 
	local cnf = TaChronos.cm:GetClockConf(self.name)
		
	-- Clock base	
	self.face = wm:CreateControl("TaChronos_Face_"..self.name, self.base, CT_BACKDROP)	
	self.face:SetAnchor(CENTER, self.base, CENTER, 0, 0)
	self.face:SetAlpha(1)
	self.face:SetEdgeColor( 0.0 , 0.0, 0.0, 0.0)
	self.face:SetCenterTexture(clockDay)
	self.face:SetDimensions(self.x, self.y)
	self.face:SetDrawLayer(DL_BACKGROUND)
			
	-- Tamriel Night overlay	
	self.over = wm:CreateControl("TaChronos_NightOL_"..self.name, self.base, CT_TEXTURE)	
	self.over:SetAnchor(CENTER, self.base, CENTER, 0, 0)
	self.over:SetTexture(nightsDay)
	self.over:SetDimensions(self.x, self.y)

	-- Clock Scale	
	self.cscale = wm:CreateControl("TaChronos_ClockScale_"..self.name, self.base, CT_BACKDROP)	
	self.cscale:SetAnchor(CENTER, self.base, CENTER, 0, 0)
	self.cscale:SetAlpha(1)
	self.cscale:SetEdgeColor( 0.0 , 0.0, 0.0, 0.0)
	self.cscale:SetCenterTexture(clockScale)
	self.cscale:SetDimensions(self.x, self.y)

	-- Moons 
	local masser, secunda = TaChronos.moon:GetData()
	self.masser = wm:CreateControl("TaChronos_e24_masser_"..self.name, self.base, CT_TEXTURE)
	self.masser:SetAnchor(CENTER, self.base, CENTER, -14, -28)
	self.masser:SetAlpha(.8)
	self.masser:SetTexture(masser)
	self.masser:SetDimensions(self.x/400*64, self.y/400*64)
	self.masser:SetDrawLayer(DL_CONTROLS)
	--
	self.secunda = wm:CreateControl("TaChronos_e24ésecunda_"..self.name, self.base, CT_TEXTURE)
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

	-- Earth clock analog 24h
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
	local tString, ht, mt, st = TaChronos.sun:GetTamrielTime(cnf.secs)	
	local eString, he, me, se = TaChronos.sun:GetEarthTime(cnf.secs)
		
	if not cnf.real then
		self.time:SetText(tString)
	else
		self.time:SetText(eString)
	end
	
	-- Update Earth analog 24h clock
	local rad = (he*60+me+se*1/60)*math.rad(0.25)  -- rad per min: 360/24/60 
	self.handD:SetTextureRotation(-rad, 0.5, 0.5)

	-- Set day/night clock face
	if ht >= 03 and ht < 22 then
		self.face:SetCenterTexture(clockDay)
		self.over:SetTexture(nightsDay) 
		self.handD:SetTexture(handDay)
	else	
		self.face:SetCenterTexture(clockNight) 
		self.over:SetTexture(nightsNight) 
		self.handD:SetTexture(handNight)
	end
	
	-- Adjust Tamriel Nights overlay
	local p1, p2, secSet, secRise = TaChronos.sun:GetData()
	if secSet > secRise then secSet = secRise-SECONDS_PER_TAMRIEL_NIGHT end -- sunset is already happened
	local sec = he*3600+me*60+se+secSet
	local deg = 360*sec/(24*3600)
	self.over:SetTextureRotation(-math.rad(deg))
		
end
