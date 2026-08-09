local BB=BetterBuffs
BB.Settings=BB.Settings or {}
local Settings=BB.Settings

local STYLE_ITEMS={{name="Detailed",data="DETAILED"},{name="Compact",data="COMPACT"}}
local LAYOUT_ITEMS={{name="Crescent",data="CRESCENT"},{name="Grid",data="GRID"},{name="Column",data="COLUMN"}}
local SIDE_ITEMS={{name="Left",data="LEFT"},{name="Right",data="RIGHT"}}
local SORT_ITEMS={{name="Priority",data="PRIORITY"},{name="Alphabetical",data="ALPHABETICAL"},{name="Time Remaining",data="TIME"}}

local function AddEffectSettings(panel,effects)
    local LHAS=LibHarvensAddonSettings
    local rows={}
    for _,effect in ipairs(effects) do
        local key=effect.key
        local tooltip=(effect.timer and "Tracks remaining duration. " or "")..(effect.coverage and "Tracks group coverage. " or "")
        if effect.intelligenceMode=="RECIPIENT_COOLDOWN" then tooltip=tooltip.."Tracks recipient eligibility/cooldown from verified combat events." end
        rows[#rows+1]={type=LHAS.ST_CHECKBOX,label=effect.name,tooltip=tooltip,getFunction=function() return BB:IsEffectEnabled(key) end,setFunction=function(value) BB:SetEffectEnabled(key,value) end}
    end
    panel:AddSettings(rows)
end

local function AddDisplaySettings(panel,effectType,label)
    local LHAS=LibHarvensAddonSettings
    local saved=function() return BB.UI:GetSaved(effectType) end
    panel:AddSettings({
        {type=LHAS.ST_SECTION,label=label},
        {type=LHAS.ST_CHECKBOX,label="Show Display",getFunction=function() return saved().enabled~=false end,setFunction=function(v) saved().enabled=v; BB.UI:RefreshAll(true) end},
        {type=LHAS.ST_DROPDOWN,label="Display Style",items=function() return STYLE_ITEMS end,getFunction=function() return {data=saved().style or "DETAILED"} end,setFunction=function(_,_,data) saved().style=data.data; BB.UI:ApplySettings(effectType) end},
        {type=LHAS.ST_DROPDOWN,label="Compact Layout",items=function() return LAYOUT_ITEMS end,getFunction=function() return {data=saved().compactLayout or "CRESCENT"} end,setFunction=function(_,_,data) saved().compactLayout=data.data; BB.UI:ApplySettings(effectType) end},
        {type=LHAS.ST_DROPDOWN,label="Crescent Side",items=function() return SIDE_ITEMS end,getFunction=function() return {data=saved().crescentSide or (effectType=="BUFF" and "LEFT" or "RIGHT")} end,setFunction=function(_,_,data) saved().crescentSide=data.data; BB.UI:ApplySettings(effectType) end},
        {type=LHAS.ST_DROPDOWN,label="Sort Order",items=function() return SORT_ITEMS end,getFunction=function() return {data=saved().sortOrder or "PRIORITY"} end,setFunction=function(_,_,data) saved().sortOrder=data.data; BB.UI:RefreshPanel(effectType,true) end},
        {type=LHAS.ST_SLIDER,label="Scale",min=60,max=160,step=5,unit="%",getFunction=function() return zo_round((saved().scale or 1)*100) end,setFunction=function(v) saved().scale=v/100; BB.UI:ApplySettings(effectType) end},
        {type=LHAS.ST_SLIDER,label="Background Opacity",min=5,max=90,step=5,unit="%",getFunction=function() return zo_round((saved().opacity or .42)*100) end,setFunction=function(v) saved().opacity=v/100; BB.UI:ApplySettings(effectType) end},
        {type=LHAS.ST_SLIDER,label="Compact Tile Size",min=42,max=90,step=2,getFunction=function() return saved().tileSize or 58 end,setFunction=function(v) saved().tileSize=v; BB.UI:RefreshPanel(effectType,true) end},
        {type=LHAS.ST_SLIDER,label="Tile Spacing",min=0,max=30,step=1,getFunction=function() return saved().tileSpacing or 10 end,setFunction=function(v) saved().tileSpacing=v; BB.UI:RefreshPanel(effectType,true) end},
        {type=LHAS.ST_SLIDER,label="Icons Per Row",min=1,max=8,step=1,getFunction=function() return saved().iconsPerRow or 4 end,setFunction=function(v) saved().iconsPerRow=v; BB.UI:RefreshPanel(effectType,true) end},
        {type=LHAS.ST_SLIDER,label="Crescent Curve Depth",min=0,max=140,step=5,getFunction=function() return saved().curveDepth or 54 end,setFunction=function(v) saved().curveDepth=v; BB.UI:RefreshPanel(effectType,true) end},
        {type=LHAS.ST_SLIDER,label="Crescent Vertical Spread",min=30,max=120,step=2,getFunction=function() return saved().verticalSpread or 66 end,setFunction=function(v) saved().verticalSpread=v; BB.UI:RefreshPanel(effectType,true) end},
        {type=LHAS.ST_BUTTON,buttonText="Preview Display",clickHandler=function() BB.UI:Preview(effectType) end},
        {type=LHAS.ST_BUTTON,buttonText="Move Up",clickHandler=function() BB.UI:Nudge(effectType,0,-BB.Constants.POSITION_STEP) end},
        {type=LHAS.ST_BUTTON,buttonText="Move Down",clickHandler=function() BB.UI:Nudge(effectType,0,BB.Constants.POSITION_STEP) end},
        {type=LHAS.ST_BUTTON,buttonText="Move Left",clickHandler=function() BB.UI:Nudge(effectType,-BB.Constants.POSITION_STEP,0) end},
        {type=LHAS.ST_BUTTON,buttonText="Move Right",clickHandler=function() BB.UI:Nudge(effectType,BB.Constants.POSITION_STEP,0) end},
        {type=LHAS.ST_BUTTON,buttonText="Restore Default Position",clickHandler=function() BB.UI:ResetPosition(effectType) end},
    })
end

function Settings:Initialize()
    local LHAS=LibHarvensAddonSettings
    if not LHAS then return end
    local panel=LHAS:AddAddon(BB.displayName,{allowRefresh=true})
    if not panel then return end
    panel:AddSettings({
        {type=LHAS.ST_LABEL,label="|cFFD447BETTER BUFFS|r"},
        {type=LHAS.ST_LABEL,label="|cFFD447Created by BMGxSancho|r"},
        {type=LHAS.ST_LABEL,label="Raid Effect Intelligence for organized PvE."},
        {type=LHAS.ST_LABEL,label="Version "..BB.version},
        {type=LHAS.ST_CHECKBOX,label="Enable Better Buffs",getFunction=function() return BB.saved.enabled end,setFunction=function(v) BB:SetEnabled(v) end},
    })
    panel:AddSettings({{type=LHAS.ST_SECTION,label="Buffs"},{type=LHAS.ST_LABEL,label="Choose the buffs and support-effect intelligence shown by Better Buffs."}})
    AddEffectSettings(panel,BB.Registry.buffs)
    panel:AddSettings({{type=LHAS.ST_SECTION,label="Debuffs"},{type=LHAS.ST_LABEL,label="Choose the target-aware enemy debuffs shown by Better Debuffs."}})
    AddEffectSettings(panel,BB.Registry.debuffs)
    AddDisplaySettings(panel,"BUFF","Buff Display")
    AddDisplaySettings(panel,"DEBUFF","Debuff Display")
    panel:AddSettings({
        {type=LHAS.ST_SECTION,label="Analytics"},
        {type=LHAS.ST_CHECKBOX,label="Show Encounter Results in Chat",tooltip="Prints event-driven uptime, applications, longest gap, and coverage metrics after encounters lasting at least five seconds.",getFunction=function() return BB.saved.uptime.enabled~=false end,setFunction=function(v) BB.saved.uptime.enabled=v==true end},
        {type=LHAS.ST_CHECKBOX,label="Show Advanced Coverage Metrics",getFunction=function() return BB.saved.uptime.showAdvanced~=false end,setFunction=function(v) BB.saved.uptime.showAdvanced=v==true end},
        {type=LHAS.ST_SECTION,label="Advanced"},
        {type=LHAS.ST_CHECKBOX,label="READY Highlight",tooltip="Briefly brightens a compact tile when it transitions to READY, then leaves a steady gold border.",getFunction=function() return BB.saved.advanced.readyAnimation~=false end,setFunction=function(v) BB.saved.advanced.readyAnimation=v==true end},
    })
end
