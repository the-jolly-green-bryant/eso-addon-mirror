local F = Chorus.Format

function F.Amount(n)
    n = math.floor(n + 0.5)
    if n < 10000 then return tostring(n) end
    if n < 100000 then return ("%.1fk"):format(n / 1000) end
    if n < 1000000 then return ("%dk"):format(math.floor(n / 1000)) end
    return ("%.2fm"):format(n / 1000000)
end

function F.Seconds(ms)
    local s = math.floor(ms / 1000 + 0.5)
    if s < 60 then return s .. " s" end
    return ("%d:%02d"):format(math.floor(s / 60), s % 60)
end

function F.CleanName(name)
    name = tostring(name or "")
    name = name:gsub("%s*%b()%s*$", "")
    return name
end
