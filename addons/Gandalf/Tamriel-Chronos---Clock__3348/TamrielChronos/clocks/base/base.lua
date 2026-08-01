-----------------------------------------------------------------------------
-- 					      									               --
-- 	Title:		 Tamriel Chronos                    					   --
--	Description: Tamriel Time and astronomical data                        --
--	Author: 	 Gandalf (@Gandalf2675)									   --
-- 					      									               --
-----------------------------------------------------------------------------

TaChronos.clockBaseObject  = ZO_Object:Subclass()
local cbo                  = TaChronos.clockBaseObject

function cbo:New(setup, defaults)
    local clock            = ZO_Object.New(self)
    clock.name             = setup.name
    clock.longName         = setup.longName    or "long name missing"
    clock.description      = setup.description or "description missing"
    clock.x                = setup.tlc.x
    clock.y                = setup.tlc.y
    clock.supportedOptions = setup.supportedOptions
    clock.choiceIcn        = setup.choiceIcn
    clock.defaults         = defaults
    return clock
end

-- cm.lua checks
function cbo:IsDisabledTc()   return not self.supportedOptions.timeColor end   -- colors of time can be set
function cbo:IsDisabledReal() return not self.supportedOptions.realTime  end   -- switching tamriel clock to real clock possible  	
function cbo:IsDisabledSecs() return not self.supportedOptions.showSecs  end   -- display of seconds can be toggled on/off
function cbo:IsDisabledFont() return not self.supportedOptions.font      end   -- can Change font

function cbo:Initialize()
	local cnf = TaChronos.cm:GetClockConf(self.name)
	self:CreateBase()			-- Create TLW
	self:CreateClock()			-- Create the clock
	self:SetScale(cnf.scale)    -- Adjust the size to the config	
	self:Add()					-- Create a fragment and add to scenes 
end

function cbo:Update()	
	if TaChronos.cm:GetClockMode() ~= self.name then return end -- this clock is not active
	self:UpdateClock()
end

function cbo:CreateBase()
	local wm  = GetWindowManager() 
	local cnf = TaChronos.cm:GetClockConf(self.name)

	self.base = wm:CreateTopLevelWindow("TaChronos_Base_"..self.name)
	self.base:SetDimensions(self.x, self.y)
	self.base:SetMovable(true)
	self.base:SetMouseEnabled(true)
	self.base:SetClampedToScreen(true)
	self.base:SetAnchor(cnf.p, GuiRoot, cnf.rp, cnf.x, cnf.y)
	self.base:SetHandler("OnMouseEnter", function(info) self:ShowTooltip(info) end) 
	self.base:SetHandler("OnMouseExit",  function() ClearTooltip(InformationTooltip) end)
	self.base:SetHandler("OnMouseUp",
							function() 
								_, cnf.p, _, cnf.rp, cnf.x, cnf.y = self.base:GetAnchor() 
							end
					  	 )
	self.base:SetHandler("OnMouseDown", function(info, button) self:OnMouseDown(button) end) 
	self.base:SetHandler("OnMouseDoubleClick", function(info) self:OnMouseDoubleClick() end) 
end

function cbo:SetScale(scale)
	self.base:SetScale(scale)
end

function cbo:ZoomIn()
	self:SetScale(2.0)
end

function cbo:ZoomOut()
	local cnf = TaChronos.cm:GetClockConf(self.name)
	self:SetScale(cnf.scale)
end

function cbo:UpdateFont()
	-- place holder, needs to be addressed in the clock object
end

function cbo:Refresh()
	self.fragment:Refresh()
end

function cbo:Add()
	local function HideFragment()
		local visible = true 
		if 		   TaChronos.cm:GetClockMode() ~= self.name then visible = false 
			elseif TaChronos:IsClockHidden() == true        then visible = false
		end
		return visible
	end
	local fragment = ZO_HUDFadeSceneFragment:New(self.base)
	HUD_SCENE:AddFragment(fragment)
	HUD_UI_SCENE:AddFragment(fragment)
	GAME_MENU_SCENE:AddFragment(fragment)
	fragment:SetConditional(function() return HideFragment() end)
	self.fragment = fragment									   	
end

function cbo:ShowTooltip(info)
	local fontTitle   = "$(BOLD_FONT)|$(KB_22)|soft-shadow-thin"
	local fontRelease = "$(MEDIUM_FONT)|$(KB_11)|soft-shadow-thin"
	local fontInfo    = "EsoUI/Common/Fonts/consola.ttf".."|12"
	local ttTxt       = ""
	
	local tex1, tex2, rot, phase, rPhase, fMoon, nMoon, nPhase = TaChronos.moon:GetData()
	local sunset, sunrise, secSet, secRise = TaChronos.sun:GetData()    
	local tPhase = TaChronos.moon:GetPhaseStr(phase, nPhase)


	InitializeTooltip(InformationTooltip, info, CENTER, 0, 100, BOTTOMRIGHT)
	InformationTooltip:AddLine(TaChronos.ADDON_TITLE, fontTitle, 222/255, 222/255, 192/255, CENTER)
	InformationTooltip:AddVerticalPadding(-10)
	
	InformationTooltip:AddLine(TaChronos.RELEASESTRING, fontRelease, ZO_TOOLTIP_DEFAULT_COLOR:UnpackRGB(), CENTER)
	InformationTooltip:AddVerticalPadding(-10)
	
	local withSecs = true
	local st, hE,  mE,  sE , ddE, moE, yyE = TaChronos.sun:GetEarthTime(withSecs)
	local st, hT,  mT,  sT  = TaChronos.sun:GetTamrielTime(withSecs)
	local st, ddT, moT, yyT = TaChronos.sun:GetTamrielDate()
	local tt = ZO_FormatTime(hT*3600+mT*60+sT, TIME_FORMAT_STYLE_CLOCK_TIME, TIME_FORMAT_PRECISION_TWENTY_FOUR_HOUR)
	local rt = ZO_FormatTime(hE*3600+mE*60+sE, TIME_FORMAT_STYLE_CLOCK_TIME, TIME_FORMAT_PRECISION_TWENTY_FOUR_HOUR)
	ttTxt = string.format(GetString(SI_TACHRONOS_T_TITLE))
		  ..string.format(GetString(SI_TACHRONOS_T_REAL),    rt, ddE, moE, yyE)
		  ..string.format(GetString(SI_TACHRONOS_T_TAMRIEL), tt, ddT, moT, yyT)
	
	local setTime  = ZO_FormatTime(GetSecondsSinceMidnight()%(24*3600)+secSet,  TIME_FORMAT_STYLE_CLOCK_TIME, TIME_FORMAT_PRECISION_TWENTY_FOUR_HOUR)
	local riseTime = ZO_FormatTime(GetSecondsSinceMidnight()%(24*3600)+secRise, TIME_FORMAT_STYLE_CLOCK_TIME, TIME_FORMAT_PRECISION_TWENTY_FOUR_HOUR)
	ttTxt = ttTxt..GetString(SI_TACHRONOS_M_TITLE)
			..string.format(GetString(SI_TACHRONOS_M_LEVEL), rPhase)
			..string.format(GetString(SI_TACHRONOS_M_PHASE), phase, tPhase)	
			..GetString(SI_TACHRONOS_E_TITLE)
			..GetString(SI_TACHRONOS_E_SUNSET)..setTime.." ("..sunset..")"
			..GetString(SI_TACHRONOS_E_SUNRISE)..riseTime.." ("..sunrise..")"
			..GetString(SI_TACHRONOS_E_FULLMOON)..fMoon
			..GetString(SI_TACHRONOS_E_NEWMOON)..nMoon
			.."\n"
	
	local secs = TaChronos.health:GetTimePlayed()
	if secs > 0 then
		ttTxt = ttTxt .. string.format(GetString(SI_TACHRONOS_T_PLAYED), ZO_FormatTime(secs,  TIME_FORMAT_STYLE_COLONS, TIME_FORMAT_PRECISION_TWELVE_HOUR_NO_SECONDS))
	end

	InformationTooltip:AddLine(ttTxt, fontInfo, ZO_TOOLTIP_DEFAULT_COLOR:UnpackRGB(), LEFT)	
end

function cbo:OnMouseDown(button)
	if button == MOUSE_BUTTON_INDEX_RIGHT then
		local tex1, tex2, rot, phase, rPhase, fMoon, nMoon, nPhase = TaChronos.moon:GetData()
		local sunset, sunrise = TaChronos.sun:GetData()
		local tst             = TaChronos.sun:GetTamrielTime(withSecs)
		local msg = "Tamriel Chronos: Tamriel Time: %s - next sunset: %s next sunrise: %s - moon phases: %s (%d%%) next full moon: %s"
		CHAT_SYSTEM:StartTextEntry(msg:format(tst, sunset, sunrise, phase, rPhase, fMoon))
	end
end

function cbo:OnMouseDoubleClick()
	TaChronos:ToggleConversion()	
end
