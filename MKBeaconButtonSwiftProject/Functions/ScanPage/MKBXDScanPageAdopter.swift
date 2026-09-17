//
//  MKBXDScanPageAdopter.swift
//  MKBeaconButtonSwiftProject
//
//  Created by aa on 2026/9/17.
//  Copyright © 2026 aadyx2007@163.com. All rights reserved.
//

import UIKit
@preconcurrency import CoreBluetooth

import MKBaseSwiftModule
import MKSwiftCustomUI
import MKSwiftBeaconXCustomUI

// MARK: - 扫描帧 Model 统一协议（用关联对象存 index / frameIndex）

/// 扫描设备信息中每一种广播帧 model 的统一协议
public protocol MKBXDScanFrameModel: AnyObject {
    /// 用来标示数据 model 在设备列表或者设备信息广播帧数组里的 index
    var mk_bxd_index: Int { get set }
    /// 用来对同一个设备的广播帧进行排序
    var mk_bxd_frameIndex: Int { get set }
}

private var kMKBXDIndexKey: UInt8 = 0
private var kMKBXDFrameIndexKey: UInt8 = 1

public extension MKBXDScanFrameModel where Self: AnyObject {
    var mk_bxd_index: Int {
        get { (objc_getAssociatedObject(self, &kMKBXDIndexKey) as? Int) ?? 0 }
        set { objc_setAssociatedObject(self, &kMKBXDIndexKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    var mk_bxd_frameIndex: Int {
        get { (objc_getAssociatedObject(self, &kMKBXDFrameIndexKey) as? Int) ?? 0 }
        set { objc_setAssociatedObject(self, &kMKBXDFrameIndexKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
}

// 业务自有 model（继承 NSObject）遵循协议，直接获得关联对象默认实现
extension MKBXDScanAdvCellModel: MKBXDScanFrameModel {}
extension MKBXDScanDeviceInfoCellModel: MKBXDScanFrameModel {}

// 组件库 model 自带 index/frameIndex 存储属性，桥接到统一协议
extension MKSwiftBXScanBeaconCellModel: MKBXDScanFrameModel {
    public var mk_bxd_index: Int {
        get { index }
        set { index = newValue }
    }
    public var mk_bxd_frameIndex: Int {
        get { frameIndex }
        set { frameIndex = newValue }
    }
}

extension MKSwiftBXScanUIDCellModel: MKBXDScanFrameModel {
    public var mk_bxd_index: Int {
        get { index }
        set { index = newValue }
    }
    public var mk_bxd_frameIndex: Int {
        get { frameIndex }
        set { frameIndex = newValue }
    }
}

// MARK: - Adopter

public enum MKBXDScanPageAdopter {

    // MARK: - parseAdvDatas

    /// 将扫描到的数据转换成对应的 CellModel
    public static func parseAdvDatas(_ advModel: MKBXDBaseAdvModel) -> MKBXDScanFrameModel? {
        if let beacon = advModel as? MKBXDBeacon {
            // iBeacon
            let cellModel = MKSwiftBXScanBeaconCellModel()
            cellModel.rssi = "\(beacon.rssi.intValue)"
            cellModel.rssi1M = "\(beacon.rssi1M.intValue)"
            cellModel.txPower = "\(beacon.txPower.intValue)"
            cellModel.interval = beacon.interval
            cellModel.major = beacon.major
            cellModel.minor = beacon.minor
            cellModel.uuid = beacon.uuid.lowercased()
            return cellModel
        }
        if let uidBeacon = advModel as? MKBXDUIDBeacon {
            // UID
            let cellModel = MKSwiftBXScanUIDCellModel()
            cellModel.txPower = "\(uidBeacon.txPower.intValue)"
            cellModel.namespaceId = uidBeacon.namespaceId
            cellModel.instanceId = uidBeacon.instanceId
            return cellModel
        }
        if let advData = advModel as? MKBXDAdvDataModel {
            // 触发数据包
            let cellModel = MKBXDScanAdvCellModel()
            cellModel.alarmMode = advData.alarmType.rawValue
            cellModel.triggerStatus = advData.triggerStatus
            cellModel.triggerCount = advData.triggerCount
            cellModel.motionStatus = advData.motionStatus
            cellModel.version = advData.version
            return cellModel
        }
        if let respondData = advModel as? MKBXDAdvRespondDataModel {
            // 芯片信息报
            let cellModel = MKBXDScanDeviceInfoCellModel()
            cellModel.rangingData = respondData.rangingData + "dBm"
            cellModel.xData = respondData.xData + "mg"
            cellModel.yData = respondData.yData + "mg"
            cellModel.zData = respondData.zData + "mg"
            return cellModel
        }
        return nil
    }

    // MARK: - parseBaseAdvDataToInfoModel

    /// 将扫描到的数据转换成 MKBXDScanDataModel
    public static func parseBaseAdvDataToInfoModel(_ advData: MKBXDBaseAdvModel) -> MKBXDScanDataModel {
        let deviceModel = MKBXDScanDataModel()
        guard let identifier = advData.peripheral?.identifier.uuidString else {
            return deviceModel
        }
        deviceModel.identifier = identifier
        deviceModel.rssi = "\(advData.rssi.intValue)"
        deviceModel.displayTime = "N/A"
        deviceModel.lastScanDate = Date().timeIntervalSince1970 * 1000
        deviceModel.connectEnable = advData.connectEnable
        deviceModel.peripheral = advData.peripheral

        var frameType = 0
        if let respondData = advData as? MKBXDAdvRespondDataModel {
            // 回应包
            deviceModel.battery = respondData.voltage
            deviceModel.txPower = "\(respondData.txPower.intValue)"
            deviceModel.macAddress = respondData.macAddress
            frameType = 4
        } else if let advDataModel = advData as? MKBXDAdvDataModel {
            deviceModel.deviceName = advDataModel.deviceName
            frameType = advDataModel.alarmType.rawValue
            deviceModel.deviceID = advDataModel.deviceID
        } else if advData is MKBXDUIDBeacon {
            frameType = 5
        } else if advData is MKBXDBeacon {
            frameType = 6
        }

        guard let obj = parseAdvDatas(advData) else {
            return deviceModel
        }
        obj.mk_bxd_index = 0
        obj.mk_bxd_frameIndex = frameType
        deviceModel.advertiseList.append(obj)

        return deviceModel
    }

    // MARK: - updateInfoCellModel

    /// 新扫描到的数据已经在列表的数据源中存在，则需要替换，不存在则添加
    public static func updateInfoCellModel(_ exsitModel: MKBXDScanDataModel, advData: MKBXDBaseAdvModel) {
        exsitModel.connectEnable = advData.connectEnable
        exsitModel.peripheral = advData.peripheral
        exsitModel.rssi = "\(advData.rssi.intValue)"

        if exsitModel.lastScanDate > 0 {
            let space = Date().timeIntervalSince1970 * 1000 - exsitModel.lastScanDate
            if space > 10 {
                exsitModel.displayTime = "<->\(Int(space))ms"
                exsitModel.lastScanDate = Date().timeIntervalSince1970 * 1000
            }
        }

        var frameType = 0
        if let respondData = advData as? MKBXDAdvRespondDataModel {
            // 回应包
            exsitModel.battery = respondData.voltage
            exsitModel.txPower = "\(respondData.txPower.intValue)"
            exsitModel.macAddress = respondData.macAddress
            frameType = 4
        } else if let advDataModel = advData as? MKBXDAdvDataModel {
            exsitModel.deviceName = advDataModel.deviceName
            frameType = advDataModel.alarmType.rawValue
            exsitModel.deviceID = advDataModel.deviceID
        } else if advData is MKBXDUIDBeacon {
            frameType = 5
        } else if advData is MKBXDBeacon {
            frameType = 6
        }

        guard let tempModel = parseAdvDatas(advData) else {
            return
        }
        tempModel.mk_bxd_frameIndex = frameType

        // 查找已有的
        for model in exsitModel.advertiseList {
            guard let model = model as? MKBXDScanFrameModel else { continue }
            if tempModel.mk_bxd_frameIndex == model.mk_bxd_frameIndex {
                // 需要替换
                tempModel.mk_bxd_index = model.mk_bxd_index
                if let idx = exsitModel.advertiseList.firstIndex(where: { ($0 as? MKBXDScanFrameModel) === model }) {
                    exsitModel.advertiseList[idx] = tempModel
                }
                return
            }
        }

        // 不包含则添加
        exsitModel.advertiseList.append(tempModel)
        tempModel.mk_bxd_index = exsitModel.advertiseList.count - 1

        // 排序
        let tempArray = exsitModel.advertiseList
        let sortedArray = tempArray.sorted { a, b in
            guard let a = a as? MKBXDScanFrameModel, let b = b as? MKBXDScanFrameModel else { return false }
            return a.mk_bxd_frameIndex < b.mk_bxd_frameIndex
        }
        exsitModel.advertiseList.removeAll()
        for (i, model) in sortedArray.enumerated() {
            if let model = model as? MKBXDScanFrameModel {
                model.mk_bxd_index = i
            }
            exsitModel.advertiseList.append(model)
        }
    }

    // MARK: - loadCell

    /// 根据不同的 dataModel 加载 cell
    public static func loadCellWithTableView(_ tableView: UITableView, dataModel: MKBXDScanFrameModel) -> UITableViewCell {
        if let model = dataModel as? MKSwiftBXScanUIDCellModel {
            // UID
            let cell = MKSwiftBXScanUIDCell.initCell(with: tableView)
            cell.dataModel = model
            return cell
        }
        if let model = dataModel as? MKSwiftBXScanBeaconCellModel {
            // iBeacon
            let cell = MKSwiftBXScanBeaconCell.initCell(with: tableView)
            cell.dataModel = model
            return cell
        }
        if let model = dataModel as? MKBXDScanDeviceInfoCellModel {
            // Device Info
            let cell = MKBXDScanDeviceInfoCell.initCellWithTableView(tableView)
            cell.dataModel = model
            return cell
        }
        if let model = dataModel as? MKBXDScanAdvCellModel {
            // Adv Data
            let cell = MKBXDScanAdvCell.initCellWithTableView(tableView)
            cell.dataModel = model
            return cell
        }
        return UITableViewCell(style: .default, reuseIdentifier: "MKBXDScanPageAdopterIdenty")
    }

    // MARK: - loadCellHeight

    /// 根据不同的 dataModel 返回 cell 的高度
    public static func loadCellHeightWithDataModel(_ dataModel: MKBXDScanFrameModel) -> CGFloat {
        if dataModel is MKSwiftBXScanUIDCellModel {
            // UID
            return 85
        }
        if let model = dataModel as? MKSwiftBXScanBeaconCellModel {
            // iBeacon
            return MKSwiftBXScanBeaconCell.getCellHeight(with: model.uuid)
        }
        if dataModel is MKBXDScanDeviceInfoCellModel {
            // Device Info
            return 105
        }
        if let model = dataModel as? MKBXDScanAdvCellModel {
            // Adv Data
            if model.alarmMode != 3 {
                if model.version == 2 {
                    return 90
                }
                return 70
            }
            if model.version == 2 {
                return 70
            }
            return 50
        }
        return 0
    }
}
