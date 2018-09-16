//
//  Place+Image.swift
//  NearbyPlaces
//
//  Created by Maria on 9/15/18.
//  Copyright © 2018 Maria Deygin. All rights reserved.
//

import Foundation
import Kingfisher
import RxKingfisher
import RxSwift

extension Place {
    
    var icon:Observable<UIImage> {
        guard let imagePath = iconPath else { return  Observable.just(#imageLiteral(resourceName: "default_marker"))  }
        return KingfisherManager.shared.rx
            .retrieveImage(with: URL(string: imagePath)!)
            .asObservable()
            .startWith(#imageLiteral(resourceName: "default_marker"))
            .catchErrorJustReturn(#imageLiteral(resourceName: "default_marker"))
    }
    
}
