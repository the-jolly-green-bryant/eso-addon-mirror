-----------------------------------------------------------------------------
-- 					      									               --
-- 	Title:		 Tamriel Chronos               							   --
--	Description: Tamriel Time and astronomical data                        --
--	Author: 	 Gandalf (@Gandalf2675)									   --
-- 					      									               --
-----------------------------------------------------------------------------

TaChronos.cal = TaChronos.cal or {}
local cal     = TaChronos.cal

function cal:Initialize()
	self:CreateCalendar()
	
	EVENT_MANAGER:RegisterForEvent("TaCHRONOS_CAL_PUSH", EVENT_ACTION_LAYER_PUSHED, function(...) self:OnLayerPushed(...) end)		
	self:ShowCalendar()
end

function cal:CreateCalendar(year)
	local wm  = GetWindowManager() 
	local a   = 1250
	local b   = 800
	
	-- base: tlw and bd
	if not self.base then
    	self.base = wm:CreateTopLevelWindow("TCCalendarTLW")
    	self.base:SetDimensions(a, b)
    	self.base:SetMovable(true)
    	self.base:SetMouseEnabled(true)
    	self.base:SetClampedToScreen(true)
    	self.base:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    	self.base.bd = TCCalenarBD or CreateControlFromVirtual("TCCalenarBD", self.base, "ZO_DefaultBackdrop")
    	self.base.bd:SetDimensions(self.base:GetWidth(),self.base:GetHeight())
    	self.base.bd:SetAnchor(TOPLEFT, self.base, TOPLEFT ,0 , 0)	
    	self.base:SetDrawLevel(DL_CONTROLS)
	end	

	-- close button
	if not self.base.close then
    	self.base.close = CreateControlFromVirtual(nil, self.base.bd, 'ZO_CloseButton')
        self.base.close:SetHandler('OnClicked', function() self.base:SetHidden(true) end)
	end
    				  	 
	-- title
	year = year or select(4,TaChronos.sun:GetTamrielDate())
	self.base.title = TCCalendarTitle or wm:CreateControl("TCCalendarTitle", self.base, CT_LABEL)
	self.base.title:SetFont("$(BOLD_FONT)|24|soft-shadow-thick") 
	self.base.title:SetDimensions(400,20)
	self.base.title:SetAnchor(TOPLEFT, self.base, TOPLEFT, self.base:GetWidth()/2-300, 30)
	self.base.title:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
	self.base.title:SetText(GetString(SI_TACHRONOS_CALENDAR_TITLE).. " - 2E ")
	self.base.title:SetColor(222/255,222/255,192/255,1)

	--self.base.titleY = TCCalendarTitleY or wm:CreateControl("TCCalendarTitleY", self.base, CT_EDIT)
	if not TCCalendarTitleBdY then
    	self.base.titleBdY = CreateControlFromVirtual("TCCalendarTitleBdY", self.base, "ZO_EditBackdrop")
    	self.base.titleBdY:SetDimensions(60, 32)
    	self.base.titleBdY:SetAnchor(TOPPRIGHT, self.base, TOPPRIGHT, self.base:GetWidth()/2+110, 30)
    	self.base.titleY   = TCCalendarTitleY or CreateControlFromVirtual("TCCalendarTitleY", self.base.titleBdY, "ZO_DefaultEditForBackdrop")
    	self.base.titleY:SetFont("$(BOLD_FONT)|24|soft-shadow-thick") 
    	self.base.titleY:SetDimensions(60, 32)
    	self.base.titleY:SetAnchor(TOPPRIGHT, self.base, TOPPRIGHT, self.base:GetWidth()/2+120, 30)
    	self.base.titleY:SetMaxInputChars(3)
    	self.base.titleY:SetHandler("OnEnter",      function() self:TreatYear(self.base.titleY:GetText()) end)
    	self.base.titleY:SetHandler("OnFocusGained",function() end)
	end
    self.base.titleY:SetText(year)
	
	self.today = {day = 1, month = 1, year = year}
	-- Create a 4 x 3 calendar
	self.month = self.month  or 
	{}
	local row, line, col, k = 0, 0 ,0, 0
	local base       = 60
	local topBorder  = 20
	local leftBorder = 20
	local weekday    = 0
	for i = 1,12 do
		self.month[i] = { day = {} }	
		line, col = 1, 0
		self.month[i].name = wm:CreateControl(nil, self.base, CT_LABEL)
		self.month[i].name:SetFont("$(BOLD_FONT)|18|soft-shadow-thick") 
		self.month[i].name:SetDimensions(200,40)
		self.month[i].name:SetAnchor(TOPLEFT, self.base, TOPLEFT, leftBorder + 240*k+30, row*240+topBorder+base)
		self.month[i].name:SetText(TaChronos.sun:GetTamrielMonthName(i))
		self.month[i].name:SetColor(222/255,222/255,192/255,1)

		--weekday = select(5,TaChronos.sun:GetTamrielDate(TaChronos.sun:GetEarthTimestamp(TaChronos.sun:Conv2EST(02,00,00,1,i,year))))
		weekday = select(5,TaChronos.sun:GetTamrielDate(TaChronos.sun:GetTamrielTimestamp(02,00,00,1,i,year)))
		col = weekday-1
		--for j =  1, 1 do
		for j =  1, TaChronos.sun:GetTamrielMonthLen(i) do
			col = col + 1	
			self.month[i].day[j]    = {}
			self.month[i].day[j].bd = _G["TaChronosBD_"..i.."_"..j] or wm:CreateControl("TaChronosBD_"..i.."_"..j, self.base, CT_BACKDROP)
			self.month[i].day[j].bd:SetDimensions(28, 28 )
			self.month[i].day[j].bd:SetAnchor(TOPLEFT, self.base, TOPLEFT, leftBorder+ 240*k+col*30, row*240 +topBorder+line*30+base)
			self.month[i].day[j].bd:SetEdgeColor(   .2, .2, .2, .6 )
			self.month[i].day[j].bd:SetCenterColor( .2, .2, .2, .6 )					
			self.month[i].day[j].field = _G["TaChronosField_"..i.."_"..j]  or wm:CreateControl("TaChronosField_"..i.."_"..j, self.base.bd, CT_LABEL)
			self.month[i].day[j].field:SetAnchor(TOPLEFT, self.base, TOPLEFT, leftBorder+ 240*k+col*30, row*240 +topBorder+line*30+base)
			self.month[i].day[j].field:SetFont("$(BOLD_FONT)|14|soft-shadow-thick") 
			self.month[i].day[j].field:SetDimensions(28,28)
			self.month[i].day[j].field:SetText(j)
			self.month[i].day[j].field:SetColor(1,1,1,.8)
			self.month[i].day[j].field:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
			self.month[i].day[j].field:SetVerticalAlignment(TEXT_ALIGN_CENTER)
			local dd,mo,yy = select(5,TaChronos.sun:GetEarthTime(nil, TaChronos.sun:GetTamrielTimestamp(02,00,00,j,i,year)))
			if TaChronos.hol:IsHoliday(j,i) then 
				self.month[i].day[j].field:SetHandler("OnMouseEnter", function(info) self:ShowTooltip(info,j,i,dd,mo,yy) end) 
				self.month[i].day[j].field:SetHandler("OnMouseExit",  function() ClearTooltip(InformationTooltip) end)
				self.month[i].day[j].field:SetMouseEnabled(true)
				self.month[i].day[j].field:SetColor(.6,.6,1, .8)
			else
				self.month[i].day[j].field:SetHandler("OnMouseEnter", function(info) self:ShowTooltipWorkday(info,dd,mo,yy) end) 
				self.month[i].day[j].field:SetHandler("OnMouseExit",  function() ClearTooltip(InformationTooltip) end)
				self.month[i].day[j].field:SetMouseEnabled(true)				
			end
			if (j+weekday-1) % 7 == 0 then line = line+1  col = 0 end	
		end
		k = k + 1
		if i % 4 == 0 then row = row+1 k = 0 end
	end
	
	-- Crate calendar legend - weeks
	if not TCHoliday_Cal_legend_dTitle then
    	self.dayTitle = wm:CreateControl("TCHoliday_Cal_legend_dTitle", self.base, CT_LABEL)
    	self.dayTitle:SetFont("$(BOLD_FONT)|18|soft-shadow-thick") 
    	self.dayTitle:SetAnchor(TOPLEFT, self.base, TOPLEFT, 1040, 110)
    	self.dayTitle:SetText(GetString(SI_TACHRONOS_Legend_Week))
    	self.dayTitle:SetColor(222/255,222/255,192/255,1)
    	self.dayT = TCHoliday_Cal_legend_dT or wm:CreateControl("TCHoliday_Cal_legend_dT", self.base, CT_LABEL)
    	self.dayT:SetFont("$(BOLD_FONT)|14|soft-shadow-thick") 
    	self.dayT:SetAnchor(TOPLEFT, self.base, TOPLEFT, 1040, 140)
    	self.dayE = TCHoliday_Cal_legend_dE or wm:CreateControl("TCHoliday_Cal_legend_dE", self.base, CT_LABEL)
    	self.dayE:SetFont("$(BOLD_FONT)|14|soft-shadow-thick") 
    	self.dayE:SetAnchor(TOPLEFT, self.base, TOPLEFT, 1140, 140)
    	local dayT, dayE = "",""
    	for i = 1,7 do
    		dayT = dayT..TaChronos.sun:GetTamrielDay(i).."\n"
    		dayE = dayE..TaChronos.sun:GetEarthDay(i).."\n"
    	end
    	self.dayT:SetText(dayT)
    	self.dayE:SetText(dayE)
    	self.dayT:SetDimensions(200, self.dayT:GetTextHeight()+64)
    	self.dayE:SetDimensions(200, self.dayT:GetTextHeight()+64)
	end
	
	-- Crate calendar legend - month
    if not TCHoliday_Cal_legend_wTitle then
    	self.monTitle = wm:CreateControl("TCHoliday_Cal_legend_wTitle", self.base, CT_LABEL)
    	self.monTitle:SetFont("$(BOLD_FONT)|18|soft-shadow-thick") 
    	self.monTitle:SetAnchor(TOPLEFT, self.base, TOPLEFT, 1040, 350)
    	self.monTitle:SetText(GetString(SI_TACHRONOS_Legend_Year))
    	self.monTitle:SetColor(222/255,222/255,192/255,1)	
    	self.dayT = TCHoliday_Cal_legend_mT or wm:CreateControl("TCHoliday_Cal_legend_mT", self.base, CT_LABEL)
    	self.dayT:SetFont("$(BOLD_FONT)|14|soft-shadow-thick") 
    	self.dayT:SetAnchor(TOPLEFT, self.base, TOPLEFT, 1040, 380)
    	self.dayE = TCHoliday_Cal_legend_mE or wm:CreateControl("TCHoliday_Cal_legend_mE", self.base, CT_LABEL)
    	self.dayE:SetFont("$(BOLD_FONT)|14|soft-shadow-thick") 
    	self.dayE:SetAnchor(TOPLEFT, self.base, TOPLEFT, 1140, 380)
    	local dayT, dayE = "",""
    	for i = 1,12 do
    		dayT = dayT..TaChronos.sun:GetTamrielMonthName(i).."\n"
    		dayE = dayE..TaChronos.sun:GetEarthMonthName(i).."\n"
    	end
    	self.dayT:SetText(dayT)
    	self.dayE:SetText(dayE)
    	self.dayT:SetDimensions(200, self.dayT:GetTextHeight()+64)
    	self.dayE:SetDimensions(200, self.dayT:GetTextHeight()+64)
	end
	
	self.base:SetHidden(true)
end

function cal:HideCalendar()
	self.base:SetHidden(true)
end

function cal:IsHidden()
	return self.base:IsHidden()
end

function cal:TreatYear(year)
	year = tonumber(year)
	if year == nil then year = 582 end
	if year < 582  then year = 582 end
	if year > 679  then year = 679 end
	self:ShowCalendar(year)
end

function cal:ShowCalendar(givenYear)
	local day, month, currentYear = select(2,TaChronos.sun:GetTamrielDate())	
	local year = givenYear or currenYear
	if self.today.year ~= year then self:CreateCalendar(year) end	
	if self.today.day  ~= day or self.today.month ~= month  or self.today.year ~= currentYear then
		-- reset old
		self.month[self.today.month].day[self.today.day].bd:SetDimensions(28,28)
		self.month[self.today.month].day[self.today.day].bd:SetEdgeColor(   .2, .2, .2, .6 )
		self.month[self.today.month].day[self.today.day].bd:SetCenterColor( .2, .2, .2, .6 )
	end
	if self.today.year == currentYear then
		-- mark new
		self.month[month].day[day].bd:SetDimensions(28,28)
		self.month[month].day[day].bd:SetEdgeColor(   1, .1, .1, .6 )
		self.month[month].day[day].bd:SetCenterColor( 1, .1, .1, .6 ) 
		-- store 
		self.today.month = month
		self.today.day   = day
		self.today.year  = currentYear
	end
	self.base:SetHidden(false)
end

function cal:ToggleCalendar()
	if self.base:IsHidden() then
		self:ShowCalendar()
	else
		self:HideCalendar()
	end
end
function cal:OnLayerPushed(event, layerIndex, activeLayerIndex)	
	--d("Push event: "..layerIndex.."/"..activeLayerIndex)
	if layerIndex ~= 8 and activeLayerIndex ~= 3 then 
		self.base:SetHidden(true)
	end -- dont' close when '.'
end

function cal:ShowTooltip(info, day, month, dd, mo, yy)
	local fontTitle = "$(BOLD_FONT)|$(KB_16)|soft-shadow-thin"
	local fontDate  = "$(MEDIUM_FONT)|$(KB_16)|soft-shadow-thin"
	local fontInfo  = "$(MEDIUM_FONT)|$(KB_16)|soft-shadow-thin"
	
	local ttTxt     = string.format("%02d-%02d-%04d", dd, mo, yy)
	InitializeTooltip(InformationTooltip, info, CENTER, 0, 100, BOTTOMRIGHT)
	InformationTooltip:AddLine(ttTxt, fontDate, ZO_TOOLTIP_DEFAULT_COLOR:UnpackRGB(), CENTER)

	local events = TaChronos.hol:GetCurrentHolidays(day, month)
	for k, event in pairs (events) do
		InformationTooltip:AddLine(GetString(event.name).." - "..GetString(event.date), fontTitle, 0.6, 0.6, 1, CENTER)
		InformationTooltip:AddVerticalPadding(-4)
		InformationTooltip:AddLine(GetString(event.text), fontInfo, ZO_TOOLTIP_DEFAULT_COLOR:UnpackRGB(), CENTER)
	end	
end

function cal:ShowTooltipWorkday(info, dd, mo, yy)
	local fontTitle = "$(BOLD_FONT)|$(KB_18)|soft-shadow-thin"
	local fontInfo  = "$(MEDIUM_FONT)|$(KB_16)|soft-shadow-thin"
	local ttTxt     = string.format("%02d-%02d-%04d", dd, mo, yy)
	InitializeTooltip(InformationTooltip, info)
	InformationTooltip:AddLine(ttTxt, fontInfo, ZO_TOOLTIP_DEFAULT_COLOR:UnpackRGB(), CENTER)
end
