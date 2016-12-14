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
		m_currentTrick.SetLeadPlayer(owner: Owner(rawValue: Int(lead))!)
		
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
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	// Round Stuff
	var m_teamBid: Int?
	var m_bidAmount: Int?
	var m_currentBid: Int?
	var m_playerBid: Int?
	var m_currentTrick = Trick()
	
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
		GetBids(Players: &Players)
		//FinalizeBid(playerBid: player, Players: &Players)
	}
	
	func GetBids(Players: inout [Player]) -> Int {
		let lead = m_currentTrick.GetLeadPlayer().rawValue
		m_currentBid = 2
		var playerUp = 0
		var player = (lead - 1) % 4
		
		for i in 0...3 {
			playerUp = (lead + i) % 4
			if playerUp != 0 {
				let temp = m_currentBid
				Players[playerUp].myAI.AIBid(trick: m_currentTrick, player: Players[playerUp], currentBid: &m_currentBid!)
				if m_currentBid == 8 {
					FinalizeBid(playerBid: playerUp, Players: &Players)
					break
				}
				if temp != m_currentBid {
					player = playerUp
				}
			}
			else {
				var bidView = UIAlertController()
				if(self.m_currentBid! > 2) {
					bidView = UIAlertController(title: "How much would you like to bid?", message: "The current bid is: \(self.m_currentBid) by Player \(player + 1)", preferredStyle: UIAlertControllerStyle.alert)
				}
				else {
					bidView = UIAlertController(title: "How much would you like to bid?", message: "No one has bid yet", preferredStyle: UIAlertControllerStyle.alert)
				}
				
				if !(i == 3 && m_currentBid! == 2) {
					bidView.addAction(UIAlertAction(title: "0", style: .default, handler: { (action: UIAlertAction!) in
						self.m_currentBid = 2
					}))
				}
				else {
					bidView.message = "No one has bid and you dealt so you must bid!"
				}
				if !(m_currentBid! >= 3) {
					bidView.addAction(UIAlertAction(title: "3", style: .default, handler: { (action: UIAlertAction!) in
						self.m_currentBid = 3
					}))
				}
				if !(m_currentBid! >= 4) {
					bidView.addAction(UIAlertAction(title: "4", style: .default, handler: { (action: UIAlertAction!) in
						self.m_currentBid = 4
					}))
				}
				if !(m_currentBid! >= 5) {
					bidView.addAction(UIAlertAction(title: "5", style: .default, handler: { (action: UIAlertAction!) in
						self.m_currentBid = 5
					}))
				}
				if !(m_currentBid! >= 7) {
					bidView.addAction(UIAlertAction(title: "Shoot", style: .default, handler: { (action: UIAlertAction!) in
						self.m_currentBid = 7
					}))
				}
				if !(m_currentBid! >= 8) {
					bidView.addAction(UIAlertAction(title: "Alone", style: .default, handler: { (action: UIAlertAction!) in
						self.m_currentBid = 8
					}))
				}
				present(bidView, animated: true, completion: nil)
			}
		}
		m_playerBid = player
		m_bidAmount = m_currentBid
		return player
		//FinalizeBid(playerBid: player, Players: &Players)
	}
	
	func FinalizeBid(playerBid: Int, Players: inout [Player]) {
		switch playerBid {
		case 0:
			m_teamBid = 1
			break
		case 1:
			m_teamBid = 2
			break
		case 2:
			m_teamBid = 1
			break
		case 3:
			m_teamBid = 2
			break
		default:
			assert(true, "One of the teams should have made a bid (FinalizeBid)")
			break
		}
		
		if playerBid != 0 {
			Players[playerBid].myAI.AIFinalizeBid(trick: m_currentTrick)
			m_currentTrick.SetBidder(owner: Owner(rawValue: playerBid)!)
			for players in Players {
				players.SortHand(trump: m_currentTrick.GetTrump())
			}
			return
		}
		else {
			var pickSuit = UIAlertController(title: "What Suit would you like?", message: "", preferredStyle: UIAlertControllerStyle.alert)
			
			pickSuit.addAction(UIAlertAction(title: "♥️", style: .default, handler: { (action: UIAlertAction!) in
				self.m_currentBid = 2
			}))
			
			pickSuit.addAction(UIAlertAction(title: "♠️", style: .default, handler: { (action: UIAlertAction!) in
				self.m_currentBid = 3
			}))
			
			pickSuit.addAction(UIAlertAction(title: "♦️", style: .default, handler: { (action: UIAlertAction!) in
				self.m_currentBid = 4
			}))
			
			pickSuit.addAction(UIAlertAction(title: "♣️", style: .default, handler: { (action: UIAlertAction!) in
				self.m_currentBid = 5
			}))
			if GameSettings.AllowHigh == true {
				pickSuit.addAction(UIAlertAction(title: "High", style: .default, handler: { (action: UIAlertAction!) in
					self.m_currentBid = 7
				}))
			}
			if GameSettings.AllowLow == true {
				pickSuit.addAction(UIAlertAction(title: "Low", style: .default, handler: { (action: UIAlertAction!) in
					self.m_currentBid = 8
				}))
			}
			present(pickSuit, animated: true, completion: nil)
		}
		
		m_currentTrick.SetBidder(owner: Owner(rawValue: playerBid)!)
		for players in Players {
			players.SortHand(trump: m_currentTrick.GetTrump())
		}
	}
	
	func PlayTrick(Players: inout [Player]) {
		let lead = m_currentTrick.GetLeadPlayer().rawValue
		for i in 0...3 {
			let playerUp = (lead + i) % 4
			var good = 1
			if playerUp != 0 {
				Players[playerUp].myAI.AIPlayCard(trick: m_currentTrick, player: Players[playerUp])
			}
			else {
				while good != 0 {
					good = AskPlayCard(trick: m_currentTrick, player: Players[playerUp])
				}
			}
		}
	}
	
	private func PlayTrickLone(Players: inout [Player]) {
		let lead = m_currentTrick.GetLeadPlayer().rawValue
		
		for i in 0...3 {
			let playerUp = (lead + i) % 4
			if playerUp == (m_playerBid! + 2) % 4 {
				continue
			}
			var good = 1
			print("This is \(Players[playerUp].WhoAmI())")
			if playerUp != 0 {
				Players[playerUp].myAI.AIPlayCard(trick: m_currentTrick, player: Players[playerUp])
			}
			else {
				while good == 1 {
					good = AskPlayCard(trick: m_currentTrick, player: Players[playerUp])
				}
			}
		}
	}
	
	private func AskPlayCard(trick: Trick, player: Player) -> Int {
		print("Trump is \(trick.GetTrump())")
		print("The cards played so far are:")
		trick.PrintTrick()
		print("Pick what card number you want to play")
		player.PrintHand()
		let choice = 1
		// Get choice from UI
		let result = player.PlayCard(choice: choice, trick: m_currentTrick)
		if result == 1 {
			print("Did not follow Lead Suit of \(trick.GetLeadSuit())")
			return 1
		}
		else if result == 2 {
			print("Picked a card not in your hand")
			return 2
		}
		return 0
	}
	
	private func SetUpShoot(Players: inout [Player]) {
		let givingPlayer = (m_playerBid! + 2) % 4
		var tempCard: Card?
		if givingPlayer != 0 {
			tempCard = Players[givingPlayer].myAI.AIPassCard(trick: m_currentTrick, player: Players[givingPlayer])
		}
		else {
			print("Your teammate is shooting it in \(m_currentTrick.GetTrump())")
			print("What card will you give them?")
			Players[0].PrintHand()
			let choice = 1
			// Get choice from UI
			tempCard = Players[0].GiveCard(choice: choice)
		}
		
		// This part is for recieving the card
		if m_playerBid != 0 {
			Players[m_playerBid!].myAI.AITakeCard(trick: m_currentTrick, player: Players[m_playerBid!], card: tempCard!)
		}
		else {
			print("Player 1, your teammate is giving you the \(tempCard?.Print())")
			print("What card will you discard for it?")
			Players[0].PrintHand()
			let choice = 1
			// Get choice from UI
			Players[0].TakeCard(card: tempCard!, choice: choice)
			Players[0].SortHand(trump: m_currentTrick.GetTrump())
		}
		
		// Return the other Players hand to the deck
		if givingPlayer == 0 {
			for _ in 0...4 {
				let temp = Players[(m_playerBid! + 2) % 4].GiveCard(choice: 1)
				Deck.GetInstance().Return(card: temp)
			}
		}
	}
	
	func SetScore(team1Tricks: Int, team2Tricks: Int) {
		// Loner
		if m_bidAmount == 8 {
			if(m_teamBid == 1 && team1Tricks < 6) {
				Game.GetInstance().Points[0] = -12
				Game.GetInstance().Points[1] = team2Tricks
				return
			}
			else if m_teamBid == 2 && team2Tricks < 6 {
				Game.GetInstance().Points[0] = team1Tricks
				Game.GetInstance().Points[1] = -12
				return
			}
			else if m_teamBid == 1 {
				Game.GetInstance().Points[0] = 12
				return
			}
			else {
				Game.GetInstance().Points[1] = 12
				return
			}
		}
		
		// shoot
		if m_bidAmount == 7 {
			if(m_teamBid == 1 && team1Tricks < 6) {
				Game.GetInstance().Points[0] = -8
				Game.GetInstance().Points[1] = team2Tricks
				return
			}
			else if m_teamBid == 2 && team2Tricks < 6 {
				Game.GetInstance().Points[0] = team1Tricks
				Game.GetInstance().Points[1] = -8
				return
			}
			else if m_teamBid == 1 {
				Game.GetInstance().Points[0] = 8
				return
			}
			else {
				Game.GetInstance().Points[1] = 8
				return
			}
		}
		
		// team1 fails bid
		if m_teamBid == 1 && m_bidAmount! > team1Tricks {
			Game.GetInstance().Points[0] = m_bidAmount! * -1
			Game.GetInstance().Points[1] = team2Tricks
			return
		}
			
			// team 2 fails bid
		else if m_teamBid == 2 && m_bidAmount! > team2Tricks {
			Game.GetInstance().Points[0] = team1Tricks
			Game.GetInstance().Points[1] = m_bidAmount! * -1
			return
		}
			
			// either team completes the bid
		else {
			Game.GetInstance().Points[0] = team1Tricks
			Game.GetInstance().Points[1] = team2Tricks
			return
		}
	}
}
