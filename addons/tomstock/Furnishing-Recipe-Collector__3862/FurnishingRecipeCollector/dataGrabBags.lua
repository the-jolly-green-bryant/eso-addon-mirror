FurnishingRecipeCollector = FurnishingRecipeCollector or {}
local FRC = FurnishingRecipeCollector
FRC.Data = FRC.Data or {}
--https://en.uesp.net/wiki/Online:Furnisher_Documents
--RegexReplace on site:
--<li>.*?itemid=(\d*).*?>(.*?)<.*
--$1, --$2
FRC.Data.FurnisherDocuments =
{
  --AUTOMATION START================================
  [184191]= --Blackwood Journeyman Furnisher's Document
  {
    175955, --Blueprint: Leyawiin Armchair, Backless
    175959, --Blueprint: Leyawiin Bench, Formal Wide
    175927, --Blueprint: Leyawiin Bookcase, Narrow
    175924, --Blueprint: Leyawiin Bookcase, Short
    175925, --Blueprint: Leyawiin Bookcase, Tall
    175920, --Blueprint: Leyawiin Cabinet, Sturdy
    175918, --Blueprint: Leyawiin Counter, Corner
    175919, --Blueprint: Leyawiin Counter, Long
    175915, --Blueprint: Leyawiin Cupboard, Sturdy
    175943, --Blueprint: Leyawiin End Table, Formal Round
    175951, --Blueprint: Leyawiin Nightstand, Formal
    176026, --Blueprint: Leyawiin Ox Cart, Sturdy
    176020, --Blueprint: Leyawiin Plates, Stack
    175968, --Blueprint: Leyawiin Sconce, Lantern
    175965, --Blueprint: Leyawiin Streetlight, Carved Waves
    175947, --Blueprint: Leyawiin Table, Formal
    175944, --Blueprint: Leyawiin Table, Formal Square Low
    175948, --Blueprint: Leyawiin Table, Sturdy Grand
    175963, --Blueprint: Leyawiin Trunk, Carved Octad
    175917, --Blueprint: Leyawiin Wall Shelf, Carved
    176010, --Design: Leyawiin Bowl, Lobster Stew
    176014, --Design: Leyawiin Gravy Boat, Silver
    176005, --Design: Leyawiin Kylix, Silver
    176016, --Design: Leyawiin Meal, Clams
    176017, --Design: Leyawiin Meal, Lobster
    176012, --Design: Leyawiin Meal, Octopus
    176013, --Design: Leyawiin Meal, Squid
    176011, --Design: Leyawiin Meal, Vegetables
    176003, --Design: Leyawiin Mug, Milk
    176021, --Design: Leyawiin Platter, Seafood
    175973, --Diagram: Leyawiin Brazier, Iron
    175971, --Diagram: Leyawiin Brazier, Short Iron Serpent
    175980, --Diagram: Leyawiin Chandelier, Twin Lanterns
    175970, --Diagram: Leyawiin Lamp, Stationary
    175987, --Diagram: Leyawiin Wall Mirror, Lacquered Frame
    175988, --Pattern: Leyawiin Basket, Hamper Tall
    175989, --Pattern: Leyawiin Basket, Hamper Wide
    175932, --Pattern: Leyawiin Bed, Sturdy Single
    175942, --Pattern: Leyawiin Carpet, Large Carmine Octad
    175941, --Pattern: Leyawiin Carpet, Large Misty Octad
    175984, --Pattern: Leyawiin Clothesline, Pulleys
    175985, --Pattern: Leyawiin Laundry, Stack
    175939, --Pattern: Leyawiin Rug, Carmine Octad
    175935, --Pattern: Leyawiin Tapestry, Lone Vessel
    175936, --Pattern: Leyawiin Tapestry, Twin Vessels
    175977, --Praxis: Leyawiin Firepit, Stone
    175997, --Praxis: Leyawiin Pot, Waves
    176000, --Praxis: Leyawiin Potted Plant, Aspen Sapling
    176002, --Sketch: Leyawiin Hand Mirror, Lacquered
  },
  [184190]= --Blackwood Master Furnisher's Document
  {
    175954, --Blueprint: Leyawiin Armchair, Cushioned
    175922, --Blueprint: Leyawiin Armoire, Formal
    175956, --Blueprint: Leyawiin Bench, Cushioned
    175958, --Blueprint: Leyawiin Bench, Cushioned Wide
    175929, --Blueprint: Leyawiin Bookcase, Grand Filled
    175928, --Blueprint: Leyawiin Bookcase, Narrow Filled
    175926, --Blueprint: Leyawiin Bookcase, Tall Filled
    176024, --Blueprint: Leyawiin Counter, Wide Merchant
    175916, --Blueprint: Leyawiin Cupboard, Formal
    175921, --Blueprint: Leyawiin Cupboard, Formal Display
    175952, --Blueprint: Leyawiin Desk, Formal
    175982, --Blueprint: Leyawiin Divider, Octopus
    176025, --Blueprint: Leyawiin Merchant Stall, Portable
    175949, --Blueprint: Leyawiin Table, Formal Grand
    175964, --Blueprint: Leyawiin Trunk, Floral Gilded
    175962, --Blueprint: Leyawiin Trunk, Ornate
    176022, --Blueprint: Leyawiin Wagon, Covered
    175923, --Blueprint: Leyawiin Wardrobe, Formal
    176015, --Design: Leyawiin Pie, Octopus
    176009, --Design: Leyawiin Serving Pot, Lobster Stew
    175974, --Diagram: Leyawiin Brazier, Copper
    175972, --Diagram: Leyawiin Brazier, Tall Copper Serpent
    175991, --Diagram: Leyawiin Censer, Iron Stand
    175992, --Diagram: Leyawiin Censer, Serpents
    175979, --Diagram: Leyawiin Chandelier, Brass
    175978, --Diagram: Leyawiin Chandelier, Grand Brass
    175976, --Diagram: Leyawiin Lamp, Oil
    175975, --Diagram: Leyawiin Lamp, Oil Double
    175966, --Diagram: Leyawiin Lamppost, Floral Gilded
    175967, --Diagram: Leyawiin Sconce, Gilded Lantern
    175986, --Diagram: Leyawiin Wall Mirror, Silver
    175930, --Pattern: Leyawiin Bed, Formal Double
    175931, --Pattern: Leyawiin Bed, Formal Single
    175938, --Pattern: Leyawiin Carpet, Grand Carmine Octad
    175937, --Pattern: Leyawiin Tapestry, Fleet
    175933, --Pattern: Leyawiin Tapestry, Floral
    175995, --Praxis: Leyawiin Amphora, Elegant
    175994, --Praxis: Leyawiin Pitcher, Elegant
    175983, --Praxis: Leyawiin Well, Covered
    176001, --Sketch: Leyawiin Hand Mirror, Silver
    175960, --Sketch: Leyawiin Jewelry Box, Gilded
    175961, --Sketch: Leyawiin Jewelry Box, Iron Octopus
  },
  [153623]= --Clockwork Mixed Furnisher's Document
  {
    134516, --Design: Clockwork Bowl, Large Nutriment Paste
    134522, --Design: Clockwork Goblet, Recycled Water
    134526, --Design: Clockwork Meal, Dish
    134527, --Design: Clockwork Meal, Plate
    134546, --Design: Clockwork Paste Dispenser, Empty
    134509, --Diagram: Clockwork Cabinet, Sequence Plaque
    134502, --Diagram: Clockwork Chair, Practical
    134503, --Diagram: Clockwork Chair, Reinforced
    134518, --Diagram: Clockwork Coffer, Robust
    134505, --Diagram: Clockwork Drafting Table, Flat
    134504, --Diagram: Clockwork Drafting Table, Raised
    134500, --Diagram: Clockwork Furnace, Socketed
    134521, --Diagram: Clockwork Goblet, Empty
    134508, --Diagram: Clockwork Lectern, Empty
    134525, --Diagram: Clockwork Mug, Reinforced
    134513, --Diagram: Clockwork Nightstand, Octagonal
    134494, --Diagram: Clockwork Pump, Vertical
    134528, --Diagram: Clockwork Scales, Precision Calibrated
    134529, --Diagram: Clockwork Sequence Plaques, Folded
    134530, --Diagram: Clockwork Sequence Plaques, Unfolded
    134506, --Diagram: Clockwork Sequence Spool, Single
    134507, --Diagram: Clockwork Sequence Spool, Triple
    134501, --Diagram: Clockwork Somnolostation
    134534, --Diagram: Clockwork Surveyor's Tripod, Calibrated
    134511, --Diagram: Clockwork Table, Beveled
    134514, --Diagram: Clockwork Table, Grand
    134497, --Diagram: Clockwork Vent, Octagonal Fan
    134543, --Diagram: Clockwork Wall Machinery, Arched
    134515, --Diagram: Clockwork Wardrobe, Precision Engineered
    134493, --Formula: Clockwork Lamppost, Gas
    134482, --Formula: Fabricant Tree, Cobalt Spruce
    134479, --Formula: Fabricant Tree, Electrum
    134481, --Formula: Fabricant Tree, Miniature Cherry Blossom
    134480, --Formula: Fabricant Tree, Vibrant Cherry Blossom
    134477, --Formula: Fabricant Trees, Clustered Maple
    134544, --Praxis: Clockwork Charging Station, Animo Core
    134545, --Praxis: Clockwork Charging Station, Factotum
    134498, --Praxis: Clockwork Control Panel, Single
    134538, --Praxis: Clockwork Illuminator, Capsule Tower
    134540, --Praxis: Clockwork Illuminator, Compact
    134539, --Praxis: Clockwork Illuminator, Compact Stand
    134535, --Praxis: Clockwork Illuminator, Personal Desk
    134537, --Praxis: Clockwork Illuminator, Powered Capsule
    134536, --Praxis: Clockwork Illuminator, Solitary Capsule
    134524, --Praxis: Clockwork Mortar and Pestle, Sintered
    134496, --Praxis: Clockwork Switch, Sturdy
  },
  [190870]= --Deadlands Mixed Furnisher's Document
  {
    182963, --Blueprint: Deadlands Armoire, Etched
    182964, --Blueprint: Deadlands Bookcase, Etched
    182940, --Blueprint: Deadlands Bookcase, Large Ashen
    183003, --Blueprint: Deadlands Bookcase, Large Cluttered
    182969, --Blueprint: Deadlands Table, Etched
    182968, --Blueprint: Deadlands Table, Long Etched
    182938, --Blueprint: Fargrave Counter, Merchant
    182939, --Blueprint: Fargrave Stall, Large Merchant
    182996, --Design: Fargrave Box of Fruit
    182948, --Design: Fargrave Bread and Sweetrolls
    182947, --Design: Fargrave Bread, Baguettes
    182946, --Design: Fargrave Bread, Round Loaves
    182995, --Design: Fargrave Bread, Various Loaves
    182999, --Design: Fargrave Corn, Bunch
    182997, --Design: Fargrave Fish Pile, Marinated Trout
    182949, --Design: Fargrave Meats
    182945, --Design: Fargrave Sausages
    182998, --Design: Fargrave Tomato Bunch
    182966, --Diagram: Deadlands Bench, Etched Wide
    182950, --Diagram: Deadlands Brazier, Large Etched
    182952, --Diagram: Deadlands Candelabra, Tall
    182951, --Diagram: Deadlands Candelabra, Tall Caged
    182954, --Diagram: Deadlands Candleholder, Etched
    182962, --Diagram: Deadlands Chair, Etched
    182953, --Diagram: Deadlands Crystal Brazier
    182955, --Diagram: Deadlands Sconce, Large
    182967, --Diagram: Deadlands Tenderizer
    182965, --Diagram: Deadlands Torture Table, Etched
    182957, --Formula: Deadlands Gems, Levitating
    182942, --Formula: Fargrave Gems, Levitating
    182972, --Formula: Fargrave Terrarium, Flower
    182975, --Formula: Fargrave Terrarium, Large Gas Blossom
    182974, --Formula: Fargrave Terrarium, Scuttlebloom
    182973, --Formula: Fargrave Terrarium, Small Gas Blossom
    182994, --Formula: Fargrave Terrarium, Watcher
    182976, --Pattern: Deadlands Carpet, Large
    182960, --Pattern: Deadlands Curtains, Closed
    182958, --Pattern: Deadlands Curtains, Open
    182977, --Pattern: Deadlands Rug
    182978, --Pattern: Deadlands Rug, Small
    182959, --Pattern: Deadlands Tapestry
    182961, --Pattern: Deadlands Tapestry, Long
    182941, --Pattern: Fargrave Book Stack, Levitating
    182970, --Praxis: Deadlands Lightning Rod, Crescent
    182971, --Praxis: Deadlands Lightning Rod, Spike
    183004, --Praxis: Fargrave Bench, Long Stone
    182937, --Praxis: Fargrave Bench, Stone
  },
  [159653]= --Elsweyr Journeyman Furnisher's Document
  {
    152035, --Blueprint: Elsweyr Armchair, Low-Backed Wooden
    152042, --Blueprint: Elsweyr Bookcase, Elegant Wooden
    152044, --Blueprint: Elsweyr Bookcase, Short Elegant
    152040, --Blueprint: Elsweyr Bookcase, Wooden
    152055, --Blueprint: Elsweyr Cabinet, Elegant Wooden
    152053, --Blueprint: Elsweyr Cabinet, Wall
    152032, --Blueprint: Elsweyr Couch, Wooden
    152060, --Blueprint: Elsweyr Desk, Wooden
    151979, --Blueprint: Elsweyr Meal, Hearty Noodles
    152059, --Blueprint: Elsweyr Nightstand, Wooden
    152054, --Blueprint: Elsweyr Shelf, Elegant Wall
    152019, --Blueprint: Elsweyr Stall Counter, Single
    152063, --Blueprint: Elsweyr Table, Low
    152064, --Blueprint: Elsweyr Table, Low Square
    152061, --Blueprint: Elsweyr Table, Square
    152062, --Blueprint: Elsweyr Table, Wide
    151978, --Design: Elsweyr Bowl, Deep Ceramic
    151983, --Design: Elsweyr Bowl, Shallow Ceramic
    151980, --Design: Elsweyr Fish, Displayed
    151984, --Design: Elsweyr Meal, Root Vegetables
    152086, --Design: Elsweyr Sconce, Candle Carved
    152084, --Design: Elsweyr Sconce, Candle Elegant
    152085, --Design: Elsweyr Sconce, Candle Engraved
    152087, --Design: Elsweyr Sconce, Candle Shielded
    151987, --Design: Elsweyr Steamer, Ceramic
    152106, --Diagram: Hakoshae Hook, Block
    152107, --Diagram: Hakoshae Pillar, Wooden Hooked
    152038, --Pattern: Elsweyr Barstool, Wooden
    152012, --Pattern: Elsweyr Bed, Quilted Double
    152011, --Pattern: Elsweyr Bed, Quilted Single
    152013, --Pattern: Elsweyr Bed, Rumpled Quilted Single
    152093, --Pattern: Elsweyr Carpet, Chaotic Symmetry
    152022, --Pattern: Elsweyr Curtains, Flat Panel Maroon
    152023, --Pattern: Elsweyr Curtains, Tied-Back Blue
    152024, --Pattern: Elsweyr Fabric, Hanging
    152025, --Pattern: Elsweyr Fabric, Hanging Cluster
    152096, --Pattern: Elsweyr Half-Rug, Sandflowers
    152097, --Pattern: Elsweyr Runner, Autumn Vines
    152100, --Pattern: Elsweyr Runner, Lavish Floral
    152103, --Pattern: Elsweyr Tapestry, Amber Vines
    152105, --Pattern: Elsweyr Tapestry, Ruby-Maroon
    152104, --Pattern: Elsweyr Tapestry, Verdant Blossom
    152102, --Pattern: Elsweyr Tapestry, Water Flowers
    152005, --Praxis: Elsweyr Altar, Ancient Stone
    152073, --Praxis: Elsweyr Brazier, Embellished
    152072, --Praxis: Elsweyr Brazier, Ribbed
    152030, --Praxis: Elsweyr Column, Stone Support
    152114, --Praxis: Elsweyr Floor, Masonry
    152116, --Praxis: Elsweyr Foot Bridge, Masonry
    152081, --Praxis: Elsweyr Lantern, Hanging Twist
    152076, --Praxis: Elsweyr Lightpost, Ancient Stone
    151974, --Praxis: Elsweyr Pillar, Ancient Stone
    153723, --Praxis: Elsweyr Platform, Ancient Square
    152113, --Praxis: Elsweyr Platform, Stepped
    151998, --Praxis: Elsweyr Pot, Cerulean
    151999, --Praxis: Elsweyr Pot, Floral
    152003, --Praxis: Elsweyr Sand Meditation Ring, Large
    152238, --Praxis: Elsweyr Sarcophagus Lid, Ancient
    152237, --Praxis: Elsweyr Sarcophagus, Ancient
    153725, --Praxis: Elsweyr Shrine, Ancient Multilevel
    153724, --Praxis: Elsweyr Shrine, Ancient Small
    152031, --Praxis: Elsweyr Spire, Decorative
    152115, --Praxis: Elsweyr Stairs, Masonry
    152077, --Praxis: Elsweyr Streetlight, Inlaid Stone
    151989, --Sketch: Elsweyr Cup of Rice, Gilded
    151991, --Sketch: Elsweyr Gravy Boat, Gilded
    152006, --Sketch: Elsweyr Incense Burner, Tall Brass
    152082, --Sketch: Elsweyr Lantern, Metal Ring
    152088, --Sketch: Elsweyr Lantern, Twist
    151990, --Sketch: Elsweyr Sugar Bowl, Gilded
    152008, --Sketch: Elsweyr Vessel, Umber Embellished
  },
  [159654]= --Elsweyr Master Furnisher's Document
  {
    152033, --Blueprint: Elsweyr Armchair, Elegant Wooden
    152036, --Blueprint: Elsweyr Armchair, Low-Backed Elegant
    152043, --Blueprint: Elsweyr Bookcase, Elegant Wooden Full
    152045, --Blueprint: Elsweyr Bookcase, Short Elegant Full
    152041, --Blueprint: Elsweyr Bookcase, Wooden Full
    152056, --Blueprint: Elsweyr Cabinet, Wide Elegant Wooden
    152052, --Blueprint: Elsweyr Chest, Red Gilded
    152120, --Blueprint: Elsweyr Couch, Elegant Wooden
    152046, --Blueprint: Elsweyr Cupboard, Elegant Wooden
    152065, --Blueprint: Elsweyr Desk, Elegant Wooden
    151982, --Blueprint: Elsweyr Meal, Whole Roasted Chicken
    152068, --Blueprint: Elsweyr Nightstand, Elegant Wooden
    152067, --Blueprint: Elsweyr Nightstand, Octagonal Wooden
    151981, --Blueprint: Elsweyr Plate, Umber Ceramic
    152057, --Blueprint: Elsweyr Room-Divider, Elegant
    152020, --Blueprint: Elsweyr Stall Counter, Triple
    152069, --Blueprint: Elsweyr Table, Elegant Wooden
    152066, --Blueprint: Elsweyr Table, Long Wooden
    152070, --Blueprint: Elsweyr Table, Wide Elegant Wooden
    152034, --Blueprint: Elsweyr Throne, Elegant Wooden
    152049, --Blueprint: Elsweyr Trunk, Floral
    152051, --Blueprint: Elsweyr Trunk, Peaked Embellished
    152050, --Blueprint: Elsweyr Trunk, Peaked Floral
    152048, --Blueprint: Elsweyr Wardrobe, Elegant Wooden
    152047, --Blueprint: Elsweyr Wardrobe, Wide Elegant Wooden
    152058, --Blueprint: Elsweyr Winerack, Cane Mead
    152071, --Blueprint: Elsweyr Writing Desk, Elegant Wooden
    152037, --Pattern: Elsweyr Barstool, Elegant Wooden
    152009, --Pattern: Elsweyr Bed, Blue Four-Poster
    152016, --Pattern: Elsweyr Bed, Elegant Double
    152015, --Pattern: Elsweyr Bed, Elegant Single
    152018, --Pattern: Elsweyr Bed, Rumpled Elegant Double
    152017, --Pattern: Elsweyr Bed, Rumpled Elegant Single
    152014, --Pattern: Elsweyr Bed, Rumpled Quilted Double
    152010, --Pattern: Elsweyr Bed, Yellow Four-Poster
    152101, --Pattern: Elsweyr Carpet, Blossoms on Blue
    152092, --Pattern: Elsweyr Carpet, Botanical Grand
    152094, --Pattern: Elsweyr Carpet, Sandflowers
    152021, --Pattern: Elsweyr Curtains, Wide Maroon
    152095, --Pattern: Elsweyr Rug, Sandflowers
    152029, --Pattern: Elsweyr Tent, Open
    152090, --Pattern: Hakoshae Lantern, Blue
    152091, --Pattern: Hakoshae Lantern, Crimson
    152089, --Pattern: Hakoshae Lantern, Linked Rings
    151972, --Praxis: Elsweyr Bookcase, Ancient Stone Full
    152075, --Praxis: Elsweyr Brazier, Massive
    152074, --Praxis: Elsweyr Brazier, Tall
    152080, --Praxis: Elsweyr Candle, Column
    152112, --Praxis: Elsweyr Fountain, Four Lions
    152079, --Praxis: Elsweyr Lightpost, Ancient Sturdy
    152078, --Praxis: Elsweyr Lightpost, Ancient Tall
    151975, --Praxis: Elsweyr Monument, Ancient Stone Broken
    151997, --Praxis: Elsweyr Pot, Tall
    153727, --Praxis: Elsweyr Shrine, Ancient Large
    153728, --Praxis: Elsweyr Tower, Ancient Huge
    152007, --Sketch: Elsweyr Incense Burner, Branched Brass
    151992, --Sketch: Elsweyr Steaming Pot, Ceramic
    152002, --Sketch: Elsweyr Sugar Pipe, Gilded
  },
  [198599]= --Galen Mixed Furnisher's Document
  {
    192533, --Blueprint: Druidic Bookcase, Tall Wood
    192534, --Blueprint: Druidic Cage, Ivy Wood
    192542, --Blueprint: High Isle Dresser, Wood
    192541, --Blueprint: High Isle Nightstand, Wood
    192555, --Design: Druidic Chandelier, Firesong
    192556, --Design: Druidic Gourd Candle, Hanging
    192559, --Design: Druidic Incense Burner, Clay
    192560, --Design: Druidic Pot, Clay
    192557, --Design: Druidic Wind Chimes, Gourd
    192529, --Diagram: High Isle Censer, Metal
    192539, --Diagram: High Isle Copper Teapot
    192532, --Pattern: Druidic Bed, Wood Single
    192544, --Pattern: Druidic Tapestry, Woven
    192554, --Pattern: Druidic Wind Chimes, Stone
    192528, --Praxis: Druidic Bed, Ivy Stone Double
    192527, --Praxis: Druidic Bed, Ivy Stone Single
    192521, --Praxis: Druidic Bench, Curved Stone
    192520, --Praxis: Druidic Bench, Ivy Curved Stone
    192519, --Praxis: Druidic Bench, Ivy Stone
    192524, --Praxis: Druidic Bookcase, Tall Stone
    192536, --Praxis: Druidic Dresser, Ivy Open Stone
    192526, --Praxis: Druidic Dresser, Open Stone
    192523, --Praxis: Druidic End Table, Ivy Stone
    192561, --Praxis: Druidic Game, Marble Maze
    192517, --Praxis: Druidic Gourd Candles, Stone
    192518, --Praxis: Druidic Hearth, Stone
    192516, --Praxis: Druidic Meditation Stones, Tall
    192515, --Praxis: Druidic Sculpture, Sphere
    192514, --Praxis: Druidic Statue, Planter
    192537, --Praxis: Druidic Table, Stone
    192535, --Praxis: Druidic Trunk, Stone
    192545, --Praxis: Druidic Wall Stone, Fertility
    192547, --Praxis: Druidic Wall Stone, Flame
    192546, --Praxis: Druidic Wall Stone, Spirits
    192543, --Praxis: High Isle Fountain, Wall
  },
  [194430]= --High Isle Mixed Furnisher's Document
  {
    188150, --Blueprint: High Isle Bench, Padded
    188159, --Blueprint: High Isle Bench, Sturdy
    188168, --Blueprint: High Isle Bookcase, Carved Filled
    188169, --Blueprint: High Isle Bookcase, Wide Carved Filled
    188151, --Blueprint: High Isle Chair, Ornate
    188158, --Blueprint: High Isle Chair, Sturdy
    188156, --Blueprint: High Isle Counter, Sturdy
    188185, --Blueprint: High Isle Divider, Ornate
    188180, --Blueprint: High Isle Dresser, Carved
    188181, --Blueprint: High Isle End Table, Carved
    188167, --Blueprint: High Isle Nightstand, Ornate
    188176, --Blueprint: High Isle Plate, Compass Rose Setting
    188160, --Blueprint: High Isle Stool, Cushioned
    188157, --Blueprint: High Isle Stool, Sturdy
    188172, --Blueprint: High Isle Streetlight, Paired
    188153, --Blueprint: High Isle Table, Compass Rose
    188152, --Blueprint: High Isle Table, Ornate
    188155, --Blueprint: High Isle Table, Sturdy
    188154, --Blueprint: High Isle Tea Table, Round Wheel
    188165, --Blueprint: High Isle Trunk, Ornate
    188166, --Blueprint: High Isle Trunk, Sturdy
    188147, --Blueprint: High Isle Wardrobe, Compass Rose
    188177, --Design: High Isle Crab, Steamed
    188178, --Design: High Isle Crab, Steamed Pile
    188179, --Design: High Isle Mussel, Steamed Pile
    188171, --Diagram: High Isle Brazier, Standing
    188192, --Diagram: High Isle Lantern, Table
    188186, --Diagram: High Isle Mirror, Standing
    188174, --Diagram: High Isle Sconce, Glass
    188173, --Diagram: High Isle Sconce, Ornate
    188175, --Diagram: High Isle Serving Platter, Silver
    188184, --Formula: High Isle Herb Rack, Ladder
    188145, --Pattern: High Isle Bed, Canopy Full
    188182, --Pattern: High Isle Carpet, Ballroom
    188187, --Sketch: High Isle Wall Mirror, Gilded
  },
  [127106]= --Hlaalu Journeyman Furnisher's Document
  {
    115759, --Blueprint: Argonian Bar, Woven Corner
    115761, --Blueprint: Argonian Bed, Woven
    115762, --Blueprint: Argonian Bench, Woven
    115765, --Blueprint: Argonian Bookcase, Short Woven
    115768, --Blueprint: Argonian Bookcase, Sturdy
    115757, --Blueprint: Argonian Cage, Bird
    115756, --Blueprint: Argonian Cage, Rat
    115763, --Blueprint: Argonian Chair, Woven
    115766, --Blueprint: Argonian Dresser, Sturdy
    115771, --Blueprint: Argonian End Table, Woven
    115767, --Blueprint: Argonian Shelf, Woven
    115760, --Blueprint: Argonian Snakes in a Basket
    115769, --Blueprint: Argonian Stool, Woven
    115770, --Blueprint: Argonian Table, Formal
    115764, --Blueprint: Argonian Trunk, Sturdy
    115758, --Blueprint: Argonian Wind Chimes
    115937, --Blueprint: Breton Bench, Knotwork
    115938, --Blueprint: Breton Bookcase, Knotwork
    115963, --Blueprint: Breton Cart, Covered Open
    115939, --Blueprint: Breton Chair, Rocking
    115943, --Blueprint: Breton Chest of Drawers
    115940, --Blueprint: Breton Chest, Knotwork
    115944, --Blueprint: Breton Counter, Long Cabinet
    115942, --Blueprint: Breton Cupboard, Knotwork
    115947, --Blueprint: Breton Desk, Knotwork
    115941, --Blueprint: Breton Hutch, Knotwork
    115936, --Blueprint: Breton Pew, Knotwork
    115951, --Blueprint: Breton Rack, Wine
    115950, --Blueprint: Breton Shelf, Scrolled
    115964, --Blueprint: Breton Stall, Vending
    115946, --Blueprint: Breton Stool, Plain
    115948, --Blueprint: Breton Table, Round
    115949, --Blueprint: Breton Table, Square
    119420, --Blueprint: Cart, Sided
    121120, --Blueprint: Chair, Carved
    116032, --Blueprint: Dark Elf Bookcase, Sectioned
    116030, --Blueprint: Dark Elf Caravan, Cargo
    116034, --Blueprint: Dark Elf Counter, Bar
    116036, --Blueprint: Dark Elf Desk, Angled
    116031, --Blueprint: Dark Elf Dresser, Angled
    116065, --Blueprint: Dark Elf End Table, Angled
    116043, --Blueprint: Dark Elf Shelf, Barrel
    116039, --Blueprint: Dark Elf Stool, Angled
    116041, --Blueprint: Dark Elf Trestle, Scaled
    116029, --Blueprint: Dark Elf Wagon, Merchant
    116035, --Blueprint: Dark Elf Wardrobe, Scaled
    116042, --Blueprint: Dark Elf Wine Rack, Sturdy
    119540, --Blueprint: Desk, Engraved
    118963, --Blueprint: High Elf Bar, Overhanging
    118958, --Blueprint: High Elf Bed, Verdant
    118957, --Blueprint: High Elf Bed, Winged
    118960, --Blueprint: High Elf Bookcase, Verdant
    118961, --Blueprint: High Elf Chair, Verdant
    118962, --Blueprint: High Elf Chair, Winged
    118959, --Blueprint: High Elf Chest of Drawers
    118970, --Blueprint: High Elf Trunk, Winged
    118956, --Blueprint: High Elf Wagon, Sturdy
    118971, --Blueprint: High Elf Wine Rack, Folding
    119423, --Blueprint: Keg
    116122, --Blueprint: Khajiit Barstool, Padded
    116101, --Blueprint: Khajiit Bookcase, Short Arched
    116129, --Blueprint: Khajiit Counter, Long Cabinet
    116104, --Blueprint: Khajiit Nightstand, Gilded
    116105, --Blueprint: Khajiit Table, Formal
    116117, --Blueprint: Khajiit Tent, Mercantile
    116118, --Blueprint: Khajiit Tent, Storage
    116102, --Blueprint: Khajiit Trunk, Arched
    116119, --Blueprint: Khajiit Wagon, Reed
    116184, --Blueprint: Nord Armoire, Lattice
    116172, --Blueprint: Nord Bed, Sleigh
    116173, --Blueprint: Nord Bench, Plank
    116174, --Blueprint: Nord Bookcase, Short Alcove
    116166, --Blueprint: Nord Cart, Cargo
    116175, --Blueprint: Nord Chair, Braced
    116176, --Blueprint: Nord Counter, Long
    116177, --Blueprint: Nord Dresser, Braced
    116190, --Blueprint: Nord Drinking Horn, Empty
    116183, --Blueprint: Nord Footlocker, Braced
    116185, --Blueprint: Nord Rack, Wine
    116178, --Blueprint: Nord Stool, Braced
    116181, --Blueprint: Nord Table, Braced
    116179, --Blueprint: Nord Table, Dining
    116180, --Blueprint: Nord Table, Round
    116182, --Blueprint: Nord Trestle, Braced
    116167, --Blueprint: Nord Trunk, Faded
    119043, --Blueprint: Orcish Armchair, Peaked
    119051, --Blueprint: Orcish Bar, Long Branded Block
    119045, --Blueprint: Orcish Bedding, Peaked
    119040, --Blueprint: Orcish Bucket, Cistern
    119047, --Blueprint: Orcish Bunkbed, Leather
    119053, --Blueprint: Orcish Cabinet, Branded
    119048, --Blueprint: Orcish Chair, Peaked
    119052, --Blueprint: Orcish Counter, Branded
    119041, --Blueprint: Orcish Curtain, Folding
    119044, --Blueprint: Orcish Pew, Peaked
    119036, --Blueprint: Orcish Platform, Stage
    119242, --Blueprint: Redguard Bookcase, Arched
    119171, --Blueprint: Redguard Cabinet, Inlaid
    119215, --Blueprint: Redguard Candleholder, Polished
    119214, --Blueprint: Redguard Candlestick, Polished
    119163, --Blueprint: Redguard Caravan, Practical
    119164, --Blueprint: Redguard Carriage, Merchant
    119168, --Blueprint: Redguard Cask, Sealed
    119176, --Blueprint: Redguard Counter, Cabinet
    119175, --Blueprint: Redguard Counter, Corner
    119173, --Blueprint: Redguard Cupboard, Lattice
    119179, --Blueprint: Redguard Divider, Florid
    119301, --Blueprint: Redguard End Table, Inlaid
    119190, --Blueprint: Redguard End Table, Oasis
    119187, --Blueprint: Redguard Footlocker, Braced
    119169, --Blueprint: Redguard Keg, Hefty
    119178, --Blueprint: Redguard Nightstand, Florid
    119193, --Blueprint: Redguard Shelf, Arched
    119182, --Blueprint: Redguard Stool, Padded
    119188, --Blueprint: Redguard Table, Grand Oasis
    119295, --Blueprint: Redguard Table, Inlaid
    119189, --Blueprint: Redguard Table, Oasis
    119191, --Blueprint: Redguard Trunk, Bolted
    119194, --Blueprint: Redguard Wardrobe, Inlaid
    119259, --Blueprint: Redguard Wine Rack, Inlaid
    119192, --Blueprint: Redguard Wine Rack, Sturdy
    115871, --Blueprint: Wood Elf Rack, Single
    115755, --Design: Argonian Totem, Frilled Skull
    115753, --Design: Argonian Totem, Painted Skull
    119438, --Design: Baked Potato, Display
    119477, --Design: Basket of Apples
    119478, --Design: Basket of Apples, Full
    119481, --Design: Basket of Corn
    119480, --Design: Basket of Gourds
    119479, --Design: Basket of Lettuce
    119482, --Design: Basket of Tomatoes
    119533, --Design: Box of Plums
    119529, --Design: Bread Loaves, Round
    119525, --Design: Bread, Braided
    119532, --Design: Bread, Hearty Loaves
    119527, --Design: Bread, Round
    115957, --Design: Breton Amphora, Glazed
    119032, --Design: Breton Chamberstick, Short
    119033, --Design: Breton Chamberstick, Tall
    115955, --Design: Breton Pottery, Lid
    115956, --Design: Breton Urn, Glazed
    115959, --Design: Breton Vase, Glazed
    119489, --Design: Candle Set, Ritual
    119444, --Design: Candle, Group
    119427, --Design: Cheese Wedge
    119467, --Design: Cured Meat
    119470, --Design: Cured Meat Chunk
    119469, --Design: Cured Meat Chunks
    119472, --Design: Cured Meat Hock
    119471, --Design: Cured Meat Pile
    119491, --Design: Cured Meat Shank
    119468, --Design: Cured Meats
    119443, --Design: Drumstick
    119543, --Design: Fish, Large
    119542, --Design: Fish, Medium
    119541, --Design: Fish, Small
    119526, --Design: Goblet, Wine
    119429, --Design: Ham, Display
    119425, --Design: Hearty Bread
    116111, --Design: Khajiit Carafe, Amber
    116112, --Design: Khajiit Decanter, Amber
    116106, --Design: Khajiit Jug, Amber
    116107, --Design: Khajiit Pitcher, Amber
    116170, --Design: Nord Amphora, Glazed
    116168, --Design: Nord Cauldron, Glazed
    116186, --Design: Nord Crockpot, Carrot Soup
    116169, --Design: Nord Pot, Empty
    116171, --Design: Nord Vase, Bent
    119465, --Design: Oranges, Bunch
    119062, --Design: Orcish Goblet, Stone
    119066, --Design: Orcish Urn, Ceramic
    119065, --Design: Orcish Vessel, Sealed Ceramic
    119464, --Design: Peaches, Bunch
    119462, --Design: Plums, Bunch
    119439, --Design: Pot Pie, Display
    119167, --Design: Redguard Amphora, Polished
    119195, --Design: Redguard Kabobs, Plate
    119166, --Design: Redguard Pot, Lacquered
    119231, --Design: Redguard Urn, Mural
    119165, --Design: Redguard Vase, Lacquered
    119463, --Design: Tangerines, Bunch
    115865, --Design: Wood Elf Barrel, Ceramic
    115883, --Design: Wood Elf Bowl, Striped
    115866, --Design: Wood Elf Cask, Ceramic
    115868, --Design: Wood Elf Cauldron, Ceramic
    115882, --Design: Wood Elf Pitcher, Ceramic
    115881, --Design: Wood Elf Pitcher, Chipped
    115878, --Design: Wood Elf Pitcher, Marked
    115877, --Design: Wood Elf Pitcher, Painted
    115880, --Design: Wood Elf Vase, Chipped
    115879, --Design: Wood Elf Vase, Painted
    115875, --Design: Wood Elf Vessel, Tiered Ceramic
    115876, --Design: Wood Elf Vessel, Tiered Painted
    115772, --Diagram: Argonian Bowl, Serving
    115773, --Diagram: Argonian Cup, Bordered
    115965, --Diagram: Breton Lightpost, Arched
    115945, --Diagram: Breton Shelf, Barrel Rack
    115961, --Diagram: Breton Streetlight, Arched Stone
    115966, --Diagram: Breton Streetlight, Paired
    115962, --Diagram: Breton Streetlight, Paired Stone
    119413, --Diagram: Cauldron of Soup
    119416, --Diagram: Cauldron of Stew
    119418, --Diagram: Cauldron, Covered
    119424, --Diagram: Cleaver, Butcher's
    116048, --Diagram: Dark Elf Cauldron, Banded
    116052, --Diagram: Dark Elf Hook, Wall
    116078, --Diagram: Dark Elf Lantern, Ashen
    116069, --Diagram: Dark Elf Pot, Banded
    116044, --Diagram: Dark Elf Pot, Scaled
    116055, --Diagram: Dark Elf Streetlamp, Stone
    116056, --Diagram: Dark Elf Streetlamps, Stone
    119476, --Diagram: Grilling Rack
    119400, --Diagram: Hammer, Forge
    118981, --Diagram: High Elf Basin, Winged
    118977, --Diagram: High Elf Carafe, Gilded
    118980, --Diagram: High Elf Flute, Wine
    118983, --Diagram: High Elf Lamp, Oil
    118972, --Diagram: High Elf Platter, Gilded
    118978, --Diagram: High Elf Vase, Gilded
    119451, --Diagram: Kennel, Locked
    116121, --Diagram: Khajiit Barstool, Clawfoot
    116115, --Diagram: Khajiit Basin, Claw
    116114, --Diagram: Khajiit Brazier, Claw
    116093, --Diagram: Khajiit Candle, Clawfoot
    116116, --Diagram: Khajiit Lantern, Hanging
    119446, --Diagram: Lantern, Hanging
    119445, --Diagram: Lantern, Stationary
    116187, --Diagram: Nord Crockpot, Covered
    116189, --Diagram: Nord Lantern, Hanging
    119061, --Diagram: Orcish Bowl, Stone
    119068, --Diagram: Orcish Brazier, Pedestal
    119069, --Diagram: Orcish Chandelier, Practical
    119060, --Diagram: Orcish Footlocker, Buckled
    119067, --Diagram: Orcish Lantern, Hanging
    119063, --Diagram: Orcish Plate, Stone
    119064, --Diagram: Orcish Saucer, Stone
    119070, --Diagram: Orcish Sconce, Caged
    119049, --Diagram: Orcish Trunk, Heavy
    119440, --Diagram: Pie Dish, Empty
    119185, --Diagram: Redguard Bowl, Hanging Star
    119213, --Diagram: Redguard Brazier, Robust
    119204, --Diagram: Redguard Cauldron, Clawfoot
    119201, --Diagram: Redguard Goblet, Empty
    119202, --Diagram: Redguard Goblet, Full
    119206, --Diagram: Redguard Mug, Empty
    119207, --Diagram: Redguard Mug, Full
    119205, --Diagram: Redguard Sconce, Polished
    119177, --Diagram: Redguard Shelf, Barrel
    119211, --Diagram: Redguard Streetlamps, Paired
    119212, --Diagram: Redguard Streetlamps, Triple
    119208, --Diagram: Redguard Tankard, Empty
    119209, --Diagram: Redguard Tankard, Full
    119186, --Diagram: Redguard Urn, Star
    119401, --Diagram: Tongs, Forge
    116046, --Formula: Dark Elf Cruet, Glass
    116045, --Formula: Dark Elf Decanter, Glass
    118979, --Formula: High Elf Bottle, Winged
    119174, --Formula: Redguard Vanity, Florid
    115751, --Pattern: Argonian Basket, Closed
    115774, --Pattern: Argonian Basket, Woven
    115752, --Pattern: Argonian Bin, Woven
    115779, --Pattern: Argonian Curtain, Woven
    115780, --Pattern: Argonian Curtains, Woven
    115785, --Pattern: Argonian Lamppost
    115754, --Pattern: Argonian Rack, Drying
    115784, --Pattern: Argonian Scaleskin, Faded
    115782, --Pattern: Argonian Scaleskin, Pale
    115783, --Pattern: Argonian Scaleskin, Striped
    115778, --Pattern: Argonian Tray, Woven
    115934, --Pattern: Breton Bed, Four-Poster
    115935, --Pattern: Breton Bed, Full
    115954, --Pattern: Breton Carpet, Dark
    115952, --Pattern: Breton Carpet, Full
    115953, --Pattern: Breton Rug, Starburst
    116037, --Pattern: Dark Elf Bed, Full
    116070, --Pattern: Dark Elf Carpet, Ashen
    116050, --Pattern: Dark Elf Carpet, Fungal
    116049, --Pattern: Dark Elf Carpet, Mossy
    116047, --Pattern: Dark Elf Flags, Hanging
    116038, --Pattern: Dark Elf Pillow, Body
    118974, --Pattern: High Elf Carpet, Tree-Themed
    118973, --Pattern: High Elf Carpet, Water-Themed
    118976, --Pattern: High Elf Tapestry, Tree-Themed
    118975, --Pattern: High Elf Tapestry, Water-Themed
    116113, --Pattern: Khajiit Banner, Hooked
    116099, --Pattern: Khajiit Bed, Faded
    116100, --Pattern: Khajiit Bench, Padded
    116108, --Pattern: Khajiit Carpet, Sun
    116120, --Pattern: Khajiit Curtains, Moons
    116109, --Pattern: Khajiit Cushion, Long
    116110, --Pattern: Khajiit Cushion, Single
    116188, --Pattern: Nord Tapestry, Dragon
    119071, --Pattern: Orcish Banner, Hammer Fist
    119034, --Pattern: Orcish Canopy, Shingled
    119042, --Pattern: Orcish Curtain, Curved
    119039, --Pattern: Orcish Sack, Bean
    119038, --Pattern: Orcish Sack, Flour
    119037, --Pattern: Orcish Sack, Grain
    119035, --Pattern: Orcish Shelter, Shingled
    119172, --Pattern: Redguard Armchair, Cushioned
    119224, --Pattern: Redguard Awning, Desert Flame
    119282, --Pattern: Redguard Awning, Oasis
    119220, --Pattern: Redguard Basket, Closed
    119184, --Pattern: Redguard Bed, Full Arched
    119183, --Pattern: Redguard Bed, Wide Grand
    119226, --Pattern: Redguard Canopy, Dawn
    119198, --Pattern: Redguard Carpet, Dunes
    119170, --Pattern: Redguard Couch, Padded
    119197, --Pattern: Redguard Mat, Sunset
    119196, --Pattern: Redguard Runner, Sun
    119180, --Pattern: Redguard Sofa, Desert Flame
    119199, --Pattern: Redguard Tapestry, Lattice
    119225, --Pattern: Redguard Tent, Scaled Flames
    119283, --Pattern: Redguard Tent, Starry
    119181, --Pattern: Redguard Tuffet, Flames
    115885, --Pattern: Wood Elf Bedding, Layered
    115867, --Pattern: Wood Elf Bladder, Fermenting
    115863, --Pattern: Wood Elf Bookcase, Leather
    115884, --Pattern: Wood Elf Canopy, Braced
    115862, --Pattern: Wood Elf Chair, Leather
    115873, --Pattern: Wood Elf Divider, Relaxed
    115874, --Pattern: Wood Elf Divider, Taut
    115870, --Pattern: Wood Elf Hammock, Double
    115869, --Pattern: Wood Elf Hammock, Single
    115872, --Pattern: Wood Elf Rack, Double
    115864, --Pattern: Wood Elf Table, Formal
    115861, --Pattern: Wood Elf Tent, Sturdy
    115775, --Praxis: Argonian Bowl, Bordered
    115781, --Praxis: Argonian Medallion, Stone
    115776, --Praxis: Argonian Ramekin, Bordered
    115777, --Praxis: Argonian Urn, Clawfoot
    118964, --Praxis: High Elf Desk, Verdant
    118965, --Praxis: High Elf Dresser, Verdant
    118966, --Praxis: High Elf End Table, Verdant
    118982, --Praxis: High Elf Lamppost, Spiked
    118967, --Praxis: High Elf Table, Verdant Formal
    118968, --Praxis: High Elf Table, Verdant Kitchen
    118969, --Praxis: High Elf Trestle, Verdant
    119046, --Praxis: Orcish Bookcase, Engraved
    119050, --Praxis: Orcish Desk, Engraved
    119054, --Praxis: Orcish Dresser, Open
    119055, --Praxis: Orcish Nightstand, Open
    119056, --Praxis: Orcish Table, Engraved
    119059, --Praxis: Orcish Table, Formal
    119058, --Praxis: Orcish Table, Kitchen
    119057, --Praxis: Orcish Trestle, Engraved
    119216, --Praxis: Redguard Well, Arched
  },
  [121364]= --Hlaalu Master Furnisher's Document
  {
    115827, --Blueprint: Argonian Bark, Painted
    115830, --Blueprint: Argonian Gravestick
    115796, --Blueprint: Argonian Hamper, Woven
    115799, --Blueprint: Argonian Table, Horn
    115790, --Blueprint: Argonian Trunk, Painted
    115973, --Blueprint: Breton Armchair, Padded
    115998, --Blueprint: Breton Armoire, Knotwork
    115974, --Blueprint: Breton Cabinet, Knotwork
    118955, --Blueprint: Breton Cart, Covered Closed
    115999, --Blueprint: Breton Cart, Palanquin
    115972, --Blueprint: Breton Chair, Padded
    115977, --Blueprint: Breton Coffer, Knotwork
    115981, --Blueprint: Breton Counter, Cabinet
    115980, --Blueprint: Breton Counter, Corner
    115975, --Blueprint: Breton Curio, Knotwork
    115987, --Blueprint: Breton Desk, Scholar's
    115985, --Blueprint: Breton Divider, Curved Knotwork
    115984, --Blueprint: Breton Divider, Folded Knotwork
    115979, --Blueprint: Breton Dresser, Knotwork
    115997, --Blueprint: Breton Footlocker, Knotwork
    115983, --Blueprint: Breton Nightstand, Knotwork
    115971, --Blueprint: Breton Sideboard, Knotwork
    115986, --Blueprint: Breton Stool, Padded
    115988, --Blueprint: Breton Table, Formal
    115989, --Blueprint: Breton Trestle, Formal
    116058, --Blueprint: Dark Elf Bed, Canopy
    116060, --Blueprint: Dark Elf Counter, Block
    116059, --Blueprint: Dark Elf Counter, Corner
    116064, --Blueprint: Dark Elf Divider, Folded
    116061, --Blueprint: Dark Elf Nightstand, Angled
    116057, --Blueprint: Dark Elf Sofa, Angled
    116040, --Blueprint: Dark Elf Table, Tea
    116066, --Blueprint: Dark Elf Trunk, Buckled
    116067, --Blueprint: Dark Elf Wardrobe, Angled
    119483, --Blueprint: Gibbet, Single
    118920, --Blueprint: High Elf Armoire, Winged
    118917, --Blueprint: High Elf Bed, Winged Double
    118919, --Blueprint: High Elf Bookcase, Short Winged
    118921, --Blueprint: High Elf Bookcase, Winged
    118927, --Blueprint: High Elf Cabinet, Corner
    118923, --Blueprint: High Elf Chair, Regal Verdant
    118924, --Blueprint: High Elf Chair, Regal Winged
    118926, --Blueprint: High Elf Counter, Block
    118933, --Blueprint: High Elf Stool, Covered
    118916, --Blueprint: High Elf Wagon, Covered
    119490, --Blueprint: Horn, Ritual
    116125, --Blueprint: Khajiit Bed, Canopy
    116127, --Blueprint: Khajiit Bookcase, Arched
    116103, --Blueprint: Khajiit Counter, Faded
    116132, --Blueprint: Khajiit Table, Round
    116124, --Blueprint: Khajiit Tent, Vacation
    116133, --Blueprint: Khajiit Wardrobe, Arched
    116194, --Blueprint: Nord Bed, Canopy
    116195, --Blueprint: Nord Bookcase, Alcove
    116191, --Blueprint: Nord Cart, Covered
    116196, --Blueprint: Nord Chair, Lattice
    116198, --Blueprint: Nord Counter, Cabinet
    116197, --Blueprint: Nord Counter, Corner
    116199, --Blueprint: Nord Desk, Tied
    116201, --Blueprint: Nord Divider, Folding
    116200, --Blueprint: Nord Nightstand, Braced
    116203, --Blueprint: Nord Table, Formal
    116204, --Blueprint: Nord Table, Game
    116202, --Blueprint: Nord Table, Great
    116205, --Blueprint: Nord Trestle, Tied
    116216, --Blueprint: Nord Trunk, Buckled
    119079, --Blueprint: Orcish Armoire, Peaked
    119080, --Blueprint: Orcish Bed, Peaked
    119081, --Blueprint: Orcish Bookcase, Peaked
    119082, --Blueprint: Orcish Bookcase, Peaked
    119084, --Blueprint: Orcish Cabinet, Engraved
    119111, --Blueprint: Orcish Candleholder, Horn
    119112, --Blueprint: Orcish Candlestick, Horn
    119075, --Blueprint: Orcish Chair, Peaked
    119086, --Blueprint: Orcish Coffer, Bolted
    119090, --Blueprint: Orcish Counter, Corner
    119120, --Blueprint: Orcish Cradle, Peaked
    119087, --Blueprint: Orcish Cupboards, Peaked
    119095, --Blueprint: Orcish Divider, Curved
    119094, --Blueprint: Orcish Divider, Folded
    119091, --Blueprint: Orcish Hutch, Storage
    119100, --Blueprint: Orcish Mug, Horn
    119093, --Blueprint: Orcish Nightstand, Engraved
    119092, --Blueprint: Orcish Shelves, Storage
    119099, --Blueprint: Orcish Stein, Horn
    121369, --Blueprint: Redguard Bed, Full Lattice
    119245, --Blueprint: Redguard Bookcase, Full
    119244, --Blueprint: Redguard Bookcase, Piled
    119228, --Blueprint: Redguard Caravan, Cargo
    119229, --Blueprint: Redguard Caravan, Merchant
    119286, --Blueprint: Redguard Counter, Bar Island
    119285, --Blueprint: Redguard Counter, Block Island
    119287, --Blueprint: Redguard Counter, Grill
    119257, --Blueprint: Redguard Cupboard, Sturdy
    119248, --Blueprint: Redguard Desk, Bolted
    119254, --Blueprint: Redguard Divider, Lattice
    119297, --Blueprint: Redguard End Table, Tea
    119250, --Blueprint: Redguard Nightstand, Bolted
    119258, --Blueprint: Redguard Shelf, Bolted
    119252, --Blueprint: Redguard Table, Formal
    119253, --Blueprint: Redguard Table, Game
    119296, --Blueprint: Redguard Table, Grand Inlaid
    119241, --Blueprint: Redguard Wardrobe, Braced
    119243, --Blueprint: Redguard Wardrobe, Sturdy
    119524, --Blueprint: Stockade
    115887, --Blueprint: Wood Elf Tent, Frame
    115795, --Design: Argonian Bone Chimes
    115823, --Design: Argonian Light, Stick
    115826, --Design: Argonian Lights, Branch
    115820, --Design: Argonian Post, Frilled
    115792, --Design: Argonian Skull, Crocodile
    115794, --Design: Argonian Skull, Lizard
    115829, --Design: Argonian Totem of Skulls
    115793, --Design: Argonian Totem of the Snake
    115831, --Design: Argonian Tree of Lights
    116002, --Design: Breton Urn Lid, Striated
    116138, --Design: Khajiit Urn, Amber
    116139, --Design: Khajiit Vessel, Amber
    116137, --Design: Khajiit Vial, Amber
    121372, --Design: Noble Standing Cauldron
    116193, --Design: Nord Urn, Braided
    119103, --Design: Orcish Bowl, Buffed
    119113, --Design: Orcish Candle Sconce, Horn
    119078, --Design: Orcish Capsule, Sealed
    119104, --Design: Orcish Platter, Serving
    119105, --Design: Orcish Urn, Sealed
    119487, --Design: Pie Dish, Display
    119262, --Design: Redguard Pot, Hanging Mosaic
    119261, --Design: Redguard Pot, Mosaic
    119263, --Design: Redguard Slices, Wax
    119539, --Design: Sweetroll
    115892, --Design: Wood Elf Bin, Blue Feathers
    115893, --Design: Wood Elf Bin, Feathers
    115902, --Design: Wood Elf Bone Chimes
    115894, --Design: Wood Elf Cask, Painted
    115886, --Design: Wood Elf Censer, Hanging
    115895, --Design: Wood Elf Fish Dish
    115903, --Design: Wood Elf Rack, Dried Fish
    115904, --Design: Wood Elf Rack, Dried Meat
    115888, --Design: Wood Elf Rack, Meat
    115901, --Design: Wood Elf Skull and Bones
    115889, --Design: Wood Elf Totem, Framed
    115890, --Design: Wood Elf Totem, Skull
    115891, --Design: Wood Elf Trough, Slop
    116010, --Diagram: Breton Candelabra, Formal
    116009, --Diagram: Breton Candle, Grand
    115968, --Diagram: Breton Chandelier, Wrought Iron
    116004, --Diagram: Breton Lamp, Hanging
    115995, --Diagram: Breton Lamp, Oil
    115993, --Diagram: Breton Medallion, Lion
    116008, --Diagram: Breton Sconce, Floor
    116011, --Diagram: Breton Sconce, Wall
    116007, --Diagram: Breton Streetlight, Full
    116005, --Diagram: Breton Streetlight, Full Stone
    119520, --Diagram: Cage, Covered
    119518, --Diagram: Cage, Wild Animal
    116079, --Diagram: Dark Elf Candelabra, Angled
    116080, --Diagram: Dark Elf Candle, Votive Tray
    116077, --Diagram: Dark Elf Cauldron, Ringed
    116074, --Diagram: Dark Elf Censer, Hanging
    116068, --Diagram: Dark Elf Kettle Cooker
    116053, --Diagram: Dark Elf Lantern, Caged
    116054, --Diagram: Dark Elf Lantern, Hanging
    116073, --Diagram: Dark Elf Medallion, Tribunal
    116075, --Diagram: Dark Elf Thurible, Caged
    118940, --Diagram: High Elf Basin, Standing
    118938, --Diagram: High Elf Bowl, Serving
    118948, --Diagram: High Elf Brazier, Winged
    118952, --Diagram: High Elf Candelabra, Winged
    118950, --Diagram: High Elf Candle, Winged
    118949, --Diagram: High Elf Chandelier, Winged
    118953, --Diagram: High Elf Crest, Winged
    118930, --Diagram: High Elf Divider, Delicate
    118946, --Diagram: High Elf Goblet, Winged
    121309, --Diagram: High Elf Medal, Winged
    118941, --Diagram: High Elf Platter, Winged
    118939, --Diagram: High Elf Pot, Hanging
    121310, --Diagram: High Elf Sconce, Winged
    118925, --Diagram: High Elf Trunk, Jeweled
    116144, --Diagram: Khajiit Brazier, Hanging
    116146, --Diagram: Khajiit Candle-Filled Lamp
    116140, --Diagram: Khajiit Candles, Clawfoot
    116128, --Diagram: Khajiit Footlocker, Arched
    116145, --Diagram: Khajiit Sconce, Spiked
    116213, --Diagram: Nord Brazier, Hanging
    116209, --Diagram: Nord Candle, Antler
    116210, --Diagram: Nord Chandelier, Antler
    116192, --Diagram: Nord Chest, Latched
    116212, --Diagram: Nord Lamppost, Stone
    116211, --Diagram: Nord Streetlamps, Stone
    119114, --Diagram: Orcish Brazier, Bordered
    119117, --Diagram: Orcish Brazier, Floor
    119115, --Diagram: Orcish Brazier, Hanging
    119116, --Diagram: Orcish Brazier, Tabletop
    119110, --Diagram: Orcish Cauldron, Sealed
    119123, --Diagram: Orcish Chandelier, Spiked
    119074, --Diagram: Orcish Chest, Buckled
    119101, --Diagram: Orcish Knife, Kitchen
    119118, --Diagram: Orcish Sconce, Bordered
    119119, --Diagram: Orcish Sconce, Scrolled
    119072, --Diagram: Orcish Strongbox, Buckled
    119073, --Diagram: Orcish Trunk, Buckled
    119109, --Diagram: Orcish Vessel, Sealed
    119288, --Diagram: Redguard Brazier, Enchanted
    119230, --Diagram: Redguard Brazier, Garish
    119279, --Diagram: Redguard Candelabra, Polished
    119278, --Diagram: Redguard Candelabra, Twisted
    121373, --Diagram: Redguard Censer, Hanging Bulb
    121374, --Diagram: Redguard Censer, Hanging Disc
    119268, --Diagram: Redguard Chalice, Empty
    119269, --Diagram: Redguard Chalice, Full
    121305, --Diagram: Redguard Chandelier, Dark
    121304, --Diagram: Redguard Chandelier, Grated
    119280, --Diagram: Redguard Chandelier, Polished
    119281, --Diagram: Redguard Chandelier, Polished Grated
    119251, --Diagram: Redguard Pot, Hanging Garish
    119277, --Diagram: Redguard Streetlamps, Full
    115806, --Formula: Argonian Pestle, Bone
    119484, --Formula: Bottle, Elixir
    119485, --Formula: Bottle, Liquor
    119488, --Formula: Bottle, Wine
    115982, --Formula: Breton Mirror, Knotwork
    118945, --Formula: High Elf Decanter, Glass
    118947, --Formula: High Elf Goblet, Glass
    118944, --Formula: High Elf Vase, Winged
    121307, --Formula: Orcish Brazier, Pillar
    119121, --Formula: Orcish Mirror, Peaked
    119273, --Formula: Redguard Bottle, Delicate
    119303, --Formula: Redguard Bottle, Stained Glass
    119275, --Formula: Redguard Decanter, Delicate
    119302, --Formula: Redguard Decanter, Glass
    119270, --Formula: Redguard Hourglass of Desert Sands
    119309, --Formula: Redguard Lamp, Caged
    119310, --Formula: Redguard Lantern, Caged
    119311, --Formula: Redguard Lantern, Caged Stand
    119308, --Formula: Redguard Lantern, Cannister
    119276, --Formula: Redguard Lantern, Delicate
    119249, --Formula: Redguard Vanity, Bolted
    119304, --Formula: Redguard Vial, Stained Glass
    119486, --Formula: Vial, Delicate
    115819, --Pattern: Argonian Banner, Half Hands
    115818, --Pattern: Argonian Banners, Frilled
    115817, --Pattern: Argonian Bedroll, Woven
    115787, --Pattern: Argonian Canopy, Frilled
    115789, --Pattern: Argonian Canopy, Scaled
    115788, --Pattern: Argonian Canopy, Skull
    115800, --Pattern: Argonian Curtain of Smoke
    115801, --Pattern: Argonian Curtain of the Nest
    115816, --Pattern: Argonian Divider, Stretched
    115802, --Pattern: Argonian Drum, Ceremonial
    115822, --Pattern: Argonian Lanterns, Strand
    115821, --Pattern: Argonian Lanterns, String
    115807, --Pattern: Argonian Seat of Authority
    115815, --Pattern: Argonian Seat of Comfort
    115808, --Pattern: Argonian Seat of Honor
    115970, --Pattern: Breton Bed, Canopy
    115992, --Pattern: Breton Carpet, Bordered
    115978, --Pattern: Breton Cradle, Infant
    115969, --Pattern: Breton Curtains, Window
    115976, --Pattern: Breton Drapes, Grand
    115990, --Pattern: Breton Rug, Bordered
    115991, --Pattern: Breton Runner, Bordered
    115994, --Pattern: Breton Tablecloth, Blue
    115996, --Pattern: Breton Tablecloth, Striped
    116001, --Pattern: Breton Tapestry, Boughs
    116000, --Pattern: Breton Tapestry, Vines
    116062, --Pattern: Dark Elf Pillow, Cushion
    116063, --Pattern: Dark Elf Pillow, Roll
    116051, --Pattern: Dark Elf Rug, Fungal
    116071, --Pattern: Dark Elf Rug, Mossy
    116072, --Pattern: Dark Elf Rug, Striated
    121308, --Pattern: High Elf Banner, Gilded
    118918, --Pattern: High Elf Bench, Covered
    118942, --Pattern: High Elf Carpet, Eagle
    118931, --Pattern: High Elf Divider, Carved
    118943, --Pattern: High Elf Tapestry, Eagle
    121365, --Pattern: High Elf Tapestry, Gilded
    116126, --Pattern: Khajiit Couch, Padded
    116131, --Pattern: Khajiit Divider, Folding
    116135, --Pattern: Khajiit Drapes, Grand
    116136, --Pattern: Khajiit Pillow, Crescents
    116142, --Pattern: Khajiit Pillow, Roll
    116134, --Pattern: Khajiit Rug, Moons
    116143, --Pattern: Khajiit Rug, Sun
    116141, --Pattern: Khajiit Sofa, Padded
    116207, --Pattern: Nord Banner, Knotwork
    116206, --Pattern: Nord Rug, Bearskin
    116208, --Pattern: Nord Tapestry, Ship
    119102, --Pattern: Orcish Backpack
    119106, --Pattern: Orcish Tapestry, Axe
    119107, --Pattern: Orcish Tapestry, Heroes
    121366, --Pattern: Orcish Tapestry, Hunt
    119108, --Pattern: Orcish Tapestry, Sword
    119122, --Pattern: Orcish Tapestry, War
    119246, --Pattern: Redguard Armchair, Starry
    119238, --Pattern: Redguard Bed, Wide Canopy
    119240, --Pattern: Redguard Bench, Padded
    119290, --Pattern: Redguard Canopy, Stars
    119266, --Pattern: Redguard Carpet, Mirage
    119305, --Pattern: Redguard Carpet, Oasis
    119247, --Pattern: Redguard Chair, Starry
    119239, --Pattern: Redguard Couch, Slatted
    119256, --Pattern: Redguard Footstool, Starry
    119265, --Pattern: Redguard Mat, Desert
    119306, --Pattern: Redguard Mat, Mirage
    119307, --Pattern: Redguard Mat, Starburst
    119298, --Pattern: Redguard Pillow Roll, Desert Flame
    119235, --Pattern: Redguard Pillow Roll, Oasis
    119292, --Pattern: Redguard Pillow, Florid Flames
    119234, --Pattern: Redguard Pillow, Florid Oasis
    119293, --Pattern: Redguard Pillow, Florid Sunset
    119291, --Pattern: Redguard Pillow, Lattice Flames
    119233, --Pattern: Redguard Pillow, Oasis
    119232, --Pattern: Redguard Pillow, Sunset
    119264, --Pattern: Redguard Runner, Oasis
    119255, --Pattern: Redguard Stool, Starry
    119267, --Pattern: Redguard Tapestry, Oasis
    119312, --Pattern: Redguard Tapestry, Starry
    119299, --Pattern: Redguard Throw Pillow, Desert Flame
    119236, --Pattern: Redguard Throw Pillow, Oasis
    119300, --Pattern: Redguard Tuffet, Oasis
    115900, --Pattern: Wood Elf Bedding, Padded
    115899, --Pattern: Wood Elf Canopy, Spine
    115897, --Pattern: Wood Elf Tapestry, Deer
    115896, --Pattern: Wood Elf Tapestry, Painted
    115898, --Pattern: Wood Elf Tapestry, Vine
    115803, --Praxis: Argonian Bowl, Ritual
    115825, --Praxis: Argonian Brazier, Mud
    115812, --Praxis: Argonian Censer
    115791, --Praxis: Argonian Chest, Carved
    115804, --Praxis: Argonian Jug, Ritual
    115824, --Praxis: Argonian Lamp, Mud
    115809, --Praxis: Argonian Mortar and Pestle, Bone
    115810, --Praxis: Argonian Mortar, Bone
    115811, --Praxis: Argonian Pedestal, Altar
    115805, --Praxis: Argonian Pot, Ritual
    115828, --Praxis: Argonian Relic, Basin
    115814, --Praxis: Argonian Relic, Serpent
    115813, --Praxis: Argonian Relic, Small Serpent
    115832, --Praxis: Argonian Tile, Inscribed
    115967, --Praxis: Breton Figure, Stone
    116003, --Praxis: Breton Urn, Striated
    116006, --Praxis: Breton Vase, Delicate
    118928, --Praxis: High Elf Desk, Regal Winged
    118922, --Praxis: High Elf Dresser, Corner
    118929, --Praxis: High Elf Dresser, Winged
    118934, --Praxis: High Elf End Table, Winged
    118951, --Praxis: High Elf Lamppost, Stone
    118954, --Praxis: High Elf Streetlight, Stone
    118932, --Praxis: High Elf Table, Tea
    118935, --Praxis: High Elf Table, Winged Formal
    118936, --Praxis: High Elf Table, Winged Kitchen
    118937, --Praxis: High Elf Trestle, Winged
    121203, --Praxis: Khajiit Brazier, Enchanted
    119089, --Praxis: Orcish Cabinet, Bedside
    119088, --Praxis: Orcish Dresser, Engraved
    121306, --Praxis: Orcish Figurine, Strength
    119085, --Praxis: Orcish Hutch, Engraved
    119083, --Praxis: Orcish Sideboard, Engraved
    119096, --Praxis: Orcish Table, Game
    119097, --Praxis: Orcish Table, Grand
    119260, --Praxis: Redguard Enclosure, Arc
    119284, --Praxis: Redguard Firepit, Stone
    119274, --Praxis: Redguard Jar, Baroque
    119271, --Praxis: Redguard Jar, Oasis
    119272, --Praxis: Redguard Vase, Baroque
    121371, --Praxis: Wood Elf Hearth, Forest
  },
  [181612]= --Markarth Mixed Furnisher's Document
  {
    171489, --Blueprint: Dwarven Wall Lamp, Reachfolk Adorned
    171487, --Blueprint: Reachmen Chandelier, Gnarled
    171488, --Blueprint: Reachmen Chandelier, Shaded
    171529, --Blueprint: Reachmen Pergola, Ivy
    171510, --Design: Dwarven Dinner Bowl, Hearty Stew
    171512, --Design: Dwarven Plate, Full Breakfast
    171511, --Design: Dwarven Serving Dish, Vegetable Soup
    171503, --Diagram: Dwarven Amphora, Ornate Polished
    171484, --Diagram: Dwarven Brazier, Square Polished
    171493, --Diagram: Dwarven Chair, Ornate Polished
    171508, --Diagram: Dwarven Cooking Implements, Hanging
    171492, --Diagram: Dwarven Corner Bench, Ornate Polished
    171514, --Diagram: Dwarven Desk, Ornate Polished
    171498, --Diagram: Dwarven Divider, Ornate Polished
    171505, --Diagram: Dwarven Kettle, Ornate Polished
    171483, --Diagram: Dwarven Lamp, Conal Frustum Cage
    171482, --Diagram: Dwarven Lamp, Cylinder Cage
    171519, --Diagram: Dwarven Low Table, Ornate Polished
    171491, --Diagram: Dwarven Pew, Ornate Polished
    171504, --Diagram: Dwarven Pot, Polished
    171481, --Diagram: Dwarven Potted Plant, Polished Vase
    171501, --Diagram: Dwarven Relief, Connected Circles
    171502, --Diagram: Dwarven Relief, Tracks
    171517, --Diagram: Dwarven Sideboard, Granite Polished
    171509, --Diagram: Dwarven Strainer, Kitchen
    171486, --Diagram: Dwarven Table Lamp, Polished Dome
    171515, --Diagram: Dwarven Table, Grand Polished
    171523, --Diagram: Dwarven Trunk, Ornate Polished
    171526, --Diagram: Dwarven Wardrobe, Ornate Polished
    171789, --Diagram: Markarth Door, Double
    171494, --Pattern: Dwarven Bed, Reach Furs
    171496, --Pattern: Dwarven Bed, Reach Furs Canopy
    171495, --Pattern: Dwarven Bed, Reach Furs Double
    171490, --Praxis: Dwarven Bench, Ornate Granite
    171527, --Praxis: Dwarven Bookcase, Granite
    171528, --Praxis: Dwarven Bookcase, Granite Filled
    171513, --Praxis: Dwarven Counter, Granite
    171497, --Praxis: Dwarven Divider, Ornate Granite
    171522, --Praxis: Dwarven Dresser, Granite
    171520, --Praxis: Dwarven End Table, Columnar Granite
    171521, --Praxis: Dwarven Nightstand, Granite
    171516, --Praxis: Dwarven Table, Granite
    171518, --Praxis: Dwarven Table, Granite Kitchen
    171524, --Praxis: Dwarven Wall Cabinet, Granite
    171799, --Praxis: Markarth Archway, Stone
    171790, --Praxis: Markarth Fireplace, Stone
    171781, --Praxis: Markarth Floor, Circular
    171783, --Praxis: Markarth Floor, Large Oval
    171785, --Praxis: Markarth Floor, Large Rectangle
    171784, --Praxis: Markarth Floor, Large Square
    171782, --Praxis: Markarth Floor, Square
    171788, --Praxis: Markarth Pillar, Stone
    171793, --Praxis: Markarth Platform, Bordered Square
    171792, --Praxis: Markarth Platform, Square
    171796, --Praxis: Markarth Stairway, Wide Stone
    171800, --Praxis: Markarth Tower, Stone
    171798, --Praxis: Markarth Walkway, Metal Trim
    171791, --Praxis: Markarth Wall, Windowed Stone
    171500, --Sketch: Dwarven Cage, Polished Specimen
    171499, --Sketch: Dwarven Mirror, Polished
  },
  [134684]= --Morrowind Journeyman Furnisher's Document
  {
    127002, --Blueprint: Ashlander Cup, Empty
    127003, --Blueprint: Ashlander Cup, Mazte
    126916, --Blueprint: Dres Sideboard, Display
    126917, --Blueprint: Dres Table, Kitchen
    126915, --Blueprint: Dres Trestle, Corridor
    126909, --Blueprint: Hlaalu Bench, Polished
    126932, --Blueprint: Hlaalu Bookcase, Empty
    126934, --Blueprint: Hlaalu Cabinet, Open
    126914, --Blueprint: Hlaalu Chair, Polished
    126933, --Blueprint: Hlaalu Cupboard, Open
    126935, --Blueprint: Hlaalu Dresser, Open
    126948, --Blueprint: Hlaalu Dresser, Scroll Drawers
    126977, --Blueprint: Hlaalu Dresser, Scroll Rack
    126907, --Blueprint: Hlaalu Settee, Polished
    126975, --Blueprint: Hlaalu Shelf, Long
    126950, --Blueprint: Indoril End Table, Rounded
    126976, --Blueprint: Indoril Shelf, Long
    126931, --Blueprint: Redoran Bench, Sanded
    126940, --Blueprint: Redoran Chair, Sanded
    126951, --Blueprint: Redoran End Table, Sanded
    127068, --Blueprint: Redoran Fork, Wooden
    127069, --Blueprint: Redoran Knife, Wooden
    126929, --Blueprint: Redoran Settee, Sanded
    126967, --Blueprint: Redoran Sideboard, Display
    127070, --Blueprint: Redoran Spoon, Wooden
    126968, --Blueprint: Redoran Table, Kitchen
    126966, --Blueprint: Redoran Trestle, Corridor
    126999, --Design: Ashlander Platter, Bread and Cheese
    126998, --Design: Ashlander Platter, Ceramic
    126996, --Design: Dres Bowl, Empty
    126997, --Design: Dres Bowl, Saltrice Mash
    127083, --Design: Dres Candles, Meditation
    127004, --Design: Dres Cup, Empty Greef
    127005, --Design: Dres Cup, Greef
    126994, --Design: Redoran Bowl, Empty
    126995, --Design: Redoran Bowl, Saltrice Mash
    127000, --Diagram: Dres Cauldron, Floral Banded
    127104, --Diagram: Hlaalu Boxes, Compact
    126991, --Diagram: Indoril Bellows, Practical
    127074, --Diagram: Indoril Brazier, Knotwork
    127086, --Diagram: Indoril Chandelier, Knotwork
    126962, --Diagram: Indoril Chest, Fortified
    126963, --Diagram: Indoril Footlocker, Fortified
    127017, --Formula: Dres Censer, Chains
    127084, --Formula: Indoril Candelabra, Shrine
    127090, --Formula: Indoril Lantern, Hanging
    127087, --Formula: Indoril Streetlight, Brick
    127018, --Formula: Redoran Incense Holder, Ceramic Pan
    127032, --Pattern: Dres Carpet, Fertile Peat
    127056, --Pattern: Dres Tapestry, Vines
    127059, --Pattern: Hlaalu Banner, Floral
    126921, --Pattern: Hlaalu Bed, Double Pillow
    126920, --Pattern: Hlaalu Bed, Single Pillow
    127031, --Pattern: Hlaalu Carpet, Garden Moss
    127058, --Pattern: Hlaalu Tapestry, Floral
    127021, --Pattern: Hlaalu Towels, Folded
    126924, --Pattern: Redoran Bed, Double Pillow
    126923, --Pattern: Redoran Bed, Single Pillow
    127030, --Pattern: Redoran Carpet, Volcanic Ash
    127053, --Pattern: Redoran Mantle Cloth, Crimson Coverlet
    127067, --Praxis: Dres Jar, Stoneflower
    127062, --Praxis: Dres Teapot, Ceramic
    127064, --Praxis: Hlaalu Jar, Garden Moss
    127019, --Praxis: Indoril Incense Cup, Silver
    127066, --Praxis: Redoran Jar, Jazbay
  },
  [134683]= --Morrowind Master Furnisher's Document
  {
    126960, --Blueprint: Dres Divider, Chains
    126961, --Blueprint: Dres Divider, Honeycomb
    126959, --Blueprint: Dres Divider, Screen
    126912, --Blueprint: Hlaalu Armchair, Mossy Cushion
    126913, --Blueprint: Hlaalu Armchair, Polished
    126942, --Blueprint: Hlaalu Bookcase, Orderly
    127048, --Blueprint: Hlaalu Box, Trinket
    126946, --Blueprint: Hlaalu Cabinet of Drawers, Clerk
    126955, --Blueprint: Hlaalu Cabinet, Clerk
    126972, --Blueprint: Hlaalu Chest, Secure
    126943, --Blueprint: Hlaalu Cupboard, Formal
    126944, --Blueprint: Hlaalu Desk, Scholar's
    126953, --Blueprint: Hlaalu End Table, Formal Scales
    126952, --Blueprint: Hlaalu End Table, Formal Turtle
    126971, --Blueprint: Hlaalu Footlocker, Secure
    126958, --Blueprint: Hlaalu Nightstand, Formal
    126957, --Blueprint: Hlaalu Nightstand, Scholar's
    126945, --Blueprint: Hlaalu Sideboard, Low Cabinet
    126947, --Blueprint: Hlaalu Sideboard, Scholar's
    126949, --Blueprint: Hlaalu Sideboard, Scribe's
    126918, --Blueprint: Hlaalu Table, Formal Floral
    126919, --Blueprint: Hlaalu Table, Formal Turtle
    126941, --Blueprint: Hlaalu Wardrobe, Formal
    126939, --Blueprint: Redoran Armchair, Sanded
    126969, --Blueprint: Redoran Table, Formal Floral
    126970, --Blueprint: Redoran Table, Formal Turtle
    127006, --Design: Dres Cup, Empty Sujamma
    127007, --Design: Dres Cup, Sujamma
    127080, --Design: Indoril Candelabra, Shrine Chamber
    127085, --Design: Indoril Candelabra, Temple
    127079, --Design: Indoril Candelabra, Temple Chamber
    127078, --Design: Indoril Candle, Temple
    127008, --Design: Redoran Cup, Empty
    127009, --Design: Redoran Cup, Mazte
    127047, --Diagram: Hlaalu Cannister, Trinket
    127088, --Diagram: Hlaalu Sconce, Vellum
    127049, --Diagram: Indoril Box, Trinket
    127075, --Diagram: Indoril Brazier, Cauldron
    127076, --Diagram: Indoril Brazier, Kettle
    127077, --Diagram: Indoril Brazier, Pedestal
    127046, --Diagram: Indoril Cannister, Trinket
    126965, --Diagram: Indoril Cassone, Sealed
    127012, --Diagram: Indoril Platter, Floral
    126964, --Diagram: Indoril Vault, Sealed
    127014, --Diagram: Redoran Incense Holder, Mesh
    127020, --Diagram: Redoran Incense Pot, Beastly
    127022, --Diagram: Redoran Plate, Floral
    127023, --Diagram: Redoran Plate, Meal
    127050, --Diagram: Redoran Steamer, Iron
    127024, --Diagram: Redoran Tray, Floral
    127101, --Diagram: Velothi Brazier, Temple
    127016, --Formula: Dres Incense Stand, Chains
    127092, --Formula: Hlaalu Lantern, Classic Vellum
    127093, --Formula: Hlaalu Lantern, Modest Vellum
    127091, --Formula: Hlaalu Lantern, Oversized Vellum
    126956, --Formula: Hlaalu Mirror, Standing
    127089, --Formula: Hlaalu Streetlight, Vellum
    127082, --Formula: Indoril Sconce, Shrine
    127081, --Formula: Indoril Sconce, Temple
    127037, --Pattern: Dres Rug, Chains
    127036, --Pattern: Dres Runner, Chains
    126922, --Pattern: Hlaalu Bed, Canopy
    126908, --Pattern: Hlaalu Bench, Mossy Cushion
    126906, --Pattern: Hlaalu Settee, Mossy Cushion
    126910, --Pattern: Hlaalu Stool, Mossy Cushion
    127071, --Pattern: Indoril Banner, Almalexia
    127072, --Pattern: Indoril Banner, Sotha Sil
    127073, --Pattern: Indoril Banner, Vivec
    127028, --Pattern: Indoril Carpet, Almalexia
    127029, --Pattern: Indoril Carpet, Grand Almalexia
    127041, --Pattern: Indoril Carpet, Grand Sotha Sil
    127045, --Pattern: Indoril Carpet, Grand Vivec
    127040, --Pattern: Indoril Carpet, Sotha Sil
    127044, --Pattern: Indoril Carpet, Vivec
    127027, --Pattern: Indoril Rug, Almalexia
    127039, --Pattern: Indoril Rug, Sotha Sil
    127043, --Pattern: Indoril Rug, Vivec
    127026, --Pattern: Indoril Runner, Almalexia
    127038, --Pattern: Indoril Runner, Sotha Sil
    127042, --Pattern: Indoril Runner, Vivec
    127057, --Pattern: Indoril Tapestry, Almalexia
    127060, --Pattern: Indoril Tapestry, Sotha Sil
    127061, --Pattern: Indoril Tapestry, Vivec
    126938, --Pattern: Redoran Armchair, Fungal Cushion
    126925, --Pattern: Redoran Bed, Canopy
    126930, --Pattern: Redoran Bench, Fungal Cushion
    127051, --Pattern: Redoran Mantle Cloth, Crimson Cover
    126928, --Pattern: Redoran Settee, Fungal Cushion
    126936, --Pattern: Redoran Stool, Fungal Cushion
    127054, --Pattern: Redoran Table Runner, Gilded Ochre
    126901, --Praxis: Hlaalu Amphora, Sealed Orichalcum
    126905, --Praxis: Hlaalu Cannister, Sealed Azurite
    127015, --Praxis: Hlaalu Censer, Mesh
    126900, --Praxis: Hlaalu Jar, Sealed Malachite
    127065, --Praxis: Hlaalu Vase, Gilded
    126902, --Praxis: Redoran Amphora, Sealed Marble
    126904, --Praxis: Redoran Urn, Dusky Marble
    126903, --Praxis: Redoran Urn, Pale Marble
    127099, --Praxis: Telvanni Arched Light, Organic Azure
    126980, --Praxis: Telvanni Armchair, Organic
    126978, --Praxis: Telvanni Bed, Organic
    126986, --Praxis: Telvanni Bookcase, Organic
    127097, --Praxis: Telvanni Candelabra, Organic
    126979, --Praxis: Telvanni Chair, Organic
    126984, --Praxis: Telvanni Desk, Organic
    126985, --Praxis: Telvanni End Table, Organic
    127096, --Praxis: Telvanni Lamp, Organic Azure
    127098, --Praxis: Telvanni Lantern, Organic Azure
    126983, --Praxis: Telvanni Nightstand, Organic
    127100, --Praxis: Telvanni Sconce, Organic Azure
    126987, --Praxis: Telvanni Shelves, Organic
    126982, --Praxis: Telvanni Sofa, Organic
    126988, --Praxis: Telvanni Stool, Organic
    127055, --Praxis: Telvanni Table Runner, Bordered Azure
    127052, --Praxis: Telvanni Table Runner, Gilded Azure
    126989, --Praxis: Telvanni Table, Organic Game
    126990, --Praxis: Telvanni Table, Organic Grand
    126981, --Praxis: Telvanni Throne, Organic
    127102, --Praxis: Tribunal Tablet of Almalexia
  },
  [153888]= --Murkmire Mixed Furnisher's Document
  {
    145992, --Blueprint: Murkmire Bed, Carved
    145980, --Blueprint: Murkmire Bonding Chimes, Domed
    146016, --Blueprint: Murkmire Bonding Chimes, Simple
    145994, --Blueprint: Murkmire Chair, Woven
    145996, --Blueprint: Murkmire Counter, Cabinet
    146006, --Blueprint: Murkmire Gate, Arched
    146005, --Blueprint: Murkmire Platform, Reed
    146002, --Blueprint: Murkmire Ramp, Marshwood
    146004, --Blueprint: Murkmire Ramp, Reed
    146001, --Blueprint: Murkmire Shelf, Woven Hanging
    146000, --Blueprint: Murkmire Shelves, Woven
    145998, --Blueprint: Murkmire Table, Woven
    146008, --Blueprint: Murkmire Totem Post, Carved
    146017, --Blueprint: Murkmire Totem, Wolf-Lizard
    145995, --Blueprint: Murkmire Trunk, Leatherbound
    146009, --Blueprint: Murkmire Wall, Corner Curve
    146007, --Blueprint: Murkmire Wall, Straight
    145993, --Blueprint: Murkmire Wardrobe, Woven
    145971, --Design: Bowl of Worms, Large
    145988, --Design: Murkmire Candlepost, Driftwood
    145987, --Design: Murkmire Candlepost, Timber
    145989, --Design: Murkmire Candles, Bone Group
    145968, --Design: Murkmire Pot, Large Carved
    145960, --Diagram: Murkmire Brazier, Bowl
    145986, --Formula: Murkmire Candle, Standing Shell
    145982, --Formula: Murkmire Lamp, Hanging Bottle
    145983, --Formula: Murkmire Lamp, Hanging Conch
    145981, --Formula: Murkmire Lantern, Covered
    145984, --Formula: Murkmire Sconce, Shell
    146011, --Pattern: Murkmire Rug, Hist Gathering
    146012, --Pattern: Murkmire Rug, Supine Turtle
    146010, --Pattern: Murkmire Tapestry, Hist Gathering
    145947, --Praxis: Murkmire Bed, Enclosed
    145945, --Praxis: Murkmire Bench, Wide
    145955, --Praxis: Murkmire Bookcase
    145956, --Praxis: Murkmire Bookcase, Full
    145951, --Praxis: Murkmire Bookcase, Grand
    145952, --Praxis: Murkmire Bookcase, Grand Full
    145950, --Praxis: Murkmire Brazier, Engraved
    145962, --Praxis: Murkmire Hearth Shrine, Sithis Coiled
    145963, --Praxis: Murkmire Hearth Shrine, Sithis Looming
    145961, --Praxis: Murkmire Hearth Shrine, Sithis Rearing
    145958, --Praxis: Murkmire Pedestal, Winged
    145957, --Praxis: Murkmire Platform, Sectioned
    145954, --Praxis: Murkmire Sarcophagus Lid
    145953, --Praxis: Murkmire Sarcophagus, Empty
    145967, --Praxis: Murkmire Shrine, Sithis Coiled
    145966, --Praxis: Murkmire Shrine, Sithis Figure
    145965, --Praxis: Murkmire Shrine, Sithis Rearing
    145964, --Praxis: Murkmire Shrine, Sithis Relief
    145949, --Praxis: Murkmire Table, Engraved
    145959, --Praxis: Murkmire Totem, Beacon
    145979, --Praxis: Murkmire Wall, Stone
  },
  [204501]= --Necrom Journeyman Furnisher's Document
  {
    197549, --Blueprint: Necrom Bookcase, Elegant Tall
    197559, --Blueprint: Necrom Chair, Elegant
    197553, --Blueprint: Necrom Chest, Elegant
    197556, --Blueprint: Necrom Divider, Elegant
    197552, --Blueprint: Necrom End Table, Elegant
    197563, --Blueprint: Necrom Table, Elegant Dining
    197551, --Blueprint: Necrom Wardrobe, Elegant
    197588, --Blueprint: Telvanni Box, Fungal
    197590, --Blueprint: Telvanni Chair, Fungal
    197586, --Blueprint: Telvanni Chest, Fungal
    197580, --Blueprint: Telvanni Dresser, Small Fungal
    197583, --Blueprint: Telvanni Nightstand, Fungal
    197591, --Blueprint: Telvanni Stool, Fungal
    197571, --Design: Necrom Bowl, Elegant
    197577, --Design: Necrom Urn, Malachite
    197584, --Design: Telvanni Bookcase, Tall Fungal
    197595, --Design: Telvanni Meal, Fish Dinner
    197599, --Design: Telvanni Meal, Kebab Lunch
    197596, --Design: Telvanni Mug, Fungal
    197589, --Design: Telvanni Planter, Fungal
    197587, --Design: Telvanni Table, Round Fungal
    197565, --Diagram: Necrom Lamppost, Elegant
    197566, --Diagram: Necrom Sconce, Elegant
    197602, --Formula: Telvanni Candle, Fungal Standing
    197601, --Formula: Telvanni Sconce, Fungal Wall
    197611, --Pattern: Apocrypha Bed, Marble Twin
    197613, --Pattern: Book Pile, Large
    197555, --Pattern: Necrom Bed, Elegant Single
    197615, --Pattern: Necrom Carpet, Medium
    197714, --Pattern: Tribunal Rug
    197604, --Praxis: Apocrypha Bookcase, Tall Marble
    197606, --Praxis: Apocrypha Candlestick, Twisted
    197609, --Praxis: Apocrypha Chair, Marble
    197605, --Praxis: Apocrypha Desk, Marble
    197610, --Praxis: Apocrypha Nightstand, Marble
    197568, --Praxis: Necrom Lamp, Elegant Standing
    197574, --Praxis: Necrom Memorial, Large
    197570, --Praxis: Necrom Vase, Elegant Square Floral
    197573, --Praxis: Necrom Wind Chimes, Elegant
  },
  [204500]= --Necrom Master Furnisher's Document
  {
    197560, --Blueprint: Necrom Bench, Elegant
    197550, --Blueprint: Necrom Bookcase, Elegant Grand
    197630, --Blueprint: Necrom Bookcase, Elegant Grand Filled
    197629, --Blueprint: Necrom Bookcase, Elegant Tall Filled
    197597, --Blueprint: Telvanni Teapot, Fungal
    197581, --Blueprint: Telvanni Wardrobe, Fungal
    197578, --Design: Necrom Incense, Mushroom Offering
    197585, --Design: Telvanni Dresser, Large Fungal
    197693, --Diagram: Necrom Chandelier, Elegant
    197564, --Diagram: Necrom Firepit, Elegant
    197572, --Diagram: Necrom Hanging Flowers, Elegant
    197576, --Diagram: Necrom Ossuary, Plated
    197600, --Formula: Telvanni Chandelier, Fungal
    197593, --Formula: Telvanni Water Jug, Fungal
    197554, --Pattern: Necrom Bed, Elegant Double
    197614, --Pattern: Necrom Carpet, Large
    197579, --Pattern: Telvanni Bed, Fungal Double
    197631, --Praxis: Apocrypha Bookcase, Tall Marble Filled
    197607, --Praxis: Apocrypha Sconce, Cylindrical
    197608, --Praxis: Apocrypha Sconce, Spiral
    197569, --Praxis: Necrom Vase, Elegant Rounded Floral
    197557, --Sketch: Necrom Mirror, Elegant Standing
    197582, --Sketch: Telvanni Mirror, Fungal
  },
  [171753]= --Skyrim Journeyman Furnisher's Document
  {
    166806, --Blueprint: Solitude Armchair, Wicker
    166921, --Blueprint: Solitude Backpack, Basket
    166803, --Blueprint: Solitude Barstool, Wicker
    166919, --Blueprint: Solitude Basket, Centerpiece
    166920, --Blueprint: Solitude Basket, Ornate
    166917, --Blueprint: Solitude Basket, Wicker Handles
    166918, --Blueprint: Solitude Basket, Wicker Wide
    166820, --Blueprint: Solitude Bench, Polished
    166878, --Blueprint: Solitude Bookcase, Narrow Backless
    166874, --Blueprint: Solitude Bookcase, Narrow Noble
    166869, --Blueprint: Solitude Bookcase, Narrow Rustic Filled
    166867, --Blueprint: Solitude Bookcase, Rustic Filled
    166880, --Blueprint: Solitude Cabinet, Narrow Noble
    166849, --Blueprint: Solitude Cabinet, Ornate Wall
    166865, --Blueprint: Solitude Cabinet, Rustic Filled
    167366, --Blueprint: Solitude Cart, Work
    166808, --Blueprint: Solitude Chair, Wicker
    166832, --Blueprint: Solitude Dresser, Rustic
    167367, --Blueprint: Solitude Foot Bridge, Wood-Planked
    166862, --Blueprint: Solitude Jewelry Box, Wolf's-Head
    166847, --Blueprint: Solitude Nightstand, Noble
    166848, --Blueprint: Solitude Nightstand, Noble Cabinet
    166846, --Blueprint: Solitude Nightstand, Noble Drawers
    166812, --Blueprint: Solitude Pew, Sturdy
    166810, --Blueprint: Solitude Pew, Sturdy Long
    166916, --Blueprint: Solitude Picnic Basket, Wicker
    167361, --Blueprint: Solitude Pillar Base, Wood
    167368, --Blueprint: Solitude Platform, Square Wooden
    166915, --Blueprint: Solitude Serving Basket, Wicker
    166914, --Blueprint: Solitude Serving Tray, Wood
    166837, --Blueprint: Solitude Table, Circular Ornate Small
    166823, --Blueprint: Solitude Table, Round
    166824, --Blueprint: Solitude Table, Round Small
    166821, --Blueprint: Solitude Table, Rustic
    166822, --Blueprint: Solitude Table, Rustic Large
    166827, --Blueprint: Solitude Table, Square
    166826, --Blueprint: Solitude Table, Square Low
    166858, --Blueprint: Solitude Travel Chest, Practical
    166840, --Blueprint: Solitude Trestle, Ornate
    166841, --Blueprint: Solitude Trestle, Ornate Large
    166830, --Blueprint: Solitude Wardrobe, Rustic
    166931, --Design: Solitude Bowl, Berries
    166930, --Design: Solitude Bowl, Mushrooms
    166944, --Design: Solitude Bread, Floral Pattern
    166948, --Design: Solitude Bread, Long
    166947, --Design: Solitude Bread, Rustic Loaf
    166942, --Design: Solitude Breakfast, Eggs and Ham
    166941, --Design: Solitude Breakfast, Full
    166943, --Design: Solitude Breakfast, Sausages and Ham
    166939, --Design: Solitude Camping Pot, Fish Stew
    166936, --Design: Solitude Dinner Bowl, Hearty Stew
    166938, --Design: Solitude Dinner Bowl, Vegetable Soup
    166953, --Design: Solitude Drinking Horn, Ivory
    166954, --Design: Solitude Drying Rack, Stockfish
    166950, --Design: Solitude Goblet, Knotwork
    166932, --Design: Solitude Meal, Rustic
    166902, --Design: Solitude Pot, Large Ceramic
    166933, --Design: Solitude Tray, Stockfish
    166903, --Design: Solitude Vase, Large Sealed
    166923, --Diagram: Solitude Cauldron, Flat-Bottomed
    166775, --Diagram: Solitude Chandelier, Horns
    166925, --Diagram: Solitude Frying Pan, Long-Handled
    166927, --Diagram: Solitude Frying Pan, Trivet
    166940, --Diagram: Solitude Gravy Boat, Metal
    166854, --Diagram: Solitude Hand Mirror, Elegant
    166855, --Diagram: Solitude Hand Mirror, Ornate
    166895, --Diagram: Solitude Hand-Drill, Simple
    166785, --Diagram: Solitude Lantern, Table
    166924, --Diagram: Solitude Melting Pot, Double Boiler
    166906, --Diagram: Solitude Pot, Narrow Metal
    166907, --Diagram: Solitude Pot, Stout Metal
    166905, --Diagram: Solitude Pot, Wide Metal
    166783, --Diagram: Solitude Sconce, Torch
    166780, --Diagram: Solitude Sconce, Wrought Iron
    166909, --Diagram: Solitude Serving Bowl, Metal
    166893, --Diagram: Solitude Skewer, Twisted Iron
    166860, --Diagram: Solitude Trunk, Knotwork
    166888, --Pattern: Solitude Bed, Rustic Bearskin Double
    166891, --Pattern: Solitude Bed, Rustic Bearskin Single
    166889, --Pattern: Solitude Bed, Rustic Cowhide Double
    166892, --Pattern: Solitude Bed, Rustic Cowhide Single
    166794, --Pattern: Solitude Carpet, Small Plush
    166898, --Pattern: Solitude Patching Kit, Well-Worn
    166787, --Pattern: Solitude Rug, Cowhide
    166793, --Pattern: Solitude Rug, Knotwork
    166788, --Pattern: Solitude Rug, Snow Bear
    167364, --Praxis: Solitude Archway, Stone
    167370, --Praxis: Solitude Platform, Ornate Tile
    167363, --Praxis: Solitude Post, Stone Wall
    166782, --Praxis: Solitude Sconce, Candle Embellished
    167362, --Praxis: Solitude Wall, Curved Stone
    167369, --Praxis: Solitude Well, Covered
    166951, --Sketch: Solitude Goblet, Noble
    166863, --Sketch: Solitude Jewelry Box, Copper and Agate
    166911, --Sketch: Solitude Serving Bowl, Verdigris
  },
  [171754]= --Skyrim Master Furnisher's Document
  {
    166799, --Blueprint: Solitude Armchair, High-Backed Noble
    166800, --Blueprint: Solitude Armchair, Noble
    166801, --Blueprint: Solitude Armchair, Ornate
    166802, --Blueprint: Solitude Armchair, Ornate Low
    166876, --Blueprint: Solitude Bookcase, Backless
    166877, --Blueprint: Solitude Bookcase, Backless Filled
    166875, --Blueprint: Solitude Bookcase, Narrow Noble Filled
    166879, --Blueprint: Solitude Bookcase, Narrow Open Filled
    166872, --Blueprint: Solitude Bookcase, Noble
    166870, --Blueprint: Solitude Bookcase, Noble Cabinet
    166871, --Blueprint: Solitude Bookcase, Noble Cabinet Filled
    166873, --Blueprint: Solitude Bookcase, Noble Filled
    166881, --Blueprint: Solitude Cabinet, Narrow Noble Filled
    166844, --Blueprint: Solitude Chest of Drawers, Noble
    166845, --Blueprint: Solitude Chest of Drawers, Wide Noble
    166842, --Blueprint: Solitude Desk, Ornate
    166882, --Blueprint: Solitude Display Shelf, Noble
    166959, --Blueprint: Solitude Display Shelf, Noble Filled
    166899, --Blueprint: Solitude Game, Warrior and the Wolf
    166851, --Blueprint: Solitude Mirror, Noble Full-Length
    166819, --Blueprint: Solitude Pew, Noble
    166817, --Blueprint: Solitude Pew, Noble Long
    166818, --Blueprint: Solitude Pew, Ornate
    166816, --Blueprint: Solitude Pew, Ornate Long
    166859, --Blueprint: Solitude Strongbox, Iron Hunt Relief
    166836, --Blueprint: Solitude Table, Circular Ornate
    166835, --Blueprint: Solitude Table, Grand Noble
    166839, --Blueprint: Solitude Table, Square Ornate
    166838, --Blueprint: Solitude Table, Square Ornate Low
    166852, --Blueprint: Solitude Wall Mirror, Noble
    166843, --Blueprint: Solitude Wardrobe, Noble
    166850, --Blueprint: Solitude Wine Rack, Noble Full
    166928, --Design: Solitude Bowl, Winter Onions
    166934, --Design: Solitude Platter, Ribs
    166935, --Design: Solitude Serving Pot, Hearty Stew
    166937, --Design: Solitude Serving Pot, Vegetable Soup
    166955, --Design: Solitude Smoking Rack, Sausage
    166929, --Design: Solitude Tray, Fresh Eel
    166776, --Diagram: Solitude Chandelier, Steel
    166779, --Diagram: Solitude Lantern, Hanging
    166778, --Diagram: Solitude Sconce, Lantern
    166777, --Diagram: Solitude Sconce, Wolf's-Head Lantern
    166910, --Diagram: Solitude Serving Dish, Metal
    166861, --Diagram: Solitude Strongbox, Iron Bands
    166853, --Diagram: Solitude Wall Mirror, Ornate
    166887, --Pattern: Solitude Bed, Noble Double
    166890, --Pattern: Solitude Bed, Noble Single
    166789, --Pattern: Solitude Carpet, Grand Wolf's-Head Border
    166791, --Pattern: Solitude Carpet, Plush
    166792, --Pattern: Solitude Carpet, Wolf's-Head Border
    166790, --Pattern: Solitude Runner, Grand Wolf's-Head Border
    166957, --Praxis: Solitude Streetlight, Paired
    166956, --Praxis: Solitude Streetlight, Single
    166857, --Sketch: Solitude Censer, Pagoda
    166856, --Sketch: Solitude Censer, Wolf-Head
    166949, --Sketch: Solitude Goblet, Covered
  },
  [224293]= --Solstice Journeyman Furnisher's Document
  {
    217568, --Blueprint: Pigment Bowl, Blue Large
    217565, --Blueprint: Pigment Bowl, Green
    217566, --Blueprint: Pigment Bowl, Red
    217567, --Blueprint: Pigment Bowl, Yellow
    217515, --Blueprint: Tide-Born Shelves, Tall
    217516, --Blueprint: Tide-Born Table, Grand
    223579, --Blueprint: Worm Cult Divider, Wooden
    217535, --Design: Coconut Bunch, Display
    217546, --Design: Green Coconut Bunch, Display
    217539, --Design: Lychee Bowl, Display
    217542, --Design: Oyster Plate, Display
    217544, --Design: Seahorse Platter, Display
    217519, --Design: Tide-Born Art, Decorative Shrimp
    217554, --Design: Tide-Born Candleholder, Coral
    217531, --Design: Tide-Born Gourd Shaker
    217520, --Design: Tide-Born Windcatcher, Feathered
    223595, --Design: Worm Cult Candelabra, Cold-Flame
    223574, --Diagram: Worm Cult Bookcase, Filled
    223591, --Diagram: Worm Cult Brazier, Cold-Flame
    223569, --Diagram: Worm Cult Buffet
    223592, --Diagram: Worm Cult Chandelier, Caged Cold-Flame
    223572, --Diagram: Worm Cult Decor, Skeleton
    223577, --Diagram: Worm Cult Dresser, Short
    223603, --Diagram: Worm Cult Lever, Metal Gate
    223598, --Diagram: Worm Cult Sconce, Caged Cold-Flame
    223601, --Diagram: Worm Cult Sconce, Cold-Flame Torch
    223624, --Diagram: Worm Cult Specimen, Skull
    223584, --Diagram: Worm Cult Table, Small
    223580, --Diagram: Worm Cult Trunk, Medium
    223585, --Formula: Worm Cult Mirror, Metal
    223621, --Formula: Worm Cult Specimen Jar, Brain
    223625, --Formula: Worm Cult Specimen Jar, Spider
    223602, --Pattern: Battlefield Marker, Flag Spear
    217570, --Pattern: Canvas, Blank
    217525, --Pattern: Tide-Born Basket, Shell-Topped
    217507, --Pattern: Tide-Born Bed, Single
    217526, --Pattern: Tide-Born Mat, Geometric Round
    217529, --Pattern: Tide-Born Rug, Medium Rectangular
    217534, --Pattern: Tide-Born Wall Art, Rope
    223567, --Pattern: Worm Cult Bed, Full
    223607, --Pattern: Worm Cult Bench, Padded
    223615, --Pattern: Worm Cult Book Stack, Trio
    223616, --Pattern: Worm Cult Books, Row
    223609, --Pattern: Worm Cult Chair, Padded
    223587, --Pattern: Worm Cult Rug, Red
    223588, --Pattern: Worm Cult Rug, Triangular Sigil
    223623, --Pattern: Worm Cult Scroll, Unfinished
    223619, --Pattern: Worm Cult Stool, Padded
    223610, --Pattern: Worm Cult Stool, Round
    217559, --Praxis: Sunport Fountain, Floral Wall
    217562, --Praxis: Sunport Table, Tall
    217506, --Praxis: Tide-Born Coffer, Trinket
    217512, --Praxis: Tide-Born Firepit, Stone
    217552, --Praxis: Tide-Born Pitcher, Stone
  },
  [224294]= --Solstice Master Furnisher's Document
  {
    217564, --Blueprint: Paint Muller Board
    217509, --Blueprint: Tide-Born Bench, Wicker
    217527, --Blueprint: Tide-Born Rug, Large Round
    223605, --Blueprint: Worm Cult Mill, Grinding
    217536, --Design: Fruit Bunch, Display
    217543, --Design: Seafood Platter, Display
    217518, --Design: Tide-Born Art, Flame Lily
    217553, --Design: Tide-Born Chandelier, Coral
    217522, --Design: Tide-Born Pot, Shell-Topped
    217556, --Design: Tide-Born Sconce, Coral
    217561, --Diagram: Sunport Planter, Hanging
    223575, --Diagram: Worm Cult Bookcase, Wide Filled
    223593, --Diagram: Worm Cult Chandelier, Bone Cold-Flame
    223604, --Diagram: Worm Cult Crane, Mining
    223571, --Diagram: Worm Cult Decor, Crystal Skeleton
    223578, --Diagram: Worm Cult Divider, Iron
    223594, --Diagram: Worm Cult Lamp, Floor Cold-Flame
    223597, --Diagram: Worm Cult Lamp, Jaw
    223599, --Diagram: Worm Cult Lightpost, Caged Cold-Flame
    223600, --Diagram: Worm Cult Sconce, Jaw
    223583, --Diagram: Worm Cult Table, Grand
    223576, --Diagram: Worm Cult Trunk, Large
    217533, --Formula: Tide-Born Wall Mirror
    223622, --Formula: Worm Cult Apparatus, Condenser
    217558, --Pattern: Sunport Scarf Valance, Lavender
    217508, --Pattern: Tide-Born Bed, Double
    217528, --Pattern: Tide-Born Rug, Large Rectangular
    223566, --Pattern: Worm Cult Bed, Canopy Full
    223608, --Pattern: Worm Cult Bench, Padded Backed
    223617, --Pattern: Worm Cult Books, Long Row
    223612, --Pattern: Worm Cult Chair, Padded Double-Backed
    223589, --Pattern: Worm Cult Rug, Large Teal
    217563, --Praxis: Sunport Game, Marbles
    217560, --Praxis: Sunport Planter, Stone
    217504, --Praxis: Tide-Born Chest, Large
    217505, --Praxis: Tide-Born Chest, Small
    217513, --Praxis: Tide-Born Oven, Stone
  },
  [153622]= --Summerset Journeyman Furnisher's Document
  {
    139551, --Blueprint: Alinor Armchair, Backless Polished
    139550, --Blueprint: Alinor Armchair, Polished
    139541, --Blueprint: Alinor Bed, Noble Single
    139539, --Blueprint: Alinor Bed, Polished Single
    139532, --Blueprint: Alinor Candles, Stand
    139531, --Blueprint: Alinor Candles, Tall Stand
    139549, --Blueprint: Alinor Chair, Polished
    139559, --Blueprint: Alinor Counter, Polished Corner
    139558, --Blueprint: Alinor Counter, Polished Drawers
    139552, --Blueprint: Alinor Desk, Polished
    139584, --Blueprint: Alinor Divider, Polished
    139570, --Blueprint: Alinor Jewelry Box, Octagonal
    139568, --Blueprint: Alinor Jewelry Box, Polished
    139555, --Blueprint: Alinor Nightstand, Octagonal
    139554, --Blueprint: Alinor Nightstand, Scalloped
    139485, --Blueprint: Alinor Pew, Polished
    139593, --Blueprint: Alinor Table, Noble Intimate
    139564, --Blueprint: Alinor Trunk, Engraved
    139563, --Blueprint: Alinor Trunk, Peaked
    139557, --Blueprint: Alinor Winerack, Polished
    139598, --Design: Alinor Amphora, Embossed
    139648, --Design: Alinor Amphora, Portrait
    139610, --Design: Alinor Meal, Complete Setting
    139594, --Design: Alinor Urn, Gilded
    139533, --Diagram: Alinor Brazier, Hanging Coals
    139526, --Diagram: Alinor Brazier, Standing Coals
    139620, --Diagram: Alinor Bread Basket, Wrought Iron
    139618, --Diagram: Alinor Platter, Scalloped
    139519, --Diagram: Alinor Sconce, Arched
    139520, --Diagram: Alinor Sconce, Crenellated
    139609, --Diagram: Alinor Table Setting, Complete
    139599, --Diagram: Alinor Urn, Bronze
    139639, --Pattern: Alinor Carpet, Vibrant
    139635, --Pattern: Alinor Curtains, Drawn
    139634, --Pattern: Alinor Curtains, Tall Drawn
    139640, --Pattern: Alinor Rug, Alinor Seal
    139643, --Pattern: Alinor Tapestry, Alinor Dawn
    139644, --Pattern: Alinor Tapestry, Alinor Dusk
    139645, --Pattern: Alinor Tapestry, Royal Gryphons
    139518, --Praxis: Alinor Archway, Tall
    139498, --Praxis: Alinor Archway, Timeworn
    139546, --Praxis: Alinor Bench, Marble
    139502, --Praxis: Alinor Column, Slender Timeworn
    139504, --Praxis: Alinor Column, Timeworn
    139607, --Praxis: Alinor Display Stand, Marble
    139606, --Praxis: Alinor Display Stand, Marble Wide
    139516, --Praxis: Alinor Fence, Tall
    139517, --Praxis: Alinor Fence, Tall Long
    139503, --Praxis: Alinor Floor, Ballroom Timeworn
    139589, --Praxis: Alinor Fountain, Timeworn
    139507, --Praxis: Alinor Plinth, Sarcophagus
    139515, --Praxis: Alinor Post, Tall Fence
    139630, --Praxis: Alinor Potted Plant, Double Tiered
    139629, --Praxis: Alinor Potted Plant, Triple Tiered
    139631, --Praxis: Alinor Potted Plant, Twin Saplings
    139508, --Praxis: Alinor Sarcophagus, Open
    139603, --Praxis: Alinor Shrine, Limestone
    139604, --Praxis: Alinor Shrine, Limestone Raised
    139509, --Praxis: Alinor Stairway, Timeworn
    139510, --Praxis: Alinor Stairway, Timeworn Wide
    139591, --Praxis: Alinor Table, Decorative Marble
    139590, --Praxis: Alinor Table, Round Marble
    139602, --Praxis: Alinor Urn, Limestone Large
    139608, --Praxis: Alinor Wall Shrine, Marble
    139613, --Sketch: Alinor Chalice, Delicate
    139615, --Sketch: Alinor Chalice, Ornate
    139616, --Sketch: Alinor Goblet, Silver Ornate
    139576, --Sketch: Scrimshaw, Sea Monster
    139577, --Sketch: Scrimshaw, Ship
  },
  [153621]= --Summerset Master Furnisher's Document
  {
    139545, --Blueprint: Alinor Armchair, Backless Verdant
    139547, --Blueprint: Alinor Armchair, Noble
    139548, --Blueprint: Alinor Armchair, Overhang
    139537, --Blueprint: Alinor Bed, Canopy Full
    139536, --Blueprint: Alinor Bed, Noble Full
    139538, --Blueprint: Alinor Bed, Overhang Full
    139540, --Blueprint: Alinor Bed, Polished Full
    139544, --Blueprint: Alinor Bench, Verdant
    139542, --Blueprint: Alinor Bookcase, Polished
    139649, --Blueprint: Alinor Cabinet, Noble
    139553, --Blueprint: Alinor Desk, Mirrored
    139583, --Blueprint: Alinor Divider, Noble
    139567, --Blueprint: Alinor Jewelry Box, Noble
    139569, --Blueprint: Alinor Jewelry Box, Peaked
    139556, --Blueprint: Alinor Nightstand, Noble
    139592, --Blueprint: Alinor Table, Noble Grand
    139565, --Blueprint: Alinor Trunk, Noble
    139566, --Blueprint: Alinor Trunk, Spired
    139543, --Blueprint: Alinor Wardrobe, Polished
    139484, --Blueprint: Alinor Writing Desk, Noble
    139627, --Blueprint: Display Case, Large
    139626, --Blueprint: Display Case, Specimen
    139624, --Blueprint: Display Case, Standing
    139625, --Blueprint: Display Case, Standing Arched
    139596, --Design: Alinor Amphora, Slender
    139527, --Diagram: Alinor Brazier, Noble
    139528, --Diagram: Alinor Candelabra, Wrought Iron
    139521, --Diagram: Alinor Lantern, Hanging
    139522, --Diagram: Alinor Lantern, Stationary
    139524, --Diagram: Alinor Sconce, Arched Glass
    139525, --Diagram: Alinor Sconce, Lantern
    139523, --Diagram: Alinor Sconce, Wrought Glass
    139534, --Diagram: Alinor Streetlight, Paired Wrought Iron
    139535, --Diagram: Alinor Streetlight, Wrought Iron
    139637, --Pattern: Alinor Carpet, Alinor Crescent
    139638, --Pattern: Alinor Carpet, Verdant
    139636, --Pattern: Alinor Drapes, Noble
    139641, --Pattern: Alinor Runner, Royal
    139501, --Praxis: Alinor Bookcase Wall, Timeworn
    139587, --Praxis: Alinor Fireplace, Ornate
    139588, --Praxis: Alinor Fountain, Four-Way Timeworn
    139628, --Praxis: Alinor Potted Plant, Perpetual Bloom
    139506, --Praxis: Alinor Sarcophagus, Peaked
    139505, --Praxis: Alinor Sarcophagus, Wedge
    139646, --Praxis: Alinor Statue, Kinlord
    139647, --Praxis: Alinor Statue, Orator
    139633, --Praxis: Alinor Windowbox, Blue Wisteria
    139632, --Praxis: Alinor Windowbox, Purple Wisteria
    139573, --Sketch: Figurine, The Fish and the Unicorn
    139571, --Sketch: Figurine, The Sea-Monster's Surprise
    139572, --Sketch: Figurine, The Taming of the Gryphon
    139580, --Sketch: Scrimshaw Jewelry Box, Floral
    139575, --Sketch: Scrimshaw Jewelry Box, Verdant Oval
    139574, --Sketch: Scrimshaw Jewelry Box, Vineyard
    139579, --Sketch: Scrimshaw, Ancient Vessel
    139578, --Sketch: Scrimshaw, Octopus
  },
  [211092]= --Tomehold Journeyman Furnisher's Document
  {
    198531, --Blueprint: Necrom Dresser, Elegant Short
    198479, --Blueprint: Necrom Lamp Post, Wood
    198488, --Diagram: Apocrypha Bench, Intricate
    198505, --Diagram: Apocrypha Stool, Intricate
    198545, --Diagram: Necrom Candle, Tall
    198487, --Pattern: Apocrypha Bed, Spiked Double
    198480, --Pattern: Apocrypha Book Pile, Large Twisted
    198515, --Pattern: Apocrypha Book Pile, Medium
    198527, --Pattern: Apocrypha Book Piles, Floating
    198540, --Pattern: Necrom Carpet, Ruby
    198481, --Praxis: Apocrypha Bookcase, Corner
    198509, --Praxis: Apocrypha Bookcase, Intricate
    198502, --Praxis: Apocrypha Bookcase, Large
    198495, --Praxis: Apocrypha Bookcase, Large Intricate
    198512, --Praxis: Apocrypha Bookcase, Spiked
    198497, --Praxis: Apocrypha Desk, Intricate
    198499, --Praxis: Apocrypha Divider, Spiked
    198500, --Praxis: Apocrypha Dresser, Intricate
    198522, --Praxis: Apocrypha Lamp, Desk
    198504, --Praxis: Apocrypha Nightstand, Intricate
    198483, --Praxis: Apocrypha Stele, Arched
    198485, --Praxis: Apocrypha Stele, Tablet
    198484, --Praxis: Apocrypha Stele, Wide Arched
    198507, --Praxis: Apocrypha Table, Intricate
    198536, --Praxis: Necrom Planter, Small
    198541, --Praxis: Necrom Planter, Tall
    198529, --Praxis: Necrom Wind Chimes, Stone
    198516, --Praxis: Paper Making Frame
    198518, --Praxis: Pulp Masher, Paper Making
  },
  [211091]= --Tomehold Master Furnisher's Document
  {
    198528, --Blueprint: Necrom Cart, Merchant
    198530, --Blueprint: Necrom Dresser, Elegant
    198535, --Blueprint: Necrom Planter, Large
    198533, --Blueprint: Necrom Table, Elegant Round
    198496, --Diagram: Apocrypha Chair, Intricate
    198498, --Diagram: Apocrypha Divider, Intricate
    198521, --Diagram: Apocrypha Light Diffusers, Bowl
    198526, --Diagram: Apocrypha Sconce, Intricate
    198546, --Diagram: Necrom Lamp Post, Metal
    198539, --Diagram: Necrom Planter, Hanging Round
    198547, --Diagram: Necrom Sconce, Brass
    198537, --Formula: Necrom Incense Burner, Delicate Brass
    198538, --Formula: Necrom Incense Burner, Squat Brass
    198486, --Pattern: Apocrypha Bed, Intricate Double
    198511, --Praxis: Apocrypha Bookcase, Large Intricate Filled
    198549, --Praxis: Apocrypha Bookcase, Large Spiked Filled
    198523, --Praxis: Apocrypha Lamp, Large
    198503, --Praxis: Apocrypha Mirror, Spiked
    198525, --Praxis: Apocrypha Sconce, Diffuser
    198482, --Praxis: Apocrypha Stele, Tentacles
    198510, --Praxis: Apocrypha Wardrobe, Intricate
    198513, --Praxis: Apocrypha Wardrobe, Spiked
    198548, --Praxis: Necrom Brazier, Tall Stone
    198517, --Praxis: Vat, Paper Pulp
  },
  [214257]= --West Weald Journeyman Furnisher's Document
  {
    207919, --Blueprint: Colovian Beehive, Small
    207824, --Blueprint: Colovian Bookcase, Noble Small
    207823, --Blueprint: Colovian Bookshelf, Noble Filled
    207840, --Blueprint: Colovian Counter, Bar
    207838, --Blueprint: Colovian Counter, Block
    207839, --Blueprint: Colovian Counter, Corner
    207831, --Blueprint: Colovian Divider, Noble
    207913, --Blueprint: Colovian Grape Vines, Long
    207916, --Blueprint: Colovian Keg, Wine
    207828, --Blueprint: Colovian Shelf, Noble
    207836, --Blueprint: Colovian Table, Noble
    207837, --Blueprint: Colovian Tea Table, Noble
    207911, --Blueprint: Colovian Trellis, Enclosed
    207922, --Blueprint: Colovian Trellis, Tall Vineyard
    207825, --Blueprint: Colovian Wardrobe, Rustic
    211441, --Blueprint: Dawnwood Table, Reclaimed
    207879, --Design: Colovian Bowl, Grapes
    207882, --Design: Colovian Meal, Cheese Board
    207883, --Design: Colovian Meal, Grape Board
    207877, --Design: Colovian Meal, Poultry
    207876, --Design: Colovian Serving Dish, Cheese
    207881, --Design: Dawnwood Basket, Antlers
    207886, --Design: Dawnwood Meal, Flan
    211446, --Design: Dawnwood Meal, Meat
    207885, --Design: Dawnwood Tray, Fish
    211433, --Design: Dawnwood Wind Chimes, Bone
    207887, --Design: Honey Pot, Open
    207864, --Diagram: Colovian Brazier, Basin
    207863, --Diagram: Colovian Brazier, Hanging
    207850, --Diagram: Colovian Dresser, Noble
    207853, --Diagram: Colovian Jewelry Box, Noble
    207866, --Diagram: Colovian Lamppost, Arched
    207865, --Diagram: Colovian Lantern, Hanging
    207862, --Diagram: Colovian Sconce, Wall
    207899, --Diagram: Dawnwood Cauldron, Closed
    211447, --Diagram: Dawnwood Container, Metal
    211431, --Diagram: Dawnwood Firepit, Metal
    207897, --Formula: Colovian Cup, Glass
    207896, --Formula: Colovian Jug, Glass
    207908, --Formula: Colovian Mirror, Table
    207892, --Formula: Colovian Wine Bottle, Wax Sealed
    207890, --Formula: Colovian Wine Crate, Small
    207893, --Formula: Colovian Wine, Basketed
    207870, --Formula: Dawnwood Lantern String, Long
    207871, --Formula: Dawnwood Lantern String, Short
    207869, --Formula: Dawnwood Lantern, Antlers
    207872, --Formula: Dawnwood Lantern, Hanging
    211452, --Formula: Dawnwood Orange Light, Tall Sprouted Arch
    211453, --Formula: Dawnwood Orange Lights, Sprouted Arch
    207873, --Formula: Dawnwood Sconce, Wall
    207847, --Formula: Dawnwood Seat, Sprouted
    207833, --Pattern: Colovian Bed, Noble Single
    207832, --Pattern: Colovian Bed, Rustic Double
    207905, --Pattern: Colovian Curtains, Ivory
    207857, --Pattern: Colovian Rug, Fallen Leaves
    207855, --Pattern: Colovian Rug, Noble Long
    211437, --Pattern: Dawnwood Basket, Square Leather
    207854, --Pattern: Dawnwood Bedding, Skins
    211449, --Pattern: Dawnwood Container, Turtle
    211435, --Pattern: Dawnwood Container, Wood
    207901, --Praxis: Colovian Planter, Large
    207900, --Praxis: Colovian Planter, Tall
    207902, --Praxis: Colovian Vase, Limestone
    207848, --Praxis: Dawnwood Bench, Sprouted
    211445, --Praxis: Dawnwood Vase, Leather
  },
  [214256]= --West Weald Master Furnisher's Document
  {
    207918, --Blueprint: Colovian Beehive, Large
    207820, --Blueprint: Colovian Bookcase, Noble Large
    207829, --Blueprint: Colovian Cheese Rack, Rustic
    207826, --Blueprint: Colovian Wardrobe, Noble
    207914, --Blueprint: Colovian Wine Barrel, Large
    207915, --Blueprint: Colovian Wine Rack, Filled
    207852, --Blueprint: Dawnwood Chest, Antlers
    207880, --Design: Colovian Grape Basket, Wax
    207867, --Diagram: Colovian Chandelier, Metal
    207904, --Diagram: Colovian Incense Burner, Metal
    207861, --Diagram: Colovian Lamp, Brass
    211448, --Diagram: Dawnwood Container, Crow
    207860, --Formula: Colovian Lamp, Glass
    207909, --Formula: Colovian Mirror, Wall
    207889, --Formula: Colovian Wine Crate, Large
    207874, --Formula: Dawnwood Crystal Lights, Sprouted
    211451, --Formula: Dawnwood Crystal Lights, Sprouted Arch
    211454, --Formula: Dawnwood Tent, Grown
    207845, --Pattern: Colovian Armchair, Noble
    207843, --Pattern: Colovian Armchair, Noble Backless
    212617, --Pattern: Colovian Bed, Canopy Full
    207844, --Pattern: Colovian Bench, Noble
    207907, --Pattern: Colovian Curtains, Noble
    207906, --Pattern: Colovian Curtains, Sage
    207856, --Pattern: Colovian Rug, Noble Circular
    211439, --Pattern: Dawnwood Bedding, Illuminated
    207846, --Pattern: Dawnwood Chair, Antlers
    211436, --Pattern: Dawnwood Container, Bone
    207834, --Pattern: Dawnwood Hammock, Sprouted
    211430, --Pattern: Wood Elf Beehive, Stump
    207898, --Praxis: Dawnwood Pitcher, Tall
    207849, --Praxis: Dawnwood Table, Sprouted
  },

--AUTOMATION END======================================================================================================
}