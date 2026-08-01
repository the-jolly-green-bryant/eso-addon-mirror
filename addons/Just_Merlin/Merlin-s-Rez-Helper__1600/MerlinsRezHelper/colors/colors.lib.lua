local LIB = "Colors"
local Colors = MERLINS_REZHELPER[LIB]

if not Colors then
   
    Colors = Colors or {
        Plugins = {}
    }
    MERLINS_REZHELPER[LIB] = Colors
    
    function Colors:Register(name)
        table.insert(Colors.Plugins, name)
        Colors[name] = {}
        return Colors[name]
    end
    
end