//
//  ViewController.swift
//  pippopactivities
//
//  Created by Alex Thompson on 31/05/2015.
//  Copyright (c) 2015 Alex Thompson. All rights reserved.
//

import UIKit

class ActivitiesViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var MyCollectionView: UICollectionView!

    @IBOutlet weak var myPicker: UIPickerView!
    
    @IBOutlet weak var myLabel: UILabel!
    
    
    
    
    var data = ["body1", "cinderella1", "gingerbread1", "mask1", "cinderella1", "gingerbread1","body1", "cinderella1", "gingerbread1", "mask1", "cinderella1", "gingerbread1","body1", "cinderella1", "gingerbread1", "mask1", "cinderella1", "gingerbread1"]
    
    let pickerData = [
        ["Digital","Printable","Certificate"],
        ["Pink: 3 - 4 years","Red: 4 years","Yellow: 4 - 5 years","Blue: 4 - 6 years","Green: 5 - 6 years"]
    ]
    
    enum PickerComponent:Int{
        case size = 0
        case topping = 1
    }
    
    func updateLabel(){
        var sizeComponent = PickerComponent.size.rawValue
        let toppingComponent = PickerComponent.topping.rawValue
        let size = pickerData[sizeComponent][myPicker.selectedRowInComponent(sizeComponent)]
        let topping = pickerData[toppingComponent][myPicker.selectedRowInComponent(toppingComponent)]
        myLabel.text = "Pizza: " + size + " " + topping
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        println("\(self.description) loaded")
        // Do any additional setup after loading the view, typically from a nib.
        self.MyCollectionView.delegate = self
        self.MyCollectionView.dataSource = self
        myPicker.delegate = self
        myPicker.dataSource = self
        myPicker.selectRow(2, inComponent: PickerComponent.size.rawValue, animated: false)
        updateLabel()
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        updateLabel()
    }
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return pickerData.count
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData[component].count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return pickerData[component][row]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        println("Number of items in collection is \(self.data.count)")
        return data.count
    }

    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell: ActivityCell = collectionView.dequeueReusableCellWithReuseIdentifier("ActivityCellID", forIndexPath: indexPath) as! ActivityCell
        cell.ActivityTitle.text = data[indexPath.row]
        var imagename = data[indexPath.row] as String
        println("Image name is \(imagename)")
        cell.ActivityImage.image = UIImage(named: imagename)
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        println("Item \(data[indexPath.row]) Clicked")
        var vc: ActivityShowController = self.storyboard?.instantiateViewControllerWithIdentifier("ActivityShowID") as! ActivityShowController
        vc.name = data[indexPath.row]
        performSegueWithIdentifier("ActivityIndexToShowSegue", sender: self)
    }
    
}

