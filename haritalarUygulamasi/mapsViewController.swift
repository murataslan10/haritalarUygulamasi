// Harita uygulamasi
// 1. islem haritayi telefona atadik
// 2.Kullanicidan konum bilgilerini iste ve al
// 3. Alinan konumu gosteriyorum
// 4. Isaret pin'ni koymak, haritaya tiklayarak ve
// 5.Secilen yerin ismini ve notunu almak
//6.Core Dataya kayit (Core Data Ayarlari)
//10. Pin gostermek
// 11. pin' in oldugu bolgeden baslam
// 12. Veri kaydedildikten sonra direk tableView acip veriyi gosterme
// 13. Pinin seklini degistirdik ve tiklanabilir yaptik
// 14. Pin ile konum arasi navigasyon almak

import UIKit
import MapKit // 1. işlem haritayi telefona tanimlamak
import CoreLocation // 2. islem kesin lokasyon
import CoreData //6.

class mapsViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate { // 1. ve 2. islem delegate
    
    @IBOutlet weak var notTextField: UITextField! // 5.
    @IBOutlet weak var isimTextField: UITextField!  // 5.
    @IBOutlet weak var mapView: MKMapView!    // 1.
    
    var locationManager = CLLocationManager() //2. islem konum yoneticisi atadik
    var secilenLatitude = Double ()  //6.
    var secilenLongitude = Double() //6.
    
    var secilenIsim = ""         // 9. Diger taraftan prepera segue yaparken ulasmak icin yapiliyor
    var secilenId : UUID?          // 9. """""
    
    var annaotationTitle = ""  // 10
    var annotationSubtitle = ""  // 10
    var annotationLatitude = Double()   // 10
    var annotationLongitude = Double() // 10
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self //1. islem
        locationManager.delegate = self // 2. islem
        locationManager.desiredAccuracy = kCLLocationAccuracyBest // 2. uygulamanin kullanicinin nerede oldugunu bulmasi icin yazilan kod
        locationManager.requestWhenInUseAuthorization() // 2. kullanicidan konum izni alinmasi
        locationManager.startUpdatingLocation() // 2.  Konumu guncellemesine basla
        // 2. info dan kullanici iznini al, mesajini yaz
        
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action:  #selector(konumSec(gestureRecognizer:)))      // 4. Islem
        gestureRecognizer.minimumPressDuration = 2         // 4. Islem
        mapView.addGestureRecognizer(gestureRecognizer)      //4. Islem
        
        if secilenIsim != ""{    //9. if secilen isim bos degil ise CORE DATA dan verileri cek
            if let uuidString = secilenId?.uuidString{
              
                let appDelegate = UIApplication.shared.delegate as! AppDelegate //9.
                let contex = appDelegate.persistentContainer.viewContext // 9.
                
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Yer")  // 10
                fetchRequest.predicate = NSPredicate(format: "id = %@", uuidString)  //10
                fetchRequest.returnsObjectsAsFaults = false // 10
                
                do{
                    let sonuclar = try contex.fetch(fetchRequest) // 10
                    if sonuclar.count > 0{
                        
                        for sonuc in sonuclar as! [NSManagedObject] { // 10
                            
                            if let isim = sonuc.value(forKey: "isim") as? String{ // 10
                                annaotationTitle = isim // 10
                                
                                if let not = sonuc.value(forKey: "not") as? String{ // 10
                                   annotationSubtitle = not  // 10
                                
                                    if let latitude = sonuc.value(forKey: "latitude") as? Double{ // 10
                                        annotationLatitude = latitude // 10
                                        if let longitude = sonuc.value(forKey: "longitude") as? Double{
                                            annotationLongitude = longitude  // 10
                                            // Hepsini sira ile sorguluyor
                                            
                                            let annotation = MKPointAnnotation()  // 10
                                            annotation.title = annaotationTitle    // 10
                                            annotation.subtitle = annotationSubtitle     // 10
                                            let coordinate = CLLocationCoordinate2D(latitude: annotationLatitude, longitude: annotationLongitude)  // 10
                                            annotation.coordinate = coordinate  // 10
                                            
                                            mapView.addAnnotation(annotation)  // 10
                                            isimTextField.text = annaotationTitle  // 10 // 10
                                            notTextField.text = annotationSubtitle   // 10
                                            
                                            locationManager.stopUpdatingLocation() // 11. guncelleme yapma
                                           
                                            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)      // 11.
                                            let region =  MKCoordinateRegion(center: coordinate, span: span) // 11
                                            mapView.setRegion(region, animated: true)
                                        }
                                    }
                                
                                }
                            }
                            
                            if let longitude = sonuc.value(forKey: "longitude") as? Double{
                                annotationLongitude = longitude  // 10
                            }
                        }
                    }
                    
                    
                }catch{
                    print("Hata")
                }
                
            }
        }else{   // 9. yeni veri eklmeye geldi
            
        }
        
        
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation{  // 13.
            return nil
        }
        let reuseId = "benimAnnotion"  // 13.
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) // 13.
        
        if pinView == nil { // 13.
            
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.canShowCallout = true // 13.
            pinView?.tintColor = .red   // 13.
            
            let button = UIButton(type: .detailDisclosure)  // 13.
            pinView?.rightCalloutAccessoryView = button    // 13.
            
        }else {
            pinView?.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) { // 14. yukaridaki call out tusuna basilinca neler olacak buraya yaziliyor
        if secilenIsim != "" { // 14. secilen isim bos degil
            
            let requestLocation = CLLocation(latitude: annotationLatitude, longitude:  annotationLongitude) // 14
            CLGeocoder().reverseGeocodeLocation(requestLocation) { (placemarkDizisi, hata) in //14
                
                if let placemarks = placemarkDizisi{ // 14 placemark dizisini opsiyonalden ckardim
                    if placemarks.count > 0 {
                      
                        let yeniPlacemark = MKPlacemark(placemark: placemarks[0]) // diziden 0 getir
                        let item = MKMapItem(placemark: yeniPlacemark)
                        item.name = self.annaotationTitle
                        
                        
                        let launchOptions = [MKLaunchOptionsDirectionsModeKey:   MKLaunchOptionsDirectionsModeDriving] //14 navi. acmak
                        item.openInMaps(launchOptions: launchOptions)
                        
                    }
                }
            }
        }
    }
    
    @objc func konumSec(gestureRecognizer : UILongPressGestureRecognizer) {     // 4. Islem= func. icinde gestureREcognizer'a ulasmak istiyorum
        if gestureRecognizer.state == .began {  // 4. Islem
            
            let dokunulanNokta = gestureRecognizer.location(in: mapView) // 4. Islem
            let dokunulanKoordinat = mapView.convert(dokunulanNokta, toCoordinateFrom: mapView)    // 4. Islem
           
            secilenLatitude = dokunulanKoordinat.latitude
            secilenLongitude = dokunulanKoordinat.longitude // 6. kaydetmek icin enlem ve boylami almamiz gerekiyor, dokunulan koordinattan aliyoruz
            
            let annotation = MKPointAnnotation()       // 4. Islem
            annotation.coordinate = dokunulanKoordinat  // 4. Islem
            annotation.title = isimTextField.text    // 5.Islem
            annotation.subtitle = notTextField.text    // 5. Islem
            mapView.addAnnotation(annotation)      // 4. Islem
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // aldigimiz kullanici konumlari uzerinde islem yapmamizi saglayan func.
        //print(locations[0].coordinate.latitude) // 2. kullanicinin boylami
        //print(locations[0].coordinate.longitude) // 2.  kullanicinin eylemi
        if secilenIsim == ""{ // 11.
        let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude) // 3. enlem ve boylamdan konum olusturmak
        let span = MKCoordinateSpan(latitudeDelta: 0.03  , longitudeDelta: 0.03) // 3. harita baslangici zoom in out
        let region = MKCoordinateRegion(center: location, span: span) // 3.
        mapView.setRegion(region, animated: true) // 3. bolgeyi degistir
        }
    }
    
    
    @IBAction func kaydetTiklandi(_ sender: Any) { // 6.
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate // 6.
        let context = appDelegate.persistentContainer.viewContext //6.
        
        let yeniYer = NSEntityDescription.insertNewObject(forEntityName: "Yer", into: context)  //6.
        
        yeniYer.setValue(isimTextField.text, forKey: "isim")
        yeniYer.setValue(notTextField.text, forKey: "not")
        yeniYer.setValue(secilenLongitude, forKey: "longitude")
        yeniYer.setValue(secilenLatitude, forKey: "latitude")
        yeniYer.setValue(UUID(), forKey: "id")
        
        do{
            try context.save()
            print("Kayit edildi")
        } catch {
            print("Hata")
        }
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "yeniYerOlusturuldu"), object: nil)
        navigationController?.popViewController(animated: true) // 12 verini
        
    }
    
}






