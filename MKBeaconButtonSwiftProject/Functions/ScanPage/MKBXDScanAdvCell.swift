//
//  MKBXDScanAdvCell.swift
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

public final class MKBXDScanAdvCellModel: NSObject {
    /// 0:Single 1:Double 2:Long 3:Abnormal inactivity
    public var alarmMode: Int = 0

    /// version = 0/1 0:Standby 1:Trigger
    /// version = 2 0:Standby 1:Main-Triggered 2:Sub-Triggered
    public var triggerStatus: Int = 0

    public var triggerCount: String = ""

    /// Only used for version is V2(Double button)
    public var motionStatus: Bool = false

    /// 0: V1 1: Long connection 2:V2(Double button)
    public var version: Int = 0
}

// MARK: - Cell

public final class MKBXDScanAdvCell: MKSwiftBaseCell {

    public var dataModel: MKBXDScanAdvCellModel? {
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
        return label
    }()

    private lazy var triggerStatusLabel: UILabel = {
        let label = createLabel()
        label.text = "Trigger status"
        return label
    }()

    private lazy var triggerStatusValueLabel: UILabel = {
        let label = createLabel()
        return label
    }()

    private lazy var triggerCountLabel: UILabel = {
        let label = createLabel()
        label.text = "Trigger count"
        return label
    }()

    private lazy var triggerCountValueLabel: UILabel = {
        let label = createLabel()
        return label
    }()

    private lazy var motionStatusLabel: UILabel = {
        let label = createLabel()
        label.text = "Motion status"
        return label
    }()

    private lazy var motionStatusValueLabel: UILabel = {
        let label = createLabel()
        return label
    }()

    // MARK: - Init

    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(leftIcon)
        contentView.addSubview(msgLabel)
        contentView.addSubview(triggerStatusLabel)
        contentView.addSubview(triggerStatusValueLabel)
        contentView.addSubview(triggerCountLabel)
        contentView.addSubview(triggerCountValueLabel)
        contentView.addSubview(motionStatusLabel)
        contentView.addSubview(motionStatusValueLabel)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Layout

    public override func layoutSubviews() {
        super.layoutSubviews()
        leftIcon.snp.makeConstraints { make in
            make.left.equalTo(10)
            make.width.height.equalTo(7)
            make.top.equalTo(10)
        }
        msgLabel.snp.makeConstraints { make in
            make.left.equalTo(leftIcon.snp.right).offset(5)
            make.right.equalTo(-10)
            make.centerY.equalTo(leftIcon)
            make.height.equalTo(MKFont.font(15).lineHeight)
        }
        triggerStatusLabel.snp.makeConstraints { make in
            make.left.equalTo(msgLabel)
            make.right.equalTo(contentView.snp.centerX).offset(-5)
            make.top.equalTo(msgLabel.snp.bottom).offset(5)
            make.height.equalTo(MKFont.font(12).lineHeight)
        }
        triggerStatusValueLabel.snp.makeConstraints { make in
            make.left.equalTo(contentView.snp.centerX).offset(5)
            make.right.equalTo(-10)
            make.centerY.equalTo(triggerStatusLabel)
            make.height.equalTo(MKFont.font(12).lineHeight)
        }
    }

    // MARK: - Configure

    private func configure(with model: MKBXDScanAdvCellModel) {
        switch model.alarmMode {
        case 0: msgLabel.text = "Single press alarm mode"
        case 1: msgLabel.text = "Double press alarm mode"
        case 2: msgLabel.text = "Long press alarm mode"
        case 3: msgLabel.text = "Abnormal inactivity mode"
        default: break
        }

        if model.triggerStatus == 0 {
            triggerStatusValueLabel.text = "Standby"
        } else {
            if model.version == 2 {
                if model.triggerStatus == 1 {
                    triggerStatusValueLabel.text = "Main-Triggered"
                } else if model.triggerStatus == 2 {
                    triggerStatusValueLabel.text = "Sub-Triggered"
                }
            } else {
                triggerStatusValueLabel.text = "Triggered"
            }
        }
        triggerCountValueLabel.text = model.triggerCount
        motionStatusValueLabel.text = model.motionStatus ? "Moving" : "Stationary"

        // 移除 triggerCount / motionStatus 相关 view
        triggerCountValueLabel.removeFromSuperview()
        triggerCountLabel.removeFromSuperview()
        motionStatusValueLabel.removeFromSuperview()
        motionStatusLabel.removeFromSuperview()

        if model.alarmMode != 3 {
            contentView.addSubview(triggerCountLabel)
            contentView.addSubview(triggerCountValueLabel)
            triggerCountLabel.snp.makeConstraints { make in
                make.left.equalTo(msgLabel)
                make.right.equalTo(contentView.snp.centerX).offset(-5)
                make.top.equalTo(triggerStatusLabel.snp.bottom).offset(5)
                make.height.equalTo(MKFont.font(12).lineHeight)
            }
            triggerCountValueLabel.snp.makeConstraints { make in
                make.left.equalTo(contentView.snp.centerX).offset(5)
                make.right.equalTo(-10)
                make.centerY.equalTo(triggerCountLabel)
                make.height.equalTo(MKFont.font(12).lineHeight)
            }
            if model.version == 2 {
                contentView.addSubview(motionStatusLabel)
                contentView.addSubview(motionStatusValueLabel)
                motionStatusLabel.snp.makeConstraints { make in
                    make.left.equalTo(msgLabel)
                    make.right.equalTo(contentView.snp.centerX).offset(-5)
                    make.top.equalTo(triggerCountLabel.snp.bottom).offset(5)
                    make.height.equalTo(MKFont.font(12).lineHeight)
                }
                motionStatusValueLabel.snp.makeConstraints { make in
                    make.left.equalTo(contentView.snp.centerX).offset(5)
                    make.right.equalTo(-10)
                    make.centerY.equalTo(motionStatusLabel)
                    make.height.equalTo(MKFont.font(12).lineHeight)
                }
            }
        } else {
            if model.version == 2 {
                contentView.addSubview(motionStatusLabel)
                contentView.addSubview(motionStatusValueLabel)
                motionStatusLabel.snp.makeConstraints { make in
                    make.left.equalTo(msgLabel)
                    make.right.equalTo(contentView.snp.centerX).offset(-5)
                    make.top.equalTo(triggerStatusLabel.snp.bottom).offset(5)
                    make.height.equalTo(MKFont.font(12).lineHeight)
                }
                motionStatusValueLabel.snp.makeConstraints { make in
                    make.left.equalTo(contentView.snp.centerX).offset(5)
                    make.right.equalTo(-10)
                    make.centerY.equalTo(motionStatusLabel)
                    make.height.equalTo(MKFont.font(12).lineHeight)
                }
            }
        }
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

    public static func initCellWithTableView(_ tableView: UITableView) -> MKBXDScanAdvCell {
        let identy = "MKBXDScanAdvCellIdenty"
        if let cell = tableView.dequeueReusableCell(withIdentifier: identy) as? MKBXDScanAdvCell {
            return cell
        }
        return MKBXDScanAdvCell(style: .default, reuseIdentifier: identy)
    }
}
