//
//  ViewController.swift
//  ExitekProject
//
//  Created by Sergii Miroshnichenko on 05.09.2022.
//

import UIKit

enum Errors: Error {
    case notInMemory
    case notUniqueIMEI
}

class ViewController: UITableViewController, MobileStorage {
    
    var mobiles = [Mobile]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Mobiles List"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addMobile))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Find by IMEI", style: .plain, target: self, action: #selector(find))
        
        // crazy, but in protocol stubs was a set
        mobiles = Array(getAll())
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mobiles.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Mobile", for: indexPath)
        cell.textLabel?.text = mobiles[indexPath.row].model
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // 1: try loading the "Detail" view controller and typecasting it to be DetailViewController
        if let vc = storyboard?.instantiateViewController(withIdentifier: "Detail") as? DetailViewController {
            
            // 2: success! Set its selectedMobile property
            vc.selectedMobile = mobiles[indexPath.row].model
            vc.selectedImei = mobiles[indexPath.row].imei

            // 3: now push it onto the navigation controller
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            mobiles.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)

            saveList()
        }
    }
    
    @objc func addMobile() {
        let ac = UIAlertController(title: "Add Mobile", message: .none, preferredStyle: .alert)
        ac.addTextField()
        ac.addTextField()
        ac.addAction(UIAlertAction(title: "Add", style: .default) { [weak ac] _ in
            guard let newModel = ac?.textFields?[0].text else { return }
            guard let newImei = ac?.textFields?[1].text else { return }
            
            let mobile = Mobile(imei: newImei, model: newModel)
            
            self.addNewMobile(mobile)
        })
        present(ac, animated: true)
    }
    
    @objc func find() {
        let ac = UIAlertController(title: "Enter IMEI", message: .none, preferredStyle: .alert)
        ac.addTextField()
        ac.addAction(UIAlertAction(title: "Find", style: .default) { [weak ac] _ in
            if let imei = ac?.textFields?[0].text {
                let searchingMobile = self.findByImei(imei)
                let acNested = UIAlertController(title: "Your Mobile is:", message: .none, preferredStyle: .alert)
                acNested.addAction(UIAlertAction(title: "\((searchingMobile?.model ?? "Not found") as String)", style: .default))
                self.present(acNested, animated: true)
            }
        })
        present(ac, animated: true)
        
    }
    
    func addNewMobile(_ mobile: Mobile) {
        
        do {
            let newMobile = try save(mobile)
            mobiles.append(newMobile)
            tableView.reloadData()
            saveList()
        }
        catch {
            print("Phone with the same IMEI already exists")
        }
        
    }
    
    func saveList() {
        let jsonEncoder = JSONEncoder()
        if let savedData = try? jsonEncoder.encode(mobiles) {
            let defaults = UserDefaults.standard
            defaults.set(savedData, forKey: "mobiles")
        } else {
            print("Saved process is faild.")
        }
    }

    func getAll() -> Set<Mobile> {
        let defaults = UserDefaults.standard
        
        if let savedMobiles = defaults.object(forKey: "mobiles") as? Data {
            let jsonDecoder = JSONDecoder()
            do {
                mobiles = try jsonDecoder.decode([Mobile].self, from: savedMobiles)
            } catch {
                print("Failed to load mobiles list")
            }
        }
        return Set(mobiles)
    }
    
    func findByImei(_ imei: String) -> Mobile? {
        if !imei.isEmpty {
            for mobile in mobiles {
                if imei == mobile.imei {
                    return mobile
                }
            }
        }
        return nil
    }
    
    func save(_ mobile: Mobile) throws -> Mobile {
        for product in mobiles {
            if product.imei == mobile.imei {
                throw Errors.notUniqueIMEI
            } else {
                break
            }
        }
        return mobile
    }
    
    func delete(_ product: Mobile) throws {
        if mobiles.contains(product) {
            mobiles.remove(at: product.hashValue)
        } else {
            throw Errors.notInMemory
        }
    }
    
    func exists(_ product: Mobile) -> Bool {
        guard mobiles.contains(product) else { return false }
        return true
    }

}

