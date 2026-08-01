local Modules = Reforged.Modules

Modules._registry = {}

function Modules.register(mod)
    assert(mod.id,       "EsoBR module missing field: id")
    assert(mod.enabled,  "EsoBR module missing field: enabled")
    assert(mod.activate, "EsoBR module missing field: activate")
    Modules._registry[#Modules._registry + 1] = mod
end

function Modules.activateAll()
    for _, mod in ipairs(Modules._registry) do
        if mod.enabled() then
            mod.activate()
        end
    end
end
