local DEG_ADDON = _G["DEG_CURRENT_ADDON"]

local function d(msg)
  _G[DEG_ADDON.PACKAGE_NAME].plugins[DEG_ADDON.ADDON_NAME_SHORT]:d(msg)
end

local Obj = { }

function Obj:addTextTooltip(control, text)
  control.degSetTooltip = text
  if not control.degSetTooltipInit then
    control:SetHandler("OnMouseEnter", function(self)
      if not control.degSetTooltip then return end
      ZO_Tooltips_ShowTextTooltip(self, TOP, control.degSetTooltip)
    end)
    control:SetHandler("OnMouseExit", function(self)
      ZO_Tooltips_HideTextTooltip()
    end)
    control.degSetTooltipInit = true
  end
  control:SetMouseEnabled(true)
end

function Obj:remTextTooltip(control)
  control.degSetTooltip = false
end

function Obj:paintItem(inventoryType, thisControl, thisControlIcon, thisControlResearch, slot, isGrid)            

  local Addon = _G[DEG_ADDON.PACKAGE_NAME].plugins[DEG_ADDON.ADDON_NAME_SHORT]

  local doIcons = Addon.savedVariablesAccount.settings.icons
  local doKnow = Addon.savedVariablesAccount.settings.knowledge

  self:remTextTooltip(thisControl)
  self:remTextTooltip(thisControlResearch)

  local dim0 = 18
  local dimBigger0 = 20
  local dimBigger1 = 22
  local dimBigger2 = 25
  local dimBigger22 = 26
  local dimBigger221 = 27
  local dimBigger222 = 28
  local dimBigger3 = 29
  local dimBigger33 = 31
  local dimBigger4 = 33

  --THIS ADDON  STATUS--------------------------------------------------------------------------
  if thisControlIcon then
    thisControlIcon:SetHidden(true)
    thisControlIcon:SetAlpha(0.85)
        
    thisControlResearch:SetHidden(true)
    
    
    local itemLink
    --if inventoryType == "tradingHouseResult" then
      --itemLink = GetTradingHouseSearchResultItemLink(slot.slotIndex, LINK_STYLE_BRACKETS)
    --elseif inventoryType == "tradingHouseResult" then
      --itemLink = GetTradingHouseListingItemLink(slot.slotIndex, LINK_STYLE_BRACKETS)
    if inventoryType == "buyBack" then
      itemLink = GetBuybackItemLink(slot.slotIndex, LINK_STYLE_BRACKETS)    
    else
      itemLink = GetItemLink(slot.bagId, slot.slotIndex)
    end
      
    if not slot or not itemLink then return end
      
    local itemType, specializedItemType = GetItemLinkItemType(itemLink)
    local _, _, _, specializedItemTypeEquip = GetItemLinkInfo(itemLink)
    --local string_icon, number_sellPrice, boolean_meetsUsageRequirement, specializedItemTypeEquip, number_itemStyleId = GetItemLinkInfo(itemLink)
    
    local itemId;
    local split = {SplitString(':', itemLink)}
    if split[3] then 
      itemId = tonumber(split[3])    
    end
    if not itemId then return end
    
    local trait = GetItemTrait(slot.bagId, slot.slotIndex)
        
                
    --SET------------------------------------------------------------------------------------------
    local isSet = false
    if GetItemLinkSetInfo(itemLink) then
      isSet = true
      thisControlIcon:SetColor(0,95,160,255)    
    end
    
    --INTRICATE------------------------------------------------------------------------------------------
    --if trait == ITEM_TRAIT_TYPE_ARMOR_INTRICATE or trait == ITEM_TRAIT_TYPE_WEAPON_INTRICATE then
      --thisControlIcon:SetTexture([[esoui/art/icons/crafting_inspiration_logo.dds]])
      --thisControlIcon:SetHidden(false)
      --thisControlIcon:SetAlpha(1.00)
      --thisControlIcon:SetWidth(dimBigger0)
      --thisControlIcon:SetHeight(dimBigger0)
    
    --ORNATE------------------------------------------------------------------------------------------  
    --elseif trait == ITEM_TRAIT_TYPE_ARMOR_ORNATE or trait == ITEM_TRAIT_TYPE_WEAPON_ORNATE or trait == ITEM_TRAIT_TYPE_JEWELRY_ORNATE then
      --thisControlIcon:SetTexture([[esoui/art/currency/currency_gold_32.dds]])
      --thisControlIcon:SetHidden(false)
      --thisControlIcon:SetAlpha(1.00)
      --thisControlIcon:SetWidth(dimBigger0)
      --thisControlIcon:SetHeight(dimBigger0)                
    --end
    
    --ARMOR, WEAPON------------------------------------------------------------------------------------------
    if itemType == ITEMTYPE_ARMOR or itemType == ITEMTYPE_WEAPON then
      
      if false and (trait == ITEM_TRAIT_TYPE_ARMOR_INTRICATE or trait == ITEM_TRAIT_TYPE_WEAPON_INTRICATE or trait == ITEM_TRAIT_TYPE_JEWELRY_INTRICATE or
      trait == ITEM_TRAIT_TYPE_ARMOR_ORNATE or trait == ITEM_TRAIT_TYPE_WEAPON_ORNATE or trait == ITEM_TRAIT_TYPE_JEWELRY_ORNATE) then
      
      else
    
        local specializedItemTypeArmor, specializedItemTypeWeapon = GetItemLinkArmorType(itemLink), GetItemLinkWeaponType(itemLink)
        
        local specializedItemType = specializedItemTypeArmor
        if specializedItemType == 0 then
          if (specializedItemTypeWeapon == 0) then
            specializedItemType = -1
          else
            specializedItemType = specializedItemTypeWeapon
          end
        end      
            
        local dim = 0
        
        local CRAFTING_TYPE = CRAFTING_TYPE_BLACKSMITHING
        local isJewelry = false
        
        if specializedItemTypeArmor == ARMORTYPE_HEAVY then
          thisControlIcon:SetTexture([[esoui/art/icons/progression_tabicon_armorheavy_up.dds]])
          dim = dimBigger2              
        elseif specializedItemTypeArmor == ARMORTYPE_MEDIUM then
          thisControlIcon:SetTexture([[esoui/art/icons/progression_tabicon_armormedium_up.dds]])
          dim = dimBigger2
          CRAFTING_TYPE = CRAFTING_TYPE_CLOTHIER
        elseif specializedItemTypeArmor == ARMORTYPE_LIGHT then
          thisControlIcon:SetTexture([[esoui/art/icons/progression_tabicon_armorlight_up.dds]])
          dim = dimBigger22   
          CRAFTING_TYPE = CRAFTING_TYPE_CLOTHIER
        elseif specializedItemTypeWeapon == WEAPONTYPE_HAMMER or specializedItemTypeWeapon == WEAPONTYPE_SWORD or specializedItemTypeWeapon == WEAPONTYPE_DAGGER or specializedItemTypeWeapon == WEAPONTYPE_AXE then
          thisControlIcon:SetTexture([[esoui/art/icons/progression_tabicon_1handed_up.dds]])
          dim = dimBigger3
        elseif specializedItemTypeWeapon == WEAPONTYPE_TWO_HANDED_AXE or specializedItemTypeWeapon == WEAPONTYPE_TWO_HANDED_HAMMER or specializedItemTypeWeapon == WEAPONTYPE_TWO_HANDED_SWORD then
          thisControlIcon:SetTexture([[esoui/art/icons/progression_tabicon_2handed_up.dds]])
          dim = dimBigger3
        elseif specializedItemTypeWeapon == WEAPONTYPE_FIRE_STAFF or specializedItemTypeWeapon == WEAPONTYPE_FROST_STAFF or specializedItemTypeWeapon == WEAPONTYPE_LIGHTNING_STAFF then
          thisControlIcon:SetTexture([[esoui/art/icons/progression_tabicon_damagestaff_up.dds]])      
          dim = dimBigger4
          CRAFTING_TYPE = CRAFTING_TYPE_WOODWORKING    
        elseif specializedItemTypeWeapon == WEAPONTYPE_HEALING_STAFF then
          thisControlIcon:SetTexture([[esoui/art/icons/progression_tabicon_healstaff_up.dds]])      
          dim = dimBigger4
          CRAFTING_TYPE = CRAFTING_TYPE_WOODWORKING
        elseif specializedItemTypeWeapon == WEAPONTYPE_BOW then
          thisControlIcon:SetTexture([[esoui/art/icons/progression_tabicon_bow_inactive.dds]])      
          dim = dimBigger4    
          CRAFTING_TYPE = CRAFTING_TYPE_WOODWORKING
        elseif specializedItemTypeWeapon == WEAPONTYPE_SHIELD then
          thisControlIcon:SetTexture([[esoui/art/icons/progression_tabicon_1handed_up.dds]])
          dim = dimBigger3
          CRAFTING_TYPE = CRAFTING_TYPE_WOODWORKING
        elseif specializedItemTypeArmor == ARMORTYPE_NONE and specializedItemTypeEquip == EQUIP_TYPE_NECK then    
          thisControlIcon:SetTexture([[esoui/art/characterwindow/gearslot_neck.dds]])
          specializedItemType =-99
          isJewelry = true
          CRAFTING_TYPE = CRAFTING_TYPE_JEWELRYCRAFTING
        elseif specializedItemTypeArmor == ARMORTYPE_NONE and specializedItemTypeEquip == EQUIP_TYPE_RING then
          thisControlIcon:SetTexture([[esoui/art/characterwindow/gearslot_ring.dds]])
          specializedItemType =-99
          isJewelry = true
          CRAFTING_TYPE = CRAFTING_TYPE_JEWELRYCRAFTING
        else
          thisControlIcon:SetTexture([[esoui/art/crafting/smithing_armorslot.dds]])
        end
            
        if dim ~= 0 then
          thisControlIcon:SetWidth(dim)
          thisControlIcon:SetHeight(dim)
        end
            
        thisControlIcon:SetHidden(false)
        
        --TRAIT RESEARCH----------------------------------------------------------------------------------------
              
        if Addon.savedVariablesAccount.settings.traitResearch then      
          if trait ~= ITEM_TRAIT_TYPE_NONE and trait ~= ITEM_TRAIT_TYPE_DEPRECATED then
            --if specializedItemTypeEquip ~= EQUIP_TYPE_NECK and specializedItemTypeEquip ~= EQUIP_TYPE_RING then
  
              --keine farbe
              
              thisControlResearch:SetColor(
                thisControlResearch.origR,
                thisControlResearch.origG,
                thisControlResearch.origB,
                thisControlResearch.origA)
                
              thisControlResearch:SetHidden(false)
            
              if specializedItemType == specializedItemTypeWeapon then
                --waffenmodus
                
                if Addon.vars.equiptTypeToResearchLineWeapons[specializedItemType][specializedItemTypeWeapon] then
  
                  local numLine = Addon.vars.equiptTypeToResearchLineWeapons[specializedItemType][specializedItemTypeWeapon]
                  
                  if Addon:traitWanted(CRAFTING_TYPE, numLine, trait) then
                      thisControlResearch:SetColor(0.0*255/255,0.5*255/255,0.0*255/255,1*255/255)
                      --wenn mindestens 1ner unbekannt, dann rot
                      if Addon:traitNeeded(CRAFTING_TYPE, numLine, trait) then
                        thisControlResearch:SetColor(1*255/255,0.25*255/255,0*255/255,1*255/255)
                      end
                      
                      local traitNeededText = Addon:getNeededByCharsStringTrait(CRAFTING_TYPE, numLine, trait, GetCurrentCharacterId())
                      local traitIsAnalyzingText = Addon:getAnalyzingByCharsStringTrait(CRAFTING_TYPE, numLine, trait, GetCurrentCharacterId())
                      local traitLearnedByText = Addon:getLearnedByCharsStringTrait(CRAFTING_TYPE, numLine, trait, GetCurrentCharacterId())
  
                      if traitNeededText ~= "" then
                        traitNeededText = GetString(SI_DEG_TRAIT_NEED_BY)..": "..traitNeededText
                      end
                      if traitIsAnalyzingText ~= "" then                                             
                        traitIsAnalyzingText = GetString(SI_DEG_TRAIT_ANALYZING_BY)..": "..traitIsAnalyzingText
                        if traitNeededText ~= "" then
                          traitIsAnalyzingText = "\n"..traitIsAnalyzingText
                        end                      
                      end
                      if traitLearnedByText ~= "" then
                        traitLearnedByText = GetString(SI_DEG_TRAIT_LEARNED_BY)..": "..traitLearnedByText
                        if traitNeededText ~= "" or traitIsAnalyzingText ~= "" then
                          traitLearnedByText = "\n"..traitLearnedByText
                        end                      
                      end               
                      
                      if traitIsAnalyzingText ~= "" and traitNeededText == "" then
                        thisControlResearch:SetColor(100/255,175/255,255/255,1*255/255)
                      end
                        
                      self:addTextTooltip(thisControlResearch, traitNeededText..traitIsAnalyzingText..traitLearnedByText)
                  else
                    --keiner möchte den Trait, lasse keine farbe
                    self:addTextTooltip(thisControlResearch, GetString(SI_DEG_TRAIT_NEED_NOT))              
                  end
                end
              elseif specializedItemType == specializedItemTypeArmor then
                --rüstungsmodus
                --type = ARMORTYPE_MEDIUM
                --type2 = EQUIP_TYPE_SHOULDERS                                         
                
                
                              
                if Addon.vars.equiptTypeToResearchLineArmor[specializedItemType][specializedItemTypeEquip] then
                  local numLine = Addon.vars.equiptTypeToResearchLineArmor[specializedItemType][specializedItemTypeEquip]
                                                  
                  if Addon:traitWanted(CRAFTING_TYPE, numLine, trait) then
                    --grün
                    thisControlResearch:SetColor(0.0*255/255,0.5*255/255,0.0*255/255,1*255/255)
                    
                    if Addon:traitNeeded(CRAFTING_TYPE, numLine, trait) then
                      thisControlResearch:SetColor(1*255/255,0.25*255/255,0*255/255,1*255/255)
                    end                  
                    
                    local traitNeededText = Addon:getNeededByCharsStringTrait(CRAFTING_TYPE, numLine, trait, GetCurrentCharacterId())
                    local traitIsAnalyzingText = Addon:getAnalyzingByCharsStringTrait(CRAFTING_TYPE, numLine, trait, GetCurrentCharacterId())
                    local traitLearnedByText = Addon:getLearnedByCharsStringTrait(CRAFTING_TYPE, numLine, trait, GetCurrentCharacterId())
  
                    if traitNeededText ~= "" then
                      traitNeededText = GetString(SI_DEG_TRAIT_NEED_BY)..": "..traitNeededText
                    end
                    if traitIsAnalyzingText ~= "" then                                             
                      traitIsAnalyzingText = GetString(SI_DEG_TRAIT_ANALYZING_BY)..": "..traitIsAnalyzingText
                      if traitNeededText ~= "" then
                        traitIsAnalyzingText = "\n"..traitIsAnalyzingText
                      end                      
                    end
                    if traitLearnedByText ~= "" then
                      traitLearnedByText = GetString(SI_DEG_TRAIT_LEARNED_BY)..": "..traitLearnedByText
                      if traitNeededText ~= "" or traitIsAnalyzingText ~= "" then
                        traitLearnedByText = "\n"..traitLearnedByText
                      end                      
                    end
                    
                    if traitIsAnalyzingText ~= "" and traitNeededText == "" then
                      thisControlResearch:SetColor(100/255,175/255,255/255,1*255/255)
                    end
                    self:addTextTooltip(thisControlResearch, traitNeededText..traitIsAnalyzingText..traitLearnedByText)
                  else
                    --keiner möchte den Trait, lasse keine farbe              
                    self:addTextTooltip(thisControlResearch, GetString(SI_DEG_TRAIT_NEED_NOT))
                  end
                end
              elseif specializedItemType == -99 then
                --d("isJewelry="..specializedItemType..";"..specializedItemTypeEquip)
                
                if Addon.vars.researchLineToEquiptTypeJewelry[specializedItemType][specializedItemTypeEquip] then
                  local numLine = Addon.vars.researchLineToEquiptTypeJewelry[specializedItemType][specializedItemTypeEquip]
                                                  
                  if Addon:traitWanted(CRAFTING_TYPE, numLine, trait) then
                    --grün
                    thisControlResearch:SetColor(0.0*255/255,0.5*255/255,0.0*255/255,1*255/255)
                    
                    if Addon:traitNeeded(CRAFTING_TYPE, numLine, trait) then
                      thisControlResearch:SetColor(1*255/255,0.25*255/255,0*255/255,1*255/255)
                    end                  
                    
                    local traitNeededText = Addon:getNeededByCharsStringTrait(CRAFTING_TYPE, numLine, trait, GetCurrentCharacterId())
                    local traitIsAnalyzingText = Addon:getAnalyzingByCharsStringTrait(CRAFTING_TYPE, numLine, trait, GetCurrentCharacterId())
                    local traitLearnedByText = Addon:getLearnedByCharsStringTrait(CRAFTING_TYPE, numLine, trait, GetCurrentCharacterId())
  
                    if traitNeededText ~= "" then
                      traitNeededText = GetString(SI_DEG_TRAIT_NEED_BY)..": "..traitNeededText
                    end
                    if traitIsAnalyzingText ~= "" then                                             
                      traitIsAnalyzingText = GetString(SI_DEG_TRAIT_ANALYZING_BY)..": "..traitIsAnalyzingText
                      if traitNeededText ~= "" then
                        traitIsAnalyzingText = "\n"..traitIsAnalyzingText
                      end                      
                    end
                    if traitLearnedByText ~= "" then
                      traitLearnedByText = GetString(SI_DEG_TRAIT_LEARNED_BY)..": "..traitLearnedByText
                      if traitNeededText ~= "" or traitIsAnalyzingText ~= "" then
                        traitLearnedByText = "\n"..traitLearnedByText
                      end                      
                    end
                    
                    if traitIsAnalyzingText ~= "" and traitNeededText == "" then
                      thisControlResearch:SetColor(100/255,175/255,255/255,1*255/255)
                    end
                    self:addTextTooltip(thisControlResearch, traitNeededText..traitIsAnalyzingText..traitLearnedByText)
                  else
                    --keiner möchte den Trait, lasse keine farbe              
                    self:addTextTooltip(thisControlResearch, GetString(SI_DEG_TRAIT_NEED_NOT))
                  end
                end              
                
                
              else
                --keine rüstung und keine armor kein schmuck              
              end
            --end
          end
        end
      end
          
    --VERSORGEN------------------------------------------------------------------------------------------
    elseif itemType == ITEMTYPE_INGREDIENT or itemType == ITEMTYPE_FOOD or itemType == ITEMTYPE_DRINK
    or itemType == ITEMTYPE_SPICE or itemType == ITEMTYPE_FLAVORING then
      thisControlIcon:SetTexture([[esoui/art/icons/servicemappins/servicepin_inn.dds]])
      
      
      thisControlIcon:SetWidth(18)
      thisControlIcon:SetHeight(18)

      thisControlIcon:SetHidden(false)
      
      
      thisControlIcon:SetAlpha(0.75)
      if itemType == ITEMTYPE_FOOD then        
        thisControlIcon:SetColor(255 / 255, 159 / 255, 107 / 255, 255 / 255)
        thisControlIcon:SetAlpha(0.55)
      elseif itemType == ITEMTYPE_DRINK then        
        thisControlIcon:SetColor(82 / 255, 116 / 255, 154 / 255, 255 / 255)
        thisControlIcon:SetAlpha(0.85)
      end
    
    --INGREDIENT/ALCHEMY------------------------------------------------------------------------------------------
    elseif itemType == ITEMTYPE_REAGENT or itemType == ITEMTYPE_POTION_BASE or itemType == ITEMTYPE_POISON_BASE then
      thisControlIcon:SetTexture([[esoui/art/icons/servicemappins/servicepin_alchemy.dds]])
      thisControlIcon:SetHidden(false)      
      
    --MATERIAL------------------------------------------------------------------------------------------
    elseif itemType == ITEMTYPE_RAW_MATERIAL or itemType == ITEMTYPE_STYLE_MATERIAL or itemType == ITEMTYPE_WEAPON_TRAIT or itemType == ITEMTYPE_ARMOR_TRAIT 
      or itemType == ITEMTYPE_BLACKSMITHING_MATERIAL or itemType == ITEMTYPE_BLACKSMITHING_RAW_MATERIAL or itemType == ITEMTYPE_BLACKSMITHING_BOOSTER
      or itemType == ITEMTYPE_WOODWORKING_MATERIAL or itemType == ITEMTYPE_WOODWORKING_RAW_MATERIAL or itemType == ITEMTYPE_WOODWORKING_BOOSTER
      or itemType == ITEMTYPE_CLOTHIER_MATERIAL or itemType == ITEMTYPE_CLOTHIER_RAW_MATERIAL or itemType == ITEMTYPE_CLOTHIER_BOOSTER
      or itemType == ITEMTYPE_ARMOR_BOOSTER
    then
      thisControlIcon:SetTexture([[esoui/art/icons/servicemappins/servicepin_smithy.dds]])
      thisControlIcon:SetHidden(false)
      
      if itemType == ITEMTYPE_WOODWORKING_MATERIAL or itemType == ITEMTYPE_WOODWORKING_RAW_MATERIAL or itemType == ITEMTYPE_WOODWORKING_BOOSTER then
        thisControlIcon:SetTexture([[esoui/art/icons/servicemappins/servicepin_woodworking.dds]])
      elseif itemType == ITEMTYPE_CLOTHIER_MATERIAL or itemType == ITEMTYPE_CLOTHIER_RAW_MATERIAL or itemType == ITEMTYPE_CLOTHIER_BOOSTER then
        thisControlIcon:SetTexture([[esoui/art/icons/servicemappins/servicepin_clothier.dds]])
        thisControlIcon:SetWidth(17)
        thisControlIcon:SetHeight(17)
      elseif itemType == ITEMTYPE_STYLE_MATERIAL then
        thisControlIcon:SetTexture([[esoui/art/inventory/inventory_tabIcon_Craftbag_styleMaterial_up.dds]])
        thisControlIcon:SetWidth(dimBigger22)
        thisControlIcon:SetHeight(dimBigger22)
        thisControlIcon:SetColor(1,1,1,0.50)
      elseif itemType == ITEMTYPE_WEAPON_TRAIT or itemType == ITEMTYPE_ARMOR_TRAIT then
        thisControlIcon:SetTexture([[esoui/art/inventory/inventory_tabIcon_Craftbag_itemtrait_up.dds]])
        thisControlIcon:SetWidth(dimBigger222)
        thisControlIcon:SetHeight(dimBigger222)
        thisControlIcon:SetColor(1,1,1,0.50)
      end
      
      if itemType == ITEMTYPE_BLACKSMITHING_BOOSTER or itemType == ITEMTYPE_WOODWORKING_BOOSTER or itemType == ITEMTYPE_CLOTHIER_BOOSTER then
        thisControlIcon:SetColor(225 / 255, 255 / 255, 200 / 255, 255 / 255)
      end
         
    --FURNISHING------------------------------------------------------------------------------------------
    elseif itemType == ITEMTYPE_FURNISHING or itemType == ITEMTYPE_FURNISHING_MATERIAL 
    then
      thisControlIcon:SetTexture([[esoui/art/treeicons/collection_indexicon_furnishings_up.dds]])
      thisControlIcon:SetHidden(false)
      thisControlIcon:SetWidth(thisControlIcon:GetWidth() + 6)
      thisControlIcon:SetHeight(thisControlIcon:GetHeight() + 6)
          
    --ENCHANTING/SOULS------------------------------------------------------------------------------------------
    elseif itemType == ITEMTYPE_ENCHANTING_RUNE_ASPECT or itemType == ITEMTYPE_ENCHANTING_RUNE_ESSENCE or itemType == ITEMTYPE_ENCHANTING_RUNE_POTENCY 
      or itemType == ITEMTYPE_GLYPH_ARMOR or itemType == ITEMTYPE_GLYPH_JEWELRY or itemType == ITEMTYPE_GLYPH_WEAPON
      or itemType == ITEMTYPE_SOUL_GEM
      or itemType == ITEMTYPE_ENCHANTMENT_BOOSTER
    then
      thisControlIcon:SetTexture([[esoui/art/icons/soulgem_001_filled.dds]])
      thisControlIcon:SetHidden(false)

    --RECIPE--
    elseif itemType == ITEMTYPE_RECIPE then      
      thisControlIcon:SetTexture([[esoui/art/icons/housing_bre_inc_scroll_open001.dds]])
      thisControlIcon:SetHidden(false)
      
      local knowledgeType = "Provisioning"
      --local textureNeeded = [[esoui/art/icons/master_writ_provisioning.dds]]
      local textureNeeded = [[esoui/art/icons/master_writ_enchanting.dds]]
      
      if specializedItemType == SPECIALIZED_ITEMTYPE_RECIPE_ALCHEMY_FORMULA_FURNISHING then
        knowledgeType = "Alchemy"
        --textureNeeded = [[esoui/art/icons/master_writ_alchemy.dds]]        
        textureNeeded = [[esoui/art/icons/master_writ_enchanting.dds]]        
      elseif specializedItemType == SPECIALIZED_ITEMTYPE_RECIPE_BLACKSMITHING_DIAGRAM_FURNISHING then
        knowledgeType = "Blacksmithing"
        --textureNeeded = [[esoui/art/icons/master_writ_blacksmithing.dds]]
        textureNeeded = [[esoui/art/icons/master_writ_enchanting.dds]]
      elseif specializedItemType == SPECIALIZED_ITEMTYPE_RECIPE_CLOTHIER_PATTERN_FURNISHING then
        knowledgeType = "Clothier"
        --textureNeeded = [[esoui/art/icons/master_writ_clothier.dds]]
        textureNeeded = [[esoui/art/icons/master_writ_enchanting.dds]]
      elseif specializedItemType == SPECIALIZED_ITEMTYPE_RECIPE_ENCHANTING_SCHEMATIC_FURNISHING then
        knowledgeType = "Enchanting"
        --textureNeeded = [[esoui/art/icons/master_writ_enchanting.dds]]
        textureNeeded = [[esoui/art/icons/master_writ_enchanting.dds]]
      elseif specializedItemType == SPECIALIZED_ITEMTYPE_RECIPE_WOODWORKING_BLUEPRINT_FURNISHING then
        knowledgeType = "Woodworking"
        --textureNeeded = [[esoui/art/icons/master_writ_woodworking.dds]]
        textureNeeded = [[esoui/art/icons/master_writ_enchanting.dds]]
      end
                  
      if Addon:wantsKnowledge(knowledgeType) and not Addon:hasItemKnowledge(knowledgeType, itemId) then
        thisControlIcon:SetTexture(textureNeeded)
        self:addTextTooltip(thisControl, GetString(SI_DEG_NEED_BY)..": "..Addon:getNeededByCharsString(knowledgeType, itemId, GetCurrentCharacterId()))
        thisControlIcon:SetWidth(dimBigger0)
        thisControlIcon:SetHeight(dimBigger0)
      elseif Addon:othersWantAndNeedItemKnowledge(knowledgeType, itemId) then
        thisControlIcon:SetTexture([[esoui/art/icons/housing_bre_inc_scroll_closed001.dds]])
        self:addTextTooltip(thisControl, GetString(SI_DEG_NEED_BY)..": "..Addon:getNeededByCharsString(knowledgeType, itemId))        
      else
        self:addTextTooltip(thisControl, GetString(SI_DEG_NEED_NOT)..".")
        thisControlIcon:SetWidth(17)
        thisControlIcon:SetHeight(17)                
      end      
      
    --MOTIF--
    elseif itemType == ITEMTYPE_RACIAL_STYLE_MOTIF then
      local knowledgeType = "Styles"
      thisControlIcon:SetTexture([[esoui/art/icons/housing_bre_inc_scroll_open001.dds]])
      thisControlIcon:SetHidden(false)
                  
      if Addon:wantsKnowledge(knowledgeType) and not Addon:hasItemKnowledge(knowledgeType, itemId) then
        thisControlIcon:SetTexture([[esoui/art/icons/master_writ_enchanting.dds]])
        self:addTextTooltip(thisControl, GetString(SI_DEG_NEED_BY)..": "..Addon:getNeededByCharsString(knowledgeType, itemId, GetCurrentCharacterId()))
        thisControlIcon:SetWidth(dimBigger0)
        thisControlIcon:SetHeight(dimBigger0)        
      elseif Addon:othersWantAndNeedItemKnowledge(knowledgeType, itemId) then
        thisControlIcon:SetTexture([[esoui/art/icons/housing_bre_inc_scroll_closed001.dds]])
        self:addTextTooltip(thisControl, GetString(SI_DEG_NEED_BY)..": "..Addon:getNeededByCharsString(knowledgeType, itemId))
      else
        self:addTextTooltip(thisControl, GetString(SI_DEG_NEED_NOT)..".")
        thisControlIcon:SetWidth(17)
        thisControlIcon:SetHeight(17)        
      end      
      
    --POTION -----------------------------------------------------------------------------------------
    elseif itemType == ITEMTYPE_POTION then
      thisControlIcon:SetTexture([[esoui/art/icons/consumable_potion_028_type_001.dds]])
      thisControlIcon:SetHidden(false)
    
    --POISON ------------------------------------------------------------------------------------------
    elseif itemType == ITEMTYPE_POISON then
      thisControlIcon:SetTexture([[esoui/art/icons/consumable_potion_028_type_001.dds]])
      thisControlIcon:SetColor(100 / 255, 215 / 255, 0 / 255, 255 / 255)
      thisControlIcon:SetHidden(false)
        
    --TRASH------------------------------------------------------------------------------------------
    elseif itemType == ITEMTYPE_TRASH
    then
      thisControlIcon:SetTexture([[esoui/art/inventory/inventory_tabicon_junk_up.dds]])
      thisControlIcon:SetHidden(false)  
    
    --TREASURE------------------------------------------------------------------------------------------ 
    elseif itemType == ITEMTYPE_TREASURE
    then
      thisControlIcon:SetTexture([[esoui/art/inventory/inventory_tabicon_junk_up.dds]])
      thisControlIcon:SetHidden(false)
      thisControlIcon:SetColor(255,0,0,200)          
      
    --CONTAINER------------------------------------------------------------------------------------------ 
    elseif itemType == ITEMTYPE_CONTAINER
    then
      thisControlIcon:SetTexture([[esoui/art/icons/quest_container_001.dds]])
      thisControlIcon:SetHidden(false)
        
    --SIEGE------------------------------------------------------------------------------------------ 
    elseif itemType == ITEMTYPE_SIEGE
    then
      thisControlIcon:SetTexture([[esoui/art/icons/ava_siege_weapon_002.dds]])
--esoui/art/icons/ava_siege_weapon_001.dds
--esoui/art/icons/ava_siege_weapon_002.dds
--esoui/art/icons/ava_siege_weapon_003.dds
--esoui/art/icons/ava_siege_weapon_004.dds
--esoui/art/icons/ava_siege_weapon_005.dds
--esoui/art/icons/ava_siege_weapon_006.dds      
      thisControlIcon:SetHidden(false)
     
    --FISH,LURE------------------------------------------------------------------------------------------ 
    elseif itemType == ITEMTYPE_LURE or itemType == ITEMTYPE_FISH
    then
      thisControlIcon:SetTexture([[esoui/art/icons/crafting_fishing_perch.dds]])
      thisControlIcon:SetHidden(false)            
             
    --TOOL------------------------------------------------------------------------------------------ 
    elseif itemType == ITEMTYPE_LURE or itemType == ITEMTYPE_TOOL or itemType == ITEMTYPE_AVA_REPAIR or itemType == ITEMTYPE_CROWN_REPAIR
    then
      thisControlIcon:SetTexture([[esoui/art/icons/lockpick.dds]])
      thisControlIcon:SetHidden(false)
    
    --CROWN------------------------------------------------------------------------------------------ 
    elseif itemType == ITEMTYPE_CROWN_ITEM
    then
      thisControlIcon:SetTexture([[EsoUI/Art/MainMenu/menuBar_market_up.dds]])
      thisControlIcon:SetHidden(false)
      thisControlIcon:SetWidth(26)
      thisControlIcon:SetHeight(26)
    
    --TROPHY------------------------------------------------------------------------------------------ 
    elseif itemType == ITEMTYPE_TROPHY
    then
      thisControlIcon:SetTexture([[/esoui/art/treeicons/store_indexicon_trophy_down.dds]])
      thisControlIcon:SetHidden(false)
    
    --COLLECTIBLE------------------------------------------------------------------------------------------ 
    elseif itemType == ITEMTYPE_COLLECTIBLE
    then
      thisControlIcon:SetColor(125 / 255, 125 / 255, 125 / 255, 255 / 255)
      thisControlIcon:SetTexture([[/esoui/art/treeicons/store_indexicon_trophy_down.dds]])
      thisControlIcon:SetHidden(false)
      
    --COSTUME--------------------------------------------------------------------------------------------
    elseif itemType == ITEMTYPE_TABARD or itemType == ITEMTYPE_COSTUME or itemType == ITEMTYPE_DISGUISE then
      thisControlIcon:SetTexture([[esoui/art/icons/costume_bloodthorndisguise.dds]])
      thisControlIcon:SetHidden(false)
    end   
    
    if not doIcons and not doKnow then
      thisControlIcon:SetHidden(true)
    elseif not doIcons then 
      if itemType == ITEMTYPE_RECIPE or itemType == ITEMTYPE_RACIAL_STYLE_MOTIF then
      
      else
        thisControlIcon:SetHidden(true)
      end
    elseif not doKnow then
      if itemType == ITEMTYPE_RECIPE or itemType == ITEMTYPE_RACIAL_STYLE_MOTIF then
        thisControlIcon:SetHidden(true)
      end
    end   
  end
end

function Obj:setupItemControls(parentControl, slot, isGrid)
  
  local Addon = _G[DEG_ADDON.PACKAGE_NAME].plugins[DEG_ADDON.ADDON_NAME_SHORT]
  
  local thisControlName = parentControl:GetName().."DEGInv"
  local thisControlIconName = parentControl:GetName().."DEGInvIcon"
  local thisControlResearchName = parentControl:GetName().."DEGInvResearch"
  local thisControl, thisControlIcon, thisControlResearch, vanillaNameControl, vanillaIconControl, vanillaPriceControl, statValueControl, vanillaTraiInfoControl

  for i = 1, parentControl:GetNumChildren() do
    local theTempControl = parentControl:GetChild(i)
    if theTempControl and type(theTempControl) == "userdata" and theTempControl.GetName then 
      if theTempControl:GetName() == parentControl:GetName().."Name" then
        vanillaNameControl = theTempControl
      elseif theTempControl:GetName() == parentControl:GetName().."Button" then
        vanillaIconControl = theTempControl
      elseif theTempControl:GetName() == parentControl:GetName().."SellPrice" then
        vanillaPriceControl = theTempControl
      elseif theTempControl:GetName() == parentControl:GetName().."StatValue" then
        statValueControl = theTempControl                
    elseif theTempControl:GetName() == parentControl:GetName().."TraitInfo" then
    vanillaTraiInfoControl = theTempControl
      elseif theTempControl:GetName() == thisControlName then
        thisControl = theTempControl
      end      
    end
  end
            
  if not thisControl and vanillaNameControl and vanillaIconControl then
    thisControl = WINDOW_MANAGER:CreateControl(thisControlName, parentControl, CT_CONTROL)
    local thisControlWidth = vanillaNameControl:GetLeft() - vanillaIconControl:GetRight()    
    thisControl:SetDrawTier(DT_HIGH)
    --thisControl:SetDrawLevel(vanillaStatusControl:GetDrawLevel() + 1)
    thisControl:ClearAnchors()
    thisControl:SetAnchor(TOP, parentControl, TOP)
    thisControl:SetAnchor(LEFT, vanillaNameControl, LEFT, thisControlWidth * -1)
    thisControl:SetHeight(parentControl:GetHeight())
    thisControl:SetWidth(thisControlWidth)
    --thisControl:SetHidden(false)        
    --@todo in deconstruct panel the width is all taken by the icon
    --=> textureSize
    
    thisControlIcon = WINDOW_MANAGER:CreateControl(thisControlIconName, thisControl, CT_TEXTURE)
    thisControlIcon:ClearAnchors()
    thisControlIcon:SetAnchor(CENTER, thisControl, CENTER, 0, 0)
    
    local r,g,b,a = thisControlIcon:GetColor()    
    thisControlIcon.degOriginalColorR = r
    thisControlIcon.degOriginalColorG = g
    thisControlIcon.degOriginalColorB = b
    thisControlIcon.degOriginalColorA = a    
    thisControlIcon.degOriginalTexture = thisControlIcon:GetTextureFileName()    
    
    thisControlResearch = WINDOW_MANAGER:CreateControl(thisControlResearchName, thisControl, CT_TEXTURE)
    thisControlResearch:ClearAnchors()
    --thisControlResearch:SetAnchor(CENTER, thisControlIcon, CENTER, 0, 0)        
        
    local r,g,b,a = thisControlResearch:GetColor()
    thisControlResearch.origR = r
    thisControlResearch.origG = g
    thisControlResearch.origB = b        
    thisControlResearch.origA = a
         
    thisControlResearch:SetWidth(32)
    thisControlResearch:SetHeight(32)    
    --ist das research assistant icon anwesend?
    
    
  if vanillaTraiInfoControl then
    thisControlResearch:SetAnchor(LEFT, vanillaTraiInfoControl, RIGHT, 0, 0)
  else  
    if Addon.vars.researchAssistantLoaded then
      if statValueControl then
      thisControlResearch:SetAnchor(RIGHT, statValueControl, LEFT, 20, 0)
      else
      thisControlResearch:SetAnchor(LEFT, vanillaNameControl, RIGHT, 0, 0)
      end    
    else
      if statValueControl then
      thisControlResearch:SetAnchor(LEFT, statValueControl, RIGHT, 10, 0)
      else
      if vanillaPriceControl then
        thisControlResearch:SetAnchor(RIGHT, vanillaPriceControl, LEFT, 0, 0)
      else
        thisControlResearch:SetAnchor(LEFT, vanillaNameControl, RIGHT, 0, 0)
      end        
      end    
    end
    end 
      
    thisControlResearch:SetAlpha(0.80)
    thisControlResearch:SetTexture([[esoui/art/inventory/inventory_tabIcon_Craftbag_itemtrait_up.dds]])
       
    local r,g,b,a = thisControlResearch:GetColor()    
    thisControlResearch.degOriginalColorR = r
    thisControlResearch.degOriginalColorG = g
    thisControlResearch.degOriginalColorB = b
    thisControlResearch.degOriginalColorA = a    
    thisControlResearch.degOriginalTexture = thisControlResearch:GetTextureFileName()    
  end
  
  thisControlIcon = thisControl:GetChild(1)
  thisControlResearch = thisControl:GetChild(2)  
        
  local textureSize = 18
  
  thisControlIcon:SetDimensions(textureSize, textureSize)
  thisControlIcon:SetColor(thisControlIcon.degOriginalColorR, thisControlIcon.degOriginalColorG, thisControlIcon.degOriginalColorB, thisControlIcon.degOriginalColorA)
  thisControlIcon:SetTexture(thisControlIcon.degOriginalTexture)
        
  return thisControl, thisControlIcon, thisControlResearch
end

_G[_G["DEG_CURRENT_ADDON"].ADDON_NAME.."Paint"] = Obj