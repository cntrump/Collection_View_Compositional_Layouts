/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A simple outline view for the sample apps main UI
*/

import UIKit

class OutlineViewController: UIViewController {

    enum Section {
        case main
    }

    class OutlineItem: Hashable {
        let title: String
        let indentLevel: Int
        let subitems: [OutlineItem]
        let outlineViewController: UIViewController.Type?

        var isExpanded = false

        init(title: String,
             indentLevel: Int = 0,
             viewController: UIViewController.Type? = nil,
             subitems: [OutlineItem] = []) {
            self.title = title
            self.indentLevel = indentLevel
            self.subitems = subitems
            self.outlineViewController = viewController
        }
        func hash(into hasher: inout Hasher) {
            hasher.combine(identifier)
        }
        static func == (lhs: OutlineItem, rhs: OutlineItem) -> Bool {
            return lhs.identifier == rhs.identifier
        }
        var isGroup: Bool {
            return self.outlineViewController == nil
        }
        private let identifier = UUID()
    }

    var dataSource: UICollectionViewDiffableDataSource<Section, OutlineItem>! = nil
    var outlineCollectionView: UICollectionView! = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Diffable + CompLayout"
        configureCollectionView()
        configureDataSource()
    }

    private lazy var menuItems: [OutlineItem] = {
        return [
            OutlineItem(title: "Compositional Layout", indentLevel: 0, subitems: [
                OutlineItem(title: "Getting Started", indentLevel: 1, subitems: [
                    OutlineItem(title: "List", indentLevel: 2, viewController: ListViewController.self),
                    OutlineItem(title: "Grid", indentLevel: 2, viewController: GridViewController.self),
                    OutlineItem(title: "Inset Items Grid", indentLevel: 2,
                                viewController: InsetItemsGridViewController.self),
                    OutlineItem(title: "Two-Column Grid", indentLevel: 2, viewController: TwoColumnViewController.self),
                    OutlineItem(title: "Per-Section Layout", indentLevel: 2, subitems: [
                        OutlineItem(title: "Distinct Sections", indentLevel: 3,
                                    viewController: DistinctSectionsViewController.self),
                        OutlineItem(title: "Adaptive Sections", indentLevel: 3,
                                    viewController: AdaptiveSectionsViewController.self)
                        ])
                    ]),
                OutlineItem(title: "Advanced Layouts", indentLevel: 1, subitems: [
                    OutlineItem(title: "Supplementary Views", indentLevel: 2, subitems: [
                        OutlineItem(title: "Item Badges", indentLevel: 3,
                                    viewController: ItemBadgeSupplementaryViewController.self),
                        OutlineItem(title: "Section Headers/Footers", indentLevel: 3,
                                    viewController: SectionHeadersFootersViewController.self),
                        OutlineItem(title: "Pinned Section Headers", indentLevel: 3,
                                    viewController: PinnedSectionHeaderFooterViewController.self)
                        ]),
                    OutlineItem(title: "Section Background Decoration", indentLevel: 2,
                                viewController: SectionDecorationViewController.self),
                    OutlineItem(title: "Nested Groups", indentLevel: 2,
                                viewController: NestedGroupsViewController.self),
                    OutlineItem(title: "Orthogonal Sections", indentLevel: 2, subitems: [
                        OutlineItem(title: "Orthogonal Sections", indentLevel: 3,
                                    viewController: OrthogonalScrollingViewController.self),
                        OutlineItem(title: "Orthogonal Section Behaviors", indentLevel: 3,
                                    viewController: OrthogonalScrollBehaviorViewController.self)
                        ])
                    ]),
                OutlineItem(title: "Conference App", indentLevel: 1, subitems: [
                    OutlineItem(title: "Videos", indentLevel: 2,
                                viewController: ConferenceVideoSessionsViewController.self),
                    OutlineItem(title: "News", indentLevel: 2, viewController: ConferenceNewsFeedViewController.self)
                    ])
            ]),
            OutlineItem(title: "Diffable Data Source", indentLevel: 0, subitems: [
                OutlineItem(title: "Mountains Search", indentLevel: 1, viewController: MountainsViewController.self),
                OutlineItem(title: "Settings: Wi-Fi", indentLevel: 1, viewController: WiFiSettingsViewController.self),
                OutlineItem(title: "Insertion Sort Visualization", indentLevel: 1,
                            viewController: InsertionSortViewController.self),
                OutlineItem(title: "UITableView: Editing", indentLevel: 1,
                            viewController: TableViewEditingViewController.self)
                ])
        ]
    }()
}

extension OutlineViewController {

    func configureCollectionView() {
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: generateLayout())
        view.addSubview(collectionView)
        collectionView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        collectionView.register(OutlineItemCell.self, forCellWithReuseIdentifier: OutlineItemCell.reuseIdentifer)
        self.outlineCollectionView = collectionView
    }

    func configureDataSource() {
        self.dataSource = UICollectionViewDiffableDataSource
            <Section, OutlineItem>(collectionView: outlineCollectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, menuItem: OutlineItem) -> UICollectionViewCell? in
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: OutlineItemCell.reuseIdentifer,
                for: indexPath) as? OutlineItemCell else { fatalError("Could not create new cell") }
            cell.label.text = menuItem.title
            cell.indentLevel = menuItem.indentLevel
            cell.isGroup = menuItem.isGroup
            cell.isExpanded = menuItem.isExpanded
            return cell
        }

        // load our initial data
        let snapshot = snapshotForCurrentState()
        self.dataSource.apply(snapshot, animatingDifferences: false)
    }

    func generateLayout() -> UICollectionViewLayout {
        let itemHeightDimension = NSCollectionLayoutDimension.absolute(44)
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: itemHeightDimension)
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: itemHeightDimension)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)

        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }

    func snapshotForCurrentState() -> NSDiffableDataSourceSnapshot<Section, OutlineItem> {
        var snapshot = NSDiffableDataSourceSnapshot<Section, OutlineItem>()
        snapshot.appendSections([Section.main])
        func addItems(_ menuItem: OutlineItem) {
            snapshot.appendItems([menuItem])
            if menuItem.isExpanded {
                menuItem.subitems.forEach { addItems($0) }
            }
        }
        menuItems.forEach { addItems($0) }
        return snapshot
    }

    func updateUI() {
        let snapshot = snapshotForCurrentState()
        dataSource.apply(snapshot, animatingDifferences: true)
    }

}

extension OutlineViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let menuItem = self.dataSource.itemIdentifier(for: indexPath) else { return }

        collectionView.deselectItem(at: indexPath, animated: true)
        if menuItem.isGroup {
            menuItem.isExpanded.toggle()
            if let cell = collectionView.cellForItem(at: indexPath) as? OutlineItemCell {
                UIView.animate(withDuration: 0.3) {
                    cell.isExpanded = menuItem.isExpanded
                    self.updateUI()
                }
            }
        } else {
            if let viewController = menuItem.outlineViewController {
                let navController = UINavigationController(rootViewController: viewController.init())
                present(navController, animated: true)
            }
        }
    }
}
