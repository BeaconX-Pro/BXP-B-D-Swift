//
//  MKBXDCentralManager.swift
//  MKBeaconButtonSwiftProject
//
//  Created by aa on 2025/5/18.
//

import Foundation
@preconcurrency import CoreBluetooth
import MKSwiftBleModule

// MARK: - 通知名常量
public extension Notification.Name {
    /// 设备连接状态变化
    static let mk_bxd_peripheralConnectStateChangedNotification = Notification.Name("mk_bxd_peripheralConnectStateChangedNotification")
    /// 蓝牙中心状态变化
    static let mk_bxd_centralManagerStateChangedNotification = Notification.Name("mk_bxd_centralManagerStateChangedNotification")
    /// 设备断开类型（0x01/0x02/0x03/0x04）
    static let mk_bxd_deviceDisconnectTypeNotification = Notification.Name("mk_bxd_deviceDisconnectTypeNotification")
    /// 长连接模式触发记录
    static let mk_bxd_receiveLongConnectionModeDataNotification = Notification.Name("mk_bxd_receiveLongConnectionModeDataNotification")
    /// 三轴数据
    static let mk_bxd_receiveThreeAxisDataNotification = Notification.Name("mk_bxd_receiveThreeAxisDataNotification")
    /// 副按键触发记录
    static let mk_bxd_receiveSubClickDataNotification = Notification.Name("mk_bxd_receiveSubClickDataNotification")
    /// 状态恢复完成
    static let mk_bxd_stateRestorationNotification = Notification.Name("mk_bxd_stateRestorationNotification")
}

// MARK: - 状态枚举

/// 蓝牙中心可用状态
public enum MKBXDCentralManagerStatus: Int {
    /// 不可用
    case unable = 0
    /// 可用
    case enable
}

/// 设备连接状态
public enum MKBXDCentralConnectStatus: Int {
    /// 未知
    case unknow = 0
    /// 正在连接
    case connecting
    /// 连接成功
    case connected
    /// 连接失败
    case connectedFailed
    /// 断开
    case disconnect
}

// MARK: - 协议

/// 扫描代理
public protocol MKBXDCentralManagerScanDelegate: AnyObject {
    /// 收到扫描设备列表
    func mk_bxd_receiveAdvData(_ deviceList: [MKBXDBaseAdvModel])

    /// 开始扫描（可选）
    func mk_bxd_startScan()
    /// 停止扫描（可选）
    func mk_bxd_stopScan()
}

public extension MKBXDCentralManagerScanDelegate {
    func mk_bxd_startScan() {}
    func mk_bxd_stopScan() {}
}

/// 告警事件代理
public protocol MKBXDCentralManagerAlarmEventDelegate: AnyObject {
    /// 收到告警事件数据
    func mk_bxd_receiveAlarmEventData(_ contentData: [String: Any])
}

/// 状态恢复代理
public protocol MKBXDStateRestorationDelegate: AnyObject {
    /// 状态恢复完成，系统重新连接了外设
    func mk_bxd_didRestoreStateWithPeripherals(_ peripherals: [CBPeripheral])
}

// MARK: - MKBXDCentralManager

/// BXD 中心管理器（业务层）
public final class MKBXDCentralManager: NSObject, MKSwiftBleCentralManagerProtocol, @unchecked Sendable {

    // MARK: - 单例
    private static var _shared: MKBXDCentralManager?
    private static let sharedLock = NSLock()

    public static var shared: MKBXDCentralManager {
        sharedLock.lock()
        defer { sharedLock.unlock() }
        if let s = _shared { return s }
        let s = MKBXDCentralManager()
        _shared = s
        return s
    }

    /// 销毁单例（DFU 升级后调用）
    public static func sharedDealloc() {
        sharedLock.lock()
        defer { sharedLock.unlock() }
        MKSwiftBleBaseCentralManager.singleDealloc()
        _shared = nil
    }

    /// 从中心列表移除（保留 SPM 中心实例）
    public static func removeFromCentralList() {
        sharedLock.lock()
        defer { sharedLock.unlock() }
        MKSwiftBleBaseCentralManager.shared.removeCentralManager()
        _shared = nil
    }

    // MARK: - 状态恢复全局变量
    private static var g_restoreIdentifier: String?
    private static var g_isLaunchedFromStateRestoration = false
    private static var g_restorationCompletion: (([CBPeripheral]) -> Void)?

    /// 启用状态恢复功能（建议在 didFinishLaunchingWithOptions 中调用）
    /// - Note: 当前 SPM 库暂未支持状态恢复，此接口仅保留骨架，调用后无实际效果
    public static func enableStateRestorationWithIdentifier(_ restoreIdentifier: String?) {
        g_restoreIdentifier = restoreIdentifier

        let defaults = UserDefaults.standard
        let wasTerminated = defaults.bool(forKey: "MKBXD_WAS_TERMINATED")
        if wasTerminated {
            g_isLaunchedFromStateRestoration = true
            NSLog("[MKBXD] App launched from terminated state, checking for state restoration")
        }
        defaults.set(false, forKey: "MKBXD_WAS_TERMINATED")
        defaults.synchronize()

        if let _ = restoreIdentifier {
            MKSwiftBleBaseCentralManager.shared.configCentralManager(shared)
        }
    }

    /// 检查当前是否是从状态恢复中启动的应用
    public static func isLaunchedFromStateRestoration() -> Bool {
        g_isLaunchedFromStateRestoration
    }

    /// 设置状态恢复完成回调
    public static func setStateRestorationCompletion(_ completion: (([CBPeripheral]) -> Void)?) {
        g_restorationCompletion = completion
    }

    // MARK: - 公开属性
    public weak var delegate: MKBXDCentralManagerScanDelegate?
    public weak var eventDelegate: MKBXDCentralManagerAlarmEventDelegate?
    public weak var restorationDelegate: MKBXDStateRestorationDelegate?

    /// 当前连接状态
    public private(set) var connectStatus: MKBXDCentralConnectStatus = .unknow

    // MARK: - 私有属性
    private var sucBlock: ((CBPeripheral) -> Void)?
    private var failedBlock: ((Error) -> Void)?
    private var needPasswordBlock: (([String: Any]) -> Void)?
    private var password: String = ""
    private var readingNeedPassword: Bool = false

    private let operationListLock = NSLock()
    private var _operationList: [MKBXDOperation] = []
    private var operationList: [MKBXDOperation] {
        get { operationListLock.lock(); defer { operationListLock.unlock() }; return _operationList }
        set { operationListLock.lock(); defer { operationListLock.unlock() }; _operationList = newValue }
    }
    private var _isAction: Bool = false
    private var isAction: Bool {
        get { operationListLock.lock(); defer { operationListLock.unlock() }; return _isAction }
        set { operationListLock.lock(); defer { operationListLock.unlock() }; _isAction = newValue }
    }

    private static let logFileName = "mk_bxp_button_d_log"

    // MARK: - Init
    private override init() {
        super.init()
        logToLocal("MKBXDCentralManager初始化")
        MKSwiftBleBaseCentralManager.shared.configCentralManager(self)
        setupStateRestorationObserver()
    }

    deinit {
        logToLocal("MKBXDCentralManager销毁")
        NSLog("MKBXDCentralManager销毁")
    }

    // MARK: - 状态恢复观察
    private func setupStateRestorationObserver() {
        NotificationCenter.default.addObserver(self,
                                              selector: #selector(handleStateRestoration(_:)),
                                              name: .mk_bxd_stateRestorationNotification,
                                              object: nil)
    }

    @objc private func handleStateRestoration(_ notification: Notification) {
        guard let peripherals = notification.userInfo?["peripherals"] as? [CBPeripheral],
              !peripherals.isEmpty else {
            return
        }
        NSLog("[MKBXD] Handling state restoration for %lu peripherals", peripherals.count)
    }

    // MARK: - MKSwiftBleScanProtocol

    public func centralManagerDiscoverPeripheral(_ peripheral: CBPeripheral,
                                                  advertisementData: MKBleAdvInfo) {
        var advDic: [String: Any] = [:]
        if let localName = advertisementData.localName {
            advDic[CBAdvertisementDataLocalNameKey] = localName
        }
        if let serviceData = advertisementData.serviceData {
            advDic[CBAdvertisementDataServiceDataKey] = serviceData
        }
        if let manufacturerData = advertisementData.manufacturerData {
            advDic[CBAdvertisementDataManufacturerDataKey] = manufacturerData
        }
        if let txPower = advertisementData.txPowerLevel {
            advDic[CBAdvertisementDataTxPowerLevelKey] = NSNumber(value: txPower)
        }
        if let isConnectable = advertisementData.isConnectable {
            advDic[CBAdvertisementDataIsConnectable] = isConnectable
        }
        if let serviceUUIDs = advertisementData.serviceUUIDs {
            advDic[CBAdvertisementDataServiceUUIDsKey] = serviceUUIDs
        }

        let rssi = advertisementData.rssi
        let deviceList = MKBXDBaseAdvModel.parseAdvData(advDic,
                                                        peripheral: peripheral,
                                                        RSSI: rssi)

        for beaconModel in deviceList {
            beaconModel.identifier = peripheral.identifier.uuidString
            beaconModel.rssi = rssi
            beaconModel.peripheral = peripheral
            if let localName = advertisementData.localName {
                beaconModel.deviceName = localName
            }
            beaconModel.connectEnable = advertisementData.isConnectable ?? false
        }

        if deviceList.isEmpty {
            return
        }

        DispatchQueue.main.async { [weak self] in
            self?.delegate?.mk_bxd_receiveAdvData(deviceList)
        }
    }

    public func centralManagerStartScan() {
        logToLocal("开始扫描")
        DispatchQueue.main.async { [weak self] in
            self?.delegate?.mk_bxd_startScan()
        }
    }

    public func centralManagerStopScan() {
        logToLocal("停止扫描")
        DispatchQueue.main.async { [weak self] in
            self?.delegate?.mk_bxd_stopScan()
        }
    }

    // MARK: - MKSwiftBleCentralManagerStateProtocol

    public func centralManagerStateChanged(_ centralManagerState: MKSwiftCentralManagerState) {
        let string = "蓝牙中心改变:\(centralManagerState)"
        operationList = []
        isAction = false
        logToLocal(string)
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .mk_bxd_centralManagerStateChangedNotification, object: nil)
        }
    }

    public func peripheralConnectStateChanged(_ connectState: MKSwiftPeripheralConnectState) {
        if readingNeedPassword {
            return
        }
        operationList = []
        isAction = false
        switch connectState {
        case .unknown:
            connectStatus = .unknow
        case .connecting:
            connectStatus = .connecting
        case .disconnect:
            connectStatus = .disconnect
        case .connectedFailed:
            connectStatus = .connectedFailed
        case .connected:
            break
        @unknown default:
            break
        }
        let string = "连接状态发生改变:\(connectState)"
        logToLocal(string)
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .mk_bxd_peripheralConnectStateChangedNotification, object: nil)
        }
    }

    // MARK: - MKSwiftBleCentralManagerProtocol

    public func peripheral(_ peripheral: CBPeripheral,
                           didUpdateValueFor characteristic: CBCharacteristic,
                           error: Error?) {
        if error != nil {
            NSLog("+++++++++++++++++接收数据出错")
            return
        }
        let content = MKSwiftBleSDKAdopter.hexStringFromData(characteristic.value ?? Data())
        NSLog("%@-%@", characteristic.uuid.uuidString, content)

        let uuidString = characteristic.uuid.uuidString

        if uuidString == "AA03" || uuidString == "AA04" || uuidString == "AA05" || uuidString == "AA09" {
            let alarmType: String
            switch uuidString {
            case "AA03": alarmType = "0"
            case "AA04": alarmType = "1"
            case "AA05": alarmType = "2"
            case "AA09": alarmType = "3"
            default:  alarmType = "4"
            }
            let triggerContent = content.bleSubstring(from: 8, length: content.count - 8)
            let dic: [String: Any] = [
                "alarmType": alarmType,
                "content": triggerContent
            ]
            if let eventDelegate = eventDelegate {
                DispatchQueue.main.async {
                    eventDelegate.mk_bxd_receiveAlarmEventData(dic)
                }
            }
            return
        }

        if uuidString == "AA02" {
            saveToLogData(content, appToDevice: false)
            let type = content.bleSubstring(from: 8, length: 2)
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .mk_bxd_deviceDisconnectTypeNotification,
                                              object: nil,
                                              userInfo: ["type": type])
            }
            return
        }

        if uuidString == "AA06" {
            saveToLogData(content, appToDevice: false)
            let xHex = content.bleSubstring(from: 8, length: 4)
            let yHex = content.bleSubstring(from: 12, length: 4)
            let zHex = content.bleSubstring(from: 16, length: 4)
            let xData = MKSwiftBleSDKAdopter.signedHexTurnToInt(xHex)
            let yData = MKSwiftBleSDKAdopter.signedHexTurnToInt(yHex)
            let zData = MKSwiftBleSDKAdopter.signedHexTurnToInt(zHex)
            let xDataString = String(format: "%ld", xData)
            let yDataString = String(format: "%ld", yData)
            let zDataString = String(format: "%ld", zData)
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .mk_bxd_receiveThreeAxisDataNotification,
                                              object: nil,
                                              userInfo: [
                                                "x-Data": xDataString,
                                                "y-Data": yDataString,
                                                "z-Data": zDataString
                                              ])
            }
            return
        }

        if uuidString == "AA08" {
            saveToLogData(content, appToDevice: false)
            let count = MKSwiftBleSDKAdopter.getDecimalStringWithHex(content, range: NSRange(location: 8, length: 2))
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .mk_bxd_receiveLongConnectionModeDataNotification,
                                              object: nil,
                                              userInfo: ["count": count])
            }
            return
        }

        if uuidString == "AA0A" {
            saveToLogData(content, appToDevice: false)
            let count = MKSwiftBleSDKAdopter.getDecimalStringWithHex(content, range: NSRange(location: 8, length: 2))
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .mk_bxd_receiveSubClickDataNotification,
                                              object: nil,
                                              userInfo: ["count": count])
            }
            return
        }

        if operationList.isEmpty || !isAction {
            return
        }
        let currentOperation = operationList[0]
        currentOperation.didUpdateValueForCharacteristic(characteristic)
    }

    public func peripheral(_ peripheral: CBPeripheral,
                           didWriteValueFor characteristic: CBCharacteristic,
                           error: Error?) {
        if error != nil {
            NSLog("+++++++++++++++++发送数据出错")
            logToLocal("发送数据出错")
            return
        }
    }

    // MARK: - 公开方法

    public var centralManager: CBCentralManager {
        MKSwiftBleBaseCentralManager.shared.centralManager
    }

    public func peripheral() -> CBPeripheral? {
        MKSwiftBleBaseCentralManager.shared.peripheral()
    }

    public var centralStatus: MKBXDCentralManagerStatus {
        MKSwiftBleBaseCentralManager.shared.centralStatus == .enable ? .enable : .unable
    }

    public func startScan() {
        _ = MKSwiftBleBaseCentralManager.shared.scanForPeripherals(
            withServices: [
                CBUUID(string: "FEAA"),
                CBUUID(string: "FEAB"),
                CBUUID(string: "FEE0"),
                CBUUID(string: "EA00")
            ],
            options: nil
        )
    }

    public func stopScan() {
        _ = MKSwiftBleBaseCentralManager.shared.stopScan()
    }

    /// 读取设备是否需要连接密码
    public func readNeedPassword(with peripheral: CBPeripheral,
                                 sucBlock: @escaping ([String: Any]) -> Void,
                                 failedBlock: @escaping (Error) -> Void) {
        if readingNeedPassword {
            operationFailedBlock(withMsg: "Device is busy now", failedBlock: failedBlock)
            return
        }
        readingNeedPassword = true
        needPasswordBlock = nil
        self.failedBlock = failedBlock

        // ✅ 修复：result 已经是 [String: Any]，不需要 as?
        needPasswordBlock = { [weak self] result in
            guard let self = self else { return }
            // result 类型已经是 [String: Any]，直接判空
            guard !result.isEmpty else {
                self.clearAllParams()
                self.operationFailedBlock(withMsg: "Read Error", failedBlock: failedBlock)
                return
            }
            self.clearAllParams()
            sucBlock(result)
        }

        let bxdPeripheral = MKBXDPeripheral(peripheral: peripheral, dfuMode: false)
        Task { [weak self] in
            guard let self = self else { return }
            do {
                _ = try await MKSwiftBleBaseCentralManager.shared.connectDevice(bxdPeripheral)
                self.confirmNeedPassword()
            } catch {
                self.clearAllParams()
                failedBlock(error)
            }
        }
    }

    /// 连接设备（带密码）
    public func connectPeripheral(_ peripheral: CBPeripheral,
                                  password: String,
                                  sucBlock: @escaping (CBPeripheral) -> Void,
                                  failedBlock: @escaping (Error) -> Void) {
        if peripheral.identifier.uuidString.isEmpty {
            operationConnectFailedBlock(failedBlock)
            return
        }
        guard !password.isEmpty,
              password.count <= 16,
              MKSwiftBleSDKAdopter.asciiString(password) else {
            operationFailedBlock(withMsg: "The password should be no more than 16 characters.",
                                 failedBlock: failedBlock)
            return
        }
        self.password = ""
        self.password = password
        connectPeripheral(peripheral, dfu: false, successBlock: { peripheral in
            sucBlock(peripheral)
        }, failedBlock: { error in
            failedBlock(error)
        })
    }

    /// 连接设备（免密）
    public func connectPeripheral(_ peripheral: CBPeripheral,
                                  sucBlock: @escaping (CBPeripheral) -> Void,
                                  failedBlock: @escaping (Error) -> Void) {
        if peripheral.identifier.uuidString.isEmpty {
            operationConnectFailedBlock(failedBlock)
            return
        }
        self.password = ""
        connectPeripheral(peripheral, dfu: false, successBlock: { peripheral in
            sucBlock(peripheral)
        }, failedBlock: { error in
            failedBlock(error)
        })
    }

    /// DFU 连接设备
    public func dfuconnectPeripheral(_ peripheral: CBPeripheral,
                                     sucBlock: @escaping (CBPeripheral) -> Void,
                                     failedBlock: @escaping (Error) -> Void) {
        if peripheral.identifier.uuidString.isEmpty {
            operationConnectFailedBlock(failedBlock)
            return
        }
        self.password = ""
        connectPeripheral(peripheral, dfu: true, successBlock: { peripheral in
            sucBlock(peripheral)
        }, failedBlock: { error in
            failedBlock(error)
        })
    }

    public func disconnect() {
        MKSwiftBleBaseCentralManager.shared.disconnect()
    }

    // MARK: - 任务通信

    public func addTaskWithTaskID(_ operationID: MKBXDTaskOperationID,
                                  characteristic: CBCharacteristic,
                                  commandData: String,
                                  successBlock: @escaping (Any) -> Void,
                                  failureBlock: @escaping (Error) -> Void) {
        guard let operation = generateOperationWithOperationID(operationID,
                                                               characteristic: characteristic,
                                                               commandData: commandData,
                                                               successBlock: successBlock,
                                                               failureBlock: failureBlock) else {
            return
        }
        operationList.append(operation)
        operationAction()
    }

    public func addReadTaskWithTaskID(_ operationID: MKBXDTaskOperationID,
                                      characteristic: CBCharacteristic,
                                      successBlock: @escaping (Any) -> Void,
                                      failureBlock: @escaping (Error) -> Void) {
        guard let operation = generateReadOperationWithOperationID(operationID,
                                                                    characteristic: characteristic,
                                                                    successBlock: successBlock,
                                                                    failureBlock: failureBlock) else {
            return
        }
        operationList.append(operation)
        operationAction()
    }

    // MARK: - Notify 开关

    public func notifySingleClickData(_ notify: Bool) -> Bool {
        guard connectStatus == .connected,
              let peripheral = MKSwiftBleBaseCentralManager.shared.peripheral(),
              let characteristic = peripheral.bxd_singleRecord else {
            return false
        }
        peripheral.setNotifyValue(notify, for: characteristic)
        return true
    }

    public func notifyDoubleClickData(_ notify: Bool) -> Bool {
        guard connectStatus == .connected,
              let peripheral = MKSwiftBleBaseCentralManager.shared.peripheral(),
              let characteristic = peripheral.bxd_doubleRecord else {
            return false
        }
        peripheral.setNotifyValue(notify, for: characteristic)
        return true
    }

    public func notifyLongClickData(_ notify: Bool) -> Bool {
        guard connectStatus == .connected,
              let peripheral = MKSwiftBleBaseCentralManager.shared.peripheral(),
              let characteristic = peripheral.bxd_longRecord else {
            return false
        }
        peripheral.setNotifyValue(notify, for: characteristic)
        return true
    }

    public func notifyLongConnectClickData(_ notify: Bool) -> Bool {
        guard connectStatus == .connected,
              let peripheral = MKSwiftBleBaseCentralManager.shared.peripheral(),
              let characteristic = peripheral.bxd_longConnectRecord else {
            return false
        }
        peripheral.setNotifyValue(notify, for: characteristic)
        return true
    }

    public func notifySubClickData(_ notify: Bool) -> Bool {
        guard connectStatus == .connected,
              let peripheral = MKSwiftBleBaseCentralManager.shared.peripheral(),
              let characteristic = peripheral.bxd_subBtnData else {
            return false
        }
        peripheral.setNotifyValue(notify, for: characteristic)
        return true
    }

    public func notifyThreeAxisData(_ notify: Bool) -> Bool {
        guard connectStatus == .connected,
              let peripheral = MKSwiftBleBaseCentralManager.shared.peripheral(),
              let characteristic = peripheral.bxd_threeAxisData else {
            return false
        }
        peripheral.setNotifyValue(notify, for: characteristic)
        return true
    }

    public func notifyLongConModeData(_ notify: Bool) -> Bool {
        guard connectStatus == .connected,
              let peripheral = MKSwiftBleBaseCentralManager.shared.peripheral(),
              let characteristic = peripheral.bxd_longConModeData else {
            return false
        }
        peripheral.setNotifyValue(notify, for: characteristic)
        return true
    }

    // MARK: - 私有：连接

    private func connectPeripheral(_ peripheral: CBPeripheral,
                                   dfu: Bool,
                                   successBlock: @escaping (CBPeripheral) -> Void,
                                   failedBlock: @escaping (Error) -> Void) {
        self.sucBlock = successBlock
        self.failedBlock = failedBlock
        let bxdPeripheral = MKBXDPeripheral(peripheral: peripheral, dfuMode: dfu)
        Task { [weak self] in
            guard let self = self else { return }
            do {
                let connectedPeripheral = try await MKSwiftBleBaseCentralManager.shared.connectDevice(bxdPeripheral)
                if !self.password.isEmpty {
                    self.logToLocal("密码登录")
                    self.sendPasswordToDevice()
                    return
                }
                if dfu {
                    self.logToLocal("DFU升级")
                } else {
                    self.logToLocal("免密登录")
                }
                DispatchQueue.main.async {
                    self.connectStatus = .connected
                    NotificationCenter.default.post(name: .mk_bxd_peripheralConnectStateChangedNotification, object: nil)
                    if let sucBlock = self.sucBlock {
                        self.sucBlock = nil
                        self.failedBlock = nil
                        sucBlock(connectedPeripheral)
                    }
                }
            } catch {
                if let failedBlock = self.failedBlock {
                    self.sucBlock = nil
                    self.failedBlock = nil
                    failedBlock(error)
                }
            }
        }
    }

    private func sendPasswordToDevice() {
        var lenString = String(format: "%1lx", password.count)
        if lenString.count == 1 {
            lenString = "0" + lenString
        }
        var commandData = "ea0155" + lenString
        for scalar in password.unicodeScalars {
            let asciiCode = Int(scalar.value)
            commandData += String(format: "%02lx", asciiCode)
        }

        let operation = MKBXDOperation(operationID: .connectPassword,
                                      commandBlock: {
                                        guard let peripheral = MKSwiftBleBaseCentralManager.shared.peripheral(),
                                              let characteristic = peripheral.bxd_password else {
                                            return
                                        }
                                        _ = MKSwiftBleBaseCentralManager.shared.sendDataToPeripheral(
                                            commandData,
                                            characteristic: characteristic,
                                            type: .withResponse
                                        )
                                      },
                                      completeBlock: { [weak self] error, returnData in
                                        guard let self = self else { return }
                                        self.isAction = false
                                        if !self.operationList.isEmpty {
                                            self.operationList.removeFirst()
                                            self.operationAction()
                                        }
                                        guard error == nil,
                                              let returnData = returnData,
                                              let success = returnData["success"] as? Bool,
                                              success else {
                                            self.operationFailedBlock(withMsg: "Password Error",
                                                                       failedBlock: self.failedBlock)
                                            return
                                        }
                                        DispatchQueue.main.async {
                                            self.connectStatus = .connected
                                            NotificationCenter.default.post(name: .mk_bxd_peripheralConnectStateChangedNotification, object: nil)
                                            if let sucBlock = self.sucBlock,
                                               let peripheral = MKSwiftBleBaseCentralManager.shared.peripheral() {
                                                sucBlock(peripheral)
                                            }
                                        }
                                      })
        operationList.append(operation)
        operationAction()
    }

    private func confirmNeedPassword() {
        let commandData = "ea002300"
        let operation = MKBXDOperation(operationID: .readNeedPassword,
                                       commandBlock: {
                                        guard let peripheral = MKSwiftBleBaseCentralManager.shared.peripheral(),
                                              let characteristic = peripheral.bxd_password else {
                                            return
                                        }
                                        _ = MKSwiftBleBaseCentralManager.shared.sendDataToPeripheral(
                                            commandData,
                                            characteristic: characteristic,
                                            type: .withResponse
                                        )
                                       },
                                       completeBlock: { [weak self] error, returnData in
                                        guard let self = self else { return }
                                        self.isAction = false
                                        if !self.operationList.isEmpty {
                                            self.operationList.removeFirst()
                                            self.operationAction()
                                        }
                                        DispatchQueue.main.async {
                                            if let needPasswordBlock = self.needPasswordBlock {
                                                if let returnData = returnData {
                                                    needPasswordBlock(returnData)
                                                } else {
                                                    self.operationFailedBlock(withMsg: "Read Error",
                                                                               failedBlock: self.failedBlock ?? { _ in })
                                                    self.clearAllParams()
                                                }
                                            } else {
                                                self.operationFailedBlock(withMsg: "Read Error",
                                                                           failedBlock: self.failedBlock ?? { _ in })
                                                self.clearAllParams()
                                            }
                                        }
                                       })
        operationList.append(operation)
        operationAction()
    }

    // MARK: - 私有：任务生成

    private func generateOperationWithOperationID(_ operationID: MKBXDTaskOperationID,
                                                  characteristic: CBCharacteristic,
                                                  commandData: String,
                                                  successBlock: @escaping (Any) -> Void,
                                                  failureBlock: @escaping (Error) -> Void) -> MKBXDOperation? {
        if !MKSwiftBleBaseCentralManager.shared.readyToCommunication {
            operationFailedBlock(withMsg: "The current connection device is in disconnect", failedBlock: failureBlock)
            return nil
        }
        if commandData.isEmpty {
            operationFailedBlock(withMsg: "The data sent to the device cannot be empty", failedBlock: failureBlock)
            return nil
        }
        let operation = MKBXDOperation(operationID: operationID,
                                       commandBlock: {
                                        _ = MKSwiftBleBaseCentralManager.shared.sendDataToPeripheral(
                                            commandData,
                                            characteristic: characteristic,
                                            type: .withResponse
                                        )
                                       },
                                       completeBlock: { [weak self] error, returnData in
                                        guard let self = self else { return }
                                        self.isAction = false
                                        if !self.operationList.isEmpty {
                                            self.operationList.removeFirst()
                                            self.operationAction()
                                        }
                                        if let error = error {
                                            DispatchQueue.main.async {
                                                failureBlock(error)
                                            }
                                            return
                                        }
                                        guard let returnData = returnData else {
                                            self.operationFailedBlock(withMsg: "Request data error", failedBlock: failureBlock)
                                            return
                                        }
                                        let resultDic: [String: Any] = [
                                            "msg": "success",
                                            "code": "1",
                                            "result": returnData
                                        ]
                                        DispatchQueue.main.async {
                                            successBlock(resultDic)
                                        }
                                       })
        return operation
    }

    private func generateReadOperationWithOperationID(_ operationID: MKBXDTaskOperationID,
                                                      characteristic: CBCharacteristic,
                                                      successBlock: @escaping (Any) -> Void,
                                                      failureBlock: @escaping (Error) -> Void) -> MKBXDOperation? {
        if !MKSwiftBleBaseCentralManager.shared.readyToCommunication {
            operationFailedBlock(withMsg: "The current connection device is in disconnect", failedBlock: failureBlock)
            return nil
        }
        let operation = MKBXDOperation(operationID: operationID,
                                       commandBlock: {
                                        if let peripheral = MKSwiftBleBaseCentralManager.shared.peripheral() {
                                            peripheral.readValue(for: characteristic)
                                        }
                                       },
                                       completeBlock: { [weak self] error, returnData in
                                        guard let self = self else { return }
                                        self.isAction = false
                                        if !self.operationList.isEmpty {
                                            self.operationList.removeFirst()
                                            self.operationAction()
                                        }
                                        if let error = error {
                                            DispatchQueue.main.async {
                                                failureBlock(error)
                                            }
                                            return
                                        }
                                        guard let returnData = returnData else {
                                            self.operationFailedBlock(withMsg: "Request data error", failedBlock: failureBlock)
                                            return
                                        }
                                        let resultDic: [String: Any] = [
                                            "msg": "success",
                                            "code": "1",
                                            "result": returnData
                                        ]
                                        DispatchQueue.main.async {
                                            successBlock(resultDic)
                                        }
                                       })
        return operation
    }

    // MARK: - 私有：清理与错误回调

    private func clearAllParams() {
        sucBlock = nil
        failedBlock = nil
        guard needPasswordBlock != nil else {
            return
        }
        disconnect()
        needPasswordBlock = nil
        readingNeedPassword = false
        operationList = []
        isAction = false
    }

    private func operationAction() {
        if operationList.isEmpty || isAction {
            return
        }
        isAction = true
        let currentOperation = operationList[0]
        currentOperation.startCommunication()
    }

    private func operationFailedBlock(withMsg message: String,
                                      failedBlock: ((Error) -> Void)?) {
        let error = NSError(domain: "com.moko.BXDCentralManager",
                             code: -999,
                             userInfo: ["errorInfo": message])
        DispatchQueue.main.async {
            failedBlock?(error)
        }
    }

    private func operationConnectFailedBlock(_ failedBlock: @escaping (Error) -> Void) {
        let error = NSError(domain: "com.moko.BXDCentralManager",
                             code: -999,
                             userInfo: ["errorInfo": "Device is not exist"])
        DispatchQueue.main.async {
            failedBlock(error)
        }
    }

    // MARK: - 私有：日志

    private func saveToLogData(_ string: String, appToDevice app: Bool) {
        let function = app ? "App To Device" : "Device To App"
        let recordString = "\(function)---->\(string)"
        logToLocal(recordString)
    }

    private func logToLocal(_ string: String) {
        _ = MKSwiftBleLogManager.saveData(fileName: MKBXDCentralManager.logFileName, dataList: [string])
    }
}
