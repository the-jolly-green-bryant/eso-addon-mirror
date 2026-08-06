local BB=BetterBuffs
BB.Settings=BB.Settings or {}
local Settings=BB.Settings

local function AddEffectSettings(panel,effects)
    local LHAS=LibHarvensAddonSettings
    local rows={}
    for _,effect in ipairs(effects) do
        local key=effect.key
        rows[#rows+1]={type=LHAS.ST_CHECKBOX,label=effect.name,tooltip=(effect.timer and "Tracks remaining duration. " or "")..(effect.coverage and "Tracks current group coverage." or ""),getFunction=function() return BB:IsEffectEnabled(key) end,setFunction=function(value) BB:SetEffectEnabled(key,value) end}
    end
    panel:AddSettings(rows)
end

local function AddPositionSettings(panel,effectType,label)
    local LHAS=LibHarvensAddonSettings
    local saved=function() return BB.UI:GetSaved(effectType) end
    panel:AddSettings({
        {type=LHAS.ST_LABEL,label="|cFFD447"..label.."|r"},
        {type=LHAS.ST_CHECKBOX,label="Show Dashboard",getFunction=function() return saved().enabled~=false end,setFunction=function(v) saved().enabled=v; BB.UI:RefreshAll(true) end},
        {type=LHAS.ST_SLIDER,label="Scale",min=60,max=160,step=5,unit="%",getFunction=function() return zo_round((saved().scale or 1)*100) end,setFunction=function(v) saved().scale=v/100; BB.UI:ApplySettings(effectType) end},
        {type=LHAS.ST_SLIDER,label="Background Opacity",min=10,max=90,step=5,unit="%",getFunction=function() return zo_round((saved().opacity or .42)*100) end,setFunction=function(v) saved().opacity=v/100; BB.UI:ApplySettings(effectType) end},
        {type=LHAS.ST_BUTTON,buttonText="Preview",clickHandler=function() BB.UI:Preview(effectType) end},
        {type=LHAS.ST_BUTTON,buttonText="Move Up",clickHandler=function() BB.UI:Nudge(effectType,0,-BB.Constants.POSITION_STEP) end},
        {type=LHAS.ST_BUTTON,buttonText="Move Down",clickHandler=function() BB.UI:Nudge(effectType,0,BB.Constants.POSITION_STEP) end},
        {type=LHAS.ST_BUTTON,buttonText="Move Left",clickHandler=function() BB.UI:Nudge(effectType,-BB.Constants.POSITION_STEP,0) end},
        {type=LHAS.ST_BUTTON,buttonText="Move Right",clickHandler=function() BB.UI:Nudge(effectType,BB.Constants.POSITION_STEP,0) end},
        {type=LHAS.ST_BUTTON,buttonText="Reset Position",clickHandler=function() BB.UI:ResetPosition(effectType) end},
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
        {type=LHAS.ST_LABEL,label="Effect tracking and dashboard technology developed from the Conductor project."},
        {type=LHAS.ST_LABEL,label="Version "..BB.version},
        {type=LHAS.ST_CHECKBOX,label="Enable Better Buffs",getFunction=function() return BB.saved.enabled end,setFunction=function(v) BB:SetEnabled(v) end},
        {type=LHAS.ST_CHECKBOX,label="Show Uptime Results in Chat",tooltip="Prints uptime for enabled effects after combat lasting at least five seconds.",getFunction=function() return BB.saved.uptime.enabled~=false end,setFunction=function(v) BB.saved.uptime.enabled=v==true end},
    })
    panel:AddSettings({{type=LHAS.ST_SECTION,label="Buffs"},{type=LHAS.ST_LABEL,label="Choose the buffs shown on the Better Buffs dashboard. Effects can show duration, group coverage, or both."}})
    AddEffectSettings(panel,BB.Registry.buffs)
    panel:AddSettings({{type=LHAS.ST_SECTION,label="Debuffs"},{type=LHAS.ST_LABEL,label="Choose the target-aware enemy debuffs shown on the Better Debuffs dashboard."}})
    AddEffectSettings(panel,BB.Registry.debuffs)
    panel:AddSettings({{type=LHAS.ST_SECTION,label="Positioning"}})
    AddPositionSettings(panel,"BUFF","Better Buffs Dashboard")
    AddPositionSettings(panel,"DEBUFF","Better Debuffs Dashboard")
end
