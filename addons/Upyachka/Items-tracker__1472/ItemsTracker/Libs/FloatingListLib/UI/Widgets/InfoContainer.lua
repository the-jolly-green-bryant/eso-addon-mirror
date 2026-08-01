--Register with LibStub
local MAJOR, MINOR = "Up_InfoContainer", 1
local LIB, _ = LibStub:NewLibrary(MAJOR, MINOR)
if not LIB then return end -- avoid double loading.

--[[
-- Used as container with padding for content and backdrop for stylization.
-- <root><backdrop><container></container></backdrop></root>
]] --

function LIB:new(id, root, backdrop, container)
    local instance = { ID = id, Root = root, Backdrop = backdrop, Container = container, LabelsList = {} }
    self.__index = self
    return setmetatable(instance, self)
end
