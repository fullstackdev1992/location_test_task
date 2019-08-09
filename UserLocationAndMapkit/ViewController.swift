import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    var locationManager = CLLocationManager()
    
    @IBOutlet weak var locationLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        mapView.showsUserLocation = true
        
        if CLLocationManager.locationServicesEnabled() == true {
            
            if CLLocationManager.authorizationStatus() == .restricted || CLLocationManager.authorizationStatus() == .denied || CLLocationManager.authorizationStatus() == .notDetermined {
                
                locationManager.requestWhenInUseAuthorization()
            }
            
            locationManager.desiredAccuracy = 1.0
            locationManager.delegate = self
            locationManager.startUpdatingLocation()
            
            let userLatitude = locationManager.location?.coordinate.latitude
            let userLongitude = locationManager.location?.coordinate.longitude
           
//            print("-----USER LOCATION")
//            print (userLatitude)
//            print (userLongitude)
//            print("-----USER LOCATION")
            
            // calling the API
            makeGetCall(latitude: userLatitude ?? 0,longitude: userLongitude ?? 0)
        } else {
            print("PLease turn on location services or GPS")
        }

    }
    
    
    //MARK:- CLLocationManager Delegates
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude), span: MKCoordinateSpan(latitudeDelta: 0.002, longitudeDelta: 0.002))
        self.mapView.setRegion(region, animated: true)
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Unable to access your current location")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func makeGetCall(latitude: Double, longitude:Double) {
        // Set up the URL request
        let nominatimEndpoint: String = "https://nominatim.openstreetmap.org/reverse.php?format=json&lat=\(latitude)&lon=\(longitude)"
        guard let url = URL(string: nominatimEndpoint) else {
            print("Error: cannot create URL")
            return
        }
        let urlRequest = URLRequest(url: url)
        
        // set up the session
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        // make the request
        let task = session.dataTask(with: urlRequest) {
            (data, response, error) in
            // check for any errors
            guard error == nil else {
                print("error calling GET on nominatim")
                print(error!)
                return
            }
            // make sure we got data
            guard let responseData = data else {
                print("Error: did not receive data")
                return
            }
            // parse the result as JSON
            do {
                guard let nominatimResponse = try JSONSerialization.jsonObject(with: responseData, options: [])
                    as? [String: Any] else {
                        print("error trying to convert data to JSON")
                        return
                }
                // let's just print it to prove we can access it
                // print("Raw request: " + nominatimResponse.description)
                
                // the response object is a dictionary
                // so we just access the display_name using the "display_name" key
                guard let displayName = nominatimResponse["display_name"] as? String else {
                    print("Could not get display_name from JSON")
                    return
                }
                print("The display_name: " + displayName)
                
                DispatchQueue.main.async {
                    //Do UI Code here.
                    self.locationLabel.text = displayName
                }
                
                
            } catch  {
                print("error trying to convert data to JSON")
                return
            }
        }
        task.resume()
    }


}

