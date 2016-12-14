//
//  bidViewController.swift
//  EuchreSwift
//
//  Created by Tyler Rose on 12/13/16.
//  Copyright © 2016 Tyler Rose. All rights reserved.
//

import UIKit

class bidViewController: UIViewController {
	static private var m_bvcInstance: bidViewController?
	
	static func GetInstance() ->bidViewController {
		if m_bvcInstance == nil {
			m_bvcInstance = bidViewController()
		}
		return m_bvcInstance!
	}

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		self.view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	var m_teamBid: Int?
	var m_bidAmount: Int?
	var m_currentBid: Int?
	var m_playerBid: Int?
	var m_currentTrick = Trick()
	
	func GetCurrentTrick() -> Trick {
		return m_currentTrick
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
				let gvc = GameViewController.GetInstance()
				gvc.PopOver()
				
				
				/*var bidView = UIAlertController()
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
				present(bidView, animated: true, completion: nil)*/
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
			let pickSuit = UIAlertController(title: "What Suit would you like?", message: "", preferredStyle: UIAlertControllerStyle.alert)
			
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
