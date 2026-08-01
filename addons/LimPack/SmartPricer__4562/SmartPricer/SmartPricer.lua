-- ============================================================
--  SmartPricer v1.1.0
--  Auteur : LimPack
-- ============================================================

SmartPricer = {}
local VM  = SmartPricer
local LAM = LibAddonMenu2
local ADDON_NAME   = "SmartPricer"

-- Position et taille fixes
local ICON_OFFSET_X = 2
local ICON_SIZE     = 38

-- Table des paliers : texture + seuil par défaut
-- Recommandation Dolgalon : utiliser une table plutôt que des constantes séparées
local TIERS = {
    [1] = { texture = "EsoUI/Art/bank/bank_tabicon_gold_up.dds",                        defaultPrice = 5000  },
    [2] = { texture = "EsoUI/Art/guild/history/guildhistory_bankcurrency_up.dds",        defaultPrice = 10000 },
    [3] = { texture = "EsoUI/Art/market/keyboard/tabicon_goldcoastbazaar_up.dds",        defaultPrice = 25000 },
}

-- Objets banque de guilde — initialisés à la demande (après addon load)
-- pour éviter que GUILD_BANK_INVENTORY/GUILD_BANK soient nil au chargement
local function SP_GetGuildBankObjects()
    return { GUILD_BANK_INVENTORY, GUILD_BANK }
end

local defaults = {
    enabled              = true,
    debugMode            = false,
    filterEquipmentOnly  = false,
    -- Paliers : prix configurables (textures fixes dans TIERS)
    tiers = {
        [1] = { price = 5000,  enabled = true  },
        [2] = { price = 10000, enabled = true  },
        [3] = { price = 25000, enabled = true  },
    },
}

local priceCache   = {}
local hookedLists  = {}
local activeBadges = {}
local rowToEntry   = {}
local badgePool    = {}
local tlc          = nil
local badgeCount   = 0  -- compteur pour nommer les badges créés dynamiquement

-- ──────────────────────────────────────────────────────────────
--  Utilitaires
-- ──────────────────────────────────────────────────────────────
local function DBG(msg)
    if VM.savedVars and VM.savedVars.debugMode then
        CHAT_SYSTEM:AddMessage("|cFF8800[SP]|r " .. tostring(msg))
    end
end

-- ZO_CommaDelimitNumber est la fonction native ESO pour formater les montants
local function FormatGold(n)
    return ZO_CommaDelimitNumber(math.floor(n)) .. "g"
end

-- ──────────────────────────────────────────────────────────────
--  Prix TTC
-- ──────────────────────────────────────────────────────────────
local function GetTTCPrice(itemLink)
    if not itemLink or itemLink == "" then return nil end
    if priceCache[itemLink] ~= nil then return priceCache[itemLink] end
    local price = nil
    local TTC = TamrielTradeCentrePrice or TamrielTradeCentre
    if TTC and TTC.GetPriceInfo then
        local info = TTC:GetPriceInfo(itemLink)
        if info then
            local avg, sug = info.Avg, info.SuggestedPrice
            if avg and sug and avg > (sug * 3) then price = sug
            elseif sug then price = sug
            elseif avg then price = avg
            end
        end
    end
    priceCache[itemLink] = price
    return price
end

local function ShouldMark(link)
    if not VM.savedVars.enabled then return false, nil end
    local price = GetTTCPrice(link)
    if price == nil then return false, nil end
    return (price >= VM.savedVars.tiers[1].price), price
end

-- ──────────────────────────────────────────────────────────────
--  Lecture du slot depuis un rowControl
--  Supporte : inventaire perso, banque, banque de guilde, craft bag
-- ──────────────────────────────────────────────────────────────
local function SP_GetBagSlot(ctrl)
    if not ctrl then return nil, nil end
    local de = ctrl.dataEntry
    if de and de.data then
        local d  = de.data
        local b  = d.bagId or d.bag
        local s  = d.slotIndex or d.index or d.slotId
        if b ~= nil and s ~= nil then return b, s end
    end
    -- Fallback : données directement sur le contrôle
    if ctrl.bagId ~= nil then return ctrl.bagId, ctrl.slotIndex end
    return nil, nil
end

-- ──────────────────────────────────────────────────────────────
--  TLC : overlay plein écran déclaré dans SmartPricerBadges.xml
--  Les badges sont créés dynamiquement en Lua (pool sans limite fixe)
-- ──────────────────────────────────────────────────────────────
local function SP_CreateBadge()
    badgeCount = badgeCount + 1
    local badge = WINDOW_MANAGER:CreateControl(
        "SmartPricerBadge" .. badgeCount,
        tlc,
        CT_TEXTURE
    )
    badge:SetDrawLayer(DL_OVERLAY)
    badge:SetDrawTier(DT_HIGH)
    badge:SetDrawLevel(7)
    badge:SetMouseEnabled(false)
    badge:SetHidden(true)
    return badge
end

local function SP_InitTLC()
    if tlc then return end
    tlc = SmartPricerLayer
    if not tlc then
        CHAT_SYSTEM:AddMessage("|cFF4444" .. SmartPricer_STR("INIT_NO_XML") .. "|r")
        return
    end
    local sw = GuiRoot:GetWidth()
    local sh = GuiRoot:GetHeight()
    tlc:SetDimensions(sw, sh)
    tlc:SetHidden(false)
    CHAT_SYSTEM:AddMessage("|c00FF7FSmartPricer|r " .. SmartPricer_STR("INIT_OK") .. sw .. "x" .. sh)
end

-- ──────────────────────────────────────────────────────────────
--  Gestion des badges
--  Ancrage DIRECT sur rowControl (technique FCO ItemSaver) :
--  badge:SetAnchor(TOPLEFT, rowControl, TOPLEFT, offsetX, offsetY)
--  → pas de coordonnées absolues, suit le scroll automatiquement
-- ──────────────────────────────────────────────────────────────
local function SP_ReleaseBadge(key)
    local e = rowToEntry[key]
    if e then
        e.badge:SetHidden(true)
        table.insert(badgePool, e.badge)
        -- O(1) : swap avec le dernier élément via l'index stocké dans l'entry
        local n = #activeBadges
        local i = e.index
        if i and i <= n then
            local last = activeBadges[n]
            activeBadges[i] = last
            if last then last.index = i end
            activeBadges[n] = nil
        end
        rowToEntry[key] = nil
    end
end

local function SP_ApplyBadge(rowControl)
    if not rowControl or not tlc then return end
    local key     = tostring(rowControl)
    local bagId, slotIndex = SP_GetBagSlot(rowControl)
    if bagId == nil then SP_ReleaseBadge(key); return end

    local link = GetItemLink(bagId, slotIndex, LINK_STYLE_BRACKETS)
    if not link or link == "" then SP_ReleaseBadge(key); return end

    -- Filtre optionnel : armes, armures et bijoux uniquement
    if VM.savedVars.filterEquipmentOnly then
        local itype = GetItemType(bagId, slotIndex)
        if itype ~= ITEMTYPE_WEAPON
        and itype ~= ITEMTYPE_ARMOR
        and itype ~= ITEMTYPE_JEWELRY then
            SP_ReleaseBadge(key); return
        end
    end

    local mark, price = ShouldMark(link)
    local ex = rowToEntry[key]

    if mark then
        local sv      = VM.savedVars
        -- Choix de la texture : palier le plus haut d'abord
        local texture = TIERS[1].texture
        for i = 3, 2, -1 do
            local tier = sv.tiers[i]
            if tier and tier.enabled and price >= tier.price then
                texture = TIERS[i].texture
                break
            end
        end

        local badge
        if ex then
            badge = ex.badge
            -- ★ Lazy evaluation : si le badge est déjà correct, ne rien faire
            if not badge:IsHidden() and ex.texture == texture then
                return
            end
        else
            badge = table.remove(badgePool)
            if not badge then
                badge = SP_CreateBadge()
            end
            -- Trouve le container ScrollList une seule fois et le met en cache
            local container = rowControl:GetParent()
            while container and container ~= GuiRoot do
                if container.scrollData or container.dataTypes then break end
                container = container:GetParent()
            end
            if container == GuiRoot then container = nil end
            local entry = {
                row       = rowControl,
                badge     = badge,
                texture   = texture,
                container = container,
                index     = #activeBadges + 1,
            }
            activeBadges[entry.index] = entry
            rowToEntry[key] = entry
            ex = entry
        end

        ex.texture = texture
        badge:SetHidden(false)
        badge:SetAlpha(1)
        badge:SetTexture(texture)
        badge:SetDimensions(ICON_SIZE, ICON_SIZE)
        badge:SetColor(1, 1, 1, 1)
        badge:ClearAnchors()
        badge:SetAnchor(LEFT, rowControl, LEFT, ICON_OFFSET_X, 0)

        if VM.savedVars.debugMode then
            DBG("badge placé — bag=" .. tostring(bagId) .. " slot=" .. tostring(slotIndex)
                .. " prix=" .. FormatGold(price) .. " texture=" .. texture)
        end
    else
        SP_ReleaseBadge(key)
    end
end

-- ──────────────────────────────────────────────────────────────
--  OnUpdate : throttlé à 10fps (interval 100ms)
--  Vérifie que les badges sont dans le viewport de leur ScrollList
-- ──────────────────────────────────────────────────────────────
local ONUPDATE_INTERVAL = 0.1  -- 100ms = 10 fois/seconde
local onUpdateElapsed   = 0

local function SP_SetupOnUpdate()
    if not tlc then return end
    tlc:SetHandler("OnUpdate", function(_, elapsed)
            if not VM.savedVars or not VM.savedVars.enabled then return end

            -- ★ Throttle : n'exécute la logique qu'à 10fps max
            onUpdateElapsed = onUpdateElapsed + elapsed
            if onUpdateElapsed < ONUPDATE_INTERVAL then return end
            onUpdateElapsed = 0

            for _, entry in ipairs(activeBadges) do
                local row   = entry.row
                local badge = entry.badge
                if not row or not badge then
                    if badge then badge:SetHidden(true) end
                else
                    -- 1. Vérifie la hiérarchie IsHidden
                    local hidden = row:IsHidden()
                    if not hidden then
                        local p = row:GetParent()
                        while p and p ~= GuiRoot do
                            if p:IsHidden() then hidden = true; break end
                            p = p:GetParent()
                        end
                    end

                    -- 2. Vérifie que le row est dans les limites de son conteneur scroll
                    --    Le container est mis en cache dans entry à la création du badge
                    if not hidden then
                        local container = entry.container
                        if container then
                            local rL, rT, rR, rB = row:GetScreenRect()
                            local cL, cT, cR, cB = container:GetScreenRect()
                            local rowCenterY = rT + (rB - rT) * 0.5
                            if rowCenterY < cT or rowCenterY > cB
                            or rR < cL or rL > cR then
                                hidden = true
                            end
                        end
                    end

                    badge:SetHidden(hidden)
                end
            end
        end)
end

-- ──────────────────────────────────────────────────────────────
--  Gestion des scenes : cache tous les badges quand l'inventaire
--  se ferme (plus fiable que détecter via IsHidden)
-- ──────────────────────────────────────────────────────────────
local function SP_HideAllBadges()
    for _, entry in ipairs(activeBadges) do
        if entry.badge then entry.badge:SetHidden(true) end
    end
end

local function SP_SetupSceneListeners()
    -- Scènes d'inventaire connues dans ESO
    local inventoryScenes = {
        "inventory",
        "bank",
        "guildBank",
        "craftBag",
        "gamepad_inventory_root",
        "gamepad_bank_root",
    }
    for _, sceneName in ipairs(inventoryScenes) do
        local scene = SCENE_MANAGER:GetScene(sceneName)
        if scene then
            scene:RegisterCallback("StateChange", function(old, new)
                if new == SCENE_HIDDEN then
                    SP_HideAllBadges()
                    DBG("Scene '" .. sceneName .. "' cachée → badges masqués")
                end
            end)
        end
    end
end

-- ──────────────────────────────────────────────────────────────
--  Hooks scroll lists
-- ──────────────────────────────────────────────────────────────
local function SP_HookListView(lv, label)
    if not lv then return false end
    -- Certaines listes (guild bank) exposent directement scrollData
    if not lv.dataTypes or not lv.dataTypes[1] then return false end
    local key = tostring(lv)
    if hookedLists[key] then return true end
    local dtt = ZO_ScrollList_GetDataTypeTable(lv, 1)
    if not dtt then return false end
    SecurePostHook(dtt, "setupCallback", function(rc)
        if rc then SP_ApplyBadge(rc) end
    end)
    hookedLists[key] = true
    DBG("hooked : " .. (label or "?"))
    return true
end

--[[
    SP_HookAll — hook toutes les listes d'inventaire connues :
      • Inventaire perso (INVENTORY_BACKPACK, INVENTORY_BANK, INVENTORY_EQUIPMENT)
      • Craft bag (INVENTORY_CRAFT_BAG) si disponible
      • Banque (BANKING_INVENTORY)
      • Banque de guilde (GUILD_BANK ou GUILD_BANK_INVENTORY)
]]
local function SP_HookAll()
    -- Inventaire du joueur (perso, banque, équipement, craft bag)
    if PLAYER_INVENTORY and PLAYER_INVENTORY.inventories then
        for t, inv in pairs(PLAYER_INVENTORY.inventories) do
            local lv = inv.listView or inv.list
            if lv then SP_HookListView(lv, "playerInv[" .. t .. "]") end
        end
    end

    -- Banque (BANKING_INVENTORY est un ZO_SharedInventory)
    if BANKING_INVENTORY and BANKING_INVENTORY.inventories then
        for t, inv in pairs(BANKING_INVENTORY.inventories) do
            local lv = inv.listView or inv.list
            if lv then SP_HookListView(lv, "bank[" .. t .. "]") end
        end
    end

    -- Banque de guilde — deux objets possibles selon la version d'ESO
    for _, obj in ipairs(SP_GetGuildBankObjects()) do
        if obj then
            -- Cas 1 : objet avec .inventories (ZO_SharedInventory-like)
            if obj.inventories then
                for t, inv in pairs(obj.inventories) do
                    local lv = inv.listView or inv.list
                    if lv then SP_HookListView(lv, "guildBank[" .. t .. "]") end
                end
            end
            -- Cas 2 : objet avec .control (scene manager based)
            if obj.control then
                local ctrl = obj.control
                -- Cherche un enfant ScrollList typique
                for _, childName in ipairs({ "ItemList", "List", "ScrollList" }) do
                    local child = ctrl:GetNamedChild(childName)
                    if child and child.dataTypes then
                        SP_HookListView(child, "guildBankCtrl/" .. childName)
                    end
                end
            end
        end
    end
end

-- Fallback global : hook tous les ZO_ScrollList_Commit via SecurePostHook
local SP_COMMIT_EXCLUDE = {
    Chat=true, Action=true, Keybind=true, Quest=true, Map=true,
    Buff=true, Skill=true, Ability=true, Effect=true, Alert=true,
    HUD=true, Gamepad=true, Contacts=true, Guild=true, Group=true,
}
local function SP_HookCommit()
    SecurePostHook("ZO_ScrollList_Commit", function(lc)
        if not lc then return end
        local name = lc:GetName() or ""
        for pattern in pairs(SP_COMMIT_EXCLUDE) do
            if name:find(pattern) then return end
        end
        if not lc.dataTypes then return end
        SP_HookListView(lc, "commit/" .. name)
    end)
end

-- ──────────────────────────────────────────────────────────────
--  RefreshAll — reparse tous les slots visibles
-- ──────────────────────────────────────────────────────────────
local function RefreshAll()
    zo_callLater(function()
        -- Retourne tous les badges actifs dans le pool en une seule passe
        for _, e in ipairs(activeBadges) do
            e.badge:SetHidden(true)
            badgePool[#badgePool + 1] = e.badge
        end
        activeBadges = {}
        rowToEntry   = {}

        -- Inventaire perso, banque, équipement
        if PLAYER_INVENTORY and PLAYER_INVENTORY.inventories then
            local bags = {
                { inv = INVENTORY_BACKPACK },
                { inv = INVENTORY_BANK     },
                { inv = INVENTORY_EQUIPMENT},
            }
            -- Craft bag optionnel
            if INVENTORY_CRAFT_BAG then
                table.insert(bags, { inv = INVENTORY_CRAFT_BAG })
            end
            for _, e in ipairs(bags) do
                local inv = PLAYER_INVENTORY.inventories[e.inv]
                if inv and inv.slots then
                    for _, sd in pairs(inv.slots) do
                        if sd and sd.slotControl then
                            pcall(SP_ApplyBadge, sd.slotControl)
                        end
                    end
                end
            end
        end

        -- Banque de guilde
        for _, obj in ipairs(SP_GetGuildBankObjects()) do
            if obj and obj.inventories then
                for _, inv in pairs(obj.inventories) do
                    local lv = inv.listView or inv.list
                    if lv then
                        -- Re-commit déclenche les setupCallback déjà hookés
                        pcall(ZO_ScrollList_Commit, lv)
                    end
                    if inv.slots then
                        for _, sd in pairs(inv.slots) do
                            if sd and sd.slotControl then
                                pcall(SP_ApplyBadge, sd.slotControl)
                            end
                        end
                    end
                end
            end
        end
    end, 300)
end

-- ──────────────────────────────────────────────────────────────
--  Événements
-- ──────────────────────────────────────────────────────────────
local function HookInventorySlots()
    SP_HookCommit()

    -- Mise à jour d'un seul slot (loot, vente, craft…)
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_INVENTORY_SINGLE_SLOT_UPDATE,
        function(_, bagId, slotIndex, isNewItem)
            if isNewItem then
                local link = GetItemLink(bagId, slotIndex, LINK_STYLE_BRACKETS)
                if link then priceCache[link] = nil end
            end
            -- Retrouve le slotControl correspondant
            local function tryRefreshSlot(invType)
                if not PLAYER_INVENTORY then return end
                local inv = PLAYER_INVENTORY.inventories[invType]
                local sd  = inv and inv.slots and inv.slots[slotIndex]
                if sd and sd.slotControl then
                    pcall(SP_ApplyBadge, sd.slotControl)
                end
            end
            if bagId == BAG_BACKPACK then tryRefreshSlot(INVENTORY_BACKPACK)
            elseif bagId == BAG_BANK  then tryRefreshSlot(INVENTORY_BANK)
            elseif bagId == BAG_WORN  then tryRefreshSlot(INVENTORY_EQUIPMENT)
            end
        end)

    -- Joueur activé (chargement initial, changement de zone)
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_PA", EVENT_PLAYER_ACTIVATED, function()
        zo_callLater(function() SP_HookAll(); RefreshAll() end, 500)
    end)

    -- Joueur désactivé (déconnexion, changement de personnage, /reloadui)
    -- C'est le moment idéal pour vider le cache : plus besoin des prix,
    -- ils seront reconstruits proprement à la prochaine connexion
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_PD", EVENT_PLAYER_DEACTIVATED, function()
        priceCache = {}
        DBG("Cache vidé (déconnexion)")
    end)

    -- Ouverture de la banque perso
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_Bank", EVENT_OPEN_BANK, function()
        SP_HookAll(); zo_callLater(RefreshAll, 200)
    end)

    -- Ouverture de la banque de guilde
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_GBank", EVENT_OPEN_GUILD_BANK, function()
        SP_HookAll(); zo_callLater(RefreshAll, 200)
    end)

    -- Fermeture de la banque de guilde : libère les badges guild bank
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_GBankClose", EVENT_CLOSE_GUILD_BANK, function()
        for _, e in ipairs(activeBadges) do
            if e.row then
                local bagId = SP_GetBagSlot(e.row)
                if bagId ~= nil and bagId == BAG_GUILDBANK then
                    e.badge:SetHidden(true)
                end
            end
        end
    end)

    VM.RefreshAll = RefreshAll
    VM.HookAll    = SP_HookAll
end

-- ──────────────────────────────────────────────────────────────
--  Menu LAM
-- ──────────────────────────────────────────────────────────────
local function BuildSettingsMenu()
    LAM:RegisterAddonPanel(ADDON_NAME .. "Panel", {
        type                = "panel",
        name                = SmartPricer_STR("LAM_PANEL_NAME"),
        displayName         = "|c00FF7FSmart|cFFD700Pricer|r",
        author              = SmartPricer_STR("LAM_AUTHOR"),
        version             = "1.1.0",
        slashCommand        = "/sp",
        registerForRefresh  = true,
        registerForDefaults = true,
    })
    LAM:RegisterOptionControls(ADDON_NAME .. "Panel", {
        {
            type    = "checkbox",
            name    = SmartPricer_STR("LAM_ENABLED"),
            getFunc = function() return VM.savedVars.enabled end,
            setFunc = function(v) VM.savedVars.enabled = v; VM.RefreshAll() end,
            default = defaults.enabled,
        },
        {
            type    = "checkbox",
            name    = SmartPricer_STR("LAM_FILTER_EQUIP"),
            tooltip = SmartPricer_STR("LAM_FILTER_EQUIP_TT"),
            getFunc = function() return VM.savedVars.filterEquipmentOnly end,
            setFunc = function(v)
                VM.savedVars.filterEquipmentOnly = v
                priceCache = {}
                for _, e in ipairs(activeBadges) do
                    e.badge:SetHidden(true)
                    badgePool[#badgePool + 1] = e.badge
                end
                activeBadges = {}
                rowToEntry   = {}
                hookedLists  = {}
                VM.HookAll()
                VM.RefreshAll()
            end,
            default = defaults.filterEquipmentOnly,
        },
        { type = "divider" },
        -- ── Palier 1 ─────────────────────────────────────────────
        { type = "header", name = SmartPricer_STR("LAM_TIER1_HEADER") },
        {
            type    = "editbox",
            name    = SmartPricer_STR("LAM_TIER1_THRESHOLD"),
            tooltip = SmartPricer_STR("LAM_TIER1_TT"),
            getFunc = function() return tostring(VM.savedVars.tiers[1].price) end,
            setFunc = function(v)
                local n = tonumber(v)
                if n and n > 0 then
                    VM.savedVars.tiers[1].price = math.floor(n)
                    priceCache = {}
                    VM.RefreshAll()
                end
            end,
            default = tostring(defaults.tiers[1].price),
        },
        { type = "divider" },
        -- ── Palier 2 ─────────────────────────────────────────────
        { type = "header", name = SmartPricer_STR("LAM_TIER2_HEADER") },
        {
            type    = "checkbox",
            name    = SmartPricer_STR("LAM_TIER2_ENABLE"),
            tooltip = SmartPricer_STR("LAM_TIER2_ENABLE_TT"),
            getFunc = function() return VM.savedVars.tiers[2].enabled end,
            setFunc = function(v) VM.savedVars.tiers[2].enabled = v; VM.RefreshAll() end,
            default = defaults.tiers[2].enabled,
        },
        {
            type    = "editbox",
            name    = SmartPricer_STR("LAM_TIER2_THRESHOLD"),
            getFunc = function() return tostring(VM.savedVars.tiers[2].price) end,
            setFunc = function(v)
                local n = tonumber(v)
                if n and n > 0 then
                    VM.savedVars.tiers[2].price = math.floor(n)
                    priceCache = {}
                    VM.RefreshAll()
                end
            end,
            default = tostring(defaults.tiers[2].price),
            disabled = function() return not VM.savedVars.tiers[2].enabled end,
        },
        { type = "divider" },
        -- ── Palier 3 ─────────────────────────────────────────────
        { type = "header", name = SmartPricer_STR("LAM_TIER3_HEADER") },
        {
            type    = "checkbox",
            name    = SmartPricer_STR("LAM_TIER3_ENABLE"),
            tooltip = SmartPricer_STR("LAM_TIER3_ENABLE_TT"),
            getFunc = function() return VM.savedVars.tiers[3].enabled end,
            setFunc = function(v) VM.savedVars.tiers[3].enabled = v; VM.RefreshAll() end,
            default = defaults.tiers[3].enabled,
        },
        {
            type    = "editbox",
            name    = SmartPricer_STR("LAM_TIER3_THRESHOLD"),
            getFunc = function() return tostring(VM.savedVars.tiers[3].price) end,
            setFunc = function(v)
                local n = tonumber(v)
                if n and n > 0 then
                    VM.savedVars.tiers[3].price = math.floor(n)
                    priceCache = {}
                    VM.RefreshAll()
                end
            end,
            default = tostring(defaults.tiers[3].price),
            disabled = function() return not VM.savedVars.tiers[3].enabled end,
        },
        { type = "divider" },
        {
            type    = "checkbox",
            name    = SmartPricer_STR("LAM_DEBUG"),
            getFunc = function() return VM.savedVars.debugMode end,
            setFunc = function(v) VM.savedVars.debugMode = v end,
            default = defaults.debugMode,
        },
        {
            type = "button",
            name = SmartPricer_STR("LAM_REFRESH"),
            func = function()
                priceCache = {}
                for _, e in ipairs(activeBadges) do
                    e.badge:SetHidden(true)
                    badgePool[#badgePool + 1] = e.badge
                end
                activeBadges = {}; rowToEntry = {}; hookedLists = {}
                VM.HookAll(); VM.RefreshAll()
                CHAT_SYSTEM:AddMessage("|c00FF7FSmartPricer|r " .. SmartPricer_STR("SLASH_REFRESHED"))
            end,
        },
        {
            type  = "description",
            title = SmartPricer_STR("LAM_TTC_TITLE"),
            text  = function()
                local TTC = TamrielTradeCentrePrice or TamrielTradeCentre
                if TTC and TTC.GetPriceInfo then return SmartPricer_STR("LAM_TTC_OK")
                elseif TTC                  then return SmartPricer_STR("LAM_TTC_WARN")
                else                             return SmartPricer_STR("LAM_TTC_KO")
                end
            end,
        },
    })
end

-- ──────────────────────────────────────────────────────────────
--  Point d'entrée
-- ──────────────────────────────────────────────────────────────
local function OnAddOnLoaded(_, addonName)
    if addonName ~= ADDON_NAME then return end
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)

    VM.savedVars = ZO_SavedVars:NewAccountWide("SmartPricerSavedVars", 22, nil, defaults)

    SP_InitTLC()
    BuildSettingsMenu()
    HookInventorySlots()
    SP_SetupOnUpdate()
    SP_SetupSceneListeners()

    local TTC = TamrielTradeCentrePrice or TamrielTradeCentre
    CHAT_SYSTEM:AddMessage("|c00FF7FSmartPricer|r " .. SmartPricer_STR("STARTUP")
        .. (TTC and TTC.GetPriceInfo and SmartPricer_STR("TTC_OK") or SmartPricer_STR("TTC_ABSENT")))
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)

-- ──────────────────────────────────────────────────────────────
--  Commandes slash
-- ──────────────────────────────────────────────────────────────
SLASH_COMMANDS["/sp"] = function(args)
    args = (args or ""):lower():match("^%s*(.-)%s*$")
    if args == "on" then
        VM.savedVars.enabled = true; VM.RefreshAll()
        CHAT_SYSTEM:AddMessage("|c00FF7FSmartPricer|r " .. SmartPricer_STR("SLASH_ENABLED"))
    elseif args == "off" then
        VM.savedVars.enabled = false; VM.RefreshAll()
        CHAT_SYSTEM:AddMessage("|c00FF7FSmartPricer|r " .. SmartPricer_STR("SLASH_DISABLED"))
    elseif args == "cache" then
        priceCache = {}; VM.RefreshAll()
        CHAT_SYSTEM:AddMessage("|c00FF7FSmartPricer|r " .. SmartPricer_STR("SLASH_CACHE_CLEAR"))
    elseif args == "debug" then
        VM.savedVars.debugMode = not VM.savedVars.debugMode
        CHAT_SYSTEM:AddMessage(VM.savedVars.debugMode
            and SmartPricer_STR("SLASH_DEBUG_ON")
            or  SmartPricer_STR("SLASH_DEBUG_OFF"))
    elseif args == "hook" then
        hookedLists = {}; VM.HookAll(); VM.RefreshAll()
        CHAT_SYSTEM:AddMessage("|c00FF7FSmartPricer|r " .. SmartPricer_STR("SLASH_HOOKED"))
    elseif args == "settings" then
        LAM:OpenToPanel(ADDON_NAME .. "Panel")
    elseif args:match("^seuil %d+$") or args:match("^threshold %d+$") then
        local n = tonumber(args:match("%d+"))
        if n and n > 0 then
            VM.savedVars.tiers[1].price = math.floor(n); priceCache = {}; VM.RefreshAll()
            CHAT_SYSTEM:AddMessage(SmartPricer_STR("SLASH_SEUIL") .. FormatGold(n) .. "|r")
        end
    else
        CHAT_SYSTEM:AddMessage(SmartPricer_STR("SLASH_HELP"))
    end
end
