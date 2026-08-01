MAHelper = {
	name = "MAHelper",
	Versione = "0.1.6",
}

Set = nil
local CurrStageArena = 1
local MY_TEXTURES = {
	"MAHelper/Icons/Signal.dds",
	"MAHelper/Icons/Signal2.dds",
	"MAHelper/Icons/Signal3.dds",
	"MAHelper/Icons/Signal4.dds",
	"MAHelper/Icons/Signal5.dds",
	"MAHelper/Icons/BossRMael.dds",
	"MAHelper/Icons/BossMael.dds",
	"MAHelper/Icons/BossRobot1.dds",
	"MAHelper/Icons/BossRobot2.dds",
	"MAHelper/Icons/BossRobot3.dds",
	"MAHelper/Icons/BossMaelSpider.dds",
	"MAHelper/Icons/BossMaelCroco.dds",
	"MAHelper/Icons/BossMaelCharmander.dds",
	"MAHelper/Icons/BossMaelDraghenshi.dds",
	"MAHelper/Icons/BossMaelFinal.dds",
	"MAHelper/Icons/BossMaelMegaSpider.dds",
	"MAHelper/Icons/BossMaelSerpe.dds",
	"MAHelper/Icons/MaelSkeletonMage.dds",
	"MAHelper/Icons/MaelMoyaiSuper.dds",
}
icons = {}
sIcon = {}
--def settings
defSett = {
	arrowColorArr = {
		{ 0.88, 0.88, 0.04, 1},--w1
		{ 1, 0.33, 0, 1},--BossInt
		{ 1, 0.0, 0.0, 1},--BossStage
	},
	arrowColorFlash = {
		{0.92549019607843,0.094117647058824,0.007843137254902,1},
		{1,0.4,0.18823529411765,1},
		{1,0.8078431372549,0.22352941176471,1},
		{0.4156862745098,0.65882352941176,0.30980392156863,1},
		{0.027450980392157,0.2156862745098,0.38823529411765,1},
		{0.29803921568627,0.070588235294118,0.79607843137255,1},
		{0.23921568627451,0.52156862745098,0.77647058823529,1},
		{0.40392156862745,0.30588235294118,0.65490196078431,1},
		{0.85,0.03921,0.83137255,1},
	},
	p1 = 0,
	p2 = 0,
	changedPos = false,
	tv = false,
	TextVis = true,
	size = 100,
	arrowScale = 0.7,
	vIcon = true,
	sLocV = false,
	ArrowV = true, -- 0 hidden, 1 visible
	arrowTime = 5000,
}
local savedVariable
-----------sezione spawn freccia e segnalino / section for spawn objects -Arrows and OSI icons-
function MAHelper.ListAddPosition( r,  w)
	CurrStageArena = r
	p = Set.rounds[r].Waves[w]
	if not savedVariable.vIcon then
		do return end
	end
	for i = 1, p.nMOB, 1
	do
		--icon
		iconData = p.Mobs[i]
		local icon = OSI.CreatePositionIcon(iconData.posx, iconData.posy, iconData.posz, iconData.texture,savedVariable.size, {1, 1, 1})
		icons[i] = icon
		--arrow
		TX = iconData.X
		TY = iconData.Y
		local playerX, playerY = GetMapPlayerPosition("player")
		if playerX < 0.3 and Set.name == "Igneous Cistern" then
			TX = iconData.X2
			TY = iconData.Y2
			if playerX < 0 then
				TX = iconData.X3
				TY = iconData.Y3
			end
		end
		if savedVariable.ArrowV  then
			local index = LibSimpleArrowModS.SearchFreeArrow()
			LibSimpleArrowModS.ShowArrow(TX, TY, index)
			LibSimpleArrowModS.ApplyStyle(MAHelper.name .. "/texture/arrow21.dds", savedVariable.arrowColorArr[iconData.c], savedVariable.arrowScale, index)
			zo_callLater(function() LibSimpleArrowModS.HideArrow(index) end, savedVariable.arrowTime)
		end
	end
end
function MAHelper.RemoveIcons()
	if #icons > 0 then 
		for i = 1, #icons, 1   do
			OSI.DiscardPositionIcon(icons[i])
		end
	end
	icons = {}
end
function MAHelper.UpdateArrowScale(value)
	v = value / 100
	savedVariable.arrowScale = v
end

function MAHelper.UpdateArrowTime(value)
	v = value *1000
	savedVariable.arrowTime = v
end
function MAHelper.UpdateIconSize(value)
	savedVariable.size = value
end
function  MAHelper.UpdateArrowColor(r,g,b,a,pos)
	local colore = {r,g,b,a}
	savedVariable.arrowColorArr[pos] = colore
end
function MAHelper.ButtonTry()
	MAHelper.RemoveIcons()
	d("Example of arrow and icon!")
	local playerX, playerY = GetMapPlayerPosition("player")
	local zone, wX, wY, wZ = GetUnitRawWorldPosition( "player" )
	local texture = "MAHelper/Icons/Signal.dds"
	local icon = OSI.CreatePositionIcon(wX, wY, wZ,texture,savedVariable.size, {1, 1, 1} )
	icons[1] = icon
	LibSimpleArrowModS.ShowArrow(playerX, playerY, 1)
	LibSimpleArrowModS.ApplyStyle(MAHelper.name .. "/texture/arrow21.dds", savedVariable.arrowColorArr[1], savedVariable.arrowScale, 1)
	zo_callLater(function() LibSimpleArrowModS.HideArrow(1) end, savedVariable.arrowTime)
	zo_callLater(function() MAHelper.RemoveIcons() end, savedVariable.arrowTime)
end
flash = true
counter = 1
-----------sezione iniziale / setup addon
function MAHelper.Initialize()
	savedVariable = ZO_SavedVars:NewCharacterIdSettings("MAHelperSavedVariables", 1 , "Options", defSett)
	MAHelper.UILoad()
	MAHelper.Menu(savedVariable)
	LibSimpleArrowModS.CreateTexture()
	if OSI and OSI.AddCustomIconPack then
		OSI.AddCustomIconPack( MY_TEXTURES )
	end
	EVENT_MANAGER:RegisterForEvent(MAHelper.name .."EZC",  EVENT_ZONE_CHANGED , MAHelper.ChangedZoneInt)
	EVENT_MANAGER:RegisterForEvent(MAHelper.name .."OPC", EVENT_PLAYER_ACTIVATED, MAHelper.OnPlayerZoneChanged)
end

function MAHelper.OnAddOnLoaded(event, addonName)
	if addonName == MAHelper.name then	
		MAHelper.Initialize()  
	end
end

function MAHelper.OnPlayerZoneChanged()
	Sets = { Set1,Set2,Set3,Set4,Set5,Set6,Set7,Set8,Set9,}
	zI =  GetPlayerActiveSubzoneName()
	if Set ~= nil then
		MAHelper.RegUnloadEvents()
		Set8.RegUnloadEvents()
	end
	for i = 1,9,1 
	do
		if Sets[i].name == zI then	
			Set = Sets[i]
			MAHelper.RegEventsLoader()
			do return end
		end
	end
	MAHelper.RemoveIcons()
	MAHelperAddonIndicatorLabel:SetHidden(true)
end
EVENT_MANAGER:RegisterForEvent(MAHelper.name, EVENT_ADD_ON_LOADED, MAHelper.OnAddOnLoaded)

function MAHelper.OnTitleReturnRound(title)
	local currS = 0
	 if title == "Final Round"  then	
		currS = Set.nR		
		MAHelper.ListAddPosition(Set.nR, 1)		
		do return Set.nR end
	 end
	 cr = Set.nR -1
	 for i=1,cr, 1
	 do
		str = "Round " ..i
		if title == str then
			currS = i
		end
	 end	
	 return currS
end

function MAHelper.ChangedZoneInt()
	if Set8.name == GetPlayerActiveSubzoneName() then
		Set = Set8
			Set.RegEventsLoader()
		do return end
	end
end



-----------Function Test
function stampa(extra)
	local playerX, playerY = GetMapPlayerPosition("player")
	local zone, wX, wY, wZ = GetUnitRawWorldPosition( "player" )
	d("posx =" ..wX  ..",posy =" ..wY  ..",posz =" ..wZ  ..",".."X=" ..playerX ..",Y=" ..playerY)
	d( extra % 3)
end

SLASH_COMMANDS["/st"] = stampa

-----------Events Loader/Un
function MAHelper.RegEventsLoader()
	MAHelper.ListAddPosition(1,1)
	EVENT_MANAGER:RegisterForEvent(MAHelper.name .. "EffectChange", EVENT_EFFECT_CHANGED, Set.OnCheckingEffect)
	EVENT_MANAGER:RegisterForEvent(MAHelper.name .. "PlayerDeath", EVENT_UNIT_DEATH_STATE_CHANGED, MAHelper.OnPlayerDeath)
	EVENT_MANAGER:RegisterForEvent(MAHelper.name .."Announcement", EVENT_DISPLAY_ANNOUNCEMENT, Set.OnTitleAnnounced)
	EVENT_MANAGER:RegisterForEvent(MAHelper.name .."kill", EVENT_COMBAT_EVENT, Set.OnUnitKilled)
	EVENT_MANAGER:AddFilterForEvent(MAHelper.name .."kill", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_DIED_XP)
	EVENT_MANAGER:RegisterForEvent(MAHelper.name, EVENT_PLAYER_COMBAT_STATE, MAHelper.OnCombat)
end
function MAHelper.RegUnloadEvents()
	if Set8.name == Set.name then
		Set.RegUnloadEvents()
		do return end
	end
	EVENT_MANAGER:UnregisterForEvent(MAHelper.name .. "EffectChange", EVENT_EFFECT_CHANGED, Set.OnCheckingEffect)
	EVENT_MANAGER:UnregisterForEvent(MAHelper.name .. "PlayerDeath", EVENT_COMBAT_EVENT, Set.OnPlayerDeath)
	EVENT_MANAGER:UnregisterForEvent(MAHelper.name .."Announcement", EVENT_DISPLAY_ANNOUNCEMENT, Set.OnTitleAnnounced)
	EVENT_MANAGER:UnregisterForEvent(MAHelper.name .."kill", EVENT_COMBAT_EVENT, Set.OnUnitKilled)
end

function MAHelper.OnCombat()
	if not IsUnitInCombat("player") then
		MAHelper.StopText()
	end
end

function  MAHelper.OnPlayerDeath( eventCode,  unitTag,  isDead)
	if isDead and unitTag == "player" then
		MAHelper.RemoveIcons()
		MAHelper.ListAddPosition(CurrStageArena , 1)
		if Set == Set4 then
			Set.counterCurrStageArena = 0
		end
		MAHelper.StopText()
	end
end

-----------Text Functions
function MAHelper.SetText(Texter)
	if not savedVariable.TextVis then
		do return end
	end
	MAHelperAddonIndicatorLabel:SetText(Texter)
	MAHelperAddonIndicatorLabel:SetHidden(false)
	flash = true
	MAHelper.TextFlash()
end
function MAHelper.StopText()
	MAHelperAddonIndicatorLabel:SetHidden(true)
	flash = false
end


function MAHelper.ChangeVisText(value)
	savedVariable.tv = value
	MAHelperAddonIndicatorLabel:SetHidden(not value)
	MAHelperAddonIndicatorLabel:SetMovable(value)
	MAHelperAddonIndicatorLabel:SetMouseEnabled(value)
end
function MAHelper.UILoad()
	savedVariable.tv = false
	MAHelperAddonIndicatorLabel:SetHidden(true)
	if savedVariable.p1 and savedVariable.p2 then
		MAHelperAddonIndicatorLabel:ClearAnchors()
		MAHelperAddonIndicatorLabel:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, savedVariable.p1,savedVariable.p2)
	end
	MAHelperAddonIndicatorLabel:SetHandler("OnMoveStop", function(control)
		savedVariable.p1, savedVariable.p2 = control:GetScreenRect()
	end)
end


function  MAHelper.RestorePos()
	MAHelperAddonIndicatorLabel:ClearAnchors()
	MAHelperAddonIndicatorLabel:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT,TOPLEFT, TOPLEFT)
	MAHelperAddonIndicatorLabel:SetMovable(value)
	MAHelperAddonIndicatorLabel:SetMouseEnabled(value)
end

function MAHelper.TextFlash()
	if not flash then
		do return end
	end
	counter = counter +1
	if counter > 8 then
		counter = 1
	end
	MAHelperAddonIndicatorLabel:SetColor( unpack( savedVariable.arrowColorFlash[counter]))
	zo_callLater(function() MAHelper.TextFlash() end, 100)
end
