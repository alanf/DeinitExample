//
//  ViewController.swift
//  DeinitExample
//
//  Created by Alan Fineberg on 1/19/17.
//  Copyright © 2017 Alan Fineberg. All rights reserved.
//

import UIKit
import ReactiveKit

class ViewController: UIViewController {

    fileprivate let foo: Property<Bool> = Property(false)
    fileprivate let bnd_bag = DisposeBag()
    
    deinit {
        NSLog("deinit of \(NSStringFromClass(type(of: self)))")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        foo
            .observeOn(DispatchQueue.main)
            .observeNext { foo in
                // not using self, yet it's got a strong reference for some reason
                
                UIView.animate(withDuration: 0.2, animations: { [weak self] in
                    self?.view.backgroundColor = foo ? UIColor.green : UIColor.lightGray
                })
                
        }.dispose(in: bnd_bag)
        
        DispatchQueue.global().after(when: 10) { 
            UIView.animate(withDuration: 0.2, animations: { [weak self] in
                self?.view.backgroundColor = self?.foo.value ?? false ? UIColor.green : UIColor.lightGray
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

