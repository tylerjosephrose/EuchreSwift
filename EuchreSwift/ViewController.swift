//
//  ViewController.swift
//  EuchreSwift
//
//  Created by Tyler Rose on 12/9/16.
//  Copyright © 2016 Tyler Rose. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
	
	private var test = Card(value: Value.Nine, ofSuit: Suit.Hearts)
	

	@IBAction func Main() {
		let deck = Deck()
		deck.PrintDeck()
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}


}

