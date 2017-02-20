//
//  ViewController.swift
//  CodeTest-HomeDepot
//
//  Created by Karthik Yalamanchili on 2/17/17.
//  Copyright © 2017 Karthik Yalamanchili. All rights reserved.
//

import UIKit
import CoreData

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}

class ViewController: UIViewController {
    
    //Outlets
    @IBOutlet weak var fetchResultLabel: UILabel!
    @IBOutlet weak var aIndicator: UIActivityIndicatorView!
    @IBOutlet weak var fetchScreenValueTextFeild: UITextField!
    @IBOutlet weak var fetchButton: UIButton!
    @IBOutlet weak var primeSegmentControl: UISegmentedControl!
    @IBOutlet weak var listNPrimes: UIButton!
    @IBOutlet weak var listNumbersView: UITextView!
    @IBOutlet weak var listScreenTextFeild: UITextField!
    @IBOutlet weak var nthPrimeView: UIView!
    @IBOutlet weak var listView: UIView!
    
    //declarations
    var pNums = [Int]()
    var storageValues = [Int]()
    
   
    
    //we check the dividents of i
    func checkIfDivides(_ a: Int, _ b: Int) -> Bool {
        return a % b == 0
    }
    
    //we increment the count of divisors from the methos "checkIfDivides"
    func numberOfDivisorsCount(_ number: Int) -> Int {
        var cnt = 0
        for i in 1...number {
            if checkIfDivides(number, i) {
                cnt += 1
            }
        }
        return cnt
    }
    
    // method returns bool 
    func checkIfPrime(_ number: Int) -> Bool {
        return numberOfDivisorsCount(number) == 2
    }
    
    // this method handles the switch between the list view and fetch view
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        switch primeSegmentControl.selectedSegmentIndex
        {
        case 0:
            nthPrimeView.isHidden = true;
            listView.isHidden = false;
            
        case 1:
            
            nthPrimeView.isHidden = false;
            listView.isHidden = true;
        default:
            break;
        }
    }
    
    
    //with this method we check the number of record in DB
    func getCountFromDB() -> Int {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        print(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])
        let request  = NSFetchRequest<NSFetchRequestResult>(entityName:"StorePrime")
        request.returnsObjectsAsFaults = false
        var existingCount:Int = 0
        
        do {
            existingCount = try context.count(for: request)
            
        }
        catch{
            //error
        }
        return existingCount
    }
    
    
    // we check the current records in the DB . If the current array count is more than the reult array count then we append the extra set of values to the DB.
    @IBAction func saveCLicked(_ sender:AnyObject){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let alert = UIAlertController(title: "Alert", message: "List of Primes Saved Succesfully", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
        let existingRecordCount:Int = getCountFromDB()
        
        if(existingRecordCount > storageValues.count){
            return;
        }
        
        for i in existingRecordCount..<storageValues.count{
            let newList = NSEntityDescription.insertNewObject(forEntityName: "StorePrime", into: (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext)
            newList.setValue(storageValues[i], forKey: "primeNum")
            newList.setValue(i+1, forKey: "rowID")
        }
        
        do{
            try context.save()
            
            
        }
        catch{
            //error
        }
        print(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])

        
    }
    
    
    
    // We first check if the requested number of primes are in the cooredata container
    // if present we fetch the result from the DB or we run the loop to generate the primes
    @IBAction func displayNumbers(_ sender: UIButton) {
        
        listScreenTextFeild.resignFirstResponder()
        
        self.listNumbersView.text = ""
        
        
        
        let targetValue:String = self.primeSegmentControl.selectedSegmentIndex == 0 ? self.listScreenTextFeild.text!: self.fetchScreenValueTextFeild.text!
        self.listScreenTextFeild.text = targetValue
        
        if targetValue == ""{
            let alert = UIAlertController(title: "Alert", message: "Please Enter a Value", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        }
        else{
            self.aIndicator .startAnimating()
            
            let textFeildString:String = targetValue
            self.listScreenTextFeild.text = targetValue
            let N:Int = Int(textFeildString)!
            DispatchQueue.global().async {
                
                if(self.getCountFromDB()<N){
                    var i = 1
                    self.storageValues.removeAll()
                    
                    while self.storageValues.count < N{
                        
                        if self.checkIfPrime(i) {
                            self.storageValues.append(i);
                            
                        }
                        i += 1
                        
                    }
                }
                else{
                    
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    let context = appDelegate.persistentContainer.viewContext
                    
                    let request  = NSFetchRequest<NSFetchRequestResult>(entityName:"StorePrime")
                    request.returnsObjectsAsFaults = false
                    
                    request.fetchLimit = N
                    request.sortDescriptors = [NSSortDescriptor(key: "rowID",ascending: true)]
                    do {
                        let results = try context.fetch(request)
                        
                        //debug purpose
                        print("count %d",results.count)
                        
                        self.storageValues.removeAll()
                        if results.count>0{
                            for result in results as! [NSManagedObject]
                            {
                                self.storageValues.append(result.value(forKey: "primeNum") as! Int);
                                // debug purpose
                                print(results)
                                
                            }
                            
                            
                        }
                        
                    }
                    catch{
                       
                        // error handling
                    }
                    
                }
                DispatchQueue.main.async {
                    var str: String = ""
                    
                    for j in 0..<Int(targetValue)! {
                        
                        str += "\(self.storageValues[j])\n"
                        self.pNums = [self.storageValues[j]]
                        self.listNumbersView.text = str
                        
                    }
                    
                    if(sender == self.fetchButton){
                        
                        self.fetchResultLabel.text = String(format:" %d Prime Number : %d",self.storageValues.count,self.storageValues.last!);
                        
                    }
                    
                    self.aIndicator .stopAnimating()
                }
            }
        }
    }
    
    
    
    // we check if the requested Nth prime is in the DB,
    // if not we run the loop and fetch the Nth prime.
    @IBAction func fetchClicked(_ sender: Any) {
        
        aIndicator .startAnimating()
        
        fetchScreenValueTextFeild.resignFirstResponder()
        
        let feildString:String = self.fetchScreenValueTextFeild.text!
        let fetchNumber = Int(feildString)
        
        if self.fetchScreenValueTextFeild.text == ""{
            let alert = UIAlertController(title: "Alert", message: "Please Enter a Value", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return;
            
        }
        DispatchQueue.global().async {
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let request  = NSFetchRequest<NSFetchRequestResult>(entityName:"StorePrime")
            request.returnsObjectsAsFaults = false
            request.fetchLimit = 1
            request.predicate = NSPredicate(format: " rowID = %d",fetchNumber! )
            
            
            do {
                let results = try context.fetch(request)
                print("count %d",results.count)
                if results.count>0{
                    for result in results as! [NSManagedObject]
                    {
                        DispatchQueue.main.async {
                            
                            self.fetchResultLabel.text = String(format:" Prime Number %d is: %d",fetchNumber!,result.value(forKey: "primeNum") as! Int);
                            print(results)
                            self.aIndicator .stopAnimating()
                            
                        }
                    }
                    
                }
                else{
                    self.displayNumbers(sender as! UIButton)
                }
            }
            catch{
                //error handling
            }
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.persistentContainer.viewContext
        
        NotificationCenter.default.addObserver(self, selector: #selector(rotate), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    
    // to avoid textview scroll issue while orientation we scroll to top of the list when orientation changed
    func rotate() {
        
        listNumbersView.scrollRangeToVisible(NSMakeRange(0, 0));
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

