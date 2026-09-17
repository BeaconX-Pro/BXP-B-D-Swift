//
//  MKBXDTxPowerCell.swift
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

public final class MKBXDTxPowerCellModel: NSObject {
    public var index: Int = 0
    /// 0:-40dBm 1:-20dBm 2:-16dBm 3:-12dBm 4:-8dBm 5:-4dBm 6:0dBm 7:+3dBm 8:+4dBm
    public var txPower: Int = 0
}

// MARK: - Delegate

public protocol MKBXDTxPowerCellDelegate: AnyObject {
    func bxd_txPowerChanged(_ index: Int, txPower: Int)
}

// MARK: - Cell

public final class MKBXDTxPowerCell: MKSwiftBaseCell {

    public weak var delegate: MKBXDTxPowerCellDelegate?

    public var dataModel: MKBXDTxPowerCellModel? {
        didSet {
            guard let model = dataModel else { return }
            txPowerSlider.value = Float(model.txPower)
            txPowerValueLabel.text = txPowerValueText(Float(model.txPower))
        }
    }

    private lazy var txPowerMsgLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.attributedText = MKSwiftUIAdaptor.createAttributedString(strings:
            ["Tx Power", "   (-40,-20,-16,-12,-8,-4,0,+3,+4)"],
            fonts: [MKFont.font(15), MKFont.font(13)],
            colors: [MKColor.defaultText, UIColor(red: 223/255.0, green: 223/255.0, blue: 223/255.0, alpha: 1)]
        )
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
        label.text = "-12dBm"
        return label
    }()

    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(txPowerMsgLabel)
        contentView.addSubview(txPowerSlider)
        contentView.addSubview(txPowerValueLabel)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        txPowerMsgLabel.snp.makeConstraints { make in
            make.left.equalTo(15)
            make.top.equalTo(5)
            make.right.equalTo(-15)
            make.height.equalTo(MKFont.font(15).lineHeight)
        }
        txPowerSlider.snp.makeConstraints { make in
            make.left.equalTo(15)
            make.right.equalTo(txPowerValueLabel.snp.left).offset(-5)
            make.top.equalTo(txPowerMsgLabel.snp.bottom).offset(5)
            make.height.equalTo(10)
        }
        txPowerValueLabel.snp.makeConstraints { make in
            make.right.equalTo(-15)
            make.width.equalTo(60)
            make.centerY.equalTo(txPowerSlider)
            make.height.equalTo(MKFont.font(12).lineHeight)
        }
    }

    @objc private func txPowerSliderValueChanged() {
        let value = txPowerSlider.value
        txPowerValueLabel.text = txPowerValueText(value)
        delegate?.bxd_txPowerChanged(dataModel?.index ?? 0, txPower: Int(value))
    }

    private func txPowerValueText(_ sliderValue: Float) -> String {
        if sliderValue >= 0 && sliderValue < 1 { return "-40dBm" }
        if sliderValue >= 1 && sliderValue < 2 { return "-20dBm" }
        if sliderValue >= 2 && sliderValue < 3 { return "-16dBm" }
        if sliderValue >= 3 && sliderValue < 4 { return "-12dBm" }
        if sliderValue >= 4 && sliderValue < 5 { return "-8dBm" }
        if sliderValue >= 5 && sliderValue < 6 { return "-4dBm" }
        if sliderValue >= 6 && sliderValue < 7 { return "0dBm" }
        if sliderValue >= 7 && sliderValue < 8 { return "3dBm" }
        return "4dBm"
    }

    public static func initCellWithTableView(_ tableView: UITableView) -> MKBXDTxPowerCell {
        let identy = "MKBXDTxPowerCellIdenty"
        if let cell = tableView.dequeueReusableCell(withIdentifier: identy) as? MKBXDTxPowerCell {
            return cell
        }
        return MKBXDTxPowerCell(style: .default, reuseIdentifier: identy)
    }
}
