-- Original BUI local vars + coord data
local ch,cm,cs,cw,ch1,cm1,cs1,cw1,rh,rh1
local disable_hit_anim
local fixedHB = false
local coords={
	--Simple
	[1]={	{.25,.375,0,1},{.375,.5,0,.5},{.375,.5,.5,1},	--Health 1 bg,2 top,3 bot
		{0,.125,0,.5},{.125,.25,0,.5},			--Primary 4 bg,5 bar
		{0,.125,.5,.853},{.125,.25,.5,.853},		--Secondary 6 bg,7 bar

		{.75,.875,0,1},{.875,1,0,.5},{.875,1,.5,1},	--Target 8 bg,9 top,10 bot
		{.5,.625,0,.5},{.625,.75,0,.5},			--Primary 11 bg,12 bar
		{.5,.625,.25,.853},{.625,.75,.5,.853},		--Secondary 13 bg,14 bar
		.03,.3							--Shift for 15 hot,16 pct
		},
	--Cone
	[2]={	{.25,.375,0,1},{.375,.5,0,.5},{.375,.5,.5,1},
		{0,.125,0,.667},{.125,.25,0,.667},
		{0,.125,.667,1},{.125,.25,.667,1},

		{.75,.875,0,1},{.875,1,0,.5},{.875,1,.5,1},
		{.5,.625,0,.667},{.625,.75,0,.667},
		{.5,.625,.667,1},{.625,.75,.667,1},
		.08,.33
		},
	--Blades
	[3]={	{.25,.375,0,1},{.375,.5,0,1},false,
		{0,.125,0,.667},{.125,.25,0,.667},
		{0,.125,.667,1},{.125,.25,.667,1},

		{.75,.875,0,1},{.875,1,0,1},false,
		{.5,.625,0,.667},{.625,.75,0,.667},
		{.5,.625,.667,1},{.625,.75,.667,1},
		.26,.58
		},
}
local theme_color
local CurvedFrameFadeDelay
local DecayStep,Attributes=1/50,{player={health={cur=1,target=1},magicka={cur=1,target=1},stamina={cur=1,target=1}},reticleover={health={cur=1,target=1}}}

-- Original BUI UI_Init function w/ forced alignment override
local function UI_Init_Aligned()
	local c=type(BUI.Vars.CurvedFrame)~="number" and 1 or BUI.Vars.CurvedFrame
	local fs=BUI.Vars.FrameFontSize
	local distance=BUI.inMenu and 100 or BUI.Vars.CurvedDistance
	local w,h,w1=distance*2,BUI.Vars.CurvedHeight,64*BUI.Vars.CurvedDepth
	local wh,ws=22*BUI.Vars.CurvedDepth,22*BUI.Vars.CurvedDepth
	local space=5
	local texture="/BanditsUserInterface/textures/curved/Curved"..c..".dds"
	local half=coords[c][3] and .5 or 1
	local ui	=BUI.UI.Control("BUI_Curved",	BanditsUI,	{w,h},	{CENTER,CENTER,0,BUI.Vars.CurvedOffset}, false)
	--Shift animation
	ui.shift	=BUI.UI.Texture("BUI_Curved_Shift", ui, {w1*2,h}, {LEFT,LEFT,0,0}, "/BanditsUserInterface/textures/curved/Shift.dds", true, {0,0})
	if BUI.MainPower=="magicka" then
		ui.shift:SetGradientColors(2,cs[1],cs[2],cs[3],cs[4],cm[1],cm[2],cm[3],cm[4])
	else
		ui.shift:SetGradientColors(2,cm[1],cm[2],cm[3],cm[4],cs[1],cs[2],cs[3],cs[4])
	end
	ui.shift:SetAlpha(.8)
	--Player
	ui.health	=BUI.UI.Texture("BUI_Curved_HealthBg", ui, {w1,h}, {LEFT,LEFT,0,0}, texture, false, {0,0}, coords[c][1])
	ui.health:SetColor(unpack(theme_color))
	ui.health.hot=BUI.UI.Texture("BUI_Curved_HealthHoT", ui.health, {wh,wh/2}, {LEFT,LEFT,w1*coords[c][15]-wh*.2,wh}, '/BanditsUserInterface/textures/regen_sm.dds', true, {1,2})
	ui.health.hot:SetTextureRotation(math.pi*.5)
	ui.health.dot=BUI.UI.Texture("BUI_Curved_HealthDoT", ui.health, {wh,wh/2}, {LEFT,LEFT,w1*coords[c][15]-wh*.2,-wh}, '/BanditsUserInterface/textures/regen_sm.dds', true, {1,2})
	ui.health.dot:SetTextureRotation(math.pi*1.5)
	if BUI.Vars.CurvedStatValues then
			BUI.UI.Line("BUI_Curved_HealthLine", ui, {fs*3,0}, {LEFT,LEFT,w1*coords[c][16],0}, theme_color, 2)
	ui.health.cur=BUI.UI.Label("BUI_Curved_HealthCur", ui, {fs*6,fs*1.5}, {BOTTOMLEFT,LEFT,w1*coords[c][16],0}, BUI.UI.Font(BUI.Vars.FrameFont1,fs,true), nil, {0,0}, BUI.DisplayNumber(BUI.Player.health.current/1000, 1).."k", false)
	ui.health.pct=BUI.UI.Label("BUI_Curved_HealthPct", ui, {fs*3,fs*1.5}, {TOPLEFT,LEFT,w1*coords[c][16],0}, BUI.UI.Font(BUI.Vars.FrameFont1,fs,true), nil, {0,2}, math.floor(BUI.Player.health.pct*100).."%", false)
	else
		if BUI_Curved_HealthLine then BUI_Curved_HealthLine:SetHidden(true) end
		if BUI_Curved_HealthCur then BUI_Curved_HealthCur:SetHidden(true) end
		if BUI_Curved_HealthPct then BUI_Curved_HealthPct:SetHidden(true) end
	end
	
	-- // BAHUI // force use the blades configuration for the bar alignment
	c = 3
	
	local coord=coords[c][2]
	local delta=math.abs(coord[3]-coord[4])
	ui.health.top={
		[1]	=BUI.UI.Texture("BUI_Curved_HealthTop1", ui, {w1,h*delta}, {BOTTOMLEFT,(delta==1 and BOTTOMLEFT or LEFT),0,0}, texture, false, {1,0}, coord),
		[2]	=BUI.UI.Texture("BUI_Curved_HealthTop2", ui, {w1,h*delta}, {BOTTOMLEFT,(delta==1 and BOTTOMLEFT or LEFT),0,0}, texture, false, {0,1}, coord),
		[3]	=BUI.UI.Texture("BUI_Curved_HealthTop3", ui, {w1,h*delta}, {BOTTOMLEFT,(delta==1 and BOTTOMLEFT or LEFT),0,0}, texture, true, {1,1}, coord),
		coord=coord
		}
	ui.health.top[1]:SetGradientColors(2,ch[1],ch[2],ch[3],ch[4],ch1[1],ch1[2],ch1[3],ch1[4])
	ui.health.top[2]:SetColor(ch[1],ch[2],ch[3],.4)
	ui.health.top[3]:SetGradientColors(2,cw[1],cw[2],cw[3],cw[4],cw1[1],cw1[2],cw1[3],cw1[4])
	ui.health.top[3]:SetAlpha(.4)
	local coord=coords[c][3]
	if coord then
		local delta=math.abs(coord[3]-coord[4])
		ui.health.bot={
		[1]	=BUI.UI.Texture("BUI_Curved_HealthBot1", ui, {w1,h*delta}, {TOPLEFT,(delta==1 and TOPLEFT or LEFT),0,0}, texture, false, {1,0}, coord),
		[2]	=BUI.UI.Texture("BUI_Curved_HealthBot2", ui, {w1,h*delta}, {TOPLEFT,(delta==1 and TOPLEFT or LEFT),0,0}, texture, false, {0,1}, coord),
		[3]	=BUI.UI.Texture("BUI_Curved_HealthBot3", ui, {w1,h*delta}, {TOPLEFT,(delta==1 and TOPLEFT or LEFT),0,0}, texture, true, {1,1}, coord),
		coord=coord
		}
		ui.health.bot[1]:SetGradientColors(2,ch1[1],ch1[2],ch1[3],ch1[4],ch[1],ch[2],ch[3],ch[4])
		ui.health.bot[2]:SetColor(ch[1],ch[2],ch[3],.4)
		ui.health.bot[3]:SetGradientColors(2,cw1[1],cw1[2],cw1[3],cw1[4],cw[1],cw[2],cw[3],cw[4])
		ui.health.bot[3]:SetAlpha(.4)
	else
		ui.health.bot=nil
		if BUI_Curved_HealthBot1 then BUI_Curved_HealthBot1:SetHidden(true) end
		if BUI_Curved_HealthBot2 then BUI_Curved_HealthBot2:SetHidden(true) end
		if BUI_Curved_HealthBot3 then BUI_Curved_HealthBot3:SetHidden(true) end
	end
	Attributes.player.health.frame=ui.health
	
	-- // BAHUI // reset to user chosen config
	c = type(BUI.Vars.CurvedFrame)~="number" and 1 or BUI.Vars.CurvedFrame

	--Target
	local target	=BUI.UI.Control("BUI_CurvedTarget",	BanditsUI,	{w,h},	{CENTER,CENTER,0,BUI.Vars.CurvedOffset}, true)
	ui.target		=BUI.UI.Texture("BUI_Curved_TargetBg", target, {w1,h}, {RIGHT,RIGHT,0,0}, texture, false, {0,0}, coords[c][8])
	ui.target:SetColor(unpack(theme_color))
	ui.target.hot=BUI.UI.Texture("BUI_Curved_TargetHoT", ui.target, {wh,wh/2}, {RIGHT,RIGHT,-w1*coords[c][15]+wh*.2,wh}, '/BanditsUserInterface/textures/regen_sm.dds', true, {1,2})
	ui.target.hot:SetTextureRotation(math.pi*.5)
	ui.target.dot=BUI.UI.Texture("BUI_Curved_TargetDoT", ui.target, {wh,wh/2}, {RIGHT,RIGHT,-w1*coords[c][15]+wh*.2,-wh}, '/BanditsUserInterface/textures/regen_sm.dds', true, {1,2})
	ui.target.dot:SetTextureRotation(math.pi*1.5)
	ui.target.dif	=BUI.UI.Texture("BUI_Curved_Dif", target, {fs*1.5,fs*1.5}, {TOPRIGHT,TOPRIGHT,0,0}, GetClassIcon(1), not BUI.inMenu)
	ui.target.rank	=BUI.UI.Texture("BUI_Curved_Rank", target, {fs*1.5,fs*1.5}, {TOPRIGHT,TOPRIGHT,0,fs*1.5}, GetAvARankIcon(1), not BUI.inMenu)
	ui.target.execute	=BUI.UI.Texture("BUI_Curved_Execute", target, {fs*1.5,fs*1.5}, {RIGHT,RIGHT,-w1*coords[c][16]-(BUI.Vars.CurvedStatValues and fs*3 or 0),0}, '/esoui/art/icons/mapkey/mapkey_groupboss.dds', true)
	if BUI.Vars.CurvedStatValues then
			BUI.UI.Line("BUI_Curved_TargetLine", target, {-fs*3,0}, {LEFT,RIGHT,-w1*coords[c][16],0}, theme_color, 2)
	ui.target.cur=BUI.UI.Label("BUI_Curved_TargetCur", target, {fs*6,fs*1.5}, {BOTTOMRIGHT,RIGHT,-w1*coords[c][16],0}, BUI.UI.Font(BUI.Vars.FrameFont1,fs,true), nil, {2,0}, 'Health', false)
	ui.target.pct=BUI.UI.Label("BUI_Curved_TargetPct", target, {fs*3,fs*1.5}, {TOPRIGHT,RIGHT,-w1*coords[c][16],0}, BUI.UI.Font(BUI.Vars.FrameFont1,fs,true), nil, {2,2}, 'pct', false)
	else
		if BUI_Curved_TargetLine then BUI_Curved_TargetLine:SetHidden(true) end
		if BUI_Curved_TargetCur then BUI_Curved_TargetCur:SetHidden(true) end
		if BUI_Curved_TargetPct then BUI_Curved_TargetPct:SetHidden(true) end
	end
	
	-- // BAHUI // force use blades configuration for bar alignment
	c = 3
	
	local coord=coords[c][9]
	local delta=math.abs(coord[3]-coord[4])
	ui.target.bot={
		[1]	=BUI.UI.Texture("BUI_Curved_TargetBot1", target, {w1,h*delta}, {BOTTOMRIGHT,(delta==1 and BOTTOMRIGHT or RIGHT),0,0}, texture, false, {1,0}, coord),
		[2]	=BUI.UI.Texture("BUI_Curved_TargetBot2", target, {w1,h*delta}, {BOTTOMRIGHT,(delta==1 and BOTTOMRIGHT or RIGHT),0,0}, texture, false, {0,1}, coord),
		[3]	=BUI.UI.Texture("BUI_Curved_TargetBot3", target, {w1,h*delta}, {BOTTOMRIGHT,(delta==1 and BOTTOMRIGHT or RIGHT),0,0}, texture, true, {1,1}, coord),
		coord=coord
		}
	ui.target.bot[1]:SetGradientColors(2,ch[1],ch[2],ch[3],ch[4],ch1[1],ch1[2],ch1[3],ch1[4])
	ui.target.bot[2]:SetColor(ch[1],ch[2],ch[3],.4)
	ui.target.bot[3]:SetGradientColors(2,cw[1],cw[2],cw[3],cw[4],cw1[1],cw1[2],cw1[3],cw1[4])
	ui.target.bot[3]:SetAlpha(.4)
	local coord=coords[c][10]
	if coord then
		local delta=math.abs(coord[3]-coord[4])
		ui.target.top={
		[1]	=BUI.UI.Texture("BUI_Curved_TargetTop1", target, {w1,h*delta}, {TOPRIGHT,(delta==1 and TOPRIGHT or RIGHT),0,0}, texture, false, {1,0}, coord),
		[2]	=BUI.UI.Texture("BUI_Curved_TargetTop2", target, {w1,h*delta}, {TOPRIGHT,(delta==1 and TOPRIGHT or RIGHT),0,0}, texture, false, {0,1}, coord),
		[3]	=BUI.UI.Texture("BUI_Curved_TargetTop3", target, {w1,h*delta}, {TOPRIGHT,(delta==1 and TOPRIGHT or RIGHT),0,0}, texture, true, {1,1}, coord),
		coord=coord
		}
		ui.target.top[1]:SetGradientColors(2,ch1[1],ch1[2],ch1[3],ch1[4],ch[1],ch[2],ch[3],ch[4])
		ui.target.top[2]:SetColor(ch[1],ch[2],ch[3],.4)
		ui.target.top[3]:SetGradientColors(2,cw1[1],cw1[2],cw1[3],cw1[4],cw[1],cw[2],cw[3],cw[4])
		ui.target.top[3]:SetAlpha(.4)
	else
		ui.target.top=nil
		if BUI_Curved_TargetTop1 then BUI_Curved_TargetTop1:SetHidden(true) end
		if BUI_Curved_TargetTop2 then BUI_Curved_TargetTop2:SetHidden(true) end
		if BUI_Curved_TargetTop3 then BUI_Curved_TargetTop3:SetHidden(true) end
	end
	Attributes.reticleover.health.frame=ui.target
	
	-- // BAHUI // reset to user chosen config
	c = type(BUI.Vars.CurvedFrame)~="number" and 1 or BUI.Vars.CurvedFrame

	--Attributes
	ui.attr={
		l	=BUI.UI.Control("BUI_Curved_PrimL",		ui,	{w,h},	{CENTER,CENTER,0,0}, true),
		r	=BUI.UI.Control("BUI_Curved_PrimR",		ui,	{w,h},	{CENTER,CENTER,0,0}, true),
		primar=true
		}
	--Primary bar
		--Left
	ui.attr.l.primar={}
	local coord=coords[c][4] local delta=math.abs(coord[3]-coord[4])
	ui.attr.l.primar.bg=BUI.UI.Texture("BUI_Curved_PrimLBg",	ui.attr.l, {w1,h*delta}, {BOTTOMLEFT,BOTTOMLEFT,-ws,-h*(1-delta)}, texture, false, 0, coord)
	ui.attr.l.primar.bg:SetColor(unpack(theme_color))
	local coord=coords[c][5] local delta=math.abs(coord[3]-coord[4])
	ui.attr.l.primar.top={
		[1]	=BUI.UI.Texture("BUI_Curved_PrimLTop1",	ui.attr.l, {w1,h*delta}, {BOTTOMLEFT,BOTTOMLEFT,-ws,-h*(1-delta)}, texture, false, 2, coord),
		[2]	=BUI.UI.Texture("BUI_Curved_PrimLTop2",	ui.attr.l, {w1,h*delta}, {BOTTOMLEFT,BOTTOMLEFT,-ws,-h*(1-delta)}, texture, false, 1, coord),
		coord=coord
		}
		--Right
	ui.attr.r.primar={}
	local coord=coords[c][11] local delta=math.abs(coord[3]-coord[4])
	ui.attr.r.primar.bg=BUI.UI.Texture("BUI_Curved_PrimRBg",	ui.attr.r, {w1,h*delta}, {BOTTOMRIGHT,BOTTOMRIGHT,0,-h*(1-delta)}, texture, false, 0, coord)
	ui.attr.r.primar.bg:SetColor(unpack(theme_color))
	local coord=coords[c][12] local delta=math.abs(coord[3]-coord[4])
	ui.attr.r.primar.top={
		[1]	=BUI.UI.Texture("BUI_Curved_PrimRTop1",	ui.attr.r, {w1,h*delta}, {BOTTOMRIGHT,BOTTOMRIGHT,0,-h*(1-delta)}, texture, false, 2, coord),
		[2]	=BUI.UI.Texture("BUI_Curved_PrimRTop2",	ui.attr.r, {w1,h*delta}, {BOTTOMRIGHT,BOTTOMRIGHT,0,-h*(1-delta)}, texture, false, 1, coord),
		coord=coord
		}

	--Secondary bar
		--Left
	ui.attr.l.second={}
	local coord=coords[c][6] local delta=math.abs(coord[3]-coord[4])
	ui.attr.l.second.bg=BUI.UI.Texture("BUI_Curved_SecondLBg",	ui.attr.l, {w1,h*delta}, {TOPLEFT,TOPLEFT,-ws,h*coord[3]}, texture, false, 0, coord)
	ui.attr.l.second.bg:SetColor(unpack(theme_color))
	local coord=coords[c][7] local delta=math.abs(coord[3]-coord[4])
	ui.attr.l.second.top={
		[1]	=BUI.UI.Texture("BUI_Curved_SecondLTop1",	ui.attr.l, {w1,h*delta}, {TOPLEFT,TOPLEFT,-ws,h*coord[3]}, texture, false, 2, coord),
		[2]	=BUI.UI.Texture("BUI_Curved_SecondLTop2",	ui.attr.l, {w1,h*delta}, {TOPLEFT,TOPLEFT,-ws,h*coord[3]}, texture, false, 1, coord),
		coord=coord
		}
		--Right
	ui.attr.r.second={}
	local coord=coords[c][13] local delta=math.abs(coord[3]-coord[4])
	ui.attr.r.second.bg=BUI.UI.Texture("BUI_Curved_SecondRBg",	ui.attr.r, {w1,h*delta}, {TOPRIGHT,TOPRIGHT,0,h*coord[3]}, texture, false, 0, coord)
	ui.attr.r.second.bg:SetColor(unpack(theme_color))
	local coord=coords[c][14] local delta=math.abs(coord[3]-coord[4])
	ui.attr.r.second.top={
		[1]	=BUI.UI.Texture("BUI_Curved_SecondRTop1",	ui.attr.r, {w1,h*delta}, {TOPRIGHT,TOPRIGHT,0,h*coord[3]}, texture, false, 2, coord),
		[2]	=BUI.UI.Texture("BUI_Curved_SecondRTop2",	ui.attr.r, {w1,h*delta}, {TOPRIGHT,TOPRIGHT,0,h*coord[3]}, texture, false, 1, coord),
		coord=coord
		}

	--Set attribute colors
	for _,side in pairs({"l","r"}) do
		if BUI.MainPower=="magicka" then
			ui.attr[side].primar.top[1]:SetGradientColors(2,cm[1],cm[2],cm[3],cm[4],cm1[1],cm1[2],cm1[3],cm1[4])
			ui.attr[side].second.top[1]:SetGradientColors(2,cs1[1],cs1[2],cs1[3],cs1[4],cs[1],cs[2],cs[3],cs[4])
			ui.attr[side].primar.top[2]:SetColor(cm[1],cm[2],cm[3],.4)
			ui.attr[side].second.top[2]:SetColor(cs[1],cs[2],cs[3],.4)
			Attributes.player.magicka.frame=ui.attr.l.primar
			Attributes.player.stamina.frame=ui.attr.l.second
		else
			ui.attr[side].primar.top[1]:SetGradientColors(2,cs[1],cs[2],cs[3],cs[4],cs1[1],cs1[2],cs1[3],cs1[4])
			ui.attr[side].second.top[1]:SetGradientColors(2,cm1[1],cm1[2],cm1[3],cm1[4],cm[1],cm[2],cm[3],cm[4])
			ui.attr[side].primar.top[2]:SetColor(cs[1],cs[2],cs[3],.4)
			ui.attr[side].second.top[2]:SetColor(cm[1],cm[2],cm[3],.4)
			Attributes.player.stamina.frame=ui.attr.l.primar
			Attributes.player.magicka.frame=ui.attr.l.second
		end
	end

	--Stat values lables
	if BUI.Vars.CurvedStatValues then
		local primar_value=BUI.DisplayNumber(BUI.Player[BUI.MainPower].current/1000, 1).."k"
		local second_value=BUI.DisplayNumber(BUI.Player[BUI.SecondaryPower].current/1000, 1).."k"
			BUI.UI.Line("BUI_Curved_StatLineL", ui.attr.l.primar.bg, {-fs*3,0}, {RIGHT,BOTTOMLEFT,0,0}, theme_color, 2)
	ui.attr.l.primar.cur=BUI.UI.Label("BUI_Curved_PrimarLCur", ui.attr.l, {fs*4,fs*1.5}, {BOTTOMRIGHT,BOTTOMLEFT,0,0,ui.attr.l.primar.bg}, BUI.UI.Font(BUI.Vars.FrameFont1,fs,true), nil, {2,0}, primar_value)
	ui.attr.l.second.cur=BUI.UI.Label("BUI_Curved_SecondLCur", ui.attr.l, {fs*4,fs*1.5}, {TOPRIGHT,BOTTOMLEFT,0,0,ui.attr.l.primar.bg}, BUI.UI.Font(BUI.Vars.FrameFont1,fs,true), nil, {2,2}, second_value)
			BUI.UI.Line("BUI_Curved_StatLineR", ui.attr.r.primar.bg, {-fs*3,0}, {RIGHT,BOTTOMRIGHT,-w1*coords[c][16],0}, theme_color, 2)
	ui.attr.r.primar.cur=BUI.UI.Label("BUI_Curved_PrimarRCur", ui.attr.r, {fs*4,fs*1.5}, {BOTTOMRIGHT,BOTTORIGHT,-w1*coords[c][16]*(1+coords[c][6][4]-.5),0,ui.attr.r.primar.bg}, BUI.UI.Font(BUI.Vars.FrameFont1,fs,true), nil, {2,0}, primar_value)
	ui.attr.r.second.cur=BUI.UI.Label("BUI_Curved_SecondRCur", ui.attr.r, {fs*4,fs*1.5}, {TOPRIGHT,BOTTOMRIGHT,-w1*coords[c][16]*(1+coords[c][6][4]-.5),0,ui.attr.r.primar.bg}, BUI.UI.Font(BUI.Vars.FrameFont1,fs,true), nil, {2,2}, second_value)
	else
		if BUI_Curved_StatLineL then BUI_Curved_StatLineL:SetHidden(true) end
		if BUI_Curved_PrimarLCur then BUI_Curved_PrimarLCur:SetHidden(true) end
		if BUI_Curved_SecondLCur then BUI_Curved_SecondLCur:SetHidden(true) end
		if BUI_Curved_StatLineR then BUI_Curved_StatLineR:SetHidden(true) end
		if BUI_Curved_PrimarRCur then BUI_Curved_PrimarRCur:SetHidden(true) end
		if BUI_Curved_SecondRCur then BUI_Curved_SecondRCur:SetHidden(true) end
	end

	--Alt bar
	local coord=coords[c][6] local delta=math.abs(.667-coord[4])
	ui.alt	=BUI.UI.Texture("BUI_Curved_Alt", ui, {w1,h*delta}, {TOPLEFT,TOPLEFT,ws,h*.667}, texture, true, 0, {coord[1],coord[2],.667,coord[4]})
	ui.alt:SetColor(unpack(theme_color))
	local delta=coords[c][15]+(coords[c][16]-coords[c][15])/2
	ui.icon	=BUI.UI.Texture("BUI_Curved_AltIcon", ui.alt, {fs*1.5,fs*1.5}, {BOTTOMLEFT,TOPLEFT,w1*delta-fs*.75,0},"/esoui/art/icons/mapkey/mapkey_stables.dds")
	local coord=coords[c][7] local delta=math.abs(.667-coord[4])
	ui.alt.top={
		[1]	=BUI.UI.Texture("BUI_Curved_AltTop1", ui.alt, {w1,h*delta}, {TOPLEFT,TOPLEFT,ws,h*.667,ui}, texture, false, 2, {coord[1],coord[2],.667,coord[4]}),
		coord={coord[1],coord[2],.667,coord[4]}
		}
	ui.alt.top[1]:SetColor(cs[1],cs[2],cs[3],cs[4])

	--Dots control
	if BUI.Vars.Actions or BUI.Vars.ProcAnimation then
	local h=16*BUI.Vars.CurvedDepth
	local bar	=BUI.UI.Control("BUI_CurvedFrame_Dots",		ui,	{h,h*5+4},	{BOTTOMLEFT,LEFT,w1*coords[c][16]+4,-fs*1.5-4},	true)
	for i=1,5 do
		bar[i]=BUI.UI.Texture("BUI_CurvedFrame_Dots"..i,	bar,	{h,h},		{BOTTOM,BOTTOM,(i-1)*(c==2.2 and 1 or 3)*BUI.Vars.CurvedDepth,-(i-1)*h-3},	"")
		bar[i]:SetDrawLayer(3) bar[i]:SetColor(unpack(theme_color))
	end
	end

	ui:SetAlpha(BUI.Vars.FramesFade and 0 or BUI.Vars.FrameOpacityOut/100)
	target:SetAlpha(BUI.Vars.FramesFade and 0 or BUI.Vars.FrameOpacityOut/100)
end

-- Original BUI curve initialize function w/ override
function BUI_Curved_Initialize_Aligned()
	if BUI.Vars.CurvedFrame==0 then
		if BUI_Curved then BUI_Curved:SetHidden(true) BUI_CurvedTarget:SetHidden(true) end
		return
	end
	theme_color=BUI.Vars.Theme==6 and {1,204/255,248/255,1} or BUI.Vars.Theme==7 and BUI.Vars.AdvancedThemeColor or BUI.Vars.CustomEdgeColor
	ch,cm,cs,cw=BUI.Vars.FrameHealthColor,BUI.Vars.FrameMagickaColor,BUI.Vars.FrameStaminaColor,BUI.Vars.FrameShieldColor
	ch1,cm1,cs1,cw1=BUI.Vars.FrameHealthColor1,BUI.Vars.FrameMagickaColor1,BUI.Vars.FrameStaminaColor1,BUI.Vars.FrameShieldColor1
	rh,rh1={1-ch[1],1-ch[2],1-ch[3],1-ch[4]},{1-ch1[1],1-ch1[2],1-ch1[3],1-ch1[4]}
	disable_hit_anim=not BUI.Vars.CurvedHitAnimation
	UI_Init_Aligned()
	BUI.Curved.OnCombatState(false,true)
end





-- // BAHUI Code //
local Name = "BAHUI"
local initialized = false


local function LoadAddon()
	EVENT_MANAGER:UnregisterForEvent(Name .. "Loaded", EVENT_ADD_ON_LOADED)
end

-- Override the reference and initialize at least once
local function Update()
	if BUI then
		-- Replace the reference to the curved frames initialize function
		BUI.Curved.Initialize = BUI_Curved_Initialize_Aligned
		if initialized == true then
			BUI.Curved.Initialize()
			EVENT_MANAGER:UnregisterForUpdate(Name .. "Update")
		end
		if initialized == false then
			initialized = true
		end
	else
		-- If BUI isn't installed or enabled, unregister the update
		d("BUI could not be found")
		EVENT_MANAGER:UnregisterForUpdate(Name .. "Update")
	end
end

EVENT_MANAGER:RegisterForEvent(Name .. "Loaded", EVENT_ADD_ON_LOADED, LoadAddon)
EVENT_MANAGER:RegisterForUpdate(Name .. "Update", 1000, Update)