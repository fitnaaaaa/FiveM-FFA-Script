const FFA = {
    join(zone) {
        $.post(`https://${GetParentResourceName()}/join`, JSON.stringify(zone));
        FFA.close();

        $('.stats').fadeIn(250);
    },

    addZone(zone) {
        $('.content').append(`
            <div class="item">
                <span class="name">${zone.name}</span>
                <span class="players"><span style="color: var(--primary);">${zone.players}</span>/${zone.MaximaleSpieler}</span>

                <img src="assets/images/wuerfelpark.png" draggable="false">

                <button onclick="FFA.join('${zone.name}')">BEITRETEN</button>
            </div>
        `);
    },

    close() {
        $('.main').fadeOut(250);
        $.post(`https://${GetParentResourceName()}/close`);
    }
}

$(document).ready(function () {
    window.addEventListener('message', function (event) {
        var i = event.data;

        switch (i.action) {
            case 'open':
                $('.main').fadeIn(250);

                var config = i.config;
                var color = config.Settings.Color;

                $('.servername').text(config.Settings.ServerName);

                document.documentElement.style.setProperty('--primary', 'rgb(' + color.x + ', ' + color.y + ', ' + color.z + ')');

                var content = $('.content');

                content.empty();

                for (const [name, players] of Object.entries(i.zones)) {
                    var zoneConfig = config["Zones"][name];

                    FFA.addZone({
                        name: name,
                        players: players,
                        MaximaleSpieler: zoneConfig.MaximaleSpieler
                    })
                }
                break;

            case 'stats':
                $('#kills').text(i.kills);
                $('#deaths').text(i.deaths);
                $('#kd').text(i.kills > 0 ? i.deaths > 0 ? (i.kills / i.deaths).toFixed(2) : `${i.kills}.0` : "0.0");
                break;

            case 'hideStats':
                $('.stats').fadeOut(250);
                break;
        }
    });
});

window.addEventListener('keyup', function (data) {
    switch (data.which) {
        case 27:
            FFA.close();
            break;
    }
});