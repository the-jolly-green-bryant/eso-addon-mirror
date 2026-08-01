local LIB = "Modes"
local Modes = MERLINS_REZHELPER[LIB]

if not Modes then
   
    Modes = Modes or {
        Plugins = {}
    }
    MERLINS_REZHELPER[LIB] = Modes
    
    function Modes:Register(name)
        table.insert(Modes.Plugins, name)
        Modes[name] = {}
        return Modes[name]
    end
    
end