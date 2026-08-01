Tauntless                 = Tauntless or {}
Tauntless.Widget = Tauntless.Widget or {}
Tauntless.Widget.pool = nil
Tauntless.Widget.tauntList = {}
Tauntless.Widget.endTimes = {}
Tauntless.Widget.lastAnchor = nil

-- TODO OnTauntEnd

--local Tauntless           = Tauntless
local uiScale = TAUNTLESS_UI_SCALE

local function removeFromPool(olditem, objectPool) -- Removes an item from the taunt list and redirect the anchors.
    local key = olditem.key
    if key == nil then return end

    olditem:SetHidden(true)

    local id, abilityId = olditem.id, olditem.abilityId

    local idkey = ZO_CachedStrFormat("<<1>>,<<2>>", id, abilityId)

    if id and abilityId then Tauntless.Widget.tauntList[idkey] = nil end

    olditem.endTime = nil
    olditem.abilityId = nil
    olditem.id = nil

    Tauntless.OnTauntEnd(key)

    if olditem:GetNamedChild("Bar").timeline then olditem:GetNamedChild("Bar").timeline:PlayInstantlyToStart() end

    local _, point, rel, relpoint, x, y = olditem:GetAnchor(0)

    if olditem.anchored then
        olditem.anchored:ClearAnchors()
        olditem.anchored:SetAnchor(point, rel, relpoint, x, y)
        rel.anchored = olditem.anchored
        olditem.anchored = nil
    else
        rel.anchored = nil
        Tauntless.Widget.lastAnchor = { point, rel, relpoint, x, y }
    end
end

local function addToPool(objectPool)
    return ZO_ObjectPool_CreateNamedControl("$(parent)UnitItem", "Tauntless_UnitItemTemplate", objectPool, Tauntless_TLW)
end

Tauntless.Widget.pool = ZO_ObjectPool:New(addToPool, removeFromPool)

function Tauntless.Widget.GetGrowthAnchor(item)
    item = item or Tauntless.Widget.lastAnchor[2].anchored

    local a1 = Tauntless.Settings.growthdirection and BOTTOMLEFT or TOPLEFT
    local a2 = Tauntless.Settings.growthdirection and TOPLEFT or BOTTOMLEFT

    local sp = Tauntless.Settings.growthdirection and zo_round(-4 / uiScale) * uiScale or zo_round(4 / uiScale) * uiScale

    local anchor = { a1, item, a2, 0, sp }

    local firstitem = Tauntless_TLW.anchored

    firstitem:ClearAnchors()
    firstitem:SetAnchor(a1, Tauntless_TLW, a1, zo_round(4 / uiScale) * uiScale, sp)

    return anchor
end

function Tauntless.Widget.NewItem(unitname, unitId, abilityId) -- Adds an item to the taunt list,
    local item, key = Tauntless.Widget.pool:AcquireObject()

    item.key = key
    item.id = unitId

    local height = Tauntless.Settings.window.height
    local width = Tauntless.Settings.window.width

    local fontsize = height * 5 / 6 + 4 - (4 * uiScale)
    local font = string.format("%s|%d|%s", GetString(SI_TAUNTLESS_FONT), fontsize, 'shadow')

    item:SetHidden(false)
    item:ClearAnchors()
    item:SetAnchor(unpack(Tauntless.Widget.lastAnchor))

    local label = item:GetNamedChild("Label")

    label:SetText(zo_strformat("<<!aC:1>>", unitname))
    label:SetFont(font)

    local bg = item:GetNamedChild("Bg")

    bg:SetEdgeTexture("", 1, 1, uiScale, 1)
    bg:SetEdgeColor(1, 1, 0, 1)
    bg:SetDimensions(width, height)

    item:GetNamedChild("Bar"):SetDimensions(width - height - (zo_round(2 / uiScale) * uiScale), height - (zo_round(2 / uiScale) * uiScale))

    local icon = item:GetNamedChild("Icon")

    icon:SetDimensions(height, height)
    icon:SetTexture(GetAbilityIcon(abilityId))

    local timer = item:GetNamedChild("Timer")

    timer:SetDimensions(height * 1.4, height)
    timer:SetFont(font)
    timer:SetText("15.0")
    timer:SetColor(1, 1, 0, 1)

    Tauntless.Widget.lastAnchor[2].anchored =	item  -- stores a reference to the item at the item it is anchored to. This is needed when redirecting anchors when an item is removed (see below)
    Tauntless.Widget.lastAnchor = Tauntless.Widget.GetGrowthAnchor(item) -- new anchor for the next item

    return key
end

function Tauntless.Widget.RefreshActiveItemSizes()
    local height = Tauntless.Settings.window.height
    local width = Tauntless.Settings.window.width

    local fontsize = height * 5 / 6 + 4 - (4 * uiScale)
    local font = string.format("%s|%d|%s", GetString(SI_TAUNTLESS_FONT), fontsize, 'soft-shadow-thin')

    local offset = zo_round(2 / uiScale) * uiScale

    if Tauntless.Widget.pool == nil then return end
    local ActiveObjects = Tauntless.Widget.pool:GetActiveObjects()

    for key, item in pairs(ActiveObjects) do
        if item then
            local label = item:GetNamedChild("Label")
            if label then label:SetFont(font) end

            local bg = item:GetNamedChild("Bg")
            if bg then
                bg:SetEdgeTexture("", 1, 1, uiScale, 1)
                bg:SetDimensions(width, height)
            end

            local bar = item:GetNamedChild("Bar")
            if bar then
                bar:SetDimensions(width - height - offset, height - offset)
            end

            local icon = item:GetNamedChild("Icon")
            if icon then
                icon:SetDimensions(height, height)
                if item.abilityId then icon:SetTexture(GetAbilityIcon(item.abilityId)) end
            end

            local timer = item:GetNamedChild("Timer")
            if timer then
                timer:SetDimensions(height * 1.4, height)
                timer:SetFont(font)
            end

            -- Recreate/refresh timeline to match new control widths and remaining duration
            if bar then
                if item.endTime then
                    local duration = item.endTime - GetGameTimeMilliseconds()
                    if duration < 0 then duration = 0 end

                    if bar.timeline and bar.timeline.Stop then bar.timeline:Stop() end

                    local offset = zo_round(2 / uiScale) * uiScale
                    local barStartWidth = Tauntless.Settings.window.width - Tauntless.Settings.window.height - offset
                    local barStartHeight = Tauntless.Settings.window.height - offset
                    bar.timeline = Tauntless.SetBarAnimation(bar, duration, nil, barStartWidth, barStartHeight)
                    if bar.timeline and bar.timeline.PlayFromStart then bar.timeline:PlayFromStart() end
                else
                    if bar.timeline then
                        if bar.timeline.Stop then bar.timeline:Stop() end
                        if bar.timeline.PlayInstantlyToStart then bar.timeline:PlayInstantlyToStart() end
                    end
                end
            end
        end
    end
end

function Tauntless.Widget.ClearItems()
    if Tauntless.inCombat then return end

    Tauntless.Widget.pool:ReleaseAllObjects()

    Tauntless.Widget.tauntList = {}
    Tauntless.Widget.endTimes = {}
end

-- Forcefully clear items and hide the window regardless of combat state
function Tauntless.Widget.ForceClear()
    if Tauntless.Widget.pool ~= nil then
    	Tauntless.Widget.pool:ReleaseAllObjects()
    end

    Tauntless.Widget.tauntList = {}
    Tauntless.Widget.endTimes = {}

    if Tauntless_TLW then
    	Tauntless_TLW:SetHidden(true)
    end
end

function Tauntless.Widget.ShowItems(currentpanel)
    if currentpanel ~= Tauntless.Menu.Panel then return end

    Tauntless_TLW:SetHidden(false)
    Tauntless.Widget.ClearItems()

    for i = 1, Tauntless.Settings.maxbars do
        Tauntless.Widget.NewItem("Unit" .. i, i, 38254)
    end
end

