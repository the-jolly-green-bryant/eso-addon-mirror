
LoreLibrary = {}

local logFunctions = {}
if LibDebugLogger then
	LoreLibrary.logger = LibDebugLogger("LoreLibrary")
	local logFunctionNames = {"Verbose", "Debug", "Info", "Warn", "Error"}
	for _, logFunctionName in pairs(logFunctionNames) do
		logFunctions[logFunctionName] = function(self, ...) return self.logger[logFunctionName](self.logger, ...) end
		LoreLibrary[logFunctionName] = logFunctions[logFunctionName]
	end
else
	local logFunctionNames = {"Verbose", "Debug", "Info", "Warn", "Error"}
	for _, logFunctionName in pairs(logFunctionNames) do
		logFunctions[logFunctionName] = function(...) end
		LoreLibrary[logFunctionName] = logFunctions[logFunctionName]
	end
end
	
LoreLibrary.modules = {}
function LoreLibrary:RegisterModule(moduleName, moduleTable)
	self[moduleName] = moduleTable
	if LoreLibrary.logger then
		moduleTable.logger = LoreLibrary.logger:Create(moduleName)
	end
	for logFunctionName, logFunction in pairs(logFunctions) do
		moduleTable[logFunctionName] = logFunction
	end
	table.insert(self.modules, moduleTable)
end

function LoreLibrary:InitializeModules()
	for _, moduleTable in ipairs(self.modules) do
		moduleTable:Initialize()
	end
	for _, moduleTable in ipairs(self.modules) do
		if moduleTable.Finalize then
			moduleTable:Finalize()
		end
	end
end

function LoreLibrary.OnLoad(eventCode, addOnName)
	if addOnName ~= "LoreLibrary" then
		return
	end
	LoreLibrary:InitializeModules()
end

EVENT_MANAGER:RegisterForEvent("LoreLibrary", EVENT_ADD_ON_LOADED, LoreLibrary.OnLoad)
