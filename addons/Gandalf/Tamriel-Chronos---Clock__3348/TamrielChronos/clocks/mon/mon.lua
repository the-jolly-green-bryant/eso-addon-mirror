-----------------------------------------------------------------------------
-- 					      									               --
-- 	Title:		 Tamriel Chronos                    					   --
--	Description: Tamriel Time and astronomical data                        --
--	Author: 	 Gandalf (@Gandalf2675)									   --
-- 					      									               --
-----------------------------------------------------------------------------

local name     = "mon"
local setup    = {
		  name             = name,
		  longName         = GetString(SI_TACHRONOS_MODE_mon),
		  description      = GetString(SI_TACHRONOS_DESC_mon),
		  choiceIcn        = "TamrielChronos/clocks/mon/dds/choiceMon.dds",
		  tlc              = { x=64, y=64 },  
          supportedOptions = { 
							   timeColor = false, 
							   realTime  = false, 
							   showSecs  = false, 
							   font      = false
							 },
                  }					
local defaults =  { [name] = { 
				     scale = 1.0, 
				     p     = CENTER, 
				     p     = CENTER, 
				     x     = 0, 
				     y     = 0, 
				     secs  = false, 
				     tc    = {r=1,g=1,b=1,a=1}, 
				     real  = false,
				     font  = {type="Univers 57", size=32, style="soft-shadow-thick"} 
				  	}
           		  }

TaChronos.clocks[name] = TaChronos.clocks[name] or TaChronos.clockBaseObject:New(setup, defaults)
local clock            = TaChronos.clocks[name]
 

function clock:CreateClock()
	local wm = GetWindowManager() 
	
	-- Moon phases 
	-- Moons 
	local masser, secunda = TaChronos.moon:GetData()
	self.masser = wm:CreateControl("TaChronos_mo_masser_"..self.name, self.base, CT_TEXTURE)
	self.masser:SetAnchor(CENTER, self.base, CENTER, -16, 0)
	self.masser:SetAlpha(1)
	self.masser:SetTexture(masser)
	self.masser:SetDimensions(64, 64)
	self.masser:SetDrawLayer(DL_CONTROLS)
	--
	self.secunda = wm:CreateControl("TaChronos_mo_secunda_"..self.name, self.base, CT_TEXTURE)
	self.secunda:SetAnchor(CENTER, self.base, CENTER, 40, -18)
	self.secunda:SetAlpha(1)
	self.secunda:SetTexture(secunda)
	self.secunda:SetDimensions(64, 64)
	self.secunda:SetDrawLayer(DL_CONTROLS)
end


function clock:UpdateClock()
	-- Moon phases 
	local masser, secunda, rotation = TaChronos.moon:GetData()
	self.masser:SetTexture(masser)
	self.masser:SetTextureRotation(-math.rad(rotation), 0.5, 0.5)
	self.secunda:SetTexture(secunda)
	self.secunda:SetTextureRotation(-math.rad(rotation), 0.5, 0.5)

end

