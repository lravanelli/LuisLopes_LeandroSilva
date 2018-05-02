//
//  Calculator.swift
//  LuisLopes_LeandroSilva
//
//  Created by Luis Fernando Ravanelli Lopes on 30/04/2018.
//  Copyright © 2018 lravanelli. All rights reserved.
//

import Foundation

class Calculator{
    
    // MARK: - Singleton
    static let shared = Calculator()
    
    //MARK: - Super Method
    private init() {
    }
    
    //MARK: - Method
    func calculate (productValue: Double, tax: Double, card: Bool, iof: Double, dolar: Double) -> Double {
        var finalValue: Double
        finalValue = productValue + (productValue * tax)
        
        if card {
            finalValue += finalValue * iof
        }
        
        finalValue = finalValue * dolar
        
        return finalValue
    }
}
