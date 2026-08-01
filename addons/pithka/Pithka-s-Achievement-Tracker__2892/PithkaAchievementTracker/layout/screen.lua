-- global namspacing
-- NOTE: This implementation uses a single GUI container (PITHKA_GUI) for all screens.
-- Rather than creating separate UI containers for each screen, we simply change the
-- dimensions and visibility of the contents when switching between screens.
-- This means all screens share the same background container, just with different sizes.
PITHKA = PITHKA or {} 
PITHKA.layout = PITHKA.layout or {}
PITHKA.layout.screen = {}

-- convenient namespacing
local api = PITHKA.common.api
local constants = PITHKA.common.constants
local screen = PITHKA.layout.screen

---------------------------------------------------------------------------------------------------------
-- Screen
---------------------------------------------------------------------------------------------------------

-- Screen class definition
screen.__index = screen

-- Constructor
function screen.new(navIconTexture, width, height, title, populateCallback)
    local self = setmetatable({}, screen)
    self.navIconTexture = navIconTexture
    self.width = width
    self.height = height
    self.title = title
    self.objects = {}
    self.isHidden = true
	self.populateCallback = populateCallback
	self.isInitialized = false
    return self
end

function screen:EnsureInitialized()
	if not self.isInitialized then
		self.populateCallback()
		self.isInitialized = true
	end
end

-- Method to set visibility on self and children
function screen:setHidden(isHidden)
    -- update hidden state of Screen
    self.isHidden = isHidden
	
    -- update hidden state to all children objects
    for _, obj in ipairs(self.objects) do
        if obj.setHidden then
            obj:setHidden(self.isHidden)
        end
    end

    -- if not hidden update Screen title and dimensions
    if not self.isHidden then 
        -- update Screen size
        api.gui.setDimensions(self.width, self.height)

        -- update Screen title
        api.gui.setTitle(self. title)
    end
end

function screen:addObject(obj)
    -- add object to Screen
    table.insert(self.objects, obj)

    -- update object hidden state to match Screen
    obj:setHidden(self.isHidden)
end
