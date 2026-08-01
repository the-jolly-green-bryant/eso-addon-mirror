-- Create namespace
DsRVersionDefaults = {}
local DsRVersionDefaults = DsRVersionDefaults  or {}

DsRVersionDefaults.name = "DsRVersionDefaults"

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRVersionDefaults:Defaults()
    local VersionDefaults = {
			UV       = "2000.01.01",
			Show     = true,
		}

    local NewsDefaults = {
			NV 			  = "01.01.2025",
			NewsShow      = true,
			NewsShowOnOff = true,
		}

    local WaechterDefaults = {
			WachtLogin    = {
				["@Hasenwarrior"] = 0,
				["@PettiPuuh"] = 0,
				["@flo1980"] = 0,
				["@Siraa"] = 0,
				["@Sisiktil"] = 0,
				["@Prof_Flausch"] = 0,
				["@Ravnic93"] = 0,
				["@Magnolyon"] = 0,
			},
		}
	
	DsRVersion.UpdateVersion = ZO_SavedVars:NewAccountWide("DsRGuildRosterUpdateVersion", 1, nil, VersionDefaults)
	DsRVersion.NewsVersion   = ZO_SavedVars:NewAccountWide("DsRGuildRosterUpdateVersion", 1, nil, NewsDefaults)
	DsRVersion.Waechter      = ZO_SavedVars:NewAccountWide("DsRGuildRosterUpdateVersion", 1, nil, WaechterDefaults)
end
