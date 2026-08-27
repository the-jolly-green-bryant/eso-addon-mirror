-- Integrated into ESO Adventurer Suite; original data/marker architecture retained and namespaced.

EASLoreLibrary = {}

local logFunctions = {}
if LibDebugLogger then
	EASLoreLibrary.logger = LibDebugLogger("EASLoreLibrary")
	local logFunctionNames = {"Verbose", "Debug", "Info", "Warn", "Error"}
	for _, logFunctionName in pairs(logFunctionNames) do
		logFunctions[logFunctionName] = function(self, ...) return self.logger[logFunctionName](self.logger, ...) end
		EASLoreLibrary[logFunctionName] = logFunctions[logFunctionName]
	end
else
	local logFunctionNames = {"Verbose", "Debug", "Info", "Warn", "Error"}
	for _, logFunctionName in pairs(logFunctionNames) do
		logFunctions[logFunctionName] = function(...) end
		EASLoreLibrary[logFunctionName] = logFunctions[logFunctionName]
	end
end
	
EASLoreLibrary.modules = {}
function EASLoreLibrary:RegisterModule(moduleName, moduleTable)
	self[moduleName] = moduleTable
	if EASLoreLibrary.logger then
		moduleTable.logger = EASLoreLibrary.logger:Create(moduleName)
	end
	for logFunctionName, logFunction in pairs(logFunctions) do
		moduleTable[logFunctionName] = logFunction
	end
	table.insert(self.modules, moduleTable)
end

function EASLoreLibrary:InitializeModules()
	for _, moduleTable in ipairs(self.modules) do
		moduleTable:Initialize()
	end
	for _, moduleTable in ipairs(self.modules) do
		if moduleTable.Finalize then
			moduleTable:Finalize()
		end
	end
end

function EASLoreLibrary:Initialize()
	if self.initialized then return end
	self.initialized = true
	self:InitializeModules()
end
