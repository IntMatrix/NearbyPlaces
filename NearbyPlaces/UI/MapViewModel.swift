//
//  MapViewModel.swift
//  NearbyPlaces
//
//  Created by Maria on 9/11/18.
//  Copyright © 2018 Maria Deygin. All rights reserved.
//

import Foundation
import RxSwift
import Action
import CoreLocation

class MapViewModel: NSObject {
    
    var networkService = NetworkService.shared
    
    let places = BehaviorSubject<[Place]>(value: [])
    let selectedPlace = BehaviorSubject<Place?>(value: nil)
    let currentAddress = BehaviorSubject<Address>(value: Address())
    
    let loading = BehaviorSubject<Bool>(value: false)
    let cancelPreviousLoads = PublishSubject<Void>()
    var nextPageTrigger: Observable<Bool>!
    var nextPageToken: String?
    
    private let disposeBag = DisposeBag()
    
    override init() {
        super.init()
        
        loading.filter{ $0 == true }
            .subscribe(onNext: { _ in
                self.cancelPreviousLoads.onNext(())
            }).disposed(by: disposeBag)
        
        nextPageTrigger = loading.map({ (value) -> Bool in
                guard self.nextPageToken != nil else { return false }
                return !value
            })
    }
    
    //MARK: Load places
    
    func loadPlaces(_ coordinate: CLLocationCoordinate2D) {
        self.loadNearbyPlaces(coordinate)
        self.loadCurrentAddress(coordinate)
    }
    
    private func loadNearbyPlaces(_ coordinate: CLLocationCoordinate2D) {
        self.nextPageToken = nil
        loading.onNext(true)
        
        networkService.getNearbyPlaces(latitude: coordinate.latitude, longitude: coordinate.longitude)
            .asObservable()
            .takeUntil(cancelPreviousLoads.asObservable())
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: {
                [weak self] (result) in
                guard let strongSelf = self else { return }
                strongSelf.places.onNext(result.places)
                strongSelf.nextPageToken = result.nextPageToken
                
                strongSelf.loading.onNext(false)
            })
            .disposed(by: disposeBag)
    }
    
    private func loadMorePlaces() {
        guard let pageToken = self.nextPageToken else { return }
        loading.onNext(true)
        
        networkService.getNearbyPlacesMore(pageToken: pageToken)
            .asObservable()
            .takeUntil(cancelPreviousLoads.asObservable())
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: {
                [weak self] (result) in
                guard let strongSelf = self else { return }
                
                var updatedPlaces: [Place]
                do {
                    updatedPlaces = try strongSelf.places.value()
                }
                catch {
                    updatedPlaces = []
                }
                updatedPlaces += result.places
                
                strongSelf.places.onNext(updatedPlaces)
                strongSelf.nextPageToken = result.nextPageToken
                
                strongSelf.loading.onNext(false)
            })
            .disposed(by: disposeBag)
    }
    
    //MARK: - Load current address
    
    private func loadCurrentAddress(_ coordinate: CLLocationCoordinate2D) {
        networkService.getReversedGeocode(latitude: coordinate.latitude, longitude: coordinate.longitude)
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: {
                [weak self] (address) in
                guard let strongSelf = self else { return }
                strongSelf.currentAddress.onNext(address)
            })
            .disposed(by: disposeBag)
    }

    //MARK: - Actions
    
    lazy var loadMoreAction = CocoaAction(enabledIf: nextPageTrigger) { [weak self] _ in
        guard let strongSelf = self else { return .empty() }
        strongSelf.loadMorePlaces()
        return .empty()
    }
    
    lazy var selectPlaceAction = Action<Place, Void> { [weak self] place in
        guard let strongSelf = self else { return .empty() }
        strongSelf.selectedPlace.onNext(place)
        return .empty()
    }

}
