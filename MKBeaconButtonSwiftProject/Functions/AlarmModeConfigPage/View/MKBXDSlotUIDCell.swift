//
//  MKBXDSlotUIDCell.swift
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

public final class MKBXDSlotUIDCellModel: NSObject {
    /// Namespace ID，10 bytes（20 个十六进制字符）
    public var namespaceID: String = ""
    /// Instance ID，6 bytes（12 个十六进制字符）
    public var instanceID: String = ""
}

// MARK: - Delegate

public protocol MKBXDSlotUIDCellDelegate: AnyObject {
    func bxd_advContent_namespaceIDChanged(_ namespaceID: String)
    func bxd_advContent_instanceIDChanged(_ instanceID: String)
}

// MARK: - Cell

public final class MKBXDSlotUIDCell: MKSwiftBaseCell {

    public weak var delegate: MKBXDSlotUIDCellDelegate?

    public var dataModel: MKBXDSlotUIDCellModel? {
        didSet {
            guard let model = dataModel else { return }
            namespaceTextField.text = model.namespaceID
            instanceTextField.text = model.instanceID
        }
    }

    private lazy var backView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 8
        return view
    }()

    private lazy var leftIcon: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "bxd_slotAdvContent.png")
        return iv
    }()

    private lazy var typeLabel: UILabel = {
        let label = UILabel()
        label.textColor = MKColor.defaultText
        label.textAlignment = .left
        label.font = MKFont.font(15)
        label.text = "Adv content"
        return label
    }()

    private lazy var namespaceLabel: UILabel = {
        let label = UILabel()
        label.textColor = MKColor.defaultText
        label.textAlignment = .left
        label.font = MKFont.font(15)
        label.text = "Namespace ID"
        return label
    }()

    private lazy var namespaceHexLabel: UILabel = {
        let label = UILabel()
        label.textColor = MKColor.defaultText
        label.font = MKFont.font(12)
        label.textAlignment = .right
        label.text = "0x"
        return label
    }()

    private lazy var namespaceTextField: MKSwiftTextField = {
        let tf = MKSwiftUIAdaptor.createTextField(text: "",
                                                        placeholder: "10bytes",
                                                        textType: .hexCharOnly)
        tf.maxLength = 20
        tf.textChangedBlock = { [weak self] text in
            self?.delegate?.bxd_advContent_namespaceIDChanged(text)
        }
        return tf
    }()

    private lazy var instanceLabel: UILabel = {
        let label = UILabel()
        label.textColor = MKColor.defaultText
        label.textAlignment = .left
        label.font = MKFont.font(15)
        label.text = "Instance ID"
        return label
    }()

    private lazy var instanceHexLabel: UILabel = {
        let label = UILabel()
        label.textColor = MKColor.defaultText
        label.font = MKFont.font(12)
        label.textAlignment = .right
        label.text = "0x"
        return label
    }()

    private lazy var instanceTextField: MKSwiftTextField = {
        let tf = MKSwiftUIAdaptor.createTextField(text: "",
                                                        placeholder: "6bytes",
                                                        textType: .hexCharOnly)
        tf.maxLength = 12
        tf.textChangedBlock = { [weak self] text in
            self?.delegate?.bxd_advContent_instanceIDChanged(text)
        }
        return tf
    }()

    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(backView)
        backView.addSubview(leftIcon)
        backView.addSubview(typeLabel)
        backView.addSubview(namespaceLabel)
        backView.addSubview(namespaceHexLabel)
        backView.addSubview(namespaceTextField)
        backView.addSubview(instanceLabel)
        backView.addSubview(instanceHexLabel)
        backView.addSubview(instanceTextField)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        backView.snp.remakeConstraints { make in
            make.edges.equalToSuperview()
        }
        leftIcon.snp.remakeConstraints { make in
            make.left.equalTo(15)
            make.width.height.equalTo(22)
            make.top.equalTo(10)
        }
        typeLabel.snp.remakeConstraints { make in
            make.left.equalTo(leftIcon.snp.right).offset(15)
            make.right.equalTo(-15)
            make.centerY.equalTo(leftIcon)
            make.height.equalTo(MKFont.font(15).lineHeight)
        }
        namespaceLabel.snp.remakeConstraints { make in
            make.left.equalTo(15)
            make.width.equalTo(120)
            make.centerY.equalTo(namespaceTextField)
            make.height.equalTo(MKFont.font(15).lineHeight)
        }
        namespaceHexLabel.snp.remakeConstraints { make in
            make.right.equalTo(namespaceTextField.snp.left).offset(-2)
            make.width.equalTo(30)
            make.centerY.equalTo(namespaceTextField)
            make.height.equalTo(MKFont.font(12).lineHeight)
        }
        namespaceTextField.snp.remakeConstraints { make in
            make.left.equalTo(namespaceLabel.snp.right).offset(5)
            make.right.equalTo(-15)
            make.top.equalTo(leftIcon.snp.bottom).offset(10)
            make.height.equalTo(30)
        }
        instanceLabel.snp.remakeConstraints { make in
            make.left.equalTo(15)
            make.width.equalTo(120)
            make.centerY.equalTo(instanceTextField)
            make.height.equalTo(MKFont.font(15).lineHeight)
        }
        instanceHexLabel.snp.remakeConstraints { make in
            make.right.equalTo(instanceTextField.snp.left).offset(-2)
            make.width.equalTo(30)
            make.centerY.equalTo(instanceTextField)
            make.height.equalTo(MKFont.font(12).lineHeight)
        }
        instanceTextField.snp.remakeConstraints { make in
            make.left.equalTo(instanceLabel.snp.right).offset(5)
            make.right.equalTo(-15)
            make.top.equalTo(namespaceTextField.snp.bottom).offset(10)
            make.height.equalTo(30)
        }
    }

    public static func initCellWithTableView(_ tableView: UITableView) -> MKBXDSlotUIDCell {
        let identy = "MKBXDSlotUIDCellIdenty"
        if let cell = tableView.dequeueReusableCell(withIdentifier: identy) as? MKBXDSlotUIDCell {
            return cell
        }
        return MKBXDSlotUIDCell(style: .default, reuseIdentifier: identy)
    }
}
