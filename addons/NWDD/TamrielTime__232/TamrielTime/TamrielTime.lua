local VERSION = 99.1
local defaults = {fmt="$W $D of $M 2E $Y - $h:$m", ring = "LevelUp", style = "soft-shadow-thick", size = 16, font="Univers 67", fix=2, alarms={nalarms=0}, refresh=1000, tta="off", alpha=0.8, color={r=207/255,g=220/255,b=189/255}, x=GuiRoot:GetRight(), y=0}
local tt_ui, tt_svars
local SetAutoHide

local fontdb = {}
local ringdb = { "NoSound", "LevelUp", "Skill_Gained", "Achievement_Awarded", "Money_Transact", "Lockpicking_success", "Quest_Complete", "Smithing_Finish_Research", "System_Open" }
local fontd = { ["ProseAntique"]= "ProseAntiquePSMT.otf", ["Arial Narrow"]= "arialn.ttf", ["Consolas"]="consola.ttf", ["ESO Cartographer"]="esocartographer-bold.otf", ["Fontin Bold"]="fontin_sans_b.otf", ["Fontin Italic"]="fontin_sans_i.otf", ["Fontin Regular"]="fontin_sans_r.otf", ["Fontin SmallCaps"]="fontin_sans_sc.otf", ["Skyrim Handwritten"]="Handwritten_Bold.otf", ["Trajan Pro"]="trajanpro-regular.otf", ["Univers 55"]="univers55.otf", ["Univers 57"]="univers57.otf", ["Univers 67"]="univers67.otf"}
local styledb = {"normal", "outline", "thick-outline", "shadow", "soft-shadow-thick", "soft-shadow-thin"}
for k,v in pairs(fontd) do
	fontdb[#fontdb+1] = k
end

local function g(t,e)
	return function () return t[e] end
end

local function FormatTime(DateStruct)
	DateStruct.n = "\n"
	return lu.fmt(tt_svars.fmt, DateStruct)
end

local function SetRing(sound)
	PlaySound(sound)
	tt_svars.ring = sound
end

local function Ring(DateStruct)
	PlaySound(tt_svars.ring)
	d("[TamrielTime]Alarm: "..DateStruct.h..":"..DateStruct.m)
end

SLASH_COMMANDS["/tta"] = function (text)
	if text ~= nil and text ~= "" then
		tt_svars.tta = text
		SetAutoHide(text)
		d("[TamrielTime]"..("Autohide "..tt_svars.tta))
	elseif text=="" then
		d("[TamrielTime]"..("Autohide "..tt_svars.tta))
	end
	return tt_svars.tta
end

local function Update()
	tt_ui.text:SetText(lu.fmt(tt_svars.fmt, tt.CheckAlarms(tt_svars.alarms, tt.Date(GetTimeStamp()+(tt_svars.fix*tt.xhour)))))
	zo_callLater(Update, tt_svars.refresh)
end

local function SetLook(o)
	tt_ui.text:SetFont("EsoUI/Common/Fonts/"..fontd[o.font].."|"..tostring(o.size).."|"..o.style)
end
local function SetFont(font)
	tt_svars.font = font
	SetLook(tt_svars)
end
local function SetSize(size)
	tt_svars.size = size
	SetLook(tt_svars)
end
local function SetStyle(style)
	tt_svars.style = style
	SetLook(tt_svars)
end
local function UpdatePosition()
	tt_svars.x, tt_svars.y = tt_ui.frame:GetCenter()
end

local function SetColor(r,g,b)
	tt_svars.color = {r=r,g=g,b=b}
	tt_ui.text:SetColor(r,g,b)
end

local function GetHour()
	return  tonumber(tt.Date(GetTimeStamp()+(tt_svars.fix*tt.xhour)).h)
end

local function GetTime()
	local date = tt.Date(GetTimeStamp()+(tt_svars.fix*tt.xhour))
	return tonumber(date.h..date.m..date.s)
end

local function ParamTime(time)
	return time/10000
end

local function SetTime(time)
	tt_svars.fix = tt_svars.fix+ParamTime(time)-ParamTime(GetTime())
	return 
end

SLASH_COMMANDS["/tt"] = function ()
	d("[TamrielTime] Help(v"..tostring(VERSION).."):\nA command without params clears whatever you mess.\n/tta <menu|chat|off> (Sets Autohide: menu,chat or off)\n/ttfmt <format> ($W$D$ord,$M($dM)/$Y|$h:$m:$s|$h12$f12)\n/ttrefresh <seconds> (clock updated every seconds)\n/tthour <hour> (sets clock hour)\n/ttalarm ?h:m (? means repeat, hour/mins optional)\n/ttalarms (lists alarms)")
end

SLASH_COMMANDS["/ttfmt"] = function (newformat)
	if newformat==nil then
		return tt_svars.fmt
	end
	tt_svars.fmt = (newformat~="") and newformat or defaults.fmt
	d("[TamrielTime]New Time Format: "..tt_svars.fmt)
end

SLASH_COMMANDS["/ttforceshow"] = function(foo)
	if foo then
		tt_ui.frame:SetDrawWhenGuiHidden(foo~="false")
		SetAutoHide(foo=="true" and "off" or tt_svars.tta)
	end
	return tt_ui.frame
end

SLASH_COMMANDS["/ttrefresh"] = function (refreshrate)
	if refreshrate==nil then
		return tt_svars.refresh/1000
	end
	refreshrate = tonumber(refreshrate)
	tt_svars.refresh = (refreshrate ~= nil) and refreshrate*1000 or defaults.refresh
	tt_svars.refresh = (refreshrate == 0) and defaults.refresh or refreshrate*1000
	d("[TamrielTime]New Refresh Ratio: "..tt_svars.refresh.."ms")
end

SLASH_COMMANDS["/tthour"] = function (hours)
	local fixtime = tonumber(hours)
	if (fixtime==fixtime and fixtime~=nil) then
		tt_svars.fix = tt_svars.fix+(fixtime%24)-GetHour()
	end
	d("[TamrielTime]Current Fix: "..tt_svars.fix)
end

SLASH_COMMANDS["/ttalarm"] = function (timestring)
	if timestring == "" then
		tt_svars.alarms = {nalarms = 0}
		d("[TamrielTime]Removed Alarms")
	else
		d("[TamrielTime]Setting Alarm at "..timestring)
		tt.newAlarm(tt_svars.alarms,timestring,Ring)
	end
end

SLASH_COMMANDS["/ttalarms"] = function ()
	d("[TamrielTime]Listing Alarms("..tt_svars.alarms.nalarms.."):")
	for k,v in pairs(tt_svars.alarms) do
		if k~="nalarms" then
			d("\t"..k.."("..((v.times==0) and "once" or "always")..")")
		end
	end
end

SLASH_COMMANDS["/ttdefault"] = function ()
	tt_svars.alarms = {nalarms = 0}
	tt_svars.fix = defaults.fix
	for k,v in pairs(defaults) do
		tt_svars[k] = v
	end
	tt_ui.frame:SetAnchor(CENTER,GuiRoot,TOPLEFT,tt_svars.x,tt_svars.y)
	SetColor(tt_svars.color.r,tt_svars.color.g,tt_svars.color.b)
	SetAutoHide(tt_svars.tta)
	SetLook(tt_svars)
end

function Init()
	tt_svars = ZO_SavedVars:NewAccountWide("tt_svars", VERSION, nil, defaults)
	local wm = GetWindowManager()
	local frame = lu.c(wm:CreateTopLevelWindow())
		:SetAnchor(CENTER,GuiRoot,TOPLEFT,tt_svars.x,tt_svars.y)
		:SetClampedToScreen(true)
		:SetHidden(false)
		:SetMovable(true)
		:SetMouseEnabled(true)
		:SetResizeToFitDescendents(true)
		:SetHandler("OnMouseUp", UpdatePosition)()
	local text = lu.c(wm:CreateControl(nil, frame, CT_LABEL))
		:SetAnchor(CENTER,frame,CENTER,0,0)
		:SetColor(tt_svars.color.r,tt_svars.color.g,tt_svars.color.b)
		:SetVerticalAlignment(50)
		:SetHorizontalAlignment(50)
		:SetAlpha(tt_svars.alpha)()
	tt_ui = {frame=frame, text=text}
	SetLook(tt_svars)
	SetAutoHide = lu.HookInherit(tt_ui.frame, {menu=ZO_KeybindStripControlBackground, chat=ZO_ChatWindowTabTemplate1}, tt_svars.tta, {SetHidden="IsHidden",SetAlpha="GetAlpha"}, {SetHidden=false,SetAlpha=1})
	local ttconf = lam:CreateControlPanel("ttsettings", "TamrielTime")
	lam:AddHeader(ttconf, "TT_MAIN", "")
	lam:AddDescription(ttconf, "TT_CL", "", "")
	lam:AddDropdown(ttconf, "TT_CHANGE_HOUR", "Change Hour", "Changes current hour",{0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23}, GetHour, SLASH_COMMANDS["/tthour"])
	lam:AddSlider(ttconf, "TT_TIME", "Set Time", "Sets absolute day time", 0, 240000, 1, GetTime,SetTime )
	lam:AddSlider(ttconf, "TT_HZ", "Refresh Rate", "Sets refresh rate in seconds", 0.5, 10, 0.5, SLASH_COMMANDS["/ttrefresh"], SLASH_COMMANDS["/ttrefresh"])
	lam:AddDropdown(ttconf, "TT_AHIDE", "Autohide", "Hide when ... ", {"never","menu","chat"}, SLASH_COMMANDS["/tta"], SLASH_COMMANDS["/tta"])
	lam:AddHeader(ttconf, "TT_CLOCK", "")
	lam:AddDescription(ttconf, "TT_INFOBAR", "", "InfoBar Details")
	lam:AddColorPicker(ttconf, "TT_COLOR", "Color", "TamrielTime InfoBar Color", function () return tt_ui.text:GetColor() end, SetColor)
	lam:AddDropdown(ttconf, "TT_FONT", "Font", "TamrielTime InfoBar Font", fontdb, g(tt_svars,"font"), SetFont)
	lam:AddDropdown(ttconf, "TT_STYLE", "Style", "Select the style that will use the font", styledb, g(tt_svars,"style"), SetStyle)
	lam:AddSlider(ttconf, "TT_SIZE", "Select size", "Set font size", 6, 76, 1, g(tt_svars,"size"), SetSize)
	lam:AddDropdown(ttconf, "TT_ALARM", "Alarm Sound", "Select the sound that will play when alarm rings", ringdb, g(tt_svars,"ring"), SetRing)
	lam:AddEditBox(ttconf, "TT_FMT", "Format", "Avaliable placeholders: $W, $M $D $dM $Y $ord $h $h12 $f12 $m $s $n", true, SLASH_COMMANDS["/ttfmt"], SLASH_COMMANDS["/ttfmt"])
	lam:AddHeader(ttconf, "TT_About" , "")
	lam:AddDescription(ttconf, "TT_Details", "\n    Version: v".. VERSION, "TamrielTime Details")
	lam:AddButton(ttconf, "TT_DEFAULTS", "Reset defaults", "Reset all your Settings to default values", SLASH_COMMANDS["/ttdefault"], true, "This will reset all your settings, including: alarms, custom formats, menuhide and custom timezone.")
	Update()
end

EVENT_MANAGER:RegisterForEvent("TamrielTime", EVENT_ADD_ON_LOADED, function ( _, addOnName )
	if addOnName == "TamrielTime" then
		zo_callLater( Init, 1000)
	end
end)