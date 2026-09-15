-- ESO Adventurer Suite
-- v0.29.535 - Bank Withdraw/Deposit mode-switch root reuse.
-- Reuse the working V2 bank grid instead of creating duplicate named controls
-- when ESO changes the active bank pane/parent.

local EPC = ESOProgressionCoach
if not EPC then return end
local U = EPC.BankGridUnifiedV2
if not U then return end

local baseCreateFor = U.CreateFor

local function forceHigh(control, level)
    if not control then return end
    if type(control.SetAlpha) == "function" then pcall(control.SetAlpha, control, 1) end
    if type(control.SetDrawTier) == "function" and rawget(_G, "DT_HIGH") ~= nil then
        pcall(control.SetDrawTier, control, DT_HIGH)
    end
    if type(control.SetDrawLayer) == "function" and rawget(_G, "DL_OVERLAY") ~= nil then
        pcall(control.SetDrawLayer, control, DL_OVERLAY)
    end
    if type(control.SetDrawLevel) == "function" then pcall(control.SetDrawLevel, control, level or 900) end
end

function U:CreateFor(info)
    if type(info) ~= "table" or not info.control then return end

    local parent = nil
    if type(info.control.GetParent) == "function" then
        local ok, value = pcall(info.control.GetParent, info.control)
        if ok then parent = value end
    end
    parent = parent or rawget(_G, "GuiRoot")

    -- First bank pane: let V2 create the one named control pool normally.
    if not self.root then
        return baseCreateFor(self, info)
    end

    -- Later Withdraw <-> Deposit switches must reuse that pool. ESO controls are
    -- globally named, so creating EASBankUnifiedRoot029534 twice throws the
    -- duplicate-name error reported by the client.
    if parent and self.parent ~= parent and type(self.root.SetParent) == "function" then
        pcall(self.root.SetParent, self.root, parent)
    end
    self.parent = parent

    -- Re-anchor the existing root to whichever live bank list is active now.
    if type(self.root.ClearAnchors) == "function" then pcall(self.root.ClearAnchors, self.root) end
    if type(self.root.SetAnchor) == "function" then
        pcall(self.root.SetAnchor, self.root, TOPLEFT, info.control, TOPLEFT, 0, 0)
        pcall(self.root.SetAnchor, self.root, BOTTOMRIGHT, info.control, BOTTOMRIGHT, 0, 0)
    end

    if type(self.root.SetHidden) == "function" then pcall(self.root.SetHidden, self.root, false) end
    if type(self.root.SetMouseEnabled) == "function" then pcall(self.root.SetMouseEnabled, self.root, true) end
    forceHigh(self.root, 900)
    forceHigh(self.bg, 901)
    forceHigh(self.title, 902)

    -- Headers/cells are children of the reused root, so they move with it and
    -- retain their globally unique names. Reassert their visual state after the
    -- parent change because ESO/PerfectPixel can refresh the bank scene here.
    for _, h in ipairs(self.headers or {}) do
        if h then
            forceHigh(h, 920)
            forceHigh(h.bg, 921)
            forceHigh(h.label, 922)
        end
    end
    for _, c in ipairs(self.cells or {}) do
        if c then
            forceHigh(c, 930)
            forceHigh(c.bg, 931)
            forceHigh(c.icon, 932)
            forceHigh(c.count, 933)
        end
    end
end
