-- Addon
ChallengeModeSelector = ChallengeModeSelector or {}
local CMS = ChallengeModeSelector

-- Modules
CMS.SidePanel = CMS.SidePanel or {}
local SidePanel = CMS.SidePanel

-- State
SidePanel.requested = false
SidePanel.stats_hooked = false

local SIDE_PANEL = ZO_CHALLENGE_DIFFICULTY_KEYBOARD

-- Main
do
	-- Wrappers
	function SidePanel.IsShowing()
		return SIDE_PANEL:IsShowing()
	end
	function SidePanel.Hide()
		return SIDE_PANEL:Hide()
	end
	function SidePanel.Show()
		return SIDE_PANEL:Show()
	end
	function SidePanel.ResetPendingDifficulty()
		return SIDE_PANEL:ResetPendingDifficulty()
	end
	function SidePanel.RefreshDifficulties()
		return SIDE_PANEL:RefreshDifficulties()
	end

	-- Helpers
	function SidePanel.Refresh()
		-- Only refresh if panel is showing
		if not SidePanel.IsShowing() then
			return
		end
		SidePanel.ResetPendingDifficulty()
		SidePanel.RefreshDifficulties()
	end

	function SidePanel.RequestHide()
		SidePanel.requested = false
		SidePanel.Hide()
	end

	function SidePanel.RequestShow()
		SidePanel.requested = true
		SidePanel.Show()
	end

	function SidePanel.UpdateVisibility()
		if SidePanel.requested then
			SidePanel.RequestShow()
		else
			SidePanel.RequestHide()
		end
	end

	function SidePanel.Toggle()
		-- We toggle, but in cases where requested is in the wrong state, we just update it
		-- SidePanel.requested = not SidePanel.requested
		SidePanel.requested = not SidePanel.IsShowing()
		SidePanel.UpdateVisibility()
	end

	function SidePanel.HookStatsChallengePanel()
		-- Return if already hooked
		if SidePanel.stats_hooked then
			return
		end
		-- Hook
		ZO_PostHook(ZO_Stats, "UpdateLevelUpRewards", function()
			SidePanel.UpdateVisibility()
		end)
		SidePanel.stats_hooked = true
	end
end
