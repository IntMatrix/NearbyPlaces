//
//  PlaceAnnotation.swift
//  NearbyPlaces
//
//  Created by Maria on 9/11/18.
//  Copyright © 2018 Maria Deygin. All rights reserved.
//

import Foundation
import MapKit
import RxSwift

class PlaceAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var iconPath: String?
    var placeId: String
    var icon:Observable<UIImage>
    
    init(from place: Place) {
        self.coordinate = place.location.coordinate
        self.title = place.name
        self.subtitle = place.vicinity
        self.iconPath = place.iconPath
        self.placeId = place.id
        self.icon = place.icon
        
        super.init()
    }
}
