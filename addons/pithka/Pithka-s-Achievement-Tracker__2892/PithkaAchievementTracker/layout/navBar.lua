-- global namspacing
PITHKA = PITHKA or {} 
PITHKA.layout = PITHKA.layout or {}
PITHKA.layout.navBar = {}

-- convenient namespacing
local constants = PITHKA.common.constants
local navBar = PITHKA.layout.navBar
local ui = PITHKA.ui

---------------------------------------------------------------------------------------------------------
-- Nav Bar
---------------------------------------------------------------------------------------------------------

-- Define the NavBar class
navBar.__index = navBar

-- Constructor for NavBar
function navBar.new()
    local self = setmetatable({}, navBar)
    self.screens = {}
    self.navButtons = {}    
    return self
end

-- to do, save the open tab using local variables


-- Method to add a new Screen and corresponding navButton
function navBar:addScreen(screen)
    -- Append the screen to the screens array
    table.insert(self.screens, screen)
    
    -- Create a corresponding navButton 
    local navButton = self:createNavButtonFromScreen(screen)
    
    -- Append the navButton to the navButtons array
    table.insert(self.navButtons, navButton)
end

-- Method to handle button clicked event
function navBar:onClick(id)
    -- Only set the variable, do not show/hide screens directly
    PITHKA.data.savedVars.set('currentScreen', self.screens[id].title)
end

-- Register a callback to handle screen switching
function navBar:registerScreenCallback()
    PITHKA.data.savedVars.registerCallback(function(var, value)
        if var ~= 'currentScreen' then return end
        for i, screen in ipairs(self.screens) do
			--lazy-load the screen, it'll stutter once upon first view, but should be smooth after.
			if screen.title == value then
				screen:EnsureInitialized()
			end
            screen:setHidden(screen.title ~= value)
        end
    end)
end

-- Method to create clickable nav buttons
function navBar:createNavButtonFromScreen(screen)
    local id = #self.navButtons + 1 -- increment id, used for clickFn and anchors

    -- create icon
    local iconSettings = {
        texture = screen.navIconTexture,
        size    = constants.navIcon.size, 
        tooltipText =  screen.title, 
        tooltipAnchor = LEFT,
        clickFn = function() self:onClick(id) end -- wrap parameterized clickFn
    }
    local control = ui.icon.basic(iconSettings)

    -- anchor icon
    local xOffset = -12
    local yOffset = constants.navIcon.size * id
    control:SetAnchor(BOTTOMRIGHT, PITHKA_GUI, TOPLEFT, xOffset, yOffset)

    return control
end

