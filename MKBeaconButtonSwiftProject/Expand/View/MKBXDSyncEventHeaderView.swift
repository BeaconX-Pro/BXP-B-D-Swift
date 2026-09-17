//
//  MKBXDSyncEventHeaderView.swift
//  MKBeaconXDButton
//
//  Created by aa on 2026/9/17.
//  Copyright © 2026 aadyx2007@163.com. All rights reserved.
//

import UIKit

import SnapKit

import MKBaseSwiftModule
import MKSwiftCustomUI

// MARK: - 内部 Btn

private final class MKBXDSyncEventHeaderBtn: UIControl {

    lazy var icon: UIImageView = {
        let iv = UIImageView()
        return iv
    }()

    lazy var msgLabel: UILabel = {
        let label = UILabel()
        label.textColor = MKColor.defaultText
        label.textAlignment = .center
        label.font = MKFont.font(11)
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(icon)
        addSubview(msgLabel)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard let image = icon.image else { return }
        let iconSize = image.size
        icon.snp.remakeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalTo(iconSize.width)
            make.top.equalTo(2)
            make.height.equalTo(iconSize.height)
        }
        msgLabel.snp.remakeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(MKFont.font(13).lineHeight)
        }
    }
}

// MARK: - Delegate

public protocol MKBXDSyncEventHeaderViewDelegate: AnyObject {
    func bxd_syncEventHeaderView_syncBtnPressed(_ selected: Bool)
    func bxd_syncEventHeaderView_deleteBtnPressed()
    func bxd_syncEventHeaderView_exportBtnPressed()
}

// MARK: - View

public final class MKBXDSyncEventHeaderView: UIView {

    public weak var delegate: MKBXDSyncEventHeaderViewDelegate?

    public var sync: Bool = false {
        didSet {
            syncButton.isSelected = false
            syncIcon.layer.removeAnimation(forKey: "synIconAnimationKey")
            syncLabel.text = "Sync"
        }
    }

    public var modeMsg: String = "" {
        didSet {
            modeLabel.text = modeMsg
        }
    }

    // MARK: - Subviews

    private lazy var syncIcon: UIImageView = {
        let iv = UIImageView()
        // ⚠️ 图片加载方式按工程实际 API 调整
        iv.image = UIImage(named: "bxd_threeAxisAcceLoadingIcon.png")
        return iv
    }()

    private lazy var syncButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.addTarget(self, action: #selector(syncButtonPressed), for: .touchUpInside)
        return btn
    }()

    private lazy var syncLabel: UILabel = {
        let label = UILabel()
        label.textColor = MKColor.defaultText
        label.textAlignment = .center
        label.font = MKFont.font(10)
        label.text = "Sync"
        return label
    }()

    private lazy var deleteButton: MKBXDSyncEventHeaderBtn = {
        let btn = MKBXDSyncEventHeaderBtn()
        btn.msgLabel.text = "Erase all"
        // ⚠️ 图片加载方式按工程实际 API 调整
        btn.icon.image = UIImage(named: "bxd_slotExportDeleteIcon.png")
        btn.addTarget(self, action: #selector(deleteButtonPressed), for: .touchUpInside)
        return btn
    }()

    private lazy var exportButton: MKBXDSyncEventHeaderBtn = {
        let btn = MKBXDSyncEventHeaderBtn()
        btn.msgLabel.text = "Export"
        // ⚠️ 图片加载方式按工程实际 API 调整
        btn.icon.image = UIImage(named: "bxd_slotExportEnableIcon.png")
        btn.addTarget(self, action: #selector(exportButtonPressed), for: .touchUpInside)
        return btn
    }()

    private lazy var timestampLabel: UILabel = {
        let label = UILabel()
        label.textColor = MKColor.defaultText
        label.font = MKFont.font(15)
        label.textAlignment = .center
        label.text = "Timestamp"
        return label
    }()

    private lazy var modeLabel: UILabel = {
        let label = UILabel()
        label.textColor = MKColor.defaultText
        label.font = MKFont.font(15)
        label.textAlignment = .center
        return label
    }()

    // MARK: - Init

    public override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(syncButton)
        addSubview(syncLabel)
        syncButton.addSubview(syncIcon)
        addSubview(deleteButton)
        addSubview(exportButton)
        addSubview(timestampLabel)
        addSubview(modeLabel)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Layout

    public override func layoutSubviews() {
        super.layoutSubviews()
        syncButton.snp.makeConstraints { make in
            make.left.equalTo(15)
            make.width.equalTo(30)
            make.top.equalTo(15)
            make.height.equalTo(30)
        }
        syncIcon.snp.makeConstraints { make in
            make.centerX.equalTo(syncButton)
            make.centerY.equalTo(syncButton)
            make.width.equalTo(25)
            make.height.equalTo(25)
        }
        syncLabel.snp.makeConstraints { make in
            make.left.equalTo(15)
            make.width.equalTo(30)
            make.top.equalTo(syncButton.snp.bottom).offset(2)
            make.height.equalTo(MKFont.font(10).lineHeight)
        }
        exportButton.snp.makeConstraints { make in
            make.right.equalTo(-15)
            make.width.equalTo(50)
            make.top.equalTo(10)
            make.height.equalTo(50)
        }
        deleteButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalTo(50)
            make.centerY.equalTo(exportButton)
            make.height.equalTo(50)
        }
        timestampLabel.snp.makeConstraints { make in
            make.left.equalTo(15)
            make.right.equalTo(self.snp.centerX).offset(-5)
            make.top.equalTo(exportButton.snp.bottom).offset(15)
            make.height.equalTo(MKFont.font(15).lineHeight)
        }
        modeLabel.snp.makeConstraints { make in
            make.right.equalTo(-15)
            make.left.equalTo(self.snp.centerX).offset(5)
            make.top.equalTo(exportButton.snp.bottom).offset(15)
            make.height.equalTo(MKFont.font(15).lineHeight)
        }
    }

    // MARK: - Actions

    @objc private func syncButtonPressed() {
        syncButton.isSelected.toggle()
        syncIcon.layer.removeAnimation(forKey: "synIconAnimationKey")

        if syncButton.isSelected {
            // 开始旋转
            let refreshRotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
            refreshRotationAnimation.toValue = Double.pi * 2.0
            refreshRotationAnimation.duration = 2.0
            refreshRotationAnimation.isCumulative = true
            refreshRotationAnimation.repeatCount = .infinity
            refreshRotationAnimation.isRemovedOnCompletion = false
            syncIcon.layer.add(refreshRotationAnimation, forKey: "synIconAnimationKey")
            syncLabel.text = "Stop"
        } else {
            syncLabel.text = "Sync"
        }
        delegate?.bxd_syncEventHeaderView_syncBtnPressed(syncButton.isSelected)
    }

    @objc private func deleteButtonPressed() {
        delegate?.bxd_syncEventHeaderView_deleteBtnPressed()
    }

    @objc private func exportButtonPressed() {
        delegate?.bxd_syncEventHeaderView_exportBtnPressed()
    }
}
