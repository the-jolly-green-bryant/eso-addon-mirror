
ResourceRadar = {}
local Main = ResourceRadar

Main.modules = {}
function Main:RegisterModule(identifier, module)
	self[identifier] = module
	table.insert(self.modules, module)
end

function Main:InitializeModules()
	for _, module in pairs(self.modules) do
		if type(module.Initialize) == "function" then
			module:Initialize()
		end
	end
end

local function OnAddOnLoaded(eventCode, addOnName)
	if addOnName ~= "ResourceRadar" then
		return
	end
	
	LibDAU:VerifyAddon("ResourceRadar")
	
	Main:InitializeModules()
end

EVENT_MANAGER:RegisterForEvent("ResourceRadar", EVENT_ADD_ON_LOADED, OnAddOnLoaded)
