-- PlayerReady.lua
if MSI == nil then MSI = MSI or {} end
local MSI = _G['MSI']

MSI.IsPlayerLoaded = false

--***********************--
-- Player already Loaded
local function PlayerLoaded(eventCode)
	MSI.IsPlayerLoaded = true
	MSI.InitModuleEvents()
	MSI.InitPlayerReady()

	local isNotDeveloper = false
	if GetUnitDisplayName("player") ~= DecorateDisplayName(MSI.DevAcc) then
		isNotDeveloper = true
		MSI.Print("c", zo_strformat(GetString(MSI_ADDON_NORM_MODE), (isNotDeveloper and GetString(MSI_ADDON_DISABLED) or GetString(MSI_ADDON_ENABLED))))
	else
		isNotDeveloper = false
		MSI.Print("i", zo_strformat(GetString(MSI_ADDON_DEV_MODE), MSI.Author, (isNotDeveloper and GetString(MSI_ADDON_DISABLED) or GetString(MSI_ADDON_ENABLED))))
	end
	zo_callLater(MSI.ShowInitCenterMsg, 3000 + GetLatency())
end

--**************--
-- Player Ready
function MSI.InitPlayerReady()
	local function UnRegModuleEvents()
		EVENT_MANAGER:UnregisterForEvent(MSI.Name.."PlayerLoaded", EVENT_PLAYER_ACTIVATED)
	end
	local function RegModuleEvents()
		UnRegModuleEvents()
		EVENT_MANAGER:RegisterForEvent(MSI.Name.."PlayerLoaded", EVENT_PLAYER_ACTIVATED, PlayerLoaded)
	end
		-- After AddOn has been Loaded
	if not MSI.IsPlayerLoaded then
		RegModuleEvents()
		--MSI.Print("d", "Player |c8B0000not|r loaded yet!! PlayerCheck Event registered")
	elseif MSI.IsPlayerLoaded then
		-- When Player is Ready Loaded
		UnRegModuleEvents()
--		MSI.InitMenuAfterPlayer()
		--MSI.Print("d", "Player loaded !! PlayerCheck Event unregistered")
	else
		UnRegModuleEvents()
		--MSI.Print("d", "MSI |c8B0000not|r Active!! PlayerCheck Event unregistered")
	end
end
--eof