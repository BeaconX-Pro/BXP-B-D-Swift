//
//  MKBXDDismissConfigModel.swift
//  MKBeaconButtonSwiftProject
//
//  Created by aa on 2026/9/17.
//  Copyright © 2026 aadyx2007@163.com. All rights reserved.
//

import Foundation

import MKBaseSwiftModule

@MainActor
public final class MKBXDDismissConfigModel: NSObject {

    /// BXP-B-D:
    /// 0:Silent 1:LED 2:Buzzer 3:LED+Buzzer
    /// BXP-CR:
    /// 0:Silent 1:LED 2:Vibration 3:Buzzer 4:LED+Vibration 5:LED+Buzzer
    public var dismissAlarmNotiType: Int = 0

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
        readDismissType(sucBlock: { [weak self] in
            guard let self = self else { return }
            self.readLEDParams(sucBlock: { [weak self] in
                guard let self = self else { return }
                self.readVibrationAndBuzzer(sucBlock: sucBlock, failedBlock: failedBlock)
            }, failedBlock: failedBlock)
        }, failedBlock: failedBlock)
    }

    private func readVibrationAndBuzzer(sucBlock: @escaping () -> Void,
                                        failedBlock: @escaping (Error) -> Void) {
        if MKBXDConnectManager.shared.isCR {
            readVibrationParams(sucBlock: { [weak self] in
                guard let self = self else { return }
                self.readBuzzerParams(sucBlock: sucBlock, failedBlock: failedBlock)
            }, failedBlock: failedBlock)
        } else {
            readBuzzerParams(sucBlock: sucBlock, failedBlock: failedBlock)
        }
    }

    // MARK: - Config

    public func configData(sucBlock: @escaping () -> Void,
                           failedBlock: @escaping (Error) -> Void) {
        guard validParams() else {
            operationFailed("Params Error", failedBlock: failedBlock)
            return
        }

        configDismissType(sucBlock: { [weak self] in
            guard let self = self else { return }
            self.configNotiParams(sucBlock: sucBlock, failedBlock: failedBlock)
        }, failedBlock: failedBlock)
    }

    private func configNotiParams(sucBlock: @escaping () -> Void,
                                   failedBlock: @escaping (Error) -> Void) {
        let isCR = MKBXDConnectManager.shared.isCR
        if isCR {
            func stepVibration() {
                if dismissAlarmNotiType == 2 || dismissAlarmNotiType == 4 {
                    configVibrationParams(sucBlock: stepBuzzer, failedBlock: failedBlock)
                } else { stepBuzzer() }
            }
            func stepBuzzer() {
                if dismissAlarmNotiType == 3 || dismissAlarmNotiType == 5 {
                    configBuzzerParams(sucBlock: sucBlock, failedBlock: failedBlock)
                } else { sucBlock() }
            }
            if dismissAlarmNotiType == 1 || dismissAlarmNotiType == 4 || dismissAlarmNotiType == 5 {
                configLEDParams(sucBlock: stepVibration, failedBlock: failedBlock)
            } else {
                stepVibration()
            }
        } else {
            func stepBuzzer() {
                if dismissAlarmNotiType == 2 || dismissAlarmNotiType == 3 {
                    configBuzzerParams(sucBlock: sucBlock, failedBlock: failedBlock)
                } else { sucBlock() }
            }
            if dismissAlarmNotiType == 1 || dismissAlarmNotiType == 3 {
                configLEDParams(sucBlock: stepBuzzer, failedBlock: failedBlock)
            } else {
                stepBuzzer()
            }
        }
    }

    // MARK: - Private: 读

    private func readDismissType(sucBlock: @escaping () -> Void,
                                  failedBlock: @escaping (Error) -> Void) {
        MKBXDInterface.bxd_readDismissAlarmNotificationType(sucBlock: { [weak self] returnData in
            guard let self = self else { return }
            let result = (returnData as? [String: Any])?["result"] as? [String: Any] ?? [:]
            let type = Int((result["type"] as? String) ?? "0") ?? 0
            if MKBXDConnectManager.shared.isCR {
                self.dismissAlarmNotiType = type
            } else {
                switch type {
                case 0: self.dismissAlarmNotiType = 0
                case 1: self.dismissAlarmNotiType = 1
                case 3: self.dismissAlarmNotiType = 2
                case 5: self.dismissAlarmNotiType = 3
                default: break
                }
            }
            sucBlock()
        }, failedBlock: { error in failedBlock(error) })
    }

    private func readLEDParams(sucBlock: @escaping () -> Void,
                                failedBlock: @escaping (Error) -> Void) {
        MKBXDInterface.bxd_readDismissAlarmLEDNotiParams(sucBlock: { [weak self] returnData in
            guard let self = self else { return }
            let result = (returnData as? [String: Any])?["result"] as? [String: Any] ?? [:]
            self.blinkingTime = (result["time"] as? String) ?? ""
            self.blinkingInterval = (result["interval"] as? String) ?? ""
            sucBlock()
        }, failedBlock: { error in failedBlock(error) })
    }

    private func readVibrationParams(sucBlock: @escaping () -> Void,
                                      failedBlock: @escaping (Error) -> Void) {
        MKBXDInterface.bxd_readDismissAlarmVibrationNotiParams(sucBlock: { [weak self] returnData in
            guard let self = self else { return }
            let result = (returnData as? [String: Any])?["result"] as? [String: Any] ?? [:]
            self.vibratingTime = (result["time"] as? String) ?? ""
            self.vibratingInterval = (result["interval"] as? String) ?? ""
            sucBlock()
        }, failedBlock: { error in failedBlock(error) })
    }

    private func readBuzzerParams(sucBlock: @escaping () -> Void,
                                   failedBlock: @escaping (Error) -> Void) {
        MKBXDInterface.bxd_readDismissAlarmBuzzerNotiParams(sucBlock: { [weak self] returnData in
            guard let self = self else { return }
            let result = (returnData as? [String: Any])?["result"] as? [String: Any] ?? [:]
            self.ringingTime = (result["time"] as? String) ?? ""
            self.ringingInterval = (result["interval"] as? String) ?? ""
            sucBlock()
        }, failedBlock: { error in failedBlock(error) })
    }

    // MARK: - Private: 配置

    private func configDismissType(sucBlock: @escaping () -> Void,
                                    failedBlock: @escaping (Error) -> Void) {
        var reminderType: MKBXDReminderType = .silent
        if MKBXDConnectManager.shared.isCR {
            reminderType = MKBXDReminderType(rawValue: dismissAlarmNotiType) ?? .silent
        } else {
            switch dismissAlarmNotiType {
            case 1: reminderType = .led
            case 2: reminderType = .buzzer
            case 3: reminderType = .ledAndBuzzer
            default: reminderType = .silent
            }
        }
        MKBXDInterface.bxd_configDismissAlarmNotificationType(reminderType, sucBlock: {
            sucBlock()
        }, failedBlock: { error in failedBlock(error) })
    }

    private func configLEDParams(sucBlock: @escaping () -> Void,
                                  failedBlock: @escaping (Error) -> Void) {
        MKBXDInterface.bxd_configDismissAlarmLEDNotiParams(time: Int(blinkingTime) ?? 0,
                                                            interval: Int(blinkingInterval) ?? 0,
                                                            sucBlock: {
            sucBlock()
        }, failedBlock: { error in failedBlock(error) })
    }

    private func configVibrationParams(sucBlock: @escaping () -> Void,
                                        failedBlock: @escaping (Error) -> Void) {
        MKBXDInterface.bxd_configDismissAlarmVibrationNotiParams(time: Int(vibratingTime) ?? 0,
                                                                  interval: Int(vibratingInterval) ?? 0,
                                                                  sucBlock: {
            sucBlock()
        }, failedBlock: { error in failedBlock(error) })
    }

    private func configBuzzerParams(sucBlock: @escaping () -> Void,
                                     failedBlock: @escaping (Error) -> Void) {
        MKBXDInterface.bxd_configDismissAlarmBuzzerNotiParams(time: Int(ringingTime) ?? 0,
                                                               interval: Int(ringingInterval) ?? 0,
                                                               sucBlock: {
            sucBlock()
        }, failedBlock: { error in failedBlock(error) })
    }

    // MARK: - Private: 校验

    private func validParams() -> Bool {
        var needValidLed = false
        var needValidVibration = false
        var needValidBuzzer = false

        if MKBXDConnectManager.shared.isCR {
            if dismissAlarmNotiType == 1 || dismissAlarmNotiType == 4 || dismissAlarmNotiType == 5 { needValidLed = true }
            if dismissAlarmNotiType == 2 || dismissAlarmNotiType == 4 { needValidVibration = true }
            if dismissAlarmNotiType == 3 || dismissAlarmNotiType == 5 { needValidBuzzer = true }
        } else {
            if dismissAlarmNotiType == 1 || dismissAlarmNotiType == 3 { needValidLed = true }
            if dismissAlarmNotiType == 2 || dismissAlarmNotiType == 3 { needValidBuzzer = true }
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

    // MARK: - Private: Helpers

    private func operationFailed(_ msg: String, failedBlock: @escaping (Error) -> Void) {
        DispatchQueue.main.async {
            let error = NSError(domain: "DismissAlarmParams",
                                code: -999,
                                userInfo: ["errorInfo": msg])
            failedBlock(error)
        }
    }
}
