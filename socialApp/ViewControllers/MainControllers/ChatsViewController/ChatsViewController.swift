//
//  ListViewController.swift
//  socialApp
//
//  Created by Денис Щиголев on 05.07.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit
import SwiftUI
import FirebaseAuth


class ChatsViewController: UIViewController {
    
    private var collectionView: UICollectionView?
    private var dataSource: UICollectionViewDiffableDataSource<SectionsChats, MChat>?
    private var currentPeople: MPeople
    private var emptyView = EmptyView(imageName: "newsletter",
                                      header: MLabels.emptyAcceptChatHeader.rawValue,
                                      text: MLabels.emptyAcceptChatText.rawValue,
                                      buttonText: MLabels.emptyAcceptChatButton.rawValue,
                                      delegate: self,
                                      selector: #selector(emptyButtonTapped))
        
    weak var acceptChatDelegate: AcceptChatListenerDelegate?
    weak var likeDislikeDelegate: LikeDislikeListenerDelegate?
    weak var messageDelegate: MessageListenerDelegate?
    weak var requestChatsDelegate: RequestChatListenerDelegate?
    weak var peopleDelegate: PeopleListenerDelegate?
    weak var reportDelegate: ReportsListnerDelegate?
    
    init(currentPeople: MPeople,
         acceptChatDelegate: AcceptChatListenerDelegate?,
         likeDislikeDelegate: LikeDislikeListenerDelegate?,
         messageDelegate: MessageListenerDelegate?,
         requestChatsDelegate: RequestChatListenerDelegate?,
         peopleDelegate: PeopleListenerDelegate?,
         reportDelegate: ReportsListnerDelegate?) {
        
        self.currentPeople = currentPeople
        self.acceptChatDelegate = acceptChatDelegate
        self.likeDislikeDelegate = likeDislikeDelegate
        self.messageDelegate = messageDelegate
        self.requestChatsDelegate = requestChatsDelegate
        self.peopleDelegate = peopleDelegate
        self.reportDelegate = reportDelegate
        
        super.init(nibName: nil, bundle: nil)
        setupListeners()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        ListenerService.shared.removeAcceptChatsListener()
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationController()
        setupCollectionView()
        setupDataSource()
        loadSectionHedear()
        renewDataSource(searchText: nil)
        setupConstraint()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateCurrentPeople()
        tabBarController?.tabBar.isHidden = false
    }
    
    private func setupListeners() {
        acceptChatDelegate?.setupAcceptChatListener()
        NotificationCenter.addObsorverToCurrentUser(observer: self, selector: #selector(updateCurrentPeople))
        NotificationCenter.addObsorverToPremiumUpdate(observer: self, selector: #selector(premiumIsUpdated))
    }
    
  
    
    //MARK:  setupNavigationController
    private func setupNavigationController(){
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.backButtonTitle = ""
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
        searchController.searchBar.backgroundColor = .myWhiteColor()
        searchController.searchBar.barTintColor = .myWhiteColor()
        searchController.searchBar.placeholder = "Поиск по людям"
        searchController.searchBar.searchTextField.borderStyle = .roundedRect
        
        navigationItem.searchController = searchController
    }
    
    //MARK: checkPeopleNearbyIsEmpty
    private func checkPeopleNearbyIsEmpty()  {
        //if nearby people empty set
        guard let acceptChatDelegate = acceptChatDelegate?.acceptChats else { fatalError() }
        if acceptChatDelegate.isEmpty {
            emptyView.hide(hidden: false)
            navigationItem.searchController = nil
        } else {
            emptyView.hide(hidden: true)
            setupNavigationController()
        }
    }
    
    //MARK: objc
    
    @objc private func updateCurrentPeople() {
        if let people = UserDefaultsService.shared.getMpeople() {
            currentPeople = people
        }
    }
    
    @objc private func premiumIsUpdated() {
        // reloadDataSource(changeType: .update)
        print("Premium was updated on chats screen")
    }
    
    @objc private func emptyButtonTapped() {
        tabBarController?.selectedIndex = 0
    }
}

extension ChatsViewController {
    
    //MARK: - setupCollectionView
    private func setupCollectionView() {
        collectionView = UICollectionView(frame: view.bounds,
                                          collectionViewLayout: setupCompositionalLayout(isEmptyActiveSection: false,
                                                                                         isEmptyNewSection: false))
        
        guard let collectionView = collectionView else { fatalError("CollectionView is nil")}
        
        view.addSubview(collectionView)
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .myWhiteColor()
        collectionView.delegate = self
        
        collectionView.register(ActiveChatsCell.self, forCellWithReuseIdentifier: ActiveChatsCell.reuseID)
        collectionView.register(NewChatsCell.self, forCellWithReuseIdentifier: NewChatsCell.reuseID)
        collectionView.register(SectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SectionHeader.reuseId)
    }
    
    //MARK:  setupCompositionLayout
    private func setupCompositionalLayout(isEmptyActiveSection: Bool, isEmptyNewSection: Bool) -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            
            guard let section = SectionsChats(rawValue: sectionIndex) else { fatalError("Unknown section")}
            
            switch section {
            case .newChats:
                return self.createWaitingChatsLayout(isEmpty: isEmptyNewSection)
            case .activeChats:
                return self.createActiveChatsLayout(isEmpty: isEmptyActiveSection)
            }
        }
        return layout
    }
    
    //MARK:  createSectionHeader
    private func createSectionHeader() -> NSCollectionLayoutBoundarySupplementaryItem {
        let sectionSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                 heightDimension: .estimated(1))
        
        let item = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: sectionSize,
                                                               elementKind: UICollectionView.elementKindSectionHeader,
                                                               alignment: .top)
        
        return item
    }
    
    //MARK:  createActiveChatsLayout
    private func createActiveChatsLayout(isEmpty: Bool) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                              heightDimension: .fractionalHeight(1))
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let grupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                              heightDimension: .estimated(70))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: grupSize,
                                                       subitems: [item])
        

        
        let section = NSCollectionLayoutSection(group: group)
        
        if !isEmpty {
            let sectionHeader = createSectionHeader()
            section.boundarySupplementaryItems = [sectionHeader]
            section.interGroupSpacing = 40
            section.contentInsets = NSDirectionalEdgeInsets(top: 60,
                                                            leading: 20,
                                                            bottom: 0,
                                                            trailing: 20)
        }
        
        return section
    }
    
    //MARK:  createWaitingChatsLayout
    private func createWaitingChatsLayout(isEmpty: Bool) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                              heightDimension: .estimated(80))
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let grupSize = NSCollectionLayoutSize(widthDimension: .estimated(70),
                                              heightDimension: isEmpty ? .absolute(0.1) : .estimated(80))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: grupSize,
                                                       subitems: [item])
        
//        group.contentInsets = NSDirectionalEdgeInsets(top: 0,
//                                                      leading: 0,
//                                                      bottom: 0,
//                                                      trailing: 0)
        
        let section = NSCollectionLayoutSection(group: group)
        
        
        if !isEmpty {
            let sectionHeader = createSectionHeader()
            section.boundarySupplementaryItems = [sectionHeader]
            section.orthogonalScrollingBehavior = .continuous
            section.interGroupSpacing = 20
            section.contentInsets = NSDirectionalEdgeInsets(top: 40,
                                                            leading: 20,
                                                            bottom: 0,
                                                            trailing: 20)
        }
        return section
    }
}

//MARK:  DiffableDataSource
extension ChatsViewController {
    //MARK:  configure  cell
    private func configure<T: SelfConfiguringCell>(cellType: T.Type, currentUser: MPeople, value: MChat, indexPath: IndexPath) -> T {
        guard let cell = collectionView?.dequeueReusableCell(withReuseIdentifier: cellType.reuseID, for: indexPath) as? T else { fatalError("Can't dequeue cell type \(cellType)") }
        
        cell.configure(with: value,currentUser: currentUser)
        return cell
    }
    
    //MARK:  setupDataSource
    private func setupDataSource(){
        let strongCurrentPeople = currentPeople
        guard let collectionView = collectionView else { fatalError("CollectionView is nil")}
        dataSource = UICollectionViewDiffableDataSource<SectionsChats, MChat>(
            collectionView: collectionView,
            cellProvider: { [weak self] (collectionView, indexPath, chat) -> UICollectionViewCell? in
                
                guard let section = SectionsChats(rawValue: indexPath.section) else {
                    fatalError("Unknown Section")
                }
                
                switch section {
                case .activeChats:
                    return self?.configure(cellType: ActiveChatsCell.self,
                                           currentUser: strongCurrentPeople,
                                           value: chat,
                                           indexPath: indexPath)
                    
                case .newChats:
                    return self?.configure(cellType: NewChatsCell.self,
                                           currentUser: strongCurrentPeople,
                                           value: chat,
                                           indexPath: indexPath)
                }
            })
    }
    
    //MARK:  supplementaryViewProvider
    private func loadSectionHedear() {
        
        dataSource?.supplementaryViewProvider = {
            [weak self] collectionView, kind, indexPath in
            guard let reuseSectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SectionHeader.reuseId, for: indexPath) as? SectionHeader else { fatalError("Can't create new sectionHeader") }
            
            guard let section = SectionsChats(rawValue: indexPath.section) else { fatalError("Unknown section")}
            
            guard let itemsInSection = self?.collectionView?.numberOfItems(inSection: indexPath.section) else { fatalError("Can't get count of items")}
           
            reuseSectionHeader.configure(text: section.description(count: itemsInSection),
                                         font: .avenirRegular(size: 12),
                                         textColor: UIColor.myGrayColor())
            
            return reuseSectionHeader
        }
    }
    
    //MARK: renewDataSource
    private func renewDataSource(searchText: String?) {
        guard let sortedAcceptChats = acceptChatDelegate?.sortedAcceptChats else { fatalError("Can't get sorted accept chats")}
        checkPeopleNearbyIsEmpty()
        
        let filtredAcceptChats = sortedAcceptChats.filter { acceptChat -> Bool in
            acceptChat.contains(element: searchText)
        }
        
        let newChats = filtredAcceptChats.filter { filtredAcceptChat -> Bool in
            filtredAcceptChat.isNewChat
        }
        
        let activeChats = filtredAcceptChats.filter { filtredAcceptChat -> Bool in
            !filtredAcceptChat.isNewChat
        }
        
        if let dataSource = dataSource {
            
            //for correct update cell data in collectionView
            var snapshot = dataSource.snapshot()
            snapshot.deleteAllItems()
            snapshot.appendSections([.newChats, .activeChats])
            snapshot.appendItems(newChats, toSection: .newChats)
            snapshot.appendItems(activeChats, toSection: .activeChats)
            
            dataSource.apply(snapshot, animatingDifferences: false) { [weak self] in
               
                self?.collectionView?.collectionViewLayout.invalidateLayout()
                self?.collectionView?.layoutIfNeeded()
                self?.collectionView?.setCollectionViewLayout(self?.setupCompositionalLayout(isEmptyActiveSection: activeChats.isEmpty,
                                                                                             isEmptyNewSection: newChats.isEmpty) ?? UICollectionViewFlowLayout(),
                                                              animated: false)
            }
            
            
        } else {
            var snapshot = NSDiffableDataSourceSnapshot<SectionsChats,MChat>()
            snapshot.appendSections([.newChats, .activeChats])
            snapshot.appendItems(newChats, toSection: .newChats)
            snapshot.appendItems(activeChats, toSection: .activeChats)
            
            dataSource?.apply(snapshot, animatingDifferences: false, completion: { [weak self] in
                
                self?.collectionView?.collectionViewLayout.invalidateLayout()
                self?.collectionView?.layoutIfNeeded()
                self?.collectionView?.setCollectionViewLayout(self?.setupCompositionalLayout(isEmptyActiveSection: activeChats.isEmpty,
                                                                                             isEmptyNewSection: newChats.isEmpty) ?? UICollectionViewFlowLayout(),
                                                              animated: false)
                
            })
        }
    }
}

extension ChatsViewController: AcceptChatCollectionViewDelegate {
    //MARK:  reloadDataSource
    func reloadDataSource(changeType: MTypeOfListenerChanges){
        
        switch changeType {
        case .delete:
        //chat can be deleted only if user unmatch or timer to delete, when user unmatch people it is add to dislike collection
        //we need update dislike collection
            likeDislikeDelegate?.getDislike(complition: { _ in })
            fallthrough
        default:
            renewDataSource(searchText: nil)
            guard let sortedAcceptChats = acceptChatDelegate?.sortedAcceptChats else { fatalError("Can't get sorted accept chats")}
            //  if only one chat in collection, and this is update, need second renew, for correct update header (change new to active chat)
            if sortedAcceptChats.count == 1 {
                renewDataSource(searchText: nil)
            }
        }
    }
}

//MARK: UISearchBarDelegate
extension ChatsViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        renewDataSource(searchText: searchText)
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        renewDataSource(searchText: nil)
    }
}

//MARK: CollectionViewDelegate
extension ChatsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let section = SectionsChats(rawValue: indexPath.section) else { fatalError("Unknow section index")}
        guard let item = dataSource?.itemIdentifier(for: indexPath) else { fatalError(DataSourceError.unknownChatIdentificator.localizedDescription)}
        
        switch section {
        case .newChats:
            
            let chatVC = ChatViewController(people: currentPeople,
                                            chat: item,
                                            messageDelegate: messageDelegate,
                                            acceptChatDelegate: acceptChatDelegate,
                                            reportDelegate: reportDelegate,
                                            peopleDelegate: peopleDelegate,
                                            requestDelegate: requestChatsDelegate)
            chatVC.acceptChatDelegate = acceptChatDelegate
            navigationController?.pushViewController(chatVC, animated: true)
            FirestoreService.shared.updateLastActiveDate(id: currentPeople.senderId)
            
        case .activeChats:
            
            let chatVC = ChatViewController(people: currentPeople,
                                            chat: item,
                                            messageDelegate: messageDelegate,
                                            acceptChatDelegate: acceptChatDelegate,
                                            reportDelegate: reportDelegate,
                                            peopleDelegate: peopleDelegate,
                                            requestDelegate: requestChatsDelegate)
            chatVC.acceptChatDelegate = acceptChatDelegate
            navigationController?.pushViewController(chatVC, animated: true)
            FirestoreService.shared.updateLastActiveDate(id: currentPeople.senderId)
        }
    }
}

extension ChatsViewController {
    private func setupConstraint() {
        emptyView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(emptyView)
        
        NSLayoutConstraint.activate([
            emptyView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            emptyView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            emptyView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            emptyView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
        ])
    }
}
