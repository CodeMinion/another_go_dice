import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:another_go_dice/another_go_dice.dart';

void main() {
  test('Test GoDice', () {
    GoDice goDice = GoDice();

    IGoDiceMessage? dieMessage = goDice.processDieMessage(dieType: DieType.d6, data: Uint8List.fromList([82, 0,0,0]));
    expect(dieMessage, isA<GoDiceRollingMessage>());


    // 70-83-63-254-255 - Rolled 6
    dieMessage = goDice.processDieMessage(dieType: DieType.d6, data: Uint8List.fromList([70,83,63,254,255]));
    expect(dieMessage, isA<GoDiceRollMessage>());
    GoDiceRollMessage rolledMessage = dieMessage as GoDiceRollMessage;
    expect(rolledMessage.getValue(), 6);


    // 70-83-63-252-2 -- Rolled 6
    dieMessage = goDice.processDieMessage(dieType: DieType.d6, data: Uint8List.fromList([70,83,63,252,2]));
    expect(dieMessage, isA<GoDiceRollMessage>());
    rolledMessage = dieMessage as GoDiceRollMessage;
    expect(rolledMessage.getValue(), 6);

    // 83-1-195-246 -- Rolled 4
    dieMessage = goDice.processDieMessage(dieType: DieType.d6, data: Uint8List.fromList([83,1,195,246]));
    expect(dieMessage, isA<GoDiceRollMessage>());
    rolledMessage = dieMessage as GoDiceRollMessage;
    expect(rolledMessage.getValue(), 4);

    // 83-2-193-253 -- Rolled 4
    dieMessage = goDice.processDieMessage(dieType: DieType.d6, data: Uint8List.fromList([83,2,193,253]));
    expect(dieMessage, isA<GoDiceRollMessage>());
    rolledMessage = dieMessage as GoDiceRollMessage;
    expect(rolledMessage.getValue(), 4);

    // 70-83-0-65-5 -- Rolled 3
    dieMessage = goDice.processDieMessage(dieType: DieType.d6, data: Uint8List.fromList([70,83,0,65,5]));
    expect(dieMessage, isA<GoDiceRollMessage>());
    rolledMessage = dieMessage as GoDiceRollMessage;
    expect(rolledMessage.getValue(), 3);

    // 83-192-1-4 -- Rolled 1
    dieMessage = goDice.processDieMessage(dieType: DieType.d6, data: Uint8List.fromList([83,192,1,4]));
    expect(dieMessage, isA<GoDiceRollMessage>());
    rolledMessage = dieMessage as GoDiceRollMessage;
    expect(rolledMessage.getValue(), 1);

    // 83-3-251-194 -- Rolled 5
    dieMessage = goDice.processDieMessage(dieType: DieType.d6, data: Uint8List.fromList([83,3,251,194]));
    expect(dieMessage, isA<GoDiceRollMessage>());
    rolledMessage = dieMessage as GoDiceRollMessage;
    expect(rolledMessage.getValue(), 5);

    GoDiceRequest colorRequest = goDice.getColorRequest();
    expect(colorRequest.payload[0], 23);

    GoDiceRequest batteryRequest = goDice.getBatteryRequest();
    expect(batteryRequest.payload[0], 3);

    GoDiceRequest setColorRequest = goDice.getSetLedRequest(led1: Colors.blue);
    expect(setColorRequest.payload[0], 8); // Has LED message indicator
    expect(setColorRequest.payload[1], Colors.blue.red);
    expect(setColorRequest.payload[2], Colors.blue.green);
    expect(setColorRequest.payload[3], Colors.blue.blue);

  });
}
