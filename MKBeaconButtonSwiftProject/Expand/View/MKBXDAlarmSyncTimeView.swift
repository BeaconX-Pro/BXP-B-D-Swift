//
//  MKBXDAlarmSyncTimeView.swift
//  MKBeaconXDButton
//
//  Created by aa on 2026/9/17.
//  Copyright © 2026 aadyx2007@163.com. All rights reserved.
//

import UIKit

import SnapKit

import MKBaseSwiftModule
import MKSwiftCustomUI

public protocol MKBXDAlarmSyncTimeViewDelegate: AnyObject {
    func bxd_alarmSyncTimeButtonPressed()
}

public final class MKBXDAlarmSyncTimeView: UIView {

    public weak var delegate: MKBXDAlarmSyncTimeViewDelegate?

    // MARK: - Subviews

    private lazy var msgLabel: UILabel = {
        let label = UILabel()
        label.textColor = MKColor.defaultText
        label.textAlignment = .left
        label.font = MKFont.font(15)
        label.text = "Sync standard UTC time"
        label.numberOfLines = 0
        return label
    }()

    private lazy var syncButton: UIButton = {
        return MKSwiftUIAdaptor.createRoundedButton(title: "Sync",
                                                    target: self,
                                                    action: #selector(syncButtonPressed))
    }()

    private lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = MKColor.defaultText
        label.font = MKFont.font(15)
        return label
    }()

    // MARK: - Init

    public override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        addSubview(msgLabel)
        addSubview(syncButton)
        addSubview(timeLabel)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Layout

    public override func layoutSubviews() {
        super.layoutSubviews()
        syncButton.snp.makeConstraints { make in
            make.right.equalTo(-15)
            make.width.equalTo(45)
            make.top.equalTo(10)
            make.height.equalTo(30)
        }
        let msgSize = (msgLabel.text ?? "").size(withFont: msgLabel.font,
                                                 maxSize: CGSize(width: MKScreen.width - 3 * 15 - 45, height: .greatestFiniteMagnitude))
        msgLabel.snp.makeConstraints { make in
            make.left.equalTo(15)
            make.right.equalTo(syncButton.snp.left).offset(-15)
            make.centerY.equalTo(syncButton)
            make.height.equalTo(msgSize.height)
        }
        timeLabel.snp.makeConstraints { make in
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.bottom.equalTo(-20)
            make.height.equalTo(MKFont.font(15).lineHeight)
        }
    }

    // MARK: - Actions

    @objc private func syncButtonPressed() {
        delegate?.bxd_alarmSyncTimeButtonPressed()
    }

    // MARK: - Public

    public func updateTimestamp(_ timestamp: String) {
        timeLabel.text = timestamp
    }
}
