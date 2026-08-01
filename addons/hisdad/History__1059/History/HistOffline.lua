-- The MIT License (MIT) http://opensource.org/licenses/MIT
-- Copyright (c) 2014-2020 His Dad

-- Some code from the luatz project (MIT Licence)

dofile "./Prog/utility.lua"		-- utility functions including configuration settings including the version


debug=false


--force_lang = "ru"  --	or "de" or "fr" or "ru" for debugging
--force_lang = "de"
--force_lang = "fr"
--force_lang = "es"


-- ========================

require( "iuplua" )
require( "iupluacontrols" )


if (iup._VERSION_NUMBER < 326000) then
	iup.Message("Old Version of IUP-LUA", "Upgrade to 3.26 or later.")
	iup.Close()
end

iup.SetGlobal("UTF8MODE","YES")
start=os.clock()
log("Starting to load SavedVariables Data")
dofile "../../SavedVariables/History.lua"
log("SavedVariables/history.lua Loaded.")


dung={}
Dat={}
Group_Dat={}
DLC_Dat={}


-- can be overwrrtten in my/custom.lua
Order={"Public",
"Group 1N","Group 1V","Group 1VH",
"Group 2N","Group 2V","Group 2VH",
"Trials Norm","Trials Vet","Trials Hard",
"DLC Group" }



dofile("./data/en/en-data.lua") -- Do this early so we can do an existance sanity_check() of the other data files. Defines Ach_Detail = {}



dofile "./Prog/Strings.lua"		-- String Handling
dofile "./Prog/make_a_tab.lua"

if (debug == false) then
	sanity_check = function() return end
end



dofile "./data/DLC_Grp.lua"
dofile "./data/meta/DLC_Order.lua"   -- and DLC_Order in english


-- DLC_Dat. The filenames are the category (DLC) names that we want to load as DLC2 tabs.
for _,file in ipairs (DLC_Order.dat) do
	thisfile = "./data/dlc/" .. file .. ".lua"
	dofile ("./data/dlc/" .. file .. ".lua")
	log("Loaded DLC " .. thisfile)
end



dofile "./data/DLC_Grp.lua"
dofile "./data/Group1.lua"		-- Grp Mode 1 data, N, V, VH
dofile "./data/Group2.lua"		-- Grp Mode 2 data, N, V, VH
dofile "./data/Public.lua"
dofile "./data/Quest.lua"
dofile "./data/WB.lua"
dofile "./data/Trials.lua"
dofile "./data/Special.lua"		-- Record of non standard Achievement ID's we need to keep. (may not be displayed)


log("Data Files loaded Ok")
--print(string.format("time: %.2f\n", os.clock() - start))

--generate_id ()			-- Generate the file the addon uses to filter Achievement ID's
-- This is used by the in game part history.lua to only record achievements that are used.
-- Uncomment when need to run.



 -- We need to load all the language translations. The problem is that we need to use a default language for the Accounts Dialog.
 -- The Accounts Dialog is the one that sets the account and thus the language. So we could end up changing the selected language!

  -- ===	Load Language Tables ====
	log("Starting load of all language translations.")
	langs={}

	for _,lang in ipairs{"en","de","fr","es","ru"} do
	langs[lang]={}
	local path = "./data/" .. lang .. "/"
	dofile (path .. lang .. "-ui.lua")
	langs[lang].L=L
	langs[lang].Area_names=Area_names
	end


	--What is the first Account Language, that we can use to start with.

accounts_list = {}		-- String list for selection dialog

for acc,_ in pairs(History_SV["Default"]) do
	log("Account: " .. acc)
	table.insert(accounts_list, acc)
end

if #accounts_list == 0 then
	print("Critical data Error. No Accounts in history.")
end

table.sort(accounts_list)

-- get the first account to start with
acc=accounts_list[1]

log("First Account is " .. acc)

-- get its language
  lang = (History_SV["Default"][acc]["$AccountWide"].lang)
	if lang == nil then
		print("Critical data Error. No Lang in history.")
		return
	end


	if force_lang ~= nil then
		lang = force_lang	-- Force the language for testing
		log("Language was forced.")
	end

	log("Initial Language is " .. lang)

-- print(string.format("End of first setup. (reset clock) time: %.2f\n", os.clock() - start))
--====
-- Create dialog to choose account
account_s = "ERROR"
local selected

if #accounts_list > 1 then
	selected = iup.ListDialog (1,  L.SelectA,
			#accounts_list,	--Size
			accounts_list,
			1, --Initial
			1,#accounts_list	--MaxCol MaxLine
			)


	if selected <0 then
			print("No Account Selected.")
			os.exit()
	else
		account_s = accounts_list[selected+1]
		log("Account " ..account_s .. " selected in dialog.")
	end
else

	account_s = accounts_list[1]		-- only 1 account, no need for Dialog
	log("Account " ..account_s .. " chosen. No Dialog")

end

start=os.clock()
account_t=History_SV["Default"][account_s]["$AccountWide"]
History_SV=nil

-- Now we know that account we are using, get the real language

lang = account_t.lang
if lang == nil then
	log("No language in datafile, default to en")
		lang = "en"
end

-- recheck for forcing
if force_lang ~= nil then
		lang = force_lang	-- Force the language for testing
		log("Language was forced again.")
end

log("Account Language is " .. lang)



local path = "./data/" .. lang .. "/"
-- ===	1. Load Language Files  ====
log("Loading lang data files " .. lang)
if lang ~= "en" then		--we have already done this for en at the start for sanity check
	dofile (path .. lang .."-data.lua")			--Achievement Data from game. Auto Generated.
end


dofile (path .. lang .."-DLC.lua")			--DLC Naming. Auto Generated but edited.. Creates DLC_Names{}  Array which  is for translation.
f,err= loadfile(path .. "MYDLC.lua")		--DLC Naming. Optional. Manually Created..  For personal DLC translations.
if f then
	f()
	log("DLC_Names custom override loaded")
else
	log("DLC_Names custom override file " .. path .. lang .."-MYDLC.lua" .. " not loaded. Err: " .. err)
end

-- and get the translations

L =langs[lang].L
Area_names =langs[lang].Area_names

langs=nil		-- one less thing to worry about

--we need to access players in a reproducible way. columns in dungeon mode for example
-- create a array of PlayerID
PlayerIDs={}
for PlayerID in pairs(account_t.data) do
	table.insert(PlayerIDs, PlayerID)
end
table.sort(PlayerIDs)
nplayers=#PlayerIDs

load_visibility()

--load customisation

f,err= loadfile("./my/custom.lua")		--Override defaults to limit display
if f then
	f()
	log("custom override loaded")
else
	log("custom override not loaded Err: " .. err)
end


-- ===	2. Translate WB Areas  ====

log("Add WB to Area_names table.")
--Add all WB to Area_name so we can get them by Area in one pass.
--Wb_Dat  [197] = {Area=1},		--Shipwreck Strand
--Area_Names  [16]={ name="Coldharbor"},
--Becomes [16]={ name="Coldharbor", WB[1]=ACH_ID},

for Ach,Data in pairs(WB_dat) do
	if Area_names[Data.Area] == nil then
		print("Error: with WB_Dat. Area ".. Data.Area .. " Not in Area_names. Ach = " .. Ach)
					break
	end
	local Area = Area_names[Data.Area]
	if Area.WB == nil then Area.WB={} end
	table.insert(Area.WB,Ach)
end

	-- ===	3. Translate SQ Areas  ====
log("Add SQ to Area_names table.")
--Add all SQ to Area_name so we can get them by Area in one pass.
--SQ_Dat [201] = {Area=1, ["link1"] ="http://www.uesp.net/wiki/Online:The_Death_of_Balreth" },
--Area_Names  [16]={ name="Coldharbor"},
--Becomes [16]={ name="Coldharbor", SQ[1]=ACH_ID},

for Ach,Data in pairs(SQ_dat) do
	if Area_names[Data.Area] == nil then
		print("Error: with SQ_Dat. Area ".. Data.Area .. " Not in Area_names. Ach = " .. Ach)
		break
	end
	local Area = Area_names[Data.Area]
	if Area.SQ == nil then Area.SQ={} end
	table.insert(Area.SQ,Ach)
end

	-- ===	1. Load Language Files  Complete ====

-- We are using account_s as the account name  (String) and index.
-- and account_t as the table



log("Account: " .. account_s)


--[[ At this point we know which account we are using and the translations are up.
-- account_s as the account name  (String)
-- account_t as the table
account_t.data[]  is the playerInfo by PlayerID


Now its time to create display items...
-]]






-- ====  Accountwide Display Data


Status_bar = iup.label{title=L.Welcome .. " " .. L.Version .. " " .. version .. ", for update " .. update .. msg, expand = "HORIZONTAL"}

mode_zbox = iup.zbox{}  -- display submain panel containing tabs and dungeons
char_tabs = iup.tabs{}  -- Top level of Char_Tabs, Character Info in Here
dung_tabs = iup.tabs{}  -- Top level of Dung_Tabs, Dungeon  Info in Here


iup.Append(mode_zbox, char_tabs)
iup.Append(mode_zbox, dung_tabs)





-- Mode Buttons (Toggles)
--[[  These control the display of the zbox
 Char mode lists the characters and information for them (default for prior versions)
 Dung Mode lists the dungeons and which characters have done them.
 Buttons are arranged in radio mode
 --]]

char_tog = iup.toggle{ title = L.Characters}
dung_tog = iup.toggle{ title = L.Dungeons}
filter_but = iup.button{title=L.Filter, visible="NO"}

function char_tog:action(x)
	if x == 1 then
		mode_zbox.value =char_tabs
		filter_but.VISIBLE="NO"
	end

end


function dung_tog:action(x)
	if x == 1 then
		mode_zbox.value =dung_tabs
		filter_but.VISIBLE="YES"
	end
end

function filter_but:action(x)
	select_box(account_t)
end


--Top part "Showing" has control buttons
mode = iup.frame {
								iup.hbox{
									iup.radio {
										iup.hbox{
												char_tog,
												dung_tog,
												},
										},
										filter_but,
									}
								}
mode.title =  L.Mode
mode.margin = "15x5"




-- ================  END Accountwide Data

log("Account Wide for Account " .. account_s .. " Done")
--print(string.format("End of Account Wide, time: %.2f\n", os.clock() - start))

--=================  START OF CHARACTER MODE DISPLAY

-- Creates boxes,

-- While doing this, put names and data files into dung{}

for _,PlayerID in ipairs(PlayerIDs) do
 local thischar=account_t.data[PlayerID]

	if thischar.visible == nil then
		thischar.visible = 1			--enable for display, use number as it easier to handle with dialogs
	end
	-- Pull in some char data for processing
	if thischar.name == nil  then --	Old Format
		log(print("Old Format  " .. PlayerID))
		thischar.name = PlayerID
	end


	log("PlayerID: " .. PlayerID .. " is " .. thischar.name)


	-- == Gender, replace with translations
	if thischar.Gender =="M" then
		thischar.Gender = L.Male
	elseif thischar.Gender == "F" then
		thischar.Gender = L.Female
	end

	-- == Cumulative TimePlayed
	if thischar.timeplayed == nil then
		thischar.timeplayed = 0
	else
		thischar.timeplayed = math.floor(thischar.timeplayed/60)
	end

-- End of data fixups


	thischar.data_tabs = iup.tabs{} --Data tabs for Char

	for _,i in ipairs(Order) do

		make_a_tab(thischar,thischar.data_tabs,L.box[i],Dat[i])
		dung[i] = {}
		dung[i].name=i
		dung[i].xlated = L.box[i] or i .. " No Translation"	-- L.box[]  is the translation from the UI file.
		dung[i].dat = Dat[i].dat
	end



-- Create WorldBoss Achievements Box==========================
	log("Starting WB Box")
	thischar.WB_box= Location_Box(thischar, "WB")
	log("Done WB Box")

-- Create SkillQuest Achievements Box==========================
	log("Starting SQ Box")
	thischar.SQ_box= Location_Box(thischar, "SQ")
	log("Done SQ Box")

--========== DLC

	thischar.DLC2 = {}
	thischar.DLC2_tabs = iup.flattabs{}		-- we add our tabs to here for display. (list of vboxes)


	local wrap_size = math.floor(250/3.7)


--	These don't go into  dung.
-- a Second level of tabs for DLC2
	for _,dlc in ipairs (DLC_Order.dat) do  -- dlc is untranslated string . default en   my_name(dlc)  is the translation
		make_a_tab(thischar,thischar.DLC2_tabs,my_name(dlc),DLC_Dat[dlc])
	end

--====================================
--  == Prepare for the character data display tabs
	thischar.tab = iup.vbox{
					["tabtitle"] =thischar.name,		-- This vbox will be a tab and the tab text is this

					iup.hbox{		--Top Information bar
						Alignment = "ACENTER",
						iup.label{title=thischar.world,PADDING="10X0"},
						iup.label{title=thischar.gender, FONT="Times,BOLD,10"},
						iup.label{title=thischar.Race .." / ".. thischar.Class, PADDING="10X0", FONT="Times,BOLD,10"},
						iup.label{title=thischar.Alliance, PADDING="10X0"},
						iup.label{title=L.Created .. os.date(dateformat,thischar.Created), PADDING="10X0"},
						iup.label{title=L.LLog .. os.date(dateformat,thischar.LoginTime), PADDING="10X0"},
						iup.label{title=L.TPlayed .. thischar.timeplayed .." " .. L.Hrs},
						iup.fill{}
						},
				iup.label{SEPARATOR="HORIZONTAL"}
				}


	iup.Append(thischar.data_tabs, iup.vbox {
					["tabtitle"] =L.WBosses,
					iup.label{title=L.WBLab,expand="HORIZONTAL"},
					thischar.WB_box,
					iup.fill{}
				})


	iup.Append(thischar.data_tabs, iup.vbox {
					["tabtitle"] =L.SkillQuests,
					iup.label{title=L.SkillLab,expand="HORIZONTAL"},
					thischar.SQ_box,
					iup.fill{}
				})


	iup.Append(thischar.data_tabs, iup.vbox {
					["tabtitle"] ="DLC2",
					iup.label{title=L.DLCLab,expand="HORIZONTAL"},
					thischar.DLC2_tabs,
					iup.fill{},
				})



	iup.Append(thischar.tab,thischar.data_tabs)		-- Add Dungeons/Data under the Character

	iup.Append(char_tabs,thischar.tab) -- Add Char tab to level for characters
end -- next player


--=================  END OF CHARACTER MODE DISPLAY
--print(string.format("Start Dung Mode Display time: %.2f\n", os.clock() - start))
--=================  START OF DUNGEON MODE DISPLAY
-- We have already added the data files to the dung table while setting up the char data above.
-- Now make it displayable


-- DefWidth  is set at the start of this file and can be set in custom.lua

for _,name in ipairs(Order) do
	local this=dung[name]
	this.box = iup.matrix {READONLY="YES", WIDTHDEF=DefWidth, numcol=(2+ nplayers), numlin=#this.dat,	["tabtitle"] = this.xlated }
	-- iup.SetAttribute(this.box,  "BGCOLOR" , BG_Colour_Not_Complete)

	--set lines Heading
	set_headings(this)


	--Load Lines (Dungeon Ach names)
	for line,Ach in ipairs(this.dat) do
		this.box:setcell(line, 1, Ach)
		this.box:setcell(line, 2, Ach_Detail[Ach].name)
	end

	iup.Append(dung_tabs,this.box)
end


-- Generic function for populating dungeon mode boxes with player data.

populate = function(ADung)

	if ADung == nil then
		print("Populate: ADung is nil")
		return
	end

	if ADung.name == nil then
		print("Populate: ADung.name is nil")
		return
	end

  -- log("Populate " .. ADung.name)


	for	col,PlayerID in ipairs(PlayerIDs) do

		ADung.box:setcell(0,col+2, account_t.data[PlayerID].name)

		for line,Ach in ipairs(ADung.dat) do

			isCompleted = account_t.data[PlayerID].ach[Ach] or false

			if isCompleted  then
				ADung.box:setcell(line, col+2, L.YesLabel)
				iup.SetAttribute(ADung.box,"BGCOLOR" .. tostring(line) .. ":" .. tostring(col+2), BG_Colour_Complete)
			else
				ADung.box:setcell(line,col+2, L.NoLabel)
				iup.SetAttribute(ADung.box,"BGCOLOR" .. tostring(line) .. ":" .. tostring(col+2), BG_Colour_Not_Complete)
			end

		end
	end

end


-- print(string.format("Populate Start time: %.2f\n", os.clock() - start))

	-- Populate dungeons boxes with character data ============================
for _,datname in ipairs(Order) do
  if (dung[datname] == nil ) then
		print("datname not in dung[]: " .. datname)
	end
	populate(dung[datname])
end




	local wide =((#account_t.data+1) * 110)
	if wide < 690  then
		wide = 690
	elseif wide >960 then
		wide =  960
	end

	panelsize =  tostring(wide) ..  "x350"

-- print(string.format("Starting display time: %.2f\n", os.clock() - start))


	-- Create dialog if not cancelled
	dlg = iup.dialog{iup.vbox{
							mode,
							mode_zbox,
							Status_bar,	-- Bottom Status bar.
							margin="5x5",
							ngap="3",
							},
					title=L.title .. account_s ,
					size=panelsize,
					}
	-- Shows dialog in the centre of the screen
	dlg:showxy(iup.CENTER, iup.CENTER)

-- print(string.format("End of display time: %.2f\n", os.clock() - start))
	if (iup.MainLoopLevel()==0) then
	  iup.MainLoop()
	end

