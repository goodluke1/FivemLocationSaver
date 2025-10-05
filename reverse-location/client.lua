local function sendCoords()
    local ped = PlayerPedId()
    if not ped or ped == 0 then return end
    local coords = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)
    TriggerServerEvent('reverse-location:updatePosition', coords.x, coords.y, coords.z, heading)
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(9000)
        sendCoords()
    end
end)

AddEventHandler('playerSpawned', function()
    Citizen.Wait(3000)
    TriggerServerEvent('reverse-location:requestCoords')
end)

RegisterNetEvent('reverse-location:teleport', function(x, y, z, h)
    local ped = PlayerPedId()
    if not ped or ped == 0 then return end
    SetEntityCoords(ped, x, y, z, false, false, false, false)
    SetEntityHeading(ped, h or 0.0)
end)
