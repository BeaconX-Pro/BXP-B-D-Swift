//
//  MKBXDScanDeviceInfoCell.swift
//  MKBeaconButtonSwiftProject
//
//  Created by aa on 2026/9/17.
//  Copyright © 2026 aadyx2007@163.com. All rights reserved.
//

import UIKit

import SnapKit

import MKBaseSwiftModule
import MKSwiftCustomUI

// MARK: - Model

public final class MKBXDScanDeviceInfoCellModel: NSObject {
    public var rangingData: String = ""
    public var xData: String = ""
    public var yData: String = ""
    public var zData: String = ""
}

// MARK: - Cell

public final class MKBXDScanDeviceInfoCell: MKSwiftBaseCell {

    public var dataModel: MKBXDScanDeviceInfoCellModel? {
        didSet {
            guard let model = dataModel else { return }
            configure(with: model)
        }
    }

    // MARK: - Subviews

    private lazy var leftIcon: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "bxd_littleBluePoint.png")
        return iv
    }()

    private lazy var msgLabel: UILabel = {
        let label = UILabel()
        label.textColor = MKColor.defaultText
        label.font = MKFont.font(15)
        label.textAlignment = .left
        label.text = "Device info"
        return label
    }()

    private lazy var rangingLabel: UILabel = {
        let label = createLabel()
        label.text = "Ranging data"
        return label
    }()

    private lazy var rangingValueLabel: UILabel = {
        return createLabel()
    }()

    private lazy var accelerationLabel: UILabel = {
        let label = createLabel()
        label.text = "Acceleration"
        return label
    }()

    private lazy var xDataLabel: UILabel = {
        return createLabel()
    }()

    private lazy var yDataLabel: UILabel = {
        return createLabel()
    }()

    private lazy var zDataLabel: UILabel = {
        return createLabel()
    }()

    // MARK: - Init

    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(leftIcon)
        contentView.addSubview(msgLabel)
        contentView.addSubview(rangingLabel)
        contentView.addSubview(rangingValueLabel)
        contentView.addSubview(accelerationLabel)
        contentView.addSubview(xDataLabel)
        contentView.addSubview(yDataLabel)
        contentView.addSubview(zDataLabel)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Layout

    public override func layoutSubviews() {
        super.layoutSubviews()
        leftIcon.snp.remakeConstraints { make in
            make.left.equalTo(10)
            make.width.height.equalTo(7)
            make.top.equalTo(10)
        }
        msgLabel.snp.remakeConstraints { make in
            make.left.equalTo(leftIcon.snp.right).offset(5)
            make.right.equalTo(-10)
            make.centerY.equalTo(leftIcon)
            make.height.equalTo(MKFont.font(15).lineHeight)
        }
        rangingLabel.snp.remakeConstraints { make in
            make.left.equalTo(msgLabel)
            make.right.equalTo(contentView.snp.centerX).offset(-5)
            make.top.equalTo(msgLabel.snp.bottom).offset(5)
            make.height.equalTo(MKFont.font(12).lineHeight)
        }
        rangingValueLabel.snp.remakeConstraints { make in
            make.left.equalTo(contentView.snp.centerX).offset(5)
            make.right.equalTo(-10)
            make.centerY.equalTo(rangingLabel)
            make.height.equalTo(MKFont.font(12).lineHeight)
        }
        accelerationLabel.snp.remakeConstraints { make in
            make.left.equalTo(msgLabel)
            make.right.equalTo(contentView.snp.centerX).offset(-5)
            make.top.equalTo(rangingValueLabel.snp.bottom).offset(5)
            make.height.equalTo(MKFont.font(12).lineHeight)
        }
        xDataLabel.snp.remakeConstraints { make in
            make.left.equalTo(contentView.snp.centerX).offset(5)
            make.right.equalTo(-10)
            make.centerY.equalTo(accelerationLabel)
            make.height.equalTo(MKFont.font(12).lineHeight)
        }
        yDataLabel.snp.remakeConstraints { make in
            make.left.equalTo(contentView.snp.centerX).offset(5)
            make.right.equalTo(-10)
            make.top.equalTo(xDataLabel.snp.bottom).offset(5)
            make.height.equalTo(MKFont.font(12).lineHeight)
        }
        zDataLabel.snp.remakeConstraints { make in
            make.left.equalTo(contentView.snp.centerX).offset(5)
            make.right.equalTo(-10)
            make.top.equalTo(yDataLabel.snp.bottom).offset(5)
            make.height.equalTo(MKFont.font(12).lineHeight)
        }
    }

    // MARK: - Configure

    private func configure(with model: MKBXDScanDeviceInfoCellModel) {
        rangingValueLabel.text = model.rangingData

        var hidden = false
        if model.xData == "0mg" && model.yData == "0mg" && model.zData == "0mg" {
            hidden = true
        }
        xDataLabel.isHidden = hidden
        yDataLabel.isHidden = hidden
        zDataLabel.isHidden = hidden
        accelerationLabel.isHidden = hidden

        xDataLabel.text = "X: " + model.xData
        yDataLabel.text = "Y: " + model.yData
        zDataLabel.text = "Z: " + model.zData
    }

    // MARK: - Helper

    private func createLabel() -> UILabel {
        let label = UILabel()
        label.textColor = UIColor(red: 184/255.0, green: 184/255.0, blue: 184/255.0, alpha: 1)
        label.textAlignment = .left
        label.font = MKFont.font(12)
        return label
    }

    // MARK: - Static

    public static func initCellWithTableView(_ tableView: UITableView) -> MKBXDScanDeviceInfoCell {
        let identy = "MKBXDScanDeviceInfoCellIdenty"
        if let cell = tableView.dequeueReusableCell(withIdentifier: identy) as? MKBXDScanDeviceInfoCell {
            return cell
        }
        return MKBXDScanDeviceInfoCell(style: .default, reuseIdentifier: identy)
    }
}
