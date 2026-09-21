local A = ESOBuildTracker
local function Plain(value)
    if value == nil then return "Unavailable" end
    return tostring(value):gsub("|c%x%x%x%x%x%x", ""):gsub("|r", ""):gsub("%^%a+", "")
end
function A.ExportText(snapshot)
    local lines = { "ESO Build Tracker " .. A.version, Plain(snapshot.characterName),
        "Captured: " .. A.CaptureTimeText(snapshot), "Server: " .. Plain(snapshot.world),
        "Level " .. Plain(snapshot.level) .. " / CP " .. Plain(snapshot.championPoints), "", "EQUIPPED GEAR" }
    for _, item in ipairs(snapshot.equipment) do
        lines[#lines + 1] = Plain(item.slotLabel) .. ": " .. (item.status == "equipped" and Plain(item.name) or Plain(item.status))
        if item.status == "equipped" then
            lines[#lines + 1] = "  Set: " .. Plain(item.set and item.set.name or item.noSet and "None" or nil)
            lines[#lines + 1] = "  " .. Plain(item.qualityName) .. "; " .. Plain(item.traitName) .. "; level " .. Plain(item.requiredLevel) .. "; CP " .. Plain(item.requiredCP)
            if item.armorTypeName then lines[#lines + 1] = "  Armor: " .. Plain(item.armorTypeName) end
            if item.weaponTypeName then lines[#lines + 1] = "  Weapon: " .. Plain(item.weaponTypeName) end
            lines[#lines + 1] = "  Enchant: " .. (item.enchantReadComplete and Plain(item.enchantName) or "Unavailable")
            if item.enchantDescription then lines[#lines + 1] = "  " .. Plain(item.enchantDescription) end
        end
    end
    for _, bar in ipairs(snapshot.bars) do
        lines[#lines + 1] = "\n" .. Plain(bar.label)
        for index, skill in ipairs(bar.slots) do
            lines[#lines + 1] = (skill.ultimate and "Ultimate" or tostring(index)) .. ": " .. (skill.status == "slotted" and Plain(skill.name) or Plain(skill.status))
            if skill.rank then lines[#lines + 1] = "  Rank: " .. Plain(skill.rank) end
            for _, script in ipairs(skill.scripts or {}) do lines[#lines + 1] = "  Script: " .. Plain(script.name) end
        end
    end
    lines[#lines + 1] = "\nSTATS - " .. A.ActiveBarName(snapshot) .. " at capture; buffs affect totals"
    for _, stat in ipairs(snapshot.stats or {}) do lines[#lines + 1] = Plain(stat.label) .. ": " .. Plain(stat.value) end
    for _, warning in ipairs(snapshot.warnings or {}) do lines[#lines + 1] = "Warning: " .. Plain(warning) end
    return table.concat(lines, "\n")
end
function A.ExportChecksum(text)
    local a, b = 1, 0
    for i = 1, #text do a = (a + text:byte(i)) % 65521; b = (b + a) % 65521 end
    return string.format("%08X", b * 65536 + a)
end
function A.ExportPackets(text)
    local chunks, size, id = {}, 400, A.ExportChecksum(text)
    local total = math.ceil(#text / size)
    if total > 128 then return nil, "Export exceeds 128 pages; no data was truncated." end
    for i = 1, total do
        local chunk = text:sub((i - 1) * size + 1, i * size):gsub(".", function(c) return string.format("%02X", c:byte()) end)
        chunks[i] = "EBT1:" .. id .. ":" .. i .. ":" .. total .. ":" .. chunk
    end
    return chunks
end
function A.OpenExport()
    if not A.Refresh("export current setup") or not A.live then A.Notify("Could not capture current setup."); return end
    local text = A.ExportText(A.live)
    local packets, err = A.ExportPackets(text)
    if not packets then A.Notify(err); return end
    local rows = {}
    for index, packet in ipairs(packets) do
        local row = A.Row("Export page " .. index .. " / " .. #packets, "Screenshot this QR page", "")
        row.qrPacket = packet
        rows[#rows + 1] = row
    end
    A.OpenMenu("Export current setup", rows)
end
function A.RenderExportQR(row)
    if A.ui.qr then A.ui.qr.root:SetHidden(true) end
    A.ui.body:SetHidden(false)
    if not row or not row.qrPacket then return end
    local ok, success, matrix = pcall(A.EncodeQR, row.qrPacket, 2)
    if not ok or not success then A.ui.body:SetText("QR generation failed; " .. tostring(ok and matrix or success)); return end
    if not A.ui.qr then
        local root = WINDOW_MANAGER:CreateControl("ESOBuildTrackerQR", A.ui.root, CT_BACKDROP)
        root:SetAnchor(TOPLEFT, A.ui.body, TOPLEFT, 0, 0)
        root:SetCenterColor(1, 1, 1, 1)
        A.ui.qr = { root = root, runs = {} }
    end
    local qr = A.ui.qr
    local width, height = A.ui.body:GetDimensions()
    local cell = math.floor(math.min(width, height) / (#matrix + 8))
    if cell < 2 then A.ui.body:SetText("QR area too small. Increase display resolution or reduce UI scale."); return end
    for _, control in ipairs(qr.runs) do control:SetHidden(true) end
    qr.root:SetDimensions((#matrix + 8) * cell, (#matrix + 8) * cell)
    qr.root:SetHidden(false); A.ui.body:SetHidden(true)
    local count = 0
    for y = 1, #matrix do
        local x = 1
        while x <= #matrix do
            if matrix[x][y] > 0 then
                local start = x
                repeat x = x + 1 until x > #matrix or matrix[x][y] <= 0
                count = count + 1
                local run = qr.runs[count]
                if not run then
                    run = WINDOW_MANAGER:CreateControl("ESOBuildTrackerQRRun" .. count, qr.root, CT_BACKDROP)
                    run:SetCenterColor(0, 0, 0, 1); qr.runs[count] = run
                end
                run:ClearAnchors()
                run:SetAnchor(TOPLEFT, qr.root, TOPLEFT, (start + 3) * cell, (y + 3) * cell)
                run:SetDimensions((x - start) * cell, cell); run:SetHidden(false)
            else x = x + 1 end
        end
    end
end
