
//
//  AsyncImageView.swift
//  iSearch
//
//  Created by Lawand, Poonam on 5/11/19.
//  Copyright © 2019 Lawand, Poonam. All rights reserved.
//

import UIKit
import SVGKit

enum ImageType: String{
    case PNG = "png"
    case SVG = "svg"
}
class AsyncImageView :UIImageView {
    var imageType:ImageType = .SVG
    var imageURL:URL?
    var dataTask:URLSessionDataTask? = nil
    var activityIndicator: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //Adding Extra design
        self.layer.backgroundColor = UIColor.clear.cgColor
        self.layer.cornerRadius = 10
        self.layer.borderWidth =   0.3
        self.layer.masksToBounds = true
        self.layer.borderColor = UIColor.gray.cgColor
        
        activityIndicator = UIActivityIndicatorView(style: .gray)
        activityIndicator.center = self.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.center = CGPoint(x:self.bounds.size.width / 2.0, y: self.bounds.size.height / 2.0)
        activityIndicator.autoresizingMask = [.flexibleLeftMargin, .flexibleTopMargin , .flexibleRightMargin, .flexibleBottomMargin]
        activityIndicator.removeFromSuperview()
        self.addSubview(activityIndicator)
    }
    init(_ frame: CGRect) {
        super.init(frame:frame)
    }
    init(_ imageURL:URL) {
        super.init(frame:CGRect.zero)
        setImageURL(imageURL)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //fatalError("init(coder:) has not been implemented")
    }
    deinit {
        
        self.dataTask?.cancel()
    }
    
    
    func cancelDownload(){
        guard self.dataTask != nil else {
            return
        }
        //print("Cancel Task------>")
        
        self.dataTask?.cancel()
        self.dataTask = nil
        self.image = nil
        
    }
    func setImageURL(_ imageURL:URL){
        self.buildAsyncTask(imageURL)
    }
    
    func buildAsyncTask(_ imageURL:URL){
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
        
        DispatchQueue.global(qos: .background).async {
            let request = URLRequest(url: imageURL,
                                     cachePolicy: .returnCacheDataElseLoad,
                                     timeoutInterval: 30)
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                if error != nil {
                    return
                }
                //                if let data = data,let response = String(data: data, encoding: String.Encoding.utf8) {
                //                    #if DEBUG
                //                    print("Request: \(String(describing: request.url?.absoluteString))")
                //                    print("Response: \(response)")
                //                    #endif
                //                }
                // successBlock(data, response)
                guard let data = data else {
                    return
                }
                DispatchQueue.main.sync {
                    self.activityIndicator.stopAnimating()
                    
                    if (self.imageType == .SVG){
                        if let anSVGImage: SVGKImage = SVGKImage(data: data) {
                            self.image = anSVGImage.uiImage
                            
                        }
                    }
                    else {
                        self.image = UIImage(data: data)
                        
                    }
                }
            }
            self.dataTask = task
            task.resume()
            
        }
    }
}
