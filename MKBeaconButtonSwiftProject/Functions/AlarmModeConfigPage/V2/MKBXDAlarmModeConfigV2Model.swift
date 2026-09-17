//
//  MKBXDAlarmModeConfigV2Model.swift
//  MKBeaconButtonSwiftProject
//
//  Created by aa on 2026/9/17.
//  Copyright © 2026 aadyx2007@163.com. All rights reserved.
//

import Foundation

import MKBaseSwiftModule

@MainActor
public final class MKBXDAlarmModeConfigV2Model: NSObject {

    // MARK: - 状态

    public var singleIsOn: Bool = false
    public var doubleIsOn: Bool = false
    public var longIsOn: Bool = false
    public var inactivityIsOn: Bool = false

    /// 0:single 1:double 2:long 3:abnormal
    public var alarmType: Int = 0

    public var slotType: MKBXDSlotType = .alarmInfo

    public var advIsOn: Bool = false

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

    // MARK: - UID

    public var namespaceID: String = ""
    public var instanceID: String = ""

    // MARK: - iBeacon

    public var major: String = ""
    public var minor: String = ""
    public var uuid: String = ""

    // MARK: - 底部 Trigger notification type

    public var showTriggerType: Bool = false

    /// 0:Silent 1:LED 2:Buzzer 3:LED+Buzzer (BXP-B-D)
    /// 0:Silent 1:LED 2:Vibration 3:Buzzer 4:LED+Vibration 5:LED+Buzzer (BXP-CR)
    public var alarmNotiType: Int = 0

    // MARK: - LED notification

    public var blinkingTime: String = ""
    public var blinkingInterval: String = ""

    // MARK: - Vibration notification

    public var vibratingTime: String = ""
    public var vibratingInterval: String = ""

    // MARK: - Buzzer notification

    public var ringingTime: String = ""
    public var ringingInterval: String = ""

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
                        self.readContentData(sucBlock: { [weak self] in
                            guard let self = self else { return }
                            self.readRestData(sucBlock: sucBlock, failedBlock: failedBlock)
                        }, failedBlock: failedBlock)
                    }, failedBlock: failedBlock)
                }, failedBlock: failedBlock)
            }, failedBlock: failedBlock)
        }, failedBlock: failedBlock)
    }

    private func readRestData(sucBlock: @escaping () -> Void,
                              failedBlock: @escaping (Error) -> Void) {
        // abnormalTime
        func stepAbnormalTime() {
            if alarmType == 3 {
                readAbnormalTime(sucBlock: stepAlarmType, failedBlock: failedBlock)
            } else {
                stepAlarmType()
            }
        }
        // alarmType
        func stepAlarmType() {
            readAlarmType(sucBlock: stepLEDParams, failedBlock: failedBlock)
        }
        // LED
        func stepLEDParams() {
            readLEDParams(sucBlock: stepVibrateParams, failedBlock: failedBlock)
        }
        // Vibrate
        func stepVibrateParams() {
            if MKBXDConnectManager.shared.isCR {
                readVibrateParams(sucBlock: stepBuzzerParams, failedBlock: failedBlock)
            } else {
                stepBuzzerParams()
            }
        }
        // Buzzer
        func stepBuzzerParams() {
            readBuzzerParams(sucBlock: {
                sucBlock()
            }, failedBlock: failedBlock)
        }
        stepAbnormalTime()
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
                    self.configContentData(sucBlock: { [weak self] in
                        guard let self = self else { return }
                        self.configRestData(sucBlock: sucBlock, failedBlock: failedBlock)
                    }, failedBlock: failedBlock)
                }, failedBlock: failedBlock)
            }, failedBlock: failedBlock)
        }, failedBlock: failedBlock)
    }

    private func configRestData(sucBlock: @escaping () -> Void,
                                failedBlock: @escaping (Error) -> Void) {
        func stepAbnormalTime() {
            if alarmType == 3 {
                configAbnormalTime(sucBlock: stepAlarmType, failedBlock: failedBlock)
            } else {
                stepAlarmType()
            }
        }
        func stepAlarmType() {
            configAlarmType(sucBlock: stepNotiParams, failedBlock: failedBlock)
        }
        func stepNotiParams() {
            let isCR = MKBXDConnectManager.shared.isCR
            if isCR {
                // BXP-CR
                func stepVibrate() {
                    if alarmNotiType == 2 || alarmNotiType == 4 {
                        configVibrateParams(sucBlock: stepBuzzer, failedBlock: failedBlock)
                    } else { stepBuzzer() }
                }
                func stepBuzzer() {
                    if alarmNotiType == 3 || alarmNotiType == 5 {
                        configBuzzerParams(sucBlock: sucBlock, failedBlock: failedBlock)
                    } else { sucBlock() }
                }
                if alarmNotiType == 1 || alarmNotiType == 4 || alarmNotiType == 5 {
                    configLEDParams(sucBlock: stepVibrate, failedBlock: failedBlock)
                } else {
                    stepVibrate()
                }
            } else {
                // BXP-B-D
                func stepBuzzer() {
                    if alarmNotiType == 2 || alarmNotiType == 3 {
                        configBuzzerParams(sucBlock: sucBlock, failedBlock: failedBlock)
                    } else { sucBlock() }
                }
                if alarmNotiType == 1 || alarmNotiType == 3 {
                    configLEDParams(sucBlock: stepBuzzer, failedBlock: failedBlock)
                } else {
                    stepBuzzer()
                }
            }
        }
        stepAbnormalTime()
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

    private func readContentData(sucBlock: @escaping () -> Void,
                                  failedBlock: @escaping (Error) -> Void) {
        let alarmTypeValue = MKBXDChannelAlarmType(rawValue: alarmType) ?? .single
        MKBXDInterface.bxd_readChannelAdvContent(alarmTypeValue, sucBlock: { [weak self] returnData in
            guard let self = self else { return }
            let result = (returnData as? [String: Any])?["result"] as? [String: Any] ?? [:]
            self.updateContentData(result)
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

    private func readAlarmType(sucBlock: @escaping () -> Void,
                                failedBlock: @escaping (Error) -> Void) {
        let alarmTypeValue = MKBXDChannelAlarmNotifyType(rawValue: alarmType) ?? .single
        MKBXDInterface.bxd_readAlarmNotificationType(alarmTypeValue, sucBlock: { [weak self] returnData in
            guard let self = self else { return }
            let result = (returnData as? [String: Any])?["result"] as? [String: Any] ?? [:]
            let type = Int((result["alarmNotificationType"] as? String) ?? "0") ?? 0
            if MKBXDConnectManager.shared.isCR {
                self.alarmNotiType = type
            } else {
                switch type {
                case 0: self.alarmNotiType = 0
                case 1: self.alarmNotiType = 1
                case 3: self.alarmNotiType = 2
                case 5: self.alarmNotiType = 3
                default: break
                }
            }
            sucBlock()
        }, failedBlock: { error in failedBlock(error) })
    }

    private func readLEDParams(sucBlock: @escaping () -> Void,
                                failedBlock: @escaping (Error) -> Void) {
        let alarmTypeValue = MKBXDChannelAlarmType(rawValue: alarmType) ?? .single
        MKBXDInterface.bxd_readAlarmLEDNotiParams(alarmTypeValue, sucBlock: { [weak self] returnData in
            guard let self = self else { return }
            let result = (returnData as? [String: Any])?["result"] as? [String: Any] ?? [:]
            self.blinkingTime = (result["time"] as? String) ?? ""
            self.blinkingInterval = (result["interval"] as? String) ?? ""
            sucBlock()
        }, failedBlock: { error in failedBlock(error) })
    }

    private func readVibrateParams(sucBlock: @escaping () -> Void,
                                    failedBlock: @escaping (Error) -> Void) {
        let alarmTypeValue = MKBXDChannelAlarmType(rawValue: alarmType) ?? .single
        MKBXDInterface.bxd_readAlarmVibrateNotiParams(alarmTypeValue, sucBlock: { [weak self] returnData in
            guard let self = self else { return }
            let result = (returnData as? [String: Any])?["result"] as? [String: Any] ?? [:]
            self.vibratingTime = (result["time"] as? String) ?? ""
            self.vibratingInterval = (result["interval"] as? String) ?? ""
            sucBlock()
        }, failedBlock: { error in failedBlock(error) })
    }

    private func readBuzzerParams(sucBlock: @escaping () -> Void,
                                   failedBlock: @escaping (Error) -> Void) {
        let alarmTypeValue = MKBXDChannelAlarmType(rawValue: alarmType) ?? .single
        MKBXDInterface.bxd_readAlarmBuzzerNotiParams(alarmTypeValue, sucBlock: { [weak self] returnData in
            guard let self = self else { return }
            let result = (returnData as? [String: Any])?["result"] as? [String: Any] ?? [:]
            self.ringingTime = (result["time"] as? String) ?? ""
            self.ringingInterval = (result["interval"] as? String) ?? ""
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

    private func configContentData(sucBlock: @escaping () -> Void,
                                    failedBlock: @escaping (Error) -> Void) {
        let alarmTypeValue = MKBXDChannelAlarmType(rawValue: alarmType) ?? .single
        switch slotType {
        case .alarmInfo:
            MKBXDInterface.bxd_configChannelContentAlarmInfo(alarmTypeValue, sucBlock: {
                sucBlock()
            }, failedBlock: { error in failedBlock(error) })
        case .uid:
            MKBXDInterface.bxd_configChannelContentUID(alarmTypeValue,
                                                        namespaceID: namespaceID,
                                                        instanceID: instanceID,
                                                        sucBlock: {
                sucBlock()
            }, failedBlock: { error in failedBlock(error) })
        case .beacon:
            MKBXDInterface.bxd_configChannelContentBeacon(alarmTypeValue,
                                                           major: Int(major) ?? 0,
                                                           minor: Int(minor) ?? 0,
                                                           uuid: uuid,
                                                           sucBlock: {
                sucBlock()
            }, failedBlock: { error in failedBlock(error) })
        }
    }

    private func configAbnormalTime(sucBlock: @escaping () -> Void,
                                     failedBlock: @escaping (Error) -> Void) {
        MKBXDInterface.bxd_configAbnormalInactivityTime(Int(abnormalTime) ?? 0, sucBlock: {
            sucBlock()
        }, failedBlock: { error in failedBlock(error) })
    }

    private func configAlarmType(sucBlock: @escaping () -> Void,
                                  failedBlock: @escaping (Error) -> Void) {
        var reminderType: MKBXDReminderType = .silent
        if MKBXDConnectManager.shared.isCR {
            reminderType = MKBXDReminderType(rawValue: alarmNotiType) ?? .silent
        } else {
            switch alarmNotiType {
            case 1: reminderType = .led
            case 2: reminderType = .buzzer
            case 3: reminderType = .ledAndBuzzer
            default: reminderType = .silent
            }
        }
        let alarmTypeValue = MKBXDChannelAlarmNotifyType(rawValue: alarmType) ?? .single
        MKBXDInterface.bxd_configAlarmNotificationType(alarmTypeValue,
                                                        reminderType: reminderType,
                                                        sucBlock: {
            sucBlock()
        }, failedBlock: { error in failedBlock(error) })
    }

    private func configLEDParams(sucBlock: @escaping () -> Void,
                                  failedBlock: @escaping (Error) -> Void) {
        let alarmTypeValue = MKBXDChannelAlarmType(rawValue: alarmType) ?? .single
        MKBXDInterface.bxd_configAlarmLEDNotiParams(alarmTypeValue,
                                                     blinkingTime: Int(blinkingTime) ?? 0,
                                                     blinkingInterval: Int(blinkingInterval) ?? 0,
                                                     sucBlock: {
            sucBlock()
        }, failedBlock: { error in failedBlock(error) })
    }

    private func configVibrateParams(sucBlock: @escaping () -> Void,
                                      failedBlock: @escaping (Error) -> Void) {
        let alarmTypeValue = MKBXDChannelAlarmType(rawValue: alarmType) ?? .single
        MKBXDInterface.bxd_configAlarmVibrateNotiParams(alarmTypeValue,
                                                         vibratingTime: Int(vibratingTime) ?? 0,
                                                         vibratingInterval: Int(vibratingInterval) ?? 0,
                                                         sucBlock: {
            sucBlock()
        }, failedBlock: { error in failedBlock(error) })
    }

    private func configBuzzerParams(sucBlock: @escaping () -> Void,
                                     failedBlock: @escaping (Error) -> Void) {
        let alarmTypeValue = MKBXDChannelAlarmType(rawValue: alarmType) ?? .single
        MKBXDInterface.bxd_configAlarmBuzzerNotiParams(alarmTypeValue,
                                                        ringingTime: Int(ringingTime) ?? 0,
                                                        ringingInterval: Int(ringingInterval) ?? 0,
                                                        sucBlock: {
            sucBlock()
        }, failedBlock: { error in failedBlock(error) })
    }

    // MARK: - Private: Helpers

    private func updateContentData(_ dic: [String: Any]) {
        slotType = MKBXDSlotType(rawValue: Int((dic["advType"] as? String) ?? "0") ?? 0) ?? .alarmInfo
        switch slotType {
        case .alarmInfo:
            return
        case .uid:
            let advContent = dic["advContent"] as? [String: Any] ?? [:]
            namespaceID = (advContent["namespaceID"] as? String) ?? ""
            instanceID = (advContent["instanceID"] as? String) ?? ""
        case .beacon:
            let advContent = dic["advContent"] as? [String: Any] ?? [:]
            uuid = (advContent["uuid"] as? String) ?? ""
            major = (advContent["major"] as? String) ?? ""
            minor = (advContent["minor"] as? String) ?? ""
        }
    }

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

    // MARK: - Private: 校验

    private func validParams() -> Bool {
        if slotType == .uid {
            if namespaceID.isEmpty || namespaceID.count != 20 ||
               instanceID.isEmpty || instanceID.count != 12 {
                return false
            }
        } else if slotType == .beacon {
            if major.isEmpty || (Int(major) ?? 0) < 0 || (Int(major) ?? 0) > 65535 { return false }
            if minor.isEmpty || (Int(minor) ?? 0) < 0 || (Int(minor) ?? 0) > 65535 { return false }
            if uuid.isEmpty || uuid.count != 32 { return false }
        }

        if advInterval.isEmpty || (Int(advInterval) ?? 0) < 1 || (Int(advInterval) ?? 0) > 500 { return false }
        if alarmMode_advTime.isEmpty || (Int(alarmMode_advTime) ?? 0) < 1 || (Int(alarmMode_advTime) ?? 0) > 65535 { return false }
        if alarmMode_advInterval.isEmpty || (Int(alarmMode_advInterval) ?? 0) < 1 || (Int(alarmMode_advInterval) ?? 0) > 500 { return false }

        if alarmType == 3 {
            if abnormalTime.isEmpty || (Int(abnormalTime) ?? 0) < 1 || (Int(abnormalTime) ?? 0) > 65535 { return false }
        }

        if alarmNotiType > 0 {
            if !validTriggerNotiParams() { return false }
        }
        return true
    }

    private func validTriggerNotiParams() -> Bool {
        if alarmNotiType == 0 { return true }

        var needValidLed = false
        var needValidVibration = false
        var needValidBuzzer = false

        if MKBXDConnectManager.shared.isCR {
            if alarmNotiType == 1 || alarmNotiType == 4 || alarmNotiType == 5 { needValidLed = true }
            if alarmNotiType == 2 || alarmNotiType == 4 { needValidVibration = true }
            if alarmNotiType == 3 || alarmNotiType == 5 { needValidBuzzer = true }
        } else {
            if alarmNotiType == 1 || alarmNotiType == 3 { needValidLed = true }
            if alarmNotiType == 2 || alarmNotiType == 3 { needValidBuzzer = true }
        }

        if needValidLed && !validLEDParams() { return false }
        if needValidVibration && !validVibrationParams() { return false }
        if needValidBuzzer && !validBuzzerParams() { return false }
        return true
    }

    private func validLEDParams() -> Bool {
        if blinkingTime.isEmpty || (Int(blinkingTime) ?? 0) < 1 || (Int(blinkingTime) ?? 0) > 6000 { return false }
        if blinkingInterval.isEmpty || (Int(blinkingInterval) ?? 0) < 0 || (Int(blinkingInterval) ?? 0) > 100 { return false }
        return true
    }

    private func validVibrationParams() -> Bool {
        if vibratingTime.isEmpty || (Int(vibratingTime) ?? 0) < 1 || (Int(vibratingTime) ?? 0) > 6000 { return false }
        if vibratingInterval.isEmpty || (Int(vibratingInterval) ?? 0) < 0 || (Int(vibratingInterval) ?? 0) > 100 { return false }
        return true
    }

    private func validBuzzerParams() -> Bool {
        if ringingTime.isEmpty || (Int(ringingTime) ?? 0) < 1 || (Int(ringingTime) ?? 0) > 6000 { return false }
        if ringingInterval.isEmpty || (Int(ringingInterval) ?? 0) < 0 || (Int(ringingInterval) ?? 0) > 100 { return false }
        return true
    }
}
