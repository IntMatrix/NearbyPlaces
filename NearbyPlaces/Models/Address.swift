//
//  Address.swift
//  NearbyPlaces
//
//  Created by Maria on 9/14/18.
//  Copyright © 2018 Maria Deygin. All rights reserved.
//

import Foundation
import CoreLocation

struct Address: Codable {
    var placeId: String
    var formattedAddress: String
    var location: CLLocation?
    
    enum CodingKeys: String, CodingKey {
        case placeId = "place_id"
        case formattedAddress = "formatted_address"
    }
    
    enum GeometryKeys: String, CodingKey {
        case geometry
        case location
    }
    
    enum LocationKeys: String, CodingKey {
        case latitude = "lat"
        case longitude = "lng"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        placeId = try container.decode(String.self, forKey: .placeId)
        formattedAddress = try container.decode(String.self, forKey: .formattedAddress)
        
        let rootContainer = try decoder.container(keyedBy: GeometryKeys.self)
        let geometryContainer = try rootContainer.nestedContainer(keyedBy: GeometryKeys.self, forKey:.geometry)
        let locationContainer = try geometryContainer.nestedContainer(keyedBy: LocationKeys.self, forKey: .location)
        
        let lat = try? locationContainer.decode(Double.self, forKey: .latitude)
        let lng = try? locationContainer.decode(Double.self, forKey: .longitude)
        
        if let latitude = lat, let longitude = lng {
            location = CLLocation(latitude: latitude, longitude: longitude)
        }
    }

    init() {
        self.formattedAddress = ""
        self.placeId = ""
    }
}


extension Address {
    
    struct Batch: Codable {
        var addresses: [Address]
        
        enum CodingKeys: String, CodingKey {
            case addresses = "results"
        }
        
        enum DataKeys: String, CodingKey {
            case data
        }
    }
    
}

