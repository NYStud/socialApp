//
//  MPeople.swift
//  socialApp
//
//  Created by Денис Щиголев on 26.08.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import Foundation
import FirebaseFirestore
import MessageKit
import MapKit

struct MPeople: Hashable, Codable, SenderType {
    
    var displayName: String
    var advert: String
    var userImage: String
    var gallery: [String]
    var search: String
    var mail: String
    var sex: String
    var isActive: Bool
    var senderId: String
    var location: CLLocationCoordinate2D
    var distance: Int
    
    init(displayName: String,
         advert: String,
         userImage: String,
         gallery: [String],
         search: String,
         mail: String,
         sex: String,
         isActive: Bool,
         senderId: String,
         location: CLLocationCoordinate2D,
         distance: Int) {
        
        self.displayName = displayName
        self.advert = advert
        self.userImage = userImage
        self.gallery = gallery
        self.search = search
        self.mail = mail
        self.sex = sex
        self.isActive = isActive
        self.senderId = senderId
        self.location = location
        self.distance = distance
    }
    
    //for get document from Firestore
    init?(documentSnap: DocumentSnapshot){
        guard let documet = documentSnap.data()  else { return nil }
        if let displayName = documet["displayName"] as? String { self.displayName = displayName } else { displayName = ""}
        if let advert = documet["advert"] as? String { self.advert = advert } else { self.advert = ""}
        if let userImage = documet["userImage"] as? String { self.userImage = userImage } else { self.userImage = "" }
        if let gallery = documet["gallery"] as? [String] { self.gallery = gallery } else { self.gallery = []}
        if let search = documet["search"] as? String { self.search = search } else { self.search = ""}
        if let sex = documet["sex"] as? String { self.sex = sex } else { self.sex = ""}
        if let isActive = documet["isActive"] as? Bool { self.isActive = isActive} else { self.isActive = false}
        if let location = documet["location"] as? [String:Double] {
            let latitude = location[MLocation.latitude.rawValue] ?? MLocation.latitude.defaultValue
            let longitude = location[MLocation.longitude.rawValue] ?? MLocation.longitude.defaultValue
            let clLocation = CLLocationCoordinate2D(latitude: latitude,
                                                    longitude: longitude)
            self.location = clLocation
        } else { self.location = CLLocationCoordinate2D(latitude: MLocation.latitude.defaultValue,
                                                        longitude: MLocation.longitude.defaultValue)}
        guard let mail = documet["mail"] as? String else { return nil }
        guard let senderId = documet["senderId"] as? String else { return nil }
        
        self.distance = 0
        self.mail = mail
        self.senderId = senderId
    }
    
    //for init with ListenerService
    init?(documentSnap: QueryDocumentSnapshot){
        let documet = documentSnap.data()
        
        if let displayName = documet["displayName"] as? String { self.displayName = displayName } else { displayName = ""}
        if let advert = documet["advert"] as? String { self.advert = advert } else { self.advert = ""}
        if let userImage = documet["userImage"] as? String { self.userImage = userImage } else { self.userImage = "" }
        if let gallery = documet["gallery"] as? [String] { self.gallery = gallery } else { self.gallery = []}
        if let search = documet["search"] as? String { self.search = search } else { self.search = ""}
        if let sex = documet["sex"] as? String { self.sex = sex } else { self.sex = ""}
        if let isActive = documet["isActive"] as? Bool { self.isActive = isActive} else { self.isActive = false}
        if let location = documet["location"] as? [String:Double] {
            let latitude = location[MLocation.latitude.rawValue] ?? MLocation.latitude.defaultValue
            let longitude = location[MLocation.longitude.rawValue] ?? MLocation.longitude.defaultValue
            let clLocation = CLLocationCoordinate2D(latitude: latitude,
                                                    longitude: longitude)
            self.location = clLocation
        } else { self.location = CLLocationCoordinate2D(latitude: MLocation.latitude.defaultValue,
                                                        longitude: MLocation.longitude.defaultValue)}
        guard let mail = documet["mail"] as? String else { return nil }
        guard let senderId = documet["senderId"] as? String else { return nil }
        
        self.distance = 0
        self.mail = mail
        self.senderId = senderId
    }
    
    //for init UserDefaults
    init?(data: [String : Any]){
        
        guard let displayName = data["displayName"] as? String else { return nil }
        guard let advert = data["advert"] as? String else { return nil }
        guard let userImage = data["userImage"] as? String else { return nil }
        guard let gallery = data["gallery"] as? [String] else { return nil}
        guard let search = data["search"] as? String else { return nil }
        guard let sex = data["sex"] as? String else { return nil }
        guard let isActive = data["isActive"] as? Bool else { return nil }
        guard let location = data["location"] as? CLLocationCoordinate2D else { return nil }
        guard let mail = data["mail"] as? String else { return nil }
        guard let senderId = data["senderId"] as? String else { return nil }
        guard let distance = data["distance"] as? Int else { return nil }
        
        self.displayName = displayName
        self.advert = advert
        self.userImage = userImage
        self.gallery = gallery
        self.search = search
        self.sex = sex
        self.isActive = isActive
        self.location = location
        self.mail = mail
        self.senderId = senderId
        self.distance = distance
    }
    
    enum CodingKeys: String, CodingKey {
        case displayName
        case advert
        case userImage
        case gallery
        case search
        case mail
        case sex
        case location
        case isActive
        case senderId
        case distance
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(senderId)
    }
    
    static func == (lhs: MPeople, rhs: MPeople) -> Bool {
        return  lhs.senderId == rhs.senderId
    }
}
