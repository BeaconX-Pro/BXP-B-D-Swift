//
//  MKBXDQuickSwitchModel.swift
//  MKBeaconButtonSwiftProject
//
//  Created by aa on 2026/9/17.
//  Copyright © 2026 aadyx2007@163.com. All rights reserved.
//

import Foundation

import MKBaseSwiftModule

@MainActor
public final class MKBXDQuickSwitchModel: NSObject {

    public var connectable: Bool = false
    public var passwordVerification: Bool = false
    public var resetByButton: Bool = false
    public var scanPacket: Bool = false
    public var dismiss: Bool = false
    /// BXP-CR 支持
    public var turnOffByButton: Bool = false

    // MARK: - Read

    public func read(sucBlock: @escaping () -> Void,
                     failedBlock: @escaping (Error) -> Void) {
        readConnectable(sucBlock: { [weak self] in
            guard let self = self else { return }
            self.readPasswordVerification(sucBlock: { [weak self] in
                guard let self = self else { return }
                self.readResetByButton(sucBlock: { [weak self] in
                    guard let self = self else { return }
                    self.readScanPacket(sucBlock: { [weak self] in
                        guard let self = self else { return }
                        self.readDismissAlarmByButton(sucBlock: { [weak self] in
                            guard let self = self else { return }
                            if MKBXDConnectManager.shared.isCR {
                                self.readTurnOffByButton(sucBlock: {
                                    sucBlock()
                                }, failedBlock: failedBlock)
                            } else {
                                sucBlock()
                            }
                        }, failedBlock: failedBlock)
                    }, failedBlock: failedBlock)
                }, failedBlock: failedBlock)
            }, failedBlock: failedBlock)
        }, failedBlock: failedBlock)
    }

    // MARK: - Private

    private func readConnectable(sucBlock: @escaping () -> Void,
                                  failedBlock: @escaping (Error) -> Void) {
        MKBXDInterface.bxd_readConnectable(sucBlock: { [weak self] returnData in
            guard let self = self else { return }
            let result = (returnData as? [String: Any])?["result"] as? [String: Any] ?? [:]
            self.connectable = (result["connectable"] as? Bool) ?? false
            sucBlock()
        }, failedBlock: { error in failedBlock(error) })
    }

    private func readPasswordVerification(sucBlock: @escaping () -> Void,
                                           failedBlock: @escaping (Error) -> Void) {
        MKBXDInterface.bxd_readPasswordVerification(sucBlock: { [weak self] returnData in
            guard let self = self else { return }
            let result = (returnData as? [String: Any])?["result"] as? [String: Any] ?? [:]
            self.passwordVerification = ((result["state"] as? String) == "01")
            sucBlock()
        }, failedBlock: { error in failedBlock(error) })
    }

    private func readResetByButton(sucBlock: @escaping () -> Void,
                                    failedBlock: @escaping (Error) -> Void) {
        MKBXDInterface.bxd_readResetDeviceByButtonStatus(sucBlock: { [weak self] returnData in
            guard let self = self else { return }
            let result = (returnData as? [String: Any])?["result"] as? [String: Any] ?? [:]
            self.resetByButton = (result["isOn"] as? Bool) ?? false
            sucBlock()
        }, failedBlock: { error in failedBlock(error) })
    }

    private func readScanPacket(sucBlock: @escaping () -> Void,
                                 failedBlock: @escaping (Error) -> Void) {
        MKBXDInterface.bxd_readScanResponsePacket(sucBlock: { [weak self] returnData in
            guard let self = self else { return }
            let result = (returnData as? [String: Any])?["result"] as? [String: Any] ?? [:]
            self.scanPacket = (result["isOn"] as? Bool) ?? false
            sucBlock()
        }, failedBlock: { error in failedBlock(error) })
    }

    private func readDismissAlarmByButton(sucBlock: @escaping () -> Void,
                                           failedBlock: @escaping (Error) -> Void) {
        MKBXDInterface.bxd_readDismissAlarmByButton(sucBlock: { [weak self] returnData in
            guard let self = self else { return }
            let result = (returnData as? [String: Any])?["result"] as? [String: Any] ?? [:]
            self.dismiss = (result["isOn"] as? Bool) ?? false
            sucBlock()
        }, failedBlock: { error in failedBlock(error) })
    }

    private func readTurnOffByButton(sucBlock: @escaping () -> Void,
                                      failedBlock: @escaping (Error) -> Void) {
        MKBXDInterface.bxd_readTurnOffByButtonStatus(sucBlock: { [weak self] returnData in
            guard let self = self else { return }
            let result = (returnData as? [String: Any])?["result"] as? [String: Any] ?? [:]
            self.turnOffByButton = (result["isOn"] as? Bool) ?? false
            sucBlock()
        }, failedBlock: { error in failedBlock(error) })
    }
}
