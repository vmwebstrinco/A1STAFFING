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
    
    @IBOutlet weak var txt_first_name: UITextField!
    // MARK: - Public Vars
    @IBOutlet weak var txt_last_name: UITextField!
    open var showsDate: Bool = true
    open var showsSaveSignatureOption: Bool = true
    open weak var signatureDelegate: EPSignatureDelegate?
    open var tintColor = UIColor.defaultTintColor()
    
    // MARK: - Life cycle methods
    
    override open func viewDidLoad() {
        super.viewDidLoad()
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
    
    
    
    @IBAction func btn_clear(_ sender: Any) {
        signatureView.clear()
    }
    
    
    @IBAction func btn_saveform(_ sender: Any) {
        if let signature = signatureView.getSignatureAsImage(){
            sig = signatureView.converAsBase64()!
            signatureDelegate?.epSignature!(self, didSign: signature, boundingRect: signatureView.getSignatureBoundsInCanvas())
        }
        
        let inserviceUrl = "http://a1staffing.ca/insert.php"
        let inurl = URL(string: inserviceUrl)
        
        var request = URLRequest(url: inurl!)
        request.httpMethod = "POST"
        var dataString = "secretWord=44fdcv8jf3"
        
        dataString = dataString + "&first_name=\(txt_first_name.text!)"
        dataString = dataString + "&last_name=\(txt_last_name.text!)"
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
    
    override open func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        signatureView.reposition()
    }
}



