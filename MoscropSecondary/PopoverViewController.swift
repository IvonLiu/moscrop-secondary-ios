//
//  PopoverViewController.swift
//  
//
//  Created by Jason Wong on 2016-01-07.
//
//

import UIKit

class PopoverViewController: UIViewController {

    @IBOutlet var lightRadioButton: DLRadioButton!
    
    @IBOutlet var darkRadioButton: DLRadioButton!
    
    @IBOutlet var blackRadioButton: DLRadioButton!
    
    @IBOutlet var transRadioButton: DLRadioButton!
    
    @IBOutlet var cancelButton: UIButton!
    
    var theme = ThemeType.Light.rawValue
    
    var black = false

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view
         let defaults = NSUserDefaults.standardUserDefaults()
        
        if (defaults.objectForKey("Theme") != nil){
            theme = defaults.objectForKey("Theme") as! String
            if theme == ThemeType.Black.rawValue {
                black = true
            }
        }
        
        switch theme {
        case "Light":
            lightRadioButton.selected = true
        case "Dark":
            darkRadioButton.selected = true
        case "Black":
            blackRadioButton.selected = true
        case "Trans":
            transRadioButton.selected = true
        default:
            theme = ThemeType.Light.rawValue
            lightRadioButton.selected = true
        }
        
        cancelButton.tintColor = ThemeType(rawValue: theme)!.buttonColor

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func lightAction(sender: AnyObject) {
        promptRestart()
        updateTheme(ThemeType.Light)
    }
    
    @IBAction func darkAction(sender: AnyObject) {
        promptRestart()
        updateTheme(ThemeType.Dark)
    }
    
    
    @IBAction func blackAction(sender: AnyObject) {
        promptRestart()
        updateTheme(ThemeType.Black)
        
    }
    
    @IBAction func transAction(sender: AnyObject) {
        promptRestart()
        updateTheme(ThemeType.TransparentBlack)
    }
    @IBAction func cancelButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(false, completion: nil)
    }
    
    func updateTheme(themeType: ThemeType) {
        let defaults = NSUserDefaults.standardUserDefaults()
        theme = themeType.rawValue
        defaults.setObject(theme, forKey: "Theme")
        defaults.synchronize()
    }
    func promptRestart() {
        let title = "Restart Required"
        let message = "Please restart the application to fully update to the new selected theme!"
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        
        
        alert.addAction(defaultAction)
        
        presentViewController(alert, animated: true, completion: nil)
        print(self.view.tintColor == UIColor.whiteColor())
        if black {
            alert.view.tintColor = UIColor.blackColor()
            
        }
        
    }



}
