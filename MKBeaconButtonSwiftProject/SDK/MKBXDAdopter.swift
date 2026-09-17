//
//  MKBXDAdopter.swift
//  MKBeaconButtonSwiftProject
//
//  Created by aa on 2025/5/18.
//

import Foundation
import MKSwiftBleModule

/// BXD 协议参数解析工具
public enum MKBXDAdopter {

    /// 校验活跃通道广播参数
    public static func validTriggerChannelAdvParams(_ params: MKBXDTriggerChannelAdvParamsProtocol) -> Bool {
        if params.rssi < -100 || params.rssi > 0 {
            return false
        }
        guard !params.advInterval.isEmpty,
              let value = Int(params.advInterval),
              value >= 1, value <= 500 else {
            return false
        }
        return true
    }

    /// 解析活跃通道广播参数为命令字符串
    public static func parseTriggerChannelAdvParams(_ params: MKBXDTriggerChannelAdvParamsProtocol) -> String {
        guard validTriggerChannelAdvParams(params) else {
            return ""
        }
        let channel = MKSwiftBleSDKAdopter.fetchHexValue(UInt(params.alarmType.rawValue), byteLen: 1)
        let state = params.isOn ? "01" : "00"
        let rssiValue = MKSwiftBleSDKAdopter.hexStringFromSignedNumber(params.rssi)
        let advInterval = MKSwiftBleSDKAdopter.fetchHexValue(UInt((Int(params.advInterval) ?? 0) * 20), byteLen: 2)
        let txPower = fetchTxPower(params.txPower)
        return "ea013406" + channel + state + rssiValue + advInterval + txPower
    }

    /// 校验活跃通道触发广播参数
    public static func validChannelTriggerParams(_ params: MKBXDChannelTriggerParamsProtocol) -> Bool {
        if params.rssi < -100 || params.rssi > 0 {
            return false
        }
        guard !params.advInterval.isEmpty,
              let advValue = Int(params.advInterval),
              advValue >= 1, advValue <= 500 else {
            return false
        }
        guard !params.advertisingTime.isEmpty,
              let timeValue = Int(params.advertisingTime),
              timeValue >= 1, timeValue <= 65535 else {
            return false
        }
        return true
    }

    /// 解析活跃通道触发广播参数为命令字符串
    public static func parseChannelTriggerParams(_ params: MKBXDChannelTriggerParamsProtocol) -> String {
        guard validChannelTriggerParams(params) else {
            return ""
        }
        let channel = MKSwiftBleSDKAdopter.fetchHexValue(UInt(params.alarmType.rawValue), byteLen: 1)
        let state = params.alarm ? "01" : "00"
        let rssiValue = MKSwiftBleSDKAdopter.hexStringFromSignedNumber(params.rssi)
        let advInterval = MKSwiftBleSDKAdopter.fetchHexValue(UInt((Int(params.advInterval) ?? 0) * 20), byteLen: 2)
        let txPower = fetchTxPower(params.txPower)
        let advTime = MKSwiftBleSDKAdopter.fetchHexValue(UInt(Int(params.advertisingTime) ?? 0), byteLen: 2)
        return "ea013508" + channel + state + rssiValue + advInterval + txPower + advTime
    }

    /// 发射功率枚举转十六进制字符串
    public static func fetchTxPower(_ txPower: MKBXDTxPower) -> String {
        switch txPower {
        case .four4dBm:    return "04"
        case .three3dBm:   return "03"
        case .zero0dBm:    return "00"
        case .neg4dBm:     return "fc"
        case .neg8dBm:     return "f8"
        case .neg12dBm:    return "f4"
        case .neg16dBm:    return "f0"
        case .neg20dBm:    return "ec"
        case .dBm40:      return "d8"
        }
    }

    /// 发射功率十六进制字符串转可读字符串
    public static func fetchTxPowerValueString(_ content: String) -> String {
        switch content {
        case "04": return "4dBm"
        case "03": return "3dBm"
        case "00": return "0dBm"
        case "fc": return "-4dBm"
        case "f8": return "-8dBm"
        case "f4": return "-12dBm"
        case "f0": return "-16dBm"
        case "ec": return "-20dBm"
        case "d8": return "-40dBm"
        default:  return "0dBm"
        }
    }

    /// 提醒类型枚举转十六进制字符串
    public static func fetchReminderTypeString(_ type: MKBXDReminderType) -> String {
        switch type {
        case .silent:           return "00"
        case .led:              return "01"
        case .buzzer:           return "03"
        case .ledAndBuzzer:     return "05"
        default:                return "00"
        }
    }

    /// 三轴数据采样率转十六进制字符串
    public static func fetchThreeAxisDataRate(_ dataRate: MKBXDThreeAxisDataRate) -> String {
        switch dataRate {
        case .rate1Hz:    return "00"
        case .rate10Hz:   return "01"
        case .rate25Hz:   return "02"
        case .rate50Hz:   return "03"
        case .rate100Hz:  return "04"
        }
    }

    /// 三轴加速度量程转十六进制字符串
    public static func fetchThreeAxisDataAG(_ ag: MKBXDThreeAxisDataAG) -> String {
        switch ag {
        case .ag2g:  return "00"
        case .ag4g:  return "01"
        case .ag8g:  return "02"
        case .ag16g: return "03"
        }
    }

    /// 解析通道广播帧内容
    /// - Parameter content: 通道广播帧内容字符串
    /// - Returns: 解析后的字典，可能包含 channelType/advType/advContent
    public static func parseChannelContent(_ content: String) -> [String: Any] {
        guard !content.isEmpty, content.count >= 2 else {
            return [:]
        }
        var resultDic: [String: Any] = [:]
        var index = 0

        let channelType = content.bleSubstring(from: index, length: 2)
        resultDic["channelType"] = channelType
        index += 2

        let advType = MKSwiftBleSDKAdopter.getDecimalStringWithHex(content, range: NSRange(location: index, length: 2))
        resultDic["advType"] = advType
        index += 2

        switch advType {
        case "0":
            // Alarm info
            return resultDic
        case "1":
            // UID
            let namespaceID = content.bleSubstring(from: index, length: 20)
            index += 20
            let instanceID = content.bleSubstring(from: index, length: 12)
            index += 12
            resultDic["advContent"] = [
                "namespaceID": namespaceID,
                "instanceID": instanceID
            ]
            return resultDic
        case "2":
            // iBeacon
            let uuid = content.bleSubstring(from: index, length: 32)
            index += 32
            let major = MKSwiftBleSDKAdopter.getDecimalStringWithHex(content, range: NSRange(location: index, length: 4))
            index += 4
            let minor = MKSwiftBleSDKAdopter.getDecimalStringWithHex(content, range: NSRange(location: index, length: 4))
            index += 4
            resultDic["advContent"] = [
                "uuid": uuid,
                "major": major,
                "minor": minor
            ]
            return resultDic
        default:
            return [:]
        }
    }
}
