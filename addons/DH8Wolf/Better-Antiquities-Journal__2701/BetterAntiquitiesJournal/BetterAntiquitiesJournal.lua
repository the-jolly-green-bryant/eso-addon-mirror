BetterAntiquitiesJournal = {}
BetterAntiquitiesJournal.name = "BetterAntiquitiesJournal"

function BetterAntiquitiesJournal:Initialize()
	ZO_PostHook(
		ZO_AntiquityTile_Keyboard,
		'Initialize',
		function(self, control)
			self.hasLead = CreateControlFromVirtual(self.header:GetName() .. "HasLead", self.header, "ZO_AntiquityLabel_Keyboard")
			self.hasLead:SetAnchor(TOPLEFT, self.antiquityType, BOTTOMLEFT)
		end
	)

	ZO_PostHook(
		ZO_AntiquityTile_Keyboard,
		'Refresh',
		function(self)
			if self.tileData:HasDiscovered() then
			
				local hasLead = "No"
				if not self.tileData:RequiresLead() or self.tileData:HasLead() then
					local _, leadTimeRemaining = self.tileData:GetLeadExpirationStatus()
					if leadTimeRemaining ~= nil then
						hasLead = leadTimeRemaining
					else
						hasLead = "Yes"
					end
				end
				
				if self.tileData:HasRecovered() then
					self.hasLead:SetColor(ZO_NORMAL_TEXT:UnpackRGB())
				else
					self.hasLead:SetColor(ZO_DISABLED_TEXT:UnpackRGB())
				end
				
				hasLead = ZO_SELECTED_TEXT:Colorize(hasLead)
				
				self.hasLead:SetText(zo_strformat("Lead: <<1>>", hasLead))
				self.hasLead:SetHidden(false)
			else
				self.hasLead:SetHidden(true)
			end
		end
	)

	ZO_PostHook(
		ZO_ScryableAntiquityTile_Keyboard,
		'Refresh',
		function(self)
			self.progressIcons:ClearAnchors()
			local _, leadTimeRemaining = self.tileData:GetLeadExpirationStatus()
			if self.tileData:RequiresLead() and leadTimeRemaining ~= nil then
				local expirationText = zo_strformat(SI_ANTIQUITY_TOOLTIP_LEAD_EXPIRATION, ZO_SELECTED_TEXT:Colorize(leadTimeRemaining))
				self.leadExpiration:SetText(expirationText)
				self.leadExpiration:SetHidden(false)
				self.progressIcons:SetAnchor(TOPLEFT, self.leadExpiration, BOTTOMLEFT, 0, 4)
			else
				self.progressIcons:SetAnchor(TOPLEFT, self.difficulty, BOTTOMLEFT, 0, 4)
			end
		end
	)
end

function BetterAntiquitiesJournal:OnAddOnLoaded(event, addonName)
    if (addonName == BetterAntiquitiesJournal.name) then
        EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
		BetterAntiquitiesJournal:Initialize()
    end
end

EVENT_MANAGER:RegisterForEvent(
    BetterAntiquitiesJournal.name,
    EVENT_ADD_ON_LOADED,
    function(...)
        BetterAntiquitiesJournal:OnAddOnLoaded(...)
    end
)
