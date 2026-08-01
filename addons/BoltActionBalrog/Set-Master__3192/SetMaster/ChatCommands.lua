ChatCommands = {}
local This = ChatCommands

local function ExtractCommaDelimArgs(InString)
	local Options = {}
	local SearchResult = { string.match(InString,"([^,]+)%s*") }
	for i,v in pairs(SearchResult) do
		if (v ~= nil and v ~= "") then
			Options[i] = v
		end
	end
	
	return Options
end

function This.DeleteCharacter(InString)
	local Args = ExtractCommaDelimArgs(InString)
	if #Args < 1 then
		d("Provide the name of the character to delete.")
		return
	end
	
	PlayerSetDatabase:DeleteCharacter(Args[1])
end

SLASH_COMMANDS["/setmasterdeletecharacter"] = ChatCommands.DeleteCharacter
--SLASH_COMMANDS["/printmoc"] = ChatCommands.PrintMoc