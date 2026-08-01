BSCAHPotions = BSCAHPotions or {}
local BSCAHP = BSCAHPotions

local optionsTable = {}
function BSCAHP:GetItemLinkInfo(ItemLink)
	if ItemLink == nil or ItemLink == "  " then return end
	local description = " "
	local count = 0	
	local Icon = "/esoui/art/icons/icon_missing.dds"
	if IsItemLinkConsumable(ItemLink) then
		Icon = GetItemLinkIcon(ItemLink)
		local hasAbility, abilityHeader, abilityDescription, cooldown, hasScaling, minLevel, maxLevel, isChampionPoints, remainingCooldown = GetItemLinkOnUseAbilityInfo(ItemLink) 
		if hasAbility then
			description = abilityDescription
		end	
		for i = 1, GetMaxTraits() do
			local hasAbility, abilityDescription, cooldown, hasScaling, minLevel, maxLevel, isChampionPoints = GetItemLinkTraitOnUseAbilityInfo(ItemLink, i)
			if hasAbility then
				if i == 1 then
					description = abilityDescription
				else
					description = description.." "..abilityDescription
				end
			end
		end
		if IsItemLinkStackable(ItemLink) then
			count = GetItemLinkStacks(ItemLink)
		else
			count = 1
		end
	else
		if GetLinkType(ItemLink) == LINK_TYPE_COLLECTIBLE then			
			local collectibleId = GetCollectibleIdFromLink(ItemLink)			
			description = GetCollectibleDescription(collectibleId) 
			count = 1
			Icon = GetCollectibleIcon(collectibleId) 
		end	
	end	
	return description, count, Icon
end
local function AddSendFeedBack()
    table.insert(optionsTable, {
        type = "button",
        name = "Donate",
        tooltip = "Main - EU Server",
        func = function()
              local function PrefillMail()
                ZO_MailSendToField:SetText(BSCAHP.Author)
                ZO_MailSendSubjectField:SetText(BSCAHP.NameMenu)
                ZO_MailSendBodyField:TakeFocus()
              end
                SCENE_MANAGER:Show('mailSend')
                zo_callLater(PrefillMail, 250)
        end,
        width = "half",
    })
end
local function AddTexture(control, strIcon, strDesciption, ref)
	table.insert(control, {
        type = "texture",
        image =  strIcon,
		tooltip = strDesciption,			
        imageWidth = 32,
        imageHeight = 32,
        width = "half",		
		reference = "BSCAHP_TEXTURE_"..ref,
	})
end
local function AddDescription(control, strDesciption, ref)
	table.insert(control, {
		type = "description",	
        text = strDesciption,
        width = "half",
		reference = "BSCAHP_DESCR_"..ref,
	})	
end
local function AddDescriptionFULL(control, strDesciption, ref)
	table.insert(control, {
		type = "description",	
        text = strDesciption,
		reference = "BSCAHP_DESCR_I_"..ref,
	})	
end
local function AddDivider(control)
	table.insert(control, {
		type = "divider",
	})
end
local function UpdateMenuSettings()	
	local description, count, Icon = BSCAHP:GetItemLinkInfo(BSCAHP.SLOTTED_POTS[1])
	BSCAHP_TEXTURE_1.texture:SetTexture(Icon)
	BSCAHP_DESCR_1.data.text = zo_strformat("1 [<<1>>] (<<2>>)", BSCAHP.SLOTTED_POTS[1], count)
	BSCAHP_DESCR_1:UpdateValue()
	BSCAHP_DESCR_I_1.data.text = description
	BSCAHP_DESCR_I_1:UpdateValue()
	
	description, count, Icon = BSCAHP:GetItemLinkInfo(BSCAHP.SLOTTED_POTS[2])
	BSCAHP_TEXTURE_2.texture:SetTexture(Icon)
	BSCAHP_DESCR_2.data.text = zo_strformat("2 [<<1>>] (<<2>>)", BSCAHP.SLOTTED_POTS[2], count)
	BSCAHP_DESCR_2:UpdateValue()
	BSCAHP_DESCR_I_2.data.text = description
	BSCAHP_DESCR_I_2:UpdateValue()
		
	description, count, Icon = BSCAHP:GetItemLinkInfo(BSCAHP.SLOTTED_POTS[3])
	BSCAHP_TEXTURE_3.texture:SetTexture(Icon)
	BSCAHP_DESCR_3.data.text = zo_strformat("3 [<<1>>] (<<2>>)", BSCAHP.SLOTTED_POTS[3], count)
	BSCAHP_DESCR_3:UpdateValue()
	BSCAHP_DESCR_I_3.data.text = description
	BSCAHP_DESCR_I_3:UpdateValue()

	description, count, Icon = BSCAHP:GetItemLinkInfo(BSCAHP.SLOTTED_POTS[4])
	BSCAHP_TEXTURE_4.texture:SetTexture(Icon)
	BSCAHP_DESCR_4.data.text = zo_strformat("4 [<<1>>] (<<2>>)", BSCAHP.SLOTTED_POTS[4], count)
	BSCAHP_DESCR_4:UpdateValue()
	BSCAHP_DESCR_I_4.data.text = description
	BSCAHP_DESCR_I_4:UpdateValue()

	description, count, Icon = BSCAHP:GetItemLinkInfo(BSCAHP.SLOTTED_POTS[5])
	BSCAHP_TEXTURE_5.texture:SetTexture(Icon)
	BSCAHP_DESCR_5.data.text = zo_strformat("5 [<<1>>] (<<2>>)", BSCAHP.SLOTTED_POTS[5], count)
	BSCAHP_DESCR_5:UpdateValue()
	BSCAHP_DESCR_I_5.data.text = description
	BSCAHP_DESCR_I_5:UpdateValue()

	description, count, Icon = BSCAHP:GetItemLinkInfo(BSCAHP.SLOTTED_POTS[6])
	BSCAHP_TEXTURE_6.texture:SetTexture(Icon)
	BSCAHP_DESCR_6.data.text = zo_strformat("6 [<<1>>] (<<2>>)", BSCAHP.SLOTTED_POTS[6], count)
	BSCAHP_DESCR_6:UpdateValue()
	BSCAHP_DESCR_I_6.data.text = description
	BSCAHP_DESCR_I_6:UpdateValue()

	description, count, Icon = BSCAHP:GetItemLinkInfo(BSCAHP.SLOTTED_POTS[7])
	BSCAHP_TEXTURE_7.texture:SetTexture(Icon)
	BSCAHP_DESCR_7.data.text = zo_strformat("7 [<<1>>] (<<2>>)", BSCAHP.SLOTTED_POTS[7], count)
	BSCAHP_DESCR_7:UpdateValue()
	BSCAHP_DESCR_I_7.data.text = description
	BSCAHP_DESCR_I_7:UpdateValue()

	description, count, Icon = BSCAHP:GetItemLinkInfo(BSCAHP.SLOTTED_POTS[8])
	BSCAHP_TEXTURE_8.texture:SetTexture(Icon)
	BSCAHP_DESCR_8.data.text = zo_strformat("8 [<<1>>] (<<2>>)", BSCAHP.SLOTTED_POTS[8], count)
	BSCAHP_DESCR_8:UpdateValue()
	BSCAHP_DESCR_I_8.data.text = description
	BSCAHP_DESCR_I_8:UpdateValue()
end
local function AddSlotedItems()
	table.insert(optionsTable, {
        type = "header",
        name = "Sloted Items",
    })		
	for i = 1, 8 do
		local itemLink = BSCAHP.SLOTTED_POTS[i]
		local stack = GetItemLinkStacks(itemLink)				
		AddDescription(optionsTable, zo_strformat("<<1>> <<2>>", itemLink, stack), i)
		AddTexture(optionsTable, GetItemLinkIcon(itemLink), "", i)
		AddDescriptionFULL(optionsTable, BSCAHP:GetItemLinkInfo(itemLink), i)		
		if i < 8 then AddDivider(optionsTable) end
	end
end
local function AddBuffGain(control, ref)
	table.insert(control, {
		type = "editbox",
		name = ref.." - Buff GainID",
		getFunc = function() return BSCAHP.SV.BUFF_GAIN_LIST[ref] end,		
        setFunc = function(value) 
			if value == nil then 
				value = 0 
			end 
			BSCAHP.SV.BUFF_GAIN_LIST[ref] = value	
			BSCAHP:UpdateSkillSlotIDS()
		end,
		width = "half",
		textType = TEXT_TYPE_NUMERIC,
		reference = "BSCAHP_EB_G_"..ref,
	})
	table.insert(optionsTable, {
		type = 'dropdown',
		name = "Potion",
		choices = BSCAHP.SLOTTED_POTS,
		choicesTooltips = BSCAHP.SLOTTED_POTS_TOOLTIP,
		getFunc = function() return BSCAHP.SV.POTION_GAIN_LIST[ref] end,
		setFunc = function(value)
			if value == "" then value = "Not In Use" end
			BSCAHP.SV.POTION_GAIN_LIST[ref] = value
			BSCAHP:UpdateSkillSlotIDS()
		end,
		scrollable = 9,
        width = "half",
		reference = "BSCAHP_DD_G_"..ref,
	})
end
local function AddBuffFade(control, ref)
	table.insert(control, {
		type = "editbox",
		name = ref.." - Buff FadeID",
		getFunc = function() return BSCAHP.SV.BUFF_FADE_LIST[ref] end,		
        setFunc = function(value) 
			if value == nil then 
				value = 0 
			end 
			BSCAHP.SV.BUFF_FADE_LIST[ref] = value
			BSCAHP:UpdateSkillSlotIDS()			
		end,
		width = "half",
		textType = TEXT_TYPE_NUMERIC,
		reference = "BSCAHP_EB_F_"..ref,
	})
	table.insert(optionsTable, {
		type = 'dropdown',
		name = "Potion",
		choices = BSCAHP.SLOTTED_POTS,
		choicesTooltips = BSCAHP.SLOTTED_POTS_TOOLTIP,
		getFunc = function() return BSCAHP.SV.POTION_FADE_LIST[ref] end,
		setFunc = function(value)
			if value == "" then value = "Not In Use" end
			BSCAHP.SV.POTION_FADE_LIST[ref] = value
			BSCAHP:UpdateSkillSlotIDS()
		end,
		scrollable = 9,
        width = "half",
		reference = "BSCAHP_DD_F_"..ref,
	})
end
local function AddSwitchSettings()
	table.insert(optionsTable, {
        type = "header",
        name = "Buff Settings",
    })	
	for i = 1, 8 do
		AddBuffGain(optionsTable, i)
		AddBuffFade(optionsTable, i)
		if i < 8 then AddDivider(optionsTable) end
	end
end
local function AddBaseSettings()
	table.insert(optionsTable, {
        type = "header",
        name = "Base Settings",
    })	
	table.insert(optionsTable, {
		type = "checkbox",
		name = "Enable Potion Switch",
		tooltip = "",
		getFunc = function() return BSCAHP.SV.ENABLE_ADDON end,
		setFunc = function(value) 
			BSCAHP.SV.ENABLE_ADDON = value
		end,
	})	
	table.insert(optionsTable, {
		type = 'dropdown',
		name = "Swap to Potion when in Combat",
		choices = BSCAHP.SLOTTED_POTS,
		choicesTooltips = BSCAHP.SLOTTED_POTS_TOOLTIP,
		getFunc = function() return BSCAHP.SV.POTION_IN_COMBAT end,
		setFunc = function(value)
			if value == "" then value = "Not In Use" end
			BSCAHP.SV.POTION_IN_COMBAT = value
		end,
		scrollable = 9,
		reference = "BSCAHP_COMBAT_IN",
	})
	table.insert(optionsTable, {
		type = 'dropdown',
		name = "Swap to Potion when out Combat",
		choices = BSCAHP.SLOTTED_POTS,
		choicesTooltips = BSCAHP.SLOTTED_POTS_TOOLTIP,
		getFunc = function() return BSCAHP.SV.POTION_OUT_COMBAT end,
		setFunc = function(value)
			if value == "" then value = "Not In Use" end
			BSCAHP.SV.POTION_OUT_COMBAT = value
		end,
		scrollable = 9,
		reference = "BSCAHP_COMBAT_OUT",
	})
end
function BSCAHP.InitMenu()
	-- the panel for the addons menu
	local panelData = {
		type = "panel",
		name = BSCAHP.NameMenu,
		displayName = BSCAHP.NameMenu,
		author = BSCAHP.Author,
		version = BSCAHP.VersionDisplay,
		registerForRefresh = true,
		slashCommand = "/bscahp",
	}	
	AddSendFeedBack()
	AddSlotedItems()
	AddBaseSettings()
	AddSwitchSettings()		
    local addonpanel = LibAddonMenu2:RegisterAddonPanel(BSCAHP.NameMenu, panelData)
    LibAddonMenu2:RegisterOptionControls(BSCAHP.NameMenu, optionsTable)
		
	CALLBACK_MANAGER:RegisterCallback("LAM-PanelOpened", function(currentpanel) if addonpanel == currentpanel then UpdateMenuSettings() end end )
	--CALLBACK_MANAGER:RegisterCallback("LAM-PanelClosed", function(currentpanel) if addonpanel == currentpanel then BSCASUIAlert:SetHidden(true) BSCASUIAlert:SetMovable(false) end end )
end