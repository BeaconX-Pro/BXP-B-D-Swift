//
//  MKBXDConnectManager.swift
//  MKBeaconButtonSwiftProject
//
//  Created by aa on 2026/9/17.
//  Copyright © 2026 aadyx2007@163.com. All rights reserved.
//

import Foundation
@preconcurrency import CoreBluetooth

import MKBaseSwiftModule
import MKSwiftBleModule

public final class MKBXDConnectManager: NSObject {

    // MARK: - Singleton

    public static let shared = MKBXDConnectManager()
    private override init() { super.init() }

    // MARK: - Properties

    /// 当前连接密码
    public var password: String = ""

    /// 是否需要密码连接
    public var needPassword: Bool = false

    /// 设备类型 00:旧固件 01:支持长链接模式 02:2.0版本(BXP-B-D新增了双按键支持)
    public var deviceType: String = ""

    /// 仅仅当 deviceType=02 的时候才支持当前功能
    /// 1:Single button, only for B2
    /// 2:Single button, only for B2
    /// 3:Double button
    public var pcbType: Int = 0

    /// 是否带有三轴传感器
    public var threeSensor: Bool = false

    /// 是否带有温湿度传感器
    public var htSensor: Bool = false

    /// 是否带有光感传感器
    public var lightSensor: Bool = false

    /// 是否是 BXP-CR
    public var isCR: Bool = false

    /// 是否是双按键，只有 BXP-B-D & deviceType=2 & pcbType=3 才支持
    public var doubleBtn: Bool = false

    /// 使用新版本的 dfu 流程
    public var isBXPB03D: Bool = false

    // MARK: - Connect

    /// 连接设备
    /// - Parameters:
    ///   - peripheral: 设备
    ///   - password: 密码
    ///   - sucBlock: 成功回调
    ///   - failedBlock: 失败回调
    public func connectDevice(_ peripheral: CBPeripheral,
                              password: String,
                              sucBlock: (() -> Void)?,
                              failedBlock: @escaping (Error) -> Void) {
        // 1. 连接（带密码 or 免密）
        if !password.isEmpty && password.count <= 16 {
            // 有密码登录
            connectWithPassword(peripheral, password: password, sucBlock: { [weak self] in
                guard let self = self else { return }
                self.needPassword = true
                self.password = password
                self.readDeviceInfoAndFinish(peripheral, sucBlock: sucBlock, failedBlock: failedBlock)
            }, failedBlock: { error in
                self.operationFailed(error, failedBlock: failedBlock)
            })
        } else {
            // 免密登录
            connectWithoutPassword(peripheral, sucBlock: { [weak self] in
                guard let self = self else { return }
                self.needPassword = false
                self.password = ""
                self.readDeviceInfoAndFinish(peripheral, sucBlock: sucBlock, failedBlock: failedBlock)
            }, failedBlock: { error in
                self.operationFailed(error, failedBlock: failedBlock)
            })
        }
    }

    // MARK: - Private: Connect

    private func connectWithPassword(_ peripheral: CBPeripheral,
                                     password: String,
                                     sucBlock: @escaping () -> Void,
                                     failedBlock: @escaping (Error) -> Void) {
        MKBXDCentralManager.shared.connectPeripheral(peripheral,
                                                     password: password,
                                                     sucBlock: { _ in
            sucBlock()
        }, failedBlock: { error in
            failedBlock(error)
        })
    }

    private func connectWithoutPassword(_ peripheral: CBPeripheral,
                                        sucBlock: @escaping () -> Void,
                                        failedBlock: @escaping (Error) -> Void) {
        MKBXDCentralManager.shared.connectPeripheral(peripheral,
                                                     sucBlock: { _ in
            sucBlock()
        }, failedBlock: { error in
            failedBlock(error)
        })
    }

    // MARK: - Private: 读设备信息流程

    /// 连接成功后读设备信息，全部成功后回调 `sucBlock`
    private func readDeviceInfoAndFinish(_ peripheral: CBPeripheral,
                                         sucBlock: (() -> Void)?,
                                         failedBlock: @escaping (Error) -> Void) {
        // 1. 读 deviceType
        readDeviceType(sucBlock: { [weak self] deviceType in
            guard let self = self else { return }
            self.deviceType = deviceType

            // 2. 只有 deviceType=2 才读 pcbType
            if deviceType == "2" {
                self.readPCBType(sucBlock: { [weak self] pcbType in
                    guard let self = self else { return }
                    self.pcbType = pcbType
                    self.readSoftwareAndFinish(sucBlock: sucBlock, failedBlock: failedBlock)
                }, failedBlock: { error in
                    self.operationFailedWithMsg("Read PCB Type Error", failedBlock: failedBlock)
                })
                return
            }

            // deviceType != 2，直接读 software
            self.readSoftwareAndFinish(sucBlock: sucBlock, failedBlock: failedBlock)
        }, failedBlock: { error in
            self.operationFailedWithMsg("Read Device Type Error", failedBlock: failedBlock)
        })
    }

    /// 读 software + 正则校验 + 读 sensorStatus
    private func readSoftwareAndFinish(sucBlock: (() -> Void)?,
                                       failedBlock: @escaping (Error) -> Void) {
        // 1. 读 software
        readSoftwareVersion(sucBlock: { [weak self] software in
            guard let self = self else { return }
            guard !software.isEmpty else {
                self.operationFailedWithMsg("Read Software Failed!", failedBlock: failedBlock)
                return
            }

            // 2. 正则校验 BXP-B.*-(D|CR)
            let pattern = "^.*BXP-B.*-(D|CR)$"
            guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
                self.operationFailedWithMsg("Opps:The current app only supports BXP-B type devices!", failedBlock: failedBlock)
                return
            }
            let range = NSRange(location: 0, length: software.utf16.count)
            let numberOfMatches = regex.numberOfMatches(in: software, options: [], range: range)
            guard numberOfMatches > 0 else {
                self.operationFailedWithMsg("Opps:The current app only supports BXP-B type devices!", failedBlock: failedBlock)
                return
            }

            // 3. isBXPB03D
            self.isBXPB03D = software.contains("BXP-B03-D")

            // 4. isCR 正则
            let crPattern = "^.*BXP-B.*-CR$"
            if let crRegex = try? NSRegularExpression(pattern: crPattern, options: []) {
                let crMatches = crRegex.numberOfMatches(in: software, options: [], range: range)
                self.isCR = (crMatches > 0)
            } else {
                self.isCR = false
            }

            // 5. doubleBtn: BXP-B-D & deviceType=02 & pcbType=3
            self.doubleBtn = (!self.isCR && self.pcbType == 3)

            // 6. 读 sensorStatus
            self.readSensorStatus(sucBlock: { [weak self] in
                guard self != nil else { return }
                DispatchQueue.main.async {
                    sucBlock?()
                }
            }, failedBlock: { error in
                self.operationFailedWithMsg("Read Sensor Error", failedBlock: failedBlock)
            })
        }, failedBlock: { error in
            self.operationFailedWithMsg("Read Software Failed!", failedBlock: failedBlock)
        })
    }

    // MARK: - Private: 接口封装

    private func readDeviceType(sucBlock: @escaping (String) -> Void,
                                failedBlock: @escaping (Error) -> Void) {
        MKBXDInterface.bxd_readDeviceType(sucBlock: { returnData in
            let result = (returnData as? [String: Any])?["result"] as? [String: Any] ?? [:]
            let deviceType = (result["deviceType"] as? String) ?? ""
            sucBlock(deviceType)
        }, failedBlock: { error in
            failedBlock(error)
        })
    }

    private func readSoftwareVersion(sucBlock: @escaping (String) -> Void,
                                     failedBlock: @escaping (Error) -> Void) {
        MKBXDInterface.bxd_readSoftware(sucBlock: { returnData in
            let result = (returnData as? [String: Any])?["result"] as? [String: Any] ?? [:]
            let software = (result["software"] as? String) ?? ""
            sucBlock(software)
        }, failedBlock: { error in
            failedBlock(error)
        })
    }

    private func readSensorStatus(sucBlock: @escaping () -> Void,
                                  failedBlock: @escaping (Error) -> Void) {
        MKBXDInterface.bxd_readSensorStatus(sucBlock: { [weak self] returnData in
            guard let self = self else { return }
            let result = (returnData as? [String: Any])?["result"] as? [String: Any] ?? [:]
            self.threeSensor = (result["threeAxis"] as? Bool) ?? false
            self.htSensor = (result["htSensor"] as? Bool) ?? false
            self.lightSensor = (result["lightSensor"] as? Bool) ?? false
            sucBlock()
        }, failedBlock: { error in
            failedBlock(error)
        })
    }

    private func readPCBType(sucBlock: @escaping (Int) -> Void,
                             failedBlock: @escaping (Error) -> Void) {
        MKBXDInterface.bxd_readDevicePCBType(sucBlock: { returnData in
            let result = (returnData as? [String: Any])?["result"] as? [String: Any] ?? [:]
            let pcbType = Int((result["type"] as? String) ?? "0") ?? 0
            sucBlock(pcbType)
        }, failedBlock: { error in
            failedBlock(error)
        })
    }

    // MARK: - Private: 错误回调

    private func operationFailed(_ error: Error, failedBlock: @escaping (Error) -> Void) {
        DispatchQueue.main.async {
            MKBXDCentralManager.shared.disconnect()
            failedBlock(error)
        }
    }

    private func operationFailedWithMsg(_ msg: String, failedBlock: @escaping (Error) -> Void) {
        DispatchQueue.main.async {
            MKBXDCentralManager.shared.disconnect()
            let error = NSError(domain: "connectDevice",
                                code: -999,
                                userInfo: ["errorInfo": msg])
            failedBlock(error)
        }
    }
}
