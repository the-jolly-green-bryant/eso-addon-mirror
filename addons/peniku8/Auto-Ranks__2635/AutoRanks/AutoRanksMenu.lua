if AutoRanks == nil then AutoRanks = {} end
	local AR = AutoRanks
	local L = AR.Localization


	function AR.MakeMenu()

		local presetNames = AR.getPresetNames()
		local newPresetName = ""
		local loadPreset = tostring(AR.settings.ActivePreset)

		local panelData = {
			type = "panel",
			name = "Auto Ranks",
			displayName = "Auto Ranks",
			author = "|c6C00FF@peniku8|r",
			version = AR.version,
			slashCommand = "/autoranks",
			registerForRefresh = true,
			registerForDefaults = true,
			website = "https://www.esoui.com/downloads/info2635-AutoRanks.html",
		}



		function AR.MakePresetMenu() -- PresetManager submenu

			local options = {}

			table.insert(options,
			{
				type = "button",
				name = L["AR_STR_NEW_PRESET"],
				tooltip = L["AR_STR_NEW_PRESET_TT"],
				func = function()
					if string.len(newPresetName)>0
					then AR.savePreset(newPresetName)
						newPresetName = ""
					else d(L["AR_STR_NEW_PRESET_ERROR"])
					end
				end,
				width = "half",
				warning = L["AR_STR_RELOADUI_WARNING"],
			}
			)

			table.insert(options,
			{
				type = "editbox",
				name = L["AR_STR_PRESET_NAME"],
				tooltip = L["AR_STR_PRESET_NAME_TT"],
				getFunc = function() return newPresetName end,
				setFunc = function(value) newPresetName = value end,
				isMultiline = false,
				width = "half",
				default = "",
			}
			)

			table.insert(options,
			{
				type = "button",
				name = L["AR_STR_DELETE_PRESET"],
				func = function() AR.deletePreset(AR.settings.ActivePreset) end,
				width = "half",
				warning = L["AR_STR_RELOADUI_WARNING"],
			}
			)

			return options

		end


		function AR.MakeRankMenu(guild) -- Rank submenu

			local options = {}

			for i=#AR.ranks[guild], 1, -1 do

				local rank = AR.getIDfromRank(guild, AR.ranks[guild][i])

				table.insert(options,
				{
					type = "header",
					name = "|t::" .. GetGuildRankLargeIcon(GetGuildRankIconIndex(GetGuildId(guild), rank)) .. "|t" .. AR.ranks[guild][i],
					width = "full",
				}
				)

				table.insert(options,
				{
					type = "checkbox",
					name = L["AR_STR_ENABLED"],
					tooltip =  L["AR_STR_ENABLED_TT"],
					getFunc = function() return AR.settings.rank[guild][rank] end,
					setFunc = function(value) AR.settings.rank[guild][rank] = value end,
					width = "full",
					default = false,
				}
				)

				if rank == GetNumGuildRanks(GetGuildId(guild)) then
					table.insert(options,
					{
						type = "checkbox",
						name =  L["AR_STR_NEW_MEMBER"],
						tooltip =  L["AR_STR_NEW_MEMBER_TT"],
						getFunc = function() return AR.settings.recruits[guild] end,
						setFunc = function(value) AR.settings.recruits[guild] = value end,
						width = "full",
						default = false,
					}
					)

					table.insert(options,
					{
						type = "slider",
						name =  L["AR_STR_RANK_PERIOD"],
						tooltip =  L["AR_STR_RANK_PERIOD_TT"],
						min = 1,
						max = 30,
						step = 1,
						getFunc = function() return AR.settings.newMemberPeriod[guild] end,
						setFunc = function(value) AR.settings.newMemberPeriod[guild] = value end,
						width = "full",
						default = 7,
					}
					)
				end

				if i==1 then
					table.insert(options,
					{
						type = "checkbox",
						name =  L["AR_STR_PERMANENT_RANK"],
						tooltip =  L["AR_STR_PERMANENT_RANK_TT"],
						getFunc = function() return AR.settings.noDemote[guild][rank] end,
						setFunc = function(value) AR.settings.noDemote[guild][rank] = value end,
						width = "full",
						default = false,
					}
					)
				end

				table.insert(options,
				{
					type = "editbox",
					name =  L["AR_STR_SALES_REQUIREMENT"],
					tooltip =  L["AR_STR_SALES_REQUIREMENT_TT"],
					getFunc = function() return AR.settings.sales[guild][rank] end,
					setFunc = function(value) AR.settings.sales[guild][rank] = value end,
					isMultiline = false,
					width = "full",
					default = "",
				}
				)

				table.insert(options,
				{
					type = "editbox",
					name =  L["AR_STR_DONATION_REQUIREMENT"],
					tooltip =  L["AR_STR_DONATION_REQUIREMENT_TT"],
					getFunc = function() return AR.settings.donations[guild][rank] end,
					setFunc = function(value) AR.settings.donations[guild][rank] = value end,
					isMultiline = false,
					width = "full",
					default = "",
				}
				)

				table.insert(options,
				{
					type = "checkbox",
					name =  L["AR_STR_MEET_BOTH"],
					tooltip =  L["AR_STR_MEET_BOTH_TT"],
					getFunc = function() return AR.settings.meetBoth[guild][rank] end,
					setFunc = function(value) AR.settings.meetBoth[guild][rank] = value end,
					isMultiline = false,
					width = "full",
					default = "",
				}
				)
				
				table.insert(options, {type = "custom"})

			end

			return options

		end


		function AR.MakeMessageMenu(guild) -- Message submenu

			local options = {}
			local guildID = GetGuildId(guild)
			local ranks = GetNumGuildRanks(guildID)
			local rank1 = GetFinalGuildRankName(guildID, ranks)
			local rank2 = GetFinalGuildRankName(guildID, ranks-1)

			table.insert(options,
			{
				type = "description",
				text = L["AR_STR_DESC_1"],
			}
			)

			table.insert(options,
			{
				type = "description",
				text = L["AR_STR_DESC_2"],
			}
			)

			table.insert(options,
			{
				type = "checkbox",
				name = rank1 .. L["AR_STR_MAIL"],
				tooltip = L["AR_STR_MAIL_TT_1"] .. rank1  .. L["AR_STR_MAIL_TT_2"] .. rank2 .. L["AR_STR_MAIL_TT_3"],
				getFunc = function() return AR.settings.recruitMail[guild] end,
				setFunc = function(value) AR.settings.recruitMail[guild] = value end,
				default = false,
			}
			)

			table.insert(options,
			{
				type = "editbox",
				name = L["AR_STR_SUBJECT"],
				tooltip = AR.settings.recruitMail1[guild],
				getFunc = function() return AR.settings.recruitMail1[guild] end,
				setFunc = function(value) AR.settings.recruitMail1[guild] = value end,
				isMultiline = false,
				default = "",
			}
			)

			table.insert(options,
			{
				type = "editbox",
				name = L["AR_STR_MESSAGE_TEXT"],
				tooltip = AR.settings.recruitMail2[guild],
				getFunc = function() return AR.settings.recruitMail2[guild] end,
				setFunc = function(value) AR.settings.recruitMail2[guild] = value end,
				isMultiline = true,
				default = "",
			}
			)

			table.insert(options,
			{
				type = "checkbox",
				name = rank2 .. L["AR_STR_MAIL"],
				tooltip = L["AR_STR_SEND_DEMOTE_MAIL_TT"] .. rank2 .. L["AR_STR_SEND_DEMOTE_MAIL_TT_2"],
				getFunc = function() return AR.settings.feesMail[guild] end,
				setFunc = function(value) AR.settings.feesMail[guild] = value end,
				default = false,
			}
			)

			table.insert(options,
			{
				type = "editbox",
				name = L["AR_STR_SUBJECT"],
				tooltip = AR.settings.feesMail1[guild],
				getFunc = function() return AR.settings.feesMail1[guild] end,
				setFunc = function(value) AR.settings.feesMail1[guild] = value end,
				isMultiline = false,
				default = "",
			}
			)

			table.insert(options,
			{
				type = "editbox",
				name = L["AR_STR_MESSAGE_TEXT"],
				tooltip = AR.settings.feesMail2[guild],
				getFunc = function() return AR.settings.feesMail2[guild] end,
				setFunc = function(value) AR.settings.feesMail2[guild] = value end,
				isMultiline = true,
				default = "",
			}
			)

			return options

		end


		function AR.MakeAdvancedMenu(guild) -- Advanced submenu
			local options = {}

			table.insert(options,
			{
				type = "checkbox",
				name = L["AR_STR_NOTE_IMMUNITY"],
				tooltip = L["AR_STR_NOTE_IMMUNITY_TT"],
				getFunc = function() return AR.settings.note[guild] end,
				setFunc = function(value) AR.settings.note[guild] = value end,
				width = "full",
				default = false,
			}
			)

			table.insert(options,
			{
				type = "editbox",
				name = L["AR_STR_NOTE_KEY"],
				getFunc = function() return AR.settings.noteKey[guild] end,
				setFunc = function(value) AR.settings.noteKey[guild] = value end,
				isMultiline = false,
				width = "full",
				default = "",
			}
			)

			table.insert(options,
			{
				type = "slider",
				name = L["AR_STR_DEMOTE_CAP"],
				tooltip = L["AR_STR_DEMOTE_CAP_TT"],
				min = 1,
				max = 8,
				step = 1,
				getFunc = function() return AR.settings.demoteCap[guild] end,
				setFunc = function(value) AR.settings.demoteCap[guild] = value end,
				width = "full",
				default = 8,
			}
			)

			table.insert(options,
			{
				type = "checkbox",
				name = L["AR_STR_RESTORE_RANK"],
				tooltip = L["AR_STR_RESTORE_RANK_TT"],
				getFunc = function() return AR.settings.restoreRank[guild] end,
				setFunc = function(value) AR.settings.restoreRank[guild] = value end,
				width = "full",
				default = false,
			}
			)

			return options

		end



		local optionsTable = { -- Main menu

			{
				type = "button",
				name = L["AR_STR_PROCESS"],
				tooltip = L["AR_STR_PROCESS_TT"],
				func = function() AR.launch() end,
				width = "half",
			},

			{
				type = "checkbox",
				name = L["AR_STR_CHAT_NOTIF"],
				getFunc = function() return AR.settings.chatMessages end,
				setFunc = function(value) AR.settings.chatMessages = value end,
				width = "half",
				default = AR.defaults.chatMessages,
			},

			{
				type = "button",
				name = L["AR_STR_LOAD_PRESET"],
				tooltip = L["AR_STR_LOAD_PRESET_TT"],
				func = function()
					if string.len(loadPreset)>0
					then AR.loadPreset(loadPreset)
					else d(L["AR_STR_LOAD_PRESET_HINT"])
					end
				end,
				width = "half",
			},

			{
				type = "dropdown",
				choices = presetNames,
				getFunc = function()
					if string.len(loadPreset)>0
					then return loadPreset
					else return AR.settings.ActivePreset
					end
				end,
				setFunc = function(value) loadPreset = value end,
				width = "half",
			},

			{
				type = "submenu",
				name = L["AR_STR_PRESET_MANAGER"],
				controls = AR.MakePresetMenu(),
			},

			{type = "custom"},

		}



		for guild=1, GetNumGuilds() do -- Guild submenu

			local guildID = GetGuildId(guild)

			if DoesGuildRankHavePermission(guildID, zo_strformat("<<3>>", GetGuildMemberInfo(guildID, GetGuildMemberIndexFromDisplayName(guildID, GetDisplayName()))), GUILD_PERMISSION_PROMOTE) and #AR.ranks[guild]>0 then

				local rankMenu = AR.MakeRankMenu(guild)
				local messageMenu = AR.MakeMessageMenu(guild)
				local advancedMenu = AR.MakeAdvancedMenu(guild)

				table.insert(optionsTable,
				{
					type = "header",
					name = "|c3a92ff" .. AR.guilds[guild],
					width = "full",
				}
				)

				local timeTooltip
				if MasterMerchant then timeTooltip = L["AR_STR_MM_INFO"] end

				table.insert(optionsTable,
				{
					type = "dropdown",
					name = L["AR_STR_SALES_TIME"],
					tooltip = timeTooltip,
					choices = {L["AR_STR_THIS_WEEK"], L["AR_STR_LAST_WEEK"], L["AR_STR_CUSTOM"]},
					getFunc = function() return AR.settings.salesTimeFrame[guild] end,
					setFunc = function(value) AR.settings.salesTimeFrame[guild] = value end,
					width = "full",
					default = L["AR_STR_THIS_WEEK"],
				}
				)

				if ArkadiusTradeTools then
					
					local salesTooltip
					if MasterMerchant then salesTooltip = L["AR_STR_CUSTOM_SALES_TT"] end
					
					table.insert(optionsTable,
					{
						type = "slider",
						name = L["AR_STR_CUSTOM_SALES"],
					  tooltip = salesTooltip,
						min = 1,
						max = 30,
						step = 1,
						getFunc = function() return AR.settings.salesWindow[guild] end,
						setFunc = function(value) AR.settings.salesWindow[guild] = value end,
						width = "full",
						default = 7,
					}
					)
				end

				table.insert(optionsTable,
				{
					type = "dropdown",
					name = L["AR_STR_CUSTOM_DONATIONS"],
					choices = {L["AR_STR_THIS_WEEK"], L["AR_STR_LAST_WEEK"], L["AR_STR_TWO_WEEKS"], L["AR_STR_ALL"]},
					getFunc = function() return AR.settings.donationsTimeFrame[guild] end,
					setFunc = function(value) AR.settings.donationsTimeFrame[guild] = value end,
					width = "full",
					default = L["AR_STR_THIS_WEEK"],
				}
				)

				table.insert(optionsTable,
				{
					type = "checkbox",
					name = L["AR_STR_TRACK_LAST"],
					tooltip = L["AR_STR_TRACK_LAST_TT"],
					getFunc = function() return AR.settings.trackLastDonation[guild] end,
					setFunc = function(value) AR.settings.trackLastDonation[guild] = value end,
					width = "full",
					default = false,
				}
				)

				table.insert(optionsTable,
				{
					type = "slider",
					name = L["AR_STR_TRACK_LAST_TIME"],
					tooltip = L["AR_STR_TRACK_LAST_TIME_TT"],
					min = 1,
					max = 365,
					step = 1,
					getFunc = function() return AR.settings.donationsWindow[guild] end,
					setFunc = function(value) AR.settings.donationsWindow[guild] = value end,
					width = "full",
					default = 30,
				}
				)

				table.insert(optionsTable,
				{
					type = "submenu",
					name = L["AR_STR_RANK_SETTINGS"],
					controls = rankMenu,
				}
				)

				table.insert(optionsTable,
				{
					type = "submenu",
					name = L["AR_STR_MESSAGE_SETTINGS"],
					controls = messageMenu,
				}
				)

				table.insert(optionsTable,
				{
					type = "submenu",
					name = L["AR_STR_ADVANCED_SETTINGS"],
					controls = advancedMenu,
				}
				)

				table.insert(optionsTable,
				{
					type = "checkbox",
					name = L["AR_STR_PROCESS_RANKS"],
					tooltip = L["AR_STR_GUILD_ACTIVATE"] .. AR.guilds[guild],
					getFunc = function() return AR.settings.process[guild] end,
					setFunc = function(value) AR.settings.process[guild] = value end,
					width = "half",
					default = false,
				}
				)

				table.insert(optionsTable,
				{
					type = "checkbox",
					name = L["AR_STR_PROMOTIONS_ONLY"],
					getFunc = function() return AR.settings.restrict[guild] end,
					setFunc = function(value) AR.settings.restrict[guild] = value end,
					width = "half",
					default = false,
				}
				)

				table.insert(optionsTable, {type = "custom"})
			end
		end


		for i=1, #optionsTable do
			if optionsTable[i].type == "header" then
				break
			elseif i==#optionsTable then
				table.insert(optionsTable,
				{
					type = "header",
					name = L["AR_STR_NOGUILDS"],
					width = "full",
				}
				)
			end
		end
		
		
		LibAddonMenu2:RegisterAddonPanel("Auto_Ranks", panelData)
		LibAddonMenu2:RegisterOptionControls("Auto_Ranks", optionsTable)

	end