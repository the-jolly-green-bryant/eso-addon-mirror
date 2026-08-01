if not Zgoo then return end

local Events = {}
Zgoo.Events = Events

Events.eventsTable = {}

local tinsert,tremove,min,max,type = table.insert,table.remove,math.min,math.max,type

local CHAIN = Zgoo.ChainCall
local MAX_LINES = 40
local LINE_HEIGHT = 20
local HEIGHT = MAX_LINES*LINE_HEIGHT
local WIDTH = 600
local wm = WINDOW_MANAGER

-- Functions that take a paramater with ^Get/^Is/^Can
local tex = "/esoui/art/miscellaneous/scrollbox_elevator.dds"

Events.curBotEvent = 0
local lines = {}

-- Frame creation pretty much copied from Zgoo.lua... meh

local function createALine(parent,num)
	local name = parent:GetName().."_Line"..num

	local line = CHAIN(wm:CreateControl(name,parent,CT_CONTROL))
		:SetDimensions(WIDTH,LINE_HEIGHT)
	.__END

	line.bd = CHAIN(wm:CreateControl(name.."_BD",line,CT_BACKDROP))
		:SetCenterColor(0,0,0,0)
		:SetEdgeColor(0,0,0,0)
		:SetAnchorFill(line)
	.__END

	-- unregister
	line.but = CHAIN(wm:CreateControl(name.."_But",line,CT_BUTTON))
		:SetDimensions(LINE_HEIGHT-2,LINE_HEIGHT-2)
		:SetAnchor(LEFT,line,LEFT,0,0)
		:SetFont("ZoFontGame")
		:SetText("X")
		:SetHorizontalAlignment(CENTER)
		:SetVerticalAlignment(CENTER)
		:SetHandler("OnClicked",function(self,but)
			if self.bd:GetAlpha() < .1 then return end
			Events:UnregEvent(line.event)
		end)
	.__END

	line.but.myText = "X"

	line.but.bd = CHAIN(wm:CreateControl(name.."_But_BD",line.but,CT_BACKDROP))
		:SetCenterColor(255,0,0,1)
		:SetEdgeColor(0,0,0,0)
		:SetAnchorFill(line.but)
	.__END

	-- expand
	line.but1 = CHAIN(wm:CreateControl(name.."_But1",line,CT_BUTTON))
		:SetDimensions(LINE_HEIGHT-2,LINE_HEIGHT-2)
		:SetAnchor(LEFT,line.but,RIGHT,10,0)
		:SetFont("ZoFontGame")
		:SetText("+")
		:SetHorizontalAlignment(CENTER)
		:SetVerticalAlignment(CENTER)
		:SetHandler("OnClicked",function(self,but)
			Events:ExpandEvent(line)
		end)
	.__END

	line.but1.myText = "+"

	line.but1.bd = CHAIN(wm:CreateControl(name.."_But1_BD",line.but,CT_BACKDROP))
		:SetCenterColor(255,0,0,1)
		:SetEdgeColor(0,0,0,0)
		:SetAnchorFill(line.but1)
	.__END

	local butHide = function(self)
		self.bd:SetAlpha(0)
		self:SetText("")
		--self:SetHidden(true)
	end


	local butShow = function(self)
		self.bd:SetAlpha(1)
		self:SetText(self.myText)
		--self:SetHidden(false)
	end

	line.but.Show = butShow
	line.but1.Show = butShow

	line.but.Hide = butHide
	line.but1.Hide = butHide

	line.indent = CHAIN(wm:CreateControl(name.."_Indent",line,CT_LABEL))
		:SetDimensions(0,LINE_HEIGHT)
		:SetAnchor(LEFT,line.but1,RIGHT,0,0)
	.__END

	line.text = CHAIN(wm:CreateControl(name.."_Text",line,CT_LABEL))
		:SetDimensions(WIDTH,LINE_HEIGHT)
		:SetFont("ZoFontGame")
		:SetColor(255,255,255,1)
		:SetText(name)
		:SetAnchor(LEFT,line.indent,RIGHT,5,0)
	.__END

	line.Hide = function(self)
		--self:SetHidden(true)	--TODO why doesn't this work?

		self.text:SetText("")
		self.but:Hide()
		self.but1:Hide()
	end

	line.Show = function(self)
		--self:SetHidden(false)
		self.but:Show()
		self.but1:Show()
	end

	line:Hide() --Show later
	return line
end

function Events:CreateEventTracker()
	if Zgoo.EventTracker then return end
	local name = "ZgooEventTracker"
	local frame = CHAIN(wm:CreateTopLevelWindow(name))
		:SetDimensions(WIDTH,HEIGHT)
		:SetHidden(true)
		:SetAnchor(TOPLEFT,GuiRoot,TOPLEFT,200,100)
		:SetMovable(true)
		:SetMouseEnabled(true)
		:SetHandler("OnMouseWheel",function(self,delta)
			self.slider:SetValue(self.slider:GetValue() - delta)
		end)
	.__END

	frame.bd = CHAIN(wm:CreateControl(name.."_BD",frame,CT_BACKDROP))
		:SetCenterColor(0,0,0,.5)
		:SetEdgeColor(0,0,0,0)
		:SetAnchorFill(frame)
	.__END

	frame.title = CHAIN(wm:CreateControl(name.."_Title",frame,CT_LABEL))
		:SetFont("ZoFontGame")
		:SetColor(255,255,255,1)
		:SetText("Zgoo Events")
		:SetAnchor(BOTTOM,frame,TOP,0,0)
	.__END

	frame.close = CHAIN(wm:CreateControl(name.."_Close",frame,CT_BUTTON))
		:SetDimensions(20,20)
		:SetAnchor(CENTER,frame,TOPRIGHT,0,0)
		:SetFont("ZoFontGame")
		:SetText("X")
		:SetHandler("OnClicked",function(self,but) frame:SetHidden(true) end)
	.__END

	frame.close.bd = CHAIN(wm:CreateControl(name.."_Close_BD",frame.close,CT_BACKDROP))
		:SetCenterColor(255,0,0,1)
		:SetEdgeColor(0,0,0,0)
		:SetAnchorFill(frame.close)
	.__END

	frame.toggle = CHAIN(wm:CreateControl(name.."_Toggle",frame,CT_BUTTON))
		:SetDimensions(20,20)
		:SetAnchor(TOPRIGHT,frame,BOTTOMRIGHT,0,0)
		:SetHandler("OnClicked",function(self,but)
			self:Toggle()
		end)
	.__END

	frame.toggle.toggled = 1

	frame.toggle.bd = CHAIN(wm:CreateControl(name.."_Toggle_BD",frame.toggle,CT_BACKDROP))
		:SetCenterColor(0,255,0,1)
		:SetEdgeColor(0,0,0,0)
		:SetAnchorFill(frame.toggle)
	.__END

	frame.toggle.Toggle = function(self)
		self.toggled = not self.toggled
		if self.toggled then
			self.bd:SetCenterColor(0,255,0,1)
		else
			self.bd:SetCenterColor(255,0,0,1)
		end
	end

	frame.toggle.IsToggled = function(self)
		return self.toggled
	end

	frame.toggleText = CHAIN(wm:CreateControl(name.."_TT",frame,CT_LABEL))
		:SetFont("ZoFontGame")
		:SetColor(255,255,255,1)
		:SetText("Track Events?")
		:SetAnchor(RIGHT,frame.toggle,LEFT,-5,0)
	.__END

	frame.slider = CHAIN(wm:CreateControl(name.."_Slider",frame,CT_SLIDER))
		:SetDimensions(30,HEIGHT)
		:SetMouseEnabled(true)
		:SetThumbTexture(tex,tex,tex,30,50,0,0,1,1)
		:SetMinMax(0,0)
		:SetValueStep(1)
		:SetHandler("OnValueChanged",function(self,value,eventReason)
			Events.curBotEvent = max(value,MAX_LINES)
			Events:Refresh()
		end)
		:SetAnchor(LEFT,frame,RIGHT,0,0)
	.__END

	frame.lines = {}
	for i=1,MAX_LINES do
		frame.lines[i] = createALine(frame,i)
		if i == 1 then
			frame.lines[i]:SetAnchor(TOPLEFT,frame,TOPLEFT,0,0)
		else
			frame.lines[i]:SetAnchor(TOPLEFT,frame.lines[i-1],BOTTOMLEFT,0,0)
		end
	end

	self.EventTracker = frame
	self:RegisterAllEvents(self.EventTracker)
end

function Events:UnregEvent(event)
	if not event then 
		d("No event?") 
		return 
	end

	local b = self.EventTracker:UnregisterForEvent(event)

	if not b then
		d("Event - "..self.eventList[event].." not removed....Try again?")
		return
	end

	-- No ipairs, skips some.
	for i=#self.eventsTable,1,-1 do
		local data = self.eventsTable[i]
		if data[1] == event or (data[1] == "args" and data[2] == event) then
			tremove(self.eventsTable,i)
		end
	end

	self:Refresh()
end

function Events:ExpandEvent(line)
	if not (line and line.eventid) then return end
	local myevent = self.eventsTable[line.eventid]
	if not myevent then d("WTF no event at id - "..line.eventid) return end

	myevent.expanded = not myevent.expanded

	if myevent.expanded then
		-- A little bad making new tables? probably...
		for i=3,#myevent do
			tinsert(self.eventsTable,line.eventid + (i-2),{"args",myevent[1],i-2,myevent[i]})
		end
	else
		for i=#myevent,3,-1 do
			tremove(self.eventsTable,line.eventid + (i-2))
		end
	end

	self:Refresh("args")
end

function Events:Refresh(event)
	local slider = self.EventTracker.slider
	local numEvents = min(Events.curBotEvent,#self.eventsTable)

	slider:SetMinMax(0,#self.eventsTable)

	for i=MAX_LINES,1,-1 do
		local line=self.EventTracker.lines[i]
		local eventnum = numEvents + i - MAX_LINES
		local myevent = self.eventsTable[eventnum]
		if not myevent then
			line.event = nil
			line.eventid = nil
			line:Hide()
		elseif not myevent[1] then
			d("WTF Event-"..event.." malformed?!")
		elseif myevent[1] == "args" then
			line.indent:SetWidth(10)
			line.text:SetText(("[|c00aaff%d|r] = %s"):format(myevent[3],Zgoo.FormatType(myevent[4])))
			line:Show()
			line.but:Hide()
			line.but1:Hide()
		elseif not self.eventList[myevent[1]] then
			d("WTF Event-"..myevent[1].." not in our table?!")
		else
			local numArgs = #myevent - 2		-- # args - id and time
			line.indent:SetWidth(0)
			line.event = myevent[1]
			line.eventid = eventnum
			line.text:SetText(("|cffff00%dms|r - |cff00aa%s|r |c886600[|cbb9900%d|c886600]|r"):format(myevent[2],self.eventList[myevent[1]],numArgs))
			line.but1.myText = myevent.expanded and "-" or "+"
			line:Show()
			if numArgs == 0 then line.but1:Hide() end
		end
	end

	slider:SetValue(numEvents)
end

function Events.EventHandler(event,...)
	local self = Events
	if not self.EventTracker.toggle.toggled then return end
	local eventTab = {event,GetFrameTimeMilliseconds(),...}
	eventTab.expanded = false

	local slider = self.EventTracker.slider
	local smin,smax = slider:GetMinMax()
	local curpos = slider:GetValue()

	if smax == curpos then
		Events.curBotEvent = curpos + 1
	end

	tinsert(self.eventsTable,eventTab)
	self:Refresh(event)
end

function Events:RegisterAllEvents(frame)
	if not frame then return end

	local myevents = {
		--[65548] = [[EVENT_ACTION_LAYER_PUSHED]],
		--[65549] = [[EVENT_ACTION_LAYER_POPPED]],
	}

	for id,event in pairs(self.eventList) do
	--for id,event in pairs(myevents) do
		frame:RegisterForEvent(id,Events.EventHandler)
	end
end

Events.eventList = {}
for k,v in globalprefixes("EVENT_") do
	if type(v)=="number"
	 and k~="EVENT_GLOBAL_MOUSE_DOWN" 
	 and k~="EVENT_GLOBAL_MOUSE_UP" 
	 then Events.eventList[v]=k
	end
end

setmetatable(Events.eventList,{__index = "NO EVENT IN LIST!?!?"})

Events.eventListR = {}  for k,v in pairs(Events.eventList) do Events.eventListR[v]=k end

--Zgoo.CommandHandler("events")