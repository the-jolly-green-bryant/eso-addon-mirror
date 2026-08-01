--[[--------------------------------------------
    Project:    Clock - Tamriel Standard Time
    Author:     Arne Rantzen (Tyx) & Phinix
    Created:    2020-02-23
    Updated:    2020-02-23
    License:    GPL-3.0
--------------------------------------------]]--

Clock_TST = Clock_TST or {}
local settings
local Bindings = ZO_Object:Subclass()

-- ----------------
-- Updates
-- ----------------

--- Function to toggle the visibility of the time and date
-- will update the time object and the settings
local function ToggleTimeVisibility(isVisible)
    settings:SetTimeIsVisible(isVisible)
    Clock_TST.time:UpdateVisibility()
    Clock_TST.time:UpdateMouse()
end

--- Function to toggle the visibility of the moon
-- will update the moon object and the settings
local function ToggleMoonVisibility(isVisible)
    settings:SetMoonIsVisible(isVisible)
    Clock_TST.moon:UpdateVisibility()
    Clock_TST.moon:UpdateMouse()
end

-- ----------------
-- Toggles
-- ----------------

--- Function to toggle the visibility of the moon and time and date
function Bindings.Toggle()
    local visibility = not settings:GetTimeIsVisible()
    ToggleTimeVisibility(visibility)
    ToggleMoonVisibility(visibility)
end

--- Function to toggle the visibility of the time and date
function Bindings.ToggleTime()
    local visibility = not settings:GetTimeIsVisible()
    ToggleTimeVisibility(visibility)
end

--- Function to toggle the visibility of the moon
function Bindings.ToggleMoon()
    local visibility = not settings:GetMoonIsVisible()
    ToggleMoonVisibility(visibility)
end

-- ----------------
-- Start
-- ----------------

--- Function to create the bindings
function Clock_TST:SetupBindings()
    settings = Clock_TST.settings
    self.bindings = Bindings:New()
end
