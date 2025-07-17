import QtQuick
import QtLocation
import QtPositioning

MapPolyline {
    id: headingLine
    property var vehicle
    property var map
    property real length: 100
    property real earthRadius: 6371000

    map: map
    line.width: 3
    line.color: "deeppink"
    z: 99
    path: []

    Timer {
        interval: 100
        running: true
        repeat: true
        triggeredOnStart: true

        onTriggered: {
            if (!vehicle || !vehicle.latitude || !vehicle.longitude || !vehicle.heading) return

            let brng = vehicle.heading.value * Math.PI / 180
            let lat1 = (typeof vehicle.latitude === "number" ? vehicle.latitude : vehicle.latitude.value) * Math.PI / 180
            let lon1 = (typeof vehicle.longitude === "number" ? vehicle.longitude : vehicle.longitude.value) * Math.PI / 180
            let d = length / earthRadius

            let lat2 = Math.asin(Math.sin(lat1)*Math.cos(d) + Math.cos(lat1)*Math.sin(d)*Math.cos(brng))
            let lon2 = lon1 + Math.atan2(Math.sin(brng)*Math.sin(d)*Math.cos(lat1), Math.cos(d)-Math.sin(lat1)*Math.sin(lat2))

            path = [
                QtPositioning.coordinate(lat1 * 180/Math.PI, lon1 * 180/Math.PI),
                QtPositioning.coordinate(lat2 * 180/Math.PI, lon2 * 180/Math.PI)
            ]
        }
    }
}
