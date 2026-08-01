-- DC base in IC

local function textExample()
    local anchor = TOP
    local position = LibImplex.Vector({5230, 14060, 155820})
    local orientation = {0, math.pi, 0, true}
    local size = 2
    local color = {0, 100 / 255, 0}
    local maxWidth = 600
    local outline = false
    local font = LibImplex.Fonts.Univers67

    -- local testString = "абвгдеёжзийклмнопрст уфхцчшщъыьэюяАБВГДЕЁЖЗИ ЙКЛМНОП Р СТУФХЦЧШЩЪЫЬЭЮЯ"
    local testString = "abcdefghijklmop qrstuvwxyz ABCDEFGHIJKLMNOP QRSTUVWXYZ"

    -- testString = "Р"
    -- d({testString:byte(1, #testString)})
    -- d('-------')

    -- for s in testString:gmatch('%S+') do
    --     d(s)
    --     d({s:byte(1, #s)})
    -- end

    local text = LibImplex.Text(testString, anchor, position, orientation, size, color, maxWidth, outline, nil, font)
    text:Render()
end


do
    EVENT_MANAGER:RegisterForEvent('LIB_IMPLEX_EXAMPLES_TEXT', EVENT_PLAYER_ACTIVATED, textExample)
end
