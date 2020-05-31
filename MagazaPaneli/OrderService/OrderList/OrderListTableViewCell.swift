//
//  OrderListTableViewCell.swift
//  MagazaPaneli
//
//  Created by Berkant Beğdilili on 30.05.2020.
//  Copyright © 2020 Berkant Beğdilili. All rights reserved.
//

import UIKit

class OrderListTableViewCell: UITableViewCell {

    
    
    @IBOutlet weak var citizenshipId: UILabel!
    @IBOutlet weak var createDate: UILabel!
    @IBOutlet weak var orderId: UILabel!
    @IBOutlet weak var orderNumber: UILabel!
    @IBOutlet weak var paymentType: UILabel!
    @IBOutlet weak var orderStatus: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
