//
//  MKBXDScanDataModel.swift
//  MKBeaconButtonSwiftProject
//
//  Created by aa on 2026/9/17.
//  Copyright © 2026 aadyx2007@163.com. All rights reserved.
//

import Foundation
@preconcurrency import CoreBluetooth

import MKBaseSwiftModule

public final class MKBXDScanDataModel: NSObject {

    /// 强业务相关，设备信息帧的广播数组
    public var advertiseList: [Any] = []

    public var rssi: String = ""

    public var connectEnable: Bool = false

    /// 扫描到的设备标识
    public var identifier: String = ""

    /// 扫描到的设备
    public var peripheral: CBPeripheral?

    public var deviceName: String = ""

    public var battery: String = ""

    public var txPower: String = ""

    public var macAddress: String = ""

    public var deviceID: String = ""

    /// 用于记录本次扫到该设备距离上次扫到该设备的时间差，单位 ms
    public var displayTime: String = ""

    /// 上一次扫描到的时间
    public var lastScanDate: TimeInterval = 0
}
