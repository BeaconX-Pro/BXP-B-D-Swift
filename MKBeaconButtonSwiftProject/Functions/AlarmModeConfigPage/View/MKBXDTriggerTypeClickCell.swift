//
//  MKBXDTriggerTypeClickCell.swift
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

public final class MKBXDTriggerTypeClickCellModel: NSObject {
    public var selected: Bool = false
}

// MARK: - Delegate

public protocol MKBXDTriggerTypeClickCellDelegate: AnyObject {
    func bxd_triggerTypeClickCell_pressed(_ selected: Bool)
}

// MARK: - Cell

public final class MKBXDTriggerTypeClickCell: MKSwiftBaseCell {

    public weak var delegate: MKBXDTriggerTypeClickCellDelegate?

    public var dataModel: MKBXDTriggerTypeClickCellModel? {
        didSet {
            guard let model = dataModel else { return }
            backButton.isSelected = model.selected
            rightIcon.transform = backButton.isSelected
                ? CGAffineTransform(rotationAngle: .pi / 2)
                : .identity
        }
    }

    private lazy var backButton: UIControl = {
        let btn = UIControl()
        btn.addTarget(self, action: #selector(backButtonPressed), for: .touchUpInside)
        return btn
    }()

    private lazy var msgLabel: UILabel = {
        let label = UILabel()
        label.textColor = MKColor.defaultText
        label.font = MKFont.font(15)
        label.textAlignment = .left
        label.text = "Trigger notification type"
        return label
    }()

    private lazy var rightIcon: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "bxd_goNextButton.png")
        return iv
    }()

    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(backButton)
        backButton.addSubview(msgLabel)
        backButton.addSubview(rightIcon)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        backButton.snp.makeConstraints { make in
            make.edges.equalTo(contentView)
        }
        msgLabel.snp.makeConstraints { make in
            make.left.equalTo(15)
            make.right.equalTo(rightIcon.snp.right).offset(-5)
            make.centerY.equalTo(contentView)
            make.height.equalTo(MKFont.font(15).lineHeight)
        }
        rightIcon.snp.makeConstraints { make in
            make.width.equalTo(8)
            make.right.equalTo(-15)
            make.centerY.equalTo(contentView)
            make.height.equalTo(14)
        }
    }

    @objc private func backButtonPressed() {
        backButton.isSelected.toggle()
        rightIcon.transform = backButton.isSelected
            ? CGAffineTransform(rotationAngle: .pi / 2)
            : .identity
        delegate?.bxd_triggerTypeClickCell_pressed(backButton.isSelected)
    }

    public static func initCellWithTableView(_ tableView: UITableView) -> MKBXDTriggerTypeClickCell {
        let identy = "MKBXDTriggerTypeClickCellIdenty"
        if let cell = tableView.dequeueReusableCell(withIdentifier: identy) as? MKBXDTriggerTypeClickCell {
            return cell
        }
        return MKBXDTriggerTypeClickCell(style: .default, reuseIdentifier: identy)
    }
}
