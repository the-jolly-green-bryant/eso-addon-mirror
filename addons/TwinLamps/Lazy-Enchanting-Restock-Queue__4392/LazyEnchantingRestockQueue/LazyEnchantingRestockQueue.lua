-- A simplistic addon that does what it says on the tin:
-- Add gold Truly Superb Glyphs to the LibLazyCrafting Enchanting queue either from an Item Sold mail button
-- or from clicking within a pop-up menu from /lerq or /lerq menu.
-- Menu has favorites checkbox and can filter to show only favorites.
local ADDON_NAME = "LazyEnchantingRestockQueue"
local Addon = {}
_G[ADDON_NAME] = Addon

------------------------------------------------------------
-- RECIPES FOR GOLD CP160 GLYPHS
------------------------------------------------------------

-- Define CP160 potency & aspect runes
local R   = 68341   -- Repora (positive, CP160)
local I   = 68340   -- Itade (negative, CP160)
local K   = 45854   -- Kuta (gold aspect)
local IND = 166045  -- Prismatic Recovery essence

-- Note: Essence IDs pulled from LibLazyCrafting glyphInfo table
Addon.Map = {
    -- Max Stats
    ["Truly Superb Glyph of Health"]              = {p = R, e = 45831, a = K},
    ["Truly Superb Glyph of Magicka"]            = {p = R, e = 45832, a = K},
    ["Truly Superb Glyph of Stamina"]            = {p = R, e = 45833, a = K},

    -- Prismatic
    ["Truly Superb Glyph of Prismatic Defense"]  = {p = R, e = 68342, a = K},
    ["Truly Superb Glyph of Prismatic Onslaught"]= {p = I, e = 68342, a = K},
    ["Truly Superb Glyph of Prismatic Recovery"] = {p = R, e = IND,   a = K},

    -- Elemental & Damage
    ["Truly Superb Glyph of Flame"]              = {p = R, e = 45839, a = K},
    ["Truly Superb Glyph of Foulness"]           = {p = R, e = 45841, a = K},
    ["Truly Superb Glyph of Frost"]              = {p = R, e = 45840, a = K},
    ["Truly Superb Glyph of Shock"]              = {p = R, e = 45838, a = K},
    ["Truly Superb Glyph of Poison"]             = {p = R, e = 45837, a = K},

    ["Truly Superb Glyph of Crushing"]           = {p = I, e = 45842, a = K},
    ["Truly Superb Glyph of Decrease Health"]    = {p = I, e = 45834, a = K},
    ["Truly Superb Glyph of Hardening"]          = {p = R, e = 45842, a = K},
    ["Truly Superb Glyph of Weakening"]          = {p = I, e = 45843, a = K},
    ["Truly Superb Glyph of Weapon Damage"]      = {p = R, e = 45843, a = K},

    -- Absorb
    ["Truly Superb Glyph of Absorb Health"]      = {p = I, e = 45831, a = K},
    ["Truly Superb Glyph of Absorb Magicka"]     = {p = I, e = 45832, a = K},
    ["Truly Superb Glyph of Absorb Stamina"]     = {p = I, e = 45833, a = K},

    -- Recovery & Cost Reduction
    ["Truly Superb Glyph of Health Recovery"]    = {p = R, e = 45834, a = K},
    ["Truly Superb Glyph of Magicka Recovery"]   = {p = R, e = 45835, a = K},
    ["Truly Superb Glyph of Stamina Recovery"]   = {p = R, e = 45836, a = K},

	["Truly Superb Glyph of Reduce Spell Cost"] = {p = I, e = 45835, a = K},
	["Truly Superb Glyph of Reduce Feat Cost"]  = {p = I, e = 45836, a = K},

    -- Harm & Resist
    ["Truly Superb Glyph of Increase Magical Harm"] = {p = R, e = 45848, a = K},
    ["Truly Superb Glyph of Increase Physical Harm"] = {p = R, e = 45847, a = K},

	["Truly Superb Glyph of Flame Resist"]  = {p = I, e = 45839, a = K},
	["Truly Superb Glyph of Frost Resist"]  = {p = I, e = 45840, a = K},
	["Truly Superb Glyph of Shock Resist"]  = {p = I, e = 45838, a = K},
	["Truly Superb Glyph of Poison Resist"] = {p = I, e = 45837, a = K},
	["Truly Superb Glyph of Disease Resist"]= {p = I, e = 45841, a = K},

    -- Utility
    ["Truly Superb Glyph of Potion Boost"]       = {p = R, e = 45846, a = K},
    ["Truly Superb Glyph of Potion Speed"]       = {p = I, e = 45846, a = K},
    ["Truly Superb Glyph of Shielding"]          = {p = R, e = 45849, a = K},
    ["Truly Superb Glyph of Bashing"]            = {p = R, e = 45849, a = K},
}

------------------------------------------------------------
-- MAIL BUTTON AND QUEUE SETUP
------------------------------------------------------------

-- Parse the mail body and return ONLY if it's a sold item, for a Truly Superb glyph
function Addon:GetGlyphFromMail()
    local body = ZO_MailInboxMessageBody
    if not (body and not body:IsHidden()) then return nil end

    local subject = ZO_MailInboxMessageSubject:GetText() or ""
    if subject ~= "Item Sold" then
        return nil
    end

    local link = string.match(body:GetText() or "", "(|H.-|h)")
    if not link then return nil end

    local clean = zo_strformat("<<t:1>>", GetItemLinkName(link))
    local runes = self.Map[clean]

    if runes then
        return clean, runes
    end

    return nil
end


-- Queue the craft into LLC, calling via our own LLC interaction table
function Addon:Restock()
    if not Addon.LLC then
        CHAT_ROUTER:AddSystemMessage("[LERQ] LibLazyCrafting was not found. Oops, we need that!")
        return
    end

    local name, runes = self:GetGlyphFromMail()
    if not (name and runes) then
        CHAT_ROUTER:AddSystemMessage("[LERQ] Error: No valid Truly Superb glyph found in this mail.")
        return
    end

	-- LibLazyCrafting uses different capitalizations in different spaces
    local req = Addon.LLC:CraftEnchantingItemId(runes.p, runes.e, runes.a, true, name)
	if req then
		req.Requester = ADDON_NAME
		req.requester = ADDON_NAME
	end

    CHAT_ROUTER:AddSystemMessage("[LERQ] Queued: " .. name)
end


-- Add the button and only show it when the mail contains a mapped glyph
function Addon:SetupButton()
    if Addon.RestockBtn then return end

    local btn = WINDOW_MANAGER:CreateControlFromVirtual(ADDON_NAME .. "_RestockBtn", ZO_MailInboxMessage, "ZO_DefaultButton")
    Addon.RestockBtn = btn  -- store global reference to avoid letting other addons confuse LLC

    btn:SetText("Queue Restock")
    btn:SetWidth(160)
    btn:SetHeight(28)
    btn:SetAnchor(TOPLEFT, ZO_MailInboxMessageBody, TOPLEFT, 0, -35)

    -- always start disabled and track readiness so it will activate to the correct queue
    btn:SetEnabled(false)
    btn.LERQ_Ready = false

    -- if LLC is already registered (such as, OnLoaded ran first), enable now
    if Addon.LLC then
        btn.LERQ_Ready = true
        btn:SetEnabled(true)
    end

    btn:SetHandler("OnClicked", function()
        if not Addon.LLC or not btn.LERQ_Ready then
            CHAT_ROUTER:AddSystemMessage("[LERQ] LibLazyCrafting not ready yet.")
            return
        end
        self:Restock()
    end)
	-- Update visibility based on current mail contents
	local function RefreshButtonVisibility()
		if not Addon.RestockBtn then return end
		local name, runes = Addon:GetGlyphFromMail()
		Addon.RestockBtn:SetHidden(not (name and runes))
	end

	-- Update when mail changes
	EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_MAIL_READABLE, RefreshButtonVisibility)
	EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_MAIL_INBOX_UPDATE, RefreshButtonVisibility)

	-- Initial visibility check
	RefreshButtonVisibility()

end

------------------------------------------------------------
-- MENU WINDOW WITH FAVORITES
------------------------------------------------------------

local MENU_NAME = ADDON_NAME .. "_MenuWindow"
local MENU_WIDTH = 450
local MENU_HEIGHT = GuiRoot:GetHeight() * 0.75

-- Menu Groups for logical flow
local GLYPH_GROUPS = {
    {
        name = "Armor Glyphs",
        items = {
            "Truly Superb Glyph of Health",
            "Truly Superb Glyph of Magicka",
            "Truly Superb Glyph of Stamina",
            "Truly Superb Glyph of Prismatic Defense",
        },
    },
    {
        name = "Weapon Damage/Recovery",
        items = {
            "Truly Superb Glyph of Absorb Health",
            "Truly Superb Glyph of Absorb Magicka",
            "Truly Superb Glyph of Absorb Stamina",
            "Truly Superb Glyph of Prismatic Onslaught",
        },
    },
    {
        name = "Weapon Damage Types",
        items = {
            "Truly Superb Glyph of Decrease Health",
            "Truly Superb Glyph of Flame",
            "Truly Superb Glyph of Foulness",
            "Truly Superb Glyph of Frost",
            "Truly Superb Glyph of Poison",
            "Truly Superb Glyph of Shock",
        },
    },
    {
        name = "Weapon Utility",
        items = {
            "Truly Superb Glyph of Crushing",
            "Truly Superb Glyph of Hardening",
            "Truly Superb Glyph of Weakening",
            "Truly Superb Glyph of Weapon Damage",
        },
    },
    {
        name = "Jewelry Resource Glyphs",
        items = {
            "Truly Superb Glyph of Health Recovery",
            "Truly Superb Glyph of Magicka Recovery",
            "Truly Superb Glyph of Stamina Recovery",
            "Truly Superb Glyph of Prismatic Recovery",
            "Truly Superb Glyph of Reduce Spell Cost",
            "Truly Superb Glyph of Reduce Feat Cost",
        },
    },
    {
        name = "Jewelry Resist",
        items = {
            "Truly Superb Glyph of Flame Resist",
            "Truly Superb Glyph of Frost Resist",
            "Truly Superb Glyph of Shock Resist",
            "Truly Superb Glyph of Poison Resist",
            "Truly Superb Glyph of Disease Resist",
        },
    },
    {
        name = "Jewelry Utility",
        items = {
            "Truly Superb Glyph of Potion Boost",
            "Truly Superb Glyph of Potion Speed",
            "Truly Superb Glyph of Bashing",
            "Truly Superb Glyph of Shielding",
        },
    },
}

-- Create menu window via native UI functionality
function Addon:CreateMenu()
    if Addon.Menu then return end

    local wm = WINDOW_MANAGER

    local win = wm:CreateTopLevelWindow(MENU_NAME)
    win:SetDimensions(MENU_WIDTH, MENU_HEIGHT)
    win:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    win:SetMovable(true)
    win:SetMouseEnabled(true)
    win:SetClampedToScreen(true)
    win:SetHidden(true)
    Addon.Menu = win

    -- Background
    local bg = wm:CreateControl(nil, win, CT_BACKDROP)
    bg:SetAnchorFill(win)
    bg:SetCenterColor(0, 0, 0, 0.7)
    bg:SetEdgeColor(1, 1, 1, 0.8)
    bg:SetEdgeTexture(nil, 2, 2, 2)

    -- X to Close
    local close = wm:CreateControlFromVirtual(nil, win, "ZO_CloseButton")
    close:SetAnchor(TOPRIGHT, win, TOPRIGHT, -5, 5)
    close:SetHandler("OnClicked", function() win:SetHidden(true) end)

    -- Title
    local title = wm:CreateControl(nil, win, CT_LABEL)
    title:SetFont("ZoFontWinH1")
    title:SetText("Lazy Enchanting Restock Queue")
    title:SetAnchor(TOP, win, TOP, 0, 10)

    -- Favorites toggle
    local favToggle = wm:CreateControlFromVirtual(nil, win, "ZO_CheckButton")
    favToggle:SetAnchor(TOPLEFT, win, TOPLEFT, 20, 50)

    -- Manual label to avoid duplicate 'Label' control
    local favLabel = wm:CreateControl(nil, win, CT_LABEL)
    favLabel:SetFont("ZoFontGame")
    favLabel:SetText("Show Favorites Only")
    favLabel:SetAnchor(LEFT, favToggle, RIGHT, 10, 0)

	-- Initial state
	ZO_CheckButton_SetCheckState(favToggle, Addon.Menu_ShowFavorites)

	ZO_CheckButton_SetToggleFunction(favToggle, function(control)
		local checked = ZO_CheckButton_IsChecked(control)
		Addon.Menu_ShowFavorites = checked
		Addon.SavedVars.showFavoritesOnly = checked

-- Debug row kept but commented out, in case of future breakage
--		d("[LERQ Toggle] Changed to " .. tostring(checked) .. " — updating menu")

		-- Immediately force visual
		ZO_CheckButton_SetChecked(control, checked)
		ZO_CheckButton_SetCheckState(control, checked)

		zo_callLater(function()
			Addon:UpdateMenu()

			-- Re-force after update, with a tiny delay for safety
			ZO_CheckButton_SetChecked(control, checked)
			ZO_CheckButton_SetCheckState(control, checked)
		end, 50)
	end)
	
    Addon.Menu_FavToggle = favToggle

    -- Scroll container (clearing to avoid dup'ing container)
    local scroll = wm:CreateControlFromVirtual(nil, win, "ZO_ScrollContainer")
    scroll:ClearAnchors()
    scroll:SetAnchor(TOPLEFT, win, TOPLEFT, 20, 90)
    scroll:SetDimensions(MENU_WIDTH - 40, MENU_HEIGHT - 120)

    Addon.MenuScroll = scroll
    Addon.MenuScrollChild = scroll:GetNamedChild("ScrollChild")

   
    -- Resize Grip Setup
    -- Shared resize state
    local resizing = false
    local startX, startY, startW, startH

    -- Helper: begin resize
    local function BeginResize()
        resizing = true
        startX, startY = GetUIMousePosition()
        startW, startH = win:GetDimensions()
    end

    -- Helper: end resize
    local function EndResize()
        resizing = false
    end

    -- Helper: apply resize on update
    local function ApplyResize()
        if resizing then
            local x, y = GetUIMousePosition()
            local dx = x - startX
            local dy = y - startY

            local newW = math.max(300, startW + dx)
            local newH = math.max(400, startH + dy)

            win:SetDimensions(newW, newH)

            -- Resize scroll container to match
            Addon.MenuScroll:SetDimensions(newW - 40, newH - 120)
        end
    end

    -- Corner box for bottom-right resize grip
    local grip = wm:CreateControl(nil, win, CT_CONTROL)
    grip:SetDimensions(20, 20)
    grip:SetAnchor(BOTTOMRIGHT, win, BOTTOMRIGHT, 0, 0)
    grip:SetMouseEnabled(true)

    -- Make the grip actually visible
    local gripBG = wm:CreateControl(nil, grip, CT_BACKDROP)
    gripBG:SetAnchorFill(grip)
    gripBG:SetCenterColor(0, 0, 0, 0.4)
    gripBG:SetEdgeColor(1, 1, 1, 0.6)

    local gripTex = wm:CreateControl(nil, grip, CT_TEXTURE)
    gripTex:SetAnchorFill(grip)
    gripTex:SetTexture("EsoUI/Art/Buttons/resizeGrip.dds")
    gripTex:SetColor(1, 1, 1, 1)

    grip:SetHandler("OnMouseDown", function(_, button)
        if button == MOUSE_BUTTON_INDEX_LEFT then
            BeginResize()
        end
    end)

    grip:SetHandler("OnMouseUp", EndResize)
    grip:SetHandler("OnUpdate", ApplyResize)

    -- Delay one frame so the menu anchors settle down before the first UpdateMenu()
    zo_callLater(function()
        Addon:UpdateMenu()
    end, 50)

end

------------------------------------------------------------
-- Refresh menu contents for expected behaviors
------------------------------------------------------------
function Addon:UpdateMenu(forceRebuild)
    if not Addon.MenuScrollChild then return end

    -- If first time or forceRebuild is true, build everything
    if not Addon.MenuCheckboxes or forceRebuild then
        -- Clear any old stuff just once
        local children = {}
        for i = 1, Addon.MenuScrollChild:GetNumChildren() do
            table.insert(children, Addon.MenuScrollChild:GetChild(i))
        end
        for _, child in ipairs(children) do
            child:SetParent(nil)
            child:SetHidden(true)
        end

        Addon.MenuCheckboxes = {}     -- {glyphName = favControl}
        Addon.MenuRows = {}           -- {glyphName = rowControl} for hide/show
		Addon.MenuGroupLabels = {}	-- So we won't show them if none are showing

        local wm = WINDOW_MANAGER
        local parent = Addon.MenuScrollChild
        local last = nil

        for _, group in ipairs(GLYPH_GROUPS) do
            local groupLabel = wm:CreateControl(nil, parent, CT_LABEL)
            groupLabel:SetFont("ZoFontGameBold")
            groupLabel:SetText(group.name)
			Addon.MenuGroupLabels[group.name] = groupLabel
            if last then
                groupLabel:SetAnchor(TOPLEFT, last, BOTTOMLEFT, 0, 20)
            else
                groupLabel:SetAnchor(TOPLEFT, parent, TOPLEFT, 0, 0)
            end
            last = groupLabel

            for _, glyphName in ipairs(group.items) do
                local row = wm:CreateControl(nil, parent, CT_CONTROL)
                row:SetDimensions(MENU_WIDTH - 60, 30)
                row:SetAnchor(TOPLEFT, last, BOTTOMLEFT, 0, 5)
                last = row

                local fav = wm:CreateControlFromVirtual(nil, row, "ZO_CheckButton")
                fav:SetAnchor(LEFT, row, LEFT, 0, 0)

                -- Initial state
                local isFavorite = Addon.SavedVars.favorites[glyphName] == true
				ZO_CheckButton_SetCheckState(fav, isFavorite)
				ZO_CheckButton_SetChecked(fav, isFavorite)

                -- Store
                Addon.MenuCheckboxes[glyphName] = fav
                Addon.MenuRows[glyphName] = row

                -- Let ESO handle toggle, we just save on change
				ZO_CheckButton_SetToggleFunction(fav, function(control)
					local checked = ZO_CheckButton_IsChecked(control)
					Addon.SavedVars.favorites[glyphName] = checked or nil
-- Debug row kept but commented out, in case of future breakage
--					d("[LERQ Favorite] '" .. glyphName .. "' toggled to " .. tostring(checked) .. " — saved")

					-- Force visual match after ESO toggle
					zo_callLater(function()
						ZO_CheckButton_SetChecked(control, checked)
						ZO_CheckButton_SetCheckState(control, checked)
					end, 50)
				end)


                local label = wm:CreateControl(nil, row, CT_LABEL)
                label:SetFont("ZoFontGame")
                label:SetText(glyphName)
                label:SetAnchor(LEFT, fav, RIGHT, 10, 0)

                local btn = wm:CreateControlFromVirtual(nil, row, "ZO_DefaultButton")
                btn:SetText("+")
                btn:SetDimensions(30, 26)
                btn:SetAnchor(RIGHT, row, RIGHT, 0, 0)
                btn:SetHandler("OnClicked", function()
                    local runes = Addon.Map[glyphName]
                    if runes and Addon.LLC then
						local req = Addon.LLC:CraftEnchantingItemId(runes.p, runes.e, runes.a, true, glyphName)
						-- LibLazyCrafting uses different capitalization
						if req then
							req.Requester = ADDON_NAME
							req.requester = ADDON_NAME
						end
						CHAT_ROUTER:AddSystemMessage("[LERQ] Queued: " .. glyphName)
					end
                end)
            end
        end
    end

	-- Always: apply current filter and state
    local showOnlyFavorites = Addon.Menu_ShowFavorites

    -- First, calculate visibility for items and hide/show rows
	for glyphName, row in pairs(Addon.MenuRows) do
		local isFavorite = Addon.SavedVars.favorites[glyphName] == true
		local shouldShow = not showOnlyFavorites or isFavorite

		row:SetHidden(not shouldShow)
		row:SetHeight(shouldShow and 30 or 0)

		local fav = Addon.MenuCheckboxes[glyphName]
		if fav then
			ZO_CheckButton_SetChecked(fav, isFavorite)
			ZO_CheckButton_SetCheckState(fav, isFavorite)
		end
	end


	 -- Hide group headers if no items in group are visible AND collapse whitespace
	for _, group in ipairs(GLYPH_GROUPS) do
		local groupHasVisible = false
		for _, glyphName in ipairs(group.items) do
			if not Addon.MenuRows[glyphName]:IsHidden() then
				groupHasVisible = true
				break
			end
		end

		local label = Addon.MenuGroupLabels[group.name]
		if label then
			if groupHasVisible then
				label:SetHidden(false)
				label:SetHeight(20)
			else
				label:SetHidden(true)
				label:SetHeight(0)
			end
		end
	end

	-- Clean rebuild of the anchor chain based on what's selected
	local lastControl = nil

	for _, group in ipairs(GLYPH_GROUPS) do
		local header = Addon.MenuGroupLabels[group.name]

		-- Only anchor visible headers
		if header and not header:IsHidden() then
			header:ClearAnchors()
			if lastControl then
				header:SetAnchor(TOPLEFT, lastControl, BOTTOMLEFT, 0, 10)
			else
				header:SetAnchor(TOPLEFT, Addon.MenuScrollChild, TOPLEFT, 0, 0)
			end
			lastControl = header
		end

		-- Only anchor visible rows
		for _, glyphName in ipairs(group.items) do
			local row = Addon.MenuRows[glyphName]
			if row and not row:IsHidden() then
				row:ClearAnchors()
				row:SetAnchor(TOPLEFT, lastControl, BOTTOMLEFT, 0, 5)
				lastControl = row
			end
		end
	end

	-- Forced visual sync for a clean view
	zo_callLater(function()
		for glyphName, fav in pairs(Addon.MenuCheckboxes) do
			local shouldBeChecked = Addon.SavedVars.favorites[glyphName] == true
			ZO_CheckButton_SetChecked(fav, shouldBeChecked)
			ZO_CheckButton_SetCheckState(fav, shouldBeChecked)
		end
	end, 50)


end

------------------------------------------------------------
-- Slash Command definitions
------------------------------------------------------------

SLASH_COMMANDS["/lerq"] = function(text)
    local arg = text
    if arg ~= nil then
        arg = arg:match("^%s*(.-)%s*$")  -- trim spaces for clean behavior
        if arg == "" then
            arg = nil
        else
            arg = arg:lower()
        end
    end

    local L = LibLazyCrafting
    local key = Addon.LLC.addonName

    -- /lerq menu (also the default /lerq behavior)
	if arg == "menu" then
        if not Addon.Menu then
            Addon:CreateMenu()
        end
        local isHidden = not Addon.Menu:IsHidden()
        Addon.Menu:SetHidden(isHidden)
        -- Refresh data whenever the menu is shown
        if not isHidden then Addon:UpdateMenu() end
        return
    end

    -- /lerq clear
    if arg == "clear" then
        if not (L and L.craftingQueue and L.craftingQueue[key]) then
            CHAT_ROUTER:AddSystemMessage("[LERQ] No LibLazyCrafting queue found for addon '" .. tostring(key) .. "'.")
            return
        end

        local q = L.craftingQueue[key][CRAFTING_TYPE_ENCHANTING]
        if not q or #q == 0 then
            CHAT_ROUTER:AddSystemMessage("[LERQ] Enchanting queue is already empty.")
            return
        end

        for i = #q, 1, -1 do
            table.remove(q, i)
        end

        if L.DeleteHomeMarker then
            L.DeleteHomeMarker(nil, CRAFTING_TYPE_ENCHANTING)
        end

        CHAT_ROUTER:AddSystemMessage("[LERQ] Enchanting queue cleared.")
        return
    end

    -- /lerq list  (list of queue'd glyphs and total count in queue)
    if arg == "list" then
        if not (L and L.craftingQueue and L.craftingQueue[key]) then
            CHAT_ROUTER:AddSystemMessage("[LERQ] No LibLazyCrafting queue found for addon '" .. tostring(key) .. "'.")
            return
        end

        local q = L.craftingQueue[key][CRAFTING_TYPE_ENCHANTING]
        if not q or #q == 0 then
            CHAT_ROUTER:AddSystemMessage("[LERQ] No enchanting requests queued.")
            return
        end

        local c = 0
        CHAT_ROUTER:AddSystemMessage("[LERQ] Queued glyphs:")
        for i, req in ipairs(q) do
            c = c + 1
            CHAT_ROUTER:AddSystemMessage(string.format(
                "  #%d: %s | Qty: %d",
                i,
                req.reference or "(unnamed)",
                req.quantity or 1
            ))
        end
        CHAT_ROUTER:AddSystemMessage("[LERQ] Items in queue: " .. c)
        return
    end

    -- Just /lerq toggles the menu (most common use of /lerq and there's no keybind to make it faster)
    if not arg then
		if not Addon.Menu then
            Addon:CreateMenu()
        end
        local isHidden = not Addon.Menu:IsHidden()
        Addon.Menu:SetHidden(isHidden)
        -- Refresh data whenever the menu is shown
        if not isHidden then Addon:UpdateMenu() end
        return
    end

    -- /lerq [*] aka help text for all other instances
    CHAT_ROUTER:AddSystemMessage("[LERQ] Commands:")
    CHAT_ROUTER:AddSystemMessage("  /lerq       - Open/close the glyph menu")
    CHAT_ROUTER:AddSystemMessage("  /lerq menu  - Also toggles the glyph menu")
    CHAT_ROUTER:AddSystemMessage("  /lerq list  - List queued glyphs + total count")
    CHAT_ROUTER:AddSystemMessage("  /lerq clear - Clear the crafting queue")
end

------------------------------------------------------------
-- Addon Load Block
-- Register our custom LibLazyCrafting callback (so it doesn't keep telling us we just crafted our hat)
------------------------------------------------------------
local function OnLoaded(event, addon)
    if addon ~= ADDON_NAME then return end
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)

    -- Register LERQ with LLC
    Addon.LLC = LibLazyCrafting:AddRequestingAddon(
        ADDON_NAME,
        true,
        function(event, station, result)
            -- Normalize requester field for LLC 4.031+
            if result then
                result.Requester = ADDON_NAME
                result.requester = ADDON_NAME
            end

            if event == "success" and result and result.reference then
                CHAT_ROUTER:AddSystemMessage(
                    string.format("[LERQ] %s was crafted and removed from the queue.", result.reference)
                )
            end
        end
    )

    -- mail button babysitting: if the button already exists, mark it ready and enable it
    if Addon.RestockBtn then
        Addon.RestockBtn.LERQ_Ready = true
        Addon.RestockBtn:SetEnabled(true)
    end

    -- Saved variables (moved from OnPlayerActivated)
    local defaults = {
        favorites = {},
        showFavoritesOnly = false,
    }

    Addon.SavedVars = ZO_SavedVars:NewAccountWide(
        "LERQ_Saved",
        1,
        nil,
        defaults,
        GetWorldName()
    )

    Addon.Menu_ShowFavorites = Addon.SavedVars.showFavoritesOnly

    Addon:SetupButton()
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnLoaded)