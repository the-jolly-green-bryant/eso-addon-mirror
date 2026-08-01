--[[
Addon:    DuelRPG - Gestion avancée des combats JDR
Author:   @neferys
File:     DuelRPG.lua
]]--

-- Local variables
local str = DuelRPG.Strings[DuelRPG.GetLanguage()].TEXT
local com = DuelRPG.Strings[DuelRPG.GetLanguage()].COMMANDS
local _

-- DuelRPG Declaration
if DuelRPG == nil then DuelRPG = {} end

--
-- Register with LibMenu and ESO
--
function DuelRPG.MakeMenu()
    -- load the settings->addons menu library
	local menu = LibStub("LibAddonMenu-2.0")
	local set = DuelRPG.settings
	
	local panel = {
	  type = "panel",
	  name = "DuelRPG",
	  displayName = "DuelRPG",
	  author = "Neferys",
	  slashCommand = "/drpg",
	  version = DuelRPG.version,
	  registerForRefresh = true,
	}

	local optionsData = {}
	table.insert(optionsData, {
		type = "submenu",
		name = "|cCAB222"..str.strlife.."|r",
		controls = {
				[1] =  {
				type = "slider",
				name = str.strlife,
				min = -10,
				max = 33,
				step = 1,
				getFunc = function() return DuelRPG.GetLife() end,
				setFunc = function(value) end,
				width="full",
				disabled = true,
			},
				[2] =  {
				type = "description",
				text = str.strlifetips,
				width = "full"
			},
				[3] =  {
				type = "slider",
				name = "Total "..str.strend,
				min = 6,
				max = 19,
				step = 1,
				getFunc = function() return DuelRPG.GetAttrEndPerso() end,
				setFunc = function(value) end,
				width="full",
				disabled = true,
			},
				[4] =  {
				type = "slider",
				name = str.strendmodifier,
				min = -4,
				max = 4,
				step = 1,
				getFunc = function() return DuelRPG.GetMultiEndPerso() end,
				setFunc = function(value) end,
				width="full",
				disabled = true,
			},
		}
	})	
	table.insert(optionsData, {
		type = "submenu",
		name = "|cCAB222"..str.strca.."|r",
		controls = {
				[1] =  {
				type = "slider",
				name = str.strca,
				min = 0,
				max = 20,
				step = 1,
				tooltip = str.strarmordesc,
				getFunc = function() return DuelRPG.GetTotArmor() end,
				setFunc = function(value) end,
				width="full",
				disabled = true,
			},
				[2] =  {
				type = "slider",
				name = str.strrapmulti,
				min = 0,
				max = 4,
				step = 1,
				tooltip = "Le multiplicateur d'agilité est de 2 maximum pour une armure intermédiaire, 0 pour une armure lourde. Un multiplicateur d'agilité négatif ne s'applique pas au CA.",
				getFunc = function() return DuelRPG.GetMultiArmor() end,
				setFunc = function(value) end,
				width="full",
				disabled = true,
			},
				[3] =  {
				type = "slider",
				name = str.strarmor,
				min = 0,
				max = 8,
				step = 1,
				tooltip = "Le bonus d'armure est lié à la pièce de torse équipé par le personnage.",
				getFunc = function() return DuelRPG.CAN_RESEARCH_COMBATS_OPTIONS_ARMOR[DuelRPG.GetArmor()].defearmor + DuelRPG.CAN_RESEARCH_COMBATS_OPTIONS_WEAPON[DuelRPG.GetMainWeapon()].armoweapon + DuelRPG.CAN_RESEARCH_COMBATS_OPTIONS_WEAPON[DuelRPG.GetOffWeapon()].armoweapon end,
				setFunc = function(value) end,
				width="full",
				disabled = true,
			},
		}
	})	
	table.insert(optionsData, {
		type = "submenu",
		name = "|cCAB222"..str.strlvl.."|r",
		controls = {
				[1] =  {
				type = "slider",
				name = str.strlvl,
				min = 1,
				max = 10,
				step = 1,
				tooltip = str.strlvldesc,
				getFunc = function() return set.level end,
				setFunc = function(value)
					DuelRPG.Updatelevel(value)
				end,
				width="full",
			},
				[2] =  {
				type = "description",
				text = "Le niveau du personnage correspond à son expérience en combat. Le niveau choisi doit être validé par le MJ. Un niveau supplémentaire ajoute 1 point d'attribut supplémentaire.\nL'ajout ou la suppression d'un niveau réinitialise les attributs.",
				width = "full"
			},
		}
	})	
	table.insert(optionsData, {
		type = "submenu",
		name = "|cCAB222"..str.stratb.."|r",
		controls = {
				[1] =  {
				type = "description",
				text = str.strraceattrb.." ("..DuelRPG.GetRace()..") : "..str.strcac.." : "..DuelRPG.GetAttrCacRace()..", "..str.strdex.." : "..DuelRPG.GetAttrDisRace()..", "..str.strmag.." : "..DuelRPG.GetAttrMagRace()..", "..str.strrap.." : "..DuelRPG.GetAttrDexRace()..", "..str.strend.." : "..DuelRPG.GetAttrEndRace(),
				width = "full"
			},
				[2] =  {
				type = "editbox",
				name = str.strpointsdispo,
				tooltip = str.strpointsdispotips,
				getFunc = function() return DuelRPG.GetValAttr() end,
				setFunc = function(value) end,
				disabled = true,
			},
				[3] =  {
				type = "slider",
				name = str.strcac,
				min = 7,
				max = 18,
				step = 1,
				tooltip = str.strcacdesc,
				getFunc = function() return DuelRPG.settings.cacperso+10 end,
				setFunc = function(value) end,
				width="full",
				disabled = true,
			},
				[4] =  {
				type = "button",
				name = str.straddpoint,
				width = "half",
				func = function()
					DuelRPG.AddAttr("cac")				
				end,
			},
				[5] =  {
				type = "button",
				name = str.strdelpoint,
				width = "half",
				func = function()
					DuelRPG.DelAttr("cac")			
				end,
			},
				[6] =  {	
				type = "slider",
				name = str.strdex,
				min = 7,
				max = 18,
				step = 1,
				tooltip = str.strdexdesc,
				getFunc = function() return DuelRPG.settings.disperso+10 end,
				setFunc = function(value) end,
				width="full",
				disabled = true,
			},
				[7] =  {
				type = "button",
				name = str.straddpoint,
				width = "half",
				func = function()
					DuelRPG.AddAttr("dis")					
				end,
			},
				[8] =  {
				type = "button",
				name = str.strdelpoint,
				width = "half",
				func = function()
					DuelRPG.DelAttr("dis")					
				end,
			},
				[9] =  {
				type = "slider",
				name = str.strmag,
				min = 7,
				max = 18,
				step = 1,
				tooltip = str.strmagdesc,
				getFunc = function() return DuelRPG.settings.magperso+10 end,
				setFunc = function(value) end,
				width="full",
				disabled = true,
			},
				[10] =  {
				type = "button",
				name = str.straddpoint,
				width = "half",
				func = function()
					DuelRPG.AddAttr("mag")					
				end,
			},
				[11] =  {
				type = "button",
				name = str.strdelpoint,
				width = "half",
				func = function()
					DuelRPG.DelAttr("mag")					
				end,
			},
				[12] =  {
				type = "slider",
				name = str.strrap,
				min = 7,
				max = 18,
				step = 1,
				tooltip = "La rapidité influence le jet d'initiative. L'initiative détermine l'ordre des tours pendant le combat. Quand le combat commence, chaque participant fait un jet de d'initiative pour déterminer sa place dans l'ordre d'initiative.",
				getFunc = function() return DuelRPG.settings.dexperso+10 end,
				setFunc = function(value) end,
				width="full",
				disabled = true,
			},
				[13] =  {
				type = "button",
				name = str.straddpoint,
				width = "half",
				func = function()
					DuelRPG.AddAttr("dex")				
				end
			},
				[14] =  {
				type = "button",
				name = str.strdelpoint,
				width = "half",
				func = function()
					DuelRPG.DelAttr("dex")				
				end,
			},
				[15] =  {
				type = "slider",
				name = str.strend,
				min = 7,
				max = 18,
				step = 1,
				tooltip = str.strconst,
				getFunc = function() return DuelRPG.settings.endperso+10 end,
				setFunc = function(value) end,
				width="full",
				disabled = true,
			},
				[16] =  {
				type = "button",
				name = str.straddpoint,
				width = "half",
				func = function()
					DuelRPG.AddAttr("end")				
				end,
			},
				[17] =  {
				type = "button",
				name = str.strdelpoint,
				width = "half",
				func = function()
					DuelRPG.DelAttr("end")					
				end,
			},
		}
	})	
	table.insert(optionsData, {
		type = "submenu",
		name = "|cCAB222"..com.strcommand.."|r",
		controls = {
				[1] =  {
				type = "editbox",
				name = com.strdrpginfo,
				tooltip = "Ex : /"..set.drpginfo,
				getFunc = function() return set.drpginfo end,
				setFunc = function(value) set.drpginfo = value end,
				warning = com.strtooltips,
				},
				[2] =  {
				type = "header",
				name = com.stropponents
				},	
				[3] =  {
				type = "editbox",
				name = com.strdrpgaddchar,
				tooltip = "Ex : /"..set.drpgaddchar.." Bob",
				getFunc = function() return set.drpgaddchar end,
				setFunc = function(value) set.drpgaddchar = value end,
				warning = com.strtooltips,
				},
				[4] =  {
				type = "editbox",
				name = com.strdrpgaddcharca,
				tooltip = "Ex : /"..set.drpgaddcharca.." 8",
				getFunc = function() return set.drpgaddcharca end,
				setFunc = function(value) set.drpgaddcharca = value end,
				warning = com.strtooltips,
				},
				[5] =  {
				type = "editbox",
				name = com.strdrpgdelchar,
				tooltip = "Ex : /"..set.drpgdelchar,
				getFunc = function() return set.drpgdelchar end,
				setFunc = function(value) set.drpgdelchar = value end,
				warning = com.strtooltips,
				},
				[6] =  {
				type = "header",
				name = com.strdrpginit
				},	
				[7] =  {
				type = "editbox",
				name = com.strdrpginit,
				tooltip = "Ex : /"..set.drpginit,
				getFunc = function() return set.drpginit end,
				setFunc = function(value) set.drpginit = value end,
				warning = com.strtooltips,
				},
				[8] =  {
				type = "header",
				name = com.strattacks
				},	
				[9] =  {
				type = "editbox",
				name = com.strdrpgcac,
				tooltip = "Ex : /"..set.drpgcac.." Bob "..com.stroptionnel,
				getFunc = function() return set.drpgcac end,
				setFunc = function(value) set.drpgcac = value end,
				warning = com.strtooltips,
				},
				[10] =  {
				type = "editbox",
				name = com.strdrpgdist,
				tooltip = "Ex : /"..set.drpgdist.." Bob "..com.stroptionnel,
				getFunc = function() return set.drpgdist end,
				setFunc = function(value) set.drpgdist = value end,
				warning = com.strtooltips,
				},
				[11] =  {
				type = "editbox",
				name = com.strdrpgmagie,
				tooltip = "Ex : /"..set.drpgmagie.." Bob "..com.stroptionnel,
				getFunc = function() return set.drpgmagie end,
				setFunc = function(value) set.drpgmagie = value end,
				warning = com.strtooltips,
				},
				[12] =  {
				type = "header",
				name = com.strdrpgdegat
				},	
				[13] =  {
				type = "editbox",
				name = com.strdrpgdegat,
				tooltip = "Ex : /"..set.drpgdegat.." 8",
				getFunc = function() return set.drpgdegat end,
				setFunc = function(value) set.drpgdegat = value end,
				warning = com.strtooltips,
			},
		}
	})
	
	menu:RegisterAddonPanel(DuelRPG.name .."_OptionsPanel", panel)
	menu:RegisterOptionControls(DuelRPG.name .."_OptionsPanel", optionsData)
end