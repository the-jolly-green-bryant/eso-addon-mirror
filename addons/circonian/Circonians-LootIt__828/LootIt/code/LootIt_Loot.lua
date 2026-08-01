
-- Holds the controls yet to be displayed
-- Including items found, xp gains, exc...
local tMainDisplayTable = {}

-- Translation factors, used to calculate translation direction +/- for right/left, down/up
local TRANSLATE_Y_UP = -1
local TRANSLATE_Y_DOWN = 1
local TRANSLATE_Y_NONE = 0

local TRANSLATE_X_LEFT = -1
local TRANSLATE_X_RIGHT = 1
local TRANSLATE_X_NONE = 0

local tFonts = {
	Bold 				= "BOLD_FONT",
	Chat 				= "CHAT_FONT",
	Antique 			= "ANTIQUE_FONT",
	Handwritten 		= "HANDWRITTEN_FONT",
	["Stone Tablet"] 	= "STONE_TABLET_FONT",
}

-- After copying items (in shallowcopy) from tMainDisplayTable, remove them from tMainDisplayTable
-- They've already been gathered into a separate table to be prepared for display
local function CleanLootItemTable(_tLoot)
	-- Loop through the (possibly partial) copy of the tMainDisplayTable
	for k,v in pairs(_tLoot) do
		-- and the real loot table
		for k2, v2 in pairs (tMainDisplayTable) do
			-- see if the keys match, these are ZO_Pool table keys so they are unique
			-- if the keys match I already copied this loot item to be displayed, remove it
			-- from the main loot table.
			if v.key == v2.key then
				table.remove(tMainDisplayTable, k2)
			end
		end
	end
end

-- Used to copy the loot items in the main loot table.
--[[ I had trouble figuring out how to group a set of loot together
-- display it, & remove it from the table..without loosing loot...I.E. Due to this possibly
-- being called multiple times in quick succession due to looting multiple bodies some loot was mysteriously 
-- not getting displayed because it got deleted before it was shown or displayed twice. I decided to
-- Copy the loot from the tMainDisplayTable, then delete that loot from the tMainDisplayTable
-- and then continue on with the displaying loot, using my copy, this prevents any loot
-- from being displayed twice or slipping through the cracks & getting wiped before it is displayed.
--]]
local function shallowcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = orig_value
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

--[[ Main function for displaying loot. Creates a copy of the items that are currently
in the tMainDisplayTable to be displayed, then calls a func to wipe them from the tMainDisplayTable,
calls a func to get window positions, sorts by window position, then loops through them and calls the
animate function on each item to display it. 
--]] 
local function DisplayLoot()
	if #tMainDisplayTable == 0 then return end
	
	local tLoot = shallowcopy(tMainDisplayTable)
	CleanLootItemTable(tLoot)
	
	tLoot = LootIt.GetWindowPositions(tLoot)
	
	-- Need to sort descending so the highest position gets animated first
	table.sort(tLoot, 
		function(a, b)
			if a.position > b.position then 
				return true
			end
		end)
		

	-- lootCounter is used so I know when to fade the item into vision, so they fade in 1 at a time
	local lootCounter = 0
	local row = 0
	for k,v in ipairs(tLoot) do
		lootCounter = lootCounter + 1
		v.displayed = true
		v.displayed = true
		v.lootCounter = lootCounter
		LootIt.Animate(v)
	end
end

--[[ Translation factors are used when calculating the translation offsets, by multiplying by
the offset by +1 the offset value will be positive and translate right or down, if the translation
factor is -1 the offset will become negative & translate left or up, if its 0 it will not
translate on that axis
--]]
local function GetTranslationFactors()
	local lootDir = LootIt.SavedVariables["LOOTDIRECTION"]
	local xFactor = TRANSLATE_X_NONE
	local yFactor = TRANSLATE_Y_NONE
	
	if lootDir == "Left" then
		xFactor = TRANSLATE_X_LEFT
		yFactor = TRANSLATE_Y_NONE
	elseif lootDir == "Right" then
		xFactor = TRANSLATE_X_RIGHT
		yFactor = TRANSLATE_Y_NONE
	elseif lootDir == "Down" then
		xFactor = TRANSLATE_X_NONE
		yFactor = TRANSLATE_Y_DOWN
	else
		xFactor = TRANSLATE_X_NONE
		yFactor = TRANSLATE_Y_UP
	end
	return xFactor, yFactor
end

--[[ Setup the control to be displayed 
position represents the controls position on the screen, 2 would be the second item Up, Down, Left, Right
(not the order they are displayed in). This tells me how far to translate the controls to get them into
position.
lootCounter tells me how long to wait before fading in a control. This is so they do not all appear
at the same time at the starting anchor point on top of each other...although there is some overlap because
they fade in a little quicker than they translate, but thats ok I wanted it like that so when one control
starts to translate you see the next control that will translate, then the next. If they all faded in at once
and took turns translating there would be no guarantee to the order to which control you would see next when
one starts to translate.
--]]
function LootIt.SetUpControl(labelText, sIcon)
	-- get a new loot item window from the ZO_ControlPool --
	local cCntrl, iKey = LootIt.LootPool:AcquireObject()
	cCntrl:GetNamedChild("Texture"):SetTexture(sIcon)
	cCntrl:GetNamedChild("Label"):SetText(labelText)
	cCntrl:ClearAnchors()
	cCntrl:SetAnchor(BOTTOMLEFT, LootIt.LootWindow, BOTTOMLEFT, 0, 0)
	
	
	local winWidth = LootIt.SavedVariables["LOOTWINDOWWIDTH"]
	local winHeight = LootIt.SavedVariables["LOOTWINDOWHEIGHT"]
	local fontSize = LootIt.SavedVariables["FONTSIZE"]
	local font = tFonts[LootIt.SavedVariables["FONT"]]
	local labelWidth = winWidth - winHeight - 10 -- 10 for padding
	
	local font = "$("..font..")|"..fontSize
	
	cCntrl:SetDimensions(winWidth, winHeight)
	cCntrl:GetNamedChild("Label"):SetFont(font)
	cCntrl:GetNamedChild("Label"):SetDimensions(labelWidth, winHeight)
	cCntrl:GetNamedChild("TextureBG"):SetDimensions(winHeight, winHeight)
	cCntrl:GetNamedChild("Texture"):SetDimensions(winHeight-8, winHeight-8)
	
	
	local xFactor, yFactor = GetTranslationFactors()
	
	local itemData = { 
		control 		= cCntrl,
		key 			= iKey,
		position 		= nil,
		lootCounter 	= nil,
		displayed 		= false,
		windowWidth		= winWidth,
		windowHeight	= winHeight,
		winXFactor		= xFactor,
		winYFactor		= yFactor,
	}
	-- Insert the data into the main display table, so this entire set of loot
	-- can be grouped & displayed together later.
	table.insert(tMainDisplayTable, itemData)
	-- Delay a call on DisplayLoot() so all of the current set/group of loot can be gathered
	-- up and displayed together later.
	zo_callLater(function() DisplayLoot() end, 300)
end


function LootIt.ShowLootWindow(_bShowLootWindow)
	LootIt.LootWindowBg:SetHidden(not _bShowLootWindow)
	LootIt.LootWindow:SetMovable(_bShowLootWindow)
	LootIt.LootWindow:SetMouseEnabled(_bShowLootWindow)
end


function LootIt.SetSavedAnchorLootWindow()
	LootIt.LootWindow:ClearAnchors()
	LootIt.LootWindow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, LootIt.SavedVariables["LOOTWINDOWOFFSETX"], LootIt.SavedVariables["LOOTWINDOWOFFSETY"])
	LootIt.LootWindowBg:SetHidden(not LootIt.SavedVariables["SHOWLOOTWINDOW"])
end
