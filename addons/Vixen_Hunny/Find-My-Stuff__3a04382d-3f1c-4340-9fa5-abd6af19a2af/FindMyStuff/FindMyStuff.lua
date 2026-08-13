FindMyStuff = FindMyStuff or {}
FindMyStuff.Name = "FindMyStuff"
FindMyStuff.Author = "Vixen Hunny"
FindMyStuff.Version = "1.0.0"
FindMyStuff.SettingsVersion = "1.0"
local pmax = 184000
local gmin = 1
local gmax = pmax
local total_results = 0
local max_results = 100
local current_cycle = 1
local cycles = 5
local cycle_size = 0
local base_suffix = ":0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:10000:0|h|h"
local link_suffix = ""
local dump_output = {}
local dump_position = 1

-- Nil-safe table builder: skips entries whose ESO constant key is nil in this API version
local function FMS_BuildTable(list)
	local t = {}
	for i = 1, #list do
		if list[i][1] ~= nil then
			t[list[i][1]] = list[i][2]
		end
	end
	return t
end

FindMyStuff.TraitTable = FMS_BuildTable({
	{ITEM_TRAIT_TYPE_NONE, "None"},
	{ITEM_TRAIT_TYPE_ARMOR_DIVINES, "Divines"},
	{ITEM_TRAIT_TYPE_ARMOR_EXPLORATION, "Invigorating"},   -- pre-Update 28 name
	{ITEM_TRAIT_TYPE_ARMOR_INVIGORATING, "Invigorating"},  -- current name (renamed from Exploration)
	{ITEM_TRAIT_TYPE_ARMOR_IMPENETRABLE, "Impenetrable"},
	{ITEM_TRAIT_TYPE_ARMOR_INFUSED, "Infused"},
	{ITEM_TRAIT_TYPE_ARMOR_INTRICATE, "Intricate"},
	{ITEM_TRAIT_TYPE_ARMOR_NIRNHONED, "Nirnhoned"},
	{ITEM_TRAIT_TYPE_ARMOR_ORNATE, "Ornate"},
	{ITEM_TRAIT_TYPE_ARMOR_REINFORCED, "Reinforced"},
	{ITEM_TRAIT_TYPE_ARMOR_STURDY, "Sturdy"},
	{ITEM_TRAIT_TYPE_ARMOR_TRAINING, "Training"},
	{ITEM_TRAIT_TYPE_ARMOR_WELL_FITTED, "Well-Fitted"},
	{ITEM_TRAIT_TYPE_WEAPON_CHARGED, "Charged"},
	{ITEM_TRAIT_TYPE_WEAPON_DECISIVE, "Decisive"},
	{ITEM_TRAIT_TYPE_WEAPON_DEFENDING, "Defending"},
	{ITEM_TRAIT_TYPE_WEAPON_INFUSED, "Infused"},
	{ITEM_TRAIT_TYPE_WEAPON_INTRICATE, "Intricate"},
	{ITEM_TRAIT_TYPE_WEAPON_NIRNHONED, "Nirnhoned"},
	{ITEM_TRAIT_TYPE_WEAPON_ORNATE, "Ornate"},
	{ITEM_TRAIT_TYPE_WEAPON_POWERED, "Powered"},
	{ITEM_TRAIT_TYPE_WEAPON_PRECISE, "Precise"},
	{ITEM_TRAIT_TYPE_WEAPON_SHARPENED, "Sharpened"},
	{ITEM_TRAIT_TYPE_WEAPON_TRAINING, "Training"},
	{ITEM_TRAIT_TYPE_JEWELRY_ARCANE, "Arcane"},
	{ITEM_TRAIT_TYPE_JEWELRY_BLOODTHIRSTY, "Bloodthirsty"},
	{ITEM_TRAIT_TYPE_JEWELRY_HARMONY, "Harmony"},
	{ITEM_TRAIT_TYPE_JEWELRY_HEALTHY, "Healthy"},
	{ITEM_TRAIT_TYPE_JEWELRY_INFUSED, "Infused"},
	{ITEM_TRAIT_TYPE_JEWELRY_INTRICATE, "Intricate"},
	{ITEM_TRAIT_TYPE_JEWELRY_ORNATE, "Ornate"},
	{ITEM_TRAIT_TYPE_JEWELRY_PROTECTIVE, "Protective"},
	{ITEM_TRAIT_TYPE_JEWELRY_ROBUST, "Robust"},
	{ITEM_TRAIT_TYPE_JEWELRY_SWIFT, "Swift"},
	{ITEM_TRAIT_TYPE_JEWELRY_TRIUNE, "Triune"},
	{ITEM_TRAIT_TYPE_ARMOR_AGGRESSIVE, "Aggressive"},
	{ITEM_TRAIT_TYPE_ARMOR_AUGMENTED, "Augmented"},
	{ITEM_TRAIT_TYPE_ARMOR_BOLSTERED, "Bolstered"},
	{ITEM_TRAIT_TYPE_ARMOR_FOCUSED, "Focused"},
	{ITEM_TRAIT_TYPE_ARMOR_PROLIFIC, "Prolific"},
	{ITEM_TRAIT_TYPE_ARMOR_QUICKENED, "Quickened"},
	{ITEM_TRAIT_TYPE_ARMOR_SHATTERING, "Shattering"},
	{ITEM_TRAIT_TYPE_ARMOR_SOOTHING, "Soothing"},
	{ITEM_TRAIT_TYPE_ARMOR_VIGOROUS, "Vigorous"},
	{ITEM_TRAIT_TYPE_JEWELRY_AGGRESSIVE, "Aggressive"},
	{ITEM_TRAIT_TYPE_JEWELRY_AUGMENTED, "Augmented"},
	{ITEM_TRAIT_TYPE_JEWELRY_BOLSTERED, "Bolstered"},
	{ITEM_TRAIT_TYPE_JEWELRY_FOCUSED, "Focused"},
	{ITEM_TRAIT_TYPE_JEWELRY_PROLIFIC, "Prolific"},
	{ITEM_TRAIT_TYPE_JEWELRY_QUICKENED, "Quickened"},
	{ITEM_TRAIT_TYPE_JEWELRY_SHATTERING, "Shattering"},
	{ITEM_TRAIT_TYPE_JEWELRY_SOOTHING, "Soothing"},
	{ITEM_TRAIT_TYPE_JEWELRY_VIGOROUS, "Vigorous"},
	{ITEM_TRAIT_TYPE_WEAPON_AGGRESSIVE, "Aggressive"},
	{ITEM_TRAIT_TYPE_WEAPON_AUGMENTED, "Augmented"},
	{ITEM_TRAIT_TYPE_WEAPON_BOLSTERED, "Bolstered"},
	{ITEM_TRAIT_TYPE_WEAPON_FOCUSED, "Focused"},
	{ITEM_TRAIT_TYPE_WEAPON_PROLIFIC, "Prolific"},
	{ITEM_TRAIT_TYPE_WEAPON_QUICKENED, "Quickened"},
	{ITEM_TRAIT_TYPE_WEAPON_SHATTERING, "Shattering"},
	{ITEM_TRAIT_TYPE_WEAPON_SOOTHING, "Soothing"},
	{ITEM_TRAIT_TYPE_WEAPON_VIGOROUS, "Vigorous"},
})

FindMyStuff.EquipTable = FMS_BuildTable({
	{EQUIP_TYPE_INVALID, ""},
	{EQUIP_TYPE_CHEST, "chest"},
	{EQUIP_TYPE_COSTUME, "costume"},
	{EQUIP_TYPE_FEET, "feet"},
	{EQUIP_TYPE_HAND, "hand"},
	{EQUIP_TYPE_HEAD, "head"},
	{EQUIP_TYPE_LEGS, "legs"},
	{EQUIP_TYPE_MAIN_HAND, "weapon"},
	{EQUIP_TYPE_NECK, "necklace"},
	{EQUIP_TYPE_OFF_HAND, "weapon"},
	{EQUIP_TYPE_ONE_HAND, "weapon"},
	{EQUIP_TYPE_POISON, "poison"},
	{EQUIP_TYPE_RING, "ring"},
	{EQUIP_TYPE_SHOULDERS, "shoulders"},
	{EQUIP_TYPE_TWO_HAND, "weapon"},
	{EQUIP_TYPE_WAIST, "waist"},
})
FindMyStuff.EquipTable[16] = "robe"  --Handle robe/shirts
FindMyStuff.EquipTable[17] = "shirt"

FindMyStuff.WeaponTable = FMS_BuildTable({
	{WEAPONTYPE_RUNE, "rune"},
	{WEAPONTYPE_NONE, "none"},
	{WEAPONTYPE_AXE, "axe"},
	{WEAPONTYPE_BOW, "bow"},
	{WEAPONTYPE_DAGGER, "dagger"},
	{WEAPONTYPE_FIRE_STAFF, "firestaff"},
	{WEAPONTYPE_FROST_STAFF, "froststaff"},
	{WEAPONTYPE_HAMMER, "mace"},
	{WEAPONTYPE_HEALING_STAFF, "healingstaff"},
	{WEAPONTYPE_LIGHTNING_STAFF, "lightningstaff"},
	{WEAPONTYPE_SHIELD, "shield"},
	{WEAPONTYPE_SWORD, "sword"},
	{WEAPONTYPE_TWO_HANDED_AXE, "battleaxe"},
	{WEAPONTYPE_TWO_HANDED_HAMMER, "maul"},
	{WEAPONTYPE_TWO_HANDED_SWORD, "greatsword"},
})

FindMyStuff.ArmorTable = FMS_BuildTable({
	{ARMORTYPE_NONE, "none"},
	{ARMORTYPE_HEAVY, "heavy"},
	{ARMORTYPE_LIGHT, "light"},
	{ARMORTYPE_MEDIUM, "medium"},
})

--One s removed from each for optimum matching ease
FindMyStuff.EquipSynonymTable = {
	--Light
	[1]= {[1]="hat",[2]=EQUIP_TYPE_HEAD,[3]="light"},
	[2]= {[1]="robe",[2]=16,[3]="light"},
	[3]= {[1]="shirt",[2]=17,[3]="light"},
	[4]= {[1]="epaulet",[2]=EQUIP_TYPE_SHOULDERS,[3]="light"},
	[5]= {[1]="sash",[2]=EQUIP_TYPE_WAIST,[3]="light"},
	[6]= {[1]="breeche",[2]=EQUIP_TYPE_LEGS,[3]="light"},
	[7]= {[1]="shoe",[2]=EQUIP_TYPE_FEET,[3]="light"},
	[8]= {[1]="glove",[2]=EQUIP_TYPE_HAND,[3]="light"},
	--Medium
	[9]= {[1]="helmet",[2]=EQUIP_TYPE_HEAD,[3]="medium"},
	[10]= {[1]="jack",[2]=EQUIP_TYPE_CHEST,[3]="medium"},
	[11]= {[1]="armcop",[2]=EQUIP_TYPE_SHOULDERS,[3]="medium"},
	[12]= {[1]="belt",[2]=EQUIP_TYPE_WAIST,[3]="medium"},
	[13]= {[1]="guard",[2]=EQUIP_TYPE_LEGS,[3]="medium"},
	[14]= {[1]="boot",[2]=EQUIP_TYPE_FEET,[3]="medium"},
	[15]= {[1]="bracer",[2]=EQUIP_TYPE_HAND,[3]="medium"},
	--Heavy
	[16]= {[1]="helm",[2]=EQUIP_TYPE_HEAD,[3]="heavy"},
	[17]= {[1]="cuiras",[2]=EQUIP_TYPE_CHEST,[3]="heavy"},
	[18]= {[1]="pauldron",[2]=EQUIP_TYPE_SHOULDERS,[3]="heavy"},
	[19]= {[1]="girdle",[2]=EQUIP_TYPE_WAIST,[3]="heavy"},
	[20]= {[1]="greave",[2]=EQUIP_TYPE_LEGS,[3]="heavy"},
	[21]= {[1]="sabaton",[2]=EQUIP_TYPE_FEET,[3]="heavy"},
	[22]= {[1]="gauntlet",[2]=EQUIP_TYPE_HAND,[3]="heavy"}
}

FindMyStuff.ItemTable = {built=0,items={},}	

FindMyStuff.Default = {quality=364,level=50}
-- Acts as a bridge between input and cycle
local function bridge(text,min,max,trait,etype,weight)
	if min == nil then gmin = 1 else gmin = min end
	if max == nil then gmax = pmax else gmax = max end
	
	trait = trait:lower()	
		
	--equipment type poison doesn't have results until over 75k, stops by 82k and resumes at 135k then 152k. Partial selective search for beginning for efficiency.
	if etype ~= "" and etype:lower() == "poison" and gmax > 75000 and gmin < 75000 then
		gmin = 75000
	end	
		
	--Summerset jewelry traits do not begin until 139k; partial selective search for efficiency
	if (trait == "bloodthirsty" or trait == "harmony" or trait == "infused" or trait == "protective" or trait == "swift" or trait == "triune") and gmax > 139000 and gmin < 139000 then
		gmin = 139000
	end
	
	total_results = 0
	current_cycle = 1
	--create major cycle size
	cycle_size = math.ceil((gmax-gmin)/cycles)	
	tmin = gmin
	tmax = gmin+cycle_size	
	if tmax > pmax then
		tmax = pmax
	end	
		
	d("Beginning search for " .. (text ~= "" and ("\"" ..text.. "\"") or "anything") .. (trait ~= "" and (" with trait \"" .. trait .. "\"") or "") .. (etype ~= "" and (" with equipment type \"" .. etype .. "\"") or "") .. (weight ~= "" and (" with armor weight \"" .. weight .. "\"") or ""))

	--check for specific weight etype
	if etype ~= "" then
		local temp_etype = etype:lower():gsub("s$","")
		for index,equip in pairs(FindMyStuff.EquipSynonymTable) do
			--must be exact match due to helm/helmet
			if temp_etype == equip[1] then
				etype = FindMyStuff.EquipTable[equip[2]]
				--if no specified weight, let's assume they want the correct one
				if weight == "" then
					weight = equip[3]
				end
			end
		end
	end
	
	--handle uniformity
	etype = etype:lower()
	weight = weight:lower()

	EVENT_MANAGER:RegisterForUpdate(FindMyStuff.Name, 100, function() FindMyStuff.UseName(text,trait,etype,weight) end)
end

--splits string into array
local function split_str(inputstr, sep)
        if sep == nil then
                sep = "%s"
        end
        local t={}
		local i=1
        for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
                t[i] = str
                i = i + 1
        end
        return t
end

--Finds items using their name
function FindMyStuff.UseName(text,trait,etype,weight)
	local searchstring = text:lower():gsub("-","--")
	local out_ary = {}
	
	--create search array
	local searcharray = split_str(searchstring)
	local terms = #searcharray
	
	local item_id = -1
	for i = tmin, tmax, 1 do
		local matched = true
		local temp_trait = ""
		local temp_equip = ""
		local temp_wep = ""
		local temp_weight = ""
		local temp_etype = etype
		
		--check if it is blank before anything else
		if FindMyStuff.ItemTable['items'][i] ~= "" and FindMyStuff.ItemTable['items'][i] ~= nil then
			local linkstring = tostring(FindMyStuff.ItemTable['items'][i])
			--check for first term
			if terms == 0 or string.find(linkstring, tostring(searcharray[1])) ~= nil then
				--check if there are additional terms to compare it against
				if terms > 1 then
					for a = 2, terms, 1 do
						if string.find(linkstring, tostring(searcharray[a])) == nil then
							matched = false
						end
					end
				end
				if matched then
					--handle traits being included in search
					temp_trait = FindMyStuff.TraitTable[select(1,GetItemLinkTraitInfo("|H1:item:" .. i .. link_suffix))]
					if trait == "" or temp_trait:lower():match(trait) then
						--handle equiptype being included
						if temp_etype ~= "" then
							temp_equip = FindMyStuff.EquipTable[GetItemLinkEquipType("|H1:item:" .. i .. link_suffix)]
							--check if it is a shirt or robe
							if temp_equip == "chest" then
								if temp_etype == "shirt" then
									if linkstring:find("robe") == nil then
										temp_etype = "chest"
									else
										matched = false
									end	
								elseif temp_etype == "robe" then
									if linkstring:find("robe") ~= nil then
										temp_etype = "chest"
									else
										matched = false
									end	
								end
							end
							if matched then
								--check if it matches, otherwise check the weapon table
								if temp_equip ~= nil and temp_equip:find(temp_etype) == 1 then
								--check through the weapon table instead
								elseif temp_equip ~= nil and temp_equip:find("weapon") == 1 then
									temp_wep = FindMyStuff.WeaponTable[GetItemLinkWeaponType("|H1:item:" .. i .. link_suffix)]
									if  temp_wep:find(temp_etype) ~= 1 then
										matched = false
									end
								else
									matched = false
								end
							end
						end
						--handle weight
						if weight ~= "" then
							temp_weight = FindMyStuff.ArmorTable[GetItemLinkArmorType("|H1:item:" .. i .. link_suffix)]
							if temp_weight ~= nil and temp_weight:find(weight) == 1 then
							else
								matched = false
							end
						end
						if matched then
						if i > 176000 and (temp_trait == nil or link_suffix == nil) then
						d(i)
						end
							out_ary[#out_ary+1] = "ID #" .. i .. ": |H1:item:" .. i .. link_suffix .. (temp_trait ~= "None" and (" " .. temp_trait) or "")
							total_results = total_results + 1
							--break at 100 results
							if total_results >= max_results then 
								item_id = i
								break 
							end
						end
					end	
				end
			end
		end	
	end

	if total_results < max_results and tmax < gmax then
		d(table.concat(out_ary,"\n"))
	elseif total_results < max_results and tmax >= gmax then
		d(table.concat(out_ary,"\n") .. "\nFinished search. Total results: " .. total_results)
	elseif total_results >= max_results then
		d(table.concat(out_ary,"\n") .. "\nFinished search. Too many results.")
		--Determine if it got cut short
		local next_id = tmax
		if item_id ~= -1 then
			next_id = item_id
		end	
		--clean up extra spacing
		local out_string = "/" .. text .. (text ~= "" and " " or "") .. (trait ~= "" and "trait:" .. trait .. " " or "") .. (etype ~= "" and "type:" .. etype .. " " or "") .. (weight ~= "" and "weight:" .. weight .. " " or "") .. (next_id+1)
		out_string = out_string:gsub("/%s*","/findid ")
		if not IsConsoleUI() then
			CHAT_SYSTEM.textEntry:Open(out_string)
			CHAT_SYSTEM.textEntry:SetCursorPosition(0)
		end
		EVENT_MANAGER:UnregisterForUpdate(FindMyStuff.Name)
	end
	--Cancel once fully looped through
	if tmax >= gmax then
		EVENT_MANAGER:UnregisterForUpdate(FindMyStuff.Name)
	--Otherwise update the range for the next round	
	else	
		current_cycle = current_cycle+1 
		tmin = gmin+(cycle_size*(current_cycle-1))+1
		tmax = gmin+cycle_size*current_cycle
	end
end

--Finds items by id or reassemble broken item
local function ShowItem(text)
	if string.match(text,"[^%d]") then
		d("|" .. text)
	else	
		d("ID #" .. text .. ": |H1:item:" .. text .. link_suffix)
	end	
end	

--Takes a link and returns the text
local function BreakItem(text)
	text = string.gsub(text,"|H",'H')
	if not IsConsoleUI() then
		CHAT_SYSTEM.textEntry:Open("/showitem " .. text)
		CHAT_SYSTEM.textEntry:SetCursorPosition(10)
	else
		d("/showitem " .. text)
	end
end	

--Helper function for building the table
local function TableBuilder(text,mode)
	current_cycle = 1
	--create major cycle size
	bcycles = 3
	cycle_size = math.ceil((gmax-gmin)/bcycles)
	tmin = gmin
	tmax = gmin+cycle_size	
	d("Building current item table...")		
	EVENT_MANAGER:RegisterForUpdate(FindMyStuff.Name, 100, function() FindMyStuff.BuildTable(text,mode) end)
end

--Takes the input and determines if a range was included
local function RangeCheck(text)
	--check if the table has been built
	if FindMyStuff.ItemTable.built == 0 then
		TableBuilder(text)
	else
		local trait = ""
		--check if using traits
		if text:match("%s-trait:%w+") ~= nil then
			trait = text:match("trait:(%w+)")
			text = text:gsub(text:match("%s-trait:%w+"),'',1)
		end
		local etype = ""
		--check if using type
		if text:match("%s-type:%w+") ~= nil then
			etype = text:match("type:(%w+)")
			text = text:gsub(text:match("%s-type:%w+"),'',1)
		end	
		local weight = ""
		--check if using weight
		if text:match("%s-weight:%w+") ~= nil then
			weight = text:match("weight:(%w+)")
			text = text:gsub(text:match("%s-weight:%w+"),'',1)
		end			
		--check if using just offsets
		if text:match("%a") == nil then
			text = " " .. text
		end	
		--check for offset
		local fmin = string.match(text,"(%s%d+)")
		if fmin ~= nil then	
			--remove the min
			text = text:gsub(fmin,'',1)
			--attempt to create a max
			local fmax = tonumber(text:match("(%s%d+)"))
			if fmax ~= nil then
				--remove the max
				text = text:gsub(fmax,'')
				if text:gsub("%s+",'') == "" then
					text = ""
				end	
				bridge(text,tonumber(fmin),tonumber(fmax),trait,etype,weight)
			else
				if text:gsub("%s+",'') == "" then
					text = ""
				end	
				bridge(text,tonumber(fmin),nil,trait,etype,weight)
			end	
		else	
			bridge(text,nil,nil,trait,etype,weight)
		end	
	end	
end

--Helper to reset table when necessary
function TableReset(table)
	local count = #table
	for i=0, count do table[i]=nil end
end

-- Acts as a bridge between input and cycle
local function DumpBridge(text,min,max)
	if min == nil then gmin = 1 else gmin = min end
	if max == nil then gmax = pmax else gmax = max end
	total_results = 0
	current_cycle = 1
	--create major cycle size
	cycle_size = math.ceil((gmax-gmin)/cycles)	
	tmin = gmin
	tmax = gmin+cycle_size	
	if tmax > pmax then
		tmax = pmax
	end	
	
	--Reset before use
	TableReset(dump_output)
	dump_position = 1
	
	EVENT_MANAGER:RegisterForUpdate(FindMyStuff.Name, 100, function() FindMyStuff.DumpBuilder(text) end)
end	

--Assembles the data for searching
function FindMyStuff.BuildTable(text,mode)
	if text == '' then text = nil end
	if mode == nil then mode = 0 end
	for i = tmin, tmax, 1 do
		local link = "|H1:item:" .. i .. link_suffix
		local snaglink = GetItemLinkName(link)
		--check if it is blank before anything else
		if snaglink ~= "h" then
			FindMyStuff.ItemTable['items'][i] = tostring(snaglink):lower()
		else
			FindMyStuff.ItemTable['items'][i] = ""
		end
	end
	--Cancel once fully looped through
	if tmax >= gmax then
		FindMyStuff.ItemTable.built = 1	
		d("Item table built.")
		EVENT_MANAGER:UnregisterForUpdate(FindMyStuff.Name)
		if text ~= nil and mode == 0 then
			RangeCheck(text)
		elseif mode == 1 then
			DumpBridge(text)
		end
	--Otherwise update the range for the next round	
	else	
		d("Building...")
		current_cycle = current_cycle+1 
		tmin = gmin+(cycle_size*(current_cycle-1))+1
		tmax = gmin+cycle_size*current_cycle
	end	
end

--Handles concating numbers
function implode(delimiter, list)
	local len = #list
	if len == 0 then
		return ""
	end
	local string = list[1]
	for i = 2, len do
		string = string .. delimiter .. list[i]
	end
	return string
end

--Attempts to dump all furniture/cooking recipe IDs to savedvars
local function Dump(text)
	if text == 'furniture' or text == 'provisioning' or text == 'reagent' then
		if FindMyStuff.ItemTable.built == 0 then
			TableBuilder(text,1)
		else
			DumpBridge(text)
		end	
	else
		d('Current dump options: "furniture" "provisioning" "reagent"')
	end	
end

function FindMyStuff.DumpBuilder(text)
	--Handle mode
	mode = -1
	if text == 'provisioning' then
		mode = 0
	elseif text == 'furniture' then
		mode = 1
	elseif text == 'reagent' then
		mode = 2
	end
	
	for i = tmin, tmax, 1 do
		if FindMyStuff.ItemTable['items'][i] ~= "" then
			--Only ignore Roast Pig BOP
			if i ~= 55462 then
				local itemLink = "|H1:item:" .. i .. link_suffix
				local _,sType = GetItemLinkItemType(itemLink)
				if mode == 0 then
					if sType == SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_STANDARD_FOOD or
						sType == SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_STANDARD_DRINK then
						dump_output[#dump_output+1] = i	
					end
				elseif mode == 1 then
					if sType == SPECIALIZED_ITEMTYPE_RECIPE_BLACKSMITHING_DIAGRAM_FURNISHING or
						sType == SPECIALIZED_ITEMTYPE_RECIPE_CLOTHIER_PATTERN_FURNISHING or
						sType == SPECIALIZED_ITEMTYPE_RECIPE_ENCHANTING_SCHEMATIC_FURNISHING or
						sType == SPECIALIZED_ITEMTYPE_RECIPE_ALCHEMY_FORMULA_FURNISHING or
						sType == SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_DESIGN_FURNISHING or
						sType == SPECIALIZED_ITEMTYPE_RECIPE_WOODWORKING_BLUEPRINT_FURNISHING or
						sType == SPECIALIZED_ITEMTYPE_RECIPE_JEWELRYCRAFTING_SKETCH_FURNISHING then
						dump_output[#dump_output+1] = i
					end
				elseif mode == 2 then
					if sType == SPECIALIZED_ITEMTYPE_REAGENT_ANIMAL_PART or
						sType == SPECIALIZED_ITEMTYPE_REAGENT_FUNGUS or
						sType == SPECIALIZED_ITEMTYPE_REAGENT_HERB then
						dump_output[#dump_output+1] = i
					end	
				end
				--Handle size threat
				if #dump_output >= 100 then
					FindMyStuff.SavedVariables[text .. dump_position] = implode(",",dump_output)
					dump_position = dump_position+1
					TableReset(dump_output)
				end
			end
		end	
	end
	
	--Cancel once fully looped through
	if tmax >= gmax then
		EVENT_MANAGER:UnregisterForUpdate(FindMyStuff.Name)
		--Handle stragglers
		if #dump_output ~= 0 then
			FindMyStuff.SavedVariables[text .. dump_position] = implode(",",dump_output)
		end	
		d('Dump completed. Reload and view your Saved Vars.')
	--Otherwise update the range for the next round	
	else	
		current_cycle = current_cycle+1 
		tmin = gmin+(cycle_size*(current_cycle-1))+1
		tmax = gmin+cycle_size*current_cycle
		--Prove it's still working 
		d('Building dump...')
	end
end

--Grade helper
local function AssembleItem(item_data,quality)
	if quality ~= nil then item_data[4] = quality end
	local out = ""
	if tonumber(item_data[4]) < 0 then
		item_data[4] = 0
	end		
	for i = 1, #item_data, 1 do
		out = out .. ":" .. item_data[i]
	end
	return out:sub(2)
end

--Attempts to show all qualities of an item
local function GradeItem(text)
	local item_data = split_str(text,":")
	local temp_item = ""
	local temp_quality = ""
	local quality = tonumber(item_data[4])
	local quality_tier = GetItemLinkQuality(text)
	local quality_attempts = 0
	local quality_table = {}
	--Try to handle CP10-100 (batch 1)
	if quality >= 39 and quality <= 120 then
		--Handle normal
		if quality >= 111 and quality <= 120 then
			quality_table = {[1]=quality,[2]=quality-60,[3]=quality-50,[4]=quality-40,[5]=quality-10}
		--Handle fine quest rewards
		elseif quality >= 39 and quality <= 48 then
			quality_table = {[1]=quality+72,[2]=quality,[3]=quality+22,[4]=quality+32,[5]=quality+62}
		--Handle fine		
		elseif quality >= 51 and quality <= 60 then
			quality_table = {[1]=quality+60,[2]=quality,[3]=quality+10,[4]=quality+20,[5]=quality+50}
		--Handle superior	
		elseif quality >= 61 and quality <= 70 then
			quality_table = {[1]=quality+50,[2]=quality-10,[3]=quality,[4]=quality+10,[5]=quality+40}
		--Handle superior second set
		elseif quality >= 81 and quality <= 90 then
			quality_table = {[1]=quality+30,[2]=quality-30,[3]=quality,[4]=quality-10,[5]=quality+20}		
		--Handle epic
		elseif quality >= 71 and quality <= 80 then
			quality_table = {[1]=quality+40,[2]=quality-20,[3]=quality-10,[4]=quality,[5]=quality+30}
		--Handle epic second set
		elseif quality >= 91 and quality <= 100 then
			quality_table = {[1]=quality+20,[2]=quality-40,[3]=quality-30,[4]=quality,[5]=quality+10}		
		--Handle legendary
		elseif quality >= 101 and quality <= 110 then
			quality_table = {[1]=quality+10,[2]=quality-50,[3]=quality-40,[4]=quality-30,[5]=quality}
		end
	--Try to handle CP10-100 (batch 2)
	elseif quality >= 125 and quality <= 174 then
		--Handle normal
		if quality >= 125 and quality <= 134 then
			quality_table = {[1]=quality,[2]=quality+10,[3]=quality+20,[4]=quality+30,[5]=quality+40}
		--Handle fine
		elseif quality >= 135 and quality <= 144 then
			quality_table = {[1]=quality-10,[2]=quality,[3]=quality+10,[4]=quality+20,[5]=quality+30}
		--Handle superior
		elseif quality >= 145 and quality <= 154 then
			quality_table = {[1]=quality-20,[2]=quality-10,[3]=quality,[4]=quality+10,[5]=quality+20}	
		--Handle epic
		elseif quality >= 155 and quality <= 164 then
			quality_table = {[1]=quality-30,[2]=quality-20,[3]=quality-10,[4]=quality,[5]=quality+10}	
		--Handle legendary
		elseif quality >= 165 and quality <= 174 then
			quality_table = {[1]=quality-40,[2]=quality-30,[3]=quality-20,[4]=quality-10,[5]=quality}			
		end
	elseif quality_tier ~= 0 then
		quality_table[quality_tier] = quality
		--Attempt to find tier 5 when tier 1
		if quality_table[1] ~= nil then
			item_data[4] = item_data[4]-1
			temp_item = AssembleItem(item_data)
			temp_quality = GetItemLinkQuality(temp_item)			
			if temp_quality == 5 then
				quality_table[5] = item_data[4]
			end
		end
		--Attempts to find tier 5
		if quality_table[5] == nil then
			while quality_table[5] == nil and quality_attempts < 7 do 
				item_data[4] = item_data[4]+1
				temp_item = AssembleItem(item_data)
				temp_quality = GetItemLinkQuality(temp_item)
				if temp_quality == 5 then
					quality_table[5] = item_data[4]
				end	
				quality_attempts = quality_attempts+1
			end	
		end
		--Tries to work backward from there
		local temp_attempts = quality_attempts
		while quality_attempts < (7+temp_attempts) do
			item_data[4] = item_data[4]-1
			temp_item = AssembleItem(item_data)
			temp_quality = GetItemLinkQuality(temp_item)
			if quality_table[temp_quality] == nil then
				quality_table[temp_quality] = item_data[4]
			end
			quality_attempts = quality_attempts+1		
		end
		--Attempts to handle tier 1 post 5 if not found sub 5 if 5 was found
		if quality_table[1] == nil and quality_table[5] ~= nil then
			item_data[4] = quality_table[5]
			quality_attempts = 0
			while quality_table[1] == nil and quality_attempts < 7 do 
				item_data[4] = item_data[4]+1
				temp_item = AssembleItem(item_data)
				temp_quality = GetItemLinkQuality(temp_item)
				if temp_quality == 1 then
					quality_table[1] = item_data[4]
				end	
				quality_attempts = quality_attempts+1
			end				
		end
	end
	--Ensure ordered table
	for key = 1, 5, 1 do
		if quality_table[key] ~= nil then
			d("ID #" .. item_data[3] .. ": " .. AssembleItem(item_data,quality_table[key]) .. " Quality: " .. quality_table[key])
		end	
	end	
end

--Updates quality settings
local function SetQuality(text)
	local item_data = split_str(text,":")
	if tonumber(item_data[4]) ~= nil and tonumber(item_data[5]) ~= nil then
		FindMyStuff.SavedVariables.quality = item_data[4]
		FindMyStuff.SavedVariables.level = item_data[5]
		FindMyStuff.Default = {quality=FindMyStuff.SavedVariables.quality,level=FindMyStuff.SavedVariables.level}
		link_suffix = ":" .. FindMyStuff.Default.quality .. ":" .. FindMyStuff.Default.level .. base_suffix	
		d("Item Finder quality updated.")
	else
		d("Item Finder refuses your offering. Try an item with a level.")
	end	
end

--Shows command usage
local function IFHelp()
	d("Item Finder Command Usage")
	--Find item in inventory (cross-character)
	d("Command: |cFF7700/finditem|r")
	d("Purpose: Searches your saved cross-character inventory for an item by name.")
	d("Usage: /finditem item_name")
	d("Example: /finditem night mother")
	--Rescan inventory
	d("Command: |cFF7700/fmsscan|r")
	d("Purpose: Manually rescans and saves the current character's inventory.")
	d("Usage: /fmsscan")
	--Find item in database
	d("Command: |cFF7700/findindb|r or |cFF7700/findid|r or |cFF7700/findbyname|r")
	d("Purpose: Searches all possible game items by ID (full database search).")
	d("Usage: /findindb item_name (optional)start_id (optional)end_id")
	d("Example: /findindb night mother")
	d("Advanced Example: /findindb night mother 40000 50000")
	--Find name
	d("Command: |cFF7700/showitem|r or |cFF7700/findname|r or |cFF7700/findbyid|r")
	d("Purpose: Uses an item's ID or the output from /breakitem and outputs an item link.")
	d("Usage: /showitem item_id")
	d("Example: /showitem 61225")
	--Break Item
	d("Command: |cFF7700/breakitem|r")
	d("Purpose: Takes an item link and converts it to text for editing/viewing.")
	d("Usage: /breakitem item_link")
	d("Example: /breakitem |H1:item:61225:364:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:10000:0|h|h")	
	--Show quality
	d("Command: |cFF7700/gradeitem|r")
	d("Purpose: Takes an item link and attempts to show it at each quality.")
	d("Usage: /gradeitem item_link")
	d("Example: /gradeitem |H1:item:84984:362:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:10000:0|h|h")
	--Change quality
	d("Command: |cFF7700/ifdump|r")
	d("Purpose: Sends a dump of IDs for furniture recipes/provisioning recipes.")
	d("Usage: /ifdump option")
	d("Example: /ifdump furniture")		
	--Change quality
	d("Command: |cFF7700/ifsetquality|r")
	d("Purpose: Takes an item link and uses the item's quality and level for your /findindb results. Character specific setting.")
	d("Usage: /ifsetquality item_link")
	d("Example: /ifsetquality |H1:item:84984:362:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:10000:0|h|h")	
	--Trait flag
	d("Flag: |c0077FFtrait:|r")
	d("Purpose: Allows for searching by trait.")
	d("Example: /findindb night mother trait:divines")	
	--Equipment flag weapon/armor
	d("Flag: |c0077FFtype:|r")
	d("Purpose: Allows for searching by armor or weapon type.")
	d("Weapon Keywords: Axe, Bow, Dagger, Mace, Shield, Sword, Fire, Frost, Lightning, Healing, BattleAxe, Maul, Greatsword")
	d("Armor Keywords: Chest, Feet, Hand, Head, Legs, Necklace, Ring, Shoulders, Waist")
	d("Example: /findindb night mother type:sword")
	--Equipment flag weighted armor
	d("Flag: |c0077FFtype:|r")
	d("Advanced Purpose: Allows for searching by armor type and weight by using the weight-specific names below.")
	d("Light Armor Keywords: Hat, Robe, Shirt, Epaulets, Sash, Breeches, Shoes, Gloves")
	d("Medium Armor Keywords: Helmet, Jack, ArmCops, Belt, Guards, Boots, Bracers")
	d("Heavy Armor Keywords: Helm, Cuirass, Pauldrons, Girdle, Greaves, Sabatons, Gauntlets")
	d("Example: /findindb night mother type:jack")
	--Weight flag
	d("Flag: |c0077FFweight:|r")
	d("Purpose: Allows for searching by armor weight.")	
	d("Weight Keywords: Light, Medium, Heavy")
	d("Example: /findindb night mother weight:light")
	d("Advanced Example: /findindb night mother type:head weight:light")
end
-- ========================
-- INVENTORY TRACKING SYSTEM
-- ========================

-- Quality color codes indexed by ESO ItemQuality (0=Trash .. 5=Legendary)
local FMS_QUALITY_COLORS = {
	[ITEM_DISPLAY_QUALITY_TRASH] = "|c9D9D9D",  -- Trash
	[ITEM_DISPLAY_QUALITY_NORMAL] = "|cFFFFFF",  -- Normal
	[ITEM_DISPLAY_QUALITY_MAGIC] = "|c2DC50E",  -- Fine
	[ITEM_DISPLAY_QUALITY_ARCANE] = "|c4169E1",  -- Superior
	[ITEM_DISPLAY_QUALITY_ARTIFACT] = "|cA02EF7",  -- Epic
	[ITEM_DISPLAY_QUALITY_LEGENDARY] = "|cffff00",  -- Legendary
	[ITEM_DISPLAY_QUALITY_MYTHIC_OVERRIDE] = "|cFFA500",  -- Mythic
}

local function FMS_ScanBag(bag, inv)
	local numSlots = GetBagSize(bag)
	for slot = 0, numSlots - 1 do
		local itemLink = GetItemLink(bag, slot)
		if itemLink ~= "" then
			local itemName = GetItemLinkName(itemLink)
			if itemName ~= "" then
				local stack = GetSlotStackSize(bag, slot)
				local quality = GetItemLinkDisplayQuality(itemLink)
				local traitType = select(1, GetItemLinkTraitInfo(itemLink))
				local traitName = FindMyStuff.TraitTable[traitType]
				if traitName == "None" then traitName = nil end
				-- Binding status
				local bindType = GetItemLinkBindType(itemLink)
				local boundStr
				if bindType == BIND_TYPE_NONE then
					boundStr = "Unbound"
				elseif bindType == BIND_TYPE_ON_EQUIP then
					boundStr = "BoE"
				else
					boundStr = "Bound"
				end
				-- Known/Unknown for learnable items (recipes, motifs)
				local knownStr = nil
				local itemType = GetItemLinkItemType(itemLink)
				if itemType == ITEMTYPE_RECIPE or itemType == ITEMTYPE_CRAFTED_ABILITY_SCRIPT then
					local isKnown = IsItemLinkRecipeKnown(itemLink)
					if isKnown then
						knownStr = "Known"
					else
						knownStr = "Unknown"
					end
				elseif itemType == ITEMTYPE_RACIAL_STYLE_MOTIF or itemType == ITEMTYPE_COLLECTIBLE then
					if IsItemLinkBookKnown(itemLink) then
						knownStr = "Known"
					else
						knownStr = "Unknown"
					end
				end
				-- composite key keeps different-trait copies of the same item separate
				local key = itemName .. (traitName and ("\t" .. traitName) or "")
				local existing = inv[key]
				if existing and type(existing) == "table" then
					existing.n = existing.n + stack
				else
					inv[key] = {n = stack, q = quality, t = traitName, name = itemName, bound = boundStr, known = knownStr}
				end
			end
		end
	end
end

function FindMyStuff.ScanInventory()
	if not FindMyStuff.SavedVariables then return end
	if not FindMyStuff.SavedVariables.charInventory then
		FindMyStuff.SavedVariables.charInventory = {}
	end
	local charName = GetUnitName("player")
	local charInv = {}
	FMS_ScanBag(BAG_BACKPACK, charInv)
	FMS_ScanBag(BAG_WORN, charInv)
	FindMyStuff.SavedVariables.charInventory[charName] = charInv
	-- Shared bags stored under a common key (updated each time any character logs in)
	local sharedInv = {}
	FMS_ScanBag(BAG_BANK, sharedInv)
	if GetBagSize(BAG_SUBSCRIBER_BANK) > 0 then
		FMS_ScanBag(BAG_SUBSCRIBER_BANK, sharedInv)
	end
	if GetBagSize(BAG_CRAFT_BAG) > 0 then
		FMS_ScanBag(BAG_CRAFT_BAG, sharedInv)
	end
	if next(sharedInv) ~= nil then
		FindMyStuff.SavedVariables.charInventory["[Bank/Craft Bag]"] = sharedInv
	end
end

local function FindInInventory(searchText)
	if not FindMyStuff.SavedVariables or not FindMyStuff.SavedVariables.charInventory then
		d("|cFF7700FindMyStuff:|r No inventory data saved. Log in with each character to populate.")
		return
	end
	searchText = searchText and searchText:gsub("^%s+", ""):gsub("%s+$", "") or ""
	if searchText == "" then
		d("|cFF7700FindMyStuff:|r Usage: /finditem <item name>")
		return
	end
	local search = searchText:lower()
	local results = {}
	for charName, items in pairs(FindMyStuff.SavedVariables.charInventory) do
		for key, entry in pairs(items) do
			-- handle legacy format where entry was just a count number
			if type(entry) == "number" then
				entry = {n = entry, q = 1, t = nil, name = key}
			end
			local displayName = entry.name or key
			if displayName:lower():find(search, 1, true) then
				results[#results + 1] = {char = charName, name = displayName, entry = entry}
			end
		end
	end
	if #results == 0 then
		d("|cFF7700FindMyStuff:|r No items found: |cffff00" .. searchText .. "|r")
	else
		table.sort(results, function(a, b) return a.char < b.char end)
		d("|cFF7700FindMyStuff:|r |cffff00" .. #results .. "|r result(s) for: |cffff00" .. searchText .. "|r")
		for _, r in ipairs(results) do
			local e = r.entry
			local qColor = FMS_QUALITY_COLORS[e.q] or FMS_QUALITY_COLORS[1]
			local traitStr = e.t and (" |caaaaaa[" .. e.t .. "]|r") or ""
			local boundStr
			if e.bound == "Unbound" then
				boundStr = " |c2DC50E[Unbound]|r"
			elseif e.bound == "BoE" then
				boundStr = " |cF5A9B8[Bind On Equip]|r"
			elseif e.bound == "Bound" then
				boundStr = " |caaaaaa[Bound]|r"
			else
				boundStr = ""
			end
			local knownStr = e.known == "Known" and " |caaaaaa[Known]|r" or (e.known == "Unknown" and " |c5BCEFA[Unknown]|r" or "")
			d("  |caaaaaaCharacter:|r |cffff00" .. r.char .. "|r  - " .. qColor .. r.name .. "|r" .. traitStr .. boundStr .. knownStr .. " |caaaaaa(x" .. e.n .. ")|r")
		end
	end
end

function FindMyStuff:Initialize()
	FindMyStuff.SavedVariables = ZO_SavedVars:NewAccountWide("FindMyStuffSV", FindMyStuff.SettingsVersion, nil, FindMyStuff.Default)
	EVENT_MANAGER:UnregisterForEvent(FindMyStuff.Name, EVENT_ADD_ON_LOADED)
	FindMyStuff.Default = {quality=FindMyStuff.SavedVariables.quality,level=FindMyStuff.SavedVariables.level}
	link_suffix = ":" .. FindMyStuff.Default.quality .. ":" .. FindMyStuff.Default.level .. base_suffix
    d("FindMyStuff v" .. FindMyStuff.Version .. " loaded. Type /fmshelp to begin searching for items.")
    -- Inventory cross-character search
    SLASH_COMMANDS["/finditem"] = FindInInventory
    SLASH_COMMANDS["/fmsscan"] = function() FindMyStuff.ScanInventory() end
    --Tries to find all recipes/blueprints
    SLASH_COMMANDS["/fmsdump"] = Dump
    --Allows changing the found item quality
    SLASH_COMMANDS["/fmssetquality"] = SetQuality
    --Shows command usage
    SLASH_COMMANDS["/fmshelp"] = IFHelp
    -- Auto-scan inventory on each login (3 second delay to ensure bags are loaded)
    EVENT_MANAGER:RegisterForEvent(FindMyStuff.Name .. "_Inv", EVENT_PLAYER_ACTIVATED, function()
        zo_callLater(FindMyStuff.ScanInventory, 3000)
    end)
	EVENT_MANAGER:RegisterForEvent(FindMyStuff.Name, EVENT_LOOT_UPDATED, function(eventCode)
		-- Only scan if the bag is one of the tracked bags
		zo_callLater(function()
			FindMyStuff.ScanInventory()
		end, 3000)
	end)
end

function FindMyStuff:OnAddOnLoaded(event, addonName)
	FindMyStuff:Initialize()
end

EVENT_MANAGER:RegisterForEvent(FindMyStuff.Name, EVENT_ADD_ON_LOADED, function(event, addonName)
    if addonName == FindMyStuff.Name then
        FindMyStuff:OnAddOnLoaded(event, addonName)
    end
end)