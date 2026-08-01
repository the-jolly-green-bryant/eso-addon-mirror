ZBNS = {
	name = "ZBNS",

	combatMonitoring = false,
	pollingActive = false,
	pollingInterval = 200,

	-- Default settings
	defaults = {
		left = 1330.3275146484,
		top = 325.6679077148,
		showHP = false,
		showName = false,
		showStage = false,
		lockUI = true,
		mode = "Custom",
		BossWidth			=280,
		BossHeight			=36,
		FontSize			=14,
		numberOfCustomBosses =1,
		bossData ={}
	},

	maxRows = MAX_BOSSES,
	rows = { },
	Frame = { },
	bosses = 0,

	col		={150/255,30/255,060/255,1},
	col1		={0,030/255,220/255,1},

	Textures={
		none				='',
		ftc			='/esoui/art/icons/mapkey/mapkey_stables.dds',
	},
	FrameFont1			='esobold',
	bossName = nil
};

local fonts={
	standard		="$(MEDIUM_FONT)",
	esobold		="$(BOLD_FONT)",
	antique		="/EsoUI/Common/Fonts/ProseAntiquePSMT.otf",
	handwritten		="/EsoUI/Common/Fonts/Handwritten_Bold.otf",
	trajan		="/EsoUI/Common/Fonts/TrajanPro-Regular.otf",
	futura		="/EsoUI/Common/Fonts/FuturaStd-CondensedLight.otf",
	futurabold		="/EsoUI/Common/Fonts/FuturaStd-Condensed.otf",
	gamepad_medium	="EsoUI/Common/Fonts/FTN57.otf",
	gamepad_bold	="EsoUI/Common/Fonts/FTN87.otf",
}

local countdownTimeline = nil
local number=0
local bhelp=true
local bossModes = {}

local function LineA(name, parent, dims, anchor, color, thickness, hidden)
	--Validate arguments
	if not name then name="UnnamedFrame"..number number=number+1 end
	parent=parent or GuiRoot
	if (dims=="inherit" or #dims~=2) then dims={parent:GetWidth(), parent:GetHeight()} end
	if (#anchor~=4 and #anchor~=5) then return end
	color=(color~=nil and #color==4) and color or {1, 1, 1, 1}
	hidden=(hidden==nil) and false or hidden
	--Create the line
	local control=_G[name] or WINDOW_MANAGER:CreateControl(name, parent, CT_LINE)
	--Apply properties
	control:ClearAnchors()
	control:SetAnchor(TOPLEFT, #anchor==5 and anchor[5] or parent, anchor[2], anchor[3], anchor[4])
	control:SetAnchor(BOTTOMRIGHT, #anchor==5 and anchor[5] or parent, anchor[2], anchor[3]+dims[1], anchor[4]+dims[2])
	control:SetColor(unpack(color))
	control:SetThickness(thickness)
	control:SetHidden(hidden)
	return control
end

local function LabelA(name, parent, dims, anchor, font, color, align, text, hidden)
	parent=(parent==nil) and GuiRoot or parent
	if (#anchor~=4 and #anchor~=5) then return end
	font	=(font==nil) and "ZoFontGame" or font
	color	=(color~=nil and #color==4) and color or {1,1,1,1}
	align	=(align~=nil and #align==2) and align or {0,0}
	hidden=(hidden==nil) and false or hidden

	--Create the label
	local label=_G[name] or WINDOW_MANAGER:CreateControl(name, parent, CT_LABEL)

	if dims then label:SetDimensions(dims[1], dims[2]) end
	label:ClearAnchors()
	label:SetAnchor(anchor[1], #anchor==5 and anchor[5] or parent, anchor[2], anchor[3], anchor[4])
	label:SetFont(font or 'ZoFontGame')
	label:SetColor(unpack(color))
	label:SetHorizontalAlignment(align[1])
	label:SetVerticalAlignment(align[2])
	label:SetText(text)
	label:SetHidden(hidden)
	return label
end

local function ControlA(name, parent, dims, anchor, hidden)
	parent=parent or GuiRoot
	if dims=="inherit" or #dims~=2 then dims={parent:GetWidth(), parent:GetHeight()} end
	hidden=hidden==nil and false or hidden

	--Create the control
	local control=_G[name] or WINDOW_MANAGER:CreateControl(name, parent, CT_CONTROL)

	--Apply properties
	--	control:SetParent(parent)
	control:SetDimensions(dims[1], dims[2])
	control:ClearAnchors()
	control:SetAnchor(anchor[1], #anchor==5 and anchor[5] or parent, anchor[2], anchor[3], anchor[4])
	control:SetHidden(hidden)
	return control
end

local function Chain(object)
	--Setup the metatable
	local T={}
	setmetatable(T, {__index=function(self, func)
		--Know when to stop chaining
		if func=="__END" then return object end
		--Otherwise, add the method to the parent object
		return function(self, ...)
			assert(object[func], func .. " missing in object")
			object[func](object, ...)
			return self
		end
	end})
	--Return the metatable
	return T
end

local function BackdropA(name, parent, dims, anchor, center, edge, tex, hidden)
	parent=(parent==nil) and GuiRoot or parent
	if (dims=="inherit" or #dims~=2) then dims={parent:GetWidth(), parent:GetHeight()} end
	if (#anchor~=4 and #anchor~=5) then return end
	center=(center~=nil and #center==4) and center or {0,0,0,0.4}
	edge=(edge~=nil and #edge==4) and edge or {0,0,0,1}
	hidden=(hidden==nil) and false or hidden

	--Create the backdrop
	local backdrop=_G[name]
	if (backdrop==nil) then backdrop=WINDOW_MANAGER:CreateControl(name, parent, CT_BACKDROP) end

	--Apply properties
	local backdrop=Chain(backdrop)
	:SetDimensions(dims[1], dims[2])
	:ClearAnchors()
	:SetAnchor(anchor[1], #anchor==5 and anchor[5] or parent, anchor[2], anchor[3], anchor[4])
	:SetCenterColor(center[1], center[2], center[3], center[4])
	:SetEdgeColor(edge[1], edge[2], edge[3], edge[4])
	:SetEdgeTexture("",8,2,2)
	:SetHidden(hidden)
	:SetCenterTexture(tex)
	.__END
	return backdrop
end

local function StatusbarA(name, parent, dims, anchor, color, tex, hidden)
	--Validate arguments
	if (name==nil or name=="") then return end
	parent=(parent==nil) and GuiRoot or parent
	if (dims=="inherit" or #dims~=2) then dims={parent:GetWidth(), parent:GetHeight()} end
	if (#anchor~=4 and #anchor~=5) then return end
	color=(color~=nil and #color==4) and color or {1, 1, 1, 1}
	hidden=(hidden==nil) and false or hidden
	--Create the status bar
	local bar=_G[name]
	if (bar==nil) then bar=WINDOW_MANAGER:CreateControl(name, parent, CT_STATUSBAR) end
	--Apply properties
	local bar=Chain(bar)
	:SetDimensions(dims[1], dims[2])
	:ClearAnchors()
	:SetAnchor(anchor[1], #anchor==5 and anchor[5] or parent, anchor[2], anchor[3], anchor[4])
	:SetColor(color[1], color[2], color[3], color[4])
	:SetHidden(hidden)
	:SetTexture(tex)
	.__END
	return bar
end

local function FontA(font, size, shadow, outline)
	local font=fonts[font] and fonts[font] or font
	local size=size or 14
	local shadow=shadow and '|soft-shadow-thick' or ''
	if outline then shadow='|thick-outline' end
	return font..'|'..size..shadow
end

local function MoveA(control,anchor,name,anchorPoint)
	--Get anchor position
	local anchorX=0
	local w,h=control:GetWidth(),control:GetHeight()
	anchorPoint=anchorPoint or CENTER

	--Get the new position
	local isValidAnchor, point, relativeTo, relativePoint, offsetX, offsetY=control:GetAnchor()
	if not isValidAnchor then return end
	--Save the anchors
	offsetX=math.floor(offsetX*10)/10 offsetY=math.floor(offsetY*10)/10

	offsetX=point==128 and offsetX or((point==3 or point==6) and offsetX-GuiRoot:GetWidth()/2+w/2 or GuiRoot:GetWidth()/2+offsetX-w/2)
	offsetY=point==128 and offsetY or((point==3 or point==9) and offsetY-GuiRoot:GetHeight()/2+h/2 or GuiRoot:GetHeight()/2+offsetY-h/2)
	offsetX=math.floor(offsetX*10)/10 offsetY=math.floor(offsetY*10)/10
	if anchorPoint==RIGHT or anchorPoint==BOTTOMRIGHT or anchorPoint==TOPRIGHT then offsetX=offsetX+w/2
		elseif anchorPoint==LEFT or anchorPoint==BOTTOMLEFT or anchorPoint==TOPLEFT then offsetX=offsetX-w/2
	end
	if anchorPoint==BOTTOM or anchorPoint==BOTTOMRIGHT or anchorPoint==BOTTOMRIGHT then offsetY=offsetY+h/2
		elseif anchorPoint==TOP or anchorPoint==TOPRIGHT or anchorPoint==TOPLEFT then offsetY=offsetY-h/2
	end
	ZBNS.vars[name]={[1]=anchorPoint,[2]=CENTER,[3]=(anchor and anchorX or offsetX),[4]=offsetY}

end

function ZBNS.checkLUI()
	if LUIE then
		if LUIE.SV.UnitFrames_Enabled and LUIE.UnitFrames.SV.CustomFramesBosses then return true
			else return false
		end
		else return false
	end
end

function ZBNS.checkAUI()
	if AUI and AUI.UnitFrames.Boss.IsEnabled() then
		return true
		else
		return false
	end
end

local function getSavedBosses(data)
	local newObj = {}
	for _, subTable in ipairs(data) do
		for key, value in pairs(subTable) do
			newObj[key] = value
		end
	end
	return newObj
end

local function tableMerge(t1, t2)
    for key, value in pairs(t2) do
		t1[key] = value
    end
    return t1
end

local function printToChat(text)
	local prefix = "[BNS]"

	d(prefix .. ": " .. text)
end

local function getFirstEmptyKey(obj)
    local emptyKey = 1
    while obj[emptyKey] do
        emptyKey = emptyKey + 1
    end
    return emptyKey
end

function ZBNS.getBossModes()
	bossModes = {}
	bossModes = tableMerge(bossModes, ZBNS.bossModes)
	bossModes = tableMerge(bossModes, getSavedBosses(ZBNS.vars.bossData))
end

function ZBNS.displayBossName()
	if ZBNS.bossName then
		printToChat(ZBNS.bossName)
	else
		printToChat('You must be next to boss')
	end
end

function ZBNS.addNewBoss()
	if ZBNS.bossName then
		if ZBNS.vars.bossData and not getSavedBosses(ZBNS.vars.bossData)[ZBNS.bossName] then
			local i
			if ZBNS.vars.numberOfCustomBosses > #ZBNS.vars.bossData then
				i = getFirstEmptyKey(ZBNS.vars.bossData)
				ZBNS.vars.bossData[i] = {[ZBNS.bossName] = { 75, 50, 25, 0 }}
				printToChat(ZBNS.bossName .. ' successfully added')
			elseif ZBNS.vars.numberOfCustomBosses < 100 then
				ZBNS.vars.numberOfCustomBosses = ZBNS.vars.numberOfCustomBosses + 1
				i = ZBNS.vars.numberOfCustomBosses
				ZBNS.vars.bossData[i] = {[ZBNS.bossName] = { 75, 50, 25, 0 }}
				printToChat(ZBNS.bossName .. ' successfully added')
			else
				printToChat(ZBNS.bossName .. ' You have reached the limit of added bosses (100)')
			end
			if i then
				ZBNS.AddBossControl(i, ZBNS.vars, true);
				ZBNS.BossesChanged();
			end
		else
			printToChat(ZBNS.bossName .. ' already in your list')
		end
	else
		printToChat('You must be next to boss')
	end
end

function ZBNS.OnAddOnLoaded( eventCode, addonName )

	if (addonName ~= ZBNS.name) then return end

	EVENT_MANAGER:UnregisterForEvent(ZBNS.name, EVENT_ADD_ON_LOADED);

	ZBNS.vars = ZO_SavedVars:NewAccountWide("ZBNSSavedVariables", 1, nil, ZBNS.defaults, nil, "$InstallationWide");


	ZBNSFrame:ClearAnchors();
	ZBNSFrame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, ZBNS.vars.left, ZBNS.vars.top);

	ZBNS.fragment = ZO_HUDFadeSceneFragment:New(ZBNSFrame);

	ZBNS.BuildMenu(ZBNS.vars, ZBNS.defaults);


	for i = 1, ZBNS.maxRows do
	local row = ZBNSFrame:GetNamedChild("Row" .. i)
    
		if row then
			ZBNS.rows[i] = row;
			ZBNS.rows[i].value = row:GetNamedChild("Value");
			ZBNS.rows[i].label = row:GetNamedChild("Label");
			ZBNS.rows[i].stg = row:GetNamedChild("Stg");
		end
	end

	ZBNS.Frames();
	ZBNS.BossesChanged();
	
	SLASH_COMMANDS["/zbns"] = function() ZBNS.displayBossName() end
	SLASH_COMMANDS["/zbnsadd"] = function() ZBNS.addNewBoss() end

	EVENT_MANAGER:RegisterForEvent(ZBNS.name, EVENT_BOSSES_CHANGED, ZBNS.BossesChanged);
	EVENT_MANAGER:RegisterForEvent(ZBNS.name, EVENT_PLAYER_ACTIVATED, ZBNS.BossesChanged);

end


function ZBNS.ConvertHexToRGBA(hexCode, a)
	local alpha = 1

	if a then
		alpha = a
	end

	assert(#hexCode == 7, "The hex value must be passed in the form of #XXXXXX");
	local hexCode = hexCode:gsub("#","")

	local r = tonumber("0x" .. hexCode:sub(1,2)) / 255
	local g = tonumber("0x" .. hexCode:sub(3,4)) / 255
	local b = tonumber("0x" .. hexCode:sub(5,6)) / 255
	local a = alpha

	return ZO_ColorDef:New(r, g, b, a)
end

function ZBNS.Frames()	--UI init
	local fs,w,h,bosses,tex,fnt,r,g,b,a,r1,g1,b1,a1,gloss
	local alph=100
	local colort= { }
	local centrh= { }

	if ZBNS.checkLUI() then
		w,h=LUIE.UnitFrames.SV.BossBarWidth,LUIE.UnitFrames.SV.BossBarHeight
		fs=math.min(LUIE.UnitFrames.SV.DefaultFontSize,h*.8)
		bosses = LUIE.UnitFrames.CustomFrames["boss1"].control
		fnt=ZBNS.FrameFont1

	elseif FTC then
		w,h=ZBNS.vars.BossWidth,ZBNS.vars.BossHeight
		fs=math.min(ZBNS.vars.FontSize,h*.8)
		ZBNS.vars.BossWidth=w
		tex=FTC.UI.Textures.grainy
		r = FTC.Vars.FrameHealthColor[1]
		g = FTC.Vars.FrameHealthColor[2]
		b = FTC.Vars.FrameHealthColor[3]
		a=1

		r1 = r
		g1 = g
		b1 = b
		a1=a

		centrh = {FTC.Vars.FrameHealthColor[1]/5,FTC.Vars.FrameHealthColor[2]/5,FTC.Vars.FrameHealthColor[3]/5,1}
		alph = FTC.Vars.FrameTargetOpacityOut
		fnt=ZBNS.FrameFont1

	elseif AUI then
		--bosses = _G['AUI_Attributes_Window_Boss']
		w,h=ZBNS.vars.BossWidth,ZBNS.vars.BossHeight
		fs=math.min(ZBNS.vars.FontSize,h*.8)
		ZBNS.vars.BossWidth=w
		fnt='AUI/fonts/SansitaOne.ttf'

		gloss="AUI/images/attributes/aui/player/bar_gloss.dds"
		r, g, b, a = ZBNS.ConvertHexToRGBA("#390200"):UnpackRGBA()

		r1,g1,b1,a1 = ZBNS.ConvertHexToRGBA("#7c0000"):UnpackRGBA()

	else
		w,h=ZBNS.vars.BossWidth,ZBNS.vars.BossHeight
		fs=math.min(ZBNS.vars.FontSize,h*.8)
		ZBNS.vars.BossWidth=w
		fnt=ZBNS.FrameFont1
		r, g, b, a = ZBNS.ConvertHexToRGBA("#390200"):UnpackRGBA()

		r1,g1,b1,a1 = ZBNS.ConvertHexToRGBA("#7c0000"):UnpackRGBA()


	end

	if (not ZBNS.checkLUI()) then

		--Create the bosses frame container
		bosses	=ControlA(	"BossF",				ZBNSFrame,	{ZBNS.vars.BossWidth,ZBNS.vars.BossHeight},	{0,0,0,0},		false)
		bosses.backdrop	=BackdropA(	"BossF_BG",			bosses,	"inherit",		{CENTER,CENTER,0,0},		{0,0,0,0.4}, {0,0,0,1}, nil, true)
		bosses.label	=LabelA(	"BossF_Label",			bosses.backdrop,	"inherit",		{CENTER,CENTER,0,0},		FontA("standard",20,true), nil, {1,1}, "Bosses Frame", false)
		bosses:SetDrawTier(DT_HIGH)
		local anchor	={TOPLEFT,TOPLEFT,0,0,bosses}
		for i=1, 6 do
			local unitTag="boss"..i
			local boss	=BackdropA("BossF"..i.."_Health",		bosses,	{w,h},		anchor,	centrh,			{0,0,0,1}, tex, true) boss:SetDrawTier(0)
			boss.bar	=StatusbarA("BossF"..i.."_Bar",		boss,		{w-4,h-4},		{LEFT,LEFT,2,0},			{0,0,0,1}, tex, false)
			boss.bar:SetGradientColors(r,g,b,a,r1,g1,b1,a1)
			if ZBNS.checkAUI() then
			boss.gloss	=StatusbarA("BossF"..i.."_Gloss",		boss,		{w-4,h-4},		{LEFT,LEFT,2,0},			nil, gloss, false)
			boss.gloss:SetAlpha(0.1)
			end
			boss:SetAlpha(alph/100)
			boss.name	=LabelA(	"BossF"..i.."_Name",		boss,		{w,h},		{LEFT,LEFT,8,0},			FontA(fnt,fs,true), nil, {0,1}, 'Name', false)
			boss.pct	=LabelA(	"BossF"..i.."_Pct",		boss,		{w,h},		{RIGHT,RIGHT,-8,0},		FontA(fnt,fs,true), nil, {2,1}, 'Pct%', false)
			anchor={TOP,BOTTOM,0,4,boss}
			ZBNS.Frame[unitTag]=boss
		end
	end


	local line	=ControlA(	"BossFrame_Line",				bosses,	{w,h},		{TOP,TOP,0,0},			true)
	for i=1, 4 do
		line["l"..i]=LineA(	"BossFrame"..i.."_Line",		line,		{0,h},		{TOPLEFT,TOPLEFT,0,-2},		{.8,.8,.8,.6},1.8, false) line:SetDrawTier(2)
		line["p"..i]=LabelA(	"BossFrame"..i.."_N",		line["l"..i],{(fs-4)*2.5,fs-4},{BOTTOM,TOP,0,-2},		"$(BOLD_FONT)|$(KB_12)|thick-outline", nil, {1,1}, '', false)

	end


	function ZBNS.redraw()
		local n_bosses=0

		for i = 1, 6 do
			local unitTag="boss"..i
			if DoesUnitExist(unitTag) then
				if unitTag=="boss1" then n_bosses=1 elseif unitTag=="boss2" then n_bosses=2 elseif unitTag=="boss3" then n_bosses=3 elseif unitTag=="boss4" then n_bosses=4 elseif unitTag=="boss5" then n_bosses=5 elseif unitTag=="boss6" then n_bosses=6 elseif unitTag=="boss3" then n_bosses=3 end
			end
			if not ZBNS.checkLUI() and not ZBNS.checkAUI() then
				local unitTag="boss"..n_bosses
				ZBNS.Frame[unitTag]:SetHidden(false);
			end
		end
		if ZBNS.checkAUI() and n_bosses==1 then
			local banchor=_G['AUI_Attributes_Window_Boss']

			bosses	=ControlA(	"BossF",				ZBNSFrame,	{w,h},	{0,0,0,0,banchor},		false)
			h=ZBNS.vars.BossHeight
			w=ZBNS.vars.BossWidth
			ZBNS.Frame['boss1']:SetHidden(false);
			elseif ZBNS.checkAUI() and n_bosses>1 then
			bosses = _G['AUI_Attributes_Window_Boss']
			h=40
			w=280
		end
		local curHealth, maxHealth=GetUnitPower(unitTag, POWERTYPE_HEALTH)
		local _name=(DoesUnitExist("boss1") and GetUnitName("boss1") or false);
		local _pct=curHealth/maxHealth

		local phase=bossModes[_name] or bossModes["Any"]
		for c,pct in pairs(phase) do
			control=_G["BossFrame"..c.."_Line"]
			control:ClearAnchors()
			control:SetAnchor(TOPLEFT,bosses,TOPLEFT,w*(pct/100)+((pct==100) and -1 or 1),-2)
			control:SetAnchor(BOTTOMRIGHT,bosses,TOPLEFT,w*(pct/100)+((pct==100) and -1 or 1),(h+4)*n_bosses-2)
			control:SetHidden(false)
			_G["BossFrame"..c.."_N"]:SetText(pct)
		end
	end

end



function ZBNS.BossesChanged( eventCode )
	ZBNS.getBossModes();

	-- Reset all rows
	for i = 1, ZBNS.maxRows do
		if ZBNS.rows[i] then
			ZBNS.rows[i]:SetHidden(true);
			ZBNS.rows[i].value:SetColor(1, 1, 1, 1);
			if not ZBNS.checkLUI()then
				local unitTag="boss"..i
				ZBNS.Frame[unitTag]:SetHidden(true);
			end
		end
	end

	if (DoesUnitExist('boss1')) then

		ZBNS.StartPolling();


		ZBNS.bosses = MAX_BOSSES;


		for i = 1, ZBNS.bosses do

			ZBNS.rows[i]:SetHidden(false);
			ZBNS.rows[i].value:SetHidden(not ZBNS.vars.showHP)
			ZBNS.rows[i].label:SetHidden(not ZBNS.vars.showName)
			ZBNS.rows[i].stg:SetHidden(not ZBNS.vars.showStage)
			
			if(i == 1) then
				ZBNS.bossName = (DoesUnitExist("boss".. i) and GetUnitName("boss".. i) or false);
			end
		end

		if(ZBNS.vars.showHP or ZBNS.vars.showName or ZBNS.vars.showStage)then
			ZBNS.UpdateBossHealth();
			ZBNS.StartMonitoringCombatState();
		end


		SCENE_MANAGER:GetScene("hud"):AddFragment(ZBNS.fragment);
		SCENE_MANAGER:GetScene("hudui"):AddFragment(ZBNS.fragment);


	end
	if ZBNS.vars.mode=="Custom" then
		if (DoesUnitExist('boss1')) then
			ZBNS.redraw()
			_G["BossFrame_Line"]:SetHidden(false)
			else

			_G["BossFrame_Line"]:SetHidden(true)
		end

	end
end

function ZBNS.OnMoveStop( )
	ZBNS.vars.left = ZBNSFrame:GetLeft();
	ZBNS.vars.top = ZBNSFrame:GetTop();
end


function ZBNS.UpdateBossHealth( )

	for i = 1, ZBNS.bosses do
		local current, _, effectiveMax = GetUnitPower("boss" .. i, POWERTYPE_HEALTH);
		local pheal = current/effectiveMax;
		local _name=(DoesUnitExist("boss".. i) and GetUnitName("boss".. i) or false);
		local unitTag="boss"..i;
		local health = 0;
		local bprint = 10;
		local phase=bossModes[_name] or bossModes["Any"];


		if (effectiveMax > 0) then	-- Avoid division by zero
			health = 100 * current / effectiveMax;
			if (health>phase[1]) then bprint= phase[1];
				elseif (health<=phase[1] and health> phase[2]) then bprint= phase[2];
				elseif (health<=phase[1] and health<= phase[2] and health> phase[3]) then bprint= phase[3];
				else bprint= phase[4];
			end

			if (health == 0) then
				ZBNS.rows[i].value:SetColor(0, 0.75, 0.75, 1);
				elseif (health-bprint >= 3 and health-bprint < 6) then
				ZBNS.rows[i].value:SetColor(1, 1, 0, 1);
				elseif (health-bprint >= 0 and health-bprint < 3) then
				ZBNS.rows[i].value:SetColor(0.75, 0, 0, 1);
				else
				ZBNS.rows[i].value:SetColor(1, 1, 1, 1);
			end

		end



		if(effectiveMax==0) then
			ZBNS.rows[i]:SetHidden(true);
			else
			ZBNS.rows[i].value:SetText(string.format("%d%%", health));
			ZBNS.rows[i].label:SetText(_name);
			ZBNS.rows[i].stg:SetText(bprint.."%");

			if not ZBNS.checkLUI()then
				ZBNS.Frame[unitTag].name:SetText(_name)
				ZBNS.Frame[unitTag].bar:SetWidth((ZBNS.vars.BossWidth-4)*pheal)
				--ZBNS.Frame[unitTag].barGloss:SetBarAlignment(BAR_ALIGNMENT_REVERSE)
				ZBNS.Frame[unitTag].pct:SetText(math.floor(pheal*100) .."%|r")
			end

		end
		if(bprint==0) then
			ZBNS.rows[i].stg:SetAlpha(0);
			else
			ZBNS.rows[i].stg:SetAlpha(1);
		end

	end
end

function ZBNS.OnPlayerCombatState( eventCode, inCombat )
	if (inCombat) then
		if (not ZBNS.pollingActive) then
			ZBNS.StartPolling();
		end
		else
		-- Avoid false positives of combat end, often caused by combat rezes
		zo_callLater(function() if (not IsUnitInCombat("player")) then ZBNS.CombatEnded() end end, 3000);
	end
end

function ZBNS.CombatEnded( )
	ZBNS.StopPolling();
	ZBNS.BossesChanged();
end

function ZBNS.StartMonitoringCombatState( )
	if (not ZBNS.combatMonitoring) then
		ZBNS.combatMonitoring = true;
		EVENT_MANAGER:RegisterForEvent(ZBNS.name, EVENT_PLAYER_COMBAT_STATE, ZBNS.OnPlayerCombatState);

		if (IsUnitInCombat("player")) then
			ZBNS.OnPlayerCombatState(nil, true);
		end
	end
end

function ZBNS.StopMonitoringCombatState( )
	if (ZBNS.combatMonitoring) then
		ZBNS.combatMonitoring = false;
		EVENT_MANAGER:UnregisterForEvent(ZBNS.name, EVENT_PLAYER_COMBAT_STATE);
	end
end


function ZBNS.StartPolling( )
	if (not ZBNS.pollingActive) then
		ZBNS.pollingActive = true;
		if not ZBNS.checkLUI() and ZBNS.vars.mode=="Custom" then
			EVENT_MANAGER:RegisterForUpdate(ZBNS.name, 200, ZBNS.UpdateBossHealth);
		end
		ZBNS.StartMonitoringCombatState();
	end
end

function ZBNS.StopPolling( )
	if (ZBNS.pollingActive) then
		ZBNS.pollingActive = false;
		EVENT_MANAGER:UnregisterForUpdate(ZBNS.name);
	end
end



EVENT_MANAGER:RegisterForEvent(ZBNS.name, EVENT_ADD_ON_LOADED, ZBNS.OnAddOnLoaded);
