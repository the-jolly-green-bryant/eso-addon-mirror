local EsoKRLite = EsoKRLite or {}
EsoKRLite.name = "EsoKRLite"
EsoKRLite.chat = { privCursorPos = 0, editing = false }
EsoKRLite.version = "0.1.3"

local function chsize(char)
    if not char then return 0
    elseif char > 240 then return 4
    elseif char > 225 then return 3
    elseif char > 192 then return 2
    else return 1
    end
end

function EsoKRLite:con2CNKR(texts)
    local temp = ""
    local scanleft = 0
    local result = ""
    local num = 0
    local hashan = false;

    text = texts
    if(texts == nil) then text = "" end
    for i in string.gmatch(text, ".") do
        local r = ""
        byte = string.byte(i)
        hex = string.format('%02X', byte)
        if scanleft > 0 then
            temp = temp .. hex
            scanleft = scanleft - 1
            if scanleft == 0 then
                temp = tonumber(temp, 16)
                if temp >= 0xE18480 and temp <= 0xE187BF then
                    temp = temp + 0x43400
                elseif temp > 0xe384b0 and temp <= 0xe384bf then
                    temp = temp + 0x237d0
                elseif temp > 0xe38580 and temp <= 0xe3868f then
                    temp = temp + 0x23710
                elseif temp >= 0xeab080 and temp <= 0xed9eac then
                    if temp >= 0xeab880 and temp <= 0xeabfbf then
                        temp = temp - 0x33800
                    elseif temp >= 0xebb880 and temp <= 0xebbfbf then
                        temp = temp - 0x33800
                    elseif temp >= 0xECB880 and temp <= 0xECBFBF then
                        temp = temp - 0x33800
                    else
                        temp = temp - 0x3f800
                    end
                end
                temp = string.format('%02X', temp)
                r = (temp:gsub('..', function (cc) return string.char(tonumber(cc, 16)) end))
                temp = ""
                hashan = true
                num = num + 1
            end
        else
            if byte > 224 and byte <= 239 then
                -- 3 bytes
                scanleft = 2
                temp = hex
            else
                r = i
                num = num + 1
            end
        end
        result = result .. r
        --end
    end
    return result
end

local function utfstrlen(str, targetlen)
    local len = #str;
    local left = len;
    local cnt = 0;
    local arr={0,0xc0,0xe0,0xf0,0xf8,0xfc};
    while left ~= 0 do
        local tmp=string.byte(str,-left);
        local i=#arr;
        while arr[i] do
            if tmp>=arr[i] then left=left-i;break;end
            i=i-1;
        end
        cnt=cnt+1;
    end
    return cnt;
end

local function init(eventCode, addOnName)
    ZO_PreHook("ZO_ChatTextEntry_Execute", function(control) control.system:CloseTextEntry(true) end)
    ZO_PreHook("ZO_ChatTextEntry_Escape", function(control) control.system:CloseTextEntry(true) end)
    ZO_PreHook("ZO_ChatTextEntry_TextChanged", function(control, newText) EsoKRLite:Convert(control.system.textEntry) end)
    ZO_PreHook("ZO_EditDefaultText_OnTextChanged", function(edit) EsoKRLite:Convert(edit) end)
end

function EsoKRLite:Convert(edit)
    if EsoKRLite.chat.editing then return end
    local cursorPos = edit:GetCursorPosition()
    if cursorPos ~= EsoKRLite.chat.privCursorPos and cursorPos ~= 0 then
        EsoKRLite.chat.editing = true
        local text = EsoKRLite:con2CNKR(edit:GetText())
        edit:SetText(text)
        if(cursorPos < utfstrlen(text)) then edit:SetCursorPosition(cursorPos) end
        EsoKRLite.chat.editing = false
    end
    EsoKRLite.chat.privCursorPos = cursorPos
end

local function onAddonLoaded(eventCode, addOnName)
    if(addOnName ~= EsoKRLite.name) then return end
    init(eventCode, addOnName)
    EVENT_MANAGER:UnregisterForEvent(EsoKRLite.name, EVENT_ADD_ON_LOADED)
end

EVENT_MANAGER:RegisterForEvent(EsoKRLite.name, EVENT_ADD_ON_LOADED, onAddonLoaded)