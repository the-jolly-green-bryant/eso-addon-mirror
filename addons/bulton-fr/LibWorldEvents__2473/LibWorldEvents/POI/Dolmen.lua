LibWorldEvents.POI.Dolmen = {}

-- @var bool onMap To know if the user is on a map where dolmens world event can happen
LibWorldEvents.POI.Dolmen.onMap = false

-- @var bool isGenerated To know if the list has been generated or not
LibWorldEvents.POI.Dolmen.isGenerated = false

-- @var table List of all zone with dolmen world events
LibWorldEvents.POI.Dolmen.list = {
    { -- Glénumerie / Glénumbra
        zoneId  = 3,
        mapName = "glenumbra/glenumbra_base",
        list    = {
            title = {
                cp = {
                    [1] = GetString(SI_LIB_WORLD_EVENTS_CP_NORTH),
                    [2] = GetString(SI_LIB_WORLD_EVENTS_CP_CENTER),
                    [3] = GetString(SI_LIB_WORLD_EVENTS_CP_SOUTH)
                },
                ln = {} --generated in generateList()
            },
            poiIDs = {
                [1] = 839, --King's Guard Dolmen
                [2] = 838, --Cambray Hills Dolmen
                [3] = 837, --Daenia Dolmen
            },
        },
    },
    { -- Fendretour / Rivenspire
        zoneId  = 20,
        mapName = "rivenspire/rivenspire_base",
        list    = {
            title = {
                cp = {
                    [1] = GetString(SI_LIB_WORLD_EVENTS_CP_NORTH),
                    [2] = GetString(SI_LIB_WORLD_EVENTS_CP_SOUTH_EAST),
                    [3] = GetString(SI_LIB_WORLD_EVENTS_CP_SOUTH_WEST)
                },
                ln = {} --generated in generateList()
            },
            poiIDs = {
                [1] = 963, --Boralis Dolmen
                [2] = 962, --Westmark Moor Dolmen
                [3] = 961, --Eyebright Feld Dolmen
            },
        },
    },
    { -- Havre-tempête / Stormhaven
        zoneId  = 19,
        mapName = "stormhaven/stormhaven_base",
        list    = {
            title = {
                cp = {
                    [1] = GetString(SI_LIB_WORLD_EVENTS_CP_NORTH_EAST),
                    [2] = GetString(SI_LIB_WORLD_EVENTS_CP_SOUTH_EAST),
                    [3] = GetString(SI_LIB_WORLD_EVENTS_CP_SOUTH_WEST),
                },
                ln = {} --generated in generateList()
            },
            poiIDs = {
                [1] = 813, --Menevia Dolmen
                [2] = 808, --Gavaudon Dolmen
                [3] = 807, --Alcaire Dolmen
            },
        },
    },
    { -- Alik'r
        zoneId  = 104,
        mapName = "alikr/alikr_base",
        list    = {
            title = {
                cp = {
                    [1] = GetString(SI_LIB_WORLD_EVENTS_CP_NORTH),
                    [2] = GetString(SI_LIB_WORLD_EVENTS_CP_EAST),
                    [3] = GetString(SI_LIB_WORLD_EVENTS_CP_SOUTH_WEST),
                },
                ln = {} --generated in generateList()
            },
            poiIDs = {
                [1] = 897, --Hollow Waste Dolmen
                [2] = 898, --Tigonus Dolmen
                [3] = 896, --Myrkwasa Dolmen
            },
        },
    },
    { -- Bangkoraï
        zoneId  = 92,
        mapName = "bangkorai/bangkorai_base",
        list    = {
            title = {
                cp = {
                    [1] = GetString(SI_LIB_WORLD_EVENTS_CP_NORTH),
                    [2] = GetString(SI_LIB_WORLD_EVENTS_CP_CENTER),
                    [3] = GetString(SI_LIB_WORLD_EVENTS_CP_SOUTH)
                },
                ln = {} --generated in generateList()
            },
            poiIDs = {
                [1] = 1030, --Mournoth Dolmen
                [2] = 1031, --Ephesus Dolmen
                [3] = 1032, --Fallen Wastes Dolmen
            },
        },
    },
    { -- Auridia / Auridon
        zoneId  = 381,
        mapName = "auridon/auridon_base",
        list    = {
            title = {
                cp = {
                    [1] = GetString(SI_LIB_WORLD_EVENTS_CP_NORTH),
                    [2] = GetString(SI_LIB_WORLD_EVENTS_CP_CENTER),
                    [3] = GetString(SI_LIB_WORLD_EVENTS_CP_SOUTH)
                },
                ln = {} --generated in generateList()
            },
            poiIDs = {
                [1] = 773, --Vafe Dolmen
                [2] = 772, --Calambar Dolmen
                [3] = 771, --Iluvamir Dolmen
            },
        },
    },
    { -- Bois de Grath / Grathwood
        zoneId  = 383,
        mapName = "grahtwood/grahtwood_base",
        list    = {
            title = {
                cp = {
                    [1] = GetString(SI_LIB_WORLD_EVENTS_CP_NORTH_WEST),
                    [2] = GetString(SI_LIB_WORLD_EVENTS_CP_NORTH_EAST),
                    [3] = GetString(SI_LIB_WORLD_EVENTS_CP_SOUTH),
                },
                ln = {} --generated in generateList()
            },
            poiIDs = {
                [1] = 1035, --Tarlain Heights Dolmen
                [2] = 1034, --Green Hall Dolmen
                [3] = 1033, --Long Coast Dolmen
            },
        },
    },
    { -- Prasin / Greenshade
        zoneId  = 108,
        mapName = "greenshade/greenshade_base",
        list    = {
            title = {
                cp = {
                    [1] = GetString(SI_LIB_WORLD_EVENTS_CP_NORTH),
                    [2] = GetString(SI_LIB_WORLD_EVENTS_CP_SOUTH_EAST),
                    [3] = GetString(SI_LIB_WORLD_EVENTS_CP_SOUTH_WEST),
                },
                ln = {} --generated in generateList()
            },
            poiIDs = {
                [1] = 954, --Green's Marrow Dolmen
                [2] = 956, --Wilderking Court Dolmen
                [3] = 955, --Drowned Coast Dolmen
            },
        },
    },
    { -- Malabal Tor
        zoneId  = 58,
        mapName = "malabaltor/malabaltor_base",
        list    = {
            title = {
                cp = {
                    [1] = GetString(SI_LIB_WORLD_EVENTS_CP_NORTH_WEST),
                    [2] = GetString(SI_LIB_WORLD_EVENTS_CP_NORTH_EAST),
                    [3] = GetString(SI_LIB_WORLD_EVENTS_CP_SOUTH_EAST),
                },
                ln = {} --generated in generateList()
            },
            poiIDs = {
                [1] = 768, --Broken Coast Dolmen
                [2] = 770, --Silvenar Vale Dolmen
                [3] = 769, --Xylo River Basin Dolmen
            },
        },
    },
    { -- La marche de la Camarde / Reaper's March
        zoneId  = 382,
        mapName = "reapersmarch/reapersmarch_base",
        list    = {
            title = {
                cp = {
                    [1] = GetString(SI_LIB_WORLD_EVENTS_CP_NORTH_CENTER),
                    [2] = GetString(SI_LIB_WORLD_EVENTS_CP_NORTH_EAST),
                    [3] = GetString(SI_LIB_WORLD_EVENTS_CP_SOUTH),
                },
                ln = {} --generated in generateList()
            },
            poiIDs = {
                [1] = 934, --Northern Woods Dolmen
                [2] = 936, --Dawnmead Dolmen
                [3] = 935, --Jodewood Dolmen
            },
        },
    },
    { -- Les éboulis / Stone falls
        zoneId  = 41,
        mapName = "stonefalls/stonefalls_base",
        list    = {
            title = {
                cp = {
                    [1] = GetString(SI_LIB_WORLD_EVENTS_CP_NORTH_WEST),
                    [2] = GetString(SI_LIB_WORLD_EVENTS_CP_NORTH_CENTER),
                    [3] = GetString(SI_LIB_WORLD_EVENTS_CP_SOUTH)
                },
                ln = {} --generated in generateList()
            },
            poiIDs = {
                [1] = 1036, --Zabamat Dolmen
                [2] = 758, --Daen Seeth Dolmen
                [3] = 1037, --Varanis Dolmen
            },
        },
    },
    { -- Deshaan
        zoneId  = 57,
        mapName = "deshaan/deshaan_base",
        list    = {
            title = {
                cp = {
                    [1] = GetString(SI_LIB_WORLD_EVENTS_CP_WEST),
                    [2] = GetString(SI_LIB_WORLD_EVENTS_CP_CENTER),
                    [3] = GetString(SI_LIB_WORLD_EVENTS_CP_EAST)
                },
                ln = {} --generated in generateList()
            },
            poiIDs = {
                [1] = 783, --Redolent Loam Dolmen
                [2] = 784, --Lagomere Dolmen
                [3] = 785, --Siltreen Dolmen
            },
        },
    },
    { -- Fangeombre / Shadowfen
        zoneId  = 117,
        mapName = "shadowfen/shadowfen_base",
        list    = {
            title = {
                cp = {
                    [1] = GetString(SI_LIB_WORLD_EVENTS_CP_NORTH),
                    [2] = GetString(SI_LIB_WORLD_EVENTS_CP_SOUTH_EAST),
                    [3] = GetString(SI_LIB_WORLD_EVENTS_CP_SOUTH_WEST)
                },
                ln = {} --generated in generateList()
            },
            poiIDs = {
                [1] = 765, --Reticulated Spine Dolmen
                [2] = 766, --Leafwater Dolmen
                [3] = 767, --Venomous Fens Dolmen
            },
        },
    },
    { -- Estemarche / eastmarch
        zoneId  = 101,
        mapName = "eastmarch/eastmarch_base",
        list    = {
            title = {
                cp = {
                    [1] = GetString(SI_LIB_WORLD_EVENTS_CP_NORTH_WEST),
                    [2] = GetString(SI_LIB_WORLD_EVENTS_CP_SOUTH_EAST),
                    [3] = GetString(SI_LIB_WORLD_EVENTS_CP_SOUTH_WEST),
                },
                ln = {} --generated in generateList()
            },
            poiIDs = {
                [1] = 840, --Giant's Run Dolmen
                [2] = 842, --Icewind Peaks Dolmen
                [3] = 841, --Frostwater Tundra Dolmen
            },
        },
    },
    { -- La brèche / the rift
        zoneId  = 103,
        mapName = "therift/therift_base",
        list    = {
            title = {
                cp = {
                    [1] = GetString(SI_LIB_WORLD_EVENTS_CP_NORTH_WEST),
                    [2] = GetString(SI_LIB_WORLD_EVENTS_CP_NORTH_EAST),
                    [3] = GetString(SI_LIB_WORLD_EVENTS_CP_SOUTH)
                },
                ln = {} --generated in generateList()
            },
            poiIDs = {
                [1] = 799, --Ragged Hills Dolmen
                [2] = 800, --Stony Basin Dolmen
                [3] = 801, --Smokefrost Peaks Dolmen
            },
        },
    },
    {
        -- Cyrodiil
        zoneId  = 181,
        mapName = "cyrodiil/ava_whole",
        list    = {
            title = {
                cp = {
                    [1]  = zo_strformat("<<1>> (<<2>>)", GetString(SI_LIB_WORLD_EVENTS_CP_SOUTH_WEST), zo_strformat(GetString(SI_LIB_WORLD_EVENTS_CP_NORTH_OF), GetKeepName(149))),
                    [2]  = zo_strformat("<<1>> (<<2>>)", GetString(SI_LIB_WORLD_EVENTS_CP_WEST), zo_strformat(GetString(SI_LIB_WORLD_EVENTS_CP_WEST_OF), GetKeepName(132))),
                    [3]  = zo_strformat("<<1>> (<<2>>)", GetString(SI_LIB_WORLD_EVENTS_CP_SOUTH_EAST), zo_strformat(GetString(SI_LIB_WORLD_EVENTS_CP_WEST_OF), GetKeepName(157))),
                    [4]  = zo_strformat("<<1>> (<<2>>)", GetString(SI_LIB_WORLD_EVENTS_CP_NORTH_WEST), zo_strformat(GetString(SI_LIB_WORLD_EVENTS_CP_NORTH_OF), GetKeepName(7))),
                    [5]  = zo_strformat("<<1>> (<<2>>)", GetString(SI_LIB_WORLD_EVENTS_CP_NORTH_EAST), zo_strformat(GetString(SI_LIB_WORLD_EVENTS_CP_EAST_OF), GetKeepName(163))),
                    [6]  = zo_strformat("<<1>> (<<2>>)", GetString(SI_LIB_WORLD_EVENTS_CP_NORTH_CENTER), zo_strformat(GetString(SI_LIB_WORLD_EVENTS_CP_SOUTH_OF), GetKeepName(7))),
                    [7]  = zo_strformat("<<1>> (<<2>>)", GetString(SI_LIB_WORLD_EVENTS_CP_CENTER_EAST), zo_strformat(GetString(SI_LIB_WORLD_EVENTS_CP_WEST_OF), GetKeepName(13))),
                    [8]  = zo_strformat("<<1>> (<<2>>)", GetString(SI_LIB_WORLD_EVENTS_CP_EAST), zo_strformat(GetString(SI_LIB_WORLD_EVENTS_CP_SOUTH_OF), GetKeepName(133))),
                    [9]  = zo_strformat("<<1>> (<<2>>)", GetString(SI_LIB_WORLD_EVENTS_CP_NORTH_CENTER), zo_strformat(GetString(SI_LIB_WORLD_EVENTS_CP_WEST_OF), GetKeepName(8))),
                    [10] = zo_strformat("<<1>> (<<2>>)", GetString(SI_LIB_WORLD_EVENTS_CP_NORTH_CENTER), GetKeepName(151))
                },
                ln = {} --generated in generateList()
            },
            poiIDs = {
                [1]  = 1015, --Vertepâtures (Nord de Vlastarus)
                [2]  = 1016, --Grande forêt (Ouest Nikel)
                [3]  = 1017, --Vallée du Nibanais (Ouest pont de la baie)
                [4]  = 1021, --Bois de Guettepomme (Nord Aleswell)
                [5]  = 1022, --Allonge hivernale (Est sommet de l'hiver)
                [6]  = 1023, --Côte nord-ouest (Sud Aleswell)
                [7]  = 1025, --Côte est (Ouest BRK)
                [8]  = 1026, --Bassin de la Nibène (Sud de Sejanus)
                [9]  = 1028, --Contreforts de Cheydinhal (Ouest Griffe du dragon ?)
                [10] = 515, --Bruma
            },
        },
    }
}

--[[
-- Obtain and add the location name of all POI to the list
-- To always have a updated value for the current language, I prefer to not save it myself
--]]
function LibWorldEvents.POI.Dolmen:generateList()
    for listIdx, zoneData in ipairs(self.list) do
        for poiListIdx, poiId in ipairs(zoneData.list.poiIDs) do
            local zoneIdx, poiIdx = GetPOIIndices(poiId)
            local poiTitle        = GetPOIInfo(zoneIdx, poiIdx)
            zoneData.list.title.ln[poiListIdx] = zo_strformat(poiTitle)
        end
    end

    self.isGenerated = true
end

--[[
-- To obtain the zone's list where a dolmen world event can happen
--]]
function LibWorldEvents.POI.Dolmen:obtainList()
    if self.isGenerated == false then
        self:generateList()
    end

    return self.list
end
