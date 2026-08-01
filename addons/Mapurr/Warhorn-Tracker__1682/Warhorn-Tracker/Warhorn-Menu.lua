Warhorn = Warhorn or {}
local Warhorn = Warhorn

function Warhorn.buildMenu()
	local LAM = LibStub("LibAddonMenu-2.0")
	local demoAbility = 46538	-- Aggressive Horn IV
	
	local panelData = {
		type = "panel",
		name = Warhorn.name,
		displayName = Warhorn.name,
		author = "|c800080Mapurr|r, |c00FF00Wheels|r",
		version = ""..Warhorn.version
	}

	LAM:RegisterAddonPanel(Warhorn.name.."Options", panelData)

	local options = {
		{
			type = "header",
			name = "Positioning"
		},
		{
			type = "checkbox",
			name = "UI Locked",
			tooltip = "Allows for positioning of Warhorn window",
			getFunc = function() return true end,
			setFunc = function(value)
				if not value then
					EVENT_MANAGER:UnregisterForEvent(Warhorn.name.."RetUpdate", EVENT_RETICLE_HIDDEN_UPDATE)
					WarhornTrackerWindowTitle:SetText("|t40:40:" .. GetAbilityIcon(demoAbility) .. "|t " .. zo_strformat(SI_ABILITY_NAME, GetAbilityName(demoAbility)))
					WarhornTrackerWindowTimer:SetText("99")
					WarhornTrackerWindow:SetHidden(false)
					WarhornTrackerWindow:SetMovable(true)
					WarhornTrackerWindow:SetMouseEnabled(true)
				else
					EVENT_MANAGER:RegisterForEvent(Warhorn.name.."RetUpdate", EVENT_RETICLE_HIDDEN_UPDATE, Warhorn.retUpdate)
					if Warhorn.finishTime < 1 then
						WarhornTrackerWindow:SetHidden(true)
						WarhornTrackerWindowTitle:SetText("")
						WarhornTrackerWindowTimer:SetText("")
					end
					WarhornTrackerWindow:SetMovable(false)
					WarhornTrackerWindow:SetMouseEnabled(false)
				end
			end
		},
	}

	LAM:RegisterOptionControls(Warhorn.name.."Options", options)
end
