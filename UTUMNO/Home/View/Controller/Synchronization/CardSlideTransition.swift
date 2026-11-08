//
//  CardSlideTransition.swift
//  UTUMNO
//
//  Created by Adam Mirzakanov on 08.11.2026.
//

import UIKit

/// Подставляет нужную карточку «как соседнюю», не пролистывая промежуточные.
/// Коллекция мгновенно переносится на целевую страницу, а плавность создаётся сдвигом:
/// снимок старой карточки уезжает, новая заезжает с той же стороны.
/// Ничего не знает про чипы и ViewModel.
final class CardSlideTransition {

    // MARK: Public Properties
    var duration: TimeInterval = 0.3
    private(set) var isRunning = false

    // MARK: Private Properties
    private weak var cards: UICollectionView?
    private weak var container: UIView?
    private var snapshot: UIView?
    private var token = 0

    // MARK: Init
    /// - Parameters:
    ///   - cards: горизонтальная коллекция с постраничным листанием
    ///   - container: view, в которой лежит `cards` (сюда добавляется снимок)
    init(cards: UICollectionView, container: UIView) {
        self.cards = cards
        self.container = container
    }

    // MARK: Public Methods
    func slide(to index: Int, from page: Int) {
        cancel()
        guard let cards, let container else { return }

        let width = cards.bounds.width
        let targetOffset = CGPoint(x: CGFloat(index) * width, y: 0)

        guard width > 0,
              let snapshot = cards.snapshotView(afterScreenUpdates: false) else {
            cards.setContentOffset(targetOffset, animated: false)
            return
        }

        isRunning = true
        snapshot.frame = cards.frame
        container.insertSubview(snapshot, aboveSubview: cards)
        self.snapshot = snapshot

        cards.setContentOffset(targetOffset, animated: false)
        cards.layoutIfNeeded()

        let direction: CGFloat = index > page ? 1 : -1
        cards.transform = CGAffineTransform(translationX: direction * width, y: 0)
        cards.isUserInteractionEnabled = false

        let currentToken = token
        UIView.animate(
            withDuration: duration,
            delay: 0,
            options: [.curveEaseInOut],
            animations: {
                cards.transform = .identity
                snapshot.transform = CGAffineTransform(translationX: -direction * width, y: 0)
            },
            completion: { [weak self] _ in
                // Устаревшее завершение не должно трогать новую анимацию
                guard let self, currentToken == self.token else { return }
                self.cancel()
            }
        )
    }

    /// Останавливает переход и возвращает коллекцию в обычное состояние.
    func cancel() {
        token += 1
        snapshot?.removeFromSuperview()
        snapshot = nil
        cards?.layer.removeAllAnimations()
        cards?.transform = .identity
        cards?.isUserInteractionEnabled = true
        isRunning = false
    }
}
