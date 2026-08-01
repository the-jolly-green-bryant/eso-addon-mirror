local MailerDemon 		= MailerDemon
MailerDemonMenu 		= ZO_Object:Subclass()
MailerDemonMenu.db 		= nil

MailerDemonMenu.overallValues	= {

	Send = false,
	SendRaw = false,
	SendMaterials = false,
	SendBoosters = false,
	To = "",
	Subject = "",
	MinNumber = 1,
	MinQuality = 1,
	MaxQuality = 3,
}

local CBM = CALLBACK_MANAGER
local LAM = LibStub( 'LibAddonMenu-2.0' )

local database = nil

if ( not LAM ) then return end

function MailerDemonMenu:New( ... )
    local result = ZO_Object.New( self )
    result:Initialize( ... )
    return result
end

function MailerDemonMenu:Initialize( db )
    self.db = db
	database = db

	local panelData = {
		type = "panel",
		name = "Mailer Demon",
		author = "manavortex, based on the work of Mandrakia, proofing by Slater2715",
		slashCommand = "/md",
		registerForRefresh = true,
		registerForDefaults  = true,
	}

	LAM:RegisterAddonPanel("MailerDemonOptions", panelData)

	local optionsData = {

	--{	type = "submenu", -- general settings
	--	name = "Overall settings",
	--	tooltip = "",	--(optional)
	--	controls = {


			{	type = "description",
				text = "Welcome to MailerDemon. This Add-on will help you un-stuff your bags."
			},

			{	type = "description",
				text = "Please make sure the recipient isn't misspelled."
			},

			{	type = "description",
				text = "You can configure several buttons that will be displayed in your mailbox if you check the corresponding box, " ..
				"each config will send away a different kind of items (see description below).",
			},

			{	type = "description",
				text = "Below you will occasionally find a 'want to keep' checkbox. This will apply for every item that will be sent upon button click. "
			},

			{	type = "description",
				text ="",
			},

			{	type = "slider",
				name = "Minimum mail items",
				tooltip = "Will not send mail for less items than",
				min = 1,
				max = 6,
				getFunc = function() return self.db.MinNumber end,
				setFunc = function(value) self.db.MinNumber = value end,
			},


			{	type = "description",
				text ="",
			},
			{	type = "checkbox",
				name = "Report to chat?",
				getFunc = function() return not self.db.shutUp end,
				setFunc = function(value) self.db.shutUp =  not value end,
			},

			{	type = "checkbox", -- db.ExcludeItemSaver
				name = "Consider ItemSaver?",
				tooltip = "Will not send items you item saver-ed",
				getFunc = function() return self.db.ExcludeItemSaver end,
				setFunc = function(value) self.db.ExcludeItemSaver = value end,
			},

			{	type = "checkbox", -- db.ExcludeCrafted
				name = "Keep crafted?",
				tooltip = "Will not send items you have crafted yourself - useful when un-stuffing before turning in Craftng s'wit",
				getFunc = function() return self.db.ExcludeCrafted end,
				setFunc = function(value) self.db.ExcludeCrafted = value end,
			},


	{	type = "submenu", -- Bait
		name = "Bait settings",

		controls = {

				{	type = "description",
					text = "Don't throw away your bait - mail it to the fishermer on your friendslist. They will be thankful!"
				},

			{	type = "checkbox", -- Bait.IsActive
				name = "Send bait away?",
				tooltip = "Show button in mailbox?",
				getFunc = function() return self.db.MailSettings.Bait.IsActive end,
				setFunc = function(value)
					self.db.MailSettings.Bait.IsActive = value
					self.db.MailSettings.Bait.Send = value
					self.db.MailSettings.Bait.SendRaw = value
					self.db.MailSettings.Bait.SendMaterials = value
					self.db.MailSettings.Bait.SendBoosters = value
				end,
			},


			{	type = "editbox", -- Bait.To
				name = "Recipient",
				tooltip = "Who is this patient person?",
				getFunc = function() return MailerDemon.GetTo("Bait")end,
				setFunc = function(value)
					MailerDemon.SetTo("Bait", value)					
				end,

			},

			{	type = "editbox", -- Bait.Subject
				name = "Subject",
				tooltip = "Would you like to tell them something?",
				getFunc = function() return self.db.MailSettings.Bait.Subject end,
				setFunc = function(value)
					self.db.MailSettings.Bait.Subject = value
				end,
			},


		}, -- bait controls

	}, -- Bait submenu

	{	type = "submenu", -- Bounce
		name = "bounce",

		controls = {

			{	type = "description",
				text = "This goes with someone who uses the add-on 'Wykkydd's Mailbox'. Mails that have 'bounce' as a subject will get auto-returned to the sender. " ..
				"Warning: The author of this add-on will take no responsibility for assassins that are sent because you spam your guildmates. "
			},



			{	type = "checkbox", -- Bounce.IsActive
				name = "Display mail button?",
				tooltip = "Show button in mailbox?",
				getFunc = function() return self.db.MailSettings.Bounce.IsActive end,
				setFunc = function(value)
					self.db.MailSettings.Bounce.IsActive = value
				end,
			},

			{	type = "editbox", -- Bounce.To
				name = "Recipient",
				tooltip = "Who is your bounce buddy??",
				getFunc = function() return self.db.MailSettings.Bounce.To end,
				setFunc = function(value)
					self.db.MailSettings.Bounce.To = value
					self.db.MailSettings.Bounce.RawTo = value
				end,
			},


			{	type = "slider", -- Bounce.MaxQuality
					name = "Maximum quality",
					tooltip = "How trustworthy is your bounce buddy? (1=white,5=legendary)",
					min = 1,
					max = 5,
					getFunc = function() return self.db.MailSettings.Bounce.MaxQuality end,
					setFunc = function(value) self.db.MailSettings.Bounce.MaxQuality = value end,
			},


			{	type = "header", -- config
					name = "What do you want to bounce?",
			},

			{	type = "checkbox", -- Bounce.SendMaterials
				name = "Bounce gear?",
				getFunc = function() return self.db.MailSettings.Bounce.Send end,
				setFunc = function(value)
					self.db.MailSettings.Bounce.Send = value
				end,
			},

			{	type = "checkbox", --Bounce.SendRaw
				name = "Bounce crafting?",
				getFunc = function() return self.db.MailSettings.Bounce.SendRaw end,
				setFunc = function(value)

					self.db.MailSettings.Bounce.SendRaw = value
					self.db.MailSettings.Bounce.SendMaterial = value
					self.db.MailSettings.Bounce.SendBoosters = value

				end,
			},

			{	type = "checkbox", -- Bounce.SendConsumables
				name = "Bounce consumables?",
				getFunc = function() return self.db.MailSettings.Bounce.SendConsumables end,
				setFunc = function(value)

					self.db.MailSettings.Bounce.SendConsumables = value
					self.db.MailSettings.Bounce.SendAlchemy = value

				end,
			},

			{	type = "header", -- config
					name = "But I want to keep my...",
			},


			{	type = "checkbox", -- Bounce.KeepMaxLevel
				name = "max level stuff?",
				getFunc = function() return self.db.MailSettings.Bounce.KeepMaxLevel end,
				setFunc = function(value)
					self.db.MailSettings.Bounce.KeepMaxLevel = value
				end,
			},

			{	type = "checkbox", -- Bounce.SendBlacksmithing
				name = "metal",
				width = "half",
				getFunc = function() return not self.db.MailSettings.Bounce.SendBlacksmithing end,
				setFunc = function(value)
					self.db.MailSettings.Bounce.SendBlacksmithing = (not value)
				end,
			},
			{	type = "checkbox", -- Bounce.SendBlacksmithing
				name = "cloth",
				width = "half",
				getFunc = function() return not self.db.MailSettings.Bounce.SendClothing end,
				setFunc = function(value)
					self.db.MailSettings.Bounce.SendClothing = (not value)
				end,
			},
			{	type = "checkbox", -- Bounce.SendBlacksmithing
				name = "wood",
				width = "half",
				getFunc = function() return not self.db.MailSettings.Bounce.SendWoodworking end,
				setFunc = function(value)
					self.db.MailSettings.Bounce.SendWoodworking = (not value)
				end,
			},
			{	type = "checkbox", -- Bounce.SendBlacksmithing
				name = "glyphs",
				width = "half",
				getFunc = function() return not self.db.MailSettings.Bounce.SendEnchanting end,
				setFunc = function(value)
					self.db.MailSettings.Bounce.SendEnchanting = (not value)
				end,
			},
			{	type = "checkbox", -- Bounce.SendAlchemy
				name = "alchemy stuff",
				width = "half",
				getFunc = function() return not self.db.MailSettings.Bounce.SendAlchemy end,
				setFunc = function(value)
					self.db.MailSettings.Bounce.SendAlchemy = (not value)
				end,
			},
			{	type = "checkbox", -- Bounce.SendFood
				name = "foodies",
				width = "half",
				getFunc = function() return not self.db.MailSettings.Bounce.SendFood end,
				setFunc = function(value)
					self.db.MailSettings.Bounce.SendFood = (not value)
				end,
			},

			{	type = "checkbox", -- Bounce.SendBait
				name = "baits",
				width = "half",
				getFunc = function() return not self.db.MailSettings.Bounce.SendBait end,
				setFunc = function(value)
					self.db.MailSettings.Bounce.SendBait = (not value)
				end,
			},



			{	type = "checkbox", -- Bounce.SendConsumables
				name = "consumables?",
				width = "half",
				getFunc = function() return not self.db.MailSettings.Bounce.SendConsumables end,
				setFunc = function(value)
					self.db.MailSettings.Bounce.SendConsumables = (not value)
				end,
			},


		}, -- Bounce controls

	}, -- Bounce submenu

	{	type = "submenu", -- Ref
		name = "Refineables settings",

		controls = {

			{	type = "description",
					text = "This will mail everything that can be refined and is not a style item - raw leather, cloth, wood and ore. " ..
					"It is for those of you who help a guildmate getting the 'Refinement Master' achievement, or the like."
				},

			{	type = "checkbox", -- Ref.IsActive
				name = "Activate?",
				tooltip = "Show button in mailbox?",
				getFunc = function() return self.db.MailSettings.Ref.IsActive end,
				setFunc = function(value)
					self.db.MailSettings.Ref.IsActive = value
					self.db.MailSettings.Ref.SendRaw = value
					self.db.MailSettings.Ref.Send = value
				end,
			},

			{	type = "editbox", -- Ref.To
				name = "Recipient",
				tooltip = "Who is this patient person?",
				getFunc = function() return MailerDemon.GetTo("Ref") end,
				setFunc = function(value)
					MailerDemon.SetTo("Ref", value)
				end,

			},

			{	type = "editbox", -- Bait.Subject
				name = "Subject",
				tooltip = "Would you like to tell them something?",
				getFunc = function() return MailerDemon.GetSubject("Ref") end,
				setFunc = function(value)
					MailerDemon.SetSubject("Ref", value)					
				end,
			},

			{	type = "checkbox", -- Ref.KeepMaxLevel
				name = "Keep Rubedite?",
				getFunc = function() return self.db.MailSettings.Ref.KeepMaxLevel end,
				setFunc = function(value)
					self.db.MailSettings.Ref.KeepMaxLevel = value
				end,
			},

			{	type = "checkbox", -- Ref.SendBlacksmithing
				name = "Send Metal?",
				width = "half",
				getFunc = function() return self.db.MailSettings.Ref.SendBlacksmithing end,
				setFunc = function(value)
					self.db.MailSettings.Ref.SendBlacksmithing = value
				end,
			},

			{	type = "checkbox", -- Ref.SendClothing
				name = "Send Cloth?",
				width = "half",
				getFunc = function() return self.db.MailSettings.Ref.SendClothing end,
				setFunc = function(value)
					self.db.MailSettings.Ref.SendClothing = value
				end,
			},
			{	type = "checkbox", -- Ref.SendWoodworking
				name = "Send Wood?",
				width = "half",
				getFunc = function() return self.db.MailSettings.Ref.SendWoodworking end,
				setFunc = function(value)
					self.db.MailSettings.Ref.SendWoodworking = value
				end,
			},


		}, -- Ref controls

	}, -- Ref submenu

	{	type = "submenu", -- Decon1
		name = "Decon1 settings",

		controls = {

			{	type = "description",
				text = "If you want to send away your deconstructables to help someone level their crafting skills, this config is for you." ..
				" There are three of it because there are three professions. Well, actually four, since enchanting might count as well, but I'll go with three for now."
			},

			{	type = "checkbox", -- Decon1.IsActive
				name = "Activate?",
				tooltip = "Show button in mailbox?",
				getFunc = function() return self.db.MailSettings.Decon1.IsActive end,
				setFunc = function(value)
					self.db.MailSettings.Decon1.IsActive = value
					self.db.MailSettings.Decon.IsActive = (
						value
						or self.db.MailSettings.Decon2.IsActive
						or self.db.MailSettings.Decon3.IsActive
						or self.db.MailSettings.Decon4.IsActive
					)
				end,

			},

			{	type = "editbox", -- Decon1.To
				name = "Recipient",
				tooltip = "Who is this patient person?",
				getFunc = function() return MailerDemon.GetTo("Decon1") end,
				setFunc = function(value)
					MailerDemon.SetTo("Decon1", value)
				end,

			},

			{	type = "editbox", -- Decon1.Subject
				name = "Subject",
				tooltip = "Would you like to tell them something?",
				getFunc = function() return MailerDemon.GetSubject("Decon1") end,
				setFunc = function(value)
					MailerDemon.SetSubject("Decon1", value)
				end,
			},

			{	type = "checkbox", -- RefineDables.KeepMaxLevel
				name = "Keep max level stuff?",
				getFunc = function() return self.db.MailSettings.Decon1.KeepMaxLevel end,
				setFunc = function(value)
					self.db.MailSettings.Decon1.KeepMaxLevel = value
				end,
			},

			{	type = "checkbox", -- Decon1.SendBlacksmithing
				name = "Send Metal?",
				width = "half",
				getFunc = function() return self.db.MailSettings.Decon1.SendBlacksmithing end,
				setFunc = function(value)
					self.db.MailSettings.Decon1.SendBlacksmithing = value
				end,
			},

			{	type = "checkbox", -- Decon1.SendClothing
				name = "Send Cloth?",
				width = "half",
				getFunc = function() return self.db.MailSettings.Decon1.SendClothing end,
				setFunc = function(value)
					self.db.MailSettings.Decon1.SendClothing = value
				end,
			},

			{	type = "checkbox", -- Decon1.SendWoodworking
				name = "Send Wood?",
				width = "half",
				getFunc = function() return self.db.MailSettings.Decon1.SendWoodworking end,
				setFunc = function(value)
					self.db.MailSettings.Decon1.SendWoodworking = value
				end,
			},

			{	type = "checkbox", -- Decon1.SendEnchanting
				name = "Send Glyphs?",
				width = "half",
				getFunc = function() return self.db.MailSettings.Decon1.SendEnchanting end,
				setFunc = function(value)
					self.db.MailSettings.Decon1.SendEnchanting = value
				end,
			},

			{	type = "slider", -- Decon1.MaxQuality
				name = "Maxiumum quality of items to send",
				tooltip = "Maximum quality of equipment items to send (1=white,5=legendary)",
				min = 1,
				max = 5,
				getFunc = function() return self.db.MailSettings.Decon1.MaxQuality end,
				setFunc = function(value)
					self.db.MailSettings.Decon1.MaxQuality = value
				end,
			},


		}, -- Decon1 controls

	}, -- Decon1 submenu
	{	type = "submenu", -- Decon2
		name = "Decon2 settings",

		controls = {

			{	type = "description",
				text = "If you want to send away your deconstructables to help someone level their crafting skills, this config is for you." ..
				" There are three of it because there are three professions. Well, actually four, since enchanting might count as well, but I'll go with three for now."
			},

			{	type = "checkbox", -- Decon2.IsActive
				name = "Activate?",
				tooltip = "Show button in mailbox?",
				getFunc = function() return self.db.MailSettings.Decon2.IsActive end,
				setFunc = function(value)
					self.db.MailSettings.Decon2.IsActive = value
					self.db.MailSettings.Decon.IsActive = (
						self.db.MailSettings.Decon1.IsActive
						or value
						or self.db.MailSettings.Decon3.IsActive
						or self.db.MailSettings.Decon4.IsActive
					)
				end,
			},

			{	type = "editbox", -- Decon2.To
				name = "Recipient",
				tooltip = "Who is this patient person?",
				getFunc = function() return MailerDemon.GetTo("Decon2") end,
				setFunc = function(value)
					MailerDemon.SetTo("Decon2", value)
				end,

			},

			{	type = "editbox", -- Decon2.Subject
				name = "Subject",
				tooltip = "Would you like to tell them something?",
				getFunc = function() return MailerDemon.GetSubject("Decon2") end,
				setFunc = function(value)
					MailerDemon.SetSubject("Decon2", value)
				end,
			},


			{	type = "checkbox", -- Decon2.KeepMaxLevel
				name = "Keep max level stuff?",
				getFunc = function() return self.db.MailSettings.Decon2.KeepMaxLevel end,
				setFunc = function(value)
					self.db.MailSettings.Decon2.KeepMaxLevel = value
				end,
			},

			{	type = "checkbox", -- Decon2.SendBlacksmithing
				name = "Send Metal?",
				width = "half",
				getFunc = function() return self.db.MailSettings.Decon2.SendBlacksmithing end,
				setFunc = function(value)
					self.db.MailSettings.Decon2.SendBlacksmithing = value
				end,
			},

			{	type = "checkbox", -- Decon2.SendClothing
				name = "Send Cloth?",
				width = "half",
				getFunc = function() return self.db.MailSettings.Decon2.SendClothing end,
				setFunc = function(value)
					self.db.MailSettings.Decon2.SendClothing = value
				end,
			},

			{	type = "checkbox", -- Decon2.SendWoodworking
				name = "Send Wood?",
				width = "half",
				getFunc = function() return self.db.MailSettings.Decon2.SendWoodworking end,
				setFunc = function(value)
					self.db.MailSettings.Decon2.SendWoodworking = value
				end,
			},

			{	type = "checkbox", -- Decon2.SendEnchanting
				name = "Send Glyphs?",
				width = "half",
				getFunc = function() return self.db.MailSettings.Decon2.SendEnchanting end,
				setFunc = function(value)
					self.db.MailSettings.Decon2.SendEnchanting = value
				end,
			},

			{	type = "slider", -- Decon2.MaxQuality
				name = "Maxiumum quality of items to send",
				tooltip = "Maximum quality of equipment items to send (1=white,5=legendary)",
				min = 1,
				max = 5,
				getFunc = function() return self.db.MailSettings.Decon2.MaxQuality end,
				setFunc = function(value)
					self.db.MailSettings.Decon2.MaxQuality = value
				end,
			},



		}, -- Decon2 controls

	}, -- Decon2 submenu
	{	type = "submenu", -- Decon3
		name = "Decon3 settings",

		controls = {

			{	type = "description",
				text = "If you want to send away your deconstructables to help someone level their crafting skills, this config is for you." ..
				" There are three of it because there are three professions. Well, actually four, since enchanting might count as well, but I'll go with three for now."
			},

			{	type = "checkbox", -- Decon3.IsActive
				name = "Activate?",
				tooltip = "Show button in mailbox?",
				getFunc = function() return self.db.MailSettings.Decon3.IsActive end,
				setFunc = function(value)
					self.db.MailSettings.Decon3.IsActive = value
					self.db.MailSettings.Decon.IsActive = (
					self.db.MailSettings.Decon1.IsActive
					or self.db.MailSettings.Decon2.IsActive
					or value
					or self.db.MailSettings.Decon4.IsActive
				)
				end,
			},

			{	type = "editbox", -- Decon3.To
				name = "Recipient",
				tooltip = "Who is this patient person?",
				getFunc = function() return MailerDemon.GetTo("Decon3") end,
				setFunc = function(value)
					MailerDemon.SetTo("Decon3", value)
				end,

			},

			{	type = "editbox", -- Decon3.Subject
				name = "Subject",
				tooltip = "Would you like to tell them something?",
				getFunc = function() return MailerDemon.GetSubject("Decon3") end,
				setFunc = function(value)
					MailerDemon.SetSubject("Decon3", value)
				end,
			},


			{	type = "checkbox", -- Decon3.KeepMaxLevel
				name = "Keep max level stuff?",
				getFunc = function() return self.db.MailSettings.Decon3.KeepMaxLevel end,
				setFunc = function(value)
					self.db.MailSettings.Decon3.KeepMaxLevel = value
				end,
			},

			{	type = "checkbox", -- Decon3.SendBlacksmithing
				name = "Send Metal?",
				width = "half",
				getFunc = function() return self.db.MailSettings.Decon3.SendBlacksmithing end,
				setFunc = function(value)
					self.db.MailSettings.Decon3.SendBlacksmithing = value
				end,
			},

			{	type = "checkbox", -- Decon3.SendClothing
				name = "Send Cloth?",
				width = "half",
				getFunc = function() return self.db.MailSettings.Decon3.SendClothing end,
				setFunc = function(value)
					self.db.MailSettings.Decon3.SendClothing = value
				end,
			},

			{	type = "checkbox", -- Decon3.SendWoodworking
				name = "Send Wood?",
				width = "half",
				getFunc = function() return self.db.MailSettings.Decon3.SendWoodworking end,
				setFunc = function(value)
					self.db.MailSettings.Decon3.SendWoodworking = value
				end,
			},

			{	type = "checkbox", -- Decon3.SendEnchanting
				name = "Send Glyphs?",
				width = "half",
				getFunc = function() return self.db.MailSettings.Decon3.SendEnchanting end,
				setFunc = function(value)
					self.db.MailSettings.Decon3.SendEnchanting = value
				end,
			},

			{	type = "slider", -- Decon3.MaxQuality
				name = "Maxiumum quality of items to send",
				tooltip = "Maximum quality of equipment items to send (1=white,5=legendary)",
				min = 1,
				max = 5,
				getFunc = function() return self.db.MailSettings.Decon3.MaxQuality end,
				setFunc = function(value)
					self.db.MailSettings.Decon3.MaxQuality = value
				end,
			},


		}, -- Decon3 controls

	}, -- Decon4 submenu
	{	type = "submenu", -- Decon4
	name = "Decon4 settings",

	controls = {

	{	type = "description",
	text = "If you want to send away your deconstructables to help someone level their crafting skills, this config is for you." ..
	" There are three of it because there are three professions. Well, actually four, since enchanting might count as well, but I'll go with three for now."
	},

			{	type = "checkbox", -- Decon4.IsActive
			name = "Activate?",
			tooltip = "Show button in mailbox?",
			getFunc = function() return self.db.MailSettings.Decon4.IsActive end,
			setFunc = function(value)
				self.db.MailSettings.Decon4.IsActive = value
				self.db.MailSettings.Decon.IsActive = (
					self.db.MailSettings.Decon1.IsActive
					or self.db.MailSettings.Decon2.IsActive
					or self.db.MailSettings.Decon3.IsActive
					or value
				)
			end,
			},

			{	type = "editbox", -- Decon4.To
			name = "Recipient",
			tooltip = "Who is this patient person?",
			getFunc = function() return self.db.MailSettings.Decon4.To end,
			setFunc = function(value)
			self.db.MailSettings.Decon4.To = value
			end,

			},

			{	type = "editbox", -- Decon4.Subject
			name = "Subject",
			tooltip = "Would you like to tell them something?",
			getFunc = function() return self.db.MailSettings.Decon4.Subject end,
			setFunc = function(value)
			self.db.MailSettings.Decon4.Subject = value
			end,
			},


			{	type = "checkbox", -- Decon4.KeepMaxLevel
			name = "Keep max level stuff?",
			getFunc = function() return self.db.MailSettings.Decon4.KeepMaxLevel end,
			setFunc = function(value)
			self.db.MailSettings.Decon4.KeepMaxLevel = value
			end,
			},

			{	type = "checkbox", -- Decon4.SendBlacksmithing
			name = "Send Metal?",
			width = "half",
			getFunc = function() return self.db.MailSettings.Decon4.SendBlacksmithing end,
			setFunc = function(value)
			self.db.MailSettings.Decon4.SendBlacksmithing = value
			end,
			},

			{	type = "checkbox", -- Decon4.SendClothing
			name = "Send Cloth?",
			width = "half",
			getFunc = function() return self.db.MailSettings.Decon4.SendClothing end,
			setFunc = function(value)
			self.db.MailSettings.Decon4.SendClothing = value
			end,
			},

			{	type = "checkbox", -- Decon4.SendWoodworking
			name = "Send Wood?",
			width = "half",
			getFunc = function() return self.db.MailSettings.Decon4.SendWoodworking end,
			setFunc = function(value)
			self.db.MailSettings.Decon4.SendWoodworking = value
			end,
			},

			{	type = "checkbox", -- Decon4.SendEnchanting
			name = "Send Glyphs?",
			width = "half",
			getFunc = function() return self.db.MailSettings.Decon4.SendEnchanting end,
			setFunc = function(value)
			self.db.MailSettings.Decon4.SendEnchanting = value
			end,
			},

			{	type = "slider", -- Decon4.MaxQuality
			name = "Maxiumum quality of items to send",
			tooltip = "Maximum quality of equipment items to send (1=white,5=legendary)",
			min = 1,
			max = 5,
			getFunc = function() return self.db.MailSettings.Decon4.MaxQuality end,
			setFunc = function(value)
			self.db.MailSettings.Decon4.MaxQuality = value
			end,
			},


		}, -- Decon4 controls

	}, -- Decon4 submenu

	{	type = "submenu", -- Materials1
		name = "Crafting material 1",

		controls = {

			{	type = "description",
				text = "If you have shared your crafting professions with someone else, you might need this - it will send all crafting materials of a kind away to someone else. " ..
				"You can keep your quality boosters by adjusting the maximum quality slider."
			},

			{	type = "checkbox", -- Materials1.IsActive
				name = "Activate config?",
				tooltip = "Show button in mailbox?",
				getFunc = function() return self.db.MailSettings.Materials1.IsActive end,
				setFunc = function(value)
					self.db.MailSettings.Materials1.IsActive = value
					self.db.MailSettings.Materials.IsActive = (value or self.db.MailSettings.Materials2.IsActive)
				end,
			},

			{	type = "editbox", -- Materials1.To
				name = "Recipient",
				tooltip = "Who is this patient person?",
				getFunc = function() return self.db.MailSettings.Materials1.To end,
				setFunc = function(value)
					self.db.MailSettings.Materials1.To = value
				end,

			},

			{	type = "editbox", -- Materials1.Subject
				name = "Subject",
				tooltip = "Would you like to tell them something?",
				getFunc = function() return self.db.MailSettings.Materials1.Subject end,
				setFunc = function(value)
					self.db.MailSettings.Materials1.Subject = value
				end,
			},


			{	type = "checkbox", -- Materials1.KeepMaxLevel
				name = "Keep max level stuff?",
				getFunc = function() return self.db.MailSettings.Materials1.KeepMaxLevel end,
				setFunc = function(value)
					self.db.MailSettings.Materials1.KeepMaxLevel = value
				end,
			},

			{	type = "checkbox", -- Materials1.SendBlacksmithing
				name = "Send Metal?",
				width = "half",
				getFunc = function() return self.db.MailSettings.Materials1.SendBlacksmithing end,
				setFunc = function(value)
					self.db.MailSettings.Materials1.SendBlacksmithing = value
				end,
			},

			{	type = "checkbox", -- Materials1.SendClothing
				name = "Send Cloth?",
				width = "half",
				getFunc = function() return self.db.MailSettings.Materials1.SendClothing end,
				setFunc = function(value)
					self.db.MailSettings.Materials1.SendClothing = value
				end,
			},

			{	type = "checkbox", -- Materials1.SendWoodworking
				name = "Send Wood?",
				width = "half",
				getFunc = function() return self.db.MailSettings.Materials1.SendWoodworking end,
				setFunc = function(value)
					self.db.MailSettings.Materials1.SendWoodworking = value
				end,
			},

			{	type = "checkbox", -- Materials1.SendEnchanting
				name = "Send runestones?",
				width = "half",
				getFunc = function() return self.db.MailSettings.Materials1.SendEnchanting end,
				setFunc = function(value)
					self.db.MailSettings.Materials1.SendEnchanting = value
				end,
			},

				{	type = "checkbox", -- Materials1.SendFood
				name = "Send Foodies?",
				width = "half",
				getFunc = function() return self.db.MailSettings.Materials1.SendFood end,
				setFunc = function(value)
					self.db.MailSettings.Materials1.SendFood = value
				end,
			},

			{	type = "checkbox", -- Materials1.SendBoosters
				name = "Send recipes?",
				width = "half",
				getFunc = function() return self.db.MailSettings.Materials1.SendBoosters end,
				setFunc = function(value)
					self.db.MailSettings.Materials1.SendBoosters = value
				end,
			},
				{	type = "checkbox", -- Materials1.SendAlchemy
				name = "Send flowers?",
				width = "half",
				getFunc = function() return self.db.MailSettings.Materials1.SendAlchemy end,
				setFunc = function(value)
					self.db.MailSettings.Materials1.SendAlchemy = value
				end,
			},


			{	type = "slider", -- Materials1.MaxQuality
				name = "Maxiumum quality of items to send",
				tooltip = "Maximum quality of equipment items to send (1=white,5=legendary)",
				min = 1,
				max = 5,
				getFunc = function() return self.db.MailSettings.Materials1.MaxQuality end,
				setFunc = function(value)
					self.db.MailSettings.Materials1.MaxQuality = value
				end,
			},



		}, -- Materials1 controls

	}, -- Materials1 submenu

	{	type = "submenu", -- Materials2
		name = "Crafting material 2",

		controls = {

			{	type = "description",
				text = "If you have shared your crafting professions with someone else, you might need this - it will send all crafting materials of a kind away to someone else." ..
				"You can keep your quality boosters by adjusting the maximum quality slider."
			},

			{	type = "checkbox", -- Materials2.IsActive
				name = "Activate config?",
				tooltip = "Show button in mailbox?",
				getFunc = function() return self.db.MailSettings.Materials2.IsActive end,
				setFunc = function(value)
					self.db.MailSettings.Materials2.IsActive = value
					self.db.MailSettings.Materials.IsActive = (self.db.MailSettings.Materials1.IsActive or value)
				end,
			},

			{	type = "editbox", -- Materials2.To
				name = "Recipient",
				tooltip = "Who is this patient person?",
				getFunc = function() return self.db.MailSettings.Materials2.To end,
				setFunc = function(value)
					self.db.MailSettings.Materials2.To = value
				end,

			},

			{	type = "editbox", -- Materials2.Subject
				name = "Subject",
				tooltip = "Would you like to tell them something?",
				getFunc = function() return self.db.MailSettings.Materials2.Subject end,
				setFunc = function(value)
					self.db.MailSettings.Materials2.Subject = value
				end,
			},


			{	type = "checkbox", -- Materials2.KeepMaxLevel
				name = "Keep max level stuff?",
				getFunc = function() return self.db.MailSettings.Materials2.KeepMaxLevel end,
				setFunc = function(value)
					self.db.MailSettings.Materials2.KeepMaxLevel = value
				end,
			},

			{	type = "checkbox", -- Materials2.SendBlacksmithing
				name = "Send Metal?",
				width = "half",
				getFunc = function() return self.db.MailSettings.Materials2.SendBlacksmithing end,
				setFunc = function(value)
					self.db.MailSettings.Materials2.SendBlacksmithing = value
				end,
			},

			{	type = "checkbox", -- Materials2.SendClothing
				name = "Send Cloth?",
				width = "half",
				getFunc = function() return self.db.MailSettings.Materials2.SendClothing end,
				setFunc = function(value)
					self.db.MailSettings.Materials2.SendClothing = value
				end,
			},

			{	type = "checkbox", -- Materials2.SendWoodworking
				name = "Send Wood?",
				width = "half",
				getFunc = function() return self.db.MailSettings.Materials2.SendWoodworking end,
				setFunc = function(value)
					self.db.MailSettings.Materials2.SendWoodworking = value
				end,
			},

			{	type = "checkbox", -- Materials2.SendEnchanting
				name = "Send runestones?",
				width = "half",
				getFunc = function() return self.db.MailSettings.Materials2.SendEnchanting end,
				setFunc = function(value)
					self.db.MailSettings.Materials2.SendEnchanting = value
				end,
			},

				{	type = "checkbox", -- Materials2.SendFood
				name = "Send Foodies?",
				width = "half",
				getFunc = function() return self.db.MailSettings.Materials2.SendFood end,
				setFunc = function(value)
					self.db.MailSettings.Materials2.SendFood = value
				end,
			},

			{	type = "checkbox", -- Materials2.SendBoosters
				name = "Send recipes?",
				width = "half",
				getFunc = function() return self.db.MailSettings.Materials2.SendBoosters end,
				setFunc = function(value)
					self.db.MailSettings.Materials2.SendBoosters = value
				end,
			},

				{	type = "checkbox", -- Materials2.SendAlchemy
				name = "Send flowers?",
				width = "half",
				getFunc = function() return self.db.MailSettings.Materials2.SendAlchemy end,
				setFunc = function(value)
					self.db.MailSettings.Materials2.SendAlchemy = value
				end,
			},


			{	type = "slider", -- Materials2.MaxQuality
				name = "Maxiumum quality of items to send",
				tooltip = "Maximum quality of equipment items to send (1=white,5=legendary)",
				min = 1,
				max = 5,
				getFunc = function() return self.db.MailSettings.Materials2.MaxQuality end,
				setFunc = function(value)
					self.db.MailSettings.Materials2.MaxQuality = value
				end,
			},



		}, -- Materials2 controls

	}, -- Materials2 submenu


	}	 -- optionsData end
	LAM:RegisterOptionControls("MailerDemonOptions", optionsData)

end


function getfield(f)
  local v = _G    -- start with the table of globals
  for w in string.gfind(f, "[%w_]+") do
	v = v[w]
  end
  return v
end
