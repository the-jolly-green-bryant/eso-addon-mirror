-- PB's CraftMaterialAssistant -- the recipe side
--
-- Everything that knows what a "craftable item" is lives in this file. The window draws rows
-- and the panel sets numbers; neither of them knows that a row came from a recipe. That is
-- what makes smithing addable later: another producer of the same row shape.
--
-- PBS_CRAFT_MATERIAL_ASSISTANT is nil if Main.lua bailed out early (e.g. already loaded).
if not PBS_CRAFT_MATERIAL_ASSISTANT then
	return
end

local addon = PBS_CRAFT_MATERIAL_ASSISTANT
local recipes = addon.recipes

-- The client is Lua 5.1, where unpack is a global. Written this way so the same file also
-- runs under the 5.x the test harness is executed with, where it moved into table.
local unpack = unpack or table.unpack

-- ---------------------------------------------------------------------------------------
-- Is the client answering at all
--
-- Asked once and cached. A client without the recipe API is not a client that grows one
-- halfway through a session, and the question is asked on every redraw.
-- ---------------------------------------------------------------------------------------

function recipes:Available()
	if self.available == nil then
		self.available = (type(GetNumRecipeLists) == "function"
			and type(GetRecipeListInfo) == "function"
			and type(GetRecipeInfo) == "function"
			and type(GetRecipeIngredientItemInfo) == "function")
	end
	return self.available
end

-- Every call into the recipe API goes through here. An index that has gone out of range after
-- a patch is a real possibility -- saved variables outlive the recipe list they were written
-- against -- and it must read as "not found", never as a Lua error in somebody's chat window.
local function Safe(fn, ...)
	if type(fn) ~= "function" then
		return nil
	end
	local results = { pcall(fn, ...) }
	if not results[1] then
		return nil
	end
	return unpack(results, 2)
end

-- ---------------------------------------------------------------------------------------
-- Categories
--
-- The client's own recipe lists, which are what the crafting screen groups by. Their names
-- are already translated, so the category dropdown in the panel needs no strings of ours.
-- ---------------------------------------------------------------------------------------

function recipes:Categories()
	local categories = {}
	if not self:Available() then
		return categories
	end
	local count = Safe(GetNumRecipeLists) or 0
	for index = 1, count do
		local name, numRecipes = Safe(GetRecipeListInfo, index)
		if name and name ~= "" then
			categories[#categories + 1] = { index = index, name = name, count = numRecipes or 0 }
		end
	end
	return categories
end

function recipes:CategoryName(index)
	if (index or 0) < 1 then
		return GetString(SI_PBSCMA_CATEGORY_ALL)
	end
	local name = Safe(GetRecipeListInfo, index)
	return name or GetString(SI_PBSCMA_CATEGORY_ALL)
end

function addon:SetCategory(index)
	index = math.floor(tonumber(index) or -1)
	if index < 0 then
		return false
	end
	if index > 0 and not Safe(GetRecipeListInfo, index) then
		return false
	end
	self.sv.browse.category = index
	self:Search(self.sv.browse.text or "")
	return true
end

function addon:Category()
	return math.floor(tonumber(self.sv and self.sv.browse and self.sv.browse.category) or 0)
end

-- ---------------------------------------------------------------------------------------
-- Searching
--
-- No index is built and nothing is cached between searches. The catalogue is thousands of
-- entries, the client already holds every one of them, and a copy of it in add-on memory is a
-- copy in the 100 MB pool every add-on on a console shares. A search is a scan; a scan is a
-- few thousand reads of data already in memory, and it happens when somebody presses a
-- button rather than on a timer.
--
-- Matching is a plain case-insensitive substring. string.lower only folds ASCII, which is
-- exactly right here: on an English client "salmon" finds "Solitude Salmon-Millet", and on a
-- Japanese client the names are Japanese and are matched as typed, byte for byte, which is
-- what the on-screen keyboard produces anyway.
-- ---------------------------------------------------------------------------------------

local function Normalise(text)
	return tostring(text or ""):lower():gsub("^%s+", ""):gsub("%s+$", "")
end

function addon:Search(text)
	local needle = Normalise(text)
	self.sv.browse.text = needle
	self.matches = {}
	self.searched = true
	self.truncated = false
	-- A new result set means the old page number is about a list that no longer exists.
	self.sv.browse.page = 1

	if not self.recipes:Available() then
		return 0
	end

	local knownOnly = self.sv.knownOnly ~= false
	local category = self:Category()
	local limit = self.MAX_MATCHES
	local found = 0
	local full = false

	local listCount = Safe(GetNumRecipeLists) or 0
	for listIndex = 1, listCount do
		if not full and (category == 0 or category == listIndex) then
			local listName, numRecipes = Safe(GetRecipeListInfo, listIndex)
			numRecipes = numRecipes or 0
			for recipeIndex = 1, numRecipes do
				local known, name, numIngredients, _, _, _, _, resultItemId =
					Safe(GetRecipeInfo, listIndex, recipeIndex)
				if name and name ~= "" and (known or not knownOnly) then
					if needle == "" or name:lower():find(needle, 1, true) then
						found = found + 1
						self.matches[found] = {
							list = listIndex,
							recipe = recipeIndex,
							name = name,
							itemId = resultItemId or 0,
							ingredients = numIngredients or 0,
							known = known and true or false,
							category = listName or "",
						}
						if found >= limit then
							full = true
							self.truncated = true
							break
						end
					end
				end
			end
		end
	end

	return found
end

-- ---------------------------------------------------------------------------------------
-- Holding on to a pick across a patch
--
-- A recipe is addressed by two indices, and indices move: a chapter that adds thirty
-- furnishing plans to a list pushes everything below them down. The name and the result item
-- id are stored beside the indices for exactly this, and this is where the three are
-- reconciled.
--
--   indices still name the same recipe   -> nothing to do, the common case, one API call
--   they name a different one            -> the catalogue is scanned once for the result item
--                                           id, and the indices are rewritten
--   it is not there at all               -> left alone. Requirements() will answer nil and
--                                           the window will say the pick is gone, which is
--                                           better than silently drawing somebody else's
--                                           ingredients under the name you chose.
-- ---------------------------------------------------------------------------------------

function recipes:ResolveTarget()
	if not self:Available() or not addon:HasTarget() then
		return false
	end

	local target = addon.sv.target
	local known, name = Safe(GetRecipeInfo, target.list, target.recipe)
	if name and name ~= "" then
		if target.name == "" or name == target.name then
			target.name = name
			return true
		end
	end

	if (target.itemId or 0) <= 0 then
		return false
	end

	local listCount = Safe(GetNumRecipeLists) or 0
	for listIndex = 1, listCount do
		local _, numRecipes = Safe(GetRecipeListInfo, listIndex)
		for recipeIndex = 1, (numRecipes or 0) do
			local _, foundName, _, _, _, _, _, resultItemId =
				Safe(GetRecipeInfo, listIndex, recipeIndex)
			if resultItemId and resultItemId == target.itemId then
				target.list, target.recipe = listIndex, recipeIndex
				target.name = foundName or target.name
				return true
			end
		end
	end

	return false
end

-- ---------------------------------------------------------------------------------------
-- How many of a thing you are holding
--
-- GetItemLinkStacks is the whole of it: six numbers for one link, all of them already in the
-- client. Which of the six are added up is the scope setting.
--
-- GetItemLinkInventoryCount is the fallback, for a client where the first is missing. It
-- takes an option enum rather than returning everything, so the scopes map onto the closest
-- option the client defines and the house-bank scope quietly degrades to the craft-bag one --
-- degrading a count downwards is safe, a shopping list that overstates what you have is not.
--
-- Both missing answers nil, which the window draws as "?" rather than as a zero. A zero is a
-- claim.
-- ---------------------------------------------------------------------------------------

local FALLBACK_OPTION = {
	BACKPACK = "INVENTORY_COUNT_BAG_OPTION_BACKPACK",
	BANK = "INVENTORY_COUNT_BAG_OPTION_BACKPACK_AND_BANK",
	CRAFTBAG = "INVENTORY_COUNT_BAG_OPTION_BACKPACK_AND_BANK_AND_CRAFT_BAG",
	ALL = "INVENTORY_COUNT_BAG_OPTION_BACKPACK_AND_BANK_AND_CRAFT_BAG",
}

function recipes:CountForLink(link)
	if not link or link == "" then
		return nil
	end

	local scope = addon:Scope()

	if type(GetItemLinkStacks) == "function" then
		local backpack, bank, craftBag, houseBanks = Safe(GetItemLinkStacks, link)
		if backpack ~= nil then
			local total = backpack or 0
			if scope ~= "BACKPACK" then
				total = total + (bank or 0)
			end
			if scope == "CRAFTBAG" or scope == "ALL" then
				total = total + (craftBag or 0)
			end
			if scope == "ALL" then
				total = total + (houseBanks or 0)
			end
			return total
		end
	end

	if type(GetItemLinkInventoryCount) == "function" then
		local option = _G[FALLBACK_OPTION[scope] or ""]
		if option ~= nil then
			local count = Safe(GetItemLinkInventoryCount, link, option)
			if count ~= nil then
				return count
			end
		end
	end

	return nil
end

-- ---------------------------------------------------------------------------------------
-- The answer
--
-- One table, everything the window and the chat status both need, computed in one pass over
-- the ingredients. Called on every redraw, which is at most a few times a second and only
-- while something is picked.
--
-- "quantity" is the number of TIMES the recipe is made, not the number of items that come
-- out: a recipe that yields four drinks made three times is three sets of ingredients and
-- twelve drinks, and saying so is the only way the number on the slider means one thing.
-- ---------------------------------------------------------------------------------------

function recipes:Requirements()
	if not self:Available() or not addon:HasTarget() then
		return nil
	end

	local target = addon.sv.target
	local known, name, numIngredients = Safe(GetRecipeInfo, target.list, target.recipe)
	if not name or name == "" then
		return nil
	end
	numIngredients = numIngredients or 0

	local iterations = addon:Quantity()
	local rows = {}
	local shortCount = 0
	local unknownCount = 0
	-- How many times the recipe could be made with what is held. Starts at "no limit found
	-- yet" and is pulled down by each ingredient; an ingredient whose count could not be read
	-- leaves it alone and is reported separately, so the number is never a guess.
	local craftable = nil

	for index = 1, numIngredients do
		local ingredientName, _, requiredFromInfo = Safe(GetRecipeIngredientItemInfo,
			target.list, target.recipe, index)
		local required = Safe(GetRecipeIngredientRequiredQuantity, target.list, target.recipe, index)
			or requiredFromInfo or 0
		local link = Safe(GetRecipeIngredientItemLink, target.list, target.recipe, index,
			LINK_STYLE_DEFAULT)
		local have = self:CountForLink(link)
		local need = required * iterations

		local shortfall
		if have == nil then
			unknownCount = unknownCount + 1
		else
			shortfall = need - have
			if shortfall < 0 then
				shortfall = 0
			end
			if shortfall > 0 then
				shortCount = shortCount + 1
			end
			if required > 0 then
				local possible = math.floor(have / required)
				if craftable == nil or possible < craftable then
					craftable = possible
				end
			end
		end

		rows[index] = {
			name = ingredientName or "?",
			required = required,
			need = need,
			have = have,
			short = shortfall,
			link = link,
		}
	end

	local resultCount = Safe(GetRecipeResultQuantity, target.list, target.recipe, iterations)
	if not resultCount then
		local _, _, stack = Safe(GetRecipeResultItemInfo, target.list, target.recipe)
		resultCount = (stack or 1) * iterations
	end

	return {
		name = name,
		known = known and true or false,
		iterations = iterations,
		resultCount = resultCount,
		rows = rows,
		shortCount = shortCount,
		unknownCount = unknownCount,
		craftable = craftable,
	}
end

-- ---------------------------------------------------------------------------------------
-- The measurement
--
-- Every search is a full pass over the catalogue, and how much that costs on a console is the
-- one thing in this add-on that cannot be worked out on a laptop: it depends on how many
-- recipes that client knows about and how fast it answers. So it is measurable rather than
-- assumed -- /pbcraft probe does exactly one pass and reports what it counted and how long it
-- took, which is the number to bring back if searching ever feels slow.
-- ---------------------------------------------------------------------------------------

function recipes:Census()
	local lists, total, known = 0, 0, 0
	if not self:Available() then
		return 0, 0, 0
	end
	lists = Safe(GetNumRecipeLists) or 0
	for listIndex = 1, lists do
		local _, numRecipes = Safe(GetRecipeListInfo, listIndex)
		for recipeIndex = 1, (numRecipes or 0) do
			local isKnown, name = Safe(GetRecipeInfo, listIndex, recipeIndex)
			if name then
				total = total + 1
				if isKnown then
					known = known + 1
				end
			end
		end
	end
	return lists, total, known
end

-- The same answer, cut down to what a line of chat can carry.
function recipes:Summary()
	local requirements = self:Requirements()
	if not requirements then
		return nil
	end
	return {
		name = requirements.name,
		shortCount = requirements.shortCount,
		craftable = requirements.craftable or 0,
	}
end
