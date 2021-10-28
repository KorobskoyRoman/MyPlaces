//
//  MapViewController.swift
//  MyPlaces
//
//  Created by Roman Korobskoy on 28.10.2021.
//

import MapKit
import UIKit

class MapViewController: UIViewController {
    
    var place = Place()
    let annotationIdentifier = "annotationIdentifier" //объявляем идентификатор для переиспользования аннотации к метке
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        setupPlacemak()
    }

    @IBAction func closeVC() {
        dismiss(animated: true)
    }
    
    func setupPlacemak() { //настраиваем отображение пина на карте
        guard let location = place.location else {return}
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(location) { (placemarks, error) in //передаем координаты
            //проверяем наличие ошибки
            if let error = error {
                print(error)
                return
            }
            
            guard let placemarks = placemarks else {return}
            
            let placemark = placemarks.first //присваеваем первую метку на карте элементу массива
            
            let annotation = MKPointAnnotation() //описываем точку на карте
            annotation.title = self.place.name
            annotation.subtitle = self.place.type
            
            guard let placemarkLocation = placemark?.location else {return} //проверяем есть ли точка на карте
            
            annotation.coordinate = placemarkLocation.coordinate
            self.mapView.showAnnotations([annotation], animated: true) //отражаем на карте
            self.mapView.selectAnnotation(annotation, animated: true) //выделяем аннотацию на карте
        }
    }
}

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard !(annotation is MKUserLocation) else {return nil} //проверяем совпадает ли текущая геопозиция с рестораном
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) as? MKPinAnnotationView //выбираем идентификатор для переиспользоваения метки на карте
        
        if annotationView == nil { //если аннотации нет - создаем новый
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            annotationView?.canShowCallout = true //показываем доп информацию в аннотации
//            annotationView?.image = UIImage(data: self.place.imageData!) // не работает без скейла
        }
        
        if let imageData = place.imageData { //проверяем на наличие картинки
            
            //настраиваем картинку для метки
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            imageView.layer.cornerRadius = 10
            imageView.clipsToBounds = true
            imageView.image = UIImage(data: imageData)
            annotationView?.rightCalloutAccessoryView = imageView //размещаем картинку на пине
        }
        
        return annotationView
    }
}
