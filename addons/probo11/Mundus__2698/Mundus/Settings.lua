function Mundus.CreateSettingsWindow(mundusStones, ADDON_AUTHOR, ADDON_VERSION)
	local LAM = LibAddonMenu2
	local sKA, eKA = string.find(GetRaidName(13), "%(")
	if sKA ~= nil then
		sKA = sKA - 1
	end
	local panelData = {
		type = "panel",
		name = Mundus.Name,
		author = ADDON_AUTHOR,
		version = ADDON_VERSION
	}
	local cntrlOptionsPanel = LAM:RegisterAddonPanel("MundusPanel", panelData)
	
	local optionsData = {
		[1] = {
			type = "header",
			name = "PVP"
		},
		[2] = {
			type = "dropdown",
			name = ZO_CachedStrFormat("<<C:1>>", GetZoneNameById(181)),
			tooltip = "Set the correct mundus stone for Cyrodiil",
			default = Mundus.savedVariables.Cyro,
			warning = "Will need to reload the UI.",
			choices = mundusStones,
			getFunc = function() return Mundus.GetMundusName(Mundus.savedVariables.Cyro) end,
			setFunc = function(newValue) Mundus.savedVariables.Cyro = Mundus.GetId(newValue) end
		},
		[3] = {
			type = "dropdown",
			name = ZO_CachedStrFormat("<<C:1>>", GetZoneNameById(584)),
			tooltip = "Set the correct mundus stone for Imperial City",
			default = Mundus.savedVariables.IC,
			warning = "Will need to reload the UI.",
			choices = mundusStones,
			getFunc = function() return Mundus.GetMundusName(Mundus.savedVariables.IC) end,
			setFunc = function(newValue) Mundus.savedVariables.IC = Mundus.GetId(newValue) end
		},
		[4] = {
			type = "header",
			name = "PVE"
		},
		[5] = {
			type = "dropdown",
			name = "Dungeons",
			tooltip = "Set the correct mundus stone for PVE",
			default = Mundus.savedVariables.PVE,
			warning = "Will need to reload the UI.",
			choices = mundusStones,
			getFunc = function() return Mundus.GetMundusName(Mundus.savedVariables.PVE) end,
			setFunc = function(newValue) Mundus.savedVariables.PVE = Mundus.GetId(newValue) end
		},
		[6] = {
			type = "dropdown",
			name = ZO_CachedStrFormat("<<C:1>>", GetZoneNameById(677)),
			tooltip = "Set the correct mundus stone for Maelstrom Arena",
			default = Mundus.savedVariables.MA,
			warning = "Will need to reload the UI.",
			choices = mundusStones,
			getFunc = function() return Mundus.GetMundusName(Mundus.savedVariables.MA) end,
			setFunc = function(newValue) Mundus.savedVariables.MA = Mundus.GetId(newValue) end
		},
		[7] = {
			type = "dropdown",
			name = ZO_CachedStrFormat("<<C:1>>", GetZoneNameById(1082)),
			tooltip = "Set the correct mundus stone for Blackrose Prison",
			default = Mundus.savedVariables.BRP,
			warning = "Will need to reload the UI.",
			choices = mundusStones,
			getFunc = function() return Mundus.GetMundusName(Mundus.savedVariables.BRP) end,
			setFunc = function(newValue) Mundus.savedVariables.BRP = Mundus.GetId(newValue) end
		},
        [8] = {
			type = "dropdown",
			name = ZO_CachedStrFormat("<<C:1>>", GetZoneNameById(1227)),
			tooltip = "Set the correct mundus stone for Vateshran Hollows",
			default = Mundus.savedVariables.VH,
			warning = "Will need to reload the UI.",
			choices = mundusStones,
			getFunc = function() return Mundus.GetMundusName(Mundus.savedVariables.VH) end,
			setFunc = function(newValue) Mundus.savedVariables.VH = Mundus.GetId(newValue) end
		},
		[9] = {
			type = "submenu",
			name = "Trials",
			tooltip = "Ignore if you don't want to use different mundus stones in trials",
			controls = {
				[1] = {
					type = "dropdown",
					name = ZO_CachedStrFormat("<<C:1>>", GetZoneNameById(638)),
					tooltip = "Set the correct mundus stone for Aetherian Archive",
					default = Mundus.savedVariables.Trial_AA,
					warning = "Will need to reload the UI.",
					choices = mundusStones,
					getFunc = function() return Mundus.GetMundusName(Mundus.savedVariables.Trial_AA) end,
					setFunc = function(newValue) Mundus.savedVariables.Trial_AA = Mundus.GetId(newValue) end
				},
				[2] = {
					type = "dropdown",
					name = ZO_CachedStrFormat("<<C:1>>", GetZoneNameById(1000)),
					tooltip = "Set the correct mundus stone for Asylum Sanctorium",
					default = Mundus.savedVariables.Trial_AS,
					warning = "Will need to reload the UI.",
					choices = mundusStones,
					getFunc = function() return Mundus.GetMundusName(Mundus.savedVariables.Trial_AS) end,
					setFunc = function(newValue) Mundus.savedVariables.Trial_AS = Mundus.GetId(newValue) end
				},
				[3] = {
					type = "dropdown",
					name = ZO_CachedStrFormat("<<C:1>>", GetZoneNameById(1051)),
					tooltip = "Set the correct mundus stone for Cloudrest",
					default = Mundus.savedVariables.Trial_CR,
					warning = "Will need to reload the UI.",
					choices = mundusStones,
					getFunc = function() return Mundus.GetMundusName(Mundus.savedVariables.Trial_CR) end,
					setFunc = function(newValue) Mundus.savedVariables.Trial_CR = Mundus.GetId(newValue) end
				},
				[4] = {
					type = "dropdown",
					name = ZO_CachedStrFormat("<<C:1>>", GetZoneNameById(1344)),
					tooltip = "Set the correct mundus stone for Dreadsail Reef",
					default = Mundus.savedVariables.Trial_DSR,
					warning = "Will need to reload the UI.",
					choices = mundusStones,
					getFunc = function() return Mundus.GetMundusName(Mundus.savedVariables.Trial_DSR) end,
					setFunc = function(newValue) Mundus.savedVariables.Trial_DSR = Mundus.GetId(newValue) end
				},
				[5] = {
					type = "dropdown",
					name = ZO_CachedStrFormat("<<C:1>>", GetZoneNameById(975)),
					tooltip = "Set the correct mundus stone for Halls of Fabrication",
					default = Mundus.savedVariables.Trial_HOF,
					warning = "Will need to reload the UI.",
					choices = mundusStones,
					getFunc = function() return Mundus.GetMundusName(Mundus.savedVariables.Trial_HOF) end,
					setFunc = function(newValue) Mundus.savedVariables.Trial_HOF = Mundus.GetId(newValue) end
				},
				[6] = {
					type = "dropdown",
					name = ZO_CachedStrFormat("<<C:1>>", GetZoneNameById(636)),
					tooltip = "Set the correct mundus stone for Hel Ra Citadel",
					default = Mundus.savedVariables.Trial_HRC,
					warning = "Will need to reload the UI.",
					choices = mundusStones,
					getFunc = function() return Mundus.GetMundusName(Mundus.savedVariables.Trial_HRC) end,
					setFunc = function(newValue) Mundus.savedVariables.Trial_HRC = Mundus.GetId(newValue) end
				},
				[7] = {
					type = "dropdown",
					name = ZO_CachedStrFormat("<<C:1>>", string.sub(GetRaidName(13), 1 , sKA)),
					tooltip = "Set the correct mundus stone for Kyne's Aegis",
					default = Mundus.savedVariables.Trial_KA,
					warning = "Will need to reload the UI.",
					choices = mundusStones,
					getFunc = function() return Mundus.GetMundusName(Mundus.savedVariables.Trial_KA) end,
					setFunc = function(newValue) Mundus.savedVariables.Trial_KA = Mundus.GetId(newValue) end
				},
				[8] = {
					type = "dropdown",
					name = ZO_CachedStrFormat("<<C:1>>", GetZoneNameById(1263)),
					tooltip = "Set the correct mundus stone for Rockgrove",
					default = Mundus.savedVariables.Trial_RG,
					warning = "Will need to reload the UI.",
					choices = mundusStones,
					getFunc = function() return Mundus.GetMundusName(Mundus.savedVariables.Trial_RG) end,
					setFunc = function(newValue) Mundus.savedVariables.Trial_RG = Mundus.GetId(newValue) end
				},
				[9] = {
					type = "dropdown",
					name = ZO_CachedStrFormat("<<C:1>>", GetZoneNameById(639)),
					tooltip = "Set the correct mundus stone for Sanctum Ophidia",
					default = Mundus.savedVariables.Trial_SO,
					warning = "Will need to reload the UI.",
					choices = mundusStones,
					getFunc = function() return Mundus.GetMundusName(Mundus.savedVariables.Trial_SO) end,
					setFunc = function(newValue) Mundus.savedVariables.Trial_SO = Mundus.GetId(newValue) end
				},
				[10] = {
					type = "dropdown",
					name = ZO_CachedStrFormat("<<C:1>>", GetZoneNameById(1121)),
					tooltip = "Set the correct mundus stone for Sunspire",
					default = Mundus.savedVariables.Trial_SS,
					warning = "Will need to reload the UI.",
					choices = mundusStones,
					getFunc = function() return Mundus.GetMundusName(Mundus.savedVariables.Trial_SS) end,
					setFunc = function(newValue) Mundus.savedVariables.Trial_SS = Mundus.GetId(newValue) end
				},
			},
		},
		[11] = {
			type = "button",
			name = "Remove message",
			tooltip = "This will remove that annoying message in the middle of the screen",
			func = function() MundusIndicator:SetHidden(true) end
		},
		[12] = {
			type = "button",
			name = "ReloadUI",
			func = function() ReloadUI() end
		}	
	}
	LAM:RegisterOptionControls("MundusPanel", optionsData)
end
