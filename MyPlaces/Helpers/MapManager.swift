//
//  MapManager.swift
//  MyPlaces
//
//  Created by Roman Korobskoy on 31.10.2021.
//

import UIKit
import MapKit

class MapManager {
    
    let locationManager = CLLocationManager() //управление службами геолокации
    private let regionInMeters: Double = 1000.0 //для обозначения радиуса отображения
    private var directionsArray: [MKDirections] = [] //для хранени маршрутов
    private var placeCoordinate: CLLocationCoordinate2D?
    
    func checkLocationServices(mapView: MKMapView, segueIdentifier: String, closure: () -> ()) {
        if CLLocationManager.locationServicesEnabled() { //есть геолокация доступна
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            checkLocationAuthorization(mapView: mapView, segueIdentifier: segueIdentifier)
            closure()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { //вызываем вызов алерта через 1 секунду после загрузки вью
                self.showAlert(title: "Ошибка!", message: "Функция геолокаций не включены. Необходимо активация в настройках")
            }
        }
    }
    
    func checkLocationAuthorization(mapView: MKMapView, segueIdentifier: String) {
        
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            if segueIdentifier == "getAddress" { showsUserLocation(mapView: mapView) }
            break
        case .denied:
            showAlert(title: "Ошибка!", message: "Нет доступа к геолокации. Необходимо активировать функцию в настройках.")
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            showAlert(title: "Ошибка!", message: "Нет доступа к геолокации. Необходимо активировать функцию в настройках.")
            break
        case .authorizedAlways:
            break
        @unknown default:
            print("new case")
        }
    }
    
    func showsUserLocation(mapView: MKMapView) { //показывает локацию пользователя
        if let location = locationManager.location?.coordinate { //проверяем координаты
            let region = MKCoordinateRegion(center: location,
                                            latitudinalMeters: regionInMeters,
                                            longitudinalMeters: regionInMeters) //центрируем локацию
            mapView.setRegion(region, animated: true)
        }
    }
    
    func getDirections(for mapView: MKMapView, previousLocation: (CLLocation) -> ()) { //получаем конечную точку
        
        guard let location = locationManager.location?.coordinate else { //получаем координаты пользователя
            showAlert(title: "Ошибка", message: "Локация не найдена!")
            return
        }
        
        locationManager.startUpdatingLocation() //включаем постоянное отслеживание пользователя
        previousLocation(CLLocation(latitude: location.latitude, longitude: location.longitude))
        
        guard let request = createDirectionRequest(from: location) else {
            return showAlert(title: "Ошибка!", message: "Место назначения не найдено")
        }
        let directions = MKDirections(request: request)
        
        resetMapview(withNew: directions, mapView: mapView) //очищаем все предыдущие маршруты
        
        directions.calculate { (response, error) in
            if let error = error {
                print(error)
                return
            }
            guard let response = response else {
                self.showAlert(title: "Ошибка!", message: "Место назначения не найдено")
                return
            }
            for route in response.routes { //работа с маршрутами
                mapView.addOverlay(route.polyline) //добавляем оверлей с дорогой
                mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true) //отражаем весь маршрут
                
                let distance = String(format: "%.1f", route.distance / 1000) //округляем
                let timeInterval = route.expectedTravelTime / 60 //отражаем в минутах
                
                print("расстояние \(distance)")
                print("время в пути \(timeInterval)")
            }
        }
    }
    
    func createDirectionRequest(from coordinate: CLLocationCoordinate2D) -> MKDirections.Request? {
        guard let destinationCoordinate = placeCoordinate else {return nil}
        //определяем точки начала и конца маршрута
        let startingLocation = MKPlacemark(coordinate: coordinate)
        let destination = MKPlacemark(coordinate: destinationCoordinate)
        
        let request = MKDirections.Request() //определяем начальную и конечную точку маршрута
        request.source = MKMapItem(placemark: startingLocation) //определяем точку старта
        request.destination = MKMapItem(placemark: destination) //определяем точку конца
        request.transportType = .walking //тип движения
        request.requestsAlternateRoutes = true //включаем альтернативные маршруты
        
        return request
    }
    
    func startTrackingUserLocation(for mapView: MKMapView, and location: CLLocation?, closure: (_ currentLocation: CLLocation) -> ()) {
        
        guard let location = location else {return}
        let center = getCenterLocation(for: mapView) //получаем центр отображения
        guard center.distance(from: location) > 50 else {return} //проверяем дистанцию на >50м
        
        closure(center)
    }
    
    func resetMapview(withNew directions: MKDirections, mapView: MKMapView) {
        
        mapView.removeOverlays(mapView.overlays) //очищаем все ранее созданные оверлеи на карте
        directionsArray.append(directions) //добавляем в массив данные
        let _ = directionsArray.map { $0.cancel } //проходим по каждому элементу массива и отменяем их
        directionsArray.removeAll() //отменяем все маршруты
    }
    
    func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        
        //создаем переменные и помещаем в них координаты
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        
        return CLLocation(latitude: latitude, longitude: longitude) //полученные коорднаты
    }
    
    func setupPlacemak(place: Place, mapView: MKMapView) { //настраиваем отображение пина на карте
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
            annotation.title = place.name
            annotation.subtitle = place.type
            
            guard let placemarkLocation = placemark?.location else {return} //проверяем есть ли точка на карте
            
            annotation.coordinate = placemarkLocation.coordinate
            self.placeCoordinate = placemark?.location?.coordinate
            
            mapView.showAnnotations([annotation], animated: true) //отражаем на карте
            mapView.selectAnnotation(annotation, animated: true) //выделяем аннотацию на карте
        }
    }

    private func showAlert(title: String,message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertOk = UIAlertAction(title: "ok", style: .default)
        
        alert.addAction(alertOk)
        
        //вызываем алерт на нашем экране
        let alertWindow = UIWindow(frame: UIScreen.main.bounds)
        alertWindow.rootViewController = UIViewController()
        alertWindow.windowLevel = UIWindow.Level.alert + 1
        alertWindow.makeKeyAndVisible()
        alertWindow.rootViewController?.present(alert, animated: true)
    }
}
