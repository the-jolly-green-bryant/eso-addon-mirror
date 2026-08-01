-- Load libraries
local LAM = LibAddonMenu2
local LMP = LibMediaProvider

-- create global object
CraftingSwit = CraftingSwit or {}

-- Add info to the display box
function CraftingSwit.AddNewContent(bindex, qstep, qtext)
	local fontsize = GetChatFontSize()
	local bgwidth = CraftingSwit.SavedVars.BgWidth
	local bgpadding = bgwidth - CraftingSwit.SavedVars.TextPadding
	-- Generate a new box if not exist one

	if not CraftingSwit.box[bindex] then
		-- Create Container Box
		CraftingSwit.box[bindex] = WINDOW_MANAGER:CreateControl("CraftingSwit_CraftGroup_" .. bindex, CraftingSwitBg, CT_LABEL)
		CraftingSwit.box[bindex]:ClearAnchors()
		CraftingSwit.box[bindex]:SetResizeToFitDescendents(true)
		if bindex == 1 then
			CraftingSwit.box[bindex]:SetAnchor(TOPLEFT, CraftingSwitBg, TOPLEFT,0,0)
		else
			CraftingSwit.box[bindex]:SetAnchor(TOPLEFT, CraftingSwit.box[bindex-1], BOTTOMLEFT,0,0)
		end

		-- Create Text Box
		CraftingSwit.textbox[bindex] = WINDOW_MANAGER:CreateControl("CraftingSwit_CraftItems_" .. bindex, CraftingSwit.box[bindex], CT_LABEL)
		CraftingSwit.textbox[bindex]:ClearAnchors()
		CraftingSwit.textbox[bindex]:SetAnchor(CENTER,CraftingSwit.box[bindex],CENTER,0,0)
		CraftingSwit.textbox[bindex]:SetDrawLayer(DL_TEXT)
	end

	-- Refresh content
	CraftingSwit.box[bindex]:SetDimensionConstraints(bgwidth, -1, bgwidth, -1)
--	CraftingSwit.textbox[bindex]:SetDimensionConstraints(bgpadding, -1, bgpadding, -1)

	if bindex > 1 and qstep == 0 then
		CraftingSwit.textbox[bindex]:SetText("\n" .. qtext)
	else
		CraftingSwit.textbox[bindex]:SetText(qtext)
	end
	if qstep == 0 then -- make the font bigger if it's the first quest step, because of the heading
		CraftingSwit.textbox[bindex]:SetFont(("%s|%s|%s"):format(LMP:Fetch('font', CraftingSwit.SavedVars.TextFont), fontsize + 4, CraftingSwit.SavedVars.TextStyle))
	else -- the quest steps
		CraftingSwit.textbox[bindex]:SetFont(("%s|%s|%s"):format(LMP:Fetch('font', CraftingSwit.SavedVars.TextFont), fontsize, CraftingSwit.SavedVars.TextStyle))
	end

	CraftingSwit.textbox[bindex]:SetColor(CraftingSwit.SavedVars.TextColor.r, CraftingSwit.SavedVars.TextColor.g, CraftingSwit.SavedVars.TextColor.b, CraftingSwit.SavedVars.TextColor.a)
end


function CraftingSwit.LoadQuestsInfo(i)
	local WritName = ""
	local WritSteps = ""
	local qname, backgroundText, activeStepText, activeStepType, activeStepTrackerOverrideText, completed, tracked, qlevel, pushed, qtype = GetJournalQuestInfo(i)
	local isComplete
	local matNeeds = {}

	if (qname and qname ~= "") and string.match(qname, "Writ") then
		WritName = qname

		writType = CraftingSwit.lookupCraftType(WritName)


		local stepCount = GetJournalQuestNumSteps(i)

		for idx=1, stepCount do

			local qstep, visibility, stepType, trackerOverrideText, numConditions = GetJournalQuestStepInfo(i,idx)
			if qstep and qstep ~= "" then
				for m=1, numConditions do
					local conditionText, currentval, maxval, isFailCondition, _, isCreditShared = GetJournalQuestConditionInfo(i, idx, m)
					if conditionText == nil then
						conditionText = ""
					end

					isComplete = currentval == maxval

					if conditionText > "" then
						if not (CraftingSwit.GetHideCompleted() and isComplete) then
							if conditionText and conditionText ~= "" then
								if WritSteps ~= "" then
									WritSteps = WritSteps .. "\n"
								end
								WritSteps = WritSteps .. conditionText
							end
						end

						if not isComplete then
							if writType ~= CRAFTING_TYPE_PROVISIONING and
					 			writType ~= CRAFTING_TYPE_ALCHEMY then
								itemKey, matKey = CraftingSwit.lookupItemType(writType, conditionText)
								if matKey ~= nil and itemKey ~= nil then
									if matNeeds[matKey] == nil then
										matNeeds[matKey] = 0
									end
									if writType == CRAFTING_TYPE_ENCHANTING then
										matNeeds[matKey] = matNeeds[matKey] + (maxval - currentval)
										if matNeeds[itemKey * -1] == nil then
											matNeeds[itemKey * -1] = 0
										end
										matNeeds[itemKey * -1] = matNeeds[itemKey * -1] + (maxval - currentval)
										if matNeeds[0] == nil then
											matNeeds[0] = 0
										end
										matNeeds[0] = matNeeds[0] + (maxval - currentval)
									else
										matNeeds[matKey] = matNeeds[matKey] + (CraftingSwit.CraftVals[writType][matKey][itemKey] * (maxval - currentval))

										CraftingSwit.matStyleCount = CraftingSwit.matStyleCount + (maxval - currentval)
									end
								end
							end
						end
					end
				end
			end
		end -- for quest step end
		matString = ""
		for i, qty in pairs(matNeeds) do
			if matString ~= "" then
				matString = matString .. "\n           "
			end
			if i <= 0 then
				if i == 0 then
					matString = matString .. qty .. " Ta"
				else
					i = i * -1
					matString = matString .. qty .. " " .. CraftingSwit.essenceNames[i]
				end
			else
				matString = matString .. qty .. " " .. CraftingSwit.craftInfo[writType]["names"][i]
			end
		end
		if matString > "" then
			WritSteps = WritSteps .. "\nNeed: " .. matString
		end
	end

	return WritName, WritSteps, writType
end

function CraftingSwit.QuestsLoop()
	local WritName = ""
	local WritSteps = ""
	local writType = 0
	local WritAY = {}
	local j, ctr

	j = 1
	ctr = 1

	CraftingSwit.matStyleCount = 0
	for i=1, MAX_JOURNAL_QUESTS do
		if IsValidQuestIndex(i) then
			WritName, WritSteps, writType = CraftingSwit.LoadQuestsInfo(i)
			if WritName ~= "" then
				WritAY[ctr] = { ["name"] = WritName, ["steps"] = WritSteps }

				if CraftingSwit.matStyleCount > 0 and
					ctr > 1 and
					(writType == CRAFTING_TYPE_ENCHANTING or
					 writType == CRAFTING_TYPE_PROVISIONING or
					 writType == CRAFTING_TYPE_ALCHEMY) then
					 WritAY[ctr - 1]["steps"] = WritAY[ctr - 1]["steps"] .. "\n\nNeed: " .. CraftingSwit.matStyleCount .. " style mats total"
					CraftingSwit.matStyleCount = 0
				end
				ctr = ctr + 1
			end
		end
	end

	for i = 1, #WritAY do
		CraftingSwit.AddNewContent(j, 0, "|cF0F000" .. WritAY[i]["name"] .. "|r")
		j = j + 1
		CraftingSwit.AddNewContent(j, 1, WritAY[i]["steps"])
		j = j + 1
	end



	-- if there were no enchanting/provisioning/alchemy writs, the matStyleCount won't be added in LoadQuestsInfo
	-- since one or more of them might be missing, it would be too hard to find out what is/isn't present within it
	if CraftingSwit.matStyleCount > 0 then
		CraftingSwit.AddNewContent(j, 1, "\nNeed: " .. CraftingSwit.matStyleCount .. " style mats total")
	end
end

function CraftingSwit.QuestsListUpdate(eventcode)
	-- Clear the other created boxes
	CraftingSwit.ClearBoxes()

	-- List All Quests
	CraftingSwit.QuestsLoop()
end


function CraftingSwit.RegisterForSceneChanges()
	local sceneList = {
		"smithing",
		"provisioner",
		"enchanting",
		"alchemy",
		"bank",
	}

	local fragment = ZO_SimpleSceneFragment:New(CraftingSwitMain)

	for i, sceneName in ipairs(sceneList) do
		local scene = SCENE_MANAGER:GetScene(sceneName)
		scene:AddFragment(fragment)
	end
end


----------------------------------
--		  Start & Menu
----------------------------------
function CraftingSwit.Init(eventCode, addOnName)

	if addOnName ~= "CraftingSwit" then return end

	-- we've been called to setup, get us out of the event list now
	EVENT_MANAGER:UnregisterForEvent("CraftingSwit", EVENT_ADD_ON_LOADED)

	CraftingSwit.langInit()

	-- Create & load defaults vars
	CraftingSwit.box = {}
	CraftingSwit.textbox = {}
	if not CraftingSwit.SavedVars then
		CraftingSwit.SavedVars = ZO_SavedVars:NewAccountWide("CraftingSwitSavedVars", 5, nil, CraftingSwit.defaults) or CraftingSwit.defaults
	end
	-- 5-2-2019 AM - remove data from the savedvars that we're not using anymore
	CraftingSwit.SavedVars.CraftVals = nil
	CraftingSwit.SavedVars.CraftValsDone = nil


	-- Create the UI boxes
	-- Main Box is in the window xml
	CraftingSwitMain:ClearAnchors()
	-- Set Swit position if it's been saved, otherwise default to 200, 200
	if CraftingSwit.SavedVars.position then
		--CraftingSwitMain:SetAnchor(CraftingSwit.SavedVars.position.point, GuiRoot, CraftingSwit.SavedVars.position.relativePoint, CraftingSwit.SavedVars.position.offsetX, CraftingSwit.SavedVars.position.offsetY)
		CraftingSwitMain:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, CraftingSwit.SavedVars.position.offsetX, CraftingSwit.SavedVars.position.offsetY)
	else
		CraftingSwitMain:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, 200, 200)
	end
	CraftingSwitMain:SetDimensions(300,40)
	CraftingSwitMain:SetResizeToFitDescendents(true)
	CraftingSwitMain:SetAlpha(CraftingSwit.SavedVars.BgAlpha/100)

	CraftingSwitMain:SetMovable(not CraftingSwit.SavedVars.PositionLockOption)
	CraftingSwitMain:SetMouseEnabled(not CraftingSwit.SavedVars.PositionLockOption)

	-- Main Background
	CraftingSwitBg = WINDOW_MANAGER:CreateControl("CraftingSwit_Background", CraftingSwitMain, CT_STATUSBAR)
	CraftingSwitBg:ClearAnchors()
	CraftingSwitBg:SetAnchor(TOPLEFT, CraftingSwitMain, TOPLEFT, 0, 0)
	CraftingSwitBg:SetDimensions(300,40)
	CraftingSwitBg:SetDrawLayer(1)
	CraftingSwitBg:SetResizeToFitDescendents(true)

	if CraftingSwit.SavedVars.BgOption == true then
		CraftingSwitBg:SetColor(CraftingSwit.SavedVars.BgColor.r,CraftingSwit.SavedVars.BgColor.g,CraftingSwit.SavedVars.BgColor.b,CraftingSwit.SavedVars.BgColor.a)
	else
		CraftingSwitBg:SetColor(0,0,0,0)
	end

	CraftingSwit.mylanguage = {}

	if CraftingSwit.SavedVars.Language == "Français" then
		CraftingSwit.mylanguage = CraftingSwit.language.fr
	elseif CraftingSwit.SavedVars.Language == "Deutsch" then
		CraftingSwit.mylanguage = CraftingSwit.language.de
	else
		CraftingSwit.mylanguage = CraftingSwit.language.us
	end

	-- Create new menu
	local panelData = {
		type = "panel",
		name = CraftingSwit.mylanguage.lang_craftingswit_settings,
		displayName = ZO_HIGHLIGHT_TEXT:Colorize(CraftingSwit.mylanguage.lang_craftingswit_settings),
		author = "AssemblerManiac",
		prevAuthor = "manavortex",
		version = "1.07",
		slashCommand = "/swit",
		registerForRefresh = true,
--			registerForDefaults = true,
	}
	LAM:RegisterAddonPanel("CraftingSwit_Settings", panelData)

	-- Box Settings
	local optionsData = {
		{
			type = "header",
			name = CraftingSwit.mylanguage.lang_global_settings,
		},
		{
			type = "dropdown",
			name = CraftingSwit.mylanguage.lang_language_settings,
			tooltip = CraftingSwit.mylanguage.lang_language_settings_tip,
			choices = {"English", "Français", "Deutsch"},
			getFunc = CraftingSwit.GetLanguage,
			setFunc = CraftingSwit.SetLanguage,
			warning = CraftingSwit.mylanguage.lang_menu_warn_1,
		},
		{
			type = "slider",
			name = CraftingSwit.mylanguage.lang_overall_transparency,
			tooltip = CraftingSwit.mylanguage.lang_overall_transparency_tip,
			min = 1,
			max = 100,
			getFunc = CraftingSwit.GetBgAlpha,
			setFunc = CraftingSwit.SetBgAlpha,
		},
		{
			type = "slider",
			name = CraftingSwit.mylanguage.lang_overall_width,
			tooltip = CraftingSwit.mylanguage.lang_overall_width_tip,
			min = 100,
			max = 600,
			getFunc = CraftingSwit.GetBgWidth,
			setFunc = CraftingSwit.SetBgWidth,
		},
		{
			type = "checkbox",
			name = CraftingSwit.mylanguage.lang_position_lock,
			tooltip = CraftingSwit.mylanguage.lang_position_lock_tip,
			getFunc = CraftingSwit.GetPositionLockOption,
			setFunc = CraftingSwit.SetPositionLockOption,
		},
		{
			type = "checkbox",
			name = CraftingSwit.mylanguage.lang_hide_completed,
			tooltip = CraftingSwit.mylanguage.lang_hide_completed_tip,
			getFunc = CraftingSwit.GetHideCompleted,
			setFunc = CraftingSwit.SetHideCompleted,
		},
		{
			type = "checkbox",
			name = CraftingSwit.mylanguage.lang_backgroundcolor_opt,
			tooltip = CraftingSwit.mylanguage.lang_backgroundcolor_opt_tip,
			getFunc = CraftingSwit.GetBgOption,
			setFunc = CraftingSwit.SetBgOption,
		},
		{
			type = "colorpicker",
			name = CraftingSwit.mylanguage.lang_backgroundcolor_value,
			tooltip = CraftingSwit.mylanguage.lang_backgroundcolor_value_tip,
			getFunc = CraftingSwit.GetBgColor,
			setFunc = CraftingSwit.SetBgColor,
			disabled = function () return not CraftingSwit.SavedVars.BgOption end,
		},

	}

	LAM:RegisterOptionControls("CraftingSwit_Settings", optionsData)

	-- First Init
	CraftingSwit.QuestsListUpdate()

	-- UPDATES with EVENTS
	EVENT_MANAGER:RegisterForEvent("CraftingSwit", EVENT_QUEST_REMOVED, CraftingSwit.QuestsListUpdate) --> EC:131091 delete quest
	EVENT_MANAGER:RegisterForEvent("CraftingSwit", EVENT_QUEST_ADVANCED, CraftingSwit.QuestsListUpdate) --> EC:131090
	EVENT_MANAGER:RegisterForEvent("CraftingSwit", EVENT_QUEST_OPTIONAL_STEP_ADVANCED, CraftingSwit.QuestsListUpdate)
	EVENT_MANAGER:RegisterForEvent("CraftingSwit", EVENT_QUEST_ADDED, CraftingSwit.QuestsListUpdate) --> EC:131078 add quest
	EVENT_MANAGER:RegisterForEvent("CraftingSwit", EVENT_QUEST_CONDITION_COUNTER_CHANGED, CraftingSwit.QuestsListUpdate)
	EVENT_MANAGER:RegisterForEvent("CraftingSwit", EVENT_PLAYER_ACTIVATED, CraftingSwit.QuestsListUpdate)

	EVENT_MANAGER:RegisterForEvent("CraftingSwit", EVENT_CRAFTING_STATION_INTERACT, CraftingSwit.craftInit)


	-- when scene changes, see if we should be showing the widget
	CraftingSwit.RegisterForSceneChanges()
end

-- configured to call from xml
function CraftingSwit.MoveStop()
	-- save current postion after we stop moving the widget
	CraftingSwit.SavedVars.position.offsetX = CraftingSwitMain:GetLeft()
	CraftingSwit.SavedVars.position.offsetY = CraftingSwitMain:GetTop()
end

-- Load on interface load or reload
EVENT_MANAGER:RegisterForEvent("CraftingSwit", EVENT_ADD_ON_LOADED, CraftingSwit.Init)



--[[

-- when crafting, this index tells it what Material to use, each element is the first of the type (ex: 32 & 33 are silverweave, for vr7 & vr8 respectively)

MatsIndexes = { 1, 8, 13, 18, 23, 26, 29, 32, 34, 40,
  				1, 8, 13, 18, 23, 26, 29, 32, 34, 40 }

]]--

function CraftingSwit.craftInit(eventCode, station)
	if not (station == CRAFTING_TYPE_BLACKSMITHING or
			station == CRAFTING_TYPE_CLOTHIER or
			station == CRAFTING_TYPE_WOODWORKING or
			station == CRAFTING_TYPE_JEWELRYCRAFTING) then return end

--[[	if CraftingSwit.SavedVars.CraftValsDone == nil then
		CraftingSwit.SavedVars.CraftVals = {}
		CraftingSwit.SavedVars.CraftValsDone = {}
		CraftingSwit.SavedVars.CraftValsDone[station] = false
	end

	if CraftingSwit.SavedVars.CraftValsDone[station] == true then
   		return
	end

--	CraftingSwit.SavedVars.CraftValsDone[station] = true

	local MatsIndexes = { 1, 8, 13, 18, 23, 26, 29, 32, 34, 40,
  						  1, 8, 13, 18, 23, 26, 29, 32, 34, 40,
						}



	CraftingSwit.CraftVals[station] = {}

	-- creates 2d array of rows = pieces, cols = mats, each entry in array is # mats, of the proper type, needed to craft item

	for matkey in pairs(CraftingSwit.craftInfo[station]["mats"]) do
		CraftingSwit.CraftVals[station][matkey] = {}
		for itemkey in pairs(CraftingSwit.craftInfo[station]["pieces"]) do
			CraftingSwit.CraftVals[station][matkey][itemkey] = GetSmithingPatternNextMaterialQuantity(itemkey, MatsIndexes[matkey], 1, 1)
		end
	end
--]]
--	CraftingSwit.SavedVars.CraftValsDone[station] = true

	CraftingSwit.QuestsListUpdate(nil)		-- event code required, but not used
end

function CraftingSwit.lookupCraftType(craftTitle)

	local pos = nil
	for i, txt in pairs(CraftingSwit.writTypes) do
		if zo_plainstrfind(craftTitle:lower(), txt:lower()) then
			pos = i
			break
		end
	end

	return pos
end

-- returns pieceNum, matNum
function CraftingSwit.lookupItemType(craftType, condition)
	local pieceNum = nil
	local matNum = nil

	srchItems = CraftingSwit.craftInfo[craftType]["mats"]

	for i=#srchItems, 1, -1 do
		if zo_plainstrfind(condition:lower(), srchItems[i]:lower()) then
			matNum = i
			break
		end
	end

	if matNum == nil then
		return nil
	end

	srchItems = CraftingSwit.craftInfo[craftType]["pieces"]

	for i=#srchItems, 1, -1 do
		if zo_plainstrfind(condition:lower(), srchItems[i]:lower()) then
			pieceNum = i
			break
		end
	end

	if pieceNum == nil then
		return nil
	end

	return pieceNum, matNum

end

function CraftingSwit.langInit()
	-- these must match writ text exactly
	CraftingSwit.writTypes =
		{
		[CRAFTING_TYPE_ENCHANTING] = "Enchanter",
		[CRAFTING_TYPE_BLACKSMITHING] = "Blacksmith",
		[CRAFTING_TYPE_CLOTHIER] = "Clothier",
		[CRAFTING_TYPE_PROVISIONING] = "Provisioner",
		[CRAFTING_TYPE_WOODWORKING] = "Woodworker",
		[CRAFTING_TYPE_ALCHEMY] = "Alchemist",
		[CRAFTING_TYPE_JEWELRYCRAFTING] = "Jewelry"
		}

	CraftingSwit.craftInfo =
		{
		[CRAFTING_TYPE_CLOTHIER] =
			{
			["pieces"] = --exact!!
				{
				[1] = "robe",
				[2] = "jerkin",
				[3] = "shoes",
				[4] = "gloves",
				[5] = "hat",
				[6] = "breeches",
				[7] = "epaulet",
				[8] = "sash",
				[9] = "jack",
				[10] = "boots",
				[11] = "bracers",
				[12] = "helmet",
				[13] = "guards",
				[14] = "cops",
				[15] = "belt",
				},
			["mats"] = --exact!!! This is not the material, but rather the prefix the material gives to equipment. e.g. Homespun Robe, Linen Robe
				{
				[1] = "Homespun", --lvtier one of mats
				[2] = "Linen",	--l
				[3] = "Cotton",
				[4] = "Spidersilk",
				[5] = "Ebonthread",
				[6] = "Kresh",
				[7] = "Ironthread",
				[8] = "Silverweave",
				[9] = "Shadowspun",
				[10] = "Ancestor",
				[11] = "Rawhide",
				[12] = "Hide",
				[13] = "Leather",
				[14] = "Full-Leather",
				[15] = "Fell",
				[16] = "Brigandine",
				[17] = "Ironhide",
				[18] = "Superb",
				[19] = "Shadowhide",
				[20] = "Rubedo Leather",
				},
			["names"] = --Does not strictly need to be exact, but people would probably appreciate it
				{
				[1] = "Jute",
				[2] = "Flax",
				[3] = "Cotton",
				[4] = "Spidersilk",
				[5] = "Ebonthread",
				[6] = "Kresh Fiber",
				[7] = "Ironthread",
				[8] = "Silverweave",
				[9] = "Void Cloth",
				[10] = "Ancestor Silk",
				[11] = "Rawhide",
				[12] = "Hide",
				[13] = "Leather",
				[14] = "Thick Leather",
				[15] = "Fell Hide",
				[16] = "Topgrain Hide",
				[17] = "Iron Hide",
				[18] = "Superb Hide",
				[19] = "Shadowhide",
				[20] = "Rubedo Leather",
				}
			},
		[CRAFTING_TYPE_BLACKSMITHING] =
			{
			["pieces"] = --exact!!
				{
				[4] = "battle",
				[1] = "axe",
				[2] = "mace",
				[3] = "sword",
				[5] = "maul",
				[6] = "greatsword",
				[7] = "dagger",
				[8] = "cuirass",
				[9] = "sabatons",
				[10] = "gauntlets",
				[11] = "helm",
				[12] = "greaves",
				[13] = "pauldron",
				[14] = "girdle",
				},
			["mats"] = --exact!!! This is not the material, but rather the prefix the material gives to equipment. e.g. Iron Axe, Steel Axe
				{
				[1] = "Iron",
				[2] = "Steel",
				[3] = "Orichalc",
				[4] = "Dwarven",
				[5] = "Ebon",
				[6] = "Calcinium",
				[7] = "Galatite",
				[8] = "Quicksilver",
				[9] = "Voidsteel",
				[10] = "Rubedite",
				},
			["names"] = --Does not strictly need to be exact, but people would probably appreciate it
				{
				[1] = "Iron Ingots",
				[2] = "Steel Ingots",
				[3] = "Orichalc Ingots",
				[4] = "Dwarven Ingots",
				[5] = "Ebony Ingots",
				[6] = "Calcinium Ingots",
				[7] = "Galatite Ingots",
				[8] = "Quicksilver Ingots",
				[9] = "Voidstone Ingots",
				[10]= "Rubedite Ingots",
				}
			},
		[CRAFTING_TYPE_WOODWORKING] =
			{
			["pieces"] = --Exact!!!
				{
				[1] = "bow",
				[2] = "shield",
				[3] = "inferno",
				[4] = "ice",
				[5] = "lightning",
				[6] = "restoration",
				},
			["mats"] = --exact!!! This is not the material, but rather the prefix the material gives to equipment. e.g. Maple Bow. Oak Bow.
				{
				[1] = "Maple",
				[2] = "Oak",
				[3] = "Beech",
				[4] = "Hickory",
				[5] = "Yew",
				[6] = "Birch",
				[7] = "Ash",
				[8] = "Mahogany",
				[9] = "Nightwood",
				[10] = "Ruby",
				},
			["names"] = --Does not strictly need to be exact, but people would probably appreciate it
				{
				[1] = "Sanded Maple",
				[2] = "Sanded Oak",
				[3] = "Sanded Beech",
				[4] = "Sanded Hickory",
				[5] = "Sanded Yew",
				[6] = "Sanded Birch",
				[7] = "Sanded Ash",
				[8] = "Sanded Mahogany",
				[9] = "Sanded Nightwood",
				[10]= "Sanded Ruby Ash",
				}
			},
		[CRAFTING_TYPE_ENCHANTING] =
			{
			["pieces"] = --exact!!
				{
				[2] = "stamina",
				[1] = "health",
				[3] = "magicka",
				},
			["mats"] = --names of glyphs. The prefix (in English) So trifling glyph of magicka, for example
				{
				[1] = "trifling",
				[2] = "inferior",
				[3] = "petty",
				[4] = "slight",
				[5] = "minor",
				[6] = "lesser",
				[7] = "moderate",
				[8] = "average",
				[9] = "strong",
				[10] = "major",
				[11] = "greater",
				[12] = "grand",
				[13] = "splendid",
				[14] = "monumental",
				[15] = "superb",
				[16] = "truly",
				},
			["names"] =
				{
				[1] = "Jora", --Lowest potency stone lvl
				[2] = "Porade",
				[3] = "Jera",
				[4] = "Jejora",
				[5] = "Odra",
				[6] = "Pojora",
				[7] = "Edora",
				[8] = "Jaera",
				[9] = "Pora",
				[10] = "Denara",
				[11] = "Rera",
				[12] = "Derado",
				[13] = "Rekura",
				[14] = "Kura",
				[15] = "Rejera",
				[16] = "Repora", --v16 potency stone
				},
			},
		[CRAFTING_TYPE_JEWELRYCRAFTING] =
			{
			["pieces"] = --Exact!!!
				{
				[1] = "ring",
				[2] = "necklace",
				},
			["mats"] = --exact!!! This is not the material, but rather the prefix the material gives to equipment. e.g. Maple Bow. Oak Bow.
				{
				[1] = "Pewter",
				[2] = "Copper",
				[3] = "Silver",
				[4] = "Electrum",
				[5] = "Platinum",
				},
			["names"] = --Does not strictly need to be exact, but people would probably appreciate it
				{
				[1] = "Pewter Ounce",
				[2] = "Copper Ounce",
				[3] = "Silver Ounce",
				[4] = "Electrum Ounce",
				[5] = "Platinum Ounce",
				}
			},
		}

	CraftingSwit.essenceNames =
		{
		[1] = "Oko", --health
		[2] = "Deni", --stamina
		[3] = "Makko", --magicka
		}

    CraftingSwit.CraftVals =
        {
            [CRAFTING_TYPE_BLACKSMITHING] =
            {
                [1] =
                {
                    [1] = 3,
                    [2] = 3,
                    [3] = 3,
                    [4] = 5,
                    [5] = 5,
                    [6] = 5,
                    [7] = 2,
                    [8] = 7,
                    [9] = 5,
                    [10] = 5,
                    [11] = 5,
                    [12] = 6,
                    [13] = 5,
                    [14] = 5,
                },
                [2] =
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 4,
                    [4] = 6,
                    [5] = 6,
                    [6] = 6,
                    [7] = 3,
                    [8] = 8,
                    [9] = 6,
                    [10] = 6,
                    [11] = 6,
                    [12] = 6,
                    [13] = 6,
                    [14] = 6,
                },
                [3] =
                {
                    [1] = 5,
                    [2] = 5,
                    [3] = 5,
                    [4] = 7,
                    [5] = 7,
                    [6] = 7,
                    [7] = 4,
                    [8] = 9,
                    [9] = 7,
                    [10] = 7,
                    [11] = 7,
                    [12] = 8,
                    [13] = 7,
                    [14] = 7,
                },
                [4] =
                {
                    [1] = 6,
                    [2] = 6,
                    [3] = 6,
                    [4] = 8,
                    [5] = 8,
                    [6] = 8,
                    [7] = 5,
                    [8] = 10,
                    [9] = 8,
                    [10] = 8,
                    [11] = 8,
                    [12] = 9,
                    [13] = 8,
                    [14] = 8,
                },
                [5] =
                {
                    [1] = 7,
                    [2] = 7,
                    [3] = 7,
                    [4] = 9,
                    [5] = 9,
                    [6] = 9,
                    [7] = 6,
                    [8] = 11,
                    [9] = 9,
                    [10] = 9,
                    [11] = 9,
                    [12] = 10,
                    [13] = 9,
                    [14] = 9,
                },
                [6] =
                {
                    [1] = 8,
                    [2] = 8,
                    [3] = 8,
                    [4] = 10,
                    [5] = 10,
                    [6] = 10,
                    [7] = 7,
                    [8] = 12,
                    [9] = 10,
                    [10] = 10,
                    [11] = 10,
                    [12] = 11,
                    [13] = 10,
                    [14] = 10,
                },
                [7] =
                {
                    [1] = 9,
                    [2] = 9,
                    [3] = 9,
                    [4] = 11,
                    [5] = 11,
                    [6] = 11,
                    [7] = 8,
                    [8] = 13,
                    [9] = 11,
                    [10] = 11,
                    [11] = 11,
                    [12] = 12,
                    [13] = 11,
                    [14] = 11,
                },
                [8] =
                {
                    [1] = 10,
                    [2] = 10,
                    [3] = 10,
                    [4] = 12,
                    [5] = 12,
                    [6] = 12,
                    [7] = 9,
                    [8] = 14,
                    [9] = 12,
                    [10] = 12,
                    [11] = 12,
                    [12] = 13,
                    [13] = 12,
                    [14] = 12,
                },
                [9] =
                {
                    [1] = 11,
                    [2] = 11,
                    [3] = 11,
                    [4] = 13,
                    [5] = 13,
                    [6] = 13,
                    [7] = 10,
                    [8] = 15,
                    [9] = 13,
                    [10] = 13,
                    [11] = 13,
                    [12] = 14,
                    [13] = 13,
                    [14] = 13,
                },
                [10] =
                {
                    [1] = 11,
                    [2] = 11,
                    [3] = 11,
                    [4] = 14,
                    [5] = 14,
                    [6] = 14,
                    [7] = 10,
                    [8] = 15,
                    [9] = 13,
                    [10] = 13,
                    [11] = 13,
                    [12] = 14,
                    [13] = 13,
                    [14] = 13,
                },
            },
            [CRAFTING_TYPE_CLOTHIER] =
            {
                [1] =
                {
                    [1] = 7,
                    [2] = 7,
                    [3] = 5,
                    [4] = 5,
                    [5] = 5,
                    [6] = 6,
                    [7] = 5,
                    [8] = 5,
                    [9] = 7,
                    [10] = 5,
                    [11] = 5,
                    [12] = 5,
                    [13] = 6,
                    [14] = 5,
                    [15] = 5,
                },
                [2] =
                {
                    [1] = 8,
                    [2] = 8,
                    [3] = 6,
                    [4] = 6,
                    [5] = 6,
                    [6] = 7,
                    [7] = 6,
                    [8] = 6,
                    [9] = 8,
                    [10] = 6,
                    [11] = 6,
                    [12] = 6,
                    [13] = 7,
                    [14] = 6,
                    [15] = 6,
                },
                [3] =
                {
                    [1] = 9,
                    [2] = 9,
                    [3] = 7,
                    [4] = 7,
                    [5] = 7,
                    [6] = 8,
                    [7] = 7,
                    [8] = 7,
                    [9] = 9,
                    [10] = 7,
                    [11] = 7,
                    [12] = 7,
                    [13] = 8,
                    [14] = 7,
                    [15] = 7,
                },
                [4] =
                {
                    [1] = 10,
                    [2] = 10,
                    [3] = 8,
                    [4] = 8,
                    [5] = 8,
                    [6] = 9,
                    [7] = 8,
                    [8] = 8,
                    [9] = 10,
                    [10] = 8,
                    [11] = 8,
                    [12] = 8,
                    [13] = 9,
                    [14] = 8,
                    [15] = 8,
                },
                [5] =
                {
                    [1] = 11,
                    [2] = 11,
                    [3] = 9,
                    [4] = 9,
                    [5] = 9,
                    [6] = 10,
                    [7] = 9,
                    [8] = 9,
                    [9] = 11,
                    [10] = 9,
                    [11] = 9,
                    [12] = 9,
                    [13] = 10,
                    [14] = 9,
                    [15] = 9,
                },
                [6] =
                {
                    [1] = 12,
                    [2] = 12,
                    [3] = 10,
                    [4] = 10,
                    [5] = 10,
                    [6] = 11,
                    [7] = 10,
                    [8] = 10,
                    [9] = 12,
                    [10] = 10,
                    [11] = 10,
                    [12] = 10,
                    [13] = 11,
                    [14] = 10,
                    [15] = 10,
                },
                [7] =
                {
                    [1] = 13,
                    [2] = 13,
                    [3] = 11,
                    [4] = 11,
                    [5] = 11,
                    [6] = 12,
                    [7] = 11,
                    [8] = 11,
                    [9] = 13,
                    [10] = 11,
                    [11] = 11,
                    [12] = 11,
                    [13] = 12,
                    [14] = 11,
                    [15] = 11,
                },
                [8] =
                {
                    [1] = 14,
                    [2] = 14,
                    [3] = 12,
                    [4] = 12,
                    [5] = 12,
                    [6] = 13,
                    [7] = 12,
                    [8] = 12,
                    [9] = 14,
                    [10] = 12,
                    [11] = 12,
                    [12] = 12,
                    [13] = 13,
                    [14] = 12,
                    [15] = 12,
                },
                [9] =
                {
                    [1] = 15,
                    [2] = 15,
                    [3] = 13,
                    [4] = 13,
                    [5] = 13,
                    [6] = 14,
                    [7] = 13,
                    [8] = 13,
                    [9] = 15,
                    [10] = 13,
                    [11] = 13,
                    [12] = 13,
                    [13] = 14,
                    [14] = 13,
                    [15] = 13,
                },
                [10] =
                {
                    [1] = 15,
                    [2] = 15,
                    [3] = 13,
                    [4] = 13,
                    [5] = 13,
                    [6] = 14,
                    [7] = 13,
                    [8] = 13,
                    [9] = 15,
                    [10] = 13,
                    [11] = 13,
                    [12] = 13,
                    [13] = 14,
                    [14] = 13,
                    [15] = 13,
                },
                [11] =
                {
                    [1] = 7,
                    [2] = 7,
                    [3] = 5,
                    [4] = 5,
                    [5] = 5,
                    [6] = 6,
                    [7] = 5,
                    [8] = 5,
                    [9] = 7,
                    [10] = 5,
                    [11] = 5,
                    [12] = 5,
                    [13] = 6,
                    [14] = 5,
                    [15] = 5,
                },
                [12] =
                {
                    [1] = 8,
                    [2] = 8,
                    [3] = 6,
                    [4] = 6,
                    [5] = 6,
                    [6] = 7,
                    [7] = 6,
                    [8] = 6,
                    [9] = 8,
                    [10] = 6,
                    [11] = 6,
                    [12] = 6,
                    [13] = 7,
                    [14] = 6,
                    [15] = 6,
                },
                [13] =
                {
                    [1] = 9,
                    [2] = 9,
                    [3] = 7,
                    [4] = 7,
                    [5] = 7,
                    [6] = 8,
                    [7] = 7,
                    [8] = 7,
                    [9] = 9,
                    [10] = 7,
                    [11] = 7,
                    [12] = 7,
                    [13] = 8,
                    [14] = 7,
                    [15] = 7,
                },
                [14] =
                {
                    [1] = 10,
                    [2] = 10,
                    [3] = 8,
                    [4] = 8,
                    [5] = 8,
                    [6] = 9,
                    [7] = 8,
                    [8] = 8,
                    [9] = 10,
                    [10] = 8,
                    [11] = 8,
                    [12] = 8,
                    [13] = 9,
                    [14] = 8,
                    [15] = 8,
                },
                [15] =
                {
                    [1] = 11,
                    [2] = 11,
                    [3] = 9,
                    [4] = 9,
                    [5] = 9,
                    [6] = 10,
                    [7] = 9,
                    [8] = 9,
                    [9] = 11,
                    [10] = 9,
                    [11] = 9,
                    [12] = 9,
                    [13] = 10,
                    [14] = 9,
                    [15] = 9,
                },
                [16] =
                {
                    [1] = 12,
                    [2] = 12,
                    [3] = 10,
                    [4] = 10,
                    [5] = 10,
                    [6] = 11,
                    [7] = 10,
                    [8] = 10,
                    [9] = 12,
                    [10] = 10,
                    [11] = 10,
                    [12] = 10,
                    [13] = 11,
                    [14] = 10,
                    [15] = 10,
                },
                [17] =
                {
                    [1] = 13,
                    [2] = 13,
                    [3] = 11,
                    [4] = 11,
                    [5] = 11,
                    [6] = 12,
                    [7] = 11,
                    [8] = 11,
                    [9] = 13,
                    [10] = 11,
                    [11] = 11,
                    [12] = 11,
                    [13] = 12,
                    [14] = 11,
                    [15] = 11,
                },
                [18] =
                {
                    [1] = 14,
                    [2] = 14,
                    [3] = 12,
                    [4] = 12,
                    [5] = 12,
                    [6] = 13,
                    [7] = 12,
                    [8] = 12,
                    [9] = 14,
                    [10] = 12,
                    [11] = 12,
                    [12] = 12,
                    [13] = 13,
                    [14] = 12,
                    [15] = 12,
                },
                [19] =
                {
                    [1] = 15,
                    [2] = 15,
                    [3] = 13,
                    [4] = 13,
                    [5] = 13,
                    [6] = 14,
                    [7] = 13,
                    [8] = 13,
                    [9] = 15,
                    [10] = 13,
                    [11] = 13,
                    [12] = 13,
                    [13] = 14,
                    [14] = 13,
                    [15] = 13,
                },
                [20] =
                {
                    [1] = 15,
                    [2] = 15,
                    [3] = 13,
                    [4] = 13,
                    [5] = 13,
                    [6] = 14,
                    [7] = 13,
                    [8] = 13,
                    [9] = 15,
                    [10] = 13,
                    [11] = 13,
                    [12] = 13,
                    [13] = 14,
                    [14] = 13,
                    [15] = 13,
                },
            },
            [CRAFTING_TYPE_WOODWORKING] =
            {
                [1] =
                {
                    [1] = 3,
                    [2] = 6,
                    [3] = 3,
                    [4] = 3,
                    [5] = 3,
                    [6] = 3,
                },
                [2] =
                {
                    [1] = 4,
                    [2] = 7,
                    [3] = 4,
                    [4] = 4,
                    [5] = 4,
                    [6] = 4,
                },
                [3] =
                {
                    [1] = 5,
                    [2] = 8,
                    [3] = 5,
                    [4] = 5,
                    [5] = 5,
                    [6] = 5,
                },
                [4] =
                {
                    [1] = 6,
                    [2] = 9,
                    [3] = 6,
                    [4] = 6,
                    [5] = 6,
                    [6] = 6,
                },
                [5] =
                {
                    [1] = 7,
                    [2] = 10,
                    [3] = 7,
                    [4] = 7,
                    [5] = 7,
                    [6] = 7,
                },
                [6] =
                {
                    [1] = 8,
                    [2] = 11,
                    [3] = 8,
                    [4] = 8,
                    [5] = 8,
                    [6] = 8,
                },
                [7] =
                {
                    [1] = 9,
                    [2] = 12,
                    [3] = 9,
                    [4] = 9,
                    [5] = 9,
                    [6] = 9,
                },
                [8] =
                {
                    [1] = 10,
                    [2] = 13,
                    [3] = 10,
                    [4] = 10,
                    [5] = 10,
                    [6] = 10,
                },
                [9] =
                {
                    [1] = 11,
                    [2] = 14,
                    [3] = 11,
                    [4] = 11,
                    [5] = 11,
                    [6] = 11,
                },
                [10] =
                {
                    [1] = 12,
                    [2] = 14,
                    [3] = 12,
                    [4] = 12,
                    [5] = 12,
                    [6] = 12,
                },
            },
            [CRAFTING_TYPE_JEWELRYCRAFTING] =
            	{
                [1] = { [1] = 2, [2] = 3 },
                [2] = { [1] = 3, [2] = 5 },
                [3] = { [1] = 4, [2] = 6 },
                [4] = { [1] = 6, [2] = 8 },
                [5] = { [1] = 10, [2] = 15 },
            	}
        }

end

-- change language of current UI /script SetCVar("language.2", "de")
