LibAkaUtils = LibAkaUtils or {}

function LibAkaUtils.addCommand(command, func)
	SLASH_COMMANDS["/"..command] = func
end

function LibAkaUtils.executeCommand(command, data)
	if command == nil then return end
	if SLASH_COMMANDS["/"..command] == nil then return end
	SLASH_COMMANDS["/"..command](data)
end