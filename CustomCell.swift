//
//  CustomCell.swift
//  TechBlog
//
//  Created by 岡田龍太朗 on 2019/12/21.
//  Copyright © 2019 岡田龍太朗. All rights reserved.
//

import UIKit
import FaveButton
import Firebase

protocol CellDelegate: AnyObject {
    func didTapButton(cell: CustomCell)
}
@objc(CustomCell)
class CustomCell: UITableViewCell, FaveButtonDelegate {
    
    weak var delegate: CellDelegate?

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
    let faveButton = FaveButton(
        frame: CGRect(x:200, y:200, width: 44, height: 44),
        faveIconNormal: UIImage(named: "heart.png")
    )
    let db = Firestore.firestore()
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBAction func didButtonTapped(_ sender: FaveButton) {
        delegate?.didTapButton(cell: self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}
