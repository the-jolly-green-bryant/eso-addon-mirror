local themeName = "ThemeTemplateName"

_G[themeName] = { 
   overrides = { },
   maps = { },
}

local theme = _G[themeName]
local overrides = theme.overrides

overrides[ "" ] = function ( self, output, ... )
   local args1, args2, args3 = ...
   

   return output
end