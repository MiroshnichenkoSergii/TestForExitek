import UIKit

enum Errors: Error {
    case notExists
    case notUniqueIMEI
}

protocol MobileStorage {
    func getAll() -> Set<Mobile>
    func findByImei(_ imei: String) -> Mobile?
    func save(_ mobile: Mobile) throws -> Mobile
    func delete(_ product: Mobile) throws
    func exists(_ product: Mobile) -> Bool
}

struct Mobile: Hashable, Codable {
    let imei: String
    let model: String
}

class ListOfMobiles: MobileStorage {
    var mobiles = Set<Mobile>()
    
    func getAll() -> Set<Mobile> {
        let defaults = UserDefaults.standard
        if let savedMobiles = defaults.object(forKey: "mobiles") as? Data {
            let jsonDecoder = JSONDecoder()
            do {
                mobiles = try jsonDecoder.decode(Set<Mobile>.self, from: savedMobiles)
            } catch {
                print("Failed to load mobiles list")
            }
        }
        return Set(mobiles)
    }
    
    func findByImei(_ imei: String) -> Mobile? {
        for mobile in mobiles {
            if mobile.imei == imei {
                return mobile
            }
        }
        return nil
    }
    
    func save(_ mobile: Mobile) throws -> Mobile {
        for product in mobiles {
            if product.imei == mobile.imei {
                throw Errors.notUniqueIMEI
            } else {
                mobiles.update(with: mobile) ?? Mobile(imei: "some IMEI", model: "some Model")
                break
            }
        }
        return mobile
    }
    
    func delete(_ product: Mobile) throws {
        if mobiles.contains(product) {
            mobiles.remove(product)
        } else {
            throw Errors.notExists
        }
    }
    
    func exists(_ product: Mobile) -> Bool {
        guard mobiles.contains(product) else { return false }
        return true
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
}
