//
//  Country.swift
//  iSearch
//
//  Created by Lawand, Poonam on 5/9/19.
//  Copyright © 2019 Lawand, Poonam. All rights reserved.
//

import Foundation

struct Currencies: Codable {
    var code:String = ""
    var name:String = ""
    var symbol:String = ""
    
    private enum CodingKeys: String, CodingKey {
        case code,name,symbol
    }
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.code = try container.decode(String.self, forKey: .code)
        self.name = try container.decode(String.self, forKey: .name)
        self.symbol = try container.decode(String.self, forKey: .symbol)
    }
    func getFormattedCurrency() -> String {
        return (self.name) + " ("+(self.code) + ") (" + (self.symbol)+")"
    }
}
struct Country: Codable {
    
    var name:String = ""
    var capital:String = ""
    var flag:String = ""
    var currencies:[Currencies?] = []
    var languages:[Language?] = []
    var callingCodes:[String?] = []
    var topLevelDomain :[String?] = []
    var borders:[String]?
    var region:String = ""
    var subregion:String?
    var population:String = ""
    var latlng:[Double] = []
    var timezones:[String] = []
    var gini:String?
    var area:Double?
    var alpha2Code:String?
    
    //[{"code":"BHD","name":"Bahraini dinar","symbol":".د.ب"}]
    //"region":"Asia","subregion":"Southern Asia","population":1295210000,"latlng":[20.0,77.0],"demonym":"Indian","area":3287590.0,"gini":33.4,"timezones":["UTC+05:30"]
    
    private enum CodingKeys: String, CodingKey {
        case name, capital,flag,currencies,languages,callingCodes,topLevelDomain,borders,region,subregion,population,latlng,timezones,gini,area,alpha2Code
    }
    
    init() {
        name = ""
        capital = ""
        flag = ""
        currencies = []
        languages = []
        callingCodes = []
        topLevelDomain = []
        region = ""
        population = ""
        latlng = []
        timezones = []
        
    }
    
    init(_ name:String,capital:String ,flag:String,  currencies:[Currencies?] ,languages:[Language?] ){
        self.name = name
        self.capital = capital
        self.flag = flag
        self.currencies = currencies
        self.languages = languages
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let nameValue = try? container.decode(String.self, forKey: .name) {
            name = nameValue
        }
        
        if let capitalValue = try? container.decode(String.self, forKey: .capital) {
            capital = capitalValue
        }
        if let stringValue = try? container.decode(String.self, forKey: .flag) {
            flag = stringValue
        }
        if let value = try? container.decode([Currencies].self, forKey: .currencies) {
            currencies = value
        }
        if let value = try? container.decode([Language].self, forKey: .languages) {
            languages = value
        }
        if let value = try? container.decode([String].self, forKey: .callingCodes) {
            callingCodes = value
        }
        if let value = try? container.decode([String].self, forKey: .topLevelDomain) {
            topLevelDomain = value
        }
        if let value = try? container.decode([String].self, forKey: .borders) {
            borders = value
        }
        if let value = try? container.decode(String.self, forKey: .region) {
            region = value
        }
        if let value = try? container.decode(String.self, forKey: .subregion) {
            subregion = value
        }
        if let value = try? container.decode(Int.self, forKey: .population) {
            population = String(value)
        }
        if let value = try? container.decode([Double].self, forKey: .latlng) {
            latlng = value
        }
        if let value = try? container.decode([String].self, forKey: .timezones) {
            timezones = value
        }
        if let value = try? container.decode(Double.self, forKey: .area) {
            area = value
        }
        if let value = try? container.decode(Double.self, forKey: .gini) {
            gini = String(format:"%.1f",value)
        }
        if let value = try? container.decode(String.self, forKey: .alpha2Code) {
            alpha2Code = value
        }
        
        
    }
    //Get formatted geo location txt
    func getGeoLocationText()-> String {
        if self.latlng.count < 0   {
            return ""
        }
        return String(format:"%.4f ° , %.4f ° ", self.latlng[0],self.latlng[1])
        
    }
    //Get formatted language txt
    func getLanguageNamesText()-> String {
        let languagesNameArray = self.languages.map{ ( language: Language?)  in
            language?.name
        }
        return languagesNameArray.getString()
    }
    
    //Get formatted currency txt
    func getCurrenciesText()-> String {
        let currencyArray =  self.currencies.map{ (currency: Currencies?)  in
            currency?.getFormattedCurrency()
        }
        return currencyArray.getString()
    }
    //To get area Label
    func getAreaText() -> String
    {
        if let value = self.area {
            return String(format:"%.1f killo meters", value)
        }
        return ""
    }
    func description() -> String {
        return "Country Name: \(self.name)"
    }
    
}
//Mark - Array extension
extension Array {
    func getString() -> String {
        let stringArray = self.map{ $0 as! String }
        return stringArray.joined(separator: " . ")
    }
}
