//
//  Place.swift
//  NearbyPlaces
//
//  Created by Maria on 9/11/18.
//  Copyright © 2018 Maria Deygin. All rights reserved.
//

import Foundation
import CoreLocation

struct Place: Codable {
    var id: String
    var name: String?
    var iconPath: String?
    var vicinity: String?
    var placeId: String?
    var location: CLLocation

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case iconPath = "icon"
        case vicinity
        case placeId = "place_id"
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
        
        id = try container.decode(String.self, forKey: .id)
        name = try? container.decode(String.self, forKey: .name)
        iconPath = try? container.decode(String.self, forKey: .iconPath)
        vicinity = try? container.decode(String.self, forKey: .vicinity)
        placeId = try? container.decode(String.self, forKey: .placeId)
        
        let rootContainer = try decoder.container(keyedBy: GeometryKeys.self)
        let geometryContainer = try rootContainer.nestedContainer(keyedBy: GeometryKeys.self, forKey:.geometry)
        let locationContainer = try geometryContainer.nestedContainer(keyedBy: LocationKeys.self, forKey: .location)
        
        let latitude = try locationContainer.decode(Double.self, forKey: .latitude)
        let longitude = try locationContainer.decode(Double.self, forKey: .longitude)
        location = CLLocation(latitude: latitude, longitude: longitude)
    }
    
}

extension Place {
    
    struct Batch: Codable {
        var places: [Place]
        var nextPageToken: String?
        
        enum CodingKeys: String, CodingKey {
            case places = "results"
            case nextPageToken = "next_page_token"
        }
        
        enum DataKeys: String, CodingKey {
            case data
        }
    }
    
}
