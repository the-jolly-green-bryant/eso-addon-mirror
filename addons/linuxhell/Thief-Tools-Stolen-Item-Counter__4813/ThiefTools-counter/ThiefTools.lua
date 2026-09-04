-- Focused stolen-item counter.
local TT, EM, WM = ThiefTools, EVENT_MANAGER, WINDOW_MANAGER
local FENCE, LAUNDER, IGNORE = "Fence", "Launder", "Ignore"
TT.modes = { FENCE, LAUNDER, IGNORE }

TT.categoryDefinitions = {
 {key="treasure",name="Treasures",default=FENCE},
 {key="gear",name="Weapons and Armor",default=FENCE},
 {key="jewelry",name="Jewelry",default=FENCE},
 {key="recipes",name="Food and Drink Recipes",default=FENCE},
 {key="furnishingPlans",name="Furnishing Plans",default=LAUNDER},
 {key="motifs",name="Motifs and Style Pages",default=LAUNDER},
 {key="furnishings",name="Furnishings",default=LAUNDER},
 {key="foodDrink",name="Food and Drinks",default=FENCE},
 {key="ingredients",name="Provisioning Ingredients",default=LAUNDER},
 {key="alchemy",name="Alchemy Reagents and Solvents",default=LAUNDER},
 {key="runesGlyphs",name="Runes and Glyphs",default=LAUNDER},
 {key="materials",name="Crafting Materials",default=LAUNDER},
 {key="traitStyle",name="Trait and Style Materials",default=LAUNDER},
 {key="tools",name="Lockpicks and Tools",default=LAUNDER},
 {key="soulGems",name="Soul Gems",default=LAUNDER},
 {key="fishLures",name="Fish and Lures",default=FENCE},
 {key="potionsPoisons",name="Potions and Poisons",default=FENCE},
 {key="writs",name="Master and Holiday Writs",default=LAUNDER},
 {key="scribing",name="Scribing Grimoires and Scripts",default=LAUNDER},
 {key="containers",name="Containers",default=IGNORE},
 {key="trophies",name="Trophies and Collectible Parts",default=IGNORE},
 {key="other",name="Other Stolen Items",default=FENCE},
}

local defaults={categories={},display={x=300,y=300,scale=1,locked=false,hidden=false,background=true}}
for _,c in ipairs(TT.categoryDefinitions) do defaults.categories[c.key]=c.default end
local typeMap,specialMap={},{}
local function add(map,category,names)
 for _,name in ipairs(names) do local value=_G[name]; if value~=nil then map[value]=category end end
end
local function buildMaps()
 add(typeMap,"treasure",{"ITEMTYPE_TREASURE"})
 add(typeMap,"gear",{"ITEMTYPE_WEAPON","ITEMTYPE_ARMOR"})
 add(typeMap,"recipes",{"ITEMTYPE_RECIPE"})
 add(typeMap,"motifs",{"ITEMTYPE_RACIAL_STYLE_MOTIF","ITEMTYPE_COLLECTIBLE_STYLE_PAGE"})
 add(typeMap,"furnishings",{"ITEMTYPE_FURNISHING"})
 add(typeMap,"foodDrink",{"ITEMTYPE_FOOD","ITEMTYPE_DRINK"})
 add(typeMap,"ingredients",{"ITEMTYPE_INGREDIENT","ITEMTYPE_FLAVORING","ITEMTYPE_SPICE"})
 add(typeMap,"alchemy",{"ITEMTYPE_REAGENT","ITEMTYPE_POTION_BASE","ITEMTYPE_POISON_BASE"})
 add(typeMap,"runesGlyphs",{"ITEMTYPE_ENCHANTING_RUNE_ASPECT","ITEMTYPE_ENCHANTING_RUNE_ESSENCE","ITEMTYPE_ENCHANTING_RUNE_POTENCY","ITEMTYPE_GLYPH_ARMOR","ITEMTYPE_GLYPH_WEAPON","ITEMTYPE_GLYPH_JEWELRY"})
 add(typeMap,"materials",{"ITEMTYPE_RAW_MATERIAL","ITEMTYPE_BLACKSMITHING_MATERIAL","ITEMTYPE_BLACKSMITHING_RAW_MATERIAL","ITEMTYPE_CLOTHIER_MATERIAL","ITEMTYPE_CLOTHIER_RAW_MATERIAL","ITEMTYPE_WOODWORKING_MATERIAL","ITEMTYPE_WOODWORKING_RAW_MATERIAL","ITEMTYPE_JEWELRYCRAFTING_MATERIAL","ITEMTYPE_JEWELRYCRAFTING_RAW_MATERIAL","ITEMTYPE_FURNISHING_MATERIAL","ITEMTYPE_ADDITIVE","ITEMTYPE_BLACKSMITHING_BOOSTER","ITEMTYPE_CLOTHIER_BOOSTER","ITEMTYPE_WOODWORKING_BOOSTER","ITEMTYPE_JEWELRYCRAFTING_BOOSTER","ITEMTYPE_JEWELRYCRAFTING_RAW_BOOSTER"})
 add(typeMap,"traitStyle",{"ITEMTYPE_ARMOR_TRAIT","ITEMTYPE_WEAPON_TRAIT","ITEMTYPE_JEWELRY_TRAIT","ITEMTYPE_JEWELRY_RAW_TRAIT","ITEMTYPE_STYLE_MATERIAL"})
 add(typeMap,"tools",{"ITEMTYPE_LOCKPICK","ITEMTYPE_TOOL"})
 add(typeMap,"soulGems",{"ITEMTYPE_SOUL_GEM"})
 add(typeMap,"fishLures",{"ITEMTYPE_FISH","ITEMTYPE_LURE"})
 add(typeMap,"potionsPoisons",{"ITEMTYPE_POTION","ITEMTYPE_POISON"})
 add(typeMap,"writs",{"ITEMTYPE_MASTER_WRIT","ITEMTYPE_HOLIDAY_WRIT"})
 add(typeMap,"scribing",{"ITEMTYPE_CRAFTED_ABILITY","ITEMTYPE_CRAFTED_ABILITY_SCRIPT"})
 add(typeMap,"containers",{"ITEMTYPE_CONTAINER"})
 add(typeMap,"trophies",{"ITEMTYPE_TROPHY","ITEMTYPE_COLLECTIBLE"})
 add(specialMap,"furnishingPlans",{"SPECIALIZED_ITEMTYPE_RECIPE_ALCHEMY_FORMULA_FURNISHING","SPECIALIZED_ITEMTYPE_RECIPE_BLACKSMITHING_DIAGRAM_FURNISHING","SPECIALIZED_ITEMTYPE_RECIPE_CLOTHIER_PATTERN_FURNISHING","SPECIALIZED_ITEMTYPE_RECIPE_ENCHANTING_SCHEMATIC_FURNISHING","SPECIALIZED_ITEMTYPE_RECIPE_JEWELRYCRAFTING_SKETCH_FURNISHING","SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_DESIGN_FURNISHING","SPECIALIZED_ITEMTYPE_RECIPE_WOODWORKING_BLUEPRINT_FURNISHING"})
 add(specialMap,"trophies",{"SPECIALIZED_ITEMTYPE_TROPHY_COLLECTIBLE_FRAGMENT","SPECIALIZED_ITEMTYPE_TROPHY_KEY","SPECIALIZED_ITEMTYPE_TROPHY_KEY_FRAGMENT","SPECIALIZED_ITEMTYPE_TROPHY_RECIPE_FRAGMENT","SPECIALIZED_ITEMTYPE_TROPHY_RUNEBOX_FRAGMENT","SPECIALIZED_ITEMTYPE_TROPHY_SURVEY_REPORT","SPECIALIZED_ITEMTYPE_TROPHY_TREASURE_MAP","SPECIALIZED_ITEMTYPE_TROPHY_TRIBUTE_CLUE","SPECIALIZED_ITEMTYPE_TROPHY_UPGRADE_FRAGMENT"})
 add(specialMap,"scribing",{"SPECIALIZED_ITEMTYPE_CRAFTED_ABILITY","SPECIALIZED_ITEMTYPE_CRAFTED_ABILITY_SCRIPT_PRIMARY","SPECIALIZED_ITEMTYPE_CRAFTED_ABILITY_SCRIPT_SECONDARY","SPECIALIZED_ITEMTYPE_CRAFTED_ABILITY_SCRIPT_TERTIARY"})
end
local function categoryFor(bag,slot)
 local itemType,specialType=GetItemType(bag,slot); local equipType=GetItemEquipType(bag,slot)
 if equipType==EQUIP_TYPE_RING or equipType==EQUIP_TYPE_NECK then return "jewelry" end
 return specialMap[specialType] or typeMap[itemType] or "other"
end

local stats={fence=0,launder=0,gold=0}; local pending=false
function TT:ScanStolenItems()
 stats.fence,stats.launder,stats.gold=0,0,0
 for slot=0,GetBagSize(BAG_BACKPACK)-1 do
  if HasItemInSlot(BAG_BACKPACK,slot) and IsItemStolen(BAG_BACKPACK,slot) then
   local _,count=GetItemInfo(BAG_BACKPACK,slot); count=count or 0
   local mode=self.saved.categories[categoryFor(BAG_BACKPACK,slot)] or FENCE
   if mode==FENCE then stats.fence=stats.fence+count; stats.gold=stats.gold+(GetItemSellValueWithBonuses(BAG_BACKPACK,slot) or 0)*count
   elseif mode==LAUNDER then stats.launder=stats.launder+count end
  end
 end
 self:UpdatePanel()
end
function TT:QueueScan()
 if pending then return end; pending=true
 zo_callLater(function() pending=false; TT:ScanStolenItems() end,150)
end
function TT:UpdatePanel()
 if not self.window then return end
 local totalSells,sellsUsed=GetFenceSellTransactionInfo(); local totalLaunders,laundersUsed=GetFenceLaunderTransactionInfo()
 local sellsLeft=math.max(0,(totalSells or 0)-(sellsUsed or 0)); local laundersLeft=math.max(0,(totalLaunders or 0)-(laundersUsed or 0))
 self.window.launder:SetText(string.format("Launder: %d / %d",stats.launder,laundersLeft))
 self.window.fence:SetText(string.format("Fence: %d / %d",stats.fence,sellsLeft))
 self.window.gold:SetText(string.format("Gold: %s",ZO_CommaDelimitNumber(stats.gold)))
end
local function label(parent,name,r,g,b)
 local c=WM:CreateControl(name,parent,CT_LABEL); c:SetFont("ZoFontGameBold"); c:SetColor(r,g,b,1); c:SetVerticalAlignment(TEXT_ALIGN_CENTER); c:SetHeight(30); return c
end
function TT:SavePosition() self.saved.display.x=self.window:GetLeft(); self.saved.display.y=self.window:GetTop() end
function TT:ApplyDisplaySettings()
 local w=self.window;if not w then return end;w:SetScale(self.saved.display.scale);w:SetMovable(not self.saved.display.locked);w:SetHidden(self.saved.display.hidden)
 if self.saved.display.background then w.bg:SetCenterColor(0,0,0,.82);w.bg:SetEdgeColor(.55,.38,.08,.95) else w.bg:SetCenterColor(0,0,0,0);w.bg:SetEdgeColor(0,0,0,0) end
end
function TT:BuildUI()
 local w=WM:CreateTopLevelWindow("ThiefToolsCounter");w:SetDimensions(510,42);w:SetAnchor(TOPLEFT,GuiRoot,TOPLEFT,self.saved.display.x,self.saved.display.y);w:SetMouseEnabled(true);w:SetMovable(true);w:SetClampedToScreen(true);w:SetHandler("OnMoveStop",function() TT:SavePosition() end)
 w.bg=WM:CreateControl("ThiefToolsCounterBG",w,CT_BACKDROP);w.bg:SetAnchorFill(w);w.bg:SetEdgeTexture("/esoui/art/chatwindow/chat_bg_edge.dds",128,16,2);w.bg:SetCenterTexture("/esoui/art/chatwindow/chat_bg_center.dds")
 w.launder=label(w,"ThiefToolsLaunder",.35,.78,1);w.launder:SetAnchor(LEFT,w,LEFT,12,0);w.launder:SetWidth(160)
 w.fence=label(w,"ThiefToolsFence",.82,.55,1);w.fence:SetAnchor(LEFT,w.launder,RIGHT,8,0);w.fence:SetWidth(160)
 w.gold=label(w,"ThiefToolsGold",1,.82,.2);w.gold:SetAnchor(LEFT,w.fence,RIGHT,8,0);w.gold:SetWidth(150)
 self.window=w;self:ApplyDisplaySettings();self:ScanStolenItems()
end
function TT:TogglePanel() self.saved.display.hidden=not self.saved.display.hidden;self:ApplyDisplaySettings() end
local function registerEvents()
 EM:RegisterForEvent(TT.name,EVENT_INVENTORY_SINGLE_SLOT_UPDATE,function(_,bag) if bag==BAG_BACKPACK then TT:QueueScan() end end)
 for _,eventCode in ipairs({EVENT_ITEM_LAUNDER_RESULT,EVENT_SELL_RECEIPT,EVENT_JUSTICE_STOLEN_ITEMS_REMOVED,EVENT_OPEN_FENCE,EVENT_PLAYER_ACTIVATED}) do EM:RegisterForEvent(TT.name,eventCode,function() TT:QueueScan() end) end
end
local function loaded(_,addon)
 if addon~=TT.name then return end;EM:UnregisterForEvent(TT.name,EVENT_ADD_ON_LOADED);buildMaps();TT.saved=ZO_SavedVars:NewAccountWide("ThiefToolsVars",4,nil,defaults);TT:BuildUI();TT:RegisterSettings();registerEvents()
end
SLASH_COMMANDS["/tt"]=function() TT:TogglePanel() end
SLASH_COMMANDS["/tt.update"]=function() TT:ScanStolenItems() end
EM:RegisterForEvent(TT.name,EVENT_ADD_ON_LOADED,loaded)
