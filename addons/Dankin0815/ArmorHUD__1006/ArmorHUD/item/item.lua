AHUD.Item = {}
AHUD.Item.init = 0

AHUD.Item.Default = {
	OffsetX = 0,
	OffsetY = 50,
	Hiden = false,
	HideText = true,
	ColorPerfect = {0,1,0,1},
	ColorWell = {0,0.5,0,1},
	ColorAcceptable = {1,1,0,1},
	ColorBad = {1,0.55,0,1},
	ColorBrocken = {1,0,0,1},
	IconSize = 48
}

local wm = GetWindowManager()

--Sets the Item HUD up
function AHUD.Item:Init()
	
	AHUD.showmessage = 1
	
	AHUD.Item.savedVariables = ZO_SavedVars:New("ArmorHUDVars",1,nil,AHUD.Item.Default)
	
	AHUD.Item.Armor = {
		{["ID"] = 0 , ["Durability"] = 0},  --Head
		{["ID"] = 2 , ["Durability"] = 0},  --Chest
		{["ID"] = 3 , ["Durability"] = 0},  --Shoulder
		{["ID"] = 6 , ["Durability"] = 0},  --Waist
		{["ID"] = 16 , ["Durability"] = 0}, --Hand
		{["ID"] = 8 , ["Durability"] = 0},  --Legs
		{["ID"] = 9 , ["Durability"] = 0},  --Feet
	}
	
	AHUD.Item.Weapon = {
		{["ID"] = EQUIP_SLOT_MAIN_HAND , ["chargeable"] = false , ["Charge"] = -1 , ["maxCharge"] = -1 , ["pct"] = -1},
		{["ID"] = EQUIP_SLOT_OFF_HAND , ["chargeable"] = false , ["Charge"] = -1 , ["maxCharge"] = -1 , ["pct"] = -1},
		{["ID"] = EQUIP_SLOT_BACKUP_MAIN , ["chargeable"] = false , ["Charge"] = -1 , ["maxCharge"] = -1 , ["pct"] = -1},
		{["ID"] = EQUIP_SLOT_BACKUP_OFF , ["chargeable"] = false , ["Charge"] = -1 , ["maxCharge"] = -1 , ["pct"] = -1},
	}
	
	AHUD.Item.WeaponSet = 0
	
	AHUD.Item.Control = AHUD.Item:CreateControl()
	
	local fragment = ZO_SimpleSceneFragment:New(AHUD.Item.Control)
	local scene = SCENE_MANAGER:GetScene("hud")
	scene:AddFragment(fragment)
	
	AHUD.Item.init = 1
end

--Updates the Item HUD
function AHUD.Item:Update()
	if AHUD.Item.init == 1 then
	
		AHUD.Item.WeaponSet = GetActiveWeaponPairInfo()
	
		for i=1, #AHUD.Item.Armor,1 do
			AHUD.Item.Armor[i].Durability = GetItemCondition(0,AHUD.Item.Armor[i].ID)
		end
		
		for i=1, #AHUD.Item.Weapon,1 do
			if IsItemChargeable(0, AHUD.Item.Weapon[i].ID) then
				local itemLink = GetItemLink(0, AHUD.Item.Weapon[i].ID)
				AHUD.Item.Weapon[i].chargeable = IsItemChargeable(0, AHUD.Item.Weapon[i].ID)
				AHUD.Item.Weapon[i].Charge = GetItemLinkNumEnchantCharges(itemLink)
				AHUD.Item.Weapon[i].maxCharge = GetItemLinkMaxEnchantCharges(itemLink)
				AHUD.Item.Weapon[i].pct = ((AHUD.Item.Weapon[i].Charge / AHUD.Item.Weapon[i].maxCharge)*100)
			end
		end
		AHUD.Item:UpdateControl()
	end
end

--Updates the Icons every frame
function AHUD.Item:UpdateControl()
	
	AHUD.Item.Control.headtext:SetText(AHUD.Item.Armor[1].Durability .."%")
	AHUD.Item.Control.headtext:SetHidden(AHUD.Item.savedVariables.HideText)
	AHUD.Item.Control.chesttext:SetText(AHUD.Item.Armor[2].Durability .."%")
	AHUD.Item.Control.chesttext:SetHidden(AHUD.Item.savedVariables.HideText)
	AHUD.Item.Control.shouldertext:SetText(AHUD.Item.Armor[3].Durability .."%")
	AHUD.Item.Control.shouldertext:SetHidden(AHUD.Item.savedVariables.HideText)
	AHUD.Item.Control.waisttext:SetText(AHUD.Item.Armor[4].Durability .."%")
	AHUD.Item.Control.waisttext:SetHidden(AHUD.Item.savedVariables.HideText)
	AHUD.Item.Control.handstext:SetText(AHUD.Item.Armor[5].Durability .."%")
	AHUD.Item.Control.handstext:SetHidden(AHUD.Item.savedVariables.HideText)
	AHUD.Item.Control.legstext:SetText(AHUD.Item.Armor[6].Durability .."%")
	AHUD.Item.Control.legstext:SetHidden(AHUD.Item.savedVariables.HideText)
	AHUD.Item.Control.feettext:SetText(AHUD.Item.Armor[7].Durability .."%")
	AHUD.Item.Control.feettext:SetHidden(AHUD.Item.savedVariables.HideText)
	
	if AHUD.Item.Armor[1].Durability >= 75 then 
		AHUD.Item.Control.head:SetColor(unpack(AHUD.Item.savedVariables.ColorPerfect))
	elseif AHUD.Item.Armor[1].Durability < 75 and AHUD.Item.Armor[1].Durability >= 50 then
		AHUD.Item.Control.head:SetColor(unpack(AHUD.Item.savedVariables.ColorWell))
	elseif AHUD.Item.Armor[1].Durability < 50 and AHUD.Item.Armor[1].Durability >= 25 then
		AHUD.Item.Control.head:SetColor(unpack(AHUD.Item.savedVariables.ColorAcceptable))
	elseif AHUD.Item.Armor[1].Durability < 25 and AHUD.Item.Armor[1].Durability >= 1 then
		AHUD.Item.Control.head:SetColor(unpack(AHUD.Item.savedVariables.ColorBad))
	elseif AHUD.Item.Armor[1].Durability == 0 then
		AHUD.Item.Control.head:SetColor(unpack(AHUD.Item.savedVariables.ColorBrocken))
	end
	
	if AHUD.Item.Armor[2].Durability >= 75 then 
		AHUD.Item.Control.chest:SetColor(unpack(AHUD.Item.savedVariables.ColorPerfect))
	elseif AHUD.Item.Armor[2].Durability < 75 and AHUD.Item.Armor[2].Durability >= 50 then
		AHUD.Item.Control.chest:SetColor(unpack(AHUD.Item.savedVariables.ColorWell))
	elseif AHUD.Item.Armor[2].Durability < 50 and AHUD.Item.Armor[2].Durability >= 25 then
		AHUD.Item.Control.chest:SetColor(unpack(AHUD.Item.savedVariables.ColorAcceptable))
	elseif AHUD.Item.Armor[2].Durability < 25 and AHUD.Item.Armor[2].Durability >= 1 then
		AHUD.Item.Control.chest:SetColor(unpack(AHUD.Item.savedVariables.ColorBad))
	elseif AHUD.Item.Armor[2].Durability == 0 then
		AHUD.Item.Control.chest:SetColor(unpack(AHUD.Item.savedVariables.ColorBrocken))
	end 
	
	if AHUD.Item.Armor[3].Durability >= 75 then 
		AHUD.Item.Control.shoulder:SetColor(unpack(AHUD.Item.savedVariables.ColorPerfect))
	elseif AHUD.Item.Armor[3].Durability < 75 and AHUD.Item.Armor[3].Durability >= 50 then
		AHUD.Item.Control.shoulder:SetColor(unpack(AHUD.Item.savedVariables.ColorWell))
	elseif AHUD.Item.Armor[3].Durability < 50 and AHUD.Item.Armor[3].Durability >= 25 then
		AHUD.Item.Control.shoulder:SetColor(unpack(AHUD.Item.savedVariables.ColorAcceptable))
	elseif AHUD.Item.Armor[3].Durability < 25 and AHUD.Item.Armor[3].Durability >= 1 then
		AHUD.Item.Control.shoulder:SetColor(unpack(AHUD.Item.savedVariables.ColorBad))
	elseif AHUD.Item.Armor[3].Durability == 0 then
		AHUD.Item.Control.shoulder:SetColor(unpack(AHUD.Item.savedVariables.ColorBrocken))
	end
	
	if AHUD.Item.Armor[4].Durability >= 75 then 
		AHUD.Item.Control.waist:SetColor(unpack(AHUD.Item.savedVariables.ColorPerfect))
	elseif AHUD.Item.Armor[4].Durability < 75 and AHUD.Item.Armor[4].Durability >= 50 then
		AHUD.Item.Control.waist:SetColor(unpack(AHUD.Item.savedVariables.ColorWell))
	elseif AHUD.Item.Armor[4].Durability < 50 and AHUD.Item.Armor[4].Durability >= 25 then
		AHUD.Item.Control.waist:SetColor(unpack(AHUD.Item.savedVariables.ColorAcceptable))
	elseif AHUD.Item.Armor[4].Durability < 25 and AHUD.Item.Armor[4].Durability >= 1 then
		AHUD.Item.Control.waist:SetColor(unpack(AHUD.Item.savedVariables.ColorBad))
	elseif AHUD.Item.Armor[4].Durability == 0 then
		AHUD.Item.Control.waist:SetColor(unpack(AHUD.Item.savedVariables.ColorBrocken))
	end
	
	if AHUD.Item.Armor[5].Durability >= 75 then 
		AHUD.Item.Control.hands:SetColor(unpack(AHUD.Item.savedVariables.ColorPerfect))
	elseif AHUD.Item.Armor[5].Durability < 75 and AHUD.Item.Armor[5].Durability >= 50 then
		AHUD.Item.Control.hands:SetColor(unpack(AHUD.Item.savedVariables.ColorWell))
	elseif AHUD.Item.Armor[5].Durability < 50 and AHUD.Item.Armor[5].Durability >= 25 then
		AHUD.Item.Control.hands:SetColor(unpack(AHUD.Item.savedVariables.ColorAcceptable))
	elseif AHUD.Item.Armor[5].Durability < 25 and AHUD.Item.Armor[5].Durability >= 1 then
		AHUD.Item.Control.hands:SetColor(unpack(AHUD.Item.savedVariables.ColorBad))
	elseif AHUD.Item.Armor[5].Durability == 0 then
		AHUD.Item.Control.hands:SetColor(unpack(AHUD.Item.savedVariables.ColorBrocken))
	end
	
	if AHUD.Item.Armor[6].Durability >= 75 then 
		AHUD.Item.Control.legs:SetColor(unpack(AHUD.Item.savedVariables.ColorPerfect))
	elseif AHUD.Item.Armor[6].Durability < 75 and AHUD.Item.Armor[6].Durability >= 50 then
		AHUD.Item.Control.legs:SetColor(unpack(AHUD.Item.savedVariables.ColorWell))
	elseif AHUD.Item.Armor[6].Durability < 50 and AHUD.Item.Armor[6].Durability >= 25 then
		AHUD.Item.Control.legs:SetColor(unpack(AHUD.Item.savedVariables.ColorAcceptable))
	elseif AHUD.Item.Armor[6].Durability < 25 and AHUD.Item.Armor[6].Durability >= 1 then
		AHUD.Item.Control.legs:SetColor(unpack(AHUD.Item.savedVariables.ColorBad))
	elseif AHUD.Item.Armor[6].Durability == 0 then
		AHUD.Item.Control.legs:SetColor(unpack(AHUD.Item.savedVariables.ColorBrocken))
	end
	
	if AHUD.Item.Armor[7].Durability >= 75 then 
		AHUD.Item.Control.feet:SetColor(unpack(AHUD.Item.savedVariables.ColorPerfect))
	elseif AHUD.Item.Armor[7].Durability < 75 and AHUD.Item.Armor[7].Durability >= 50 then
		AHUD.Item.Control.feet:SetColor(unpack(AHUD.Item.savedVariables.ColorWell))
	elseif AHUD.Item.Armor[7].Durability < 50 and AHUD.Item.Armor[7].Durability >= 25 then
		AHUD.Item.Control.feet:SetColor(unpack(AHUD.Item.savedVariables.ColorAcceptable))
	elseif AHUD.Item.Armor[7].Durability < 25 and AHUD.Item.Armor[7].Durability >=1 then
		AHUD.Item.Control.feet:SetColor(unpack(AHUD.Item.savedVariables.ColorBad))
	elseif AHUD.Item.Armor[7].Durability == 0 then
		AHUD.Item.Control.feet:SetColor(unpack(AHUD.Item.savedVariables.ColorBrocken))
	end
	
	if AHUD.Item.WeaponSet ~= 0 then
		if AHUD.Item.WeaponSet == 1 then
			if AHUD.Item.Weapon[1].chargeable then
				if AHUD.Item.Weapon[1].pct >= 75 then
					AHUD.Item.Control.main:SetColor(unpack(AHUD.Item.savedVariables.ColorPerfect))
				elseif AHUD.Item.Weapon[1].pct < 75 and AHUD.Item.Weapon[1].pct >= 50 then
					AHUD.Item.Control.main:SetColor(unpack(AHUD.Item.savedVariables.ColorWell))
				elseif AHUD.Item.Weapon[1].pct < 50 and AHUD.Item.Weapon[1].pct >= 25 then
					AHUD.Item.Control.main:SetColor(unpack(AHUD.Item.savedVariables.ColorAcceptable))
				elseif AHUD.Item.Weapon[1].pct < 25 and AHUD.Item.Weapon[1].pct >=1 then
					AHUD.Item.Control.main:SetColor(unpack(AHUD.Item.savedVariables.ColorBad))
				elseif AHUD.Item.Weapon[1].pct == 0 then
					AHUD.Item.Control.main:SetColor(unpack(AHUD.Item.savedVariables.ColorBrocken))
				end
				AHUD.Item.Control.maintext:SetText(AHUD.Item.Weapon[1].pct .."%")
				AHUD.Item.Control.maintext:SetHidden(AHUD.Item.savedVariables.HideText)
				AHUD.Item.Control.main:SetHidden(false)
			else
				AHUD.Item.Control.main:SetHidden(true)
				AHUD.Item.Control.maintext:SetHidden(true)
			end
				
			if AHUD.Item.Weapon[2].chargeable then
				if AHUD.Item.Weapon[2].pct >= 75 then
					AHUD.Item.Control.off:SetColor(unpack(AHUD.Item.savedVariables.ColorPerfect))
				elseif AHUD.Item.Weapon[2].pct < 75 and AHUD.Item.Weapon[2].pct >= 50 then
					AHUD.Item.Control.off:SetColor(unpack(AHUD.Item.savedVariables.ColorWell))
				elseif AHUD.Item.Weapon[2].pct < 50 and AHUD.Item.Weapon[2].pct >= 25 then
					AHUD.Item.Control.off:SetColor(unpack(AHUD.Item.savedVariables.ColorAcceptable))
				elseif AHUD.Item.Weapon[2].pct < 25 and AHUD.Item.Weapon[2].pct >=1 then
					AHUD.Item.Control.off:SetColor(unpack(AHUD.Item.savedVariables.ColorBad))
				elseif AHUD.Item.Weapon[2].pct == 0 then
					AHUD.Item.Control.off:SetColor(unpack(AHUD.Item.savedVariables.ColorBrocken))
				end
				AHUD.Item.Control.offtext:SetText(AHUD.Item.Weapon[2].pct .."%")
				AHUD.Item.Control.offtext:SetHidden(AHUD.Item.savedVariables.HideText)
				AHUD.Item.Control.off:SetHidden(false)
			else
				AHUD.Item.Control.off:SetHidden(true)
				AHUD.Item.Control.offtext:SetHidden(true)
			end
		else
			if AHUD.Item.Weapon[3].chargeable then
				if AHUD.Item.Weapon[3].pct >= 75 then
					AHUD.Item.Control.main:SetColor(unpack(AHUD.Item.savedVariables.ColorPerfect))
				elseif AHUD.Item.Weapon[3].pct < 75 and AHUD.Item.Weapon[3].pct >= 50 then
					AHUD.Item.Control.main:SetColor(unpack(AHUD.Item.savedVariables.ColorWell))
				elseif AHUD.Item.Weapon[3].pct < 50 and AHUD.Item.Weapon[3].pct >= 25 then
					AHUD.Item.Control.main:SetColor(unpack(AHUD.Item.savedVariables.ColorAcceptable))
				elseif AHUD.Item.Weapon[3].pct < 25 and AHUD.Item.Weapon[3].pct >=1 then
					AHUD.Item.Control.main:SetColor(unpack(AHUD.Item.savedVariables.ColorBad))
				elseif AHUD.Item.Weapon[3].pct == 0 then
					AHUD.Item.Control.main:SetColor(unpack(AHUD.Item.savedVariables.ColorBrocken))
				end
				AHUD.Item.Control.maintext:SetText(AHUD.Item.Weapon[3].pct .."%")
				AHUD.Item.Control.maintext:SetHidden(AHUD.Item.savedVariables.HideText)
				AHUD.Item.Control.main:SetHidden(false)
			else
				AHUD.Item.Control.main:SetHidden(true)
				AHUD.Item.Control.maintext:SetHidden(true)
			end
				
			if AHUD.Item.Weapon[4].chargeable then
				if AHUD.Item.Weapon[4].pct >= 75 then
					AHUD.Item.Control.off:SetColor(unpack(AHUD.Item.savedVariables.ColorPerfect))
				elseif AHUD.Item.Weapon[4].pct < 75 and AHUD.Item.Weapon[4].pct >= 50 then
					AHUD.Item.Control.off:SetColor(unpack(AHUD.Item.savedVariables.ColorWell))
				elseif AHUD.Item.Weapon[4].pct < 50 and AHUD.Item.Weapon[4].pct >= 25 then
					AHUD.Item.Control.off:SetColor(unpack(AHUD.Item.savedVariables.ColorAcceptable))
				elseif AHUD.Item.Weapon[4].pct < 25 and AHUD.Item.Weapon[4].pct >=1 then
					AHUD.Item.Control.off:SetColor(unpack(AHUD.Item.savedVariables.ColorBad))
				elseif AHUD.Item.Weapon[4].pct == 0 then
					AHUD.Item.Control.off:SetColor(unpack(AHUD.Item.savedVariables.ColorBrocken))
				end
				AHUD.Item.Control.offtext:SetText(AHUD.Item.Weapon[4].pct .."%")
				AHUD.Item.Control.offtext:SetHidden(AHUD.Item.savedVariables.HideText)
				AHUD.Item.Control.off:SetHidden(false)
			else
				AHUD.Item.Control.off:SetHidden(true)
				AHUD.Item.Control.offtext:SetHidden(true)
			end
		end
	end
end

--Creates the Control Window
function AHUD.Item:CreateControl()

	local c = wm:CreateTopLevelWindow("AHUDControls")
    c:SetDimensions((AHUD.Item.savedVariables.IconSize * 4), (AHUD.Item.savedVariables.IconSize * 3))
    c:SetAnchor(TOPLEFT,GuiRoot,TOPLEFT,AHUD.Item.savedVariables.OffsetX,AHUD.Item.savedVariables.OffsetY)
    c:SetHidden(AHUD.Item.savedVariables.Hiden)
    c:SetMovable(true)
    c:SetMouseEnabled(true)
    c:SetClampedToScreen(true)
    c:SetHandler("OnReceiveDrag", function(self) self:StartMoving() end)
    c:SetHandler("OnMouseUp", function(self) self:StopMovingOrResizing() end)
	c:SetHandler("OnMoveStop", function() AHUD.Item:SaveLoc() end)

    --background
    c.bg = wm:CreateControlFromVirtual("AHUDControls" .."_BG", c, "ZO_InsetTexture")
    c.bg:SetAnchorFill(c)

    --Head Icon
	c.head = wm:CreateControl("AHUDControls".."_HEAD", c, CT_TEXTURE)
    c.head:SetTexture("esoui/art/characterwindow/gearslot_head.dds")
	c.head:SetColor(1,1,1,1)
    c.head:SetDimensions(AHUD.Item.savedVariables.IconSize,AHUD.Item.savedVariables.IconSize)	
    c.head:SetAnchor(TOP,c,TOP,0,0)
	
	--Head Text
	c.headtext = wm:CreateControl("AHUDControls" .. "_HEADText", c, CT_LABEL)
	c.headtext:SetFont("ZoFontGame")
	c.headtext:SetColor(1,1,1,1)
	c.headtext:SetScale(0.6)
	c.headtext:SetWrapMode(TEX_MODE_CLAMP)
	c.headtext:SetDrawLayer(1)
	c.headtext:SetText("")
	c.headtext:SetDimensions(AHUD.Item.savedVariables.IconSize,AHUD.Item.savedVariables.IconSize)
	c.headtext:SetAnchor(TOP,c,TOP,0,(AHUD.Item.savedVariables.IconSize / 2))
	
	--Shoulder Icon
	c.shoulder = wm:CreateControl("AHUDControls".."_SHOULDER", c, CT_TEXTURE)
    c.shoulder:SetTexture("esoui/art/characterwindow/gearslot_shoulders.dds")
	c.shoulder:SetColor(1,1,1,1)
    c.shoulder:SetDimensions(AHUD.Item.savedVariables.IconSize,AHUD.Item.savedVariables.IconSize)
    c.shoulder:SetAnchor(TOP,c,TOP,-AHUD.Item.savedVariables.IconSize,AHUD.Item.savedVariables.IconSize)
	
	--Shoulder Text
	c.shouldertext = wm:CreateControl("AHUDControls" .. "__SHOULDERText", c, CT_LABEL)
	c.shouldertext:SetFont("ZoFontGame")
	c.shouldertext:SetColor(1,1,1,1)
	c.shouldertext:SetScale(0.6)
	c.shouldertext:SetWrapMode(TEX_MODE_CLAMP)
	c.shouldertext:SetDrawLayer(1)
	c.shouldertext:SetText("")
	c.shouldertext:SetDimensions(AHUD.Item.savedVariables.IconSize,AHUD.Item.savedVariables.IconSize)
	c.shouldertext:SetAnchor(TOP,c,TOP,-AHUD.Item.savedVariables.IconSize,(AHUD.Item.savedVariables.IconSize * 1.5))
	
	--Chest Icon
    c.chest = wm:CreateControl("AHUDControls".."_CHEST", c, CT_TEXTURE)
    c.chest:SetTexture("esoui/art/characterwindow/gearslot_chest.dds")
	c.chest:SetColor(1,1,1,1)
    c.chest:SetDimensions(AHUD.Item.savedVariables.IconSize,AHUD.Item.savedVariables.IconSize)
    c.chest:SetAnchor(TOP,c,TOP,0,AHUD.Item.savedVariables.IconSize)
	
	--Chest Text
	c.chesttext = wm:CreateControl("AHUDControls" .. "__CHESTText", c, CT_LABEL)
	c.chesttext:SetFont("ZoFontGame")
	c.chesttext:SetColor(1,1,1,1)
	c.chesttext:SetScale(0.6)
	c.chesttext:SetWrapMode(TEX_MODE_CLAMP)
	c.chesttext:SetDrawLayer(1)
	c.chesttext:SetText("")
	c.chesttext:SetDimensions(AHUD.Item.savedVariables.IconSize,AHUD.Item.savedVariables.IconSize)
	c.chesttext:SetAnchor(TOP,c,TOP,0,( AHUD.Item.savedVariables.IconSize * 1.5))
	
	--Hands Icon
	c.hands = wm:CreateControl("AHUDControls".."_HANDS", c, CT_TEXTURE)
    c.hands:SetTexture("esoui/art/characterwindow/gearslot_hands.dds")
	c.hands:SetColor(1,1,1,1)
    c.hands:SetDimensions(AHUD.Item.savedVariables.IconSize,AHUD.Item.savedVariables.IconSize)
    c.hands:SetAnchor(TOP,c,TOP,AHUD.Item.savedVariables.IconSize,AHUD.Item.savedVariables.IconSize)
	
	--Hands Text
	c.handstext = wm:CreateControl("AHUDControls" .. "__HANDSText", c, CT_LABEL)
	c.handstext:SetFont("ZoFontGame")
	c.handstext:SetColor(1,1,1,1)
	c.handstext:SetScale(0.6)
	c.handstext:SetWrapMode(TEX_MODE_CLAMP)
	c.handstext:SetDrawLayer(1)
	c.handstext:SetText("")
	c.handstext:SetDimensions(AHUD.Item.savedVariables.IconSize,AHUD.Item.savedVariables.IconSize)
	c.handstext:SetAnchor(TOP,c,TOP,AHUD.Item.savedVariables.IconSize,(AHUD.Item.savedVariables.IconSize * 1.5))
	
	--Waist Icon
	c.waist = wm:CreateControl("AHUDControls".."_WAIST", c, CT_TEXTURE)
    c.waist:SetTexture("esoui/art/characterwindow/gearslot_belt.dds")
	c.waist:SetColor(1,1,1,1)
    c.waist:SetDimensions(AHUD.Item.savedVariables.IconSize,AHUD.Item.savedVariables.IconSize)
    c.waist:SetAnchor(TOP,c,TOP,AHUD.Item.savedVariables.IconSize,(AHUD.Item.savedVariables.IconSize*2))
	
	--Waist Text
	c.waisttext = wm:CreateControl("AHUDControls" .. "__WAISTText", c, CT_LABEL)
	c.waisttext:SetFont("ZoFontGame")
	c.waisttext:SetColor(1,1,1,1)
	c.waisttext:SetScale(0.6)
	c.waisttext:SetWrapMode(TEX_MODE_CLAMP)
	c.waisttext:SetDrawLayer(1)
	c.waisttext:SetText("")
	c.waisttext:SetDimensions(AHUD.Item.savedVariables.IconSize,AHUD.Item.savedVariables.IconSize)
	c.waisttext:SetAnchor(TOP,c,TOP,AHUD.Item.savedVariables.IconSize,(AHUD.Item.savedVariables.IconSize * 2.5))
	
    --Legs Icon
	c.legs = wm:CreateControl("AHUDControls".."_LEGS", c, CT_TEXTURE)
    c.legs:SetTexture("esoui/art/characterwindow/gearslot_legs.dds")
	c.legs:SetColor(1,1,1,1)
    c.legs:SetDimensions(AHUD.Item.savedVariables.IconSize,AHUD.Item.savedVariables.IconSize)
    c.legs:SetAnchor(TOP,c,TOP,0,(AHUD.Item.savedVariables.IconSize * 2))
	
	--Legs Text
	c.legstext = wm:CreateControl("AHUDControls" .. "__LEGSText", c, CT_LABEL)
	c.legstext:SetFont("ZoFontGame")
	c.legstext:SetColor(1,1,1,1)
	c.legstext:SetScale(0.6)
	c.legstext:SetWrapMode(TEX_MODE_CLAMP)
	c.legstext:SetDrawLayer(1)
	c.legstext:SetText("100%")
	c.legstext:SetDimensions(AHUD.Item.savedVariables.IconSize,AHUD.Item.savedVariables.IconSize)
	c.legstext:SetAnchor(TOP,c,TOP,0,(AHUD.Item.savedVariables.IconSize * 2.5))
	
	--Feet Icon
	c.feet = wm:CreateControl("AHUDControls".."_FEET", c, CT_TEXTURE)
    c.feet:SetTexture("esoui/art/characterwindow/gearslot_feet.dds")
	c.feet:SetColor(1,1,1,1)
    c.feet:SetDimensions(AHUD.Item.savedVariables.IconSize,AHUD.Item.savedVariables.IconSize)
    c.feet:SetAnchor(TOP,c,TOP,-AHUD.Item.savedVariables.IconSize,(AHUD.Item.savedVariables.IconSize * 2))

	--Feet Text
	c.feettext = wm:CreateControl("AHUDControls" .. "__FEETText", c, CT_LABEL)
	c.feettext:SetFont("ZoFontGame")
	c.feettext:SetColor(1,1,1,1)
	c.feettext:SetScale(0.6)
	c.feettext:SetWrapMode(TEX_MODE_CLAMP)
	c.feettext:SetDrawLayer(1)
	c.feettext:SetText("")
	c.feettext:SetDimensions(AHUD.Item.savedVariables.IconSize,AHUD.Item.savedVariables.IconSize)
	c.feettext:SetAnchor(TOP,c,TOP,-AHUD.Item.savedVariables.IconSize,(AHUD.Item.savedVariables.IconSize * 2.5))
	
	--Main-Hand Icon
	c.main = wm:CreateControl("AHUDControls".."_MAIN", c, CT_TEXTURE)
    c.main:SetTexture("esoui/art/characterwindow/gearslot_mainhand.dds")
	c.main:SetColor(1,1,1,1)
    c.main:SetDimensions(AHUD.Item.savedVariables.IconSize,AHUD.Item.savedVariables.IconSize)
    c.main:SetAnchor(TOP,c,TOP,-AHUD.Item.savedVariables.IconSize,0)
	c.main:SetHidden(false)
	
	--Main-Hand Text
	c.maintext = wm:CreateControl("AHUDControls" .. "__MainText", c, CT_LABEL)
	c.maintext:SetFont("ZoFontGame")
	c.maintext:SetColor(1,1,1,1)
	c.maintext:SetScale(0.6)
	c.maintext:SetWrapMode(TEX_MODE_CLAMP)
	c.maintext:SetDrawLayer(1)
	c.maintext:SetText("")
	c.maintext:SetDimensions(AHUD.Item.savedVariables.IconSize,AHUD.Item.savedVariables.IconSize)
	c.maintext:SetAnchor(TOP,c,TOP,-AHUD.Item.savedVariables.IconSize,(AHUD.Item.savedVariables.IconSize / 2))
	
	--Off-Hand Icon
	c.off = wm:CreateControl("AHUDControls".."_OFF", c, CT_TEXTURE)
    c.off:SetTexture("esoui/art/characterwindow/gearslot_offhand.dds")
	c.off:SetColor(1,1,1,1)
    c.off:SetDimensions(AHUD.Item.savedVariables.IconSize,AHUD.Item.savedVariables.IconSize)
    c.off:SetAnchor(TOP,c,TOP,AHUD.Item.savedVariables.IconSize,0)
	c.off:SetHidden(false)
	
	--Off-Hand Text
	c.offtext = wm:CreateControl("AHUDControls" .. "__OFFText", c, CT_LABEL)
	c.offtext:SetFont("ZoFontGame")
	c.offtext:SetColor(1,1,1,1)
	c.offtext:SetScale(0.6)
	c.offtext:SetWrapMode(TEX_MODE_CLAMP)
	c.offtext:SetDrawLayer(1)
	c.offtext:SetText("")
	c.offtext:SetDimensions(AHUD.Item.savedVariables.IconSize,AHUD.Item.savedVariables.IconSize)
	c.offtext:SetAnchor(TOP,c,TOP,AHUD.Item.savedVariables.IconSize,(AHUD.Item.savedVariables.IconSize / 2))
	
    return c
  end
  
--Saves the location of the Window
function AHUD.Item:SaveLoc()
		AHUD.Item.savedVariables.OffsetX = AHUD.Item.Control:GetLeft()
		AHUD.Item.savedVariables.OffsetY = AHUD.Item.Control:GetTop()
end