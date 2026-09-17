//
//  MKBXDAlarmModeConfigModel.swift
//  MKBeaconButtonSwiftProject
//
//  Created by aa on 2026/9/17.
//  Copyright © 2026 aadyx2007@163.com. All rights reserved.
//

import Foundation

import MKBaseSwiftModule

@MainActor
public final class MKBXDAlarmModeConfigModel: NSObject {

    // MARK: - 状态

    public var singleIsOn: Bool = false
    public var doubleIsOn: Bool = false
    public var longIsOn: Bool = false
    public var inactivityIsOn: Bool = false

    /// 0:single 1:double 2:long 3:abnormal
    public var alarmType: Int = 0

    public var advIsOn: Bool = false

    /// 1~8 字节长度
    public var deviceID: String = ""

    /// 1x20ms~500x20ms
    public var advInterval: String = ""

    /// -100 dBm ~ 0 dBm
    public var rangingData: Int = 0

    /// 0:-40dBm 1:-20dBm 2:-16dBm 3:-12dBm 4:-8dBm 5:-4dBm 6:0dBm 7:+3dBm 8:+4dBm
    public var txPower: Int = 0

    public var alarmMode: Bool = false
    public var stayAdv: Bool = false

    /// Abnormal inactivity mode 才有
    public var abnormalTime: String = ""

    /// 1s~65535s
    public var alarmMode_advTime: String = ""

    /// 1x20ms~500x20ms
    public var alarmMode_advInterval: String = ""

    /// -100 dBm ~ 0 dBm
    public var alarmMode_rssi: Int = 0

    /// 0:-40dBm 1:-20dBm 2:-16dBm 3:-12dBm 4:-8dBm 5:-4dBm 6:0dBm 7:+3dBm 8:+4dBm
    public var alarmMode_txPower: Int = 0

    // MARK: - Read

    public func readData(sucBlock: @escaping () -> Void,
                         failedBlock: @escaping (Error) -> Void) {
        readAlarmStatus(sucBlock: { [weak self] in
            guard let self = self else { return }
            self.readTriggerChannelAdvParams(sucBlock: { [weak self] in
                guard let self = self else { return }
                self.readChannelTriggerParams(sucBlock: { [weak self] in
                    guard let self = self else { return }
                    self.readStayAdvertisingBeforeTriggered(sucBlock: { [weak self] in
                        guard let self = self else { return }
                        // deviceID 已隐藏读取
                        if self.alarmType == 3 {
                            self.readAbnormalTime(sucBlock: {
                                sucBlock()
                            }, failedBlock: failedBlock)
                        } else {
                            sucBlock()
                        }
                    }, failedBlock: failedBlock)
                }, failedBlock: failedBlock)
            }, failedBlock: failedBlock)
        }, failedBlock: failedBlock)
    }

    // MARK: - Config

    public func configData(sucBlock: @escaping () -> Void,
                           failedBlock: @escaping (Error) -> Void) {
        guard validParams() else {
            operationFailed("Params Error", failedBlock: failedBlock)
            return
        }
        configTriggerChannelAdvParams(sucBlock: { [weak self] in
            guard let self = self else { return }
            self.configChannelTriggerParams(sucBlock: { [weak self] in
                guard let self = self else { return }
                self.configStayAdvertisingBeforeTriggered(sucBlock: { [weak self] in
                    guard let self = self else { return }
                    // deviceID 已隐藏配置
                    if self.alarmType == 3 {
                        self.configAbnormalTime(sucBlock: {
                            sucBlock()
                        }, failedBlock: failedBlock)
                    } else {
                        sucBlock()
                    }
                }, failedBlock: failedBlock)
            }, failedBlock: failedBlock)
        }, failedBlock: failedBlock)
    }

    // MARK: - Private: 读

    private func readAlarmStatus(sucBlock: @escaping () -> Void,
                                  failedBlock: @escaping (Error) -> Void) {
        MKBXDInterface.bxd_readTriggerChannelState(sucBlock: { [weak self] returnData in
            guard let self = self else { return }
            let result = (returnData as? [String: Any])?["result"] as? [String: Any] ?? [:]
            self.singleIsOn = (result["singlePressMode"] as? Bool) ?? false
            self.doubleIsOn = (result["doublePressMode"] as? Bool) ?? false
            self.longIsOn = (result["longPressMode"] as? Bool) ?? false
            self.inactivityIsOn = (result["abnormalInactivityMode"] as? Bool) ?? false
            sucBlock()
        }, failedBlock: { error in failedBlock(error) })
    }

    private func readTriggerChannelAdvParams(sucBlock: @escaping () -> Void,
                                              failedBlock: @escaping (Error) -> Void) {
        let alarmTypeValue = MKBXDChannelAlarmType(rawValue: alarmType) ?? .single
        MKBXDInterface.bxd_readTriggerChannelAdvParams(alarmTypeValue, sucBlock: { [weak self] returnData in
            guard let self = self else { return }
            let result = (returnData as? [String: Any])?["result"] as? [String: Any] ?? [:]
            self.advIsOn = (result["isOn"] as? Bool) ?? false
            self.rangingData = Int((result["rssi"] as? String) ?? "0") ?? 0
            self.advInterval = (result["advInterval"] as? String) ?? ""
            self.txPower = self.fetchTxPowerValueString((result["txPower"] as? String) ?? "")
            sucBlock()
        }, failedBlock: { error in failedBlock(error) })
    }

    private func readChannelTriggerParams(sucBlock: @escaping () -> Void,
                                           failedBlock: @escaping (Error) -> Void) {
        let alarmTypeValue = MKBXDChannelAlarmType(rawValue: alarmType) ?? .single
        MKBXDInterface.bxd_readChannelTriggerParams(alarmTypeValue, sucBlock: { [weak self] returnData in
            guard let self = self else { return }
            let result = (returnData as? [String: Any])?["result"] as? [String: Any] ?? [:]
            self.alarmMode = (result["alarm"] as? Bool) ?? false
            self.alarmMode_advTime = (result["advTime"] as? String) ?? ""
            self.alarmMode_advInterval = (result["advInterval"] as? String) ?? ""
            self.alarmMode_txPower = self.fetchTxPowerValueString((result["txPower"] as? String) ?? "")
            sucBlock()
        }, failedBlock: { error in failedBlock(error) })
    }

    private func readStayAdvertisingBeforeTriggered(sucBlock: @escaping () -> Void,
                                                     failedBlock: @escaping (Error) -> Void) {
        let alarmTypeValue = MKBXDChannelAlarmType(rawValue: alarmType) ?? .single
        MKBXDInterface.bxd_readStayAdvertisingBeforeTriggered(alarmTypeValue, sucBlock: { [weak self] returnData in
            guard let self = self else { return }
            let result = (returnData as? [String: Any])?["result"] as? [String: Any] ?? [:]
            self.stayAdv = (result["isOn"] as? Bool) ?? false
            sucBlock()
        }, failedBlock: { error in failedBlock(error) })
    }

    private func readAbnormalTime(sucBlock: @escaping () -> Void,
                                   failedBlock: @escaping (Error) -> Void) {
        MKBXDInterface.bxd_readAbnormalInactivityTime(sucBlock: { [weak self] returnData in
            guard let self = self else { return }
            let result = (returnData as? [String: Any])?["result"] as? [String: Any] ?? [:]
            self.abnormalTime = (result["time"] as? String) ?? ""
            sucBlock()
        }, failedBlock: { error in failedBlock(error) })
    }

    // MARK: - Private: 配置

    private func configTriggerChannelAdvParams(sucBlock: @escaping () -> Void,
                                                failedBlock: @escaping (Error) -> Void) {
        let model = MKBXDTriggerChannelAdvParamsModel()
        model.alarmType = MKBXDChannelAlarmType(rawValue: alarmType) ?? .single
        model.isOn = advIsOn
        model.rssi = rangingData
        model.advInterval = advInterval
        model.txPower = MKBXDTxPower(rawValue: txPower) ?? .dBm40
        MKBXDInterface.bxd_configTriggerChannelAdvParams(model, sucBlock: {
            sucBlock()
        }, failedBlock: { error in failedBlock(error) })
    }

    private func configChannelTriggerParams(sucBlock: @escaping () -> Void,
                                             failedBlock: @escaping (Error) -> Void) {
        let model = MKBXDChannelTriggerParamsModel()
        model.alarmType = MKBXDChannelAlarmType(rawValue: alarmType) ?? .single
        model.alarm = alarmMode
        model.rssi = rangingData
        model.advInterval = alarmMode_advInterval
        model.advertisingTime = alarmMode_advTime
        model.txPower = MKBXDTxPower(rawValue: alarmMode_txPower) ?? .dBm40
        MKBXDInterface.bxd_configChannelTriggerParams(model, sucBlock: {
            sucBlock()
        }, failedBlock: { error in failedBlock(error) })
    }

    private func configStayAdvertisingBeforeTriggered(sucBlock: @escaping () -> Void,
                                                       failedBlock: @escaping (Error) -> Void) {
        let alarmTypeValue = MKBXDChannelAlarmType(rawValue: alarmType) ?? .single
        MKBXDInterface.bxd_configStayAdvertisingBeforeTriggered(alarmTypeValue,
                                                                 isOn: stayAdv,
                                                                 sucBlock: {
            sucBlock()
        }, failedBlock: { error in failedBlock(error) })
    }

    private func configAbnormalTime(sucBlock: @escaping () -> Void,
                                     failedBlock: @escaping (Error) -> Void) {
        MKBXDInterface.bxd_configAbnormalInactivityTime(Int(abnormalTime) ?? 0, sucBlock: {
            sucBlock()
        }, failedBlock: { error in failedBlock(error) })
    }

    // MARK: - Private: 校验

    private func validParams() -> Bool {
        if advInterval.isEmpty || (Int(advInterval) ?? 0) < 1 || (Int(advInterval) ?? 0) > 500 {
            return false
        }
        if alarmMode_advTime.isEmpty || (Int(alarmMode_advTime) ?? 0) < 1 || (Int(alarmMode_advTime) ?? 0) > 65535 {
            return false
        }
        if alarmMode_advInterval.isEmpty || (Int(alarmMode_advInterval) ?? 0) < 1 || (Int(alarmMode_advInterval) ?? 0) > 500 {
            return false
        }
        if alarmType == 3 {
            if abnormalTime.isEmpty || (Int(abnormalTime) ?? 0) < 1 || (Int(abnormalTime) ?? 0) > 65535 {
                return false
            }
        }
        return true
    }

    // MARK: - Private: Helpers

    private func fetchTxPowerValueString(_ content: String) -> Int {
        switch content {
        case "-40dBm": return 0
        case "-20dBm": return 1
        case "-16dBm": return 2
        case "-12dBm": return 3
        case "-8dBm":  return 4
        case "-4dBm":  return 5
        case "0dBm":   return 6
        case "3dBm":   return 7
        case "4dBm":   return 8
        default:       return 0
        }
    }

    private func operationFailed(_ msg: String, failedBlock: @escaping (Error) -> Void) {
        DispatchQueue.main.async {
            let error = NSError(domain: "AlarmModeConfigParams",
                                code: -999,
                                userInfo: ["errorInfo": msg])
            failedBlock(error)
        }
    }
}
