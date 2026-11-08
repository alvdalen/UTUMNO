//
//  HomeViewController.swift
//  UTUMNO
//
//  Created by Adam Mirzakanov on 08.11.2026.
//

//import UIKit
//
//final class HomeViewController: BaseViewController<HomeView> {
//
//    // MARK: Private Properties
//    private let viewModel: HomeViewModel
//    private var isProgrammaticScroll = false
//    private var lastCardsWidth: CGFloat = 0
//    private var slideSnapshot: UIView?
//    private var slideToken = 0
//    private var cardsTarget = 0               // страница, на которой карточки стоят или к которой едут
//    private var isSelectionFromScroll = false // выбор пришёл от свайпа, а не от тапа по чипу
//
//    private var chips: UICollectionView { mainView.chipsCollectionView }
//    private var cards: UICollectionView { mainView.cardsCollectionView }
//
//    // MARK: Init
//    init(viewModel: HomeViewModel = HomeViewModel()) {
//        self.viewModel = viewModel
//        super.init(nibName: nil, bundle: nil)
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    // MARK: View Lifecycle
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        mainView.greetingLabel.text = viewModel.greeting
//        setupCollectionViews()
//        bindViewModel()
//    }
//
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//
//        // Размер карточки = размер коллекции, при смене ширины (поворот) пересчитываем
//        let width = cards.bounds.width
//        guard width > 0, width != lastCardsWidth else { return }
//        lastCardsWidth = width
//        cards.collectionViewLayout.invalidateLayout()
//        cards.scrollToItem(
//            at: IndexPath(item: viewModel.selectedIndex, section: 0),
//            at: .centeredHorizontally,
//            animated: false
//        )
//    }
//}
//
//// MARK: - Private Methods
//private extension HomeViewController {
//    func setupCollectionViews() {
//        chips.register(ExerciseChipCell.self, forCellWithReuseIdentifier: ExerciseChipCell.reuseIdentifier)
//        chips.dataSource = self
//        chips.delegate = self
//        chips.delaysContentTouches = false
//
//        cards.register(ExerciseCardCell.self, forCellWithReuseIdentifier: ExerciseCardCell.reuseIdentifier)
//        cards.dataSource = self
//        cards.delegate = self
//    }
//
//    func bindViewModel() {
//        viewModel.onSelectionChanged = { [weak self] index in
//            self?.selectionDidChange(to: index)
//        }
//    }
//
//    func selectionDidChange(to index: Int) {
//        updateChips(selectedIndex: index)
//
//        // Свайп: карточки уже на месте, двигать их не нужно
//        guard !isSelectionFromScroll else { return }
//
//        // Тап по чипу. Отталкиваемся от цели прошлой навигации, а не от contentOffset:
//        // при быстрых тапах карточки ещё могут ехать.
//        let from = cardsTarget
//        cardsTarget = index
//        finishSlideTransition()
//
//        if abs(index - from) == 1 {
//            // Соседняя карточка: обычная анимация скролла
//            isProgrammaticScroll = true
//            cards.scrollToItem(
//                at: IndexPath(item: index, section: 0),
//                at: .centeredHorizontally,
//                animated: true
//            )
//        } else {
//            // Несмежная: без пролистывания промежуточных карточек
//            slideToCard(at: index, from: from)
//        }
//    }
//
//    /// Мгновенно переносит коллекцию на нужную карточку, а плавность создаёт
//    /// сдвигом: старая карточка (снимок) уезжает, новая заезжает как соседняя.
//    func slideToCard(at index: Int, from currentPage: Int) {
//        finishSlideTransition()
//
//        let width = cards.bounds.width
//        guard width > 0,
//              let snapshot = cards.snapshotView(afterScreenUpdates: false) else {
//            cards.scrollToItem(
//                at: IndexPath(item: index, section: 0),
//                at: .centeredHorizontally,
//                animated: false
//            )
//            return
//        }
//
//        isProgrammaticScroll = true
//        snapshot.frame = cards.frame
//        mainView.insertSubview(snapshot, aboveSubview: cards)
//        slideSnapshot = snapshot
//
//        cards.setContentOffset(CGPoint(x: CGFloat(index) * width, y: 0), animated: false)
//        cards.layoutIfNeeded()
//
//        let direction: CGFloat = index > currentPage ? 1 : -1
//        cards.transform = CGAffineTransform(translationX: direction * width, y: 0)
//        cards.isUserInteractionEnabled = false
//
//        let token = slideToken
//        UIView.animate(
//            withDuration: 0.3,
//            delay: 0,
//            options: [.curveEaseInOut],
//            animations: {
//                self.cards.transform = .identity
//                snapshot.transform = CGAffineTransform(translationX: -direction * width, y: 0)
//            },
//            completion: { [weak self] _ in
//                guard let self, token == self.slideToken else { return }
//                self.finishSlideTransition()
//            }
//        )
//    }
//
//    func finishSlideTransition() {
//        slideToken += 1
//        slideSnapshot?.removeFromSuperview()
//        slideSnapshot = nil
//        cards.layer.removeAllAnimations()
//        cards.transform = .identity
//        cards.isUserInteractionEnabled = true
//        isProgrammaticScroll = false
//    }
//
//    func updateChips(selectedIndex: Int) {
//        for case let cell as ExerciseChipCell in chips.visibleCells {
//            guard let indexPath = chips.indexPath(for: cell) else { continue }
//            cell.configure(
//                title: viewModel.exercises[indexPath.item].title,
//                isSelected: indexPath.item == selectedIndex
//            )
//        }
//        scrollChipIntoViewIfNeeded(at: selectedIndex)
//    }
//
//    /// Скроллим ленту чипов только если выбранный чип не помещается целиком.
//    /// Иначе анимация скролла «съедает» быстрые тапы по соседним чипам.
//    func scrollChipIntoViewIfNeeded(at index: Int) {
//        let indexPath = IndexPath(item: index, section: 0)
//        guard let chipFrame = chips.layoutAttributesForItem(at: indexPath)?.frame else { return }
//
//        let visibleRect = chips.bounds.insetBy(dx: 12, dy: 0)
//        guard !visibleRect.contains(chipFrame) else { return }
//
//        chips.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
//    }
//
//    func currentCardPage() -> Int {
//        let width = cards.bounds.width
//        guard width > 0 else { return viewModel.selectedIndex }
//        let page = Int(round(cards.contentOffset.x / width))
//        return min(max(page, 0), viewModel.exercises.count - 1)
//    }
//}
//
//// MARK: - UICollectionViewDataSource
//extension HomeViewController: UICollectionViewDataSource {
//    func collectionView(
//        _ collectionView: UICollectionView,
//        numberOfItemsInSection section: Int) -> Int {
//        viewModel.exercises.count
//    }
//
//    func collectionView(
//        _ collectionView: UICollectionView,
//        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let exercise = viewModel.exercises[indexPath.item]
//
//        if collectionView === chips {
//            let cell = collectionView.dequeueReusableCell(
//                withReuseIdentifier: ExerciseChipCell.reuseIdentifier,
//                for: indexPath
//            ) as! ExerciseChipCell
//            cell.configure(title: exercise.title, isSelected: indexPath.item == viewModel.selectedIndex)
//            return cell
//        } else {
//            let cell = collectionView.dequeueReusableCell(
//                withReuseIdentifier: ExerciseCardCell.reuseIdentifier,
//                for: indexPath
//            ) as! ExerciseCardCell
//            cell.configure(title: exercise.title)
//            return cell
//        }
//    }
//}
//
//// MARK: - UICollectionViewDelegate
//extension HomeViewController: UICollectionViewDelegate {
//    // Страховка: при каждом появлении чипа на экране заново применяем актуальное выделение.
//    // updateChips обновляет только видимые ячейки, поэтому ушедший за экран чип
//    // мог вернуться со старым состоянием.
//    func collectionView(
//        _ collectionView: UICollectionView,
//        willDisplay cell: UICollectionViewCell,
//        forItemAt indexPath: IndexPath) {
//        guard collectionView === chips, let chipCell = cell as? ExerciseChipCell else { return }
//        chipCell.configure(
//            title: viewModel.exercises[indexPath.item].title,
//            isSelected: indexPath.item == viewModel.selectedIndex
//        )
//    }
//
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        guard collectionView === chips else { return }
//        viewModel.select(index: indexPath.item)
//    }
//
//    // Свайп карточек -> меняем активный чип
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        guard scrollView === cards,
//              !isProgrammaticScroll,
//              scrollView.isDragging || scrollView.isDecelerating else { return }
//
//        let page = currentCardPage()
//        cardsTarget = page
//        isSelectionFromScroll = true
//        viewModel.select(index: page)
//        isSelectionFromScroll = false
//    }
//
//    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
//        // Пользователь перехватил анимацию — снова слушаем свайп
//        if scrollView === cards { isProgrammaticScroll = false }
//    }
//
//    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
//        if scrollView === cards { isProgrammaticScroll = false }
//    }
//}
//
//// MARK: - UICollectionViewDelegateFlowLayout
//extension HomeViewController: UICollectionViewDelegateFlowLayout {
//    func collectionView(
//        _ collectionView: UICollectionView,
//        layout collectionViewLayout: UICollectionViewLayout,
//        sizeForItemAt indexPath: IndexPath) -> CGSize {
//        if collectionView === cards {
//            return collectionView.bounds.size
//        }
//        let title = viewModel.exercises[indexPath.item].title
//        let font = UIFont.systemFont(ofSize: 16, weight: .semibold)
//        let textWidth = (title as NSString).size(withAttributes: [.font: font]).width
//        return CGSize(width: ceil(textWidth) + 36, height: collectionView.bounds.height)
//    }
//}

//
//  HomeViewController.swift
//  UTUMNO
//

import UIKit

final class HomeViewController: BaseViewController<HomeView> {

    // MARK: Private Properties
    private let viewModel: HomeViewModel

    private lazy var synchronizer = ChipsCardsSynchronizer(
        viewModel: viewModel,
        cards: cards,
        container: mainView
    )

    private var chips: UICollectionView { mainView.chipsCollectionView }
    private var cards: UICollectionView { mainView.cardsCollectionView }

    // MARK: Init
    init(viewModel: HomeViewModel = HomeViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        mainView.greetingLabel.text = viewModel.greeting
        setupCollectionViews()
        bindSynchronizer()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        synchronizer.layoutDidChange()
    }
}

// MARK: - Private Methods
private extension HomeViewController {
    func setupCollectionViews() {
        chips.register(ExerciseChipCell.self, forCellWithReuseIdentifier: ExerciseChipCell.reuseIdentifier)
        chips.dataSource = self
        chips.delegate = self
        chips.delaysContentTouches = false

        cards.register(ExerciseCardCell.self, forCellWithReuseIdentifier: ExerciseCardCell.reuseIdentifier)
        cards.dataSource = self
        cards.delegate = self
    }

    func bindSynchronizer() {
        synchronizer.onSelectedIndexChanged = { [weak self] index in
            self?.updateChips(selectedIndex: index)
        }
    }

    func updateChips(selectedIndex: Int) {
        for case let cell as ExerciseChipCell in chips.visibleCells {
            guard let indexPath = chips.indexPath(for: cell) else { continue }
            cell.configure(
                title: viewModel.exercises[indexPath.item].title,
                isSelected: indexPath.item == selectedIndex
            )
        }
        scrollChipIntoViewIfNeeded(at: selectedIndex)
    }

    /// Скроллим ленту чипов только если выбранный чип не помещается целиком.
    /// Иначе анимация скролла «съедает» быстрые тапы по соседним чипам.
    func scrollChipIntoViewIfNeeded(at index: Int) {
        let indexPath = IndexPath(item: index, section: 0)
        guard let chipFrame = chips.layoutAttributesForItem(at: indexPath)?.frame else { return }

        let visibleRect = chips.bounds.insetBy(dx: 12, dy: 0)
        guard !visibleRect.contains(chipFrame) else { return }

        chips.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
}

// MARK: - UICollectionViewDataSource
extension HomeViewController: UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int) -> Int {
        viewModel.exercises.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let exercise = viewModel.exercises[indexPath.item]

        if collectionView === chips {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ExerciseChipCell.reuseIdentifier,
                for: indexPath
            ) as! ExerciseChipCell
            cell.configure(title: exercise.title, isSelected: indexPath.item == viewModel.selectedIndex)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ExerciseCardCell.reuseIdentifier,
                for: indexPath
            ) as! ExerciseCardCell
            cell.configure(title: exercise.title)
            return cell
        }
    }
}

// MARK: - UICollectionViewDelegate
extension HomeViewController: UICollectionViewDelegate {
    // Страховка: при каждом появлении чипа на экране заново применяем актуальное выделение.
    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath) {
        guard collectionView === chips, let chipCell = cell as? ExerciseChipCell else { return }
        chipCell.configure(
            title: viewModel.exercises[indexPath.item].title,
            isSelected: indexPath.item == viewModel.selectedIndex
        )
    }

    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath) {
        guard collectionView === chips else { return }
        synchronizer.chipTapped(at: indexPath.item)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView === cards else { return }
        synchronizer.cardsDidScroll()
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        guard scrollView === cards else { return }
        synchronizer.cardsWillBeginDragging()
    }

    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        guard scrollView === cards else { return }
        synchronizer.cardsDidEndScrollingAnimation()
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension HomeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView === cards {
            return collectionView.bounds.size
        }
        let title = viewModel.exercises[indexPath.item].title
        let font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        let textWidth = (title as NSString).size(withAttributes: [.font: font]).width
        return CGSize(width: ceil(textWidth) + 36, height: collectionView.bounds.height)
    }
}
