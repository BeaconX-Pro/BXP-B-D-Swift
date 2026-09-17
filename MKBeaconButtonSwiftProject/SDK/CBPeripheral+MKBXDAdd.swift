//
//  CBPeripheral+MKBXDAdd.swift
//  MKBeaconButtonSwiftProject
//
//  Created by aa on 2025/5/18.
//

import Foundation
@preconcurrency import CoreBluetooth

// MARK: - 关联对象 key
private var bxd_customKey: UInt8 = 0
private var bxd_disconnectTypeKey: UInt8 = 0
private var bxd_singleRecordKey: UInt8 = 0
private var bxd_doubleRecordKey: UInt8 = 0
private var bxd_longRecordKey: UInt8 = 0
private var bxd_longConnectRecordKey: UInt8 = 0
private var bxd_passwordKey: UInt8 = 0
private var bxd_threeAxisDataKey: UInt8 = 0
private var bxd_longConModeDataKey: UInt8 = 0
private var bxd_subBtnDataKey: UInt8 = 0

private var bxd_manufacturerKey: UInt8 = 0
private var bxd_deviceModelKey: UInt8 = 0
private var bxd_productionDateKey: UInt8 = 0
private var bxd_hardwareKey: UInt8 = 0
private var bxd_softwareKey: UInt8 = 0
private var bxd_firmwareKey: UInt8 = 0

private var bxd_otaControlKey: UInt8 = 0
private var bxd_otaDataKey: UInt8 = 0

private var bxd_customSuccessKey: UInt8 = 0
private var bxd_disconnectTypeSuccessKey: UInt8 = 0
private var bxd_passwordSuccessKey: UInt8 = 0

// MARK: - CBPeripheral + BXD 特征管理
extension CBPeripheral {

    // MARK: - 系统信息特征（只读）
    /// 厂商信息
    public var bxd_manufacturer: CBCharacteristic? {
        objc_getAssociatedObject(self, &bxd_manufacturerKey) as? CBCharacteristic
    }

    /// 产品型号
    public var bxd_deviceModel: CBCharacteristic? {
        objc_getAssociatedObject(self, &bxd_deviceModelKey) as? CBCharacteristic
    }

    /// 生产日期
    public var bxd_productionDate: CBCharacteristic? {
        objc_getAssociatedObject(self, &bxd_productionDateKey) as? CBCharacteristic
    }

    /// 硬件类型
    public var bxd_hardware: CBCharacteristic? {
        objc_getAssociatedObject(self, &bxd_hardwareKey) as? CBCharacteristic
    }

    /// 软件版本
    public var bxd_software: CBCharacteristic? {
        objc_getAssociatedObject(self, &bxd_softwareKey) as? CBCharacteristic
    }

    /// 固件版本
    public var bxd_firmware: CBCharacteristic? {
        objc_getAssociatedObject(self, &bxd_firmwareKey) as? CBCharacteristic
    }

    // MARK: - 自定义特征
    public var bxd_custom: CBCharacteristic? {
        objc_getAssociatedObject(self, &bxd_customKey) as? CBCharacteristic
    }

    public var bxd_disconnectType: CBCharacteristic? {
        objc_getAssociatedObject(self, &bxd_disconnectTypeKey) as? CBCharacteristic
    }

    // BXP-CR
    public var bxd_singleRecord: CBCharacteristic? {
        objc_getAssociatedObject(self, &bxd_singleRecordKey) as? CBCharacteristic
    }

    // BXP-CR
    public var bxd_doubleRecord: CBCharacteristic? {
        objc_getAssociatedObject(self, &bxd_doubleRecordKey) as? CBCharacteristic
    }

    // BXP-CR
    public var bxd_longRecord: CBCharacteristic? {
        objc_getAssociatedObject(self, &bxd_longRecordKey) as? CBCharacteristic
    }

    // BXP-CR
    public var bxd_longConnectRecord: CBCharacteristic? {
        objc_getAssociatedObject(self, &bxd_longConnectRecordKey) as? CBCharacteristic
    }

    public var bxd_password: CBCharacteristic? {
        objc_getAssociatedObject(self, &bxd_passwordKey) as? CBCharacteristic
    }

    public var bxd_threeAxisData: CBCharacteristic? {
        objc_getAssociatedObject(self, &bxd_threeAxisDataKey) as? CBCharacteristic
    }

    public var bxd_longConModeData: CBCharacteristic? {
        objc_getAssociatedObject(self, &bxd_longConModeDataKey) as? CBCharacteristic
    }

    public var bxd_subBtnData: CBCharacteristic? {
        objc_getAssociatedObject(self, &bxd_subBtnDataKey) as? CBCharacteristic
    }

    // MARK: - OTA 特征
    public var bxd_otaData: CBCharacteristic? {
        objc_getAssociatedObject(self, &bxd_otaDataKey) as? CBCharacteristic
    }

    public var bxd_otaControl: CBCharacteristic? {
        objc_getAssociatedObject(self, &bxd_otaControlKey) as? CBCharacteristic
    }

    // MARK: - 业务方法

    /// 根据 service 更新对应特征引用，并对需要 notify 的特征开启 notify
    public func bxd_updateCharacterWithService(_ service: CBService) {
        guard let characteristicList = service.characteristics else { return }

        if service.uuid == CBUUID(string: "180A") {
            // 设备信息
            for characteristic in characteristicList {
                switch characteristic.uuid.uuidString {
                case "2A24":
                    objc_setAssociatedObject(self, &bxd_deviceModelKey, characteristic, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                case "2A25":
                    objc_setAssociatedObject(self, &bxd_productionDateKey, characteristic, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                case "2A26":
                    objc_setAssociatedObject(self, &bxd_firmwareKey, characteristic, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                case "2A27":
                    objc_setAssociatedObject(self, &bxd_hardwareKey, characteristic, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                case "2A28":
                    objc_setAssociatedObject(self, &bxd_softwareKey, characteristic, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                case "2A29":
                    objc_setAssociatedObject(self, &bxd_manufacturerKey, characteristic, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                default:
                    break
                }
            }
            return
        }

        if service.uuid == CBUUID(string: "AA00") {
            // 自定义
            for characteristic in characteristicList {
                switch characteristic.uuid.uuidString {
                case "AA01":
                    objc_setAssociatedObject(self, &bxd_customKey, characteristic, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                    setNotifyValue(true, for: characteristic)
                case "AA02":
                    objc_setAssociatedObject(self, &bxd_disconnectTypeKey, characteristic, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                    setNotifyValue(true, for: characteristic)
                case "AA03":
                    objc_setAssociatedObject(self, &bxd_singleRecordKey, characteristic, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                case "AA04":
                    objc_setAssociatedObject(self, &bxd_doubleRecordKey, characteristic, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                case "AA05":
                    objc_setAssociatedObject(self, &bxd_longRecordKey, characteristic, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                case "AA06":
                    objc_setAssociatedObject(self, &bxd_threeAxisDataKey, characteristic, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                case "AA07":
                    objc_setAssociatedObject(self, &bxd_passwordKey, characteristic, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                    setNotifyValue(true, for: characteristic)
                case "AA08":
                    objc_setAssociatedObject(self, &bxd_longConModeDataKey, characteristic, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                case "AA09":
                    objc_setAssociatedObject(self, &bxd_longConnectRecordKey, characteristic, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                case "AA0A":
                    objc_setAssociatedObject(self, &bxd_subBtnDataKey, characteristic, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                default:
                    break
                }
            }
            return
        }

        if service.uuid == CBUUID(string: "00001530-1212-EFDE-1523-785FEABCD123") {
            // OTA
            for characteristic in characteristicList {
                switch characteristic.uuid.uuidString {
                case "00001531-1212-EFDE-1523-785FEABCD123":
                    objc_setAssociatedObject(self, &bxd_otaControlKey, characteristic, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                case "00001532-1212-EFDE-1523-785FEABCD123":
                    objc_setAssociatedObject(self, &bxd_otaDataKey, characteristic, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                default:
                    break
                }
            }
            return
        }
    }

    /// 标记 notify 启用成功
    public func bxd_updateCurrentNotifySuccess(_ characteristic: CBCharacteristic) {
        switch characteristic.uuid.uuidString {
        case "AA01":
            objc_setAssociatedObject(self, &bxd_customSuccessKey, NSNumber(value: true), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        case "AA02":
            objc_setAssociatedObject(self, &bxd_disconnectTypeSuccessKey, NSNumber(value: true), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        case "AA07":
            objc_setAssociatedObject(self, &bxd_passwordSuccessKey, NSNumber(value: true), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        default:
            break
        }
    }

    /// 判断连接是否成功（dfu=true 仅校验 OTA 特征）
    public func bxd_connectSuccess(_ dfu: Bool) -> Bool {
        if dfu {
            guard bxd_otaData != nil, bxd_otaControl != nil else {
                return false
            }
            return true
        }

        let disconnectSuccess = (objc_getAssociatedObject(self, &bxd_disconnectTypeSuccessKey) as? NSNumber)?.boolValue ?? false
        let customSuccess = (objc_getAssociatedObject(self, &bxd_customSuccessKey) as? NSNumber)?.boolValue ?? false
        let passwordSuccess = (objc_getAssociatedObject(self, &bxd_passwordSuccessKey) as? NSNumber)?.boolValue ?? false

        if !disconnectSuccess || !customSuccess || !passwordSuccess {
            return false
        }
        if !bxd_customServiceSuccess {
            return false
        }
        return true
    }

    /// 清空所有特征关联对象
    public func bxd_setNil() {
        objc_setAssociatedObject(self, &bxd_manufacturerKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        objc_setAssociatedObject(self, &bxd_productionDateKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        objc_setAssociatedObject(self, &bxd_deviceModelKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        objc_setAssociatedObject(self, &bxd_hardwareKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        objc_setAssociatedObject(self, &bxd_softwareKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        objc_setAssociatedObject(self, &bxd_firmwareKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

        objc_setAssociatedObject(self, &bxd_singleRecordKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        objc_setAssociatedObject(self, &bxd_doubleRecordKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        objc_setAssociatedObject(self, &bxd_longRecordKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        objc_setAssociatedObject(self, &bxd_longConnectRecordKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

        objc_setAssociatedObject(self, &bxd_customKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        objc_setAssociatedObject(self, &bxd_disconnectTypeKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        objc_setAssociatedObject(self, &bxd_passwordKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        objc_setAssociatedObject(self, &bxd_threeAxisDataKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        objc_setAssociatedObject(self, &bxd_longConModeDataKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        objc_setAssociatedObject(self, &bxd_subBtnDataKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

        objc_setAssociatedObject(self, &bxd_otaControlKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        objc_setAssociatedObject(self, &bxd_otaDataKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

        objc_setAssociatedObject(self, &bxd_customSuccessKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        objc_setAssociatedObject(self, &bxd_disconnectTypeSuccessKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        objc_setAssociatedObject(self, &bxd_passwordSuccessKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }

    // MARK: - private
    /// 校验自定义服务特征是否齐全
    private var bxd_customServiceSuccess: Bool {
        guard bxd_custom != nil,
              bxd_disconnectType != nil,
              bxd_password != nil,
              bxd_threeAxisData != nil else {
            return false
        }
        return true
    }

    /// 校验设备信息服务特征是否齐全
    private var bxd_deviceInfoServiceSuccess: Bool {
        guard bxd_manufacturer != nil,
              bxd_productionDate != nil,
              bxd_deviceModel != nil,
              bxd_hardware != nil,
              bxd_software != nil,
              bxd_firmware != nil else {
            return false
        }
        return true
    }
}
