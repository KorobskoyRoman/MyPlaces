//
//  NewPlaceViewController.swift
//  MyPlaces
//
//  Created by Roman Korobskoy on 22.10.2021.
//

import UIKit

class NewPlaceViewController: UITableViewController {

    var imageIsChanged = false

    @IBOutlet weak var placeImage: UIImageView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var placeName: UITextField!
    @IBOutlet weak var placeLocation: UITextField!
    @IBOutlet weak var placeType: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView() //присваиваем нашей таблице вью ниже контента
        saveButton.isEnabled = false
        placeName.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged) 
    }
    
    // MARK: Table view delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) { //добавляем алерт для первой ячейки таблицы
        if indexPath.row == 0 {
            
            let cameraIcon = #imageLiteral(resourceName: "camera").imageWithSize(scaledToSize: CGSize(width: 25, height: 25)) //масштабируем через наш метод
            let photoIcon = #imageLiteral(resourceName: "photo").imageWithSize(scaledToSize: CGSize(width: 25, height: 25))
            
            let actionSheet = UIAlertController(title: nil,
                                                message: nil,
                                                preferredStyle: .actionSheet)
            
            let camera = UIAlertAction(title: "Камера", style: .default) { _ in
                self.chooseImagePicker(source: .camera) //вызываем метод из расширения для выбора из камеры/фото
            }
            camera.setValue(cameraIcon, forKey: "image")
            camera.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            
            let photo = UIAlertAction(title: "Фото", style: .default) { _ in
                self.chooseImagePicker(source: .photoLibrary) //вызываем метод из расширения для выбора из камеры/фото
            }
            photo.setValue(photoIcon, forKey: "image")
            photo.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            
            let cancel = UIAlertAction(title: "Отмена", style: .cancel)
            
            actionSheet.addAction(camera)
            actionSheet.addAction(photo)
            actionSheet.addAction(cancel)
            
            present(actionSheet,animated: true)
            } else {
            view.endEditing(true)
        }
    }
    
    func saveNewPlace() { //метод для сохранения нового места
        

        var image: UIImage?
        
        if imageIsChanged {
            image = placeImage.image //изменяем на выбранную картинку
        } else {
            image = #imageLiteral(resourceName: "food") //в ином случае присваиваем значением по умолчанию
        }
        let imageData = image?.pngData()
        
        let newPlace = Place(name: placeName.text!,
                             location: placeLocation.text,
                             type: placeType.text,
                             imageData: imageData)
        
        StorageManager.saveObject(newPlace) //сохраняем в БД новый объект
    }
    
    @IBAction func cancelAction(_ sender: UIBarButtonItem) { //метод для кнопки отмена
        dismiss(animated: true, completion: nil)
    }
    
}

// MARK: Text field delegate
extension NewPlaceViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool { //убираем клавиатуру
        textField.becomeFirstResponder()
        textField.resignFirstResponder()
        return true
    }
    
    @objc private func textFieldChanged() { //контроль изменения текста для кнопки сохранения
        if placeName.text?.isEmpty == false {
            saveButton.isEnabled = true
        } else {
            saveButton.isEnabled = false
        }
    }
}

//MARK: work with image
extension NewPlaceViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func chooseImagePicker(source: UIImagePickerController.SourceType) { //выбираем картинку
        
        if UIImagePickerController.isSourceTypeAvailable(source) { //условие для выбора картинки
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self //делегируем в этот же класс
            imagePicker.allowsEditing = true
            imagePicker.sourceType = source
            present(imagePicker, animated: true)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) { //вставляем картинку в первую ячейку таблицы
        
        placeImage.image = info[.editedImage] as? UIImage
        placeImage.contentMode = .scaleAspectFill
        placeImage.clipsToBounds = true
        
        imageIsChanged = true //меняем значение при изменении картинки
        
        dismiss(animated: true)
    }
}

extension UIImage { //для масштабирования картинок

    func imageWithSize(scaledToSize newSize: CGSize) -> UIImage {

        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        self.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }

}
