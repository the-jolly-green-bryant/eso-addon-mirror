-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------
--  Libraries --
-------------------------------------------------------------------------------------------------
local LAM2 = LibStub:GetLibrary("LibAddonMenu-2.0")
local LUNIT = LibStub:GetLibrary("LibUnits")

     --returns a reference to the library table
-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------
--  Variables --
-------------------------------------------------------------------------------------------------

OpenGlaza = {}

--Saved Variables
OpenGlaza.Default = {
	AlertOffsetX = 0,
	AlertOffsetY = -250,
	ArrowOffsetX = 0,
	ArrowOffsetY = -40,
	PortalOffsetX = 250,
	PortalOffsetY = 250,
	checkTopleft = 0,
--	TestOffsetX = 200,
--	TestOffsetY = 400,
--	HoarfrostOffsetX = 300,
--	HoarfrostOffsetY = 500,
	alwaysShow = false,
	disablePersonalities = false,
	trackRF = true,
--	trackHR = false,
	trackPortal = true,
--	showTestArea = false,
	highlightColor = "ebc700",
	mainTextColor = "FF0000",
	usePortalAlert = true
	}


-------------------------------------------------------------------------------------------------
--  Initialize Variables --
-------------------------------------------------------------------------------------------------

OpenGlaza.Name            = "OpenGlaza"
OpenGlaza.DisplayName     = "Open Glaza"
OpenGlaza.version         = "1.003"
OpenGlaza.author          = "Fortan"

RFstartTime1 = 0
RFendTime1 = 0
local RFTimeout1 = 0
local RFTimeout2 = 0
OpenGlazatNameRF = ""
OpenGlazatTagRF = ""
OpenGlazatNameRF2 = ""
OpenGlazatTagRF2 = ""
local checkRF = 0
local portalGroupCheck = true
--Spheres in the Shadow World
local shadowCores = {}
shadowCores[0] = false
shadowCores[1] = 0
shadowCores[2] = 0
shadowCores[3] = 0
local coresTimeout = os.time()
local combatCooldown = os.time()*2
local outCombatCheck = 0
local checkCheckCheck = 0
local difftime = 0
local PLAYER_UNIT_TAG = "player"
local disablePersonalities
local trackRF
local trackPortal
local usePortalAlert
local mainTextColor
local highlightColor

-------------------------------------------------------------------------------------------------
--  OnAddOnLoaded  --
-------------------------------------------------------------------------------------------------

function OpenGlaza.OnAddOnLoaded(event, addonName)
   if addonName ~= OpenGlaza.Name then return end
	OpenGlaza:Initialize()
end
-------------------------------------------------------------------------------------------------
--  Initialize Function --
-------------------------------------------------------------------------------------------------


function OpenGlaza:Initialize()
	OpenGlaza.CreateSettingsWindow()	
    OpenGlaza.savedVariables = ZO_SavedVars:New("OpenGlazaVariables", OpenGlaza.version, nil, OpenGlaza.Default)
	EVENT_MANAGER:UnregisterForEvent(OpenGlaza.Name, EVENT_ADD_ON_LOADED)
	if (OpenGlaza.savedVariables.checkTopleft == 1) then
		OpenGlazaAlert:ClearAnchors()
		OpenGlazaAlert:SetAnchor(TOPLEFT, GuiRoot,TOPLEFT, OpenGlaza.savedVariables.AlertOffsetX, OpenGlaza.savedVariables.AlertOffsetY)
		OpenGlazaArrows:ClearAnchors()
		OpenGlazaArrows:SetAnchor(TOPLEFT, GuiRoot,TOPLEFT, OpenGlaza.savedVariables.ArrowOffsetX, OpenGlaza.savedVariables.ArrowOffsetY)
		OpenGlazaPortal:ClearAnchors()
		OpenGlazaPortal:SetAnchor(TOPLEFT, GuiRoot,TOPLEFT, OpenGlaza.savedVariables.PortalOffsetX, OpenGlaza.savedVariables.PortalOffsetY)
	end
--	OpenGlazaTest:ClearAnchors()
--	OpenGlazaTest:SetAnchor(TOPLEFT, GuiRoot,TOPLEFT, OpenGlaza.savedVariables.TestOffsetX, OpenGlaza.savedVariables.TestOffsetY)
--	OpenGlazaHoarfrost:ClearAnchors()
--	OpenGlazaHoarfrost:SetAnchor(TOPLEFT, GuiRoot,TOPLEFT, OpenGlaza.savedVariables.HoarfrostOffsetX, OpenGlaza.savedVariables.HoarfrostOffsetY)
	
	disablePersonalities = OpenGlaza.savedVariables.disablePersonalities
	trackRF = OpenGlaza.savedVariables.trackRF
--	trackHR = OpenGlaza.savedVariables.trackHR
	trackPortal = OpenGlaza.savedVariables.trackPortal
	usePortalAlert = OpenGlaza.savedVariables.usePortalAlert
--	showTestArea = OpenGlaza.savedVariables.showTestArea
	EVENT_MANAGER:UnregisterForEvent(OpenGlaza.Name, EVENT_ADD_ON_LOADED)
	
	
	self.control = control
	OpenGlazaArrow:SetHidden(true)
	RFendTime1 = os.time()
	portalCountTimer = os.time()
	highlightColor = OpenGlaza.savedVariables.highlightColor
	mainTextColor = OpenGlaza.savedVariables.mainTextColor
	self.inCombat = IsUnitInCombat("player")
--	TestLabel1:SetText("")
--	TestLabel2:SetText("")
--	TestLabel3:SetText("")
--	hoarfrostCount = 0

	OpenGlazaCore1:SetHidden(true)
	OpenGlazaCore2:SetHidden(true)
	OpenGlazaCore3:SetHidden(true)
	OpenGlazaCore1_Ok:SetHidden(true)
	OpenGlazaCore2_Ok:SetHidden(true)
	OpenGlazaCore3_Ok:SetHidden(true)
	
	OpenGlazaAlert:SetHidden(true)
	OpenGlazaAlertWindow:SetHidden(true)
	OpenGlazaPortalAlertWindow:SetHidden(true)
	OpenGlazaArrows:SetHidden(true)
	OpenGlazaPortal:SetHidden(true)
	OpenGlazaCoresWindow:SetHidden(true)
	OpenGlazaPortalGroups:SetHidden(true)
--	OpenGlaza:SetHidden(true)
--	OpenGlazaTest:SetHidden(not showTestArea)
						
	EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_COMBAT_STATE, self.OnPlayerCombatState)
end



-------------------------------------------------------------------------------------------------
--  Register Events --
-------------------------------------------------------------------------------------------------
EVENT_MANAGER:RegisterForEvent(OpenGlaza.Name, EVENT_ADD_ON_LOADED, OpenGlaza.OnAddOnLoaded)


-------------------------------------------------------------------------------------------------
--  Settings --
-------------------------------------------------------------------------------------------------

function OpenGlaza.CreateSettingsWindow()
	local panelData = {
		type = "panel",
		name = "Open Glaza",
		displayName = "Open Glaza",
		author = "Fortan",
		version = OpenGlaza.version,
		slashCommand = "/openglaza",
		registerForRefresh = true,
		registerForDefaults = true,
	}
	local cntrlOptionsPanel = LAM2:RegisterAddonPanel("Open_Glaza", panelData)
	local optionsData = {
		[1] = {
				type = "header",
				name = "Open Glaza Settings"
		},
		[2] = {
				type = "description",
				text = "That addon can get you some help in the Cloudrest... or not. In fact, this is a real Frankenstein. The author doesn't know how to program Lua,  doesn't know how to play and does not bear responsibility. Relax:)"
		},
		[3] = {
				type = "checkbox",
				name = "Show it now? (for reposition)",
				tooltip = "Show it. Open glaza!!!",
				default = false,
				getFunc = function() return OpenGlaza.savedVariables.alwaysShow end,
				setFunc = function(newValue)
					OpenGlaza.savedVariables.alwaysShow = newValue
					if (newValue) then 
						OpenGlazaAlertWindow:SetText("|c"..mainTextColor.."STACK ON|r |c"..highlightColor.."@player|r |c"..mainTextColor.."IN|r |c"..highlightColor.."4|r") 
						OpenGlazaPortalAlertWindow:SetText("|c"..mainTextColor.."PORTAL |r|c"..highlightColor.."GROUP 1|r|c"..mainTextColor.." READY IN|r |c"..highlightColor.."3|r") 
				--		OpenGlazaCoresWindow:SetText("CORES (SHADOW SPHERES) ZONE") 
						OpenGlazaPortalGroups:SetText("|c"..mainTextColor.."PORTAL |r|c"..highlightColor.."GROUP 1|r|c"..mainTextColor.." READY IN|r |c"..highlightColor.."18|r")
				--		OpenGlazaHoarfrostAlert:SetText("HOARFROST ALERT ZONE")
						OpenGlazaAlert:SetHidden(false)
						OpenGlazaAlertWindow:SetHidden(false)
						OpenGlazaPortalAlertWindow:SetHidden(false)
						OpenGlazaArrows:SetHidden(false)
						OpenGlazaArrow:SetHidden(false)
				--		OpenGlazaHoarfrost:SetHidden(false)
						OpenGlazaPortal:SetHidden(false)
						OpenGlazaPortalGroups:SetHidden(false)
						OpenGlazaCoresWindow:SetHidden(false)
						OpenGlazaCore1:SetHidden(false)
						OpenGlazaCore2:SetHidden(false)
						OpenGlazaCore3:SetHidden(true)
						OpenGlazaCore1_Ok:SetHidden(false)
						OpenGlazaCore2_Ok:SetHidden(true)
						OpenGlazaCore3_Ok:SetHidden(true)
					else 
						OpenGlazaAlertWindow:SetText("") 
						OpenGlazaPortalAlertWindow:SetText("") 
						OpenGlazaPortalGroups:SetText("")
					--	OpenGlazaHoarfrostAlert:SetText("")
					--	OpenGlazaCoresWindow:SetText("") 
						OpenGlazaAlertWindow:SetHidden(true)
						OpenGlazaPortalAlertWindow:SetHidden(true)
						OpenGlazaArrows:SetHidden(true)
						OpenGlazaArrow:SetHidden(true)
						OpenGlazaPortal:SetHidden(true)
						OpenGlazaPortalGroups:SetHidden(true)
						OpenGlazaCoresWindow:SetHidden(false)
					--	OpenGlazaHoarfrost:SetHidden(true)
						OpenGlazaCore1:SetHidden(true)
						OpenGlazaCore2:SetHidden(true)
						OpenGlazaCore3:SetHidden(true)
						OpenGlazaCore1_Ok:SetHidden(true)
						OpenGlazaCore2_Ok:SetHidden(true)
						OpenGlazaCore3_Ok:SetHidden(true)
							end			end,
					},
		[4] = {
				type = "checkbox",
				name = "Track Roaring Flare?",
				tooltip = "Do you want track Siroria stack-fire mechanic?",
				default = true,
				getFunc = function() return OpenGlaza.savedVariables.trackRF end,
				setFunc = function(newValue)
					OpenGlaza.savedVariables.trackRF = newValue
					trackRF = newValue
				end,
		},
		[5] = {
				type = "checkbox",
				name = "Track Portal and spheres?",
				tooltip = "Do you want track portal groups and founded cores?",
				default = false,
				getFunc = function() return OpenGlaza.savedVariables.trackPortal end,
				setFunc = function(newValue)
					OpenGlaza.savedVariables.trackPortal = newValue
					trackPortal = newValue
				end,
		},
		[6] = {
				type = "checkbox",
				name = "Portal Alerts with group number",
				tooltip = "Show alert with portal group number four seconds before Shadow Realm portal",
				default = false,
				getFunc = function() return OpenGlaza.savedVariables.usePortalAlert end,
				setFunc = function(newValue)
					OpenGlaza.savedVariables.usePortalAlert = newValue
					usePortalAlert = newValue
				end,
		},
		[7] = {
				type = "checkbox",
				name = "Disable Personalities?",
				tooltip = "That addon have personal messages for some players. If you are one of them and don't like it - just disable. If you wanna your own personality - OpenGlaza.ua, search @fortan and just copy-paste-edit elseif. Good luck!",
				default = false,
				getFunc = function() return OpenGlaza.savedVariables.disablePersonalities end,
				setFunc = function(newValue)
					OpenGlaza.savedVariables.disablePersonalities = newValue
					disablePersonalities = newValue
				end,
		},
		[8] = {
				type = "editbox",
				name = "Main text color",
				tooltip = "You can change alert text color - just use color-code like 00ffff (blue) or 808080 (gray). Don't type #, only code!",
				default = "FF0000",
				getFunc = function() return OpenGlaza.savedVariables.mainTextColor end,
				setFunc = function(newValue)
					OpenGlaza.savedVariables.mainTextColor = newValue
		            mainTextColor = newValue
		       end,
		},
		[9] = {
				type = "editbox",
				name = "Highlight color",
				tooltip = "You can change highlight color for important alert's part - just use color-code like 00ffff (blue) or 808080 (gray). Don't type #, only code! Turn on/off/on ALways Show checkbox to see the changes",
				default = "ebc700",
				getFunc = function() return OpenGlaza.savedVariables.highlightColor end,
				setFunc = function(newValue)
					 OpenGlaza.savedVariables.highlightColor = newValue
		             highlightColor = newValue
		       end,
		},

--[[	[10] = {
				type = "checkbox",
				name = "Test Area?",
				tooltip = "For debug",
				default = false,
				getFunc = function() return OpenGlaza.savedVariables.showTestArea end,
				setFunc = function(newValue)
					OpenGlaza.savedVariables.showTestArea = newValue
					showTestArea = newValue
					OpenGlazaTest:SetHidden(not newValue)
				end,
		},--]]
--[[		[11] =  = {
				type = "checkbox",
				name = "Track Hoarfrost?",
				tooltip = "Do you want track Hoarfrost mechanic?",
				default = false,
				getFunc = function() return OpenGlaza.savedVariables.trackHR end,
				setFunc = function(newValue)
					OpenGlaza.savedVariables.trackHR = newValue
					trackHR = newValue
				end,
				},
		 },--]]
	}
	LAM2:RegisterOptionControls("Open_Glaza", optionsData)
end




-------------------------------------------------------------------------------------------------
--  Save Location --
-------------------------------------------------------------------------------------------------

function OpenGlaza.SaveLoc()
	OpenGlaza.savedVariables.AlertOffsetX = OpenGlazaAlert:GetLeft()
	OpenGlaza.savedVariables.AlertOffsetY = OpenGlazaAlert:GetTop()
	OpenGlaza.savedVariables.ArrowOffsetX = OpenGlazaArrows:GetLeft()
	OpenGlaza.savedVariables.ArrowOffsetY = OpenGlazaArrows:GetTop()
	OpenGlaza.savedVariables.PortalOffsetX = OpenGlazaPortal:GetLeft()
	OpenGlaza.savedVariables.PortalOffsetY = OpenGlazaPortal:GetTop()
	OpenGlaza.savedVariables.checkTopleft = 1
--	OpenGlaza.savedVariables.TestOffsetX = OpenGlazaTest:GetLeft()
--	OpenGlaza.savedVariables.TestOffsetY = OpenGlazaTest:GetTop()
--	OpenGlaza.savedVariables.HoarfrostOffsetX = OpenGlazaHoarfrost:GetLeft()
--	OpenGlaza.savedVariables.HoarfrostOffsetY = OpenGlazaHoarfrost:GetTop()
end

-------------------------------------------------------------------------------------------------
--  Get Name and Tag from ID part (used RaidNotifier's code and library (LUNIT)) --
-------------------------------------------------------------------------------------------------

local function UnitIdToString(id)
	local tag = LUNIT:GetUnitTagForUnitId(id)
	if tag == "" then
		tag = "#"..id
	end
	return tag
end


---reset addon data---
function OpenGlaza.OnPlayerCombatState(event, inCombat)
	if incombat ~= OpenGlaza.inCombat then
		OpenGlaza.inCombat = inCombat
		if inCombat then
			RFstartTime1 = 0
			RFendTime1 = 0
			OpenGlazatNameRF = ""
			OpenGlazatTagRF = ""
			OpenGlazatNameRF2 = ""
			OpenGlazatTagRF2 = ""
			checkRF = 0
			OpenGlazaAlert:SetHidden(false)
			OpenGlazaArrows:SetHidden(false)
			combatCooldown = os.time()*2
		else
			combatCooldown = os.time()+8
			outCombatCheck = 1	
		end
	end
end



-------------------------------------------------------------------------------------------------
--  Show alert, timer and call arrow - ROARING FLARE --
-------------------------------------------------------------------------------------------------
	
function OpenGlaza.OnCombatEvent(_, result, isError, aName, aGraphic, aActionSlotType, sName, sType, tName, tType, hitValue, pType, dType, log, sUnitId, tUnitId, abilityId)

	
	--Roaring Flare BLOCK
	if trackRF then
		if abilityId == 103531 and RFTimeout1 <= os.time() then
			--get tag and Name from Id
			tTag = UnitIdToString(tUnitId)
			tName = GetUnitName(tTag)
			PlaySound(SOUNDS.DUEL_START)
		    --fix time and Name
			RFstartTime1 = os.time()
			RFendTime1 = RFstartTime1+7
			RFTimeout1 = RFstartTime1+16
			OpenGlazatNameRF = tName
			OpenGlazatTagRF = tTag
			checkRF = 1
		end
		if abilityId == 110431 and RFTimeout2 <= os.time() then
			--get 2nd tag and Name from Id
			tTag2 = UnitIdToString(tUnitId)
		    tName2 = GetUnitName(tTag)
		    --fix 2nd Name to global
		    RFstartTime1 = os.time()
			RFendTime1 = RFstartTime1+7
			RFTimeout2 = RFstartTime1+16
			OpenGlazatNameRF2 = tName2
			OpenGlazatTagRF2 = tTag2
			checkRF = 2
		end
	end
	--Hoarfrost BLOCK--
--[[if trackHR then
		if abilityId == 103697 and hoarfrostCount <2 then
			OpenGlazaHoarfrost:SetHidden(false)
			hoarfrostCount = hoarfrostCount+1
			OpenGlazaHoarfrostAlert:SetText("|c"..mainTextColor.."HOARFROST DROPPED|r |c"..highlightColor..hoarfrostCount.."|r|c"..mainTextColor.." TIMES|r")
		elseif abilityId == 103697 then
			OpenGlazaHoarfrost:SetHidden(true)
			hoarfrostCount = 0
			OpenGlazaHoarfrostAlert:SetText("")
		end
	end ]]--
	--Portal GROUPS BLOCK--
	if trackPortal then
		if abilityId == 103946 and result == ACTION_RESULT_BEGIN then
			trackPortalNow = true
			OpenGlazaPortal:SetHidden(false)
			OpenGlazaPortal:SetHidden(false)
			portalCountTimer = os.time() +3
			shadowCores[0] = true
			shadowCores[1] = 0
			shadowCores[2] = 0
			shadowCores[3] = 0
			OpenGlazaCoresWindow:SetHidden(false)
			OpenGlazaCore1:SetHidden(true)
			OpenGlazaCore2:SetHidden(true)
			OpenGlazaCore3:SetHidden(true)
			OpenGlazaCore1_Ok:SetHidden(true)
			OpenGlazaCore2_Ok:SetHidden(true)
			OpenGlazaCore3_Ok:SetHidden(true)
			checkCheckCheck = 0
		end
		--Shadow Cores BLOCK--
		--Start tracking
		if abilityId == 108045 and shadowCores[0] == false and coresTimeout < os.time() then
		--Start counting cores--
			OpenGlazaCore1:SetHidden(true)
			OpenGlazaCore2:SetHidden(true)
			OpenGlazaCore3:SetHidden(true)
			OpenGlazaCore1_Ok:SetHidden(true)
			OpenGlazaCore2_Ok:SetHidden(true)
			OpenGlazaCore3_Ok:SetHidden(true)
		--	OpenGlazaCoresWindow:SetText(shadowCores[1].." || "..shadowCores[2].." || "..shadowCores[3])	
		end		
		--CountFoundedCores
		if abilityId == 103980 then
			if shadowCores[1] == 0 then
				shadowCores[1] = tUnitId
				OpenGlazaCore1:SetHidden(false)
			--	OpenGlazaCoresWindow:SetText(shadowCores[1].." || "..shadowCores[2].." || "..shadowCores[3])	
			elseif shadowCores[2] == 0 and shadowCores[1] ~= tUnitId then
				shadowCores[2] = tUnitId
				OpenGlazaCore2:SetHidden(false)
			--	OpenGlazaCoresWindow:SetText(shadowCores[1].."ok || "..shadowCores[2].." ok|| "..shadowCores[3])
			elseif shadowCores[3] == 0 and shadowCores[1] ~= tUnitId and shadowCores[2] ~= tUnitId then
				shadowCores[3] = tUnitId
				OpenGlazaCore3:SetHidden(false)
			--	OpenGlazaCoresWindow:SetText(shadowCores[1].."ok || "..shadowCores[2].."ok || "..shadowCores[3].."ok")		
			end
		end
		--CountDroppedCores
		if abilityId == 104047 and result == 2250 then
			if shadowCores[1] ~= 1 then
				shadowCores[1] = 1
			--	OpenGlazaCore1:SetHidden(true)
				OpenGlazaCore1_Ok:SetHidden(false)
			--	OpenGlazaCoresWindow:SetText(shadowCores[1].." || "..shadowCores[2].." || "..shadowCores[3])
			elseif shadowCores[2] ~= 1 then
				shadowCores[2] = 1
			--	OpenGlazaCore2:SetHidden(true)
				OpenGlazaCore2_Ok:SetHidden(false)
			--	OpenGlazaCoresWindow:SetText(shadowCores[1].." || "..shadowCores[2].." || "..shadowCores[3])
			elseif shadowCores[3] ~= 1 then
				shadowCores[0] = false
				coresTimeout = os.time()+20
				shadowCores[1] = 0
				shadowCores[2] = 0
				shadowCores[3] = 0
				OpenGlazaCoresWindow:SetHidden(true)
				OpenGlazaCore1:SetHidden(true)
				OpenGlazaCore2:SetHidden(true)
				OpenGlazaCore3:SetHidden(true)
				OpenGlazaCore1_Ok:SetHidden(true)
				OpenGlazaCore2_Ok:SetHidden(true)
				OpenGlazaCore3_Ok:SetHidden(true)
			--	OpenGlazaCoresWindow:SetText("")	
			end
		end
	end	
end

-------------------------------------------------------------------------------------------------
--  ANGLE FUNCTION --
-------------------------------------------------------------------------------------------------
do
	local function AngleRotation(angle)
		--[[
		This function normalize the angle. Check this page:
		https://stackoverflow.com/questions/28909130/how-to-normalize-an-angle-between-%CF%80-and-%CF%80-java
		https://stackoverflow.com/questions/24234609/standard-way-to-normalize-an-angle-to-%CF%80-radians-in-java
		]]	
		return angle - 2*math.pi * math.floor((angle + math.pi) / 2*math.pi)
	end

	function OpenGlaza:GetRotationAngle()
		--[[
		Compare players heading to groupleader position. Check this page:
		https://developer.mozilla.org/de/docs/Web/JavaScript/Reference/Global_Objects/Math/atan2
		It's calculated ccw, in the end you have to calculate for cw (*-1), because the player
		heading is cw too.
		]]
		local playerX, playerY = GetMapPlayerPosition(PLAYER_UNIT_TAG)
		local RFtargetX, RFtargetY = GetMapPlayerPosition(OpenGlazatTagRF)
		return AngleRotation(-1*(AngleRotation(GetPlayerCameraHeading()) - math.atan2(playerX-RFtargetX, playerY-RFtargetY)))
	end
end
	
-------------------------------------------------------------------------------------------------
--  SHOW ALERTS FUNCTION --
-------------------------------------------------------------------------------------------------
		
function OpenGlazaUpdate()
	--ROARING FLARE BLOCK--
	if trackRF then
		difftime = RFendTime1 - os.time()
		if checkRF == 1 then
			if difftime > 0 then
				OpenGlazaAlert:SetHidden(false)
				OpenGlazaAlertWindow:SetHidden(false)
				if OpenGlazatNameRF == GetUnitName(PLAYER_UNIT_TAG) then
					OpenGlazaArrows:SetHidden(true)
					OpenGlazaArrow:SetHidden(true)
					OpenGlazaAlertWindow:SetText("FLARE ON |cebc700YOU|r IN |cebc700"..difftime.."|r")
				else
					OpenGlazaArrows:SetHidden(false)
					OpenGlazaArrow:SetHidden(false)
					rotationAngle = OpenGlaza:GetRotationAngle()
					OpenGlazaArrow:SetTextureRotation(rotationAngle)
					if (not disablePersonalities) and OpenGlazatTagRF ~= nil then
						if GetUnitDisplayName(OpenGlazatTagRF) == "@fortan" then
							OpenGlazaAlertWindow:SetText("|c"..mainTextColor.."HUG|r |c"..highlightColor.."FORTAN|r|c"..mainTextColor.." IN |r |c"..highlightColor..difftime.."|r")
						elseif GetUnitDisplayName(OpenGlazatTagRF) == "@Frost123666" then
							OpenGlazaAlertWindow:SetText("|c"..mainTextColor.."OPEN GLAZA, STACK ON|r |c"..highlightColor.."FROST|r |c"..mainTextColor.."! YOU HAVE |r|c"..highlightColor..difftime.."|r|c"..mainTextColor.." NOFROST-SECONDS!|r")
						elseif GetUnitDisplayName(OpenGlazatTagRF) == "@Stillian" then
							OpenGlazaAlertWindow:SetText("|c"..mainTextColor.."MEIK REID,|r |c"..highlightColor.."STILLIAN|r|c"..mainTextColor..", OR GO NEGEIT |r|c"..highlightColor..difftime"|r")
						elseif GetUnitDisplayName(OpenGlazatTagRF) == "@Bo0gyman" then
							OpenGlazaAlertWindow:SetText("|c"..highlightColor.."BUGI|r|c"..mainTextColor..", NE GORI!|r |c"..highlightColor..difftime.."|r")
						elseif GetUnitDisplayName(OpenGlazatTagRF) == "@LuluKreicer" then
							OpenGlazaAlertWindow:SetText("|c"..mainTextColor.."AE IS ROTTEN. WE CANT FIX IT, BUT CAN SAVE|r |c"..highlightColor..LULU.."|r |c"..mainTextColor.."IN|r |c"..highlightColor..difftime.."|r")
						elseif GetUnitDisplayName(OpenGlazatTagRF) == "@Kirameku" then
							OpenGlazaAlertWindow:SetText("|c"..mainTextColor.."STACK TO |r |c"..highlightColor.."KIRAMEKU|r|c"..mainTextColor.."! OR HEAR «BLYAD'!» IN |r|c"..highlightColor..difftime.."|r")
						elseif GetUnitDisplayName(OpenGlazatTagRF) == "@OhNoItsMischief" then
							OpenGlazaAlertWindow:SetText("|c"..mainTextColor.."OH, NO: WE CAN|r |c"..highlightColor.."MISS CHIEF|r|c"..mainTextColor.."! SAVE HER IN |r|c"..highlightColor..difftime.."|r")
						elseif GetUnitDisplayName(OpenGlazatTagRF) == "@forgottengd" then
							OpenGlazaAlertWindow:SetText("|c"..mainTextColor.."CYKABLYAT SAVE|r |c"..highlightColor.."FOGOTTEN|r|c"..mainTextColor.."!!!|r |c"..highlightColor..difftime.."|r")
						elseif OpenGlazatTagRF ~= nil then
							OpenGlazaAlertWindow:SetText("|c"..mainTextColor.."STACK ON|r |c"..highlightColor..GetUnitDisplayName(OpenGlazatTagRF).."|r |c"..mainTextColor.."IN|r |c"..highlightColor..difftime.."|r")
						end
					else
						OpenGlazaAlertWindow:SetText("|c"..mainTextColor.."STACK ON|r |c"..highlightColor..GetUnitDisplayName(OpenGlazatTagRF).."|r|c"..mainTextColor.." IN|r |c"..highlightColor..difftime.."|r")
					end	
				end
			else
				RFstartTime1 = 0
				RFendTime1 = 0
				checkRF = 0
				OpenGlazatNameRF = ""
				OpenGlazatTagRF = ""
				OpenGlazatNameRF2 = ""
				OpenGlazatTagRF2 = ""
				OpenGlazaArrow:SetHidden(true)
				OpenGlazaArrows:SetHidden(false)
				OpenGlazaAlertWindow:SetText("")
				OpenGlazaAlert:SetHidden(true)
				OpenGlazaAlertWindow:SetHidden(true)
			end
		elseif checkRF == 2 then
			OpenGlazaArrow:SetHidden(true)
			if difftime >0 then
				OpenGlazaAlertWindow:SetText("|c"..highlightColor..GetUnitDisplayName(OpenGlazatTagRF).."|r |c"..mainTextColor.."|r <--- FLARE IN |c"..highlightColor..difftime.."|r|c"..mainTextColor.."  --->|r |c"..highlightColor..GetUnitDisplayName(OpenGlazatTagRF2).."|r")		
			else
				RFstartTime1 = 0
				RFendTime1 = 0
				checkRF = 0
				OpenGlazatNameRF = ""
				OpenGlazatTagRF = ""
				OpenGlazatNameRF2 = ""
				OpenGlazatTagRF2 = ""
				OpenGlazaAlertWindow:SetText("")
			end
		end
	end
	--END OF THE ROARING FLARE, HOARFROST BLOCK--
--	if trackHR then
		
--	end
	--PORTAL GROUPS BLOCK--
	if trackPortal then
		if portalGroupCheck then
			groupName = "GROUP 1"
		else
			groupName = "GROUP 2"
		end
		
		if trackPortalNow ~=nil and trackPortalNow then
			estimatedTime = portalCountTimer - os.time()
			if estimatedTime < 3 and estimatedTime > 0 then
				if usePortalAlert then
					OpenGlazaPortalAlertWindow:SetHidden(false)
					OpenGlazaPortalAlertWindow:SetText("|c"..mainTextColor.."PORTAL: |r|c"..highlightColor..groupName.."|r|c"..mainTextColor.." READY IN|r |c"..highlightColor..estimatedTime.."|r")
				end
				OpenGlazaPortalGroups:SetHidden(false)
				OpenGlazaPortalGroups:SetText("|c"..mainTextColor.."PORTAL |r|c"..highlightColor..groupName.."|r|c"..mainTextColor.." READY IN|r |c"..highlightColor..estimatedTime.."|r")
			elseif estimatedTime > -30 then
				if portalGroupCheck then
					groupName = "GROUP 1"
				else
					groupName = "GROUP 2"
				end
				OpenGlazaPortalAlertWindow:SetHidden(true)
				OpenGlazaPortalGroups:SetHidden(false)
				OpenGlazaPortalGroups:SetText("|c"..mainTextColor.."NOW PORTAL |r|c"..highlightColor..groupName.."|r ")
			elseif checkCheckCheck == 0 then
				portalGroupCheck = not portalGroupCheck 
				if portalGroupCheck then
					groupName = "GROUP 1"
				else
					groupName = "GROUP 2"
				end
				checkCheckCheck = 1
				OpenGlazaPortalAlertWindow:SetHidden(true)
				OpenGlazaPortalAlertWindow:SetText("")
				OpenGlazaPortalGroups:SetText("|c"..mainTextColor.."NEXT PORTAL |r|c"..highlightColor..groupName.."|r ")		
			end
		end
		
		
		--[[
		if trackPortalNow ~=nil and trackPortalNow then
			estimatedTime = portalCountTimer - os.time()
			if estimatedTime > 60 then
				if not portalGroupCheck then
					groupName = "GROUP 1"
				else
					groupName = "GROUP 2"
				end
				OpenGlazaPortalGroups:SetHidden(false)
				OpenGlazaPortalGroups:SetText("|c"..mainTextColor.."NOW PORTAL |r|c"..highlightColor..groupName.."|r "..estimatedTime)
			elseif estimatedTime > 3 then
				OpenGlazaPortalGroups:SetText("|c"..mainTextColor.."PORTAL |r|c"..highlightColor..groupName.."|r|c"..mainTextColor.." READY IN|r |c"..highlightColor..estimatedTime.."|r")
			elseif estimatedTime > 0 then
				if usePortalAlert then
					OpenGlazaPortalAlertWindow:SetHidden(false)
					OpenGlazaPortalAlertWindow:SetText("|c"..mainTextColor.."PORTAL: |r|c"..highlightColor..groupName.."|r|c"..mainTextColor.." READY IN|r |c"..highlightColor..estimatedTime.."|r")
				end
				OpenGlazaPortalGroups:SetHidden(false)
				OpenGlazaPortalGroups:SetText("|c"..mainTextColor.."PORTAL |r|c"..highlightColor..groupName.."|r|c"..mainTextColor.." READY IN|r |c"..highlightColor..estimatedTime.."|r")
			else
				portalGroupCheck = not portalGroupCheck 
				OpenGlazaPortalAlertWindow:SetHidden(true)
				OpenGlazaPortalAlertWindow:SetText("")
				OpenGlazaPortalGroups:SetHidden(true)
				portalCountTimer = os.time()+97
			end
		end
		
		--]]
		
	end
	--RESET BLOCK--
	if combatCooldown < os.time() and outCombatCheck == 1 then
		RFstartTime1 = 0
		RFendTime1 = 0
		OpenGlazatNameRF = ""
		OpenGlazatTagRF = ""
		OpenGlazatNameRF2 = ""
		OpenGlazatTagRF2 = ""
		checkRF = 0	
		portalGroupCheck = true
		trackPortalNow = false
		portalCountTimer = os.time()
		OpenGlazaPortalGroups:SetText("")
		OpenGlazaCoresWindow:SetText("")
		OpenGlazaAlertWindow:SetText("")
		OpenGlazaPortalAlertWindow:SetText("")
		RFTimeout = 0
		OpenGlazaArrows:SetHidden(true)
		OpenGlazaPortal:SetHidden(true)
		OpenGlazaPortalGroups:SetHidden(true)
		OpenGlazaCoresWindow:SetHidden(true)
--		OpenGlazaHoarfrost:SetHidden(true)
		OpenGlazaAlert:SetHidden(true)
		shadowCores[0] = false
		shadowCores[1] = 0
		shadowCores[2] = 0
		shadowCores[3] = 0
		OpenGlazaCore1:SetHidden(true)
		OpenGlazaCore2:SetHidden(true)
		OpenGlazaCore3:SetHidden(true)
		OpenGlazaCore1_Ok:SetHidden(true)
		OpenGlazaCore2_Ok:SetHidden(true)
		OpenGlazaCore3_Ok:SetHidden(true)
		outCombatCheck = 0
		checkCheckCheck = 0
	end	
end
EVENT_MANAGER:RegisterForEvent(OpenGlaza.Name, EVENT_COMBAT_EVENT, OpenGlaza.OnCombatEvent)
EVENT_MANAGER:AddFilterForEvent(OpenGlaza.Name, EVENT_COMBAT_EVENT, REGISTER_FILTER_IS_ERROR, false)