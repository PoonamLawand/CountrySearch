//
//  Language.swift
//  iSearch
//
//  Created by Lawand, Poonam on 5/11/19.
//  Copyright © 2019 Lawand, Poonam. All rights reserved.
//

import Foundation

//"languages":[{"iso639_1":"ar","iso639_2":"ara","name":"Arabic","nativeName":"العربية"}]
struct Language: Codable {
    var iso639_1:String = ""
    var iso639_2:String = ""
    var name:String = ""
    var nativeName:String? = ""
    
    private enum CodingKeys: String, CodingKey {
        case iso639_1,iso639_2,name,nativeName
    }
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.iso639_1 = try container.decode(String.self, forKey: .iso639_1)
        self.iso639_2 = try container.decode(String.self, forKey: .iso639_2)
        self.name = try container.decode(String.self, forKey: .name)
        self.nativeName = try container.decode(String.self, forKey: .nativeName)
    }
    
}
