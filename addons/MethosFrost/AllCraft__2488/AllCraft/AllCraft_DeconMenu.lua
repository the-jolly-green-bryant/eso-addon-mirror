function AllCraftDeconMenu()
	--local menu = LibAddonMenu2
	local menu = LibStub("LibAddonMenu-2.0")
	local set = AllCraft_Decon.deconSettings

	  -- the panel for the addons menu
  local panel = {
    type = "panel",
    name = "AllCraft: Deconstructor",
    displayName = "AllCraft: Deconstructor",
    author = "Methos_Frost",
	version = AllCraft.version,
	slashCommand = "/acd",
  }

  -- this addons entries in the addon menu
  local options = {
	{
		type = "checkbox",
		name = "Account Wide Settings",
		warning = "Will need to reload the UI.",
		getFunc = function() return set.Account_Wide_Settings end,
		setFunc = function(value) set.Account_Wide_Settings = value end,
		disabled = true,
	},
	{
		type = "button",
		name = "Reload UI",
		func = function() ReloadUI() end
	},
    {
      type = "checkbox",
      name = "Debug Mode On",
      getFunc = function() return set.Debug_Mode_On end,
	  setFunc = function(value) set.Debug_Mode_On = value end,
	},
    {
		type = "checkbox",
		name = "Use Pricing option",
		getFunc = function() return set.PricingOn end,
		setFunc = function(value) set.PricingOn = value end,
	},
	{
	type = "slider",
	name = "Master Merchant Sales Price Cap",
	tooltip = "Maximum Master Merchant Price before reject destruction",
	min = 0,
	max = 10000,
	getFunc = function() return set.MMMax end,
	setFunc = function(value) set.MMMax = value end,
	disabled = ACMB.MMSliderDisable,
	clampInput = false,
	inputLocation = "below",
	},
	{
	type = "slider",
	name = "Tamriel Trade Centre Sales Price Cap",
	tooltip = "Maximum Tamriel Trade Centre Price before reject destruction",
	min = 0,
	max = 10000,
	getFunc = function() return set.TTCMax end,
	setFunc = function(value) set.TTCMax = value end,
	disabled = ACMB.TTCSliderDisable,
	clampInput = false,
	inputLocation = "below",
	},
	{
		type = "checkbox",
		name = "Smart Settings On",
		getFunc = function() return set.Smart_Settings_On end,
		setFunc = function(value) set.Smart_Settings_On = value end,
	  },
    {
      type = "checkbox",
      name = "List Before Deconstruct",
      getFunc = function() return set.List_Before_Deconstruct end,
      setFunc = function(value) set.List_Before_Deconstruct = value end,
    },
	{
        type = "header",
        name = "Refine options",
        width = "full",	--or "half" (optional)
    },
	{
		type = "checkbox",
		name = "Keep Certification Materials",
		getFunc = function() return set.KeepCertMats end,
		setFunc = function(value) set.KeepCertMats = value end,
	  },
	{
        type = "header",
        name = "Deconstructions options",
        width = "full",	--or "half" (optional)
    },
    {
      type = "checkbox",
      name = "Deconstruct items in bank",
      getFunc = function() return set.Use_Bank end,
      setFunc = function(value) set.Use_Bank = value end,
    },
    {
      type = "checkbox",
      name = "Deconstruct bound items",
      getFunc = function() return set.DeconstructBound end,
      setFunc = function(value) set.DeconstructBound = value end,
    },
    {
      type = "checkbox",
	  name = "Deconstruct set pieces",
	  warning = "Reload UI for additional set options.",
      getFunc = function() return set.Deconstruct_Set_Items end,
      setFunc = function(value) set.Deconstruct_Set_Items = value end,
    },
    {
      type = "checkbox",
      name = "Deconstruct ornate items",
      getFunc = function() return set.DeconstructOrnate end,
      setFunc = function(value) set.DeconstructOrnate = value end,
    },
    {
    	type = "checkbox",
    	name = "Deconstruct crafted items",
    	getFunc = function() return set.DeconstructCrafted end,
    	setFunc = function(value) set.DeconstructCrafted = value end,
    },
	{
	  type = "checkbox",
	  name = "Deconstruct Intricate",
	  getFunc = function() return set.DeconstructIntricate end,
	  setFunc = function(value) set.DeconstructIntricate = value end,
	},
	{
        type = "submenu",
        name = "Table Options",
        controls = {
			{
			type = "header",
			name = "Blacksmithing table options",
			},
			{
			type = "slider",
			name = "Max item quality to deconstruct for non-craftmaster",
			tooltip = "Maximum quality at which items will be destroyed for non-craftmasters.  (1 = white,5 = legendary)",
			min = 1,
			max = 5,
			getFunc = function() return set.Blacksmithing_Extraction_Not_Max end,
			setFunc = function(value) set.Blacksmithing_Extraction_Not_Max = value end,
			},
			{
			type = "slider",
			name = "Max item quality to deconstruct for craftmaster",
			tooltip = "Max quality at which items will be destroyed for craftmasters.  (1 = white,5 = legendary)",
			min = 1,
			max = 5,
			getFunc = function() return set.Blacksmithing_Extraction_Max end,
			setFunc = function(value) set.Blacksmithing_Extraction_Max = value end,
			},
			{
			type = "header",
			name = "Clothing table options",
			},
			{
			type = "slider",
			name = "Max item quality to deconstruct for non-craftmaster",
			tooltip = "Maximum quality at which items will be destroyed for non-craftmasters.  (1 = white,5 = legendary)",
			min = 1,
			max = 5,
			getFunc = function() return set.Clothing_Extraction_Not_Max end,
			setFunc = function(value) set.Clothing_Extraction_Not_Max = value end,
			},
			{
			type = "slider",
			name = "Max item quality to deconstruct for craftmaster",
			tooltip = "Max quality at which items will be destroyed for craftmasters.  (1 = white,5 = legendary)",
			min = 1,
			max = 5,
			getFunc = function() return set.Clothing_Extraction_Max end,
			setFunc = function(value) set.Clothing_Extraction_Max = value end,
			},
			{
			type = "header",
			name = "Jewlery table options",
			},
			{
			type = "slider",
			name = "Max item quality to deconstruct for non-craftmaster",
			tooltip = "Maximum quality at which items will be destroyed for non-craftmasters.  (1 = white,5 = legendary)",
			min = 1,
			max = 5,
			getFunc = function() return set.Jewlery_Extraction_Not_Max end,
			setFunc = function(value) set.Jewlery_Extraction_Not_Max = value end,
			},
			{
			type = "slider",
			name = "Max item quality to deconstruct for craftmaster",
			tooltip = "Max quality at which items will be destroyed for craftmasters.  (1 = white,5 = legendary)",
			min = 1,
			max = 5,
			getFunc = function() return set.Jewlery_Extraction_Max end,
			setFunc = function(value) set.Jewlery_Extraction_Max = value end,
			},
			{
			type = "header",
			name = "Woodworking table options",
			},
			{
			type = "slider",
			name = "Max item quality to deconstruct for non-craftmaster",
			tooltip = "Maximum quality at which items will be destroyed for non-craftmasters.  (1 = white,5 = legendary)",
			min = 1,
			max = 5,
			getFunc = function() return set.Woodworking_Extraction_Not_Max end,
			setFunc = function(value) set.Woodworking_Extraction_Not_Max = value end,
			},
			{
			type = "slider",
			name = "Max item quality to deconstruct for craftmaster",
			tooltip = "Max quality at which items will be destroyed for craftmasters.  (1 = white,5 = legendary)",
			min = 1,
			max = 5,
			getFunc = function() return set.Woodworking_Extraction_Max end,
			setFunc = function(value) set.Woodworking_Extraction_Max = value end,
			},
			{
			type = "header",
			name = "Enchanting table options",
			},
			{
			type = "slider",
			name = "Max item quality to deconstruct for non-craftmaster",
			tooltip = "Maximum quality at which items will be destroyed for non-craftmasters.  (1 = white,5 = legendary)",
			min = 1,
			max = 5,
			getFunc = function() return set.Enchanting_Extraction_Not_Max end,
			setFunc = function(value) set.Enchanting_Extraction_Not_Max = value end,
			},
			{
			type = "slider",
			name = "Max item quality to deconstruct for craftmaster",
			tooltip = "Maximum quality at which items will be destroyed for craftmasters.  (1 = white,5 = legendary)",
			min = 1,
			max = 5,
			getFunc = function() return set.Enchanting_Extraction_Max end,
			setFunc = function(value) set.Enchanting_Extraction_Max = value end,
			},
		}
	}
}
local AddSets = ACLoadMenu()
if set.Deconstruct_Set_Items then table.insert(options,ACLoadMenu() ) end

--Populate menu
menu:RegisterAddonPanel("AllCraftDeconstructor", ACMB.CreatePannel("AllCraft: Deconstructor","/acd","9400D3"))
menu:RegisterOptionControls("AllCraftDeconstructor", options)
end
