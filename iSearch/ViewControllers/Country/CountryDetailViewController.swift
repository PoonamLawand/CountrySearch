//
//  CountryDetailViewController.swift
//  iSearch
//
//  Created by Lawand, Poonam on 5/10/19.
//  Copyright © 2019 Lawand, Poonam. All rights reserved.
//

import UIKit
import SVGKit


class CountryDetailViewController: UIViewController{
    
    let countryTagArray = ["Capital :","Geographical Location :","Currencies :","Languages :","Calling Code :","ISO Code :","Area :","Population :","Gini :","Neighboring countries :","Time Zones :","Internet TLD"]
    @IBOutlet weak var countryDetailTableView: UITableView!
    @IBOutlet weak var countryFlagImageView:AsyncImageView!
    
    var currentCountry: Country! {
        didSet {
            configureView()
        }
    }
    
    func configureView() {
        if let currentCountry = currentCountry {
            if let _ = countryFlagImageView {
                
                if let url = URL(string: currentCountry.flag ){
                    countryFlagImageView.setImageURL(url)
                }
                self.navigationItem.title = currentCountry.name
               
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
}
extension  CountryDetailViewController: UITabBarDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45.0
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        
        return countryTagArray.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CountryTableViewCell", for: indexPath) as! CountryTableViewCell
        
        setUpCell(cell, indexPath)
        return cell
        
    }
    //prepare Cell with country data
    func setUpCell(_ cell:CountryTableViewCell,_ indexPath: IndexPath){
        cell.countryTagLabel.text = self.countryTagArray[indexPath.row]
        cell.countryTagDetailLabel.text = "No Data"
        switch indexPath.row {
        case 0:
            cell.countryTagDetailLabel.text = currentCountry.capital
            break
        case 1:
            cell.countryTagDetailLabel.text = currentCountry.getGeoLocationText()
            break
        case 2:
            cell.countryTagDetailLabel.text = currentCountry.getCurrenciesText()
            break
        case 3:
            cell.countryTagDetailLabel.text = currentCountry.getLanguageNamesText()
            break
        case 4:
            cell.countryTagDetailLabel.text = currentCountry.callingCodes.getString()
            break
        case 5:
            cell.countryTagDetailLabel.text = currentCountry.alpha2Code
            break
        case 6:
            cell.countryTagDetailLabel.text = currentCountry.getAreaText()
            break
        case 7:
            cell.countryTagDetailLabel.text = currentCountry.population
            break
        case 8:
            cell.countryTagDetailLabel.text = currentCountry.gini
            break
        case 9:
            cell.countryTagDetailLabel.text = currentCountry.borders?.getString()
            break
        case 10:
            cell.countryTagDetailLabel.text = currentCountry.timezones.getString()
            break
        case 11:
            cell.countryTagDetailLabel.text = currentCountry.topLevelDomain.getString()
            break
        default:
            break
        }
        
    }
    
}
