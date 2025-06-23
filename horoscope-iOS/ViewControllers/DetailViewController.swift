//
//  DetailViewController.swift
//  horoscope-iOS
//
//  Created by Tardes on 17/6/25.
//

import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet weak var horoscopeImageView: UIImageView!
    @IBOutlet weak var HoroscopeNameLabel: UILabel!
    @IBOutlet weak var HoroscopeDatesLabel: UILabel!
    
    @IBOutlet weak var horoscopeLuckTexView: UITextView!
    @IBOutlet weak var loaidingView: UIActivityIndicatorView!
    
    var horoscope: Horoscope!
    var isFavorite: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.navigationItem.title = horoscope.name
        
        
        HoroscopeNameLabel.text = horoscope.name
        HoroscopeDatesLabel.text = horoscope.dates
        horoscopeImageView.image = horoscope.getImage()
        
        isFavorite =
        SessionManager.isFavoriteHoroscope(id: horoscope.id)
        
        setFavoriteImage()
        
        getHoroscopeLuck(period: "daily")
        
        }
        
        func setFavoriteImage() {
            favoriteMenu.image = isFavorite ? UIImage(systemName: "heart.fill"): UIImage(systemName: "heart")
        }
        
        
        @IBAction func setFavorite(_ sender: Any){
            isFavorite = !isFavorite
            if isFavorite {
            SessionManager.setFavoriteHoroscope(id: horoscope.id)
            } else {
            SessionManager.setFavoriteHoroscope(id: "")
            }
            setFavoriteImage()
        
        }
        
        @IBAction func share(_ sender: Any){
            //text to share
            let tex = "This is some text that I want to share"
            
            //set up activity view controller
            let textToShare = [tex]
            let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won sender as? UIBarButtonItem
            
            self.present(activityViewController, animated: true, completion: nil)
        
        }
        @IBAction func didChangePeriod(_ sender: UISegmentedControl) {
            switch sender.selectedSegmentIndex {
            case 0:
                getHoroscopeLuck(period: "daily")
            case 1:
                getHoroscopeLuck(period: "weekly")
            default:
                getHoroscopeLuck(period: "monthly")
        }
    }
    
    func getHoroscopeLuck(period:String) {
        loaidingView.isHidden = false
            guard let url = URL(string: "https://horoscope-app-api.vercel.app/api/v1/get-horoscope/\(period)?sign=\(horoscope.id)&day=TODAY") else {
                    self.loaidingView.isHidden = true
                    return // ERROR
            }
            Task {
                do {
                    let (data, _) = try await URLSession.shared.data(from: url)
                    
                /*if let str = String(data: data, encoding: .utf8) {
                    print(Successfully decode: (str)")
                }*/
                
                    guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                        DispatchQueue.main.async {
                            self.loaidingView.isHidden = true
                        }
                        return // ERROR
                    }
                    
                    let jsonData = json["data"] as? [String: String]
                    
                let  result = jsonData?["horoscope-data"] ?? ""
                
                DispatchQueue.main.async {
                    self.horoscopeLuckTexView.text = result
                    self.loaidingView.isHidden = true
                }
                
            } catch {
                print(error.localizedDescription)
            }
            
        }
        
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
