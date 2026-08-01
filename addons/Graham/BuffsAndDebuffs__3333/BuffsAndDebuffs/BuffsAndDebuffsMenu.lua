local bad = GlByGrhmForBuffsAndDebuffs
local LAM = LibAddonMenu2
local panelName = "BuffsAndDebuffsSettingsPanel"

local ref = "ReferenceForBuffsAndDebuffs:"

local iniLag = 2.0
local iniName = "Name me!"
local iniShow = true
local iniFrameSize = 16
local iniFrameColor = { r = 1.0 , g = 0.87, b = 0.68, a = 1.0 }
local iniFrameWidth = 150
local iniFrameX = 1200
local iniFrameY = 600
local iniTarget = "player"
local iniSource = COMBAT_UNIT_TYPE_PLAYER
local iniCharge = "Drain"
local iniThick = 10
local iniSit = false
local iniTimer = 0
local targets = { "Player", "Any", "Group" }
local targetsVal = { "player" , "any" , "group" }
local sources = {"Player", "Any", "Group" }
local sourcesVal = {COMBAT_UNIT_TYPE_PLAYER, 0, COMBAT_UNIT_TYPE_GROUP }
local charges = { "Drain", "Fill" }
local chargesVal = { "Drain", "Fill" }
local iniStartColor = { r = 1.0 , g = 0.0, b = 0.0, a = 1.0 }
local iniEndColor = { r = 0.0 , g = 0.0, b = 1.0, a = 1.0 }
local iniBackColor = { r = 0.0 , g = 0.0, b = 0.0, a = 0.5 }
local timers = { "Off", "Left", "Center", "Right" }
local iniTimerColor = { r = 1.0 , g = 1.0, b = 1.0, a = 1.0 }
local timersVal = { 0, LEFT, CENTER, RIGHT }
local profileBodyOff = false
local frameHeadOff = false
local frameBodyOff = false
local barHeadOff = false
local barBodyOff = false
local selProfile = 1
local selFrame = 1
local selBar = 1
local selID = 1
local newProfile = "New Profile"
local delProfile = "Delete Profile!"
local newFrame = "New Window"
local delFrame = "Delete Window!"
local newBar = "New Bar"
local delBar = "Delete Bar!"
local profileChoices = {}
local profileChoicesVal = {}
local profileNums = {}
local profileNumsVal = {}
local frameChoices = {}
local frameChoicesVal = {}
local frameNums = {}
local frameNumsVal = {}
local barChoices = {}
local barChoicesVal = {}
local barNums = {}
local barNumsVal = {}
local barIDs = {}
local barIDsVal = {}
local isFrame = false
local isBar = false
local effects = { [1] = "Put something in the searches" }
local effectsIDs = {}
local IDsStr = ""


local function ProfilesList()
	profileChoices = {}
	profileChoicesVal = {}
	profileNums = {}
	profileNumsVal = {}
	if bad.saved.profiles then
		for i = 1, #bad.saved.profiles do
			profileChoices[i] = string.format("%d.:%s", i, bad.saved.profiles[i].name)
			profileChoicesVal[i] = i
			profileNums[i] = zo_strformat("<<i:1>>", i)
			profileNumsVal[i] = i 
		end
	end
	table.insert(profileChoices, newProfile)
	table.insert(profileChoicesVal, #profileChoicesVal + 1)
end

local function FramesList()
	frameChoices = {}
	frameChoicesVal = {}
	frameNums = {}
	frameNumsVal = {}
	if isFrame == true then
		for i = 1, #bad.saved.profiles[selProfile].frames do
			frameChoices[i] = string.format("%d.:%s", i, bad.saved.profiles[selProfile].frames[i].name)
			frameChoicesVal[i] = i
			frameNums[i] = zo_strformat("<<i:1>>", i)
			frameNumsVal[i] = i
		end
	end
	table.insert(frameChoices, newFrame)
	table.insert(frameChoicesVal, #frameChoicesVal + 1)
end

local function BarsList()
	barChoices = {}
	barChoicesVal = {}
	barNums = {}
	barNumsVal = {}
	if isBar == true then
		for i = 1, #bad.saved.profiles[selProfile].frames[selFrame].bars do
			barChoices[i] = string.format("%d.:%s", i, bad.saved.profiles[selProfile].frames[selFrame].bars[i].name)
			barChoicesVal[i] = i
			barNums[i] = zo_strformat("<<i:1>>", i)
			barNumsVal[i] = i
		end
	end
	table.insert(barChoices, newBar)
	table.insert(barChoicesVal, #barChoicesVal + 1)
end

local function BarIDsList()
	barIDs = {}
	barIDsVal = {}
	local count = 0
	if isBar == true then
		table.sort(bad.saved.profiles[selProfile].frames[selFrame].bars[selBar].IDs)
		for k, v in ipairs(bad.saved.profiles[selProfile].frames[selFrame].bars[selBar].IDs) do
			barIDs[k+1] = zo_strformat("<<1>>:<<C:2>>", v, GetAbilityName(v))
			barIDsVal[k+1] = k+1
			count = count + 1
		end
	end
	barIDs[1] = zo_strformat("<<1[No/One:/$d IDs:]>>", count)
	barIDsVal[1] = 1
end

local function IsFrame()
	if bad.saved.profiles[selProfile] then
		if bad.saved.profiles[selProfile].frames == nil then bad.saved.profiles[selProfile].frames = {} end
		frameHeadOff = false
		if bad.saved.profiles[selProfile].frames[selFrame] then
			frameBodyOff = false
			isFrame = true
		else 
			frameBodyOff = true
			isFrame = false
		end
	else 
		frameHeadOff = true 
		frameBodyOff = true
		isFrame = false
	end
end

local function IsBar()
	if bad.saved.profiles[selProfile] then
		if bad.saved.profiles[selProfile].frames == nil then bad.saved.profiles[selProfile].frames = {} end
		if bad.saved.profiles[selProfile].frames[selFrame] then
			barHeadOff = false
			if bad.saved.profiles[selProfile].frames[selFrame].bars == nil then bad.saved.profiles[selProfile].frames[selFrame].bars = {} end
			if bad.saved.profiles[selProfile].frames[selFrame].bars[selBar] then
				barBodyOff = false
				isBar = true
			else 
				barBodyOff = true
				isBar = false
			end
		else
			barHeadOff = true 
			barBodyOff = true
			isBar = false
		end
	else
		barHeadOff = true 
		barBodyOff = true 
		isBar = false
	end
end


local function ProfilesUpdate()
	local control = bad.WM:GetControlByName(string.format("%sProfileList", ref))
	control.data.choices = profileChoices
	control.data.choicesValues = profileChoicesVal
	control:UpdateChoices()
	control:UpdateValue()
	control = bad.WM:GetControlByName(string.format("%sProfileNum", ref))
	control.data.choices = profileNums
	control.data.choicesValues = profileNumsVal
	control:UpdateChoices()
	control:UpdateValue()
	control.data.disabled = profileBodyOff
	control:UpdateDisabled()
	control = bad.WM:GetControlByName(string.format("%sProfileName", ref))
	control:UpdateValue()
	control = bad.WM:GetControlByName(string.format("%sProfileLag", ref))
	control:UpdateValue()
	control.data.disabled = profileBodyOff
	control:UpdateDisabled()
end

local function FrameUpdate()
	local control = bad.WM:GetControlByName(string.format("%sFrameList", ref))
	control.data.choices = frameChoices
	control.data.choicesValues = frameChoicesVal
	control:UpdateChoices()
	control:UpdateValue()
	control.data.disabled = frameHeadOff
    control:UpdateDisabled()
	control = bad.WM:GetControlByName(string.format("%sFrameName", ref))
	control:UpdateValue()
	control.data.disabled = frameHeadOff
    control:UpdateDisabled()
	control = bad.WM:GetControlByName(string.format("%sFrameNum", ref))
	control.data.choices = frameNums
	control.data.choicesValues = frameNumsVal
	control:UpdateChoices()
	control:UpdateValue()
	control.data.disabled = frameBodyOff
    control:UpdateDisabled()
	control = bad.WM:GetControlByName(string.format("%sFrameShow", ref))
	control:UpdateValue()
	control.data.disabled = frameBodyOff
    control:UpdateDisabled()
	control = bad.WM:GetControlByName(string.format("%sFrameSize", ref))
	control:UpdateValue()
	control.data.disabled = frameBodyOff
    control:UpdateDisabled()
	control = bad.WM:GetControlByName(string.format("%sFrameColor", ref))
	control:UpdateValue()
	control.data.disabled = frameBodyOff
    control:UpdateDisabled()
	control = bad.WM:GetControlByName(string.format("%sFrameWidth", ref))
	control:UpdateValue()
	control.data.disabled = frameBodyOff
    control:UpdateDisabled()
end

local function IDsUpdate()
	local control = bad.WM:GetControlByName(string.format("%sBarIDs", ref))
	control.data.choices = barIDs
	control.data.choicesValues = barIDsVal
	control:UpdateChoices()
	control:UpdateValue()
	control.data.disabled = barBodyOff
    control:UpdateDisabled()
end

local function BarUpdate()
	selID = 1
	IDsStr = ""
	local control = bad.WM:GetControlByName(string.format("%sBarList", ref))
	control.data.choices = barChoices
	control.data.choicesValues = barChoicesVal
	control:UpdateChoices()
	control:UpdateValue()
	control.data.disabled = barHeadOff
    control:UpdateDisabled()
	control = bad.WM:GetControlByName(string.format("%sBarName", ref))
	control:UpdateValue()
	control.data.disabled = barHeadOff
    control:UpdateDisabled()
	control = bad.WM:GetControlByName(string.format("%sBarNum", ref))
	control.data.choices = barNums
	control.data.choicesValues = barNumsVal
	control:UpdateChoices()
	control:UpdateValue()
	control.data.disabled = barBodyOff
    control:UpdateDisabled()
	control = bad.WM:GetControlByName(string.format("%sBarShow", ref))
	control:UpdateValue()
	control.data.disabled = barBodyOff
    control:UpdateDisabled()
	control = bad.WM:GetControlByName(string.format("%sBarTarget", ref))
	control:UpdateValue()
	control.data.disabled = barBodyOff
    control:UpdateDisabled()
	control = bad.WM:GetControlByName(string.format("%sBarSource", ref))
	control:UpdateValue()
	control.data.disabled = barBodyOff
    control:UpdateDisabled()
	control = bad.WM:GetControlByName(string.format("%sBarCharge", ref))
	control:UpdateValue()
	control.data.disabled = barBodyOff
    control:UpdateDisabled()
	control = bad.WM:GetControlByName(string.format("%sBarThick", ref))
	control:UpdateValue()
	control.data.disabled = barBodyOff
    control:UpdateDisabled()
	control = bad.WM:GetControlByName(string.format("%sBarSit", ref))
	control:UpdateValue()
	control.data.disabled = barBodyOff
    control:UpdateDisabled()
	control = bad.WM:GetControlByName(string.format("%sBarStartColor", ref))
	control:UpdateValue()
	control.data.disabled = barBodyOff
    control:UpdateDisabled()
	control = bad.WM:GetControlByName(string.format("%sBarEndColor", ref))
	control:UpdateValue()
	control.data.disabled = barBodyOff
    control:UpdateDisabled()
	control = bad.WM:GetControlByName(string.format("%sBarBackColor", ref))
	control:UpdateValue()
	control.data.disabled = barBodyOff
    control:UpdateDisabled()
	control = bad.WM:GetControlByName(string.format("%sBarTimer", ref))
	control:UpdateValue()
	control.data.disabled = barBodyOff
    control:UpdateDisabled()
	control = bad.WM:GetControlByName(string.format("%sBarTimerColor", ref))
	control:UpdateValue()
	control.data.disabled = barBodyOff
    control:UpdateDisabled()
	control = bad.WM:GetControlByName(string.format("%sBarCharacter", ref))
	control:UpdateValue()
	control.data.disabled = barBodyOff
    control:UpdateDisabled()
	control = bad.WM:GetControlByName(string.format("%sEffectsSearch", ref))
	control.data.disabled = barBodyOff
    control:UpdateDisabled()
	control = bad.WM:GetControlByName(string.format("%sEffectsList", ref))
	control.data.disabled = barBodyOff
    control:UpdateDisabled()
	control = bad.WM:GetControlByName(string.format("%sEffectIDs", ref))
	control:UpdateValue()
	control.data.disabled = barBodyOff
    control:UpdateDisabled()
	control = bad.WM:GetControlByName(string.format("%sAddIDs", ref))
	control.data.disabled = barBodyOff
    control:UpdateDisabled()
	control = bad.WM:GetControlByName(string.format("%sBarIDs", ref))
	control:UpdateValue()
	control.data.disabled = barBodyOff
    control:UpdateDisabled()
	control = bad.WM:GetControlByName(string.format("%sDelID", ref))
	control.data.disabled = barBodyOff
    control:UpdateDisabled()
	IDsUpdate()
end

local function GetProfileSel()
	if bad.saved.profiles[selProfile] then
		profileBodyOff = false
	else
		profileBodyOff = true
	end
	return selProfile
end 
local function SetProfileSel(var)
	selProfile = var
	if bad.saved.profiles[selProfile] then bad.savedChar.selProfile = selProfile end
	ProfilesUpdate()
	selFrame = 1
	IsFrame()
	FramesList()
	FrameUpdate()
	selBar = 1
	IsBar()
	BarsList()
	BarIDsList()
	BarUpdate()
end

local function GetProfileName()
	if bad.saved.profiles[selProfile] then
	return bad.saved.profiles[selProfile].name
	else return iniName end
end 
local function SetProfileName(var)
	if bad.saved.profiles[selProfile] and var ~= iniName and var ~= "" and var ~= delProfile then
		bad.saved.profiles[selProfile].name = var
		ProfilesList()
		ProfilesUpdate()
	end
	if bad.saved.profiles[selProfile] == nil and var ~= iniName and var ~= "" and var ~= delProfile then
		bad.saved.profiles[selProfile] = {}
		bad.saved.profiles[selProfile].name = var
		bad.saved.profiles[selProfile].lag = iniLag
		bad.saved.profiles[selProfile].frames = {}
		bad.savedChar.selProfile = selProfile
		ProfilesList()
		ProfilesUpdate()
		FrameUpdate()
	end
	if bad.saved.profiles[selProfile] and var == delProfile and selProfile ~= 1 then
		table.remove(bad.saved.profiles, selProfile)
		selProfile = selProfile - 1
		bad.savedChar.selProfile = selProfile
		ProfilesList()
		SetProfileSel(selProfile)
	end
end

local function GetProfileNum()
	return selProfile
end 
local function SetProfileNum(var)
	local temp = bad.saved.profiles[selProfile]
	table.remove(bad.saved.profiles, selProfile)
	table.insert(bad.saved.profiles, var, temp)
	selProfile = var
	bad.savedChar.selProfile = selProfile
	ProfilesList()
	ProfilesUpdate()
end

local function GetProfileLag()
	if bad.saved.profiles[selProfile] then
		if bad.saved.profiles[selProfile].lag then
			return bad.saved.profiles[selProfile].lag
		else return iniLag end
	else return iniLag end
end 
local function SetProfileLag(var)
	bad.saved.profiles[selProfile].lag = var
end

local function GetFrameSel()
	IsFrame()
	IsBar()
	return selFrame
end
local function SetFrameSel(var)
	selFrame = var
	FrameUpdate()
	selBar = 1
	BarsList()
	BarIDsList()
	BarUpdate()
end

local function GetFrameName()
	if isFrame == true then
		return bad.saved.profiles[selProfile].frames[selFrame].name
	else return iniName end 		
end
local function SetFrameName(var)
	if bad.saved.profiles[selProfile].frames[selFrame] and var ~= iniName and var ~= "" and var ~= delFrame then
		bad.saved.profiles[selProfile].frames[selFrame].name = var
		FramesList()
		FrameUpdate()
	end
	if bad.saved.profiles[selProfile].frames[selFrame] == nil and var ~= iniName and var ~= "" and var ~= delFrame then
		bad.saved.profiles[selProfile].frames[selFrame] = {}
		bad.saved.profiles[selProfile].frames[selFrame].name = var
		bad.saved.profiles[selProfile].frames[selFrame].show = iniShow
		bad.saved.profiles[selProfile].frames[selFrame].size = iniFrameSize
		bad.saved.profiles[selProfile].frames[selFrame].color = iniFrameColor
		bad.saved.profiles[selProfile].frames[selFrame].width = iniFrameWidth
		bad.saved.profiles[selProfile].frames[selFrame].x = iniFrameX
		bad.saved.profiles[selProfile].frames[selFrame].y = iniFrameY
		bad.saved.profiles[selProfile].frames[selFrame].bars = {}
		IsFrame()
		FramesList()
		FrameUpdate()
		IsBar()
		BarUpdate()
	end
	if bad.saved.profiles[selProfile].frames[selFrame] and var == delFrame and selFrame ~= 1 then
		table.remove(bad.saved.profiles[selProfile].frames, selFrame)
		selFrame = selFrame - 1
		FramesList()
		SetFrameSel(selFrame)
	end
end

local function GetFrameNum()
	return selFrame
end 
local function SetFrameNum(var)
	local temp = bad.saved.profiles[selProfile].frames[selFrame]
	table.remove(bad.saved.profiles[selProfile].frames, selFrame)
	table.insert(bad.saved.profiles[selProfile].frames, var, temp)
	selFrame = var
	FramesList()
	FrameUpdate()
end

local function GetFrameShow()
	if isFrame == true then
		return bad.saved.profiles[selProfile].frames[selFrame].show
	else return iniShow end
end
local function SetFrameShow(var)
	bad.saved.profiles[selProfile].frames[selFrame].show = var
end

local function GetFrameSize()
	if isFrame == true then
		return bad.saved.profiles[selProfile].frames[selFrame].size
	else return iniFrameSize end
end
local function SetFrameSize(var)
	bad.saved.profiles[selProfile].frames[selFrame].size = var
end

local function GetFrameColor()
	iniFrameColor = { r = 1.0 , g = 0.87, b = 0.68, a = 1.0 }
	if isFrame == true then
		return bad.saved.profiles[selProfile].frames[selFrame].color.r, 
		bad.saved.profiles[selProfile].frames[selFrame].color.g, 
		bad.saved.profiles[selProfile].frames[selFrame].color.b, 
		bad.saved.profiles[selProfile].frames[selFrame].color.a 
	else return iniFrameColor.r, iniFrameColor.g, iniFrameColor.b, iniFrameColor.a end
end
local function SetFrameColor(r,g,b,a)
	bad.saved.profiles[selProfile].frames[selFrame].color.r = r
	bad.saved.profiles[selProfile].frames[selFrame].color.g = g
	bad.saved.profiles[selProfile].frames[selFrame].color.b = b
	bad.saved.profiles[selProfile].frames[selFrame].color.a = a
end

local function GetFrameWidth()
	if isFrame == true then
		return bad.saved.profiles[selProfile].frames[selFrame].width
	else return iniFrameWidth end
end
local function SetFrameWidth(var)
	bad.saved.profiles[selProfile].frames[selFrame].width = var
end


local function GetBarSel()
	IsBar()
	return selBar
end
local function SetBarSel(var)
	selBar = var
	IsBar()
	BarIDsList()
	BarUpdate()
end

local function GetBarName()
	if isBar == true then
		return bad.saved.profiles[selProfile].frames[selFrame].bars[selBar].name
	else return iniName end
end
local function SetBarName(var)
	if bad.saved.profiles[selProfile].frames[selFrame].bars[selBar] and var ~= iniName and var ~= "" and var ~= delBar then
		bad.saved.profiles[selProfile].frames[selFrame].bars[selBar].name = var
		BarsList()
		BarUpdate()
	end
	if bad.saved.profiles[selProfile].frames[selFrame].bars[selBar] == nil and var ~= iniName and var ~= "" and var ~= delBar then
		bad.saved.profiles[selProfile].frames[selFrame].bars[selBar] = {}
		bad.saved.profiles[selProfile].frames[selFrame].bars[selBar].name = var
		bad.saved.profiles[selProfile].frames[selFrame].bars[selBar].show = iniShow
		bad.saved.profiles[selProfile].frames[selFrame].bars[selBar].target = iniTarget
		bad.saved.profiles[selProfile].frames[selFrame].bars[selBar].source = iniSource
		bad.saved.profiles[selProfile].frames[selFrame].bars[selBar].charge = iniCharge
		bad.saved.profiles[selProfile].frames[selFrame].bars[selBar].thick = iniThick
		bad.saved.profiles[selProfile].frames[selFrame].bars[selBar].sitsOn = iniSit
		bad.saved.profiles[selProfile].frames[selFrame].bars[selBar].startColor = iniStartColor
		bad.saved.profiles[selProfile].frames[selFrame].bars[selBar].endColor = iniEndColor
		bad.saved.profiles[selProfile].frames[selFrame].bars[selBar].backColor = iniBackColor
		bad.saved.profiles[selProfile].frames[selFrame].bars[selBar].timer = iniTimer
		bad.saved.profiles[selProfile].frames[selFrame].bars[selBar].timerColor = iniTimerColor
		bad.saved.profiles[selProfile].frames[selFrame].bars[selBar].IDs = {}
		IsBar()
		BarsList()
		BarUpdate()
	end
	if bad.saved.profiles[selProfile].frames[selFrame].bars[selBar] and var == delBar and selBar ~= 1 then
		table.remove(bad.saved.profiles[selProfile].frames[selFrame].bars, selBar)
		selBar = selBar - 1
		BarsList()
		SetBarSel(selBar)
	end
end

local function GetBarNum()
	return selBar
end 
local function SetBarNum(var)
	local temp = bad.saved.profiles[selProfile].frames[selFrame].bars[selBar]
	table.remove(bad.saved.profiles[selProfile].frames[selFrame].bars, selBar)
	table.insert(bad.saved.profiles[selProfile].frames[selFrame].bars, var, temp)
	selBar = var
	BarsList()
	BarUpdate()
end

local function GetBarShow()
	if isBar == true then
		return bad.saved.profiles[selProfile].frames[selFrame].bars[selBar].show
	else return iniShow end
end
local function SetBarShow(var)
	bad.saved.profiles[selProfile].frames[selFrame].bars[selBar].show = var
end

local function GetBarTarget()
	if isBar == true then
		return bad.saved.profiles[selProfile].frames[selFrame].bars[selBar].target
	else return iniTarget end
end
local function SetBarTarget(var)
	bad.saved.profiles[selProfile].frames[selFrame].bars[selBar].target = var
end

local function GetBarSource()
	if isBar == true then
		return bad.saved.profiles[selProfile].frames[selFrame].bars[selBar].source
	else return iniSource end
end
local function SetBarSource(var)
	bad.saved.profiles[selProfile].frames[selFrame].bars[selBar].source = var
end

local function GetBarCharge()
	if isBar == true then
		return bad.saved.profiles[selProfile].frames[selFrame].bars[selBar].charge
	else return iniCharge end
end
local function SetBarCharge(var)
	bad.saved.profiles[selProfile].frames[selFrame].bars[selBar].charge = var
end

local function GetBarThick()
	if isBar == true then
		return bad.saved.profiles[selProfile].frames[selFrame].bars[selBar].thick
	else return iniThick end
end
local function SetBarThick(var)
	bad.saved.profiles[selProfile].frames[selFrame].bars[selBar].thick = var
end

local function GetBarSit()
	if isBar == true then
		return bad.saved.profiles[selProfile].frames[selFrame].bars[selBar].sitsOn
	else return iniSit end
end
local function SetBarSit(var)
	bad.saved.profiles[selProfile].frames[selFrame].bars[selBar].sitsOn = var
end

local function GetBarStartColor()
	iniStartColor = { r = 1.0 , g = 0.0, b = 0.0, a = 1.0 }
	if isBar == true then
		return bad.saved.profiles[selProfile].frames[selFrame].bars[selBar].startColor.r,
		bad.saved.profiles[selProfile].frames[selFrame].bars[selBar].startColor.g,
		bad.saved.profiles[selProfile].frames[selFrame].bars[selBar].startColor.b,
		bad.saved.profiles[selProfile].frames[selFrame].bars[selBar].startColor.a
	else return iniStartColor.r, iniStartColor.g, iniStartColor.b, iniStartColor.a end
end
local function SetBarStartColor(r,g,b,a)
	bad.saved.profiles[selProfile].frames[selFrame].bars[selBar].startColor.r = r
	bad.saved.profiles[selProfile].frames[selFrame].bars[selBar].startColor.g = g
	bad.saved.profiles[selProfile].frames[selFrame].bars[selBar].startColor.b = b
	bad.saved.profiles[selProfile].frames[selFrame].bars[selBar].startColor.a = a
end

local function GetBarEndColor()
	iniEndColor = { r = 0.0 , g = 0.0, b = 1.0, a = 1.0 }
	if isBar == true then
		return bad.saved.profiles[selProfile].frames[selFrame].bars[selBar].endColor.r,
		bad.saved.profiles[selProfile].frames[selFrame].bars[selBar].endColor.g,
		bad.saved.profiles[selProfile].frames[selFrame].bars[selBar].endColor.b,
		bad.saved.profiles[selProfile].frames[selFrame].bars[selBar].endColor.a
	else return iniEndColor.r, iniEndColor.g, iniEndColor.b, iniEndColor.a end
end
local function SetBarEndColor(r,g,b,a)
	bad.saved.profiles[selProfile].frames[selFrame].bars[selBar].endColor.r = r
	bad.saved.profiles[selProfile].frames[selFrame].bars[selBar].endColor.g = g
	bad.saved.profiles[selProfile].frames[selFrame].bars[selBar].endColor.b = b
	bad.saved.profiles[selProfile].frames[selFrame].bars[selBar].endColor.a = a
end

local function GetBarBackColor()
	iniBackColor = { r = 0.0 , g = 0.0, b = 0.0, a = 0.5 }
	if isBar == true then
		return bad.saved.profiles[selProfile].frames[selFrame].bars[selBar].backColor.r,
		bad.saved.profiles[selProfile].frames[selFrame].bars[selBar].backColor.g,
		bad.saved.profiles[selProfile].frames[selFrame].bars[selBar].backColor.b,
		bad.saved.profiles[selProfile].frames[selFrame].bars[selBar].backColor.a
	else return iniBackColor.r, iniBackColor.g, iniBackColor.b, iniBackColor.a end
end
local function SetBarBackColor(r,g,b,a)
	bad.saved.profiles[selProfile].frames[selFrame].bars[selBar].backColor.r = r
	bad.saved.profiles[selProfile].frames[selFrame].bars[selBar].backColor.g = g
	bad.saved.profiles[selProfile].frames[selFrame].bars[selBar].backColor.b = b
	bad.saved.profiles[selProfile].frames[selFrame].bars[selBar].backColor.a = a
end

local function GetBarTimer()
	if isBar == true then
		return bad.saved.profiles[selProfile].frames[selFrame].bars[selBar].timer
	else return iniTimer end
end
local function SetBarTimer(var)
	bad.saved.profiles[selProfile].frames[selFrame].bars[selBar].timer = var
end

local function GetBarTimerColor()
	iniTimerColor = { r = 1.0 , g = 1.0, b = 1.0, a = 1.0 }
	if isBar == true then
		return bad.saved.profiles[selProfile].frames[selFrame].bars[selBar].timerColor.r,
		bad.saved.profiles[selProfile].frames[selFrame].bars[selBar].timerColor.g,
		bad.saved.profiles[selProfile].frames[selFrame].bars[selBar].timerColor.b,
		bad.saved.profiles[selProfile].frames[selFrame].bars[selBar].timerColor.a
	else return iniTimerColor.r, iniTimerColor.g, iniTimerColor.b, iniTimerColor.a end
end
local function SetBarTimerColor(r,g,b,a)
	bad.saved.profiles[selProfile].frames[selFrame].bars[selBar].timerColor.r = r
	bad.saved.profiles[selProfile].frames[selFrame].bars[selBar].timerColor.g = g
	bad.saved.profiles[selProfile].frames[selFrame].bars[selBar].timerColor.b = b
	bad.saved.profiles[selProfile].frames[selFrame].bars[selBar].timerColor.a = a
end

local function GetBarCharacter()
	if isBar == true then
		if bad.saved.profiles[selProfile].frames[selFrame].bars[selBar].character then
			return bad.saved.profiles[selProfile].frames[selFrame].bars[selBar].character
		end
	end
end
local function SetBarCharacter(var)
	if var == "" then
		bad.saved.profiles[selProfile].frames[selFrame].bars[selBar].character = nil
	else
		bad.saved.profiles[selProfile].frames[selFrame].bars[selBar].character = var
	end
end

local function SetEffectsSearch(var)
	if var ~= "" then
		effects = {}
		effectsIDs = {}
		local effect = ""
		local leng = string.len(var)
		local j = 2
		for i = 1, #bad.effectIDs do
			effect = zo_strformat("<<C:1>>", GetAbilityName(bad.effectIDs[i][1]))
			if string.lower(string.sub(effect, 1, leng)) == string.lower(var) 
			or leng > 3 and string.find(string.lower(effect), string.lower(var)) then
				effects[j] = effect
				effectsIDs[effect] = {}
				for y = 1, #bad.effectIDs[i] do
					effectsIDs[effect][y] = bad.effectIDs[i][y]
				end
				j = j + 1
			end
		end
		effects[1] = zo_strformat("<<1[No effect found/One effect found:/$d effects found:]>>", j-2)
		local control = bad.WM:GetControlByName(string.format("%sEffectsList", ref))
		control.data.choices = effects
		control:UpdateChoices()
		control:UpdateValue()
	end
end

local function GetEffectsList() return effects[1] end
local function SetEffectsList(var)
	if effectsIDs[var] then
		IDsStr = table.concat(effectsIDs[var],";")
		local control = bad.WM:GetControlByName(string.format("%sEffectIDs", ref))
		control:UpdateValue()
	end
end

local function GetEffectIDs() return IDsStr end
local function SetEffectIDs(var) IDsStr = var end

local function AddIDs()
	if IDsStr ~= "" then
		local array = {}
		local id = 0
		for i = 1, #bad.saved.profiles[selProfile].frames[selFrame].bars[selBar].IDs do
			array[bad.saved.profiles[selProfile].frames[selFrame].bars[selBar].IDs[i]] = 1
		end
		bad.saved.profiles[selProfile].frames[selFrame].bars[selBar].IDs = {}
		local s = 1
		for i = 1, string.len(IDsStr) do
			if string.sub(IDsStr,i+1,i+1) == ";" or i == string.len(IDsStr) then
				if tonumber(string.sub(IDsStr,s,i)) ~= nil then
					id = tonumber(string.sub(IDsStr,s,i))
					if GetAbilityName(id) ~= "" then
						array[id] = 1
					end
				end
			s=i+2
			end
		end
		local i = 1
		for k, _ in pairs(array) do
			bad.saved.profiles[selProfile].frames[selFrame].bars[selBar].IDs[i] = k
			i = i + 1
		end
		BarIDsList()
		IDsUpdate()
	end
end

local function GetIDs() return selID end
local function SetIDs(var) selID = var end

local function DelID()
	if selID ~= 1 and bad.saved.profiles[selProfile].frames[selFrame].bars[selBar].IDs[selID-1] then
		table.remove(bad.saved.profiles[selProfile].frames[selFrame].bars[selBar].IDs, selID-1)
		if bad.saved.profiles[selProfile].frames[selFrame].bars[selBar].IDs[selID-1] == nil then selID = selID - 1 end
		BarIDsList()
		IDsUpdate()
	end
end

local index = 0
local function indexer()
	index = index + 1
	return index
end

local menu = {}
local panelData = { type = "panel", name = "Buffs and Debuffs", author = "Graham", version = "1.2Pre" }
function bad.menuInitialize()

	selProfile = bad.savedChar.selProfile

	IsFrame()
	IsBar()
	ProfilesList()
	FramesList()
	BarsList()
	BarIDsList()

	local panel = LAM:RegisterAddonPanel(panelName, panelData)
	local optionsTable = {
	-- ### PROFILES ###
		[indexer()] = {
			type = "description",
			text = "Settings will only take effect after |cff0000ReloadUI|r - see below for further instructions."
		},
		[indexer()] = {
			type = "header",
			name = "Profile",
			width = "full",
		},
		[indexer()] = {
			type = "dropdown",
			name = "Select or create profile",
			tooltip = "Select a profile or create a new one.",
			choices = profileChoices,
			choicesValues = profileChoicesVal,
			getFunc = GetProfileSel,
			setFunc = SetProfileSel,
			width = "full",
			reference = string.format("%sProfileList", ref)
		},
		[indexer()] = {
			type = "editbox",
			name = "Profile name",
			tooltip = "Give the profile a name.",
			getFunc = GetProfileName,
			setFunc = SetProfileName,
			isMultiline = false,
			width = "full",
			reference = string.format("%sProfileName", ref)
		},
		[indexer()] = {
			type = "dropdown",
			name = "Position",
			disabled = profileBodyOff,
			tooltip = "Set the position of the proflis.",
			choices = profileNums,
			choicesValues = profileNumsVal,
			getFunc = GetProfileNum,
			setFunc = SetProfileNum,
			width = "full",
			reference = string.format("%sProfileNum", ref)
		},
		[indexer()] = {
			type = "slider",
			name = "Delay",
			disabled = profileBodyOff,
			tooltip = "Determine when the status bars are to expire if termination messages are late or do not come at all due to lags.",
			getFunc = GetProfileLag,
			setFunc = SetProfileLag,
			step = 0.25,
			min = 0.0,
			max = 5.0,
			reference = string.format("%sProfileLag", ref)
		},
		-- ### WINDOWS ###
		[indexer()] = {
			type = "header",
			name = "Fenster",
			width = "full",
		},
		[indexer()] = {
			type = "dropdown",
			name = "Select or create window",
			disabled = frameHeadOff,
			tooltip = "Select a window or create a new one.",
			choices = frameChoices,
			choicesValues = frameChoicesVal,
			getFunc = GetFrameSel,
			setFunc = SetFrameSel,
			width = "full",
			reference = string.format("%sFrameList", ref)
		},
		[indexer()] = {
			type = "editbox",
			name = "Window name",
			disabled = frameHeadOff,
			tooltip = "Set the name of the window.",
			getFunc = GetFrameName,
			setFunc = SetFrameName,
			isMultiline = false,
			width = "full",
			reference = string.format("%sFrameName", ref)
		},
		[indexer()] = {
			type = "dropdown",
			name = "Position",
			disabled = frameBodyOff,
			tooltip = "Set the position of the window.",
			choices = frameNums,
			choicesValues = frameNumsVal,
			getFunc = GetFrameNum,
			setFunc = SetFrameNum,
			width = "full",
			reference = string.format("%sFrameNum", ref)
		},
		[indexer()] = {
			type = "checkbox",
			name = "Show",
			disabled = frameBodyOff,
			getFunc = GetFrameShow,
			setFunc = SetFrameShow,
			reference = string.format("%sFrameShow", ref)
		},
		[indexer()] = {
			type = "slider",
			name = "Font size",
			disabled = frameBodyOff,
			tooltip = "Adjust the size of the font.",
			getFunc = GetFrameSize,
			setFunc = SetFrameSize,
			min = 8,
			max = 32,
			width = "full",
			reference = string.format("%sFrameSize", ref),
		},
		[indexer()] = {			
			type = "colorpicker",
			disabled = frameBodyOff,
			name = "Font colour",
			tooltip = "Adjust the colour of the font.",
			getFunc = GetFrameColor,
			setFunc = SetFrameColor,
			width = "full",
			reference = string.format("%sFrameColor", ref),
		},
		[indexer()] = {
			type = "slider",
			name = "Window width",
			disabled = frameBodyOff,
			tooltip = "Adjust the width of the window, which also affects the length of the slats.",
			getFunc = GetFrameWidth,
			setFunc = SetFrameWidth,
			min = 50,
			max = 300,
			width = "full",
			reference = string.format("%sFrameWidth", ref),
		},
		-- ### BARS ###
		[indexer()] = {
			type = "header",
			name = "Status bars",
			width = "full",
		},
		[indexer()] = {
			type = "dropdown",
			name = "Select or create status bar",
			disabled = barHeadOff,
			tooltip = "Select a status bar or create a new one.",
			choices = barChoices,
			choicesValues= barChoicesVal,
			getFunc = GetBarSel,
			setFunc = SetBarSel,
			width = "full",
			reference = string.format("%sBarList", ref),
		},
		[indexer()] = {
			type = "editbox",
			name = "Name",
			disabled = barHeadOff,
			tooltip = "Set the name of the bar.",
			getFunc = GetBarName,
			setFunc = SetBarName,
			isMultiline = false,
			width = "full",
			reference = string.format("%sBarName", ref),		
		},
		[indexer()] = {
			type = "dropdown",
			name = "Position",
			disabled = barBodyOff,
			tooltip = "Set the position of the bar.",
			choices = barNums,
			choicesValues = barNumsVal,
			getFunc = GetBarNum,
			setFunc = SetBarNum,
			width = "full",
			reference = string.format("%sBarNum", ref)
		},
		[indexer()] = {
			type = "checkbox",
			name = "Show",
			disabled = barBodyOff,
			tooltip = "Determine whether the bar is to be displayed. If it is not displayed, the bars below it move up.",
			getFunc = GetBarShow,
			setFunc = SetBarShow,
			reference = string.format("%sBarShow", ref)
		},
		[indexer()] = {
			type = "dropdown",
			name = "Charge",
			disabled = barBodyOff,
			tooltip = "Set whether the bar should fill up or drain.",
			choices = charges,
			choicesValues = chargesVal,
			getFunc = GetBarCharge,
			setFunc = SetBarCharge,
			reference = string.format("%sBarCharge", ref)
		},
		[indexer()] = {
			type = "slider",
			name = "Thickness",
			disabled = barBodyOff,
			tooltip = "Determine how thick the bar should be.",
			getFunc = GetBarThick,
			setFunc = SetBarThick,
			min = 5,
			max = 30,
			reference = string.format("%sBarThick", ref)
		},
		[indexer()] = {
			type = "checkbox",
			name = "On top",
			disabled = barBodyOff,
			tooltip = "If active, the bar is placed on top of the one above it. For this, both should be the same thickness.",
			getFunc = GetBarSit,
			setFunc = SetBarSit,
			reference = string.format("%sBarSit", ref)
		},
		[indexer()] = {			
			type = "colorpicker",
			disabled = barBodyOff,
			name = "Start colour",
			tooltip = "Match the colour that runs from left to right on the bar.",
			getFunc = GetBarStartColor,
			setFunc = SetBarStartColor,
			width = "full",
			reference = string.format("%sBarStartColor", ref)
		},
		[indexer()] = {			
			type = "colorpicker",
			name = "End colour",
			disabled = barBodyOff,
			tooltip = "Match the colour that runs from right to left on the bar.",
			getFunc = GetBarEndColor,
			setFunc = SetBarEndColor,
			width = "full",
			reference = string.format("%sBarEndColor", ref)
		},
		[indexer()] = {			
			type = "colorpicker",
			name = "Background colour",
			disabled = barBodyOff,
			tooltip = "Adjust the colour of the bar background.",
			getFunc = GetBarBackColor,
			setFunc = SetBarBackColor,
			width = "full",
			reference = string.format("%sBarBackColor", ref)
		},
		[indexer()] = {
			type = "dropdown",
			name = "Timer",
			disabled = barBodyOff,
			tooltip = "Set whether and where a timer is displayed on the bar.",
			choices = timers,
			choicesValues = timersVal,
			getFunc = GetBarTimer,
			setFunc = SetBarTimer,
			reference = string.format("%sBarTimer", ref)
		},
		[indexer()] = {			
			type = "colorpicker",
			disabled = barBodyOff,
			name = "Timer colour",
			tooltip = "Adjust the font colour of the timer.",
			getFunc = GetBarTimerColor,
			setFunc = SetBarTimerColor,
			width = "full",
			reference = string.format("%sBarTimerColor", ref),
		},
		[indexer()] = {
			type = "divider",
		},
		[indexer()] = {
			type = "description",
			text = "Filter settings for triggering the bars:"
		},
		[indexer()] = {
			type = "dropdown",
			name = "Source",
			disabled = barBodyOff,
			tooltip = "Filters who has cast the status effect.",
			choices = sources,
			choicesValues = sourcesVal,
			getFunc = GetBarSource,
			setFunc = SetBarSource,
			reference = string.format("%sBarSource", ref)
		},
		[indexer()] = {
			type = "dropdown",
			name = "Target",
			disabled = barBodyOff,
			tooltip = "Filters on whom the status effect works.",
			choices = targets,
			choicesValues = targetsVal,
			getFunc = GetBarTarget,
			setFunc = SetBarTarget,
			reference = string.format("%sBarTarget", ref)
		},
		[indexer()] = {
			type = "editbox",
			name = "Character",
			disabled = barHeadOff,
			tooltip = "Only that character's name is used to trigger the bar if it is entered here. Suffix like ^Fx for female or ^Mx for male required.",
			getFunc = GetBarCharacter,
			setFunc = SetBarCharacter,
			isMultiline = false,
			width = "full",
			reference = string.format("%sBarCharacter", ref),		
		},
		[indexer()] = {
			type = "divider",
		},
		--Effects
		[indexer()] = {
			type = "description",
			text = "Add the status effects (buffs or debuffs) to the bar here.:"
		},
		[indexer()] = {
			type = "editbox",
			name = "Search for status effects",
			disabled = barBodyOff,
			tooltip = "Enter at least one character in the search so that effects appear in the list.",
			getFunc = function() return "" end,
			setFunc = SetEffectsSearch,
			width = "full",
			reference = string.format("%sEffectsSearch", ref),
		},
		[indexer()] = {
			type = "dropdown",
			name = "Select status effect",
			disabled = barBodyOff,
			tooltip = "The effects are listed according to the characters entered in the search field and their IDs, once one has been selected, land in the field below.",
			choices = effects,
			scrollable = true,
			getFunc = GetEffectsList,
			setFunc = SetEffectsList,
			reference = string.format("%sEffectsList", ref)
		},
		[indexer()] = {
			type = "editbox",
			name = "ID(s) of the status effect",
			disabled = barBodyOff,
			tooltip = "IDs of the status effects that then activate the bar are created separated by a semicolon.",
			getFunc = GetEffectIDs,
			setFunc = SetEffectIDs,
			width = "full",
			reference = string.format("%sEffectIDs", ref),
		},
		[indexer()] = {
			type = "button",
			name = "Add ID(s)",
			tooltip = "Here the IDs of the status effect are added.",
			disabled = barBodyOff,
			func = AddIDs,
			width = "full",
			reference = string.format("%sAddIDs", ref)
		},
		[indexer()] = {
			type = "dropdown",
			name = "Added IDs",
			tooltip = "The added IDs are listed here.",
			disabled = barBodyOff,
			choices = barIDs,
			choicesValues = barIDsVal,
			getFunc = GetIDs,
			setFunc = SetIDs,
			reference = string.format("%sBarIDs", ref)
		},
		[indexer()] = {
			type = "button",
			name = "ID Remove",
			tooltip = "IDs that have been added can be removed here.",
			disabled = barBodyOff,
			func = DelID,
			width = "full",
			reference = string.format("%sDelID", ref)
		},
		[indexer()] = {
			type = "divider",
		},
		[indexer()] = {
			type = "button",
			name = "ReloadUI",
			func = function() return ReloadUI() end,
			width = "full",
		},
		[indexer()] = {
			type = "divider",
		},
		[indexer()] = {
			type = "description",
			title = "Profiles",
			text = "are available to the extent that all characters can use them. The selected character is then used for that character."
		},
		[indexer()] = {
			type = "description",
			title = "Delete",
			text = "To do this, enter Delete Profile/Delete Window/Delete Bar in the respective name field. Bear in mind, however, that when you delete a window, its bars are also deleted - and in the case of a profile, its windows as well as its bars! Otherwise it is sufficient to simply switch off a window or a bar."
		},
	}
	LAM:RegisterOptionControls(panelName, optionsTable)
	SLASH_COMMANDS["/table_list"] = function()
		for i = 1, #profileNums do
			d(profileNums[i])
		end
		for i = 1, #profileNumsVal do
			d(profileNumsVal[i])
		end
	end
	
end
--[[

[8] = {
            type = "description",
            title = nil,
            text = "",
            width = "full",
            reference = GroupBuffsMenu.constants.references.DESCRIPTION_NEW_FRAME_ERROR
},
function GroupBuffsMenu.AddFrame()
    local newFrameName = GroupBuffsMenu.GetNewFrameName()
    if newFrameName ~= nil and GroupBuffs.isUniqueFrameName(newFrameName) then
        GroupBuffsMenu.SetNewFrameName("&quot
        GroupBuffsMenu.SetErrorMessage(GroupBuffsMenu.constants.references.DESCRIPTION_NEW_FRAME_ERROR, "&quot
        GroupBuffs.AddNewFrame(newFrameName)
        
        GroupBuffsMenu.UpdateFrameDropdown()
        GroupBuffsMenu.localValues.selectedFrameName = newFrameName

    else
        GroupBuffsMenu.SetErrorMessage(GroupBuffsMenu.constants.references.DESCRIPTION_NEW_FRAME_ERROR, GroupBuffs.config.constants.menu.ERROR_UNIQUE_FRAME_NAME)
    end
end
 function GroupBuffsMenu.SetErrorMessage(controlName, errorMessage)
    local errorDescription = wm:GetControlByName(controlName)
    if errorDescription ~= nil and errorDescription.data ~= nil then
        errorDescription.data.text = errorMessage
        errorDescription:UpdateValue()
    end
end

if NewBar == var then 
				local Control = bad.wm:GetControlByName(BarHeaderRef)
				Control.data.name = NewBarHeader
				Control:UpdateValue()
			else
				local Control = bad.wm:GetControlByName(BarHeaderRef)
				Control.data.name = EditBarHeader
				Control:UpdateValue()
			end
]]
