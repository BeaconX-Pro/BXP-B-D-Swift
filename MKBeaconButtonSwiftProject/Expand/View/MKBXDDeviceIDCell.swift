//
//  MKBXDDeviceIDCell.swift
//  MKBeaconXDButton
//
//  Created by aa on 2026/9/17.
//  Copyright © 2026 aadyx2007@163.com. All rights reserved.
//

import UIKit

import SnapKit

import MKBaseSwiftModule
import MKSwiftCustomUI

// MARK: - Model

public final class MKBXDDeviceIDCellModel: NSObject {
    public var deviceID: String = ""
}

// MARK: - Delegate

public protocol MKBXDDeviceIDCellDelegate: AnyObject {
    func bxd_deviceIDChanged(_ text: String)
}

// MARK: - Cell

public final class MKBXDDeviceIDCell: MKSwiftBaseCell {

    public weak var delegate: MKBXDDeviceIDCellDelegate?

    public var dataModel: MKBXDDeviceIDCellModel? {
        didSet {
            textField.text = dataModel?.deviceID ?? ""
        }
    }

    private lazy var msgLabel: UILabel = {
        let label = UILabel()
        label.textColor = MKColor.defaultText
        label.font = MKFont.font(15)
        label.textAlignment = .left
        label.text = "Device ID"
        return label
    }()

    private lazy var oxLabel: UILabel = {
        let label = UILabel()
        label.textColor = MKColor.defaultText
        label.font = MKFont.font(15)
        label.textAlignment = .left
        label.text = "0x"
        return label
    }()

    private lazy var textField: MKSwiftTextField = {
        // ⚠️ 按工程实际 MKSwiftTextField 接口调整
        let tf = MKSwiftUIAdaptor.createNormalTextField(text: "",
                                                        placeHolder: "1-6 bytes",
                                                        textType: .hexCharOnly)
        tf.maxLength = 12
        tf.textChangedBlock = { [weak self] text in
            guard let self = self else { return }
            self.delegate?.bxd_deviceIDChanged(text)
        }
        return tf
    }()

    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(msgLabel)
        contentView.addSubview(oxLabel)
        contentView.addSubview(textField)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        msgLabel.snp.makeConstraints { make in
            make.left.equalTo(15)
            make.width.equalTo(150)
            make.centerY.equalTo(contentView)
            make.height.equalTo(MKFont.font(15).lineHeight)
        }
        oxLabel.snp.makeConstraints { make in
            make.left.equalTo(msgLabel.snp.right).offset(5)
            make.width.equalTo(20)
            make.centerY.equalTo(contentView)
            make.height.equalTo(MKFont.font(11).lineHeight)
        }
        textField.snp.makeConstraints { make in
            make.left.equalTo(oxLabel.snp.right).offset(5)
            make.right.equalTo(-15)
            make.centerY.equalTo(contentView)
            make.height.equalTo(30)
        }
    }

    public static func initCellWithTableView(_ tableView: UITableView) -> MKBXDDeviceIDCell {
        let identy = "MKBXDDeviceIDCellIdenty"
        if let cell = tableView.dequeueReusableCell(withIdentifier: identy) as? MKBXDDeviceIDCell {
            return cell
        }
        return MKBXDDeviceIDCell(style: .default, reuseIdentifier: identy)
    }
}
