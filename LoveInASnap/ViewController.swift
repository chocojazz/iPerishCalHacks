//
//  ViewController.swift
//  LoveInASnap
//
//  Created by Lyndsey Scott on 1/11/15
//  for http://www.raywenderlich.com/
//  Copyright (c) 2015 Lyndsey Scott. All rights reserved.
//

import UIKit
import Foundation

class ViewController: UIViewController, UITextViewDelegate, UINavigationControllerDelegate,UITableViewDataSource  {
  
  @IBOutlet weak var tableView: UITableView!
  
  var food_items_expiration_dict = [(key: String, value: Int)]()
  
  var food_expiration_dict = ["Instant coffee gold": 360,
                        "Orange juice 1.5l": 7,
                        "Rice crackers salt": 90,
                        "Plain margarine": 30,
                        "Free range eggs": 21]
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
  }
  
  @IBAction func takePhoto(_ sender: AnyObject) {
    
    // 1
    view.endEditing(true)
    // 2
    let imagePickerActionSheet = UIAlertController(title: "Snap/Upload Photo",
                                                   message: nil, preferredStyle: .actionSheet)
    // 3
    if UIImagePickerController.isSourceTypeAvailable(.camera) {
      let cameraButton = UIAlertAction(title: "Take Photo",
                                       style: .default) { (alert) -> Void in
                                        let imagePicker = UIImagePickerController()
                                        imagePicker.delegate = self
                                        imagePicker.sourceType = .camera
                                        self.present(imagePicker,
                                                                   animated: true,
                                                                   completion: nil)
      }
      imagePickerActionSheet.addAction(cameraButton)
    }
    // 4
    let libraryButton = UIAlertAction(title: "Choose Existing",
                                      style: .default) { (alert) -> Void in
                                        let imagePicker = UIImagePickerController()
                                        imagePicker.delegate = self
                                        imagePicker.sourceType = .photoLibrary
                                        self.present(imagePicker,
                                                                   animated: true,
                                                                   completion: nil)
    }
    imagePickerActionSheet.addAction(libraryButton)
    // 5
    let cancelButton = UIAlertAction(title: "Cancel",
                                     style: .cancel) { (alert) -> Void in
    }
    imagePickerActionSheet.addAction(cancelButton)
    // 6
    present(imagePickerActionSheet, animated: true,
                          completion: nil)
    
  }
  
  //let test_arr = ["hey", "there", "you", "amazing", "piece", "of", "shit"]
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "item_cell")!
    
    
    let current_item = food_items_expiration_dict[indexPath.row].key
    cell.textLabel?.text = current_item
      
    let val = food_items_expiration_dict[indexPath.row].value
    
    if val < 14 {
      cell.detailTextLabel?.textColor = UIColor(red: 0.90, green: 0.42, blue: 0.42, alpha: 1.0)
    }
    
    cell.detailTextLabel?.text = formattedDays(days: val)
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return food_items_expiration_dict.count
  }
  
  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == UITableViewCellEditingStyle.delete {
      food_items_expiration_dict.remove(at: indexPath.row)
      tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
    }
  }
//  
//  func getDateAfter(days: Int) -> String {
//    let date_after_val = (Calendar.current as NSCalendar).date(byAdding: .day, value: days, to: Date(), options: [])!
//    let dateFormatter = DateFormatter()
//    dateFormatter.locale = Locale(identifier: "en_US")
//    dateFormatter.dateFormat = "MMM d, yyyy"
//    let pretty_date_after_val = dateFormatter.string(from: date_after_val)
//    return pretty_date_after_val
//  }
  
  func formattedDays(days: Int) -> String {
    if days == 1 {
      return "1 day"
    } else if days < 7 {
      return "\(days) days"
    } else if (days / 7) < 4 {
      if (days / 7) == 1 {
        return "1 week"
      } else {
        return "\(days/7) weeks"
      }
    } else if (days / 30) < 12 {
      if (days/30) == 1 {
        return "1 month"
      } else {
        return "\(days/30) months"
      }
    } else {
      if (days/360) == 1 {
        return "1 year"
      } else {
        return "\(days/360) years"
      }
    }
  }
  
  func scaleImage(image: UIImage, maxDimension: CGFloat) -> UIImage {
    
    var scaledSize = CGSize(width: maxDimension, height: maxDimension)
    var scaleFactor: CGFloat
    
    if image.size.width > image.size.height {
      scaleFactor = image.size.height / image.size.width
      scaledSize.width = maxDimension
      scaledSize.height = scaledSize.width * scaleFactor
    } else {
      scaleFactor = image.size.width / image.size.height
      scaledSize.height = maxDimension
      scaledSize.width = scaledSize.height * scaleFactor
    }
    
    UIGraphicsBeginImageContext(scaledSize)
    image.draw(in: CGRect(x: 0, y: 0, width: scaledSize.width, height: scaledSize.height))
    let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return scaledImage!
  }
  
  func performImageRecognition(image: UIImage) {
    // 1
    let tesseract = G8Tesseract()
    // 2
    tesseract.language = "eng+fra"
    // 3
    tesseract.engineMode = .tesseractCubeCombined
    // 4
    tesseract.pageSegmentationMode = .auto
    // 5
    tesseract.maximumRecognitionTime = 60.0
    // 6
    tesseract.image = image.g8_blackAndWhite()
    tesseract.recognize()
    // 7
    var text_by_line = tesseract.recognizedText?.lines
    
    for item in text_by_line! {
      if item != "" && item.containsLetters() {
        var curr_item = item.lowercased()
        var characters = Array(curr_item.characters)
        characters[0] = Character(String(characters[0]).uppercased())

        var result_item = String(characters)
        
        if food_expiration_dict[result_item] != nil {
          let days_until_expiration = food_expiration_dict[result_item]!
          food_items_expiration_dict.append((key: result_item, value: days_until_expiration))
        }
        
      }

    }
    
    // sort
    food_items_expiration_dict = food_items_expiration_dict.sorted(by: {(first, second) -> Bool in return first.value < second.value})
    self.tableView.reloadData()
    
  }

}

extension ViewController: UIImagePickerControllerDelegate {
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    let selectedPhoto = info[UIImagePickerControllerOriginalImage] as! UIImage
    let scaledImage = scaleImage(image: selectedPhoto, maxDimension: 640)
    
    dismiss(animated: true, completion: {
      self.performImageRecognition(image: scaledImage)
    })

  }
  
}

extension String {
  var lines: [String] {
    var result: [String] = []
    enumerateLines { line, _ in result.append(line) }
    return result
  }
  
  func containsLetters() -> Bool
  {
    let numberRegEx  = ".*[A-Z].*"
    let testCase     = NSPredicate(format:"SELF MATCHES %@", numberRegEx)
    return testCase.evaluate(with: self)
  }
  
  func containsNumbers() -> Bool {
    let numberRegEx  = ".*[0-9].*"
    let testCase     = NSPredicate(format:"SELF MATCHES %@", numberRegEx)
    return testCase.evaluate(with: self)
  }


}


