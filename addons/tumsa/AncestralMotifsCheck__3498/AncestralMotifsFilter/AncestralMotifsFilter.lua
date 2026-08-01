-- Namespace
AMFilter = {}
AMFilter.name = "AncestralMotifsFilter"

-- Default settings/variables
local FILTER_TYPE_ID_AMF  	= 220
local FILTER_TYPE_ID_AMFES  = 221

--  a function that will initialize the addon
--	since this addon works as AwesomeGuildStore plugin, there is nothing to initialize
function AMFilter:Initialize()
    -- AMFilter.NothingToInitialize = true
end

-- event handler function which will be called when the "addon loaded" event occurs
-- initializes addon after all of its resources are fully loaded
function AMFilter.OnAddOnLoaded(event, addonName)
    if addonName == AMFilter.name then
		AMFilter:Initialize()
		AMFilter.RegisterAGSInitCallback()
		EVENT_MANAGER:UnregisterForEvent(AMFilter.name, EVENT_ADD_ON_LOADED)
	end 
end

-- register the event handler function to be called when the proper event occurs
EVENT_MANAGER:RegisterForEvent(AMFilter.name, EVENT_ADD_ON_LOADED, AMFilter.OnAddOnLoaded)

--  checks if AwesomeGuildStore is installed and working
--  tells AwesomeGuildStore there is a custom filer 
function AMFilter.RegisterAGSInitCallback()
	--  shorten name of AwesomeGuildStore
    local AGS = AwesomeGuildStore
	
	--  check AwesomeGuildStore status and version
    if AMFilter.ags_callback_registered then return end
    AMFilter.ags_callback_registered = true
    if not (AGS and AGS.GetAPIVersion and AGS.GetAPIVersion() == 4) then return end
	
	--  tell AwesomeGuildStore we have a custom filter to use
	--	custom filters are called after AGS filters are added, aka: AFTER_FILTER_SETUP
    AGS:RegisterCallback(AGS.callback.AFTER_FILTER_SETUP, AMFilter.InitAGSIntegration)
end

--  function that uses AwesomeGuildStore API and writes a custom MultiChoiceFilterBase filter 
function AMFilter.InitAGSIntegration(trading_house_wrapper)
	local AGS = AwesomeGuildStore
	
	--  check AwesomeGuildStore status and version
	if AMFilter.ags_init_started then return end
    AMFilter.ags_init_started = true
    if not (    AGS
            and AGS.GetAPIVersion
            and AGS.GetAPIVersion() == 4) then
        return
    end
	
	--  set filter variables
	local FilterBase              = AGS.class.FilterBase
    local MultiChoiceFilterBase   = AGS.class.MultiChoiceFilterBase
    local FILTER_ID               = AGS.data.FILTER_ID
    local SUB_CATEGORY_ID         = AGS.data.SUB_CATEGORY_ID
	
	-- Ancestral Motifs
    local AMFilterAGS    		  = MultiChoiceFilterBase:Subclass()
	AMFilter.AMFilterAGS		  = AMFilterAGS
	
	-- Other Expensive Stuff
	local ESFilterAGS   	  	  = MultiChoiceFilterBase:Subclass()
	AMFilter.ESFilterAGS		  = ESFilterAGS

	--	--------------------------------------------------------------------------------------
	--  Ancestral Motifs
    function AMFilterAGS:New(...)
        return MultiChoiceFilterBase.New(self, ...)
    end
	
	--  initialize AwesomeGuildStore MultiChoiceFilterBase filter, feed the filter ID and Name 
	--  currently only 2 options: true, false for inlcuding/excluding expensive motif style stones 
	--  icons used ar ZOS built-in ones so no icon folder inside the addon 
	--  [SUB_CATEGORY_ID.CONSUMABLE_WRIT] = true, - this ensures the filter only shows up for Master Writs category in Guild Store 
	function AMFilterAGS:Initialize()
		MultiChoiceFilterBase.Initialize(self, FILTER_TYPE_ID_AMF, FilterBase.GROUP_LOCAL, GetString(AMF_FILTERTITLE), {
			{
				id = true,
				label = GetString(AMF_YES),
				icon = "EsoUI/Art/Journal/journal_tabIcon_loreLibrary_%s.dds",
			},
			{
				id = false,
				label = GetString(AMF_NO),
				icon = "Esoui/Art/Contacts/tabIcon_ignored_%s.dds",
			},
		})
		self:SetEnabledSubcategories({
			[SUB_CATEGORY_ID.CONSUMABLE_WRIT] = true,
		})
	end
	
	--  finds what results to show or filter in the list
	function AMFilterAGS:FilterLocalResult(itemData)
		local item_link = itemData.itemLink
		local id = false
		
		--  calls local ExpensiveStyleStone function to check if Master Writ needs an expensive style stone
		if AMFilter.ExpensiveStyleStone(item_link) then id = true end 
		
		--  match the value (true/false) with the values list 
		local value = self.valueById[id]
		return self.localSelection[value]
	end
	
	--	--------------------------------------------------------------------------------------
	--  Expensive Stuff
	function ESFilterAGS:New(...)
        return MultiChoiceFilterBase.New(self, ...)
    end
	
	--  initialize AwesomeGuildStore MultiChoiceFilterBase filter, feed the filter ID and Name 
	--  currently only 2 options: true, false for inlcuding/excluding expensive stuff 
	--  icons used ar ZOS built-in ones so no icon folder inside the addon 
	--  [SUB_CATEGORY_ID.CONSUMABLE_WRIT] = true, - this ensures the filter only shows up for Master Writs category in Guild Store 
	function ESFilterAGS:Initialize()
		MultiChoiceFilterBase.Initialize(self, FILTER_TYPE_ID_AMFES, FilterBase.GROUP_LOCAL, GetString(EMF_FILTERTITLE), {
			{
				id = true,
				label = GetString(EMF_YES),
				icon = "EsoUI/Art/Journal/journal_tabIcon_loreLibrary_%s.dds",
			},
			{
				id = false,
				label = GetString(EMF_NO),
				icon = "Esoui/Art/Contacts/tabIcon_ignored_%s.dds",
			},
		})
		self:SetEnabledSubcategories({
			[SUB_CATEGORY_ID.CONSUMABLE_WRIT] = true,
		})
	end
	
	--  finds what results to show or filter in the list
	function ESFilterAGS:FilterLocalResult(itemData)
		local item_link = itemData.itemLink
		local id = false
		
		--  calls local ExpensiveWritFinder function to check if Master Writ needs an expensive ingredient
		if AMFilter.ExpensiveWritFinder(item_link) then id = true end 
		
		--  match the value (true/false) with the values list 
		local value = self.valueById[id]
		return self.localSelection[value]
	end
	
	--	--------------------------------------------------------------------------------------
	--  register Filters and FilterFragments in AwesomeGuildStore 
	AGS:RegisterFilter(AMFilterAGS:New())
    AGS:RegisterFilterFragment(AGS.class.MultiButtonFilterFragment:New(FILTER_TYPE_ID_AMF))
	AGS:RegisterFilter(ESFilterAGS:New())
    AGS:RegisterFilterFragment(AGS.class.MultiButtonFilterFragment:New(FILTER_TYPE_ID_AMFES))
end