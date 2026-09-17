//
//  MKBXDOperation.swift
//  MKBeaconButtonSwiftProject
//
//  Created by aa on 2025/5/18.
//

import Foundation
@preconcurrency import CoreBluetooth
import MKSwiftBleModule

/// BXD 通信任务（普通 NSObject 子类，由 MKBXDCentralManager 自维护队列串行执行）
public final class MKBXDOperation: NSObject, @unchecked Sendable {

    /// 超过 2s 没有接收到新的数据，则超时
    private var receiveTimer: DispatchSourceTimer?
    private var receiveTimerCount: Int = 0
    private var timeout: Bool = false

    /// 线程 ID
    public let operationID: MKBXDTaskOperationID

    /// 任务结束时回调
    public typealias CompleteBlock = (Error?, [String: Any]?) -> Void
    private let completeBlock: CompleteBlock?

    /// 发送命令回调
    public typealias CommandBlock = () -> Void
    private let commandBlock: CommandBlock?

    /// 锁
    private let lock = NSLock()

    deinit {
        #if DEBUG
        print("BXD任务销毁")
        #endif
        if let timer = receiveTimer {
            timer.cancel()
            self.receiveTimer = nil
        }
    }

    /// 初始化通信线程
    /// - Parameters:
    ///   - operationID: 当前线程的任务 ID
    ///   - commandBlock: 发送命令回调
    ///   - completeBlock: 数据通信完成回调
    public init(operationID: MKBXDTaskOperationID,
                commandBlock: @escaping CommandBlock,
                completeBlock: @escaping CompleteBlock) {
        self.operationID = operationID
        self.commandBlock = commandBlock
        self.completeBlock = completeBlock
        super.init()
    }

    // MARK: - Public

    /// 蓝牙中心接收到特征发过来的数据
    public func didUpdateValueForCharacteristic(_ characteristic: CBCharacteristic) {
        let dataDic = MKBXDTaskAdopter.parseReadData(with: characteristic)
        dataParserReceivedData(dataDic)
    }

    /// 中心蓝牙使用某个特征发送数据结果
    public func didWriteValueForCharacteristic(_ characteristic: CBCharacteristic) {
        let dataDic = MKBXDTaskAdopter.parseWriteData(with: characteristic)
        dataParserReceivedData(dataDic)
    }

    /// 开始通信
    public func startCommunication() {
        if let command = commandBlock {
            command()
        }
        startReceiveTimer()
    }

    // MARK: - Private

    /// 启动接收超时定时器
    /// 每 100ms 触发一次，达到 15 次计数（约 1.5s）或显式超时则视为超时
    private func startReceiveTimer() {
        let queue = DispatchQueue.global(qos: .default)
        let timer = DispatchSource.makeTimerSource(queue: queue)
        timer.schedule(deadline: .now(), repeating: .milliseconds(100))
        timer.setEventHandler { [weak self] in
            guard let self = self else { return }
            self.lock.lock()
            let isTimeout = self.timeout
            let count = self.receiveTimerCount
            if isTimeout || count >= 15 {
                // 接受数据超时
                self.receiveTimerCount = 0
                self.lock.unlock()
                self.communicationTimeout()
                return
            }
            self.receiveTimerCount += 1
            self.lock.unlock()
        }
        timer.resume()
        self.receiveTimer = timer
    }

    private func communicationTimeout() {
        lock.lock()
        self.timeout = true
        if let timer = receiveTimer {
            timer.cancel()
            self.receiveTimer = nil
        }
        lock.unlock()

        let error = NSError(domain: "com.moko.operationError",
                            code: -999,
                            userInfo: ["errorInfo": "Communication timeout"])
        completeBlock?(error, nil)
    }

    private func dataParserReceivedData(_ dataDic: [String: Any]) {
        if dataDic.isEmpty {
            return
        }
        lock.lock()
        if timeout {
            lock.unlock()
            return
        }
        lock.unlock()

        guard let operationIDValue = dataDic["operationID"] as? Int else {
            return
        }
        let currentID = MKBXDTaskOperationID(rawValue: operationIDValue) ?? .default
        if currentID == .default || currentID != self.operationID {
            return
        }
        guard let returnData = dataDic["returnData"] as? [String: Any] else {
            return
        }

        lock.lock()
        if let timer = receiveTimer {
            timer.cancel()
            self.receiveTimer = nil
        }
        lock.unlock()

        // 接受数据成功
        completeBlock?(nil, returnData)
    }
}


