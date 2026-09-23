-- Portable Lua 5.1 SHA-256. No bit library, filesystem, or external service.
PBWT = PBWT or {}
local floor, mod = math.floor, 4294967296
local function band(a, b)
    local n, p = 0, 1
    for _ = 1, 32 do
        if a % 2 == 1 and b % 2 == 1 then n = n + p end
        a, b, p = floor(a / 2), floor(b / 2), p * 2
    end
    return n
end
local function xor(a, b) return (a + b - 2 * band(a, b)) % mod end
local function xor3(a, b, c) return xor(xor(a, b), c) end
local function shr(a, n) return floor(a / 2 ^ n) end
local function ror(a, n) return shr(a, n) + (a % 2 ^ n) * 2 ^ (32 - n) end
local K = {
    0x428a2f98,0x71374491,0xb5c0fbcf,0xe9b5dba5,0x3956c25b,0x59f111f1,0x923f82a4,0xab1c5ed5,
    0xd807aa98,0x12835b01,0x243185be,0x550c7dc3,0x72be5d74,0x80deb1fe,0x9bdc06a7,0xc19bf174,
    0xe49b69c1,0xefbe4786,0x0fc19dc6,0x240ca1cc,0x2de92c6f,0x4a7484aa,0x5cb0a9dc,0x76f988da,
    0x983e5152,0xa831c66d,0xb00327c8,0xbf597fc7,0xc6e00bf3,0xd5a79147,0x06ca6351,0x14292967,
    0x27b70a85,0x2e1b2138,0x4d2c6dfc,0x53380d13,0x650a7354,0x766a0abb,0x81c2c92e,0x92722c85,
    0xa2bfe8a1,0xa81a664b,0xc24b8b70,0xc76c51a3,0xd192e819,0xd6990624,0xf40e3585,0x106aa070,
    0x19a4c116,0x1e376c08,0x2748774c,0x34b0bcb5,0x391c0cb3,0x4ed8aa4a,0x5b9cca4f,0x682e6ff3,
    0x748f82ee,0x78a5636f,0x84c87814,0x8cc70208,0x90befffa,0xa4506ceb,0xbef9a3f7,0xc67178f2,
}
function PBWT.SHA256(text)
    local bytes = { text:byte(1, #text) }
    local bits = #bytes * 8
    bytes[#bytes + 1] = 128
    while #bytes % 64 ~= 56 do bytes[#bytes + 1] = 0 end
    for i = 7, 0, -1 do bytes[#bytes + 1] = floor(bits / 256 ^ i) % 256 end
    local h = {0x6a09e667,0xbb67ae85,0x3c6ef372,0xa54ff53a,0x510e527f,0x9b05688c,0x1f83d9ab,0x5be0cd19}
    for offset = 1, #bytes, 64 do
        local w = {}
        for i = 0, 15 do
            local j = offset + i * 4
            w[i] = bytes[j] * 16777216 + bytes[j+1] * 65536 + bytes[j+2] * 256 + bytes[j+3]
        end
        for i = 16, 63 do
            local x, y = w[i-15], w[i-2]
            w[i] = (w[i-16] + xor3(ror(x,7),ror(x,18),shr(x,3)) + w[i-7] + xor3(ror(y,17),ror(y,19),shr(y,10))) % mod
        end
        local a,b,c,d,e,f,g,hh = h[1],h[2],h[3],h[4],h[5],h[6],h[7],h[8]
        for i = 0, 63 do
            local t1 = (hh + xor3(ror(e,6),ror(e,11),ror(e,25)) + xor(band(e,f),band(mod-1-e,g)) + K[i+1] + w[i]) % mod
            local t2 = (xor3(ror(a,2),ror(a,13),ror(a,22)) + xor3(band(a,b),band(a,c),band(b,c))) % mod
            hh,g,f,e,d,c,b,a = g,f,e,(d+t1)%mod,c,b,a,(t1+t2)%mod
        end
        local state = {a,b,c,d,e,f,g,hh}
        for i=1,8 do h[i]=(h[i]+state[i])%mod end
    end
    local out = {}
    for i=1,8 do out[i]=string.format("%08x",h[i]) end
    return table.concat(out)
end
