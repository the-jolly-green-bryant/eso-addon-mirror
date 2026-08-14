local function PrintOutfitStylesForWeapon(weaponFilter)
    local numCategories = GetNumCollectibleCategories()
    d("numCategories")
    d(numCategories)
    for categoryIndex = 1, numCategories do
        local _, _, _, categoryType = GetCollectibleCategoryInfo(categoryIndex)
        d("categoryType")
        d(categoryType)
        if categoryType == COLLECTIBLE_CATEGORY_TYPE_OUTFIT_STYLE then
            local numSubcategories = GetNumCollectibleSubcategories(categoryIndex)
        d("numSubcategories")
        d(numSubcategories)
            for subIndex = 1, numSubcategories do
                local subName, numCollectibles = GetCollectibleSubcategoryInfo(categoryIndex, subIndex)
        d("numCollectibles")
        d(numCollectibles)
                for collectibleIndex = 1, numCollectibles do
                    local collectibleId = GetCollectibleId(categoryIndex, subIndex, collectibleIndex)
                            d("collectibleId")
                            d(collectibleId)
                    if IsCollectibleUnlocked(collectibleId) then
                        local name = GetCollectibleName(collectibleId)
                        local visualType = GetOutfitStyleVisualData(collectibleId)

                            d("name")
                            d(name)
                            
                            d("visualType")
                            d(visualType)

                        if visualType == weaponFilter then
                            d(string.format("ID: %d - %s", collectibleId, name))
                        end
                    end
                end
            end
        end
    end
end

-- Slash command bindings
SLASH_COMMANDS["/axe"] = function()
    d("Unlocked Axe Outfit Styles:")
    PrintOutfitStylesForWeapon(OUTFIT_STYLE_VISUAL_CATEGORY_ONE_HANDED_AXE)
end

SLASH_COMMANDS["/shield"] = function()
    d("Unlocked Shield Outfit Styles:")
    PrintOutfitStylesForWeapon(OUTFIT_STYLE_VISUAL_CATEGORY_SHIELD)
end

SLASH_COMMANDS["/staves"] = function()
    d("Unlocked Staff Outfit Styles:")
    PrintOutfitStylesForWeapon(OUTFIT_STYLE_VISUAL_CATEGORY_STAFF)
end