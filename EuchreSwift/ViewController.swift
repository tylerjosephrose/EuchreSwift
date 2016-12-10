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
	
	func PrintToView(print: String) {
		PrintToUI.text = print
	}
	
	@IBAction func PressButton() {
		Main()
	}
	
	func Main() {
		let deck = Deck()
		deck.PrintDeck()
		let print = deck.PrintTest()
		PrintToView(print: print)
		//print("Pick a number 1 to 10")
		//let choice = readLine()
		//print("You chose \(choice)")
	}
	
	@IBOutlet weak var PrintToUI: UITextView!

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}


}

