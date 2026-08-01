--
-- Addon init
--

local function CreateAddonMenu()
	local lampanel = {
        type = 'panel',
        name = RaidTools.color_name,
        author = RaidTools.author,
        version = RaidTools.version,
        registerForRefresh = false,
        slashCommand = "/rtconfig"
    }

    local lamoptions = {
        {
            type = 'description',
            text = GetString('Raiding thingies'),
        },
        {
            type = 'checkbox',
            name = 'Debug',
            tooltip = 'Enable debug messages (Not recommended)',
            warning = 'Will spam you :)',
            requiresReload = true,
            getFunc = function() return RaidTools.storage.debug end,
            setFunc = function(value)
                RaidTools.storage.debug = value
            end,
        },
    	{
    		type = "header",
		    name = "Modules",
		    width = "full",
    	},
	    {
    		type = "submenu",
		    name = "Leaderboard information",
		    controls = {
		        [1] = {
		            type = 'checkbox',
		            name = 'Weekly information',
		            tooltip = 'Provides you with information about the weekly trial(s)',
		            requiresReload = true,
		            getFunc = function() return RaidTools.storage.modules.weekly_info end,
		            setFunc = function(value)
		                RaidTools.storage.modules.weekly_info = value
		            end,
		        },
		        [2] = {
		            type = 'checkbox',
		            name = 'Leaderboard information',
		            tooltip = 'Provides you with information about the trial leaderboards',
		            requiresReload = true,
		            getFunc = function() return RaidTools.storage.modules.leaderboard_info end,
		            setFunc = function(value)
		                RaidTools.storage.modules.leaderboard_info = value
		            end,
		        },
		    }
	    },
	    {
    		type = "submenu",
		    name = "Group overlay",
		    controls = {
		        --[1] = {
		        --   type = 'checkbox',
		        --    name = 'Raid overlay active',
		        --    tooltip = 'Shows detailed information about group members while in veteran trials',
		        --    requiresReload = true,
		        --    getFunc = function() return RaidTools.storage.modules.group_overlay end,
		        --    setFunc = function(value)
		        --        RaidTools.storage.modules.group_overlay = value
		        --    end,
		        --},
		        [1] = {
		            type = 'checkbox',
		            name = 'Display UserID instead of character name',
		            getFunc = function() return RaidTools.storage.config.go_userid end,
		            setFunc = function(value)
		                RaidTools.storage.config.go_userid = value
		            end,
		        },
		        [2] = {
		            type = 'checkbox',
		            name = 'WarHornStatus active',
		            requiresReload = true,
		            getFunc = function() return RaidTools.storage.config.warhorn.active end,
		            setFunc = function(value)
		                RaidTools.storage.config.warhorn.active = value
		            end,
		        },
		        [3] = {
		            type = 'checkbox',
		            name = 'Show WarHornStatus only as Tank or Heal',
		            requiresReload = true,
		            getFunc = function() return RaidTools.storage.config.warhorn.only_as_key_role end,
		            setFunc = function(value)
		                RaidTools.storage.config.warhorn.only_as_key_role = value
		            end,
		        },
		    }
	    },
	    {
    		type = "submenu",
		    name = "Status bar",
		    controls = {
		    	[1] = {
		            type = 'button',
		            name = 'Preview',
		            tooltip = 'Preview',		           
		            func = function(value)
		                RaidToolsStatusBar.Show()
		            end,
		        },
		        [2] = {
		            type = 'button',
		            name = 'Hide',	           
		            func = function(value)
		                RaidToolsStatusBar.Hide()
		            end,
		        },
		        [3] = {
		            type = 'checkbox',
		            name = 'Module active',
		            tooltip = 'Provides you with a status bar with information about your current run',
		            requiresReload = true,
		            getFunc = function() return RaidTools.storage.modules.status_bar end,
		            setFunc = function(value)
		                RaidTools.storage.modules.status_bar = value
		            end,
		        },
		        [4] = {
		            type = 'checkbox',
		            name = 'Status bar border',
		            tooltip = 'Border around the status bar',
		            requiresReload = true,
		            getFunc = function() return RaidTools.storage.config.status_bar_border end,
		            setFunc = function(value)
		                RaidTools.storage.config.status_bar_border = value
		            end,
		        },
		    }
	    },
	    {
    		type = "submenu",
		    name = "Death recap",
		    controls = {
		        [1] = {
		            type = 'checkbox',
		            name = 'Module active',
		            tooltip = 'Shows the death recap in chat',
		            requiresReload = true,
		            getFunc = function() return RaidTools.storage.modules.death_recap end,
		            setFunc = function(value)
		                RaidTools.storage.modules.death_recap = value
		            end,
		        },
		    }
	    },
	    {
    		type = "submenu",
		    name = "Raid history",
		    controls = {
		        [1] = {
		            type = 'checkbox',
		            name = 'Module active',
		            tooltip = 'Tracks your raid scores',
		            requiresReload = false,
		            getFunc = function() return RaidTools.storage.modules.raid_history end,
		            setFunc = function(value)
		                RaidTools.storage.modules.raid_history = value
		            end,
		        },
		    }
	    },
	    {
    		type = "submenu",
		    name = "DeathCounter",
		    controls = {
		        [1] = {
		            type = 'checkbox',
		            name = 'UserID instead of character names',
		            tooltip = 'Tracks&displays UserID instead of character name for death/revive counter',
		            requiresReload = true,
		            getFunc = function() return RaidTools.storage.config.userid_instead_of_name end,
		            setFunc = function(value)
		                RaidTools.storage.config.userid_instead_of_name = value
		            end,
		        },
		    }
	    },
	    {
    		type = "submenu",
		    name = "Death alert",
		    controls = {
		        [1] = {
		            type = 'checkbox',
		            name = 'Module active',
		            tooltip = 'Displays a huge warning if a group member dies',
		            requiresReload = true,
		            getFunc = function() return RaidTools.storage.modules.death_alert end,
		            setFunc = function(value)
		                RaidTools.storage.modules.death_alert = value
		            end,
		        },
		        [2] = {
		            type = 'checkbox',
		            name = 'Hide DD deaths',
		            tooltip = 'Hides dd deaths',
		            requiresReload = false,
		            getFunc = function() return RaidTools.storage.config.hide_dd_deaths end,
		            setFunc = function(value)
		                RaidTools.storage.config.hide_dd_deaths = value
		            end,
		        },
		    }
	    },
	    {
    		type = "submenu",
		    name = "<UI> Buff affected player count",
		    controls = {
		    	[1] = {
		            type = 'button',
		            name = 'Preview',	           
		            func = function(value)
		                RaidToolsGroupBuffs.Show()
		            end,
		        },
		        [2] = {
		            type = 'button',
		            name = 'Hide',	           
		            func = function(value)
		                RaidToolsGroupBuffs.Hide()
		            end,
		        },
		        [3] = {
		            type = 'checkbox',
		            name = 'Only count DDs',
		            getFunc = function() return RaidTools.storage.config.groupbuffs.only_dds end,
		            setFunc = function(value)
		                RaidTools.storage.config.groupbuffs.only_dds = value
		            end,
		        },
		        [4] = {
		            type = 'checkbox',
		            name = 'Only show when Tank or Healer',
		            getFunc = function() return RaidTools.storage.config.groupbuffs.only_as_key_role end,
		            setFunc = function(value)
		                RaidTools.storage.config.groupbuffs.only_as_key_role = value
		            end,
		        },
		        [5] = {
		            type = 'checkbox',
		            name = 'Show SpellPowerCure',
		            getFunc = function() return RaidTools.storage.config.spc.active end,
		            setFunc = function(value)
		                RaidTools.storage.config.spc.active = value
		            end,
		        },
		        [6] = {
		            type = 'checkbox',
		            name = 'Show CombatPrayer',
		            getFunc = function() return RaidTools.storage.config.cp.active end,
		            setFunc = function(value)
		                RaidTools.storage.config.cp.active = value
		            end,
		        },
		        [7] = {
		            type = 'checkbox',
		            name = 'Show PowerfulAssault',
		            getFunc = function() return RaidTools.storage.config.powass.active end,
		            setFunc = function(value)
		                RaidTools.storage.config.powass.active = value
		            end,
		        },   
		    }
		},
	    {
    		type = "submenu",
		    name = "<RaidHelper> Asylum Sanctorium",
		    controls = {
		    	[1] = {
		            type = 'button',
		            name = 'Preview',	           
		            func = function(value)
		                RaidToolsAsylum.Show()
		            end,
		        },
		        [2] = {
		            type = 'button',
		            name = 'Hide',	           
		            func = function(value)
		                RaidToolsAsylum.Hide()
		            end,
		        },
		        [3] = {
		            type = 'checkbox',
		            name = 'Module active',
		            tooltip = 'Provides you with a status bar with information about your current run',
		            requiresReload = true,
		            getFunc = function() return RaidTools.storage.modules.as_helper end,
		            setFunc = function(value)
		                RaidTools.storage.modules.as_helper = value
		            end,
		        },
		        [4] = {
		            type = 'checkbox',
		            name = 'Window border',
		            tooltip = 'Border around the window',
		            requiresReload = true,
		            getFunc = function() return RaidTools.storage.config.asui.border end,
		            setFunc = function(value)
		                RaidTools.storage.config.asui.border = value
		            end,
		        },
		        --[[
		        [5] = {
		            type = 'checkbox',
		            name = 'Notify: Teleport strike',
		            tooltip = 'Notify if you are targeted by Felms teleport strike',
		            getFunc = function() return RaidTools.storage.config.asui.notify.teleport_strikes end,
		            setFunc = function(value)
		                RaidTools.storage.config.asui.notify.teleport_strikes = value
		            end,
		        },
		        [6] = {
		            type = 'checkbox',
		            name = 'Notify: Opressive bolts',
		            tooltip = 'Pls interrupt that shit',
		            getFunc = function() return RaidTools.storage.config.asui.notify.bolts end,
		            setFunc = function(value)
		                RaidTools.storage.config.asui.notify.bolts = value
		            end,
		        },
		        [7] = {
		            type = 'checkbox',
		            name = 'Notify: Protector spawn',
		            tooltip = 'Notify when protector spawns',
		            getFunc = function() return RaidTools.storage.config.asui.notify.sphere_spawn end,
		            setFunc = function(value)
		                RaidTools.storage.config.asui.notify.sphere_spawn = value
		            end,
		        },
		        [8] = {
		            type = 'checkbox',
		            name = 'Notify: Heaven storm',
		            tooltip = 'Notify when you should kite',
		            getFunc = function() return RaidTools.storage.config.asui.notify.heaven_storm end,
		            setFunc = function(value)
		                RaidTools.storage.config.asui.notify.heaven_storm = value
		            end,
		        },
		        ]]--
		    }
	    },
        {
    		type = "header",
		    name = "Convenience",
		    width = "full",
    	},
    	
    	{
            type = 'checkbox',
            name = 'RaidTools GroupUtilityProtocol (LibGroupSocket)',
            requiresReload = true,
            getFunc = function() return RaidTools.storage.config.libgroupsocket end,
            setFunc = function(value)
                RaidTools.storage.config.libgroupsocket = value
            end,
        },
        {
            type = 'checkbox',
            name = 'Vote interface',
            requiresReload = false,
            getFunc = function() return RaidTools.storage.config.vote.active end,
            setFunc = function(value)
                RaidTools.storage.config.vote.active = value
            end,
        },
    	{
            type = 'checkbox',
            name = 'Coloured ready checks',
            tooltip = 'Coloured ready checks',
            requiresReload = false,
            getFunc = function() return RaidTools.storage.config.coloured_ready_checks end,
            setFunc = function(value)
                RaidTools.storage.config.coloured_ready_checks = value
            end,
        },
    	{
            type = 'checkbox',
            name = 'Random ready checks',
            tooltip = 'Randomizes ready check messages',
            requiresReload = false,
            getFunc = function() return RaidTools.storage.config.random_ready_checks end,
            setFunc = function(value)
                RaidTools.storage.config.random_ready_checks = value
            end,
        },
        {
            type = 'checkbox',
            name = 'Auto-enable skeleton polymorph',
            tooltip = 'Auto-enables skeleton polymorph when entering and/or starting a trial',
            requiresReload = false,
            getFunc = function() return RaidTools.storage.modules.auto_polymorph end,
            setFunc = function(value)
                RaidTools.storage.modules.auto_polymorph = value
            end,
        },
        {
            type = 'checkbox',
            name = 'Check buff-food',
            tooltip = 'Displays when no buff-food is active during trials',
            requiresReload = true,
            getFunc = function() return RaidTools.storage.modules.buff_food_checker end,
            setFunc = function(value)
                RaidTools.storage.modules.buff_food_checker = value
            end,
        },
        {
            type = 'checkbox',
            name = 'Automatically recharge weapons',
            tooltip = 'Automatically recharge weapons',
            requiresReload = false,
            getFunc = function() return RaidTools.storage.modules.auto_recharge_weapons end,
            setFunc = function(value)
                RaidTools.storage.modules.auto_recharge_weapons = value
            end,
        },
        {
            type = 'checkbox',
            name = 'Automatically repairs armour',
            tooltip = 'Automatically repairs armour',
            requiresReload = false,
            getFunc = function() return RaidTools.storage.modules.auto_repair_armour end,
            setFunc = function(value)
                RaidTools.storage.modules.auto_repair_armour = value
            end,
        },
        {
            type = 'checkbox',
            name = 'Display group loot',
            tooltip = 'Notifies about looted set items',
            requiresReload = false,
            getFunc = function() return RaidTools.storage.modules.group_loot end,
            setFunc = function(value)
                RaidTools.storage.modules.group_loot = value
            end,
        },
        {
            type = 'checkbox',
            name = 'Display group notifications',
            tooltip = 'Notifies about group changes (leave, join)',
            requiresReload = false,
            getFunc = function() return RaidTools.storage.modules.group_notifications end,
            setFunc = function(value)
                RaidTools.storage.modules.group_notifications = value
            end,
        },
        {
            type = 'checkbox',
            name = 'Auto repair at merchant',
            tooltip = 'Auto repairs when talking to a merchant',
            requiresReload = false,
            getFunc = function() return RaidTools.storage.modules.auto_repair_at_merchant end,
            setFunc = function(value)
                RaidTools.storage.modules.auto_repair_at_merchant = value
            end,
        },
        {
            type = 'checkbox',
            name = 'Jokes',
            requiresReload = false,
            getFunc = function() return RaidTools.storage.config.jokes end,
            setFunc = function(value)
                RaidTools.storage.config.jokes = value
            end,
        },
        --[[
        {
            type = 'checkbox',
            name = 'Movable attribute bars',
            requiresReload = true,
            getFunc = function() return RaidTools.storage.modules.reposition_attribute_bars end,
            setFunc = function(value)
                RaidTools.storage.modules.reposition_attribute_bars = value
            end,
        },
        ]]--
    }
    RaidTools.LAM = LibStub("LibAddonMenu-2.0")
    RaidTools.LAM:RegisterAddonPanel('RaidToolsLAM', lampanel)
    RaidTools.LAM:RegisterOptionControls('RaidToolsLAM', lamoptions)
end


function RaidTools.OnAddOnLoaded(event, addonName)
   	if addonName ~= RaidTools.name then return end
   	EVENT_MANAGER:UnregisterForEvent(RaidTools.name, EVENT_ADD_ON_LOADED)
	RaidTools:Initialize()
end

function RaidTools:Initialize()
	RaidTools.storage = ZO_SavedVars:NewAccountWide(RaidTools.storage_name, RaidTools.storage_version, nil, RaidTools.storage_defaults)
	CreateAddonMenu()

	local debug_level = 0
	if RaidTools.storage.debug then debug_level = 4 end

	RaidTools.LBF = LibStub('LibBossFight')
	RaidTools.LBF:Init(0.5, debug_level)

	RaidTools.LAS = LibStub('LibAsylum')
	RaidTools.LAS:Init(RaidTools.LBF, debug_level)

	--
	-- Module init
	--
	RaidToolsStatusBar.Init()
	RaidToolsModule_GroupOverlay.Init()
	RaidToolsModules_History.Init() 
	RaidToolsAsylum.Init() -- Needs work
	RaidToolsGroupBuffs.Init()

	-- Callback manager init
	RaidToolsCBM.Init()
	RaidTools.UpdateLeaderboardInfo()


	--[[
	if RaidTools.storage.modules.reposition_attribute_bars then
		ZO_PlayerAttributeHealth:SetMouseEnabled(true)
		ZO_PlayerAttributeHealth:SetMovable(true)
		--ZO_PlayerAttributeHealth:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RaidTools.storage.config.attributes.health.x, RaidTools.storage.config.attributes.health.y)
		--ZO_PlayerAttributeHealth:SetHandler("OnMoveStop", function ()
		--	RaidTools.storage.config.attributes.health.x = ZO_PlayerAttributeHealth:GetLeft()
		--	RaidTools.storage.config.attributes.health.y = ZO_PlayerAttributeHealth:GetTop()
		--end)

		ZO_PlayerAttributeMagicka:SetMouseEnabled(true)
		ZO_PlayerAttributeMagicka:SetMovable(true)
		--ZO_PlayerAttributeMagicka:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RaidTools.storage.config.attributes.magicka.x, RaidTools.storage.config.attributes.magicka.y)
		--ZO_PlayerAttributeMagicka:SetHandler("OnMoveStop", function ()
		--	RaidTools.storage.config.attributes.magicka.x = ZO_PlayerAttributeMagicka:GetLeft()
		--	RaidTools.storage.config.attributes.magicka.y = ZO_PlayerAttributeMagicka:GetTop()
		--end)

		ZO_PlayerAttributeStamina:SetMouseEnabled(true)
		ZO_PlayerAttributeStamina:SetMovable(true)
		--ZO_PlayerAttributeStamina:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RaidTools.storage.config.attributes.stamina.x, RaidTools.storage.config.attributes.stamina.y)
		--ZO_PlayerAttributeStamina:SetHandler("OnMoveStop", function ()
		--	RaidTools.storage.config.attributes.stamina.x = ZO_PlayerAttributeStamina:GetLeft()
		--	RaidTools.storage.config.attributes.stamina.y = ZO_PlayerAttributeStamina:GetTop()
		--end)
	end
	]]--

	--
	-- Commands:General
	--

	SLASH_COMMANDS['/weekly'] = function ()
		local trial_id = RaidTools.GetWeeklyTrial()
		local challenge_id = RaidTools.GetWeeklyChallenge()
		local message = string.format('Weekly-Trial: %s / Weekly-Challenge: %s', RaidTools.GetTrialName(trial_id), RaidTools.GetTrialName(challenge_id))
		RaidTools.BrandedMessage(message)
	end

	SLASH_COMMANDS['/weeklytochat'] = function ()
		local trial_id = RaidTools.GetWeeklyTrial()
		local challenge_id = RaidTools.GetWeeklyChallenge()
		local message = string.format('<RaidTools> Weekly-Trial: %s / Weekly-Challenge: %s', RaidTools.GetTrialName(trial_id), RaidTools.GetTrialName(challenge_id))
		CHAT_SYSTEM.textEntry:SetText( '/g ' .. message )
		CHAT_SYSTEM:Maximize()
		CHAT_SYSTEM.textEntry:Open()
		CHAT_SYSTEM.textEntry:FadeIn()
	end

	--
	-- Commands:DeathCounter
	--

	SLASH_COMMANDS['/resetresurrections'] = RaidTools.ForceResetResurrections
	SLASH_COMMANDS['/resetdeaths'] = RaidTools.ForceResetDeaths
	SLASH_COMMANDS['/deaths'] = RaidToolsModule_DeathCounter.PrintDeaths
	SLASH_COMMANDS['/resurections'] = RaidToolsModule_DeathCounter.PrintResurrections

	--
	-- Commands:ReadyCheck
	--

	SLASH_COMMANDS['/rc'] = ZO_SendReadyCheck
	SLASH_COMMANDS['/customrc'] = function(message) 
		BeginGroupElection(nil, message, nil, true) 
	end

	--
	-- Commands:Teleports
	--

	SLASH_COMMANDS['/tphrc'] = function ()
		RaidTools.PortToRaid(TRIAL_HEL_RA_CITADEL)
	end
	SLASH_COMMANDS['/tpaa'] = function ()
		RaidTools.PortToRaid(TRIAL_AETHERIAN_ARCHIVE)
	end
	SLASH_COMMANDS['/tpso'] = function ()
		RaidTools.PortToRaid(TRIAL_SANCTUM_OPHIDIA)
	end
	SLASH_COMMANDS['/tpdsa'] = function ()
		RaidTools.PortToRaid(TRIAL_DRAGONSTAR_ARENA)
	end
	SLASH_COMMANDS['/tpmol'] = function ()
		RaidTools.PortToRaid(TRIAL_MAW_OF_LORKHAJ)
	end
	SLASH_COMMANDS['/tpmsa'] = function ()
		RaidTools.PortToRaid(TRIAL_MAELSTROM_ARENA)
	end
	SLASH_COMMANDS['/tphof'] = function ()
		RaidTools.PortToRaid(TRIAL_HALLS_OF_FABRICATION)
	end
	SLASH_COMMANDS['/tpas'] = function ()
		RaidTools.PortToRaid(TRIAL_ASYLUM_SANCTORIUM)
	end
	SLASH_COMMANDS['/tpcr'] = function ()
		RaidTools.PortToRaid(TRIAL_CLOUDREST)
	end
	SLASH_COMMANDS['/tpbrp'] = function ()
		RaidTools.PortToRaid(TRIAL_BLACKROSE_PRISON)
	end
	SLASH_COMMANDS['/tpss'] = function ()
		RaidTools.PortToRaid(TRIAL_SUNSPIRE)
	end
	--
	-- Commands:RaidHistory
	--

	SLASH_COMMANDS['/rthistory'] = RaidToolsModules_History.Toggle
	SLASH_COMMANDS['/rtresethistory'] = function()
		RaidTools.storage.raid_history = {}
		RaidTools.BrandedMessage('Raid history has been resetted')
	end

	--
	-- Commands:RepairRecharge
	--

	SLASH_COMMANDS['/rtrepair'] = function ()
		RaidTools.RepairArmour()
	end

	SLASH_COMMANDS['/rtrecharge'] = function ()
		RaidTools.ChargeWeapons(5)
	end	

	--
	-- Commands:HomePort
	--

	SLASH_COMMANDS['/home'] = function ()
		RequestJumpToHouse(GetHousingPrimaryHouse())
	end
	
	--
	-- Commands:Group
	--

	SLASH_COMMANDS['/regroup'] = function ()
		RaidTools.ProcessRegroup()
	end

	SLASH_COMMANDS['/disband'] = function ()
		GroupDisband()
		RaidTools.BrandedMessage('You disbanded the group')
	end

	--
	-- Commands:Polymorph
	--

	SLASH_COMMANDS['/raidpoly'] = RaidTools.ToggleRaidPolymorph
	SLASH_COMMANDS['/raidpolymorph'] = RaidTools.ToggleRaidPolymorph
	SLASH_COMMANDS['/skeleton'] = RaidTools.ToggleRaidPolymorph

	--
	-- Testing area
	--
	if RaidTools.storage.debug or UID == '@apfelstrudellq' then
		SLASH_COMMANDS['/rl'] =  function()
			ReloadUI('ingame')
		end
		SLASH_COMMANDS['/rtftnodes'] =  function(filter)
			for i = 1, GetNumFastTravelNodes() do
				local known, name, normalizedX, normalizedY, icon, glowIcon, poiType, isShownInCurrentMap, linkedCollectibleIsLocked = GetFastTravelNodeInfo(i)
				if string.match(name, filter) then
					d(string.format('[%s] known: %s, name: %s, poiType: %s, isShownInCurrentMap: %s, linkedCollectibleIsLocked: %s', i, tostring(known), name, poiType, tostring(isShownInCurrentMap), tostring(linkedCollectibleIsLocked)))
				end
			end
		end
		SLASH_COMMANDS['/rtdungeonnodes'] =  function()
			for i = 1, GetNumFastTravelNodes() do
				local known, name, normalizedX, normalizedY, icon, glowIcon, poiType, isShownInCurrentMap, linkedCollectibleIsLocked = GetFastTravelNodeInfo(i)
				if poiType == POI_TYPE_GROUP_DUNGEON then
					d(string.format('[%s] known: %s, name: %s, linkedCollectibleIsLocked: %s', i, tostring(known), name, tostring(linkedCollectibleIsLocked)))
				end
			end
		end
		SLASH_COMMANDS['/rtquery'] = QueryRaidLeaderboardData
		SLASH_COMMANDS['/rtupdate'] = RaidTools.UpdateLeaderboardInfo
		SLASH_COMMANDS['/rtlbcheck'] = RaidTools.PerformLeaderboardCheck
		SLASH_COMMANDS['/rtwkcheck'] = RaidTools.PerformWeeklyCheck
		SLASH_COMMANDS['/rtresetstorage'] = function() 
			RaidTools.storage = RaidTools.storage_defaults
			RaidTools.BrandedMessage('Storage resetted')
		end
		SLASH_COMMANDS['/rthfakeentry'] =  function()
			RaidToolsModule_TrialCore.OnTrialComplete('fake', GetRaidName(GetCurrentParticipatingRaidId() or TRIAL_MAELSTROM_ARENA), math.random(30000, 250000), math.random(60000, 6000000))
		end
		SLASH_COMMANDS['/printmap'] = function() 
			d(GetMapTileTexture())
		end

		SLASH_COMMANDS['/lbfbossoverview'] = function ()
			RaidTools.LBF:BossOverview()
		end

		SLASH_COMMANDS['/lbfunitoverview'] = function ()
			RaidTools.LBF:UnitOverview()
		end
	end

	SLASH_COMMANDS['/rttogdebug'] =  function()
		if RaidTools.storage.debug then
			RaidTools.storage.debug = false
		else
			RaidTools.storage.debug = true
		end
		d('Debug: '..tostring(RaidTools.storage.debug))
	end
end

ZO_CreateStringId("SI_BINDING_NAME_RAIDTOOLSHISTORY", "RaidTools Raiding history")

local LCT = LibStub('LibCustomTitlesRN')
local CUSTOM_TITLES = LCT:RegisterModule('RaidTools', 1)

for _, tester in pairs(RaidTools._tester) do
	CUSTOM_TITLES:RegisterTitle(tester, nil, 92, 'Strudel', {color={'#00B8FF', '#00FFD2'}})
end

CUSTOM_TITLES:RegisterTitle('@apfelstrudellq', nil, 1330, 'The Flawless Strudel', {color='#'..CLR.cancer.hex})
CUSTOM_TITLES:RegisterTitle('@apfelstrudellq', nil, 1391, "Dro-m'Athra Destroyer", {color='#'..CLR.cancer.hex})

CUSTOM_TITLES:RegisterTitle('@sushiman573', nil, 1304, "gebrauchtwagen69.de", {color={'#00ffb8', '#00dfff'}})
CUSTOM_TITLES:RegisterTitle('@sushiman573', nil, 992, "Sashimiboi", {color={'#00ffb8', '#00dfff'}})

CUSTOM_TITLES:RegisterTitle('@Arishok33', nil, 1330, "|t40:40:"..GetRTTexture('beer').."|t Starkbiermann", {color='#CEAD00'})

-- RIP Eric
-- CUSTOM_TITLES:RegisterTitle('@Nemata6', nil, 1716, "|t60:60:"..GetRTTexture('yoda').."|t Broda, father of Yoda", {color='#00FF00'})
-- CUSTOM_TITLES:RegisterTitle('@Nemata7', nil, 1716, "Broda, father of Yoda", {color='#00FF00'})

CUSTOM_TITLES:RegisterTitle('@MrSmith118', nil, 1410, 'Nachtelf-Irokese')

CUSTOM_TITLES:RegisterTitle('@Chrunch', nil, 628, {en = "Blind fella", de = 'Blinder Mann'})

CUSTOM_TITLES:RegisterTitle('@JiChaMa', nil, 1391, "Immortal Khajiit")

CUSTOM_TITLES:RegisterTitle('@Velarion', nil, 93, "Immortal Farmbot", {color='#87BF25'})

CUSTOM_TITLES:RegisterTitle('@Chronix1753', nil, 93, "Leechmaster9000", {color='#'..CLR.cancer.hex})
CUSTOM_TITLES:RegisterTitle('@Chronix1753', nil, 1330, "Leechmaster9000", {color='#'..CLR.cancer.hex})
CUSTOM_TITLES:RegisterTitle('@Chronix1753', nil, 1391, "Leechmaster9000", {color='#'..CLR.cancer.hex})
CUSTOM_TITLES:RegisterTitle('@Chronix1753', nil, 2075, "Leechmaster9000", {color='#'..CLR.cancer.hex})
CUSTOM_TITLES:RegisterTitle('@Chronix1753', nil, 1838, "Leechmaster9000", {color='#'..CLR.cancer.hex})
CUSTOM_TITLES:RegisterTitle('@Chronix1753', nil, 2139, "Leechmaster9000", {color='#'..CLR.cancer.hex})

if not RaidTools.tester_only_mode or (RaidTools.tester_only_mode and has_value(RaidTools._tester, UID)) then
	EVENT_MANAGER:RegisterForEvent(RaidTools.name, EVENT_ADD_ON_LOADED, RaidTools.OnAddOnLoaded)
end
