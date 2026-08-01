
Harvest = {}

local logFunctions = {}
--[[if LibDebugLogger then
	Harvest.logger = LibDebugLogger("HarvestMap")
	local logFunctionNames = {"Verbose", "Debug", "Info", "Warn", "Error"}
	for _, logFunctionName in pairs(logFunctionNames) do
		logFunctions[logFunctionName] = function(self, ...) return self.logger[logFunctionName](self.logger, ...) end
		Harvest[logFunctionName] = logFunctions[logFunctionName]
	end
else--]]
	local logFunctionNames = {"Verbose", "Debug", "Info", "Warn", "Error"}
	for _, logFunctionName in pairs(logFunctionNames) do
		logFunctions[logFunctionName] = function(...) end
		Harvest[logFunctionName] = logFunctions[logFunctionName]
	end
--end
	
Harvest.modules = {}
function Harvest:RegisterModule(moduleName, moduleTable)
	self[moduleName] = moduleTable
	if Harvest.logger then
		moduleTable.logger = Harvest.logger:Create(moduleName)
	end
	for logFunctionName, logFunction in pairs(logFunctions) do
		moduleTable[logFunctionName] = logFunction
	end
	table.insert(self.modules, moduleTable)
end

function Harvest:InitializeModules()
	for _, moduleTable in ipairs(self.modules) do
		moduleTable:Initialize()
	end
	for _, moduleTable in ipairs(self.modules) do
		if moduleTable.Finalize then
			moduleTable:Finalize()
		end
	end
end

function Harvest.OnLoad(eventCode, addOnName)
		
	if addOnName ~= "HarvestMapConsole" then
		return
	end
	
	Harvest:InitializeModules()
	
	--Harvest:Info(Harvest.GenerateSettingList())
	
end

EVENT_MANAGER:RegisterForEvent("HarvestMap", EVENT_ADD_ON_LOADED, Harvest.OnLoad)
