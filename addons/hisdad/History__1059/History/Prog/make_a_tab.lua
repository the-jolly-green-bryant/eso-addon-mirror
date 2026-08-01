--[[ generates the Achievement list of each type of Dungeon for the Selected Character.
Like "Public"  "Group1"   Not Skill Quests or World Bosses

name_s  is Tab Name as displayed
parent  is parent iup container to which we append it. (list of tabs) it is type "userdata"
dat_t   is the Achievement data file as a table

It then appends it to the iup table list which is parent
--]]

set_headings = function (this)
	this.box:setcell(0, 1, L.Ach_ID)
	this.box:setcell(0, 2, L.Achievement)
	
	iup.SetAttribute(this.box,"WIDTH1", 50)		--Size is about 1/4 of character
	iup.SetAttribute(this.box,"WIDTH2", 130)

	iup.SetAttribute(this.box,"ALIGNMENT1", "ACENTER")
	iup.SetAttribute(this.box,"ALIGNMENT2", "ALEFT")

end



make_a_tab = function(thischar, parent, name_s,dat_t)	-- Called per char

	local wrap_size = math.floor(250/3.7)

	if (debug) then  -- 

		if type(parent) ~= "userdata" then 
			print("make_a_tab() called with bad parent. parent must be iup container")
		end
		
		if type(dat_t) ~= "table" then 
			print("make_a_tab() called with bad dat_t. Type is " .. type(dat_t) )
		end
		
		if type(name_s) ~= "string" then 
			print("make_a_tab() called with bad name_s. Type is " .. type(name_s) )
		end
		
		if dat_t.name then 
		--	print("dat_t has name field " .. dat_t.name .. ". name_s is " .. name_s)
		else
			print("dat_t lacks name field.  name_s is " .. name_s)
		end
		
		if dat_t.dat then 
		else
			print("dat_t lacks .dat field.  name_s is " .. name_s)
		end
		
		if #dat_t.dat > 0 then 
		else
			print("dat_t.dat has no data,  name_s is " .. name_s)
		end

	end
	
	
	local this = {}
	this.box = iup.matrix {READONLY="YES",numcol=4, numcol_visible=4, numlin=#dat_t.dat}

	this.box.name= name_s
	iup.SetAttribute(this.box,  "BGCOLOR" , BG_Colour_Not_Complete)

	--set Headings
	set_headings(this)

	iup.SetAttribute(this.box,"WIDTH3", 260)		--Size is about 1/4 of character

	iup.SetAttribute(this.box,"ALIGNMENT3", "ALEFT")
	iup.SetAttribute(this.box,"ALIGNMENT4", "ALEFT")

	this.box:setcell(0, 4, L.Completed)



	--Load Possible Achievements
	for line, Ach in ipairs (dat_t.dat) do  -- Load text
	if (Ach_Detail[Ach] == nil) then
			-- pre tested for, shouldn't be possible
			print("make_a_tab: Box: " .. name_s .. ", Achievement: " .. Ach .. " has no record in Ach_Detail")
		else
			this.box:setcell(line,1,Ach)
			this.box:setcell(line,2,Ach_Detail[Ach].name)

			local description = Ach_Detail[Ach].description
			if type(description) ~= "string" then description = "MISSING"	end
				
			local split = split_w(Ach_Detail[Ach].description)			-- Split into array of words
			local flow  = flow_w(split, wrap_size)
			this.box:setcell(line, 3, join_s(flow))
			iup.SetAttribute(this.box,"FITTOTEXT", "L".. tostring(line))
		end
	end

	-- Load Achievements, set colour
	
	for line, Ach in pairs (dat_t.dat) do
		local bgcolour = "BGCOLOR" .. tostring(line) .. ":*"
		if thischar.ach[Ach] ~= nil then		-- yes I have it..
			iup.SetAttribute(this.box, bgcolour, BG_Colour_Complete)
			this.box:setcell(line,4, os.date(dateformat,thischar.ach[Ach].time))
		else
			iup.SetAttribute(this.box, bgcolour, BG_Colour_Not_Complete)	-- Contents of Completed On are blank
		end
	end

	-- Make a tab to put the box in.

	this.tab = iup.vbox {	["tabtitle"] =name_s,
										this.box,
										iup.fill{}
									}

	iup.Append(parent,this.tab)

end