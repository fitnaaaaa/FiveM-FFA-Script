local FFA = {}
FFA.Players = {}
FFA.Zones = {}

CreateThread(function()
    for name, zone in next, Config["Zones"] do
        FFA.Zones[name] = 0
    end
end)

RegisterNetEvent("FFA:JoinZone", function(zone)
    local s = source
    local identifier = GetPlayerIdentifierByType(s, "license")

    FFA.Players[s] = zone
    FFA.Zones[zone] = FFA.Zones[zone] + 1

    local statsFile = LoadResourceFile(GetCurrentResourceName(), "stats.json")
    local stats = json.decode(statsFile)

    if not stats[identifier] then
        stats[identifier] = {
            kills = 0,
            deaths = 0
        }

        SaveResourceFile(GetCurrentResourceName(), "stats.json", json.encode(stats, { indent = true }))
    end

    TriggerClientEvent("FFA:SendStats", s, stats[identifier])
end)

RegisterNetEvent("FFA:LeaveZone", function(zone)
    local s = source

    if FFA.Players[s] == zone then
        FFA.Players[s] = nil
        FFA.Zones[zone] = FFA.Zones[zone] - 1
    end
end)

AddEventHandler("playerDropped", function()
    local s = source

    if FFA.Players[s] then
        FFA.Zones[FFA.Players[s]] = FFA.Zones[FFA.Players[s]] - 1
        FFA.Players[s] = nil
    end
end)

RegisterNetEvent("FFA:GetZones", function()
    local s = source

    TriggerClientEvent("FFA:SendZones", s, FFA.Zones)
end)

RegisterNetEvent("FFA:killed", function(killerServerId)
    local s = source
    local identifier = GetPlayerIdentifierByType(s, "license")
    local killerIdentifier = GetPlayerIdentifierByType(killerServerId, "license")

    local stats = LoadResourceFile(GetCurrentResourceName(), "stats.json")
    local stats = json.decode(stats)

    stats[identifier].kills = stats[identifier].kills + 1
    stats[killerIdentifier].deaths = stats[killerIdentifier].deaths + 1

    SaveResourceFile(GetCurrentResourceName(), "stats.json", json.encode(stats, { indent = true }))

    TriggerClientEvent("FFA:SendStats", s, stats[identifier])
    TriggerClientEvent("FFA:SendStats", killerServerId, stats[killerIdentifier])
end)
