import QtQuick
import QtLocation
import QtPositioning

MapPolyline {
    id: turnArc
    property var vehicle
    property var map
    property real arcLength: 100 // Meter
    property real earthRadius: 6371000 // Meter (Erdradius)

    map: map
    line.width: 3
    line.color: "dodgerblue" // Rechtskurve = blau, Linkskurve = orange (optional ändern)
    z: 99
    path: []

    Timer {
        interval: 100
        running: true
        repeat: true
        triggeredOnStart: true

        onTriggered: {
            if (!vehicle || !vehicle.latitude || !vehicle.longitude || !vehicle.heading || !vehicle.groundSpeed || !vehicle.bankAngle)
                return

            console.log("Heading:", vehicle.heading.value)
            console.log("BankAngle:", vehicle.bankAngle.value)
            console.log("GroundSpeed:", vehicle.groundSpeed.value)

            // Basiswerte
            let g = 9.81
            let speed = vehicle.groundSpeed.value // m/s
            let bankRad = vehicle.bankAngle.value * Math.PI / 180
            let headingRad = vehicle.heading.value * Math.PI / 180
            let turnDirection = bankRad >= 0 ? 1 : -1 // Rechts = 1, Links = -1

            // Radius des Kurvenflugs berechnen
            let turnRadius = (speed * speed) / (g * Math.tan(Math.abs(bankRad)))
            if (!isFinite(turnRadius) || turnRadius <= 0 || turnRadius > 10000)
                return

            // Bogenwinkel für 100 m Bogenlänge
            let arcAngle = arcLength / turnRadius

            // aktuelle Position
            let lat1 = (typeof vehicle.latitude === "number" ? vehicle.latitude : vehicle.latitude.value) * Math.PI / 180
            let lon1 = (typeof vehicle.longitude === "number" ? vehicle.longitude : vehicle.longitude.value) * Math.PI / 180

            // Mittelpunkt des Kreisbogens (90° versetzt vom Heading)
            let centerLat = lat1 + (turnRadius / earthRadius) * Math.cos(headingRad + turnDirection * Math.PI / 2)
            let centerLon = lon1 + (turnRadius / earthRadius) * Math.sin(headingRad + turnDirection * Math.PI / 2)

            // Punkte des Kreisbogens berechnen
            let segments = 25
            let newPath = []

            for (let i = 0; i <= segments; i++) {
                let theta = headingRad - turnDirection * arcAngle/2 + turnDirection * (arcAngle * i / segments)
                let lat = centerLat + (turnRadius / earthRadius) * Math.cos(theta)
                let lon = centerLon + (turnRadius / earthRadius) * Math.sin(theta)
                newPath.push(QtPositioning.coordinate(lat * 180 / Math.PI, lon * 180 / Math.PI))
            }

            path = newPath

            // Optional: Farbe je nach Kurvenrichtung
            line.color = turnDirection > 0 ? "dodgerblue" : "orange"


            console.log("TurnRadius:", turnRadius)
            console.log("ArcAngle (rad):", arcAngle)
            console.log("CenterLat:", centerLat * 180 / Math.PI, "CenterLon:", centerLon * 180 / Math.PI)
            console.log("Points:", newPath.length)

        }
    }
}
