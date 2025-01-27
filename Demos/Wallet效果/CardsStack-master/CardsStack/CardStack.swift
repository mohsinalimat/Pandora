//
//  CardStack.swift
//  DynamicStackOfCards
//
//  Created by Pritesh Nandgaonkar on 9/24/16.
//  Copyright © 2016 pritesh. All rights reserved.
//

import Foundation
import UIKit

/// Struct for the UI information related to cards.
public struct Configuration {
    
    /// Offset(distance between the top of the consecutive cards) between the cards while the cards are in collapsed state
    public let cardOffset: CGFloat
    
    /// Height of the collection view when the cards are in collapsed state
    public let collapsedHeight:CGFloat
    
    /// Height of the collection view when the cards are in expanded state
    public let expandedHeight:CGFloat
    
    /// Height of the cards
    public let cardHeight: CGFloat
    
    /// The minimum threshold required for the cards to be dragged down when the cards are in expanded state
    public let downwardThreshold: CGFloat
    
    /// The minimum threshold required for the cards to be dragged up when the cards are in collapsed state
    public let upwardThreshold: CGFloat
    
    /// Vertical Spacing between the cards while the cards are in expanded state
    public let verticalSpacing: CGFloat
    
    /// Leading space for the cards
    public let leftSpacing: CGFloat
    
    /// Trailing space for the cards
    public let rightSpacing: CGFloat
    

    /// init
    ///
    /// - parameter cardOffset:        Offset(distance between the top of the consecutive cards) between the cards while the cards are in collapsed state
    /// - parameter collapsedHeight:   Height of the collection view when the cards are in collapsed state
    /// - parameter expandedHeight:    Height of the collection view when the cards are in expanded state
    /// - parameter cardHeight:        Height of the cards
    /// - parameter downwardThreshold: The minimum threshold required for the cards to be dragged down when the cards are in expanded state. Its an optional field. Default value is 20
    /// - parameter upwardThreshold:   The minimum threshold required for the cards to be dragged up when the cards are in collapsed state. Its an optional field. Default value is 20
    /// - parameter leftSpacing:       Leading space for the cards. Its not a required field, default value is 8
    /// - parameter rightSpacing:      Trailing space for the cards. Optional field, default value is 8
    /// - parameter verticalSpacing:   Leading space for the cards. Optional field, default value is 8
    ///
    /// - returns: Configuration
    public init(cardOffset: CGFloat, collapsedHeight: CGFloat, expandedHeight: CGFloat, cardHeight: CGFloat, downwardThreshold: CGFloat = 20, upwardThreshold: CGFloat = 20, leftSpacing: CGFloat = 8.0, rightSpacing: CGFloat = 8.0, verticalSpacing: CGFloat = 8.0) {
        self.cardOffset = cardOffset
        self.collapsedHeight = collapsedHeight
        self.expandedHeight = expandedHeight
        self.downwardThreshold = downwardThreshold
        self.upwardThreshold = upwardThreshold
        self.cardHeight = cardHeight
        self.verticalSpacing = verticalSpacing
        self.leftSpacing = leftSpacing
        self.rightSpacing = rightSpacing
    }
}

/// Enum for decribing the state of the cards
@objc public enum CardsPosition: Int {
    /// Case when the cards are collapsed
    case collapsed
    
    /// Case when the cards are expanded
    case expanded
}

/// Delegate to get hooks to interaction over cards
@objc public protocol CardsManagerDelegate {
    
    @objc optional func cardsPositionChangedTo(position: CardsPosition)
    @objc optional func tappedOnCardsStack(cardsCollectionView: UICollectionView)
    @objc optional func cardsCollectionView(_ cardsCollectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    @objc optional func cardsCollectionView(_ cardsCollectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath)
}

/// Class for initialising stack of cards
public class CardStack {
    
    public weak var delegate: CardsManagerDelegate? = nil {
        didSet {
            cardsManager.delegate = delegate
        }
    }
    internal var cardsManager = CardsManager()
    
    internal(set) var position: CardsPosition
    
    /// init
    /// uses config = Configuration(cardOffset: 40, collapsedHeight: 200, expandedHeight: 500, cardHeight: 200, downwardThreshold: 20, upwardThreshold: 20) in
    /// init(cardsState: .Collapsed, configuration: config, collectionView: nil, collectionViewHeight: nil)
    /// - returns: CardStack
    public convenience init() {
        let configuration = Configuration(cardOffset: 40, collapsedHeight: 200, expandedHeight: 500, cardHeight: 200, downwardThreshold: 20, upwardThreshold: 20)

        self.init(cardsState: .collapsed, configuration: configuration, collectionView: nil, collectionViewHeight: nil)
    }
    
    /// init
    ///
    /// - parameter cardsState:           Initial state of the cards
    /// - parameter configuration:        Instance of the Configuration, which holds the UI related information
    /// - parameter collectionView:       UICollectionView
    /// - parameter collectionViewHeight: NSLayoutConstraint, height constraint of the collectionview
    ///
    /// - returns: CardStack
    public init(cardsState: CardsPosition, configuration: Configuration, collectionView: UICollectionView?, collectionViewHeight: NSLayoutConstraint?) {
        
        position = cardsState
        cardsManager = CardsManager(cardState: cardsState, configuration: configuration, collectionView: collectionView, heightConstraint: collectionViewHeight)
        cardsManager.cardsDelegate = self
    }
    
    /// changeCardsPosition(to position: CardsPosition)
    /// This function can be called on CardStack to change the state of cardsStack. It can be used to programmatically change the states of the cards stack
    /// - parameter position: CardsPosition
    public func changeCardsPosition(to position: CardsPosition) {
        cardsManager.updateView(with: position)
    }
}
