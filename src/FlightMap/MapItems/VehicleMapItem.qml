/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

import QtQuick
import QtQuick.Effects
import QtLocation
import QtPositioning

import QGroundControl
import QGroundControl.ScreenTools
import QGroundControl.Vehicle
import QGroundControl.Controls


/// Marker for displaying a vehicle location on the map
MapQuickItem {
    id: _root
    property var vehicle                                                         /// Vehicle object, undefined for ADSB vehicle

    function getVehicleTypeName(sysid) {
        switch (sysid) {
        case 1:  return "Multicopter X500"
        case 2:  return "VTOL"
        case 3:  return "VTOL"
        case 4:  return "Multicopter X500"
        case 5:  return "Multicopter X500"
        case 6:  return "Airplane"
        case 7:  return "Helicopter"
        default: return "Unbekannt"
        }
    }

    function getDroneName(sysid) {
        switch (sysid) {
        case 1: return "BOLEK"
        case 2: return "MANTA-X1"
        case 3: return "MANTA-X2"
        case 4: return "LOLEK"
        case 5: return "PAVEL"
        case 6: return "TIMBER"
        case 7: return "LOGO600"
        default: return "Drohne #" + sysid
        }
    }

    property var    map
    property double altitude: vehicle ? vehicle.altitudeRelative.value : Number.NaN /// Vehicle relative Altitude in m from T/O
    property double velocity: vehicle ? vehicle.groundSpeed.value : Number.NaN      /// Vehicle Groundspeed in m/s

    property string callsign:       ""                                              ///< Vehicle callsign
    property double heading:        vehicle ? vehicle.heading.value : Number.NaN    ///< Vehicle heading in degree, NAN for none
    property real   size:           ScreenTools.defaultFontPixelHeight * 3          /// Default size for icon, most usage overrides this
    property bool   alert:          false                                           /// Collision alert

    anchorPoint.x:  vehicleItem.width  / 2
    anchorPoint.y:  vehicleItem.height / 2
    visible:        coordinate.isValid

    property var    _activeVehicle: QGroundControl.multiVehicleManager.activeVehicle
    property bool   _adsbVehicle:   vehicle ? false : true
    property var    _map:           map
    property bool   _multiVehicle:  QGroundControl.multiVehicleManager.vehicles.count > 1
    property bool infoPinned: false
    property bool cursorOver: false

    property var _vehicle: vehicle  // Heading-Linie




    sourceItem: Item {
        id:         vehicleItem
        width:      vehicleIcon.width
        height:     vehicleIcon.height
        opacity:    _adsbVehicle || vehicle === _activeVehicle ? 1.0 : 0.5

        /*
        FuturePathOverlay {
            vehicle: QGroundControl.multiVehicleManager.activeVehicle
            map: _map
            projectionSeconds: 15
            intervalSeconds: 1
        }
        */



        MultiEffect {
            source: vehicleIcon
            shadowEnabled: vehicleIcon.visible && _adsbVehicle
            shadowColor: Qt.rgba(0.94,0.91,0,1.0)
            shadowVerticalOffset: 4
            shadowHorizontalOffset: 4
            shadowBlur: 1.0
            shadowOpacity: 0.5
            shadowScale: 1.3
            blurMax: 32
            blurMultiplier: .1
        }
            
        Repeater {
            model: vehicle ? vehicle.gimbalController.gimbals : [] 
            
            Item {
                id:                           canvasItem
                anchors.centerIn:             vehicleItem
                width:                        vehicleItem.width * 2
                height:                       vehicleItem.height * 2
                property var gimbalYaw:       object.absoluteYaw.rawValue
                rotation:                     gimbalYaw + 180
                onGimbalYawChanged:           canvas.requestPaint()
                visible:                      vehicle && !isNaN(gimbalYaw) && QGroundControl.settingsManager.gimbalControllerSettings.showAzimuthIndicatorOnMap.rawValue
                opacity:                      object === vehicle.gimbalController.activeGimbal ? 1.0 : 0.4

                Canvas {
                    id:                           canvas
                    anchors.centerIn:             canvasItem
                    anchors.verticalCenterOffset: vehicleItem.width
                    width:                        vehicleItem.width
                    height:                       vehicleItem.height

                    onPaint:                      paintHeading()

                    function paintHeading() {
                        var context = getContext("2d")
                        // console.log("painting heading " + object.param1Raw + " " + opacity + " " + visible + " " + _index)
                        context.clearRect(0, 0, vehicleIcon.width, vehicleIcon.height);

                        var centerX = canvas.width / 2;
                        var centerY = canvas.height / 2;
                        var length = canvas.height * 1.3
                        var width = canvas.width * 0.6

                        var point1 = [centerX - width , centerY + canvas.height * 0.6]
                        var point2 = [centerX, centerY - canvas.height * 0.5]
                        var point3 = [centerX + width , centerY + canvas.height * 0.6]
                        var point4 = [centerX, centerY + canvas.height * 0.2]

                        // Draw the arrow
                        context.save();
                        context.globalAlpha = 0.9;
                        context.beginPath();
                        context.moveTo(centerX, centerY + canvas.height * 0.2);
                        context.lineTo(point1[0], point1[1]);
                        context.lineTo(point2[0], point2[1]);
                        context.lineTo(point3[0], point3[1]);
                        context.lineTo(point4[0], point4[1]);
                        context.closePath();

                        const gradient = context.createLinearGradient(canvas.width / 2, canvas.height , canvas.width / 2, 0);
                        gradient.addColorStop(0.3, Qt.rgba(255,255,255,0));
                        gradient.addColorStop(0.5, Qt.rgba(255,255,255,0.5));
                        gradient.addColorStop(1, qgcPal.mapIndicator);

                        context.fillStyle = gradient;
                        context.fill();
                        context.restore();
                    }
                }
            }
        }

        // MAV-Symbol zuordnen
        Image {
            id: vehicleIcon

            source: {
                    switch (vehicle.id) {
                    case 1: return "/src/FlightMap/Images/6GNeXt/6GNeXt_vehicleMulticopter.png"
                    case 2: return "/src/FlightMap/Images/6GNeXt/6GNeXt_vehicleMANTA.png"
                    case 3: return "/src/FlightMap/Images/6GNeXt/6GNeXt_vehicleMANTA.png"
                    case 4: return "/src/FlightMap/Images/6GNeXt/6GNeXt_vehicleMulticopter.png"
                    case 5: return "/src/FlightMap/Images/6GNeXt/6GNeXt_vehicleMulticopter.png"
                    case 6: return "/src/FlightMap/Images/6GNeXt/6GNeXt_vehiclePlane.png"
                    case 7: return "/src/FlightMap/Images/6GNeXt/6GNeXt_vehicleHelicopter.png"
                    default: return "src/FlightMap/Images/6GNeXt/6GNeXt_vehicleDefault.svg"
                    }
                }

            mipmap: true
            width: _root.size
            sourceSize.width: _root.size
            fillMode: Image.PreserveAspectFit
            transform: Rotation {
                origin.x: vehicleIcon.width / 2
                origin.y: vehicleIcon.height / 2
                angle: isNaN(heading) ? 0 : heading
            }
        }

        // Info-Fenster anzeigen beim Hovern mit Maus
        Item {
            id: infoWrapper
            visible: true
            opacity: 0.0
            anchors.bottom: parent.top
            anchors.horizontalCenter: parent.horizontalCenter

            Behavior on opacity {
                NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
            }

            Timer {
                id: hideDelayTimer
                interval: 1500            // Zeit in Millisekunden bis ausgebelendet (z. B. 500 = 0,5 Sek.)
                repeat: false
                onTriggered: {
                    if (!infoPinned && !cursorOver) {
                        infoWrapper.opacity = 0.0
                    }
                }
            }

            Rectangle {
                id: infoBg
                color: "#202020"
                radius: 6
                border.color: "#707070"
                opacity: 0.8
                anchors.fill: infoContent
                anchors.margins: -6
                z: -1
            }

            Column {
                id: infoContent
                anchors.margins: 10
                spacing: 4

                Row {
                    spacing: 6
                    Text {
                        text: getDroneName(vehicle.id)
                        font.pointSize: ScreenTools.defaultFontPointSize
                        font.bold: true
                        color: "white"
                    }

                    MouseArea {
                        id: pinArea
                        width: 16
                        height: 16
                        onClicked: {
                            infoPinned = !infoPinned
                            infoWrapper.opacity = infoPinned || cursorOver ? 1.0 : 0.0
                        }
                        Text {
                            text: infoPinned ? "📌" : "📍"
                            color: "white"
                            font.pixelSize: 16
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.margins: 4

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    infoPinned = !infoPinned
                                    infoWrapper.opacity = infoPinned || cursorOver ? 1.0 : 0.0
                                }
                            }
                        }

                    }
                }


                Column {
                    spacing: 6

                    Row {
                        spacing: 12
                        Text { text: "Vehicle#:"; color: "lightgray"; font.pointSize: ScreenTools.defaultFontPointSize }
                        Text { text: vehicle.id; color: "white"; font.pointSize: ScreenTools.defaultFontPointSize }
                    }
                    Row {
                        spacing: 12
                        Text { text: "Typ:"; color: "lightgray"; font.pointSize: ScreenTools.defaultFontPointSize }
                        Text { text: getVehicleTypeName(vehicle.id); color: "white"; font.pointSize: ScreenTools.defaultFontPointSize }
                    }
                    Row {
                        spacing: 12
                        Text { text: "Altitude:"; color: "lightgray"; font.pointSize: ScreenTools.defaultFontPointSize }
                        Text {
                            text: isNaN(altitude) ? "n/a" : Math.round(altitude) + " m"
                            color: "white"
                            font.pointSize: ScreenTools.defaultFontPointSize
                        }
                    }
                    Row {
                        spacing: 12
                        Text { text: "Heading:"; color: "lightgray"; font.pointSize: ScreenTools.defaultFontPointSize }
                        Text {
                            text: isNaN(heading) ? "n/a" : Math.round(heading) + " °"
                            color: "white"
                            font.pointSize: ScreenTools.defaultFontPointSize
                        }
                    }
                    Row {
                        spacing: 12
                        Text { text: "Velocity:"; color: "lightgray"; font.pointSize: ScreenTools.defaultFontPointSize }
                        Text {
                            text: isNaN(velocity) ? "n/a" : Math.round(velocity) + " m/s"
                            color: "white"
                            font.pointSize: ScreenTools.defaultFontPointSize
                        }
                    }
                    Row {
                        spacing: 8
                        Text { text: "Battery:"; color: "lightgray"; font.pointSize: ScreenTools.defaultFontPointSize }
                        Text {
                            text: (vehicle.battery && !isNaN(vehicle.battery.percentRemaining))
                                ? Math.round(vehicle.battery.percentRemaining) + " %"
                                : "n/a"

                            color: "white"
                            font.pointSize: ScreenTools.defaultFontPointSize
                        }
                    }

                }

            }
        }


        // Cursor-Verhalten:    Hovern über Symbol --> Infofenster |
        //                      Pin-Nadel anklicken --> Infofenster fixieren|
        //                      Klicken auf Symbol --> Steuerung übernehmen
        MouseArea {
            id: hoverArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            onEntered: {
                cursorOver = true
                hideDelayTimer.stop()
                if (!infoPinned) infoWrapper.opacity = 1.0
            }

            onExited: {
                cursorOver = false
                if (!infoPinned) hideDelayTimer.start()
            }

            onClicked: {
                // Infofeld pinnen/entpinnen mit Shift-Klick (optional)
                if (Qt.shiftModifier & Qt.keyboardModifiers) {
                    infoPinned = !infoPinned
                    infoWrapper.opacity = infoPinned || cursorOver ? 1.0 : 0.0
                    return
                }

                // 🚁 Steuerung übernehmen
                if (vehicle && vehicle !== QGroundControl.multiVehicleManager.activeVehicle) {
                    QGroundControl.multiVehicleManager.activeVehicle = vehicle
                    console.log("Steuerung übernommen: Fahrzeug #" + vehicle.id)
                }
            }
        }





    } //sourceItem

} //MapQuickItem
