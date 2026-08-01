--[[
	Zgoo
	Dev tool for inspecting tables or userdatas, and for tracking events.
	Developed by @Errc & SinusPi
 ]]--

if not Zgoo then return end

local tinsert,tremove,min,max,type = table.insert,table.remove,math.min,math.max,type

local CHAIN = Zgoo.ChainCall
local MAX_LINES = 40
local LINE_HEIGHT = 20
local HEIGHT = MAX_LINES*LINE_HEIGHT
local WIDTH = 500
local GTableSize = 10000

local BLOCK_PRIVATE = false
local BLOCK_USERDATA = false
local BLOCK_CAPS = false
local BLOCK_ZO = false
local PRINT_GLOBALS = true

local wm = WINDOW_MANAGER

local COLORS={string="|cff8800",number="|c00aaff",["function"]="|cff00aa",table="|cffff00",["nil"]="|c888888",userdata="|c4444ff",boolean="|cff0000"}
-- Functions that take a paramater with ^Get/^Is/^Can
local BLACKLIST = {
	GetNamedChild="BLACKLISTED",
	--IsChildOf="BLACKLISTED",
	--GetAnchor="BLACKLISTED",
	--GetChild="BLACKLISTED",
	GetClass="BLACKLISTED",
	GetHandler="BLACKLISTED",
	GetTradingHouseSearchResultItemInfo="CRASHES",
	GetTradingHouseSearchResultItemLink="CRASHES",
}
local EVENTBLACKLIST = {EVENT_MANAGER=1, EVENT_REASON_HARDWARE=1, EVENT_REASON_SOFTWARE=1, EVENT_GLOBAL_MOUSE_UP=1, EVENT_GLOBAL_MOUSE_DOWN=1}
local tex = "/esoui/art/miscellaneous/scrollbox_elevator.dds"

local FUNCTIONGROUPS_ = {
	Map = {"GetCurrentMapIndex","GetCurrentMapZoneIndex","GetCurrentSubZonePOIIndices","GetMapLocation","GetMapLocationIcon","GetMapLocationTooltipHeader","GetMapLocationTooltipLineInfo","GetMapName","GetMapNumTiles","GetMapParentCategories","GetMapPing","GetMapPlayerPosition","GetMapPlayerWaypoint","GetMapType","GetMapTileTexture","GetMapRallyPoint","GetNumMaps","GetNumMapPinFilters","GetNumMapLocationTooltipLines","GetNumMapLocations","GetNumMapKeySections","GetNumMapKeySectionSymbols","GetPOIMapInfo","IsMapLocationTooltipLineVisible","IsMapLocationVisible","IsMapPinFilterSet","IsPointOnCurrentMap","SetMapByMapListIndex","SetMapFloor","SetMapPinAssisted","SetMapPinContinuousPositionUpdate","SetMapPinFilter","SetMapQuestPinsAssisted","SetMapToPlayerLocation","SetMapToQuestCondition","SetMapToQuestZone","SetMapToZone","GetNumZones","GetMapKeySectionName","GetMapKeySectionSymbolInfo","GetCurrentPlayerZoneIndex","GetPlayerLocationName","GetNumPOIInZone","GetNumPOIs","GetNumPOIsForDifficultyLevelAndZone","GetPOIInfo","GetPOIPinType","GetNumQuestsInPOI","GetMapInfo","AddMapPin","AddMapQuestPins","RemoveMapQuestPins",
	-- 2014-02-12, added:
	"GetMapContentType","GetMapFloorInfo","GetMapMouseoverInfo",
	-- 2014-03-03, added:
	"SetMapToMapListIndex"
	},
	zo_Helper = "zo_",
	Fonts = {"ZoFontGamepad27","ZoFontGamepad27","ZoFontGamepad27",string_matching = true},
	Private = {},
	Protected = {},
	Quest = "Quest",
	UnitData = {"GetUnit","IsUnit",string_matching = true},
}
local STRINGMATCHING={}
local FUNCTIONGROUPS={}
setmetatable(FUNCTIONGROUPS,{__index = function(me,ind)
	for pat,gr in pairs(STRINGMATCHING) do
		if type(pat) == "string" and ind:find(pat) then
			return gr
		end
	end
	if type(ind) == "string" then
		if IsPrivateFunction(ind) then
			return "Private"
		elseif IsProtectedFunction(ind) then
			return "Protected"
		end
	end	
end})
for gr,funcs in pairs(FUNCTIONGROUPS_) do
	if type(funcs) == "table" then
		for i,fun in ipairs(funcs) do
			FUNCTIONGROUPS[fun]=gr
			if funcs.string_matching then
				STRINGMATCHING[fun]=gr
			end
		end
	elseif type(funcs) == "string" then
		FUNCTIONGROUPS[funcs]=gr
		STRINGMATCHING[funcs]=gr
	end
end


local special_map_1=function(fun,data)  data.params={GetCurrentMapZoneIndex(),1}  end
SPECIAL_FUNC_CALLS = {
	["^Get[Raw]-Unit"] = function(fun,data)  if IsShiftKeyDown() then  data.params={"reticleover"} elseif IsCapsLockOn() then data.params={"mouseover"} else  data.params={"player"}  end  end,
	["^Is[Raw]-Unit"] = function(fun,data)  if IsShiftKeyDown() then  data.params={"reticleover"} elseif IsCapsLockOn() then data.params={"mouseover"} else  data.params={"player"}  end  end,
	["^GetMapPlayerPosition"] = function(fun,data)  if IsShiftKeyDown() then  data.params={"reticleover"} elseif IsCapsLockOn() then data.params={"mouseover"} else  data.params={"player"}  end  end,
	["^GetNumPOIInZone"] = special_map_1,
	["^GetPOIInfo"] = special_map_1,
	["^GetPOIPinType"] = special_map_1,
	["^GetNumPOIs"] = special_map_1,
	["^GetJournalQuest"] = function(fun,data)  data.params={1} end,	-- 3 = w/e journal index you want to see

	getparams = function(self,name,data)
		for spatt,sfun in pairs(self) do
			if name:find(spatt) then  sfun(name,data)  end
		end
	end
}

local offset = 0
local lines = {}




local function printfromglobal(k,v)
	local self = Zgoo
	if type(k) ~= "string" then return end
	if type(v) == "userdata" then return end
	--if k:find("^ZO") or k:find("_") then return end

	-- Updating events list
	--if k:find("EVENT") then
	--	self.SV.events[ _G[k] ] = k
	--end

	--if k:find("AbilityTooltip")
	--then
	--	d(k)--.."-"..v)
	--end

end

local function WhyBlacklisted(funcname)
	return BLACKLIST[funcname]
	or (type(funcname)=="string" and
		((IsPrivateFunction(funcname) and "PRIVATE")
	 or(IsProtectedFunction(funcname) and "PROTECTED")
	 )
	)
end


local function safepairs(tab, init)
	if rawequal(tab, _G) then
		return zo_insecureNext, tab, init
	else
		return next, tab, init
	end
end

globalprefixes = function(prefix)
	local strfind = string.find
	local safeglobalnext = function(tab,index)
		for k, v in zo_insecureNext, tab, index do
			if type(k) == "string" and strfind(k, prefix, 1, true) == 1 then
				return k, v
			end
		end
	end
	return safeglobalnext,_G,nil
end

getglobalbyprefix = function(prefix,value)
	for k,v in globalprefixes(prefix) do if v==value then return k end end
end




ZGOO_ADDRESS_LOOKUP={}
local function get_addr(obj)
	if type(obj)=="function" or type(obj)=="table" then
		return tostring(obj):match(": ([%u%d]+)")
	end
end

function dereference(obj)
	return ZGOO_ADDRESS_LOOKUP[get_addr(obj) or ""]
end

-- startup
local safe=100000
local function grab_derefs(source,name,deep)
	for k,v in safepairs(source) do
		if type(v)=="function" or type(v)=="table" then
			local addr=get_addr(v)
			if addr and not ZGOO_ADDRESS_LOOKUP[addr] then
				ZGOO_ADDRESS_LOOKUP[addr]=(name and name.."." or "") .. k
				if deep and type(v)=="table" and k:find("^ZO_") then
					grab_derefs(v,k,false)
				end
			end
		end
	end
end
grab_derefs(_G,nil,true)




local function getusermetatable(tab)
	local meta = getmetatable(tab)

	local index = meta.__index

	return index
end

local function createALine(parent,num)
	local name = parent:GetName().."_Line"..num
	name = "Line"..num

	local line = CHAIN(wm:CreateControl(name,parent,CT_CONTROL))
		:SetDimensions(WIDTH,LINE_HEIGHT)
	.__END

	line.bd = CHAIN(wm:CreateControl(name.."_BD",line,CT_BACKDROP))
		:SetCenterColor(0,0,0,0)
		:SetEdgeColor(0,0,0,0)
		:SetAnchorFill(line)
	.__END

	line.indent = CHAIN(wm:CreateControl(name.."_Indent",line,CT_LABEL))
		:SetDimensions(0,LINE_HEIGHT)
		:SetAnchor(LEFT,line,LEFT,0,0)
	.__END

	line.but = CHAIN(wm:CreateControl(name.."_But",line,CT_BUTTON))
		:SetDimensions(LINE_HEIGHT-2,LINE_HEIGHT-2)
		--:SetNormalTexture(butTex)
		:SetAnchor(LEFT,line.indent,RIGHT,0,0)
		:SetFont("ZoFontGamepad27")
		:SetHorizontalAlignment(CENTER)
		:SetVerticalAlignment(CENTER)
		:SetHandler("OnClicked",function(self,but) Zgoo:ButtonClick(self) end)
	.__END

	line.but.bd = CHAIN(wm:CreateControl(name.."_But_BD",line.but,CT_BACKDROP))
		:SetCenterColor(0.7, 0.1, 0.3, 0.8)
		:SetEdgeColor(0,0,0,0)
		:SetAnchorFill(line.but)
	.__END

	line.delbut = CHAIN(wm:CreateControl("$(parent)_DelBut", line, CT_BUTTON))
		:SetDimensions(28, LINE_HEIGHT-2)
		:SetAnchor(LEFT, line, LEFT, 2, 0)
		:SetFont("ZoFontGamepad27")
		:SetText("DEL")
		:SetHorizontalAlignment(CENTER)
		:SetVerticalAlignment(CENTER)
		:SetHidden(true)
		:SetHandler("OnClicked", function(self, mb)
			local linei = self:GetParent().linei
			local dat = lines[linei]
			ZO_Dialogs_ShowDialog("Zgoo_ConfirmDeleteTableKey", linei, {
				titleParams = { type(dat.data) },
				mainTextParams = { tostring(dat.index) },
			})
		end)
	.__END


	line.delbut.bd = CHAIN(wm:CreateControl("$(parent)_BD", line.delbut, CT_BACKDROP))
		:SetCenterColor(0.9, 0.1, 0.1, 0.8)
		:SetEdgeColor(0, 0, 0, 0)
		:SetAnchorFill(line.delbut)
	.__END

	line.text = CHAIN(wm:CreateControl(name.."_Text",line,CT_LABEL))
		--:SetDimensions(WIDTH,LINE_HEIGHT)
		:SetFont("ZoFontGamepad27")
		:SetColor(255,255,255,1)
		:SetText(name)
		:SetAnchor(LEFT,line.but,RIGHT,5,0)
	.__END

	line:SetHidden(true) --Show later
	return line
end

function Zgoo:CreateFrame()
	if Zgoo.Frame then return end
	local lastshift,lastctrl

	local name = "ZgooFrame"
	local frame = CHAIN(ZgooFrame)
		:SetDimensions(WIDTH,HEIGHT)
		:SetHidden(true)
		:SetAnchor(TOPRIGHT,GuiRoot,TOPRIGHT,-200,100)
		:SetWidth(500)
		:SetMovable(true)
		:SetResizeHandleSize(MOUSE_CURSOR_RESIZE_NS)
		:SetMouseEnabled(true)
		:SetHandler("OnMouseWheel",function(self,delta)
			local val = offset - delta
			if val < 0 then val = 0
			elseif val > #lines - MAX_LINES then val = #lines - MAX_LINES end
			offset = val
			Zgoo.Frame.slider:SetValue(offset)
		end)
		:SetHandler("OnUpdate",function(self,elapsed)
			if lastshift~=IsShiftKeyDown() or lastctrl~=IsControlKeyDown() then
				Zgoo:Update()
			end
			lastshift=IsShiftKeyDown()
			lastctrl=IsControlKeyDown()
		end)
	.__END


	frame.bd = CHAIN(wm:CreateControl(name.."_BD",frame,CT_BACKDROP))
		:SetCenterColor(0,0,0,.7)
		:SetEdgeColor(0,0,0,0)
		:SetAnchorFill(frame)
	.__END

	frame.title = CHAIN(wm :CreateControl(name.."_Title",frame,CT_LABEL))
		:SetFont("ZoFontGamepad27")
		:SetColor(255,255,255,1)
		:SetText("Zgoo")
		:SetAnchor(BOTTOM,frame,TOP,0,0)
	.__END

	frame.close = CHAIN(wm:CreateControl(name.."_Close",frame,CT_BUTTON))
		:SetDimensions(20,20)
		:SetAnchor(BOTTOMLEFT,frame,TOPRIGHT,0,-10)
		:SetFont("ZoFontGamepad27")
		:SetText("X")
		:SetHandler("OnClicked",function(self,but)
			frame:SetHidden(true)
			--SCENE_MANAGER:Show("hud")
		end)
	.__END
	frame.close.bd = CHAIN(wm:CreateControl(name.."_Close_BD",frame.close,CT_BACKDROP))
		:SetCenterColor(1,0,0,1)
		:SetEdgeColor(0,0,0,0)
		:SetAnchorFill(frame.close)
	.__END

	frame.addr = CHAIN(wm:CreateControl(name.."_Addr",frame,CT_BUTTON))
		:SetDimensions(30,20)
		:SetAnchor(BOTTOMRIGHT,frame.close,BOTTOMLEFT,-10,0)
		:SetFont("ZoFontGamepad27")
		:SetText("@")
		:SetHandler("OnClicked",function(self,but) Zgoo.SHOW_ADDRESSES = not Zgoo.SHOW_ADDRESSES  self.bd:Update()  Zgoo:Update() end)
	.__END
	frame.addr.bd = CHAIN(wm:CreateControl(name.."_Addr_BD",frame.addr,CT_BACKDROP))
		:SetCenterColor(1,0,0,1)
		:SetEdgeColor(0,0,0,0)
		:SetAnchorFill(frame.addr)
	.__END
	frame.addr.bd.Update = function(self)
		self:SetCenterColor(Zgoo.SHOW_ADDRESSES and 0 or 0.5,Zgoo.SHOW_ADDRESSES and 0.7 or 0,0,1)
	end
	frame.addr.bd:Update()

	frame.expa = CHAIN(wm:CreateControl(name.."_Expa",frame,CT_BUTTON))
		:SetDimensions(30,20)
		:SetAnchor(BOTTOMRIGHT,frame.addr,BOTTOMLEFT,-10,0)
		:SetFont("ZoFontGamepad27")
		:SetText("{...}")
		:SetHandler("OnClicked",function(self,but) Zgoo.EXPAND_TABLES = not Zgoo.EXPAND_TABLES  self.bd:Update()  Zgoo:Update() end)
	.__END
	frame.expa.bd = CHAIN(wm:CreateControl(name.."_Expa_BD",frame.expa,CT_BACKDROP))
		:SetCenterColor(1,0,0,1)
		:SetEdgeColor(0,0,0,0)
		:SetAnchorFill(frame.expa)
	.__END
	frame.expa.bd.Update = function(self)
		self:SetCenterColor(Zgoo.EXPAND_TABLES and 0 or 0.5,Zgoo.EXPAND_TABLES and 0.7 or 0,0,1)
	end
	frame.expa.bd:Update()

local FRAME_LINES = {}

	frame.copyall = CHAIN(wm:CreateControl(name.."_Copyall",frame,CT_BUTTON))
		:SetDimensions(50,20)
		:SetAnchor(BOTTOMLEFT,frame,TOPLEFT,0,-10)
		:SetFont("ZoFontGamepad27")
		:SetText("COPY")
		:SetPressedFontColor(0, 0, 0, 1)
		:SetHandler("OnClicked",function(self,but)
			if frame.edit:IsHidden() then
				self:SetState(BSTATE_PRESSED)
			else
				self:SetState(BSTATE_NORMAL)
				frame.edit:SetHidden(true)
				return
			end

			local strrep = string.rep
			local chunks ={}
			for i, line in ipairs(FRAME_LINES) do
				if not line:IsHidden() then
					for j = 16, line.indent:GetWidth(), 15 do
						tinsert(chunks, "\t")
					end
					tinsert(chunks, line.text:GetText())
					tinsert(chunks, "\n")
				end
			end
			s = table.concat(chunks, "")
			s=s:gsub("|c......",""):gsub("|r","")
			frame.edit:SetText(s)
			frame.edit:SelectAll()
			d("|c88ffffPress Ctrl-C to copy window contents to clipboard.")

			-- this triggers OnShow handler which hides all lines, that's
			-- why it could not be shown earlier - the loop above takes only
			-- visible lines
			frame.edit:SetHidden(false)
			frame.edit:TakeFocus()
		end)
	.__END
	frame.copyall.bd = CHAIN(wm:CreateControl(name.."_Copyall_BD",frame.copyall,CT_BACKDROP)) :SetCenterColor(0.7,0.5,0,1) :SetEdgeColor(0,0,0,0) :SetAnchorFill(frame.copyall) .__END

	frame.slider = CHAIN(wm:CreateControl(name.."_Slider",frame,CT_SLIDER))
		:SetDimensions(30,HEIGHT)
		:SetMouseEnabled(true)
		:SetThumbTexture(tex,tex,tex,30,50,0,0,1,1)
		:SetValue(0)
		:SetValueStep(1)
		:SetAnchor(LEFT,frame,RIGHT,0,0)
		:SetHandler("OnValueChanged",function(self,value,eventReason)
			offset = min(value,#lines - MAX_LINES)
			Zgoo:Update()
		end)

	.__END

	frame.lines = FRAME_LINES
	for i=1,MAX_LINES do
		frame.lines[i] = createALine(frame,i)
		if i == 1 then
			frame.lines[i]:SetAnchor(TOPLEFT,frame,TOPLEFT,0,0)
		else
			frame.lines[i]:SetAnchor(TOPLEFT,frame.lines[i-1],BOTTOMLEFT,0,0)
		end
	end

	-- hidden edit box
	frame.edit = CHAIN(wm:CreateControlFromVirtual("$(parent)_Edit",
						frame, "ZO_DefaultEditMultiLine"))
		:SetAnchor(TOPLEFT, frame, TOPLEFT, 2, 2)
		:SetAnchor(BOTTOMRIGHT, frame, BOTTOMRIGHT, -2, -2)
		:SetMaxInputChars(2000)
		:SetFont("ZoFontGamepad27")
		:SetHidden(true)
		:SetHandler("OnShow", function()
			-- hide all line controls
			for i, line in ipairs(FRAME_LINES) do
				line:SetHidden(true)
			end
			-- disable Zgoo:Update() while this box is shown
			frame.lines = nil
		end)
		:SetHandler("OnHide", function()
			frame.lines = FRAME_LINES
			Zgoo:Update()
		end)
	.__END

	self.Frame = frame
end

local function downcasesort(a,b)
	if type(a.index)=="number" and type(b.index)=="number" then return a.index<b.index end
	if type(a.index)=="number" and type(b.index)~="number" then return true end
	if type(a.index)~="number" and type(b.index)=="number" then return false end
	return a.index and b.index and tostring(a.index) < tostring(b.index)
end

local function _getChildren(control)
	local children = {}
	for i = 1, control:GetNumChildren() do
		children[i] = control:GetChild(i)
	end
	return children
end

local function tablesize(tab)
	local size,metasize=0
	if type(tab)=="userdata" then
		local saved = tab
		tab = getusermetatable(tab)

		if not tab.GetChildren then
			tab.GetChildren = _getChildren
		end

		-- Lazy... Bring a copy to the top
		if not tab.__ToggleHidden then
			tab.__ToggleHidden = tab.ToggleHidden
			local _, name = pcall(function() return tab.GetName(saved) end )
			tab.__GetName = name
			tab.__GetParent = tab.GetParent
			tab.__GetChildren = tab.GetChildren
		end
		-- tab.A__Zgoo_ToggleHidden = tab.ToggleHidden
	end
	if type(tab)=="table" then

		for k in safepairs(tab) do size=size+1 end

		local meta = getmetatable(tab)
		local metaindex = meta and rawget(meta, "__index")
		if type(metaindex)=="table" then
			metasize = 0
			for k in safepairs(metaindex) do metasize=metasize+1 end
		end

		return #tab,size,metasize
	end
end


function Zgoo.FormatType(data,t,expandtable,index)
	local s
	t = t or type(data)
	
	if t=="string" then
		local len=#data
		data=data:gsub("\n","")
		data=data:gsub("\r","")
		data=data:gsub("|n","")
		data=data:gsub("\"","\\\"")
		data=data:sub(1,100)
		s="|cccaa88\""..COLORS['string']..data.."|cccaa88\"|r"

		if len>100 then s=s.."... ("..len..")" end

	elseif t=="number" then
		s = ('%s'):format(tostring(data))
		s = COLORS['number'] .. s .. "|r"

	elseif t=="nil" then
		s = COLORS['nil'] .. "nil|r"

	elseif t=="table" then
		local csize,size,metasize = tablesize(data)
		s = tostring(data) .. " |c886600[|cbb9900#".. (csize or "?") .."," .. (size or "?") .. (metasize and ",+"..metasize or "") .."|c886600]"

		if not Zgoo.SHOW_ADDRESSES then s=s:gsub(": [0-9A-F]+","") end

		local derefname = dereference(data)
		if index and derefname and index~=derefname then  s = s .. " |c6688ee(global |c88aaff" .. derefname .. "|c6688ee)|r"  end

		if expandtable then
			local nt={}
			local ntlimit=0
			for k,v in safepairs(data) do tinsert(nt,Zgoo.FormatType(v)) ntlimit=ntlimit+1 if ntlimit>=expandtable then break end end
			s = s .. " : " .. table.concat(nt,",")
		end

		s = COLORS['table'] .. s .. "|r"

	elseif t=="function" then
		s = COLORS['function'] .. ('%s'):format(tostring(data):gsub("%[",""):gsub("%]","")) .. "|r"
		if not Zgoo.SHOW_ADDRESSES then s=s:gsub(": [0-9A-F]+","") end

	elseif t=="boolean" then
		if data then s="|cff0000true|r" else s="|caa0000false|r" end

	elseif t=="userdata" then
		local csize,size,metasize = tablesize(data)	-- Just put our GetChildren and A_Toggle in the userdata.
		s = tostring(data) .. " |c886600[|cbb9900#".. (csize or "?") .."," .. (size or "?") .. (metasize and ",+"..metasize or "") .."|c886600]"

	else
		s = ('%s'):format(tostring(data):gsub("%[",""):gsub("%]",""))
		if COLORS[t] then s = COLORS[t] .. s .. "|r" end
	end

	local objtype = t=="userdata" and type(data.GetType)=="function" and data:GetType() or nil
	if objtype then
		-- widget!
		local objname = t=="userdata" and type(data.GetName)=="function" and "\"|cff0000"..data:GetName().."|r\"" or "(anon)"
		s = "|r  < "..objname.." - |c00ffff"..((data.class and "Class-"..data.class) or Zgoo.UiTypes[objtype]).. " |r>"
	end


	return s
end


function pcallhelper(success, ...)
	if success then
		if select('#',...)<=1 then return success, ... else return success, {...} end
	else
		return success, ...
	end
end

function safeFunctionCallV(v,k,data,orig)
	local was_func
	local ok,err
	if type(v)=="function" and type(k)=="string"
	and not WhyBlacklisted(k)
	and ((k:find("^Is")
		 or k:find("^Can[A-Z]")
		 or k:find("^Get[A-Z]")
		 or k:find("^Did[A-Z]")
		 or k:find("^Does[A-Z]")
		 or k:find("^Has[A-Z]")
		) and not k:find("By[A-Z]")) then

		if orig and orig[k] then
			ok,v = pcallhelper(pcall(orig[k],orig))
		elseif data then
			--if data and data._is_global then data=nil end
			ok,v = pcallhelper(pcall(v,data))
		else
			local tab={params={}}
			SPECIAL_FUNC_CALLS:getparams(k,tab)
			ok,v = pcallhelper(pcall(v,unpack(tab.params)))
		end

		if not ok then
			err=v
			v=nil
		end
		was_func=true
	end

	if k and WhyBlacklisted(k) then
		was_func=true
	end

	return v,was_func,err
end


function Zgoo:Update()
	local frame = self.Frame
	offset = offset or 0
	if offset < 0 then offset = 0 end	-- offset can go negative someplace.... HACKED

	if not frame.lines then return end

	for i=1,MAX_LINES do
		local line=frame.lines[i]

		if offset+i <= #lines then
			local dat = lines[offset+i]
			if not dat then break end	--??

			local v = dat.data

			local err
			if IsControlKeyDown() and type(v)=="function" then
				v = "(FUNCTIONS DISABLED)"
			else
				v,was_func,err = safeFunctionCallV(v,dat.index,dat.parent)
			end

			local s = Zgoo.FormatType(err or v,nil,Zgoo.EXPAND_TABLES and 20 or nil,dat.index) or ""

			if self.find then
				if (type(dat.index)=="string" and dat.index:find(self.find))
				or (type(dat.data)=="string" and dat.data:find(self.find))
				or (s and s:find(self.find)) then
					d(dat.index.." = "..s)
				end
			end

			if err then s = "|cff0000"..s.."|r" end

			if dat.index then
				local blacklist = WhyBlacklisted(dat.index)
				if blacklist then  s = "|c888888"..blacklist.."|r"  end

				local metaprefix = dat.meta and "(m) " or ""

				if type(dat.index)=="string" and not dat.parent then
					SPECIAL_FUNC_CALLS:getparams(dat.index,dat)
				end
				local param = dat.params and ("|cff8800\"".. (dat.params[1] or "") .."\"|r") or ""  -- TODO:UGLY

				if type(dat.data)=="function" or dat.func then
					s = metaprefix.."|c88ff00"..tostring(dat.index).."|c44aa00(".. param ..")|r = "..s
				else
					s = metaprefix.."|c888888["..Zgoo.FormatType(dat.index).."|c888888]|r = "..s
				end
			end

			local meta = getmetatable(dat.data)
			meta = meta and meta.__index

			-- append tostring of table
			if dat.data and type(dat.data)=="table"
			and ( rawget(dat.data,"tostring")		-- Don't want to run into __index that is a function.
						or ( meta and type(meta)=="table" and rawget(meta,"tostring") ) -- Really only want :tostring that are suppose to be there. No need to dick around with __indexs just rawget the metatable too
					)
			and type(dat.data.tostring)=="function" then
				-- Note: a __index = function() end will trigger this error.
				local ok,txt = pcall(dat.data.tostring,dat.data)
				if not ok then txt="ERR: "..txt end
				txt = txt:gsub("\n","@LINEBREAK@")					-- Don't allow multiple lines because it makes it ugly
				s = s .. " \"".. txt .."\""
			end

			line.text:SetText(s)

			if expand or type(dat.data)=="table" or type(dat.data)=="userdata" then
				line.but:SetHidden(false)
				if dat.expanded then line.but:SetText("-") else line.but:SetText("+") end
			elseif dat.func and not WhyBlacklisted(dat.index) then
				line.but:SetHidden(false)
				line.but:SetText(dat.parent and ":" or ".")
			elseif dat.parent==_G.SOUNDS then
				line.but:SetHidden(false)
				line.but:SetText("S")
			else
				line.but:SetHidden(true)
			end

			if dat.meta or dat.indent < 3 or type(dat.parent) ~= "table" then
				line.delbut:SetHidden(true)
			else
				line.delbut:SetHidden(false)
			end

			line.indent:SetWidth(dat.indent*15+1)
			line.linei = offset+i

			line:SetHidden(false)
		else
			line:SetHidden(true)
		end

	end

	if #lines < MAX_LINES then
		frame.slider:SetHidden(true)
	else
		frame.slider:SetHidden(false)
	end
end



function Zgoo:CloneGlobals()  -- deprecated, unused.
	Zgoo._G2 = {}
	local index,data,err

	local limit=0
	repeat
		index,data,err = safenext(_G,index)
		if index and not WhyBlacklisted(index) then
			Zgoo._G2[index]=data
		elseif err then
			local badindex = err:match("private function '(.-)'")
			if badindex then index=badindex end
			Zgoo._G2[index]="__PRIVATE__"
		end
		limit=limit+1  if lim>50000 then return end
	until not index
end

function Zgoo:DeleteData(linei)
	local dat = lines[linei]
	dat.parent[dat.index] = nil
	dat.data = nil
	dat.func = false
	dat.userdata = false
	tremove(lines, linei)
	self:Update()
end


function Zgoo:FindSavedVarsTables()
	local results = {}
	local strfind = string.find

	local function hasMember(tab, keyPattern, valueType, maxDepth)
		if type(tab) == "table" and maxDepth > 0 then
			for k, v in zo_insecureNext, tab do
				if type(v) == valueType and type(k) == "string" and strfind(k, keyPattern) then
					return true
				elseif hasMember(v, keyPattern, valueType, maxDepth - 1) then
					return true
				end
			end
		end
		return false
	end

	for k, v in zo_insecureNext, _G do
		if type(v) == "table" then
			if hasMember(rawget(v, "Default"), "^version$", "number", 4) then
				results[k] = v
			end
		end
	end

	for _, k in ipairs{
		"AddonProfiles_SavedVariables2",
		"merCharacterSheet_SavedVariables",
	} do
		results[k] = rawget(_G, k)
	end

	return results
end

function Zgoo:Main(insertpoint,indent,data,orig,mode,command)
	if not self.Frame then self:CreateFrame() end
	if not data then return end
	if not insertpoint then lines={} insertpoint=1 end
	self.LINES=lines

	indent = indent or 1
	local s,expand,isUserdata
	local added=0

	if mode=="global" then		-- Examine the global table
		
		--local PFC = 1
		local categories = {
			ZO_ = {}
		}
		--categories.ZO_={"ZO_Achievements","ZO_Alchemy","ZO_Campaign","ZO_KeepWindow","ZO_MapPin","ZO_Provisioner","ZO_QuickSlot","ZO_StablePanel","ZO_TradingHouse","ZO_WorldMap","ZO_Smithing","ZO_PlayerInventory","ZO_Guild","ZO_Enchanting","ZO_Character"}
		local GData = {
			[1] = {_is_global=true},
			ZO_ = {},
			SI_ = {},
			CT_ = {},
			['zz EVENTS'] = {},
			['zz OTHER CONSTS']= {},
			['zz UI'] = {},
		}
		--Build ZO subgroups
		local alphabet = {'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z'}
		for k,v in pairs(alphabet) do 
			GData['ZO_']['ZO_' .. v] = {}
			GData['SI_']['SI_' .. v] = {}
			GData['zz OTHER CONSTS'][v] = {}
			GData['zz UI'][v] = {}
			GData['zz EVENTS']['EVENT_' .. v] = {}
		end
		
		for k,v in pairs(FUNCTIONGROUPS_) do GData[k]={_is_global=true} end
		local curDataTable = GData[1]
		local curTableSize, totalSize = 0,0
		local MAX_GLOBAL = 70000
		--local copyCount, legitAfterCopy = 0,0

		for index,value in safepairs(data) do while(1) do
			-- private or protected funcs have already been replaced with harmless strings by safepairs

			if type(value)=="userdata" and BLOCK_USERDATA then break end
			if index:match("^[%u_%d]*$") and BLOCK_CAPS then break end
			if index:find("ZO_") and BLOCK_ZO then break end

			-- Helpful for finding things in _G
			if PRINT_GLOBALS then
				printfromglobal(index,value)
			end

			--if not (index:find("Action") and index:find("Layer")) then break end

			if Zgoo.Events.eventListR[index] then
				local next = index:sub(7,7):upper()
				if next ~= '' and GData['zz EVENTS']['EVENT_' .. next] then
					GData['zz EVENTS']['EVENT_' .. next][index] = value
				end	
			elseif index:find("^EVENT") and not EVENTBLACKLIST[index] then
				d("New Event :"..index)
				local next = index:sub(7,7):upper()
				if next ~= '' and GData['zz EVENTS']['EVENT_' .. next] then
					GData['zz EVENTS']['EVENT_' .. next][index] = value
				end	
			elseif index:find("^SI_") then
				local next = index:sub(4,4):upper()
				if next ~= '' and GData['SI_']['SI_' .. next] then
					GData['SI_']['SI_' .. next][index] = GetString(value)
				end				
			elseif index:find("^CT_") then			GData.CT_[index]=value
			elseif type(value)=="number" and index:find("^%u+_[%u%d]+") then
				local next = index:sub(1,1):upper()
				if next ~= '' and GData['zz OTHER CONSTS'][next] then
					GData['zz OTHER CONSTS'][next][index] = value
				end
			elseif index:find("^ZO_") then
				--determine target
				local next = index:sub(4,4):upper()
				if next ~= '' then
					local found
					for k,v in pairs(categories.ZO_) do
						if index:find("^"..v) then
							v=v.."___"
							local where=GData['ZO_']['ZO_' .. next][v]
							if not where then where={} GData['ZO_']['ZO_' .. next][v]=where end
							where[index]=value
							found=true
							break
						end
					end
					if not found then GData['ZO_']['ZO_' .. next][index]=value end
				end
			elseif type(value)=="userdata" and type(value.GetType)=="function" then
				if GData['zz UI'][index:sub(1,1):upper()] then
					GData['zz UI'][index:sub(1,1):upper()][index]=value
				end	
			else
				-- use an else here so only a single FUNCTIONGROUPS[index] is indexed. It got metatabled
				local fugr = FUNCTIONGROUPS[index] or (type(value)=="string" and FUNCTIONGROUPS[value])	-- TODO could not force only strings
				if fugr then
					GData[fugr][index]=value
				else
					curDataTable[index] = value
					curTableSize = curTableSize + 1
				end
			end

			-- 1 table of 16000 crashes the game. Whoda thunk
			if curTableSize >= GTableSize then
				GData[#GData + 1] = {}
				curDataTable = GData[#GData]
				curTableSize=0
			end

			MAX_GLOBAL = MAX_GLOBAL - 1
			if MAX_GLOBAL <= 0 then d("FOR LOOP WENT TOO LONG FOR _G PLEASE REPORT TO @Errc") end
		break end end

		data = GData

		data['Zgoo Utilities'] = Zgoo.Utils
	end

	if type(data)=="table" then
		local tab={}
		for k,v in safepairs(data) do
			local parent = orig or data
			local p_meta = getmetatable(parent)
			local p_meta_safe = not p_meta or type(p_meta.__index)~="function" -- If the __index of a table is a function, then lets not index it because we can't safely say what will happen.

			if (type(parent)~="table" and type(parent)~="userdata") or (p_meta_safe and parent._is_global) then parent=nil end
			tinsert(tab,{
				data=v,
				index=k,
				func=(type(v)=="function" or WhyBlacklisted(k)),
				indent=indent,
				parent=parent,
				userdata = type(v)=="userdata" and getusermetatable(v),
				}
			)
		end

		local meta = getmetatable(data)
		if meta then
			if rawequal(meta.__index, _G) then
				-- nothing; we don't want to copy the whole _G
			elseif type(meta.__index) == "table" then
				for k,v in pairs(meta.__index) do
					tinsert(tab,{index=k,data=v,meta=true,func=(type(v)=="function" or WhyBlacklisted(k)),indent=indent,parent=orig or data,userdata = type(v)=="userdata" and getusermetatable(v)})
				end
			end
			tinsert(tab,{index="__z_metatable",data=meta,indent=indent,parent=data})
		end

		table.sort(tab,downcasesort)

		for _,v in ipairs(tab) do
			tinsert(lines,insertpoint,v)
			insertpoint=insertpoint+1
		end

	elseif type(data)=="userdata" then
		tablesize(data)	-- Stick GetChildren into the userdata
		self:Main(insertpoint,indent,getusermetatable(data),data)
		return
	else
		tinsert(lines,insertpoint,{data=data,indent=indent})
		insertpoint=insertpoint+1
	end

	self.Frame.slider:SetMinMax(0,#lines - MAX_LINES)

	self.Frame:SetHidden(false)
	self:Update()

	if not ZGOO_SCENE then
		ZGOO_SCENE = ZO_Scene:New("zgoo", SCENE_MANAGER)
		ZGOO_SCENE:AddFragment(RIGHT_BG_FRAGMENT)
		ZGOO_SCENE:AddFragment(FRAME_TARGET_STANDARD_RIGHT_PANEL_FRAGMENT)
		ZGOO_SCENE:AddFragment(FRAME_TARGET_BLUR_STANDARD_RIGHT_PANEL_FRAGMENT)
		ZGOO_SCENE:AddFragment(FRAME_EMOTE_FRAGMENT_JOURNAL)
		ZGOO_SCENE:AddFragment(FRAME_PLAYER_FRAGMENT)
	end
	--SCENE_MANAGER:Show("zgoo")
end

function Zgoo:ButtonClick(but,which)
	if but.bd:GetAlpha() == 0 then return end --TODO hiding doesn't work atm...hack hack hack

	local linei=but:GetParent().linei
	local data = lines[linei]
	local func = data[but.index and "index" or "data"]
	local indexi = but.index and "expandedi" or "expanded"

	if WhyBlacklisted(data.index) then return end

	local result

	if data.parent==_G['SOUNDS'] then PlaySound(data.data) return end
	
	if func and type(func)=="function"
	and not data[indexi]  -- don't call when we're about to COLLAPSE
	then
		--d(data.index .. " = ")
		local tab={params={}}
		SPECIAL_FUNC_CALLS:getparams(data.index,tab)

		if IsShiftKeyDown() then
			result={func(unpack(tab.params))}
		else
			result={func(data.parent or unpack(tab.params))}
		end
		--d(Zgoo.FormatType(result))
		if #result==1 then
			result=result[1]
		elseif #result==0 then
			result=nil
		end

		if not result then return end
	end

	if IsShiftKeyDown() then Zgoo(result or (but.index and data.parent --[[or data.userdata--]] or data.data)) return end

	-- expand or collapse?

	if not data[indexi] then
		-- expand
		data[indexi]=true
		self:Main(
			linei+1,
			data.indent+1,
			result or (but.index and data.parent --[[or data.userdata--]] or data.data),
			result or (type(data.data=="table") and data.data)
		)
	else
		-- collapse
		while lines[linei+1] and lines[linei+1].indent > data.indent do
			tremove(lines,linei+1)
		end
		data[indexi]=nil
		self:Update()
	end
end





BUGIT_LOG = {}

local function get_proxymeta(origtab)
	return {__index=function(tab,funcname)
		local func=origtab[funcname]
		if type(func)=="function" then
			return function(...)
				local name=rawget(tab,"___name")
				if select(1,...)==tab then
					-- method call
					table.insert(BUGIT_LOG,("CALL %s:%s(%s,%s,%s)"):format(name or "",tostring(funcname),tostring(select(2,...) or nil),tostring(select(3,...) or nil),tostring(select(4,...) or nil)))
				elseif name then
					table.insert(BUGIT_LOG,("CALL %s.%s(%s,%s,%s,%s)"):format(name,tostring(funcname),tostring(select(1,...) or nil),tostring(select(2,...) or nil),tostring(select(3,...) or nil),tostring(select(4,...) or nil)))
				else
					table.insert(BUGIT_LOG,("CALL %s(%s,%s,%s,%s)"):format(tostring(funcname),tostring(select(1,...) or nil),tostring(select(2,...) or nil),tostring(select(3,...) or nil),tostring(select(4,...) or nil)))
				end
				ret={func(...)}
				table.insert(BUGIT_LOG,ret)
				return unpack(ret)
			end
		else
			table.insert(BUGIT_LOG,"GET "..tostring(funcname))
			table.insert(BUGIT_LOG,func)
			return func
		end
	end, __newindex=function(tab,key,val)
		table.insert(BUGIT_LOG,"SET "..tostring(key).." = "..tostring(val))
		origtab[key]=val
	end}
end

local proxyG = {}
setmetatable(proxyG,get_proxymeta(_G))


function BUGIT(func)
	if type(func)~="function" then d("Not a function.") return end
	setfenv(func,proxyG)
	d("Bug in place. Call your function and '/zgoo BUGIT_LOG'.")
end

function BUGCALL(func,...)
	if type(func)~="function" then d("Not a function.") return end
	setfenv(func,proxyG)
	func(...)
	setfenv(func,_G)
	Zgoo("BUGIT_LOG")
end

function BUGIT2(funcname)
	local orig = _G[funcname]
	if type(orig)~="function" then d(funcname.." is not a function.") return end
	_G[funcname] = function(...)
		d("Bugged "..funcname.." here...")
		setfenv(orig,proxyG)
		orig(...)
		d("Bugged "..funcname.." done. See '/zgoo BUGIT_LOG'.")
	end
end

function BUGTABLE(tablename)
	local orig=_G[tablename]
	_G[tablename]={___name=tablename}
	setmetatable(_G[tablename],get_proxymeta(orig))
	d("Bugged table "..tablename..". Mess with it and see '/zgoo BUGIT_LOG'.")
end


-- SPECIFIC FEATURE GROUPS
Zgoo.Utils = {}

function Zgoo.Utils:GetLoreBookInfo()
	local ret={}
	for cat=1,GetNumLoreCategories() do
		local name,numCol = GetLoreCategoryInfo(cat)
		local cattab={}
		cattab.tostring=function() return name end
		for col=1,numCol do
			local colname,desc,known,total,hid=GetLoreCollectionInfo(cat,col)
			local coltab={}
			coltab.tostring=function() return colname.." ("..known.."/"..total..")" end
			coltab._ = desc
			for book=1,total do
				local title,icon,known = GetLoreBookInfo(cat,col,book)
				local bookstr = ("%d/%d/%d : %s%s"):format(cat,col,book,title,(known and " (known)" or ""))
				table.insert(coltab,bookstr)
			end
			table.insert(cattab,coltab)
		end
		table.insert(ret,cattab)
	end
	return ret
end

function Zgoo.Utils:GetAchievementInfo()
	local ret={}
	for cat=1,GetNumAchievementCategories() do
		local name,numSub,num_general,cpts,ctpts,hidepts = GetAchievementCategoryInfo(cat)
    local cattab={}
		cattab.tostring=function() return name.." |caaaa88("..cpts.."/"..ctpts.." pts)|r" end
		for sub=0,numSub do
			local subname,numa,pts,tpts,hidepts=GetAchievementSubCategoryInfo(cat,sub)
			if sub==0 then --general
				sub=nil
				subname="General"
				numa=num_general
				pts=cpts
				tpts=ctpts
			end
			local subtab={}
			subtab.tostring=function() return subname.." |caaaa88("..pts.."/"..tpts.." pts)|r" end
			for achi=1,numa do
				local id = GetAchievementId(cat,sub,achi)
				local name,desc,pts,icon,completed,date,time = GetAchievementInfo(id)
				local crits = GetAchievementNumCriteria(id)
				if crits==0 then
					table.insert(subtab,("|caaaaaa[|caaffff%d|caaaaaa]|cffffff %s%s"):format(id,name,(known and " (completed)" or "")))
				else
					local achieve={}
					achieve.tostring=function() return ("|caaaaaa[|caaffff%d|caaaaaa]|cffffff %s%s"):format(id,name,(known and " (completed)" or "")) end
					for ci=1,crits do
						local description, numCompleted, numRequired = GetAchievementCriterion(id,ci)
						table.insert(achieve,("|caaaaaa[|caaffff%d/%d|caaaaaa] %s%s |c99bb99(%d/%d)"):format(id,ci,(numCompleted==numRequired and "|c88ff44" or "|cbbbbbb"),description,numCompleted,numRequired))
					end
					table.insert(subtab,achieve)
				end
			end
			table.insert(cattab,subtab)
		end
		table.insert(ret,cattab)
	end
	return ret
end

function Zgoo.Utils:GetPOIInfoForCurrentMap()
	local GetPOIMapInfo = _GetPOIMapInfo_ORIG_ZGV or GetPOIMapInfo
	local GetPOIInfo = _GetPOIInfo_ORIG_ZGV or GetPOIInfo
	map = map or GetCurrentMapZoneIndex()
	local pois={}
	for i=1,GetNumPOIs(map) do
		local x,y,typ,tex = GetPOIMapInfo(map,i)
		local text,level,subtextinc,subtextcom = GetPOIInfo(map,i)
		if x and x>0 then
			tex = tex:gsub("/esoui/art/icons/","...")
			--local pin = GetPOIPinType(map,i)
			local typtxt = getglobalbyprefix("MAP_PIN_TYPE_",typ)
			typtxt = typtxt and typtxt:gsub("MAP_PIN_TYPE_","")
			local poi = {}
			
			local label = (("|cffee55%d,%d |cffffff%s [lv %d]"):format(x*100,y*100,text,level))
			poi.tostring=function(poi) return label end

			--local numq,maxq,compq = GetNumQuestsInPOI(map,i)
			--poi[2] = (("(%s %d) %s, quests: %d num/%d max/%d done"):format(typtxt or typ,num,tex, numq,maxq,compq))

			poi[1] = ((" (type: %s, icon: %s)"):format(typtxt or typ,tex))
			if subtextinc~="" then poi[2]=(" - completed: ".. subtextinc) end
			if subtextcom~="" then poi[3]=(" - incomplete: ".. subtextcom) end
			pois[i]=poi
		end
	end
	return pois
end

