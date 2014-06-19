//
//  AddIDDViewController.swift
//  IDD Dialer
//
//  Created by Raymond Lee on 12/6/14.
//  Copyright (c) 2014 RayCom. All rights reserved.
//

import UIKit

class AddIDDViewController: UIViewController {

    @IBOutlet var  iddTF:UITextField;
    @IBOutlet var  with00Siwtch:UISwitch;
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        // Custom initialization
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // #pragma mark - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */
    
    override func viewDidAppear(animated: Bool)  {
        iddTF.becomeFirstResponder()
    }
    
    @IBAction func hideAndBack(AnyObject){
        if(!iddTF.text.isEmpty){
            let iddRecord = IDDRecord(iddCode: iddTF.text, with00: with00Siwtch.on)
            NSNotificationCenter.defaultCenter().postNotificationName("AddIDDDone", object:nil, userInfo:["IDDRecord":iddRecord])
        }
        iddTF.resignFirstResponder()
        iddTF.text=""
        dismissViewControllerAnimated(true, completion:nil)
    }

}
