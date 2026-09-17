//
//  MKBXDTypeAlias.swift
//  MKBeaconButtonSwiftProject
//
//  业务层沿用了 OC 时代的 MKBXScan* 旧命名，而 MKSwiftBeaconXCustomUI 组件
//  已统一为 MKSwiftBXScan* 前缀。这里通过 typealias 做桥接，避免大面积改动业务代码。
//

import MKSwiftBeaconXCustomUI

// MARK: - 扫描页 UI 组件旧名桥接

typealias MKBXScanSearchButton = MKSwiftBXScanSearchButton
typealias MKBXScanSearchButtonModel = MKSwiftBXScanSearchButtonModel
typealias MKBXScanSearchButtonDelegate = MKSwiftBXScanSearchButtonDelegate

typealias MKBXScanFilterView = MKSwiftBXScanFilterView

typealias MKBXScanUIDCell = MKSwiftBXScanUIDCell
typealias MKBXScanUIDCellModel = MKSwiftBXScanUIDCellModel

typealias MKBXScanBeaconCell = MKSwiftBXScanBeaconCell
typealias MKBXScanBeaconCellModel = MKSwiftBXScanBeaconCellModel
