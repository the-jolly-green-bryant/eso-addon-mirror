local BB=BetterBuffs
BB.Settings=BB.Settings or {}
local Settings=BB.Settings

local STYLE_ITEMS={{name="Detailed",data="DETAILED"},{name="Compact",data="COMPACT"}}
local LAYOUT_ITEMS={{name="Crescent",data="CRESCENT"},{name="Grid",data="GRID"},{name="Column",data="COLUMN"}}
local SIDE_ITEMS={{name="Left",data="LEFT"},{name="Right",data="RIGHT"}}
local SORT_ITEMS={{name="Priority",data="PRIORITY"},{name="Alphabetical",data="ALPHABETICAL"},{name="Time Remaining",data="TIME"}}
local VISIBILITY_ITEMS={{name="Auto",data="AUTO"},{name="Always",data="ALWAYS"},{name="Hidden",data="HIDDEN"}}
local STATS_VISIBILITY_ITEMS={{name="Self",data="SELF"},{name="Group (Future)",data="GROUP"},{name="Hidden",data="HIDDEN"}}

local function LeaveDisplayPositioning()
    if BB.UI then BB.UI:HideAllPositioningPreviews() end
end

local function SectionIntro(text)
    return function()
        if IsInGamepadPreferredMode and IsInGamepadPreferredMode() then LeaveDisplayPositioning() end
        return text
    end
end

local function AddEffectSettings(panel,effects,predicate)
    local LHAS=LibHarvensAddonSettings
    local rows={}
    for _,effect in ipairs(effects) do
        if not predicate or predicate(effect) then
        local key=effect.key
        local tooltip=(effect.timer and "Tracks remaining duration. " or "")..(effect.coverage and "Tracks group coverage. " or "")
        if effect.intelligenceMode=="RECIPIENT_COOLDOWN" then tooltip=tooltip.."Tracks recipient eligibility/cooldown from verified combat events. " end
        tooltip=tooltip.."Visibility: Auto lets Better Buffs show the effect when its registry confirms it is relevant to your current setup. Always keeps it visible. Hidden never shows it on the dashboard."
        if effect.autoTrackWhenEquipped or #(effect.autoProviderSets or {})>0 or #(effect.autoProviderAbilityIds or {})>0 or #(effect.autoProviderAbilityNames or {})>0 or effect.autoGroupEffect then tooltip=tooltip.." Auto can use equipped providers, slotted skills, and live group-effect relevance for this effect." end
        rows[#rows+1]={type=LHAS.ST_DROPDOWN,label=effect.name,tooltip=tooltip,items=function() return VISIBILITY_ITEMS end,getFunction=function() return {data=BB:GetEffectVisibilityMode(key)} end,setFunction=function(_,_,data) BB:SetEffectVisibilityMode(key,data.data) end}
        end
    end
    panel:AddSettings(rows)
end

local function AddDisplaySettings(panel,effectType,label)
    local LHAS=LibHarvensAddonSettings
    local saved=function() return BB.UI:GetSaved(effectType) end
    local show=function(duration) BB.UI:ShowForPositioning(effectType,duration or 20000) end
    panel:AddSettings({
        {type=LHAS.ST_SECTION,label=label},
        {type=LHAS.ST_CHECKBOX,label="Show Display",getFunction=function() if IsInGamepadPreferredMode and IsInGamepadPreferredMode() then show(0) end; return saved().enabled~=false end,setFunction=function(v) saved().enabled=v; show(); BB.UI:RefreshAll(true) end},
        {type=LHAS.ST_DROPDOWN,label="Display Style",items=function() return STYLE_ITEMS end,getFunction=function() return {data=saved().style or "COMPACT"} end,setFunction=function(_,_,data) saved().style=data.data; show(); BB.UI:ApplySettings(effectType) end},
        {type=LHAS.ST_DROPDOWN,label="Compact Layout",items=function() return LAYOUT_ITEMS end,getFunction=function() return {data=saved().compactLayout or "GRID"} end,setFunction=function(_,_,data) saved().compactLayout=data.data; show(); BB.UI:ApplySettings(effectType) end},
        {type=LHAS.ST_LABEL,label="Compact Icons: the outer ring shows ACTIVE effect duration (green to yellow to red). The center number shows active time remaining, or cooldown time when unavailable. Gold means READY. Gray means inactive or cooling down."},
        {type=LHAS.ST_DROPDOWN,label="Crescent Side",items=function() return SIDE_ITEMS end,getFunction=function() return {data=saved().crescentSide or (effectType=="BUFF" and "LEFT" or "RIGHT")} end,setFunction=function(_,_,data) saved().crescentSide=data.data; show(); BB.UI:ApplySettings(effectType) end},
        {type=LHAS.ST_DROPDOWN,label="Sort Order",items=function() return SORT_ITEMS end,getFunction=function() return {data=saved().sortOrder or "PRIORITY"} end,setFunction=function(_,_,data) saved().sortOrder=data.data; show(); BB.UI:RefreshPanel(effectType,true) end},
        {type=LHAS.ST_SLIDER,label="Scale",min=60,max=160,step=5,unit="%",getFunction=function() return zo_round((saved().scale or 1)*100) end,setFunction=function(v) saved().scale=v/100; show(); BB.UI:ApplySettings(effectType) end},
        {type=LHAS.ST_SLIDER,label="Background Opacity",min=5,max=90,step=5,unit="%",getFunction=function() return zo_round((saved().opacity or .42)*100) end,setFunction=function(v) saved().opacity=v/100; show(); BB.UI:ApplySettings(effectType) end},
        {type=LHAS.ST_SLIDER,label="Compact Tile Size",min=42,max=90,step=2,getFunction=function() return saved().tileSize or 58 end,setFunction=function(v) saved().tileSize=v; show(); BB.UI:RefreshPanel(effectType,true) end},
        {type=LHAS.ST_SLIDER,label="Tile Spacing",min=0,max=30,step=1,getFunction=function() return saved().tileSpacing or 10 end,setFunction=function(v) saved().tileSpacing=v; show(); BB.UI:RefreshPanel(effectType,true) end},
        {type=LHAS.ST_SLIDER,label="Icons Per Row",min=1,max=8,step=1,getFunction=function() return saved().iconsPerRow or 4 end,setFunction=function(v) saved().iconsPerRow=v; show(); BB.UI:RefreshPanel(effectType,true) end},
        {type=LHAS.ST_SLIDER,label="Crescent Curve Depth",min=0,max=140,step=5,getFunction=function() return saved().curveDepth or 54 end,setFunction=function(v) saved().curveDepth=v; show(); BB.UI:RefreshPanel(effectType,true) end},
        {type=LHAS.ST_SLIDER,label="Crescent Vertical Spread",min=30,max=120,step=2,getFunction=function() return saved().verticalSpread or 66 end,setFunction=function(v) saved().verticalSpread=v; show(); BB.UI:RefreshPanel(effectType,true) end},
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
    local originalCleanUp=panel.CleanUp
    if originalCleanUp then
        panel.CleanUp=function(self,...)
            LeaveDisplayPositioning()
            if BB.UI then BB.UI:HideSlayerMissAlert() end
            if BB.Stats then BB.Stats:HideAllPreviews() end
            return originalCleanUp(self,...)
        end
    end
    panel:AddSettings({
        {type=LHAS.ST_LABEL,label="|cFFD447BETTER BUFFS|r\n|cFFD447Created by BMGxSancho|r\nRaid Effect Intelligence for organized PvE.\nEffect selections and HUD layouts are saved separately for each character.\nVersion "..BB.version},
        {type=LHAS.ST_CHECKBOX,label="Enable Better Buffs",getFunction=function() return BB.saved.enabled end,setFunction=function(v) BB:SetEnabled(v) end},
    })
    panel:AddSettings({{type=LHAS.ST_SECTION,label="Buffs"},{type=LHAS.ST_LABEL,label=SectionIntro("Choose how each non-gear buff appears: Auto shows it when Better Buffs can confirm it is relevant to your current setup, Always keeps it visible, and Hidden never displays it.")}})
    AddEffectSettings(panel,BB.Registry.buffs,function(effect) return effect.menuCategory ~= "GEAR" end)
    panel:AddSettings({{type=LHAS.ST_SECTION,label="Debuffs"},{type=LHAS.ST_LABEL,label=SectionIntro("Choose how each non-gear debuff appears: Auto shows it when Better Buffs can confirm it is relevant to your current setup, Always keeps it visible, and Hidden never displays it.")}})
    AddEffectSettings(panel,BB.Registry.debuffs,function(effect) return effect.menuCategory ~= "GEAR" end)
    panel:AddSettings({{type=LHAS.ST_SECTION,label="Gear Sets"},{type=LHAS.ST_LABEL,label=SectionIntro("Gear-set and Mythic effects live here. Auto uses Better Buffs' existing loadout intelligence when a supported set is equipped or its effect becomes relevant.")}})
    AddEffectSettings(panel,BB.Registry.gearSets)
    AddDisplaySettings(panel,"BUFF","Buff Display")
    AddDisplaySettings(panel,"DEBUFF","Debuff Display")
    panel:AddSettings({
        {type=LHAS.ST_SECTION,label="Analytics"},
        {type=LHAS.ST_DROPDOWN,label="Stats Module",tooltip="Self shows your live Current Pen, Crit Chance, and Crit Damage. Group is reserved for future Better Buffs-to-Better Buffs stat sharing and does not display group data in this release. Hidden disables the module.",items=function() return STATS_VISIBILITY_ITEMS end,getFunction=function() return {data=BB.Stats:GetVisibility()} end,setFunction=function(_,_,data) BB.Stats:SetVisibility(data.data); if data.data=="SELF" then BB.Stats:ShowPreview() else BB.Stats:HidePreview() end end},
        {type=LHAS.ST_LABEL,label="Stats colors: yellow = below the useful cap, green = within +/-5% of cap, red = above that range. Current Pen is personal penetration plus verified resistance reductions active on the current boss. An asterisk means a variable-strength reduction such as Crusher or Alkosh is active, so Better Buffs will not guess the missing amount."},
        {type=LHAS.ST_SLIDER,label="Stats Module Scale",min=60,max=160,step=5,unit="%",getFunction=function() return zo_round((BB.saved.ui.stats.scale or 1)*100) end,setFunction=function(v) BB.Stats:SetScale(v/100) end},
        {type=LHAS.ST_SLIDER,label="Stats Module Opacity",min=5,max=90,step=5,unit="%",getFunction=function() return zo_round((BB.saved.ui.stats.opacity or .34)*100) end,setFunction=function(v) BB.Stats:SetOpacity(v/100) end},
        {type=LHAS.ST_BUTTON,buttonText="Preview Stats Module",clickHandler=function() BB.Stats:ShowPreview() end},
        {type=LHAS.ST_BUTTON,buttonText="Stats Module Up",clickHandler=function() BB.Stats:Nudge(0,-BB.Constants.POSITION_STEP) end},
        {type=LHAS.ST_BUTTON,buttonText="Stats Module Down",clickHandler=function() BB.Stats:Nudge(0,BB.Constants.POSITION_STEP) end},
        {type=LHAS.ST_BUTTON,buttonText="Stats Module Left",clickHandler=function() BB.Stats:Nudge(-BB.Constants.POSITION_STEP,0) end},
        {type=LHAS.ST_BUTTON,buttonText="Stats Module Right",clickHandler=function() BB.Stats:Nudge(BB.Constants.POSITION_STEP,0) end},
        {type=LHAS.ST_BUTTON,buttonText="Restore Stats Module Position",clickHandler=function() BB.Stats:ResetPosition() end},

        {type=LHAS.ST_LABEL,label="|cFFD447WEAPON & SPELL DAMAGE|r"},
        {type=LHAS.ST_CHECKBOX,label="Show Weapon & Spell Damage",tooltip="Shows your current Weapon Damage and Spell Damage in a Better Buffs branded movable HUD panel.",getFunction=function() return BB.saved.ui.damageStats.enabled==true end,setFunction=function(v) BB.Stats:SetDamageEnabled(v); if v then BB.Stats:ShowDamagePreview() else BB.Stats:HideDamagePreview() end end},
        {type=LHAS.ST_SLIDER,label="Weapon & Spell Damage Scale",min=60,max=160,step=5,unit="%",getFunction=function() return zo_round((BB.saved.ui.damageStats.scale or 1)*100) end,setFunction=function(v) BB.Stats:SetDamageScale(v/100) end},
        {type=LHAS.ST_SLIDER,label="Weapon & Spell Damage Opacity",min=5,max=90,step=5,unit="%",getFunction=function() return zo_round((BB.saved.ui.damageStats.opacity or .34)*100) end,setFunction=function(v) BB.Stats:SetDamageOpacity(v/100) end},
        {type=LHAS.ST_BUTTON,buttonText="Preview Weapon & Spell Damage",clickHandler=function() BB.Stats:ShowDamagePreview() end},
        {type=LHAS.ST_BUTTON,buttonText="Damage Module Up",clickHandler=function() BB.Stats:NudgeDamage(0,-BB.Constants.POSITION_STEP) end},
        {type=LHAS.ST_BUTTON,buttonText="Damage Module Down",clickHandler=function() BB.Stats:NudgeDamage(0,BB.Constants.POSITION_STEP) end},
        {type=LHAS.ST_BUTTON,buttonText="Damage Module Left",clickHandler=function() BB.Stats:NudgeDamage(-BB.Constants.POSITION_STEP,0) end},
        {type=LHAS.ST_BUTTON,buttonText="Damage Module Right",clickHandler=function() BB.Stats:NudgeDamage(BB.Constants.POSITION_STEP,0) end},
        {type=LHAS.ST_BUTTON,buttonText="Restore Damage Module Position",clickHandler=function() BB.Stats:ResetDamagePosition() end},

        {type=LHAS.ST_LABEL,label="|cFFD447TANK RESISTANCE|r"},
        {type=LHAS.ST_CHECKBOX,label="Show Tank Resistance",tooltip="Shows current Physical and Spell Resistance in a Better Buffs branded movable HUD panel. Yellow is more than 5% below the 33,100 PvE resistance cap, green is within +/-5%, and red is more than 5% above it.",getFunction=function() return BB.saved.ui.resistanceStats.enabled==true end,setFunction=function(v) BB.Stats:SetResistanceEnabled(v); if v then BB.Stats:ShowResistancePreview() else BB.Stats:HideResistancePreview() end end},
        {type=LHAS.ST_LABEL,label="Resistance cap target: 33,100. Yellow < 31,445. Green 31,445-34,755. Red > 34,755."},
        {type=LHAS.ST_SLIDER,label="Tank Resistance Scale",min=60,max=160,step=5,unit="%",getFunction=function() return zo_round((BB.saved.ui.resistanceStats.scale or 1)*100) end,setFunction=function(v) BB.Stats:SetResistanceScale(v/100) end},
        {type=LHAS.ST_SLIDER,label="Tank Resistance Opacity",min=5,max=90,step=5,unit="%",getFunction=function() return zo_round((BB.saved.ui.resistanceStats.opacity or .34)*100) end,setFunction=function(v) BB.Stats:SetResistanceOpacity(v/100) end},
        {type=LHAS.ST_BUTTON,buttonText="Preview Tank Resistance",clickHandler=function() BB.Stats:ShowResistancePreview() end},
        {type=LHAS.ST_BUTTON,buttonText="Resistance Module Up",clickHandler=function() BB.Stats:NudgeResistance(0,-BB.Constants.POSITION_STEP) end},
        {type=LHAS.ST_BUTTON,buttonText="Resistance Module Down",clickHandler=function() BB.Stats:NudgeResistance(0,BB.Constants.POSITION_STEP) end},
        {type=LHAS.ST_BUTTON,buttonText="Resistance Module Left",clickHandler=function() BB.Stats:NudgeResistance(-BB.Constants.POSITION_STEP,0) end},
        {type=LHAS.ST_BUTTON,buttonText="Resistance Module Right",clickHandler=function() BB.Stats:NudgeResistance(BB.Constants.POSITION_STEP,0) end},
        {type=LHAS.ST_BUTTON,buttonText="Restore Resistance Module Position",clickHandler=function() BB.Stats:ResetResistancePosition() end},

        {type=LHAS.ST_CHECKBOX,label="Show Encounter Results in Chat",tooltip="Prints event-driven uptime, applications, longest gap, and coverage metrics after encounters lasting at least five seconds.",getFunction=function() if IsInGamepadPreferredMode and IsInGamepadPreferredMode() then LeaveDisplayPositioning() end; return BB.saved.uptime.enabled~=false end,setFunction=function(v) BB.saved.uptime.enabled=v==true end},
        {type=LHAS.ST_CHECKBOX,label="Show Advanced Coverage Metrics",getFunction=function() return BB.saved.uptime.showAdvanced~=false end,setFunction=function(v) BB.saved.uptime.showAdvanced=v==true end},
        {type=LHAS.ST_CHECKBOX,label="Personal Major Slayer Miss Alert",tooltip="After a new Major Slayer application settles, shows YOU DID NOT GET SLAYER only if your character did not receive that application.",getFunction=function() return BB.saved.ui.slayerMissAlert.enabled==true end,setFunction=function(v) BB.saved.ui.slayerMissAlert.enabled=v==true; if not BB.saved.ui.slayerMissAlert.enabled and BB.UI then BB.UI:HideSlayerMissAlert() end; if BB.Runtime then BB.Runtime:OnTrackingChanged("MAJOR_SLAYER") end end},
        {type=LHAS.ST_SLIDER,label="Slayer Miss Alert Scale",min=60,max=160,step=5,unit="%",getFunction=function() return zo_round((BB.saved.ui.slayerMissAlert.scale or 1)*100) end,setFunction=function(v) BB.saved.ui.slayerMissAlert.scale=v/100; BB.UI:ApplySlayerAlertSettings(); BB.UI:ShowSlayerMissAlert(true) end},
        {type=LHAS.ST_BUTTON,buttonText="Test Slayer Miss Alert",clickHandler=function() BB.UI:ShowSlayerMissAlert(true) end},
        {type=LHAS.ST_BUTTON,buttonText="Slayer Alert Up",clickHandler=function() BB.UI:NudgeSlayerAlert(0,-BB.Constants.POSITION_STEP) end},
        {type=LHAS.ST_BUTTON,buttonText="Slayer Alert Down",clickHandler=function() BB.UI:NudgeSlayerAlert(0,BB.Constants.POSITION_STEP) end},
        {type=LHAS.ST_BUTTON,buttonText="Slayer Alert Left",clickHandler=function() BB.UI:NudgeSlayerAlert(-BB.Constants.POSITION_STEP,0) end},
        {type=LHAS.ST_BUTTON,buttonText="Slayer Alert Right",clickHandler=function() BB.UI:NudgeSlayerAlert(BB.Constants.POSITION_STEP,0) end},
        {type=LHAS.ST_BUTTON,buttonText="Restore Slayer Alert Position",clickHandler=function() BB.UI:ResetSlayerAlertPosition() end},
        {type=LHAS.ST_SECTION,label="Advanced"},
        {type=LHAS.ST_CHECKBOX,label="READY Highlight",tooltip="Briefly brightens a compact tile when it transitions to READY, then leaves a steady gold border.",getFunction=function() return BB.saved.advanced.readyAnimation~=false end,setFunction=function(v) BB.saved.advanced.readyAnimation=v==true end},
    })
end
