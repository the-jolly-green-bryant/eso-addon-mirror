local HyruleUI = _G["HyruleUI"]
HyruleUI = {}
HyruleUI.name = "HyruleUI"
local HP_PER_HEART, heartPool = 2000, nil
local defaults = { offsetX = 0, offsetY = 0, heartColor = {r = 1, g = 0, b = 0, a = 1}, shieldColor = {r = 0.5, g = 0, b = 0.5, a = 1}, enabled = true, showShields = true, scale = 100 }

-- THE WHITELIST: Only these specific names will trigger "Shield" hearts.
local shieldWhitelist = {
    ["hardened ward"] = true, ["empowered ward"] = true, ["conjured ward"] = true,
    ["harness magicka"] = true, ["dampen magic"] = true, ["annulment"] = true,
    ["brawler"] = true, ["carve"] = true, ["titanic cleave"] = true,
    ["sun shield"] = true, ["blazing shield"] = true, ["radiant ward"] = true,
    ["bone shield"] = true, ["spiked bone shield"] = true, ["bone surge"] = true,
    ["obsidian shield"] = true, ["fragmented shield"] = true, ["igneous shield"] = true,
    ["steely ward"] = true, ["warding star"] = true, ["barrier"] = true,
    ["replenishing barrier"] = true, ["reviving barrier"] = true,
    ["concentrated barrier"] = true, ["shimmering shield"] = true,
    ["ice fortress"] = true, ["expansive frost cloak"] = true,
}

function HyruleUI.SavePosition(control)
    HyruleUI.db.offsetX, HyruleUI.db.offsetY = control:GetLeft(), control:GetTop()
end

local function SetCoords(control, state)
    local left = (4 - state) * 0.2
    control:SetTextureCoords(left, left + 0.2, 0, 1)
end

function HyruleUI.UpdateHearts()
    if not HyruleHeartContainer or not HyruleUI.db or not heartPool then return end
    local current, _, maxHP = GetUnitPower("player", POWERTYPE_HEALTH)
    local isHud = SCENE_MANAGER:GetCurrentSceneName() == "hud" or SCENE_MANAGER:GetCurrentSceneName() == "hudui"
    if not HyruleUI.db.enabled or (not isHud and current >= maxHP) then HyruleHeartContainer:SetHidden(true) return end
    
    HyruleHeartContainer:SetHidden(false)
    ZO_PlayerAttributeHealth:SetHidden(true)
    HyruleHeartContainer:SetScale(HyruleUI.db.scale / 100)

    local shieldTotal = 0
    if HyruleUI.db.showShields then
        -- 1. WHITELIST BUFF SCAN (For Stacking)
        for i = 1, GetNumBuffs("player") do
            local name = GetUnitBuffInfo("player", i)
            if name and shieldWhitelist[name:lower()] then
                -- Add a generic "Heart Value" per active shield buff
                shieldTotal = shieldTotal + 5000 
            end
        end

        -- 2. VISUALIZER SYNC (For Real-Time Accuracy)
        local vizShield = 0
        for i = 1, 15 do 
            local stat, _, val = GetUnitAttributeVisualizerEffectInfo("player", i, STAT_RELEVANCE_CURRENT, ATTRIBUTE_MAIN_VISUAL, POWERTYPE_HEALTH)
            if stat == ATTRIBUTE_VISUAL_SHIELDED and val then vizShield = vizShield + val end
        end
        shieldTotal = math.max(shieldTotal, vizShield)
    end
    
    -- 3. RENDER
    local totalHearts = math.ceil((maxHP + shieldTotal) / HP_PER_HEART)
    heartPool:ReleaseAllObjects()
    
    for i = 1, totalHearts do
        local heart = heartPool:AcquireObject()
        heart:SetAnchor(TOPLEFT, HyruleHeartContainer, TOPLEFT, ((i-1)%10)*34, math.floor((i-1)/10)*34)
        local icon = heart:GetNamedChild("Icon")
        local startHP = (i - 1) * HP_PER_HEART
        icon:SetColor(1,1,1,1)
        SetCoords(icon, 0)
        
        local combinedHP = current + shieldTotal
        if combinedHP > startHP then
            local fill = math.min(HP_PER_HEART, combinedHP - startHP)
            SetCoords(icon, math.max(0, math.min(4, math.ceil(fill / 500))))
            if shieldTotal > 0 and current <= startHP then
                icon:SetColor(HyruleUI.db.shieldColor.r, HyruleUI.db.shieldColor.g, HyruleUI.db.shieldColor.b, HyruleUI.db.shieldColor.a)
            else
                icon:SetColor(HyruleUI.db.heartColor.r, HyruleUI.db.heartColor.g, HyruleUI.db.heartColor.b, HyruleUI.db.heartColor.a)
            end
        end
    end
end

local function OnLoaded(event, addonName)
    if addonName ~= HyruleUI.name then return end
    HyruleUI.db = ZO_SavedVars:NewAccountWide("HyruleUIVars", 1, nil, defaults)
    heartPool = ZO_ControlPool:New("HeartTemplate", HyruleHeartContainer, "Heart")
    if HyruleUI.db.offsetX ~= 0 then
        HyruleHeartContainer:ClearAnchors()
        HyruleHeartContainer:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, HyruleUI.db.offsetX, HyruleUI.db.offsetY)
    end
    local LAM = _G["LibAddonMenu2"]
    if LAM then
        local panel = { type = "panel", name = "HyruleUI_Settings", displayName = "Hyrule UI" }
        LAM:RegisterAddonPanel("HyruleUI_Settings", panel)
        local opts = {
            { type = "checkbox", name = "Enabled", getFunc = function() return HyruleUI.db.enabled end, setFunc = function(v) HyruleUI.db.enabled = v end },
            { type = "checkbox", name = "Shields", getFunc = function() return HyruleUI.db.showShields end, setFunc = function(v) HyruleUI.db.showShields = v end },
            { type = "colorpicker", name = "Hearts", getFunc = function() return HyruleUI.db.heartColor.r, HyruleUI.db.heartColor.g, HyruleUI.db.heartColor.b, HyruleUI.db.heartColor.a end, setFunc = function(r,g,b,a) HyruleUI.db.heartColor = {r=r,g=g,b=b,a=a} end },
            { type = "colorpicker", name = "Shields", getFunc = function() return HyruleUI.db.shieldColor.r, HyruleUI.db.shieldColor.g, HyruleUI.db.shieldColor.b, HyruleUI.db.shieldColor.a end, setFunc = function(r,g,b,a) HyruleUI.db.shieldColor = {r=r,g=g,b=b,a=a} end },
            { type = "slider", name = "Size", min = 50, max = 300, getFunc = function() return HyruleUI.db.scale end, setFunc = function(v) HyruleUI.db.scale = v end }
        }
        LAM:RegisterOptionControls("HyruleUI_Settings", opts)
    end
    EVENT_MANAGER:RegisterForUpdate(HyruleUI.name, 100, function() HyruleUI.UpdateHearts() end)
end
EVENT_MANAGER:RegisterForEvent(HyruleUI.name, EVENT_ADD_ON_LOADED, OnLoaded)