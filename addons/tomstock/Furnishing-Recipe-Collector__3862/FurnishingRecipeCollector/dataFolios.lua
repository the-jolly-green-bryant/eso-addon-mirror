FurnishingRecipeCollector = FurnishingRecipeCollector or {}
local FRC = FurnishingRecipeCollector
FRC.Data = FRC.Data or {}
--https://en.uesp.net/wiki/Online:Furnisher_Documents
FRC.Data.Folios =
{
  --AUTOMATION START================================
  [190121]= --Blackwood Furnishing Folio
  {
    181557, --Blueprint: Leyawiin Divider, Carved Starfish
    181560, --Design: Leyawiin Bowl, Squid Special
    181556, --Diagram: Deadlands Torture Rack
    181561, --Formula: Blackwood Cottage Painting, Unframed
    181558, --Pattern: Leyawiin Tapestry, Hunting Party
    181559, --Praxis: Leyawiin Hearth, Carved Wood
    181562, --Sketch: Leyawiin Lightpost, Ornate
  },
  [171568]= --Crafter's Furnishing Folio
  {
    121200, --Blueprint: Cabinet, Poisonmaker's
    121166, --Blueprint: Podium, Skinning
    121168, --Blueprint: Tools, Case
    121199, --Design: Mortar and Pestle
    121214, --Design: Orcish Skull Goblet, Full
    121163, --Diagram: Apparatus, Boiler
    121165, --Diagram: Apparatus, Gem Calipers
    121197, --Formula: Bottle, Poison Elixir
    121164, --Formula: Case of Vials
    121209, --Pattern: Orcish Tapestry, Spear
    121207, --Praxis: Orcish Table with Fur
  },
  [171571]= --Dark Elf Furnishing Folio
  {
    134987, --Blueprint: Hlaalu Gaming Table, Foxes & Felines
    134986, --Design: Miniature Garden, Bottled
    134983, --Diagram: Hlaalu Gong
    134982, --Formula: Alchemical Apparatus, Master
    134984, --Pattern: Clothier's Form, Brass
    134985, --Praxis: Hlaalu Trinket Box, Curious Turtle
  },
  [194429]= --Deadlands Furnishing Folio
  {
    184154, --Blueprint: Alinor Easel, Carved
    184156, --Design: Blackwood Provisioning Station
    184150, --Diagram: Deadlands Throne
    184152, --Formula: Fargrave Water Globules, Static
    184151, --Pattern: Deadlands Tapestry, Mehrunes Dagon
    184149, --Praxis: Deadlands Puzzle Cube
    184153, --Sketch: Fargrave Window, Grand Medallion
  },
  [171778]= --Dragonhold Furnishing Folio
  {
    159500, --Blueprint: Elsweyr Well, Covered
    159503, --Design: Elsweyr Bread Basket, Feast-Day
    159498, --Diagram: Elsweyr Gong, Ornate
    159502, --Formula: Elsweyr Mortar and Pestle, Engraved
    159499, --Pattern: Elsweyr Bed, Senche-Raht
    159501, --Praxis: Khajiit Sigil, Moon Cycle
    159504, --Sketch: Elsweyr Game, Swan Stones
  },
  [171573]= --Ebonheart Furnishing Folio
  {
    147652, --Blueprint: Frog-Caller, Untuned
    147653, --Design: Pottery Wheel, Ever-Turning
    147657, --Diagram: Hlaalu Stove, Chiminea
    147654, --Formula: Alchemical Apparatus, Condenser
    147656, --Pattern: Dark Elf Tent, Canopy
    147655, --Praxis: Hlaalu Salt Lamp, Enchanted
    147651, --Sketch: Silver Kettle, Masterworked
  },
  [171574]= --Elsweyr Furnishing Folio
  {
    153731, --Blueprint: Elsweyr Cart, Masterwork
    153734, --Design: Provisioning Station, Elsweyr Grill
    153729, --Diagram: Elsweyr Gate, Masterwork
    153733, --Formula: Elsweyr Incense, Fragrant
    153730, --Pattern: Elsweyr Chaise Lounge, Upholstered
    153732, --Praxis: Elsweyr Statue, Shrine Lion
    153735, --Sketch: Elsweyr Cage, Filigree
  },
  [204499]= --Galen Furnishing Folio
  {
    194398, --Blueprint: Druidic Bridge, Living
    194394, --Design: Druidic Oven, Stone
    194397, --Diagram: Statue, Bronze Tentacle
    194393, --Forumula: Druidic Throne, Y'ffre's Bloom
    194395, --Pattern: Mage Tapestry, Aurbic Phoenix
    194396, --Praxis: Stone, Lava-Etched
    194392, --Sketch: Resonance Crystal, Cerulean
  },
  [198597]= --High Isle Furnishing Folio
  {
    190080, --Blueprint: High Isle Caravel, Miniature
    190079, --Design: Shark Jaw, Massive
    190075, --Diagram: High Isle Beacon, Unlit
    190074, --Formula: Potted Trees, Stonelore Dogwood
    190076, --Pattern: High Isle Tapestry, Seaside Tourney
    190077, --Praxis: High Isle Hearth, Tilework
    190078, --Sketch: High Isle Hourglass, Gold
  },
  [184192]= --Markarth Furnishing Folio
  {
    171803, --Blueprint: Solitude Well, Noble
    171806, --Design: Provisioning Station, Solitude Grill
    171801, --Diagram: Dwarven Minecart, Ornate
    171805, --Formula: Vampiric Cauldron, Distilled Coagulant
    171802, --Pattern: Solitude Yarn Rack, Colorful
    171804, --Praxis: Solitude Hearth, Rounded Tall
    171807, --Sketch: Dwarven Crystal Sconce, Mirror
  },
  [171569]= --Morrowind Furnishing Folio
  {
    132195, --Blueprint: Telvanni Candelabra, Masterwork
    132194, --Design: Mammoth Cheese, Mastercrafted
    132191, --Diagram: Dwarven Gyroscope, Masterwork
    132190, --Formula: Mages Apparatus, Master
    132192, --Pattern: Dres Sewing Kit, Master's
    132193, --Praxis: Hlaalu Bath Tub, Masterwork
  },
  [211090]= --Necrom Furnishing Folio
  {
    198062, --Blueprint: Necrom Cart, Funerary
    198065, --Design: Indoril Chandelier, Vine-Covered
    198061, --Diagram: Dwarven Door, Bronze
    198064, --Formula: Telvanni Lantern, Luminous Mushroom
    198060, --Pattern: Dark Elf Tent, Multiroom
    198063, --Praxis: Necrom Crematory, Furnace
    198059, --Sketch: Daedric Mirror, Nightmarish
  },
  [171572]= --Summerset Furnishing Folio
  {
    141904, --Blueprint: Alinor Bookcase, Grand Full
    141907, --Design: Alinor Grape Stomping Tub
    141902, --Diagram: Relic Vault, Impenetrable
    141906, --Formula: Artist's Palette, Pigment
    141903, --Pattern: Alinor Bed, Levitating
    141905, --Praxis: Alinor Gaming Table, Punctilious Conflict
    139486, --Sketch: Alinor Ancestor Clock, Celestial
    141896, --Sketch: Figurine, The Dragon's Glare
  },
  [214255]= --Tomehold Furnishing Folio
  {
    203319, --Blueprint: Pergola, Reclaimed Wood
    203320, --Design: Apocrypha Tree, Spore
    203323, --Diagram: Apocrypha Bookcase Platform
    203321, --Formula: Apocrypha Light Diffuser, Stalk
    203322, --Pattern: Apocrypha Book Press
    203325, --Praxis: Apocrypha Wall, Eye
    203324, --Sketch: Apocrypha Mirror, Intricate
  },
  [171808]= --Western Skyrim Furnishing Folio
  {
    167380, --Blueprint: Solitude Game, Blood-On-The-Snow
    167383, --Design: Solitude Smoking Rack, Fish
    167378, --Diagram: Vampiric Chandelier, Azure Wrought-Iron
    167382, --Formula: Winter Cardinal Painting, In Progress
    167379, --Pattern: Solitude Loom, Warp-Weighted
    167381, --Praxis: Ancient Nord Monolith, Head
    167384, --Sketch: Blackreach Geode, Iridescent
  },
  [219721]= --West Weald Furnishing Folio I
  {
    211039, --Blueprint: Colovian Keg, Gigantic Wine
    211038, --Design: Dawnwood Platter, Feast
    211034, --Diagram: Colovian Chandelier, Grapes
    211033, --Formula: Colovian Alembic Set, Colorful
    211035, --Pattern: Colovian Tapestry, Red Diamond
    211036, --Praxis: Colovian Glassblower's Furnace
    211037, --Sketch: Colovian Mirror, Standing
  },
  [223978]= --West Weald Furnishing Folio II
  {
    212562, --Blueprint: Colovian Wine Press
    212563, --Design: Colovian Grape Vat, Large
    212565, --Diagram: Ayleid Window, Turquoise Glass
    212564, --Formula: Dawnwood Hut, Partial
    212561, --Pattern: Wood Elf Tent, Saplings
    212566, --Praxis: Ayleid Sconce, Winged Floor
    212567, --Sketch: Guardian Key, Replica
  },

--AUTOMATION END======================================================================================================
}