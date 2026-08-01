if AutoKick == nil then AutoKick = {} end
	local AK = AutoKick


	function AK.MakeMenu()


		local panelData = {
			type = "panel",
			name = "Auto Kick",
			displayName = "Auto Kick",
			author = "|c6C00FF@peniku8|r",
			version = AK.version,
			slashCommand = "/autokick",
			registerForRefresh = true,
			registerForDefaults = true,
			website = "https://www.esoui.com/downloads/info3613-AutoKick.html",
		}



		function AK.MakeRankMenu(guild) -- Rank submenu

			local options = {}

			for i=#AK.ranks[guild], 1, -1 do

				local rank = AK.getIDfromRank(guild, AK.ranks[guild][i])

				table.insert(options,
				{
					type = "header",
					name = "|t::" .. GetGuildRankLargeIcon(GetGuildRankIconIndex(GetGuildId(guild), rank)) .. "|t" .. AK.ranks[guild][i],
					width = "full",
				}
				)

				table.insert(options,
				{
					type = "checkbox",
					name = "Enabled",
					tooltip = "Kick players from this rank",
					getFunc = function() return AK.settings.rank[guild][rank] end,
					setFunc = function(value) AK.settings.rank[guild][rank] = value end,
					width = "full",
					default = false,
				}
				)

				table.insert(options,
				{
					type = "editbox",
					name = "Sales requirement",
					tooltip = "Set the sales threshold at or above which not to kick",
					getFunc = function() return AK.settings.sales[guild][rank] end,
					setFunc = function(value) AK.settings.sales[guild][rank] = value end,
					isMultiline = false,
					width = "full",
					default = "",
				}
				)

				table.insert(options,
				{
					type = "editbox",
					name = "Donation requirement",
					tooltip = "Set the donation threshold at or above which not to kick",
					getFunc = function() return AK.settings.donations[guild][rank] end,
					setFunc = function(value) AK.settings.donations[guild][rank] = value end,
					isMultiline = false,
					width = "full",
					default = "",
				}
				)

				table.insert(options,
				{
					type = "slider",
					name = "Offline period",
					tooltip = "Set the offline period below which not to kick (amount in days)\n0 ignores offline times",
					min = 0,
					max = 365,
					step = 1,
					getFunc = function() return AK.settings.offlinePeriod[guild][rank] end,
					setFunc = function(value) AK.settings.offlinePeriod[guild][rank] = value end,
					width = "full",
					default = 10,
				}
				)

				table.insert(options, {type = "custom"})

			end

			return options

		end


		function AK.MakeMessageMenu(guild) -- Message submenu

			local options = {}

			table.insert(options,
			{
				type = "description",
				text = "You can add dynamic values to the message:\n#SALES - inserts the sales stats based on the time frame specified above\n#DONATIONS - inserts the donation stats based on the time frame above\n#AFK - inserts the offline time in days (number only)",
			}
			)

			table.insert(options,
			{
				type = "description",
				text = "Note: The message previews require you to reload the UI to update.",
			}
			)

			table.insert(options,
			{
				type = "checkbox",
				name = "Send Mail",
				tooltip = "Send a mail to the players after removal",
				getFunc = function() return AK.settings.mail[guild] end,
				setFunc = function(value) AK.settings.mail[guild] = value end,
				default = false,
			}
			)

			table.insert(options,
			{
				type = "editbox",
				name = "Subject",
				tooltip = AK.settings.mail1[guild],
				getFunc = function() return AK.settings.mail1[guild] end,
				setFunc = function(value) AK.settings.mail1[guild] = value end,
				isMultiline = false,
				default = "",
			}
			)

			table.insert(options,
			{
				type = "editbox",
				name = "Message text",
				tooltip = AK.settings.mail2[guild],
				getFunc = function() return AK.settings.mail2[guild] end,
				setFunc = function(value) AK.settings.mail2[guild] = value end,
				isMultiline = true,
				default = "",
			}
			)

			table.insert(options, {type = "custom"})

			table.insert(options,
			{
				type = "checkbox",
				name = "Alternative Mail",
				tooltip = "Select a rank to send this mail to instead, when kicking players from that rank",
				getFunc = function() return AK.settings.altMail[guild] end,
				setFunc = function(value) AK.settings.altMail[guild] = value end,
				default = false,
			}
			)

			table.insert(options,
			{
				type = "dropdown",
				name = "Alternative Rank",
				choices = AK.ranks[guild],
				getFunc = function() return AK.settings.altMailRank[guild] end,
				setFunc = function(value) AK.settings.altMailRank[guild] = value end,
				width = "full",
				default = "",
			}
			)

			table.insert(options,
			{
				type = "editbox",
				name = "Subject",
				tooltip = AK.settings.altMail1[guild],
				getFunc = function() return AK.settings.altMail1[guild] end,
				setFunc = function(value) AK.settings.altMail1[guild] = value end,
				isMultiline = false,
				default = "",
			}
			)

			table.insert(options,
			{
				type = "editbox",
				name = "Message text",
				tooltip = AK.settings.altMail2[guild],
				getFunc = function() return AK.settings.altMail2[guild] end,
				setFunc = function(value) AK.settings.altMail2[guild] = value end,
				isMultiline = true,
				default = "",
			}
			)


			return options

		end


		function AK.MakeAdvancedMenu(guild) -- Advanced submenu

			local options = {}

			table.insert(options,
			{
				type = "checkbox",
				name = "Note immunity",
				tooltip = "Ignore members, if a keyword is found in their note.\nIf no keyword is specified below, all players with a note will be ignored.",
				getFunc = function() return AK.settings.note[guild] end,
				setFunc = function(value) AK.settings.note[guild] = value end,
				width = "full",
				default = false,
			}
			)

			table.insert(options,
			{
				type = "editbox",
				name = "Note keyword",
				getFunc = function() return AK.settings.noteKey[guild] end,
				setFunc = function(value) AK.settings.noteKey[guild] = value end,
				isMultiline = false,
				width = "full",
				default = "",
			}
			)

			table.insert(options,
			{
				type = "checkbox",
				name = "Remember player rank",
				tooltip = "Select a rank, from which to save all kicked players to a list.\nUse this in combination with 'Auto Ranks' to restore ranks when players rejoin the guild (e.g. 'lifetime' members).\nUse /aksaved to post the list into the chat and /akclear to delete the list.",
				getFunc = function() return AK.settings.rememberPlayer[guild] end,
				setFunc = function(value) AK.settings.rememberPlayer[guild] = value end,
				width = "half",
				default = false,
			}
			)

			table.insert(options,
			{
				type = "dropdown",
				name = "",
				choices = AK.ranks[guild],
				getFunc = function() return AK.settings.rememberPlayerRank[guild] end,
				setFunc = function(value) AK.settings.rememberPlayerRank[guild] = value end,
				width = "half",
				default = "",
			}
			)

			return options

		end



		local optionsTable = { -- Main menu

			{
				type = "button",
				name = "Make List",
				tooltip = "Make a list of members to remove.\nThis action interrupts the kicking process if it's running.",
				func = function() AK.makeList(0) end,
				width = "half",
			},

			{
				type = "button",
				name = "Process List",
				tooltip = "Start the kicking process.\nInterrupt it with the 'Make List' button.",
				func = function() AK.doTasks(AK.tasks) end,
				width = "half",
			},

			{
				type = "button",
				name = "Make Specific List",
				tooltip = "Make a list of a specified total amount of members to remove",
				func = function() AK.kickAmount() end,
				width = "half",
			},

			{
				type = "slider",
				name = "",
				tooltip = "Set the amount for the 'Make Specific List' action",
				min = 1,
				max = 50,
				step = 1,
				getFunc = function() return AK.settings.removeAmount end,
				setFunc = function(value) AK.settings.removeAmount = value end,
				width = "half",
				default = 10,
			},

			{
				type = "checkbox",
				name = "Don't kick above requirements",
				tooltip = "Only step requirements down and not up with 'Make Specific List'",
				getFunc = function() return AK.settings.lessOnly end,
				setFunc = function(value) AK.settings.lessOnly = value end,
				width = "full",
				default = AK.defaults.lessOnly,
			},

			{
				type = "checkbox",
				name = "Display Chat Notifications",
				getFunc = function() return AK.settings.chatMessages end,
				setFunc = function(value) AK.settings.chatMessages = value end,
				width = "full",
				default = AK.defaults.chatMessages,
			},

			{type = "custom"},

		}



		for guild=1, GetNumGuilds() do -- Guild submenu
			
			local guildID = GetGuildId(guild)

			if DoesGuildRankHavePermission(guildID, zo_strformat("<<3>>", GetGuildMemberInfo(guildID, GetGuildMemberIndexFromDisplayName(guildID, GetDisplayName()))), GUILD_PERMISSION_REMOVE) and #AK.ranks[guild]>0 then

				local messageMenu = AK.MakeMessageMenu(guild)
				local rankMenu = AK.MakeRankMenu(guild)
				local advancedMenu = AK.MakeAdvancedMenu(guild)
				
				table.insert(optionsTable,
				{
					type = "header",
					name = "|c3a92ff" .. AK.guilds[guild],
					width = "full",
				}
				)
				
				local timeTooltip
				if MasterMerchant then timeTooltip = "You can configure the custom sales time frame in MM settings" end
				
				table.insert(optionsTable,
				{
					type = "dropdown",
					name = "Sales time frame",
					tooltip = timeTooltip,
					choices = {"This week", "Last week", "Custom"},
					getFunc = function() return AK.settings.salesTimeFrame[guild] end,
					setFunc = function(value) AK.settings.salesTimeFrame[guild] = value end,
					width = "full",
					default = "Last week",
				}
				)

				if ArkadiusTradeTools then
					
					local salesTooltip
					if MasterMerchant then salesTooltip = "Only for ATT. Set MM's custom time frame in MM's settings." end
					
					table.insert(optionsTable,
					{
						type = "slider",
						name = "Custom sales time frame",
					  tooltip = salesTooltip,
						min = 1,
						max = 30,
						step = 1,
						getFunc = function() return AK.settings.salesWindow[guild] end,
						setFunc = function(value) AK.settings.salesWindow[guild] = value end,
						width = "full",
						default = 7,
					}
					)
				end

				table.insert(optionsTable,
				{
					type = "dropdown",
					name = "Donations time frame",
					choices = {"This week", "Last week", "This+Last week", "All"},
					getFunc = function() return AK.settings.donationsTimeFrame[guild] end,
					setFunc = function(value) AK.settings.donationsTimeFrame[guild] = value end,
					width = "full",
					default = "Last week",
				}
				)

				table.insert(optionsTable,
				{
					type = "checkbox",
					name = "Track last donation",
					tooltip = "Calculates a 'current week donation' from the last donation to allow members to pay multiple weeks of fees in advance",
					getFunc = function() return AK.settings.trackLastDonation[guild] end,
					setFunc = function(value) AK.settings.trackLastDonation[guild] = value end,
					width = "full",
					default = false,
				}
				)

				table.insert(optionsTable,
				{
					type = "slider",
					name = "Last donation time frame",
					tooltip = "Time frame for the 'Track last donation' option.",
					min = 1,
					max = 365,
					step = 1,
					getFunc = function() return AK.settings.donationsWindow[guild] end,
					setFunc = function(value) AK.settings.donationsWindow[guild] = value end,
					width = "full",
					default = 7,
				}
				)

				table.insert(optionsTable,
				{
					type = "submenu",
					name = "Rank Settings",
					controls = rankMenu,
				}
				)

				table.insert(optionsTable,
				{
					type = "submenu",
					name = "Message Settings",
					controls = messageMenu,
				}
				)

				table.insert(optionsTable,
				{
					type = "submenu",
					name = "Advanced Settings",
					controls = advancedMenu,
				}
				)

				table.insert(optionsTable,
				{
					type = "checkbox",
					name = "Process guild",
					tooltip = "Activate Auto Kick for " .. AK.guilds[guild],
					getFunc = function() return AK.settings.process[guild] end,
					setFunc = function(value) AK.settings.process[guild] = value end,
					width = "half",
					default = false,
				}
				)

				table.insert(optionsTable,
				{
					type = "slider",
					name = "New member immunity",
					tooltip = "Ignore new members until they've been in the guild for x days. Regardless of this setting, the addon automatically calculates a theoretical sales value for a longer membership\nExample: actual membership=3 days, actual sales=3k\nsales req=10k/10days -> theoretical sales=(10/3)*3k=10k; member not kicked",
					min = 0,
					max = 30,
					step = 1,
					getFunc = function() return AK.settings.restrict[guild] end,
					setFunc = function(value) AK.settings.restrict[guild] = value end,
					width = "half",
					default = 7,
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
					name = "|cff4848No suitable guilds found. Check your permissions.",
					width = "full",
				}
				)
			end
		end


		local menu = LibAddonMenu2
		menu:RegisterAddonPanel("Auto_Kick", panelData)
		menu:RegisterOptionControls("Auto_Kick", optionsTable)

	end