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
    local function dropdown(name,key,choices,tip,values,disabled) return {type="dropdown",name=name,tooltip=tip,choices=choices,choicesValues=values,getFunc=function() return CH.sv[key] end,setFunc=function(v) apply(key,v) end,default=CH.defaults[key],disabled=disabled} end
    local options = {
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
        check("Imminent expiration alerts", "expirationAlerts", "When enabled, positive timers turn red and pulse around their icon at three seconds or less. Negative effects such as Balance are excluded."),
        dropdown("Inside timer thickness", "insideTimerStyle", {"Thin","Thick"}, "Shared by every tracker assigned to an inside position."),
        dropdown("Outside timer thickness", "outsideTimerStyle", {"Thin","Thick"}, "Shared by every tracker assigned to an outside position."),
        slider("Resource value font size", "resourceValueFontSize", 16, 42, 1), slider("Resource percent font size", "resourcePercentFontSize", 14, 34, 1),
        check("Show raw values", "showRaw"), check("Show maximum values", "showMaximum"), check("Show percentages", "showPercent"),
    }
    local function standardControls(definition,tip)
        local key=definition.key
        local positionControl
        if definition.stackOnly then
            positionControl=dropdown(definition.label.." quadrant","cruxQuadrant",CH.cruxQuadrantNames,"Uses the outside slot for stack count and the matching inside slot for expiration time.",CH.cruxQuadrantValues,function() return not CH.sv[key.."Enabled"] end)
        else
            positionControl=dropdown(definition.label.." position",key.."Slot",CH.trackerSlotNames,"Choose one of the eight timer/stack positions.",CH.trackerSlotValues,function() return not CH.sv[key.."Enabled"] end)
        end
        return {
            check("Track "..definition.label,key.."Enabled",tip or "Tracks the meaningful duration or stack window for this skill family."),
            positionControl,
            dropdown(definition.label.." color",key.."Color",CH.colorChoices,nil,nil,function() return not CH.sv[key.."Enabled"] end),
        }
    end
    local function append(target,source) for _,control in ipairs(source) do target[#target+1]=control end end
    local function submenu(name,controls) options[#options+1]={type="submenu",name=name,controls=controls} end
    local headerIndex=0
    local function header(name)
        headerIndex=headerIndex+1
        options[#options+1]={
            type="header",
            name="|c45CFFF"..name.."|r",
            width="full",
            reference="CurvedHUD_CategoryHeader_"..headerIndex,
        }
    end
    local function categoryRow(name)
        -- The console LAM build reparents header/description controls that
        -- follow a submenu into that preceding submenu. Submenu controls are
        -- the only reliable top-level rows after the first submenu, so later
        -- category separators intentionally use a colored, informational row.
        submenu("|c45CFFF"..name.."|r",{
            {type="description",text="The expandable tracker submenus for this character-specific category are listed directly below."},
        })
    end
    local function addScribingControls(target,definition)
        append(target,standardControls(definition))
        local key=definition.key
        target[#target+1]={type="slider",name=definition.label.." fallback duration",tooltip="Used only when ESO reports no duration for the current scripts.",min=1,max=120,step=1,getFunc=function() return CH.sv[key.."Duration"] end,setFunc=function(v) apply(key.."Duration",v) end,default=CH.defaults[key.."Duration"],disabled=function() return not CH.sv[key.."Enabled"] end}
    end
    local globalControls={
        dropdown("Lower-left major buff","majorBuffTracked",CH.majorBuffChoices,"Select the standardized Major buff tracked by the lower-left outside timer."),
        dropdown("Major buff timer color","majorBuffColor",CH.colorChoices),check("Track Balance debuff","balanceEnabled"),
        dropdown("Balance position","balanceSlot",CH.trackerSlotNames,"Choose the quadrant and its inside/outside timer position.",CH.trackerSlotValues,function() return not CH.sv.balanceEnabled end),
        dropdown("Balance timer color","balanceColor",CH.colorChoices,nil,nil,function() return not CH.sv.balanceEnabled end),
    }
    header("GLOBAL TIMERS - CHARACTER SPECIFIC")
    submenu("Global",globalControls)
    categoryRow("CLASS TIMERS - CHARACTER SPECIFIC")
    local sorc={
        check("Track Bound Aegis","aegisEnabled"),dropdown("Bound Aegis position","aegisSlot",CH.trackerSlotNames,"Choose one of the eight timer positions.",CH.trackerSlotValues,function() return not CH.sv.aegisEnabled end),dropdown("Bound Aegis color","aegisColor",CH.colorChoices,nil,nil,function() return not CH.sv.aegisEnabled end),
        check("Track Bound Armaments","armamentsEnabled","Shows its current weapon count over the skill icon."),dropdown("Bound Armaments position","armamentsSlot",CH.trackerSlotNames,"Choose one of the eight timer/stack positions.",CH.trackerSlotValues,function() return not CH.sv.armamentsEnabled end),dropdown("Bound Armaments color","armamentsColor",CH.colorChoices,nil,nil,function() return not CH.sv.armamentsEnabled end),
        check("Show Crystal Fragments proc","fragmentsEnabled"),dropdown("Crystal Fragments proc position","fragmentsPosition",CH.procPositionChoices,nil,nil,function() return not CH.sv.fragmentsEnabled end),
        {type="slider",name="Crystal Fragments proc size",min=.35,max=1.5,step=.05,getFunc=function() return CH.sv.fragmentsScale end,setFunc=function(v) apply("fragmentsScale",v) end,default=CH.defaults.fragmentsScale,disabled=function() return not CH.sv.fragmentsEnabled end},
        check("Track Critical Surge","surgeEnabled"),dropdown("Critical Surge position","surgeSlot",CH.trackerSlotNames,nil,CH.trackerSlotValues,function() return not CH.sv.surgeEnabled end),dropdown("Critical Surge color","surgeColor",CH.colorChoices,nil,nil,function() return not CH.sv.surgeEnabled end),
        check("Track Vibrant Shroud / Encase","shroudEnabled"),dropdown("Shroud / Encase position","shroudSlot",CH.trackerSlotNames,nil,CH.trackerSlotValues,function() return not CH.sv.shroudEnabled end),dropdown("Shroud / Encase color","shroudColor",CH.colorChoices,nil,nil,function() return not CH.sv.shroudEnabled end),
    }
    for _,definition in ipairs(CH.sorcererTrackerDefinitions) do append(sorc,standardControls(definition,"Tracks every base ability and morph in this Sorcerer skill family.")) end
    submenu("Sorcerer",sorc)
    local warden={}; for _,definition in ipairs(CH.wardenTrackerDefinitions) do append(warden,standardControls(definition,definition.key=="shalk" and "Counts through both eruptions and reaches zero when Shalks should be recast." or nil)) end; submenu("Warden",warden)
    local arcanist={}; for _,definition in ipairs(CH.arcanistTrackerDefinitions) do append(arcanist,standardControls(definition,definition.stackOnly and "Uses a full quadrant: outside shows 1-3 Crux stacks and inside counts down their expiration." or nil)) end; submenu("Arcanist",arcanist)
    for _,group in ipairs(CH.remainingClassDefinitionGroups) do
        local controls={}
        for _,definition in ipairs(group.definitions) do
            local tip=definition.stackMaximum and ("Shows the current stacks (maximum "..definition.stackMaximum..") and the remaining stack window.") or "Tracks every base ability and morph in this class skill family."
            append(controls,standardControls(definition,tip))
        end
        submenu(group.name,controls)
    end
    categoryRow("WEAPON TIMERS - CHARACTER SPECIFIC")
    local function addSkillLineSubmenu(line,lines)
        local controls={}
        for _,definition in ipairs(CH.nonClassTrackerDefinitions) do
            local match=lines and lines[definition.line] or definition.line==line
            if match then append(controls,standardControls(definition)) end
        end
        for _,definition in ipairs(CH.scribingTrackerDefinitions) do
            local mapped=CH.scribingSkillLineByKey[definition.key]; local match=lines and lines[mapped] or mapped==line
            if match then addScribingControls(controls,definition) end
        end
        submenu(line,controls)
    end
    for _,line in ipairs(CH.weaponSkillLines) do addSkillLineSubmenu(line) end
    categoryRow("GUILD / VAMPIRE / WEREWOLF TIMERS - CHARACTER SPECIFIC")
    for _,line in ipairs(CH.otherSkillLines) do addSkillLineSubmenu(line) end
    addSkillLineSubmenu("Armor",{["Light Armor"]=true,["Medium Armor"]=true,["Heavy Armor"]=true})
    LAM:RegisterOptionControls(panelName,options)
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
    local function dropdown(label,key,choices,tooltip,values,disabled)
        local items={}; for index,choice in ipairs(choices) do items[#items+1]={name=choice,data=values and values[index] or choice} end
        local function displayValue(value)
            if values then for index,data in ipairs(values) do if data==value then return choices[index] end end end
            return value
        end
        panel:AddSetting({type=HAS.ST_DROPDOWN,label=label,tooltip=tooltip,items=items,getFunction=function() return displayValue(CH.sv[key]) end,setFunction=function(_,name,item) apply(key,(item and item.data) or name) end,default=displayValue(CH.defaults[key]),disable=disabled})
    end
    local function title(label) panel:AddSetting({type=HAS.ST_SECTION or HAS.ST_LABEL,label=label}) end
    checkbox("Enabled","enabled"); checkbox("Preview mode","preview"); checkbox("Show default ESO resource bars","showDefaultResources"); checkbox("Use out-of-combat opacity","useOutOfCombatOpacity")
    panel:AddSetting({type=HAS.ST_SLIDER,label="Out-of-combat opacity",min=0.05,max=1,step=0.05,getFunction=function() return CH.sv.outOfCombatOpacity end,setFunction=function(v) apply("outOfCombatOpacity",v) end,default=CH.defaults.outOfCombatOpacity,disable=function() return not CH.sv.useOutOfCombatOpacity end})
    checkbox("Stamina inside / top","staminaInside"); checkbox("Debug chat logging","debug")
    panel:AddSetting({type=HAS.ST_DROPDOWN,label="Right resource layout",items={{name="Parallel",data="Parallel"},{name="Stacked",data="Stacked"}},getFunction=function() return CH.sv.layout end,setFunction=function(_,name,item) apply("layout",(item and item.data) or name) end,default=CH.defaults.layout})
    slider("HUD scale","scale",0.5,1.5,0.05); slider("Character spacing","spacing",100,450,5); slider("Vertical offset","verticalOffset",-250,250,5)
    panel:AddSetting({type=HAS.ST_SLIDER,label="Buff/debuff vertical offset",tooltip="Active when the default ESO resource bars are hidden.",min=-750,max=750,step=5,getFunction=function() return CH.sv.buffVerticalOffset end,setFunction=function(v) apply("buffVerticalOffset",v) end,default=CH.defaults.buffVerticalOffset,disable=function() return CH.sv.showDefaultResources end})
    slider("Parallel gap","resourceGap",0,80,1); slider("Bar width","barWidth",24,80,1); slider("Fill opacity","fillAlpha",0.1,1,0.05)
    slider("Tracker timer font size","timerFontSize",16,36,1)
    checkbox("Imminent expiration alerts","expirationAlerts")
    dropdown("Inside timer thickness","insideTimerStyle",{"Thin","Thick"},"Shared by every tracker assigned to an inside position.")
    dropdown("Outside timer thickness","outsideTimerStyle",{"Thin","Thick"},"Shared by every tracker assigned to an outside position.")
    slider("Resource value font size","resourceValueFontSize",16,42,1); slider("Resource percent font size","resourcePercentFontSize",14,34,1)
    checkbox("Show raw values","showRaw"); checkbox("Show maximum values","showMaximum"); checkbox("Show percentages","showPercent")
    title("GLOBAL TIMERS - CHARACTER SPECIFIC")
    dropdown("Lower-left major buff","majorBuffTracked",CH.majorBuffChoices,"Select the standardized Major buff tracked by the lower-left outside timer.")
    dropdown("Major buff timer color","majorBuffColor",CH.colorChoices)
    checkbox("Track Balance debuff","balanceEnabled")
    dropdown("Balance position","balanceSlot",CH.trackerSlotNames,"Choose the quadrant and its inside/outside timer position.",CH.trackerSlotValues,function() return not CH.sv.balanceEnabled end)
    dropdown("Balance timer color","balanceColor",CH.colorChoices,nil,nil,function() return not CH.sv.balanceEnabled end)
    title("CLASS TIMERS - CHARACTER SPECIFIC")
    title("SORCERER")
    checkbox("Track Bound Aegis","aegisEnabled")
    dropdown("Bound Aegis position","aegisSlot",CH.trackerSlotNames,"Choose the quadrant and its inside/outside timer position.",CH.trackerSlotValues,function() return not CH.sv.aegisEnabled end)
    dropdown("Bound Aegis timer color","aegisColor",CH.colorChoices,nil,nil,function() return not CH.sv.aegisEnabled end)
    checkbox("Track Bound Armaments","armamentsEnabled")
    dropdown("Bound Armaments position","armamentsSlot",CH.trackerSlotNames,"Choose one of the eight timer/stack positions.",CH.trackerSlotValues,function() return not CH.sv.armamentsEnabled end)
    dropdown("Bound Armaments timer color","armamentsColor",CH.colorChoices,nil,nil,function() return not CH.sv.armamentsEnabled end)
    checkbox("Show Crystal Fragments proc","fragmentsEnabled")
    dropdown("Crystal Fragments proc position","fragmentsPosition",CH.procPositionChoices,"Top, Right, Bottom, and Left use HUD-relative presets; Center uses the middle of the screen.",nil,function() return not CH.sv.fragmentsEnabled end)
    panel:AddSetting({type=HAS.ST_SLIDER,label="Crystal Fragments proc size",min=.35,max=1.5,step=.05,getFunction=function() return CH.sv.fragmentsScale end,setFunction=function(v) apply("fragmentsScale",v) end,default=CH.defaults.fragmentsScale,disable=function() return not CH.sv.fragmentsEnabled end})
    checkbox("Track Critical Surge","surgeEnabled")
    dropdown("Critical Surge position","surgeSlot",CH.trackerSlotNames,"Choose one of the eight timer positions.",CH.trackerSlotValues,function() return not CH.sv.surgeEnabled end)
    dropdown("Critical Surge timer color","surgeColor",CH.colorChoices,nil,nil,function() return not CH.sv.surgeEnabled end)
    checkbox("Track Vibrant Shroud / Encase","shroudEnabled")
    dropdown("Shroud / Encase position","shroudSlot",CH.trackerSlotNames,"Choose one of the eight timer positions.",CH.trackerSlotValues,function() return not CH.sv.shroudEnabled end)
    dropdown("Shroud / Encase timer color","shroudColor",CH.colorChoices,nil,nil,function() return not CH.sv.shroudEnabled end)
    for _,definition in ipairs(CH.sorcererTrackerDefinitions) do
        local key=definition.key
        checkbox("Track "..definition.label,key.."Enabled")
        dropdown(definition.label.." position",key.."Slot",CH.trackerSlotNames,"Choose one of the eight timer positions.",CH.trackerSlotValues,function() return not CH.sv[key.."Enabled"] end)
        dropdown(definition.label.." timer color",key.."Color",CH.colorChoices,nil,nil,function() return not CH.sv[key.."Enabled"] end)
    end
    title("WARDEN")
    for _,definition in ipairs(CH.wardenTrackerDefinitions) do
        local key=definition.key
        checkbox("Track "..definition.label,key.."Enabled")
        dropdown(definition.label.." position",key.."Slot",CH.trackerSlotNames,"Choose one of the eight timer positions.",CH.trackerSlotValues,function() return not CH.sv[key.."Enabled"] end)
        dropdown(definition.label.." timer color",key.."Color",CH.colorChoices,nil,nil,function() return not CH.sv[key.."Enabled"] end)
    end
    title("ARCANIST")
    for _,definition in ipairs(CH.arcanistTrackerDefinitions) do
        local key=definition.key
        checkbox("Track "..definition.label,key.."Enabled")
        if definition.stackOnly then
            dropdown(definition.label.." quadrant","cruxQuadrant",CH.cruxQuadrantNames,"Uses the outside slot for stack count and the matching inside slot for expiration time.",CH.cruxQuadrantValues,function() return not CH.sv[key.."Enabled"] end)
        else
            dropdown(definition.label.." position",key.."Slot",CH.trackerSlotNames,"Choose one of the eight timer/stack positions.",CH.trackerSlotValues,function() return not CH.sv[key.."Enabled"] end)
        end
        dropdown(definition.label.." color",key.."Color",CH.colorChoices,nil,nil,function() return not CH.sv[key.."Enabled"] end)
    end
    local function addStandardDefinition(definition)
        local key=definition.key
        checkbox("Track "..definition.label,key.."Enabled")
        dropdown(definition.label.." position",key.."Slot",CH.trackerSlotNames,"Choose one of the eight timer positions.",CH.trackerSlotValues,function() return not CH.sv[key.."Enabled"] end)
        dropdown(definition.label.." timer color",key.."Color",CH.colorChoices,nil,nil,function() return not CH.sv[key.."Enabled"] end)
    end
    for _,group in ipairs(CH.remainingClassDefinitionGroups) do
        title(group.name:upper())
        for _,definition in ipairs(group.definitions) do addStandardDefinition(definition) end
    end
    local function addScribingDefinition(definition)
        addStandardDefinition(definition)
        slider(definition.label.." fallback duration",definition.key.."Duration",1,120,1)
    end
    local function addSkillLine(line)
        title(line:upper())
        for _,definition in ipairs(CH.nonClassTrackerDefinitions) do if definition.line==line then addStandardDefinition(definition) end end
        for _,definition in ipairs(CH.scribingTrackerDefinitions) do if CH.scribingSkillLineByKey[definition.key]==line then addScribingDefinition(definition) end end
    end
    title("WEAPON TIMERS - CHARACTER SPECIFIC")
    for _,line in ipairs(CH.weaponSkillLines) do addSkillLine(line) end
    title("GUILD / VAMPIRE / WEREWOLF TIMERS - CHARACTER SPECIFIC")
    for _,line in ipairs(CH.otherSkillLines) do addSkillLine(line) end
    title("ARMOR")
    for _,definition in ipairs(CH.nonClassTrackerDefinitions) do
        for _,line in ipairs(CH.armorSkillLines) do if definition.line==line then addStandardDefinition(definition); break end end
    end
    CH:Log("LibHarvensAddonSettings settings registered")
    return true
end

function CH:RegisterSettings()
    local lam, harvens = false, false
    -- LAM supplies true collapsible submenus and is preferred when present.
    -- LibHarvens/LibVotans remains the console-safe functional fallback; it
    -- exposes section controls but does not provide nested child containers.
    local okLam, resultLam = pcall(function() return self:RegisterLAM() end)
    if okLam then lam = resultLam else self:Log("LibAddonMenu registration failed: " .. tostring(resultLam), true) end
    if not lam then
        local okHarvens, resultHarvens = pcall(function() return self:RegisterHarvens() end)
        if okHarvens then harvens = resultHarvens else self:Log("LibHarvens registration failed: " .. tostring(resultHarvens), true) end
    end
    if not lam and not harvens then self:Log("No settings library found; HUD remains active. Use /curvedhud preview for diagnostics.", true) end
end
