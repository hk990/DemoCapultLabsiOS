//
//  AddProductViewModel.swift
//  Geneto
//
//  Created by Hassan Khan on 10/04/2019.
//  Copyright © 2019 Mooncascade. All rights reserved.
//

import UIKit
import RealmSwift

protocol AddProductViewModelDelegate: class {
    func confirmSave(_ food: FoodItem?)
    func addComplete(_ food: FoodItem?)
    func cancelAdd()
    func showMessage(_ message: String)
    func moveForward(page: AddFormPage, viewModel: AddProductViewModel)
    func moveBack(viewModel: AddProductViewModel)
}

enum AddProductError: Error, LocalizedError {
    case invalidName
    case invalidProducerName
    case invalidPackageSizeName
    case invalidEnergy
    case invalidCarbs
    case invalidProteins
    case invalidFats
    var errorDescription: String? {
        switch self {
        case .invalidName: return L10n.addFormInvalidName
        case .invalidProducerName: return L10n.addFormInvalidProducerName
        case .invalidPackageSizeName: return L10n.addFormInvalidPackagesize
        case .invalidEnergy: return L10n.addFormInvalidEnergy
        case .invalidCarbs: return L10n.addFormInvalidCarbs
        case .invalidProteins: return L10n.addFormInvalidProtiens
        case .invalidFats: return L10n.addFormInvalidFats
        }
    }
}

class AddProductViewModel {
    weak var presentationDelegate: FoodAddingPresentationDelegate?
    weak var delegate: AddProductViewModelDelegate?
    private var deletedPhotos = [Photo]()
    private var deletedIngredients = [Ingredient]()
    var page: AddFormPage = .one
    let food: FoodItem
    var isEdit = false
    var title: String {
        switch page {
        case .one:
            return isEdit ? L10n.addFormEditProduct13 : L10n.addFormAddProduct13
        case .two:
            return isEdit ? L10n.addFormEditProduct23 : L10n.addFormAddProduct23
        case .three:
            return isEdit ? L10n.addFormEditProduct33 : L10n.addFormAddProduct33
        }
    }
    var name: String? {
        get { return food.name }
        set {
            food.name = newValue
            food.shortName = newValue
        }
    }
    var producerName: String? {
        get { return food.producerName }
        set { food.producerName = newValue }
    }
    var weightType: WeightUnitControlType = .g
    var packageSize: String {
        get {
            switch weightType {
            case .g:
                return "\(food.packageWeight.value ?? 0)"
            case .kg:
                return "\(food.packageWeight.value ?? 0)"
            case .ml:
                return "\(food.packageVolume.value ?? 0)"
            case .l:
                return "\(food.packageVolume.value ?? 0)"
            }
        }
        set {
            guard let pSize = Double(newValue) else {
                return
            }
            switch weightType {
            case .g:
                food.packageVolume.value = nil
                food.packageWeight.value =  pSize
            case .kg:
                food.packageVolume.value = nil
                food.packageWeight.value = pSize * 1000
            case .ml:
                food.packageWeight.value = nil
                food.packageVolume.value = pSize
                food.density.value = 1.0
            case .l:
                food.packageWeight.value = nil
                food.packageVolume.value = pSize * 1000
                food.density.value = 1.0
            }
        }
    }
    var tags: Results<Tag> {
        let realm = try! Realm()
        let predicate = NSPredicate(format: "typeRaw == %@", "contains")
        return realm.objects(Tag.self).filter(predicate)
    }
    var selectedTags: List<Int> {
        return food.tagIds
    }
    var energy: Double? {
        get { return food.calories.value }
        set {
            food.calories.value = newValue
        }
    }
    var carbs: Double? {
        get { return food.carbohydrates.value }
        set {
            food.carbohydrates.value = newValue
        }
    }
    var protein: Double? {
        get { return food.proteins.value }
        set {
            food.proteins.value = newValue
        }
    }
    var fats: Double? {
        get { return food.fats.value }
        set {
            food.fats.value = newValue
        }
    }
    var fibers: Double? {
        get { return food.fibers.value }
        set {
            food.fibers.value = newValue
        }
    }
    var fattyAcids: Double? {
        get { return food.saturatedFats.value }
        set {
            food.saturatedFats.value = newValue
        }
    }
    var sugar: Double? {
        get { return food.sugars.value }
        set {
            food.sugars.value = newValue
        }
    }
    var salt: Double? {
        get { return food.salt.value }
        set {
            food.salt.value = newValue
        }
    }
    var isRecommendedForBreakfast: Bool {
        get { return food.isRecommendedForBreakfast }
        set { food.isRecommendedForBreakfast = newValue }
    }
    var isRecommendedForLunch: Bool {
        get { return food.isRecommendedForLunch }
        set { food.isRecommendedForLunch = newValue }
    }
    var isRecommendedForDinner: Bool {
        get { return food.isRecommendedForDinner }
        set { food.isRecommendedForDinner = newValue }
    }
    var isRecommendedForSnack: Bool {
        get { return food.isRecommendedForSnack }
        set { food.isRecommendedForSnack = newValue }
    }
    var allowSharing: Bool {
        get { return food.crowdsourcingStatus == .waitingForReview }
        set { food.crowdsourcingStatus = newValue ? .waitingForReview : nil }
    }
    var photoURL: URL? {
        if let path = food.photos.first?.displayUrl {
            return URL(string: path)
        } else {
            return nil
        }
    }
    var density: Double? {
        get { return food.density.value }
        set {
            food.density.value = newValue
        }
    }
    init(model: FoodItem?, isEdit: Bool = false) {
        self.isEdit = isEdit
        if isEdit {
            food = model!
            let realm = try! Realm()
            try! realm.write {
                food.typeRaw = FoodItem.FoodType.product.rawValue
                food.statusRaw = FoodItem.Status.active.rawValue
            }
        } else {
            food = FoodItem()
            food.eanCode = model?.eanCode
            food.crowdsourcingStatus = .waitingForReview
            food.id = UUID().uuidString
            food.typeRaw = FoodItem.FoodType.product.rawValue
            food.statusRaw = FoodItem.Status.active.rawValue
        }
    }
    func updateImage(_ image: UIImage?) {
        food.photos
            .filter { $0.realm == nil }
            .forEach { $0.deleteLocalImage(fileManager: FileManager()) }
        deletedPhotos.append(contentsOf: food.photos.filter { $0.realm != nil })
        food.photos.removeAll()
        if let image = image {
            food.photos.append(Photo(from: image))
        }
    }
    func confirmDetails() -> Error? {
        save()
        return nil
    }
    func cancelAdd() {
        if let photo = food.photos.first, photo.realm == nil {
            photo.deleteLocalImage(fileManager: FileManager())
        }
        delegate?.cancelAdd()
    }
    func revert() {
        let realm = try! Realm()
        try! realm.write {
            realm.add(food, update: true)
        }
    }
    func save() {
        let realm = try! Realm()
        try! realm.write {
            let foodUnits = realm.objects(FoodUnit.self).filter("foodId = '\(food.apiId ?? "0")'")
            if foodUnits.first != nil {
                realm.delete(foodUnits)
            }
            food.isModified = true
            realm.add(food, update: true)
            realm.delete(deletedIngredients)
            deletedPhotos.forEach { $0.isDeleted = true }
        }
        delegate?.confirmSave(food)
    }
    func addComplete(_ addMeal: Bool) {
        if addMeal {
            delegate?.addComplete(food)
        } else {
            delegate?.addComplete(nil)
        }
    }
    func validate(page: AddFormPage) -> Bool {
        switch page {
        case .one:
            if (self.name?.isEmpty)! {
                delegate?.showMessage(AddFormError.invalidName.errorDescription ?? "")
                return false
            } else if (self.packageSize == "") || self.packageSize == "0.0" {
                delegate?.showMessage(AddFormError.invalidPackageSizeName.errorDescription ?? "")
                return false
            } else if ((Double(self.packageSize) ?? 0) > 0) {
                var weightCheck = false
                if (weightType == .g || weightType == .ml) {
                    weightCheck = (Double(self.packageSize) ?? 0) <= 99999
                    if (!weightCheck) {
                        delegate?.showMessage(L10n.newProductAlertLengthPackageSize)
                    }
                } else if (weightType == .kg || weightType == .l) {
                    weightCheck = ((Double(self.packageSize) ?? 0)/1000) <= 99
                    if (!weightCheck) {
                     delegate?.showMessage(L10n.newProductAlertLengthPackageSize)
                    }
                }
                return weightCheck
            }
        case .two:
            if (self.energy == nil) {
                delegate?.showMessage(AddFoodError.invalidEnergy.errorDescription ?? "")
                return false
            } else if (self.carbs == nil) {
                delegate?.showMessage(AddFoodError.invalidCarbs.errorDescription ?? "")
                return false
            } else if (self.protein == nil) {
                delegate?.showMessage(AddFoodError.invalidProteins.errorDescription ?? "")
                return false
            } else if (self.fats == nil) {
                delegate?.showMessage(AddFoodError.invalidFats.errorDescription ?? "")
                return false
            } else if (self.energy ?? 0) > 1000 {
                delegate?.showMessage(L10n.newProductAlertEnterEnergy)
                return false
            } else if (self.carbs ?? 0) > 100 {
                delegate?.showMessage(L10n.newProductAlertEnterCarbohydrates)
                return false
            } else if (self.protein ?? 0) > 100 {
                delegate?.showMessage(L10n.newProductAlertEnterProteins)
                return false
            } else if (self.fats ?? 0) > 100 {
                delegate?.showMessage(L10n.newProductAlertEnterFats)
                return false
            } else if (self.fibers ?? 0) > 100 {
                delegate?.showMessage(L10n.newProductAlertEnterFibers)
                return false
            } else if (self.fattyAcids ?? 0) > 100 {
                delegate?.showMessage(L10n.newProductAlertEnterFattyAcids)
                return false
            } else if (self.sugar ?? 0) > 100 {
                delegate?.showMessage(L10n.newProductAlertEnterSugar)
                return false
            } else if (self.salt ?? 0) > 100 {
                delegate?.showMessage(L10n.newProductAlertEnterSalt)
                return false
            } else if !(self.energy?.validateDecimalsMax(limit: 9) ?? false) {
                 delegate?.showMessage(L10n.newProductAlertEnterEnergyDecimal)
                return false
            } else if !(self.carbs?.validateDecimalsMax(limit: 999) ?? false) {
                delegate?.showMessage(L10n.newProductAlertEnterCarbohydratesDecimal)
                return false
            } else if !(self.protein?.validateDecimalsMax(limit: 999) ?? false) {
                delegate?.showMessage(L10n.newProductAlertEnterProteinsDecimal)
                return false
            } else if !(self.fats?.validateDecimalsMax(limit: 999) ?? false) {
                delegate?.showMessage(L10n.newProductAlertEnterFatsDecimal)
                return false
            } else if !(self.fibers?.validateDecimalsMax(limit: 999) ?? true) {
                delegate?.showMessage(L10n.newProductAlertEnterFibersDecimal)
                return false
            } else if !(self.fattyAcids?.validateDecimalsMax(limit: 999) ?? true) {
                delegate?.showMessage(L10n.newProductAlertEnterFattyAcidsDecimal)
                return false
            } else if !(self.sugar?.validateDecimalsMax(limit: 999) ?? true) {
                delegate?.showMessage(L10n.newProductAlertEnterSugarDecimal)
                return false
            } else if !(self.salt?.validateDecimalsMax(limit: 999) ?? true) {
                delegate?.showMessage(L10n.newProductAlertEnterSaltDecimal)
                return false
            }
        case .three:
            break
        }
        return true
    }
    func moveToNext(page: AddFormPage) {
        delegate?.moveForward(page: page,  viewModel: self)
    }
    func moveBack() {
        delegate?.moveBack(viewModel: self)
    }
    func setUnitForEdit() {
        let realm = try! Realm()
        food.units.removeAll()
        
        switch weightType {
        case .g:
            if let unit = realm.objects(Unit.self).filter("code == 'package_g'").first {
                let unit = FoodUnit(using: unit)
                unit.weight.value = Double(self.packageSize) ?? 0
                food.units.append(unit)
            } else {
                assertionFailure("Could not find an unit")
            }
        case .kg:
            if let unit = realm.objects(Unit.self).filter("code == 'package_g'").first {
                let unit = FoodUnit(using: unit)
                unit.isMultiplied = true
                unit.weight.value = Double(self.packageSize) ?? 0
                food.units.append(unit)
            } else {
                assertionFailure("Could not find an unit")
            }
        case .l:
            if let unit = realm.objects(Unit.self).filter("code == 'package_ml'").first {
                if let unit_ml = realm.objects(Unit.self).filter("code == 'ml'").first {
                    let unit = FoodUnit(using: unit)
                    let unit_ml = FoodUnit(using: unit_ml)
                    unit.isMultiplied = true
                    unit_ml.isMultiplied = true
                    unit_ml.volume.value = Double(self.packageSize) ?? 0
                    unit.volume.value = Double(self.packageSize) ?? 0
                    food.units.append(unit_ml)
                    food.units.append(unit)
                }
            } else {
                assertionFailure("Could not find an unit")
            }
        case .ml:
            if let unit = realm.objects(Unit.self).filter("code == 'package_ml'").first {
                if let unit_ml = realm.objects(Unit.self).filter("code == 'ml'").first {
                    let unit = FoodUnit(using: unit)
                    let unit_ml = FoodUnit(using: unit_ml)
                    unit.volume.value = Double(self.packageSize) ?? 0
                    food.units.append(unit_ml)
                    food.units.append(unit)
                }
            } else {
                assertionFailure("Could not find an unit")
            }
        }
    }
    
    func setUnit() {
        food.units.removeAll()
        let realm = try! Realm()
        switch weightType {
        case .g:
            if let unit = realm.objects(Unit.self).filter("code == 'package_g'").first {
                try! realm.write {
                    let unit = FoodUnit(using: unit)
                    unit.weight.value = Double(self.packageSize) ?? 0
                    food.units.append(unit)
                }
            } else {
                assertionFailure("Could not find an unit")
            }
        case .kg:
            if let unit = realm.objects(Unit.self).filter("code == 'package_g'").first {
                try! realm.write {
                    let unit = FoodUnit(using: unit)
                    unit.isMultiplied = true
                    unit.weight.value = Double(self.packageSize) ?? 0
                    food.units.append(unit)
                }
            } else {
                assertionFailure("Could not find an unit")
            }
        case .l:
            if let unit = realm.objects(Unit.self).filter("code == 'package_ml'").first {
                if let unit_ml = realm.objects(Unit.self).filter("code == 'ml'").first {
                    try! realm.write {
                        let unit = FoodUnit(using: unit)
                        let unit_ml = FoodUnit(using: unit_ml)
                        unit.isMultiplied = true
                        unit_ml.isMultiplied = true
                        unit_ml.volume.value = Double(self.packageSize) ?? 0
                        unit.volume.value = Double(self.packageSize) ?? 0
                        food.units.append(unit_ml)
                        food.units.append(unit)
                    }
                }
            } else {
                assertionFailure("Could not find an unit")
            }
        case .ml:
            if let unit = realm.objects(Unit.self).filter("code == 'package_ml'").first {
                if let unit_ml = realm.objects(Unit.self).filter("code == 'ml'").first {
                    try! realm.write {
                        let unit = FoodUnit(using: unit)
                        let unit_ml = FoodUnit(using: unit_ml)
                        unit.volume.value = Double(self.packageSize) ?? 0
                        food.units.append(unit_ml)
                        food.units.append(unit)
                    }
                }
            } else {
                assertionFailure("Could not find an unit")
            }
        }
    }
}
