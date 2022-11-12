-- Since I'm a lazy lil shit, loading texture dict was yoinked from https://github.com/overextended/ox_lib/blob/master/resource/streaming/client.lua
-- Use their ko-fi, they deserve it more than everyone else for the work they're doing for community.
local function request(native, hasLoaded, requestType, name, timeout)
    native(name)

    if coroutine.running() then
        if not timeout then
            timeout = 500
        end

        for i = 1, timeout do
            Wait(0)
            if hasLoaded(name) then
                return name
            end
        end

        print(("Failed to load %s '%s' after %s ticks"):format(requestType, name, timeout))
    end

    return name
end

---Load a texture dictionary. When called from a thread, it will yield until it has loaded.
---@param textureDict string
---@param timeout number? Number of ticks to wait for the dictionary to load. Default is 500.
---@return string? textureDict
function requestStreamedTextureDict(textureDict, timeout)
    if HasStreamedTextureDictLoaded(textureDict) then return textureDict end
    return request(RequestStreamedTextureDict, HasStreamedTextureDictLoaded, 'textureDict', textureDict, timeout)
end

-- Get random key for current skill cycle
function getRandomKey(tbl)
    local keys = {}

    for k, _ in pairs(tbl) do
        table.insert(keys, k)
    end

    return keys[math.random(#keys)]
end

-- Convert size
function convertSize(width, height)
    local x, y = GetActiveScreenResolution()

    return width / x, height / y
end
