//
//  MKBXDAlarmNotiTypeModel.swift
//  MKBeaconButtonSwiftProject
//
//  Created by aa on 2026/9/17.
//  Copyright © 2026 aadyx2007@163.com. All rights reserved.
//

import Foundation

import MKBaseSwiftModule

@MainActor
public final class MKBXDAlarmNotiTypeModel: NSObject {

    /// 0:single 1:double 2:long 3:abnormal 4:long connection mode
    public var alarmType: Int = 0

    /// BXP-B-D:
    /// 0:Silent 1:LED 2:Buzzer 3:LED+Buzzer
    /// BXP-CR:
    /// 0:Silent 1:LED 2:Vibration 3:Buzzer 4:LED+Vibration 5:LED+Buzzer
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
        readAlarmType(sucBlock: { [weak self] in
            guard let self = self else { return }
            self.readLEDParams(sucBlock: { [weak self] in
                guard let self = self else { return }
                self.readVibrateAndBuzzer(sucBlock: sucBlock, failedBlock: failedBlock)
            }, failedBlock: failedBlock)
        }, failedBlock: failedBlock)
    }

    private func readVibrateAndBuzzer(sucBlock: @escaping () -> Void,
                                       failedBlock: @escaping (Error) -> Void) {
        if MKBXDConnectManager.shared.isCR {
            readVibrateParams(sucBlock: { [weak self] in
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

        configAlarmType(sucBlock: { [weak self] in
            guard let self = self else { return }
            self.configNotiParams(sucBlock: sucBlock, failedBlock: failedBlock)
        }, failedBlock: failedBlock)
    }

    private func configNotiParams(sucBlock: @escaping () -> Void,
                                   failedBlock: @escaping (Error) -> Void) {
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

    // MARK: - Private: 读

    private func readAlarmType(sucBlock: @escaping () -> Void,
                                failedBlock: @escaping (Error) -> Void) {
        let alarmTypeValue = MKBXDChannelAlarmNotifyType(rawValue: alarmType) ?? .single
        MKBXDInterface.bxd_readAlarmNotificationType(alarmTypeValue, sucBlock: { [weak self] returnData in
            guard let self = self else { return }
            let result = (returnData as? [String: Any])?["result"] as? [String: Any] ?? [:]
            self.alarmNotiType = Int((result["alarmNotificationType"] as? String) ?? "0") ?? 0
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

    private func configAlarmType(sucBlock: @escaping () -> Void,
                                  failedBlock: @escaping (Error) -> Void) {
        let reminderType = MKBXDReminderType(rawValue: alarmNotiType) ?? .silent
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

    // MARK: - Private: 校验

    private func validParams() -> Bool {
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

    // MARK: - Private: Helpers

    private func operationFailed(_ msg: String, failedBlock: @escaping (Error) -> Void) {
        DispatchQueue.main.async {
            let error = NSError(domain: "AlarmNotiTypeParams",
                                code: -999,
                                userInfo: ["errorInfo": msg])
            failedBlock(error)
        }
    }
}
