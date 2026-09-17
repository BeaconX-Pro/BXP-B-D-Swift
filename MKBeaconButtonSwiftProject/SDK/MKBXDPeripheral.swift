//
//  MKBXDPeripheral.swift
//  MKBeaconButtonSwiftProject
//
//  Created by aa on 2025/5/18.
//

import Foundation
@preconcurrency import CoreBluetooth
import MKSwiftBleModule

/// BXD 外设封装，实现 MKSwiftBlePeripheralProtocol
public final class MKBXDPeripheral: NSObject, MKSwiftBlePeripheralProtocol, @unchecked Sendable {

    private var _peripheral: CBPeripheral
    private let dfu: Bool

    public var peripheral: CBPeripheral { _peripheral }

    public init(peripheral: CBPeripheral, dfuMode: Bool) {
        self._peripheral = peripheral
        self.dfu = dfuMode
        super.init()
    }

    public func discoverServices() {
        _peripheral.discoverServices(nil)
    }

    public func discoverCharacteristics() {
        guard let services = _peripheral.services else { return }
        for service in services {
            _peripheral.discoverCharacteristics(nil, for: service)
        }
    }

    public func updateCharacter(with service: CBService) {
        _peripheral.bxd_updateCharacterWithService(service)
    }

    public func updateCurrentNotifySuccess(_ characteristic: CBCharacteristic) {
        _peripheral.bxd_updateCurrentNotifySuccess(characteristic)
    }

    public var connectSuccess: Bool {
        _peripheral.bxd_connectSuccess(dfu)
    }

    public func setNil() {
        _peripheral.bxd_setNil()
    }
}
