//
//  PlaceCell.swift
//  NearbyPlaces
//
//  Created by Maria on 9/11/18.
//  Copyright © 2018 Maria Deygin. All rights reserved.
//

import UIKit
import RxSwift

class PlaceCell: UITableViewCell {
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    
    private let disposeBag = CompositeDisposable()
    
    open override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag.dispose()
    }
    
    func configureWith(_ place:Place) {
        nameLabel.text = place.name
        detailLabel.text = place.vicinity
        iconImageView.tintColor = #colorLiteral(red: 0.9294117647, green: 0.4039215686, blue: 0.3176470588, alpha: 1)
        
        _ = disposeBag.insert(
            place.icon
                .map{ $0.withRenderingMode(.alwaysTemplate) }
                .bind(to: iconImageView.rx.image)
        )
    }
    
    deinit {
        disposeBag.dispose()
    }
}
