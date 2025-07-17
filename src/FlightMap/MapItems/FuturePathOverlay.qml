import QtQuick
import QtQuick.Effects
import QtLocation
import QtPositioning

import QGroundControl
import QGroundControl.ScreenTools
import QGroundControl.Vehicle
import QGroundControl.Controls

MapPolyline {

    property var vehicle
    property var map
    property int projectionSeconds: 10
    property int intervalSeconds: 1
    property real earthRadius: 6371000 // Meter

    id: futurePath
    map: map
    line.width: 4
    line.color: "deeppink"
    visible: true
    z: 99

    Component.onCompleted: {
        console.log("🗺 map gesetzt?", map)
    }


    Timer {
        id: updateTimer
        interval: 1000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: {
            console.log("🚀 Timer läuft – versuche Pfad zu berechnen")
            futurePath.updatePath()
        }

    }

    function updatePath() {

        if (!vehicle) {
                console.log("⚠️ Kein Fahrzeug vorhanden")
                return
            }

        if (!vehicle || isNaN(vehicle.latitude) || isNaN(vehicle.longitude) || isNaN(vehicle.heading.value) || isNaN(vehicle.groundSpeed.value)) {
            console.log("⚠️ Ungültige Fahrzeugdaten – Pfad wird nicht aktualisiert")

            console.log("💡 Latitude:", vehicle.latitude)
            console.log("💡 Longitude:", vehicle.longitude)
            console.log("💡 Heading:", vehicle.heading.value)
            console.log("💡 Speed:", vehicle.groundSpeed.value)

            return
        }

        console.log("📍 Position:", vehicle.latitude, vehicle.longitude)
        console.log("🧭 Heading:", vehicle.heading.value, "Geschwindigkeit:", vehicle.groundSpeed.value)


        let points = []
        let lat = vehicle.latitude.value
        let lon = vehicle.longitude.value
        let heading = vehicle.heading.value
        let speed = vehicle.groundSpeed.value // in m/s

        for (var t = intervalSeconds; t <= projectionSeconds; t += intervalSeconds) {
            let d = speed * t
            let brng = heading * Math.PI / 180
            let φ1 = lat * Math.PI / 180
            let λ1 = lon * Math.PI / 180

            let φ2 = Math.asin( Math.sin(φ1)*Math.cos(d/earthRadius) + Math.cos(φ1)*Math.sin(d/earthRadius)*Math.cos(brng) )
            let λ2 = λ1 + Math.atan2(Math.sin(brng)*Math.sin(d/earthRadius)*Math.cos(φ1), Math.cos(d/earthRadius)-Math.sin(φ1)*Math.sin(φ2))

            points.push(QtPositioning.coordinate(φ2 * 180/Math.PI, λ2 * 180/Math.PI))
        }

        futurePath.path = points
        console.log("Updating path for:", vehicle)
        console.log("🧬 Future path length:", points.length)

        for (let i = 0; i < points.length; i++) {
            console.log("🔹 Point", i, "→", points[i].latitude, points[i].longitude)
        }



    }
}


