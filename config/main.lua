Config = {
    ["Settings"] = {
        ServerName = "SERVERNAME", -- Servername
        HelpText = "~INPUT_PICKUP~ FFA",

        deathEvent = "FFA:PlayerDeath", -- es muss killerServerId mitgegeben werden
        RespawnTime = 4,
        Color = vec3(0, 153, 255),      -- Allgemeine Farbe vom FFA

        Marker = {
            position = vec3(238.3779, -1437.3890, 29.3402),
            size = vec3(0.7, 0.7, 0.7),

            distance = 5.0,
            type = 21,
        },
    },

    ["Zones"] = {
        ["Triaden Ranch"] = {
            MaximaleSpieler = 10,

            Zone = {
                Mitte = vec3(227.9827, -1430.8613, 29.3413),
                Radius = 10.0,
            },

            Spawns = {
                vec3(223.1310, -1428.2681, 29.3312)
            }
        }
    }
}

ShowHelpNotification = function(message)
    SetTextComponentFormat("STRING")
    AddTextComponentString(message)
    DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end
