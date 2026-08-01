-----------------------------------------------------------------------------------
-- Addon Name: Rulebased Inventory
-- Creator: TaxTalis, demawi
-- Addon Ideal: user-defined rule-based actions for inventory application
-- Addon Creation Date: September 11, 2018
--
-- File Name: RuleEnvironment.lua
-- File Description: This file manages the environment for rule/function-evaluation
-- 					 it also delivers helper methods for functions
-- Load Order Requirements: before every file that delivers functions or constants
--                          for the rule environment.
--
-----------------------------------------------------------------------------------

-- imports
local RbI = RulebasedInventory
local utils = RbI.Import(RbI.utils)
local dataTypeHandler = RbI.Import(RbI.dataTypeHandler)

-- defs
local ruleEnv = {}
RbI.ruleEnvironment = ruleEnv
local ctx = {}
local executionEnv = {
	ctx = ctx,
	isNaN = RbI.isNaN,
}
setmetatable(executionEnv, {__index = _G})
executionEnv.self = executionEnv
RbI.executionEnv = executionEnv

-- Keys to ignore when the environment is dumped to the user.
local ignoreExecKeys = {}
for key in pairs(executionEnv) do ignoreExecKeys[key] = true end

-- Usage from: Rule+Item
ctx.itemLink = nil  -- deprecated: use ctx.item.link instead
ctx.bag = nil       -- deprecated: use ctx.item.bag instead
ctx.slot = nil      -- deprecated: use ctx.item.slot instead

ctx.taskName = nil
ctx.station = nil
ctx.store = nil
ctx.buyInfo = nil
ctx.task = nil -- object when task starts {}
ctx.item = nil -- object for every item {}
ctx.amountHelper = { -- Usage from: Rule+Item+Task
	count={}
}
ctx.zoneTypes = {"overland"} -- no API function to retrieve it so we need to grab it partly from EVENT_PREPARE_FOR_JUMP (InstanceDisplayType) and save it, stored in character settings

ruleEnv.GET_BOOL = "getbool" -- functions without inputs and boolean return type
ruleEnv.GET_INT = "getint" -- functions without inputs and int return type
ruleEnv.GET_STRING = "getstring" -- functions without inputs and string return type
ruleEnv.GET_LINK = "getlink" -- functions without inputs and itemLink return type
ruleEnv.MATCH_FILTER = "matchfilter" -- functions with key-string-inputs and string return type
ruleEnv.MATCH_MATRIX = "matchmatrix" -- functions with key-string-inputs and multiple string return type
ruleEnv.NI_BOOL = "nibool" -- @NotItemRelated functions with inputs and boolean return type
ruleEnv.NI_INT = "niint" -- @NotItemRelated functions with inputs and int return type

-- one of the following tags have be specified for registering a function
ruleEnv.NEED_BAGSLOT = "needbagslot" -- functions that needs bag and slot and can not give informations about itemLinks only
ruleEnv.NEED_LINKONLY = "needlinkonly" -- functions that need only
ruleEnv.NEED_NOITEM = "neednoitem" -- functions that need only

function GetAllCharNames()
	local result = {}
	for i = 1, GetNumCharacters() do
		local charName = GetCharacterInfo(i)
		-- under some conditions SI_UNIT_NAME won't uppercase the first character, so we're using <<C:1>> here like CraftStore
		charName = zo_strformat("<<C:1>>", charName)
		result[#result+1] = charName
	end
	return result
end

local me = RbI.GetUnitName('player')
local allchars = GetAllCharNames()
executionEnv.defaultchars = allchars -- should be user-editable in the future

-- returns a callable function
function ruleEnv.Compile(content)
	if(content == '') then
		return function() return false end, nil
	else
		if(RbI.account.settings.casesensitiverules == false) then
			content = string.lower(content)
		end
		local result, err = zo_loadstring('return (' .. content .. ')')
		setfenv(result, executionEnv)
		return result, err
	end
end

local functionStack = {}
function ruleEnv.getStackTrace()
	local stackTrace = {}
	for k,v in pairs(functionStack) do
		stackTrace[k] = v
	end
	return stackTrace
end

ruleEnv.INVALID_ITEMLINK_RETURN_VALUE = "|h"
local function isItemLink(arg)
	return arg~=nil and type(arg) == "string" and utils.startsWith(arg:lower(), "|h")
end
local function isValidItemLink(arg)
	return arg ~= ruleEnv.INVALID_ITEMLINK_RETURN_VALUE
end

-- not recursive. Flattens only ipairs-tables with depth=1. So a table within a table won't be flatten.
-- first argument can be an item-reference
local function flattenArguments(...)
	local optItemLink
	local firstArgumentIndex = 1
	if(isItemLink(...)) then
		firstArgumentIndex = 2
		optItemLink = select(1, ...)
	end
	local args = {}
	for _, cur in ipairs({select(firstArgumentIndex, ...)}) do
		if(type(cur) == 'table') then
			for _, cur2 in ipairs(cur) do
				args[#args+1] = cur2
			end
		else
			args[#args+1] = cur
		end
	end
	return args, optItemLink
end

local function setItemContext(itemRef)
	if(itemRef == nil) then
		ctx.item = nil
		ctx.itemLink = nil
		ctx.bag = nil
		ctx.slot = nil
	else
		ctx.item = itemRef
		ctx.itemLink = itemRef.link
		ctx.bag = itemRef.bag
		ctx.slot = itemRef.slot
	end
	return itemRef
end
local MAX_STACK = 30
local function wrapFunction(name, fn)
	return function(...)
		local args, optItemLink = flattenArguments(...)
		-- inside ruleEnvironment execution so use specific errors
		table.insert(functionStack, {name, args})
		local status, result
		if(#functionStack > MAX_STACK) then
			status, result = pcall(ruleEnv.error, 'Stack overflow error! #'..#functionStack..' (only '..MAX_STACK..' are permitted)')
		elseif(optItemLink and isValidItemLink(optItemLink)) then
			local previousItem = ctx.item
			setItemContext({
				link = optItemLink
			})
			status, result = pcall(fn, unpack(args))
			setItemContext(previousItem)
		else
			status, result = pcall(fn, unpack(args))
		end
		table.remove(functionStack)
		if(not status) then -- we have an error in a function :o
			if(type(result) == "string") then -- unexpected error
				ruleEnv.error(nil, result)
			else -- is already a RbI-Error: so just keep throwing
				error(result)
			end
		end
		return result
	end
end

local function GetCurrentFunction()
	return functionStack[#functionStack][1]
end
local fnTypes = {}
-- Registers a function to the executionEnvironment
-- @param ... function-tags like ruleEnv.GET_BOOL..
function ruleEnv.Register(origName, fn, ...)
	local name = string.lower(origName)
	if (rawget(executionEnv, name) ~= nil) then
		error("Function '" .. name .. "' is already registered!")
	end
	local wrappedFn = wrapFunction(name, fn)
	local needIsSpecified = false
	for _, fnTag in pairs({...}) do
		if(fnTag ~= nil) then
			if(fnTag == ruleEnv.NEED_BAGSLOT or fnTag == ruleEnv.NEED_LINKONLY or fnTag == ruleEnv.NEED_NOITEM) then
				if(needIsSpecified == true) then
					error("Need for function "..origName.." is specified twice!")
				end
				needIsSpecified = true
			end
			local map = fnTypes[fnTag]
			if(map == nil) then
				map = {}
				fnTypes[fnTag] = map
			end
			map[#map+1] = origName
		end
	end
	if(not needIsSpecified) then
		error("Need for function "..origName.." isn't specified! Please use ruleEnv.NEED_BAGSLOT, ruleEnv.NEED_LINKONLY or ruleEnv.NEED_NOITEM to tag the function!")
	end
	executionEnv[name] = wrappedFn
	executionEnv[origName] = wrappedFn
	return fn
end

function ruleEnv.GetTagged(tag)
	return fnTypes[tag]
end

function ruleEnv.HasTag(functionName, tag)
	functionName = functionName:lower()
	for _, origFnName in ipairs(fnTypes[tag]) do
		if(functionName == origFnName:lower()) then
			return true
		end
	end
	return false
end

function ruleEnv.RegisterInternalRule(name, content)
	if(RbI.rules.internal[name] ~= nil) then
		error("Internal rule '"..name.."' is already registered!")
	end
	RbI.rules.internal[name] = RbI.BaseRule(name, false, content)
end
function ruleEnv.UnregisterInternalRule(name)
	RbI.rules.internal[name] = nil
end

function ruleEnv.CreateUserRule(name)
	if(RbI.rules.internal[name] ~= nil) then
		error("User rule '"..name.."' is already registered!")
	end
	RbI.PersistentRule(name)
end

function ruleEnv.RenameUserRule(from, to)
	-- runtime rule
	RbI.rename(RbI.rules.user, from:lower(), to:lower())
	RbI.rules.user[to:lower()].Rename(to:lower())
    -- rule persistence
	RbI.rename(RbI.account.rules, from, to)
end

function ruleEnv.RunRule(rule)
	local status, result = pcall(ruleEnv.EvaluateRule, rule)
	if(status == false) then
		RbI.RuleErrorHandler(rule, result)
	end
	return result
end

-- should be the only way to set/unset ruleEnv-bag/slot/itemLink/taskName-Variables
-- currently needs a safe call 'fn'-function which returns: status, result
function ruleEnv.RunRuleWithItem(rule, bag, slot, itemLink, taskName)
	setItemContext({
		bag = bag,
		slot = slot,
		link = itemLink
	})
	ctx.taskName = taskName
	local status, result = pcall(ruleEnv.EvaluateRule, rule)
	setItemContext(nil)
	ctx.taskName = nil
	if(status == false) then
		RbI.RuleErrorHandler(rule, result)
	end
	return status, result
end

function ruleEnv.RunFunctionWithItem(bag, slot, itemLink, functionName, ...)
	setItemContext({
		bag = bag,
		slot = slot,
		link = itemLink
	})
	local status, result = pcall(executionEnv[functionName], ...)
	setItemContext(nil)
	if(status == false) then
		error(result)
	end
	return result
end

-- Looks at the rule runtime environment, gathers as much information as it can and returns it as string
local function getRunEnvironmentAsString()
	local constants = {}
	local functions = {}
	for key, value in pairs(executionEnv) do
		if(type(value) == 'function') then
			functions[key] = value
		elseif(not ignoreExecKeys[key]) then
			constants[key] = value
		end
	end
	local result = {}
	result[#result+1] = ">>Constants<<"
	for key, value in RbI.utils.spairs(constants) do
		result[#result+1] = ''..tostring(key)..' = '..RbI.utils.ArrayValuesToString(value)
	end

	result[#result+1] = "\n>>Functions<<"
	for key, value in RbI.utils.spairs(functions) do
		result[#result+1] = tostring(key)
	end
	return table.concat(result, '\n')
end

-- evaluate rule and fetch syntax errors
function ruleEnv.EvaluateRule(rule)
	if(rule.GetCompileError()) then
		error(ruleEnv.GetRuleError(rule, rule.GetCompileError(), rule.GetCompileError()))
	end
	local status, result = pcall(rule.Evaluate) -- result= true/false. No multivalue call.
	if(not status) then error(ruleEnv.GetRuleError(rule, result)) end
	return result
end

function ruleEnv.GetRuleError(rule, result, message)
	if(type(result) == "string") then -- hide lua stacktrace, we have our own
		result = {
			message = message and 'Syntax error: '..message
					  or 'Unknown term.',
			stackTrace = ruleEnv.getStackTrace(),
			addition="Following constants/functions can be used:\n"..getRunEnvironmentAsString()..'\n\nFurther informations at: '..RbI.wikiLink
		}
	end
	if(result.ruleName == nil) then
		result.ruleName = rule.GetName()
	end
	if(result.taskName == nil) then
		result.taskName = ctx.taskName
	end
	if(result.ruleContent == nil) then
		result.ruleContent = rule.GetContent()
	end
	return result
end

function ruleEnv.Test(ruleName, content)
	local status, result
	RbI.AddMessageToQueueStart('Rule ' .. ruleName, 'RuleTest', true)
	if(content == '') then
		content = '\n' -- force rule to be executed with an error, we want the syntax error output here
	end
	RbI.testrun = true
	ctx.task = {}
	for _, bagFrom in pairs({BAG_BACKPACK, BAG_BANK, BAG_SUBSCRIBER_BANK, BAG_VIRTUAL, BAG_WORN, BAG_COMPANION_WORN}) do
		RbI.BagIteration(bagFrom, function(slotFrom)
			if(HasItemInSlot(bagFrom, slotFrom)) then
				local itemLink = GetItemLink(bagFrom, slotFrom)
				ctx.amountHelper = {}
				ctx.amountHelper.count = {}
				setItemContext({
					bag = bagFrom,
					slot = slotFrom,
					link = itemLink,
				})
				local rule = RbI.BaseRule(ruleName, true, content)
				status, result = ruleEnv.RunRuleWithItem(rule, bagFrom, slotFrom, itemLink, nil)

				setItemContext(nil)
				if(status) then
					if(result) then
						RbI.AddMessageToQueue('Rule ' .. ruleName, 'RuleTest', true, itemLink, 1, false)
					end
				else
					return false -- break iteration
				end
			end
		end)
		if(status == false) then
			break
		end
	end
	ctx.task = nil
	RbI.testrun = false
	local message
	if(status == nil) then
		message = 'Test found no items to test on'
	elseif(status == false) then
		message = 'Test canceled: An error ocurred!'
	else
		message = 'Test finished'
	end
	RbI.AddMessageToQueueFinal('Rule ' .. ruleName, 'RuleTest', true, message)
	RbI.PrintQueue('Rule ' .. ruleName)
end

----------------------------------------------------------------------------
-- rule helper methods and errors ------------------------------------------
----------------------------------------------------------------------------

-- Default error with automatically attached stacktrace
function ruleEnv.error(msg, addition, notsupported)
	error({message=msg, stackTrace = ruleEnv.getStackTrace(), addition=addition, notsupported=notsupported})
end

function ruleEnv.errorNeedRequirement(msg)
	ruleEnv.error(msg, nil, true)
end

function ruleEnv.errorAddonRequired(addonname)
	ruleEnv.errorNeedRequirement('Required addon \''..addonname..'\' was not found')
end

function ruleEnv.errorNoInputsAllowed()
	ruleEnv.error("This function doesn't allow inputs")
end

-- new errorInvalidArgument function that also look at language dependent keys
-- 'dataTypeKey' can be nil, string or table(array or map). If string it has to be a valid RbI.dataType-key
local QUOTER = '\''
function ruleEnv.errorInvalidArgument(argIndex, input, dataTypeKey, typeName)
	local addition
	if(dataTypeKey == nil) then
		-- nothing to do
	elseif(type(dataTypeKey) == 'table') then
		if (utils.isArray(dataTypeKey)) then
			addition = 'Valid values are:\n' .. RbI.utils.ArrayValuesToString(dataTypeKey)
		else
			addition = 'Valid values are:\n' .. RbI.utils.ArrayKeysToString(dataTypeKey)
		end
	else
		local validInputs = RbI.dataType[dataTypeKey]
		if (validInputs ~= nil) then
			if(utils.isArray(validInputs)) then -- like charnames
				addition = 'Valid values are:\n' .. RbI.dataKeyFixed(RbI.utils.ArrayValuesToString(validInputs))
			else
				local languageDependent = RbI.collectedData[dataTypeKey]
				local static = RbI.dataTypeStatic[dataTypeKey]
				if(languageDependent == nil) then
					addition = 'Valid values are:\n' .. RbI.dataKeyFixed(RbI.utils.ArrayKeysToString(validInputs))
				else
					local m = {}
					for key, value in utils.spairs(validInputs) do
						local lKeys = dataTypeHandler.GetKeysForValues(languageDependent, value)
						local message
						if(dataTypeHandler.isStaticDataTypeKey(dataTypeKey, key)) then -- is not language dependent key
							message = (message or '') .. RbI.dataKeyFixed(QUOTER .. key .. QUOTER)..', '
							if(#lKeys > 0) then
								message = (message or '') .. RbI.dataKeyLD(RbI.utils.ArrayValuesToString(lKeys, nil, QUOTER))..','
							end
						else
							local sKeys = dataTypeHandler.GetKeysForValues(static, value)
							if(#lKeys > 0 and #sKeys == 0) then
								message = (message or '') .. RbI.dataKeyLD(RbI.utils.ArrayValuesToString(lKeys, nil, QUOTER))..','
							end
						end
						m[#m+1] = message
					end
					addition = 'Valid values are:\n' .. table.concat(m, '\n')..'\n\n[Legend: '..RbI.dataKeyFixed(QUOTER.."Static key"..QUOTER)..' '..RbI.dataKeyLD(QUOTER..'Language dependent'..QUOTER)..']'
				end
			end
		end
	end

	typeName = typeName or 'Argument'
	if(argIndex ~= nil) then
		typeName = typeName..' #'..tostring(argIndex)
	end
	if(input == nil) then
		ruleEnv.error('No input was found', addition)
	else
		ruleEnv.error(typeName..': \'' .. tostring(input) .. '\' is not recognized.', addition)
	end
end

-- some functions can only perform on specific items.
function ruleEnv.errorInvalidItem(needs)
	ruleEnv.error('Wrong item: '..ctx.itemLink..'\n'..GetCurrentFunction()..'() works only for \''..needs..'\'')
end

-- Ensures that the arguments have no nil value. (This could happen, when the user misspelled a variable or just forgot the apostrophe for a string)
-- With this method we accept varargs as long as predefined table-variables.
-- @param typeName will be shown when an error occurs
-- @param isRequired if true the function will throw an error, when there are no inputs in the varargs-argument
-- @param dataTypeKey optional string or table(array or map), if dataTypeKey is given the data will be verified against the given dataType
-- @return argument[1], if argument[1] is a table
--         arguments as validated and mapped table, when dataTypeKey is given
--         arguments only lowered, otherwise
local function GetArguments(typeName, isRequired, dataTypeKey, addFn, ...)
	local validInputs
	if(dataTypeKey == nil) then
		-- nothing to do
	elseif(type(dataTypeKey) == 'table') then
		validInputs = dataTypeKey
	else
		validInputs = RbI.dataType[dataTypeKey]
	end
	if(dataTypeKey ~= nil and validInputs == nil) then
		error("Validinputs required") -- fire as unexpected error
	end
	local args = {...}
	typeName = typeName or 'Argument'
	if(#args ~= select('#', ...)) then -- we got a nil value
		for i=1, select('#', ...) do -- search for it
			if(select(i, ...) == nil) then
				ruleEnv.errorInvalidArgument(i, nil, dataTypeKey, typeName)
			end
		end
	end
	if(#args == 0) then
		if(isRequired) then
			ruleEnv.errorInvalidArgument(nil, nil, dataTypeKey, typeName)
		end
	else -- #args > 0
		if(type(args[1]) == "table") then
			return args[1] -- already validated and mapped
		end
		if(dataTypeKey == nil) then -- no mapping, only lower
			local result = {}
			for _, curArg in ipairs(args) do
				addFn(result, string.lower(curArg))
			end
			return result
		elseif(utils.isArray(validInputs)) then -- has to be a dynamic dataType string-array (like armory-build-names)
			local result = {}
			for i, curArg in pairs(args) do
				local valid = utils.TableSearchValueIgnoreCase(validInputs, curArg)
				if(not valid) then
					ruleEnv.errorInvalidArgument(i, curArg, dataTypeKey, typeName)
				end
				addFn(result, valid)
			end
			return result
		else -- is data mapping
			local result = {}
			for i, curArg in ipairs(args) do
				curArg = string.lower(curArg)
				local mapped = validInputs[curArg]
				if(mapped == nil) then
					ruleEnv.errorInvalidArgument(i, curArg, dataTypeKey, typeName)
				elseif(type(mapped) == 'table') then -- multi value mapping, like trait "intricate", which includes "armor_intricate", "weapon_intricate", "jewelry_intricate"
					for _, curValue in pairs(mapped) do
						addFn(result, curValue)
					end
				else
					addFn(result, mapped)
				end
			end
			return result
		end
	end
	return args
end

local arrayAdd = function(table, entry) table[#table+1] = entry end
-- return the arguments as array
function ruleEnv.GetArguments(typeName, isRequired, dataTypeKeyOrTable, ...)
	return GetArguments(typeName, isRequired, dataTypeKeyOrTable, arrayAdd, ...)
end

local mapAdd = function(table, entry) table[entry] = true end
-- return the arguments as map
function ruleEnv.GetArgumentsMap(typeName, isRequired, dataTypeKeyOrTable, ...)
	return GetArguments(typeName, isRequired, dataTypeKeyOrTable, mapAdd, ...)
end

function ruleEnv.GetNumberArguments(typeName, isRequired, ...)
	local args = {...}
	if(#args ~= select('#', ...)) then -- we got a nil value
		for i=1, select('#', ...) do
			if(select(i, ...) == nil) then
				ruleEnv.errorInvalidArgument(i, nil, nil, typeName)
			end
		end
	end
	if(#args == 0) then
		if(isRequired) then
			ruleEnv.errorInvalidArgument(nil, nil, nil, typeName)
		end
	else -- #args > 0
		if(type(args[1]) == "table") then
			return args[1] -- already validated and mapped
		end
	end
	return args
end

-- @return the given ... characterNames as table (names lowered in rulestring)
--         if not given the defaults will be used
--         'defaultchars' for defaultAll == true
--         'me' for defaultAll == false
-- the names are validated if they are correctly written
local function GetCharactersNamesIntern(defaultAll, isOptional, ...)
	local charNames = ruleEnv.GetArguments('CharacterName', false, 'charName', ...)
	if(#charNames == 0) then
		if(defaultAll ~= nil) then
			if(defaultAll) then
				return executionEnv.defaultchars -- already validated
			else
				return {me} -- already validated
			end
		elseif(not isOptional) then
			ruleEnv.errorInvalidArgument(nil, nil, 'charName', 'CharacterName')
		end
	elseif(defaultAll and #charNames == 1) then
		d("Hint: You are using an \'..inorder\'-function with only one argument. The function without 'inorder' will produce the same result, but is more efficient")
	end
	return charNames
end
function ruleEnv.GetCharactersNames(defaultAll, ...)
	return GetCharactersNamesIntern(defaultAll, false, ...)
end
function ruleEnv.GetCharactersNamesOptional(defaultAll, ...)
	return GetCharactersNamesIntern(defaultAll, true, ...)
end

-- @return if one of the input matching one itemData in the list
local function IsIncludedInList(itemDatas, inputs)
	if((#inputs == 0) ~= (#itemDatas == 0)) then
		return false
	elseif(#inputs == 0) then
		return true
	end
	for _, input in ipairs(inputs) do
		for _, itemData in ipairs(itemDatas) do
			if(itemData == input) then return true end
		end
	end
	return false
end

local function mapItemDatas(dataType, itemData)
	if(type(dataType)=="string") then
		return RbI.dataTypeHandler.GetKeysForValues(RbI.dataTypeStatic[dataType], itemData)
	else
		return itemData
	end
end

-- @param typeName will be shown when an error occurs
-- @param isRequired if true the function will throw an error, when there are no inputs in the varargs-argument
--                   if false the mapped itemData will be returned
-- @param dataTypeKeyOrTable optional string or table(array or map), if dataTypeKey is given the data will be verified against the given dataType
-- @param itemDatas can be a direct value or table-array value-list
function ruleEnv.Validate(typeName, isRequired, dataTypeKeyOrTable, itemDatas, ...)
	local input = ruleEnv.GetArguments(typeName, isRequired, dataTypeKeyOrTable, ...)
	if(isRequired == false and #input == 0) then return mapItemDatas(dataTypeKeyOrTable, itemDatas) end
	if(type(itemDatas) ~= "table") then itemDatas = {itemDatas} end
	return IsIncludedInList(itemDatas, input)
end
function ruleEnv.ValidateNumbers(typeName, isRequired, itemDatas, ...)
	local input = ruleEnv.GetNumberArguments(typeName, isRequired, ...)
	if(isRequired == false and #input == 0) then return itemDatas end
	if(type(itemDatas) ~= "table") then itemDatas = {itemDatas} end
	return IsIncludedInList(itemDatas, input)
end