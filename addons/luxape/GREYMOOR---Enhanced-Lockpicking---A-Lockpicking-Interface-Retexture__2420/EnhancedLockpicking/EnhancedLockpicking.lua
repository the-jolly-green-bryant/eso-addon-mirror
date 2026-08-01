enhancedlockpicking = {}
enhancedlockpicking.appName = "enhancedlockpicking"

local ADDON_VERSION = "1.00"

function enhancedlockpicking.OnAddOnLoaded()

	RedirectTexture("esoui/art/lockpicking/pins.dds", "esoui/art/lockpicking/pins.dds")
	RedirectTexture("esoui/art/lockpicking/pins_over.dds", "esoui/art/lockpicking/blank.dds")
	RedirectTexture("esoui/art/lockpicking/pins_set.dds", "esoui/art/lockpicking/pins.dds")
	RedirectTexture("esoui/art/lockpicking/lock_body.dds", "enhancedlockpicking/lockpick/lock_body.dds")
	RedirectTexture("esoui/art/lockpicking/lock_mask.dds", "enhancedlockpicking/lockpick/lock_mask.dds")
	RedirectTexture("esoui/art/lockpicking/lock_pick.dds", "enhancedlockpicking/lockpick/lock_pick.dds")
	RedirectTexture("esoui/art/lockpicking/lock_pick_broken_left.dds", "enhancedlockpicking/lockpick/lock_pick_broken_left.dds")
	RedirectTexture("esoui/art/lockpicking/lock_pick_broken_right.dds", "enhancedlockpicking/lockpick/lock_pick_broken_right.dds")
	RedirectTexture("esoui/art/lockpicking/lock_tensioner_bottom.dds", "enhancedlockpicking/lockpick/lock_tensioner_bottom.dds")
	RedirectTexture("esoui/art/lockpicking/lock_tensioner_top.dds", "enhancedlockpicking/lockpick/lock_tensioner_top.dds")

end

EVENT_MANAGER:RegisterForEvent(enhancedlockpicking.appName, EVENT_ADD_ON_LOADED, enhancedlockpicking.OnAddOnLoaded)