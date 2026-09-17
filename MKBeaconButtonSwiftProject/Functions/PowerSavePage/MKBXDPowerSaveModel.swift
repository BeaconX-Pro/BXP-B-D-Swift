//
//  MKBXDPowerSaveModel.swift
//  MKBeaconButtonSwiftProject
//
//  Created by aa on 2026/9/17.
//  Copyright © 2026 aadyx2007@163.com. All rights reserved.
//

import Foundation

import MKBaseSwiftModule

@MainActor
public final class MKBXDPowerSaveModel: NSObject {

    public var isOn: Bool = false

    /// 1~65535
    public var triggerTime: String = ""

    // MARK: - Read

    public func readData(sucBlock: @escaping () -> Void,
                         failedBlock: @escaping (Error) -> Void) {
        readModeStatus(sucBlock: { [weak self] in
            guard let self = self else { return }
            self.readTriggerTime(sucBlock: {
                sucBlock()
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
        configModeStatus(sucBlock: { [weak self] in
            guard let self = self else { return }
            if self.isOn {
                self.configTriggerTime(sucBlock: {
                    sucBlock()
                }, failedBlock: failedBlock)
            } else {
                sucBlock()
            }
        }, failedBlock: failedBlock)
    }

    // MARK: - Private

    private func readModeStatus(sucBlock: @escaping () -> Void,
                                 failedBlock: @escaping (Error) -> Void) {
        MKBXDInterface.bxd_readPowerSavingMode(sucBlock: { [weak self] returnData in
            guard let self = self else { return }
            let result = (returnData as? [String: Any])?["result"] as? [String: Any] ?? [:]
            self.isOn = (result["isOn"] as? Bool) ?? false
            sucBlock()
        }, failedBlock: { error in failedBlock(error) })
    }

    private func readTriggerTime(sucBlock: @escaping () -> Void,
                                  failedBlock: @escaping (Error) -> Void) {
        MKBXDInterface.bxd_readStaticTriggerTime(sucBlock: { [weak self] returnData in
            guard let self = self else { return }
            let result = (returnData as? [String: Any])?["result"] as? [String: Any] ?? [:]
            self.triggerTime = (result["time"] as? String) ?? ""
            sucBlock()
        }, failedBlock: { error in failedBlock(error) })
    }

    private func configModeStatus(sucBlock: @escaping () -> Void,
                                   failedBlock: @escaping (Error) -> Void) {
        MKBXDInterface.bxd_configPowerSavingMode(isOn, sucBlock: {
            sucBlock()
        }, failedBlock: { error in failedBlock(error) })
    }

    private func configTriggerTime(sucBlock: @escaping () -> Void,
                                    failedBlock: @escaping (Error) -> Void) {
        MKBXDInterface.bxd_configStaticTriggerTime(Int(triggerTime) ?? 0, sucBlock: {
            sucBlock()
        }, failedBlock: { error in failedBlock(error) })
    }

    private func validParams() -> Bool {
        if isOn {
            if triggerTime.isEmpty || (Int(triggerTime) ?? 0) < 1 || (Int(triggerTime) ?? 0) > 65535 {
                return false
            }
        }
        return true
    }

    private func operationFailed(_ msg: String, failedBlock: @escaping (Error) -> Void) {
        DispatchQueue.main.async {
            let error = NSError(domain: "PowerSaveParams",
                                code: -999,
                                userInfo: ["errorInfo": msg])
            failedBlock(error)
        }
    }
}
