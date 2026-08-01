OpulentOrdealNavigator = OpulentOrdealNavigator or {}

local OON = OpulentOrdealNavigator

-- Fill this from data/MarkerIntake.csv once marker coordinates are known.
-- Keep markerId values matching data/Routes.lua exactly.
OON.MARKER_OVERRIDES = {
    -- red_pickup_west = { x = 0, y = 0, z = 0, label = "Red pickup west" },
    red_drop_north = {
        x = 50166,
        y = 35037,
        z = 48032,
        label = "Red solo soak",
        renderLabel = "Red\nSolo soak",
    },
    orange_drop_north = {
        x = 48226,
        y = 35037,
        z = 51058,
        label = "Orange solo soak",
        renderLabel = "Orange\nSolo soak",
    },
    purple_drop_north = {
        x = 51592,
        y = 35037,
        z = 51159,
        label = "Purple solo soak",
        renderLabel = "Purple\nSolo soak",
    },
    red_dual_soak_left = {
        x = 49475,
        y = 35057,
        z = 48127,
    },
    red_dual_soak_right = {
        x = 50913,
        y = 35057,
        z = 48123,
    },
    orange_dual_soak_left = {
        x = 48116,
        y = 35057,
        z = 50543,
    },
    orange_dual_soak_right = {
        x = 48460,
        y = 35057,
        z = 51247,
    },
    purple_dual_soak_left = {
        x = 51876,
        y = 35057,
        z = 50492,
    },
    purple_dual_soak_right = {
        x = 51069,
        y = 35057,
        z = 51599,
    },
    m0r_pickup_red_in_purple_hand_to_orange_09 = {
        label = "Kill boss and pick up orb",
        renderLabel = "9\nKill boss\nPick up orb",
    },
    m0r_pickup_red_in_purple_hand_to_orange_14 = {
        label = "Help kill boss, deliver orb",
        renderLabel = "14\nHelp kill boss\nDeliver orb",
    },
    m0r_pickup_orange_in_purple_hand_to_red_07 = {
        label = "Kill boss and pick up orb",
        renderLabel = "7\nKill boss\nPick up orb",
    },
    m0r_pickup_orange_in_purple_hand_to_red_14 = {
        label = "Help kill boss, deliver orb",
        renderLabel = "14\nHelp kill boss\nDeliver orb",
    },
    m0r_pickup_purple_in_orange_hand_to_red_10 = {
        label = "Kill boss and pick up orb",
        renderLabel = "10\nKill boss\nPick up orb",
    },
    m0r_pickup_purple_in_orange_hand_to_red_06 = {
        x = 41762,
        z = 53734,
    },
    m0r_pickup_purple_in_orange_hand_to_red_07 = {
        x = 40524,
        z = 55990,
    },
    m0r_pickup_purple_in_orange_hand_to_red_12 = {
        renderLabel = "14",
    },
    m0r_pickup_purple_in_orange_hand_to_red_13 = {
        renderLabel = "15",
    },
    m0r_pickup_purple_in_orange_hand_to_red_14 = {
        renderLabel = "16",
    },
    m0r_pickup_purple_in_orange_hand_to_red_15 = {
        label = "Help kill boss, deliver orb",
        renderLabel = "17\nHelp kill boss\nDeliver orb",
    },
    m0r_pickup_purple_in_red_hand_to_orange_07 = {
        label = "Kill boss and pick up orb",
        renderLabel = "7\nKill boss\nPick up orb",
    },
    m0r_pickup_purple_in_red_hand_to_orange_10 = {
        renderLabel = "12",
    },
    m0r_pickup_purple_in_red_hand_to_orange_11 = {
        renderLabel = "13",
    },
    m0r_pickup_purple_in_red_hand_to_orange_12 = {
        renderLabel = "14",
    },
    m0r_pickup_purple_in_red_hand_to_orange_13 = {
        label = "Help kill boss, deliver orb",
        renderLabel = "15\nHelp kill boss\nDeliver orb",
    },
    m0r_pickup_red_in_orange_hand_to_purple_10 = {
        label = "Kill boss and pick up orb",
        renderLabel = "10\nKill boss\nPick up orb",
    },
    m0r_pickup_red_in_orange_hand_to_purple_11_custom = {
        room = "imported",
        kind = "m0r_route",
        label = "Pickup red in orange hand to purple 11",
        renderLabel = "11",
        x = 39844,
        y = 36816,
        z = 57483,
        source = "Manual route insert",
    },
    m0r_pickup_red_in_orange_hand_to_purple_11 = {
        renderLabel = "16",
    },
    m0r_pickup_red_in_orange_hand_to_purple_12 = {
        renderLabel = "17",
    },
    m0r_pickup_red_in_orange_hand_to_purple_13 = {
        renderLabel = "18",
    },
    m0r_pickup_red_in_orange_hand_to_purple_14 = {
        label = "Help kill boss, deliver orb",
        renderLabel = "19\nHelp kill boss\nDeliver orb",
    },
    m0r_pickup_orange_in_red_hand_to_purple_06 = {
        label = "Kill boss and pick up orb",
        renderLabel = "6\nKill boss\nPick up orb",
    },
    m0r_pickup_orange_in_red_hand_to_purple_07 = {
        renderLabel = "11",
    },
    m0r_pickup_orange_in_red_hand_to_purple_08 = {
        renderLabel = "12",
    },
    m0r_pickup_orange_in_red_hand_to_purple_09 = {
        renderLabel = "13",
    },
    m0r_pickup_orange_in_red_hand_to_purple_10 = {
        label = "Help kill boss, place orb",
        renderLabel = "14\nHelp kill boss\nPlace orb",
    },
    m0r_orange_orb_from_red_through_purple_hand_to_orange_07 = {
        label = "Help kill boss and pick up orb",
        renderLabel = "7\nHelp kill boss\nPick up orb",
    },
    m0r_orange_orb_from_red_through_purple_hand_to_orange_18 = {
        label = "Help kill boss, deliver orb",
        renderLabel = "18\nHelp kill boss\nDeliver orb",
    },
    m0r_orange_orb_from_purple_through_red_hand_to_orange_08 = {
        label = "Help kill boss and pick up orb",
        renderLabel = "8\nHelp kill boss\nPick up orb",
    },
    m0r_orange_orb_from_purple_through_red_hand_to_orange_09 = {
        renderLabel = "10",
    },
    m0r_orange_orb_from_purple_through_red_hand_to_orange_10 = {
        renderLabel = "11",
    },
    m0r_orange_orb_from_purple_through_red_hand_to_orange_11 = {
        renderLabel = "12",
    },
    m0r_orange_orb_from_purple_through_red_hand_to_orange_12 = {
        renderLabel = "13",
    },
    m0r_orange_orb_from_purple_through_red_hand_to_orange_13 = {
        renderLabel = "14",
    },
    m0r_orange_orb_from_purple_through_red_hand_to_orange_14 = {
        renderLabel = "15",
    },
    m0r_orange_orb_from_purple_through_red_hand_to_orange_15 = {
        renderLabel = "16",
    },
    m0r_orange_orb_from_purple_through_red_hand_to_orange_16 = {
        renderLabel = "17",
    },
    m0r_orange_orb_from_purple_through_red_hand_to_orange_17 = {
        renderLabel = "18",
    },
    m0r_orange_orb_from_purple_through_red_hand_to_orange_18 = {
        label = "Help kill boss, deliver orb",
        renderLabel = "19\nHelp kill boss\nDeliver orb",
    },
    m0r_purple_orb_from_orange_through_red_hand_to_purple_09 = {
        label = "Help kill boss and pick up orb",
        renderLabel = "9\nHelp kill boss\nPick up orb",
    },
    m0r_purple_orb_from_orange_through_red_hand_to_purple_10 = {
        renderLabel = "14",
    },
    m0r_purple_orb_from_orange_through_red_hand_to_purple_11 = {
        renderLabel = "13",
    },
    m0r_purple_orb_from_orange_through_red_hand_to_purple_12 = {
        renderLabel = "15",
    },
    m0r_purple_orb_from_orange_through_red_hand_to_purple_13 = {
        renderLabel = "16",
    },
    m0r_purple_orb_from_orange_through_red_hand_to_purple_14 = {
        renderLabel = "17",
    },
    m0r_purple_orb_from_orange_through_red_hand_to_purple_15 = {
        renderLabel = "18",
    },
    m0r_purple_orb_from_orange_through_red_hand_to_purple_16 = {
        label = "Help kill boss, deliver orb",
        renderLabel = "19\nHelp kill boss\nDeliver orb",
    },
    m0r_purple_orb_from_red_through_orange_hand_to_purple_07 = {
        label = "Help kill boss and pick up orb",
        renderLabel = "7\nHelp kill boss\nPick up orb",
    },
    m0r_purple_orb_from_red_through_orange_hand_to_purple_17 = {
        label = "Help kill boss, deliver orb",
        renderLabel = "17\nHelp kill boss\nDeliver orb",
    },
    m0r_red_orb_from_orange_through_purple_hand_to_red_06 = {
        label = "Help kill boss and pick up orb",
        renderLabel = "6\nHelp kill boss\nPick up orb",
    },
    m0r_red_orb_from_orange_through_purple_hand_to_red_17 = {
        label = "Help kill boss, deliver orb",
        renderLabel = "17\nHelp kill boss\nDeliver orb",
    },
    m0r_red_orb_from_purple_through_orange_hand_to_red_05 = {
        label = "Help kill boss and pick up orb",
        renderLabel = "5\nHelp kill boss\nPick up orb",
    },
    m0r_red_orb_from_purple_through_orange_hand_to_red_16 = {
        label = "Help kill boss, deliver orb",
        renderLabel = "16\nHelp kill boss\nDeliver orb",
    },
    m0r_hand_in_orange_orb_from_purple_06 = {
        label = "Kill boss and move along",
        renderLabel = "6\nKill boss\nMove along",
    },
    m0r_hand_in_orange_orb_from_purple_07 = {
        renderLabel = "9",
    },
    m0r_hand_in_orange_orb_from_purple_08 = {
        renderLabel = "10",
    },
    m0r_hand_in_orange_orb_from_purple_09 = {
        label = "Help kill boss and pick up orb",
        renderLabel = "11\nHelp kill boss\nPick up orb\nReturn to 6\nPlace orb",
    },
    m0r_hand_in_orange_orb_from_red_side_06 = {
        label = "Kill boss and move along",
        renderLabel = "6\nKill boss\nMove along",
    },
    m0r_hand_in_orange_orb_from_red_side_07 = {
        renderLabel = "9",
    },
    m0r_hand_in_orange_orb_from_red_side_08 = {
        renderLabel = "10",
    },
    m0r_hand_in_orange_orb_from_red_side_09 = {
        label = "Help kill boss and pick up orb",
        renderLabel = "11\nHelp kill boss\nPick up orb\nGo to 6\nPlace orb",
    },
    m0r_hand_in_purple_orb_from_orange_side_02 = {
        label = "Kill boss and move along",
        renderLabel = "2\nKill boss\nMove along",
    },
    m0r_hand_in_purple_orb_from_orange_side_06 = {
        label = "Help kill boss and pick up orb",
        renderLabel = "6\nHelp kill boss\nPick up orb\nGo to 2\nPlace orb",
    },
    m0r_hand_in_purple_orb_from_red_side_02 = {
        label = "Kill boss and move along",
        renderLabel = "2\nKill boss\nMove along",
    },
    m0r_hand_in_purple_orb_from_red_side_06 = {
        label = "Help kill boss and pick up orb",
        renderLabel = "6\nHelp kill boss\nPick up orb\nGo to 2\nPlace orb",
    },
    m0r_hand_in_red_orb_from_orange_side_06 = {
        label = "Kill boss and move along",
        renderLabel = "6\nKill boss\nMove along",
    },
    m0r_hand_in_red_orb_from_orange_side_10 = {
        label = "Help kill boss and pick up orb",
        renderLabel = "10\nHelp kill boss\nPick up orb\nGo to 6\nPlace orb",
    },
    m0r_hand_in_red_orb_from_purple_side_04 = {
        label = "Kill boss and move along",
        renderLabel = "4\nKill boss\nMove along",
    },
    m0r_hand_in_red_orb_from_purple_side_05 = {
        renderLabel = "6",
    },
    m0r_hand_in_red_orb_from_purple_side_06 = {
        renderLabel = "7",
    },
    m0r_hand_in_red_orb_from_purple_side_07 = {
        renderLabel = "8",
    },
    m0r_hand_in_red_orb_from_purple_side_08 = {
        label = "Help kill boss and pick up orb",
        renderLabel = "9\nHelp kill boss\nPick up orb\nGo to 4\nPlace orb",
    },
}

for markerId, override in pairs(OON.MARKER_OVERRIDES) do
    OON.MARKERS[markerId] = OON.MARKERS[markerId] or {}
    for key, value in pairs(override) do
        OON.MARKERS[markerId][key] = value
    end
end

local function CopyMarker(targetId, sourceId, renderLabel)
    local source = OON.MARKERS[sourceId]
    if not source then
        return
    end

    OON.MARKERS[targetId] = OON.MARKERS[targetId] or {}
    for key, value in pairs(source) do
        OON.MARKERS[targetId][key] = value
    end
    OON.MARKERS[targetId].label = "Reused " .. (source.label or sourceId)
    OON.MARKERS[targetId].renderLabel = renderLabel
    OON.MARKERS[targetId].source = (source.source or sourceId) .. " reused"
end

CopyMarker(
    "m0r_pickup_purple_in_orange_hand_to_red_12_reuse_07",
    "m0r_pickup_purple_in_orange_hand_to_red_07",
    "12"
)
CopyMarker(
    "m0r_pickup_purple_in_orange_hand_to_red_13_reuse_06",
    "m0r_pickup_purple_in_orange_hand_to_red_06",
    "13"
)

-- Steps 12/13 reuse the same physical spots as 7/6. Offset them to the
-- opposite side so both passes can be read when the full path is visible.
if OON.MARKERS.m0r_pickup_purple_in_orange_hand_to_red_12_reuse_07 then
    OON.MARKERS.m0r_pickup_purple_in_orange_hand_to_red_12_reuse_07.x = 40216
    OON.MARKERS.m0r_pickup_purple_in_orange_hand_to_red_12_reuse_07.z = 55822
end
if OON.MARKERS.m0r_pickup_purple_in_orange_hand_to_red_13_reuse_06 then
    OON.MARKERS.m0r_pickup_purple_in_orange_hand_to_red_13_reuse_06.x = 41454
    OON.MARKERS.m0r_pickup_purple_in_orange_hand_to_red_13_reuse_06.z = 53566
end

if OON.M0R_ROUTE_PROFILES and OON.M0R_ROUTE_PROFILES.pickup_purple_in_orange_hand_to_red then
    local profile = OON.M0R_ROUTE_PROFILES.pickup_purple_in_orange_hand_to_red
    profile.markers = {
        { id = "m0r_pickup_purple_in_orange_hand_to_red_01" },
        { id = "m0r_pickup_purple_in_orange_hand_to_red_02" },
        { id = "m0r_pickup_purple_in_orange_hand_to_red_03" },
        { id = "m0r_pickup_purple_in_orange_hand_to_red_04" },
        { id = "m0r_pickup_purple_in_orange_hand_to_red_05" },
        { id = "m0r_pickup_purple_in_orange_hand_to_red_06" },
        { id = "m0r_pickup_purple_in_orange_hand_to_red_07" },
        { id = "m0r_pickup_purple_in_orange_hand_to_red_08" },
        { id = "m0r_pickup_purple_in_orange_hand_to_red_09" },
        { id = "m0r_pickup_purple_in_orange_hand_to_red_10" },
        { id = "m0r_pickup_purple_in_orange_hand_to_red_11" },
        { id = "m0r_pickup_purple_in_orange_hand_to_red_12_reuse_07" },
        { id = "m0r_pickup_purple_in_orange_hand_to_red_13_reuse_06" },
        { id = "m0r_pickup_purple_in_orange_hand_to_red_12" },
        { id = "m0r_pickup_purple_in_orange_hand_to_red_13" },
        { id = "m0r_pickup_purple_in_orange_hand_to_red_14" },
        { id = "m0r_pickup_purple_in_orange_hand_to_red_15" },
    }
end

CopyMarker(
    "m0r_pickup_purple_in_red_hand_to_orange_10_reuse_03",
    "m0r_pickup_purple_in_red_hand_to_orange_03",
    "10"
)
CopyMarker(
    "m0r_pickup_purple_in_red_hand_to_orange_11_reuse_02",
    "m0r_pickup_purple_in_red_hand_to_orange_02",
    "11"
)

if OON.MARKERS.m0r_pickup_purple_in_red_hand_to_orange_10_reuse_03 then
    OON.MARKERS.m0r_pickup_purple_in_red_hand_to_orange_10_reuse_03.x = 54046
    OON.MARKERS.m0r_pickup_purple_in_red_hand_to_orange_10_reuse_03.z = 41609
end
if OON.MARKERS.m0r_pickup_purple_in_red_hand_to_orange_11_reuse_02 then
    OON.MARKERS.m0r_pickup_purple_in_red_hand_to_orange_11_reuse_02.x = 50246
    OON.MARKERS.m0r_pickup_purple_in_red_hand_to_orange_11_reuse_02.z = 41174
end

if OON.M0R_ROUTE_PROFILES and OON.M0R_ROUTE_PROFILES.pickup_purple_in_red_hand_to_orange then
    local profile = OON.M0R_ROUTE_PROFILES.pickup_purple_in_red_hand_to_orange
    profile.markers = {
        { id = "m0r_pickup_purple_in_red_hand_to_orange_01" },
        { id = "m0r_pickup_purple_in_red_hand_to_orange_02" },
        { id = "m0r_pickup_purple_in_red_hand_to_orange_03" },
        { id = "m0r_pickup_purple_in_red_hand_to_orange_04" },
        { id = "m0r_pickup_purple_in_red_hand_to_orange_05" },
        { id = "m0r_pickup_purple_in_red_hand_to_orange_06" },
        { id = "m0r_pickup_purple_in_red_hand_to_orange_07" },
        { id = "m0r_pickup_purple_in_red_hand_to_orange_08" },
        { id = "m0r_pickup_purple_in_red_hand_to_orange_09" },
        { id = "m0r_pickup_purple_in_red_hand_to_orange_10_reuse_03" },
        { id = "m0r_pickup_purple_in_red_hand_to_orange_11_reuse_02" },
        { id = "m0r_pickup_purple_in_red_hand_to_orange_10" },
        { id = "m0r_pickup_purple_in_red_hand_to_orange_11" },
        { id = "m0r_pickup_purple_in_red_hand_to_orange_12" },
        { id = "m0r_pickup_purple_in_red_hand_to_orange_13" },
    }
end

CopyMarker(
    "m0r_pickup_red_in_orange_hand_to_purple_12_reuse_07",
    "m0r_pickup_red_in_orange_hand_to_purple_07",
    "12"
)
CopyMarker(
    "m0r_pickup_red_in_orange_hand_to_purple_13_reuse_06",
    "m0r_pickup_red_in_orange_hand_to_purple_06",
    "13"
)
CopyMarker(
    "m0r_pickup_red_in_orange_hand_to_purple_14_reuse_05",
    "m0r_pickup_red_in_orange_hand_to_purple_05",
    "14"
)
CopyMarker(
    "m0r_pickup_red_in_orange_hand_to_purple_15_reuse_04",
    "m0r_pickup_red_in_orange_hand_to_purple_04",
    "15"
)

if OON.MARKERS.m0r_pickup_red_in_orange_hand_to_purple_12_reuse_07 then
    OON.MARKERS.m0r_pickup_red_in_orange_hand_to_purple_12_reuse_07.x = 40146
    OON.MARKERS.m0r_pickup_red_in_orange_hand_to_purple_12_reuse_07.z = 56027
end
if OON.MARKERS.m0r_pickup_red_in_orange_hand_to_purple_13_reuse_06 then
    OON.MARKERS.m0r_pickup_red_in_orange_hand_to_purple_13_reuse_06.x = 41453
    OON.MARKERS.m0r_pickup_red_in_orange_hand_to_purple_13_reuse_06.z = 54857
end
if OON.MARKERS.m0r_pickup_red_in_orange_hand_to_purple_14_reuse_05 then
    OON.MARKERS.m0r_pickup_red_in_orange_hand_to_purple_14_reuse_05.x = 42890
    OON.MARKERS.m0r_pickup_red_in_orange_hand_to_purple_14_reuse_05.z = 55147
end
if OON.MARKERS.m0r_pickup_red_in_orange_hand_to_purple_15_reuse_04 then
    OON.MARKERS.m0r_pickup_red_in_orange_hand_to_purple_15_reuse_04.x = 44719
    OON.MARKERS.m0r_pickup_red_in_orange_hand_to_purple_15_reuse_04.z = 55220
end

if OON.M0R_ROUTE_PROFILES and OON.M0R_ROUTE_PROFILES.pickup_red_in_orange_hand_to_purple then
    local profile = OON.M0R_ROUTE_PROFILES.pickup_red_in_orange_hand_to_purple
    profile.markers = {
        { id = "m0r_pickup_red_in_orange_hand_to_purple_01" },
        { id = "m0r_pickup_red_in_orange_hand_to_purple_02" },
        { id = "m0r_pickup_red_in_orange_hand_to_purple_03" },
        { id = "m0r_pickup_red_in_orange_hand_to_purple_04" },
        { id = "m0r_pickup_red_in_orange_hand_to_purple_05" },
        { id = "m0r_pickup_red_in_orange_hand_to_purple_06" },
        { id = "m0r_pickup_red_in_orange_hand_to_purple_07" },
        { id = "m0r_pickup_red_in_orange_hand_to_purple_08" },
        { id = "m0r_pickup_red_in_orange_hand_to_purple_09" },
        { id = "m0r_pickup_red_in_orange_hand_to_purple_10" },
        { id = "m0r_pickup_red_in_orange_hand_to_purple_11_custom" },
        { id = "m0r_pickup_red_in_orange_hand_to_purple_12_reuse_07" },
        { id = "m0r_pickup_red_in_orange_hand_to_purple_13_reuse_06" },
        { id = "m0r_pickup_red_in_orange_hand_to_purple_14_reuse_05" },
        { id = "m0r_pickup_red_in_orange_hand_to_purple_15_reuse_04" },
        { id = "m0r_pickup_red_in_orange_hand_to_purple_11" },
        { id = "m0r_pickup_red_in_orange_hand_to_purple_12" },
        { id = "m0r_pickup_red_in_orange_hand_to_purple_13" },
        { id = "m0r_pickup_red_in_orange_hand_to_purple_14" },
    }
end

CopyMarker(
    "m0r_pickup_orange_in_red_hand_to_purple_07_reuse_05",
    "m0r_pickup_orange_in_red_hand_to_purple_05",
    "7"
)
CopyMarker(
    "m0r_pickup_orange_in_red_hand_to_purple_08_reuse_04",
    "m0r_pickup_orange_in_red_hand_to_purple_04",
    "8"
)
CopyMarker(
    "m0r_pickup_orange_in_red_hand_to_purple_09_reuse_03",
    "m0r_pickup_orange_in_red_hand_to_purple_03",
    "9"
)
CopyMarker(
    "m0r_pickup_orange_in_red_hand_to_purple_10_reuse_02",
    "m0r_pickup_orange_in_red_hand_to_purple_02",
    "10"
)

if OON.MARKERS.m0r_pickup_orange_in_red_hand_to_purple_07_reuse_05 then
    OON.MARKERS.m0r_pickup_orange_in_red_hand_to_purple_07_reuse_05.x = 41952
    OON.MARKERS.m0r_pickup_orange_in_red_hand_to_purple_07_reuse_05.z = 36507
end
if OON.MARKERS.m0r_pickup_orange_in_red_hand_to_purple_08_reuse_04 then
    OON.MARKERS.m0r_pickup_orange_in_red_hand_to_purple_08_reuse_04.x = 45966
    OON.MARKERS.m0r_pickup_orange_in_red_hand_to_purple_08_reuse_04.z = 36240
end
if OON.MARKERS.m0r_pickup_orange_in_red_hand_to_purple_09_reuse_03 then
    OON.MARKERS.m0r_pickup_orange_in_red_hand_to_purple_09_reuse_03.x = 48646
    OON.MARKERS.m0r_pickup_orange_in_red_hand_to_purple_09_reuse_03.z = 38323
end
if OON.MARKERS.m0r_pickup_orange_in_red_hand_to_purple_10_reuse_02 then
    OON.MARKERS.m0r_pickup_orange_in_red_hand_to_purple_10_reuse_02.x = 49945
    OON.MARKERS.m0r_pickup_orange_in_red_hand_to_purple_10_reuse_02.z = 40926
end

if OON.M0R_ROUTE_PROFILES and OON.M0R_ROUTE_PROFILES.pickup_orange_in_red_hand_to_purple then
    local profile = OON.M0R_ROUTE_PROFILES.pickup_orange_in_red_hand_to_purple
    profile.markers = {
        { id = "m0r_pickup_orange_in_red_hand_to_purple_01" },
        { id = "m0r_pickup_orange_in_red_hand_to_purple_02" },
        { id = "m0r_pickup_orange_in_red_hand_to_purple_03" },
        { id = "m0r_pickup_orange_in_red_hand_to_purple_04" },
        { id = "m0r_pickup_orange_in_red_hand_to_purple_05" },
        { id = "m0r_pickup_orange_in_red_hand_to_purple_06" },
        { id = "m0r_pickup_orange_in_red_hand_to_purple_07_reuse_05" },
        { id = "m0r_pickup_orange_in_red_hand_to_purple_08_reuse_04" },
        { id = "m0r_pickup_orange_in_red_hand_to_purple_09_reuse_03" },
        { id = "m0r_pickup_orange_in_red_hand_to_purple_10_reuse_02" },
        { id = "m0r_pickup_orange_in_red_hand_to_purple_07" },
        { id = "m0r_pickup_orange_in_red_hand_to_purple_08" },
        { id = "m0r_pickup_orange_in_red_hand_to_purple_09" },
        { id = "m0r_pickup_orange_in_red_hand_to_purple_10" },
    }
end

CopyMarker(
    "m0r_orange_orb_from_purple_through_red_hand_to_orange_09_reuse_07",
    "m0r_orange_orb_from_purple_through_red_hand_to_orange_07",
    "9"
)

if OON.MARKERS.m0r_orange_orb_from_purple_through_red_hand_to_orange_09_reuse_07 then
    OON.MARKERS.m0r_orange_orb_from_purple_through_red_hand_to_orange_09_reuse_07.x = 58287
    OON.MARKERS.m0r_orange_orb_from_purple_through_red_hand_to_orange_09_reuse_07.z = 45105
end

if OON.M0R_ROUTE_PROFILES and OON.M0R_ROUTE_PROFILES.orange_orb_from_purple_through_red_hand_to_orange then
    local profile = OON.M0R_ROUTE_PROFILES.orange_orb_from_purple_through_red_hand_to_orange
    profile.markers = {
        { id = "m0r_orange_orb_from_purple_through_red_hand_to_orange_01" },
        { id = "m0r_orange_orb_from_purple_through_red_hand_to_orange_02" },
        { id = "m0r_orange_orb_from_purple_through_red_hand_to_orange_03" },
        { id = "m0r_orange_orb_from_purple_through_red_hand_to_orange_04" },
        { id = "m0r_orange_orb_from_purple_through_red_hand_to_orange_05" },
        { id = "m0r_orange_orb_from_purple_through_red_hand_to_orange_06" },
        { id = "m0r_orange_orb_from_purple_through_red_hand_to_orange_07" },
        { id = "m0r_orange_orb_from_purple_through_red_hand_to_orange_08" },
        { id = "m0r_orange_orb_from_purple_through_red_hand_to_orange_09_reuse_07" },
        { id = "m0r_orange_orb_from_purple_through_red_hand_to_orange_09" },
        { id = "m0r_orange_orb_from_purple_through_red_hand_to_orange_10" },
        { id = "m0r_orange_orb_from_purple_through_red_hand_to_orange_11" },
        { id = "m0r_orange_orb_from_purple_through_red_hand_to_orange_12" },
        { id = "m0r_orange_orb_from_purple_through_red_hand_to_orange_13" },
        { id = "m0r_orange_orb_from_purple_through_red_hand_to_orange_14" },
        { id = "m0r_orange_orb_from_purple_through_red_hand_to_orange_15" },
        { id = "m0r_orange_orb_from_purple_through_red_hand_to_orange_16" },
        { id = "m0r_orange_orb_from_purple_through_red_hand_to_orange_17" },
        { id = "m0r_orange_orb_from_purple_through_red_hand_to_orange_18" },
    }
end

CopyMarker(
    "m0r_purple_orb_from_orange_through_red_hand_to_purple_10_reuse_08",
    "m0r_purple_orb_from_orange_through_red_hand_to_purple_08",
    "10"
)
CopyMarker(
    "m0r_purple_orb_from_orange_through_red_hand_to_purple_11_reuse_07",
    "m0r_purple_orb_from_orange_through_red_hand_to_purple_07",
    "11"
)
CopyMarker(
    "m0r_purple_orb_from_orange_through_red_hand_to_purple_12_reuse_05",
    "m0r_purple_orb_from_orange_through_red_hand_to_purple_05",
    "12"
)

if OON.MARKERS.m0r_purple_orb_from_orange_through_red_hand_to_purple_10_reuse_08 then
    OON.MARKERS.m0r_purple_orb_from_orange_through_red_hand_to_purple_10_reuse_08.x = 42188
    OON.MARKERS.m0r_purple_orb_from_orange_through_red_hand_to_purple_10_reuse_08.z = 45677
end
if OON.MARKERS.m0r_purple_orb_from_orange_through_red_hand_to_purple_11_reuse_07 then
    OON.MARKERS.m0r_purple_orb_from_orange_through_red_hand_to_purple_11_reuse_07.x = 42657
    OON.MARKERS.m0r_purple_orb_from_orange_through_red_hand_to_purple_11_reuse_07.z = 41028
end
if OON.MARKERS.m0r_purple_orb_from_orange_through_red_hand_to_purple_12_reuse_05 then
    OON.MARKERS.m0r_purple_orb_from_orange_through_red_hand_to_purple_12_reuse_05.x = 46062
    OON.MARKERS.m0r_purple_orb_from_orange_through_red_hand_to_purple_12_reuse_05.z = 41401
end

if OON.M0R_ROUTE_PROFILES and OON.M0R_ROUTE_PROFILES.purple_orb_from_orange_through_red_hand_to_purple then
    local profile = OON.M0R_ROUTE_PROFILES.purple_orb_from_orange_through_red_hand_to_purple
    profile.markers = {
        { id = "m0r_purple_orb_from_orange_through_red_hand_to_purple_01" },
        { id = "m0r_purple_orb_from_orange_through_red_hand_to_purple_02" },
        { id = "m0r_purple_orb_from_orange_through_red_hand_to_purple_03" },
        { id = "m0r_purple_orb_from_orange_through_red_hand_to_purple_04" },
        { id = "m0r_purple_orb_from_orange_through_red_hand_to_purple_05" },
        { id = "m0r_purple_orb_from_orange_through_red_hand_to_purple_06" },
        { id = "m0r_purple_orb_from_orange_through_red_hand_to_purple_07" },
        { id = "m0r_purple_orb_from_orange_through_red_hand_to_purple_08" },
        { id = "m0r_purple_orb_from_orange_through_red_hand_to_purple_09" },
        { id = "m0r_purple_orb_from_orange_through_red_hand_to_purple_10_reuse_08" },
        { id = "m0r_purple_orb_from_orange_through_red_hand_to_purple_11_reuse_07" },
        { id = "m0r_purple_orb_from_orange_through_red_hand_to_purple_12_reuse_05" },
        { id = "m0r_purple_orb_from_orange_through_red_hand_to_purple_11" },
        { id = "m0r_purple_orb_from_orange_through_red_hand_to_purple_10" },
        { id = "m0r_purple_orb_from_orange_through_red_hand_to_purple_12" },
        { id = "m0r_purple_orb_from_orange_through_red_hand_to_purple_13" },
        { id = "m0r_purple_orb_from_orange_through_red_hand_to_purple_14" },
        { id = "m0r_purple_orb_from_orange_through_red_hand_to_purple_15" },
        { id = "m0r_purple_orb_from_orange_through_red_hand_to_purple_16" },
    }
end

CopyMarker(
    "m0r_hand_in_orange_orb_from_purple_07_reuse_05",
    "m0r_hand_in_orange_orb_from_purple_05",
    "7"
)
CopyMarker(
    "m0r_hand_in_orange_orb_from_purple_08_reuse_04",
    "m0r_hand_in_orange_orb_from_purple_04",
    "8"
)

if OON.MARKERS.m0r_hand_in_orange_orb_from_purple_07_reuse_05 then
    OON.MARKERS.m0r_hand_in_orange_orb_from_purple_07_reuse_05.x = 44320
    OON.MARKERS.m0r_hand_in_orange_orb_from_purple_07_reuse_05.z = 53960
end
if OON.MARKERS.m0r_hand_in_orange_orb_from_purple_08_reuse_04 then
    OON.MARKERS.m0r_hand_in_orange_orb_from_purple_08_reuse_04.x = 44740
    OON.MARKERS.m0r_hand_in_orange_orb_from_purple_08_reuse_04.z = 54890
end

if OON.M0R_ROUTE_PROFILES and OON.M0R_ROUTE_PROFILES.hand_in_orange_orb_from_purple then
    local profile = OON.M0R_ROUTE_PROFILES.hand_in_orange_orb_from_purple
    profile.markers = {
        { id = "m0r_hand_in_orange_orb_from_purple_01" },
        { id = "m0r_hand_in_orange_orb_from_purple_02" },
        { id = "m0r_hand_in_orange_orb_from_purple_03" },
        { id = "m0r_hand_in_orange_orb_from_purple_04" },
        { id = "m0r_hand_in_orange_orb_from_purple_05" },
        { id = "m0r_hand_in_orange_orb_from_purple_06" },
        { id = "m0r_hand_in_orange_orb_from_purple_07_reuse_05" },
        { id = "m0r_hand_in_orange_orb_from_purple_08_reuse_04" },
        { id = "m0r_hand_in_orange_orb_from_purple_07" },
        { id = "m0r_hand_in_orange_orb_from_purple_08" },
        { id = "m0r_hand_in_orange_orb_from_purple_09" },
    }
end

CopyMarker(
    "m0r_hand_in_orange_orb_from_red_side_07_reuse_05",
    "m0r_hand_in_orange_orb_from_red_side_05",
    "7"
)
CopyMarker(
    "m0r_hand_in_orange_orb_from_red_side_08_reuse_04",
    "m0r_hand_in_orange_orb_from_red_side_04",
    "8"
)

if OON.MARKERS.m0r_hand_in_orange_orb_from_red_side_07_reuse_05 then
    OON.MARKERS.m0r_hand_in_orange_orb_from_red_side_07_reuse_05.x = 43740
    OON.MARKERS.m0r_hand_in_orange_orb_from_red_side_07_reuse_05.z = 52980
end
if OON.MARKERS.m0r_hand_in_orange_orb_from_red_side_08_reuse_04 then
    OON.MARKERS.m0r_hand_in_orange_orb_from_red_side_08_reuse_04.x = 43140
    OON.MARKERS.m0r_hand_in_orange_orb_from_red_side_08_reuse_04.z = 51850
end

if OON.M0R_ROUTE_PROFILES and OON.M0R_ROUTE_PROFILES.hand_in_orange_orb_from_red_side then
    local profile = OON.M0R_ROUTE_PROFILES.hand_in_orange_orb_from_red_side
    profile.markers = {
        { id = "m0r_hand_in_orange_orb_from_red_side_01" },
        { id = "m0r_hand_in_orange_orb_from_red_side_02" },
        { id = "m0r_hand_in_orange_orb_from_red_side_03" },
        { id = "m0r_hand_in_orange_orb_from_red_side_04" },
        { id = "m0r_hand_in_orange_orb_from_red_side_05" },
        { id = "m0r_hand_in_orange_orb_from_red_side_06" },
        { id = "m0r_hand_in_orange_orb_from_red_side_07_reuse_05" },
        { id = "m0r_hand_in_orange_orb_from_red_side_08_reuse_04" },
        { id = "m0r_hand_in_orange_orb_from_red_side_07" },
        { id = "m0r_hand_in_orange_orb_from_red_side_08" },
        { id = "m0r_hand_in_orange_orb_from_red_side_09" },
    }
end

CopyMarker(
    "m0r_hand_in_red_orb_from_purple_side_05_reuse_02",
    "m0r_hand_in_red_orb_from_purple_side_02",
    "5"
)

if OON.MARKERS.m0r_hand_in_red_orb_from_purple_side_05_reuse_02 then
    OON.MARKERS.m0r_hand_in_red_orb_from_purple_side_05_reuse_02.x = 50343
    OON.MARKERS.m0r_hand_in_red_orb_from_purple_side_05_reuse_02.z = 41444
end

if OON.M0R_ROUTE_PROFILES and OON.M0R_ROUTE_PROFILES.hand_in_red_orb_from_purple_side then
    local profile = OON.M0R_ROUTE_PROFILES.hand_in_red_orb_from_purple_side
    profile.markers = {
        { id = "m0r_hand_in_red_orb_from_purple_side_01" },
        { id = "m0r_hand_in_red_orb_from_purple_side_02" },
        { id = "m0r_hand_in_red_orb_from_purple_side_03" },
        { id = "m0r_hand_in_red_orb_from_purple_side_04" },
        { id = "m0r_hand_in_red_orb_from_purple_side_05_reuse_02" },
        { id = "m0r_hand_in_red_orb_from_purple_side_05" },
        { id = "m0r_hand_in_red_orb_from_purple_side_06" },
        { id = "m0r_hand_in_red_orb_from_purple_side_07" },
        { id = "m0r_hand_in_red_orb_from_purple_side_08" },
    }
end
