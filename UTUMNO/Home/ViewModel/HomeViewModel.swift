//
//  HomeViewModel.swift
//  UTUMNO
//
//  Created by Adam Mirzakanov on 08.11.2026.
//

import Foundation

final class HomeViewModel {
    let greeting = "Good morning"
    let exercises: [WorkoutExercise]

    private(set) var selectedIndex: Int = 0

    var onSelectionChanged: ((Int) -> Void)?

    init(exercises: [WorkoutExercise] = HomeViewModel.defaultExercises) {
        self.exercises = exercises
    }

    func select(index: Int) {
        guard exercises.indices.contains(index), index != selectedIndex else { return }
        selectedIndex = index
        onSelectionChanged?(index)
    }

    var selectedExercise: WorkoutExercise {
        exercises[selectedIndex]
    }
}

private extension HomeViewModel {
    static let defaultExercises: [WorkoutExercise] = [
        WorkoutExercise(title: "Pullups", currentStep: 1, totalSteps: 6),
        WorkoutExercise(title: "Dips", currentStep: 2, totalSteps: 6),
        WorkoutExercise(title: "Pushups", currentStep: 0, totalSteps: 6),
        WorkoutExercise(title: "Squats", currentStep: 3, totalSteps: 6),
        WorkoutExercise(title: "Plank", currentStep: 4, totalSteps: 6),
        WorkoutExercise(title: "Core", currentStep: 1, totalSteps: 6)
    ]
}
