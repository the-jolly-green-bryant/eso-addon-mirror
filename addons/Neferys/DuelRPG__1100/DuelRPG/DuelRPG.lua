--[[
Addon:    DuelRPG - Gestion avancée des combats JDR
Author:   @neferys
File:     DuelRPG.lua
]]--

-- Local variables
local em = GetEventManager()
local str = DuelRPG.Strings[DuelRPG.GetLanguage()].TEXT
local com = DuelRPG.Strings[DuelRPG.GetLanguage()].COMMANDS
local _

-- DuelRPG Declaration
if DuelRPG == nil then DuelRPG = {} end

-- The AddOn name
DuelRPG.name = "DuelRPG"
DuelRPG.version = "0.6d"

DuelRPG.settings = {}

-- default values for saved variables
DuelRPG.defaults = {
	oldversion = "0.5",
	drpginfo = "drpginfo",
	drpgaddchar = "drpgaddchar",
	drpgaddcharca = "drpgaddcharca",
	drpgdelchar = "drpgdelchar",
	drpginit = "drpginit",
	drpgcac = "drpgcac",
	drpgdist = "drpgdist",
	drpgmagie = "drpgmagie",
	drpgdegat = "drpgdegat",	
	cacperso = 0,
	disperso = 0,
	dexperso = 0,
	magperso = 0,
	endperso = 0,
	level = 1,
	lifem = 0,
	timestamp = GetTimeStamp()
}

-- Init des commandes
function DuelRPG.SetCommands()
	SLASH_COMMANDS["/".. DuelRPG.settings.drpginfo]  = DuelRPG.drpginfo
	SLASH_COMMANDS["/".. DuelRPG.settings.drpgaddchar]  = DuelRPG.drpgaddchar
	SLASH_COMMANDS["/".. DuelRPG.settings.drpgaddcharca]  = DuelRPG.drpgaddcharca
	SLASH_COMMANDS["/".. DuelRPG.settings.drpgdelchar]  = DuelRPG.drpgdelchar
	SLASH_COMMANDS["/".. DuelRPG.settings.drpginit]  = DuelRPG.drpginit
	SLASH_COMMANDS["/".. DuelRPG.settings.drpgcac] = DuelRPG.drpgcac
	SLASH_COMMANDS["/".. DuelRPG.settings.drpgdist] = DuelRPG.drpgdist
	SLASH_COMMANDS["/".. DuelRPG.settings.drpgmagie] = DuelRPG.drpgmagie
	SLASH_COMMANDS["/".. DuelRPG.settings.drpgdegat] = DuelRPG.drpgdegat
	SLASH_COMMANDS["/drpgh"] = DuelRPG.ShowHelp
end

function DuelRPG.ShowHelp()

  d( "DuelRPG - Gestion avancée des combats JDR ".. DuelRPG.version  )
  d( "--"..com.strcommand.." : " )
  d( "    /".. DuelRPG.settings.drpginfo.. "					--"..com.strdrpginfo)
  d( "    /".. DuelRPG.settings.drpgaddchar.." [Personnage]		-- Enregistrement du nom de l'adversaire")
  d( "    /".. DuelRPG.settings.drpgaddcharca.." [CA]			-- Enregistrement du CA de l'adversaire")
  d( "    /".. DuelRPG.settings.drpgdelchar.." 					-- Nettoyage des adversaires")
  d( "    /".. DuelRPG.settings.drpginit.. "					-- Lancement du jet d'initiative" )
  d( "    /".. DuelRPG.settings.drpgcac.. " 					-- Lancement du jet d'attaque au corps à corps" )
  d( "    /".. DuelRPG.settings.drpgdist.. " 					-- Lancement du jet d'attaque à distance" )
  d( "    /".. DuelRPG.settings.drpgmagie.. " 					-- Lancement du jet d'attaque magique" )
  d( "    /".. DuelRPG.settings.drpgdegat.. " [vie perdue]     	-- Commande de retrait de point de vie" )
  d( "    /drpgh                       							-- Afficher l'aide.")
    
end

--
-- Initialization of DuelRPG
--
function DuelRPG.Initialize(event, addon)

	if addon ~= DuelRPG.name then return end

	em:UnregisterForEvent(DuelRPG.name, EVENT_ADD_ON_LOADED)

	-- load our saved variables
	DuelRPG.settings = ZO_SavedVars:New("DuelRPG_Settings", 1, nil, DuelRPG.defaults)
		
	-- Commands
	DuelRPG.SetCommands()	
	
	em:RegisterForEvent( DuelRPG.name, EVENT_PLAYER_ACTIVATED, function() 		
		d(str.strprefix..str.strwelcome..DuelRPG.version..str.strwelcometips)

		if not (DuelRPG.settings.oldversion == DuelRPG.version) then
		
			DuelRPG.Reset()
			DuelRPG.settings.oldversion = DuelRPG.version
			d(str.strprefix..str.strreset)
			
		end
		
		-- make options menu
		DuelRPG.MakeMenu()		
		DuelRPG.Checkatb()
			
		em:UnregisterForEvent( DuelRPG.name, EVENT_PLAYER_ACTIVATED )
	end)
		
	em:RegisterForEvent(DuelRPG.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, DuelRPG.OnItemSlotChanged)
		
	-- Regain Life Function
	em:RegisterForUpdate(DuelRPG.name, 5000, function () DuelRPG.drpgregain() end)
	
end

-- Initialization
em:RegisterForEvent(DuelRPG.name, EVENT_ADD_ON_LOADED, function(...) DuelRPG.Initialize(...) end)