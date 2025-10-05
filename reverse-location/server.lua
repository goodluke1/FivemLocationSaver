local lastCoords = {}

---@param userId number
---@param x number
---@param y number
---@param z number
---@param h number
local function savePosition(userId, x, y, z, h)
    exports.oxmysql:query(
        'INSERT INTO player_positions (user_id, x, y, z, heading) VALUES (?, ?, ?, ?, ?) ON DUPLICATE KEY UPDATE x = VALUES(x), y = VALUES(y), z = VALUES(z), heading = VALUES(heading)',
        { userId, x, y, z, h }
    )
end


RegisterNetEvent('reverse-location:updatePosition', function(x, y, z, h)
    local src = source
    local userId = exports['reverse-core']:getPlayerId(src)
    if not userId then return end

    lastCoords[src] = { x = x, y = y, z = z, h = h }
    savePosition(userId, x, y, z, h)
end)

AddEventHandler('playerDropped', function()
    local src = source
    local coords = lastCoords[src]
    if not coords then return end
    local userId = exports['reverse-core']:getPlayerId(src)
    if not userId then return end
    savePosition(userId, coords.x, coords.y, coords.z, coords.h)
    lastCoords[src] = nil
end)

RegisterNetEvent('reverse-location:requestCoords', function()
    local src = source
    local userId = exports['reverse-core']:getPlayerId(src)
    if not userId then return end

    exports.oxmysql:query('SELECT x, y, z, heading FROM player_positions WHERE user_id = ? LIMIT 1', { userId },
        function(result)
            if result and result[1] then
                TriggerClientEvent('reverse-location:teleport', src, result[1].x, result[1].y, result[1].z,
                    result[1].heading)
            end
        end)
end)
