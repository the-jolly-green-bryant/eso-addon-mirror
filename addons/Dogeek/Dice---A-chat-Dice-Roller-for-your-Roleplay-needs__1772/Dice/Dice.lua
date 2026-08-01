--[[
Addon Name : Dice
Addon Author : Dogeek
Addon Description : Dice is a dice roller for ESO. Type in /dice xdy to roll x die with y faces.
]]--

--namespace declaration
Dice = {}
Dice.name = "Dice"
Dice.version = 2

--DEFAULT SETTINGS
Dice.Default = {}
Dice.Default.verbose = true
Dice.Default.locale = "en"
--globals
local d = d
local strsplit = zo_strsplit
local strjoin = zo_strjoin
local next = next
local getstr = GetString
local format = zo_strformat

-- functions used
local function print(...)
    d(strjoin("", ...))
end

local function sumTable(tbl)
	ret = 0
	for i=1, #tbl do
		ret = ret + tonumber(tbl[i])
	end
	return ret
end


--Addon initialization (nothing yet but it'll come)
function Dice:Initialize()
	Dice.savedVariables = ZO_SavedVars:New("DogeekDiceVars", Dice.version, nil, Dice.Default)
	EVENT_MANAGER:UnregisterForEvent(Dice.name, EVENT_ADD_ON_LOADED)
end
function Dice.OnAddOnLoaded(event, addonName)
  if addonName == Dice.name then
    Dice:Initialize()
  end
end
EVENT_MANAGER:RegisterForEvent(Dice.name, EVENT_ADD_ON_LOADED, Dice.OnAddOnLoaded)


function Dice.OutputResultInChat(results, dice_str, verbose)
	local rolled = sumTable(results)
	local results_str = "{"
	for i=1, #results do
		results_str = results_str..tostring(results[i])
		if i==#results then
			results_str = results_str.."}"
		else
			results_str = results_str..", "
		end
	end
	rolled = tostring(rolled)
	local output_str = ""
	if verbose then
		--output_str = "Dice rolled a "..rolled.." with "..dice_str..". Results : "..results_str
		output_str = format(getstr(DICE_ROLLEDVERBOSE), rolled, dice_str, results_str)
	else
		--output_str = "Dice rolled "..rolled
		output_str = format(getstr(DICE_ROLLED), rolled)
	end
	CHAT_SYSTEM:AddMessage(output_str)
end

function Dice.RollADice(dice_str)
	local num, faces = SplitString("d",dice_str)
	num = tonumber(num)
	faces = tonumber(faces)
	results = {}
	for i=1, num do
		r = math.random(faces)
		table.insert(results, r)
	end
	Dice.OutputResultInChat(results, dice_str, Dice.savedVariables.verbose)
end

function Dice.VerboseSetting(verbose)
	if string.lower(verbose) == "off" then
		Dice.savedVariables.verbose = false
	elseif string.lower(verbose) == "on" then
		Dice.savedVariables.verbose = true
	elseif string.lower(verbose) == "toggle" then
		Dice.savedVariables.verbose = not Dice.savedVariables.verbose
	end
	print("Verbosity changed to "..tostring(Dice.savedVariables.verbose))
end
Dice.commands = {
    ["roll"] = Dice.RollADice,
	["verbose"] = Dice.VerboseSetting,
	["help"] = Dice.SlashCommandHelp
}

function Dice.SlashCommandHelp()
    print("Dice usage:")
	print("- /dice <number of die>d<number of faces>")
    print("- /dice roll <number of die>d<number of faces>")
	print("- /dice verbose <on||off||toggle>")
	print("- /dice help to show this message")
end

function Dice.SlashCommand(argtext)
    local args = {strsplit(" ", argtext)}
    if next(args) == nil then
        Dice.SlashCommandHelp()
        return
    end
	if #args == 1 then -- /dice xdy
		if string.lower(args[1]) == "verbose" then
			Dice.VerboseSetting("toggle")
		else
			Dice.RollADice(unpack(args))
		end
	else
		local command = Dice.commands[string.lower(args[1])]
	    if not command then --/dice <command> <args>
			print(format(getstr(DICE_UNKNOWNCOMMAND), args[1]))
	        --print("Dice: unknown command '", args[1], "'.")
	        Dice.SlashCommandHelp()
	        return
	    end
	    command(unpack(args, 2))
	end
end

--REgister the slash command
if WF_SlashCommand ~= nil then
    -- Register via Wykkyd's framework for those who use it, to allow macroing
    WF_SlashCommand("dice", Dice.SlashCommand)
else
    -- But don't require the framework.
    SLASH_COMMANDS["/dice"] = Dice.SlashCommand
end
