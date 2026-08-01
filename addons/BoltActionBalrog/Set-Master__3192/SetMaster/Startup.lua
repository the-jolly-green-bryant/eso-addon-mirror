Startup = {}
local This = Startup

local RecheckDependenciesDelay = 500 -- If all dependencies haven't loaded, try again in X miliseconds
local MaxDependenciesRetryCount = 20 -- If dependencies couldn't be loaded after X tries, abort and report the error
local DependenciesRetryCount = 0

-- Called a bit after everything loads so that we can make use of debug printing
local function InitializeDelayed()
	SetMasterOptions:Initialize()
	SaveDataUpdater:UpdateData()
	PlayerSetDatabase:Initialize()
	InventoryTooltipScript:Initialize()
	
	SetMasterOptions:Finalize()
end

local function InitalizeIfEverythingLoaded()
	if not LibSets or not LibSets.checkIfSetsAreLoadedProperly() then
		DependenciesRetryCount = DependenciesRetryCount + 1
		if DependenciesRetryCount >= MaxDependenciesRetryCount then
			d("Failed to load LibSets!")
			return
		end
		
		zo_callLater(InitalizeIfEverythingLoaded, RecheckDependenciesDelay)
	end
	
	zo_callLater(InitializeDelayed, 50) -- Initializing after the event lets us do things like debug logging in the startup callstack
end

function This.OnLoaded(Event, AddonName)
	if AddonName ~= SetMasterGlobal.Namespace then
		return
	end
	
	EVENT_MANAGER:UnregisterForEvent(SetMasterGlobal.Namespace, EVENT_ADD_ON_LOADED)
	
	InitalizeIfEverythingLoaded()
end

EVENT_MANAGER:RegisterForEvent(SetMasterGlobal.Namespace, EVENT_ADD_ON_LOADED, This.OnLoaded)