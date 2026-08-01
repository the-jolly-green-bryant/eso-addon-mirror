Orgeborn_Config = {
  ConfigVersion = 8,
  ImportMode = "merge",

  -- Optional default (unused if you set per-trigger dests)
  defaultDestination = { mode="ACCOUNT", owner="@SublimeCaver", travelOutside=false },

  triggers = {
    -- Book near White Stallion Inn - tp to ravenhurst
    { type="BOOK", id=6532, dest={ mode="SPECIFIC", owner="@SublimeCaver", houseId=17, trueHouseId=17, collectibleId=1076, travelOutside=false } },

-- Book for rimmen tp
    { type="BOOK", id=4380, dest={ mode="SPECIFIC", owner="@SublimeCaver", houseId=68, trueHouseId=68, collectibleId=6380, travelOutside=true, allowSelfOutside=true } },

-- Book for leyawiin tp
    { type="BOOK", id=4287, dest={ mode="SPECIFIC", owner="@SublimeCaver", houseId=87, trueHouseId=87, collectibleId=9392, travelOutside=true, allowSelfOutside=true } },

-- Book for lava ladies vivec house tp
    { type="BOOK", id=5364, dest={ mode="SPECIFIC", owner="@elen_vetvistaya", houseId=43, trueHouseId=43, collectibleId=1243, travelOutside=false, allowSelfOutside=false } },

    -- Cat at White Stallion Inn: “Pet” (via chatter hook, reliable)
    { type="CHATTER", unit="Eater of Knowledge", optionMatch="Pet",
      dest={ mode="SPECIFIC", owner="@SublimeCaver", houseId=17, trueHouseId=17, travelOutside=false } },
  },
}
