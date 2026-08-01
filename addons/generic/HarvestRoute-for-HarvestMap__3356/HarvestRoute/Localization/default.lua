
HarvestRoute.defaultLocalizedStrings = {
	-- configuration texts
	addonsettingstext = "The HarvestRoute Tour Tracker uses a separate range for node detection. Usually this should be considerably lower than the normal detection range to make sure, that you actually walked very close to a node to be added.",
	routenodes = "Visited Nodes and Farming Helper",
	routerangemultiplier = "Tour tracking node range",
	routerangemultipliertooltip = "Nodes within X meters are considered as visited by the tour tracker.",
	enabletrackerwindow = "enable Tracker window",
	enabletrackerwindowtooltip = "display tour info, nearest resource, and the last node from tour",
  	showtrackerwindow = "always show Tracker window",
  	showtrackerwindowtooltip = "if disabled, the Tracker window will only be shown once you activate the Tracker",
	usepathheuristics = "enable smartpath",
  	usepathheuristicstooltip = "This option reduces zigzag paths by determining if inserting new resources after the last ADDED or the last VISITED node creates a shorter path",
	
	-- tracker window
	trackeractive = "|C7FCF7FTracker is active|r",
  	trackerinactive = "|CFF7F7FTracker is off|r",
	pathinfomissing = "|CFF7F7Fno tour active|r",
  	pathinfotitle = "current tour:",
  	pathinfo = "<<1>> nodes |CA0A0A0(<<2>> m length)|r",
  	nearestnodetitle = "nearest resource:",
  	nearestnodetooltip = "the nearest resource to your position, that is not included in the current tour",
  	lastpathnodetitle = "last resource from tour:",
  	lastpathnodetooltip = "new nodes will be inserted after this node",
  	nodeinfounknown = "|CA0A0A0no node within 50m|r",
	nodeinfo = [[<<1>> |CA0A0A0(<<2>> m)|r]],
	
	-- harvestmap tour generator
	tourtrackerdescription = [[The tour tracker will automatically insert new nodes after the last visited node included in your tour.	
	If there is no tour yet, one will be created after you visited at least 3 nodes, which must not be "unknown".
	]],
  	buttonstarttracker = "Enable tracking",
  	buttonstoptracker = "Disable tracking",
}

local default = HarvestRoute.defaultLocalizedStrings
local current = HarvestRoute.localizedStrings or {}

function HarvestRoute.GetLocalization(tag)
	-- return the localization for the given tag,
	-- if the localization is missing, use the english string instead
	-- if the english string is missing, something went wrong.
	-- return the tag so that at least some string is returned to prevent the addon from crashing
	return (current[ tag ] or default[ tag ]) or tag
end

