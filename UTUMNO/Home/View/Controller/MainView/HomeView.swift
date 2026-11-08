//
//  HomeView.swift
//  UTUMNO
//
//  Created by Adam Mirzakanov on 08.11.2026.
//

import UIKit

final class HomeView: UIView {

    // MARK: Views
    let greetingLabel: UILabel = {
        $0.font = .systemFont(ofSize: 40, weight: .heavy)
        $0.textColor = .black
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(UILabel())

    let chipsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 12
        layout.minimumLineSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)

        $0.collectionViewLayout = layout
        $0.backgroundColor = .clear
        $0.showsHorizontalScrollIndicator = false
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()))

    let cardsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.sectionInset = .zero

        $0.collectionViewLayout = layout
        $0.backgroundColor = .clear
        $0.isPagingEnabled = true
        $0.showsHorizontalScrollIndicator = false
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()))

    // MARK: Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Private Methods
private extension HomeView {
    func setupView() {
        backgroundColor = .white
        addSubview(greetingLabel)
        addSubview(chipsCollectionView)
        addSubview(cardsCollectionView)
    }

    func setupLayout() {
        NSLayoutConstraint.activate([
            greetingLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 16),
            greetingLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            greetingLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -20),

            chipsCollectionView.topAnchor.constraint(equalTo: greetingLabel.bottomAnchor, constant: 20),
            chipsCollectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            chipsCollectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            chipsCollectionView.heightAnchor.constraint(equalToConstant: 44),

            cardsCollectionView.topAnchor.constraint(equalTo: chipsCollectionView.bottomAnchor, constant: 24),
            cardsCollectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            cardsCollectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            cardsCollectionView.heightAnchor.constraint(equalToConstant: 260)
        ])
    }
}
