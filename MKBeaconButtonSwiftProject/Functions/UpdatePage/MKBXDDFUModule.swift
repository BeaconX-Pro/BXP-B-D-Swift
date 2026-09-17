//
//  MKBXDDFUModule.swift
//  MKBeaconButtonSwiftProject
//
//  Created by aa on 2026/9/17.
//  Copyright © 2026 aadyx2007@163.com. All rights reserved.
//

import Foundation
import CoreBluetooth

import NordicDFU

import MKBaseSwiftModule
import MKSwiftBleModule

private let dfuUpdateDomain = "com.moko.dfuUpdateDomain"

// MARK: - MKBXDDFUModule

public final class MKBXDDFUModule: NSObject {

    // MARK: - Properties

    private var progressBlock: ((CGFloat) -> Void)?
    private var updateSucBlock: (() -> Void)?
    private var updateFailedBlock: ((Error) -> Void)?

    private var dfuController: DFUServiceController?

    // MARK: - Lifecycle

    deinit {
        // 无特殊清理
    }

    // MARK: - Public

    /// 开始 DFU 升级
    public func updateWithFileUrl(_ url: String,
                                  progressBlock: @escaping (CGFloat) -> Void,
                                  sucBlock: @escaping () -> Void,
                                  failedBlock: @escaping (Error) -> Void) {
        guard !url.isEmpty else {
            operationFailed(failedBlock, msg: "The url is invalid!")
            return
        }

        // 读取 zip 数据
        guard let zipData = NSData(contentsOfFile: url) as Data?, !zipData.isEmpty else {
            operationFailed(failedBlock, msg: "Dfu upgrade failure!")
            return
        }

        // 创建固件
        let selectedFirmware: DFUFirmware
        do {
            selectedFirmware = try DFUFirmware(zipFile: zipData)
        } catch {
            operationFailed(failedBlock, msg: "Dfu upgrade failure!")
            return
        }

        // 创建 initiator
        let queue = DispatchQueue.global(qos: .default)
        let initiator = DFUServiceInitiator(queue: queue,
                                            delegateQueue: queue,
                                            progressQueue: queue,
                                            loggerQueue: queue,
                                            centralManagerOptions: [:])
        _ = initiator.with(firmware: selectedFirmware)
        initiator.logger = self
        initiator.delegate = self
        initiator.progressDelegate = self

        // 保存回调
        self.progressBlock = progressBlock
        self.updateSucBlock = sucBlock
        self.updateFailedBlock = failedBlock

        // 开始升级
        guard let peripheral = MKBXDCentralManager.shared.peripheral() else {
            operationFailed(failedBlock, msg: "The peripheral is not connected!")
            return
        }
        dfuController = initiator.start(target: peripheral)
    }

    // MARK: - Private

    private func operationFailed(_ failedBlock: ((Error) -> Void)?, msg: String) {
        DispatchQueue.main.async {
            guard let failedBlock = failedBlock else { return }
            let error = NSError(domain: dfuUpdateDomain,
                                code: -999,
                                userInfo: ["errorInfo": msg])
            failedBlock(error)
        }
    }
}

// MARK: - DFUServiceDelegate

extension MKBXDDFUModule: DFUServiceDelegate {

    public func dfuStateDidChange(to state: DFUState) {
        // 升级完成
        if state == .completed {
            DispatchQueue.main.async { [weak self] in
                self?.updateSucBlock?()
            }
        }
        if state == .uploading {
            MKBXDCentralManager.sharedDealloc()
        }
    }

    public func dfuError(_ error: DFUError,
                         didOccurWithMessage message: String) {
        operationFailed(updateFailedBlock, msg: message)
    }
}

// MARK: - DFUProgressDelegate

extension MKBXDDFUModule: DFUProgressDelegate {

    public func dfuProgressDidChange(for part: Int,
                                     outOf totalParts: Int,
                                     to progress: Int,
                                     currentSpeedBytesPerSecond: Double,
                                     avgSpeedBytesPerSecond: Double) {
        let currentProgress = CGFloat(progress) / CGFloat(totalParts)
        DispatchQueue.main.async { [weak self] in
            self?.progressBlock?(currentProgress)
        }
    }
}

// MARK: - LoggerDelegate

extension MKBXDDFUModule: LoggerDelegate {

    public func logWith(_ level: LogLevel, message: String) {
        print("NordicDFU [\(level.rawValue)]: \(message)")
    }
}
