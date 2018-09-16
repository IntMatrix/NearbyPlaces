//
//  PlaceMarkerAnnotationView.swift
//  NearbyPlaces
//
//  Created by Maria on 9/11/18.
//  Copyright © 2018 Maria Deygin. All rights reserved.
//

import MapKit
import UIKit
import RxSwift
import RxCocoa

class PlaceMarkerAnnotationView: MKMarkerAnnotationView {
    
    private let disposeBag = CompositeDisposable()
    
    open override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag.dispose()
    }
    
    func configureWith(_ annotation: PlaceAnnotation) {
        _ = disposeBag.insert(
            annotation.icon
                .bind(to: rx.icon) )
    }
    
    deinit {
        disposeBag.dispose()
    }
}

extension Reactive where Base: MKMarkerAnnotationView {
    
    /// Bindable sink for `image` property.
    public var icon: Binder<UIImage?> {
        return Binder(base) { view, icon in
            view.glyphImage = icon
        }
    }
}
