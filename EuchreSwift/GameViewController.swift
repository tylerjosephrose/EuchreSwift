//
//  GameViewController.swift
//  EuchreSwift
//
//  Created by Tyler Rose on 12/11/16.
//  Copyright © 2016 Tyler Rose. All rights reserved.
//

import UIKit

class GameViewController: UIViewController {
	static private var m_gvcInstance: GameViewController?
	
	static func GetInstance() -> GameViewController{
		if m_gvcInstance == nil {
			m_gvcInstance = GameViewController()
		}
		return m_gvcInstance!
	}
	
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
		Deck.GetInstance().Return(card: sender.GetCard())
	}
	
	@IBOutlet weak var StartGameButtonVar: UIButton!
	@IBAction func StartGameButton(_ sender: UIButton) {
		/*sender.isHidden = true
		let startcheck = UIAlertController(title: "testTitle", message: "testMessage", preferredStyle: UIAlertControllerStyle.alert)
		
		startcheck.addAction(UIAlertAction(title: "Okay", style: .default, handler: { (action: UIAlertAction!) in
		print("Hit Okay button")
		}))
		
		present(startcheck, animated: true, completion: nil)*/
		StartGameButtonVar.isHidden = true
		StartGame()
	}
	
	@IBAction func HoldingCard(_ sender: CardButton) {
		UIView.animate(withDuration: 0.2, animations: {sender.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)})
	}
	
	@IBAction func ReleasedCard(_ sender: CardButton) {
		UIView.animate(withDuration: 0.2, animations: {sender.transform = CGAffineTransform(scaleX: 1, y: 1)})
	}
	
	let bvc = bidViewController.GetInstance()
	
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
		bvc.GetCurrentTrick().SetLeadPlayer(owner: Owner(rawValue: Int(lead))!)
		
		if game.m_teamOneScore! > game.winningScore || game.m_teamTwoScore! > game.winningScore {
			game.FinalizeGame()
		}
		game.numOfRounds += 1
		Deck.GetInstance().Shuffle()
		print("Round \(game.numOfRounds)")
		StartRound(Players: &Players)
		game.SetScore()
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		/*Deck.GetInstance().Shuffle()
		Buttons = [Card1Var, Card2Var, Card3Var, Card4Var, Card5Var, Card6Var]
		for i in 0...5 {
		Buttons?[i].SetUp(card: Deck.GetInstance().DrawCard())
		}*/
		GameViewController.m_gvcInstance = self
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	func PopOver() {
		let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "sbbidView") as! bidViewController
		self.addChildViewController(popOverVC)
		popOverVC.view.frame = self.view.frame
		self.view.addSubview(popOverVC.view)
		popOverVC.didMove(toParentViewController: self)
	}
	
	// Round Stuff
	func StartRound(Players: inout [Player]) {
		Players[0].GetHand()
		Players[1].GetHand()
		Players[2].GetHand()
		Players[3].GetHand()
		// Display the cards to the player
		Buttons = [Card1Var, Card2Var, Card3Var, Card4Var, Card5Var, Card6Var]
		for i in 0...5 {
			Buttons?[i].SetUp(card: Players[0].m_hand[i])
		}
		let player = bvc.GetBids(Players: &Players)
		bvc.FinalizeBid(playerBid: player, Players: &Players)
	}
	
}
