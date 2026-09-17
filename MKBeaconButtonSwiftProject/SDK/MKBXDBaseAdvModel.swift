//
//  MKBXDBaseAdvModel.swift
//  MKBeaconButtonSwiftProject
//
//  Created by aa on 2025/5/18.
//

import Foundation
@preconcurrency import CoreBluetooth
import MKSwiftBleModule

// MARK: - 帧类型枚举
public enum MKBXDDataFrameType: Int {
    /// 未知
    case unknown = 0
    /// 设备广播包
    case advFrame
    /// 设备广播响应包
    case respondFrame
    /// UID
    case uidFrame
    /// iBeacon
    case beaconFrame
}

// MARK: - 触发广播告警类型
public enum MKBXDAdvAlarmType: Int {
    /// 单击触发
    case single = 0
    /// 双击触发
    case double
    /// 长按触发
    case long
    /// 异常静止触发
    case abnormalInactivity
}

// MARK: - 基础广播模型
public class MKBXDBaseAdvModel: NSObject {
    /// 帧类型
    public var frameType: MKBXDDataFrameType = .unknown
    /// rssi
    public var rssi: NSNumber = 0
    /// 是否可连接
    public var connectEnable: Bool = false
    /// 扫描到的设备标识
    public var identifier: String = ""
    /// 扫描到的设备
    public var peripheral: CBPeripheral?
    /// 设备广播数据
    public var advertiseData: Data = Data()
    /// 设备名称
    public var deviceName: String = ""

    /// 解析广播数据
    /// - Parameters:
    ///   - advData: 系统返回的 advertisementData 字典
    ///   - peripheral: 扫描到的外设
    ///   - RSSI: 信号强度
    /// - Returns: 解析出的所有广播模型
    public static func parseAdvData(_ advData: [String: Any],
                                     peripheral: CBPeripheral,
                                     RSSI: NSNumber) -> [MKBXDBaseAdvModel] {
        guard let advDic = advData[CBAdvertisementDataServiceDataKey] as? [CBUUID: Data],
              !advDic.isEmpty else {
            return []
        }

        var beaconList: [MKBXDBaseAdvModel] = []

        for key in advDic.keys {
            if key == CBUUID(string: "FEAA") {
                if let feaaData = advDic[CBUUID(string: "FEAA")], !feaaData.isEmpty {
                    let frameType = fetchFEAAFrameType(feaaData)
                    if frameType == .uidFrame {
                        if let beacon = MKBXDUIDBeacon(advertiseData: feaaData) {
                            beacon.frameType = .uidFrame
                            beaconList.append(beacon)
                        }
                    }
                }
            } else if key == CBUUID(string: "FEAB") {
                if let feabData = advDic[CBUUID(string: "FEAB")], !feabData.isEmpty {
                    let frameType = fetchFEABFrameType(feabData)
                    if frameType == .beaconFrame {
                        if let beacon = MKBXDBeacon(advertiseData: feabData) {
                            beacon.frameType = .beaconFrame
                            if let txPower = advData[CBAdvertisementDataTxPowerLevelKey] as? NSNumber {
                                beacon.txPower = txPower
                            }
                            beaconList.append(beacon)
                        }
                    }
                }
            } else if key == CBUUID(string: "FEE0") {
                let tempList = parseAdvDataList(advData, peripheral: peripheral, RSSI: RSSI)
                if !tempList.isEmpty {
                    beaconList.append(contentsOf: tempList)
                }
            }
        }

        return beaconList
    }

    /// 解析 FEE0 服务下的扫描包和回应包
    private static func parseAdvDataList(_ advData: [String: Any],
                                          peripheral: CBPeripheral,
                                          RSSI: NSNumber) -> [MKBXDBaseAdvModel] {
        guard let advDic = advData[CBAdvertisementDataServiceDataKey] as? [CBUUID: Data] else {
            return []
        }
        var beaconList: [MKBXDBaseAdvModel] = []
        guard let scanData = advDic[CBUUID(string: "FEE0")], !scanData.isEmpty else {
            return beaconList
        }
        let respondData = advDic[CBUUID(string: "EA00")] ?? Data()

        // 保存到日志
        _ = MKSwiftBleLogManager.saveData(fileName: "BXP-B-D",
                                           dataList: [MKSwiftBleSDKAdopter.hexStringFromData(scanData),
                                                      MKSwiftBleSDKAdopter.hexStringFromData(respondData)])

        let scanModel = parseAdvMode(with: scanData)
        let respondModel = parseAdvMode(with: respondData)

        if let tempModel = respondModel as? MKBXDAdvRespondDataModel {
            // 回应包内容
            if let txPower = advData[CBAdvertisementDataTxPowerLevelKey] as? NSNumber {
                tempModel.txPower = txPower
            }
            beaconList.append(tempModel)
        }
        if let tempModel = scanModel as? MKBXDAdvDataModel {
            // 触发广播包
            beaconList.append(tempModel)
        }

        return beaconList
    }

    /// 根据 Data 头字节判断是回应包还是触发广播包
    private static func parseAdvMode(with advData: Data) -> MKBXDBaseAdvModel? {
        guard advData.count >= 6 else { return nil }
        let content = MKSwiftBleSDKAdopter.hexStringFromData(advData)
        guard !content.isEmpty else { return nil }

        let typeString = content.bleSubstring(from: 0, length: 2)
        if typeString == "00" {
            // 回应包
            let tempModel = MKBXDAdvRespondDataModel(advertiseData: advData)
            tempModel.frameType = .respondFrame
            return tempModel
        }
        if typeString == "20" || typeString == "21" || typeString == "22" || typeString == "23" {
            // 触发广播包
            let tempModel = MKBXDAdvDataModel(advertiseData: advData)
            tempModel.frameType = .advFrame
            return tempModel
        }
        return nil
    }

    /// 解析 FEAA 帧类型
    private static func fetchFEAAFrameType(_ stoneData: Data) -> MKBXDDataFrameType {
        guard !stoneData.isEmpty else { return .unknown }
        let firstByte = stoneData[stoneData.startIndex]
        switch firstByte {
        case 0x00:
            return .uidFrame
        default:
            return .unknown
        }
    }

    /// 解析 FEAB 帧类型
    private static func fetchFEABFrameType(_ customData: Data) -> MKBXDDataFrameType {
        guard !customData.isEmpty else { return .unknown }
        let firstByte = customData[customData.startIndex]
        switch firstByte {
        case 0x50:
            return .beaconFrame
        default:
            return .unknown
        }
    }
}

// MARK: - 触发广播包
public class MKBXDAdvDataModel: MKBXDBaseAdvModel {
    /// 告警类型
    public var alarmType: MKBXDAdvAlarmType = .single

    /*
     version = 0/1 0: Standby 1:Trigger
     version = 2 0: Standby 1:Main-Triggered 2:Sub-Triggered
     */
    public var triggerStatus: Int = 0

    /// 触发次数
    public var triggerCount: String = ""

    public var deviceID: String = ""

    /// 0: V1 1: Long connection 2:V2(Double button)
    public var version: Int = 0

    /// 仅 V2（双按键）有效
    public var motionStatus: Bool = false

    public init(advertiseData advData: Data) {
        super.init()
        let content = MKSwiftBleSDKAdopter.hexStringFromData(advData)
        var index = 0

        let typeString = content.bleSubstring(from: index, length: 2)
        index += 2

        var alarmType: MKBXDAdvAlarmType = .single
        switch typeString {
        case "21":
            alarmType = .double
        case "22":
            alarmType = .long
        case "23":
            alarmType = .abnormalInactivity
        default:
            break
        }
        self.alarmType = alarmType

        let state = content.bleSubstring(from: index, length: 2)
        index += 2

        self.triggerCount = MKSwiftBleSDKAdopter.getDecimalStringWithHex(content, range: NSRange(location: index, length: 4))
        index += 4

        // deviceID：advData.length - 6 个字节，对应字符串长度为 2 * len
        let len = advData.count - 6
        self.deviceID = content.bleSubstring(from: index, length: 2 * len)
        index += (2 * len)

        self.version = MKSwiftBleSDKAdopter.getDecimalWithHex(content, range: NSRange(location: index, length: 2))
        index += 2

        self.motionStatus = (content.bleSubstring(from: index, length: 2) == "01")

        // 解析触发状态位
        let binary = MKSwiftBleSDKAdopter.binaryByhex(state)
        if self.version == 2 {
            // V2 支持双按键
            let tempType = binary.bleSubstring(from: 5, length: 2)
            switch tempType {
            case "00":
                self.triggerStatus = 0
            case "01":
                self.triggerStatus = 1
            case "10":
                self.triggerStatus = 2
            default:
                break
            }
        } else {
            let bit = binary.bleSubstring(from: 6, length: 1)
            self.triggerStatus = Int(bit) ?? 0
        }
    }
}

// MARK: - 回应包
public class MKBXDAdvRespondDataModel: MKBXDBaseAdvModel {
    /// 发射功率
    public var txPower: NSNumber = 0

    /// 3 轴加速度量程。0:±2g，1:±4g，2:±8g，3:±16g
    public var fullScale: String = ""

    /// 运动阈值（单位 mg）
    public var motionThreshold: String = ""

    public var xData: String = ""
    public var yData: String = ""
    public var zData: String = ""

    /// 如果温度值为 ffff，表示不支持
    public var beaconTemperature: String = ""

    /// RSSI@0m
    public var rangingData: String = ""

    /// 电池电压（mV）
    public var voltage: String = ""

    public var macAddress: String = ""

    public init(advertiseData advData: Data) {
        super.init()
        let content = MKSwiftBleSDKAdopter.hexStringFromData(advData)
        var index = 2

        self.fullScale = MKSwiftBleSDKAdopter.getDecimalStringWithHex(content, range: NSRange(location: index, length: 2))
        index += 2

        self.motionThreshold = MKSwiftBleSDKAdopter.getDecimalStringWithHex(content, range: NSRange(location: index, length: 4))
        index += 4

        // x/y/z 轴数据（有符号）
        let xValue = MKSwiftBleSDKAdopter.signedHexTurnToInt(content.bleSubstring(from: index, length: 4))
        index += 4
        self.xData = String(format: "%ld", xValue)

        let yValue = MKSwiftBleSDKAdopter.signedHexTurnToInt(content.bleSubstring(from: index, length: 4))
        index += 4
        self.yData = String(format: "%ld", yValue)

        let zValue = MKSwiftBleSDKAdopter.signedHexTurnToInt(content.bleSubstring(from: index, length: 4))
        index += 4
        self.zData = String(format: "%ld", zValue)

        // 温度
        let temperature = content.bleSubstring(from: index, length: 4)
        index += 4
        if temperature.lowercased() == "ffff" {
            // 不支持芯片温度
            self.beaconTemperature = temperature
        } else {
            // 支持芯片温度
            let tempHigh = MKSwiftBleSDKAdopter.signedHexTurnToInt(temperature.bleSubstring(from: 0, length: 2))
            let tempLow = CGFloat(MKSwiftBleSDKAdopter.getDecimalWithHex(temperature, range: NSRange(location: 2, length: 2)))
            self.beaconTemperature = String(format: "%ld.%.2f", tempHigh, tempLow / 256.0)
        }

        // rangingData
        let tempRssi = MKSwiftBleSDKAdopter.signedHexTurnToInt(content.bleSubstring(from: index, length: 2))
        index += 2
        self.rangingData = String(format: "%ld", tempRssi)

        // 电池电压
        self.voltage = MKSwiftBleSDKAdopter.getDecimalStringWithHex(content, range: NSRange(location: index, length: 4))
        index += 4

        // MAC 地址
        let tempMac = content.bleSubstring(from: index, length: 12).uppercased()
        let macAddress = "\(tempMac.bleSubstring(from: 0, length: 2)):" +
                         "\(tempMac.bleSubstring(from: 2, length: 2)):" +
                         "\(tempMac.bleSubstring(from: 4, length: 2)):" +
                         "\(tempMac.bleSubstring(from: 6, length: 2)):" +
                         "\(tempMac.bleSubstring(from: 8, length: 2)):" +
                         "\(tempMac.bleSubstring(from: 10, length: 2))"
        self.macAddress = macAddress
    }
}

// MARK: - UID Beacon
public class MKBXDUIDBeacon: MKBXDBaseAdvModel {
    /// RSSI@0m
    public var txPower: NSNumber = 0
    public var namespaceId: String = ""
    public var instanceId: String = ""

    public init?(advertiseData advData: Data) {
        super.init()
        // 规范上 20 字节，但有些 beacon 不广播最后 2 个 RFU 字节
        guard advData.count >= 18 else {
            return nil
        }
        let bytes = [UInt8](advData)
        let txPowerChar = bytes[1]
        if txPowerChar & 0x80 != 0 {
            self.txPower = NSNumber(value: Int(txPowerChar) - 0x100)
        } else {
            self.txPower = NSNumber(value: Int(txPowerChar))
        }
        // namespace 10 字节，instance 6 字节
        let namespaceBytes = Array(bytes[2..<12])
        let instanceBytes = Array(bytes[12..<18])
        self.namespaceId = namespaceBytes.map { String(format: "%02x", $0) }.joined()
        self.instanceId = instanceBytes.map { String(format: "%02x", $0) }.joined()
    }
}

// MARK: - iBeacon
public class MKBXDBeacon: MKBXDBaseAdvModel {
    /// RSSI@1m
    public var rssi1M: NSNumber = 0
    public var txPower: NSNumber = 0
    /// 广播间隔
    public var interval: String = ""
    public var major: String = ""
    public var minor: String = ""
    public var uuid: String = ""

    public init?(advertiseData advData: Data) {
        super.init()
        guard advData.count >= 7 else {
            assertionFailure("Invalid advertiseData:\(advData)")
            return nil
        }
        let bytes = [UInt8](advData)
        let txPowerChar = bytes[1]
        if txPowerChar & 0x80 != 0 {
            self.rssi1M = NSNumber(value: Int(txPowerChar) - 0x100)
        } else {
            self.rssi1M = NSNumber(value: Int(txPowerChar))
        }

        let content = MKSwiftBleSDKAdopter.hexStringFromData(advData)
        let temp = content.bleSubstring(from: 4, length: content.count - 4)
        self.interval = MKSwiftBleSDKAdopter.getDecimalStringWithHex(temp, range: NSRange(location: 0, length: 2))

        // 拼接 UUID（包含分隔符）
        var array: [String] = [
            temp.bleSubstring(from: 2, length: 8),
            temp.bleSubstring(from: 10, length: 4),
            temp.bleSubstring(from: 14, length: 4),
            temp.bleSubstring(from: 18, length: 4),
            temp.bleSubstring(from: 22, length: 12)
        ]
        array.insert("-", at: 1)
        array.insert("-", at: 3)
        array.insert("-", at: 5)
        array.insert("-", at: 7)
        self.uuid = array.joined().uppercased()

        // major / minor
        let majorHex = temp.bleSubstring(from: 34, length: 4)
        let minorHex = temp.bleSubstring(from: 38, length: 4)
        if let majorValue = UInt64(majorHex, radix: 16) {
            self.major = String(format: "%ld", majorValue)
        }
        if let minorValue = UInt64(minorHex, radix: 16) {
            self.minor = String(format: "%ld", minorValue)
        }
    }
}
