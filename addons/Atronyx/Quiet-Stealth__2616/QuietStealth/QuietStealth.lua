local ADDON_NAME = "QuietStealth"
local ADDON_VERSION = "1.1"
local ADDON_AUTHOR = "Atronyx"


--Backup the original sounds
local SOUND_STEALTH_HIDDEN_ORIG = SOUNDS.STEALTH_HIDDEN
local SOUND_STEALTH_DETECTED_ORIG = SOUNDS.STEALTH_DETECTED

--Set the sounds in the SOUNDS table nil
SOUNDS.STEALTH_HIDDEN = nil 
SOUNDS.STEALTH_DETECTED = nil

--Add the backuped sounds to the SOUNDS table with different names again so ppl can still select and use it
SOUNDS.STEALTH_HIDDEN_ORIG = SOUND_STEALTH_HIDDEN_ORIG 
SOUNDS.STEALTH_DETECTED_ORIG = SOUND_STEALTH_DETECTED_ORIG


-- AddOn has registered for Stealth State change events
-- When that event is called and the player is stealthed, then hide the Stealth Text
local function StealthChange( event, unit, state )
    if ( unit == "player" ) then
        if ( state ~= STEALTH_STATE_NONE ) then
            ZO_ReticleContainerStealthIconStealthText:SetHidden( true )
        end
    end
end

-- AddOn has registered for Disguise State change events
-- When that event is called and the player is disguised, then hide the Stealth Text
local function DisguiseChange( event, unit, state )
    if ( unit == "player" ) then
        if ( state ~= DISGUISE_STATE_NONE ) then
            ZO_ReticleContainerStealthIconStealthText:SetHidden( true )
        end
    end
end

-- Step 2. Unregistering from AddOn Loaded and registering for stealth and disguise events
-- The rest of the code is called on an as-needed basis, whenever stealth/disguise changes occur
local function OnAddonLoaded(event, name)
	if name ~= ADDON_NAME then return end
	
	EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, event)
		
	EVENT_MANAGER:RegisterForEvent( ADDON_NAME, EVENT_STEALTH_STATE_CHANGED, StealthChange )
	EVENT_MANAGER:RegisterForEvent( ADDON_NAME, EVENT_DISGUISE_STATE_CHANGED, DisguiseChange )
		
	-- If you /reloadui while stealthed, the "HIDDEN" text will show up
	-- So hide it right from the start
	ZO_ReticleContainerStealthIconStealthText:SetHidden( true )
end

-- Step 1. As ESO loads the addons, when it finds "QuietStealth" it fires this event which calls the OnAddonLoaded function
EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddonLoaded)
