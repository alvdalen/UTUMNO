//
//  ChipsCardsSynchronizer.swift
//  UTUMNO
//
//  Created by Adam Mirzakanov on 08.11.2026.
//

import UIKit

/// Связывает ленту чипов и карточки: тап по чипу двигает карточки,
/// свайп карточек меняет выбранный чип.
/// Контроллер только передаёт сюда события, всё решение «что делать» принимается здесь.
final class ChipsCardsSynchronizer {

    // MARK: Public Properties
    /// Вызывается при любой смене выбора (тап или свайп): нужно обновить ленту чипов.
    var onSelectedIndexChanged: ((Int) -> Void)?

    // MARK: Private Properties
    private let viewModel: HomeViewModel
    private let cards: UICollectionView
    private let transition: CardSlideTransition

    /// Страница, на которой карточки стоят или к которой едут.
    private var cardsTarget: Int
    /// Выбор пришёл от свайпа, а не от тапа по чипу.
    private var isSelectionFromScroll = false
    /// Идёт обычная анимированная прокрутка к соседней карточке.
    private var isProgrammaticScroll = false
    private var lastCardsWidth: CGFloat = 0

    // MARK: Init
    init(viewModel: HomeViewModel, cards: UICollectionView, container: UIView) {
        self.viewModel = viewModel
        self.cards = cards
        self.transition = CardSlideTransition(cards: cards, container: container)
        self.cardsTarget = viewModel.selectedIndex

        viewModel.onSelectionChanged = { [weak self] index in
            self?.selectionDidChange(to: index)
        }
    }

    // MARK: Events from Controller
    func chipTapped(at index: Int) {
        viewModel.select(index: index)
    }

    func cardsDidScroll() {
        guard !isProgrammaticScroll,
              !transition.isRunning,
              cards.isDragging || cards.isDecelerating else { return }

        let page = currentCardPage()
        cardsTarget = page
        isSelectionFromScroll = true
        viewModel.select(index: page)
        isSelectionFromScroll = false
    }

    func cardsWillBeginDragging() {
        // Пользователь перехватил анимацию: снова слушаем свайп
        isProgrammaticScroll = false
    }

    func cardsDidEndScrollingAnimation() {
        isProgrammaticScroll = false
    }

    /// Вызывать из `viewDidLayoutSubviews`: пересчитывает карточки при смене ширины (поворот).
    func layoutDidChange() {
        let width = cards.bounds.width
        guard width > 0, width != lastCardsWidth else { return }
        lastCardsWidth = width

        transition.cancel()
        cards.collectionViewLayout.invalidateLayout()
        scrollCards(to: viewModel.selectedIndex, animated: false)
    }
}

// MARK: - Private Methods
private extension ChipsCardsSynchronizer {
    func selectionDidChange(to index: Int) {
        onSelectedIndexChanged?(index)

        // Свайп: карточки уже на месте, двигать их не нужно
        guard !isSelectionFromScroll else { return }

        // Тап по чипу. Отталкиваемся от цели прошлой навигации, а не от contentOffset:
        // при быстрых тапах карточки ещё могут ехать.
        let from = cardsTarget
        cardsTarget = index
        transition.cancel()
        isProgrammaticScroll = false

        if abs(index - from) == 1 {
            // Соседняя карточка: обычная анимация скролла
            isProgrammaticScroll = true
            scrollCards(to: index, animated: true)
        } else {
            // Несмежная: без пролистывания промежуточных карточек
            transition.slide(to: index, from: from)
        }
    }

    func scrollCards(to index: Int, animated: Bool) {
        cards.scrollToItem(
            at: IndexPath(item: index, section: 0),
            at: .centeredHorizontally,
            animated: animated
        )
    }

    func currentCardPage() -> Int {
        let width = cards.bounds.width
        guard width > 0 else { return viewModel.selectedIndex }
        let page = Int((cards.contentOffset.x / width).rounded())
        return min(max(page, 0), viewModel.exercises.count - 1)
    }
}
