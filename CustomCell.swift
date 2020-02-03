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
}
//記事一覧ページのCustomCell
class CustomCell: UITableViewCell, FaveButtonDelegate {
    
    weak var delegate: CellDelegate?
    var items = [Item]()
    
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

    @IBOutlet weak var faveButton: FaveButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBAction func didButtonTapped(_ sender: FaveButton) {
        sender.switchAction(onAction: {
            self.delegate?.didTapButton(cell: self)
        },offAction: {
            self.delegate?.didUnTapButton(cell: self)
        })
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
//    override func prepareForReuse() {
//        super.prepareForReuse()
//              self.faveButton.isSelected = false
//              self.faveButton.isHighlighted = false
//              // This seems some CustomButton property
////              self.bookButton.isTouchInside = false
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
