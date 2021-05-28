function initMap(){
    if(!document.getElementById("mapid")){
        return
    }
    var mapCenter = [46.967329, 2.573059];
    var macarte = L.map('mapid', { worldCopyJump: true }).setView(mapCenter, 6);
    var trucks = L.layerGroup().addTo(macarte);

    L.tileLayer('https://{s}.tile.openstreetmap.fr/osmfr/{z}/{x}/{y}.png', {
        // Il est toujours bien de laisser le lien vers la source des données
        attribution: 'données © <a href="//osm.org/copyright">OpenStreetMap</a>/ODbL - rendu <a href="//openstreetmap.fr">OSM France</a> - <a href="https://www.openstreetmap.org/copyright">© les contributeurs d’OpenStreetMap</a>',
        minZoom: 3,
        maxZoom: 20,
    }).addTo(macarte);

    for (const truckNumber in trucksWithInfo) {
        const truck = trucksWithInfo[truckNumber];
        if (truck.lastTruckMapInfo){
            var truckMarker = L.marker([truck.lastTruckMapInfo.lat, truck.lastTruckMapInfo.lon], {hex_identifier: truck.hex_identifier})
            truckMarker.addTo(trucks);
            truckMarker.bindPopup('<a href="/trucks/'+ truck.id +'">' + truck.name + '</a><br>'+
                "Stolen: " + truck.lastTruckMapInfo.is_stolen + "<br>" +
                "Fuel level: "+ truck.lastTruckMapInfo.fuel_level + "%"
            )
        }
    }
}