//
//  MKBXDSettingPageModel.swift
//  MKBeaconButtonSwiftProject
//
//  Created by aa on 2026/9/17.
//  Copyright © 2026 aadyx2007@163.com. All rights reserved.
//

import Foundation

import MKBaseSwiftModule

@MainActor
public final class MKBXDSettingPageModel: NSObject {

    public var clickInterval: String = ""

    // MARK: - Read

    public func readData(sucBlock: @escaping () -> Void,
                         failedBlock: @escaping (Error) -> Void) {
        readInterval(sucBlock: {
            sucBlock()
        }, failedBlock: failedBlock)
    }

    // MARK: - Config

    public func configData(sucBlock: @escaping () -> Void,
                           failedBlock: @escaping (Error) -> Void) {
        guard validParams() else {
            operationFailed("Params Error", failedBlock: failedBlock)
            return
        }
        configInterval(sucBlock: {
            sucBlock()
        }, failedBlock: failedBlock)
    }

    // MARK: - Private

    private func readInterval(sucBlock: @escaping () -> Void,
                               failedBlock: @escaping (Error) -> Void) {
        MKBXDInterface.bxd_readEffectiveClickInterval(sucBlock: { [weak self] returnData in
            guard let self = self else { return }
            let result = (returnData as? [String: Any])?["result"] as? [String: Any] ?? [:]
            self.clickInterval = (result["interval"] as? String) ?? ""
            sucBlock()
        }, failedBlock: { error in failedBlock(error) })
    }

    private func configInterval(sucBlock: @escaping () -> Void,
                                 failedBlock: @escaping (Error) -> Void) {
        MKBXDInterface.bxd_configEffectiveClickInterval(Int(clickInterval) ?? 0,
                                                         sucBlock: {
            sucBlock()
        }, failedBlock: { error in failedBlock(error) })
    }

    private func validParams() -> Bool {
        if clickInterval.isEmpty || (Int(clickInterval) ?? 0) < 5 || (Int(clickInterval) ?? 0) > 15 {
            return false
        }
        return true
    }

    private func operationFailed(_ msg: String, failedBlock: @escaping (Error) -> Void) {
        DispatchQueue.main.async {
            let error = NSError(domain: "SettingsParams",
                                code: -999,
                                userInfo: ["errorInfo": msg])
            failedBlock(error)
        }
    }
}
