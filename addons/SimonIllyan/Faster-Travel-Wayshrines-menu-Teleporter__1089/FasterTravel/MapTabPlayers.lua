local MapTabPlayers = FasterTravel.class(FasterTravel.MapTab)

FasterTravel.MapTabPlayers = MapTabPlayers

local Teleport = FasterTravel.Teleport
local Utils = FasterTravel.Utils
local Location = FasterTravel.Location
local STW = FasterTravel.SurveyTheWorld

function MapTabPlayers:init(control)
    self.base.init(self, control)

    local _first = true

    local addHandlers = function(data)
        data.refresh =  function(self, control)
							control.label:SetText(self.tag .. " [" .. self.zoneName .. "] ")
						end
        data.clicked =  function(self, control)
							Teleport.TeleportToPlayer(self.tag)
							ZO_WorldMap_HideWorldMap()
						end
        return data
    end

    self.Refresh = function()
        local group = Teleport.GetGroupInfo()
        local friends = Teleport.GetFriendsInfo()

        group = Utils.map(group, addHandlers)
        friends = Utils.map(friends, addHandlers)

        local zones = {}
        local categories = {
            {
                name = string.format("%s (%d)", GetString(FASTER_TRAVEL_PLAYERS_CATEGORY_GROUP), #group),
                data = group,
                hidden = not _first and self:IsCategoryHidden(1)
            },
            {
                name = string.format("%s (%d)", GetString(FASTER_TRAVEL_PLAYERS_CATEGORY_FRIENDS), #friends),
                data = friends,
                hidden = not _first and self:IsCategoryHidden(2)
            },
            {
                name = GetString(FASTER_TRAVEL_PLAYERS_CATEGORY_ZONE),
                data = zones,
                hidden = not _first and self:IsCategoryHidden(3)
            }
        }

        local _lookup = {}
		local _players_count = {}
		local function add_to_lookup(player) -- "player" must be an element of group/friends/guildies lists
			local zoneName = player.zoneName
			local zone = _lookup[zoneName]
			if zone == nil then
				zone = {}
				_lookup[zoneName] = zone
			end
			if _players_count[zoneName] == nil then
				_players_count[zoneName] = 0
			end
			if not zone[player.name] then
				zone[player.name] = true
				_players_count[zoneName] = _players_count[zoneName] + 1
			end
		end
		
		for i, v in ipairs(group) do
			add_to_lookup(v)
		end
		for i, v in ipairs(friends) do
			add_to_lookup(v)
		end

		local gCount = GetNumGuilds()
        local id
        local name, data
        for i = 1, gCount do
            id = GetGuildId(i)
            name = GetGuildName(id)           
            data = Utils.map(Teleport.GetGuildPlayers(id),
                function(guildie)
					add_to_lookup(guildie)
                    return addHandlers(guildie)
                end)           
            table.insert(categories,
                {
                    name = string.format("%s (%d)", name, #data),
                    data = data,
                    hidden = _first or self:IsCategoryHidden(i + 3)
                })
        end

		STW.buildSurveyNameList()
		STW.GetLeadCountsInZones()
		for zoneName, zone in pairs(_lookup) do
            local zId = Location.Data.GetZoneIdByName(zoneName) 
            if zId < 508 or zId > 518 then -- not Battlegrounds zone
                local surveys, treasures, leads, sign
                surveys, treasures, leads, sign = STW.getCountersFor(zId, zoneName)
                table.insert(zones, {
                    name =  string.format("%s %s (%d)%s%s%s", sign, zoneName, _players_count[zoneName], surveys, treasures, leads),
                    zoneName = zoneName,
                    refresh = function(self, control) control.label:SetText(self.name) end,
                    clicked = function(self, control)
                        local result, zoneName = Teleport.TeleportToZone(self.zoneName)
                        if result == true then
                            ZO_WorldMap_HideWorldMap()
                        end
                    end
                })
            end
        end

        table.sort(zones, function(x, y) return Utils.BareName(x.zoneName) < Utils.BareName(y.zoneName) end)

        self:ClearControl()

        self:AddCategories(categories, 0) -- 0 for players tab

        self:RefreshControl(categories)

        _first = false
    end
end
