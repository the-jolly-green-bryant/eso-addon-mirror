local Addon = FarmingPartyPlus

local ItemCatalog = {
  categories = {
    ore = "Ore",
    wood = "Logs",
    cloth = "Cloth & Leather",
    jewelry = "Jewelry Dust",
    alchemy = "Alchemy",
    enchanting = "Enchanting",
    provisioning = "Provisioning",
    recipes = "Recipes",
    fishing = "Fishing",
    furnishing = "Furnishing Mats"
  },
  items = {
    { key = "iron ore", name = "Iron Ore", category = "ore", defaultEnabled = false },
    { key = "high iron ore", name = "High Iron Ore", category = "ore", defaultEnabled = false },
    { key = "orichalcum ore", name = "Orichalcum Ore", category = "ore", defaultEnabled = false },
    { key = "dwarven ore", name = "Dwarven Ore", category = "ore", defaultEnabled = false },
    { key = "ebony ore", name = "Ebony Ore", category = "ore", defaultEnabled = false },
    { key = "calcinium ore", name = "Calcinium Ore", category = "ore", defaultEnabled = true },
    { key = "galatite ore", name = "Galatite Ore", category = "ore", defaultEnabled = true },
    { key = "quicksilver ore", name = "Quicksilver Ore", category = "ore", defaultEnabled = true },
    { key = "voidstone ore", name = "Voidstone Ore", category = "ore", defaultEnabled = true },
    { key = "rubedite ore", name = "Rubedite Ore", category = "ore", defaultEnabled = true },

    { key = "rough maple", name = "Rough Maple", category = "wood", defaultEnabled = false },
    { key = "rough oak", name = "Rough Oak", category = "wood", defaultEnabled = false },
    { key = "rough beech", name = "Rough Beech", category = "wood", defaultEnabled = false },
    { key = "rough hickory", name = "Rough Hickory", category = "wood", defaultEnabled = false },
    { key = "rough yew", name = "Rough Yew", category = "wood", defaultEnabled = false },
    { key = "rough birch", name = "Rough Birch", category = "wood", defaultEnabled = true },
    { key = "rough ash", name = "Rough Ash", category = "wood", defaultEnabled = true },
    { key = "rough mahogany", name = "Rough Mahogany", category = "wood", defaultEnabled = true },
    { key = "rough nightwood", name = "Rough Nightwood", category = "wood", defaultEnabled = true },
    { key = "rough ruby ash", name = "Rough Ruby Ash", category = "wood", defaultEnabled = true },

    { key = "jute", name = "Jute", category = "cloth", defaultEnabled = false },
    { key = "flax", name = "Flax", category = "cloth", defaultEnabled = false },
    { key = "cotton", name = "Cotton", category = "cloth", defaultEnabled = false },
    { key = "spidersilk", name = "Spidersilk", category = "cloth", defaultEnabled = false },
    { key = "ebonthread", name = "Ebonthread", category = "cloth", defaultEnabled = false },
    { key = "kresh fiber", name = "Kresh Fiber", category = "cloth", defaultEnabled = true },
    { key = "ironthread", name = "Ironthread", category = "cloth", defaultEnabled = true },
    { key = "silverweave", name = "Silverweave", category = "cloth", defaultEnabled = true },
    { key = "void bloom", name = "Void Bloom", category = "cloth", defaultEnabled = true },
    { key = "ancestor silk", name = "Ancestor Silk", category = "cloth", defaultEnabled = true },
    { key = "raw jute", name = "Raw Jute", category = "cloth", defaultEnabled = false },
    { key = "raw flax", name = "Raw Flax", category = "cloth", defaultEnabled = false },
    { key = "raw cotton", name = "Raw Cotton", category = "cloth", defaultEnabled = false },
    { key = "raw spidersilk", name = "Raw Spidersilk", category = "cloth", defaultEnabled = false },
    { key = "raw ebonthread", name = "Raw Ebonthread", category = "cloth", defaultEnabled = false },
    { key = "raw kresh fiber", name = "Raw Kresh Fiber", category = "cloth", defaultEnabled = true },
    { key = "raw ironthread", name = "Raw Ironthread", category = "cloth", defaultEnabled = true },
    { key = "raw silverweave", name = "Raw Silverweave", category = "cloth", defaultEnabled = true },
    { key = "raw void bloom", name = "Raw Void Bloom", category = "cloth", defaultEnabled = true },
    { key = "raw ancestor silk", name = "Raw Ancestor Silk", category = "cloth", defaultEnabled = true },
    { key = "rawhide scraps", name = "Rawhide Scraps", category = "cloth", defaultEnabled = false },
    { key = "hide scraps", name = "Hide Scraps", category = "cloth", defaultEnabled = false },
    { key = "topgrain hide scraps", name = "Topgrain Hide Scraps", category = "cloth", defaultEnabled = false },
    { key = "iron hide scraps", name = "Iron Hide Scraps", category = "cloth", defaultEnabled = false },
    { key = "superb hide scraps", name = "Superb Hide Scraps", category = "cloth", defaultEnabled = false },
    { key = "shadowhide scraps", name = "Shadowhide Scraps", category = "cloth", defaultEnabled = true },
    { key = "rubedo hide scraps", name = "Rubedo Hide Scraps", category = "cloth", defaultEnabled = true },

    { key = "pewter dust", name = "Pewter Dust", category = "jewelry", defaultEnabled = false },
    { key = "copper dust", name = "Copper Dust", category = "jewelry", defaultEnabled = false },
    { key = "silver dust", name = "Silver Dust", category = "jewelry", defaultEnabled = true },
    { key = "electrum dust", name = "Electrum Dust", category = "jewelry", defaultEnabled = true },
    { key = "platinum dust", name = "Platinum Dust", category = "jewelry", defaultEnabled = true },

    { key = "natural water", name = "Natural Water", category = "alchemy", defaultEnabled = false },
    { key = "clear water", name = "Clear Water", category = "alchemy", defaultEnabled = false },
    { key = "pristine water", name = "Pristine Water", category = "alchemy", defaultEnabled = false },
    { key = "cleansed water", name = "Cleansed Water", category = "alchemy", defaultEnabled = false },
    { key = "filtered water", name = "Filtered Water", category = "alchemy", defaultEnabled = false },
    { key = "purified water", name = "Purified Water", category = "alchemy", defaultEnabled = true },
    { key = "cloud mist", name = "Cloud Mist", category = "alchemy", defaultEnabled = true },
    { key = "star dew", name = "Star Dew", category = "alchemy", defaultEnabled = true },
    { key = "lorkhan's tears", name = "Lorkhan's Tears", category = "alchemy", defaultEnabled = true },
    { key = "violet coprinus", name = "Violet Coprinus", category = "alchemy", defaultEnabled = false },
    { key = "blue entoloma", name = "Blue Entoloma", category = "alchemy", defaultEnabled = false },
    { key = "namira's rot", name = "Namira's Rot", category = "alchemy", defaultEnabled = false },
    { key = "emetic russula", name = "Emetic Russula", category = "alchemy", defaultEnabled = false },
    { key = "stinkhorn", name = "Stinkhorn", category = "alchemy", defaultEnabled = false },
    { key = "imp stool", name = "Imp Stool", category = "alchemy", defaultEnabled = false },
    { key = "luminous russula", name = "Luminous Russula", category = "alchemy", defaultEnabled = true },
    { key = "white cap", name = "White Cap", category = "alchemy", defaultEnabled = true },
    { key = "nirnroot", name = "Nirnroot", category = "alchemy", defaultEnabled = true },
    { key = "crimson nirnroot", name = "Crimson Nirnroot", category = "alchemy", defaultEnabled = true },
    { key = "water hyacinth", name = "Water Hyacinth", category = "alchemy", defaultEnabled = true },
    { key = "butterfly wing", name = "Butterfly Wing", category = "alchemy", defaultEnabled = true },
    { key = "torchbug thorax", name = "Torchbug Thorax", category = "alchemy", defaultEnabled = true },
    { key = "scrib jelly", name = "Scrib Jelly", category = "alchemy", defaultEnabled = true },
    { key = "mudcrab chitin", name = "Mudcrab Chitin", category = "alchemy", defaultEnabled = false },
    { key = "beetle scuttle", name = "Beetle Scuttle", category = "alchemy", defaultEnabled = false },
    { key = "fleshfly larva", name = "Fleshfly Larva", category = "alchemy", defaultEnabled = false },
    { key = "nightshade", name = "Nightshade", category = "alchemy", defaultEnabled = true },
    { key = "blessed thistle", name = "Blessed Thistle", category = "alchemy", defaultEnabled = true },
    { key = "columbine", name = "Columbine", category = "alchemy", defaultEnabled = true },
    { key = "corn flower", name = "Corn Flower", category = "alchemy", defaultEnabled = true },
    { key = "bugloss", name = "Bugloss", category = "alchemy", defaultEnabled = true },
    { key = "dragonthorn", name = "Dragonthorn", category = "alchemy", defaultEnabled = true },
    { key = "lady's smock", name = "Lady's Smock", category = "alchemy", defaultEnabled = true },
    { key = "wormwood", name = "Wormwood", category = "alchemy", defaultEnabled = true },
    { key = "mountain flower", name = "Mountain Flower", category = "alchemy", defaultEnabled = true },

    { key = "jora", name = "Jora", category = "enchanting", defaultEnabled = false },
    { key = "porade", name = "Porade", category = "enchanting", defaultEnabled = false },
    { key = "jera", name = "Jera", category = "enchanting", defaultEnabled = false },
    { key = "jejora", name = "Jejora", category = "enchanting", defaultEnabled = false },
    { key = "odra", name = "Odra", category = "enchanting", defaultEnabled = false },
    { key = "pojora", name = "Pojora", category = "enchanting", defaultEnabled = false },
    { key = "edora", name = "Edora", category = "enchanting", defaultEnabled = false },
    { key = "jaera", name = "Jaera", category = "enchanting", defaultEnabled = false },
    { key = "pora", name = "Pora", category = "enchanting", defaultEnabled = false },
    { key = "denara", name = "Denara", category = "enchanting", defaultEnabled = false },
    { key = "rera", name = "Rera", category = "enchanting", defaultEnabled = false },
    { key = "derado", name = "Derado", category = "enchanting", defaultEnabled = false },
    { key = "rekura", name = "Rekura", category = "enchanting", defaultEnabled = true },
    { key = "kura", name = "Kura", category = "enchanting", defaultEnabled = true },
    { key = "rejera", name = "Rejera", category = "enchanting", defaultEnabled = true },
    { key = "repora", name = "Repora", category = "enchanting", defaultEnabled = true },
    { key = "jehade", name = "Jehade", category = "enchanting", defaultEnabled = true },
    { key = "itade", name = "Itade", category = "enchanting", defaultEnabled = true },
    { key = "ta", name = "Ta", category = "enchanting", defaultEnabled = false },
    { key = "jejota", name = "Jejota", category = "enchanting", defaultEnabled = false },
    { key = "denata", name = "Denata", category = "enchanting", defaultEnabled = true },
    { key = "rekuta", name = "Rekuta", category = "enchanting", defaultEnabled = true },
    { key = "kuta", name = "Kuta", category = "enchanting", defaultEnabled = true },
    { key = "deni", name = "Deni", category = "enchanting", defaultEnabled = true },
    { key = "makko", name = "Makko", category = "enchanting", defaultEnabled = true },
    { key = "oko", name = "Oko", category = "enchanting", defaultEnabled = true },
    { key = "tade", name = "Tade", category = "enchanting", defaultEnabled = true },
    { key = "okori", name = "Okori", category = "enchanting", defaultEnabled = true },
    { key = "haoko", name = "Haoko", category = "enchanting", defaultEnabled = true },
    { key = "rakeipa", name = "Rakeipa", category = "enchanting", defaultEnabled = true },
    { key = "indeko", name = "Indeko", category = "enchanting", defaultEnabled = true },

    { key = "bervez juice", name = "Bervez Juice", category = "provisioning", defaultEnabled = true },
    { key = "fish", name = "Fish", category = "provisioning", defaultEnabled = true },
    { key = "frost mirriam", name = "Frost Mirriam", category = "provisioning", defaultEnabled = true },
    { key = "perfect roe", name = "Perfect Roe", category = "provisioning", defaultEnabled = true },
    { key = "jazbay grapes", name = "Jazbay Grapes", category = "provisioning", defaultEnabled = false },
    { key = "garlic", name = "Garlic", category = "provisioning", defaultEnabled = false },
    { key = "saltrice", name = "Saltrice", category = "provisioning", defaultEnabled = false },
    { key = "honey", name = "Honey", category = "provisioning", defaultEnabled = false },
    { key = "flour", name = "Flour", category = "provisioning", defaultEnabled = false },

    { key = "__recipes_any__", name = "All Recipes (uses recipe value floor below)", category = "recipes", defaultEnabled = false },

    { key = "__fish_any__", name = "All Fish", category = "fishing", defaultEnabled = false },
    { key = "pyandonean bottle", name = "Pyandonean Bottle", category = "fishing", defaultEnabled = true },
    { key = "wet gunny sack", name = "Wet Gunny Sack", category = "fishing", defaultEnabled = true },
    { key = "waterlogged psijic satchel", name = "Waterlogged Psijic Satchel", category = "fishing", defaultEnabled = true },

    { key = "heartwood", name = "Heartwood", category = "furnishing", defaultEnabled = true },
    { key = "mundane rune", name = "Mundane Rune", category = "furnishing", defaultEnabled = true },
    { key = "regulus", name = "Regulus", category = "furnishing", defaultEnabled = true },
    { key = "bast", name = "Bast", category = "furnishing", defaultEnabled = true },
    { key = "alchemical resin", name = "Alchemical Resin", category = "furnishing", defaultEnabled = true },
    { key = "decorative wax", name = "Decorative Wax", category = "furnishing", defaultEnabled = true },
    { key = "nickel", name = "Nickel", category = "furnishing", defaultEnabled = true },
    { key = "ochre", name = "Ochre", category = "furnishing", defaultEnabled = true },
    { key = "clean pelt", name = "Clean Pelt", category = "furnishing", defaultEnabled = true },
    { key = "bone", name = "Bone", category = "furnishing", defaultEnabled = true },
    { key = "dibellium", name = "Dibellium", category = "furnishing", defaultEnabled = true },
    { key = "culanda lacquer", name = "Culanda Lacquer", category = "furnishing", defaultEnabled = true }
  }
}

Addon.ItemCatalog = ItemCatalog

function ItemCatalog:GetByKey(itemKey)
  for _, item in ipairs(self.items) do
    if item.key == itemKey then
      return item
    end
  end
  return nil
end

function ItemCatalog:GetGroupedItems()
  local groups = {}
  for categoryKey in pairs(self.categories) do
    groups[categoryKey] = {}
  end
  for _, item in ipairs(self.items) do
    groups[item.category][#groups[item.category] + 1] = item
  end
  return groups
end
