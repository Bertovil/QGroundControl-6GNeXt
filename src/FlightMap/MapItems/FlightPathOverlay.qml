
import QtQuick
import QtLocation
import QtPositioning

MapPolyline {
    property var vehicle
    property var map

    map: map
    line.width: 2
    line.color: "limegreen"
    z: 90
    path: [
        QtPositioning.coordinate(52.206, 13.158),
        QtPositioning.coordinate(52.207, 13.162)
    ]

    Component.onCompleted: {
        console.log("🧩 FlightPathOverlay wurde geladen.")
    }


    Timer {
        interval: 500
        running: true
        repeat: true
        triggeredOnStart: true

        onTriggered: {
            if (!vehicle || !vehicle.latitude || !vehicle.longitude || !vehicle.heading) return

            let lat1 = vehicle.latitude.value * Math.PI / 180
            let lon1 = vehicle.longitude.value * Math.PI / 180
            let heading = vehicle.heading.value * Math.PI / 180
            let d = 100 / 6371000  // 100m in Erd-Radiant

            let lat2 = Math.asin(Math.sin(lat1)*Math.cos(d) + Math.cos(lat1)*Math.sin(d)*Math.cos(heading))
            let lon2 = lon1 + Math.atan2(Math.sin(heading)*Math.sin(d)*Math.cos(lat1), Math.cos(d)-Math.sin(lat1)*Math.sin(lat2))

            path = [
                QtPositioning.coordinate(lat1 * 180/Math.PI, lon1 * 180/Math.PI),
                QtPositioning.coordinate(lat2 * 180/Math.PI, lon2 * 180/Math.PI)
            ]
        }
    }
}
