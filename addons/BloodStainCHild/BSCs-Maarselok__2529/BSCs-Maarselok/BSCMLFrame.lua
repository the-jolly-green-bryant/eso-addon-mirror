BSCMaarselok = BSCMaarselok or {}
local BSCML = BSCMaarselok

local WM = GetWindowManager()
local width = 35
local hight = 35


function BSCML.GetColor()
	local color = ZO_ColorDef:New(BSCML.SV.textcolor_r, BSCML.SV.textcolor_g, BSCML.SV.textcolor_b)
	
	return string.sub(color:ToHex(), 1)
end

function BSCML.CreateWindow()
	local BSCMLUI = WM:CreateTopLevelWindow("BSCMLUI")	
    BSCMLUI:SetResizeToFitDescendents(true)
    BSCMLUI:SetMovable(true)
    BSCMLUI:SetMouseEnabled(true)
	BSCMLUI:SetHidden(true)
	
		-- Save Position
    BSCMLUI:SetHandler("OnMoveStop", function(control)
        BSCML.SV.UI_LEFT = BSCMLUI:GetLeft()
	    BSCML.SV.UI_TOP  = BSCMLUI:GetTop()
    end)
	
	
	-- back
	local BSCMLUIBackdrop = WM:CreateControl("$(parent)BSCMLUIBack_UITOP", BSCMLUI, CT_BACKDROP)
	BSCMLUIBackdrop:SetEdgeColor(0.4,0.4,0.4, 0)
	BSCMLUIBackdrop:SetCenterColor(0, 0, 0)
	BSCMLUIBackdrop:SetAnchor(TOPLEFT, BSCMLUI, TOPLEFT, 0, 0)
	BSCMLUIBackdrop:SetAlpha(0.8)
	BSCMLUIBackdrop:SetScale(1.0)
	BSCMLUIBackdrop:SetDrawLayer(0)
	BSCMLUIBackdrop:SetDimensions(width, hight)
	BSCMLUIBackdrop:SetHidden(true)
	-- icon
	local BSCMLUIIcon = WM:CreateControl("$(parent)BSCMLUIIcon", BSCMLUI, CT_TEXTURE)
    BSCMLUIIcon:SetScale(1)
	BSCMLUIIcon:SetDrawLayer(1)
	--BSCMLUIIcon:SetTexture(GetItemLinkIcon(BSCML.MAARSELOK_ITEM)) --GetAbilityIcon(BSCML.MAARSELOK_ID))
	BSCMLUIIcon:SetAnchor(CENTER, BSCMLUIBackdrop, CENTER, 0, 0)
	BSCMLUIIcon:SetDimensions(width, hight)
	-- text
	local unit = WM:CreateControl("$(parent)BSCMLUILText", BSCMLUI, CT_LABEL)
	unit:SetColor(255, 255, 255, 1)	
	unit:SetFont("ZoFontGameSmall")
	unit:SetScale(1.0)
	unit:SetWrapMode(TEX_MODE_CLAMP)
	unit:SetDrawLayer(1)
	unit:SetText(string.format("|c%s%s|r", BSCML.GetColor(), "0.0"))				
	unit:SetAnchor(CENTER, BSCMLUI, CENTER, 0, 0)
	unit:SetHidden(true)
		
	BSCMLUI:ClearAnchors()
	BSCMLUI:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, BSCML.SV.UI_LEFT, BSCML.SV.UI_TOP)	
		
	--
	BSCML.Fragment = ZO_HUDFadeSceneFragment:New(BSCMLUI);	
end

function BSCML.SetTextAnchors()
	local lable = 	BSCMLUI:GetNamedChild("BSCMLUILText")
	
	lable:ClearAnchors()
	lable:SetAnchor(CENTER, BSCMLUI, CENTER, BSCML.SV.text_anchro_left_right, BSCML.SV.text_anchro_top_bottom)
end

function BSCML.SetAlpha()
	local top = 	BSCMLUI:GetNamedChild("BSCMLUIBack_UITOP")

	top:SetAlpha(BSCML.SV.UI_ALPHA)	
end

function BSCML.SetIcon()
	local BSCMLUIIcon = 	BSCMLUI:GetNamedChild("BSCMLUIIcon")	
	
	if BSCML.SV.USEICON == false then 
		BSCMLUIIcon:SetTexture(GetAbilityIcon(BSCML.MAARSELOK_ID))
	else
		BSCMLUIIcon:SetTexture(GetItemLinkIcon(BSCML.MAARSELOK_ITEM))
	end	
end

function BSCML.SetIconDimension()
	local top = 	BSCMLUI:GetNamedChild("BSCMLUIBack_UITOP")
	local icon = 	BSCMLUI:GetNamedChild("BSCMLUIIcon")
		
	top:SetDimensions(BSCML.SV.DIMENSION, BSCML.SV.DIMENSION)
	icon:SetDimensions(BSCML.SV.DIMENSION, BSCML.SV.DIMENSION)
end

function BSCML.SetFont()
    local fontSize      = BSCML.SV.TEXTSCALING
    local fontStyle     = "MEDIUM_FONT"        
    local fontWeight    = "thick-outline" 
    
	
	
	local lable = 	BSCMLUI:GetNamedChild("BSCMLUILText")
	lable:SetFont(string.format("EsoUi/Common/Fonts/Univers67.otf|"..fontSize.."|soft-shadow-thick")) --"$(%s)|$(KB_%s)|%s", fontStyle, fontSize, fontWeight))	
end

function BSCML.HideUI(hide)
	local top = 	BSCMLUI:GetNamedChild("BSCMLUIBack_UITOP")
	local icon = 	BSCMLUI:GetNamedChild("BSCMLUIIcon")
	local lable = 	BSCMLUI:GetNamedChild("BSCMLUILText")
	
	if hide == true then
		BSCML.UIisHidden = true
		top:SetHidden(true)
		icon:SetHidden(true)
		lable:SetHidden(true)
	else
		BSCML.UIisHidden = false
		top:SetHidden(false)
		icon:SetHidden(false)
		lable:SetHidden(false)
	end
end


function BSCML.UpdateUI()

	local rTime = (BSCML.EndTime - GetGameTimeMilliseconds()) / 1000
	
	local lable = BSCMLUI:GetNamedChild("BSCMLUILText")
			
	lable:SetText(string.format("|c%s%s|r", BSCML.GetColor(), string.format("%.1f", rTime)));

	if rTime <= 0 then		
		BSCML.isRunning = false
		
		if BSCML.SV.PLAYSOUND then PlaySound(BSCML.SV.SOUND) end
		
		lable:SetText("0.0")			
		-- Nothing to update anymore
		EVENT_MANAGER:UnregisterForUpdate(BSCML.Name.."Update")
	end	
end

