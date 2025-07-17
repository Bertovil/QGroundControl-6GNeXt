import QtQuick
import QtLocation
import QtPositioning

Item {
    property var customMapObject
    property var vehicle: QGroundControl.multiVehicleManager.activeVehicle

    MapCircle {
        id: droneCircle
        center: QtPositioning.coordinate(0, 0)
        radius: 30  // z. B. 30 Meter
        color: "#4433aaff"
        border.color: "deepskyblue"
        border.width: 1
        visible: vehicle !== null
        z: 99
    }

    Timer {
        interval: 100
        running: true
        repeat: true
        triggeredOnStart: true

        onTriggered: {
            if (!vehicle || !vehicle.latitude || !vehicle.longitude)
                return

            let lat = typeof vehicle.latitude === "number" ? vehicle.latitude : vehicle.latitude.value
            let lon = typeof vehicle.longitude === "number" ? vehicle.longitude : vehicle.longitude.value
            droneCircle.center = QtPositioning.coordinate(lat, lon)
        }
    }
}
