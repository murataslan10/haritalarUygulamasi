//
//  7. Kaydettigimiz datalari gostermek icin tableview olusturuyoruz
// 8. Datalari cekme ve gosterme
// 9. verileri tableView aktarma 


import UIKit
import CoreData

class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!    // 7.
    var isimDizisi = [String]()
    var idDizisi = [UUID]()
    
    var secilenYerIsmi = "" // 9. diger taraftaki isim ve id hazirlik
    var secilenYerId : UUID?
    
    override func viewDidLoad() {     // 7.
        super.viewDidLoad()        //7.

        tableView.delegate = self     // 7.
        tableView.dataSource = self     // 7.
        
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(artiButonuTiklandi))   // 7.  Navigation cont.
        
        veriAl()  // 8. islem veri cekme
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(veriAl), name: NSNotification.Name("yeniYerOlusturuldu"), object: nil)
    }
    
    
   @objc func veriAl(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate // 8. appDelegate cagirma
        let context = appDelegate.persistentContainer.viewContext  // 8. contex cagirma
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Yer") // 8. cekme istegi
        request.returnsObjectsAsFaults = false
        
        do{
            let sonuclar = try context.fetch(request) // 8.
            if sonuclar.count > 0 {      // 8. Eger sonuclar 0 dan buyuk ise
                
                isimDizisi.removeAll(keepingCapacity: false) // 8. for dongusune girmeden diziyi bosalttim
                idDizisi.removeAll(keepingCapacity: false)
                
                for sonuc in sonuclar as! [NSManagedObject] { //8.  any dizisini ns.. ceviriyoruz
                    if let isim = sonuc.value(forKey: "isim") as? String { // 8. str. cevirdim
                        isimDizisi.append(isim)
                    }
                    if let id = sonuc.value(forKey: "id") as? UUID{ // 8. cikanlari bir diziye kaydetmek gerekiyor
                        idDizisi.append(id)
                    }
                }
                tableView.reloadData() // 8. tableview'mu yeniliyorum
            }
        } catch{
            print("Hata")
        }
        
    }
    
    
    @objc func artiButonuTiklandi(){
        secilenYerIsmi = ""       // 9. yeni veri eklemeye geldigi belli olsun
      performSegue(withIdentifier: "toMapVC", sender: nil) //7.
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isimDizisi.count   // 7.
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()     // 7.
        cell.textLabel?.text = isimDizisi[indexPath.row]     // 7.
        return cell                  //7.
        
    }
   
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {  // 9. TableView da bir row tiklandimi ne olacak
        secilenYerIsmi = isimDizisi[indexPath.row] // 9. diger v.c deki dizileri getirdim ve ekledim
        secilenYerId = idDizisi[indexPath.row]
        performSegue(withIdentifier: "toMapVC", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {  //9. tableView da segue yapilicak
        if segue.identifier == "toMapVC" {
            let destinationVC = segue.destination as! mapsViewController
            destinationVC.secilenIsim = secilenYerIsmi  // 9. Veri aktarimi gerceklesti
            destinationVC.secilenId = secilenYerId
        }
    }
    
    
    
    
    
    
    
    
    
    
}
