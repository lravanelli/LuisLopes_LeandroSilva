//
//  ProductViewController.swift
//  ComprasUSA
//
//  Created by Luis Fernando Ravanelli Lopes on 21/04/2018.
//  Copyright © 2018 Luis Fernando Ravanelli Lopes. All rights reserved.
//

import UIKit
import CoreData

class ProductViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var tfName: UITextField!
    @IBOutlet weak var ivPhoto: UIImageView!
    @IBOutlet weak var tfState: UITextField!
    @IBOutlet weak var swCard: UISwitch!
    @IBOutlet weak var tfValue: UITextField!
    @IBOutlet weak var btAddUpdate: UIButton!
    
    // MARK: - Variables
    var fetchedResultController: NSFetchedResultsController<State>!
    var states : [State] = []
    var smallImage: UIImage!
    var product: Product!
    var pickerView: UIPickerView!
    var nFormatter:  NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.decimalSeparator = Locale.current.decimalSeparator
        return formatter
    }()
    
    // MARK: - Super Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        if product != nil {
            tfName.text = product.name
            if let state = product.states {
                tfState.text = state.name
            }
            tfValue.text = nFormatter.string(from: product.value as NSNumber)
            swCard.isOn = product.card
            if let image = product.photo as? UIImage {
                ivPhoto.image = image
                smallImage = image
            }
            btAddUpdate.setTitle("ATUALIZAR", for: .normal)
        }
        
        pickerView = UIPickerView()
        pickerView.backgroundColor = .white
        pickerView.delegate = self
        pickerView.dataSource = self
        
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 44))
        let btCancel = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        let btSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let btDone = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        toolbar.items = [btCancel, btSpace, btDone]
        tfState.inputView = pickerView
        tfState.inputAccessoryView = toolbar
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadStates()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - IBActions
    @IBAction func addPhoto(_ sender: UIButton) {
        let alert = UIAlertController(title: "Selecionar poster", message: "De onde você quer escolher o poster?", preferredStyle: .actionSheet)
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let cameraAction = UIAlertAction(title: "Câmera", style: .default, handler: { (action: UIAlertAction) in
                self.selectPicture(sourceType: .camera)
            })
            alert.addAction(cameraAction)
        }
        let libraryAction = UIAlertAction(title: "Biblioteca de fotos", style: .default) { (action: UIAlertAction) in
            self.selectPicture(sourceType: .photoLibrary)
        }
        alert.addAction(libraryAction)
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func addUpdateProduct(_ sender: UIButton) {
        var required = "Favor preencher o(s) campo(s): "
        if tfValue.text == "" {
            required = required + "\n Valor"
        }
        if tfState.text == "" {
            required = required + "\n Estado da Compra"
        }
        if smallImage == nil {
            required = required + "\n Foto"
        }
        if tfName.text == "" {
            required = required + "\n Nome"
        }
        
        if required != "Favor preencher o(s) campo(s): " {
            tfName.becomeFirstResponder()
            let alert = UIAlertController(title: "Campos Obrigatórios", message: required, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        } else {
            
             if let value = nFormatter.number(from: tfValue.text!)?.doubleValue {
                if product == nil {
                    product = Product(context: context)
                }
                product.name = tfName.text
                product.value = value
                product.card = swCard.isOn
                
                if let row = states.index(where: {$0.name == tfState.text!}) {
                    product.states = states[row]
                }
                
                if smallImage != nil {
                    product.photo = smallImage
                }
                do {
                    try context.save()
                } catch {
                    print(error.localizedDescription)
                }
                goBack()
            } else {
                if let title = btAddUpdate.titleLabel?.text! {
                let alert = UIAlertController(title: "\(title) PRODUTO", message: "Valor inválido", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            }
        }
    }
    
    
    // MARK: - Methods
    func loadStates()  {
        let fetchRequest: NSFetchRequest<State> = State.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        do {
            try states = context.fetch(fetchRequest)
            pickerView.reloadAllComponents()
        } catch {
            print(error.localizedDescription)
        }
        
        if product != nil {
            if let row = states.index(where: {$0.name == product.states?.name!}) {
                pickerView.selectRow(row, inComponent: 0, animated: false)
            }
        }
    }
    
    
    func selectPicture(sourceType: UIImagePickerControllerSourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = sourceType
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    
    @objc func cancel() {
        tfState.resignFirstResponder()
    }

    @objc func done() {
        if states.count > 0 {
            tfState.text = states[pickerView.selectedRow(inComponent: 0)].name
        }
        cancel()
    }
    
    func  goBack() {
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
}

// MARK: - UIImagePickerControllerDelegate
extension ProductViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            let perc = 345/image.size.width
            
            let smallSize = CGSize(width: 345, height: image.size.height*perc)
            UIGraphicsBeginImageContext(smallSize)
            image.draw(in: CGRect(x: 0, y: 0, width: smallSize.width, height: smallSize.height))
            smallImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            ivPhoto.image = smallImage
            dismiss(animated: true, completion: nil)
        }
    }
}

// MARK: - UIPickerViewDelegate
extension ProductViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return states[row].name
    }
}

// MARK: - UIPickerViewDataSource
extension ProductViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return states.count //O total de linhas será o total de itens em nosso dataSource
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension  ProductViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        pickerView.reloadAllComponents()
    }
}



