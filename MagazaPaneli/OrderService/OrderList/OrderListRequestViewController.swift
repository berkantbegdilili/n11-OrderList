//
//  OrderListRequestViewController.swift
//  MagazaPaneli
//
//  Created by Berkant Beğdilili on 30.05.2020.
//  Copyright © 2020 Berkant Beğdilili. All rights reserved.
//

import UIKit
import AEXML

class OrderListRequestViewController: UIViewController {


    @IBOutlet weak var appKey: UITextField!
    @IBOutlet weak var appSecret: UITextField!
    @IBOutlet weak var orderStatus: UITextField!
    @IBOutlet weak var orderNumber: UITextField!
    @IBOutlet weak var startDate: UITextField!
    @IBOutlet weak var endDate: UITextField!
    
    let orderStatusMenu = ["Yeni Siparişler",
                           "Onaylanmış Siparişler",
                           "İptal Edilmiş Siparişler",
                           "Kargolanmış Siparişler",
                           "Teslim Edilen Siparişler",
                           "Tamamlanmış Siparişler",
                           "İptal/İade/Değişim Durumundaki Siparişler",
                           "Kargolanması Geciken Siparişler"]

    override func viewDidLoad() {
        super.viewDidLoad()

        setupPickerView()
        setupDatePickers()
        
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let responseVC = segue.destination as! OrderListResponseViewController
        
        if sender != nil {
            let request = sender as! String
            responseVC.is_SoapMessage = request
        }
    }
    
    @IBAction func listing(_ sender: Any) {
        if appKey.text!.count > 0 && appSecret.text!.count > 0{
            
            var status:String?
            
            switch orderStatus.text {
                case "Yeni Siparişler": status = "New"
                case "Onaylanmış Siparişler": status = "Approved"
                case "İptal Edilmiş Siparişler": status = "Rejected"
                case "Kargolanmış Siparişler": status = "Shipped"
                case "Teslim Edilen Siparişler": status = "Delivered"
                case "Tamamlanmış Siparişler": status = "Completed"
                case "İptal/İade/Değişim Durumundaki Siparişler": status = "Claimed"
                case "Kargolanması Geciken Siparişler": status = "LATE_SHIPMENT"
        
                default :
                    break
            }
            
            let order = OrderListRequest(appKey: appKey.text!,
                                             appSecret: appSecret.text!,
                                             orderStatus: status ?? "",
                                             orderNumber: orderNumber.text ?? "",
                                             startDate: startDate.text ?? "",
                                             endDate: endDate.text ?? "")
            
            let sender = request(order: order)
            self.performSegue(withIdentifier: "requestToResponse", sender: sender)
            
        } else {
            let alert = UIAlertController(title: "HATA", message: "Lütfen Zorunlu Alanları Doldurunuz!", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Tamam", style: .default, handler: nil)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    func setupDatePickers(){
        startDate.setInputViewDatePicker(target: self, selector: #selector(startDatePickerTapDone))
        endDate.setInputViewDatePicker(target: self, selector: #selector(endDatePickerTapDone))
    }
    
    func setupPickerView(){
        orderStatus.setInputViewPickerView(target: self)
    }
    

   func request(order:OrderListRequest) -> String{
       guard
           let xmlPath = Bundle.main.path(forResource: "OrderListRequest", ofType: "xml"),
           let data = try? Data(contentsOf: URL(fileURLWithPath: xmlPath)) else { return String() }
       
       do {
           let xmlDoc = try AEXMLDocument(xml: data)
           
       
           for child1 in xmlDoc.root.children{
               for child2 in child1.children{
                   
                   child2["auth"]["appKey"].value = order.appKey
                   child2["auth"]["appSecret"].value = order.appSecret
                   child2["searchData"]["status"].value = order.orderStatus
                   child2["searchData"]["orderNumber"].value = order.orderNumber
                   child2["searchData"]["period"]["startDate"].value = order.startDate
                   child2["searchData"]["period"]["endDate"].value = order.endDate
                   
               }
           }
           return xmlDoc.xml
       } catch  {
           print(error)
           return String()
       }
   }
    
    // MARK: - Date Picker Tap Done (Selector)
      
      @objc func startDatePickerTapDone() {
          

          if let startDatePicker = self.startDate.inputView as? UIDatePicker {
            
              let dateformatter = DateFormatter()
                dateformatter.dateStyle = .medium
                dateformatter.dateFormat = "dd/MM/yyyy HH:mm"
            
              self.startDate.text = dateformatter.string(from: startDatePicker.date)
              
          }
        
          self.startDate.resignFirstResponder()
      }
    
    
    @objc func endDatePickerTapDone() {
        
        if let endDatePicker = self.endDate.inputView as? UIDatePicker {
          
            let dateformatter = DateFormatter()
              dateformatter.dateStyle = .medium
              dateformatter.dateFormat = "dd/MM/yyyy HH:mm"
          
            self.endDate.text = dateformatter.string(from: endDatePicker.date)
            
        }
        
        self.endDate.resignFirstResponder()
    }

}

    // MARK: - Set Input View in Textfield

extension UITextField {
    
    func setInputViewDatePicker(target: Any, selector: Selector) {
        
        let screenWidth = UIScreen.main.bounds.width
        let datePicker = UIDatePicker(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 216))
        datePicker.datePickerMode = .dateAndTime
        datePicker.locale = Locale(identifier: "Turkish")
        self.inputView = datePicker
        
        
        let toolBar = UIToolbar(frame: CGRect(x: 0.0, y: 0.0, width: screenWidth, height: 44.0))
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancel = UIBarButtonItem(title: "İptal", style: .plain, target: nil, action: #selector(tapCancel))
        cancel.tintColor = UIColor.init(displayP3Red: 0.543973, green: 0.127511, blue: 0.10608, alpha: 1)
        let barButton = UIBarButtonItem(title: "Tamam", style: .plain, target: target, action: selector)
        toolBar.setItems([cancel, flexible, barButton], animated: false)
        self.inputAccessoryView = toolBar
    }
    
    func setInputViewPickerView(target: Any) {
        
        let screenWidth = UIScreen.main.bounds.width
        let pickerView = UIPickerView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 216))
        pickerView.delegate = target as! OrderListRequestViewController
        pickerView.dataSource = target as! OrderListRequestViewController
        self.inputView = pickerView
        
        
        let toolBar = UIToolbar(frame: CGRect(x: 0.0, y: 0.0, width: screenWidth, height: 44.0))
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancel = UIBarButtonItem(title: "İptal", style: .plain, target: nil, action: #selector(tapCancel))
        cancel.tintColor = UIColor.init(displayP3Red: 0.543973, green: 0.127511, blue: 0.10608, alpha: 1)
        let barButton = UIBarButtonItem(title: "Tamam", style: .plain, target: nil, action: #selector(tapCancel))
        toolBar.setItems([cancel, flexible, barButton], animated: false)
        self.inputAccessoryView = toolBar
    }
    
    @objc func tapCancel() {
        self.resignFirstResponder()
    }
    
}

    // MARK: - UIPickerViewDelegate & UIPickerViewDateSource Protocols

extension OrderListRequestViewController : UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return orderStatusMenu.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return orderStatusMenu[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        orderStatus.text = orderStatusMenu[row]
    }
}
