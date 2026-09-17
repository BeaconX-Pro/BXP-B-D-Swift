//
//  MKBXDRemoteReminderModel.swift
//  MKBeaconButtonSwiftProject
//
//  Created by aa on 2026/9/17.
//  Copyright © 2026 aadyx2007@163.com. All rights reserved.
//

import Foundation

import MKBaseSwiftModule

@MainActor
public final class MKBXDRemoteReminderModel: NSObject {

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
        readLEDParams(sucBlock: { [weak self] in
            guard let self = self else { return }
            self.readVibrationAndBuzzer(sucBlock: sucBlock, failedBlock: failedBlock)
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

    // MARK: - Private

    private func readLEDParams(sucBlock: @escaping () -> Void,
                                failedBlock: @escaping (Error) -> Void) {
        MKBXDInterface.bxd_readRemoteReminderLEDNotiParams(sucBlock: { [weak self] returnData in
            guard let self = self else { return }
            let result = (returnData as? [String: Any])?["result"] as? [String: Any] ?? [:]
            self.blinkingTime = (result["time"] as? String) ?? ""
            self.blinkingInterval = (result["interval"] as? String) ?? ""
            sucBlock()
        }, failedBlock: { error in failedBlock(error) })
    }

    private func readVibrationParams(sucBlock: @escaping () -> Void,
                                      failedBlock: @escaping (Error) -> Void) {
        MKBXDInterface.bxd_readRemoteReminderVibrationNotiParams(sucBlock: { [weak self] returnData in
            guard let self = self else { return }
            let result = (returnData as? [String: Any])?["result"] as? [String: Any] ?? [:]
            self.vibratingTime = (result["time"] as? String) ?? ""
            self.vibratingInterval = (result["interval"] as? String) ?? ""
            sucBlock()
        }, failedBlock: { error in failedBlock(error) })
    }

    private func readBuzzerParams(sucBlock: @escaping () -> Void,
                                   failedBlock: @escaping (Error) -> Void) {
        MKBXDInterface.bxd_readRemoteReminderBuzzerNotiParams(sucBlock: { [weak self] returnData in
            guard let self = self else { return }
            let result = (returnData as? [String: Any])?["result"] as? [String: Any] ?? [:]
            self.ringingTime = (result["time"] as? String) ?? ""
            self.ringingInterval = (result["interval"] as? String) ?? ""
            sucBlock()
        }, failedBlock: { error in failedBlock(error) })
    }
}
