local ADDON="GrimUI"

local CHEST={
 Clean={"Easy","Tricky","Difficult","Expert"},
 Silly={"Baby Lock","Getting Tricky","Okay, Concentrate","Oh Boy"},
 Sarcastic={"Free Loot","Mildly Annoying","Oh, Come On","You Have Got To Be Kidding Me"},
 Vulgar={"Easy Shit","Mild Bullshit","Oh Fuck","FUCK."},
 Grim={"Peasant-Proof","Amateur Hour","Skill Issue","Good Fucking Luck"},
}

local NAMES={
 Clean={
  ["Count Ryelaz"]="Count Ryelaz", ["Zilyesset"]="Zilyesset",
  ["Lylanar"]="The Fire One", ["Turlassil"]="The Ice One",
  ["Lieutenant Njordal"]="Lieutenant Njordal", ["Flame-Herald Bahsei"]="Flame Lizard",
  ["Ghrasharog"]="Armory Assistant", ["Ezabi"]="Banker", ["Fezez"]="Merchant",

  -- Personal Assistants
  ["Tythis Andromo"]="Banker",
  ["Tythis Andromo, the Banker"]="Banker",
  ["Ezabi the Banker"]="Banker",
  ["Baron Jangleplume"]="Banker",
  ["Baron Jangleplume, the Banker"]="Banker",
  ["Factotum Property Steward"]="Banker",
  ["Pyroclast"]="Banker",
  ["Pyroclast, Infernace Conservator"]="Banker",
  ["Eri"]="Banker",
  ["Eri, Barking Banker"]="Banker",
  ["Celia Tyde"]="Banker",
  ["Celia Tyde, Lost Fleet Bursar"]="Banker",
  ["Nuzhimeh"]="Merchant",
  ["Nuzhimeh the Merchant"]="Merchant",
  ["Peddler of Prizes"]="Merchant",
  ["Peddler of Prizes, the Merchant"]="Merchant",
  ["Factotum Commerce Delegate"]="Merchant",
  ["Hoarfrost"]="Merchant",
  ["Hoarfrost, Takubar Trader"]="Merchant",
  ["Xyn"]="Merchant",
  ["Xyn, Planar Purveyor"]="Merchant",
  ["Terilorne"]="Merchant",
  ["Terilorne, Dibellan Freetrader"]="Merchant",
  ["Ghrasharog, Armory Assistant"]="Armory Assistant",
  ["Zuqoth"]="Armory Advisor",
  ["Zuqoth, Armory Advisor"]="Armory Advisor",
  ["Drinweth"]="Armory Assistant",
  ["Drinweth, Valenwood Armorer"]="Armory Assistant",
  ["Voko"]="Armory Assistant",
  ["Voko, Carnaval Weapondancer"]="Armory Assistant",
  ["Giladil"]="Deconstructor",
  ["Giladil the Ragpicker"]="Deconstructor",
  ["Aderene"]="Deconstructor",
  ["Aderene, Fargrave Dregs Dealer"]="Deconstructor",
  ["Tzozabrar"]="Deconstructor",
  ["Tzozabrar, Dwarven Deconstructor"]="Deconstructor",
  ["Siluruz"]="Deconstructor",
  ["Siluruz, Realm Craftsmaster"]="Deconstructor",
  ["Pontius Remus"]="Deconstructor",
  ["Pontius Remus, Lupine Scavenger"]="Deconstructor",
  ["Pirharri"]="Smuggler",
  ["Pirharri the Smuggler"]="Smuggler",
  ["Cambio Zammes"]="Smuggler",
  ["Cambio Zammes, Rooster in Exile"]="Smuggler",
 

   -- Trial Dummies
   ["Target Iron Atronach, Trial"]="Trial Iron Atronach",
   ["Target Deadlands Harvester, Trial"]="Trial Harvester",
   ["Target Harrowing Reaper, Trial"]="Trial Reaper",
   ["Target Kargrym, Trial"]="Trial Kargrym",
   ["Target Serpent's Image, Trial"]="Trial Serpent",

  -- Crafting Stations
  ["Grand Master Blacksmithing Station"]="Grand Master Forge",
  ["Grand Master Clothing Station"]="Grand Master Loom",
  ["Grand Master Woodworking Station"]="Grand Master Workshop",
  ["Grand Master Jewelry Crafting Station"]="Grand Master Jeweler",
  ["Transmute Station"]="Transmutation Station",
  ["Blacksmithing Station"]="Blacksmith's Forge",
  ["Clothing Station"]="Clothing Workshop",
  ["Woodworking Station"]="Woodworking Bench",
  ["Jewelry Crafting Station"]="Jewelry Workshop",
  ["Alchemy Station"]="Alchemy Lab",
  ["Enchanting Table"]="Enchanting Table",
  ["Provisioning Station"]="Kitchen",
  ["Outfit Station"]="Outfit Workshop",
  ["Dye Station"]="Dye Workshop",
  ["Aetherial Well"]="Aetherial Well",
  ["Armory Station"]="Armory",
  ["Scribing Altar"]="Scribing Altar",

  -- Overland
  ["Skyshard"]="Skyshard",
 },
 Silly={
  ["Count Ryelaz"]="Light Side", ["Zilyesset"]="Dark Side",
  ["Lylanar"]="The Cold One", ["Turlassil"]="The Hot One",
  ["Lieutenant Njordal"]="Lieutenant Dan", ["Flame-Herald Bahsei"]="Angry Lizard Lady",
  ["Ghrasharog"]="Armor Goblin", ["Ezabi"]="Bank Goblin", ["Fezez"]="Shop Goblin",

   -- Personal Assistants
   ["Tythis Andromo"]="Bank Goblin",
   ["Tythis Andromo, the Banker"]="Bank Goblin",
   ["Ezabi the Banker"]="Bank Goblin",
   ["Baron Jangleplume"]="Bank Goblin",
   ["Baron Jangleplume, the Banker"]="Bank Goblin",
   ["Factotum Property Steward"]="Bank Goblin",
   ["Pyroclast"]="Bank Goblin",
   ["Pyroclast, Infernace Conservator"]="Bank Goblin",
   ["Eri"]="Bank Goblin",
   ["Eri, Barking Banker"]="Bank Goblin",
   ["Celia Tyde"]="Bank Goblin",
   ["Celia Tyde, Lost Fleet Bursar"]="Bank Goblin",
   ["Nuzhimeh"]="Shop Goblin",
   ["Nuzhimeh the Merchant"]="Shop Goblin",
   ["Peddler of Prizes"]="Shop Goblin",
   ["Peddler of Prizes, the Merchant"]="Shop Goblin",
   ["Factotum Commerce Delegate"]="Shop Goblin",
   ["Hoarfrost"]="Shop Goblin",
   ["Hoarfrost, Takubar Trader"]="Shop Goblin",
   ["Xyn"]="Shop Goblin",
   ["Xyn, Planar Purveyor"]="Shop Goblin",
   ["Terilorne"]="Shop Goblin",
   ["Terilorne, Dibellan Freetrader"]="Shop Goblin",
   ["Ghrasharog, Armory Assistant"]="Armor Goblin",
   ["Zuqoth"]="Armor Goblin",
   ["Zuqoth, Armory Advisor"]="Armor Goblin",
   ["Drinweth"]="Armor Goblin",
   ["Drinweth, Valenwood Armorer"]="Armor Goblin",
   ["Voko"]="Armor Goblin",
   ["Voko, Carnaval Weapondancer"]="Armor Goblin",
   ["Giladil"]="Trash Goblin",
   ["Giladil the Ragpicker"]="Trash Goblin",
   ["Aderene"]="Trash Goblin",
   ["Aderene, Fargrave Dregs Dealer"]="Trash Goblin",
   ["Tzozabrar"]="Trash Goblin",
   ["Tzozabrar, Dwarven Deconstructor"]="Trash Goblin",
   ["Siluruz"]="Trash Goblin",
   ["Siluruz, Realm Craftsmaster"]="Trash Goblin",
   ["Pontius Remus"]="Trash Goblin",
   ["Pontius Remus, Lupine Scavenger"]="Trash Goblin",
   ["Pirharri"]="Smuggle Goblin",
   ["Pirharri the Smuggler"]="Smuggle Goblin",
   ["Cambio Zammes"]="Smuggle Goblin",
   ["Cambio Zammes, Rooster in Exile"]="Smuggle Goblin",

   -- Trial Dummies
   ["Target Iron Atronach, Trial"]="Big Metal Guy",
   ["Target Deadlands Harvester, Trial"]="Angry Weed Whacker",
   ["Target Harrowing Reaper, Trial"]="Spooky Bonk Dummy",
   ["Target Kargrym, Trial"]="Big Rock Bastard",
   ["Target Serpent's Image, Trial"]="Snek Dummy",

   -- Crafting Stations
   ["Grand Master Blacksmithing Station"]="Bonk Bench Supreme",
   ["Grand Master Clothing Station"]="Sock Factory Deluxe",
   ["Grand Master Woodworking Station"]="Fancy Stick Shaver",
   ["Grand Master Jewelry Crafting Station"]="Bling Bling Machine",
   ["Transmute Station"]="Crystal Re-Roller",
   ["Blacksmithing Station"]="Bonk Bench",
   ["Clothing Station"]="Sock Factory",
   ["Woodworking Station"]="Stick Shaver",
   ["Jewelry Crafting Station"]="Shiny Thing Maker",
   ["Alchemy Station"]="Potion Blender",
   ["Enchanting Table"]="Glowy Square Reader",
   ["Provisioning Station"]="Snack Shack",
   ["Outfit Station"]="Drip Station",
   ["Dye Station"]="Pretty Paint Table",
   ["Aetherial Well"]="Magic Water Cooler",
   ["Armory Station"]="Weapon Closet",
   ["Scribing Altar"]="Spell Word Processor",

  -- Overland
  ["Skyshard"]="Shiny Skill Fragment",
 },
 Sarcastic={
  ["Count Ryelaz"]="Totally The Light Side", ["Zilyesset"]="Obviously The Dark Side",
  ["Lylanar"]="Definitely Not The Cold One", ["Turlassil"]="Definitely Not The Hot One",
  ["Lieutenant Njordal"]="Lieutenant Dan, Apparently", ["Flame-Herald Bahsei"]="Very Calm Lizard Lady",
  ["Ghrasharog"]="The Armor Department Guy", ["Ezabi"]="Financial Services Department", ["Fezez"]="Retail Specialist",

   -- Personal Assistants
   ["Tythis Andromo"]="Financial Services Department",
   ["Tythis Andromo, the Banker"]="Financial Services Department",
   ["Ezabi the Banker"]="Financial Services Department",
   ["Baron Jangleplume"]="Financial Services Department",
   ["Baron Jangleplume, the Banker"]="Financial Services Department",
   ["Factotum Property Steward"]="Financial Services Department",
   ["Pyroclast"]="Financial Services Department",
   ["Pyroclast, Infernace Conservator"]="Financial Services Department",
   ["Eri"]="Financial Services Department",
   ["Eri, Barking Banker"]="Financial Services Department",
   ["Celia Tyde"]="Financial Services Department",
   ["Celia Tyde, Lost Fleet Bursar"]="Financial Services Department",
   ["Nuzhimeh"]="Retail Specialist",
   ["Nuzhimeh the Merchant"]="Retail Specialist",
   ["Peddler of Prizes"]="Retail Specialist",
   ["Peddler of Prizes, the Merchant"]="Retail Specialist",
   ["Factotum Commerce Delegate"]="Retail Specialist",
   ["Hoarfrost"]="Retail Specialist",
   ["Hoarfrost, Takubar Trader"]="Retail Specialist",
   ["Xyn"]="Retail Specialist",
   ["Xyn, Planar Purveyor"]="Retail Specialist",
   ["Terilorne"]="Retail Specialist",
   ["Terilorne, Dibellan Freetrader"]="Retail Specialist",
   ["Ghrasharog, Armory Assistant"]="The Armor Department Guy",
   ["Zuqoth"]="The Armor Department Guy",
   ["Zuqoth, Armory Advisor"]="The Armor Department Guy",
   ["Drinweth"]="The Armor Department Guy",
   ["Drinweth, Valenwood Armorer"]="The Armor Department Guy",
   ["Voko"]="The Armor Department Guy",
   ["Voko, Carnaval Weapondancer"]="The Armor Department Guy",
   ["Giladil"]="The Deconstruction Department",
   ["Giladil the Ragpicker"]="The Deconstruction Department",
   ["Aderene"]="The Deconstruction Department",
   ["Aderene, Fargrave Dregs Dealer"]="The Deconstruction Department",
   ["Tzozabrar"]="The Deconstruction Department",
   ["Tzozabrar, Dwarven Deconstructor"]="The Deconstruction Department",
   ["Siluruz"]="The Deconstruction Department",
   ["Siluruz, Realm Craftsmaster"]="The Deconstruction Department",
   ["Pontius Remus"]="The Deconstruction Department",
   ["Pontius Remus, Lupine Scavenger"]="The Deconstruction Department",
   ["Pirharri"]="The Smuggling Department",
   ["Pirharri the Smuggler"]="The Smuggling Department",
   ["Cambio Zammes"]="The Smuggling Department",
   ["Cambio Zammes, Rooster in Exile"]="The Smuggling Department",

   -- Trial Dummies
   ["Target Iron Atronach, Trial"]="Definitely A Real Trial",
   ["Target Deadlands Harvester, Trial"]="Very Dangerous Harvester",
   ["Target Harrowing Reaper, Trial"]="Extremely Threatening Dummy",
   ["Target Kargrym, Trial"]="Absolutely A Boss",
   ["Target Serpent's Image, Trial"]="Definitely Not A Snake",

   -- Crafting Stations
   ["Grand Master Blacksmithing Station"]="Voucher Furnace",
   ["Grand Master Clothing Station"]="Voucher Loom",
   ["Grand Master Woodworking Station"]="Expensive Sawdust",
   ["Grand Master Jewelry Crafting Station"]="Gold Sink Deluxe",
   ["Transmute Station"]="Trait Regret Department",
   ["Blacksmithing Station"]="Hammering Department",
   ["Clothing Station"]="Rag Department",
   ["Woodworking Station"]="Sawdust Department",
   ["Jewelry Crafting Station"]="Chromium Expense Center",
   ["Alchemy Station"]="Potion Waste Facility",
   ["Enchanting Table"]="Rune Translation Service",
   ["Provisioning Station"]="Microwave",
   ["Outfit Station"]="Drip Check",
   ["Dye Station"]="Fashion Mistake Corrector",
   ["Aetherial Well"]="Free Magic Water",
   ["Armory Station"]="Equipment Storage Department",
   ["Scribing Altar"]="Spell Formatting Department",

  -- Overland
  ["Skyshard"]="One-Third Of A Skill Point",
 },
 Vulgar={
  ["Count Ryelaz"]="Light Side My Ass", ["Zilyesset"]="Dark Side, Goddammit",
  ["Lylanar"]="The Fucking Cold One", ["Turlassil"]="The Fucking Hot One",
  ["Lieutenant Njordal"]="Lieutenant Fucking Dan", ["Flame-Herald Bahsei"]="Pissed-Off Lizard Bitch",
  ["Ghrasharog"]="Armor Bitch", ["Ezabi"]="Bank Bitch", ["Fezez"]="Shop Bitch",

   -- Personal Assistants
   ["Tythis Andromo"]="Bank Bitch",
   ["Tythis Andromo, the Banker"]="Bank Bitch",
   ["Ezabi the Banker"]="Bank Bitch",
   ["Baron Jangleplume"]="Bank Bitch",
   ["Baron Jangleplume, the Banker"]="Bank Bitch",
   ["Factotum Property Steward"]="Bank Bitch",
   ["Pyroclast"]="Bank Bitch",
   ["Pyroclast, Infernace Conservator"]="Bank Bitch",
   ["Eri"]="Bank Bitch",
   ["Eri, Barking Banker"]="Bank Bitch",
   ["Celia Tyde"]="Bank Bitch",
   ["Celia Tyde, Lost Fleet Bursar"]="Bank Bitch",
   ["Nuzhimeh"]="Shop Bitch",
   ["Nuzhimeh the Merchant"]="Shop Bitch",
   ["Peddler of Prizes"]="Shop Bitch",
   ["Peddler of Prizes, the Merchant"]="Shop Bitch",
   ["Factotum Commerce Delegate"]="Shop Bitch",
   ["Hoarfrost"]="Shop Bitch",
   ["Hoarfrost, Takubar Trader"]="Shop Bitch",
   ["Xyn"]="Shop Bitch",
   ["Xyn, Planar Purveyor"]="Shop Bitch",
   ["Terilorne"]="Shop Bitch",
   ["Terilorne, Dibellan Freetrader"]="Shop Bitch",
   ["Ghrasharog, Armory Assistant"]="Armor Bitch",
   ["Zuqoth"]="Armor Bitch",
   ["Zuqoth, Armory Advisor"]="Armor Bitch",
   ["Drinweth"]="Armor Bitch",
   ["Drinweth, Valenwood Armorer"]="Armor Bitch",
   ["Voko"]="Armor Bitch",
   ["Voko, Carnaval Weapondancer"]="Armor Bitch",
   ["Giladil"]="Deconstructor Bitch",
   ["Giladil the Ragpicker"]="Deconstructor Bitch",
   ["Aderene"]="Deconstructor Bitch",
   ["Aderene, Fargrave Dregs Dealer"]="Deconstructor Bitch",
   ["Tzozabrar"]="Deconstructor Bitch",
   ["Tzozabrar, Dwarven Deconstructor"]="Deconstructor Bitch",
   ["Siluruz"]="Deconstructor Bitch",
   ["Siluruz, Realm Craftsmaster"]="Deconstructor Bitch",
   ["Pontius Remus"]="Deconstructor Bitch",
   ["Pontius Remus, Lupine Scavenger"]="Deconstructor Bitch",
   ["Pirharri"]="Smuggler Bitch",
   ["Pirharri the Smuggler"]="Smuggler Bitch",
   ["Cambio Zammes"]="Smuggler Bitch",
   ["Cambio Zammes, Rooster in Exile"]="Smuggler Bitch",

   -- Trial Dummies
   ["Target Iron Atronach, Trial"]="Big Fucking Dummy",
   ["Target Deadlands Harvester, Trial"]="Fucking Weed Whacker",
   ["Target Harrowing Reaper, Trial"]="Spooky Fucking Reaper",
   ["Target Kargrym, Trial"]="Rocky Fuckhead",
   ["Target Serpent's Image, Trial"]="Fucking Snek",

   -- Crafting Stations
   ["Grand Master Blacksmithing Station"]="Heavy Metal Bench",
   ["Grand Master Clothing Station"]="Sewing Bitch 3000",
   ["Grand Master Woodworking Station"]="Splinter Factory",
   ["Grand Master Jewelry Crafting Station"]="Bankruptcy Machine",
   ["Transmute Station"]="Trait Fuckery Station",
   ["Blacksmithing Station"]="Hammering Bullshit",
   ["Clothing Station"]="Rag Weaver",
   ["Woodworking Station"]="Tree Chopper",
   ["Jewelry Crafting Station"]="Chromium Dump",
   ["Alchemy Station"]="Walter White's Setup",
   ["Enchanting Table"]="Glyph Blender",
   ["Provisioning Station"]="Snack Bar",
   ["Outfit Station"]="Overpriced Closet",
   ["Dye Station"]="Paint Bucket",
   ["Aetherial Well"]="Magic Fucking Water",
   ["Armory Station"]="Weapon Hoard",
   ["Scribing Altar"]="Spell Bullshit Generator",

  -- Overland
  ["Skyshard"]="Shiny Fucking Skill Fragment",
 },
 Grim={
  ["Count Ryelaz"]="The Wrong Fucking Side", ["Zilyesset"]="Welcome To The Fucking Dark Side",
  ["Lylanar"]="The One Who Is Apparently Cold Now", ["Turlassil"]="The One Who Is Apparently Hot Now",
  ["Lieutenant Njordal"]="Lieutenant Dan Has Seen Some Shit", ["Flame-Herald Bahsei"]="She Has Had Enough Of Your Shit",
  ["Ghrasharog"]="Armory Peasant", ["Ezabi"]="Financial Peasant", ["Fezez"]="Capitalist Goblin",

   -- Personal Assistants
   ["Tythis Andromo"]="Financial Peasant",
   ["Tythis Andromo, the Banker"]="Financial Peasant",
   ["Ezabi the Banker"]="Financial Peasant",
   ["Baron Jangleplume"]="Financial Peasant",
   ["Baron Jangleplume, the Banker"]="Financial Peasant",
   ["Factotum Property Steward"]="Financial Peasant",
   ["Pyroclast"]="Financial Peasant",
   ["Pyroclast, Infernace Conservator"]="Financial Peasant",
   ["Eri"]="Financial Peasant",
   ["Eri, Barking Banker"]="Financial Peasant",
   ["Celia Tyde"]="Financial Peasant",
   ["Celia Tyde, Lost Fleet Bursar"]="Financial Peasant",
   ["Nuzhimeh"]="Capitalist Goblin",
   ["Nuzhimeh the Merchant"]="Capitalist Goblin",
   ["Peddler of Prizes"]="Capitalist Goblin",
   ["Peddler of Prizes, the Merchant"]="Capitalist Goblin",
   ["Factotum Commerce Delegate"]="Capitalist Goblin",
   ["Hoarfrost"]="Capitalist Goblin",
   ["Hoarfrost, Takubar Trader"]="Capitalist Goblin",
   ["Xyn"]="Capitalist Goblin",
   ["Xyn, Planar Purveyor"]="Capitalist Goblin",
   ["Terilorne"]="Capitalist Goblin",
   ["Terilorne, Dibellan Freetrader"]="Capitalist Goblin",
   ["Ghrasharog, Armory Assistant"]="Armory Peasant",
   ["Zuqoth"]="Armory Peasant",
   ["Zuqoth, Armory Advisor"]="Armory Peasant",
   ["Drinweth"]="Armory Peasant",
   ["Drinweth, Valenwood Armorer"]="Armory Peasant",
   ["Voko"]="Armory Peasant",
   ["Voko, Carnaval Weapondancer"]="Armory Peasant",
   ["Giladil"]="Trash Peasant",
   ["Giladil the Ragpicker"]="Trash Peasant",
   ["Aderene"]="Trash Peasant",
   ["Aderene, Fargrave Dregs Dealer"]="Trash Peasant",
   ["Tzozabrar"]="Trash Peasant",
   ["Tzozabrar, Dwarven Deconstructor"]="Trash Peasant",
   ["Siluruz"]="Trash Peasant",
   ["Siluruz, Realm Craftsmaster"]="Trash Peasant",
   ["Pontius Remus"]="Trash Peasant",
   ["Pontius Remus, Lupine Scavenger"]="Trash Peasant",
   ["Pirharri"]="Smuggler Peasant",
   ["Pirharri the Smuggler"]="Smuggler Peasant",
   ["Cambio Zammes"]="Smuggler Peasant",
   ["Cambio Zammes, Rooster in Exile"]="Smuggler Peasant",

   -- Trial Dummies
   ["Target Iron Atronach, Trial"]="The Metal Bastard",
   ["Target Deadlands Harvester, Trial"]="The Harvesting Bastard",
   ["Target Harrowing Reaper, Trial"]="The Reaper Awaits",
   ["Target Kargrym, Trial"]="The Stone One",
   ["Target Serpent's Image, Trial"]="The Serpent Awaits",

   -- Crafting Stations
   ["Grand Master Blacksmithing Station"]="The Grand Forge",
   ["Grand Master Clothing Station"]="The Grand Loom",
   ["Grand Master Woodworking Station"]="The Grand Workshop",
   ["Grand Master Jewelry Crafting Station"]="The Grand Treasure Vault",
   ["Transmute Station"]="The Wheel of Regret",
   ["Blacksmithing Station"]="The Iron Forge",
   ["Clothing Station"]="The Weaver's Bench",
   ["Woodworking Station"]="The Timber Forge",
   ["Jewelry Crafting Station"]="The Precious Forge",
   ["Alchemy Station"]="The Alchemist's Den",
   ["Enchanting Table"]="The Rune Table",
   ["Provisioning Station"]="The Feeding Grounds", 
   ["Outfit Station"]="The Vanity Forge",
   ["Dye Station"]="The Color Altar",
   ["Aetherial Well"]="The Well of Endless Magicka",
   ["Armory Station"]="The Arsenal",
   ["Scribing Altar"]="The Forbidden Script",

  -- Overland
  ["Skyshard"]="Fragment Of Power",
 },
}

local defaults={heavySnacks=true,chestNames=true,tasteProfile="Silly",nameReplacements=true,nameProfile="Silly"}
local sv
local InteractNameReplacement

local function ReticleUpdate()
 if not RETICLE or not sv then return end

 if sv.heavySnacks and ZO_ReticleContainerInteractContext then
  local c=ZO_ReticleContainerInteractContext
  local text=c:GetText()
  if text=="Heavy Sack" then c:SetText("Heavy Snack") end
 end

 if sv.chestNames and ZO_ReticleContainerInteractKeybindButtonNameLabel then
  local _,name,_,_,_,difficulty=GetGameCameraInteractableActionInfo()
  if name=="Chest" then
   local p=CHEST[sv.tasteProfile] or CHEST.Silly
   local replacement=p[tonumber(difficulty)]
   if replacement then
    local c=ZO_ReticleContainerInteractKeybindButtonNameLabel
    local text=c:GetText() or ""
    c:SetText(text:gsub("%b()","("..replacement..")",1))
   end
  end
 end

 if InteractNameReplacement then InteractNameReplacement() end
end

InteractNameReplacement=function()
 if not sv or not sv.nameReplacements then return end
 local c=ZO_ReticleContainerInteractContext
 if not c then return end
 local _,current=GetGameCameraInteractableActionInfo()
 if not current or current=="" then return end
 local profile=NAMES[sv.nameProfile] or NAMES.Silly
 local replacement=profile and profile[current]
 if replacement then c:SetText(replacement) end
end

local function NameReplacement()
 if not sv or not sv.nameReplacements then return end
 local c=ZO_TargetUnitFramereticleoverName
 if not c then return end
 local current=GetUnitName("reticleover")
 if not current or current=="" then return end
 local profile=NAMES[sv.nameProfile] or NAMES.Silly
 local replacement=profile and profile[current]
 if replacement then c:SetText(replacement) end
end

local function TargetChanged()
 zo_callLater(NameReplacement,0)
 zo_callLater(NameReplacement,50)
end

local function ContactGrimGrin()
 if not SCENE_MANAGER then return end
 local mailScene=SCENE_MANAGER:GetScene("mailSend")
 if not mailScene then return end
 mailScene:RegisterCallback("StateChange",function(oldState,newState)
  if newState~=SCENE_SHOWN then return end
  ZO_MailSendToField:SetText("@GrimGrin94")
  ZO_MailSendSubjectField:SetText("GrimUI Name Suggestion")
  ZO_MailSendBodyField:SetText("Boss name:\nSuggested Change:")
  ZO_MailSendBodyField:TakeFocus()
 end)
 SCENE_MANAGER:Show("mailSend")
end

local function SetupMenu()
 if not LibAddonMenu2 then return end
 local panel=LibAddonMenu2:RegisterAddonPanel("GrimUIOptions",{
  type="panel",name="Grim UI",displayName="Grim UI",author="Grim",version="2.1_Dev",
  registerForRefresh=true,registerForDefaults=true,
 })
 LibAddonMenu2:RegisterOptionControls("GrimUIOptions",{
  {type="checkbox",name="Heavy Snacks",tooltip="Change Heavy Sack to Heavy Snack.",getFunc=function() return sv.heavySnacks end,setFunc=function(v) sv.heavySnacks=v ReticleUpdate() end,default=true},
  {type="checkbox",name="Custom Chest Names",tooltip="Replace chest difficulty names.",getFunc=function() return sv.chestNames end,setFunc=function(v) sv.chestNames=v ReticleUpdate() end,default=true},
  {type="dropdown",name="Taste Profile",choices={"Clean","Silly","Sarcastic","Vulgar","Grim"},getFunc=function() return sv.tasteProfile end,setFunc=function(v) sv.tasteProfile=v ReticleUpdate() end,default="Silly"},
  {type="checkbox",name="Name Replacements",tooltip="Replace boss, NPC, and personal assistant names.",getFunc=function() return sv.nameReplacements end,setFunc=function(v) sv.nameReplacements=v NameReplacement() if InteractNameReplacement then InteractNameReplacement() end end,default=true},
  {type="dropdown",name="Name Profile",choices={"Clean","Silly","Sarcastic","Vulgar","Grim"},getFunc=function() return sv.nameProfile end,setFunc=function(v) sv.nameProfile=v NameReplacement() if InteractNameReplacement then InteractNameReplacement() end end,default="Silly"},
  {type="button",name="Contact GrimGrin",tooltip="Open an in-game mail addressed to GrimGrin for gold or name suggestions.",func=ContactGrimGrin},
 })
end

local function Init()
 sv=ZO_SavedVars:NewAccountWide("GrimUISavedVars",1,nil,defaults)
 if RETICLE and type(SecurePostHook)=="function" then SecurePostHook(RETICLE,"UpdateInteractText",ReticleUpdate) end
 EVENT_MANAGER:RegisterForEvent(ADDON.."_Target",EVENT_RETICLE_TARGET_CHANGED,TargetChanged)
 if type(SecurePostHook)=="function" and type(ZO_UnitFrames_UpdateWindow)=="function" then
  SecurePostHook("ZO_UnitFrames_UpdateWindow",function(unitTag)
   if unitTag=="reticleover" then zo_callLater(NameReplacement,0) end
  end)
 end
 SetupMenu()
 SLASH_COMMANDS["/grimui"]=function()
  d("|cFF4444GrimUI v2.1|r Heavy Snacks="..tostring(sv.heavySnacks).." Chest Names="..tostring(sv.chestNames).." Chest Profile="..tostring(sv.tasteProfile).." Name Replacements="..tostring(sv.nameReplacements).." Name Profile="..tostring(sv.nameProfile))
 end
end

EVENT_MANAGER:RegisterForEvent(ADDON,EVENT_ADD_ON_LOADED,function(_,name)
 if name==ADDON then EVENT_MANAGER:UnregisterForEvent(ADDON,EVENT_ADD_ON_LOADED) Init() end
end)
