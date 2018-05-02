//
//  SettingsViewController.swift
//  ComprasUSA
//
//  Created by Luis Fernando Ravanelli Lopes on 21/04/2018.
//  Copyright © 2018 Luis Fernando Ravanelli Lopes. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications

// MARK: - Enumerators
enum StateType {
    case add
    case edit
}

// MARK: -
class SettingsViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tfDolar: UITextField!
    @IBOutlet weak var tfIOF: UITextField!
    
    // MARK: - Variables
    var nFormatter:  NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.decimalSeparator = Locale.current.decimalSeparator
        return formatter
    }()
    var dataSource : [State] = []
    
    // MARK: - Super Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        loadStates()
        NotificationCenter.default.addObserver(self, selector: #selector(loadUserDefault), name: NSNotification.Name(rawValue: "Retornou"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadUserDefault()
    }
    
    // MARK: - IBActions
    @IBAction func changeIOF(_ sender: UITextField) {
        guard let iof = nFormatter.number(from: tfIOF.text!)?.doubleValue else {return}
        UserDefaults.standard.set(nFormatter.string(from: iof as NSNumber), forKey: "iof")
    }
    
    @IBAction func changeDolar(_ sender: UITextField) {
        guard let dolar = nFormatter.number(from: tfDolar.text!)?.doubleValue else {return}
        UserDefaults.standard.set(nFormatter.string(from: dolar as NSNumber), forKey: "dolar")
    }
    
    @IBAction func addState(_ sender: UIButton) {
        showAlert(type: .add, state: nil)
    }

    // MARK: - Methods
    @objc func loadUserDefault() {
        if let sDolar = UserDefaults.standard.string(forKey: "dolar"), let dolar = nFormatter.number(from: sDolar)?.doubleValue {
            tfDolar.text = nFormatter.string(from: dolar as NSNumber)
        }
        if let sIOF = UserDefaults.standard.string(forKey: "iof"), let iof = nFormatter.number(from: sIOF)?.doubleValue {
            tfIOF.text = nFormatter.string(from: iof as NSNumber)
        }
    }
    
    func loadStates() {
        let fetchRequest: NSFetchRequest<State> = State.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        do {
            dataSource = try context.fetch(fetchRequest)
            tableView.reloadData()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func showAlert(type: StateType, state: State?) {
        let title = (type == .add) ? "Adicionar" : "Editar"
        let alert = UIAlertController(title: "\(title) Estado", message: nil, preferredStyle: .alert)
        
        
        let addAction = UIAlertAction(title: title, style: .default, handler: { (action: UIAlertAction) in
            var required = "Informações obrigatórias: "
            if alert.textFields?.first?.text == "" {
                required += "\n Estado"
            }
            if alert.textFields?.last?.text == "" {
                required += "\n Imposto"
            }
            if required != "Informações obrigatórias: "
            {
                let alert = UIAlertController(title: "\(title) Estado", message: required + "\n Não foi possivel salvar as informações", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else {
                if let tax = self.nFormatter.number(from: (alert.textFields?.last?.text)!)?.doubleValue {
                    let state = state ?? State(context: self.context)
                    state.name = alert.textFields?.first?.text
                    state.tax = tax
                    do {
                        try self.context.save()
                        self.loadStates()
                    } catch {
                        print(error.localizedDescription)
                    }
                } else {
                    let alert = UIAlertController(title: "\(title) Estado", message: "Imposto inválido \n Não foi possivel salvar as informações", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        })
        addAction.isEnabled = false;
        alert.addAction(addAction)
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
        
        alert.addTextField { (textField: UITextField) in
            textField.placeholder = "Nome do estado"
            if let name = state?.name {
                textField.text = name
            }
            NotificationCenter.default.addObserver(forName: .UITextFieldTextDidChange, object: textField, queue: OperationQueue.main, using: {_ in
                if let tax = self.nFormatter.number(from: (alert.textFields?.last?.text)!)?.doubleValue {
                    alert.textFields?.last?.textColor = .black
                    if textField.text != "" && tax > 0 {
                        addAction.isEnabled = true
                    }
                } else {
                    alert.textFields?.last?.textColor = .red
                    addAction.isEnabled = false
                }
                
            })
        }
        
        alert.addTextField { (textField: UITextField) in
            textField.placeholder = "Imposto"
            textField.keyboardType = .decimalPad
            if let tax = state?.tax {
                textField.text = self.nFormatter.string(from: tax as NSNumber)
            }
            NotificationCenter.default.addObserver(forName: .UITextFieldTextDidChange, object: textField, queue: OperationQueue.main, using: {_ in
                if let tax = self.nFormatter.number(from: textField.text!)?.doubleValue {
                    textField.textColor = .black
                    if alert.textFields?.first?.text != "" && tax > 0 {
                        addAction.isEnabled = true
                    }
                } else {
                    textField.textColor = .red
                    addAction.isEnabled = false
                }
                
                })
        }
        
        present(alert, animated: true, completion: nil)
    }

}

// MARK: - UITableViewDelegate
extension SettingsViewController: UITableViewDelegate {
//    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
//        let deleteAction = UITableViewRowAction(style: .destructive, title: "Excluir") { (action: UITableViewRowAction, indexPath: IndexPath) in
//            let state = self.dataSource[indexPath.row]
//            self.context.delete(state)
//            do {
//                try self.context.save()
//            } catch {
//                print(error.localizedDescription)
//            }
//            self.dataSource.remove(at: indexPath.row)
//            tableView.deleteRows(at: [indexPath], with: .fade)
//        }
//        return [deleteAction]
//    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let state = self.dataSource[indexPath.row]
            self.context.delete(state)
            do {
                try self.context.save()
            } catch {
                print(error.localizedDescription)
            }
            self.dataSource.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let state = dataSource[indexPath.row]
        showAlert(type: .edit, state: state)
        
    }
}

// MARK: - UITableViewDelegate
extension SettingsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! StatesTableViewCell
        let state = dataSource[indexPath.row]
        cell.lbState.text = state.name
        cell.lbTax.text = nFormatter.string(from: state.tax as NSNumber)
        return cell
        
    }
}
