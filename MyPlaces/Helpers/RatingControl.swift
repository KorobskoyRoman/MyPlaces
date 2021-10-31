//
//  RatingControl.swift
//  MyPlaces
//
//  Created by Roman Korobskoy on 25.10.2021.
//

import UIKit

class RatingControl: UIStackView {

    var rating = 0 {
        didSet {
            updateButtonSelectionState()
        }
    }
    private var ratingButtons = [UIButton]()
    
    @IBInspectable var starSize: CGSize = CGSize(width: 44.0, height: 44.0) {
        didSet {
            setupButtons()
        }
    }
    @IBInspectable var starCount: Int = 5 {
        didSet {
            setupButtons()
        }
    }
    
    //MARK: Инициализаторы
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButtons()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setupButtons()
    }
    
    // MARK: Button action
    @objc func ratingButtonTapped(button: UIButton) {
        
        guard let index = ratingButtons.firstIndex(of: button) else { return }
        
        //определеяем рейтинг
        let selectedRating = index + 1
        
        if selectedRating == rating { //при повторном нажатии рейтинг обнуляется
            rating = 0
        } else {
            rating = selectedRating
        }
    }

    private func setupButtons() {
        for _ in 0..<starCount { //делаем 5 кнопок
            
//            for button in ratingButtons { //для отображения реального кол-ва кнопок в ИБ
//                removeArrangedSubview(button)
//                button.removeFromSuperview()
//            }
//
//            ratingButtons.removeAll()
            
            //загружаем картинку для кнопки
            let bundle = Bundle(for: type(of: self))
            let filledStar = UIImage(named: "filledStar",
                                     in: bundle,
                                     compatibleWith: self.traitCollection)
            let emptyStar = UIImage(named: "emptyStar",
                                    in: bundle,
                                    compatibleWith: self.traitCollection)
            let highlightedStar = UIImage(named: "highlightedStar",
                                          in: bundle,
                                          compatibleWith: self.traitCollection)
            
            let button = UIButton()
            
            //устанавливаем картинку
            button.setImage(emptyStar, for: .normal)
            button.setImage(highlightedStar, for: .selected)
            button.setImage(filledStar, for: .highlighted)
            button.setImage(filledStar, for: [.highlighted, .selected])
            
            //констрейнты
            button.translatesAutoresizingMaskIntoConstraints = false
            button.heightAnchor.constraint(equalToConstant: starSize.height).isActive = true
            button.widthAnchor.constraint(equalToConstant: starSize.width).isActive = true
            
            //добавляем действие кнопки
            button.addTarget(self, action: #selector(ratingButtonTapped(button:)), for: .touchUpInside)
            
            //добавляем кнопку в стэк
            addArrangedSubview(button)
            
            //добавляем новую кнопку в массив
            ratingButtons.append(button)
        }
        updateButtonSelectionState()
        
    }
    
    private func updateButtonSelectionState() { //присваиваем рейтинг кнопке
        for (index, button) in ratingButtons.enumerated() {
            button.isSelected = index < rating  //присваиваем всем кнопкам значение true, если индекс меньше рейтинга
        }
    }
}
