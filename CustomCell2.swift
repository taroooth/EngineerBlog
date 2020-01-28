//
//  CustomCell2.swift
//  TechBlog
//
//  Created by 岡田龍太朗 on 2020/01/27.
//  Copyright © 2020 岡田龍太朗. All rights reserved.
//

import UIKit
import FaveButton

protocol CellDelegate2: AnyObject {
    func didTapButton2(cell: CustomCell2)
    func didUnTapButton2(cell: CustomCell2)
}

class CustomCell2: UITableViewCell, FaveButtonDelegate {
    
    weak var delegate: CellDelegate2?

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

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var faveButton: FaveButton!
    @IBAction func faveButtonTapped(_ sender: FaveButton) {
        sender.switchAction2(onAction: {
            self.delegate?.didTapButton2(cell: self)
        },offAction: {
            self.delegate?.didUnTapButton2(cell: self)
        })
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}

extension FaveButton {

    func switchAction2(onAction: @escaping ()->Void, offAction: @escaping ()->Void) {
        //選択状態を反転
//        self.isSelected = !self.isSelected
        switch self.isSelected {
        case true:
            //ONにする時に走らせたい処理
            onAction()
        case false:
            //OFFにする時に走らせたい処理
            offAction()
        }

    }
}
