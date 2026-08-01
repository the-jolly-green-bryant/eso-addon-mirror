LibTextFormat = LibTextFormat or {}
local LTF = LibTextFormat

LibTextFormatScope = LibTextFormatScope or ZO_Object:Subclass()

local Scope = LibTextFormatScope
LibTextFormatScope.__index = LibTextFormatScope

function Scope:New(...)
    local object = ZO_Object.New(self)
    object:Initialize(...)
    return object
end

function Scope:Initialize(initial)
    local vars = {}
    if initial then
        for k, v in pairs(initial) do
            vars[k] = v
        end
    end
    self._vars = vars
end

function Scope:Add(key, value)
    self._vars[key] = value
end

function Scope:List()
    return self._vars
end

function Scope:Get(key)
    return self._vars[key]
end

function Scope:Update(key, value)
    self._vars[key] = value
end

function Scope:Delete(key)
    self._vars[key] = nil
end

function Scope:Clone()
    local copy = {}
    for k, v in pairs(self._vars) do
        copy[k] = v
    end
    return Scope:New(copy)
end
