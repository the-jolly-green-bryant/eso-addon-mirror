-- First, we create a namespace for our addon by declaring a top-level table that will hold everything else.
local IE = InventoryExtensions
local EM = EVENT_MANAGER

-- Then we create an event handler function which will be called when the "addon loaded" event
-- occurs. We'll use this to initialize our addon after all of its resources are fully loaded.
local function OnAddOnLoaded(eventCode, addonName)
    -- The event fires each time *any* addon loads - but we only care about when our own addon loads.
    if addonName ~= IE.name then return end
	EM:UnregisterForEvent(IE.name.."_Event", EVENT_ADD_ON_LOADED)

    -- Load saved variables
    IE.SavedVars = ZO_SavedVars:NewAccountWide(IE.name.."_Vars", IE.varsVersion, nil, IE.DefaultVars)

    -- Initialize stuff
    IE.Junk.Init()
    IE.MoneyTracker.Init()
    IE.SettingsMenu.Init()
    -- IE.MarkItem.Init()
end

-- Finally, we'll register our event handler function to be called when the proper event occurs.
EM:RegisterForEvent(IE.name.."_Event", EVENT_ADD_ON_LOADED, OnAddOnLoaded)