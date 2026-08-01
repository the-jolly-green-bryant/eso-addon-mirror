----------------------------------------------------------------------------------------------------------------------------------------
--####################################################################################################################################--
--####################################################################################################################################--
--####################################################################################################################################--
--####################################################################################################################################--
--####################################################################################################################################--
--##################################################  HIER BITTE NICHTS ÄNDERN !!!  ##################################################--
--####################################################################################################################################--
--####################################################################################################################################--
--####################################################################################################################################--
--####################################################################################################################################--
--####################################################################################################################################--
----------------------------------------------------------------------------------------------------------------------------------------
KI 					= {}
KIUI 				= {}

KI.addon 			= "KInfo"
KI.addonversion 	= "1.4.5"
KI.addonready 		= 0

KI.upgrade1 		= false
KI.firsttime 		= false
KI.bag 				= 0
KI.maximum 			= 0
KI.used 			= 0
KI.available 		= 0
KI.updated 			= 0
KI.debug 			= "Uninitialized"
KI.message 			= ""
KI.bankfree 		= "" 
KI.invfree 			= ""
KI.guildfree 		= ""
KI.savedvariables 	= {}

KIUI.windowmgr 		= GetWindowManager()
KIUI.topwindow 		= nil
KIUI.backdrop 		= nil
KIUI.line1 			= nil
KIUI.line2 			= nil
KIUI.line3 			= nil
KIUI.label1 		= nil
KIUI.label2 		= nil
KIUI.label3 		= nil
KIUI.icon1 			= nil
KIUI.icon2 			= nil
KIUI.icon3 			= nil

Ausrichtung			= 0
B_N_G				= ""

Schrott = 0


-- Farben
local colorYellow 		= 	"|cFFFF00"
local colorLightYellow 	= 	"|cFFFFCC"
local colorGreen	 	= 	"|c996633"
local colorGreen2	 	= 	"|cFFFF00"
local colorMagenta		= 	"|cFF00FF"
local colorRed 			= 	"|cFF0000"
local colorDrkOrange 	= 	"|cFFA500"
local iconYellow		= 	"|cFFFF33"
local iconOrange		= 	"|cFF6600"
local whitetext			= 	"|cffffff"
local redtext 			= 	"|cff0000"
local yellowtext		= 	"|cffff00"
local orangetext		= 	"|cff7b1a"
local lillatext			= 	"|cc437ff"
local goldtext 			= 	"|cffd700"
local greentext 		= 	"|c93ff00"
local banktext 			= 	"|c00a8ff"
local gbanktext 		= 	"|ccd67ff"
local timertext 		= 	"|c1affb4"
local graytext 			= 	"|c7f7f7f"
local creamtext 		= 	"|cffffcc"
local defaulttext 		= creamtext

local GetBagSize = GetBagSize
local GetNumBagUsedSlots = GetNumBagUsedSlots
local GetNumBagFreeSlots = GetNumBagFreeSlots
local GetFrameTimeMilliseconds = GetFrameTimeMilliseconds

-- Debug "Hilfe"
if ChatDebug == 1 then
	if Lang == "de" then
		d(lillatext.."KInfo geladen!")
		d(lillatext.." ")
		d(lillatext.."Für die Liste der Befehle")
		d(lillatext.."[/ki.help] eingeben.")
	else
		d(lillatext.."KInfo loaded!")
		d(lillatext.." ")
		d(lillatext.."For a List of commands enter")
		d(lillatext.."[/ki.help] in the Chat.")
	end
end

-- Update
function KIUpdate()
	if KI.updated then
		KI.updated = 0
	end
end

-- Fenster Verstecken
function HideCheck()
	
	-- Wird versteckt wenn der Kompass ausgeblendet ist
	if ZO_FocusedQuestTracker and KInfoFloat then
		KInfoFloat:SetHidden(ZO_CompassFrame:IsHidden())
	end
	
	-- Wird versteckt wenn Chat aktiv ist,
	-- und angezeigt wenn Chat inaktiv ist.
--	if ............ then
--		KInfoFloat:SetHidden(ZO_CompassFrame:IsHidden())
--	else
--		...........
--	end
	
end

-- Standart Koordinaten
KI.default = {offsetX = 0,	offsetY = 20}

-- Verzögerung
local delay = {last = nil}

-- Speichert die Position des Fensters, wenn es gewegt wurde.
local function OnMoveStop(self)
  KI.savedvariables.offsetX = self:GetLeft()
  KI.savedvariables.offsetY = self:GetTop()
end

local function LoadAddon(eventCode, addOnName)
	
	if(addOnName == KI.addon) then
	  
	  local labelheight = ZeilenHoehe
	  
if AutoFensterBreite == 1 then
	if FensterBreite < 220 then
		local labelwidth = 220
	else
	  	local labelwidth = FensterBreite
	end
else	
	if FensterBreite < 220 then
		labelwidth = 220
	else
	  	labelwidth = FensterBreite
	end
end
	
	  -- adjust the default offset based on screen size
	  local screenwidth = GuiRoot:GetWidth()
	  KI.default.offsetX = screenwidth*0.2
	  
	
		KI.savedvariables = ZO_SavedVars:New("KInfoVars", 1, nil, KI.default)
		
		-- upgrade and repair saved variables  
		if KI.savedvariables.offsetX==nil then
		  KI.savedvariables.offsetX = KI.defaults.offsetX
		  KI.upgrade1 = true
		end
		
    if KI.savedvariables.offsetY==nil then
      KI.savedvariables.offsetY = KI.defaults.offsetY
      KI.upgrade1 = true
    end
    
    if KI.savedvariables.ishidden==nil then
      KI.savedvariables.ishidden = false
      KI.upgrade1 = true
      KI.firsttime = true
    end
    
    if KI.savedvariables.displaywindow then
      KI.savedvariables.displaywindow = nil
    end
		
		KI.savedvariables.addonversion = KI.addonversion
		
		-- create the floating information window
		KIUI.topwindow = KIUI.windowmgr:CreateTopLevelWindow("KInfoFloat")
		
if Hintergrund == 1 then
	local uitemp
	uitemp = KIUI.topwindow
    uitemp:SetClampedToScreen(true)
    uitemp:SetMouseEnabled(true) 
    uitemp:SetResizeToFitDescendents(true)
    uitemp:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, KI.savedvariables.offsetX, KI.savedvariables.offsetY)
    uitemp:SetHidden(KI.savedvariables.ishidden)
    uitemp:SetMovable(true)
    uitemp:SetHandler("OnMoveStop", OnMoveStop)

    KIUI.backdrop = KIUI.windowmgr:CreateControl("KInfoFloatBG", KIUI.topwindow, CT_BACKDROP)
    uitemp = KIUI.backdrop
    uitemp:SetHidden(false)
    uitemp:SetClampedToScreen(false)
    --uitemp:SetAnchor(TOP, KIUI.topwindow, TOP, 0, 0)
    uitemp:SetAnchor(TOPLEFT, KIUI.topwindow, TOPLEFT, 0, 0)
    uitemp:SetResizeToFitDescendents(true)
    uitemp:SetResizeToFitPadding(32,16)
    uitemp:SetDimensionConstraints(labelwidth,labelheight*3)
    uitemp:SetInsets (16,16,-16,-16)
    uitemp:SetEdgeTexture("EsoUI/Art/ChatWindow/chat_BG_edge.dds", 256, 256, 16)
    uitemp:SetCenterTexture("EsoUI/Art/ChatWindow/chat_BG_center.dds")
    --uitemp:SetCenterColor(0.1, 0.1, 0.1)
    --uitemp:SetEdgeColor(0.1, 0.1, 0.1)
    uitemp:SetAlpha(Transparenz)
    uitemp:SetDrawLayer(0)

else		
	uitemp = KIUI.topwindow
    uitemp:SetClampedToScreen(true)
    uitemp:SetMouseEnabled(true) 
    uitemp:SetResizeToFitDescendents(true)
    uitemp:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, KI.savedvariables.offsetX, KI.savedvariables.offsetY)
    uitemp:SetHidden(KI.savedvariables.ishidden)
    uitemp:SetMovable(true)
    uitemp:SetHandler("OnMoveStop", OnMoveStop)

    KIUI.backdrop = KIUI.windowmgr:CreateControl("KInfoFloatBG", KIUI.topwindow)
    uitemp = KIUI.backdrop
    uitemp:SetHidden(false)
    uitemp:SetClampedToScreen(false)
    --uitemp:SetAnchor(TOP, KIUI.topwindow, TOP, 0, 0)
    uitemp:SetAnchor(TOPLEFT, KIUI.topwindow, TOPLEFT, 5, 5)
    uitemp:SetResizeToFitDescendents(true)
    uitemp:SetResizeToFitPadding(32,16)
    uitemp:SetDimensionConstraints(labelwidth,labelheight*3)
    --uitemp:SetInsets (16,16,-16,-16)
    --uitemp:SetEdgeTexture("EsoUI/Art/ChatWindow/chat_BG_edge.dds", 256, 256, 16)
    --uitemp:SetCenterTexture("EsoUI/Art/ChatWindow/chat_BG_center.dds")
    --uitemp:SetCenterColor(0.0, 0.0, 0.0)
    --uitemp:SetEdgeColor(0.0, 0.0, 0.0)
    uitemp:SetAlpha(Transparenz)
    uitemp:SetDrawLayer(0)
 end   

    
    KIUI.infobox = KIUI.windowmgr:CreateControl("KInfoFloatBox", KIUI.backdrop, CT_CONTROL)
    uitemp = KIUI.infobox
    uitemp:SetAnchor(TOPLEFT, KIUI.backdrop, TOPLEFT, 16, 16)
  		
  	-- gold
if AnzeigeGold == 1 then
    KIUI.line1 = KIUI.windowmgr:CreateControl("KInfoZeile1", KIUI.infobox, CT_CONTROL)
    uitemp = KIUI.line1
    uitemp:SetAnchor(TOPLEFT, KIUI.infobox, TOPLEFT, 0, 0)

    KIUI.icon1 = KIUI.windowmgr:CreateControl("KInfoIcon1", KIUI.line1, CT_TEXTURE)
    uitemp = KIUI.icon1
    uitemp:SetDimensions(labelheight*1,labelheight*1)
    uitemp:SetAnchor(LEFT, KIUI.line1, LEFT, labelheight*.2, labelheight*.1)
    uitemp:SetTexture("/esoui/art/currency/currency_gold_32.dds")

    KIUI.label1 = KIUI.windowmgr:CreateControl("KInfoTextZeile1", KIUI.line1, CT_LABEL)
    uitemp = KIUI.label1
    uitemp:SetColor(0.8, 0.8, 0.8, 1)
    uitemp:SetFont("ZoFontGameMedium")
    uitemp:SetWrapMode(TEX_MODE_CLAMP)
    uitemp:SetText("")
    uitemp:SetAnchor(LEFT, KIUI.icon1, RIGHT, 10, -2)
    uitemp:SetDimensions(labelwidth,labelheight)
end
    
  	-- Tel'Var
if AnzeigeTelVar == 1 then
Ausrichtung = Ausrichtung + 1
    KIUI.line1 = KIUI.windowmgr:CreateControl("KInfoZeile2", KIUI.infobox, CT_CONTROL)
    uitemp = KIUI.line1
    uitemp:SetAnchor(TOPLEFT, KIUI.infobox, TOPLEFT, 0, labelheight*Ausrichtung)

    KIUI.icon1 = KIUI.windowmgr:CreateControl("KInfoIcon2", KIUI.line1, CT_TEXTURE)
    uitemp = KIUI.icon1
    uitemp:SetDimensions(labelheight*1,labelheight*1)
    uitemp:SetAnchor(LEFT, KIUI.line3, LEFT, 5, 3)
    uitemp:SetTexture("/esoui/art/currency/currency_telvar_32.dds")

    KIUI.label1 = KIUI.windowmgr:CreateControl("KInfoTextZeile2", KIUI.line1, CT_LABEL)
    uitemp = KIUI.label1
    uitemp:SetColor(0.8, 0.8, 0.8, 1)
    uitemp:SetFont("ZoFontGameMedium")
    uitemp:SetWrapMode(TEX_MODE_CLAMP)
    uitemp:SetText("")
    uitemp:SetAnchor(LEFT, KIUI.icon1, RIGHT, 10, -2)
    uitemp:SetDimensions(labelwidth,labelheight)
end

  	-- Allianzpunkte
if AnzeigeAllianz == 1 then
Ausrichtung = Ausrichtung + 1
    KIUI.line1 = KIUI.windowmgr:CreateControl("KInfoZeile3", KIUI.infobox, CT_CONTROL)
    uitemp = KIUI.line1
    uitemp:SetAnchor(TOPLEFT, KIUI.infobox, TOPLEFT, 0, labelheight*Ausrichtung)

    KIUI.icon1 = KIUI.windowmgr:CreateControl("KInfoIcon3", KIUI.line1, CT_TEXTURE)
    uitemp = KIUI.icon1
    uitemp:SetDimensions(labelheight*1,labelheight*1)
    uitemp:SetAnchor(LEFT, KIUI.line3, LEFT, 5, 3)
    uitemp:SetTexture("/esoui/art/currency/alliancepoints_32.dds")

    KIUI.label1 = KIUI.windowmgr:CreateControl("KInfoTextZeile3", KIUI.line1, CT_LABEL)
    uitemp = KIUI.label1
    uitemp:SetColor(0.8, 0.8, 0.8, 1)
    uitemp:SetFont("ZoFontGameMedium")
    uitemp:SetWrapMode(TEX_MODE_CLAMP)
    uitemp:SetText("")
    uitemp:SetAnchor(LEFT, KIUI.icon1, RIGHT, 10, -2)
    uitemp:SetDimensions(labelwidth,labelheight)
end

    -- bags
if AnzeigeTasche == 1 then
Ausrichtung = Ausrichtung + 1
    KIUI.line2 = KIUI.windowmgr:CreateControl("KInfoZeile4", KIUI.infobox, CT_CONTROL)
    uitemp = KIUI.line2
    uitemp:SetAnchor(TOPLEFT, KIUI.infobox, TOPLEFT, 0, labelheight*Ausrichtung)

    KIUI.icon2 = KIUI.windowmgr:CreateControl("KInfoIcon4", KIUI.line2, CT_TEXTURE)
    uitemp = KIUI.icon2
    uitemp:SetDimensions(labelheight*1.25,labelheight*1.25)
    uitemp:SetAnchor(LEFT, KIUI.line2, LEFT, 0, 1)
    uitemp:SetTexture("/esoui/art/tooltips/icon_bag.dds")
    
    KIUI.label2 = KIUI.windowmgr:CreateControl("KInfoTextZeile4", KIUI.line2, CT_LABEL)
    uitemp = KIUI.label2
    uitemp:SetColor(0.8, 0.8, 0.8, 1)
    uitemp:SetFont("ZoFontGameMedium")
    uitemp:SetWrapMode(TEX_MODE_CLAMP)
    uitemp:SetText("")
    uitemp:SetAnchor(LEFT, KIUI.icon2, RIGHT, 10, -2)
    uitemp:SetDimensions(labelwidth,labelheight)
end	
    
	-- Seelensteine
if AnzeigeSeelensteine == 1 then
Ausrichtung = Ausrichtung + 1
	KIUI.line3 = KIUI.windowmgr:CreateControl("KInfoZeile5", KIUI.infobox, CT_CONTROL)
    uitemp = KIUI.line3
    uitemp:SetAnchor(TOPLEFT, KIUI.infobox, TOPLEFT, 0, (labelheight*Ausrichtung))

    KIUI.icon3 = KIUI.windowmgr:CreateControl("KInfoIcon5", KIUI.line3, CT_TEXTURE)
    uitemp = KIUI.icon3
    uitemp:SetDimensions(labelheight*1,labelheight*1)
    uitemp:SetAnchor(LEFT, KIUI.line3, LEFT, 0, 3)
    uitemp:SetTexture("/esoui/art/icons/soulgem_005_filled.dds")
    
    KIUI.label3 = KIUI.windowmgr:CreateControl("KInfoTextZeile5", KIUI.line3, CT_LABEL)
    uitemp = KIUI.label3
    uitemp:SetColor(0.8, 0.8, 0.8, 1)
    uitemp:SetFont("ZoFontGameMedium")
    uitemp:SetWrapMode(TEX_MODE_CLAMP)
    uitemp:SetText("")
    uitemp:SetAnchor(LEFT, KIUI.icon3, RIGHT, 15, -2)
    uitemp:SetDimensions(labelwidth,labelheight)
end

    -- Reperaturkosten
if AnzeigeReperaturkosten == 1 then
Ausrichtung = Ausrichtung + 1
    KIUI.line3 = KIUI.windowmgr:CreateControl("KInfoZeile6", KIUI.infobox, CT_CONTROL)
    uitemp = KIUI.line3
    uitemp:SetAnchor(TOPLEFT, KIUI.infobox, TOPLEFT, 0, (labelheight*Ausrichtung))

    KIUI.icon3 = KIUI.windowmgr:CreateControl("KInfoIcon6", KIUI.line3, CT_TEXTURE)
    uitemp = KIUI.icon3
    uitemp:SetDimensions(labelheight*1.5,labelheight*1.5)
    uitemp:SetAnchor(LEFT, KIUI.line3, LEFT, 0, 3)
    uitemp:SetTexture("/esoui/art/repair/inventory_tabicon_repair_up.dds")
    
    KIUI.label3 = KIUI.windowmgr:CreateControl("KInfoTextZeile6", KIUI.line3, CT_LABEL)
    uitemp = KIUI.label3
    uitemp:SetColor(0.8, 0.8, 0.8, 1)
    uitemp:SetFont("ZoFontGameMedium")
    uitemp:SetWrapMode(TEX_MODE_CLAMP)
    uitemp:SetText("")
    uitemp:SetAnchor(LEFT, KIUI.icon3, RIGHT, 5, -2)
    uitemp:SetDimensions(labelwidth,labelheight)
end

	-- Himmelsscherben
if AnzeigeHimmelsscherben == 1 then
Ausrichtung = Ausrichtung + 1
    KIUI.line3 = KIUI.windowmgr:CreateControl("KInfoZeile7", KIUI.infobox, CT_CONTROL)
    uitemp = KIUI.line3
    uitemp:SetAnchor(TOPLEFT, KIUI.infobox, TOPLEFT, 0, (labelheight*Ausrichtung))

    KIUI.icon3 = KIUI.windowmgr:CreateControl("KInfoIcon7", KIUI.line3, CT_TEXTURE)
    uitemp = KIUI.icon3
    uitemp:SetDimensions(labelheight*1.75,labelheight*1.75)
    uitemp:SetAnchor(LEFT, KIUI.line3, LEFT, -5, 3)
    uitemp:SetTexture("/esoui/art/icons/achievements_indexicon_skyshards_up.dds")
    
    KIUI.label3 = KIUI.windowmgr:CreateControl("KInfoTextZeile7", KIUI.line3, CT_LABEL)
    uitemp = KIUI.label3
    uitemp:SetColor(0.8, 0.8, 0.8, 1)
    uitemp:SetFont("ZoFontGameMedium")
    uitemp:SetWrapMode(TEX_MODE_CLAMP)
    uitemp:SetText("")
    uitemp:SetAnchor(LEFT, KIUI.icon3, RIGHT, 5, -2)
    uitemp:SetDimensions(labelwidth,labelheight)
end	
	
	-- Timer-Pferd
if AnzeigePferdTimer == 1 then
Ausrichtung = Ausrichtung + 1
    KIUI.line3 = KIUI.windowmgr:CreateControl("KInfoZeile8", KIUI.infobox, CT_CONTROL)
    uitemp = KIUI.line3
    uitemp:SetAnchor(TOPLEFT, KIUI.infobox, TOPLEFT, 0, (labelheight*Ausrichtung))

    KIUI.icon3 = KIUI.windowmgr:CreateControl("KInfoIcon8", KIUI.line3, CT_TEXTURE)
    uitemp = KIUI.icon3
    uitemp:SetDimensions(labelheight*1.75,labelheight*1.75)
    uitemp:SetAnchor(LEFT, KIUI.line3, LEFT, -5, 3)
    uitemp:SetTexture("/esoui/art/tutorial/tutorial_idexicon_mounts_up.dds")
    
    KIUI.label3 = KIUI.windowmgr:CreateControl("KInfoTextZeile8", KIUI.line3, CT_LABEL)
    uitemp = KIUI.label3
    uitemp:SetColor(0.8, 0.8, 0.8, 1)
    uitemp:SetFont("ZoFontGameMedium")
    uitemp:SetWrapMode(TEX_MODE_CLAMP)
    uitemp:SetText("")
    uitemp:SetAnchor(LEFT, KIUI.icon3, RIGHT, 5, -2)
    uitemp:SetDimensions(labelwidth,labelheight)
end	

	-- Stats-Pferd
if AnzeigePferdStats == 1 then
Ausrichtung = Ausrichtung + 1
    KIUI.line3 = KIUI.windowmgr:CreateControl("KInfoZeile9", KIUI.infobox, CT_CONTROL)
    uitemp = KIUI.line3
    uitemp:SetAnchor(TOPLEFT, KIUI.infobox, TOPLEFT, 0, (labelheight*Ausrichtung))

    KIUI.icon3 = KIUI.windowmgr:CreateControl("KInfoIcon9", KIUI.line3, CT_TEXTURE)
    uitemp = KIUI.icon3
    uitemp:SetDimensions(labelheight*1.75,labelheight*1.75)
    uitemp:SetAnchor(LEFT, KIUI.line3, LEFT, -5, 3)
    uitemp:SetTexture("/esoui/art/tutorial/tabicon_ridingskills_up.dds")
    
    KIUI.label3 = KIUI.windowmgr:CreateControl("KInfoTextZeile9", KIUI.line3, CT_LABEL)
    uitemp = KIUI.label3
    uitemp:SetColor(0.8, 0.8, 0.8, 1)
    uitemp:SetFont("ZoFontGameMedium")
    uitemp:SetWrapMode(TEX_MODE_CLAMP)
    uitemp:SetText("")
    uitemp:SetAnchor(LEFT, KIUI.icon3, RIGHT, 5, -2)
    uitemp:SetDimensions(labelwidth,labelheight)
end	

	-- bank
if AnzeigeBank == 1 then
Ausrichtung = Ausrichtung + 1
    KIUI.line3 = KIUI.windowmgr:CreateControl("KInfoZeile10", KIUI.infobox, CT_CONTROL)
    uitemp = KIUI.line3
    uitemp:SetAnchor(TOPLEFT, KIUI.infobox, TOPLEFT, 0, (labelheight*Ausrichtung))

    KIUI.icon3 = KIUI.windowmgr:CreateControl("KInfoIcon10", KIUI.line3, CT_TEXTURE)
    uitemp = KIUI.icon3
    uitemp:SetDimensions(labelheight*1.25,labelheight*1.25)
    uitemp:SetAnchor(LEFT, KIUI.line3, LEFT, 0, 3)
    uitemp:SetTexture("/esoui/art/icons/mapkey/mapkey_bank.dds")
    
    KIUI.label3 = KIUI.windowmgr:CreateControl("KInfoTextZeile10", KIUI.line3, CT_LABEL)
    uitemp = KIUI.label3
    uitemp:SetColor(0.8, 0.8, 0.8, 1)
    uitemp:SetFont("ZoFontGameMedium")
    uitemp:SetWrapMode(TEX_MODE_CLAMP)
    uitemp:SetText("")
    uitemp:SetAnchor(LEFT, KIUI.icon3, RIGHT, 10, -2)
    uitemp:SetDimensions(labelwidth,labelheight)
end	

  	-- bankgold
if AnzeigeGoldBank == 1 then
Ausrichtung = Ausrichtung + 1
    KIUI.line1 = KIUI.windowmgr:CreateControl("KInfoZeile11", KIUI.infobox, CT_CONTROL)
    uitemp = KIUI.line1
    uitemp:SetAnchor(TOPLEFT, KIUI.infobox, TOPLEFT, 0, (labelheight*Ausrichtung))

    KIUI.icon1 = KIUI.windowmgr:CreateControl("KInfoIcon11", KIUI.line1, CT_TEXTURE)
    uitemp = KIUI.icon1
    uitemp:SetDimensions(labelheight*1,labelheight*1)
    uitemp:SetAnchor(LEFT, KIUI.line4, LEFT, 5, 3)
    uitemp:SetTexture("/esoui/art/currency/currency_gold_32.dds")

    KIUI.label1 = KIUI.windowmgr:CreateControl("KInfoTextZeile11", KIUI.line1, CT_LABEL)
    uitemp = KIUI.label1
    uitemp:SetColor(0.8, 0.8, 0.8, 1)
    uitemp:SetFont("ZoFontGameMedium")
    uitemp:SetWrapMode(TEX_MODE_CLAMP)
    uitemp:SetText("")
    uitemp:SetAnchor(LEFT, KIUI.icon1, RIGHT, 10, -2)
    uitemp:SetDimensions(labelwidth,labelheight)
end

  	-- bank Tel'Var
if AnzeigeTelVarBank == 1 then
Ausrichtung = Ausrichtung + 1
    KIUI.line1 = KIUI.windowmgr:CreateControl("KInfoZeile12", KIUI.infobox, CT_CONTROL)
    uitemp = KIUI.line1
    uitemp:SetAnchor(TOPLEFT, KIUI.infobox, TOPLEFT, 0, (labelheight*Ausrichtung))

    KIUI.icon1 = KIUI.windowmgr:CreateControl("KInfoIcon12", KIUI.line1, CT_TEXTURE)
    uitemp = KIUI.icon1
    uitemp:SetDimensions(labelheight*1,labelheight*1)
    uitemp:SetAnchor(LEFT, KIUI.line4, LEFT, 5, 3)
    uitemp:SetTexture("/esoui/art/currency/currency_telvar_32.dds")

    KIUI.label1 = KIUI.windowmgr:CreateControl("KInfoTextZeile12", KIUI.line1, CT_LABEL)
    uitemp = KIUI.label1
    uitemp:SetColor(0.8, 0.8, 0.8, 1)
    uitemp:SetFont("ZoFontGameMedium")
    uitemp:SetWrapMode(TEX_MODE_CLAMP)
    uitemp:SetText("")
    uitemp:SetAnchor(LEFT, KIUI.icon1, RIGHT, 10, -2)
    uitemp:SetDimensions(labelwidth,labelheight)
end

			
		UpdateKIData()
if AnzeigeGold == 1 then
KInfoTextZeile1:SetText(KI.floatgold)
end
if AnzeigeTelVar == 1 then
KInfoTextZeile2:SetText(KI.floattelvar)
end
if AnzeigeAllianz == 1 then
KInfoTextZeile3:SetText(KI.floatallianz)
end
if AnzeigeTasche == 1 then
KInfoTextZeile4:SetText(KI.floatbag)
end
if AnzeigeSeelensteine == 1 then
KInfoTextZeile5:SetText(KI.floatsoul)
end
if AnzeigeReperaturkosten == 1 then
KInfoTextZeile6:SetText(KI.floatrepair)
end
if AnzeigeHimmelsscherben == 1 then
KInfoTextZeile7:SetText(KI.floatshards)
end
if AnzeigePferdTimer == 1 then
KInfoTextZeile8:SetText(KI.floatpferd)
end
if AnzeigePferdStats == 1 then
KInfoTextZeile9:SetText(KI.floatpferdstats)
end
if AnzeigeBank == 1 then
KInfoTextZeile10:SetText(KI.floatbank)
end
if AnzeigeGoldBank == 1 then
KInfoTextZeile11:SetText(KI.floatbankgold)
end
if AnzeigeTelVarBank == 1 then
KInfoTextZeile12:SetText(KI.floatbanktelvar)
end
							
		EVENT_MANAGER:UnregisterForEvent(KI.addon, EVENT_ADD_ON_LOADED)
		
		KI.addonready = 1
			
	end
	
end

function KIScherben(eventCode)
	if (KI.addonready == 0) then return end
	KI.updated=1
	postBagInformation()
end

function KIOpenBank(eventCode)
	if (KI.addonready == 0) then return end
	KI.updated=1
	postBagInformation()
end

function KICloseBank(eventCode)
  if (KI.addonready == 0) then return end
  KI.updated=1
  postBagInformation()
end


function KIInventoryEvent(bagId, slotId, isNewItem, itemSoundCategory, updateReason)
	if (KI.addonready == 0) then return end
	KI.updated=1
	postBagInformation()
end 

function KIItemEvent(eventCode, eventData)
	if (KI.addonready == 0) then return end
	KI.updated=1
	postBagInformation()
end 

function KIMoneyEvent(eventCode, eventData)
  if (KI.addonready == 0) then return end
  KI.updated=1
  postBagInformation()
end 


function postBagInformation()
	UpdateKIData()
	--KInfoWindow:SetText(KI.message)
if AnzeigeGold == 1 then
KInfoTextZeile1:SetText(KI.floatgold)
end
if AnzeigeTelVar == 1 then
KInfoTextZeile2:SetText(KI.floattelvar)
end
if AnzeigeAllianz == 1 then
KInfoTextZeile3:SetText(KI.floatallianz)
end
if AnzeigeTasche == 1 then
KInfoTextZeile4:SetText(KI.floatbag)
end
if AnzeigeSeelensteine == 1 then
KInfoTextZeile5:SetText(KI.floatsoul)
end
if AnzeigeReperaturkosten == 1 then
KInfoTextZeile6:SetText(KI.floatrepair)
end
if AnzeigeHimmelsscherben == 1 then
KInfoTextZeile7:SetText(KI.floatshards)
end
if AnzeigePferdTimer == 1 then
KInfoTextZeile8:SetText(KI.floatpferd)
end
if AnzeigePferdStats == 1 then
KInfoTextZeile9:SetText(KI.floatpferdstats)
end
if AnzeigeBank == 1 then
KInfoTextZeile10:SetText(KI.floatbank)
end
if AnzeigeGoldBank == 1 then
KInfoTextZeile11:SetText(KI.floatbankgold)
end
if AnzeigeTelVarBank == 1 then
KInfoTextZeile12:SetText(KI.floatbanktelvar)
end
end


function postBankInformation()
end


function UpdateKIData()
    --BagID:
    -- BAG_BACKPACK
    -- BAG_BANK
    -- BAG_BUYBACK
    -- BAG_GUILDBANK
    -- BAG_WORN 
	
----Eigene Variablen--------------------------------------------------
-- Reperatur Kosten
	kosten = 0
	for k=0, GetBagSize(BAG_WORN) do
		kosten = kosten + GetItemRepairCost(BAG_WORN, k)
	end

-- Reperatur Zustand in Prozent DoesItemHaveDurability(bagId,slotIndex)


-- Preis für den Verkauf der Items im Inventar (Grün = Normale Items , Rot = Gestohlene Items)
	gewinn		= 0
	gewinntext 	= ""

	for g=0, GetBagSize(BAG_BACKPACK) do
		
		if IsItemJunk(BAG_BACKPACK, g) == true then
		
			if IsItemStolen(BAG_BACKPACK, g) == true then
				gewinntext = redtext
					if gewinn < 0 then
						gewinntext = iconOrange
					end
			end
		
			Stack = GetSlotStackSize(BAG_BACKPACK, g)
			
			if Stack == GetSlotStackSize(BAG_BACKPACK, g) then
				Schrott = GetItemSellValueWithBonuses(BAG_BACKPACK, g) * Stack
				gewinn = gewinn + (GetItemSellValueWithBonuses(BAG_BACKPACK, g) * Stack)
			else end
			
		else 
		end
	end


-- Anzahl der Seelensteine im Inventar
	SoulGems 		= 0
	local s2		= 0
	for s=0, GetBagSize(BAG_BACKPACK) do
		
		if IsItemSoulGem(1, BAG_BACKPACK, s) == true then
			
			s2 = s
			Stack = GetSlotStackSize(BAG_BACKPACK, s2)
			
			if Stack == GetSlotStackSize(BAG_BACKPACK, s2) then
				SoulGems = SoulGems + (1 * Stack)
			else end
			
		else 
		end
	end

-- Stats vom Pferd
	local TimerPferd		= GetTimeUntilCanBeTrained()
	local inventoryBonus, maxInventoryBonus, staminaBonus, maxStaminaBonus, speedBonus, maxSpeedBonus = GetRidingStats()
	
	local TimerSchmied		= GetSmithingResearchLineTraitTimes()
	local TimerSchneider	= ""
	local TimerSchreiner	= ""
	local repair 			= kosten
--	local zustand 			= zustand
	local gewinn 			= gewinn
	local spliter			= GetNumSkyShards()
	local SoulGems			= SoulGems
	local Allianz			= GetAlliancePoints()
	local Kopfgeld			= GetFullBountyPayoffAmount()
	local TelVar			= GetCarriedCurrencyAmount(CURT_TELVAR_STONES)
	local TelVarBank		= GetBankedTelvarStones()
	local BeuteTypeNormal	= 0
	local BeuteTypeGestohlen= 0
----------------------------------------------------------------------
	
	local bagid 			= BAG_BACKPACK
	local bagid2 			= BAG_BANK	
	local gold 				= GetCurrentMoney()
	
--	local gold				= "" --NUR ZUM TESTEN
	
	KI.bag = bagid
	KI.maximum = GetBagSize(KI.bag)
    KI.used = GetNumBagUsedSlots(KI.bag)
    KI.available = GetNumBagFreeSlots(KI.bag)
    
	KI.bag2 = bagid2
    local bankmax = GetBagSize(KI.bag2)
    local bankused = GetNumBagUsedSlots(KI.bag2)
	local bankgold = GetBankedMoney()
    local guildmax = GetBagSize(BAG_GUILDBANK)
    local guildused = GetNumBagUsedSlots(BAG_GUILDBANK)



----------------------------------------------------------------------
-- Einfärbun des "Gewinn"-Wertes, abhängig vom BeuteType. (Grün = Normal , Rot = Gestohlen)
if AnzeigeGewinn == 1 then
	gewinn_test = gewinn - repair - Kopfgeld
	if gewinn_test < 0 then
	
		for g=0, GetBagSize(BAG_BACKPACK) do
		
			if IsItemJunk(BAG_BACKPACK, g) == true then
				
				
				if IsItemStolen(BAG_BACKPACK, g) == true then
				gewinntext = redtext
				else
					if gewinn < 0 then
						gewinntext = iconOrange
					else
						gewinntext = greentext
					end
				end
			else
			end
		end
	if Lang == "de" then
		gew_vertext 	= iconOrange
		gewinn 			= math.floor(gewinn - repair - Kopfgeld)
		gew_ver			= gew_vertext.."            Verlust: "..gewinntext..gewinn..colorDrkOrange.."g"
	elseif Lang == "en" then
		gew_vertext 	= greentext
		gewinn 			= math.floor(gewinn - repair - Kopfgeld)
		gew_ver			= gew_vertext.."            Loss: "..gewinntext..gewinn..colorDrkOrange.."g"		
	else
		Lang = "de"
		gew_vertext 	= greentext
		gewinn 			= math.floor(gewinn - repair - Kopfgeld)
		gew_ver			= gew_vertext.."            Verlust: "..gewinntext..gewinn..colorDrkOrange.."g"	
	end
	else
	if Lang == "de" then
		gew_vertext 	= greentext
		gewinn 			= math.floor(gewinn - repair - Kopfgeld)
		gew_ver			= gew_vertext.."            Gewinn: "..gewinntext..gewinn..colorDrkOrange.."g"
	elseif Lang == "en" then
		gew_vertext 	= greentext
		gewinn 			= math.floor(gewinn - repair - Kopfgeld)
		gew_ver			= gew_vertext.."            Profit: "..gewinntext..gewinn..colorDrkOrange.."g"		
	else
		Lang = "de"
		gew_vertext 	= greentext
		gewinn 			= math.floor(gewinn - repair - Kopfgeld)
		gew_ver			= gew_vertext.."            Gewinn: "..gewinntext..gewinn..colorDrkOrange.."g"	
	end
	end
else
gew_ver = ""
end
----------------------------------------------------------------------
-- Zählen der BeuteTypen im "Trödel"-Inventar. (Grün = Normal , Rot = Gestohlen)
if AnzeigeBeuteType == 1 then
	for g=0, GetBagSize(BAG_BACKPACK) do
		if IsItemJunk(BAG_BACKPACK, g) == true then
			BeuteTypeNormal = BeuteTypeNormal + 1
			if IsItemStolen(BAG_BACKPACK, g) == true then
				BeuteTypeGestohlen = BeuteTypeGestohlen + 1
			else
			end
		else
		end
	end
	BeuteTypeNormal = BeuteTypeNormal - BeuteTypeGestohlen
	B_N_G	= colorDrkOrange.."              ("..greentext..BeuteTypeNormal.." / "..redtext..BeuteTypeGestohlen..colorDrkOrange..")"
else
	B_N_G	= ""
end
----------------------------------------------------------------------
-- Markiere "Gifte" als Trödel
if Gifte == 1 then
	for g=0, GetBagSize(BAG_BACKPACK) do
		if IsItemJunk(BAG_BACKPACK, g) == true then
			-- NICHT MACHEN !
		else
			----Gifte erkennen
				local itemType = GetItemType(BAG_BACKPACK, g)
				if ITEMTYPE_POISON == itemType then
					local giftCounter 	= 0
					local totalgift 	= 0
					local giftname 		= ""
					local bag 			= BAG_BACKPACK
					local slot 			= 0
					local bagSlots 		= GetBagSize(bag) - 1
	
					while(slot<=bagSlots) do
						local itemType 	= GetItemType(bag, slot)
						if ITEMTYPE_POISON == itemType then
							giftname	= GetItemLink(bag, slot)
							giftCounter = GetItemTotalCount(bag, slot)
							totalgift 	= totalgift + giftCounter
							SetItemIsJunk(bag, slot, true)
						end
						slot = slot + 1
					end
				if ChatDebug == 1 then
					if Lang == "de" then
						d(greentext.."KInfo-Trödel markiert:")
						d(giftname)
					elseif Lang == "en" then
						d(greentext.."KInfo-Market as Junk:")
						d(giftname)
					else
						Lang = "de"
						d(greentext.."KInfo-Trödel markiert:")
						d(giftname)
					end
				end
		end
	end
end
end
----------------------------------------------------------------------
-- Zahlen runden
function round(val, decimal)
  if (decimal) then
    return math.floor( (val * 10^decimal)) / (10^decimal)
  else
    return math.floor(val)
  end
end
----------------------------------------------------------------------
if RundenGold == 1 then
		if gold >= 1000 then
			gold = math.floor(gold)/1000
			gold = round(gold, RundenGoldStellen).."K"
		else
		end
 end
----------------------------------------------------------------------
if RundenTelVar == 1 then
		if TelVar >= 1000 then
			TelVar = math.floor(TelVar)/1000
			TelVar = round(TelVar, RundenTelVarStellen).."K"
		else
		end
end
----------------------------------------------------------------------
if RundenTelVarBank == 1 then
		if TelVarBank >= 1000 then
			TelVarBank = math.floor(TelVarBank)/1000
			TelVarBank = round(TelVarBank, RundenTelVarBankStellen).."K"
		else
		end
end
----------------------------------------------------------------------
if RundenAllianz == 1 then
		if Allianz >= 1000 then
			Allianz = math.floor(Allianz)/1000
			Allianz = round(Allianz, RundenAllianzStellen).."K"
		else
		end
end
----------------------------------------------------------------------
if RundenBankGold == 1 then
		if bankgold >= 1000 then
			bankgold = math.floor(bankgold)/1000
			bankgold = round(bankgold, RundenBankGoldStellen).."K"
		else
		end
end
----------------------------------------------------------------------
if RundenReperatur == 1 then
		if repair >= 1000 then
			repair = math.floor(repair)/1000
			repair = round(repair, RundenReperaturStellen).."K"
		else
		end
end
----------------------------------------------------------------------
if RundenGewinn == 1 then
		if gewinn >= 1000 then
			gewinn = math.floor(gewinn)/1000
			gewinn = round(gewinn, RundenGewinnStellen).."K"
		else
		end
end
----------------------------------------------------------------------
	if TimerPferd > 0 then
		millisekunden	= TimerPferd
		
		sek_ges = millisekunden /1000
		stunden = math.floor(sek_ges/3600)
		reste 	= sek_ges - (stunden*3600)
		minuten = math.floor(reste/60)
		sekunden= reste -(minuten*60)
	
			if sekunden <= 9 then
				sekunden = "0"..sekunden
				else end
			if minuten <= 9 then
				minuten = "0"..minuten
				else end
			if stunden <= 9 then
				stunden = "0"..stunden
				else end
	if Zeitformat == 1 then
		TimerPferd	= stunden..":"..minuten
	elseif Zeitformat == 2 then
		TimerPferd	= stunden..":"..minuten..":"..sekunden
	else
		TimerPferd	= stunden..":"..minuten
	end
	else
		if Lang == "de" then
			TimerPferd = "Hungrig!"
		elseif Lang == "en" then
			TimerPferd = "Feed!"
		else
			Lang = "de"
			TimerPferd = "Hungrig!"
		end
	end	
----------------------------------------------------------------------
if speedBonus <=9 then
	speedBonus = "0"..speedBonus
	elseif speedBonus == maxSpeedBonus then
	speedBonus = "MAX"
end
if staminaBonus <=9 then
	staminaBonus = "0"..staminaBonus
	elseif staminaBonus == maxStaminaBonus then
	staminaBonus = "MAX"
end
if inventoryBonus <=9 then
	inventoryBonus = "0"..inventoryBonus
	elseif inventoryBonus == maxInventoryBonus then
	inventoryBonus = "MAX"
end
local StatsPferd = banktext.."["..speedBonus.." / 60] "..greentext.." ["..staminaBonus.." / 60] "..timertext.." ["..inventoryBonus.." / 60] "
----------------------------------------------------------------------

	local banksizewarning = banktext
	local guildsizewarning = gbanktext
	local bagsizewarning = greentext
	
	if (KI.used==KI.maximum) then bagsizewarning = redtext
	elseif (KI.used>(KI.maximum-5)) then bagsizewarning = yellowtext
	end
	
	if (bankused==bankmax) then banksizewarning = redtext
	elseif (bankused>(bankmax-5)) then banksizewarning = yellowtext
	end

	if (guildused==guildmax) then guildsizewarning = redtext
	elseif (guildused>(guildmax-5)) then guildsizewarning = yellowtext
	end

	-- text for the bank/guild/inventory dialog
	local backpack 		= defaulttext.."Backpack: "..bagsizewarning..KI.used.." / "..KI.maximum..defaulttext
	local playerbank 	= banktext..",  Bank: "..banksizewarning..bankused.." / "..bankmax..defaulttext
	local guildbank 	= ",  Guild: "..guildsizewarning..guildused.." / "..guildmax..defaulttext
	
	-- text for the floating window
	local goldline 		= colorDrkOrange..gold..gew_ver
	local telvarline	= timertext..TelVar
	local allianzline	= timertext..Allianz
	local bagline 		= bagsizewarning..KI.used.." / "..KI.maximum..B_N_G
	local soulline		= lillatext..SoulGems
	local repairline 	= orangetext..repair
	local shardsline 	= orangetext..spliter.." / 3"
	local pferdline		= orangetext..TimerPferd
	local pferdstatsline= StatsPferd
	local bankline 		= banksizewarning..bankused.." / "..bankmax
	local bankgoldline 	= banktext..bankgold
	local banktelvarline= banktext..TelVarBank

	KI.message 			= backpack..playerbank
	KI.bankfree 		= backpack..playerbank 
	KI.invfree 			= backpack
	KI.guildfree 		= backpack..guildbank 
	
	KI.floatgold 		= goldline
	KI.floattelvar		= telvarline
	KI.floatallianz		= allianzline
	KI.floatbag 		= bagline
	KI.floatsoul 		= soulline
	KI.floatrepair 		= repairline
	KI.floatshards 		= shardsline
	KI.floatpferd		= pferdline
	KI.floatpferdstats	= pferdstatsline
	KI.floatbank 		= bankline
	KI.floatbankgold 	= bankgoldline
	KI.floatbanktelvar	= banktelvarline
	
	KI.updated = 1
	return message
	
end 


function ThrashingDelay(timer)
	local now = GetFrameTimeMilliseconds() 
	if delay.last == nil then
		delay.last = now 
	end	
	local diff = now - delay.last
	local eval = (diff >= timer)
	if eval then
		delay.last = now 
	end
	return eval
end

function BankEinzahlung()

	local gold		= GetCurrentMoney()
	local TelVar	= GetCarriedCurrencyAmount(CURT_TELVAR_STONES)
	
	local EinzahlungGold	= gold - AutoEinzahlungGold
	local EinzahlungTelVar	= TelVar - AutoEinzahlungTelVar
	local EinlagerungSeelen	= SoulGems - AutoLagerungSeelen
------------------------------------------------------------------------------------
if AutomatischEinzahlen == 1 then
		if gold >= AutoEinzahlungGold then
			DepositMoneyIntoBank(EinzahlungGold)
			if EinzahlungGold > 0 then
			if ChatDebug == 1 then
				if Lang == "de" then
					d(banktext.."KInfo: Du hast "..yellowtext..EinzahlungGold..banktext.." Gold eingezahlt!")
				else
					d(banktext.."KInfo: You have deposit "..yellowtext..EinzahlungGold..banktext.." Gold!")
				end
			end
			end
		elseif gold <= AutoEinzahlungGold then
			local gold				= GetCurrentMoney()
			local AbbuchungGold		= AutoEinzahlungGold - gold
			WithdrawMoneyFromBank(AbbuchungGold)
			if AbbuchungGold > 0 then
			if ChatDebug == 1 then
				if Lang == "de" then
					d(banktext.."KInfo: Du hast "..yellowtext..AbbuchungGold..banktext.." Gold abgehoben!")
				else
					d(banktext.."KInfo: You have withdrawed "..yellowtext..AbbuchungGold..banktext.." Gold!")
				end
			end
			end
		end
end
------------------------------------------------------------------------------------
if AutomatischEinzahlen == 1 then
		if TelVar >= AutoEinzahlungTelVar then
			DepositCurrencyIntoBank(CURT_TELVAR_STONES, EinzahlungTelVar)
			if EinzahlungTelVar > 0 then
			if ChatDebug == 1 then
				if Lang == "de" then
					d(banktext.."KInfo: Du hast "..yellowtext..EinzahlungTelVar..banktext.." Tel'Var eingezahlt!")
				else
					d(banktext.."KInfo: You have deposit "..yellowtext..EinzahlungTelVar..banktext.." Tel'Var!")
				end
			end
			end
		elseif TelVar <= AutoEinzahlungTelVar then
			local TelVar			= GetCarriedCurrencyAmount(CURT_TELVAR_STONES)
			local AbbuchungTelVar	= AutoEinzahlungTelVar - TelVar
			WithdrawCurrencyFromBank(CURT_TELVAR_STONES, AbbuchungTelVar)
			if AbbuchungTelVar > 0 then
			if ChatDebug == 1 then
				if Lang == "de" then
					d(banktext.."KInfo: Du hast "..yellowtext..AbbuchungTelVar..banktext.." Tel'Var abgehoben!")
				else
					d(banktext.."KInfo: You have withdrawed "..yellowtext..AbbuchungTelVar..banktext.." Tel'Var!")
				end
			end
			end
		end
end
------------------------------------------------------------------------------------
--		if SoulGems >= AutoLagerungSeelen then
--			for s=0, GetBagSize(BAG_BACKPACK) do
--				if IsItemSoulGem(1, BAG_BACKPACK, s) == true then
--					local Anzahl = GetItemTotalCount(BAG_BACKPACK, s)
--					local Seelen = GetItemInstanceId(1, BAG_BACKPACK, s)
--				end
--			end
--			DepositItemIntoBank(CURT_TELVAR_STONES, EinlagerungSeelen)
--		elseif SoulGems <= AutoEinzahlungTelVar then
--			local TelVar			= GetCarriedCurrencyAmount(CURT_TELVAR_STONES)
--			local AuslagerungSeelen	= AutoLagerungSeelen - SoulGems
--			WithdrawItemFromBank(CURT_TELVAR_STONES, AbbuchungTelVar)
--		end
end

local function Trader()
-- Auto-Repair
if kosten <= 0 then
	kosten = 0
end
if kosten >= 1 then
	if AutoRepair == 1 then
		for k=0, GetBagSize(BAG_WORN) do
			RepairItem(BAG_WORN, k)
		end
		if ChatDebug == 1 then
			if Lang == "de" then
				d(orangetext.."KInfo: Ausrüstung für "..yellowtext..kosten..orangetext.." Gold repariert!")
			else
				d(orangetext.."KInfo: Gear repaired for"..yellowtext..kosten..orangetext.." Gold!")
			end
		end
	end
end
if Schrott <= 0 then
	Schrott = 0
end
if Schrott >= 1 then
	if Autoverkauf == 1 then
		SellAllJunk()
		if ChatDebug == 1 then
			if Lang == "de" then
				d(greentext.."KInfo: Trödel für "..yellowtext..Schrott..greentext.." Gold verkauft!")
			else
				d(greentext.."KInfo: Junk sold for"..yellowtext..Schrott..greentext.." Gold!")
			end
		end
	end
end
end
	
local function hilfe()
				if Lang == "de" then
					d(lillatext.."KInfo - HILFE:")
					d(lillatext.." ")
					d(lillatext.."-Wechsele mit [/ki.en] die KInfo-Ausgabe auf Englisch.")
					d(lillatext.."-Wechsele mit [/ki.de] die KInfo-Ausgabe auf Deutsch.")
					d(lillatext.."-Wechsele mit [/ki.debug] wird der Debug im")
					d(lillatext.."Chat EIN/AUS-geschaltet.")
				else
					d(lillatext.."KInfo - HELP:")
					d(lillatext.." ")
					d(lillatext.."-Switch with [/ki.de] the KInfo-Output to german.")
					d(lillatext.."-Switch with [/ki.en] the KInfo-Output to english.")
					d(lillatext.."-With [/ki.debug] the Debug at the chat will be")
					d(lillatext.."turned ON/OFF.")
				end
end

local function deutsch()
	Lang = "de"
	d(lillatext.."KInfo: Deutsch-Modus")
end

local function english()
	Lang = "en"
	d(lillatext.."KInfo: English-Mode")
end

local function KIDebug()
	if ChatDebug == 0 then
		if Lang == "de" then
			ChatDebug = 1
			d(lillatext.."KInfo: Debug aktiviert!")
		else
			ChatDebug = 1
			d(lillatext.."KInfo: Debug activated!")
		end
	else
		if Lang == "de" then
			ChatDebug = 0
			d(lillatext.."KInfo: Debug deaktiviert!")
		else
			ChatDebug = 0
			d(lillatext.."KInfo: Debug disabled!")
		end
	end
end

--SLASH_COMMANDS["/Kommando"] = FUNKTION
SLASH_COMMANDS["/ki.help"] 			= hilfe
SLASH_COMMANDS["/ki.de"] 			= deutsch
SLASH_COMMANDS["/ki.en"] 			= english
SLASH_COMMANDS["/ki.debug"] 		= KIDebug

----------------------------------------------------------------------------
----------------------------------------------------------------------------
EVENT_MANAGER:RegisterForUpdate("KIHideCheck", Refresh, HideCheck)----------
EVENT_MANAGER:RegisterForUpdate("KIUpdateCheck", Refresh, KIUpdate)---------
----------------------------------------------------------------------------
EVENT_MANAGER:RegisterForEvent(KI.addon, EVENT_ADD_ON_LOADED, LoadAddon)----
----------------------------------------------------------------------------
----------------------------------------------------------------------------
EVENT_MANAGER:RegisterForEvent(KI.addon, EVENT_OPEN_BANK, BankEinzahlung)---
EVENT_MANAGER:RegisterForEvent(KI.addon, EVENT_OPEN_STORE, Trader)----------
----------------------------------------------------------------------------
----------------------------------------------------------------------------
	EVENT_MANAGER:RegisterForUpdate(KI.addon, Refresh, KIOpenBank)----------
----------------------------------------------------------------------------
----------------------------------------------------------------------------