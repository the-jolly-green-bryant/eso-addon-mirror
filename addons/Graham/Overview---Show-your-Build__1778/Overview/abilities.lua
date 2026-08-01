local ov = GlByGrhmForOverview

local win = "abilities"
ov.ctrl.subHeader[win] = {}
ov.ctrl.control[win] = {}

local ctrl = {}
ctrl.name = {}
ctrl.info = {}
ctrl.texture = {}
ctrl.textureBox = {}
 
function ov.createAbilities()

	ov.createSubheader("bar1" ,win , TOPLEFT, TOPLEFT, 5, 35, GetString(SI_KEYBINDINGS_PRIMARY))
	ov.backdrop("bar1", win, 280, 290, 0, 30)
	ov.createSubheader("bar2", win , TOPLEFT, TOPLEFT, 290, 35, GetString(SI_KEYBINDINGS_SECONDARY))
	ov.backdrop("bar2", win, 280, 290, 285, 30)
	
	ov.ctrl.activeBar1 = ov.ctrl.wm:CreateControl(string.format("OverviewActiveBar1-%s", win), ov.ctrl.tlw[win], CT_LABEL )
	ov.ctrl.activeBar1:SetAnchor(TOPRIGHT, ov.ctrl.control[win]["bar1"], TORIGHT, 0, 8)
	ov.ctrl.activeBar1:SetDimensions(50, 25)
	ov.ctrl.activeBar1:SetFont(ov.font.subElement)
	ov.ctrl.activeBar1:SetColor(ov.getColor("white"))
	ov.ctrl.activeBar1:SetWrapMode(ELLIPSIS)
	ov.ctrl.activeBar1:SetText(GetString(SI_INVENTORY_SORT_TYPE_ACTIVE))
	
	ov.ctrl.activeBar2 = ov.ctrl.wm:CreateControl(string.format("OverviewActiveBar2-%s", win), ov.ctrl.tlw[win], CT_LABEL )
	ov.ctrl.activeBar2:SetAnchor(TOPRIGHT, ov.ctrl.control[win]["bar2"], TORIGHT, 0, 8)
	ov.ctrl.activeBar2:SetDimensions(50, 25)
	ov.ctrl.activeBar2:SetFont(ov.font.subElement)
	ov.ctrl.activeBar2:SetColor(ov.getColor("white"))
	ov.ctrl.activeBar2:SetWrapMode(ELLIPSIS)
	ov.ctrl.activeBar2:SetText(GetString(SI_INVENTORY_SORT_TYPE_ACTIVE))

	local bar = "bar1"
	local spacerY = 0
				
	for i = 1, 12 do
	
		ctrl.texture[i] = ov.ctrl.wm:CreateControl(string.format("OverviewTexture%d-%s", i, win), ov.ctrl.tlw[win], CT_TEXTURE )
		ctrl.texture[i]:SetAnchor(TOPLEFT, ov.ctrl.control[win][bar], TOPLEFT, 5 , 35 + spacerY ) 
		ctrl.texture[i]:SetDimensions( 38, 38)
		ctrl.texture[i]:SetTexture("/esoui/art/actionbar/abilityframe64_up.dds")
	
		ctrl.name[i] = ov.ctrl.wm:CreateControl(string.format("OverviewName%d-%s", i, win), ov.ctrl.tlw[win], CT_LABEL )
		ctrl.name[i]:SetAnchor(TOPLEFT, ctrl.texture[i], TOPLEFT, 40, 0)
		ctrl.name[i]:SetFont(ov.font.element)
		ctrl.name[i]:SetDimensions( 230, 8)
		ctrl.name[i]:SetWrapMode(ELLIPSIS)
		ctrl.name[i]:SetColor(ov.getColor("gold"))
		
		ctrl.info[i] = ov.ctrl.wm:CreateControl(string.format("OverviewInfo%d-%s", i, win), ov.ctrl.tlw[win], CT_LABEL )
		ctrl.info[i]:SetAnchor(TOPLEFT, ctrl.name[i], TOPLEFT, 0, 20)
		ctrl.info[i]:SetFont(ov.font.subElement)
		ctrl.info[i]:SetWrapMode(ELLIPSIS)
		ctrl.info[i]:SetColor(ov.getColor("white"))
		ctrl.info[i]:SetText("---")
		
		ctrl.textureBox[i] = ov.ctrl.wm:CreateControl(string.format("OverviewTexturesBox%d-%s", i, win), ov.ctrl.tlw[win], CT_TEXTURE)
		ctrl.textureBox[i]:SetAnchor(TOPLEFT, ctrl.texture[i], TOPLEFT) 
		ctrl.textureBox[i]:SetDimensions( 38, 38)
		ctrl.textureBox[i]:SetTexture("/esoui/art/actionbar/abilityframe64_up.dds")
		ctrl.textureBox[i]:SetDrawLayer(1)
		
		spacerY = spacerY + 40
		if i == 5 then 
			spacerY = spacerY + 15 
		end
		if i == 6 then 
			bar = "bar2"
			spacerY = 0
		end
		
		if i == 11 then 
			spacerY = spacerY + 15 
		end
	end
end

local avtivePair = 0 
local abilityCost = 0
local mechanicType = 0

function ov.abilitiesFill()
	avtivePair = GetActiveWeaponPairInfo()
	
	if avtivePair == 1 then 
		ov.ctrl.activePair1:SetHidden(false)
		ov.ctrl.activePair2:SetHidden(true)
		ov.ctrl.activeBar1:SetHidden(false)
		ov.ctrl.activeBar2:SetHidden(true)
	elseif avtivePair == 2 then 
		ov.ctrl.activePair1:SetHidden(true)
		ov.ctrl.activePair2:SetHidden(false)
		ov.ctrl.activeBar1:SetHidden(true)
		ov.ctrl.activeBar2:SetHidden(false)
	end
	
	local avtivePair = 0 
	
	local hotbar = HOTBAR_CATEGORY_PRIMARY
	local swap = 0
	local slot = 0
	local color = "grey"
	local combatType = "..."
		
	for i = 1, 12 do
		slot = 2 + i - swap
		abilityCost, mechanicType = GetAbilityCost(GetSlotBoundId(slot, hotbar))
		-- GetAbilityCost(GetSlotBoundId(slot, hotbar))
		if GetAbilityName(GetSlotBoundId(slot, hotbar)) ~= "" then 
			ctrl.name[i]:SetText(zo_strformat("<<C:1>>", GetAbilityName(GetSlotBoundId(slot, hotbar))))
			ctrl.texture[i]:SetTexture(GetAbilityIcon(GetSlotBoundId(slot, hotbar)))
			ctrl.texture[i]:SetHidden(false)
			if mechanicType == POWERTYPE_HEALTH then
				combatType = SI_COMBATMECHANICTYPE_2
				color = "life"	
			elseif mechanicType == POWERTYPE_MAGICKA then
				color = "magicka"
				combatType = SI_COMBATMECHANICTYPE0
			elseif mechanicType == POWERTYPE_STAMINA then
				color = "endurance"
				combatType = SI_COMBATMECHANICTYPE6
			elseif mechanicType == POWERTYPE_ULTIMATE then
				color = "white"
				combatType = SI_COMBATMECHANICTYPE10
			else
				color = "grey"
				combatType = "..."
			end
			ctrl.info[i]:SetText(string.format("%d %s", abilityCost, GetString(combatType)))
			ctrl.info[i]:SetColor(ov.getColor(color))
		else
			ctrl.name[i]:SetText("---")
			ctrl.info[i]:SetText("---")
			ctrl.info[i]:SetColor(ov.getColor("white"))
			ctrl.texture[i]:SetTexture(nil)
			ctrl.texture[i]:SetHidden(true)
		end
		if i == 6 then 
			hotbar = HOTBAR_CATEGORY_BACKUP
			swap = 6
		end
	end
end