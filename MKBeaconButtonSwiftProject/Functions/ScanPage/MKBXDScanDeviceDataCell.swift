//
//  MKBXDScanDeviceDataCell.swift
//  MKBeaconButtonSwiftProject
//
//  Created by aa on 2026/9/17.
//  Copyright © 2026 aadyx2007@163.com. All rights reserved.
//

import UIKit
@preconcurrency import CoreBluetooth

import SnapKit

import MKBaseSwiftModule
import MKSwiftCustomUI

// MARK: - Delegate

public protocol MKBXDScanDeviceDataCellDelegate: AnyObject {
    func mk_bxd_connectPeripheral(_ peripheral: CBPeripheral)
}

// MARK: - Cell

public final class MKBXDScanDeviceDataCell: MKSwiftBaseCell {

    public weak var delegate: MKBXDScanDeviceDataCellDelegate?

    public var dataModel: MKBXDScanDataModel? {
        didSet {
            guard let model = dataModel else { return }
            configure(with: model)
        }
    }

    // MARK: - Constants

    private let offsetX: CGFloat = 15
    private let rssiIconWidth: CGFloat = 22
    private let rssiIconHeight: CGFloat = 11
    private let connectButtonWidth: CGFloat = 80
    private let connectButtonHeight: CGFloat = 30
    private let batteryIconWidth: CGFloat = 25
    private let batteryIconHeight: CGFloat = 25

    // MARK: - Subviews

    private lazy var rssiIcon: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "bxd_signalIcon.png")
        return iv
    }()

    private lazy var rssiLabel: UILabel = {
        let label = createLabel(font: MKFont.font(10))
        label.textAlignment = .center
        return label
    }()

    private lazy var nameLabel: UILabel = {
        let label = createLabel(font: MKFont.font(15))
        label.textColor = MKColor.defaultText
        label.numberOfLines = 0
        return label
    }()

    private lazy var connectButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.backgroundColor = MKColor.navBar
        btn.setTitle("CONNECT", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = MKFont.font(15)
        btn.layer.masksToBounds = true
        btn.layer.cornerRadius = 10
        btn.addTarget(self, action: #selector(connectButtonPressed), for: .touchUpInside)
        return btn
    }()

    private lazy var batteryIcon: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "bxd_batteryHighest.png")
        return iv
    }()

    private lazy var batteryLabel: UILabel = {
        let label = createLabel(font: MKFont.font(10))
        label.textAlignment = .center
        return label
    }()

    private lazy var macLabel: UILabel = {
        return createLabel(font: MKFont.font(13))
    }()

    private lazy var devieIDLabel: UILabel = {
        return createLabel(font: MKFont.font(12))
    }()

    private lazy var txPowerLabel: UILabel = {
        let label = createLabel(font: MKFont.font(10))
        label.text = "Tx Power:"
        return label
    }()

    private lazy var txPowerValueLabel: UILabel = {
        return createLabel(font: MKFont.font(10))
    }()

    private lazy var rangingDataLabel: UILabel = {
        return createLabel(font: MKFont.font(10))
    }()

    private lazy var timeLabel: UILabel = {
        let label = createLabel(font: MKFont.font(10))
        label.textAlignment = .center
        return label
    }()

    private lazy var topBackView: UIView = UIView()
    private lazy var centerBackView: UIView = UIView()
    private lazy var bottomBackView: UIView = UIView()

    // MARK: - Init

    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(topBackView)
        contentView.addSubview(centerBackView)
        contentView.addSubview(bottomBackView)

        topBackView.addSubview(rssiIcon)
        topBackView.addSubview(rssiLabel)
        topBackView.addSubview(nameLabel)
        topBackView.addSubview(connectButton)
        topBackView.addSubview(macLabel)

        bottomBackView.addSubview(devieIDLabel)
        centerBackView.addSubview(batteryIcon)

        bottomBackView.addSubview(batteryLabel)
        bottomBackView.addSubview(txPowerLabel)
        bottomBackView.addSubview(txPowerValueLabel)
        bottomBackView.addSubview(rangingDataLabel)
        bottomBackView.addSubview(timeLabel)

        layer.masksToBounds = true
        layer.cornerRadius = 4
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Layout

    public override func layoutSubviews() {
        super.layoutSubviews()
        topBackView.snp.remakeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(40)
        }
        rssiIcon.snp.remakeConstraints { make in
            make.left.equalTo(20)
            make.top.equalTo(10)
            make.width.equalTo(rssiIconWidth)
            make.height.equalTo(rssiIconHeight)
        }
        rssiLabel.snp.remakeConstraints { make in
            make.centerX.equalTo(rssiIcon)
            make.width.equalTo(40)
            make.top.equalTo(rssiIcon.snp.bottom).offset(5)
            make.height.equalTo(MKFont.font(10).lineHeight)
        }
        let nameWidth = contentView.frame.size.width - 2 * offsetX - rssiIconWidth - 10 - 8 - connectButtonWidth
        let nameSize = NSString.mk_size(withText: nameLabel.text ?? "",
                                        andFont: nameLabel.font,
                                        andMaxSize: CGSize(width: nameWidth, height: .greatestFiniteMagnitude))
        nameLabel.snp.remakeConstraints { make in
            make.left.equalTo(rssiIcon.snp.right).offset(20)
            make.centerY.equalTo(rssiIcon)
            make.right.equalTo(connectButton.snp.left).offset(-8)
            make.height.equalTo(nameSize.height)
        }
        connectButton.snp.remakeConstraints { make in
            make.right.equalTo(-offsetX)
            make.width.equalTo(connectButtonWidth)
            make.centerY.equalTo(topBackView)
            make.height.equalTo(connectButtonHeight)
        }
        macLabel.snp.remakeConstraints { make in
            make.left.equalTo(nameLabel)
            make.right.equalTo(connectButton.snp.left).offset(-5)
            make.top.equalTo(nameLabel.snp.bottom).offset(3)
            make.height.equalTo(MKFont.font(13).lineHeight)
        }
        centerBackView.snp.remakeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(topBackView.snp.bottom)
            make.height.equalTo(batteryIconHeight)
        }
        batteryIcon.snp.remakeConstraints { make in
            make.left.equalTo(offsetX)
            make.width.equalTo(batteryIconWidth)
            make.centerY.equalTo(centerBackView)
            make.height.equalTo(batteryIconHeight)
        }
        devieIDLabel.snp.remakeConstraints { make in
            make.left.equalTo(nameLabel)
            make.right.equalTo(timeLabel.snp.left).offset(-5)
            make.centerY.equalTo(batteryIcon)
            make.height.equalTo(MKFont.font(12).lineHeight)
        }
        timeLabel.snp.remakeConstraints { make in
            make.right.equalTo(-15)
            make.width.equalTo(70)
            make.centerY.equalTo(devieIDLabel)
            make.height.equalTo(MKFont.font(10).lineHeight)
        }
        bottomBackView.snp.remakeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(centerBackView.snp.bottom)
            make.bottom.equalToSuperview()
        }
        batteryLabel.snp.remakeConstraints { make in
            make.centerX.equalTo(batteryIcon)
            make.width.equalTo(45)
            make.top.equalTo(3)
            make.height.equalTo(MKFont.font(15).lineHeight)
        }
        txPowerLabel.snp.remakeConstraints { make in
            make.left.equalTo(nameLabel)
            make.width.equalTo(60)
            make.centerY.equalTo(batteryLabel)
            make.height.equalTo(MKFont.font(10).lineHeight)
        }
        txPowerValueLabel.snp.remakeConstraints { make in
            make.left.equalTo(txPowerLabel.snp.right)
            make.width.equalTo(40)
            make.centerY.equalTo(txPowerLabel)
            make.height.equalTo(MKFont.font(10).lineHeight)
        }
        rangingDataLabel.snp.remakeConstraints { make in
            make.left.equalTo(txPowerValueLabel.snp.right).offset(5)
            make.right.equalTo(-15)
            make.centerY.equalTo(txPowerLabel)
            make.height.equalTo(MKFont.font(10).lineHeight)
        }
    }

    // MARK: - Actions

    @objc private func connectButtonPressed() {
        guard let peripheral = dataModel?.peripheral,
              peripheral.isKind(of: CBPeripheral.self) else {
            return
        }
        delegate?.mk_bxd_connectPeripheral(peripheral)
    }

    // MARK: - Configure

    private func configure(with model: MKBXDScanDataModel) {
        connectButton.isHidden = !model.connectEnable
        txPowerLabel.text = !model.txPower.isEmpty ? "Tx Power:" : ""
        txPowerValueLabel.text = !model.txPower.isEmpty ? model.txPower + "dBm" : ""
        rssiLabel.text = model.rssi + "dBm"
        nameLabel.text = !model.deviceName.isEmpty ? model.deviceName : "N/A"

        let macAddress = !model.macAddress.isEmpty ? model.macAddress : "N/A"
        macLabel.text = "MAC:\(macAddress)"

        if model.battery.isEmpty {
            batteryLabel.text = "N/A"
        } else {
            let unitString = (Int(model.battery) ?? 0) > 100 ? "mV" : "%"
            batteryLabel.text = model.battery + unitString
        }

        if !model.deviceID.isEmpty {
            devieIDLabel.text = "Device ID:0x\(model.deviceID)"
        }
        setNeedsLayout()
    }

    // MARK: - Helper

    private func createLabel(font: UIFont) -> UILabel {
        let label = UILabel()
        label.textColor = UIColor(red: 184/255.0, green: 184/255.0, blue: 184/255.0, alpha: 1)
        label.textAlignment = .left
        label.font = font
        return label
    }

    // MARK: - Static

    public static func initCellWithTableView(_ tableView: UITableView) -> MKBXDScanDeviceDataCell {
        let identy = "MKBXDScanDeviceDataCellIdenty"
        if let cell = tableView.dequeueReusableCell(withIdentifier: identy) as? MKBXDScanDeviceDataCell {
            return cell
        }
        return MKBXDScanDeviceDataCell(style: .default, reuseIdentifier: identy)
    }
}
