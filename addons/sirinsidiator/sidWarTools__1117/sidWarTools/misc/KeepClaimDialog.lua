local function Initialize(saveData)
	if(saveData.keepClaimFilterAlliance) then
		KEEP_CLAIM_DIALOG:SetGuildFilter(function(guildId)
			return DoesPlayerHaveGuildPermission(guildId, GUILD_PERMISSION_CLAIM_AVA_RESOURCE) and GetGuildAlliance(guildId) == GetUnitAlliance("player")
		end)
	end

	if(saveData.keepClaimUpdateTimerFix) then
		local updateKeepClaimDialogRegistered = false
		local updateKeepClaimDialogHandle = "sidWarToolsUpdateKeepClaimDialog"
		local updateKeepClaimDialogInterval = 500 --ms
		ZO_PreHook(KEEP_CLAIM_DIALOG.control, "SetHidden", function(self, hidden)
			if(hidden) then
				if(updateKeepClaimDialogRegistered) then
					updateKeepClaimDialogRegistered = false
					EVENT_MANAGER:UnregisterForUpdate(updateKeepClaimDialogHandle)
				end
			else
				if(not updateKeepClaimDialogRegistered) then
					updateKeepClaimDialogRegistered = true
					EVENT_MANAGER:RegisterForUpdate(updateKeepClaimDialogHandle, updateKeepClaimDialogInterval, function(time)
						KEEP_CLAIM_DIALOG:OnUpdate(time)
					end)
				end
			end
		end)
	end
end

sidWarTools.InitializeKeepClaimDialogFixes = Initialize
