//
//  GameViewController.swift
//  EuchreSwift
//
//  Created by Tyler Rose on 12/11/16.
//  Copyright © 2016 Tyler Rose. All rights reserved.
//

import UIKit

class GameViewController: UIViewController {
	
	@IBOutlet weak var Card1Var: CardButton!
	@IBOutlet weak var Card2Var: CardButton!
	@IBOutlet weak var Card3Var: CardButton!
	@IBOutlet weak var Card4Var: CardButton!
	@IBOutlet weak var Card5Var: CardButton!
	@IBOutlet weak var Card6Var: CardButton!
	private var Buttons: [CardButton]?
	
	@IBAction func CardSelected(_ sender: CardButton) {
		// Card was selected. Let model know and get out of UI
		//UIView.animate(withDuration: 0.2, animations: {sender.transform = CGAffineTransform(scaleX: 1/1.1, y: 1/1.1)})
		/*let point = CGPoint(x: Int(sender.frame.origin.x), y: Int(sender.frame.origin.y) - 20)
		let size = CGSize(width: sender.frame.size.width * 1.3, height: sender.frame.size.height * 1.3)
		UIView.animate(withDuration: 0.2, animations: {sender.frame = CGRect(origin: point, size: size)})*/
		print("The \(sender.GetCard().Print()) was selected")
		sender.isHidden = true
	}
	
	@IBAction func HoldingCard(_ sender: CardButton) {
		UIView.animate(withDuration: 0.2, animations: {sender.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)})
	}
	
	@IBAction func ReleasedCard(_ sender: CardButton) {
		UIView.animate(withDuration: 0.2, animations: {sender.transform = CGAffineTransform(scaleX: 1, y: 1)})
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		// Temporary stuff for testing
		Buttons = [Card1Var, Card2Var, Card3Var, Card4Var, Card5Var, Card6Var]
		print("\(Buttons!.count) Buttons")
		Deck.GetInstance().Shuffle()
		for i in 0...5 {
			print("Making button number \(i)")
			Buttons?[i].SetUp(card: Deck.GetInstance().DrawCard())
		}
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	
}
