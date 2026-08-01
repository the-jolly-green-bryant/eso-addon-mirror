ThemeUI ={
    name = "ThemeUI",
    author = "KA3ZUS",
    menuName = "Theme UI",
    taglist = {},

}

ThemeUI.CurrenciesNames = {-- Here is how you will reference the current currencies names in the code. A function should replace this later.
    goldLower = "pugs", --ThemeUI.CurrenciesNames.goldLower
    goldUpper = "Pugs", --ThemeUI.CurrenciesNames.goldUpper
    versionNumber = 4, -- ThemeUI.CurrenciesNames.versionNumber
}

--Declaring variables
local Pug_Name = "Pug"
local CURT_MONEY = 1

--Other addons that this addon will change
PITHKA = PITHKA or {}

-- This change the label name of the gold currency in the inventory at the bottom
ZO_CURRENCIES_DATA[CURT_MONEY].amountLabel = Pug_Name

--This change the "Send gold" field in the mail window
ZO_MailSendAttachMoneyLabel:SetText("Send "..ThemeUI.CurrenciesNames.goldUpper.."")
--Options_Gameplay_DefaultSoulGemDropdownDropdownScroll1Row1Label:SetText("test12")


--The followings are all functions used to dynamically create, then use a TextureList that take textures from XXXPath files and redirect them in the game.

function ThemeUI:cleartaglist() --This function erase the conten of the taglist so a new one can be made
    for k,v in pairs(self.taglist) do
        self.taglist[k] = nil
    end
end

function ThemeUI:tablelength(Table)-- This function iterate through a table and count how many elements are inside and then returns that number
    local count = 0
    for _ in pairs(Table) do count = count + 1 end
    return count
end

function ThemeUI:isTrueTag(Table)-- This function take a table as a parameter and return true only if all elements inside the table are of type "string" and that there is at least 1 element inside the table
    local typo = type(Table)
    if typo == "table" then
        for k,v in pairs(Table) do
            local typo = type(Table[k])
            if typo ~= "string" and self:tablelength(Table) > 0 then
                return false
            end
        end
        return true
    end
    return false
end

function ThemeUI:makeTagList(Table, currentPath)--This function will loop through a table return taglist, a table that will be used to create the final TextureList
    currentPath = currentPath or ""
    for k,v in pairs(Table) do
        local newPath = currentPath.."."..k
        if self:isTrueTag(Table[k]) then
            table.insert(self.taglist,newPath)
        elseif type(v) == "table" then
            self:makeTagList(v, newPath)
        else
        end
    end
end

function ThemeUI:accessNestedTable(path, mode) --path is a string of the path to the texture that is identicale for every texturepath file. mode = texturepath file ex: PugPath or EsoPath
    local currentTable = self
    local fpath = mode..path
    for segment in fpath:gmatch("[^.]+") do
        currentTable = currentTable[segment]
        --Check if the current segment exists as a string
        if type(currentTable) == "string" then
            return currentTable -- Return nil if the segment is not a string
        end
    end
    return currentTable
end

function ThemeUI:MakeList(OldTextureTable, NewTextureTable) --Old and NewTextureTable must be the name of the file containing the tags and textures path --> ex: "PugPath" because PugPath.lua
    self:cleartaglist()
    self:makeTagList(self[NewTextureTable])
    self.TextureList = {}
    local taglist = self.taglist
    for k,v in pairs(taglist) do
        local new1 = self:accessNestedTable(taglist[k], NewTextureTable)
        local old1 = self:accessNestedTable(taglist[k], OldTextureTable)
        table.insert(self.TextureList,{old = old1, new = new1})
    end
end

function ThemeUI:TextureReplacerMain(Table)--This function work, just replace the d("j'applique la fonction") by the function you want to execute **WARNING** This function works if multiples old textures are replaced by a new one, but only one.
    for k,v in pairs(Table) do
        if (k == "old") or (k == "new") then
            for k,v in pairs(Table.old) do
                RedirectTexture(Table.old[k], Table.new[1])
            end
            return
        else
            self:TextureReplacerMain(Table[k])
        end
    end

end

function ThemeUI:Initialize()
    ThemeUI:MakeList("EsoPath", "PugPath")
    ThemeUI:TextureReplacerMain(ThemeUI.TextureList)
end

local original_GetCurrencyName = GetCurrencyName-- It's that code that makes it that the currency is called pug in bank and in loot history
function GetCurrencyName(curt, isPlural, isUpper)
	local currencyName = original_GetCurrencyName(curt, isPlural, isUpper)
	
	if curt == CURT_MONEY then
		currencyName = Pug_Name
	end
	return currencyName
end

local function OnAddonLoaded(event, addonName)
    if addonName == ThemeUI.name then
        ThemeUI.Initialize()
        if BUI_PlayerFrame_Orn1 ~= nil then 
            BUI_PlayerFrame_Orn1:SetTexture("ThemeUI/textures/Pug1b_256px.dds")
        end
        if PithkaAchievementTracker then
            PITHKA.UI.Constants.texture.CHECK = "ThemeUI/textures/Pug_face_simple.dds"
		    PITHKA.UI.Constants.rgbGreen = {1,1,1,.9}
        end
    end
end


EVENT_MANAGER:RegisterForEvent(ThemeUI.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)

