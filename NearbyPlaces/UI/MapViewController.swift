//
//  MapViewController.swift
//  NearbyPlaces
//
//  Created by Maria on 9/11/18.
//  Copyright © 2018 Maria Deygin. All rights reserved.
//

import UIKit
import MapKit
import RxSwift
import RxMKMapView

class MapViewController: UIViewController {

    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var styleSegmentedControl: UISegmentedControl!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var showMoreButton: UIButton!
    @IBOutlet var viewModel: MapViewModel!
    
    private let locationManager = CLLocationManager()
    var currentCoordinate: CLLocationCoordinate2D?
    
    private let placesReuseIdentifier = "placesReuseIdentifier"
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLocationManager()
        setupTopView()
        setupBottomView()
        setupMapView()
        setupTableView()
        setupSelectPlaceObserving()
    }
    
    //MARK: - Setups
    
    private func setupLocationManager() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    private func setupTopView() {
        styleSegmentedControl.rx.selectedSegmentIndex
            .map { $0 == 0 }
            .bind(to: tableView.rx.isHidden)
            .disposed(by: disposeBag)
        
        showMoreButton.rx.action = viewModel.loadMoreAction
    }
    
    private func setupBottomView () {
        viewModel.currentAddress
            .map{ "You're at: " + $0.formattedAddress }
            .bind(to: addressLabel.rx.text)
            .disposed(by: disposeBag)
    }

    private func setupMapView() {
        mapView.showsUserLocation = true
        mapView.showsCompass = true
        mapView.showsScale = true
        
        viewModel.places
            .map {
                $0.map { PlaceAnnotation(from: $0) }
            }
            .bind(to: mapView.rx.annotations)
            .disposed(by: disposeBag)
    }
    
    private func setupTableView() {
        
        viewModel.places
            .bind(to: tableView.rx.items(cellIdentifier: String(describing: PlaceCell.self), cellType: PlaceCell.self)) {
                (row, place, cell) in
                cell.configureWith(place)
            }
            .disposed(by: disposeBag)
        
        tableView.rx.modelSelected(Place.self)
            .bind(to: viewModel.selectPlaceAction.inputs)
            .disposed(by: disposeBag)
        
        tableView.rx.itemSelected.asObservable()
            .bind { [unowned self] (indexPath) in
                self.tableView.deselectRow(at: indexPath, animated: true)
            }
            .disposed(by: disposeBag)
        
        tableView.rx.contentOffset
            .filter { [unowned self] (contentOffset) in
                let res = contentOffset.y >= self.tableView.contentSize.height - self.tableView.bounds.size.height
                return res && self.tableView.contentSize.height >= self.tableView.bounds.size.height
            }
            .map{ _ in () }
            .bind(to: viewModel.loadMoreAction.inputs).disposed(by: disposeBag)
    }
    
    func setupSelectPlaceObserving() {
        viewModel.selectedPlace
            .filter{ $0 != nil }
            .map{ $0! }
            .subscribe(onNext: {
                [weak self] (place) in
                guard let strongSelf = self else { return }
                
                strongSelf.styleSegmentedControl.rx.selectedSegmentIndex.onNext(0)
                strongSelf.styleSegmentedControl.sendActions(for: UIControlEvents.valueChanged)
                
                if let index = strongSelf.mapView.annotations
                    .index(where: { (annotation) -> Bool in
                        guard let placeAnnotation = annotation as? PlaceAnnotation else { return false }
                        return placeAnnotation.placeId == place.id
                    })
                    .map({ Int($0) }) {
                    
                    strongSelf.mapView.selectAnnotation(strongSelf.mapView.annotations[index], animated: true)
                }
            })
            .disposed(by: disposeBag)
    }
    
    //MARK: - Helpers
    
    private let regionRadius: CLLocationDistance = 200
    
    private func centerMapOnCurrentLocation(_ coordinate: CLLocationCoordinate2D) {
        self.currentCoordinate = coordinate

        let coordinateRegion = MKCoordinateRegionMakeWithDistance(coordinate, regionRadius, regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    private func centerMapOnSelectedPlace(_ coordinate: CLLocationCoordinate2D) {
        let annotationPoint = MKMapPointForCoordinate(coordinate)
        let pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.1, 0.1)
        mapView.setVisibleMapRect(pointRect, animated: true)
    }
    
}

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let placeAnnotation = annotation as? PlaceAnnotation  else { return nil }
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: placesReuseIdentifier) as? PlaceMarkerAnnotationView
        if annotationView == nil {
            annotationView = PlaceMarkerAnnotationView(annotation: annotation, reuseIdentifier: placesReuseIdentifier)
            annotationView?.canShowCallout = true
            annotationView?.rightCalloutAccessoryView = UIView()
        }
        else {
            annotationView?.annotation = annotation
        }
        
        if let placeAnnotationView = annotationView {
            placeAnnotationView.configureWith(placeAnnotation)
        }
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let coordinate = view.annotation?.coordinate {
            centerMapOnSelectedPlace(coordinate)
        }
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        if let coordinate = userLocation.location?.coordinate {
            
            var allowLoad = true
            
            if let oldCoordinate = currentCoordinate {
                let newPoint = MKMapPointForCoordinate(coordinate)
                let oldPoint = MKMapPointForCoordinate(oldCoordinate)
                
                allowLoad = MKMetersBetweenMapPoints(newPoint, oldPoint) > 50 
            }
            
            if allowLoad {
                centerMapOnCurrentLocation(coordinate)
                viewModel.loadPlaces(coordinate)
            }
        }
    }
}
