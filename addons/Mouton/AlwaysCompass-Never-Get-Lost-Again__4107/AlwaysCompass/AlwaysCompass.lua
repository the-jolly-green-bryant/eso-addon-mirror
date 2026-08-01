AlwaysCompass = {
	name = "AlwaysCompass",
	options = {
		type = "panel",
		name = "AlwaysCompass: Never Lost Again",
		author = "mouton",
		version = "0.0.2"
	},
	settings = {
	},
	defaultSettings = {
		variableVersion = 1,
		debug = false,
	}
}

local AC = AlwaysCompass

function AC.OnAddOnLoaded(event, addonName)
	if addonName ~= AC.name then return end

	AC:Initialize()
end

function AC.debug(is_debug)
	-- For debugging all effects
	if is_debug then
		AC.settings.debug = true
	else
		AC.settings.debug = false
	end
end

function AC.d(...)
	if AC.settings.debug then
		d(...)
	end
end

-- Override the compass style
function BOSS_BAR:ApplyStyle()
	AC.d("ApplyStyle")
    ApplyTemplateToControl(self.control, ZO_GetPlatformTemplate("AC_BossBar"))
end

-- Review the way we display the boss bar and the compass
function COMPASS_FRAME:RefreshVisible()
    if(self.compassReady and self.bossBarReady) then
        local bossBarIsHidden = self.bossBarHiddenReasons:IsHidden() or not self.bossBarActive
        local compassIsHidden = false
        
        local frameWasHidden = self.control:IsHidden()
        local frameIsHidden = bossBarIsHidden and compassIsHidden
        local frameChanged = frameWasHidden ~= frameIsHidden

        -- If the frame is showing or hiding, or the frame isn't even shown, do the transition
        -- between the boss bar and compass instantly
        if(frameChanged or frameIsHidden) then
            if(self.crossFadeTimeline) then
                self.crossFadeTimeline:Stop()
            end
            COMPASS_FRAME_FRAGMENT:SetHiddenForReason("contentsHidden", frameIsHidden)
            ZO_BossBar:SetAlpha(.9)
            ZO_Compass:SetAlpha(1)
            ZO_BossBar:SetHidden(bossBarIsHidden)
            ZO_Compass:SetHidden(false)
        else
            --otherwise animate it if it changed
            local bossBarWasHidden = ZO_BossBar:IsHidden()
			ZO_Compass:SetHidden(false)

            if(bossBarWasHidden ~= bossBarIsHidden) then
                if(not self.crossFadeTimeline) then
					-- Use Custom animation
                    self.crossFadeTimeline = ANIMATION_MANAGER:CreateTimelineFromVirtual("AC_CompassFrame_FadeAnimation", ZO_BossBar)
                end
                if(not bossBarIsHidden) then
                    if(self.crossFadeTimeline:IsPlaying()) then
                        self.crossFadeTimeline:PlayForward()
                    else
                        self.crossFadeTimeline:PlayFromStart()
                    end
                else
                    if(self.crossFadeTimeline:IsPlaying()) then
                        self.crossFadeTimeline:PlayBackward()
                    else
                        self.crossFadeTimeline:PlayFromEnd()
                    end
                end
            end
        end        
    end
end

function AC.init()
	AC.d("AlwaysCompass: Initialized")
	BOSS_BAR:ApplyStyle()
end

function AC:Initialize()
	AC.settings = ZO_SavedVars:NewAccountWide(AC.name .. "Variables", AC.defaultSettings.variableVersion, nil, AC.defaultSettings)

	EVENT_MANAGER:RegisterForEvent(AC.name, EVENT_PLAYER_ACTIVATED, AC.init)
	EVENT_MANAGER:UnregisterForEvent(AC.name, EVENT_ADD_ON_LOADED)
end

EVENT_MANAGER:RegisterForEvent(AC.name, EVENT_ADD_ON_LOADED, AC.OnAddOnLoaded)
