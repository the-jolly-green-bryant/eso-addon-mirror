--- UI control stubs generated from UnDeadGroupMod.xml
--- Purpose: silence LuaLS undefined-global diagnostics for XML-created globals.
--- These lines simply re-reference the globals so the language server knows they exist.
---@diagnostic disable: undefined-global

---@class Control
---@field SetHidden fun(self:Control, hidden:boolean)
---@field SetAnchor fun(self:Control, point:any, relativeTo:any, relativePoint:any, offsetX:number, offsetY:number)
---@field ClearAnchors fun(self:Control)
---@field SetText fun(self:Control, text:any)  -- widen 'text' to any to avoid SetText warnings

-- Provide empty no-op implementations only for language server (never executed differently at runtime)
if false then
    ---@diagnostic disable-next-line: duplicate-set-field
    function Control:SetHidden(hidden) end

    ---@diagnostic disable-next-line: duplicate-set-field
    function Control:SetAnchor(point, relativeTo, relativePoint, offsetX, offsetY) end

    ---@diagnostic disable-next-line: duplicate-set-field
    function Control:ClearAnchors() end

    function Control:SetText(text) end
end

---@type Control UnDeadGroupModIndicator
UnDeadGroupModIndicator = UnDeadGroupModIndicator
---@type Control UnDeadGroupModIndicatorButtonOptions
UnDeadGroupModIndicatorButtonOptions = UnDeadGroupModIndicatorButtonOptions
---@type Control UnDeadGroupModIndicatorTitle
UnDeadGroupModIndicatorTitle = UnDeadGroupModIndicatorTitle
---@type Control UnDeadGroupModIndicatorLabel1
UnDeadGroupModIndicatorLabel1 = UnDeadGroupModIndicatorLabel1
---@type Control UnDeadGroupModIndicatorLabelRole
UnDeadGroupModIndicatorLabelRole = UnDeadGroupModIndicatorLabelRole
---@type Control UnDeadGroupModIndicatorLabel2
UnDeadGroupModIndicatorLabel2 = UnDeadGroupModIndicatorLabel2
---@type Control UnDeadGroupModIndicatorLabel3
UnDeadGroupModIndicatorLabel3 = UnDeadGroupModIndicatorLabel3
---@type Control UnDeadGroupModIndicatorLabel4
UnDeadGroupModIndicatorLabel4 = UnDeadGroupModIndicatorLabel4
---@type Control UnDeadGroupModIndicatorButton1
UnDeadGroupModIndicatorButton1 = UnDeadGroupModIndicatorButton1
---@type Control UnDeadGroupModIndicatorButtonRandom
UnDeadGroupModIndicatorButtonRandom = UnDeadGroupModIndicatorButtonRandom
---@type Control UnDeadGroupModIndicatorButtonRole
UnDeadGroupModIndicatorButtonRole = UnDeadGroupModIndicatorButtonRole
---@type Control UnDeadGroupModIndicatorButtonMyHouse
UnDeadGroupModIndicatorButtonMyHouse = UnDeadGroupModIndicatorButtonMyHouse
---@type Control UnDeadGroupModIndicatorButton2
UnDeadGroupModIndicatorButton2 = UnDeadGroupModIndicatorButton2
---@type Control UnDeadGroupModIndicatorButtonJump1
UnDeadGroupModIndicatorButtonJump1 = UnDeadGroupModIndicatorButtonJump1
---@type Control UnDeadGroupModIndicatorButtonHouse1
UnDeadGroupModIndicatorButtonHouse1 = UnDeadGroupModIndicatorButtonHouse1
---@type Control UnDeadGroupModIndicatorButton3
UnDeadGroupModIndicatorButton3 = UnDeadGroupModIndicatorButton3
---@type Control UnDeadGroupModIndicatorButtonJump2
UnDeadGroupModIndicatorButtonJump2 = UnDeadGroupModIndicatorButtonJump2
---@type Control UnDeadGroupModIndicatorButtonHouse2
UnDeadGroupModIndicatorButtonHouse2 = UnDeadGroupModIndicatorButtonHouse2
---@type Control UnDeadGroupModIndicatorButton4
UnDeadGroupModIndicatorButton4 = UnDeadGroupModIndicatorButton4
---@type Control UnDeadGroupModIndicatorButtonJump3
UnDeadGroupModIndicatorButtonJump3 = UnDeadGroupModIndicatorButtonJump3
---@type Control UnDeadGroupModIndicatorButtonHouse3
UnDeadGroupModIndicatorButtonHouse3 = UnDeadGroupModIndicatorButtonHouse3
---@type Control UnDeadGroupModIndicatorButtonLeave
UnDeadGroupModIndicatorButtonLeave = UnDeadGroupModIndicatorButtonLeave
---@type Control UnDeadGroupModIndicatorButtonDisband
UnDeadGroupModIndicatorButtonDisband = UnDeadGroupModIndicatorButtonDisband
---@type Control UnDeadGroupModIndicatorLabelReady
UnDeadGroupModIndicatorLabelReady = UnDeadGroupModIndicatorLabelReady
---@type Control UnDeadGroupModIndicatorButtonReady
UnDeadGroupModIndicatorButtonReady = UnDeadGroupModIndicatorButtonReady
