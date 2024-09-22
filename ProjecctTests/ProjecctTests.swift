//
//  ProjecctTests.swift
//  ProjecctTests
//
//  Created by Haggag on 23/09/2024.
//

import XCTest

import RealmSwift
@testable import Task

 class WeatherViewControllerTests: XCTestCase {
    
    var weatherVC: WeatherViewController!
    var mockNetworkManager: MockNetworkManager!
    var realm: Realm!
    
    override func setUp() {
        super.setUp()
        
        mockNetworkManager = MockNetworkManager()
        weatherVC = WeatherViewController(networkManager: mockNetworkManager)

        var config = Realm.Configuration()
        config.inMemoryIdentifier = "TestRealm"
        realm = try! Realm(configuration: config)
    }
    
    override func tearDown() {
        weatherVC = nil
        mockNetworkManager = nil
        realm = nil
        super.tearDown()
    }
    
    func testFetchWeatherDataSuccess() {
        mockNetworkManager.result = .success(mockWeatherResponse())
        
        weatherVC.fetchWeatherData(city: "dubai")
        
        let weatherData = realm.object(ofType: WeatherData.self, forPrimaryKey: "dubai")
        XCTAssertNotNil(weatherData)
        XCTAssertEqual(weatherData?.city, "dubai")
        XCTAssertEqual(weatherData?.temperature, 35.0)
    }
    
    func testFetchWeatherDataFailure() {
        mockNetworkManager.result = .failure(NSError(domain: "", code: -1, userInfo: nil))
        
        weatherVC.fetchWeatherData(city: "invalidcity")
        let weatherData = realm.object(ofType: WeatherData.self, forPrimaryKey: "invalidcity")
        XCTAssertNil(weatherData)
    }
    
    func testGetCachedWeatherDataValid() {
        let weatherData = WeatherData()
        weatherData.city = "dubai"
        weatherData.temperature = 35.0
        weatherData.cacheTimestamp = Date()
        
        try! realm.write {
            realm.add(weatherData, update: .modified)
        }
        
        let cachedData = weatherVC.getCachedWeatherData(for: "dubai")
        XCTAssertNotNil(cachedData)
        XCTAssertEqual(cachedData?.temperature, 35.0)
    }
    
    func testGetCachedWeatherDataExpired() {
        let weatherData = WeatherData()
        weatherData.city = "dubai"
        weatherData.temperature = 35.0
        weatherData.cacheTimestamp = Date(timeIntervalSinceNow: -3600)
        
        try! realm.write {
            realm.add(weatherData, update: .modified)
        }
        
        let cachedData = weatherVC.getCachedWeatherData(for: "dubai")
        XCTAssertNil(cachedData)
    }
    
    // Helper methods
    func mockWeatherResponse() -> WeatherResponse {
        let condition = CurrentCondition(text: "Sunny", icon: nil, code: nil)
        
        let currentWeather = Current(
            lastUpdatedEpoch: nil,
            lastUpdated: nil,
            tempC: 35.0,
            tempF: nil,
            isDay: nil,
            condition: condition,
            windMph: nil,
            windKph: nil,
            windDegree: nil,
            windDir: nil,
            humidity: nil,
            cloud: nil
        )
        
        let forecastDayData = Day(
            maxwindMph: nil,
            maxwindKph: nil,
            totalprecipMm: nil,
            totalprecipIn: nil,
            totalsnowCM: nil,
            dailyWillItRain: nil,
            dailyChanceOfRain: nil,
            dailyWillItSnow: nil,
            dailyChanceOfSnow: nil,
            condition: condition,
            uv: nil
        )
        
        let forecastDay = Forecastday(
            date: "2024-09-22",
            dateEpoch: nil,
            day: forecastDayData,
            astro: nil,
            hour: nil
        )
        
        let forecast = Forecast(forecastday: [forecastDay])
        
        let weatherResponse = WeatherResponse(
            location: nil,
            current: currentWeather,
            forecast: forecast
        )
        
        return weatherResponse
    }
}

class MockNetworkManager: NetworkManagerProtocol {
    var result: Result<WeatherResponse, Error>?
    
    func fetchData<T>(from url: URL, responseType: T.Type, completion: @escaping (Result<T, Error>) -> Void) where T : Decodable {
        if let result = result as? Result<T, Error> {
            completion(result)
        }
    }
}
