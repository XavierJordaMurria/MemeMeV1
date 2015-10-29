//
//  MainMemeViewController.swift
//  MemeMe V1.0
//
//  Created by Xavier Jorda Murria on 19/09/2015.
//
//

import UIKit

class MainMemeViewController: UIViewController,UIImagePickerControllerDelegate, UITextFieldDelegate,
    UINavigationControllerDelegate
{
    let TOOL_BAR_HEIGHT:CGFloat = 44
    
    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var topTextView: UITextField!
    @IBOutlet weak var bottomTextView: UITextField!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var pickerBar: UIToolbar!
    
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
        
        setTextViewProperties(topTextView, textInit: "TOP TEXT")
        setTextViewProperties(bottomTextView, textInit: "BOTTOM TEXT BOTTOM TEXT BOTTOM TEXT BOTTOM TEXT BOTTOM TEXT")
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
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
    func dismissKeyboard()
    {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    func setTextViewProperties(text:UITextField, textInit:String)
    {
        text.delegate = self
        text.defaultTextAttributes = memeTextAttributes
        text.textAlignment = NSTextAlignment.Center
        text.text = textInit
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
        
        pickerBar.hidden = true
        
        if(showKeyBoardWithScreenMoved && !movedKeyBoardUp)
        {
            view.frame.origin.y -= (getKeyboardHeight(notification)-TOOL_BAR_HEIGHT)
            movedKeyBoardUp = true
        }
    }
    
    func keyboardWillHide(notification: NSNotification)
    {
        print("ViewController keyboardWillHide with \(showKeyBoardWithScreenMoved), \(movedKeyBoardUp)")
        
        pickerBar.hidden = false
        
        if(showKeyBoardWithScreenMoved && movedKeyBoardUp)
        {
            view.frame.origin.y += (getKeyboardHeight(notification)-TOOL_BAR_HEIGHT)
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
        
        UIImageWriteToSavedPhotosAlbum(meme.memeImage!, nil, nil, nil);
        
        let shareText = "saved MEME"
        let activityViewController = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
        
        presentViewController(activityViewController,
            animated: true,
            completion:
            { () -> Void in
                print("activityViewController onCompletion")
                self.hideShowNavStatusBar(false)
            })
 
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
        
        return memedImage
    }
    
    // MARK- PRIVATE METHODS
    private func hideShowNavStatusBar(hide: Bool)
    {
        print("hideShowNavStatusBar ==> \(hide)")
        if(hide)
        {
            hideStatusBar = true
            navigationController?.setNavigationBarHidden(navigationController?.navigationBarHidden == true, animated: true)
        }
        else
        {
            hideStatusBar = false
            navigationController?.setNavigationBarHidden(navigationController?.navigationBarHidden == false, animated: true)
        }
    }
}
