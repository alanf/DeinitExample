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



/// Schedules a timer on a queue when the view is loaded.
/// Also logs when deinit is invoked
class ViewControllerBase: UIViewController {
    let timer:DispatchSourceTimer = DispatchSource.makeTimerSource(flags: [], queue:  DispatchQueue(label: "q.q"))
    
    deinit {
        NSLog("deinit of \(NSStringFromClass(type(of: self)))")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timer.scheduleRepeating(deadline: .now(), interval: .seconds(1))
    }
}

/// SUBTLE MEMORY LEAK ILLUSTRATED
/// Which of the following `ViewController`s:
/// - Is retained for a long time (would leak memory if )?
/// - Compiles with an error?
/// - Is correct?

class ViewControllerA: ViewControllerBase {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timer.setEventHandler {
            UIView.animate(withDuration: 0.2) {
                self.view.backgroundColor = UIColor.green
            }
        }
    }
}

class ViewControllerB: ViewControllerBase {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timer.setEventHandler {
            UIView.animate(withDuration: 0.2) {
                NSLog("Hello")
            }
        }
    }
}

class ViewControllerC: ViewControllerBase {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timer.setEventHandler {
            UIView.animate(withDuration: 0.2) { [weak self] in
                NSLog("Hello")
            }
        }
    }
}

class ViewControllerD: ViewControllerBase {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timer.setEventHandler { [weak self] in
            UIView.animate(withDuration: 0.2) {
                self?.view.backgroundColor = UIColor.green
            }
        }
    }
}

class ViewControllerE: ViewControllerBase {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timer.setEventHandler {
            UIView.animate(withDuration: 0.2) { [weak self] in
                self?.view.backgroundColor = UIColor.green
            }
        }
    }
}

