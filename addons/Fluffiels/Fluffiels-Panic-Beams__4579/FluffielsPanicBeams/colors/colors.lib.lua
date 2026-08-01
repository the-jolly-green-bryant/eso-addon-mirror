local LIB = "Colors"
local Colors = FLUFFIELS_PANICBEAMS[LIB]

if not Colors then
   
    Colors = Colors or {
        Plugins = {}
    }
    FLUFFIELS_PANICBEAMS[LIB] = Colors
    
    function Colors:Register(name)
        table.insert(Colors.Plugins, name)
        Colors[name] = {}
        return Colors[name]
    end
    
end