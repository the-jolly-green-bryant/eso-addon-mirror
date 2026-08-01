local NTakCamera = NTCam
local ADDON_NAME = "NTakCamera"
local texts = NTCam_Texts
local icons = NTakCamera.icons


------------------------------------------
--		INITIALIZATIONS

local presetNone			= texts.menuX.choices[1]
local presetCenter3rd		= texts.menuX.choices[2]
local presetSwitch1st		= texts.menuX.choices[3]
local presetSwitch3rd		= texts.menuX.choices[4]
local presetDistant			= texts.menuX.choices[5]
local presetFocus			= texts.menuX.choices[6]
local presetCustom			= texts.menuX.choices[7]


------------------------------------------
--		SETTINGS

local LAM2 = LibAddonMenu2
function NTCam.InitSettings()
	--	Usefull
	local function Titler(text)
		return ZO_HIGHLIGHT_TEXT:Colorize(zo_strformat("<<Z:1>>", text))
	end
	local SUBDIVIDER = {
		type = "divider",
		alpha = 0.33,
		width = "half",
	}
	local SPACER = {
		type = "description",
		title = nil,
		text = " ",
	}
	
	local panelData = {
		type = "panel",
		name = "N'Tak' Camera",
		displayName = "N'|c887788Tak'|r Camera", 
		author = "N'|c887788Tak'|r",
		version = "2.5.6",
		slashCommand = "/ntcam",
		website = "https://www.esoui.com/portal.php?id=285&a=list",
		registerForRefresh = true,
		registerForDefaults = true,
	}

	local options =
	{
		{ -- ACCOUNT WIDE
			type = "checkbox",
			name = Titler(texts.cat0.title),
			default = false,
			getFunc = function()
				return NTakCamera_SavedVariables.Default[GetDisplayName()][GetCurrentCharacterId()]["Settings"]["accountWide"]
			end,
			setFunc = function(value)
				NTakCamera_SavedVariables.Default[GetDisplayName()][GetCurrentCharacterId()]["Settings"]["accountWide"] = value
				zo_callLater(function() ReloadUI() end, 200)
			end,
			requiresReload = true,
			width = "full",
		},
		SPACER,
		{ -- PREFERRED CAMERA
			type = "header",
			name = Titler(texts.cat1.title),
			width = "full",
		},
			{ -- Description
				type = "description",
				title = nil,
				text = texts.cat1.desc1,
				width = "full",		
			},
			{ -- Zoom
				type = "slider",
				name = texts.cat1.opt1,
				min = 0,
				step = 1,
				max = 20,
				getFunc = function() return NTakCamera.settings.defaultDistance * 2 end,
				setFunc = function(value)
					NTakCamera.settings.defaultDistance = value / 2
					InitCameraValues()
				end,
				width = "full",
				default = 4,
			},
			{ -- Field of View
				type = "slider",
				name = texts.cat1.opt1b,
				min = 70,
				step = 1,
				max = 130,
				getFunc = function() return NTakCamera.settings.defaultFieldOfView * 2 end,
				setFunc = function(value)
					NTakCamera.settings.defaultFieldOfView = value / 2
					InitCameraValues()
				end,
				width = "full",
				default = 100,
			},
			{ -- Shoulder side
				type = "dropdown",
				name = texts.cat1.opt2,
				choices = texts.cat1.choices,
				getFunc = function() return NTakCamera.settings.defaultHorizontalSide end,
				setFunc = function(value)
					NTakCamera.settings.defaultHorizontalSide = value
					InitCameraValues()
				end,
				width = "full",
				default = texts.cat1.choices[3],
			},
			{ -- Horizontal position
				type = "slider",
				name = texts.cat1.opt3,
				min = 0,
				step = 1,
				max = 100,
				getFunc = function() return NTakCamera.settings.defaultHorizontalOffset end,
				setFunc = function(value)
					NTakCamera.settings.defaultHorizontalOffset = value
					-- if value == 0 then NTakCamera.settings.defaultHorizontalSide = texts.cat1.choices[1] end
					InitCameraValues()
				end,
				width = "full",
				default = 66,
			},
			{ -- Horizontal additional offset
				type = "slider",
				name = texts.cat1.opt3b,
				min = -100,
				step = 1,
				max = 100,
				getFunc = function() return NTakCamera.settings.defaultHorizontalPosition end,
				setFunc = function(value)
					NTakCamera.settings.defaultHorizontalPosition = value
					InitCameraValues()
				end,
				width = "full",
				default = 0,
				warning = texts.cat1.warn3b,
			},
			{ -- Vertical offset
				type = "slider",
				name = texts.cat1.opt4,
				min = -60,
				step = 1,
				max = 100,
				getFunc = function() return NTakCamera.settings.defaultVerticalOffsetMin * 2 end,
				setFunc = function(value)
					NTakCamera.settings.defaultVerticalOffsetMin = value / 2
					InitCameraValues()
				end,
				width = "full",
				default = 0,
			},
			{ -- Vertical offset when centered
				type = "slider",
				name = texts.cat1.opt5,
				min = -60,
				step = 1,
				max = 100,
				getFunc = function() return NTakCamera.settings.defaultVerticalOffsetMax * 2 end,
				setFunc = function(value)
					NTakCamera.settings.defaultVerticalOffsetMax = value / 2
					InitCameraValues()
				end,
				width = "full",
				default = 0,
				warning = texts.cat1.warn5,
			},
			SUBDIVIDER,
			{ -- Description
				type = "description",
				title = nil,
				text = texts.cat1.desc11,
				width = "full"
			},
			{ -- Default after events
				type = "checkbox",
				name = texts.cat1.opt11,
				getFunc = function() return NTakCamera.settings.defaultAfterEvents end,
				setFunc = function(value) NTakCamera.settings.defaultAfterEvents = value end,
				width = "full",
				default = false,
			},
		SPACER,
		{ -- ALTERNATE CAMERAS
			type = "header",
			name = Titler(texts.cat2.title0),
			width = "full",
		},		
			{ -- Description
				type = "description",
				title = nil,
				text = texts.cat2.desc0,
				width = "full"
			},
			{ -- ALTERNATE VALUES
				type = "submenu",
				name = " " .. texts.cat2.title1,
				controls =
				{
					{ -- Description
						type = "description",
						title = nil,
						text = texts.cat2.desc1,
						width = "full",		
					},			
					{ -- Zoom
						type = "slider",
						name = texts.cat1.opt1,
						min = 0,
						step = 1,
						max = 20,
						getFunc = function() return NTakCamera.settings.altDistance * 2 end,
						setFunc = function(value)
							NTakCamera.settings.altDistance = value / 2
							InitCameraValues()
						end,
						width = "full",
						default = 20,
					},
					{ -- Field of View
						type = "slider",
						name = texts.cat1.opt1b,
						min = 70,
						step = 1,
						max = 130,
						getFunc = function() return NTakCamera.settings.altFieldOfView * 2 end,
						setFunc = function(value)
							NTakCamera.settings.altFieldOfView = value / 2
							InitCameraValues()
						end,
						width = "full",
						default = 130,
					-- },
					-- { -- Horizontal position
						-- type = "slider",
						-- name = texts.cat1.opt3,
						-- min = 0,
						-- step = 1,
						-- max = 100,
						-- getFunc = function() return NTakCamera.settings.altHorizontalOffset end,
						-- setFunc = function(value)
							-- NTakCamera.settings.altHorizontalOffset = value
							-- InitCameraValues()
						-- end,
						-- width = "full",
						-- default = 100,
					-- },
					-- { -- Horizontal additional offset
						-- type = "slider",
						-- name = texts.cat1.opt3b,
						-- min = -100,
						-- step = 1,
						-- max = 100,
						-- getFunc = function() return NTakCamera.settings.altHorizontalPosition end,
						-- setFunc = function(value)
							-- NTakCamera.settings.altHorizontalPosition = value
							-- InitCameraValues()
						-- end,
						-- width = "full",
						-- default = 100,
						-- warning = texts.cat1.warn3b,
					},
				}
			},
			{ -- STATIC CAMERAS
				type = "submenu",
				name = " " .. texts.cat2.title2,
				controls =
				{		
					{ -- Description
						type = "description",
						title = nil,
						text = texts.cat2.desc2,
						width = "full"
					},
					{ -- Display change in chat
						type = "checkbox",
						name = texts.cat2.opt0,
						getFunc = function() return NTakCamera.settings.staticOutputInChat end,
						setFunc = function(value) NTakCamera.settings.staticOutputInChat = value end,
						width = "full",
						default = true,
					},
					{ -- STATIC CAMERA 1
						type = "submenu",
						name = texts.cat2.menuX .. "1",
						controls =
						{
							{ -- Distance
								type = "slider",
								name = texts.cat2.opt1,
								min = 0,
								step = 1,
								max = 20,
								getFunc = function() return NTakCamera.settings.staticCamera1.distance * 2 end,
								setFunc = function(value) NTakCamera.settings.staticCamera1.distance = value / 2 end,
								width = "full",
								default = 5,
							},
							{ -- Field of view
								type = "slider",
								name = texts.cat2.opt2,
								min = 70,
								step = 1,
								max = 130,
								getFunc = function() return NTakCamera.settings.staticCamera1.fieldOfView * 2 end,
								setFunc = function(value) NTakCamera.settings.staticCamera1.fieldOfView = value / 2 end,
								width = "full",
								default = 100,
							},
							{ -- Horizontal position
								type = "slider",
								name = texts.cat2.opt3,
								min = -200,
								step = 1,
								max = 200,
								getFunc = function() return NTakCamera.settings.staticCamera1.horizontalPosition end,
								setFunc = function(value) NTakCamera.settings.staticCamera1.horizontalPosition = value end,
								width = "full",
								default = 66,
							},
							{ -- Vertical position
								type = "slider",
								name = texts.cat2.opt4,
								min = -60,
								step = 1,
								max = 100,
								getFunc = function() return NTakCamera.settings.staticCamera1.verticalPosition * 2 end,
								setFunc = function(value) NTakCamera.settings.staticCamera1.verticalPosition = value / 2 end,
								width = "full",
								default = 0,
							},
						}
					},
					{ -- STATIC CAMERA 2
						type = "submenu",
						name = texts.cat2.menuX .. "2",
						controls =
						{
							{ -- Distance
								type = "slider",
								name = texts.cat2.opt1,
								min = 0,
								step = 1,
								max = 20,
								getFunc = function() return NTakCamera.settings.staticCamera2.distance * 2 end,
								setFunc = function(value) NTakCamera.settings.staticCamera2.distance = value / 2 end,
								width = "full",
								default = 5,
							},
							{ -- Field of view
								type = "slider",
								name = texts.cat2.opt2,
								min = 70,
								step = 1,
								max = 130,
								getFunc = function() return NTakCamera.settings.staticCamera2.fieldOfView * 2 end,
								setFunc = function(value) NTakCamera.settings.staticCamera2.fieldOfView = value / 2 end,
								width = "full",
								default = 100,
							},
							{ -- Horizontal position
								type = "slider",
								name = texts.cat2.opt3,
								min = -200,
								step = 1,
								max = 200,
								getFunc = function() return NTakCamera.settings.staticCamera2.horizontalPosition end,
								setFunc = function(value) NTakCamera.settings.staticCamera2.horizontalPosition = value end,
								width = "full",
								default = 66,
							},
							{ -- Vertical position
								type = "slider",
								name = texts.cat2.opt4,
								min = -60,
								step = 1,
								max = 100,
								getFunc = function() return NTakCamera.settings.staticCamera2.verticalPosition * 2 end,
								setFunc = function(value) NTakCamera.settings.staticCamera2.verticalPosition = value / 2 end,
								width = "full",
								default = 0,
							},
						}
					},		
					{ -- STATIC CAMERA 3
						type = "submenu",
						name = texts.cat2.menuX .. "3",
						controls =
						{
							{ -- Distance
								type = "slider",
								name = texts.cat2.opt1,
								min = 0,
								step = 1,
								max = 20,
								getFunc = function() return NTakCamera.settings.staticCamera3.distance * 2 end,
								setFunc = function(value) NTakCamera.settings.staticCamera3.distance = value / 2 end,
								width = "full",
								default = 5,
							},
							{ -- Field of view
								type = "slider",
								name = texts.cat2.opt2,
								min = 70,
								step = 1,
								max = 130,
								getFunc = function() return NTakCamera.settings.staticCamera3.fieldOfView * 2 end,
								setFunc = function(value) NTakCamera.settings.staticCamera3.fieldOfView = value / 2 end,
								width = "full",
								default = 100,
							},
							{ -- Horizontal position
								type = "slider",
								name = texts.cat2.opt3,
								min = -200,
								step = 1,
								max = 200,
								getFunc = function() return NTakCamera.settings.staticCamera3.horizontalPosition end,
								setFunc = function(value) NTakCamera.settings.staticCamera3.horizontalPosition = value end,
								width = "full",
								default = 66,
							},
							{ -- Vertical position
								type = "slider",
								name = texts.cat2.opt4,
								min = -60,
								step = 1,
								max = 100,
								getFunc = function() return NTakCamera.settings.staticCamera3.verticalPosition * 2 end,
								setFunc = function(value) NTakCamera.settings.staticCamera3.verticalPosition = value / 2 end,
								width = "full",
								default = 0,
							},
						},
					},
				}
			},
		SPACER,
		{ -- INTERACTIONS CAMERA CHANGES
			type = "header",
			name = Titler(texts.cat3.title),
			width = "full",
		},
			{ -- Description
				type = "description",
				title = nil,
				text = texts.cat3.desc1,
				width = "full",
			},
			{ -- ON CHAT
				type = "submenu",
				name = icons["Chat"] .. " " .. texts.cat3.menu1.title,
				disabledLabel = function() return not(NTakCamera.settings.chatPreventCam) end,
				controls =
				{
					{ -- Prevent default interaction cam
						type = "checkbox",
						name = texts.menuX.opt0,
						getFunc = function() return NTakCamera.settings.chatPreventCam end,
						setFunc = function(value)
							NTakCamera.settings.chatPreventCam = value
							InitBlockingInteractions()
						end,
						width = "full",
						default = false,
					},
					{ -- Preset list
						type = "dropdown",
						name = texts.menuX.opt1,
						choices = texts.menuX.choices,
						getFunc = function() return NTakCamera.settings.chatAction end,
						setFunc = function(value)
							if not(value == presetCustom) then
								NTakCamera.settings.chatDoDistance			= false
								NTakCamera.settings.chatDoFieldOfView		= false
								NTakCamera.settings.chatDoHorizontalPos 	= false
								NTakCamera.settings.chatDoVerticalOffset	= false
							end
							if value == presetCenter3rd then
								NTakCamera.settings.chatDoDistance 			= true
								NTakCamera.settings.chatDistance 			= NTakCamera.settings.defaultDistance
								NTakCamera.settings.chatDoHorizontalPos 	= true
								NTakCamera.settings.chatHorizontalPos 		= 0
							end
							if value == presetSwitch1st then
								NTakCamera.settings.chatDoDistance 			= true
								NTakCamera.settings.chatDistance 			= 0
							end
							if value == presetSwitch3rd then
								NTakCamera.settings.chatDoDistance 			= true
								NTakCamera.settings.chatDistance 			= 5
							end
							if value == presetDistant then
								NTakCamera.settings.chatDoDistance 			= true
								NTakCamera.settings.chatDistance 			= 8
							end
							if value == presetFocus then
								NTakCamera.settings.chatDoDistance 			= true
								NTakCamera.settings.chatDistance 			= 3
								NTakCamera.settings.chatDoFieldOfView		= true
								NTakCamera.settings.chatFieldOfView			= 40
							end
							NTakCamera.settings.chatAction = value
						end,
						width = "full",
						disabled = function() return not(NTakCamera.settings.chatPreventCam) end,
						default = presetNone,
					},
					{ -- Do Distance
						type = "checkbox",
						name = texts.menuX.opt2,
						getFunc = function() return NTakCamera.settings.chatDoDistance end,
						setFunc = function(value) NTakCamera.settings.chatDoDistance = value end,
						width = "half",
						disabled = function() return
							NTakCamera.settings.chatAction == presetNone
							or not(NTakCamera.settings.chatPreventCam)
						end,
						default = false,
					},
					{ -- Distance
						type = "slider",
						name = texts.menuX.to,
						min = 0,
						step = 1,
						max = 20,
						getFunc = function() return NTakCamera.settings.chatDistance * 2 end,
						setFunc = function(value)
							NTakCamera.settings.chatDistance = value / 2
							NTakCamera.settings.chatAction = presetCustom
						end,
						width = "half",
						disabled = function() return
							NTakCamera.settings.chatAction == presetNone
							or not(NTakCamera.settings.chatPreventCam)
							or not(NTakCamera.settings.chatDoDistance)
						end,
						default = 5,
					},
					{ -- Do Field of view
						type = "checkbox",
						name = texts.menuX.opt2b,
						getFunc = function() return NTakCamera.settings.chatDoFieldOfView end,
						setFunc = function(value) NTakCamera.settings.chatDoFieldOfView = value end,
						width = "half",
						disabled = function() return
							NTakCamera.settings.chatAction == presetNone
							or not(NTakCamera.settings.chatPreventCam)
						end,
						default = false,
					},
					{ -- Field of view
						type = "slider",
						name = texts.menuX.to,
						min = 70,
						step = 1,
						max = 130,
						getFunc = function() return NTakCamera.settings.chatFieldOfView * 2 end,
						setFunc = function(value)
							NTakCamera.settings.chatFieldOfView = value / 2
							NTakCamera.settings.chatAction = presetCustom
						end,
						width = "half",
						disabled = function() return
							NTakCamera.settings.chatAction == presetNone
							or not(NTakCamera.settings.chatPreventCam)
							or not(NTakCamera.settings.chatDoFieldOfView)
						end,
						default = 100,
					},
					{ -- Do Horizontal position
						type = "checkbox",
						name = texts.menuX.opt3,
						getFunc = function() return NTakCamera.settings.chatDoHorizontalPos end,
						setFunc = function(value) NTakCamera.settings.chatDoHorizontalPos = value end,
						width = "half",
						disabled = function() return
							NTakCamera.settings.chatAction == presetNone
							or not(NTakCamera.settings.chatPreventCam)
						end,
						default = false,
					},
					{ -- Horizontal position
						type = "slider",
						name = texts.menuX.to,
						min = 0,
						step = 1,
						max = 100,
						getFunc = function() return NTakCamera.settings.chatHorizontalPos end,
						setFunc = function(value)
							NTakCamera.settings.chatHorizontalPos = value
							NTakCamera.settings.chatAction = presetCustom
						end,
						width = "half",
						disabled = function() return
							NTakCamera.settings.chatAction == presetNone
							or not(NTakCamera.settings.chatPreventCam)
							or not(NTakCamera.settings.chatDoHorizontalPos)
						end,
						default = 66,
					},
					{ -- Do Vertical position
						type = "checkbox",
						name = texts.menuX.opt4,
						getFunc = function() return NTakCamera.settings.chatDoVerticalOffset end,
						setFunc = function(value) NTakCamera.settings.chatDoVerticalOffset = value end,
						width = "half",
						disabled = function() return
							NTakCamera.settings.chatAction == presetNone
							or not(NTakCamera.settings.chatPreventCam)
						end,
						default = false,
					},
					{ -- Vertical position
						type = "slider",
						name = texts.menuX.to,
						min = -60,
						step = 1,
						max = 100,
						getFunc = function() return NTakCamera.settings.chatVerticalOffset * 2 end,
						setFunc = function(value)
							NTakCamera.settings.chatVerticalOffset = value / 2
							NTakCamera.settings.chatAction = presetCustom
						end,
						width = "half",
						disabled = function() return
							NTakCamera.settings.chatAction == presetNone
							or not(NTakCamera.settings.chatPreventCam)
							or not(NTakCamera.settings.chatDoVerticalOffset)
						end,
						default = 0,
					},
				}
			},
			{ -- ON CRAFT STATION
				type = "submenu",
				name = icons["Craft"] .. " " .. texts.cat3.menu2.title,
				disabledLabel = function() return not(NTakCamera.settings.craftPreventCam) end,
				controls =
				{
					{ -- Prevent default interaction cam
						type = "checkbox",
						name = texts.menuX.opt0,
						getFunc = function() return NTakCamera.settings.craftPreventCam end,
						setFunc = function(value)
							NTakCamera.settings.craftPreventCam = value
							InitBlockingInteractions()
						end,
						width = "full",
						default = false,
					},
					{ -- Preset list
						type = "dropdown",
						name = texts.menuX.opt1,
						choices = texts.menuX.choices,
						getFunc = function() return NTakCamera.settings.craftAction end,
						setFunc = function(value)
							if not(value == presetCustom) then
								NTakCamera.settings.craftDoDistance			= false
								NTakCamera.settings.craftDoFieldOfView		= false
								NTakCamera.settings.craftDoHorizontalPos 	= false
								NTakCamera.settings.craftDoVerticalOffset	= false
							end
							if value == presetCenter3rd then
								NTakCamera.settings.craftDoDistance			= true
								NTakCamera.settings.craftDistance 			= NTakCamera.settings.defaultDistance
								NTakCamera.settings.craftDoHorizontalPos	= true
								NTakCamera.settings.craftHorizontalPos 		= 0
							end
							if value == presetSwitch1st then
								NTakCamera.settings.craftDoDistance			= true
								NTakCamera.settings.craftDistance 			= 0
							end
							if value == presetSwitch3rd then
								NTakCamera.settings.craftDoDistance			= true
								NTakCamera.settings.craftDistance 			= 5
							end
							if value == presetDistant then
								NTakCamera.settings.craftDoDistance 		= true
								NTakCamera.settings.craftDistance 			= 8
							end
							if value == presetFocus then
								NTakCamera.settings.craftDoDistance 		= true
								NTakCamera.settings.craftDistance 			= 3
								NTakCamera.settings.craftDoFieldOfView		= true
								NTakCamera.settings.craftFieldOfView		= 40
							end
							NTakCamera.settings.craftAction = value
						end,
						width = "full",
						disabled = function() return not(NTakCamera.settings.craftPreventCam) end,
						default = presetNone,
					},
					{ -- Do Distance
						type = "checkbox",
						name = texts.menuX.opt2,
						getFunc = function() return NTakCamera.settings.craftDoDistance end,
						setFunc = function(value) NTakCamera.settings.craftDoDistance = value end,
						width = "half",
						disabled = function() return
							NTakCamera.settings.craftAction == presetNone
							or not(NTakCamera.settings.craftPreventCam)
						end,
						default = false,
					},
					{ -- Distance
						type = "slider",
						name = texts.menuX.to,
						min = 0,
						step = 1,
						max = 20,
						getFunc = function() return NTakCamera.settings.craftDistance * 2 end,
						setFunc = function(value)
							NTakCamera.settings.craftDistance = value / 2
							NTakCamera.settings.craftAction = presetCustom
						end,
						width = "half",
						disabled = function() return
							NTakCamera.settings.craftAction == presetNone
							or not(NTakCamera.settings.craftPreventCam)
							or not(NTakCamera.settings.craftDoDistance)
						end,
						default = 5,
					},
					{ -- Do Field of view
						type = "checkbox",
						name = texts.menuX.opt2b,
						getFunc = function() return NTakCamera.settings.craftDoFieldOfView end,
						setFunc = function(value) NTakCamera.settings.craftDoFieldOfView = value end,
						width = "half",
						disabled = function() return
							NTakCamera.settings.craftAction == presetNone
							or not(NTakCamera.settings.craftPreventCam)
						end,
						default = false,
					},
					{ -- Field of view
						type = "slider",
						name = texts.menuX.to,
						min = 70,
						step = 1,
						max = 130,
						getFunc = function() return NTakCamera.settings.craftFieldOfView * 2 end,
						setFunc = function(value)
							NTakCamera.settings.craftFieldOfView = value / 2
							NTakCamera.settings.craftAction = presetCustom
						end,
						width = "half",
						disabled = function() return
							NTakCamera.settings.craftAction == presetNone
							or not(NTakCamera.settings.craftPreventCam)
							or not(NTakCamera.settings.craftDoFieldOfView)
						end,
						default = 100,
					},
					{ -- Do Horizontal position
						type = "checkbox",
						name = texts.menuX.opt3,
						getFunc = function() return NTakCamera.settings.craftDoHorizontalPos end,
						setFunc = function(value) NTakCamera.settings.craftDoHorizontalPos = value end,
						width = "half",
						disabled = function() return
							NTakCamera.settings.craftAction == presetNone
							or not(NTakCamera.settings.craftPreventCam)
						end,
						default = false,
					},
					{ -- Horizontal position
						type = "slider",
						name = texts.menuX.to,
						min = 0,
						step = 1,
						max = 100,
						getFunc = function() return NTakCamera.settings.craftHorizontalPos end,
						setFunc = function(value)
							NTakCamera.settings.craftHorizontalPos = value
							NTakCamera.settings.craftAction = presetCustom
						end,
						width = "half",
						disabled = function() return
							NTakCamera.settings.craftAction == presetNone
							or not(NTakCamera.settings.craftPreventCam)
							or not(NTakCamera.settings.craftDoHorizontalPos)
						end,
						default = 66,
					},
					{ -- Do Vertical position
						type = "checkbox",
						name = texts.menuX.opt4,
						getFunc = function() return NTakCamera.settings.craftDoVerticalOffset end,
						setFunc = function(value) NTakCamera.settings.craftDoVerticalOffset = value end,
						width = "half",
						disabled = function() return
							NTakCamera.settings.craftAction == presetNone
							or not(NTakCamera.settings.craftPreventCam)
						end,
						default = false,
					},
					{ -- Vertical position
						type = "slider",
						name = texts.menuX.to,
						min = -60,
						step = 1,
						max = 100,
						getFunc = function() return NTakCamera.settings.craftVerticalOffset * 2 end,
						setFunc = function(value)
							NTakCamera.settings.craftVerticalOffset = value / 2
							NTakCamera.settings.craftAction = presetCustom
						end,
						width = "half",
						disabled = function() return
							NTakCamera.settings.craftAction == presetNone
							or not(NTakCamera.settings.craftPreventCam)
							or not(NTakCamera.settings.craftDoVerticalOffset)
						end,
						default = 0,
					},
				}
			},
			{ -- ON OUTFIT STATION
				type = "submenu",
				name = icons["Outfit"] .. " " .. texts.cat3.menu3.title,
				disabledLabel = function() return not(NTakCamera.settings.stylePreventCam) end,
				controls =
				{
					{ -- Prevent default interaction cam
						type = "checkbox",
						name = texts.menuX.opt0,
						getFunc = function() return NTakCamera.settings.stylePreventCam end,
						setFunc = function(value)
							NTakCamera.settings.stylePreventCam = value
							InitBlockingInteractions()
						end,
						width = "full",
						default = false,
					},
					{ -- Preset list
						type = "dropdown",
						name = texts.menuX.opt1,
						choices = texts.menuX.choices,
						getFunc = function() return NTakCamera.settings.styleAction end,
						setFunc = function(value)
							if not(value == presetCustom) then
								NTakCamera.settings.styleDoDistance			= false
								NTakCamera.settings.styleDoFieldOfView		= false
								NTakCamera.settings.styleDoHorizontalPos 	= false
								NTakCamera.settings.styleDoVerticalOffset	= false
							end
							if value == presetCenter3rd then
								NTakCamera.settings.styleDoDistance			= true
								NTakCamera.settings.styleDistance 			= NTakCamera.settings.defaultDistance
								NTakCamera.settings.styleDoHorizontalPos	= true
								NTakCamera.settings.styleHorizontalPos 		= 0
							end
							if value == presetSwitch1st then
								NTakCamera.settings.styleDoDistance			= true
								NTakCamera.settings.styleDistance 			= 0
							end
							if value == presetSwitch3rd then
								NTakCamera.settings.styleDoDistance			= true
								NTakCamera.settings.styleDistance 			= 5
							end
							if value == presetDistant then
								NTakCamera.settings.styleDoDistance 		= true
								NTakCamera.settings.styleDistance 			= 8
							end
							if value == presetFocus then
								NTakCamera.settings.styleDoDistance 		= true
								NTakCamera.settings.styleDistance 			= 3
								NTakCamera.settings.styleDoFieldOfView		= true
								NTakCamera.settings.styleFieldOfView		= 40
							end
							NTakCamera.settings.styleAction = value
						end,
						width = "full",
						disabled = function() return not(NTakCamera.settings.stylePreventCam) end,
						default = presetNone,
					},
					{ -- Do Distance
						type = "checkbox",
						name = texts.menuX.opt2,
						getFunc = function() return NTakCamera.settings.styleDoDistance end,
						setFunc = function(value) NTakCamera.settings.styleDoDistance = value end,
						width = "half",
						disabled = function() return
							NTakCamera.settings.styleAction == presetNone
							or not(NTakCamera.settings.stylePreventCam)
						end,
						default = false,
					},
					{ -- Distance
						type = "slider",
						name = texts.menuX.to,
						min = 0,
						step = 1,
						max = 20,
						getFunc = function() return NTakCamera.settings.styleDistance * 2 end,
						setFunc = function(value)
							NTakCamera.settings.styleDistance = value / 2
							NTakCamera.settings.styleAction = presetCustom
						end,
						width = "half",
						disabled = function() return
							NTakCamera.settings.styleAction == presetNone
							or not(NTakCamera.settings.stylePreventCam)
							or not(NTakCamera.settings.styleDoDistance)
						end,
						default = 5,
					},
					{ -- Do Field of View
						type = "checkbox",
						name = texts.menuX.opt2b,
						getFunc = function() return NTakCamera.settings.styleDoFieldOfView end,
						setFunc = function(value) NTakCamera.settings.styleDoFieldOfView = value end,
						width = "half",
						disabled = function() return
							NTakCamera.settings.styleAction == presetNone
							or not(NTakCamera.settings.stylePreventCam)
						end,
						default = false,
					},
					{ -- Field of View
						type = "slider",
						name = texts.menuX.to,
						min = 70,
						step = 1,
						max = 130,
						getFunc = function() return NTakCamera.settings.styleFieldOfView * 2 end,
						setFunc = function(value)
							NTakCamera.settings.styleFieldOfView = value / 2
							NTakCamera.settings.styleAction = presetCustom
						end,
						width = "half",
						disabled = function() return
							NTakCamera.settings.styleAction == presetNone
							or not(NTakCamera.settings.stylePreventCam)
							or not(NTakCamera.settings.styleDoFieldOfView)
						end,
						default = 100,
					},
					{ -- Do Horizontal position
						type = "checkbox",
						name = texts.menuX.opt3,
						getFunc = function() return NTakCamera.settings.styleDoHorizontalPos end,
						setFunc = function(value) NTakCamera.settings.styleDoHorizontalPos = value end,
						width = "half",
						disabled = function() return
							NTakCamera.settings.styleAction == presetNone
							or not(NTakCamera.settings.stylePreventCam)
						end,
						default = false,
					},
					{ -- Horizontal position
						type = "slider",
						name = texts.menuX.to,
						min = 0,
						step = 1,
						max = 100,
						getFunc = function() return NTakCamera.settings.styleHorizontalPos end,
						setFunc = function(value)
							NTakCamera.settings.styleHorizontalPos = value
							NTakCamera.settings.styleAction = presetCustom
						end,
						width = "half",
						disabled = function() return
							NTakCamera.settings.styleAction == presetNone
							or not(NTakCamera.settings.stylePreventCam)
							or not(NTakCamera.settings.styleDoHorizontalPos)
						end,
						default = 66,
					},
					{ -- Do Vertical position
						type = "checkbox",
						name = texts.menuX.opt4,
						getFunc = function() return NTakCamera.settings.styleDoVerticalOffset end,
						setFunc = function(value) NTakCamera.settings.styleDoVerticalOffset = value end,
						width = "half",
						disabled = function() return
							NTakCamera.settings.styleAction == presetNone
							or not(NTakCamera.settings.stylePreventCam)
						end,
						default = false,
					},
					{ -- Vertical position
						type = "slider",
						name = texts.menuX.to,
						min = -60,
						step = 1,
						max = 100,
						getFunc = function() return NTakCamera.settings.styleVerticalOffset * 2 end,
						setFunc = function(value)
							NTakCamera.settings.styleVerticalOffset = value / 2
							NTakCamera.settings.styleAction = presetCustom
						end,
						width = "half",
						disabled = function() return
							NTakCamera.settings.styleAction == presetNone
							or not(NTakCamera.settings.stylePreventCam)
							or not(NTakCamera.settings.styleDoVerticalOffset)
						end,
						default = 0,
					},
				}
			},
			{ -- WHILE LOCKPICKING
				type = "submenu",
				name = icons["Lockpick"] .. " " .. texts.cat3.menu4.title,
				disabledLabel = function() return not(NTakCamera.settings.lockpickPreventCam) end,
				controls =
				{
					{ -- Prevent default interaction cam
						type = "checkbox",
						name = texts.menuX.opt0,
						getFunc = function() return NTakCamera.settings.lockpickPreventCam end,
						setFunc = function(value)
							NTakCamera.settings.lockpickPreventCam = value
							InitBlockingInteractions()
						end,
						width = "full",
						default = false,
					},
					{ -- Preset list
						type = "dropdown",
						name = texts.menuX.opt1,
						choices = texts.menuX.choices,
						getFunc = function() return NTakCamera.settings.lockpickAction end,
						setFunc = function(value)
							if not(value == presetCustom) then
								NTakCamera.settings.lockpickDoDistance			= false
								NTakCamera.settings.lockpickDoFieldOfView		= false
								NTakCamera.settings.lockpickDoHorizontalPos 	= false
								NTakCamera.settings.lockpickDoVerticalOffset	= false
							end
							if value == presetCenter3rd then
								NTakCamera.settings.lockpickDoDistance			= true
								NTakCamera.settings.lockpickDistance 			= NTakCamera.settings.defaultDistance
								NTakCamera.settings.lockpickDoHorizontalPos		= true
								NTakCamera.settings.lockpickHorizontalPos 		= 0
							end
							if value == presetSwitch1st then
								NTakCamera.settings.lockpickDoDistance			= true
								NTakCamera.settings.lockpickDistance 			= 0
							end
							if value == presetSwitch3rd then
								NTakCamera.settings.lockpickDoDistance			= true
								NTakCamera.settings.lockpickDistance 			= 5
							end
							if value == presetDistant then
								NTakCamera.settings.lockpickDoDistance 			= true
								NTakCamera.settings.lockpickDistance 			= 8
							end
							if value == presetFocus then
								NTakCamera.settings.lockpickDoDistance 			= true
								NTakCamera.settings.lockpickDistance 			= 3
								NTakCamera.settings.lockpickDoFieldOfView		= true
								NTakCamera.settings.lockpickFieldOfView			= 40
							end
							NTakCamera.settings.lockpickAction = value
						end,
						width = "full",
						disabled = function() return not(NTakCamera.settings.lockpickPreventCam) end,
						default = presetNone,
					},
					{ -- Do Distance
						type = "checkbox",
						name = texts.menuX.opt2,
						getFunc = function() return NTakCamera.settings.lockpickDoDistance end,
						setFunc = function(value) NTakCamera.settings.lockpickDoDistance = value end,
						width = "half",
						disabled = function() return
							NTakCamera.settings.lockpickAction == presetNone
							or not(NTakCamera.settings.lockpickPreventCam)
						end,
						default = false,
					},
					{ -- Distance
						type = "slider",
						name = texts.menuX.to,
						min = 0,
						step = 1,
						max = 20,
						getFunc = function() return NTakCamera.settings.lockpickDistance * 2 end,
						setFunc = function(value)
							NTakCamera.settings.lockpickDistance = value / 2
							NTakCamera.settings.lockpickAction = presetCustom
						end,
						width = "half",
						disabled = function() return
							NTakCamera.settings.lockpickAction == presetNone
							or not(NTakCamera.settings.lockpickPreventCam)
							or not(NTakCamera.settings.lockpickDoDistance)
						end,
						default = 5,
					},
					{ -- Do Field of View
						type = "checkbox",
						name = texts.menuX.opt2b,
						getFunc = function() return NTakCamera.settings.lockpickDoFieldOfView end,
						setFunc = function(value) NTakCamera.settings.lockpickDoFieldOfView = value end,
						width = "half",
						disabled = function() return
							NTakCamera.settings.lockpickAction == presetNone
							or not(NTakCamera.settings.lockpickPreventCam)
						end,
						default = false,
					},
					{ -- Field of View
						type = "slider",
						name = texts.menuX.to,
						min = 70,
						step = 1,
						max = 130,
						getFunc = function() return NTakCamera.settings.lockpickFieldOfView * 2 end,
						setFunc = function(value)
							NTakCamera.settings.lockpickFieldOfView = value / 2
							NTakCamera.settings.lockpickAction = presetCustom
						end,
						width = "half",
						disabled = function() return
							NTakCamera.settings.lockpickAction == presetNone
							or not(NTakCamera.settings.lockpickPreventCam)
							or not(NTakCamera.settings.lockpickDoFieldOfView)
						end,
						default = 100,
					},
					{ -- Do Horizontal position
						type = "checkbox",
						name = texts.menuX.opt3,
						getFunc = function() return NTakCamera.settings.lockpickDoHorizontalPos end,
						setFunc = function(value) NTakCamera.settings.lockpickDoHorizontalPos = value end,
						width = "half",
						disabled = function() return
							NTakCamera.settings.lockpickAction == presetNone
							or not(NTakCamera.settings.lockpickPreventCam)
						end,
						default = false,
					},
					{ -- Horizontal position
						type = "slider",
						name = texts.menuX.to,
						min = 0,
						step = 1,
						max = 100,
						getFunc = function() return NTakCamera.settings.lockpickHorizontalPos end,
						setFunc = function(value)
							NTakCamera.settings.lockpickHorizontalPos = value
							NTakCamera.settings.lockpickAction = presetCustom
						end,
						width = "half",
						disabled = function() return
							NTakCamera.settings.lockpickAction == presetNone
							or not(NTakCamera.settings.lockpickPreventCam)
							or not(NTakCamera.settings.lockpickDoHorizontalPos)
						end,
						default = 66,
					},
					{ -- Do Vertical position
						type = "checkbox",
						name = texts.menuX.opt4,
						getFunc = function() return NTakCamera.settings.lockpickDoVerticalOffset end,
						setFunc = function(value) NTakCamera.settings.lockpickDoVerticalOffset = value end,
						width = "half",
						disabled = function() return
							NTakCamera.settings.lockpickAction == presetNone
							or not(NTakCamera.settings.lockpickPreventCam)
						end,
						default = false,
					},
					{ -- Vertical position
						type = "slider",
						name = texts.menuX.to,
						min = -60,
						step = 1,
						max = 100,
						getFunc = function() return NTakCamera.settings.lockpickVerticalOffset * 2 end,
						setFunc = function(value)
							NTakCamera.settings.lockpickVerticalOffset = value / 2
							NTakCamera.settings.lockpickAction = presetCustom
						end,
						width = "half",
						disabled = function() return
							NTakCamera.settings.lockpickAction == presetNone
							or not(NTakCamera.settings.lockpickPreventCam)
							or not(NTakCamera.settings.lockpickDoVerticalOffset)
						end,
						default = 0,
					},
				}
			},			
		SPACER,
		{ -- EVENT-DRIVEN CAMERA CHANGES
			type = "header",
			name = Titler(texts.cat4.title),
			width = "full",
		},
			{ -- Description
				type = "description",
				title = nil,
				text = texts.cat4.desc1,
				width = "full"
			},	
			{ -- ON MOVE
				type = "submenu",
				name = icons["Move"] .. " " .. texts.cat4.menu0.title,
				disabledLabel = function() return NTakCamera.settings.moveAction == presetNone end,
				controls =
				{
					{ -- Preset list
						type = "dropdown",
						name = texts.menuX.opt1,
						choices = texts.menuX.choices,
						getFunc = function() return NTakCamera.settings.moveAction end,
						setFunc = function(value)
							if not(value == presetCustom) then
								NTakCamera.settings.moveDoDistance		= false
								NTakCamera.settings.moveDoFieldOfView	= false
								NTakCamera.settings.moveDoHorizontalPos 	= false
								NTakCamera.settings.moveDoVerticalOffset	= false
							end
							if value == presetCenter3rd then
								NTakCamera.settings.moveDoDistance		= true
								NTakCamera.settings.moveDistance 		= NTakCamera.settings.defaultDistance
								NTakCamera.settings.moveDoHorizontalPos	= true
								NTakCamera.settings.moveHorizontalPos 	= 0
							end
							if value == presetSwitch1st then
								NTakCamera.settings.moveDoDistance		= true
								NTakCamera.settings.moveDistance 		= 0
							end
							if value == presetSwitch3rd then
								NTakCamera.settings.moveDoDistance		= true
								NTakCamera.settings.moveDistance 		= 5
							end
							if value == presetDistant then
								NTakCamera.settings.moveDoDistance 		= true
								NTakCamera.settings.moveDistance 		= 8
							end
							if value == presetFocus then
								NTakCamera.settings.moveDoDistance 		= true
								NTakCamera.settings.moveDistance 		= 3
								NTakCamera.settings.moveDoFieldOfView	= true
								NTakCamera.settings.moveFieldOfView		= 40
							end
							NTakCamera.settings.moveAction = value
						end,
						width = "full",
						default = presetNone,
					},
					{ -- Do Distance
						type = "checkbox",
						name = texts.menuX.opt2,
						getFunc = function() return NTakCamera.settings.moveDoDistance end,
						setFunc = function(value) NTakCamera.settings.moveDoDistance = value end,
						width = "half",
						disabled = function() return
							NTakCamera.settings.moveAction == presetNone
						end,
						default = false,
					},
					{ -- Distance
						type = "slider",
						name = texts.menuX.to,
						min = 0,
						step = 1,
						max = 20,
						getFunc = function() return NTakCamera.settings.moveDistance * 2 end,
						setFunc = function(value)
							NTakCamera.settings.moveDistance = value / 2
							NTakCamera.settings.moveAction = presetCustom
						end,
						width = "half",
						disabled = function() return
            				NTakCamera.settings.moveAction == presetNone
            				or not(NTakCamera.settings.moveDoDistance)
          				end,
					},
					{ -- Do Field of View
						type = "checkbox",
						name = texts.menuX.opt2b,
						getFunc = function() return NTakCamera.settings.moveDoFieldOfView end,
						setFunc = function(value) NTakCamera.settings.moveDoFieldOfView = value end,
						width = "half",
						disabled = function() return
							NTakCamera.settings.moveAction == presetNone
						end,
						default = false,
					},
					{ -- Field of View
						type = "slider",
						name = texts.menuX.to,
						min = 70,
						step = 1,
						max = 130,
						getFunc = function() return NTakCamera.settings.moveFieldOfView * 2 end,
						setFunc = function(value)
							NTakCamera.settings.moveFieldOfView = value / 2
							NTakCamera.settings.moveAction = presetCustom
						end,
						width = "half",
						disabled = function() return
							NTakCamera.settings.moveAction == presetNone
							or not(NTakCamera.settings.moveDoFieldOfView)
						end,
						default = 100,
					},
					{ -- Do Horizontal position
						type = "checkbox",
						name = texts.menuX.opt3,
						getFunc = function() return NTakCamera.settings.moveDoHorizontalPos end,
						setFunc = function(value) NTakCamera.settings.moveDoHorizontalPos = value end,
						width = "half",
						disabled = function() return
							NTakCamera.settings.moveAction == presetNone
						end,
						default = false,
					},
					{ -- Horizontal position
						type = "slider",
						name = texts.menuX.to,
						min = 0,
						step = 1,
						max = 100,
						getFunc = function() return NTakCamera.settings.moveHorizontalPos end,
						setFunc = function(value)
							NTakCamera.settings.moveHorizontalPos = value
							NTakCamera.settings.moveAction = presetCustom
						end,
						width = "half",
						disabled = function() return
            				NTakCamera.settings.moveAction == presetNone
            				or not(NTakCamera.settings.moveDoHorizontalPos)
          				end,
					},
					{ -- Do Vertical position
						type = "checkbox",
						name = texts.menuX.opt4,
						getFunc = function() return NTakCamera.settings.moveDoVerticalOffset end,
						setFunc = function(value) NTakCamera.settings.moveDoVerticalOffset = value end,
						width = "half",
						disabled = function() return
							NTakCamera.settings.moveAction == presetNone
						end,
						default = false,
					},
					{ -- Vertical position
						type = "slider",
						name = texts.menuX.to,
						min = -60,
						step = 1,
						max = 100,
						getFunc = function() return NTakCamera.settings.moveVerticalOffset * 2 end,
						setFunc = function(value)
							NTakCamera.settings.moveVerticalOffset = value / 2
							NTakCamera.settings.moveAction = presetCustom
						end,
						width = "half",
						disabled = function() return
            				NTakCamera.settings.moveAction == presetNone
            				or not(NTakCamera.settings.moveDoVerticalOffset)
          				end,
						default = 0,
					},															
					SUBDIVIDER,
					{ -- Debug Movement speed
						type = "checkbox",
						name = texts.cat4.menu0.opt1,
						getFunc = function() return NTakCamera.settings.moveDebugSpeed end,
						setFunc = function(value) NTakCamera.settings.moveDebugSpeed = value end,
						width = "full",
						default = false,
					},
					SUBDIVIDER,		
					{ -- Note on fast moving
						type = "description",
						title = nil,
						text = texts.cat4.menu0.desc1,
						width = "full",		
						disabled = false,
					},
					{ -- Move/Sprint Threshold
						type = "slider",
						name = texts.cat4.menu0.opt2,
						min = 50,
						step = 1,
						max = 150,
						getFunc = function() return NTakCamera.settings.moveFastThreshold * 100 end,
						setFunc = function(value) NTakCamera.settings.moveFastThreshold = value / 100 end,
						width = "full",
						disabled = false,
						default = 90,
					},
					{ -- Do Distance
						type = "checkbox",
						name = texts.menuX.opt2,
						getFunc = function() return NTakCamera.settings.moveFastDoDistance end,
						setFunc = function(value) NTakCamera.settings.moveFastDoDistance = value end,
						width = "half",
						disabled = function() return
							NTakCamera.settings.moveAction == presetNone
							or not(NTakCamera.settings.moveDoDistance)
						end,
						default = false,
					},
					{ -- Distance
						type = "slider",
						name = texts.menuX.to,
						min = 0,
						step = 1,
						max = 20,
						getFunc = function() return NTakCamera.settings.moveFastDistance * 2 end,
						setFunc = function(value) NTakCamera.settings.moveFastDistance = value / 2 end,
						width = "half",
						disabled = function() return
            				NTakCamera.settings.moveAction == presetNone
							or not(NTakCamera.settings.moveDoDistance)
            				or not(NTakCamera.settings.moveFastDoDistance)
          				end,
						default = 20,
					},
					{ -- Do Field of View
						type = "checkbox",
						name = texts.menuX.opt2b,
						getFunc = function() return NTakCamera.settings.moveFastDoFieldOfView end,
						setFunc = function(value) NTakCamera.settings.moveFastDoFieldOfView = value end,
						width = "half",
						disabled = function() return
							NTakCamera.settings.moveAction == presetNone
							or not(NTakCamera.settings.moveDoFieldOfView)
						end,
						default = false,
					},
					{ -- Field of View
						type = "slider",
						name = texts.menuX.to,
						min = 70,
						step = 1,
						max = 130,
						getFunc = function() return NTakCamera.settings.moveFastFieldOfView * 2 end,
						setFunc = function(value) NTakCamera.settings.moveFastFieldOfView = value / 2 end,
						width = "half",
						disabled = function() return
							NTakCamera.settings.moveAction == presetNone
							or not(NTakCamera.settings.moveDoFieldOfView)
							or not(NTakCamera.settings.moveFastDoFieldOfView)
						end,
						default = 130,
					},
					{ -- Do Horizontal position
						type = "checkbox",
						name = texts.menuX.opt3,
						getFunc = function() return NTakCamera.settings.moveFastDoHorizontalPos end,
						setFunc = function(value) NTakCamera.settings.moveFastDoHorizontalPos = value end,
						width = "half",
						disabled = function() return
							NTakCamera.settings.moveAction == presetNone
            				or not(NTakCamera.settings.moveDoHorizontalPos)
						end,
						default = false,
					},
					{ -- Horizontal position
						type = "slider",
						name = texts.menuX.to,
						min = 0,
						step = 1,
						max = 100,
						getFunc = function() return NTakCamera.settings.moveFastHorizontalPos end,
						setFunc = function(value) NTakCamera.settings.moveFastHorizontalPos = value end,
						width = "half",
						disabled = function() return
            				NTakCamera.settings.moveAction == presetNone
            				or not(NTakCamera.settings.moveDoHorizontalPos)
            				or not(NTakCamera.settings.moveFastDoHorizontalPos)
          				end,
					},
					{ -- Do Vertical position
						type = "checkbox",
						name = texts.menuX.opt4,
						getFunc = function() return NTakCamera.settings.moveFastDoVerticalOffset end,
						setFunc = function(value) NTakCamera.settings.moveFastDoVerticalOffset = value end,
						width = "half",
						disabled = function() return
							NTakCamera.settings.moveAction == presetNone
            				or not(NTakCamera.settings.moveDoVerticalOffset)
						end,
						default = false,
					},
					{ -- Vertical position
						type = "slider",
						name = texts.menuX.to,
						min = -60,
						step = 1,
						max = 100,
						getFunc = function() return NTakCamera.settings.moveFastVerticalOffset * 2 end,
						setFunc = function(value) NTakCamera.settings.moveFastVerticalOffset = value / 2 end,
						width = "half",
						disabled = function() return
            				NTakCamera.settings.moveAction == presetNone
            				or not(NTakCamera.settings.moveDoVerticalOffset)
            				or not(NTakCamera.settings.moveFastDoVerticalOffset)
          				end,
						default = 0,
					},
				}
			},
			{ -- ON MOUNT
				type = "submenu",
				name = icons["Mount"] .. " " .. texts.cat4.menu1.title,
				disabledLabel = function() return NTakCamera.settings.rideAction == presetNone end,
				controls =
				{
					{ -- Preset list
						type = "dropdown",
						name = texts.menuX.opt1,
						choices = texts.menuX.choices,
						getFunc = function() return NTakCamera.settings.rideAction end,
						setFunc = function(value)
							if not(value == presetCustom) then
								NTakCamera.settings.rideDoDistance			= false
								NTakCamera.settings.rideDoFieldOfView		= false
								NTakCamera.settings.rideDoHorizontalPos 	= false
								NTakCamera.settings.rideDoVerticalOffset	= false
							end
							if value == presetCenter3rd then
								NTakCamera.settings.rideDoDistance			= true
								NTakCamera.settings.rideDistance			= NTakCamera.settings.defaultDistance
								NTakCamera.settings.rideDoHorizontalPos		= true
								NTakCamera.settings.rideHorizontalPos 		= 0
							end
							if value == presetSwitch1st then
								NTakCamera.settings.rideDoDistance			= true
								NTakCamera.settings.rideDistance 			= 0
							end
							if value == presetSwitch3rd then
								NTakCamera.settings.rideDoDistance			= true
								NTakCamera.settings.rideDistance 			= 5
							end
							if value == presetDistant then
								NTakCamera.settings.rideDoDistance 			= true
								NTakCamera.settings.rideDistance 			= 8
							end
							if value == presetFocus then
								NTakCamera.settings.rideDoDistance 			= true
								NTakCamera.settings.rideDistance 			= 3
								NTakCamera.settings.rideDoFieldOfView		= true
								NTakCamera.settings.rideFieldOfView			= 40
							end
							NTakCamera.settings.rideAction = value
						end,
						width = "full",
						default = presetCustom,
					},
					{ -- Do Distance
						type = "checkbox",
						name = texts.menuX.opt2,
						getFunc = function() return NTakCamera.settings.rideDoDistance end,
						setFunc = function(value) NTakCamera.settings.rideDoDistance = value end,
						width = "half",
						disabled = function() return
							NTakCamera.settings.rideAction == presetNone
						end,
						default = false,
					},
					{ -- Distance
						type = "slider",
						name = texts.menuX.to,
						min = 0,
						step = 1,
						max = 20,
						getFunc = function() return NTakCamera.settings.rideDistance * 2 end,
						setFunc = function(value)
							NTakCamera.settings.rideDistance = value / 2
							NTakCamera.settings.rideAction = presetCustom
						end,
						width = "half",
						disabled = function() return
            				NTakCamera.settings.rideAction == presetNone
            				or not(NTakCamera.settings.rideDoDistance)
          				end,
						default = 10,
					},
					{ -- Do Field of View
						type = "checkbox",
						name = texts.menuX.opt2b,
						getFunc = function() return NTakCamera.settings.rideDoFieldOfView end,
						setFunc = function(value) NTakCamera.settings.rideDoFieldOfView = value end,
						width = "half",
						disabled = function() return
							NTakCamera.settings.rideAction == presetNone
						end,
						default = false,
					},
					{ -- Field of View
						type = "slider",
						name = texts.menuX.to,
						min = 70,
						step = 1,
						max = 130,
						getFunc = function() return NTakCamera.settings.rideFieldOfView * 2 end,
						setFunc = function(value)
							NTakCamera.settings.rideFieldOfView = value / 2
							NTakCamera.settings.rideAction = presetCustom
						end,
						width = "half",
						disabled = function() return
							NTakCamera.settings.rideAction == presetNone
							or not(NTakCamera.settings.rideDoFieldOfView)
						end,
						default = 100,
					},
					{ -- Do Horizontal position
						type = "checkbox",
						name = texts.menuX.opt3,
						getFunc = function() return NTakCamera.settings.rideDoHorizontalPos end,
						setFunc = function(value) NTakCamera.settings.rideDoHorizontalPos = value end,
						width = "half",
						disabled = function() return
							NTakCamera.settings.rideAction == presetNone
						end,
						default = false,
					},
					{ -- Horizontal position
						type = "slider",
						name = texts.menuX.to,
						min = 0,
						step = 1,
						max = 100,
						getFunc = function() return NTakCamera.settings.rideHorizontalPos end,
						setFunc = function(value)
							NTakCamera.settings.rideHorizontalPos = value
							NTakCamera.settings.rideAction = presetCustom
						end,
						width = "half",
						disabled = function()
            				return NTakCamera.settings.rideAction == presetNone
            				or not(NTakCamera.settings.rideDoHorizontalPos)
          				end,
						default = 0,
					},
					{ -- Do Vertical position
						type = "checkbox",
						name = texts.menuX.opt4,
						getFunc = function() return NTakCamera.settings.rideDoVerticalOffset end,
						setFunc = function(value) NTakCamera.settings.rideDoVerticalOffset = value end,
						width = "half",
						disabled = function() return
							NTakCamera.settings.rideAction == presetNone
						end,
						default = false,
					},
					{ -- Vertical position
						type = "slider",
						name = texts.menuX.to,
						min = -60,
						step = 1,
						max = 100,
						getFunc = function() return NTakCamera.settings.rideVerticalOffset * 2 end,
						setFunc = function(value)
							NTakCamera.settings.rideVerticalOffset = value / 2
							NTakCamera.settings.rideAction = presetCustom
						end,
						width = "half",
						disabled = function() return
            				NTakCamera.settings.rideAction == presetNone
            				or not(NTakCamera.settings.rideDoVerticalOffset)
          				end,
						default = 0,
					},
					{ -- Prevent ?
						type = "checkbox",
						name = texts.menuX.opt10 .. texts.cat4.menu1.title,
						getFunc = function() return NTakCamera.settings.ridePreventChange end,
						setFunc = function(value) NTakCamera.settings.ridePreventChange = value end,
						width = "full",
						disabled = function() return
							NTakCamera.settings.rideAction == presetNone
						end,
						default = true,
					},
				}
			},
			{ -- ON STEALTH
				type = "submenu",
				name = icons["Stealth"] .. " " .. texts.cat4.menu2.title,
				disabledLabel = function() return NTakCamera.settings.stealthAction == presetNone end,
				controls =
				{
					{ -- Preset list
						type = "dropdown",
						name = texts.menuX.opt1,
						choices = texts.menuX.choices,
						getFunc = function() return NTakCamera.settings.stealthAction end,
						setFunc = function(value)
							if not(value == presetCustom) then
								NTakCamera.settings.stealthDoDistance		= false
								NTakCamera.settings.stealthDoFieldOfView	= false
								NTakCamera.settings.stealthDoHorizontalPos 	= false
								NTakCamera.settings.stealthDoVerticalOffset	= false
							end
							if value == presetCenter3rd then
								NTakCamera.settings.stealthDoDistance		= true
								NTakCamera.settings.stealthDistance 		= NTakCamera.settings.defaultDistance
								NTakCamera.settings.stealthDoHorizontalPos	= true
								NTakCamera.settings.stealthHorizontalPos 	= 0
							end
							if value == presetSwitch1st then
								NTakCamera.settings.stealthDoDistance		= true
								NTakCamera.settings.stealthDistance 		= 0
							end
							if value == presetSwitch3rd then
								NTakCamera.settings.stealthDoDistance		= true
								NTakCamera.settings.stealthDistance 		= 5
							end
							if value == presetDistant then
								NTakCamera.settings.stealthDoDistance 		= true
								NTakCamera.settings.stealthDistance 		= 8
							end
							if value == presetFocus then
								NTakCamera.settings.stealthDoDistance 		= true
								NTakCamera.settings.stealthDistance 		= 3
								NTakCamera.settings.stealthDoFieldOfView	= true
								NTakCamera.settings.stealthFieldOfView		= 40
							end
							NTakCamera.settings.stealthAction = value
						end,
						width = "full",
						default = presetNone,
					},
					{ -- Do Distance
						type = "checkbox",
						name = texts.menuX.opt2,
						getFunc = function() return NTakCamera.settings.stealthDoDistance end,
						setFunc = function(value) NTakCamera.settings.stealthDoDistance = value end,
						width = "half",
						disabled = function() return
							NTakCamera.settings.stealthAction == presetNone
						end,
						default = false,
					},
					{ -- Distance
						type = "slider",
						name = texts.menuX.to,
						min = 0,
						step = 1,
						max = 20,
						getFunc = function() return NTakCamera.settings.stealthDistance * 2 end,
						setFunc = function(value)
							NTakCamera.settings.stealthDistance = value / 2
							NTakCamera.settings.stealthAction = presetCustom
						end,
						width = "half",
						disabled = function() return
            				NTakCamera.settings.stealthAction == presetNone
            				or not(NTakCamera.settings.stealthDoDistance)
          				end,
					},
					{ -- Do Field of View
						type = "checkbox",
						name = texts.menuX.opt2b,
						getFunc = function() return NTakCamera.settings.stealthDoFieldOfView end,
						setFunc = function(value) NTakCamera.settings.stealthDoFieldOfView = value end,
						width = "half",
						disabled = function() return
							NTakCamera.settings.stealthAction == presetNone
						end,
						default = false,
					},
					{ -- Field of View
						type = "slider",
						name = texts.menuX.to,
						min = 70,
						step = 1,
						max = 130,
						getFunc = function() return NTakCamera.settings.stealthFieldOfView * 2 end,
						setFunc = function(value)
							NTakCamera.settings.stealthFieldOfView = value / 2
							NTakCamera.settings.stealthAction = presetCustom
						end,
						width = "half",
						disabled = function() return
							NTakCamera.settings.stealthAction == presetNone
							or not(NTakCamera.settings.stealthDoFieldOfView)
						end,
						default = 100,
					},
					{ -- Do Horizontal position
						type = "checkbox",
						name = texts.menuX.opt3,
						getFunc = function() return NTakCamera.settings.stealthDoHorizontalPos end,
						setFunc = function(value) NTakCamera.settings.stealthDoHorizontalPos = value end,
						width = "half",
						disabled = function() return
							NTakCamera.settings.stealthAction == presetNone
						end,
						default = false,
					},
					{ -- Horizontal position
						type = "slider",
						name = texts.menuX.to,
						min = 0,
						step = 1,
						max = 100,
						getFunc = function() return NTakCamera.settings.stealthHorizontalPos end,
						setFunc = function(value)
							NTakCamera.settings.stealthHorizontalPos = value
							NTakCamera.settings.stealthAction = presetCustom
						end,
						width = "half",
						disabled = function() return
            				NTakCamera.settings.stealthAction == presetNone
            				or not(NTakCamera.settings.stealthDoHorizontalPos)
          				end,
					},
					{ -- Do Vertical position
						type = "checkbox",
						name = texts.menuX.opt4,
						getFunc = function() return NTakCamera.settings.stealthDoVerticalOffset end,
						setFunc = function(value) NTakCamera.settings.stealthDoVerticalOffset = value end,
						width = "half",
						disabled = function() return
							NTakCamera.settings.stealthAction == presetNone
						end,
						default = false,
					},
					{ -- Vertical position
						type = "slider",
						name = texts.menuX.to,
						min = -60,
						step = 1,
						max = 100,
						getFunc = function() return NTakCamera.settings.stealthVerticalOffset * 2 end,
						setFunc = function(value)
							NTakCamera.settings.stealthVerticalOffset = value / 2
							NTakCamera.settings.stealthAction = presetCustom
						end,
						width = "half",
						disabled = function() return
            				NTakCamera.settings.stealthAction == presetNone
            				or not(NTakCamera.settings.stealthDoVerticalOffset)
          				end,
						default = 0,
					},
					{ -- Off delay
						type = "slider",
						name = texts.menuX.opt5,
						min = 0,
						step = 1,
						max = 200,
						getFunc = function() return NTakCamera.settings.stealthOffDelay end,
						setFunc = function(value) NTakCamera.settings.stealthOffDelay = value end,
						width = "full",
						disabled = function() return NTakCamera.settings.stealthAction == presetNone end,
						default = 0,
					},
				}
			},
			{ -- ON WIELD
				type = "submenu",
				name = icons["Wield"] .. " " .. texts.cat4.menu3.title,
				disabledLabel = function() return NTakCamera.settings.wieldAction == presetNone end,
				controls =
				{
					{ -- Preset list
						type = "dropdown",
						name = texts.menuX.opt1,
						choices = texts.menuX.choices,
						getFunc = function() return NTakCamera.settings.wieldAction end,
						setFunc = function(value)
							if not(value == presetCustom) then
								NTakCamera.settings.wieldDoDistance			= false
								NTakCamera.settings.wieldDoFieldOfView		= false
								NTakCamera.settings.wieldDoHorizontalPos 	= false
								NTakCamera.settings.wieldDoVerticalOffset	= false
							end
							if value == presetCenter3rd then
								NTakCamera.settings.wieldDoDistance			= true
								NTakCamera.settings.wieldDistance 			= NTakCamera.settings.defaultDistance
								NTakCamera.settings.wieldDoHorizontalPos	= true
								NTakCamera.settings.wieldHorizontalPos 		= 0
							end
							if value == presetSwitch1st then
								NTakCamera.settings.wieldDoDistance			= true
								NTakCamera.settings.wieldDistance 			= 0
							end
							if value == presetSwitch3rd then
								NTakCamera.settings.wieldDoDistance			= true
								NTakCamera.settings.wieldDistance 			= 5
							end
							if value == presetDistant then
								NTakCamera.settings.wieldDoDistance 		= true
								NTakCamera.settings.wieldDistance 			= 8
							end
							if value == presetFocus then
								NTakCamera.settings.wieldDoDistance 		= true
								NTakCamera.settings.wieldDistance 			= 3
								NTakCamera.settings.wieldDoFieldOfView		= true
								NTakCamera.settings.wieldFieldOfView		= 40
							end
							NTakCamera.settings.wieldAction = value
						end,
						width = "full",
						default = presetNone,
					},
					{ -- Do Distance
						type = "checkbox",
						name = texts.menuX.opt2,
						getFunc = function() return NTakCamera.settings.wieldDoDistance end,
						setFunc = function(value) NTakCamera.settings.wieldDoDistance = value end,
						width = "half",
						disabled = function() return
							NTakCamera.settings.wieldAction == presetNone
						end,
						default = false,
					},
					{ -- Distance
						type = "slider",
						name = texts.menuX.to,
						min = 0,
						step = 1,
						max = 20,
						getFunc = function() return NTakCamera.settings.wieldDistance * 2 end,
						setFunc = function(value)
							NTakCamera.settings.wieldDistance = value / 2
							NTakCamera.settings.wieldAction = presetCustom
						end,
						width = "half",
						disabled = function() return
            				NTakCamera.settings.wieldAction == presetNone
            				or not(NTakCamera.settings.wieldDoDistance)
          				end,
					},
					{ -- Do Field of View
						type = "checkbox",
						name = texts.menuX.opt2b,
						getFunc = function() return NTakCamera.settings.wieldDoFieldOfView end,
						setFunc = function(value) NTakCamera.settings.wieldDoFieldOfView = value end,
						width = "half",
						disabled = function() return
							NTakCamera.settings.wieldAction == presetNone
						end,
						default = false,
					},
					{ -- Field of View
						type = "slider",
						name = texts.menuX.to,
						min = 70,
						step = 1,
						max = 130,
						getFunc = function() return NTakCamera.settings.wieldFieldOfView * 2 end,
						setFunc = function(value)
							NTakCamera.settings.wieldFieldOfView = value / 2
							NTakCamera.settings.wieldAction = presetCustom
						end,
						width = "half",
						disabled = function() return
							NTakCamera.settings.wieldAction == presetNone
							or not(NTakCamera.settings.wieldDoFieldOfView)
						end,
						default = 100,
					},
					{ -- Do Horizontal position
						type = "checkbox",
						name = texts.menuX.opt3,
						getFunc = function() return NTakCamera.settings.wieldDoHorizontalPos end,
						setFunc = function(value) NTakCamera.settings.wieldDoHorizontalPos = value end,
						width = "half",
						disabled = function() return
							NTakCamera.settings.wieldAction == presetNone
						end,
						default = false,
					},
					{ -- Horizontal position
						type = "slider",
						name = texts.menuX.to,
						min = 0,
						step = 1,
						max = 100,
						getFunc = function() return NTakCamera.settings.wieldHorizontalPos end,
						setFunc = function(value)
							NTakCamera.settings.wieldHorizontalPos = value
							NTakCamera.settings.wieldAction = presetCustom
						end,
						width = "half",
						disabled = function() return
            				NTakCamera.settings.wieldAction == presetNone
            				or not(NTakCamera.settings.wieldDoHorizontalPos)
          				end,
					},
					{ -- Do Vertical position
						type = "checkbox",
						name = texts.menuX.opt4,
						getFunc = function() return NTakCamera.settings.wieldDoVerticalOffset end,
						setFunc = function(value) NTakCamera.settings.wieldDoVerticalOffset = value end,
						width = "half",
						disabled = function() return
							NTakCamera.settings.wieldAction == presetNone
						end,
						default = false,
					},
					{ -- Vertical position
						type = "slider",
						name = texts.menuX.to,
						min = -60,
						step = 1,
						max = 100,
						getFunc = function() return NTakCamera.settings.wieldVerticalOffset * 2 end,
						setFunc = function(value)
							NTakCamera.settings.wieldVerticalOffset = value / 2
							NTakCamera.settings.wieldAction = presetCustom
						end,
						width = "half",
						disabled = function() return
            				NTakCamera.settings.wieldAction == presetNone
            				or not(NTakCamera.settings.wieldDoVerticalOffset)
          				end,
						default = 0,
					},
					{ -- Note on wield event
						type = "description",
						title = nil,
						text = texts.cat4.menu3.desc1,
						width = "full",		
						disabled = function() return NTakCamera.settings.wieldAction == presetNone end,
					},
					{ -- Wield on combat
						type = "checkbox",
						name = texts.cat4.menu3.opt1,
						getFunc = function() return NTakCamera.settings.wieldOnCombat end,
						setFunc = function(value) NTakCamera.settings.wieldOnCombat = value end,
						width = "full",
						disabled = function() return NTakCamera.settings.wieldAction == presetNone end,
						default = false,
					},
				}
			},
			{ -- ON COMBAT
				type = "submenu",
				name = icons["Combat"] .. " " .. texts.cat4.menu4.title,
				disabledLabel = function() return NTakCamera.settings.combatAction == presetNone end,
				controls =
				{
					{ -- Preset list
						type = "dropdown",
						name = texts.menuX.opt1,
						choices = texts.menuX.choices,
						getFunc = function() return NTakCamera.settings.combatAction end,
						setFunc = function(value)
							if not(value == presetCustom) then
								NTakCamera.settings.combatDoDistance		= false
								NTakCamera.settings.combatDoFieldOfView		= false
								NTakCamera.settings.combatDoHorizontalPos 	= false
								NTakCamera.settings.combatDoVerticalOffset	= false
							end
							if value == presetCenter3rd then
								NTakCamera.settings.combatDoDistance		= true
								NTakCamera.settings.combatDistance 			= NTakCamera.settings.defaultDistance
								NTakCamera.settings.combatDoHorizontalPos	= true
								NTakCamera.settings.combatHorizontalPos 	= 0
							end
							if value == presetSwitch1st then
								NTakCamera.settings.combatDoDistance		= true
								NTakCamera.settings.combatDistance 			= 0
							end
							if value == presetSwitch3rd then
								NTakCamera.settings.combatDoDistance		= true
								NTakCamera.settings.combatDistance 			= 5
							end
							if value == presetDistant then
								NTakCamera.settings.combatDoDistance 		= true
								NTakCamera.settings.combatDistance 			= 8
							end
							if value == presetFocus then
								NTakCamera.settings.combatDoDistance 		= true
								NTakCamera.settings.combatDistance 			= 3
								NTakCamera.settings.combatDoFieldOfView		= true
								NTakCamera.settings.combatFieldOfView		= 40
							end
							NTakCamera.settings.combatAction = value
						end,
						width = "full",
						default = presetCustom,
					},
					{ -- Do Distance
						type = "checkbox",
						name = texts.menuX.opt2,
						getFunc = function() return NTakCamera.settings.combatDoDistance end,
						setFunc = function(value) NTakCamera.settings.combatDoDistance = value end,
						width = "half",
						disabled = function() return
							NTakCamera.settings.combatAction == presetNone
						end,
						default = false,
					},
					{ -- Distance
						type = "slider",
						name = texts.menuX.to,
						min = 0,
						step = 1,
						max = 20,
						getFunc = function() return NTakCamera.settings.combatDistance * 2 end,
						setFunc = function(value)
							NTakCamera.settings.combatDistance = value / 2
							NTakCamera.settings.combatAction = presetCustom
						end,
						width = "half",
						disabled = function() return
            				NTakCamera.settings.combatAction == presetNone
            				or not(NTakCamera.settings.combatDoDistance)
          				end,
						default = 8,
					},
					{ -- Do Field of View
						type = "checkbox",
						name = texts.menuX.opt2b,
						getFunc = function() return NTakCamera.settings.combatDoFieldOfView end,
						setFunc = function(value) NTakCamera.settings.combatDoFieldOfView = value end,
						width = "half",
						disabled = function() return
							NTakCamera.settings.combatAction == presetNone
						end,
						default = false,
					},
					{ -- Field of View
						type = "slider",
						name = texts.menuX.to,
						min = 70,
						step = 1,
						max = 130,
						getFunc = function() return NTakCamera.settings.combatFieldOfView * 2 end,
						setFunc = function(value)
							NTakCamera.settings.combatFieldOfView = value / 2
							NTakCamera.settings.combatAction = presetCustom
						end,
						width = "half",
						disabled = function() return
							NTakCamera.settings.combatAction == presetNone
							or not(NTakCamera.settings.combatDoFieldOfView)
						end,
						default = 100,
					},
					{ -- Do Horizontal position
						type = "checkbox",
						name = texts.menuX.opt3,
						getFunc = function() return NTakCamera.settings.combatDoHorizontalPos end,
						setFunc = function(value) NTakCamera.settings.combatDoHorizontalPos = value end,
						width = "half",
						disabled = function() return
							NTakCamera.settings.combatAction == presetNone
						end,
						default = false,
					},
					{ -- Horizontal position
						type = "slider",
						name = texts.menuX.to,
						min = 0,
						step = 1,
						max = 100,
						getFunc = function() return NTakCamera.settings.combatHorizontalPos end,
						setFunc = function(value)
							NTakCamera.settings.combatHorizontalPos = value
							NTakCamera.settings.combatAction = presetCustom
						end,
						width = "half",
						disabled = function() return
            				NTakCamera.settings.combatAction == presetNone
            				or not(NTakCamera.settings.combatDoHorizontalPos)
          				end,
						default = 33,
					},
					{ -- Do Vertical position
						type = "checkbox",
						name = texts.menuX.opt4,
						getFunc = function() return NTakCamera.settings.combatDoVerticalOffset end,
						setFunc = function(value) NTakCamera.settings.combatDoVerticalOffset = value end,
						width = "half",
						disabled = function() return
							NTakCamera.settings.combatAction == presetNone
						end,
						default = false,
					},
					{ -- Vertical position
						type = "slider",
						name = texts.menuX.to,
						min = -60,
						step = 1,
						max = 100,
						getFunc = function() return NTakCamera.settings.combatVerticalOffset * 2 end,
						setFunc = function(value)
							NTakCamera.settings.combatVerticalOffset = value / 2
							NTakCamera.settings.combatAction = presetCustom
						end,
						width = "half",
						disabled = function() return
            				NTakCamera.settings.combatAction == presetNone
            				or not(NTakCamera.settings.combatDoVerticalOffset)
          				end,
						default = 0,
					},
					{ -- Off delay
						type = "slider",
						name = texts.menuX.opt5,
						min = 0,
						step = 1,
						max = 200,
						getFunc = function() return NTakCamera.settings.combatOffDelay end,
						setFunc = function(value) NTakCamera.settings.combatOffDelay = value end,
						width = "full",
						disabled = function() return NTakCamera.settings.combatAction == presetNone end,
						default = 20,
					},
					{ -- Auto-sheath
						type = "checkbox",
						name = texts.cat4.menu4.opt1,
						getFunc = function() return NTakCamera.settings.combatAutoSheath end,
						setFunc = function(value) NTakCamera.settings.combatAutoSheath = value end,
						width = "full",
						disabled = function() return NTakCamera.settings.combatAction == presetNone end,
						default = false,
					},
				}
			},
			{ -- ON WEREWOLF
				type = "submenu",
				name = icons["Werewolf"] .. " " .. texts.cat4.menu5.title,
				disabledLabel = function() return NTakCamera.settings.wolfAction == presetNone end,
				controls =
				{
					{ -- Preset list
						type = "dropdown",
						name = texts.menuX.opt1,
						choices = texts.menuX.choices,
						getFunc = function() return NTakCamera.settings.wolfAction end,
						setFunc = function(value)
							if not(value == presetCustom) then
								NTakCamera.settings.wolfDoDistance			= false
								NTakCamera.settings.wolfDoFieldOfView		= false
								NTakCamera.settings.wolfDoHorizontalPos 	= false
								NTakCamera.settings.wolfDoVerticalOffset	= false
							end
							if value == presetCenter3rd then
								NTakCamera.settings.wolfDoDistance			= true
								NTakCamera.settings.wolfDistance 			= NTakCamera.settings.defaultDistance
								NTakCamera.settings.wolfDoHorizontalPos		= true
								NTakCamera.settings.wolfHorizontalPos 		= 0
							end
							if value == presetSwitch1st then
								NTakCamera.settings.wolfDoDistance			= true
								NTakCamera.settings.wolfDistance 			= 0
							end
							if value == presetSwitch3rd then
								NTakCamera.settings.wolfDoDistance			= true
								NTakCamera.settings.wolfDistance 			= 5
							end
							if value == presetDistant then
								NTakCamera.settings.wolfDoDistance 			= true
								NTakCamera.settings.wolfDistance 			= 8
							end
							if value == presetFocus then
								NTakCamera.settings.wolfDoDistance 			= true
								NTakCamera.settings.wolfDistance 			= 3
								NTakCamera.settings.wolfDoFieldOfView		= true
								NTakCamera.settings.wolfFieldOfView			= 40
							end
							NTakCamera.settings.wolfAction = value
						end,
						width = "full",
						default = presetNone,
					},
					{ -- Do Distance
						type = "checkbox",
						name = texts.menuX.opt2,
						getFunc = function() return NTakCamera.settings.wolfDoDistance end,
						setFunc = function(value) NTakCamera.settings.wolfDoDistance = value end,
						width = "half",
						disabled = function() return
							NTakCamera.settings.wolfAction == presetNone
						end,
						default = false,
					},
					{ -- Distance
						type = "slider",
						name = texts.menuX.to,
						min = 0,
						step = 1,
						max = 20,
						getFunc = function() return NTakCamera.settings.wolfDistance * 2 end,
						setFunc = function(value)
							NTakCamera.settings.wolfDistance = value / 2
							NTakCamera.settings.wolfAction = presetCustom
						end,
						width = "half",
						disabled = function() return
            				NTakCamera.settings.wolfAction == presetNone
            				or not(NTakCamera.settings.wolfDoDistance)
          				end,
					},
					{ -- Do Field of View
						type = "checkbox",
						name = texts.menuX.opt2b,
						getFunc = function() return NTakCamera.settings.wolfDoFieldOfView end,
						setFunc = function(value) NTakCamera.settings.wolfDoFieldOfView = value end,
						width = "half",
						disabled = function() return
							NTakCamera.settings.wolfAction == presetNone
						end,
						default = false,
					},
					{ -- Field of View
						type = "slider",
						name = texts.menuX.to,
						min = 70,
						step = 1,
						max = 130,
						getFunc = function() return NTakCamera.settings.wolfFieldOfView * 2 end,
						setFunc = function(value)
							NTakCamera.settings.wolfFieldOfView = value / 2
							NTakCamera.settings.wolfAction = presetCustom
						end,
						width = "half",
						disabled = function() return
							NTakCamera.settings.wolfAction == presetNone
							or not(NTakCamera.settings.wolfDoFieldOfView)
						end,
						default = 100,
					},
					{ -- Keep distance
						type = "checkbox",
						name = texts.cat4.menu5.opt1,
						getFunc = function() return NTakCamera.settings.wolfKeepDistance end,
						setFunc = function(value) NTakCamera.settings.wolfKeepDistance = value end,
						width = "full",
						disabled = function()
            				return NTakCamera.settings.wolfAction == presetNone
          				end,
						default = false,
					},
					{ -- Do Horizontal position
						type = "checkbox",
						name = texts.menuX.opt3,
						getFunc = function() return NTakCamera.settings.wolfDoHorizontalPos end,
						setFunc = function(value) NTakCamera.settings.wolfDoHorizontalPos = value end,
						width = "half",
						disabled = function() return
							NTakCamera.settings.wolfAction == presetNone
						end,
						default = false,
					},
					{ -- Horizontal position
						type = "slider",
						name = texts.menuX.to,
						min = 0,
						step = 1,
						max = 100,
						getFunc = function() return NTakCamera.settings.wolfHorizontalPos end,
						setFunc = function(value)
							NTakCamera.settings.wolfHorizontalPos = value
							NTakCamera.settings.wolfAction = presetCustom
						end,
						width = "half",
						disabled = function() return
            				NTakCamera.settings.wolfAction == presetNone
            				or not(NTakCamera.settings.wolfDoHorizontalPos)
          				end,
					},
					{ -- Do Vertical position
						type = "checkbox",
						name = texts.menuX.opt4,
						getFunc = function() return NTakCamera.settings.wolfDoVerticalOffset end,
						setFunc = function(value) NTakCamera.settings.wolfDoVerticalOffset = value end,
						width = "half",
						disabled = function() return
							NTakCamera.settings.wolfAction == presetNone
						end,
						default = false,
					},
					{ -- Vertical position
						type = "slider",
						name = texts.menuX.to,
						min = -60,
						step = 1,
						max = 100,
						getFunc = function() return NTakCamera.settings.wolfVerticalOffset * 2 end,
						setFunc = function(value)
							NTakCamera.settings.wolfVerticalOffset = value / 2
							NTakCamera.settings.wolfAction = presetCustom
						end,
						width = "half",
						disabled = function() return
            				NTakCamera.settings.wolfAction == presetNone
            				or not(NTakCamera.settings.wolfDoVerticalOffset)
          				end,
						default = 0,
					},
				}
			},
	}
	
	--	Create options panel
	LAM2:RegisterAddonPanel(ADDON_NAME, panelData)
	LAM2:RegisterOptionControls(ADDON_NAME, options)
end