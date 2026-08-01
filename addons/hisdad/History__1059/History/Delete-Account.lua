-- The MIT License (MIT) http://opensource.org/licenses/MIT
-- Copyright (c) 2014-2016 His Dad

-- Some code from the luatz project (MIT Licence)
--[[
Utility to delete old Accounts

]]



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

-- Localisations
local path = "./data/" .. lang .. "/" .. lang .. "-ui.lua"
dofile (path)





function select_account()
	local selected
		if naccounts >1 then
			selected = iup.ListDialog (1, L.ChooseAccounttoDelete,
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

 -- Need two or more accounts
if naccounts < 2  then
	iup.Message("",L.NoAccount)
	iup.Close()
	os.exit()
end




-- Create dialog to choose account
account=select_account()
-- Not selected, quit.
if account == nil then
	iup.Close()
	os.exit()
end


confirm=  iup.messagedlg{
  dialogtype = "QUESTION",
  buttons = "OKCANCEL",
  buttondefault = 2,
  title = L.Delete .. "  " .. L.Account,
  value = L.Delete .. " " .. account
  }

confirm:popup()
-- Button "1" is "OK"

if iup.GetAttribute(confirm, "BUTTONRESPONSE") ~= "1" then
	iup.Close()
	os.exit()
end

backfile=os.date("History-"..dateformat_log .. ".lua")
os.execute( "md ..\\..\\SavedVariables\\History_Bak" )  -- fails silently if already exists.
os.execute("copy  ..\\..\\SavedVariables\\History.lua ..\\..\\SavedVariables\\History_Bak\\" .. backfile)

newf = assert(io.open("../../SavedVariables/History.new", "w"))
-- ==============
-- Erase Account

History_SV["Default"][account] = nil

--Dump it back out
newf:write("History_SV=" .. write_saved(History_SV))
newf:close()

os.execute("del  ..\\..\\SavedVariables\\History.lua")
os.execute("rename  ..\\..\\SavedVariables\\History.new history.lua")

os.execute("del  .\\my\\visibility.lua")



