local LIB = "Colors"
local Colors = EXT_GROUPLEADER[LIB]

if not Colors then
   
    Colors = Colors or {
        Plugins = {}
    }
    EXT_GROUPLEADER[LIB] = Colors
    
    function Colors:Register(name)
        table.insert(Colors.Plugins, name)
        Colors[name] = {}
        return Colors[name]
    end
    
end