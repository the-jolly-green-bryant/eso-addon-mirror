local Addon = TheSynapticRegistry


function TheSynapticRegistry_UI_OnInitialized(control)
    if Addon and Addon.Alerts and Addon.Alerts.Initialize then
        Addon.Alerts.Initialize(control)
    end
end

function TheSynapticRegistry_Diagnostics_OnInitialized(control)
    if Addon and Addon.Diagnostics and Addon.Diagnostics.Initialize then
        Addon.Diagnostics.Initialize(control)
    end
end

