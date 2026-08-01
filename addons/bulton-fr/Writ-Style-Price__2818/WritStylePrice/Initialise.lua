WritStylePrice = {}

WritStylePrice.name           = "Writ Style Price"
WritStylePrice.dirName        = "WritStylePrice"
WritStylePrice.async          = nil
WritStylePrice.LAM            = LibAddonMenu2
WritStylePrice.savedVariables = nil
WritStylePrice.ready          = false
WritStylePrice.charactersMap  = {}

--[[
-- Addon initialiser
--]]
function WritStylePrice:Initialise()
    WritStylePrice.async = LibAsync:Create('WritStylePriceAsync')

    WritStylePrice.savedVariables = ZO_SavedVars:NewAccountWide("WritStylePriceSavedVariables", 1, nil, {})

    if WritStylePrice.savedVariables.gui == nil then
        WritStylePrice.savedVariables.gui = {}
    end
    if WritStylePrice.savedVariables.price == nil then
        WritStylePrice.savedVariables.price = {}
    end
    if WritStylePrice.savedVariables.collect == nil then
        WritStylePrice.savedVariables.collect = {}
    end
    
    self:initCharactersMap()

    self.Collect:init()
    self.Price:init()
    self.Settings:init()
    self.GUI:init()

    WritStylePrice.ready = true
end

--[[
-- Generate the list of characters
--]]
function WritStylePrice:initCharactersMap()
    -- Extracted from Inventory Insight
    for i=1, GetNumCharacters() do
		local charName, _, _, _, _, _, charId, _ = GetCharacterInfo(i)
        charName = charName:sub(1, charName:find("%^") - 1)
        
        WritStylePrice.charactersMap[charId] = charName
	end
end
