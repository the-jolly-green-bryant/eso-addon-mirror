-- The MIT License (MIT) http://opensource.org/licenses/MIT
-- Copyright (c) 2014-2016 His Dad

-- Some code from the luatz project (MIT Licence)
--[[
Utility to delete old chars

]]


--for version 29 and later


-- Configuration ==========
local dateformat = "%Y-%m-%d, %H:%M"
local dateformat_log = "%Y-%m-%d-%H-%M-%S"

-- ========================
version= "94"
require( "iuplua" )
require( "iupluacontrols" )
iup.SetGlobal("UTF8MODE","YES")
dofile "../../SavedVariables/History.lua"

function dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end


-- Minimally effective quoting
function quote(astring)
    local quoted1 = string.gsub(astring,'\"', '\\"')
    local quoted2 = '"' .. string.gsub(quoted1,"%'", "\\'") .. '"'
	local linefeed = string.gsub(quoted2,"\n", "\\n")
	return linefeed
end


function write_saved(o)
--	local escaped
   if type(o) == 'table' then
      local s = '{\n'
      for k,v in pairs(o) do
         if type(k) ~= 'number' then
		 k = '"'..k..'"'
		 end
         s = s .. '['..k..'] = ' .. write_saved(v) .. ',\n'
      end
      return s .. '}\n'
   elseif
		type(o) == 'string' then
		return quote(o)
   else
		return tostring(o)
   end
end



accounts_list = {}		-- String list for selection dialog
naccounts = 0
for i,j in pairs(History_SV["Default"]) do
	naccounts = naccounts +1
	table.insert(accounts_list, i)
end

if lang == nil then
lang = "en"
end

local path = "./data/" .. lang .. "/" .. lang .. "-ui.lua"
dofile (path)




function select_account()
	local selected
		if naccounts >1 then
			selected = iup.ListDialog (1, L.Account,
					naccounts,	--Size
					accounts_list,
					1, --Initial
					1,naccounts	--MaxCol MaxLine
					)

			if selected <0 then
				return nil		-- Cancelled
			else
				return accounts_list[selected+1]
			end
		else
		return accounts_list[1]		-- only 1 account, no need for Dialog
		end
end


-- Create dialog to choose account
account=select_account()

-- Not selected, quit. should happen, but to be sure
if account == nil then
   print ("Account not Selected")
--	iup.Close()
--	os.exit()
end






playerNames = {}
playerName2ID={}


for playerID, j in pairs(History_SV["Default"][account]["$AccountWide"]["data"]) do
	if j.name == nil then
	-- old Style
		name =  playerID
	else
		name = j.name
	end

	name = name .. " ("
	if j.world ~= nil then
		name = name .. " " .. j.world
	end


	if j.Class ~= nil then
		name = name .. ", " ..j.Class
	end

	if j.Race ~= nil then
		name = name .. ", " .. j.Race
	end


	if j.Alliance ~= nil then
		name = name .. ", " .. j.Alliance
	end

	if j.LoginTime ~= nil then
		LoginTime = os.date(dateformat,j.LoginTime)
		name = name .. " Last: " .. LoginTime
	end

	if j.logins ~= nil then
		name = name .. ", Logins: " .. j.logins
	end
	name = name .. ")"
	table.insert(playerNames, name)
	playerName2ID[name] = playerID

end


-- No players.
if #playerNames ==  0 then
    print ("No Player names")
--	iup.Close()
--	os.exit()
end

selected = iup.ListDialog (1, L.ChooseChartoDelete,
			#playerNames,	--Size
			playerNames,
			1, --Initial
			1,#playerNames--MaxCol MaxLine
			)

if selected <0 then
    print ("not Selected")
--	iup.Close()		-- Cancelled
--	os.exit()
end


playerName = playerNames[selected +1]
playerID =   playerName2ID[playerName]


confirm=  iup.messagedlg{
  dialogtype = "QUESTION",
  buttons = "OKCANCEL",
  buttondefault = 2,
  title = L.Delete .. "  " .. L.Char,
  value = L.Delete .. " " .. playerNames[selected +1]
  }

confirm:popup()
-- Button "1" is "OK"

if iup.GetAttribute(confirm, "BUTTONRESPONSE") ~= "1" then
	iup.Close()
	-- os.exit()
end

backfile=os.date("History-"..dateformat_log .. ".lua")
os.execute( "md ..\\..\\SavedVariables\\History_Bak" )  -- fails silently if already exists.
os.execute("copy  ..\\..\\SavedVariables\\History.lua ..\\..\\SavedVariables\\History_Bak\\" .. backfile)

newf = assert(io.open("../../SavedVariables/History.new", "w"))
-- ==============
-- Erase Character

History_SV["Default"][account]["$AccountWide"]["data"][playerID] = nil

--Dump it back out
newf:write("History_SV=" .. write_saved(History_SV))
newf:close()

os.execute("del  ..\\..\\SavedVariables\\History.lua")
os.execute("rename  ..\\..\\SavedVariables\\History.new history.lua")


os.execute("del  .\\my\\visibility.lua")



