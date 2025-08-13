import QtQuick
import QtLocation
import QtPositioning
import QGroundControl.Vehicle

MapPolyline {
    id: flightPathPreview
    property var vehicle: QGroundControl.multiVehicleManager.activeVehicle
    //property real arcLength: 200                // Länge der prognostizierten Flugbahn
    property real t_predict: 10                 // Sekunden Vorschau der prognostizierten Flugbahn
    property real earthRadius: 6378137          // Erdradius in Metern
    property int segments: 25                   // Wie glatt die Kurve ist
    property var map
    property real _rollAngle: vehicle ? vehicle.roll.rawValue : 0


    map: map
    line.width: 15
    line.color: Qt.rgba(1.0, 0.0, 0.5, 0.3)     // RGB für Pink + Alpha = 0.6
    //line.color: "deeppink"
    z: 99
    path: []

    Timer {
        interval: 100
        running: true
        repeat: true
        triggeredOnStart: true

        onTriggered: {
            if (!vehicle || !vehicle.latitude || !vehicle.longitude || !vehicle.heading || !vehicle.groundSpeed)
                return

            const speed = vehicle.groundSpeed.value      // [m/s]
            const arcLength = speed*t_predict
            const rollDeg = vehicle.roll.rawValue           // [°]
            const headingDeg = vehicle.heading.value     // [°]
            //const headingDeg = vehicle.groundCourse.value // funktioniert nicht


            if (Math.abs(rollDeg) < 2) return       // Geradeausflug → keine Kurve

            const rollRad = rollDeg * Math.PI / 180
            const headingRad = -headingDeg * Math.PI / 180 + Math.PI/2
            const lat = vehicle.latitude
            const lon = vehicle.longitude
            const latRad = lat * Math.PI / 180

            const turnDirection = rollRad >= 0 ? -1 : 1
            const g = 9.80665
            const turnRadius = speed * speed / (g * Math.tan(Math.abs(rollRad)))*1.16
            //console.log("TurnRadius:", turnRadius)


            if (!isFinite(turnRadius) || turnRadius <= 0 || turnRadius > 100000)
                return

            const arcAngle = arcLength / turnRadius // [rad]

            const newPath = []

            for (let i = 0; i <= segments; i++) {
                let alpha = arcAngle * i / segments
                let localX = turnRadius * Math.sin(alpha)
                let localY = turnRadius * (1 - Math.cos(alpha)) * turnDirection

            //  Rotation in Heading-Richtung
                //console.log(vehicle.heading.value)

                let rotatedX = localX * Math.cos(headingRad) - localY * Math.sin(headingRad)
                let rotatedY = localX * Math.sin(headingRad) + localY * Math.cos(headingRad)

                //console.log("localX:", localX)
                //console.log("localY:", localY)

                // Umrechnung in GPS-Koordinaten
                let deltaLat = (rotatedY / earthRadius) * (180 / Math.PI)
                let deltaLon = (rotatedX / (earthRadius * Math.cos(latRad))) * (180 / Math.PI)
/*
                if (vehicle.groundSpeed >=2.0) {
                    let point = QtPositioning.coordinate(lat + deltaLat, lon + deltaLon)
                }

                else {
                const newPath = []
                }
*/

                let point = QtPositioning.coordinate(lat + deltaLat, lon + deltaLon)
                newPath.push(point)

            }

            path = newPath
        }
    }
}
