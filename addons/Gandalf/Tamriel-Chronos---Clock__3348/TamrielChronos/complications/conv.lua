-----------------------------------------------------------------------------
-- 					      									               --
-- 	Title:		 Tamriel Chronos               							   --
--	Description: Tamriel Time and astronomical data                        --
--	Author: 	 Gandalf (@Gandalf2675)									   --
-- 					      									               --
-----------------------------------------------------------------------------

TaChronos.conv = TaChronos.conv or {}
local cv       = TaChronos.conv

function cv:Initialize()
	self:CreateConvView()	
	EVENT_MANAGER:RegisterForEvent("TaCHRONOS_CONV_PUSH",   EVENT_ACTION_LAYER_PUSHED,         function(...) self:OnLayerPushed(...)         end)		
	EVENT_MANAGER:RegisterForEvent("TaCHRONOS_CONV_UIMODE", EVENT_GAME_CAMERA_UI_MODE_CHANGED, function(...) self:OnCameraUIModeChanged(...) end)	
end

function cv:ConvertTimeFrom(time)

	local function checkValues(h, m, s, dd, mo, yy)
		if tonumber(h) and tonumber(m) and tonumber(s) and tonumber(dd) and tonumber(mo) and tonumber(yy)then
			h  = tonumber(h)  m  = tonumber(m)  s  = tonumber(s)
			dd = tonumber(dd) mo = tonumber(mo) yy = tonumber(yy)
		else
			return GetString(SI_TACHRONOS_CONV_NUMBER)
		end
		if h  < 0 or h  > 23 then return GetString(SI_TACHRONOS_CONV_HH) end
		if m  < 0 or m  > 59 then return GetString(SI_TACHRONOS_CONV_MM) end
		if s  < 0 or s  > 59 then return GetString(SI_TACHRONOS_CONV_SS) end
		if dd < 1 or dd > 31 then return GetString(SI_TACHRONOS_CONV_DD) end
		if mo < 1 or mo > 12 then return GetString(SI_TACHRONOS_CONV_MO) end
		if time == "EST" then
			 if yy < 2014 or yy > 2037 then return GetString(SI_TACHRONOS_CONV_YY) end
		end
		if time == "TST" then
			 if yy <  582 or yy >  679 then return GetString(SI_TACHRONOS_CONV_YY_T) end
		end
		return "", h, m, s, dd, mo, yy
	end

	local status, h, m, s, dd, mo, yy = 0, self:GetTime(time)
	status, h, m, s, dd, mo, yy  = checkValues(h, m, s, dd, mo, yy)
	if status == "" then
		if time == "EST" then
			local ts = TaChronos.sun:GetEarthTimestamp(h, m, s, dd, mo, yy)
			self:UpdateTST(ts)
 		elseif time == "TST" then
 			local ts = TaChronos.sun:GetTamrielTimestamp(h, m, s, dd, mo, yy)
 			h, m, s, dd, mo, yy = TaChronos.sun:Conv2EST(ts)
			self:SetTime("EST", h, m, s, dd, mo, yy)
			self:UpdateTST(ts)
 		end
 	end
	
	self.base.status:SetText("|cff1010"..status.."|r")
end

function cv:GetTime(time)
	local h, m, s, dd, mo, yyyy = 0, 0, 0, 0, 0, 0
	
	h  = self[time].hh.digits:GetText()
	m  = self[time].mm.digits:GetText()
	s  = self[time].ss.digits:GetText()
	dd = self[time].dd.digits:GetText()
	mo = self[time].mo.digits:GetText()
	yy = self[time].yy.digits:GetText()

	return h, m, s, dd, mo, yy
end

function cv:SetTime(time, h, m, s, dd, mo, yy)
	self[time].hh.digits:SetText(string.format("%02d", h))
	self[time].mm.digits:SetText(string.format("%02d", m))
	self[time].ss.digits:SetText(string.format("%02d", s))
	self[time].dd.digits:SetText(string.format("%02d", dd))
	self[time].mo.digits:SetText(string.format("%02d", mo))
	self[time].yy.digits:SetText(string.format("%04d", yy))
end

function cv:AddTimeField(time, name, pref, posx, posy, width, len, value, ttxt)
	self[time]       = self[time] or {}
	self[time][name] = {}
	local base       = self.base
	local root       = self[time]
	local field      = self[time][name]
	local wm         = GetWindowManager() 
	
	field.pref = wm:CreateControl(nil, self.base, CT_LABEL)
	field.pref:SetFont("$(BOLD_FONT)|16|soft-shadow-thin") 
	field.pref:SetDimensions(24,26)
	field.pref:SetAnchor(TOPLEFT, base, TOPLEFT, posx-8, posy)
	field.pref:SetText(pref)

    field.bd = CreateControlFromVirtual(nil, base, "ZO_EditBackdrop")
	field.bd:SetDimensions(width, 26)
	field.bd:SetAnchor(TOPLEFT, base ,TOPLEFT, posx, posy)

	field.digits = CreateControlFromVirtual(nil, field.bd, "ZO_DefaultEditForBackdrop")
	field.digits:SetDimensions(width, 26)
	field.digits:SetMouseEnabled(true)
	local font = "EsoUI/Common/Fonts/FTN47.otf|16"
	-- local font = "$(BOLD_FONT)|16|soft-shadow-thin"
	field.digits:SetFont(font) 
	field.digits:SetMaxInputChars(len)
	field.digits:SetText(string.format("%02d", value))
	field.digits:SetHandler("OnEnter",      function() self:ConvertTimeFrom(time) end)
	field.digits:SetHandler("OnFocusGained",function() end)
	field.digits:SetHandler("OnEscape",     function() base:SetHidden(true) end)
	if ttxt then
		field.digits:SetHandler("OnMouseEnter", function(info) self:ShowTooltip(info, ttxt) end) 
		field.digits:SetHandler("OnMouseExit",  function() ClearTooltip(InformationTooltip) end)
	end
end

function cv:CreateConvView()
	local cnf = TaChronos.cm.config.conv
	local wm  = GetWindowManager() 
	local a   = 380
	local b   = 420

	-- base: tlw and bd
	self.base = wm:CreateTopLevelWindow(nil)
	self.base:SetDimensions(a, b)
	self.base:SetMovable(true)
	self.base:SetMouseEnabled(true)
	self.base:SetClampedToScreen(true)
	self.base:SetAnchor(cnf.p, GuiRoot, cnf.rp, cnf.x, cnf.y)
	self.base:SetHandler("OnMouseUp",
							function() 
								_, cnf.p, _, cnf.rp, cnf.x, cnf.y = self.base:GetAnchor() 
								self.base.moved = true
							end
					  	 )			  	 
	self.base.bd = CreateControlFromVirtual(nil, self.base, "ZO_DefaultBackdrop")
	self.base.bd:SetDimensions(self.base:GetWidth(),self.base:GetHeight())
	self.base.bd:SetAnchor(TOPLEFT, self.base, TOPLEFT ,0 , 0)		

	-- close button
	self.base.close = CreateControlFromVirtual(nil, self.base.bd, 'ZO_CloseButton')
    self.base.close:SetHandler('OnClicked', function() self.base:SetHidden(true) end)
    				  	 
	-- title
	self.base.title = wm:CreateControl(nil, self.base, CT_LABEL)
	self.base.title:SetFont("$(BOLD_FONT)|20|soft-shadow-thick") 
	self.base.title:SetDimensions(self.base:GetWidth(),20)
	self.base.title:SetAnchor(TOPLEFT, self.base, TOPLEFT, 30, 20)
	self.base.title:SetText(GetString(SI_TACHRONOS_CONV_TITLE))
	self.base.title:SetColor(222/255,222/255,192/255,1)

		
	-- headers
	local font = "EsoUI/Common/Fonts/univers57.otf|16|soft-shadow-thin"
	self.base.headEST = wm:CreateControl(nil, self.base, CT_LABEL)
	self.base.headEST:SetFont(font) 
	self.base.headEST:SetDimensions(self.base:GetWidth(),30)
	self.base.headEST:SetAnchor(TOPLEFT, self.base, TOPLEFT, 30, 64)
	self.base.headEST:SetText(GetString(SI_TACHRONOS_CONV_EST))
	
	self.base.headTST = wm:CreateControl(nil, self.base, CT_LABEL)
	self.base.headTST:SetFont(font) 
	self.base.headTST:SetDimensions(self.base:GetWidth(),30)
	self.base.headTST:SetAnchor(TOPLEFT, self.base, TOPLEFT, 220, 64)
	self.base.headTST:SetText(GetString(SI_TACHRONOS_CONV_TST))
		
	-- Earth Time fields   hh:mm:ss
	local lb = 30
	self:AddTimeField("EST", "hh", "",  lb,     98, 29, 2, 0)
	self:AddTimeField("EST", "mm", ":", lb+40,  98, 29, 2, 0)
	self:AddTimeField("EST", "ss", ":", lb+40,  98, 29, 2, 0)
	self["EST"].ss.digits:SetHidden(true)
	local lb = 30
	self:AddTimeField("EST", "dd", "",  lb,    128, 29, 2, 1)
	self:AddTimeField("EST", "mo", ".", lb+40, 128, 29, 2, 1)
	self:AddTimeField("EST", "yy", ".", lb+80, 128, 60, 4, 1970)	

	local lb = 220
	self:AddTimeField("TST", "hh", "",  lb,     98, 29, 2, 0)
	self:AddTimeField("TST", "mm", ":", lb+40,  98, 29, 2, 0)
	self:AddTimeField("TST", "ss", ":", lb+40,  98, 29, 2, 0)
	self["TST"].ss.digits:SetHidden(true)
	local lb = 220
	self:AddTimeField("TST", "dd", "",  lb,    128, 29, 2, 1)
	self:AddTimeField("TST", "mo", ".", lb+40, 128, 29, 2, 1)
	self:AddTimeField("TST", "yy", ".", lb+80, 128, 60, 4, 399)	
	
	--  daylight area
	self.base.day = wm:CreateControl(nil, self.base, CT_BACKDROP)
	self.base.day:SetAnchor(CENTER, self.base, CENTER, 0,80)
	self.base.day:SetAlpha(1)
	self.base.day:SetEdgeColor( 0.0 , 0.0, 0.0, 0.0)
	self.base.day:SetDimensions(340, 220)
	self.base.day:SetDrawLayer(DL_BACKGROUND)	

	-- Moons 
	local masser, secunda = TaChronos.moon:GetData()
	self.base.masser = wm:CreateControl(nil, self.base, CT_TEXTURE)
	self.base.masser:SetAnchor(CENTER, self.base, CENTER, -40,  60)
	self.base.masser:SetAlpha(1)
	self.base.masser:SetTexture(masser)
	self.base.masser:SetDimensions(96, 96)
	self.base.masser:SetDrawLayer(DL_CONTROLS)
	--
	self.base.secunda = wm:CreateControl(nil, self.base, CT_TEXTURE)
	self.base.secunda:SetAnchor(CENTER, self.base, CENTER, 48, 24)
	self.base.secunda:SetAlpha(1)
	self.base.secunda:SetTexture(secunda)
	self.base.secunda:SetDimensions(96, 96)
	self.base.secunda:SetDrawLayer(DL_CONTROLS)
	
	-- Output date time
	self.base.text = wm:CreateControl(nil, self.base, CT_LABEL)
	self.base.text:SetFont("$(BOLD_FONT)|18|soft-shadow-thick") 
	self.base.text:SetDimensions(self.base:GetWidth(),40)
	self.base.text:SetAnchor(CENTER, self.base, CENTER, 0, 130)
	self.base.text:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
	
	-- Output moon data
	self.base.data = wm:CreateControl(nil, self.base, CT_LABEL)
	self.base.data:SetFont("$(BOLD_FONT)|18|soft-shadow-thick") 
	self.base.data:SetDimensions(self.base:GetWidth(),40)
	self.base.data:SetAnchor(CENTER, self.base, CENTER, 0,152)
	self.base.data:SetHorizontalAlignment(TEXT_ALIGN_CENTER)

	-- Output holiday data
	self.base.holidays = wm:CreateControl(nil, self.base, CT_LABEL)
	self.base.holidays:SetFont("$(BOLD_FONT)|18|soft-shadow-thick") 
	self.base.holidays:SetDimensions(self.base:GetWidth(),40)
	self.base.holidays:SetAnchor(CENTER, self.base, CENTER, 0,174)
	self.base.holidays:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
	self.base.holidays:SetMouseEnabled(true)
	self.base.holidays:SetLinkEnabled(true)
 	self.base.holidays:SetHandler("OnLinkMouseUp", function(self, _, link, button) return ZO_LinkHandler_OnLinkMouseUp(link, button, self) end)
	-- Status Field
	self.base.status = wm:CreateControl(nil, self.base, CT_LABEL)
	self.base.status:SetFont("ZoFontGameSmall") 
	self.base.status:SetDimensions(self.base:GetWidth(),30)
	self.base.status:SetAnchor(BOTTOMLEFT, self.base, BOTTOMLEFT, 20, 12)
	-- self.base.status:SetText("|cff1010".."Might be an error message here......".."|r")
	
	TaChronosCalendarButton:SetParent(self.base.bd:GetParent())
	TaChronosCalendarButton:SetAnchor(BOTTOMRIGHT, self.base.bd, BOTTOMRIGHT,-2,-5)
end

function cv:HideConv()
	self.base:SetHidden(true)
	if IsGameCameraUIModeActive() then SetGameCameraUIMode(false) end
end

function cv:IsHidden()
	return self.base:IsHidden()
end

function cv:ShowConv()
	local ts = GetTimeStamp()
	local hE, mE, sE ,ddE, moE, yyE = select(2,TaChronos.sun:GetEarthTime(ts))
	self:SetTime("EST", hE, mE, sE, ddE, moE, yyE)
	self:UpdateTST(ts)
	self.base:SetHidden(false)
	if not IsGameCameraUIModeActive() then SetGameCameraUIMode(true) end
end

function cv:ToggleConv()
	if self.base:IsHidden() then 
		self:ShowConv()
	else
		self:HideConv()
	end
end

function cv:UpdateTST(ts)
	local masser, secunda, rotation, phase, rPhase, fMoon, nMoon, nPhase = TaChronos.moon:GetData(ts)
	local tPhase = TaChronos.moon:GetPhaseStr(phase, nPhase)
	h, m, s, dd, mo, yy, timeDate, daylight, weekDay = TaChronos.sun:Conv2TST(ts)
	self:SetTime("TST", h, m, s, dd, mo, yy)
 	self.base.day:SetCenterTexture(daylight)
 	local v = tonumber(h)	
 	if v >= 4 and v < 21 then
 		self.base.masser:SetAlpha(0.1)
 		self.base.secunda:SetAlpha(0.1)
 	elseif v == 21 then
 		self.base.masser:SetAlpha(0.25)
		self.base.secunda:SetAlpha(0.25)
	elseif v == 3 then
 		self.base.masser:SetAlpha(0.25)
		self.base.secunda:SetAlpha(0.25)
	else
 		self.base.masser:SetAlpha(1)
		self.base.secunda:SetAlpha(1)
	end

	self.base.masser:SetTexture(masser)
	self.base.masser:SetTextureRotation(-math.rad(rotation), 0.5, 0.5)
	self.base.secunda:SetTexture(secunda)
	self.base.secunda:SetTextureRotation(-math.rad(rotation), 0.5, 0.5)
	
	mo         = tonumber(mo)
	weekDay    = tonumber(weekDay)
	local text = TaChronos.sun:GetTamrielDay(weekDay)..", "..TaChronos.sun:GetTamrielMonthName(mo).." "..dd..", 2E "..yy.." - "..string.format("%02d:%02d", h, m)
	self.base.text:SetText(text)
	text = string.format(GetString(SI_TACHRONOS_CONV_MOON), rPhase, phase, tPhase)	
	self.base.data:SetText(text)
	local holidays = TaChronos.hol:GetCurrentHolidays(dd,mo)
	local prefix   = ""
	text           = ""
	for k, event in pairs (holidays) do
		text = text..prefix..TaChronos.hol:CreateLink(event)
		prefix = " "
	end
	self.base.holidays:SetText("|c9999ff"..text.."|r")	
end

function cv:OnLayerPushed(event, layerIndex, activeLayerIndex)	
	--d("Push event: "..layerIndex.."/"..activeLayerIndex)
	if layerIndex ~= 8 and activeLayerIndex ~= 2 then 
		self.base:SetHidden(true)
	end -- dont' close when '.'
end

function cv:OnCameraUIModeChanged(event)
	if self.base.moved then 
		-- d("camera changed")
		self.base.moved = false
		SetGameCameraUIMode(true)
	end
end

