LibAkaUtils = LibAkaUtils or {}

LibAkaUtils.name = "LibAkaUtils"
LibAkaUtils.version = nil
LibAkaUtils.watches = {}
LibAkaUtils.listeners = {}
LibAkaUtils.listening = nil
LibAkaUtils.lastChat = ""
LibAkaUtils.dataShare = {}
LibAkaUtils.data = {}
LibAkaUtils.sending = false
LibAkaUtils.sending2 = false
LibAkaUtils.listeningCodes = {}
LibAkaUtils.dataQueue = {}
LibAkaUtils.dataQueue2 = {}
LibAkaUtils.savedVars = {}
LibAkaUtils.sendTime = 200
LibAkaUtils.setting = nil

function LibAkaUtils.getVersion()
	local addOnManager = GetAddOnManager()
    for i = 1, addOnManager:GetNumAddOns() do
        local name = addOnManager:GetAddOnInfo(i)
        if name == LibAkaUtils.name then
            return addOnManager:GetAddOnVersion(i)
        end
    end
    return 0
end

function LibAkaUtils.getAddonInfo(addonName)
	local addOnManager = GetAddOnManager()
    for i = 1, addOnManager:GetNumAddOns() do
        local name, title, author, description, enabled, _, _, isLibrary = addOnManager:GetAddOnInfo(i)
        local version = addOnManager:GetAddOnVersion(i) 
        if name == addonName then
            return {
				name = name,
				title = title,
				author = author,
				description = description,
				enabled = enabled,
				isLibrary = isLibrary,
				version = version
			}
        end
    end
    return {
		name = "",
		title = "",
		author = "",
		description = "",
		enabled = false,
		isLibrary = false,
		version = 0
	}
end

function LibAkaUtils.isAddonAvailable(addonName)
	local addOnManager = GetAddOnManager()
    for i = 1, addOnManager:GetNumAddOns() do
        local name = addOnManager:GetAddOnInfo(i)
        if name == addonName then
            return true
        end
    end
    return false
end

local function start( _, addonName )
	if (addonName ~= LibAkaUtils.name) then return end
	EVENT_MANAGER:UnregisterForEvent(LibAkaUtils.name, EVENT_ADD_ON_LOADED)
	
	LibAkaUtils.version = LibAkaUtils.getVersion()
	
	LibAkaUtilsData = LibAkaUtilsData or {}
	LibAkaUtils.savedVars = LibAkaUtilsData
	
	LibAkaUtils.addCommand("autofill", LibAkaUtils.TriggerAutofill)
	
	LibAkaUtils.SetupAutofillDataCollector()
end

EVENT_MANAGER:RegisterForEvent(LibAkaUtils.name, EVENT_ADD_ON_LOADED, start)