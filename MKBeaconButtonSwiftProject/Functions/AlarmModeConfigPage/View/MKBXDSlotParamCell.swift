//
//  MKBXDSlotParamCell.swift
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

public final class MKBXDSlotParamCellModel: NSObject {
    public var cellType: MKBXDSlotType = .alarmInfo
    public var interval: String = ""
    public var rssi: Int = 0
    /// 0:-40dBm 1:-20dBm 2:-16dBm 3:-12dBm 4:-8dBm 5:-4dBm 6:0dBm 7:+3dBm 8:+4dBm
    public var txPower: Int = 0
}

// MARK: - Delegate

public protocol MKBXDSlotParamCellDelegate: AnyObject {
    func bxd_slotParam_advIntervalChanged(_ interval: String)
    func bxd_slotParam_rssiChanged(_ rssi: Int)
    func bxd_slotParam_txPowerChanged(_ txPower: Int)
}

// MARK: - Cell

public final class MKBXDSlotParamCell: MKSwiftBaseCell {

    public weak var delegate: MKBXDSlotParamCellDelegate?

    public var dataModel: MKBXDSlotParamCellModel? {
        didSet {
            guard let model = dataModel else { return }
            // 先清空 backView 的子视图
            backView.subviews.forEach { $0.removeFromSuperview() }
            if backView.superview != nil {
                backView.removeFromSuperview()
            }
            contentView.addSubview(backView)
            backView.snp.remakeConstraints { make in
                make.edges.equalToSuperview()
            }

            setupTxPowerParams()
            addNormalSubViews()
            setupTopViews()
            setupNormalSliderUI()

            intervalField.text = model.interval
            rssiSlider.value = Float(model.rssi)
            var value = String(format: "%.f", rssiSlider.value)
            if value == "-0" { value = "0" }
            rssiValueLabel.text = value + "dBm"
            txPowerSlider.value = Float(model.txPower)
            txPowerValueLabel.text = txPowerValueText(model.txPower)
            updateRssiMsg()
        }
    }

    // MARK: - Subviews

    private lazy var backView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 8
        return view
    }()

    private lazy var leftIcon: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "bxd_slot_baseParams.png")   // ⚠️ 按工程图标 API 调整
        return iv
    }()

    private lazy var msgLabel: UILabel = {
        let label = UILabel()
        label.textColor = MKColor.defaultText
        label.textAlignment = .left
        label.font = MKFont.font(15)
        label.text = "Parameters"
        return label
    }()

    private lazy var intervalLabel: UILabel = {
        return loadLabel(withMsg: "Adv interval")
    }()

    private lazy var intervalField: MKSwiftTextField = {
        let tf = MKSwiftUIAdaptor.createTextField(text: "",
                                                        placeholder: "1~100",
                                                        textType: .realNumberOnly)
        tf.font = MKFont.font(12)
        tf.maxLength = 3
        tf.textChangedBlock = { [weak self] text in
            self?.delegate?.bxd_slotParam_advIntervalChanged(text)
        }
        return tf
    }()

    private lazy var intervalUnitLabel: UILabel = {
        return loadLabel(withMsg: "x20ms")
    }()

    private lazy var rssiLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        return label
    }()

    private lazy var rssiSlider: UISlider = {
        let slider = UISlider()
        slider.maximumValue = 0
        slider.minimumValue = -100
        slider.addTarget(self, action: #selector(rssiSliderValueChanged), for: .valueChanged)
        return slider
    }()

    private lazy var rssiValueLabel: UILabel = {
        let label = UILabel()
        label.textColor = MKColor.defaultText
        label.textAlignment = .left
        label.font = MKFont.font(11)
        return label
    }()

    private lazy var txPowerLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        return label
    }()

    private lazy var txPowerSlider: UISlider = {
        let slider = UISlider()
        slider.maximumValue = 8
        slider.minimumValue = 0
        slider.value = 0
        slider.addTarget(self, action: #selector(txPowerSliderValueChanged), for: .valueChanged)
        return slider
    }()

    private lazy var txPowerValueLabel: UILabel = {
        let label = UILabel()
        label.textColor = MKColor.defaultText
        label.textAlignment = .left
        label.font = MKFont.font(11)
        return label
    }()

    // MARK: - Init

    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Actions

    @objc private func rssiSliderValueChanged() {
        var value = String(format: "%.f", rssiSlider.value)
        if value == "-0" { value = "0" }
        rssiValueLabel.text = value + "dBm"
        delegate?.bxd_slotParam_rssiChanged(Int(value) ?? 0)
    }

    @objc private func txPowerSliderValueChanged() {
        let value = Int(txPowerSlider.value)
        txPowerValueLabel.text = txPowerValueText(value)
        delegate?.bxd_slotParam_txPowerChanged(value)
    }

    // MARK: - Private: Setup

    private func setupTxPowerParams() {
        txPowerLabel.attributedText = MKSwiftUIAdaptor.createAttributedString(strings:
            ["Tx power", "   (-40,-20,-16,-12,-8,-4,0,+3,+4)"],
            fonts: [MKFont.font(13), MKFont.font(12)],
            colors: [MKColor.defaultText, UIColor(red: 223/255.0, green: 223/255.0, blue: 223/255.0, alpha: 1)]
        )
        txPowerSlider.maximumValue = 8
        txPowerSlider.minimumValue = 0
    }

    private func addNormalSubViews() {
        backView.addSubview(leftIcon)
        backView.addSubview(msgLabel)
        backView.addSubview(intervalLabel)
        backView.addSubview(intervalField)
        backView.addSubview(intervalUnitLabel)
        backView.addSubview(rssiLabel)
        backView.addSubview(rssiSlider)
        backView.addSubview(rssiValueLabel)
        backView.addSubview(txPowerLabel)
        backView.addSubview(txPowerSlider)
        backView.addSubview(txPowerValueLabel)
    }

    private func setupTopViews() {
        leftIcon.snp.remakeConstraints { make in
            make.left.equalTo(15)
            make.width.height.equalTo(22)
            make.top.equalTo(10)
        }
        msgLabel.snp.remakeConstraints { make in
            make.left.equalTo(leftIcon.snp.right).offset(15)
            make.right.equalTo(-15)
            make.centerY.equalTo(leftIcon)
            make.height.equalTo(MKFont.font(15).lineHeight)
        }
        intervalUnitLabel.snp.remakeConstraints { make in
            make.right.equalTo(-15)
            make.width.equalTo(50)
            make.centerY.equalTo(intervalField)
            make.height.equalTo(MKFont.font(12).lineHeight)
        }
        intervalField.snp.remakeConstraints { make in
            make.right.equalTo(intervalUnitLabel.snp.left).offset(-5)
            make.width.equalTo(60)
            make.top.equalTo(leftIcon.snp.bottom).offset(10)
            make.height.equalTo(25)
        }
        intervalLabel.snp.remakeConstraints { make in
            make.left.equalTo(leftIcon)
            make.right.equalTo(intervalField.snp.left).offset(-10)
            make.centerY.equalTo(intervalField)
            make.height.equalTo(MKFont.font(12).lineHeight)
        }
    }

    private func setupNormalSliderUI() {
        rssiLabel.snp.remakeConstraints { make in
            make.left.equalTo(15)
            make.top.equalTo(intervalField.snp.bottom).offset(15)
            make.right.equalTo(-15)
            make.height.equalTo(MKFont.font(15).lineHeight)
        }
        rssiSlider.snp.remakeConstraints { make in
            make.left.equalTo(15)
            make.right.equalTo(rssiValueLabel.snp.left).offset(-5)
            make.top.equalTo(rssiLabel.snp.bottom).offset(5)
            make.height.equalTo(10)
        }
        rssiValueLabel.snp.remakeConstraints { make in
            make.right.equalTo(-15)
            make.width.equalTo(60)
            make.centerY.equalTo(rssiSlider)
            make.height.equalTo(MKFont.font(12).lineHeight)
        }
        txPowerLabel.snp.remakeConstraints { make in
            make.left.equalTo(15)
            make.top.equalTo(rssiSlider.snp.bottom).offset(15)
            make.right.equalTo(-15)
            make.height.equalTo(MKFont.font(15).lineHeight)
        }
        txPowerSlider.snp.remakeConstraints { make in
            make.left.equalTo(15)
            make.right.equalTo(txPowerValueLabel.snp.left).offset(-5)
            make.top.equalTo(txPowerLabel.snp.bottom).offset(5)
            make.height.equalTo(10)
        }
        txPowerValueLabel.snp.remakeConstraints { make in
            make.right.equalTo(-15)
            make.width.equalTo(60)
            make.centerY.equalTo(txPowerSlider)
            make.height.equalTo(MKFont.font(12).lineHeight)
        }
    }

    // MARK: - Private: Helpers

    private func txPowerValueText(_ value: Int) -> String {
        switch value {
        case 0: return "-40dBm"
        case 1: return "-20dBm"
        case 2: return "-16dBm"
        case 3: return "-12dBm"
        case 4: return "-8dBm"
        case 5: return "-4dBm"
        case 6: return "0dBm"
        case 7: return "3dBm"
        case 8: return "4dBm"
        default: return "4dBm"
        }
    }

    private func updateRssiMsg() {
        let colors: [UIColor] = [MKColor.defaultText, UIColor(red: 223/255.0, green: 223/255.0, blue: 223/255.0, alpha: 1)]
        let fonts: [UIFont] = [MKFont.font(13), MKFont.font(12)]
        switch dataModel?.cellType ?? .alarmInfo {
        case .uid:
            rssiLabel.attributedText = MKSwiftUIAdaptor.createAttributedString(strings:
                ["RSSI@0m", "   (-100dBm ~ 0dBm)"],
                fonts: fonts, colors: colors)
        case .beacon:
            rssiLabel.attributedText = MKSwiftUIAdaptor.createAttributedString(strings:
                ["RSSI@1m", "   (-100dBm ~ 0dBm)"],
                fonts: fonts, colors: colors)
        case .alarmInfo:
            rssiLabel.attributedText = MKSwiftUIAdaptor.createAttributedString(strings:
                ["Ranging data", "   (-100dBm ~ 0dBm)"],
                fonts: fonts, colors: colors)
        }
    }

    private func loadLabel(withMsg msg: String) -> UILabel {
        let label = UILabel()
        label.textColor = MKColor.defaultText
        label.textAlignment = .left
        label.font = MKFont.font(12)
        label.text = msg
        return label
    }

    public static func initCellWithTableView(_ tableView: UITableView) -> MKBXDSlotParamCell {
        let identy = "MKBXDSlotParamCellIdenty"
        if let cell = tableView.dequeueReusableCell(withIdentifier: identy) as? MKBXDSlotParamCell {
            return cell
        }
        return MKBXDSlotParamCell(style: .default, reuseIdentifier: identy)
    }
}
