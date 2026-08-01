
local savedVars = {}
local LAM2 = LibAddonMenu2
local initialized = false

local function showCompanionIcon()
	if savedVars.hideCombat and HasActiveCompanion() then
		return IsUnitInCombat("player")
	end
	return HasActiveCompanion()
end
	
---------------------------------------------------------------------------------------------------------------
-- Player Role Indicator for companions
---------------------------------------------------------------------------------------------------------------
local function createCompanionWindow()
	local unitTag = "companion"
	
	PlayerRoleIndicatorWindow:CreateControl(string.format("$(parent)%s", unitTag),CT_TEXTURE)
	local c = PlayerRoleIndicatorWindow:GetNamedChild(unitTag)
	c:SetAnchor(CENTER, PlayerRoleIndicatorWindow, CENTER, 0, 50)
	c:SetMouseEnabled(false)
	local hidden = not HasPendingCompanion() and not HasActiveCompanion()
	c:SetHidden(true)
end

local function createSubmenu(role, roleSV, roleDefault)
	local submenu = {
		[1] = {
			type = "checkbox",
			name = string.format("Show icon above %s", role),
			getFunc = function() return roleSV.show end,
			setFunc = function(newValue) 
				roleSV.show = newValue
				PlayerRoleIndicator.UpdateRoleSwitch()
				PlayerRoleIndicator.UpdateAllIconVisuals()
				end,
			default = roleDefault.show,
		},
		[2] = {
			type = "checkbox",
			name = string.format("Show icon above alive %s", role),
			getFunc = function() return roleSV.showOnAlive end,
			setFunc = function(newValue) 
				roleSV.showOnAlive = newValue
				PlayerRoleIndicator.UpdateRoleSwitch()
				PlayerRoleIndicator.UpdateAllIconVisuals()
				end,
			disabled = function() return not roleSV.show end,
			default = roleDefault.showOnAlive,
		},
		[3] = {
			type = "colorpicker",
			name = string.format("Colour of alive %s icons", role),
			getFunc = function() return roleSV.colourAlive.r, roleSV.colourAlive.g, roleSV.colourAlive.b, roleSV.colourAlive.a end,
			setFunc = function(r,g,b,a) 
				roleSV.colourAlive.r = r
				roleSV.colourAlive.g = g
				roleSV.colourAlive.b = b
				roleSV.colourAlive.a = a
				PlayerRoleIndicator.UpdateRoleSwitch()
				PlayerRoleIndicator.UpdateAllIconVisuals()
				end,
			disabled = function() return not (roleSV.show and roleSV.showOnAlive) end,
			default = {r = roleDefault.colourAlive.r, g = roleDefault.colourAlive.g, b = roleDefault.colourAlive.b, a = roleDefault.colourAlive.a},
		},
		[4] = {
			type = "colorpicker",
			name = string.format("Colour of dead %s icons", role),
			getFunc = function() return roleSV.colourDead.r, roleSV.colourDead.g, roleSV.colourDead.b, roleSV.colourDead.a end,
			setFunc = function(r,g,b,a) 
				roleSV.colourDead.r = r
				roleSV.colourDead.g = g
				roleSV.colourDead.b = b
				roleSV.colourDead.a = a
				PlayerRoleIndicator.UpdateRoleSwitch()
				PlayerRoleIndicator.UpdateAllIconVisuals()
				end,
			disabled = function() return not roleSV.show end,
			default = {r = roleDefault.colourDead.r, g = roleDefault.colourDead.g, b = roleDefault.colourDead.b, a = roleDefault.colourDead.a},
		},
		[5] = {
			type = "iconpicker",
			name = string.format("Icon to use for %s", role),
			choices = {
				"/esoui/art/compass/activeCompanion.dds",
				"/esoui/art/tutorial/gamepad/gp_lfg_tank.dds",
				"/esoui/art/tutorial/gamepad/gp_lfg_healer.dds",
				"/esoui/art/tutorial/gamepad/gp_lfg_dps.dds",
				"/esoui/art/tutorial/gamepad/gp_lfg_ava.dds",
				"/esoui/art/tutorial/gamepad/gp_lfg_normaldungeon.dds",
				"/esoui/art/tutorial/gamepad/gp_lfg_trial.dds",
				"/esoui/art/tutorial/gamepad/gp_lfg_veteranldungeon.dds",
				"/esoui/art/tutorial/gamepad/gp_lfg_world.dds",
				"/esoui/art/tutorial/gamepad/gp_crowns.dds",
				"/esoui/art/tutorial/gamepad/gp_bonusicon_emperor.dds",
				"/esoui/art/compass/groupleader.dds",
				"/esoui/art/compass/groupmember.dds",
			},
			maxColumns = 3,
			visibleRows = 5,
			iconSize = 32,
			getFunc = function() return roleSV.texturePath end,
			setFunc = function(newValue)
				roleSV.texturePath = newValue
				PlayerRoleIndicator.UpdateRoleSwitch()
				PlayerRoleIndicator.UpdateAllIconVisuals()
				end,
			disabled = function() return not roleSV.show end,
			default = roleDefault.texturePath,
		},
	}
	return submenu
end

local function UpdateRoleSwitch()
	PlayerRoleIndicator.roleSwitch = {
		[LFG_ROLE_TANK] = {
			show = PlayerRoleIndicator.savedVariables.tank.show,
			showOnAlive = PlayerRoleIndicator.savedVariables.tank.showOnAlive,
			sv = PlayerRoleIndicator.savedVariables.tank
			},
		[LFG_ROLE_HEAL] = {
			show = PlayerRoleIndicator.savedVariables.healer.show,
			showOnAlive = PlayerRoleIndicator.savedVariables.healer.showOnAlive,
			sv = PlayerRoleIndicator.savedVariables.healer
			},
		[LFG_ROLE_DPS] = {
			show = PlayerRoleIndicator.savedVariables.dps.show,
			showOnAlive = PlayerRoleIndicator.savedVariables.dps.showOnAlive,
			sv = PlayerRoleIndicator.savedVariables.dps
			},
		["Leader"] = {
			show = PlayerRoleIndicator.savedVariables.leader.show,
			showOnAlive = PlayerRoleIndicator.savedVariables.leader.showOnAlive,
			sv = PlayerRoleIndicator.savedVariables.leader
			},
		[LFG_ROLE_INVALID] = {
			show = false,
			showOnAlive = false,
			sv = {
				texturePath = "",
				colourAlive = {r = 1, g = 1, b = 1, a = 0},
				colourDead = {r = 1, g = 1, b = 1, a = 0},
			}
		},
		["companion"] = {
			show = PlayerRoleIndicator.savedVariables.companion.show,
			showOnAlive = PlayerRoleIndicator.savedVariables.companion.showOnAlive,
			sv = PlayerRoleIndicator.savedVariables.companion
		}
	}
end

local function GetRole(unitTag)
	if unitTag == "companion" then
		return PlayerRoleIndicator.roleSwitch[unitTag]
	end
	
	local customRole = nil
	for _, value in ipairs(PlayerRoleIndicator.savedVariables.customRole) do
		for index, playerName in ipairs(value.players) do
			if playerName == GetUnitDisplayName(unitTag) then 
				customRole = value
				break
			end
		end
		if customRole then break end
	end
	
	local role = nil
	if customRole then
		role = {}
		role.name = customRole.name
		role.show = customRole.show
		role.showOnAlive = customRole.showOnAlive
		role.sv = {
			texturePath = customRole.texturePath,
			colourAlive = customRole.colourAlive,
			colourDead = customRole.colourDead,
		}
	elseif (AreUnitsEqual(GetGroupLeaderUnitTag(), unitTag) and PlayerRoleIndicator.roleSwitch["Leader"].show) then
		role = PlayerRoleIndicator.roleSwitch["Leader"]
	else role = PlayerRoleIndicator.roleSwitch[GetGroupMemberSelectedRole(unitTag)] end
	
	return role
end

local function UpdateAllIconVisuals() 
	if HasActiveCompanion() or HasPendingCompanion() then
		local unitTag = "companion"
		local role = PlayerRoleIndicator.GetRole(unitTag)
		PlayerRoleIndicator.UpdateIconVisual(unitTag, role)
	end
	if IsUnitGrouped("player") then
		for i = 1, PlayerRoleIndicator.groupSize, 1 do
			local unitTag = string.format("group%u", i)
			local role = PlayerRoleIndicator.GetRole(unitTag)
			PlayerRoleIndicator.UpdateIconVisual(unitTag, role)
		end
	end
end
	
local function UnitChecks(unitTag)
	if unitTag == "companion" then return showCompanionIcon() end
	if (not DoesUnitExist(unitTag)) then return false end
	if AreUnitsEqual("player", unitTag) then return false end
	if (not IsUnitPlayer(unitTag)) then return false end
	if (not IsUnitOnline(unitTag)) then return false end
	if (not IsUnitGrouped(unitTag)) then return false end
	if (not IsGroupMemberInSameInstanceAsPlayer(unitTag) or not IsGroupMemberInSameWorldAsPlayer(unitTag) or IsGroupMemberInRemoteRegion(unitTag)) then return false end
	return true
end

local function UpdateIndicators()
	--Gets the direction vectors of the camera and the world position of the camera
	--They are then put into a matrix and inverted
	--The inverted matrix is used to convert world position into a local position with the camera as the origin, and the cameras direction vectors as axis
	local RenderSpace = PlayerRoleIndicator.RenderSpace
	Set3DRenderSpaceToCurrentCamera(RenderSpace:GetName())
	local cameraX, cameraY, cameraZ = GuiRender3DPositionToWorldPosition(RenderSpace:Get3DRenderSpaceOrigin())
	local forwardX, forwardY, forwardZ = RenderSpace:Get3DRenderSpaceForward()
	local rightX, rightY, rightZ = RenderSpace:Get3DRenderSpaceRight()
	local upX, upY, upZ = RenderSpace:Get3DRenderSpaceUp()
	
	local camMatrix = matrix:new(4,4,0)
	
	camMatrix[1][1] = rightX
	camMatrix[1][2] = rightY
	camMatrix[1][3] = rightZ
	camMatrix[1][4] = 0
	
	camMatrix[2][1] = upX
	camMatrix[2][2] = upY
	camMatrix[2][3] = upZ
	camMatrix[2][4] = 0
	
	camMatrix[3][1] = forwardX
	camMatrix[3][2] = forwardY
	camMatrix[3][3] = forwardZ
	camMatrix[3][4] = 0
	
	camMatrix[4][1] = cameraX
	camMatrix[4][2] = cameraY
	camMatrix[4][3] = cameraZ
	camMatrix[4][4] = 1
	
	local camMatrixInv = matrix.invert(camMatrix)
	local screenX, screenY = GuiRoot:GetDimensions()
	
	local hidden = PlayerRoleIndicator.UpdateForUnit("companion", camMatrixInv, screenX, screenY)
	PlayerRoleIndicatorWindow:GetNamedChild("companion"):SetHidden(hidden)
	
	if not IsUnitGrouped("player") then return end
	for i=1, PlayerRoleIndicator.groupSize, 1 do
		local unitTag = string.format("group%u", i)
		local hidden = PlayerRoleIndicator.UpdateForUnit(unitTag, camMatrixInv, screenX, screenY)
		PlayerRoleIndicatorWindow:GetNamedChild(unitTag):SetHidden(hidden)
	end
end

local function CreateSettingsWindow(default)
	local optionsData = {
		[1] = {
			type = "slider",
			name = "Icon size",
			getFunc = function() return PlayerRoleIndicator.savedVariables.iconSize end,
			setFunc = function(newValue)
				PlayerRoleIndicator.savedVariables.iconSize = newValue 
				PlayerRoleIndicator.UpdateRoleSwitch()
				PlayerRoleIndicator.UpdateAllIconVisuals()
				end,
			min = 1,
			max = 128,
			default = PlayerRoleIndicator.default.iconSize,
		},
		[2] = {
			type = "slider",
			name = "Dead player icon offset",
			getFunc = function() return PlayerRoleIndicator.savedVariables.yOffsetDead end,
			setFunc = function(newValue) PlayerRoleIndicator.savedVariables.yOffsetDead = newValue end,
			min = 0,
			max = 500,
			tooltip = "The vertical offset for the icon displayed over dead players.",
			default = PlayerRoleIndicator.default.yOffsetDead,
		},
		[3] = {
			type = "slider",
			name = "Alive player icon offset",
			getFunc = function() return PlayerRoleIndicator.savedVariables.yOffsetAlive end,
			setFunc = function(newValue) PlayerRoleIndicator.savedVariables.yOffsetAlive = newValue end,
			min = 0,
			max = 500,
			tooltip = "The vertical offset for the icon displayed over alive players.",
			default = PlayerRoleIndicator.default.yOffsetAlive,
		},
		[4] = {
			type = "checkbox",
			name = "Use different colours for players resurrection status",
			getFunc = function() return PlayerRoleIndicator.savedVariables.useRezColour end,
			setFunc = function(newValue)
				PlayerRoleIndicator.savedVariables.useRezColour = newValue
				PlayerRoleIndicator.UpdateAllIconVisuals()
				end,
			default = PlayerRoleIndicator.default.useRezColour,
		},
		[5] = {
			type = "colorpicker",
			name = "Colour of players with resurrection pending",
			getFunc = function()  
				local colour = PlayerRoleIndicator.savedVariables.rezPendingColour
				return colour.r, colour.g, colour.b, colour.a 
				end,
			setFunc = function(r,g,b,a)
				local colour = PlayerRoleIndicator.savedVariables.rezPendingColour
				colour.r = r
				colour.g = g
				colour.b = b
				colour.a = a
				PlayerRoleIndicator.UpdateAllIconVisuals()
				end,
			disabled = function() return not PlayerRoleIndicator.savedVariables.useRezColour end, 
			default = {
				r = PlayerRoleIndicator.default.rezPendingColour.r,
				g = PlayerRoleIndicator.default.rezPendingColour.g,
				b = PlayerRoleIndicator.default.rezPendingColour.b,
				a = PlayerRoleIndicator.default.rezPendingColour.a
				},
		},
		[6] = {
			type = "colorpicker",
			name = "Colour of players being resurrected",
			getFunc = function()  
				local colour = PlayerRoleIndicator.savedVariables.rezingColour
				return colour.r, colour.g, colour.b, colour.a 
				end,
			setFunc = function(r,g,b,a)
				local colour = PlayerRoleIndicator.savedVariables.rezingColour
				colour.r = r
				colour.g = g
				colour.b = b
				colour.a = a
				PlayerRoleIndicator.UpdateAllIconVisuals()
				end,
			disabled = function() return not PlayerRoleIndicator.savedVariables.useRezColour end, 
			default = {
				r = PlayerRoleIndicator.default.rezingColour.r,
				g = PlayerRoleIndicator.default.rezingColour.g,
				b = PlayerRoleIndicator.default.rezingColour.b,
				a = PlayerRoleIndicator.default.rezingColour.a
			},
		},
		[7] = {
			type = "submenu",
			name = "Notifications",
			icon = "/esoui/art/tutorial/gamepad/achievement_categoryicon_quests.dds",
			controls = {
				[1] = {
					type = "description",
					text = "Gives a notification on screen when a group member dies or is resurrected." ..
					"\n\nIcon, colour and if it should be showed for X role is taken from the respected role settings."
					},
				[2] = {
					type = "checkbox",
					name = "Use notifications",
					getFunc = function() return PlayerRoleIndicator.savedVariables.useNote end,
					setFunc = function(newValue) PlayerRoleIndicator.savedVariables.useNote = newValue end,
					default = PlayerRoleIndicator.default.useNote,
				},
				[3] = {
					type = "checkbox",
					name = "Unlock and show notification panel",
					getFunc = function() return noteVisable end,
					setFunc = function(newValue)
						local c = PlayerRoleIndicatorWindowNotePanel
						c:SetMouseEnabled(newValue)
						c:SetMovable(newValue)
						
						for i = 1, PlayerRoleIndicator.noteNum, 1 do
							local label = c:GetNamedChild(string.format("Note%u", i))
							local labelIcon = label:GetNamedChild("Icon")
							label:SetHidden(not newValue)
							labelIcon:SetHidden(not newValue)
						end
						
						if not newValue then
							PlayerRoleIndicator.savedVariables.notePos.x = c:GetLeft()
							PlayerRoleIndicator.savedVariables.notePos.y = c:GetTop()
							PlayerRoleIndicator.UpdateAllNoteSize()
						end
						
						noteVisable = newValue
						end,
					disabled = function() return not PlayerRoleIndicator.savedVariables.useNote end,
					default = false,
				},
				[4] = {
					type = "slider",
					name = "Notification scale",
					getFunc = function() return PlayerRoleIndicator.savedVariables.noteSize end,
					setFunc = function(newValue) 
						PlayerRoleIndicator.savedVariables.noteSize = newValue
						PlayerRoleIndicator.UpdateAllNoteSize()
						end,
					min = 0.1,
					max = 4,
					step = 0.1,
					decimals = 1,
					disabled = function() return not PlayerRoleIndicator.savedVariables.useNote end,
					default = PlayerRoleIndicator.default.noteSize,
				},
				[5] = {
					type = "slider",
					name = "Notification duration",
					getFunc = function() return PlayerRoleIndicator.savedVariables.noteDuration end,
					setFunc = function(newValue) PlayerRoleIndicator.savedVariables.noteDuration = newValue end,
					min = 1,
					max = 10,
					disabled = function() return not PlayerRoleIndicator.savedVariables.useNote end,
					default = PlayerRoleIndicator.default.noteDuration,
				},
				[6] = {
					type = "checkbox",
					name = "Use account name",
					getFunc = function() return PlayerRoleIndicator.savedVariables.noteUseAccountName end,
					setFunc = function(newValue) PlayerRoleIndicator.savedVariables.noteUseAccountName = newValue end,
					disabled = function() return not PlayerRoleIndicator.savedVariables.useNote end,
					default = PlayerRoleIndicator.default.noteUseAccountName,
				},
				[7] = {
					type = "checkbox",
					name = "Use role icon in notification",
					getFunc = function() return PlayerRoleIndicator.savedVariables.noteUseIcon end,
					setFunc = function(newValue) PlayerRoleIndicator.savedVariables.noteUseIcon = newValue end,
					disabled = function() return not PlayerRoleIndicator.savedVariables.useNote end,
					default = PlayerRoleIndicator.default.noteUseIcon,
				},
			},
		},
		[8] = {
			type = "submenu",
			name = "leader",
			icon = "/esoui/art/compass/groupleader.dds",
			controls = PlayerRoleIndicator.createSubmenu("leader", PlayerRoleIndicator.savedVariables.leader, PlayerRoleIndicator.default.leader),
		},
		[9] = {
			type = "submenu",
			name = "tanks",
			icon = "/esoui/art/tutorial/gamepad/gp_lfg_tank.dds",
			controls = PlayerRoleIndicator.createSubmenu("tanks", PlayerRoleIndicator.savedVariables.tank, PlayerRoleIndicator.default.tank),
		},
		[10] = {
			type = "submenu",
			name = "healers",
			icon = "/esoui/art/tutorial/gamepad/gp_lfg_healer.dds",
			controls = PlayerRoleIndicator.createSubmenu("healers", PlayerRoleIndicator.savedVariables.healer, PlayerRoleIndicator.default.healer),
		},
		[11] = {
			type = "submenu",
			name = "damage dealers",
			icon = "/esoui/art/tutorial/gamepad/gp_lfg_dps.dds",
			controls = PlayerRoleIndicator.createSubmenu("damage dealers", PlayerRoleIndicator.savedVariables.dps, PlayerRoleIndicator.default.dps),
		},
		[12] = {
			type = "submenu",
			name = "Custom roles",
			icon = "/esoui/art/tutorial/gamepad/gp_lfg_world.dds",
			controls = PlayerRoleIndicator.createCustomRoles(),
		},
		[13] = {
			type = "submenu",
			name = "Shadow of the Fallen",
			icon = GetAbilityIcon(102271), --Icon for "Shadow of the Fallen" buff
			tooltip = "Settings for the veteran Cloudrest shade on death mechanic.",
			controls = {
				[1] = {
					type = "description",
					text = "When a player dies while fighting Z'Maja in veteran Cloudrest a shade will spawn. " ..
					"This shade must be killed before you can resurrect the fallen player." ..
					"\n\nThese are the settings relating to this mechanic, if a player is down and their shade is alive the icon above them will reflect this via a colour change when enabled.",
				},
				[2] = {
					type = "checkbox",
					name = "Enable colour indicator for Shadow of the Fallen",
					getFunc = function() return PlayerRoleIndicator.savedVariables.showShade end,
					setFunc = function(newValue)
						PlayerRoleIndicator.savedVariables.showShade = newValue
						PlayerRoleIndicator.UpdateRoleSwitch()
						PlayerRoleIndicator.UpdateAllIconVisuals()
						end,
					default = PlayerRoleIndicator.default.showShade,
				},
				[3] = {
					type = "colorpicker",
					name = "Colour of icon while shade is alive",
					getFunc = function() return 
						PlayerRoleIndicator.savedVariables.shadeColour.r,
						PlayerRoleIndicator.savedVariables.shadeColour.g,
						PlayerRoleIndicator.savedVariables.shadeColour.b,
						PlayerRoleIndicator.savedVariables.shadeColour.a
						end,
					setFunc = function(r,g,b,a)
						PlayerRoleIndicator.savedVariables.shadeColour.r = r
						PlayerRoleIndicator.savedVariables.shadeColour.g = g
						PlayerRoleIndicator.savedVariables.shadeColour.b = b
						PlayerRoleIndicator.savedVariables.shadeColour.a = a
						end,
					default = {
						r = PlayerRoleIndicator.default.shadeColour.r, 
						g = PlayerRoleIndicator.default.shadeColour.g,
						b = PlayerRoleIndicator.default.shadeColour.b,
						a = PlayerRoleIndicator.default.shadeColour.a
						},
				},
			},
		},
		[14] = {
			type = "submenu",
			name = "companion",
			icon = "/esoui/art/compass/activeCompanion.dds",
	--		controls = PlayerRoleIndicator.createSubmenu("companion", PlayerRoleIndicator.savedVariables.companion, default),
			controls = createSubmenu("companion", PlayerRoleIndicator.savedVariables.companion, default),
		}
	}
	LAM2:RegisterOptionControls("Player_role_indicator", optionsData)
end

---------------------------------------------------------------------------------------------------------------
-- 
---------------------------------------------------------------------------------------------------------------
local Companion_Indicator = ZO_InitializingObject:Subclass()

function Companion_Indicator:Initialize(parent)
	zo_mixin(self, parent)
	savedVars = self.savedVars
end

function Companion_Indicator:PerformDeferredInitialization()
	if not (PlayerRoleIndicator and self.savedVars.indicator) then return end
	
	local default = {
		show = function() return HasActiveCompanion() end,
		showOnAlive = false,
		texturePath = "/esoui/art/compass/activeCompanion.dds",
		colourAlive = {r = 1, g = 1, b = 1, a = 1},
		colourDead = {r = 1, g = 1, b = 1, a = 1},
	}
	
	if not PlayerRoleIndicator.savedVariables.companion then PlayerRoleIndicator.savedVariables.companion = default end
	
	PlayerRoleIndicator.GetRole = GetRole
	PlayerRoleIndicator.UnitChecks = UnitChecks
--	PlayerRoleIndicator.createSubmenu = createSubmenu
	PlayerRoleIndicator.UpdateIndicators = UpdateIndicators
	PlayerRoleIndicator.UpdateRoleSwitch = UpdateRoleSwitch
	PlayerRoleIndicator.UpdateAllIconVisuals = UpdateAllIconVisuals
	CreateSettingsWindow(default)
	
	PlayerRoleIndicator.UpdateRoleSwitch()
	createCompanionWindow()
	
	self.control:RegisterForEvent(EVENT_SCREEN_RESIZED, function()
		PlayerRoleIndicatorWindow:SetDimensions(GuiRoot:GetWidth(),GuiRoot:GetHeight())
	end)
	
	local function OnGamepadPreferredModeChanged()
		-- fires on load
		local isGamepadMode = IsInGamepadPreferredMode()
		self.isGamepadMode = isGamepadMode
		self:SetLootHistoryTemplate(isGamepadMode)
	end
	ZO_PlatformStyle:New(PlayerRoleIndicator.UpdateAllIconVisuals)
	
	EVENT_MANAGER:AddFilterForEvent("PlayerRoleIndicatorShowNote", EVENT_UNIT_DEATH_STATE_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "companion")
	self:RegisterUpdate()
end

function Companion_Indicator:RegisterUpdate()
	EVENT_MANAGER:UnregisterForUpdate("PlayerRoleIndicatorUpdateIndicators")
	EVENT_MANAGER:RegisterForUpdate("PlayerRoleIndicatorUpdateIndicators", 10, PlayerRoleIndicator.UpdateIndicators)
end

---------------------------------------------------------------------------------------------------------------
-- Frame options
---------------------------------------------------------------------------------------------------------------
function Companion_Indicator:GetSettings()
	local controlList = {
		{ type = "checkbox",	-- PRI
			name = GetString(SI_IJA_MCF_INDICATOR),
			tooltip = GetString(SI_IJA_MCF_INDICATOR_TOOLTIP),
			getFunc = function() return self.savedVars.indicator end,
			setFunc = function(value)
				self.savedVars.indicator = value
			end,
			width = "half",
			requiresReload = true,
			disabled = function() return not PlayerRoleIndicator end,
		},
		{ type = "checkbox",
			name = GetString(SI_IJA_MCF_HIDECOMBAT),
			tooltip = GetString(SI_IJA_MCF_HIDECOMBAT_TOOLTIP),
			getFunc = function() return self.savedVars.hideCombat end,
			setFunc = function(value)
				self.savedVars.hideCombat = value
			end,
			disabled = function() return not self.savedVars.indicator end,
			width = "half",
		},
		--[[
		{ type = "slider",		-- scale
            name = GetString(SI_IJA_MCF_UPDATEDELAY),
			tooltip = GetString(SI_IJA_MCF_UPDATEDELAY_TOOLTIP),
			min = 1,
			max = 100,
			step = 1,
			getFunc = function() return self.savedVars.priUpdate end,
			setFunc = function(value)
				self.savedVars.priUpdate = value
				self:RegisterUpdate()
			end,
			disabled = function() return not self.savedVars.indicator end,
			width = "full",
		}
		]]
	}
	
	local menu = {
		type = "submenu",
		name = GetString(SI_IJA_MCF_INDICATOR_HEADER),
		tooltip = GetString(SI_IJA_MCF_INDICATOR_HEADER_TOOLTIP),
		reference = SI_IJA_MCF_INDICATOR_HEADER,
		controls = controlList,
		disabled = function() return not PlayerRoleIndicator end,
	}
	return menu
end

---------
function IJA_CompanionIndicator_Initialize(parent)
	return Companion_Indicator:New(parent)
end
