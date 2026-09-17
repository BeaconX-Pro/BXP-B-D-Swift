//
//  MKBXDAccelerationModel.swift
//  MKBeaconButtonSwiftProject
//
//  Created by aa on 2026/9/17.
//  Copyright © 2026 aadyx2007@163.com. All rights reserved.
//

import Foundation

import MKBaseSwiftModule

@MainActor
public final class MKBXDAccelerationModel: NSObject {

    /// 0:1hz, 1:10hz, 2:25hz, 3:50hz, 4:100hz
    public var samplingRate: Int = 0
    /// 0:±2g, 1:±4g, 2:±8g, 3:±16g
    public var scale: Int = 0
    public var threshold: String = ""

    public func read(sucBlock: @escaping () -> Void,
                     failedBlock: @escaping (Error) -> Void) {
        MKBXDInterface.bxd_readThreeAxisDataParams(sucBlock: { [weak self] returnData in
            guard let self = self else { return }
            let result = (returnData as? [String: Any])?["result"] as? [String: Any] ?? [:]
            self.scale = Int((result["fullScale"] as? String) ?? "0") ?? 0
            self.samplingRate = Int((result["samplingRate"] as? String) ?? "0") ?? 0
            self.threshold = (result["threshold"] as? String) ?? ""
            sucBlock()
        }, failedBlock: { error in
            failedBlock(error)
        })
    }

    public func config(sucBlock: @escaping () -> Void,
                       failedBlock: @escaping (Error) -> Void) {
        let rate = MKBXDThreeAxisDataRate(rawValue: samplingRate) ?? .rate1Hz
        let ag = MKBXDThreeAxisDataAG(rawValue: scale) ?? .ag2g
        MKBXDInterface.bxd_configThreeAxisDataParams(dataRate: rate,
                                                      fullScale: ag,
                                                      motionThreshold: Int(threshold) ?? 0,
                                                      sucBlock: {
            sucBlock()
        }, failedBlock: { error in
            failedBlock(error)
        })
    }
}
