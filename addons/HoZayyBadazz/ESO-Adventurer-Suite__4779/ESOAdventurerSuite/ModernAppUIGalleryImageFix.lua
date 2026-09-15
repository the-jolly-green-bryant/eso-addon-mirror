-- ESO Adventurer Suite
-- v0.29.548 - Modern UI Character/Companion gallery image visibility repair.
-- Rebind packaged DDS portraits with an explicit addon-root path after gallery
-- creation/refresh so class and companion artwork cannot remain transparent.

local EPC = ESOProgressionCoach
if not EPC or not EPC.ModernAppUI then return end
local M = EPC.ModernAppUI

local function normalizePath029548(path)
    path = tostring(path or "")
    if path == "" then return "" end
    path = path:gsub("\\", "/")
    if string.sub(path, 1, 1) ~= "/" then path = "/" .. path end
    return path
end

local function forceArt029548(page)
    if type(page) ~= "table" then return end
    for _, entry in ipairs(page.cardEntries or {}) do
        local art = entry.art
        if art then
            local path = normalizePath029548(entry.path)
            if path ~= "" then
                if type(PreloadTexture) == "function" then pcall(PreloadTexture, path) end
                if type(art.SetTexture) == "function" then pcall(art.SetTexture, art, path) end
            end
            if type(art.SetHidden) == "function" then pcall(art.SetHidden, art, false) end
            if type(art.SetAlpha) == "function" then pcall(art.SetAlpha, art, 1) end
            if type(art.SetColor) == "function" then pcall(art.SetColor, art, 1, 1, 1, 1) end
            if type(art.SetDrawTier) == "function" and rawget(_G, "DT_HIGH") ~= nil then
                pcall(art.SetDrawTier, art, DT_HIGH)
            end
            if type(art.SetDrawLayer) == "function" and rawget(_G, "DL_CONTROLS") ~= nil then
                pcall(art.SetDrawLayer, art, DL_CONTROLS)
            end
            if type(art.SetDrawLevel) == "function" then pcall(art.SetDrawLevel, art, 24) end
        end

        -- Some older gallery builds created a fallback texture above the portrait.
        -- Once the packaged portrait is rebound, keep that fallback from covering it.
        local fallback = entry.fallback
        if fallback and fallback ~= art then
            if type(fallback.SetHidden) == "function" then pcall(fallback.SetHidden, fallback, true) end
            if type(fallback.SetAlpha) == "function" then pcall(fallback.SetAlpha, fallback, 0) end
        end
    end
end

if type(M.CreateCardGallery) == "function" and not M._galleryImageCreateFix029548 then
    local baseCreate = M.CreateCardGallery
    function M:CreateCardGallery(tab, cards, titleText, subText)
        local page = baseCreate(self, tab, cards, titleText, subText)
        if tab == "CHARACTER" or tab == "COMPANIONS" then forceArt029548(page) end
        return page
    end
    M._galleryImageCreateFix029548 = true
end

if type(M.RefreshGallery) == "function" and not M._galleryImageRefreshFix029548 then
    local baseRefresh = M.RefreshGallery
    function M:RefreshGallery(tab, page, ...)
        local result = baseRefresh(self, tab, page, ...)
        if tab == "CHARACTER" or tab == "COMPANIONS" then forceArt029548(page) end
        return result
    end
    M._galleryImageRefreshFix029548 = true
end

-- Repair already-created pages immediately when this patch loads.
if type(M.pages) == "table" then
    forceArt029548(M.pages.CHARACTER)
    forceArt029548(M.pages.COMPANIONS)
end
