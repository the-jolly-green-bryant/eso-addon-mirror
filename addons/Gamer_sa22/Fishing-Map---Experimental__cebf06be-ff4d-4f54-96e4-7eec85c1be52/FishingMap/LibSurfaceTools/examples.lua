-- Examples

local RANDOM_STRING = 'sgjkjngf325gjnkf'

--[[
ZO_PostHook(_G, 'ZO_WorldMap_MouseDown', function() d('ZO_WorldMap_MouseDown') end)
ZO_PostHook(_G, 'ZO_WorldMap_MouseUp', function() d('ZO_WorldMap_MouseUp') end)
ZO_PostHook(_G, 'ZO_WorldMap_MouseWheel', function() d('ZO_WorldMap_MouseWheel') end)
ZO_PostHook(_G, 'ZO_WorldMap_MouseEnter', function() d('ZO_WorldMap_MouseEnter') end)
ZO_PostHook(_G, 'ZO_WorldMap_MouseExit', function() d('ZO_WorldMap_MouseExit') end)
--]]

local function example1()
    local function OnMouseEnter(surface)
        surface[5], surface[6] = 64, 64
    end

    local function OnMouseExit(surface)
        surface[5], surface[6] = 32, 32
    end

    local map = LibSurfaceTools.Tools.FlexRect(ZO_WorldMapContainer, nil, OnMouseEnter, OnMouseExit)
        :SetAnchor(TOPLEFT)
        :SetAnchor(BOTTOMRIGHT)
        -- :SetTexture('/esoui/art/tutorial/poi_wayshrine_complete.dds', 2, 2)
        :SetTexture('/esoui/art/tutorial/poi_wayshrine_complete.dds')

    local control = map.control

    ZO_PostHook(_G, 'ZO_WorldMap_MouseEnter', function(_, ...) control:GetHandler('OnMouseEnter')(control) end)
    ZO_PostHook(_G, 'ZO_WorldMap_MouseExit', function(_, ...) control:GetHandler('OnMouseExit')(control) end)

    -- GLOBAL_MAP = map

    --[[
    local function inner()
        if #map.surfaces > 1 then return map:Clear() end

        local N = 100

        for i = 1, N do
            local j = 2 * math.pi * (i / N)
            local x = math.cos(j) * 0.2
            local y = math.sin(j) * 0.2

            map:Add(0.5 + x, 0.5 - y, 0, 0, 16, 16, math.ceil(4 * i / N))
        end

        map:RemoveSurfacesOfKind(3)
    end
    --]]

    local function inner()
        if #map.surfaces > 1 then return map:Clear() end

        local N = 16

        for i = 1, N do
            local j = 2 * math.pi * (i / N)
            local x = math.cos(j) * 0.2
            local y = math.sin(j) * 0.2

            map:Add(0.5 + x, 0.5 - y, 0, 0, 32, 32)
        end

        -- map:RemoveSurfacesOfKind(3)
    end

    return inner
end


local function example2()
    local function OnMouseEnter(surface)
        surface[5], surface[6] = 36, 36
    end

    local function OnMouseExit(surface)
        surface[5], surface[6] = 24, 24
    end

    local map = LibSurfaceTools.Tools.FlexRect(ZO_WorldMapContainer, nil, OnMouseEnter, OnMouseExit)
        :SetAnchor(TOPLEFT)
        :SetAnchor(BOTTOMRIGHT)
        :SetTexture('EsoUI/Art/Miscellaneous/Gamepad/gp_bullet.dds')

    local control = map.control

    ZO_PostHook(_G, 'ZO_WorldMap_MouseEnter', function(_, ...) control:GetHandler('OnMouseEnter')(control) end)
    ZO_PostHook(_G, 'ZO_WorldMap_MouseExit', function(_, ...) control:GetHandler('OnMouseExit')(control) end)

    local function inner()
        if #map.surfaces > 1 then GLOBAL_MAP = nil return map:Clear() end

        local cyroCache
        for _, cache in pairs(Harvest.Data.mapCaches) do
            if cache.map == 'cyrodiil/ava_whole' then
                cyroCache = cache
                break
            end
        end

        local zoneId = GetZoneId(GetUnitZoneIndex('player'))

        for i = 1, #cyroCache.worldX do
            if cyroCache.worldX[i] and cyroCache.worldY[i] then
                local x, y = cyroCache.worldX[i] * 100, cyroCache.worldY[i] * 100
                local n_x, n_y = GetNormalizedWorldPosition(zoneId, x, 40000, y)

                map:Add(n_x, n_y, 0, 0, 24, 24)
            end
        end

        GLOBAL_MAP = map
    end

    return inner
end



local function example3()
    local map = LibSurfaceTools.Tools.FlexRect(ZO_WorldMapContainer)
        :SetTexture('LibSurfaceTools/media/fish.dds', 4, 1)

    local filters = {}

    function SetFilter(filterId, isChecked)
        df('Set filter %d to %s', filterId, tostring(isChecked))
        -- collectgarbage('stop')
        if isChecked then
            if not filters[filterId] then
                -- public DecodeData from MapPins
                local data = GLOBAL_DECODE_DATA('FishingNodes', GetCurrentMapId())
                for i = 1, #data do
                    local pin = data[i]
                    if pin[3] == filterId then
                        map:Add(pin[1], pin[2], 0, 0, 32, 32, pin[3])
                    end
                end
            end
            filters[filterId] = true
        else
            if filters[filterId] then
                map:RemoveSurfacesOfKind(filterId)
            end
            filters[filterId] = false
        end
        -- collectgarbage('restart')
    end

    local function CreateMapFilters()
        local worldMapFrameControl = ZO_WorldMapMapFrame

        if not worldMapFrameControl then
            return
        end

        local panel = worldMapFrameControl:CreateControl('$(parent)MapFilterPanel', CT_CONTROL)
        panel:SetAnchor(TOPRIGHT, worldMapFrameControl, TOPRIGHT, -20, 20)
        panel:SetDimensions(80, 120)
        panel:SetDrawTier(DT_HIGH)
        panel:SetDrawLayer(DL_OVERLAY)

        local textures   = {
            "/esoui/art/icons/crafting_slaughterfish.dds",	      -- Foul
            "/esoui/art/icons/crafting_fishing_river_betty.dds",  -- River
            "/esoui/art/icons/crafting_fishing_merringar.dds",	  -- Salt
            "/esoui/art/icons/crafting_fishing_perch.dds"	      -- Lake
        }

        local lastControl = nil
        for i = 1, 4 do
            local cb = CreateControlFromVirtual('$(parent)MapFilterCB', panel, 'ZO_CheckButton', i)
            -- cb:SetText(labels[i])
            -- cb:SetDimensions(160, 25)
            if i == 1 then
                cb:SetAnchor(TOPLEFT, panel, TOPLEFT, 0, 0)
            else
                cb:SetAnchor(TOPLEFT, lastControl, BOTTOMLEFT, 0, 5)
            end
            ZO_CheckButton_SetToggleFunction(cb, function(_, checked)
                SetFilter(i, checked)
            end)

            local tex = cb:CreateControl(nil, CT_TEXTURE)
            tex:SetAnchor(LEFT, cb, RIGHT, 5, 0)
            tex:SetDimensions(24, 24)
            tex:SetTexture(textures[i])

            lastControl = cb
        end

        return panel
    end

    local filtersControl
    local function inner()
        filtersControl = filtersControl or CreateMapFilters()
        GLOBAL_MAP = map
    end

    return inner
end


EVENT_MANAGER:RegisterForEvent(RANDOM_STRING, EVENT_ADD_ONS_LOADED, function()
    EVENT_MANAGER:UnregisterForEvent(RANDOM_STRING, EVENT_ADD_ONS_LOADED)

    LibSurfaceToolsExamples = {
        e1 = example1(),
        e2 = example2(),
        e3 = example3(),
    }
end)