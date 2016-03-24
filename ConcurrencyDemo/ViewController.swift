//
//  ViewController.swift
//  ConcurrencyDemo
//
//  Created by Hossam Ghareeb on 11/15/15.
//  Copyright © 2015 Hossam Ghareeb. All rights reserved.
//

import UIKit

let imageURLs = ["http://www.planetware.com/photos-large/F/france-paris-eiffel-tower.jpg", "http://adriatic-lines.com/wp-content/uploads/2015/04/canal-of-Venice.jpg", "http://algoos.com/wp-content/uploads/2015/08/ireland-02.jpg", "http://bdo.se/wp-content/uploads/2014/01/Stockholm1.jpg"]

var queue = NSOperationQueue()

class Downloader {
  
  class func downloadImageWithURL(url:String) -> UIImage! {
    
    let data = NSData(contentsOfURL: NSURL(string: url)!)
    return UIImage(data: data!)
  }
}

class ViewController: UIViewController {
  
  @IBOutlet weak var imageView1: UIImageView!
  
  @IBOutlet weak var imageView2: UIImageView!
  
  @IBOutlet weak var imageView3: UIImageView!
  
  @IBOutlet weak var imageView4: UIImageView!
  
  @IBOutlet weak var sliderValueLabel: UILabel!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    
  }
  
  @IBAction func didClickOnCancel(sender: AnyObject) {
    
    // used for runOperationMethod2()
    queue.cancelAllOperations()
  }
  
  @IBAction func didClickOnStart(sender: AnyObject) {
    
    /***  Dispatch Queue (FIFO)***/
    
    // Concurrent dispatch queue , you don't konw order of execution  ***/
    
    //runConcurrentQueue()
    
    //    Serial dispatch queue
    //    1. Only one task to be executed at a time.
    //    2. Order of execution is img1~img4.
    //    3. Serial dispatch queue is slower than concurrent dispatch queue.
    
    //runSerialQueue()
    
    
    
    /***  Operation Queue (Not FIFO) ***/
    
    // This method is same as concurrent dispatch queue.
    
    runOperationMethod1()
    
    
    
    // This method show NSBlockOperation how to cancel operations and depend between two operations
    
    //runOperationMethod2()
    
  }
  
  @IBAction func sliderValueChanged(sender: UISlider) {
    
    self.sliderValueLabel.text = "\(sender.value * 100.0)"
  }
  
  
  func runConcurrentQueue(){
    
    let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
    
    dispatch_async(queue) { () -> Void in
      let img1 = Downloader.downloadImageWithURL(imageURLs[0])
      dispatch_async(dispatch_get_main_queue(), { () -> Void in
        self.imageView1.image = img1
      })
    }
    
    dispatch_async(queue) { () -> Void in
      let img2 = Downloader.downloadImageWithURL(imageURLs[1])
      dispatch_async(dispatch_get_main_queue(), { () -> Void in
        self.imageView2.image = img2
      })
    }
    
    dispatch_async(queue) { () -> Void in
      let img3 = Downloader.downloadImageWithURL(imageURLs[2])
      dispatch_async(dispatch_get_main_queue(), { () -> Void in
        self.imageView3.image = img3
      })
    }
    
    dispatch_async(queue) { () -> Void in
      let img4 = Downloader.downloadImageWithURL(imageURLs[3])
      dispatch_async(dispatch_get_main_queue(), { () -> Void in
        self.imageView4.image = img4
      })
    }
    
  }
  
  func runSerialQueue(){
    
    let serialQueue = dispatch_queue_create("com.appcoda.imagesQueue", DISPATCH_QUEUE_SERIAL)
    
    
    dispatch_async(serialQueue) { () -> Void in
      let img1 = Downloader.downloadImageWithURL(imageURLs[0])
      dispatch_async(dispatch_get_main_queue(), { () -> Void in
        self.imageView1.image = img1
      })
    }
    
    dispatch_async(serialQueue) { () -> Void in
      let img2 = Downloader.downloadImageWithURL(imageURLs[1])
      dispatch_async(dispatch_get_main_queue(), { () -> Void in
        self.imageView2.image = img2
      })
    }
    
    dispatch_async(serialQueue) { () -> Void in
      let img3 = Downloader.downloadImageWithURL(imageURLs[2])
      dispatch_async(dispatch_get_main_queue(), { () -> Void in
        self.imageView3.image = img3
      })
    }
    
    dispatch_async(serialQueue) { () -> Void in
      let img4 = Downloader.downloadImageWithURL(imageURLs[3])
      dispatch_async(dispatch_get_main_queue(), { () -> Void in
        self.imageView4.image = img4
      })
    }
  }
  
  
  func runOperationMethod1(){
    
    let queue = NSOperationQueue()
    
    queue.addOperationWithBlock { () -> Void in
      let img1 = Downloader.downloadImageWithURL(imageURLs[0])
      NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
        self.imageView1.image = img1;
      })
    }
    
    queue.addOperationWithBlock { () -> Void in
      let img2 = Downloader.downloadImageWithURL(imageURLs[1])
      NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
        self.imageView2.image = img2;
      })
    }
    
    queue.addOperationWithBlock { () -> Void in
      let img3 = Downloader.downloadImageWithURL(imageURLs[2])
      NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
        self.imageView3.image = img3;
      })
    }
    
    queue.addOperationWithBlock { () -> Void in
      let img4 = Downloader.downloadImageWithURL(imageURLs[3])
      NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
        self.imageView4.image = img4;
      })
    }
    
  }
  
  
  func runOperationMethod2(){
    queue = NSOperationQueue()
    let operation1 = NSBlockOperation(block: {
      let img1 = Downloader.downloadImageWithURL(imageURLs[0])
      NSOperationQueue.mainQueue().addOperationWithBlock({
        self.imageView1.image = img1
      })
    })
    
    operation1.completionBlock = {
      print("Operation 1 completed, cancelled:\(operation1.cancelled)")
    }
    
    queue.addOperation(operation1)
    
    
    
    let operation2 = NSBlockOperation(block: {
      let img2 = Downloader.downloadImageWithURL(imageURLs[1])
      NSOperationQueue.mainQueue().addOperationWithBlock({
        self.imageView2.image = img2
      })
    })
    
    operation2.completionBlock = {
      print("Operation 2 completed, cancelled:\(operation2.cancelled)")
    }
    
    //operation2 will start after operation1 finishes
    operation2.addDependency(operation1)
    
    queue.addOperation(operation2)
    
    let operation3 = NSBlockOperation(block: {
      let img3 = Downloader.downloadImageWithURL(imageURLs[2])
      NSOperationQueue.mainQueue().addOperationWithBlock({
        self.imageView3.image = img3
      })
    })
    
    operation3.completionBlock = {
      print("Operation 3 completed, cancelled:\(operation3.cancelled)")
    }
    
    //operation3 will start after operation2 finishes
    operation3.addDependency(operation2)
    
    queue.addOperation(operation3)
    
    let operation4 = NSBlockOperation(block: {
      let img4 = Downloader.downloadImageWithURL(imageURLs[3])
      NSOperationQueue.mainQueue().addOperationWithBlock({
        self.imageView4.image = img4
      })
    })
    
    operation4.completionBlock = {
      print("Operation 4 completed, cancelled:\(operation4.cancelled)")
    }
    
    queue.addOperation(operation4)
    
  }
  
}

