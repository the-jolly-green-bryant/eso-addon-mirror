-----------------------------------------------------------------------------------
-- Library Name: LibTextFormat (LTF)
-- Creator: Saranicole1980 (Sara Jarjoura)
-- Library Ideal: Advanced Text Formatting and Parsing
-- Library Creation Date: February, 2026
-- Publication Date: TBD
--
-- File Name: LibTextFormat.lua
-- File Description: Contains the main functions of LTF
-- Load Order Requirements: After all other library files
--
-----------------------------------------------------------------------------------

LibTextFormat = LibTextFormat or {}

local LTF = LibTextFormat

LTF.defaultVersion = "v1"

local rendersPrefix = "from"

local function splitPipeline(block)
    local argsPart, pipePart = block:match("^(.-)|(.+)$")
    if not argsPart then
        return { block }
    end

    local parts = { argsPart }
    for p in pipePart:gmatch("[^|]+") do
        parts[#parts + 1] = zo_strtrim(p)
    end
    return parts
end

function LTF.Scope(initial)
  return LibTextFormatScope:New(initial)
end

function LTF:RegisterCore(version, selectiveOverrides)
  version = version or self.defaultVersion
  selectiveOverrides = selectiveOverrides or {}
  self:RegisterProtocolsBulk(self.CoreProtocols, version, selectiveOverrides)
  self:RegisterFiltersBulk(self.Core, version, selectiveOverrides)
end

local function SeedValue(expr, ctx)
    -- expr = "my.path" or "foo,bar" if you want later
    return ctx.scope:Get(expr)
end

local function BuildFormatContext(scope, ltf)
    return {
        scope = scope,
        ltf   = ltf,
        now = GetTimeStamp(),
        itemSep = scope:Get("itemSep"),
        pathSep = scope:Get("pathSep"),
        recordSep = scope:Get("recordSep")
    }
end

function LTF:GetStage(name)
    return self:GetProtocol(name) or self:GetFilter(name)
end

local function IsPureExpression(template)
    return template:match("^%s*{[^}]+}%s*$") ~= nil
end

local function returnsObject(protocolName)
  if protocolName:sub(1, #rendersPrefix) == rendersPrefix then
    return true
  end
  return false
end

function LTF:eval(block, scope)
    local parts = splitPipeline(block)
    local ctx   = BuildFormatContext(scope, self)

    local value
    local lastRenderer

    for _, part in ipairs(parts) do
        part = zo_strtrim(part)

        local stage = self:GetStage(part)
        if stage then
            value = stage(ctx, value, part)

            if value ~= nil and returnsObject(part) then
                lastRenderer = stage
            end
        else
            value = scope:Get(part)
        end
    end

    if self.IsEmpty(value) then
      return value
    end

    return value, lastRenderer
end

function LTF:format(template, scope)
  if IsPureExpression(template) then
      local block = template:match("{(.-)}")
      return self:eval(block, scope)
  end
  return (template:gsub("{(.-)}", function(block)
      local value, renderer = self:eval(block, scope)

      if type(value) ~= "string" then
          local ctx = BuildFormatContext(scope, self)

          if renderer then
              return renderer(ctx, value)
          end

          -- last-resort fallback
          return tostring(value)
      end

      return value
  end))
end
