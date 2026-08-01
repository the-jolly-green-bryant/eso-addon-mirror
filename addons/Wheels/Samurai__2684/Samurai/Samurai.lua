SAMURAI = SAMURAI or { }
local sam = SAMURAI

sam.name = "Samurai"
sam.version = "2.14.0-beta"

sam.EM = EventCallbackManager and EventCallbackManager:New("SamuraiManager") or GetEventManager()
local EM = sam.EM

sam.dbug = false

sam.LUNITS = LibUnits2

sam.defaults = {
	["debug"] = false,
	["26bReset"] = false,
	["bossTimers"] = true,
	["hideSubtitles"] = GetSetting(SETTING_TYPE_SUBTITLES, SUBTITLE_SETTING_ENABLED) == 0, -- legacy
	["activeOffsetX"] = 0,
	["activeOffsetY"] = -150,
	["activePoint"] = CENTER,
	["activeRelPoint"] = CENTER,
	["timedOffsetX"] = 0,
	["timedOffsetY"] = -120,
	["timedPoint"] = TOP,
	["timedRelPoint"] = CENTER,
	["modules"] = {
		["potions"] = {
			["renameHeroism"] = true,
			["renameTri"] = true,
			["renameVitality"] = true,
		},
		["targetHealth"] = {
			["show"] = false,
		},
	},
	["notis"] = {
		["Dive"] = true,
		["TakingAim"] = true,
		["HeavyAttack"] = true,
		["HeavySlash"] = true,
		["Bash"] = true,
		["UpperCut"] = true,
		["AnvilCracker"] = true,
		["CrushingBlow"] = true,
		["Boulder"] = true,
		["Slam"] = true,
		["powerBash"] = true,
		["LavaWhip"] = true,
		["TopplingBlow"] = true,
		["ClashofBones"] = true,
		["DrainResource"] = true,
		["LavaGeyser"] = true,
		["Rake"] = true, 
		["WrathofTides"] = true, 
		["CrashingWave"] = true, 
		["Chaurus"] = false, 
		["ChaurusInc"] = false, 
		["StoneCurse"] = true, 
		["ShockingSmash"] = true,
		["DirectCurrent"] = true,
		["NocturnalsFavor"] = true,
		["Creeper"] = true,
		["HeavyStrike"] = true,
		["ssNegate"] = true,
		["ssGale"] = true,
		["ssIce"] = true,
		["transApoc"] = true,
		["asBossProtected"] = true,
		["ShockLash"] = false,
		["IcyTeleport"] = false,
		["creeperTarget"] = false,
		["creeperStun"] = false,
		--["kaMeteor"] = true, go away kabs
	},
}

sam.instances = { }

function sam.debug(message, ...)
	if not sam.dbug then return end
	df("[|cffd000Samur|r.|cffe675ai|r] %s", message:format(...))
end

local function slash(args)
	if args == "debug 1" then
		sam.dbug = true
		sam.savedVars.debug = true
		sam.debug("|c00FF00enabling|r debug mode")
	elseif args == "debug 0" then
		sam.debug("|cFF0000disabling|r debug mode")
		sam.dbug = false
		sam.savedVars.debug = false
	elseif args == "master" then
		sam.masterPrint()
	end
end

function sam.playerActivated()
	local zoneID = GetZoneId(GetUnitZoneIndex("player"))
	for k,v in pairs(sam.instances) do
		if v:getZoneID() == zoneID then
			sam.debug("loading zone %d", zoneID)
			v:Register()
		else
			v:Unregister()
		end
	end
end

function sam.fireInstanceCombatHandlers(e, inCombat)
	for k,v in pairs(sam.instances) do
		if v:getIsLoaded() then
			if inCombat then
				sam.debug("starting")
				v:StartCombat()
			else
				sam.debug("resetting")
				v:Reset()
			end
		end
	end
end

local function bossLines(text)
	if not sam.savedVars.bossTimers then return false end
	local boss = false
	local time = 0
	if string.find(text, "Reprocessing yard contamination critical") then
		boss = true
		time = 9.3
	elseif string.find(text, "Don't .... It's ... trap.") then
		boss = true
		time = 15.6
	elseif string.find(text, "Have you not heard me%? Have I not") then
		boss = true
		time = 24.4
	elseif string.find(text, "There! Somethings coming through! Another fabricant!") then
		boss = true
		time = 7.2
	elseif string.find(text, "The Celestial Mage summons me to") then
		boss = true
		time = 4.4
	elseif string.find(text, "To restore the natural order%. To reclaim all that was and will be") then
		boss = true
		time = 21.2
	elseif string.find(text, "Feel that%? A chill breeze") then
		boss = true
		time = 22.3
	elseif string.find(text, "we kept it hidden from our brethren and buried them with our tears") then
		boss = true
		time = 11
	elseif string.find(text, "They shall not intrude much longer") then
		boss = true
		time = 5
	end
	if boss then
		sam.spawnTimer(time)
	end
end

local channels = {
	[CHAT_CHANNEL_MONSTER_EMOTE] = "CHAT_CHANNEL_MONSTER_EMOTE",
	[CHAT_CHANNEL_MONSTER_SAY] = "CHAT_CHANNEL_MONSTER_SAY",
	[CHAT_CHANNEL_MONSTER_WHISPER] = "CHAT_CHANNEL_MONSTER_WHISPER",
	[CHAT_CHANNEL_MONSTER_YELL] = "CHAT_CHANNEL_MONSTER_YELL",
}

local function chatHandler(e, channelType, fromName, text, isCustomerSupport, fromDisplayName)
	if channels[channelType] then
		sam.debug("message received in channel: %s containing text: %s", channels[channelType], tostring(text))
		bossLines(tostring(text))
	end
end

function sam.init(e, addon)
	if addon ~= sam.name then return end
	EM:UnregisterForEvent(sam.name.."Load", EVENT_ADD_ON_LOADED)
	sam.savedVars = ZO_SavedVars:NewCharacterIdSettings("SamuraiSavedVars", 1, "Samurai", sam.defaults, GetWorldName())
	sam.dbug = sam.savedVars.debug
	SLASH_COMMANDS["/samurai"] = slash
	sam.buildDisplay()
	sam.buildMenu()
	sam.setupTestHarness()
	sam.onStartupNotificationSetup()
	EM:RegisterForEvent(sam.name.."playerActivate", EVENT_PLAYER_ACTIVATED, sam.playerActivated)
	sam.generalAlerts:Register()

	EM:RegisterForEvent(sam.name.."ChatHandler", EVENT_CHAT_MESSAGE_CHANNEL, chatHandler)
	EM:RegisterForEvent(sam.name.."CombatHandlers", EVENT_PLAYER_COMBAT_STATE, sam.fireInstanceCombatHandlers)

	-- setup modules
	sam.setupPotionModule()
	sam.setupTargetHealthModule()

	-- old setting cleanup
	if sam.savedVars.bossTimers and sam.savedVars.hideSubtitles then
		sam.savedVars.hideSubtitles = false
		zo_callLater(function()
			SetSetting(SETTING_TYPE_SUBTITLES, SUBTITLE_SETTING_ENABLED, 0)
		end, 3000)
	end
	
	if not sam.savedVars["26bReset"] then
		sam.savedVars.bossTimers = true
		sam.savedVars["26bReset"] = true
	end
end

EM:RegisterForEvent(sam.name.."Load", EVENT_ADD_ON_LOADED, sam.init)

