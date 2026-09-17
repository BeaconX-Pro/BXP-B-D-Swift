//
//  MKBXDDevicePageModel.swift
//  MKBeaconButtonSwiftProject
//
//  Created by aa on 2026/9/17.
//  Copyright © 2026 aadyx2007@163.com. All rights reserved.
//

import Foundation

import MKBaseSwiftModule

@MainActor
public final class MKBXDDevicePageModel: NSObject {

    public var deviceName: String = ""
    public var deviceID: String = ""

    // MARK: - Read

    public func readData(sucBlock: @escaping () -> Void,
                         failedBlock: @escaping (Error) -> Void) {
        readDeviceName(sucBlock: { [weak self] in
            guard let self = self else { return }
            self.readDeviceID(sucBlock: {
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
        configDeviceName(sucBlock: { [weak self] in
            guard let self = self else { return }
            self.configDeviceID(sucBlock: {
                sucBlock()
            }, failedBlock: failedBlock)
        }, failedBlock: failedBlock)
    }

    // MARK: - Private

    private func readDeviceName(sucBlock: @escaping () -> Void,
                                 failedBlock: @escaping (Error) -> Void) {
        MKBXDInterface.bxd_readDeviceName(sucBlock: { [weak self] returnData in
            guard let self = self else { return }
            let result = (returnData as? [String: Any])?["result"] as? [String: Any] ?? [:]
            self.deviceName = (result["deviceName"] as? String) ?? ""
            sucBlock()
        }, failedBlock: { error in failedBlock(error) })
    }

    private func readDeviceID(sucBlock: @escaping () -> Void,
                               failedBlock: @escaping (Error) -> Void) {
        MKBXDInterface.bxd_readDeviceID(sucBlock: { [weak self] returnData in
            guard let self = self else { return }
            let result = (returnData as? [String: Any])?["result"] as? [String: Any] ?? [:]
            self.deviceID = (result["deviceID"] as? String) ?? ""
            sucBlock()
        }, failedBlock: { error in failedBlock(error) })
    }

    private func configDeviceName(sucBlock: @escaping () -> Void,
                                   failedBlock: @escaping (Error) -> Void) {
        MKBXDInterface.bxd_configDeviceName(deviceName, sucBlock: {
            sucBlock()
        }, failedBlock: { error in failedBlock(error) })
    }

    private func configDeviceID(sucBlock: @escaping () -> Void,
                                 failedBlock: @escaping (Error) -> Void) {
        MKBXDInterface.bxd_configDeviceID(deviceID, sucBlock: {
            sucBlock()
        }, failedBlock: { error in failedBlock(error) })
    }

    private func validParams() -> Bool {
        if deviceName.isEmpty || deviceName.count > 10 { return false }
        if deviceID.isEmpty || deviceID.count % 2 != 0 || deviceID.count > 12 { return false }
        return true
    }

    private func operationFailed(_ msg: String, failedBlock: @escaping (Error) -> Void) {
        DispatchQueue.main.async {
            let error = NSError(domain: "DeviceParams",
                                code: -999,
                                userInfo: ["errorInfo": msg])
            failedBlock(error)
        }
    }
}
