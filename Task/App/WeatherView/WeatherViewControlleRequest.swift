//
//  WeatherViewControllerRequest.swift
//  Task
//
//  Created by Haggag on 22/09/2024.
//

import Foundation
import UIKit
import RealmSwift

extension WeatherViewController {
    func fetchWeatherData(city: String) {
        let apiKey = "9e635ac587c941ff836213724242009"
        let urlString = "https://api.weatherapi.com/v1/forecast.json?q=\(city)&days=5&key=\(apiKey)"
        
        guard let url = URL(string: urlString) else {
            showAlert(title: "Error", message: "Invalid URL.")
            return
        }
        
        networkManager.fetchData(from: url, responseType: WeatherResponse.self) { result in
            switch result {
            case .success(let weatherData):
                self.saveWeatherDataToRealm(weatherData, for: city)
                DispatchQueue.main.async {
                    self.setupView(city: city)
                    self.collectionView.reloadData()
                }
            case .failure(let error):
                print("Error fetching data: \(error)")
                DispatchQueue.main.async {
                    self.showAlert(title: "Error", message: "Unable to fetch city information.")
                }
            }
        }
    }
    
    func saveWeatherDataToRealm(_ weatherData: WeatherResponse, for city: String) {
        let realm = try! Realm()
        
        let weatherObject = WeatherData()
        weatherObject.city = city
        weatherObject.temperature = weatherData.current?.tempC ?? 0.0
        weatherObject.weatherDescription = weatherData.current?.condition?.text ?? ""
        weatherObject.cacheTimestamp = Date()
        
        guard let forecastData = weatherData.forecast?.forecastday else { return }
        for forecastDay in forecastData {
            let forecastObject = ForecastData()
            forecastObject.date = forecastDay.date ?? ""
            forecastObject.minTemperature = forecastDay.hour?.first?.tempC ?? 0.0
            forecastObject.maxTemperature = forecastDay.hour?.first?.tempF ?? 0.0
            forecastObject.weatherDescription = forecastDay.day?.condition?.text ?? ""
            weatherObject.forecast.append(forecastObject)
        }
        
        try! realm.write {
            realm.add(weatherObject, update: .modified)
        }
    }
    
    func getCachedWeatherData(for city: String) -> WeatherData? {
        let realm = try! Realm()
        
        if let weatherData = realm.object(ofType: WeatherData.self, forPrimaryKey: city) {
            let cacheDuration: TimeInterval = 60 * 30
            if Date().timeIntervalSince(weatherData.cacheTimestamp) < cacheDuration {
                return weatherData
            }
        }
        return nil
    }
    
    func getWeatherData(city: String) {
        if getCachedWeatherData(for: city) != nil {
            print("Using cached data for \(city)")
            self.setupView(city: city)
            return
        }
        
        fetchWeatherData(city: city)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true)
    }
}
