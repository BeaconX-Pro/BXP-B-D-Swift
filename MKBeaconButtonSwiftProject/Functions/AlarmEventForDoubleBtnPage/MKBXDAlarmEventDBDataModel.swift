//
//  MKBXDAlarmEventDBDataModel.swift
//  MKBeaconButtonSwiftProject
//
//  Created by aa on 2026/9/17.
//  Copyright © 2026 aadyx2007@163.com. All rights reserved.
//

import Foundation

import MKBaseSwiftModule

@MainActor
public final class MKBXDAlarmEventDBDataModel: NSObject {

    public var singleMainCount: String = ""
    public var singleSubCount: String = ""
    public var doubleMainCount: String = ""
    public var doubleSubCount: String = ""
    public var longMainCount: String = ""
    public var longSubCount: String = ""

    public func readData(sucBlock: @escaping () -> Void,
                         failedBlock: @escaping (Error) -> Void) {
        // 串行 6 个读取
        readSingleMainCount(sucBlock: { [weak self] in
            guard let self = self else { return }
            self.readSingleSubCount(sucBlock: { [weak self] in
                guard let self = self else { return }
                self.readDoubleMainCount(sucBlock: { [weak self] in
                    guard let self = self else { return }
                    self.readDoubleSubCount(sucBlock: { [weak self] in
                        guard let self = self else { return }
                        self.readLongMainCount(sucBlock: { [weak self] in
                            guard let self = self else { return }
                            self.readLongSubCount(sucBlock: {
                                sucBlock()
                            }, failedBlock: failedBlock)
                        }, failedBlock: failedBlock)
                    }, failedBlock: failedBlock)
                }, failedBlock: failedBlock)
            }, failedBlock: failedBlock)
        }, failedBlock: failedBlock)
    }

    private func readSingleMainCount(sucBlock: @escaping () -> Void,
                                      failedBlock: @escaping (Error) -> Void) {
        MKBXDInterface.bxd_readSinglePressEventCount(sucBlock: { [weak self] returnData in
            guard let self = self else { return }
            let result = (returnData as? [String: Any])?["result"] as? [String: Any] ?? [:]
            self.singleMainCount = (result["count"] as? String) ?? "0"
            sucBlock()
        }, failedBlock: { error in
            failedBlock(error)
        })
    }

    private func readSingleSubCount(sucBlock: @escaping () -> Void,
                                     failedBlock: @escaping (Error) -> Void) {
        MKBXDInterface.bxd_readSubButtonSinglePressEventCount(sucBlock: { [weak self] returnData in
            guard let self = self else { return }
            let result = (returnData as? [String: Any])?["result"] as? [String: Any] ?? [:]
            self.singleSubCount = (result["count"] as? String) ?? "0"
            sucBlock()
        }, failedBlock: { error in
            failedBlock(error)
        })
    }

    private func readDoubleMainCount(sucBlock: @escaping () -> Void,
                                      failedBlock: @escaping (Error) -> Void) {
        MKBXDInterface.bxd_readDoublePressEventCount(sucBlock: { [weak self] returnData in
            guard let self = self else { return }
            let result = (returnData as? [String: Any])?["result"] as? [String: Any] ?? [:]
            self.doubleMainCount = (result["count"] as? String) ?? "0"
            sucBlock()
        }, failedBlock: { error in
            failedBlock(error)
        })
    }

    private func readDoubleSubCount(sucBlock: @escaping () -> Void,
                                     failedBlock: @escaping (Error) -> Void) {
        MKBXDInterface.bxd_readSubButtonDoublePressEventCount(sucBlock: { [weak self] returnData in
            guard let self = self else { return }
            let result = (returnData as? [String: Any])?["result"] as? [String: Any] ?? [:]
            self.doubleSubCount = (result["count"] as? String) ?? "0"
            sucBlock()
        }, failedBlock: { error in
            failedBlock(error)
        })
    }

    private func readLongMainCount(sucBlock: @escaping () -> Void,
                                    failedBlock: @escaping (Error) -> Void) {
        MKBXDInterface.bxd_readLongPressEventCount(sucBlock: { [weak self] returnData in
            guard let self = self else { return }
            let result = (returnData as? [String: Any])?["result"] as? [String: Any] ?? [:]
            self.longMainCount = (result["count"] as? String) ?? "0"
            sucBlock()
        }, failedBlock: { error in
            failedBlock(error)
        })
    }

    private func readLongSubCount(sucBlock: @escaping () -> Void,
                                   failedBlock: @escaping (Error) -> Void) {
        MKBXDInterface.bxd_readSubButtonLongPressEventCount(sucBlock: { [weak self] returnData in
            guard let self = self else { return }
            let result = (returnData as? [String: Any])?["result"] as? [String: Any] ?? [:]
            self.longSubCount = (result["count"] as? String) ?? "0"
            sucBlock()
        }, failedBlock: { error in
            failedBlock(error)
        })
    }
}
