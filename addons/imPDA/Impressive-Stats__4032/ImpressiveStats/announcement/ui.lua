local TEXT = [[
Starting with this version, a new way of saving Battlegrounds data has been introduced.
I hope all bugs from the previous version have been fixed by now. Additionally, saved variables size reduced approximatelly 10 times to avoid potential performance issues and no data now loaded during loading screen to decrese loading duration.

This feature is optional in this update, but it will become mandatory in the future. I recommend switching early to avoid problems later. :)

---------------------------------------------------------------------

How to enable the new manager:
- IMPORTANT! Backup your SavedVariables! Navigate to your SavedVariables folder (...\Documents\Elder Scrolls Online\live\SavedVariables) and copy ImpressiveStats.lua to a safe location (a different folder).
- OPTIONAL: Take a screenshot of your current stats for reference.
- Navigate to the settings: Main Menu → Settings → Addons → Imp-ressive Stats.
- Open the "Battlegrounds module" and turn "New manager" on.
- Reload the UI (press E).
- NOTE: Corrupted matches will be deleted during the update, but this should not affect your overall stats, as these matches were never included in calculations.
- Compare your stats before and after the update—they should be the same.
- Same stats? → Good! No errors? → AWESOME!

---------------------------------------------------------------------

If you encounter any errors or inconsistencies in your stats, please let me know! You can reach me via Discord (@impda) or ESOUI website.

---------------------------------------------------------------------

How to revert changes in case of issues:
- Log out or exit the game.
- Restore your old SavedVariables: copy the backed-up ImpressiveStats.lua from your safe location and paste it into ...\Documents\Elder Scrolls Online\live\SavedVariables, replacing the current file.
- Log back in or start the game.

(This text will disappear once you turn on the new match manager.)
]]

--[[
function IMP_STATS_Announcement_OnInitialized(control)
    control:GetNamedChild('Text'):SetText(TEXT)

    ZO_PostHookHandler(IMP_STATS_MATCHES, "OnEffectivelyShown", function()
        if IMP_STATS_MATCHES_MANAGER and IMP_STATS_MATCHES_MANAGER.sv.newManager then return end
        control:SetHidden(false)
    end)

    ZO_PostHookHandler(IMP_STATS_MATCHES, "OnEffectivelyHidden", function()
        control:SetHidden(true)
    end)
end
--]]