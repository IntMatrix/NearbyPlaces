//
//  NetworkService.swift
//  NearbyPlaces
//
//  Created by Maria on 9/11/18.
//  Copyright © 2018 Maria Deygin. All rights reserved.
//

import Foundation
import RxSwift
import Moya

class NetworkService {
    let provider = MoyaProvider<NearbyPlacesAPI>()
    let jsonDecoder = JSONDecoder()
    
    static let shared = NetworkService()
    
    func getNearbyPlaces(latitude: Double, longitude: Double) -> Single<Place.Batch> {
        return provider.rx.request(.getNearbyPlaces(latitude, longitude))
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .filterSuccessfulStatusAndRedirectCodes()
            .map(Place.Batch.self, using: jsonDecoder)
    }
    
    func getNearbyPlacesMore(pageToken: String) -> Single<Place.Batch> {
        return provider.rx.request(.getNearbyPlacesMore(pageToken))
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .filterSuccessfulStatusAndRedirectCodes()
            .map(Place.Batch.self, using: jsonDecoder)
    }
    
    func getReversedGeocode(latitude: Double, longitude: Double) -> Single<Address> {
        return provider.rx.request(.getReversedGeocode(latitude, longitude))
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .filterSuccessfulStatusAndRedirectCodes()
            .map(Address.Batch.self, using: jsonDecoder)
            .map{ $0.addresses.first ?? Address() }
    }
}
