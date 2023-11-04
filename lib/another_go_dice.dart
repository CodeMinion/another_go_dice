library another_go_dice;

import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:another_ble_manager/another_ble_manager.dart';
import 'package:flutter/painting.dart';

/// A Calculator.
class GoDice {
  static const String _dieServiceUuid = "6E400001-B5A3-F393-E0A9-E50E24DCCA9E";

  // Characteristic where the different readings are received from
  static const String _dieReceiveCharacteristicUuid = "6E400003-B5A3-F393-E0A9-E50E24DCCA9E";

  // Characteristic where the different requests are made to.
  static const String _dieWriteCharacteristicUuid =
      "6e400002-b5a3-f393-e0a9-e50e24dcca9e";

  //Dice vectors
  static const Map<int, _Vector3> _d6Vectors = {
    1: _Vector3(-64, 0, 0),
    2: _Vector3(0, 0, 64),
    3: _Vector3(0, 64, 0),
    4: _Vector3(0, -64, 0),
    5: _Vector3(0, 0, -64),
    6: _Vector3(64, 0, 0)
  };

  static const Map<int, _Vector3> _d20Vectors = {
    1: _Vector3(-64, 0, -22),
    2: _Vector3(42, -42, 40),
    3: _Vector3(0, 22, -64),
    4: _Vector3(0, 22, 64),
    5: _Vector3(-42, -42, 42),
    6: _Vector3(22, 64, 0),
    7: _Vector3(-42, -42, -42),
    8: _Vector3(64, 0, -22),
    9: _Vector3(-22, 64, 0),
    10: _Vector3(42, -42, -42),
    11: _Vector3(-42, 42, 42),
    12: _Vector3(22, -64, 0),
    13: _Vector3(-64, 0, 22),
    14: _Vector3(42, 42, 42),
    15: _Vector3(-22, -64, 0),
    16: _Vector3(42, 42, -42),
    17: _Vector3(0, -22, -64),
    18: _Vector3(0, -22, 64),
    19: _Vector3(-42, 42, -42),
    20: _Vector3(64, 0, 22)
  };

  static const Map<int, _Vector3> _d24Vectors = {
    1: _Vector3(20, -60, -20),
    2: _Vector3(20, 0, 60),
    3: _Vector3(-40, -40, 40),
    4: _Vector3(-60, 0, 20),
    5: _Vector3(40, 20, 40),
    6: _Vector3(-20, -60, -20),
    7: _Vector3(20, 60, 20),
    8: _Vector3(-40, 20, -40),
    9: _Vector3(-40, 40, 40),
    10: _Vector3(-20, 0, 60),
    11: _Vector3(-20, -60, 20),
    12: _Vector3(60, 0, 20),
    13: _Vector3(-60, 0, -20),
    14: _Vector3(20, 60, -20),
    15: _Vector3(20, 0, -60),
    16: _Vector3(40, -20, -40),
    17: _Vector3(-20, 60, -20),
    18: _Vector3(-40, -40, -40),
    19: _Vector3(40, -20, 40),
    20: _Vector3(20, -60, 20),
    21: _Vector3(60, 0, -20),
    22: _Vector3(40, 20, -40),
    23: _Vector3(-20, 0, -60),
    24: _Vector3(-20, 60, 20)
  };

  // Dice Transforms
  static const Map<int, int> _d10Transform = {
    1: 8,
    2: 2,
    3: 6,
    4: 1,
    5: 4,
    6: 3,
    7: 9,
    8: 0,
    9: 7,
    10: 5,
    11: 5,
    12: 7,
    13: 0,
    14: 9,
    15: 3,
    16: 4,
    17: 1,
    18: 6,
    19: 2,
    20: 8,
  };

  static const Map<int, int> _d10XTransform = {
    1: 80,
    2: 20,
    3: 60,
    4: 10,
    5: 40,
    6: 30,
    7: 90,
    8: 0,
    9: 70,
    10: 50,
    11: 50,
    12: 70,
    13: 0,
    14: 90,
    15: 30,
    16: 40,
    17: 10,
    18: 60,
    19: 20,
    20: 80,
  };

  static const Map<int, int> _d4Transform = {
    1: 3,
    2: 1,
    3: 4,
    4: 1,
    5: 4,
    6: 4,
    7: 1,
    8: 4,
    9: 2,
    10: 3,
    11: 1,
    12: 1,
    13: 1,
    14: 4,
    15: 2,
    16: 3,
    17: 3,
    18: 2,
    19: 2,
    20: 2,
    21: 4,
    22: 1,
    23: 3,
    24: 2
  };

  static const Map<int, int> _d8Transform = {
    1: 3,
    2: 3,
    3: 6,
    4: 1,
    5: 2,
    6: 8,
    7: 1,
    8: 1,
    9: 4,
    10: 7,
    11: 5,
    12: 5,
    13: 4,
    14: 4,
    15: 2,
    16: 5,
    17: 7,
    18: 7,
    19: 8,
    20: 2,
    21: 8,
    22: 3,
    23: 6,
    24: 6
  };

  static const Map<int, int> _d12Transform = {
    1: 1,
    2: 2,
    3: 3,
    4: 4,
    5: 5,
    6: 6,
    7: 7,
    8: 8,
    9: 9,
    10: 10,
    11: 11,
    12: 12,
    13: 1,
    14: 2,
    15: 3,
    16: 4,
    17: 5,
    18: 6,
    19: 7,
    20: 8,
    21: 9,
    22: 10,
    23: 11,
    24: 12
  };

  const GoDice();

  /// Returns a request for requesting the die color.
  /// This request has all the information needed to send
  /// a request to the physical device.
  GoDiceRequest getColorRequest() {
    Uint8List payload =
        Uint8List.fromList([(ByteData(1)..setInt8(0, 23)).getInt8(0)]);
    return GoDiceRequest(
        serviceUuid: _dieServiceUuid,
        characteristicUuid: _dieWriteCharacteristicUuid,
        payload: payload);
  }

  /// Returns a request for requesting the
  /// battery level of the device.
  GoDiceRequest getBatteryRequest() {
    Uint8List payload =
        Uint8List.fromList([(ByteData(1)..setInt8(0, 3)).getInt8(0)]);
    return GoDiceRequest(
        serviceUuid: _dieServiceUuid,
        characteristicUuid: _dieWriteCharacteristicUuid,
        payload: payload);
  }

  /// Turn On/Off RGB LEDs, will turn off if led1 and led2 are None
  // :param led1: a list to control the 1st LED in the following format '[R, G, B]'
  //  where R, G, and B are numbers in the range of 0-255
  // :param led2: a list to control the 2nd LED in the following format '[R, G, B]'
  // where R, G, and B are numbers in the range of 0-255
  GoDiceRequest getSetLedRequest(
      {Color led1 = const Color.fromARGB(255, 0, 0, 0),
      Color led2 = const Color.fromARGB(255, 0, 0, 0)}) {
    Uint8List payload = Uint8List.fromList([
      8, // LED message identifier
      led1.red, led1.green, led1.blue,
      led2.red, led2.green, led2.blue
    ]);
    return GoDiceRequest(
        serviceUuid: _dieServiceUuid,
        characteristicUuid: _dieWriteCharacteristicUuid,
        payload: payload);
  }

  /// Pulses the die's leds for set time
  // :param pulseCount: How many pulses
  // :param onTime: How much time to spend on (units of 10 ms)
  // :param offTime: How much time to spend off (units of 10 ms)
  // :param rgb: List of RGB values to set die to pulse to
  GoDiceRequest getPulseLedRequest(
      {int pulseCount = 1,
      int onTime = 10,
      int offTime = 10,
      required List<Color> colors}) {
    List<int> msgBytes = List.empty(growable: true);
    //LED pulse message identifier
    msgBytes.add(16);
    msgBytes.add(pulseCount);
    msgBytes.add(onTime);
    msgBytes.add(offTime);
    for (var color in colors) {
      msgBytes.add(color.red);
      msgBytes.add(color.green);
      msgBytes.add(color.blue);
    }
    msgBytes.add(1);
    msgBytes.add(0);

    Uint8List payload = Uint8List.fromList(msgBytes);
    return GoDiceRequest(
        serviceUuid: _dieServiceUuid,
        characteristicUuid: _dieWriteCharacteristicUuid,
        payload: payload);
  }

  /// Callback function when die sends value, processes the data sent by die
  IGoDiceMessage? processDieMessage(
      {required DieType dieType, required Uint8List data}) {
    if (data.isEmpty) {
      return null;
    }

    int firstByte = data[0];

    if (firstByte == 82) {
      //Die is in rolling mode
      return GoDiceRollingMessage._(dieType: dieType);
    } else {
      int secondByte = data[1];
      int thirdByte = data[2];

      if (firstByte == 66 && secondByte == 97 && thirdByte == 116) {
        // Battery level - B
        return GoBatteryMessage._(battReading: data[3]);
      } else if (firstByte == 67 && secondByte == 111 && thirdByte == 108) {
        //Color - C
        //self.result_queue.put(("C", data[3]))
        return GoColorMessage._(color: _Vector3(data[3], 0, 0));
      } else if (firstByte == 83) {
        //Stable - S
        _Vector3 xyz = _getXyzFromBytes(data, 1);
        int rolledValue = _getRolledNumber(dieType, xyz);
        return GoDiceRollMessage(dieType: dieType, rollValue: rolledValue);
      } else if (secondByte == 83) {
        //Other stable events
        _Vector3 xyz = _getXyzFromBytes(data, 2);
        int rolledValue = _getRolledNumber(dieType, xyz);

        if (firstByte == 70) {
          //Fake stable - FS
          return GoDiceRollMessage(dieType: dieType, rollValue: rolledValue);
        } else if (firstByte == 84) {
          //Tilt stable - TS
          return GoDiceRollMessage(dieType: dieType, rollValue: rolledValue);
        } else if (firstByte == 77) {
          //Move stable - MS
          return GoDiceRollMessage(dieType: dieType, rollValue: rolledValue);
        }
      }
    }

    return null;
  }

  ///  :param data: raw data sent by die
  ///  :param start_byte: the byte in which the xyz coordinates start at
  ///  :return: a tuple of the xyz coordinates sent by the die
  _Vector3 _getXyzFromBytes(Uint8List data, int startByte) {
    int x =
        ByteData.view(Uint8List.fromList([data[startByte]]).buffer).getInt8(0);
    int y = ByteData.view(Uint8List.fromList([data[startByte + 1]]).buffer)
        .getInt8(0);
    int z = ByteData.view(Uint8List.fromList([data[startByte + 2]]).buffer)
        .getInt8(0);
    return _Vector3(x, y, z);
  }

  ///Gets xyz position of die and returns it's rolled value
  ///:param xyz: xyz position of die
  ///:return: the die's rolled value
  int _getRolledNumber(DieType dieType, _Vector3 xyz) {
    int value = 0;
    if (dieType.code == 0) {
      value = _getClosestVector(_d6Vectors, xyz);
    } else if (0 < dieType.code && dieType.code <= 3) {
      value = _getClosestVector(_d20Vectors, xyz);
    } else if (3 < dieType.code && dieType.code <= 6) {
      value = _getClosestVector(_d24Vectors, xyz);
    }

    // Not D6 Or D20:
    if (!(dieType.code == 0 || dieType.code == 1)) {
      if (dieType.code == 2) {
        value = _d10Transform[value]!;
      } else if (dieType.code == 3) {
        value = _d10XTransform[value]!;
      } else if (dieType.code == 4) {
        value = _d4Transform[value]!;
      } else if (dieType.code == 5) {
        value = _d8Transform[value]!;
      } else if (dieType.code == 6) {
        value = _d12Transform[value]!;
      }
    }

    return value;
  }

  /// Returns the closest die vector to the specified coordinate
  int _getClosestVector(Map<int, _Vector3> dieTable, _Vector3 coord) {
    int coordX = coord[0];
    int coordY = coord[1];
    int coordZ = coord[2];

    double minDistance = double.infinity;
    int value = 0;

    int xResult = 0;
    int yResult = 0;
    int zResult = 0;
    // Calculating distance to each value in vector array
    for (var dieValue in dieTable.keys) {
      _Vector3 vector = dieTable[dieValue]!;
      xResult = coordX - vector[0];
      yResult = coordY - vector[1];
      zResult = coordZ - vector[2];

      double curDist =
          (pow(xResult, 2) + pow(yResult, 2) + pow(zResult, 2)).toDouble();
      if (curDist < minDistance) {
        minDistance = curDist;
        value = dieValue;
      }
    }

    return value;
  }
}

enum DieType {
  d6(code: 0),
  d20(code: 1),
  d10(code: 2),
  d10x(code: 3),
  d4(code: 4),
  d8(code: 5),
  d12(code: 6);

  final int code;

  const DieType({required this.code});
}

class _Vector3 {
  final int x;
  final int y;
  final int z;

  const _Vector3(this.x, this.y, this.z);

  int operator [](int position) {
    if (position == 0) {
      return x;
    }
    if (position == 1) {
      return y;
    }

    return z;
  }

  @override
  String toString() => "$x,$y,$z";
}

abstract class IGoDiceMessage {}

class GoDiceMessageUnknown implements IGoDiceMessage {}

class GoColorMessage implements IGoDiceMessage {
  final _Vector3 _color;

  GoColorMessage._({required _Vector3 color}) : _color = color;

  int getR() => _color[0];

  int getG() => _color[1];

  int getB() => _color[1];
}

class GoBatteryMessage implements IGoDiceMessage {
  final int _battery;

  GoBatteryMessage._({required int battReading}) : _battery = battReading;

  int getBatteryReading() => _battery;
}

class GoDiceRollMessage implements IGoDiceMessage {
  final DieType _dieType;
  final int _value;

  GoDiceRollMessage({required DieType dieType, required int rollValue})
      : _dieType = dieType,
        _value = rollValue;

  DieType getDie() => _dieType;

  int getValue() => _value;
}

class GoDiceRollingMessage implements IGoDiceMessage {
  final DieType _dieType;

  GoDiceRollingMessage._({required DieType dieType}) : _dieType = dieType;

  DieType getDie() => _dieType;
}

class GoDiceRequest {
  final String serviceUuid;
  final String characteristicUuid;
  final Uint8List payload;

  GoDiceRequest(
      {required this.serviceUuid,
      required this.characteristicUuid,
      required this.payload});
}

/// BLE Owner for usage along with another_ble_manager to handle
/// the connection states of the BLE device.
class BleGoDiceDeviceOwner extends BleDeviceOwner {
  DieType _dieType = DieType.d6;
  static const GoDice _goDice = GoDice();
  final GoDiceDeviceInfo _goDiceDeviceInfo;

  IGoDiceMessage ? _prevGoDiceMessage;

  BleGoDiceDeviceOwner(
      {required super.device,
      super.initCommands: const [
        // Used to start listening to the die events as soon as we are connected.
        EnableCharacteristicNotificationCommand(
            serviceUuid: GoDice._dieServiceUuid,
            charUuid: GoDice._dieReceiveCharacteristicUuid)
      ]}):_goDiceDeviceInfo = GoDiceDeviceInfo(device: device);

  DieType getDieType() => _dieType;

  void setDieType({required DieType dieType}) => _dieType = dieType;

  /// Returns the name of the Prop
  String getPropName() => device.getName();

  /// Listen to die messages events
  Stream<IGoDiceMessage> getDieMessages() =>
      getCharacteristicsChanges().map((event) {
        print ("Got Characteristic Change!");
        IGoDiceMessage message;
        if (event.serviceUuid.toUpperCase() == GoDice._dieServiceUuid &&
            event.charUuid.toUpperCase() == GoDice._dieReceiveCharacteristicUuid) {
          message = _goDice.processDieMessage(
                  dieType: _dieType, data: event.value) ??
              GoDiceMessageUnknown();
        } else {
          message = GoDiceMessageUnknown();
        }
        _prevGoDiceMessage = message;
        return message;
      });

  IGoDiceMessage? getLastMessage() => _prevGoDiceMessage;
  @override
  bool operator ==(Object other) {
    if (other is! BleGoDiceDeviceOwner) {
      return false;
    }
    return device.getId() == other.device.getId();
  }

  @override
  int get hashCode => device.getId().hashCode;

  ///
  /// Returns the Color of the pips in the die.
  GoDicePhysicalColor get dicePhysicalColor => _goDiceDeviceInfo.color;

  ///
  /// Returns the version of the die as present in the device name.
  String get version => _goDiceDeviceInfo.version;

}

class GoDiceDeviceInfo {
  final GoDicePhysicalColor color;
  final String last4Mac;
  final String version;

  const GoDiceDeviceInfo._({ required this.version, required this.color, required this.last4Mac});

  ///
  /// On GoDice the device name is composed of 4 parts separated by "_"
  /// 1 - GoDice
  /// 2 - Last 6 digits of the mac address.
  /// 3 - Character representing the color of the pips on the die (O,R,G,Y,B,K)
  /// 4 - Version (v03)
  factory GoDiceDeviceInfo({required IBleDevice device}) {

    String deviceName = device.getName();

    if(!deviceName.startsWith("GoDice")) {
      return GoDiceDeviceInfo._(version: "", color: GoDicePhysicalColor.unknown, last4Mac: "");
    }

    List<String> nameParts = device.getName().split("_");
    String last4Mac = nameParts[1];
    String colorStr = nameParts[2];
    String version = nameParts[3];

    GoDicePhysicalColor color = GoDicePhysicalColor.unknown;
    if (colorStr.toUpperCase() == "O") {
      color = GoDicePhysicalColor.orange;
    }
    else if (colorStr.toUpperCase() == "R") {
      color = GoDicePhysicalColor.red;
    }
    else if (colorStr.toUpperCase() == "G") {
      color = GoDicePhysicalColor.green;
    }
    else if (colorStr.toUpperCase() == "B") {
      color = GoDicePhysicalColor.blue;
    }
    else if (colorStr.toUpperCase() == "Y") {
      color = GoDicePhysicalColor.yellow;
    }
    else if (colorStr.toUpperCase() == "K") {
      color = GoDicePhysicalColor.black;
    }
    return GoDiceDeviceInfo._(version: version, color: color, last4Mac: last4Mac);
  }
}

enum GoDicePhysicalColor {
  unknown,
  orange,
  blue,
  yellow,
  black,
  green,
  red,
}
