local LIB = "Modes"
local Modes = FLUFFIELS_PANICBEAMS[LIB]

if not Modes then
   
    Modes = Modes or {
        Plugins = {}
    }
    FLUFFIELS_PANICBEAMS[LIB] = Modes
    
    function Modes:Register(name)
        table.insert(Modes.Plugins, name)
        Modes[name] = {}
        return Modes[name]
    end
    
end