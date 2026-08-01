local NAME = "CompanionRapportInfo"

EVENT_MANAGER:RegisterForEvent(NAME, EVENT_ADD_ON_LOADED, function( eventCode, addonName )
	if (addonName ~= NAME) then return end
	EVENT_MANAGER:UnregisterForEvent(NAME, EVENT_ADD_ON_LOADED)

	local maxRapport = GetMaximumRapport()

	-- Modify companion UI
	SecurePostHook(COMPANION_OVERVIEW_KEYBOARD, "RefreshCompanionRapport", function( self )
		local control = self.rapportStatusLabel
		if (control) then
			control:SetText(string.format("%s (%d/%d)", control:GetText(), GetActiveCompanionRapport(), maxRapport))
		end
	end)

	-- Chat notifications of rapport changes
	EVENT_MANAGER:RegisterForEvent(NAME, EVENT_COMPANION_RAPPORT_UPDATE, function( eventCode, companionId, previousRapport, currentRapport )
		CHAT_ROUTER:AddSystemMessage(zo_strformat(
			"<<1>> <<2>>: <<3>> <<4>>",
			os.date("[%H:%M:%S]", GetTimeStamp()),
			GetString(SI_COMPANION_OVERVIEW_RAPPORT),
			GetCompanionName(companionId),
			string.format("%+d (%d/%d)", currentRapport - previousRapport, currentRapport, maxRapport)
		))
	end)
end)
