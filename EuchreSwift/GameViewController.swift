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
	
	
	// Start controls for the game
	func StartGame() {
		Deck.GetInstance().Shuffle()
		
		let game = Game()
		GameSettings.AllowHigh = true
		GameSettings.AllowLow = false
		GameSettings.ScrewTheDealer = true
		
		let Player1 = Player(player: .Player_1)
		let Player2 = Player(player: .Player_2)
		let Player3 = Player(player: .Player_3)
		let Player4 = Player(player: .Player_4)
		
		var Players = [Player1, Player2, Player3, Player4]
		
		game.m_teamOneScore = 0
		game.m_teamTwoScore = 0
		
		// Pick the player to lead
		let lead = (arc4random() % 4) + 1
		
		let WinningScore = 32
		if game.m_teamOneScore! > WinningScore || game.m_teamTwoScore! > WinningScore {
			game.FinalizeGame()
		}
		game.numOfRounds += 1
		Deck.GetInstance().Shuffle()
		print("Round \(game.numOfRounds)")
		let round = Round(LeadPlayer: Owner(rawValue: Int(lead))!)
		round.StartRound(Players: &Players)
		game.SetScore()
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		StartGame()

	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	
}
