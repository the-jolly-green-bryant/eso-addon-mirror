Vesi = {
	name = "Vesi",
	version = "1.1.5",
	varversion = 1,
	varname = "VesiSV",
	
	RegisterSavedVars = function(self, namespace, defaults)
		return ZO_SavedVars:NewAccountWide(self.varname, self.varversion, namespace, defaults)
	end,

	Init = function(self)
		self.Emotes:Init()
		self.Menu:Build()
		self.Hooks:Init()
	end,

	Debug = function(self, msg)
		d("DEBUG: " .. msg)
	end,
}

V = Vesi

function AddonLoaded(event, addonName)
	if addonName == V.name then
		V:Init()
	end
end

EVENT_MANAGER:RegisterForEvent(V.name, EVENT_ADD_ON_LOADED, AddonLoaded)