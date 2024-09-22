//
//  WeatherCollectionViewCell.swift
//  Task
//
//  Created by Haggag on 22/09/2024.
//

import UIKit

class WeatherCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var maxTemp: UILabel!
    @IBOutlet weak var minTemp: UILabel!
    @IBOutlet weak var weatherDescription: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.layer.cornerRadius = 12
    }
    func configure(forecast: ForecastData) {
        dateLabel.text = forecast.date
        maxTemp.text = "\(forecast.maxTemperature)"
        minTemp.text = "\(forecast.minTemperature)"
        weatherDescription.text = forecast.weatherDescription
    }
}
