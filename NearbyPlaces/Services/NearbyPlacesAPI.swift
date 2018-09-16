//
//  NearbyPlacesAPI.swift
//  NearbyPlaces
//
//  Created by Maria on 9/11/18.
//  Copyright © 2018 Maria Deygin. All rights reserved.
//

import Foundation
import Moya

enum NearbyPlacesAPI {
    
    //apiKey was hidden
    static let apiKey = "API_KEY"
    
    case getNearbyPlaces(Double, Double)
    case getNearbyPlacesMore(String)
    case getReversedGeocode(Double, Double)
}

extension NearbyPlacesAPI: TargetType {
    
    var baseURL: URL {
        switch self {
        case .getNearbyPlaces,
             .getNearbyPlacesMore,
             .getReversedGeocode:
            return URL(string: "https://maps.googleapis.com/maps/api")!
        }
    }
    
    var path: String {
        switch self {
        case .getNearbyPlaces,
             .getNearbyPlacesMore:
            return "/place/nearbysearch/json"
        case .getReversedGeocode:
            return "/geocode/json"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getNearbyPlaces,
             .getNearbyPlacesMore,
             .getReversedGeocode:
            return .get
        }
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        switch self {
        case .getNearbyPlaces,
             .getNearbyPlacesMore,
             .getReversedGeocode:
            return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
        }
    }
    
    var parameters: [String:Any] {
        switch self {
        case .getNearbyPlaces(let latitude, let longitude):
            return ["location" : "\(latitude),\(longitude)",
                    "rankby" : "distance",
                    "key" : NearbyPlacesAPI.apiKey]
            
        case .getNearbyPlacesMore(let pageToken):
            return ["pagetoken" : pageToken,
                    "key" : NearbyPlacesAPI.apiKey]
            
        case .getReversedGeocode(let latitude, let longitude):
            return ["latlng" : "\(latitude),\(longitude)",
                    "key" : NearbyPlacesAPI.apiKey]
        }
    }
    
    var headers: [String: String]? {
        switch self {
        case .getNearbyPlaces,
             .getNearbyPlacesMore,
             .getReversedGeocode:
            return ["Content-Type": "application/json", "Accept": "application/json"]
        }
    }
    
    public var validationType: ValidationType {
        return .successCodes
    }
    
}
