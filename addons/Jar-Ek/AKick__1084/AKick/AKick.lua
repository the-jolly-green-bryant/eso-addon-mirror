--
-- AKicker
--
-- Permission is hereby granted, free of charge, to any person
-- obtaining a copy of this software and associated documentation
-- files (the "Software"), to deal in the Software without
-- restriction, including without limitation the rights to use,
-- copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the
-- Software is furnished to do so, subject to the following
-- conditions:
--
-- The above copyright notice and this permission notice shall be
-- included in all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
-- EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
-- OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
-- NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
-- HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
-- WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
-- FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
-- OTHER DEALINGS IN THE SOFTWARE.
--
-------------------------------------------------------------------------------
--
-- DISCLAIMER:
--
-- This Add-on is not created by, affiliated with or sponsored by ZeniMax
-- Media Inc. or its affiliates. The Elder Scrolls® and related logos are
-- registered trademarks or trademarks of ZeniMax Media Inc. in the United
-- States and/or other countries. All rights reserved.
--
-- You can read the full terms at:
-- https://account.elderscrollsonline.com/add-on-terms
--
-------------------------------------------------------------------------------
local LAM = LibStub("LibAddonMenu-2.0")

--
-- AKicker
--
AKicker = {}
newVersion = 2

ldebug = true
desiredGuildName = "Temple of Traders"
desiredGuildRankCutoff = 3				-- Note 1 = Grandmaster, 2 = Second-in-command, etc
desiredKickTimeGap = 2116800			-- 25 days
exclusionList = { "@darkeye1f", "@Ozezaichi", "@kiti" }

guildNameList = {}
numGuilds = 0

recruitMsg_start = " are recruiting members of all levels."
recruitMsg_middle = " We are a trade guild with 450+ active members. So if you're looking to make money or friends."
recruitMsg_end = " Please whisper for an invite"

-- Setup Colours?
local colWhite     = "|cFFFFFF" -- white (c1)
local colYellow    = "|cFFFF00" -- yellow (c2)
local colGreen     = "|c00FF00" -- green (c3)
local colTeal      = "|c00FFFF" -- teal (c4)
local colRed       = "|cFF0000" -- Red

---- NEW --------------------------------------------------------------
officerExclusionList = {
	[1] = {							-- All guild members (runs first) for time check
		["Enabled"] 	= true,			-- Is this enabled
		["AlwaysImmune"]= false,		-- Not always immune
		["RankCutoff"] 	= 20,			-- Rank cut off
		["KickTime"] 	= 2116800		-- KickTime for this rank
	},
	[2] = {							-- Officers are immune
		["Enabled"] 	= true,			-- Is this enabled
		["AlwaysImmune"]= true,			-- Always immune
		["RankCutoff"] 	= 3,			-- Rank cut off
		["KickTime"] 	= 2116800		-- KickTime for this rank
	},
	[3] = {							-- Available for additional customisation
		["Enabled"] 	= false,		-- Is this enabled
		["AlwaysImmune"]= false,		-- Not always immune
		["RankCutoff"] 	= 5,			-- Rank cut off
		["KickTime"] 	= 2116800		-- KickTime for this rank
	}
}
officerExclusionListSize = 3
---- NEW --------------------------------------------------------------

function AKicker.Initialize( self, addOnName )
	if addOnName ~= "AKick" then return end

	-- Register keybindings
	ZO_CreateStringId("SI_BINDING_NAME_AK_AUTOKICK", "Perform Auto Kick")

    AKicker.PopulateGuildNameTable()
	if numGuilds > 0 then
		desiredGuildName = guildNameList[1]
	else
		desiredGuildName = "Default"
	end

	AKicker.SavedVariables = ZO_SavedVars:NewAccountWide("AKick_Save", 9, nil, {})

	-- Since we added some fields we have to add them here, or users will have to reconfigure.
	if AKicker.SavedVariables.desiredGuildName ~= nil then
		desiredGuildName = AKicker.SavedVariables.desiredGuildName
    else
        AKicker.SavedVariables.desiredGuildName = desiredGuildName
	end

	if AKicker.SavedVariables.desiredKickTimeGap ~= nil then
		desiredKickTimeGap = AKicker.SavedVariables.desiredKickTimeGap
    else
        AKicker.SavedVariables.desiredKickTimeGap = desiredKickTimeGap
	end

	if AKicker.SavedVariables.desiredGuildRankCutoff ~= nil then
		desiredGuildRankCutoff = AKicker.SavedVariables.desiredGuildRankCutoff
    else
        AKicker.SavedVariables.desiredGuildRankCutoff = desiredGuildRankCutoff
	end

	if AKicker.SavedVariables.exclusionList ~= nil then
        exclusionList = AKicker.SavedVariables.exclusionList
    else
        AKicker.SavedVariables.exclusionList = exclusionList
    end

	if AKicker.SavedVariables.bAnyNoteImmune == nil then
        AKicker.SavedVariables.bAnyNoteImmune = false
    end


---- NEW --------------------------------------------------------------
	if AKicker.SavedVariables.officerExclusionList ~= nil then
        officerExclusionList = AKicker.SavedVariables.officerExclusionList
    else
		officerExclusionList[2].RankCutoff = desiredGuildRankCutoff
		officerExclusionList[1].KickTime = desiredKickTimeGap
        AKicker.SavedVariables.officerExclusionList = officerExclusionList
    end

	if AKicker.SavedVariables.bSilent == nil then
        AKicker.SavedVariables.bSilent = false
    end

	if AKicker.SavedVariables.bVerbose == nil then
        AKicker.SavedVariables.bVerbose = true
    end

    if AKicker.SavedVariables.akVersion == nil then
        AKicker.ClearAll()
    elseif AKicker.SavedVariables.akVersion < newVersion then
        AKicker.ClearAll()
    end
---- NEW --------------------------------------------------------------

	SLASH_COMMANDS["/akick"] = AKicker.commandHandler
	SLASH_COMMANDS["/ak"] = AKicker.commandHandler

	--AKick.AutoKick()
	AKicker.CreateSettingsMenu()

	-- Display successful startup
	d( "AKick Enabled!" )
end

function AKicker.doNothing()
end


--- NEW ---------------------------------------------------------------------------------
-- Determine immunity based on officer rank
function AKicker.CheckForImmunity(memberSecsSinceLogOff, memberRank, memberName)
	if officerExclusionListSize <= 0 then return false end
	for oIndex = 1, officerExclusionListSize, 1 do
		-- Check if rule is enabled
		if officerExclusionList[oIndex].Enabled == true then
			-- Check if the immunity check is valid for the member's rank
			if memberRank <= officerExclusionList[oIndex].RankCutoff then
				--- Check if this rank is always immune to kick
				if officerExclusionList[oIndex].AlwaysImmune == true then
					if AKicker.SavedVariables.bSilent == false then
						d(memberName.." immune due to rank. This rank is always immune!")
					end
					return true
				-- Check if member logged in within kick period
				elseif memberSecsSinceLogOff <= officerExclusionList[oIndex].KickTime then
					if officerExclusionList[oIndex].RankCutoff ~= 20 and AKicker.SavedVariables.bSilent == false then
						d(memberName.." immune due to rank. This rank is immune up to ".. officerExclusionList[oIndex].KickTime/86400 .. "days")
					end
					return true
				end
			end
		end
	end
	-- Not immune due to rules check of rank and time
	return false
end
--- NEW ---------------------------------------------------------------------------------

-- Read a member note
function AKicker.ReadNoteForImmunity(text)
	local input = string.lower(text)
	local index = 1

	-- Separate the note text into fields
	if text ~= nil then
--		if ldebug == true then d(text.." "..input) end
		for value in string.gmatch(input,"%w+") do
            index = index + 1
			if value =="AKickImmune" then
				return true
			end
		end
	end

	if index > 1 and AKicker.SavedVariables.bAnyNoteImmune == true then
		return true
	end

	return false
end

-- Automatically kick everyone over 21 days
--- Must provide the guild name and rank at which this is disabled
function AKicker.AutoKick(testOnly)
    local daysInActive = desiredKickTimeGap/86400
    d("Performing automatic guild removal for "..desiredGuildName.." on all members inactive past "..daysInActive.." days")
--- NEW ---------------------------------------------------------------------------------
	if AKicker.SavedVariables.bSilent == false then
		d("Seeing who to boot...")
	end
--- NEW ---------------------------------------------------------------------------------
    local totalKicked = 0
	--- Get number of guilds
	numGuilds = GetNumGuilds()
	if numGuilds ~= 0 then
		--- Loop through our guilds
		for gIndex = 1, numGuilds, 1 do
			guildId = GetGuildId(gIndex)
			guildName = GetGuildName(guildId)
			--- If we have a name match with requested guild
			if guildName == desiredGuildName then
				--- Check our guild membership status
				ourMemberIndex = GetPlayerGuildMemberIndex(guildId)

				if ourMemberIndex ~= nil then
					---			 str, 		 str, 		 int, 		   int, 				  int
					local ourMemberName, ourMemberNote, ourMemberRank, ourMemberStatus, ourMemberSecsSinceLogOff = GetGuildMemberInfo(guildId, ourMemberIndex)

                    --- If we have permission to kick
                    if DoesGuildRankHavePermission(guildId, ourMemberRank, GUILD_PERMISSION_REMOVE) then
 --                 do
                        --- Need to loop through the current membership
                        numGuildMembers = GetNumGuildMembers(guildId)
                        if numGuildMembers ~= 0 then
                            for memberIndex = 1 , numGuildMembers , 1 do
                                local immuneToKick = false
                                --- Get Member info
                                ---	 str, 		 str, 		 int, 		   int, 				  int
                                local memberName, memberNote, memberRank, memberStatus, memberSecsSinceLogOff = GetGuildMemberInfo(guildId, memberIndex)

--- NEW ---------------------------------------------------------------------------------
								immuneToKick = AKicker.CheckForImmunity(memberSecsSinceLogOff, memberRank, memberName)
--- NEW ---------------------------------------------------------------------------------

--								-- Check if member logged in within kick period
--                                if memberSecsSinceLogOff <= desiredKickTimeGap then
--									immuneToKick = true

--                                --- Check to see if member rank is below the cutoff (and hence safe)
--                                elseif memberRank <= desiredGuildRankCutoff then
--									immuneToKick = true
--									d(memberName.." immune due to rank")

                                --- Check to see if member note specifies immunity to kick
--								elseif AKicker.ReadNoteForImmunity(memberNote) == true then
--- NEW ---------------------------------------------------------------------------------
								if AKicker.ReadNoteForImmunity(memberNote) == true then
									immuneToKick = true
									if AKicker.SavedVariables.bSilent == false then
										d(memberName.." immune due to guild note")
									end
--- NEW ---------------------------------------------------------------------------------

                                --- Check to see if member is in exclusion list
								elseif exclusionList ~= nil then
									for _, v in pairs (exclusionList) do
										if memberName ~= nil and memberName == v then
											immuneToKick = true
--- NEW ---------------------------------------------------------------------------------
											if AKicker.SavedVariables.bSilent == false then
												d(memberName.." immune due to exclusion list")
											end
--- NEW ---------------------------------------------------------------------------------
										end
									end
								end

								-- Kick Test
                                if immuneToKick == false then
                                    --- If status is offline
                                    if memberStatus ~= 1 then
                                        local daysSinceLogOff = memberSecsSinceLogOff/86400
                                        --- Kick from guild
--- NEW ---------------------------------------------------------------------------------
										if AKicker.SavedVariables.bVerbose == true and AKicker.SavedVariables.bSilent == false then
											d("Kick " .. memberName .. " from " .. guildName.." at "..daysSinceLogOff.."days")
										end
--- NEW ---------------------------------------------------------------------------------

--[[								-- Check if member logged in within kick period
                                if memberSecsSinceLogOff <= desiredKickTimeGap then
									immuneToKick = true

                                --- Check to see if member rank is below the cutoff (and hence safe)
                                elseif memberRank <= desiredGuildRankCutoff then
									immuneToKick = true
									d(memberName.." immune due to rank")

                                --- Check to see if member note specifies immunity to kick
								elseif AKicker.ReadNoteForImmunity(memberNote) == true then
									immuneToKick = true
									d(memberName.." immune due to guild note")

                                --- Check to see if member is in exclusion list
								elseif exclusionList ~= nil then
									for _, v in pairs (exclusionList) do
										if memberName ~= nil and memberName == v then
											immuneToKick = true
											d(memberName.." immune due to exclusion list")
										end
									end
								end

								-- Kick Test
                                if immuneToKick == false then
                                    --- If status is offline
                                    if memberStatus ~= 1 then
                                        local daysSinceLogOff = memberSecsSinceLogOff/86400
                                        --- Kick from guild
                                        d("Kick " .. memberName .. " from " .. guildName.." at "..daysSinceLogOff.."days")
--]]
                                        totalKicked = totalKicked +1
                                        if testOnly == false then GuildRemove(guildId, memberName) end
									end
								end
							end
						end
					end
				end
				break
			end
		end
	end
	d("Kicked "..totalKicked)
end


function AKicker.Update()
  if AKicker.active then
    -- THIS MUST HAVE A FUNCTION, EVEN IF IT DOES NOTHING
    AKicker.doNothing()
  end
end

function AKicker.Recruit()
   	if desiredGuildName ~= nil then
		CHAT_SYSTEM:StartTextEntry(desiredGuildName .. recruitMsg_start .. recruitMsg_middle .. recruitMsg_end)
--	    d(desiredGuildName .. recruitMsg_start .. recruitMsg_middle .. recruitMsg_end)
    end
end

-- Just cause a chain by itself is boring.
function AKicker.BallAndChain( object )

	local T = {}
	setmetatable( T , { __index = function( self , func )

		if func == "__BALL" then	return object end

		return function( self , ... )
			assert( object[func] , func .. " missing in object" )
			object[func]( object , ... )
			return self
		end
	end })

	return T
end

function AKicker.PopulateGuildNameTable()
	--- Get number of guilds
	numGuilds = GetNumGuilds()
	if numGuilds ~= 0 then
		--- Grab the names of the guilds and their index
		for gIndex = 1, numGuilds, 1 do
			local guildId = GetGuildId(gIndex)
			local guildName = GetGuildName(guildId)
			guildNameList[gIndex] = guildName
		end
	end
end


--- NEW ---------------------------------------------------------------------------------
function AKicker.ShowBooleanAsText(boolIn)
    local RetVal = "FALSE"
	if boolIn == true then
		RetVal = "TRUE"
	end
	return RetVal
end

-- Determine immunity based on officer rank
function AKicker.ShowOfficerExclusionList()
	d(colWhite.."Version: "..colTeal..tostring(AKicker.SavedVariables.akVersion)..colWhite..".")
	d(colWhite.."NewVersion: "..colTeal..tostring(newVersion)..colWhite..".")
	for oIndex = 1, officerExclusionListSize, 1 do
		if officerExclusionList[oIndex].RankCutoff == 20 then
			d(oIndex..", General KickTime:"..officerExclusionList[oIndex].KickTime)
		elseif officerExclusionList[oIndex].AlwaysImmune == true then
			d(oIndex..": Enabled:"..AKicker.ShowBooleanAsText(officerExclusionList[oIndex].Enabled)..", Rank:"..officerExclusionList[oIndex].RankCutoff.." ALWAYS IMMUNE")
		else
			d(oIndex..": Enabled:"..AKicker.ShowBooleanAsText(officerExclusionList[oIndex].Enabled)..", Rank:"..officerExclusionList[oIndex].RankCutoff..", KickTime:"..officerExclusionList[oIndex].KickTime)
		end
	end
end
--- NEW ---------------------------------------------------------------------------------
-- Settings menu --------------------------------------------------------------
function AKicker.CreateSettingsMenu()
   local panelData = {
      type = "panel",
      name = "Auto Kicker",
      displayName = ZO_HIGHLIGHT_TEXT:Colorize("Auto Kicker Test"),
      author = "Jar-Ek",
      version = 0.1,
      slashCommand = "/akset",
      registerForRefresh = true,
      registerForDefaults = true,
   }
   LAM:RegisterAddonPanel("AKickerPanel", panelData)

   local optionsTable = {
	[1] = {
		type = "header",
		name = "Auto-Kicker Settings",
		width = "full",	--or "half" (optional)
	},
	[2] = {
		type = "description",
		--title = "My Title",	--(optional)
		title = nil,	--(optional)
		text = "Settings for autokicker, an addon which helps kick inactive guildmembers",
		width = "full",	--or "half" (optional)
	},
	[3] = {
		type = "dropdown",
		name = "Guild Select",
		tooltip = "Select the correct guild",
		choices = guildNameList,
		getFunc = function() return desiredGuildName end,
		setFunc = function(var)
			desiredGuildName = var
	        AKicker.SavedVariables.desiredGuildName = desiredGuildName
		end,
		width = "half",	--or "half" (optional)
		warning = "Will need to reload the UI.",	--(optional)
	},
	[4] = {
         type = "slider",
         name = "Inactivity time",
         tooltip = "Sets inactivity time (in days) after which we will kick, max 30 days",
         min = 1,
         max = 30,
         step = 1,
         getFunc = function() return desiredKickTimeGap/86400 end,
         setFunc = function(val)
			desiredKickTimeGap = val*86400
			AKicker.SavedVariables.desiredKickTimeGap = desiredKickTimeGap
--- NEW ---------------------------------------------------------------------------------
				officerExclusionList[1].KickTime = desiredKickTimeGap
				officerExclusionList[2].KickTime = desiredKickTimeGap
				AKicker.SavedVariables.officerExclusionList = officerExclusionList
--- NEW ---------------------------------------------------------------------------------
            end,
		 width = "half",	--or "half" (optional)
         default = AKicker.SavedVariables.desiredKickTimeGap,
    },
 	[5] = {
        type = "slider",
         name = "Guild Rank Cutoff",
         tooltip = "Set the rank at which you may may not participate in the raffle (1 = GuildMaster)",
         min = 1,
         max = 8,
         step = 1,
         getFunc = function() return desiredGuildRankCutoff end,
         setFunc = function(val)
				desiredGuildRankCutoff = val
				AKicker.SavedVariables.desiredGuildRankCutoff = desiredGuildRankCutoff
--- NEW ---------------------------------------------------------------------------------
				officerExclusionList[2].RankCutoff = desiredGuildRankCutoff
				AKicker.SavedVariables.officerExclusionList = officerExclusionList
--- NEW ---------------------------------------------------------------------------------
            end,
		 width = "half",	--or "half" (optional)
         default = AKicker.SavedVariables.desiredGuildRankCutoff,
    },
	[6] = {
		type = "editbox",
		name = "Add exclusion",
		tooltip = "Add an exclusion to the kick time",
		getFunc = function() return "" end,
		setFunc = function(text)
			table.insert (exclusionList, tostring(text))
			table.insert (AKicker.SavedVariables.exclusionList, tostring(text))
		end,
		isMultiline = false,	--boolean
		width = "half",	--or "half" (optional)
		warning = "Will need to reload the UI.",	--(optional)
		default = "",	--(optional)
	},
	[7] = {
		type = "editbox",
		name = "Remove exclusion",
		tooltip = "Remove an exclusion to the kick time",
		getFunc = function() return "" end,
		setFunc = function(text)
			if exclusionList ~= nil and text ~= nil then
				for exclusionIndex, element in pairs (exclusionList) do
					if text == element then
						table.remove (exclusionList, exclusionIndex)
						table.remove (AKicker.SavedVariables.exclusionList, exclusionIndex)
					end
				end
			end
		end,
		isMultiline = false,	--boolean
		width = "half",	--or "half" (optional)
		warning = "Will need to reload the UI.",	--(optional)
		default = "",	--(optional)
	},
	[8] = {
		type = "checkbox",
		name = "Note Immunity",
		tooltip = "Members with anything in the note field is immune, otherwise only immune if AKickImmune is somewhere within the note",
		getFunc = function() return AKicker.SavedVariables.bAnyNoteImmune end,
		setFunc = function(value) AKicker.SavedVariables.bAnyNoteImmune = value end,
		width = "half",	--or "half" (optional)
--		warning = "Will need to reload the UI.",	--(optional)
	},
--- NEW ---------------------------------------------------------------------------------
	[9] = {
		type = "checkbox",
		name = "Enable additional alternative rank settings",
		tooltip = "Enables an additional set of settings for controlling an alternative kick time for a different rank cutoff",
		getFunc = function() return officerExclusionList[3].Enabled end,
		setFunc = function(value) officerExclusionList[3].Enabled = value end,
		width = "half",	--or "half" (optional)
--		warning = "Will need to reload the UI.",	--(optional)
	},
	[10] = {
		type = "submenu",
		name = "Additional rank kick settings",
		tooltip = "Settings for an extra layer of kick control, enabling specific ranks to have a different kick time",	--(optional)
		controls = {
			[1] = {
				type = "slider",
				name = "Rank affected",
				tooltip = "Set the rank at which, and below which (to the general rank cutoff), members are subject to the alternative kick time. This may not be lower than the general rank cutoff",
				min = 1,
				max = 8,
				step = 1,
				getFunc = function() return officerExclusionList[3].RankCutoff end,
				setFunc = function(val)
						if val > desiredGuildRankCutoff then
							officerExclusionList[3].RankCutoff = val
							AKicker.SavedVariables.officerExclusionList = officerExclusionList
						end
					end,
				width = "half",	--or "half" (optional)
				default = AKicker.SavedVariables.desiredGuildRankCutoff,
			},
			[2] = {
				type = "slider",
				name = "Alternative Inactivity time",
				tooltip = "Sets a rank cutoff specific inactivity time (in days) after which we will kick those of this rank and below (max 30 days). This will not over-ride the general rank immunity settings",
				min = 1,
				max = 30,
				step = 1,
				getFunc = function() return officerExclusionList[3].KickTime/86400 end,
				setFunc = function(val)
						officerExclusionList[3].KickTime = val*86400
						AKicker.SavedVariables.officerExclusionList = officerExclusionList
					end,
				width = "half",	--or "half" (optional)
				default = officerExclusionList[3].KickTime,
			},
		}
	},
	[11] = {
--	[9] = {
		type = "button",
		name = "Reset",
		tooltip = "Reset the add-on to default values",
		func = function() AKicker.ClearAll() end,
		width = "half",	--or "half" (optional)
		warning = "This will reset all your settings!",	--(optional)
    },
  }
   LAM:RegisterOptionControls("AKickerPanel", optionsTable)
end

---## Start of function to handle commands
function AKicker.commandHandler(text)
	-- put everything in lowercase
	local input = string.lower(text)
	-- set up some variables
	local com = {}
	local index = 1

	-- separate arguments
	if text~=nil then
--		if ldebug==true then d(text.." "..input) end
		for value in string.gmatch(input,"%w+") do
			com[index] = value
	    	index = index + 1
		end
	end

	-- the check...
	if com[1]=="kick" then
		d("Performing auto-kick")
		AKicker.AutoKick(false)
	elseif com[1]=="test" then
		d("Testing auto-kick. If the results are incorrect please use /ak clear")
        AKicker.AutoKick(true)
	elseif com[1]=="recruit" then
        AKicker.Recruit()
	elseif com[1]=="clear" then
		AKicker.ClearAll()
	elseif com[1]=="show" then
		AKicker.ShowOfficerExclusionList()
	elseif com[1]=="list" then
		d("AKick:"..colWhite.." current settings:")
		d(colWhite.."Version: "..colTeal..tostring(AKicker.SavedVariables.akVersion)..colWhite..".")
		d(colWhite.."GuildName: "..colTeal..tostring(desiredGuildName)..colWhite..".")
		d(colWhite.."KickTime: "..colTeal..tostring(desiredKickTimeGap)..colWhite..".")
		d(colWhite.."RankCuttOff: "..colTeal..tostring(desiredGuildRankCutoff)..colWhite..".")
		if exclusionList ~= nil then
			d(colWhite.."ExclusionList: ")
			for exclusionIndex, element in pairs (exclusionList) do
				d(colTeal..element..colWhite)
			end
		end
		if officerExclusionList[3].Enabled == true then
			d(colWhite.."Alternative rank kick time enabled.")
			d(colWhite.."Ranks : "..colTeal..tostring(officerExclusionList[3].RankCutoff)..colWhite.." to "..colTeal..tostring(officerExclusionList[2].RankCutoff + 1)..colWhite.." affected.")
			d(colWhite.."KickTime: "..colTeal..tostring(officerExclusionList[3].KickTime)..colWhite..".")
		end
		d("Immunity to kick may also be added by adding AKickImmune to the guild member's note")
	elseif com[1]=="set" then

		if com[2]=="guildname" then
			if com[3] ~= nil then
				local buildGuildName = com[3]
				for nameTextIndex = 1, index, 1 do
					if com[nameTextIndex+3] ~= nil then
						buildGuildName = buildGuildName.." "..tostring(com[nameTextIndex+3])
					end
				end
				desiredGuildName = buildGuildName
		        AKicker.SavedVariables.desiredGuildName = desiredGuildName
				d(colWhite.."GuildName set to"..colTeal..tostring(desiredGuildName)..colWhite..".")
			end
		elseif com[2]=="kicktime" then
			if com[3] ~= nil then
				desiredKickTimeGap = tonumber(com[3]) * 86400
				AKicker.SavedVariables.desiredKickTimeGap = desiredKickTimeGap
				d(colWhite.."KickTime set to"..colTeal..tostring(desiredKickTimeGap)..colWhite.." seconds.")
			end
		elseif com[2]=="rankcutoff" then
			if com[3] ~= nil then
				if tonumber(com[3])>=0 and tonumber(com[3])<=8 then
					desiredGuildRankCutoff = tonumber(com[3])
					AKicker.SavedVariables.desiredGuildRankCutoff = desiredGuildRankCutoff
					d(colWhite.."Guild Rank for cutoff set to"..colTeal..tostring(desiredGuildRankCutoff)..colWhite..".")
				end
			end
		elseif com[2]=="addexclusion" then
			if com[3] ~= nil then
                local exclName = "@"..tostring(com[3])
				table.insert (exclusionList, exclName)
				table.insert (AKicker.SavedVariables.exclusionList, exclName)
				d(colWhite.."Added "..colTeal..tostring(com[3])..colWhite.." to exclusion list.")
			end
		elseif com[2]=="delexclusion" then
			if com[3] ~= nil and exclusionList ~= nil then
                local delName = "@"..tostring(com[3])
				for exclusionIndex, element in pairs (exclusionList) do
					if delName == element then
						table.remove (exclusionList, exclusionIndex)
						table.remove (AKicker.SavedVariables.exclusionList, exclusionIndex)
						d(colWhite.."Removed "..colTeal..tostring(com[3])..colWhite.." from exclusion list.")
						break
					end
				end
			end
		end
	else
		d("AKick"..colWhite.." commands:")
		d(colTeal.."/akick or /ak")
		d(colTeal.."kick"..colWhite.." - Perform an autokick.")
		d(colTeal.."clear"..colWhite.." - Resets autokicker default values (including guildname funnies).")
		d(colTeal.."set"..colWhite.." - To set guildname name, kicktime days, or rankcutoff integer")
		d(colTeal.."list"..colWhite.." - List the current settings")
		d("Immunity to kick may be added by adding AKickImmune to the guild member's note")
	end
end
----### end of function


function AKicker.ClearAll()
    d("Resetting AKick add-on to default settings")
	-- Reset all data to defaults
	AKicker.SavedVariables.akVersion = newVersion
	desiredGuildName = ""
	guildNameList = {}
	numGuilds = 0
	AKicker.PopulateGuildNameTable()
	desiredGuildName = guildNameList[1]
	AKicker.SavedVariables.desiredGuildName = desiredGuildName

	desiredGuildRankCutoff = 3
	AKicker.SavedVariables.desiredGuildRankCutoff = desiredGuildRankCutoff

	desiredKickTimeGap = 21 * 86400
    AKicker.SavedVariables.desiredKickTimeGap = desiredKickTimeGap

	exclusionList = {}
    AKicker.SavedVariables.exclusionList = exclusionList

--	recruitMsg = ""

	officerExclusionList = {}
	officerExclusionList = {
		[1] = {							-- All guild members (runs first) for time check
			["Enabled"] 	= true,						-- Is this enabled
			["AlwaysImmune"]= false,					-- Not always immune
			["RankCutoff"] 	= 20,						-- Rank cut off
			["KickTime"] 	= desiredKickTimeGap		-- KickTime for this rank
		},
		[2] = {							-- Officers are immune
			["Enabled"] 	= true,						-- Is this enabled
			["AlwaysImmune"]= true,						-- Always immune
			["RankCutoff"] 	= desiredGuildRankCutoff,	-- Rank cut off
			["KickTime"] 	= desiredKickTimeGap		-- KickTime for this rank
		},
		[3] = {							-- Available for additional customisation
			["Enabled"] 	= false,					-- Is this enabled
			["AlwaysImmune"]= false,					-- Not always immune
			["RankCutoff"] 	= 5,						-- Rank cut off
			["KickTime"] 	= desiredKickTimeGap		-- KickTime for this rank
		}
	}
    AKicker.SavedVariables.officerExclusionList = officerExclusionList
	AKicker.SavedVariables.bSilent = false
	AKicker.SavedVariables.bVerbose = true
end

-- Init Hook --
EVENT_MANAGER:RegisterForEvent("AKick", EVENT_ADD_ON_LOADED, AKicker.Initialize )
