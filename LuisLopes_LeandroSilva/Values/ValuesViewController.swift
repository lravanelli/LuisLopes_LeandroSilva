//
//  ValuesViewController.swift
//  ComprasUSA
//
//  Created by Luis Fernando Ravanelli Lopes on 21/04/2018.
//  Copyright © 2018 Luis Fernando Ravanelli Lopes. All rights reserved.
//

import UIKit
import CoreData

class ValuesViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var lbUS: UILabel!
    @IBOutlet weak var lbRS: UILabel!
    
    // MARK: - Variables
    var products: [Product] = []
    var calculator =  Calculator.shared
    var nFormatter:  NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 4
        formatter.usesGroupingSeparator = false
        return formatter
    }()
    
    // MARK: - Super Methods
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadProducts()
        var totalUS = 0.0
        var totalRS = 0.0
        nFormatter.decimalSeparator = Locale.current.decimalSeparator
        guard let sDolar = UserDefaults.standard.string(forKey: "dolar"), let dolar = nFormatter.number(from: sDolar)?.doubleValue else {return}
        guard let sIOF = UserDefaults.standard.string(forKey: "iof"), let iof = nFormatter.number(from: sIOF)?.doubleValue else {return}
        
        
//        if products.isEmpty == false {
//            for Product in products {
//                if let states = Product.states {
//                    for state in states.allObjects {
//                        let tax = (state as! State).tax
//                        totalUS += Product.value
//                        totalRS += calculator.calculate(productValue: Product.value, tax: tax/100, card: Product.card, iof: iof/100, dolar: dolar)
//                    }
//                }
//            }
//        }
        if products.isEmpty == false {
            for Product in products {
                guard let tax = Product.states?.tax else {return}
                totalUS += Product.value
                totalRS += calculator.calculate(productValue: Product.value, tax: tax/100, card: Product.card, iof: iof/100, dolar: dolar)
            }
        }
        
        nFormatter.decimalSeparator = Locale(identifier: "EN").decimalSeparator
        lbUS.text = nFormatter.string(from: NSNumber(value: totalUS))
        nFormatter.decimalSeparator = Locale.current.decimalSeparator
        lbRS.text = nFormatter.string(from: NSNumber(value: totalRS))
    }
    
    // MARK: - Methods
    func loadProducts()  {
        let fetchRequest: NSFetchRequest<Product> = Product.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        do {
            try products = context.fetch(fetchRequest)
        } catch {
            print(error.localizedDescription)
        }
    }
    
}
