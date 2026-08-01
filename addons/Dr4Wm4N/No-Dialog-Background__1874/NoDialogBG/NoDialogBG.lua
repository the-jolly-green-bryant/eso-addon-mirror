	NoDialogBG = {}
    NoDialogBG.name = "NoDialogBG"
     
        local function Addon_Loaded(eventCode, addOnName)
            if (addOnName == "NoDialogBG") then
				-- Mouse & keyboard dialog background
				ZO_InteractWindowTopBG:SetAlpha(0)
				ZO_InteractWindowBottomBG:SetAlpha(0)
				-- Gamepad dialog background
				ZO_InteractWindow_GamepadBG:SetAlpha(0)
				-- Subtitles background
				ZO_SubtitlesTextBackground:SetAlpha(0)
				ZO_SubtitlesTextBackgroundLeft:SetAlpha(0)
				ZO_SubtitlesTextBackgroundRight:SetAlpha(0)
            end
        end
		        
         EVENT_MANAGER:RegisterForEvent("NoDialogBG", EVENT_ADD_ON_LOADED, Addon_Loaded)