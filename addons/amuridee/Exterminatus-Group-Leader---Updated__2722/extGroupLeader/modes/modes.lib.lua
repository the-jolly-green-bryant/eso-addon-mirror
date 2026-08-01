local LIB = "Modes"
local Modes = EXT_GROUPLEADER[LIB]

if not Modes then
   
    Modes = Modes or {
        Plugins = {}
    }
    EXT_GROUPLEADER[LIB] = Modes
    
    function Modes:Register(name)
        table.insert(Modes.Plugins, name)
        Modes[name] = {}
        return Modes[name]
    end
    
end