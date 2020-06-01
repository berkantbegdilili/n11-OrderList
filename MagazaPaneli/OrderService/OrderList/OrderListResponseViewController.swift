//
//  OrderServiceViewController.swift
//  MagazaPaneli
//
//  Created by Berkant Beğdilili on 30.05.2020.
//  Copyright © 2020 Berkant Beğdilili. All rights reserved.
//

import UIKit

class OrderListResponseViewController: UIViewController {


    var orderList = [OrderListResponse]()
    
    var elementName:String = String()
    var result:String = String()
    var citizenshipId:String = String()
    var createDate:String = String()
    var orderId:String = String()
    var orderNumber:String = String()
    var paymentType:String = String()
    var orderStatus:String = String()
    var errorMessage:String = String()

    var is_SoapMessage:String?
    
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let request = is_SoapMessage {
            
            response(is_SoapMessage: request)
            
            
            tableView.delegate = self
            tableView.dataSource = self
        }else {
            let alert = UIAlertController(title: "HATA", message: "İstek Gönderilemedi!", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Tamam", style: .default, handler: nil)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }
    
    }
    
    
    func response(is_SoapMessage:String){

            let is_URL: String = "https://api.n11.com/ws/OrderService.wsdl"

                let lobj_Request = NSMutableURLRequest(url: URL(string: is_URL)!)
                let session = URLSession.shared
            

                lobj_Request.httpMethod = "POST"
                lobj_Request.httpBody = is_SoapMessage.data(using: .utf8)
                lobj_Request.addValue("https://api.n11.com", forHTTPHeaderField: "Host")
                lobj_Request.addValue("text/xml; charset=utf-8", forHTTPHeaderField: "Content-Type")
                lobj_Request.addValue(String(is_SoapMessage.count), forHTTPHeaderField: "Content-Length")
            
            
                let task = session.dataTask(with: lobj_Request as URLRequest, completionHandler: { data, response, error -> Void in
                    let parser = XMLParser(data: data!)
                    parser.delegate = self
                    parser.parse()
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                    
                    if let e = error{
                        DispatchQueue.main.async {
                            let alert = UIAlertController(title: "HATA", message: "\(e)", preferredStyle: .alert)
                            let okAction = UIAlertAction(title: "Tamam", style: .default,handler: { _ in
                                self.navigationController!.popToRootViewController(animated: true)
                            })
                            alert.addAction(okAction)
                            self.present(alert, animated: true, completion: nil)
                        }
                    }

                })
                task.resume()
                     
    }

}
    
    
extension OrderListResponseViewController: UITableViewDelegate, UITableViewDataSource, XMLParserDelegate {
    
    // MARK: - UITableViewDelegate & UITableViewDataSource Protocols
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orderList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "OrderListTableViewCell", for: indexPath) as! OrderListTableViewCell
        
        let list = orderList[indexPath.row]
        
        cell.citizenshipId.text = list.citizenshipId
        cell.createDate.text = list.createDate
        cell.orderId.text = list.orderId
        cell.orderNumber.text = list.orderNumber
        cell.paymentType.text = list.paymentType
        cell.orderStatus.text = list.orderStatus
        
        return cell
    }
    
    // MARK: - XMLParserDelegate Protocol
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
            
            if elementName == "order" {
                
                citizenshipId = String()
                createDate = String()
                orderId = String()
                orderNumber = String()
                paymentType = String()
                orderStatus = String()
            }else if elementName == "errorMessage"{
                
                errorMessage = String()
            }
            
            self.elementName = elementName
        }
        
        func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
            
            if elementName == "order"{
                
                
                
                switch orderStatus {
                    case "1":
                        orderStatus = "İşlem Bekliyor"
                    case "2":
                        orderStatus = "İşlemde"
                    case "3":
                        orderStatus = "İptal Edilmiş"
                    case "4":
                        orderStatus = "Geçersiz"
                    case "5":
                        orderStatus = "Tamamlandı"
                    default:
                        break
                }
                
                switch paymentType {
                    case "1":
                        paymentType = "Kredi Kartı"
                    case "2":
                        paymentType = "BKMExpress"
                    case "6":
                        paymentType = "GarantiPay"
                    case "8":
                        paymentType = "MasterPass"
                    case "10":
                        paymentType = "Paycell"
                    default:
                        paymentType = "Diğer"
                }
                
                let order = OrderListResponse(citizenshipId: citizenshipId,
                                              createDate: createDate,
                                              orderId: orderId,
                                              orderNumber: orderNumber,
                                              paymentType: paymentType,
                                              orderStatus: orderStatus)
                
                orderList.append(order)
            }else if elementName == "errorMessage"{
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "HATA", message: "\(self.errorMessage)", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "Tamam", style: .default,handler: { _ -> Void in
                        self.navigationController!.popToRootViewController(animated: true)
                    })
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                }
                
            }
        }
    
        func parser(_ parser: XMLParser, foundCharacters string: String) {
             let data = string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)

               if (!data.isEmpty) {
                
                    if self.elementName == "citizenshipId" {
                       citizenshipId += data
                   } else if self.elementName == "createDate" {
                       createDate += data
                   } else if self.elementName == "id" {
                       orderId += data
                   } else if self.elementName == "orderNumber" {
                       orderNumber += data
                   } else if self.elementName == "paymentType" {
                       paymentType += data
                   } else if self.elementName == "status" {
                        orderStatus += data
                   } else if self.elementName == "errorMessage" {
                        errorMessage += data
                   }
                
               }
        }
    
}
