//
//  MKBXDAccelerationHeaderView.swift
//  MKBeaconButtonSwiftProject
//
//  Created by aa on 2026/9/17.
//  Copyright © 2026 aadyx2007@163.com. All rights reserved.
//

import UIKit

import SnapKit

import MKBaseSwiftModule
import MKSwiftCustomUI

public protocol MKBXDAccelerationHeaderViewDelegate: AnyObject {
    func bxd_updateThreeAxisNotifyStatus(_ notify: Bool)
}

public final class MKBXDAccelerationHeaderView: UIView {

    public weak var delegate: MKBXDAccelerationHeaderViewDelegate?

    private lazy var syncButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.addTarget(self, action: #selector(syncButtonPressed), for: .touchUpInside)
        return btn
    }()

    private lazy var synIcon: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "bxd_threeAxisAcceLoadingIcon.png")
        return iv
    }()

    private lazy var syncLabel: UILabel = {
        let label = UILabel()
        label.textColor = MKColor.defaultText
        label.textAlignment = .center
        label.font = MKFont.font(10)
        label.text = "Sync"
        return label
    }()

    private lazy var xDataLabel: UILabel = {
        let label = UILabel()
        label.textColor = MKColor.defaultText
        label.textAlignment = .center
        label.font = MKFont.font(12)
        label.text = "X-axis:N/A"
        return label
    }()

    private lazy var yDataLabel: UILabel = {
        let label = UILabel()
        label.textColor = MKColor.defaultText
        label.textAlignment = .center
        label.font = MKFont.font(12)
        label.text = "Y-axis:N/A"
        return label
    }()

    private lazy var zDataLabel: UILabel = {
        let label = UILabel()
        label.textColor = MKColor.defaultText
        label.textAlignment = .center
        label.font = MKFont.font(12)
        label.text = "Z-axis:N/A"
        return label
    }()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        addSubview(syncButton)
        syncButton.addSubview(synIcon)
        addSubview(syncLabel)
        addSubview(xDataLabel)
        addSubview(yDataLabel)
        addSubview(zDataLabel)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        syncButton.snp.makeConstraints { make in
            make.left.equalTo(15)
            make.width.equalTo(30)
            make.top.equalTo(5)
            make.height.equalTo(30)
        }
        synIcon.snp.makeConstraints { make in
            make.centerX.equalTo(syncButton)
            make.centerY.equalTo(syncButton)
            make.width.height.equalTo(25)
        }
        syncLabel.snp.makeConstraints { make in
            make.left.equalTo(15)
            make.width.equalTo(25)
            make.top.equalTo(syncButton.snp.bottom).offset(2)
            make.height.equalTo(MKFont.font(10).lineHeight)
        }
        let width = (MKScreen.width - 6 * 15) / 3
        xDataLabel.snp.makeConstraints { make in
            make.left.equalTo(syncButton.snp.right).offset(5)
            make.width.equalTo(width)
            make.centerY.equalTo(syncButton).offset(2)
            make.height.equalTo(MKFont.font(12).lineHeight)
        }
        yDataLabel.snp.makeConstraints { make in
            make.left.equalTo(xDataLabel.snp.right).offset(5)
            make.width.equalTo(width)
            make.centerY.equalTo(xDataLabel)
            make.height.equalTo(MKFont.font(12).lineHeight)
        }
        zDataLabel.snp.makeConstraints { make in
            make.left.equalTo(yDataLabel.snp.right).offset(5)
            make.width.equalTo(width)
            make.centerY.equalTo(xDataLabel)
            make.height.equalTo(MKFont.font(12).lineHeight)
        }
    }

    @objc private func syncButtonPressed() {
        syncButton.isSelected.toggle()
        synIcon.layer.removeAnimation(forKey: "bxd_synIconAnimationKey")
        delegate?.bxd_updateThreeAxisNotifyStatus(syncButton.isSelected)
        if syncButton.isSelected {
            synIcon.layer.add(MKSwiftUIAdaptor.refreshAnimation(2.0), forKey: "bxd_synIconAnimationKey")
            syncLabel.text = "Stop"
            return
        }
        syncLabel.text = "Sync"
    }

    public func updateData(xData: String, yData: String, zData: String) {
        xDataLabel.text = "X-axis:\(xData)mg"
        yDataLabel.text = "Y-axis:\(yData)mg"
        zDataLabel.text = "Z-axis:\(zData)mg"
    }
}
