-- LibValknarrUIE: public host API so other add-ons can opt their controls
-- into the grid editor instead of Valknarr forking those add-ons.
--
-- Tonight this lives inside ValknarrUIE. After console validation it
-- should be extracted to a separate IsLibrary Bethesda listing so authors
-- can ## DependsOn: LibValknarrUIE without pulling editor chrome.
--
-- Do not copy third-party Lua. Authors register their own controls.

LibValknarrUIE = LibValknarrUIE or {}

local Lib = LibValknarrUIE
local Log = ValknarrUIELog

Lib.addons = Lib.addons or {}
Lib.order = Lib.order or {}
Lib.byId = Lib.byId or {}

local HOST_ADDON = "ValknarrUIE"

local function FullId(addonId, elementId)
    if addonId == HOST_ADDON then
        return elementId
    end
    return tostring(addonId) .. ":" .. tostring(elementId)
end

function Lib:RegisterAddon(addonId, displayName)
    if type(addonId) ~= "string" or addonId == "" then
        return false
    end
    self.addons[addonId] = {
        id = addonId,
        name = tostring(displayName or addonId),
    }
    if Log then
        Log:Debug("LibValknarrUIE addon registered: " .. addonId)
    end
    return true
end

function Lib:RegisterElement(addonId, elementId, spec)
    if type(addonId) ~= "string" or type(elementId) ~= "string" then
        if Log then
            Log:Warn("LibValknarrUIE:RegisterElement needs addonId and elementId strings")
        end
        return false
    end
    spec = spec or {}
    if type(spec.locate) ~= "function" then
        if Log then
            Log:Warn("LibValknarrUIE:RegisterElement(" .. addonId .. ", " .. elementId .. ") needs spec.locate")
        end
        return false
    end

    local id = FullId(addonId, elementId)
    local entry = {
        id = id,
        addonId = addonId,
        elementId = elementId,
        name = tostring(spec.name or elementId),
        locate = spec.locate,
        apply = spec.apply,
        preparePreview = spec.preparePreview,
        endPreview = spec.endPreview,
        resizable = spec.resizable and true or false,
        default = {
            x = tonumber(spec.default and spec.default.x) or 0.5,
            y = tonumber(spec.default and spec.default.y) or 0.5,
        },
    }
    if spec.default and tonumber(spec.default.w) and tonumber(spec.default.h) then
        entry.default.w = tonumber(spec.default.w)
        entry.default.h = tonumber(spec.default.h)
    end

    if not self.byId[id] then
        self.order[#self.order + 1] = id
    end
    self.byId[id] = entry
    if not self.addons[addonId] then
        self:RegisterAddon(addonId, addonId)
    end
    if Log then
        Log:Info("LibValknarrUIE element: " .. id .. " (" .. entry.name .. ")")
    end
    return id
end

-- Returns the live registration order. Callers must not mutate the table.
function Lib:Ids()
    return self.order
end

-- Guest API: full entry list for third-party tools. Host uses Ids().
function Lib:List()
    local list = {}
    for index = 1, #self.order do
        list[index] = self.byId[self.order[index]]
    end
    return list
end

function Lib:Get(id)
    return self.byId[id]
end

function Lib:Label(id)
    local entry = self.byId[id]
    if entry then
        return entry.name
    end
    return nil
end

function Lib:DefaultFor(id)
    local entry = self.byId[id]
    if entry and entry.default then
        local result = { x = entry.default.x, y = entry.default.y }
        if entry.default.w then
            result.w = entry.default.w
        end
        if entry.default.h then
            result.h = entry.default.h
        end
        return result
    end
    return nil
end

-- Guest API: whether an element supports RS resize. Host currently allows
-- resize for all registered pieces that store w/h; keep this for authors.
function Lib:IsResizable(id)
    local entry = self.byId[id]
    return entry and entry.resizable == true
end

function Lib:LocateGuests(controls, sources)
    controls = controls or {}
    sources = sources or {}
    for index = 1, #self.order do
        local entry = self.byId[self.order[index]]
        -- Fill any id that is not already located, including host extras
        -- (chat). HMS are located first by the player-attribute adapter.
        if entry and controls[entry.id] == nil then
            local ok, control, source = pcall(entry.locate)
            if ok then
                controls[entry.id] = control
                sources[entry.id] = source or (control and (entry.addonId .. " registered") or "missing")
            else
                sources[entry.id] = "locate-error"
                if Log then
                    Log:Warn("Locate failed for " .. entry.id .. ": " .. tostring(control))
                end
            end
        end
    end
    return controls, sources
end

function Lib:Count()
    return #self.order
end

return Lib
