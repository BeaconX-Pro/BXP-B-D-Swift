//
//  MKBXDDeviceInfoModel.swift
//  MKBeaconButtonSwiftProject
//
//  Created by aa on 2026/9/17.
//  Copyright © 2026 aadyx2007@163.com. All rights reserved.
//

import Foundation

import MKBaseSwiftModule

@MainActor
public final class MKBXDDeviceInfoModel: NSObject {

    /// 软件版本
    public var software: String = ""

    /// 固件版本
    public var firmware: String = ""

    /// 硬件版本
    public var hardware: String = ""

    /// 电压
    public var voltage: String = ""

    /// 电池电量百分比，仅对新版本固件有效
    public var batteryPercent: String = ""

    /// MAC 地址
    public var macAddress: String = ""

    /// 产品型号
    public var productMode: String = ""

    /// 厂商信息
    public var manu: String = ""

    /// 生产日期
    public var manuDate: String = ""

    // MARK: - Read

    public func readData(sucBlock: @escaping () -> Void,
                         failedBlock: @escaping (Error) -> Void) {
        readMacAddress(sucBlock: { [weak self] in
            guard let self = self else { return }
            self.readBatteryVoltage(sucBlock: { [weak self] in
                guard let self = self else { return }
                self.readBatteryPercentIfNeeded(sucBlock: { [weak self] in
                    guard let self = self else { return }
                    self.readDeviceModel(sucBlock: { [weak self] in
                        guard let self = self else { return }
                        self.readSoftware(sucBlock: { [weak self] in
                            guard let self = self else { return }
                            self.readHardware(sucBlock: { [weak self] in
                                guard let self = self else { return }
                                self.readFirmware(sucBlock: { [weak self] in
                                    guard let self = self else { return }
                                    self.readManu(sucBlock: { [weak self] in
                                        guard let self = self else { return }
                                        self.readManuDate(sucBlock: {
                                            sucBlock()
                                        }, failedBlock: failedBlock)
                                    }, failedBlock: failedBlock)
                                }, failedBlock: failedBlock)
                            }, failedBlock: failedBlock)
                        }, failedBlock: failedBlock)
                    }, failedBlock: failedBlock)
                }, failedBlock: failedBlock)
            }, failedBlock: failedBlock)
        }, failedBlock: failedBlock)
    }

    private func readBatteryPercentIfNeeded(sucBlock: @escaping () -> Void,
                                             failedBlock: @escaping (Error) -> Void) {
        if Int(MKBXDConnectManager.shared.deviceType) == 1 {
            readBatteryPercent(sucBlock: sucBlock, failedBlock: failedBlock)
        } else {
            sucBlock()
        }
    }

    // MARK: - Private

    private func readMacAddress(sucBlock: @escaping () -> Void,
                                 failedBlock: @escaping (Error) -> Void) {
        MKBXDInterface.bxd_readMacAddress(sucBlock: { [weak self] returnData in
            guard let self = self else { return }
            let result = (returnData as? [String: Any])?["result"] as? [String: Any] ?? [:]
            self.macAddress = (result["macAddress"] as? String) ?? ""
            sucBlock()
        }, failedBlock: { error in failedBlock(error) })
    }

    private func readBatteryVoltage(sucBlock: @escaping () -> Void,
                                     failedBlock: @escaping (Error) -> Void) {
        MKBXDInterface.bxd_readBatteryVoltage(sucBlock: { [weak self] returnData in
            guard let self = self else { return }
            let result = (returnData as? [String: Any])?["result"] as? [String: Any] ?? [:]
            self.voltage = (result["voltage"] as? String) ?? ""
            sucBlock()
        }, failedBlock: { error in failedBlock(error) })
    }

    private func readBatteryPercent(sucBlock: @escaping () -> Void,
                                     failedBlock: @escaping (Error) -> Void) {
        MKBXDInterface.bxd_readDeviceBatteryPercent(sucBlock: { [weak self] returnData in
            guard let self = self else { return }
            let result = (returnData as? [String: Any])?["result"] as? [String: Any] ?? [:]
            self.batteryPercent = (result["percent"] as? String) ?? ""
            sucBlock()
        }, failedBlock: { error in failedBlock(error) })
    }

    private func readDeviceModel(sucBlock: @escaping () -> Void,
                                  failedBlock: @escaping (Error) -> Void) {
        MKBXDInterface.bxd_readDeviceModel(sucBlock: { [weak self] returnData in
            guard let self = self else { return }
            let result = (returnData as? [String: Any])?["result"] as? [String: Any] ?? [:]
            self.productMode = (result["modeID"] as? String) ?? ""
            sucBlock()
        }, failedBlock: { error in failedBlock(error) })
    }

    private func readSoftware(sucBlock: @escaping () -> Void,
                               failedBlock: @escaping (Error) -> Void) {
        MKBXDInterface.bxd_readSoftware(sucBlock: { [weak self] returnData in
            guard let self = self else { return }
            let result = (returnData as? [String: Any])?["result"] as? [String: Any] ?? [:]
            self.software = (result["software"] as? String) ?? ""
            sucBlock()
        }, failedBlock: { error in failedBlock(error) })
    }

    private func readFirmware(sucBlock: @escaping () -> Void,
                               failedBlock: @escaping (Error) -> Void) {
        MKBXDInterface.bxd_readFirmware(sucBlock: { [weak self] returnData in
            guard let self = self else { return }
            let result = (returnData as? [String: Any])?["result"] as? [String: Any] ?? [:]
            self.firmware = (result["firmware"] as? String) ?? ""
            sucBlock()
        }, failedBlock: { error in failedBlock(error) })
    }

    private func readHardware(sucBlock: @escaping () -> Void,
                               failedBlock: @escaping (Error) -> Void) {
        MKBXDInterface.bxd_readHardware(sucBlock: { [weak self] returnData in
            guard let self = self else { return }
            let result = (returnData as? [String: Any])?["result"] as? [String: Any] ?? [:]
            self.hardware = (result["hardware"] as? String) ?? ""
            sucBlock()
        }, failedBlock: { error in failedBlock(error) })
    }

    private func readManu(sucBlock: @escaping () -> Void,
                           failedBlock: @escaping (Error) -> Void) {
        MKBXDInterface.bxd_readManufacturer(sucBlock: { [weak self] returnData in
            guard let self = self else { return }
            let result = (returnData as? [String: Any])?["result"] as? [String: Any] ?? [:]
            self.manu = (result["manufacturer"] as? String) ?? ""
            sucBlock()
        }, failedBlock: { error in failedBlock(error) })
    }

    private func readManuDate(sucBlock: @escaping () -> Void,
                               failedBlock: @escaping (Error) -> Void) {
        MKBXDInterface.bxd_readProductionDate(sucBlock: { [weak self] returnData in
            guard let self = self else { return }
            let result = (returnData as? [String: Any])?["result"] as? [String: Any] ?? [:]
            self.manuDate = (result["productionDate"] as? String) ?? ""
            sucBlock()
        }, failedBlock: { error in failedBlock(error) })
    }
}
