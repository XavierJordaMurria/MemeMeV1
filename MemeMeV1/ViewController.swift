//
//  ViewController.swift
//  MemeMe V1.0
//
//  Created by Xavier Jorda Murria on 19/09/2015.
//
//

import UIKit

class ViewController: UIViewController,UIImagePickerControllerDelegate, UITextFieldDelegate,
    UINavigationControllerDelegate
{
    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var topTextView: UITextField!
    @IBOutlet weak var bottomTextView: UITextField!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    @IBOutlet weak var bottomBar: UIToolbar!
    let TOP_TEXT_ID     = "TopTextField"
    let BOTTOM_TEXT_ID  = "BottomTextField"
    
    var topTextFirstFocus: Bool     = false
    var bottomTextFirstFocus: Bool  = false
    var showKeyBoardWithScreenMoved: Bool   = false
    var movedKeyBoardUp: Bool       = false
    var hideStatusBar: Bool         = false
    
    
    let memeTextAttributes =
    [
        NSStrokeColorAttributeName : UIColor.blackColor(),
        NSForegroundColorAttributeName : UIColor.whiteColor(),
        NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSStrokeWidthAttributeName : -8.0
    ]
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
         print("ViewController viewDidLoad")

        topTextView.delegate = self
        topTextView.defaultTextAttributes = memeTextAttributes
        topTextView.textAlignment = NSTextAlignment.Center
        topTextView.text = "TOP TEXT"
        
        bottomTextView.delegate = self
        bottomTextView.defaultTextAttributes = memeTextAttributes
        bottomTextView.textAlignment = NSTextAlignment.Center
        bottomTextView.text = "BOTTOM TEXT BOTTOM TEXT BOTTOM TEXT BOTTOM TEXT BOTTOM TEXT"
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DismissKeyboard")
        view.addGestureRecognizer(tap)
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        //disable save button till the user has pick up a photo
        shareButton.enabled = false
    }
    
    override func viewWillAppear(animated: Bool)
    {
        print("ViewController viewWillAppear")
        super.viewWillAppear(animated)
        
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(animated: Bool)
    {
        print("ViewController viewWillDisappear")
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prefersStatusBarHidden() -> Bool
    {
        return hideStatusBar
    }

    @IBAction func pickerButton(sender: AnyObject)
    {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        
        presentViewController(pickerController, animated: true, completion: nil)
    }
    
    @IBAction func cameraButton(sender: AnyObject)
    {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
        presentViewController(imagePicker, animated: true, completion: nil)
        
    }
    
    @IBAction func shareButton(sender: AnyObject)
    {
        save()
    }
    
    //Calls this function when the tap is recognized.
    func DismissKeyboard()
    {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
// MARK: - KeyBoard Notifications
    
    func subscribeToKeyboardNotifications()
    {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:"    , name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:"    , name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications()
    {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification)
    {
        print("ViewController keyboardWillShow with \(showKeyBoardWithScreenMoved), \(movedKeyBoardUp)")
        
        hideShowNavStatusBar(false);
        
        if(showKeyBoardWithScreenMoved && !movedKeyBoardUp)
        {
            view.frame.origin.y -= getKeyboardHeight(notification)
            movedKeyBoardUp = true
        }
    }
    
    func keyboardWillHide(notification: NSNotification)
    {
        hideShowNavStatusBar(false)
        
        print("ViewController keyboardWillHide with \(showKeyBoardWithScreenMoved), \(movedKeyBoardUp)")
        if(showKeyBoardWithScreenMoved && movedKeyBoardUp)
        {
            view.frame.origin.y += getKeyboardHeight(notification)
            movedKeyBoardUp = false
        }
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat
    {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
    }

// MARK: -

    func save()
    {
        //Create the meme
        let meme = MemeModel.init(topText: topTextView.text!, bottomText: bottomTextView.text!, image: imagePickerView.image!, memeImage: generateMemedImage())

        UIImageWriteToSavedPhotosAlbum(meme.getMemeStruct().memeImage!, nil, nil, nil);

        let shareText = "saved MEME"
        let activityViewController = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
        
        presentViewController(activityViewController,
                                animated: true,
                                completion:
                                nil)
    }
    
// MARK: - UIImagePickerControllerDelegate methods
    
    func imagePickerController(picker: UIImagePickerController,didFinishPickingMediaWithInfo info: [String : AnyObject])
    {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage
        {
            imagePickerView.image = image
            shareButton.enabled = true
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }

    func imagePickerControllerDidCancel(picker: UIImagePickerController)
    {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
// MARK: - UITextFieldDelegate
    func textFieldDidBeginEditing(textField: UITextField)
    {
        if let textID = textField.restorationIdentifier as String?
        {
            print("ID ==> \(textID)")
            
            if( textID == TOP_TEXT_ID)
            {
                if(!topTextFirstFocus)
                {
                    textField.text = ""
                }
                
                topTextFirstFocus = true
                showKeyBoardWithScreenMoved = false
            }
            else if( textID == BOTTOM_TEXT_ID)
            {
                if(!bottomTextFirstFocus)
                {
                    textField.text = ""
                }
                
                bottomTextFirstFocus = true
                showKeyBoardWithScreenMoved = true
            }
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        view.endEditing(true)
        return false
    }
    
    func textFieldDidEndEditing(textField: UITextField)
    {
         print("ViewController textFieldDidEndEditing")
        
    }
    
    func generateMemedImage() -> UIImage
    {
        hideShowNavStatusBar(true)
        
        // Render view to an image
        UIGraphicsBeginImageContext(view.frame.size)
        view.drawViewHierarchyInRect(view.frame, afterScreenUpdates: true)
        
        let memedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        hideShowNavStatusBar(false)
        
        return memedImage
    }
    
// MARK- PRIVATE METHODS
    private func hideShowNavStatusBar(hide: Bool)
    {
        if(hide)
        {
            hideStatusBar = true
            navigationController?.setNavigationBarHidden(navigationController?.navigationBarHidden == true, animated: true) //or animated: false
             navigationController?.setNavigationBarHidden(true, animated: true)
        }
        else
        {
            hideStatusBar = false
            navigationController?.setNavigationBarHidden(navigationController?.navigationBarHidden == false, animated: true) //or animated: false
             navigationController?.setNavigationBarHidden(false, animated: true)
        }
    }
}
