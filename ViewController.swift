
import UIKit
import CoreLocation
extension ViewController : CLLocationManagerDelegate{
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("GOT IT")
        
        if let location = locations.last {
            let latitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude
            print("Latlng: (\(latitude),\(longitude))")
            displayLocation(locationText: "Latlng: (\(latitude),\(longitude))")
            self.loadWeather(search: "\(latitude),\(longitude)")
        }
        
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
     print (error)
    }
    
}
class ViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var locationname: UILabel!
     
    @IBOutlet weak var condition: UILabel!
    
    
    
    private let locationManager = CLLocationManager()
    
    @IBOutlet weak var tf_serch: UITextField!
    
    
    @IBOutlet weak var image_weather: UIImageView!
    
    
    @IBOutlet weak var tempLB: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        locationManager.delegate = self
        displaySampleImage()
        tf_serch.delegate = self
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
    
    private func displaySampleImage(){
        let config=UIImage.SymbolConfiguration(paletteColors: [
            .systemCyan,.systemYellow,.systemOrange
        ])
        image_weather.preferredSymbolConfiguration=config
        image_weather.image=UIImage(systemName: "cloud.drizzle")
//        ?.withTintColor(.blue, renderingMode: .alwaysOriginal)

    }

    @IBAction func onLocationTapped(_ sender: UIButton) {
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        locationManager.startUpdatingLocation()
    }
    
    public func displayLocation(locationText : String){
        locationname.text=locationText
    }
    
    @IBAction func onSearchTapped(_ sender: UIButton) {
        loadWeather(search: tf_serch.text)
        
    }
    
    private func loadWeather(search: String?){
        guard let search = search else{
            return
        }
//        Step 1: Get URL
        guard let url=getURL(query: search) else{
            return
        }
//         STEP:2
        let session = URLSession.shared
//  STEP:3
        let dataTask = session.dataTask(with: url) { data, response, error in
            
            // network call finished
            print("Network call complete")
            
            guard error == nil else {
                 print("ERROR RECEIVED")
                return
            }
            guard let data = data else
            {
                print("no data found ")
                return
            }
            
            if let weatherResponse = self.parseJSON(data: data){
//                prints the name of the locationa and temperature in the console
                print(weatherResponse.location.name)
                print(weatherResponse.current.temp_c)
                let weath = weatherResponse.current.condition.code
//                update has been happening in background thread instead of main(ui)thread
//            DispatchQueue: is an object whcih manages the execution of tasks serially
                            
                DispatchQueue.main.async { [self] in
                    self.locationname.text = weatherResponse.location.name
                    self.tempLB.text = "\(weatherResponse.current.temp_c) C"
                    self.condition.text = weatherResponse.current.condition.text
                    
                    
                    if ((weath) == 1000){
                        self.image_weather.image=UIImage(systemName: "sun.max")?.withTintColor(.red, renderingMode: .alwaysOriginal)
                    }
                    if((weath) == 1003){
                        self.image_weather.image = UIImage(systemName: "cloud")?.withTintColor(.gray, renderingMode: .alwaysOriginal)
                    }
                    if ((weath) == 1006){
                        self.image_weather.image = UIImage(systemName: "cloud.fill")?.withTintColor(.black, renderingMode: .alwaysOriginal)
                    }
                    
                    if ((weath) == 1009){
                        self.image_weather.image = UIImage(systemName: "cloud.sun.fill")?.withTintColor(.orange,renderingMode: .alwaysOriginal)
                    }
                    
                    if ((weath) == 1030){
                        self.image_weather.image = UIImage(systemName: "sun.haze.fill")?.withTintColor(.purple, renderingMode: .alwaysOriginal)
                    }
                    
                    if ((weath) == 1114){
                        self.image_weather.image = UIImage(systemName: "cloud.snow.fill")?.withTintColor(.white, renderingMode: .alwaysOriginal)
                    }
                    
                    if ((weath) == 1135){
                        self.image_weather.image = UIImage(systemName: "cloud.fog")?.withTintColor(.cyan, renderingMode: .alwaysOriginal)
                    }
                    
                    if ((weath) == 1153){
                        self.image_weather.image = UIImage(systemName: "cloud.drizzle.fill")?.withTintColor(.green, renderingMode: .alwaysOriginal)
                    }
                    
                    if ((weath) == 1183){
                        self.image_weather.image = UIImage(systemName: "cloud.rain")?.withTintColor(.white, renderingMode: .alwaysOriginal)
                    }
                    
                    if ((weath) == 1189){
                        self.image_weather.image = UIImage(systemName: "cloud.rain.fill")?.withTintColor(.darkGray, renderingMode: .alwaysOriginal)
                    }
                    
                    if ((weath) == 1213){
                        self.image_weather.image = UIImage(systemName: "cloud.snow")?.withTintColor(.orange, renderingMode: .alwaysOriginal)
                    }
                    
                    
                    if((weath) == 1219){
                        
                        self.image_weather.image = UIImage(systemName: "cloud.snow.circle.fill")?.withTintColor(.blue, renderingMode: .alwaysOriginal)
                    }
                    if((weath) == 1030){
                        self.image_weather.image = UIImage(systemName: "smoke.fill")?.withTintColor(.gray, renderingMode: .alwaysOriginal)
                    }
                }
            }
        }
        dataTask.resume()
        }
//    In the peranthesis below we use whatever we search(search parameteer we use), which is a query
        
    private func getURL(query : String)-> URL? {
        let baseURL = "https://api.weatherapi.com/v1/"
        let currentEndpoint = "current.json"
        let apiKey = "c768bd8e53fc42f79dc23919221511"
//        TO ADD the special characters in addition to text like whitespaces ... we use .addingpercentEncoding(withAllcharacteers:...)
//        it allows the url query if it doesn't it returns nil
       guard  let url = "\(baseURL)\(currentEndpoint)?key=\(apiKey)&q=\(query)"
        .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
           return nil
       }
        
        print(url)
        
           
        return URL(string: url)
        
        
    }
    private func parseJSON(data:Data) -> WeatherResponse? {
        
        let decoder = JSONDecoder()
        var weather: WeatherResponse?
        
        do{
            weather = try decoder.decode(WeatherResponse.self, from: data)
            
        } catch {
            print("ERROR IN DECODING ")
        }
        return weather
    }
   
}

struct WeatherResponse: Decodable{
    let location : Location
    let current : Weather
}

struct Location: Decodable{
    let name: String
}
struct Weather: Decodable{
    let temp_c :Float
    let condition: WeatherCondition
    
}
struct WeatherCondition: Decodable{
    let text:String
    var code:Int
}


