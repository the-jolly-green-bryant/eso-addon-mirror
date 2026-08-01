function Int8(value)
    return Int:new(8, true, value)
end

function Int16(value)
    return Int:new(16, true, value)
end

function Int32(value)
    return Int:new(32, true, value)
end

function Int64(value)
    return Int:new(64, true, value)
end

function uInt8(value)
    return Int:new(8, false, value)
end

function uInt16(value)
    return Int:new(16, false, value)
end

function uInt32(value)
    return Int:new(32, false, value)
end

function uInt64(value)
    return Int:new(64, false, value)
end

sbyte = Int8
short = Int16
int = Int32
long = Int64
byte = uInt8
ushort = uInt16
uint = uInt32
ulong = uInt64