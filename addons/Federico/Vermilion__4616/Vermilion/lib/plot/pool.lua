Vermilion = Vermilion or {}
Vermilion.lib = Vermilion.lib or {}
Vermilion.lib.plot = Vermilion.lib.plot or {}

local M = {}
Vermilion.lib.plot.Pool = M

local zui = Vermilion.zenimax.ui
local WINDOW_MANAGER  = zui.WINDOW_MANAGER
local ZO_ObjectPool   = zui.ZO_ObjectPool

local Primitives = Vermilion.lib.plot.Primitives

function M.new(name_prefix, parent, ctype, on_factory, on_reset)
  local counter = 0
  return ZO_ObjectPool:New(
    function()
      counter = counter + 1
      local c = WINDOW_MANAGER:CreateControl(name_prefix .. counter, parent, ctype)
      if on_factory then on_factory(c, counter) end
      return c
    end,
    function(c)
      if on_reset then on_reset(c)
      else Primitives.clear(c) end
    end
  )
end

function M.new_virtual(name_prefix, parent, virtual_template, on_factory, on_reset)
  local CreateControlFromVirtual = zui.CreateControlFromVirtual
  local counter = 0
  return ZO_ObjectPool:New(
    function()
      counter = counter + 1
      local c = CreateControlFromVirtual(name_prefix .. counter, parent, virtual_template)
      if on_factory then on_factory(c, counter) end
      return c
    end,
    function(c)
      if on_reset then on_reset(c)
      else Primitives.clear(c) end
    end
  )
end
