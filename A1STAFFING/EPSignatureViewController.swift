//
//  EPSignatureViewController.swift
//  A1STAFFING
//
//  Created by Dinesh Kunanayagam on 2017-11-24.
//  Copyright © 2017 Dinesh Kunanayagam. All rights reserved.
//

import UIKit

// MARK: - EPSignatureDelegate
@objc public protocol EPSignatureDelegate {
    @objc optional    func epSignature(_: EPSignatureViewController, didCancel error : NSError)
    @objc optional    func epSignature(_: EPSignatureViewController, didSign signatureImage : UIImage, boundingRect: CGRect)
}

open class EPSignatureViewController: UIViewController {

    
    // MARK: - IBOutlets
    @IBOutlet var viewMargin: UIView!
    @IBOutlet weak var signatureView: EPSignatureView!
    
    var sig : String="";
    var list=["Full Time","Part Time"];
    var first_name : String?
    var last_name : String?
    var address : String?
    var email : String?
    var phone_number : String?
    var category : String = ""
    var gender : String = ""
    var memo :String?
    
    @IBOutlet weak var txt_first_name: UITextField!
    @IBOutlet weak var txt_last_name: UITextField!
    @IBOutlet weak var txt_phone_number: UITextField!
    @IBOutlet weak var txt_email: UITextField!
    @IBOutlet weak var txt_address: UITextField!
    @IBOutlet weak var lbl_error: UILabel!
    @IBOutlet weak var btn_full: DLRadioButton!
    @IBOutlet weak var btn_part: DLRadioButton!
    @IBOutlet weak var btn_male: DLRadioButton!
    @IBOutlet weak var btn_female: DLRadioButton!
    @IBOutlet weak var txt_memo: UITextField!
    @IBOutlet weak var bor_label: UILabel!
    
    open var showsDate: Bool = true
    open var showsSaveSignatureOption: Bool = true
    open weak var signatureDelegate: EPSignatureDelegate?
    open var tintColor = UIColor.defaultTintColor()
    
    // MARK: - Life cycle methods
    
    
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        txt_first_name.setLeftPaddingPoints(10)
        txt_first_name.setRightPaddingPoints(10)
        
        txt_last_name.setLeftPaddingPoints(10)
        txt_last_name.setRightPaddingPoints(10)
        
        txt_phone_number.setLeftPaddingPoints(10)
        txt_phone_number.setRightPaddingPoints(10)
        
        txt_email.setLeftPaddingPoints(10)
        txt_email.setRightPaddingPoints(10)
        
        txt_address.setLeftPaddingPoints(10)
        txt_address.setRightPaddingPoints(10)
        
        txt_memo.setLeftPaddingPoints(10)
        txt_memo.setRightPaddingPoints(10)
        
        bor_label.layer.borderWidth = 0.5
        bor_label.layer.borderColor = UIColor.black.cgColor
       
    }
    
    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Initializers
    
    public convenience init(signatureDelegate: EPSignatureDelegate) {
        self.init(signatureDelegate: signatureDelegate, showsDate: true, showsSaveSignatureOption: true)
    }
    
    public convenience init(signatureDelegate: EPSignatureDelegate, showsDate: Bool) {
        self.init(signatureDelegate: signatureDelegate, showsDate: showsDate, showsSaveSignatureOption: true)
    }
    
    public init(signatureDelegate: EPSignatureDelegate, showsDate: Bool, showsSaveSignatureOption: Bool ) {
        self.showsDate = showsDate
        self.showsSaveSignatureOption = showsSaveSignatureOption
        self.signatureDelegate = signatureDelegate
        let bundle = Bundle(for: EPSignatureViewController.self)
        super.init(nibName: "EPSignatureViewController", bundle: bundle)
    }
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    // MARK: - Button Actions
    
    @IBAction func btn_male_action(_ sender: DLRadioButton) {
        if(sender.tag == 1){
            gender = "male"
        }else if(sender.tag == 2){
            gender = "female"
        }else{
            gender = ""
        }
    }
    
    @IBAction func btn_action(_ sender: DLRadioButton) {
        if(sender.tag == 1){
            category = "Full Time"
        }else if(sender.tag == 2){
            category = "Part Time"
        }else{
            category=""
        }
    }
    
    @IBAction func btn_clear(_ sender: Any) {
        signatureView.clear()
    }
    
    public func validateform() -> Int{
        first_name = txt_first_name.text
        if(first_name == nil){
            first_name = ""
        }
        
        last_name = txt_last_name.text
        if(last_name == nil){
            last_name = ""
        }
       
        email = txt_email.text
        if(email == nil){
            email = ""
        }
        
        phone_number = txt_phone_number.text
        if(phone_number == nil){
            phone_number = ""
        }
        
        address = txt_address.text
        if(address == nil){
            address = ""
        }
        
        memo = txt_memo.text
        if(memo == nil){
            memo = ""
        }
        
        if(first_name! != "" && last_name! != "" && phone_number! != "" && address! != "" && category != ""){
            return 1
        }else{
            return 0
        }
    }
    
    @IBAction func btn_saveform(_ sender: Any) {
        if(validateform() == 0){
            lbl_error.text="Please fill all required fields";
        }
        else if(validateform() == 1){
            lbl_error.text="";
            if let signature = signatureView.getSignatureAsImage(){
                sig = signatureView.converAsBase64()!
                signatureDelegate?.epSignature!(self, didSign: signature, boundingRect: signatureView.getSignatureBoundsInCanvas())
            }
            
            let inserviceUrl = "http://a1staffing.ca/insert.php"
            let inurl = URL(string: inserviceUrl)
            
            var request = URLRequest(url: inurl!)
            request.httpMethod = "POST"
            var dataString = "secretWord=44fdcv8jf3"
            
            dataString = dataString + "&first_name=\(first_name!)"
            dataString = dataString + "&last_name=\(last_name!)"
            dataString = dataString + "&main_phone=\(phone_number!)"
            dataString = dataString + "&main_email=\(email!)"
            dataString = dataString + "&address=\(address!)"
            dataString = dataString + "&category=\(category)"
            dataString = dataString + "&gender=\(gender)"
            dataString = dataString + "&memo=\(memo!)"
            dataString = dataString + "&stringnature=\(sig)"
            
            let dataD = dataString.data(using: .utf8)
            
            let insertEntry = URLSession.shared.uploadTask(with:request, from: dataD, completionHandler: { (data, response, error) in
                
                if error != nil {
                    DispatchQueue.main.async
                        {
                            let alert = UIAlertController(title: "Register Didn't Work?", message: "Looks like the connection to the server didn't work.  Do you have Internet access?", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                    }
                }
                else
                {
                    if let unwrappedData = data {
                        
                        let returnedData = NSString(data: unwrappedData, encoding: String.Encoding.utf8.rawValue)
                        
                        if returnedData == "1"
                        {
                            DispatchQueue.main.async
                                {
                                    let alert = UIAlertController(title: "Success", message: "Successfully registered", preferredStyle: .alert)
                                    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                                    self.present(alert, animated: true, completion: nil)
                                    
                                    self.cleanfields();
                            }
                        }
                        else
                        {
                            DispatchQueue.main.async
                                {
                                    let alert = UIAlertController(title: "Error", message: "Please try again later", preferredStyle: .alert)
                                    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                                    self.present(alert, animated: true, completion: nil)
                            }
                        }
                    }
                }
            })
            insertEntry.resume()
        }
    }
    
    public func cleanfields(){
        txt_first_name.text=""
        txt_last_name.text=""
        txt_email.text=""
        txt_phone_number.text=""
        txt_address.text=""
        txt_memo.text=""
        btn_full.isSelected=false
        btn_part.isSelected=false
        btn_male.isSelected=false
        btn_female.isSelected=false
        signatureView.clear()
    }    
    
    
    override open func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        signatureView.reposition()
    }
   
    
    
}



