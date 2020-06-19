//
//  CustomCell.swift
//  TechBlog
//
//  Created by 岡田龍太朗 on 2019/12/21.
//  Copyright © 2019 岡田龍太朗. All rights reserved.
//

import UIKit
import FaveButton
//→ListViewController.swift
protocol CellDelegate: AnyObject {
    func didTapButton(cell: CustomCell)
    func didUnTapButton(cell: CustomCell)
//    func selectedCell(cell: CustomCell)
}
//記事一覧ページのCustomCell
class CustomCell: UITableViewCell, FaveButtonDelegate {
    
    weak var delegate: CellDelegate?
    var navi: UINavigationController!
    
    func faveButton(_ faveButton: FaveButton, didSelected selected: Bool) {
    }
    func color(_ rgbColor: Int) -> UIColor{
        return UIColor(
            red:   CGFloat((rgbColor & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbColor & 0x00FF00) >> 8 ) / 255.0,
            blue:  CGFloat((rgbColor & 0x0000FF) >> 0 ) / 255.0,
            alpha: CGFloat(1.0)
        )
    }

    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var faveButton: FaveButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var feedTitleLabel: UILabel!
    @IBAction func didButtonTapped(_ sender: FaveButton) {
        sender.switchAction(onAction: {
            self.delegate?.didTapButton(cell: self)
        },offAction: {
            self.delegate?.didUnTapButton(cell: self)
        })
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = .clear

        self.backView.layer.borderWidth = 1
        self.backView.layer.cornerRadius = 8
        self.backView.layer.borderColor = UIColor.clear.cgColor
        self.backView.layer.masksToBounds = true
        self.backView.backgroundColor = .white

        self.layer.shadowOpacity = 0.18
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowRadius = 2
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.masksToBounds = false

    }
    
//    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        self.delegate?.selectedCell(cell: self)
//    }
}

extension FaveButton {
//ボタンのON/OFFで処理を変える
    func switchAction(onAction: @escaping ()->Void, offAction: @escaping ()->Void) {
       
        switch self.isSelected {
        case true:
            onAction()
        case false:
            offAction()
        }

    }
}
