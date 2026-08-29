local T = BetterBars
T.Settings = T.Settings or {}
local Settings = T.Settings

local RESOURCE_LAYOUT_ITEMS = {{name="Vertical Crescent",data="CRESCENT"},{name="Horizontal",data="HORIZONTAL"}}
local RESOURCE_VALUE_ITEMS = {
    {name="Numbers",data="NUMBERS"},
    {name="Percentage",data="PERCENT"},
    {name="Numbers & Percentage",data="BOTH"},
}
local RESOURCE_SIDE_ITEMS = {{name="Bow Left",data="LEFT"},{name="Bow Right",data="RIGHT"}}

local function AddResourceBarSettings(panel,key,label)
    local LHAS = LibHarvensAddonSettings
    local saved = function() return T.ResourceBars:GetBarSaved(key) end
    local settings = {
        {type=LHAS.ST_LABEL,label="|cFFD447"..string.upper(label).."|r"},
        {type=LHAS.ST_CHECKBOX,label="Show "..label,getFunction=function() return saved().enabled==true end,setFunction=function(v) T.ResourceBars:SetBarEnabled(key,v); T.ResourceBars:ShowPreview() end},
        {type=LHAS.ST_DROPDOWN,label=label.." Layout",items=function() return RESOURCE_LAYOUT_ITEMS end,getFunction=function() return {data=saved().layout or "CRESCENT"} end,setFunction=function(_,_,data) T.ResourceBars:SetBarOption(key,"layout",data.data) end},
        {type=LHAS.ST_SLIDER,label=label.." Scale",min=60,max=160,step=5,unit="%",getFunction=function() return zo_round((saved().scale or 1)*100) end,setFunction=function(v) T.ResourceBars:SetBarOption(key,"scale",v/100) end},
        {type=LHAS.ST_SLIDER,label=label.." Opacity",min=10,max=100,step=5,unit="%",getFunction=function() return zo_round((saved().opacity or .92)*100) end,setFunction=function(v) T.ResourceBars:SetBarOption(key,"opacity",v/100) end},
        {type=LHAS.ST_SLIDER,label=label.." Length",tooltip="Defines the physical length of a 30,000-resource bar. With Auto-size enabled, actual length scales from the same shared standard so different max resources are visually comparable.",min=140,max=520,step=10,getFunction=function() return saved().length or 350 end,setFunction=function(v) T.ResourceBars:SetBarOption(key,"length",v) end},
        {type=LHAS.ST_SLIDER,label=label.." Thickness",min=14,max=72,step=2,getFunction=function() return saved().thickness or 34 end,setFunction=function(v) T.ResourceBars:SetBarOption(key,"thickness",v) end},
    }
    local depthSetting = {type=LHAS.ST_SLIDER,label=label.." Crescent Depth",min=1,max=5,step=1,getFunction=function() return saved().crescentDepth or 3 end,setFunction=function(v) T.ResourceBars:SetBarOption(key,"crescentDepth",v) end}
    if key ~= "shield" then
        depthSetting.tooltip = "Applies only to Vertical Crescent. Five optimized curve profiles are used; there are no segmented/tick bars and no runtime geometry loop."
    end
    table.insert(settings, depthSetting)
    local autoLabel = key == "shield" and "Auto-size Damage Shield from Shield Capacity" or "Auto-size "..label.." from Max Resource"
    local autoTooltip = key == "shield" and "Auto-sizes below the configured Damage Shield Length. Length is a hard cap, so even very large Barrier shields never grow beyond it." or "Sizes this bar from the actual maximum resource using the shared standard: 30,000 resource equals the configured Length value. Food, gear, and other max-resource changes update automatically."
    table.insert(settings, {type=LHAS.ST_CHECKBOX,label=autoLabel,tooltip=autoTooltip,getFunction=function() return saved().dynamicMaxSize~=false end,setFunction=function(v) T.ResourceBars:SetBarOption(key,"dynamicMaxSize",v==true) end})
    table.insert(settings, {type=LHAS.ST_DROPDOWN,label=label.." Crescent Direction",items=function() return RESOURCE_SIDE_ITEMS end,getFunction=function() return {data=saved().crescentSide or "RIGHT"} end,setFunction=function(_,_,data) T.ResourceBars:SetBarOption(key,"crescentSide",data.data) end})
    table.insert(settings, {type=LHAS.ST_BUTTON,buttonText=label.." Up",clickHandler=function() T.ResourceBars:Nudge(key,0,-T.Constants.POSITION_STEP) end})
    table.insert(settings, {type=LHAS.ST_BUTTON,buttonText=label.." Down",clickHandler=function() T.ResourceBars:Nudge(key,0,T.Constants.POSITION_STEP) end})
    table.insert(settings, {type=LHAS.ST_BUTTON,buttonText=label.." Left",clickHandler=function() T.ResourceBars:Nudge(key,-T.Constants.POSITION_STEP,0) end})
    table.insert(settings, {type=LHAS.ST_BUTTON,buttonText=label.." Right",clickHandler=function() T.ResourceBars:Nudge(key,T.Constants.POSITION_STEP,0) end})
    table.insert(settings, {type=LHAS.ST_BUTTON,buttonText="Restore "..label.." Position",clickHandler=function() T.ResourceBars:ResetPosition(key) end})
    panel:AddSettings(settings)
end

function Settings:Initialize()
    local LHAS = LibHarvensAddonSettings
    if not LHAS then return end
    local panel = LHAS:AddAddon(T.displayName,{allowRefresh=true})
    if not panel then return end
    local originalCleanUp = panel.CleanUp
    if originalCleanUp then
        panel.CleanUp = function(self,...)
            if T.ResourceBars then T.ResourceBars:HidePreview() end
            return originalCleanUp(self,...)
        end
    end
    panel:AddSettings({
        {type=LHAS.ST_LABEL,label="|cFFD447BETTER BARS|r\n|cFFD447A BMG Addon|r\n|cFFD447Created and maintained by @BMGXSANCHO|r\nVersion "..T.version},
        {type=LHAS.ST_SECTION,label="Resource Bars"},
        {type=LHAS.ST_LABEL,label="Replace ESO's native player Health, Magicka, and Stamina bars with Better Bars. Turning Better Bars off immediately restores the native resource bars."},
        {type=LHAS.ST_LABEL,label="|cFFD447Auto-size standard:|r 30,000 maximum resource equals the configured Length value. With Auto-size enabled, food, gear, and other max-resource changes resize each bar from the same shared scale."},
        {type=LHAS.ST_CHECKBOX,label="Enable Better Bars",tooltip="Master switch for the Better Bars HUD. Disable it at any time to restore ESO's native player resource bars.",getFunction=function() return T.saved.resourceBars.enabled==true end,setFunction=function(v) T.ResourceBars:SetEnabled(v); if v then T.ResourceBars:ShowPreview() else T.ResourceBars:HidePreview() end end},
        {type=LHAS.ST_DROPDOWN,label="Resource Value Display",items=function() return RESOURCE_VALUE_ITEMS end,getFunction=function() return {data=T.saved.resourceBars.valueDisplay or "PERCENT"} end,setFunction=function(_,_,data) T.ResourceBars:SetValueDisplay(data.data); T.ResourceBars:ShowPreview() end},
        {type=LHAS.ST_BUTTON,buttonText="Preview Resource Bars",clickHandler=function() T.ResourceBars:ShowPreview() end},
    })
    AddResourceBarSettings(panel,"health","Health")
    AddResourceBarSettings(panel,"magicka","Magicka")
    AddResourceBarSettings(panel,"stamina","Stamina")
    AddResourceBarSettings(panel,"shield","Damage Shield")
    panel:AddSettings({
        {type=LHAS.ST_CHECKBOX,label="Hide Damage Shield When Empty",getFunction=function() return T.saved.resourceBars.shield.hideWhenEmpty~=false end,setFunction=function(v) T.ResourceBars:SetBarOption("shield","hideWhenEmpty",v==true) end},
    })
    if T.ChatHUD and T.ChatHUD.AddSettings then T.ChatHUD:AddSettings(panel) end
end
