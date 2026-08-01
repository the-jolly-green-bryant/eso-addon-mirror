--local dateformat = "%Y-%m-%d, %H:%M"
FG_Colour_Not_Complete = "#FFB67D"
FG_Colour_Complete = "#000000"
BG_Colour_Not_Complete = "#FFB67D"
BG_Colour_Complete = "#A4FF5A"
Colour_Heading_Complete = "#58FA58"
DefWidth = 120		-- data column width for dungeon Columns
Settings_s ="./my/visibility.lua"
msg=".  Rage Quit Edition. Still Raging."
--msg=".  For TheAutumnWind."

version= "97"
update="50"



log = function (msg)
	if debug then
		print(msg)
	end
end



function dump(tbl, indent)
  indent = indent or 0
  local result = ""

  for k, v in pairs(tbl) do
    local formatting = string.rep(" ", indent) .. k .. ": "
    if type(v) == "table" then
      result = result .. formatting .. "\n"
      result = result .. dump(v, indent + 2)
    elseif type(v) == "boolean" then
      result = result .. formatting .. tostring(v) .. "\n"
    else
      result = result .. formatting .. tostring(v) .. "\n"
    end
  end

  return result
end




dumpf = function (o, fname)
	fname = fname or "dump-file.txt"
	outfile=io.open(fname, "w")
	if outfile == nil then
		print("dumpf: Could not open " .. fname .. " for writing.")
		return
	end

	outfile:write(dump(o))
	outfile:close()
end

-- Minimally effective quoting
quote = function (astring)
    local quoted1 = string.gsub(astring,'\"', '\\"')
    local quoted2 = '"' .. string.gsub(quoted1,"%'", "\\'") .. '"'
	local linefeed = string.gsub(quoted2,"\n", "\\n")
	return linefeed
end


write_saved = function (o)
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

_size = function (t)		-- return number of elements in table
	local i = 0
	for _,_ in pairs(t) do
		i = i +1
	end
	return i
end



load_visibility=function()
	-- print("Setting file is " .. Settings_s)
	-- local infile=io.open(Settings_s,r)
	-- if infile == nil then
		-- print ("Couldn't open " .. Settings_s .. " for reading.")
		-- return
	-- end
	-- infile:close()
	-- for line in io.lines(Settings_s) do
		-- print(line)
	-- end


	local f,err= loadfile(Settings_s)		--may not exist
	if f then
		f()
	else
		print("Settings file not loaded. Err: " .. err)
	end
end


save_visibility=function()
	local outfile = io.open(Settings_s, "w")
	if outfile == nil then
		print ("Couldn't open " .. Settings_s .. "  file for writing.")
		return false
	end


	for playerID, thischar in pairs (account_t.data) do
		outfile:write("account_t.data[\"" .. playerID .. "\"].visible=" .. tostring(thischar.visible) .. "\t-- " .. thischar.name .. "\n")
	end	 --player

	io.close(outfile)
end

generate_id=function()
--write a combined list of achievement id we look for to add to the in-game part (cut and paste) for filtering
    local unique_id= {}   -- (id,true}
	print("Generating ids.lua")
	local outfile=io.open("data/ids.lua", "w")

	if outfile == nil then
		print ("Couldn't open data/ids.lua file for writing.")
	end
	outfile:write("hist.IDVersion=" .. quote(version) .. "\n")

	outfile:write("hist.IDs = {" .. "\n")

	for _,i in ipairs(Order) do
		outfile:write("--  " .. i ..  "\n")
		for _,j in ipairs (Dat[i].dat) do
		    if unique_id[j] == nil then
				unique_id[j] = true
				outfile:write("[" .. j .. "] = true,\n")
				else print("Order " .. i .. " Ach " .. j .. " doubled up")
			end
		end
	end


	outfile:write("-- SQ " .. "\n")
	for j,_ in pairs (SQ_dat) do
		    if unique_id[j] == nil then
				unique_id[j] = true
				outfile:write("[" .. j .. "] = true,\n")
				else print("SQ  Ach " .. j .. " doubled up")
			end
	end


	outfile:write("-- WB " .. "\n")
	for j,_ in pairs (WB_dat) do
		    if unique_id[j] == nil then
				unique_id[j] = true
				outfile:write("[" .. j .. "] = true,\n")
				else print("WB  Ach " .. j .. " doubled up")
			end
	end

	outfile:write("-- Specials " .. "\n")
	for j,_ in pairs (Special_dat.dat) do
		    if unique_id[j] == nil then
				unique_id[j] = true
				outfile:write("[" .. j .. "] = true,\n")
				else print("Specials  Ach " .. j .. " doubled up")
			end
	end

for i,dlc in ipairs (DLC_Order.dat) do
		outfile:write("-- DLC  " .. dlc .. "\n")

	for _,j in ipairs (DLC_Dat[dlc].dat) do
		    if unique_id[j] == nil then
				unique_id[j] = true
				outfile:write("[" .. j .. "] = true,\n")
				else print("DLC " .. dlc .. " Ach " .. j .. " doubled up")
			end
	end


end
	outfile:write("}" .. "\n")
	outfile:close()
end


--Run through Location data to get the info needed to dimension the WB and SQ boxes
--Columns are AreaName, Name, Description
-- parameter "name is Either WB or SQ
Location_Box = function (thischar,name)

	-- log("Location Box ")
	local cols = {}
	local lines = {}
	local return_t = iup.matrix{}

	if name == "WB" then
		for Area,Data in pairs(Area_names) do
			if Data.WB ~= nil then
				for _,Ach in ipairs (Data.WB) do
					table.insert(lines,{Area=Area, Ach=Ach})
				end
			end
		end
		return_t.numcol=3
    end
	if name == "SQ" then   -- Extra Column
		for Area,Data in pairs(Area_names) do
			if Data.SQ ~= nil then
				for _,Ach in ipairs (Data.SQ) do

					table.insert(lines,{Area=Area, Ach=Ach, Link='"' .. SQ_dat[Ach].link1 .. '"'})
				end
			end
		end
		return_t.numcol=4
    end


	return_t.numlin=#lines


	iup.SetAttribute(return_t, "READONLY", "YES")
	iup.SetAttribute(return_t, "ALIGNMENT0", "ACENTER")
	iup.SetAttribute(return_t, "WIDTH1", 80)	-- Location
	iup.SetAttribute(return_t, "WIDTH2", 110)	-- Name
	iup.SetAttribute(return_t, "WIDTH3", 350)   -- Description
	iup.SetAttribute(return_t, "WIDTH4", 250)   -- Link	SQ Only
	iup.SetAttribute(return_t, "ALIGNMENT3", "ALEFT")
	iup.SetAttribute(return_t, "ALIGNMENT4", "ALEFT")
	-- Set Headings
	return_t:setcell(0,0, L.Ach_ID)
	return_t:setcell(0,1, L.Location)
	return_t:setcell(0,2, L.Achievement)

	--Set Lines

	for line,Data in ipairs(lines) do
		return_t:setcell(line,0, tostring(Data.Ach))
		return_t:setcell(line,1, tostring(Area_names[Data.Area].name))
		return_t:setcell(line,2, tostring(Ach_Detail[Data.Ach].name))
		return_t:setcell(line,3, tostring(Ach_Detail[Data.Ach].description))
		if Data.Link ~=nil  then
			return_t:setcell(line,4, tostring(Data.Link))
		end

		if thischar.ach[Data.Ach] ~= nil then
				iup.SetAttribute(return_t,  "BGCOLOR" .. tostring(line) .. ":*", BG_Colour_Complete)
		else
				iup.SetAttribute(return_t,  "BGCOLOR" .. tostring(line) .. ":*", BG_Colour_Not_Complete)
		end

	end


	function return_t:click_cb (Line,C)
		if C == 4 then
			iup.Help(self:getcell(Line,C))		-- Launch Browser
		else
			return IUP_IGNORE
		end
	end
	return return_t
end




--for filtering
select_box=function ()


	local marks_t = {}
	local names_t = {}
	local player_t={}

	-- load existing settings. use sort order
	for _,PlayerID in ipairs(PlayerIDs) do

		table.insert(marks_t,account_t.data[PlayerID].visible)
		table.insert(names_t,account_t.data[PlayerID].name)
		table.insert(player_t,PlayerID)
	end

	-- dumpf(marks_t,"marks-start.txt")
	-- dumpf(names_t,"names-start.txt")

	-- the dialog loads with pre-existing setting and the user updates them.
	local error = iup.ListDialog(2,L.Filter, nplayers , names_t,0,1,nplayers, marks_t)

	-- marks_t  now updated,
	if error == -1 then
		log("Dialog error")
		return false
	end

	-- dumpf(marks_t,"marks-after.txt")
	-- dumpf(names_t,"names-after.txt")

	-- update the char from marks_t

	for i, PlayerID in  ipairs(player_t) do
			-- print("update " .. account_t.data[PlayerID].name .. " to " ..  tostring((marks_t[i]))
			account_t.data[PlayerID].visible = marks_t[i]
	end

	save_visibility()


	for _, ADung in pairs (dung) do	-- for each dungeon

		for col,PlayerID in ipairs(PlayerIDs) do

			if account_t.data[PlayerID].visible ~= 0 then
				iup.SetAttribute(ADung.box, "WIDTH"..tostring(col+2) ,tostring(DefWidth))
			else
				iup.SetAttribute(ADung.box, "WIDTH"..tostring(col+2) ,"0")
			--	print("Hiding " .. account_t.data[PlayerID].name .. " in dung " .. ADung.name)
			end
		end
	end



	return true
end


--Check that our data files are are consistent.

sanity_check = function (dat_t)
	local name = dat_t.name
	local Achs = dat_t.dat

	if (name ~=nil and Achs ~= nil) then  -- has metadata
		print("Sanity Checking: " .. name )
	end

	if #dat_t.dat == 0 then
		print("#dat_t.dat  is zero")
		return
	end

	for _,Ach in ipairs (Achs) do
		if Ach_Detail[Ach] == nil then
			print("Achievement ID " .. Ach .. " Not found")
		end
	end
end

--Forward Reference
if DLC_Names == nil then
	DLC_Names={}
end

my_name = function(dlcname)
-- return a privately translated DLC name, or the language translated default.

	if type(dlcname) ~= "string" then
		log("my_name needs  a string")
		return "ERROR"
	end

	local default_translation = DLC_Names[dlcname]
	if default_translation == nil then
		log("Error: translation of " .. dlcname .. " does not exist.")
	end

	if type(MyDLC_Names) ~= "table" then return default_translation end

	local mine = MyDLC_Names[default_translation]
	if mine ~= nil then return mine
	else return default_translation
	end

end

