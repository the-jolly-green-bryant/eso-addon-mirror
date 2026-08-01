LibTextFormat = ZO_DeferredInitializingObject:Subclass()

local LTF = LibTextFormat

-- For the special case of math operations we always convert from strings
function LTF:toNumberSafe(value, default)
    default = default or 0
    if value == nil then return default end
    local n = tonumber(value)
    if n == nil then return default end
    return n
end

function LTF:ListVars()
  return self.savedVars
end

function LTF:GetVar(key)
  local vars = self:ListVars()
  return vars[key]
end

function LTF:DeleteFromVarsByValue(key, value)
  local var = self:GetVar(key)
  if var ~= nil then
    for k, v in pairs(var) do
      if value == k then
        var[key][value] = nil
        return true
      end
    end
  end
  return false
end

function LTF:SaveToVars(key, value)
  self.savedVars[key] = value
end

function LTF:GetVarByValue(key, value)
  local var = self:GetVar(key)
  if var ~= nil then
    for k, v in pairs(var) do
      if value == k then
        return v
      end
    end
  end
  return nil
end

function LTF.IsEmpty(value)
  local t = type(value)

  if t == "nil" then
    return true
  end

  if t == "string" then
    return value == ""
  end

  if t == "table" then
    return next(value) == nil
  end

  return false
end

function LTF.error(error)
  if not error then
    return "|cFF0000[LTF]|r LibTextFormat: Unhandled error."
  end
  return "|cFF0000[LTF]|r LibTextFormat: "..error
end

function LTF:Initialize(vars)
  self.savedVars = vars
end

function LTF:New(...)
  local object = ZO_Object.New(self)
  object:Initialize(...)
  return object
end
