local inFFA = false
local currentFFA = nil
local lastCoords = nil

exports("inFFA", function()
    return inFFA
end)

exports("currentFFA", function()
    return currentFFA
end)

exports("currentFFAConfig", function()
    return Config["Zones"][currentFFA]
end)

local join = function(zone)
    if inFFA then return end

    inFFA = true
    currentFFA = zone
    lastCoords = GetEntityCoords(PlayerPedId())

    TriggerServerEvent("FFA:JoinZone", zone)

    SetEntityCoords(PlayerPedId(), Config["Zones"][zone].Zone.Mitte)
end

local leave = function()
    if not inFFA then return end

    SetEntityCoords(PlayerPedId(), lastCoords)

    TriggerServerEvent("FFA:LeaveZone", currentFFA)

    SendNUIMessage({
        action = "hideStats",
    })

    currentFFA = nil
    lastCoords = nil

    inFFA = false
end

local respawn = function()
    if not inFFA then return end

    local spawns = Config["Zones"][currentFFA].Spawns
    local spawncount = #spawns
    if spawncount > 0 then
        local spawn = math.random(1, spawncount)
        local coords = spawns[spawn]

        SetEntityCoords(PlayerPedId(), vec3(coords[1], coords[2], coords[3]))
    end
end

CreateThread(function()
    while true do
        local sleep = 500
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)

        local distance = #(coords - Config["Settings"].Marker.position)

        if distance <= Config["Settings"].Marker.distance and not inFFA then
            sleep = 0
            DrawMarker(Config["Settings"].Marker.type, Config["Settings"].Marker.position, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
                Config["Settings"].Marker.size.x, Config["Settings"].Marker.size.y, Config["Settings"].Marker.size.z,
                Config["Settings"].Color.x, Config["Settings"].Color.y, Config["Settings"].Color.z, 200, true, false, 2,
                true, nil, nil, false)

            if distance <= 1.0 then
                ShowHelpNotification(Config["Settings"].HelpText)

                if IsControlJustReleased(0, 38) then
                    TriggerServerEvent("FFA:GetZones")
                end
            end
        end

        Wait(sleep)
    end
end)

RegisterNetEvent("FFA:SendZones", function(zones)
    SendNUIMessage({
        action = "open",
        config = Config,
        zones = zones
    })

    SetNuiFocus(true, true)
end)

RegisterNetEvent("FFA:SendStats", function(stats)
    SendNUIMessage({
        action = "stats",
        kills = stats.kills,
        deaths = stats.deaths,
    })
end)

RegisterNUICallback("close", function()
    SetNuiFocus(false, false)
end)

RegisterNUICallback("join", function(zone)
    join(zone)
end)

RegisterCommand("quitffa", function()
    leave()
end)

RegisterNetEvent(Config["Settings"].deathEvent, function(data)
    if not inFFA then return end

    if data and data.killerServerId then
        TriggerServerEvent("FFA:killed", data.killerServerId)
    end

    Wait(Config["Settings"].RespawnTime * 1000)
    respawn()
end)