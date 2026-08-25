local CH = CurvedHUD

local function apply(key, value)
    CH.sv[key] = value
    CH:Guard("settings apply", function() CH:ApplyLayout() end)
end

function CH:RegisterLAM()
    local LAM = LibAddonMenu2
    if not LAM then return false end
    local panelName = "CurvedHUD_Settings"
    LAM:RegisterAddonPanel(panelName, { type = "panel", name = "CurvedHUD", displayName = "CurvedHUD", author = "CurvedHUD Project", version = CH.version, registerForRefresh = true, registerForDefaults = true })
    local function check(name, key, tip) return { type="checkbox", name=name, tooltip=tip, getFunc=function() return CH.sv[key] end, setFunc=function(v) apply(key,v) end, default=CH.defaults[key] } end
    local function slider(name,key,min,max,step) return { type="slider", name=name, min=min,max=max,step=step, getFunc=function() return CH.sv[key] end,setFunc=function(v) apply(key,v) end,default=CH.defaults[key] } end
    LAM:RegisterOptionControls(panelName, {
        {type="description", text="Core HUD loading does not depend on a settings library. Use /curvedhud preview to test rendering."},
        check("Enabled", "enabled"), check("Preview mode", "preview"), check("Show default ESO resource bars", "showDefaultResources", "When off, hides ESO's stock player resource display and lowers the self-buff row into the freed space."), check("Debug chat logging", "debug"),
        check("Use out-of-combat opacity", "useOutOfCombatOpacity", "Apply a separate overall HUD opacity while not in combat."),
        {type="slider", name="Out-of-combat opacity", min=0.05,max=1,step=0.05,getFunc=function() return CH.sv.outOfCombatOpacity end,setFunc=function(v) apply("outOfCombatOpacity",v) end,default=CH.defaults.outOfCombatOpacity,disabled=function() return not CH.sv.useOutOfCombatOpacity end},
        {type="dropdown", name="Right resource layout", choices={"Parallel","Stacked"}, getFunc=function() return CH.sv.layout end, setFunc=function(v) apply("layout",v) end, default=CH.defaults.layout},
        check("Stamina inside / top", "staminaInside"), slider("HUD scale", "scale", 0.5, 1.5, 0.05), slider("Character spacing", "spacing", 100, 450, 5),
        slider("Vertical offset", "verticalOffset", -250, 250, 5), slider("Parallel gap", "resourceGap", 0, 80, 1), slider("Bar width", "barWidth", 24, 80, 1),
        {type="slider", name="Buff/debuff vertical offset", tooltip="Active when the default ESO resource bars are hidden.", min=-750,max=750,step=5, getFunc=function() return CH.sv.buffVerticalOffset end,setFunc=function(v) apply("buffVerticalOffset",v) end,default=CH.defaults.buffVerticalOffset,disabled=function() return CH.sv.showDefaultResources end},
        slider("Fill opacity", "fillAlpha", 0.1, 1, 0.05), slider("Frame opacity", "frameAlpha", 0, 1, 0.05), slider("Background opacity", "backgroundAlpha", 0, 1, 0.05),
        slider("Tracker timer font size", "timerFontSize", 16, 36, 1),
        check("Show raw values", "showRaw"), check("Show maximum values", "showMaximum"), check("Show percentages", "showPercent"),
    })
    CH:Log("LibAddonMenu-2.0 settings registered")
    return true
end

function CH:RegisterHarvens()
    local HAS = LibHarvensAddonSettings
    if not HAS or not HAS.AddAddon then return false end
    local panel = HAS:AddAddon("CurvedHUD", { allowDefaults = true, allowRefresh = true, defaultsFunction = function() for k,v in pairs(CH.defaults) do CH.sv[k]=v end CH:ApplyLayout() end })
    if not panel or not panel.AddSetting then return false end
    local function checkbox(label,key)
        panel:AddSetting({type=HAS.ST_CHECKBOX,label=label,getFunction=function() return CH.sv[key] end,setFunction=function(v) apply(key,v) end,default=CH.defaults[key]})
    end
    local function slider(label,key,min,max,step)
        panel:AddSetting({type=HAS.ST_SLIDER,label=label,min=min,max=max,step=step,getFunction=function() return CH.sv[key] end,setFunction=function(v) apply(key,v) end,default=CH.defaults[key]})
    end
    checkbox("Enabled","enabled"); checkbox("Preview mode","preview"); checkbox("Show default ESO resource bars","showDefaultResources"); checkbox("Use out-of-combat opacity","useOutOfCombatOpacity")
    panel:AddSetting({type=HAS.ST_SLIDER,label="Out-of-combat opacity",min=0.05,max=1,step=0.05,getFunction=function() return CH.sv.outOfCombatOpacity end,setFunction=function(v) apply("outOfCombatOpacity",v) end,default=CH.defaults.outOfCombatOpacity,disable=function() return not CH.sv.useOutOfCombatOpacity end})
    checkbox("Stamina inside / top","staminaInside"); checkbox("Debug chat logging","debug")
    panel:AddSetting({type=HAS.ST_DROPDOWN,label="Right resource layout",items={{name="Parallel",data="Parallel"},{name="Stacked",data="Stacked"}},getFunction=function() return CH.sv.layout end,setFunction=function(_,name,item) apply("layout",(item and item.data) or name) end,default=CH.defaults.layout})
    slider("HUD scale","scale",0.5,1.5,0.05); slider("Character spacing","spacing",100,450,5); slider("Vertical offset","verticalOffset",-250,250,5)
    panel:AddSetting({type=HAS.ST_SLIDER,label="Buff/debuff vertical offset",tooltip="Active when the default ESO resource bars are hidden.",min=-750,max=750,step=5,getFunction=function() return CH.sv.buffVerticalOffset end,setFunction=function(v) apply("buffVerticalOffset",v) end,default=CH.defaults.buffVerticalOffset,disable=function() return CH.sv.showDefaultResources end})
    slider("Parallel gap","resourceGap",0,80,1); slider("Bar width","barWidth",24,80,1); slider("Fill opacity","fillAlpha",0.1,1,0.05)
    slider("Tracker timer font size","timerFontSize",16,36,1)
    checkbox("Show raw values","showRaw"); checkbox("Show maximum values","showMaximum"); checkbox("Show percentages","showPercent")
    CH:Log("LibHarvensAddonSettings settings registered")
    return true
end

function CH:RegisterSettings()
    local lam, harvens = false, false
    local okHarvens, resultHarvens = pcall(function() return self:RegisterHarvens() end)
    if okHarvens then harvens = resultHarvens else self:Log("LibHarvens registration failed: " .. tostring(resultHarvens), true) end
    -- Register exactly one provider. LibHarvens/LibVotans is preferred on console;
    -- LAM remains the fallback for environments where Harven's library is absent.
    if not harvens then
        local okLam, resultLam = pcall(function() return self:RegisterLAM() end)
        if okLam then lam = resultLam else self:Log("LibAddonMenu registration failed: " .. tostring(resultLam), true) end
    end
    if not lam and not harvens then self:Log("No settings library found; HUD remains active. Use /curvedhud preview for diagnostics.", true) end
end
