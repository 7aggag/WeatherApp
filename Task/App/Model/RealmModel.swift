//
//  RealmModel.swift
//  Task
//
//  Created by Haggag on 22/09/2024.
//

import Foundation
import RealmSwift


class WeatherData: Object {
    @Persisted(primaryKey: true) var city: String = ""
    @Persisted var temperature: Double = 0.0
    @Persisted var weatherDescription: String = ""
    @Persisted var forecast: List<ForecastData>
    @Persisted var cacheTimestamp: Date = Date()
}

class ForecastData: EmbeddedObject {
    @Persisted var date: String = ""
    @Persisted var minTemperature: Double = 0.0
    @Persisted var maxTemperature: Double = 0.0
    @Persisted var weatherDescription: String = ""
}
