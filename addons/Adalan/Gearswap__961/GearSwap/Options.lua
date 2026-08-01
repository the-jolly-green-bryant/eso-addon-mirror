--------------------------Defaults--------------------------
-- its needed for the first start of GearSwap, coz no Options available in SavedVariables
GearSwap.Options = {}

GearSwap.Choices = 
{
	GetString(VAR_PRIMARY_SET_TEXT), 
	GetString(VAR_SECONDARY_SET_TEXT), 
	GetString(VAR_ADDITIONAL_SET1), 
	GetString(VAR_ADDITIONAL_SET2)
}


--Get the Initial GearSet Table
function GearSwap:GetDefaultGearSets()
	-- Load the empty tables using the Zenimax Constants, needs to save as string
	GearSwap.DefaultGearSets = {}
	for i=1,4,1 do
		GearSwap.DefaultGearSets[i] = 
		{
			{EQUIP_SLOT_HEAD, "nil"},{EQUIP_SLOT_NECK, "nil"},{EQUIP_SLOT_CHEST, "nil"},{EQUIP_SLOT_SHOULDERS, "nil"},
			{EQUIP_SLOT_WAIST, "nil"},{EQUIP_SLOT_LEGS, "nil"},{EQUIP_SLOT_FEET, "nil"},{EQUIP_SLOT_COSTUME, "nil"},
			{EQUIP_SLOT_RING1, "nil"}, {EQUIP_SLOT_RING2, "nil"},{EQUIP_SLOT_HAND, "nil"},
			{EQUIP_SLOT_MAIN_HAND, "nil"}, {EQUIP_SLOT_OFF_HAND, "nil"},{EQUIP_SLOT_BACKUP_MAIN, "nil"}, {EQUIP_SLOT_BACKUP_OFF, "nil"},
		}
	end
end

--Get default options
function GearSwap:GetDefaultOptions()
	GearSwap.DefaultOptions = 
	{
		-- GearSwap On or Off
		GearSwapOn = true,
		-- Change GearSet when weapon swap event is executed
		ChangeGearSetOnWeaponSwap = true, 
		-- Future paramters, allowing a user to assign a specific set to a weapon swap event
		GearSetForPrimary = 1,
		GearSetForSecondary = 2,
		--Turn off/on output statements
		OutputOnGearSwap = true,
		OutputOnGearSave = true,
		--Turn off/on Messagebox move
		MoveMsgbox = false,
		--Turn off/on costume swap
		SwapCostume = false,
		--WindowPosition
		left = 100,
		top = 100,
		--Turn off/on unequip single items
		UnequipSingleItem = false,
		--Adjust message delay for on screen messages on swap
		MsgDelay = 5000,
		--Turn off/on output for unused slots
		OutputUnusedSlots = false,
		--The set you want to use when you mount up
		MountSet = 1,
		--The set you want to use when you are going into stealth
		SneakSet = 1,
		--Enable automatically switching for mount set
		SwitchMountSetActive = false,		
		--saves the last used set for switching back
		LastUsedSet = nil,
		-- output message into chat whether auto mount is on or off
		OutputAutoMount = false,
		-- Delay to Unmount
		UnmountSwapDelay = 350,
	}
end

--Get GearSet Outputs / Indexs
function GearSwap:GetGearSetVariables()
	GearSwap.GearSetVariables =
	{
		{ 	Index = 1, Name = GetString(VAR_PRIMARY_SET_TEXT) },
		{	Index = 2, Name = GetString(VAR_SECONDARY_SET_TEXT) },
		{	Index = 3, Name = GetString(VAR_ADDITIONAL_SET1) },
		{	Index = 4, Name = GetString(VAR_ADDITIONAL_SET2) },
	}
end

--------------------------Create /Load--------------------------

--Create Character UI Button / Label and Save Dropdown
function GearSwap:CreateUIControls()
	--Create the Button and relevant variables / handlers
	GearSwap.Button = WINDOW_MANAGER:CreateControl("GearSetButton", ZO_Character, CT_BUTTON)
	GearSwap.Button:SetDimensions(35,35)
	GearSwap.Button:SetAnchor(TOPLEFT,ZO_Character,TOPLEFT, 240,-27)
	GearSwap.Button:SetHandler("OnClicked",function() GearSwap:SaveGearSet(GearSwap:GetGearSetFromCombobox()) end)
	GearSwap.Button:SetNormalTexture("ESOUI/art/progression/icon_armorsmith.dds")
	GearSwap.Button:SetMouseOverTexture("ESOUI/art/buttons/edit_save_over.dds")
	GearSwap.Button:SetHandler("OnMouseEnter",function (self) ZO_Tooltips_ShowTextTooltip(self, RIGHT, GetString(MISC_BUTTON_LABEL_SAVE_TEXT)) end)
	GearSwap.Button:SetHandler("OnMouseExit",function (self) ZO_Tooltips_HideTextTooltip() end)

	--Create the label and set the text
	GearSwap.Label = WINDOW_MANAGER:CreateControl("GearSetLabel", ZO_Character, CT_LABEL)
	GearSwap.Label:SetColor(1,1,1,1)
	GearSwap.Label:SetFont("ZoFontWinH3")
	GearSwap.Label:SetAnchor(TOPLEFT, ZO_Character, TOPLEFT, 15, -60)--   -40
	local gearSet = GetActiveWeaponPairInfo()
	GearSwap:UpdateGearSwapUILabel(gearSet)

	--Create Dropdown for saving a Gear Set
	GearSwap.Dropdown = WINDOW_MANAGER:CreateControlFromVirtual("GearSwapDropdown", ZO_Character, "ZO_ComboBox")
	GearSwap.Dropdown:SetHidden(false)
	GearSwap.Dropdown:SetAnchor(TOPLEFT,ZO_Character,TOPLEFT, 15,-20)
	GearSwap.Dropdown:SetHeight(24)
	GearSwap.Dropdown:SetWidth(200)
	GearSwap.Combobox = ZO_ComboBox_ObjectFromContainer(GearSwap.Dropdown)
	GearSwap.Combobox:SetSortsItems(false)

	--Create a button to undress all
	GearSwap.Button = WINDOW_MANAGER:CreateControl("UndressButton", ZO_Character, CT_BUTTON)
	GearSwap.Button:SetDimensions(35,35)
	GearSwap.Button:SetAnchor(TOPLEFT,ZO_Character,TOPLEFT, 240,8)
	GearSwap.Button:SetHandler("OnClicked",function() GearSwap:UnequipItems() end)
	GearSwap.Button:SetNormalTexture("/esoui/art/cadwell/cadwell_indexicon_gold_up.dds")
	GearSwap.Button:SetMouseOverTexture("/esoui/art/cadwell/cadwell_indexicon_gold_over.dds")
	GearSwap.Button:SetHandler("OnMouseEnter",function (self) ZO_Tooltips_ShowTextTooltip(self, RIGHT, GetString(MISC_BUTTON_LABEL_UNDRESS_TEXT)) end)
	GearSwap.Button:SetHandler("OnMouseExit",function (self) ZO_Tooltips_HideTextTooltip() end)

--[[ -- old variant from dboc
	for i=1,4,1 do
		local gearSetName = GearSwap.GearSetVariables[i].Name
		local entry = GearSwap.Combobox:CreateItemEntry(gearSetName, nil)
		--GearSwap.Combobox:AddItem(entry)
		GearSwap.Combobox:AddItem(entry)
	end
--]]
	-- this let you choose a set from pulldown to change it for a setup
	for _,gearSetName in ipairs(GearSwap.Choices) do
		GearSwap.Combobox:AddItem(ZO_ComboBox:CreateItemEntry(gearSetName, function() GearSwap:OnDropdownSelect(gearSetName) end))
	end
	GearSwap:UpdateComboboxSelected(gearSet)

end

function GearSwap:OnDropdownSelect(gearSetName)
	local setID = GearSwap:GetGearSetID(gearSetName)
	GearSwap.Options.LastUsedSet = setID
	GearSwap:EquipGearSet(setID, 2, 0)
end


--Load the Keybinding String ID's
function GearSwap:CreateKeybindingStrings()
	--Set Keybinding XML strings
	ZO_CreateStringId("SI_BINDING_NAME_GEARSWAP_TOGGLE",GetString(BINDING_GEARSWAP_ONOFF_TEXT))
	ZO_CreateStringId("SI_BINDING_NAME_SWAPPING_TOGGLE",GetString(BINDING_SWAPPING_ONOFF_TEXT))	
    ZO_CreateStringId("SI_BINDING_NAME_GEARSWAP_SET1",GetString(BINDING_PRIMARY_GEARSET_TEXT))
	ZO_CreateStringId("SI_BINDING_NAME_GEARSWAP_SET2",GetString(BINDING_SECONDARY_GEARSET_TEXT))
	ZO_CreateStringId("SI_BINDING_NAME_GEARSWAP_SET3",GetString(BINDING_ADDITIONAL1_GEARSET_TEXT))
	ZO_CreateStringId("SI_BINDING_NAME_GEARSWAP_SET4",GetString(BINDING_ADDITIONAL2_GEARSET_TEXT))
	ZO_CreateStringId("SI_BINDING_NAME_GEARSWAP_AUTOMOUNT_ONOFF",GetString(BINDING_MOUNT_SWAP_TEXT))
	ZO_CreateStringId("SI_BINDING_NAME_GEARSWAP_NAKED",GetString(BINDING_GO_NAKED_TEXT))
end

--Load GearSwap Add On Menu using LAM
function GearSwap:CreateGearSwapAddOnMenu()
	local LAM = LibStub:GetLibrary("LibAddonMenu-2.0")
	--Register the Options panel with LAM
	local panelData = 
	{
    	type = "panel",
     	name = "GearSwap",
		author = "dpoc, Adalan, Garkin",
		version = GearSwap.version,
	}
	LAM:RegisterAddonPanel("GearSwapOptions", panelData)

	--Set the actual panel data
	local optionsData = {
    	[1] = {
          type = "checkbox",
          name = GetString(GEARSWAP_NAME),
          tooltip = GetString(GEARSWAP_TEXT),
          getFunc = function() return GearSwap.Options.GearSwapOn end,
          setFunc = function(value) GearSwap.Options.GearSwapOn = value GearSwap:AnnounceGearSwapOnOff() end,
          width = "full",
    	},
    	[2] = {
          type = "checkbox",
          name = GetString(SWAPPING_ON_WEAPONSWAP_NAME),
          tooltip = GetString(SWAPPING_ON_WEAPONSWAP_TEXT),
          getFunc = function() return GearSwap.Options.ChangeGearSetOnWeaponSwap end,
          setFunc = function(value) GearSwap.Options.ChangeGearSetOnWeaponSwap = value GearSwap:AnnounceSwappingOnOff() end,
          width = "full",
    	},		
    	[3] = {
          type = "dropdown",
          name = GetString(OPTIONS_PRIMARY_GEARSET_NAME),
          tooltip = GetString(OPTIONS_PRIMARY_GEARSET_TEXT),
          choices = GearSwap.Choices,
          getFunc = function() return GearSwap:GetGearSetName(GearSwap.Options.GearSetForPrimary) end,
          setFunc = function(value) GearSwap:UpdateWeaponSwapDefaultSet(value, 1) end,
          width = "full",
    	},
    	[4] = {
          type = "dropdown",
          name = GetString(OPTIONS_SECONDARY_GEARSET_NAME),
          tooltip = GetString(OPTIONS_SECONDARY_GEARSET_TEXT),
          choices = GearSwap.Choices,
          getFunc = function() return GearSwap:GetGearSetName(GearSwap.Options.GearSetForSecondary) end,
          setFunc = function(value) GearSwap:UpdateWeaponSwapDefaultSet(value, 2) end,
          width = "full",
    	},
    	[5] = {
			type = "dropdown",
			name = GetString(OPTIONS_MOUNT_GEARSET_NAME),
			tooltip = GetString(OPTIONS_MOUNT_GEARSET_TEXT),
			choices = GearSwap.Choices,
			getFunc = function() return GearSwap:GetGearSetName(GearSwap.Options.MountSet) end,
			setFunc = function(value) GearSwap:UpdateMountSet(value) end,
			width = "full",
		},	
    	[6] = {
          type = "checkbox",
          name = GetString(MOUNT_ONOFF_NAME),
          tooltip = GetString(MOUNT_ONOFF_TEXT), 
          getFunc = function() return GearSwap.Options.SwitchMountSetActive end,
          setFunc = function(value) GearSwap.Options.SwitchMountSetActive = value GearSwap:EnableDisableMounting(value) end,
          width = "full",
    	},
    	[7] = {
          type = "checkbox",
          name = GetString(CHANGE_COSTUME_NAME),
          tooltip = GetString(CHANGE_COSTUME_TEXT),
          getFunc = function() return GearSwap.Options.SwapCostume end,
          setFunc = function(value) GearSwap.Options.SwapCostume = value end,
          width = "full",
    	},		
    	[8] = {
          type = "checkbox",
          name = GetString(UNEQUIP_SINGLE_ITEMS_NAME),
          tooltip = GetString(UNEQUIP_SINGLE_ITEMS_TEXT),
          getFunc = function() return GearSwap.Options.UnequipSingleItem end,
          setFunc = function(value) GearSwap.Options.UnequipSingleItem = value end,
          width = "full",
    	},
		[9] = {		
		  type = "slider",
		  min = 1000,
		  max = 10000,	
		  name = GetString(SLIDER_ADJUST_MESSAGE_DELAY_NAME),
		  tooltip = GetString(SLIDER_ADJUST_MESSAGE_DELAY_TEXT),
		  getFunc = function() return GearSwap.Options.MsgDelay  end,
		  setFunc = function(value) GearSwap.Options.MsgDelay = value end,
		  width = "full",
		},			
    	[10] = {
          type = "checkbox",
          name = GetString(SHOW_MESSAGEBOX_NAME),
          tooltip = GetString(SHOW_MESSAGEBOX_TEXT),
          getFunc = function() return GearSwap.Options.MoveMsgbox end,
          setFunc = function(value) GearSwap.Options.MoveMsgbox = value if(value) then ctlGearSwap:SetHidden(false) ctlGearSwapOutput:SetText(GearSwap:GetGearSetName(GetActiveWeaponPairInfo()).." equipped") else ctlGearSwapOutput:SetText("") ctlGearSwap:SetHidden(true) end end,
          width = "full",
    	},
    	[11] = {
		  type = "slider",
		  min = 0,
		  max = 2000,	
		  name = GetString(SLIDER_ADJUST_UNMOUNT_DELAY_NAME),
		  tooltip = GetString(SLIDER_ADJUST_UNMOUNT_DELAY_TEXT),
		  getFunc = function() return GearSwap.Options.UnmountSwapDelay  end,
		  setFunc = function(value) GearSwap.Options.UnmountSwapDelay = value end,
		  width = "full",
		},
    	[12] = {
			type = "submenu",
			name = GetString(SUBMENU_ANNOUNCEMENTS_NAME),
			tooltip = GetString(SUBMENU_ANNOUNCEMENTS_TEXT),	
			controls = {
				[1] = {
				  type = "checkbox",
				  name = GetString(SUB_MESSAGE_ONSCREEN_NAME),
				  tooltip = GetString(SUB_MESSAGE_ONSCREEN_TEXT),
				  getFunc = function() return GearSwap.Options.OutputOnGearSwap end,
				  setFunc = function(value) GearSwap.Options.OutputOnGearSwap = value end,
				  width = "full",
				},
				[2] = {
				  type = "checkbox",
				  name = GetString(SUB_CHAT_MESSAGE_ON_SAVE_NAME),
				  tooltip = GetString(SUB_CHAT_MESSAGE_ON_SAVE_TEXT),
				  getFunc = function() return GearSwap.Options.OutputOnGearSave end,
				  setFunc = function(value) GearSwap.Options.OutputOnGearSave  = value end,
				  width = "full",
				},
				[3] = {
				  type = "checkbox",
				  name = GetString(SUB_CHAT_MESSAGE_SINGLE_ITEMS_NAME),
				  tooltip = GetString(SUB_CHAT_MESSAGE_SINGLE_ITEMS_TEXT),
				  getFunc = function() return GearSwap.Options.OutputUnusedSlots end,
				  setFunc = function(value) GearSwap.Options.OutputUnusedSlots  = value end,
				  width = "full",
				},
				[4] = {
				  type = "checkbox",
				  name = GetString(SUB_CHAT_MESSAGE_AUTO_MOUNT_NAME),
				  tooltip = GetString(SUB_CHAT_MESSAGE_AUTO_MOUNT_TEXT),
				  getFunc = function() return GearSwap.Options.OutputAutoMount end,
				  setFunc = function(value) GearSwap.Options.OutputAutoMount  = value end,
				  width = "full",
				},					
			},
		},
	}
	LAM:RegisterOptionControls("GearSwapOptions", optionsData)
end

