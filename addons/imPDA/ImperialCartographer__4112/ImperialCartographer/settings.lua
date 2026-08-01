assert(ImperialCartographer, 'ImperialCartographer not loaded')

local settings = {}
local LAM = LibAddonMenu2

function settings:Initialize(settingsName, settingsDisplayName, sv)
    local panelData = {
        type = 'panel',
        name = settingsDisplayName,
        author = '@impda',
        website = 'https://www.esoui.com/downloads/info4112-ImperialCartographer.html',
        version = 'v21',
    }

    local panel = LAM:RegisterAddonPanel(settingsName, panelData)
    local optionsData = {}

    local aboutControls = {}
    optionsData[#optionsData+1] = {
        type = 'submenu',
		name = 'About',
		controls = aboutControls,
    }

    aboutControls[#aboutControls+1] = {
        type = 'description',
        -- title = 'About',
        text =
[[
ImperialCartographer is an addon that shows Points of Interest (POIs) as markers within the 3D game world of The Elder Scrolls Online, providing a more immersive alternative to the standard compass or map.

It requires a manually built database because the game's API does not provide location data. Each POI must be visited and its coordinates recorded for the marker to appear.

If you see a POI in red, it means its coordinates have not been added yet. The project relies on community contributions to map the world.
]],
        -- reference = 'MyAddonDescription'
    }

    optionsData[#optionsData+1] = {
        type = 'checkbox',
		name = 'Active',
		getFunc = function() return sv.active end,
		setFunc = function(value)
            ImperialCartographer.MarksManager:SetActive(value)
        end,
        tooltip = 'GLOBAL toggle for all marks from this addon',
        reference = 'IMP_CART_LAM_SETTING_ACTIVE',
    }

    optionsData[#optionsData+1] = {
        type = 'checkbox',
		name = 'Hide in combat',
		getFunc = function() return sv.hideInCombat end,
		setFunc = function(value)
            ImperialCartographer.MarksManager:SetHideInCombat(value)
        end,
        tooltip = 'ALL marks will be automatically hidden on combat and restored afterwards',
        -- requiresReload = true,
    }

    optionsData[#optionsData+1] = {
		type = 'slider',
		name = 'Mark name font size',
		getFunc = function() return sv.labelFontSize end,
		setFunc = function(value)
            if value ~= sv.labelFontSize then
                sv.labelFontSize = value
                ImperialCartographer.MarksManager:UpdatePOILabelFontSize()
            end
        end,
		min = 16,
		max = 36,
	}

    local defaultPOIsControls = {}
    optionsData[#optionsData+1] = {
        type = 'submenu',
		name = 'Default points of interest (POIs)',
		-- tooltip = 'My Submenu Tooltip',
		controls = defaultPOIsControls,
		-- reference = 'MyAddonSubmenu'
    }

    defaultPOIsControls[#defaultPOIsControls+1] = {
		type = 'slider',
		name = 'Marker size',
		getFunc = function() return sv.defaultPois.markerSize end,
		setFunc = function(value)
            if value ~= sv.defaultPois.markerSize then
                sv.defaultPois.markerSize = value
                ImperialCartographer.DefaultPOIs:TriggerFullUpdate()
            end
        end,
		min = 24,
		max = 144,
	}

    defaultPOIsControls[#defaultPOIsControls+1] = {
		type = 'slider',
		name = 'Distance meter font size',
		getFunc = function() return sv.defaultPois.fontSize end,
		setFunc = function(value)
            if value ~= sv.defaultPois.fontSize then
                sv.defaultPois.fontSize = value
                ImperialCartographer.DefaultPOIs:SetDistanceLabelFontSize(value)
            end
        end,
		min = 16,
		max = 36,
	}

    -- defaultPOIsControls[#defaultPOIsControls+1] = {
	-- 	type = 'slider',
	-- 	name = 'Transparency on distance',
	-- 	getFunc = function() return sv.defaultPois.maxAlpha end,
	-- 	setFunc = function(value)
    --         if value ~= sv.defaultPois.maxAlpha then
    --             sv.defaultPois.maxAlpha = value
    --             ImperialCartographer.DefaultPOIs:TriggerFullUpdate()
    --         end
    --     end,
	-- 	min = 0.05,
	-- 	max = 1,
    --     step = 0.01,
    --     decimals = 2,
    --     clampInput = true,
    --     requiresReload = true,
	-- }

    -- defaultPOIsControls[#defaultPOIsControls+1] = {
	-- 	type = 'slider',
	-- 	name = 'Transparency when close',
	-- 	getFunc = function() return sv.defaultPois.minAlpha end,
	-- 	setFunc = function(value)
    --         if value ~= sv.defaultPois.minAlpha then
    --             sv.defaultPois.minAlpha = value
    --             ImperialCartographer.DefaultPOIs:TriggerFullUpdate()
    --         end
    --     end,
	-- 	min = 0.05,
	-- 	max = 1,
    --     step = 0.01,
    --     decimals = 2,
    --     clampInput = true,
    --     requiresReload = true,
	-- }

    -- defaultPOIsControls[#defaultPOIsControls+1] = {
	-- 	type = 'slider',
	-- 	name = 'Max distance',
	-- 	getFunc = function() return sv.defaultPois.maxDistance / 100 end,
	-- 	setFunc = function(value)
    --         value = value * 100
    --         if value ~= sv.defaultPois.maxDistance then
    --             sv.defaultPois.maxDistance = value
    --             ImperialCartographer.DefaultPOIs:TriggerFullUpdate()
    --         end
    --     end,
	-- 	min = 10,
	-- 	max = 700,
    --     -- step = 1,
    --     -- decimals = 2,
    --     clampInput = true,
    --     requiresReload = true,
	-- }

    -- defaultPOIsControls[#defaultPOIsControls+1] = {
    --     type = 'colorpicker',
    --     name = 'Marker color',
    --     getFunc = function() return unpack(sv.defaultPois.markerColor) end,
    --     setFunc = function(r, g, b, a)
    --         sv.defaultPois.markerColor = {r, g, b}
    --         ImperialCartographer.DefaultPOIs:TriggerFullUpdate()
    --     end,
    --     -- width = 'half',
    --     -- warning = 'warning text',
    -- }

    local undiscoveredPOIsControls = {}
    optionsData[#optionsData+1] = {
        type = 'submenu',
		name = 'Undiscovered points of interest (POIs)',
		tooltip = 'Points which were not added to addon yet',
		controls = undiscoveredPOIsControls,
		-- reference = 'MyAddonSubmenu'
    }

    undiscoveredPOIsControls[#undiscoveredPOIsControls+1] = {
        type = 'checkbox',
        name = 'Enabled',
        getFunc = function() return sv.undiscoveredPOIs.enabled end,
        setFunc = function(value)
            sv.undiscoveredPOIs.enabled = value
        end,
        requiresReload = true,
    }

    local questTrackerControls = {}
    optionsData[#optionsData+1] = {
        type = 'submenu',
		name = 'Current tracked quest marker',
		-- tooltip = 'My Submenu Tooltip',
		controls = questTrackerControls,
		-- reference = 'MyAddonSubmenu'
    }

    questTrackerControls[#questTrackerControls+1] = {
        type = 'checkbox',
        name = 'Enabled',
        getFunc = function() return sv.questTracker.enabled end,
        setFunc = function(value)
            sv.questTracker.enabled = value
        end,
        requiresReload = true,
    }

    questTrackerControls[#questTrackerControls+1] = {
        type = 'iconpicker',
        name = 'Texture',
        choices = {
            '/esoui/art/writadvisor/advisor_trackedpin_icon.dds',
            '/esoui/art/mappins/ui_worldmap_pin_customdestination_white.dds',
            '/esoui/art/miscellaneous/gamepad/gp_bullet.dds',
            'ImperialCartographer/textures/mark_01.dds',
            'ImperialCartographer/textures/mark_02.dds',
            'ImperialCartographer/textures/mark_03.dds',
            'ImperialCartographer/textures/mark_04.dds',
            'ImperialCartographer/textures/mark_05.dds',
        },
        iconSize = 48,
        getFunc = function() return sv.questTracker.texture end,
        setFunc = function(value)
            sv.questTracker.texture = value
        end,
        requiresReload = true,
    }

    questTrackerControls[#questTrackerControls+1] = {
		type = 'slider',
		name = 'Distance meter font size',
		getFunc = function() return sv.questTracker.fontSize end,
		setFunc = function(value)
            if value ~= sv.questTracker.fontSize then
                sv.questTracker.fontSize = value
                IMP_CART_UpdateQuestTrackerDistanceLabelFontSize(value)
            end
        end,
		min = 16,
		max = 36,
	}

    -- questTrackerControls[#questTrackerControls+1] = {
    --     type = 'colorpicker',
    --     name = 'Marker color',
    --     getFunc = function() return unpack(sv.questTracker.markerColor) end,
    --     setFunc = function(r, g, b, a)
    --         sv.questTracker.markerColor = {r, g, b}
    --     end,
    --     -- width = 'half',
    --     -- warning = 'warning text',
    --     requiresReload = true,
    -- }

    -- questTrackerControls[#questTrackerControls+1] = {
    --     type = 'checkbox',
    --     name = 'Offmap marks',
    --     getFunc = function() return sv.questTracker.showOffmap end,
    --     setFunc = function(value)
    --         sv.questTracker.showOffmap = value
    --     end,
    --     tooltip = 'When ON, marks quests from all locations. When OFF, only marks quests in your current zone.',
    --     requiresReload = true,
    -- }

    -- questTrackerControls[#questTrackerControls+1] = {
    --     type = 'colorpicker',
    --     name = 'Offmap marker color',
    --     getFunc = function() return unpack(sv.questTracker.offmapMarkerColor) end,
    --     setFunc = function(r, g, b, a)
    --         sv.questTracker.offmapMarkerColor = {r, g, b}
    --     end,
    --     -- width = 'half',
    --     -- warning = 'warning text',
    --     requiresReload = true,
    -- }

    LAM:RegisterOptionControls(settingsName, optionsData)

    -- TODO: FIX
    -- CALLBACK_MANAGER:RegisterCallback('LAM-PanelOpened', function(panelOpened)
    --     if panelOpened ~= panel then return end
    --     IMP_CART_DiscoveredPOIs:SetHidden(false)
    -- end)

    -- CALLBACK_MANAGER:RegisterCallback('LAM-PanelClosed', function(panelOpened)
    --     if panelOpened ~= panel then return end

    --     if not ImperialCartographer.sv.pinned then
    --         IMP_CART_DiscoveredPOIs:SetHidden(true)
    --     end
    -- end)
end

ImperialCartographer.Settings = settings
