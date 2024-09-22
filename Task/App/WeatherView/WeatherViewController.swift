//
//  WeatherViewController.swift
//  Task
//
//  Created by Haggag on 22/09/2024.
//

import UIKit
import RealmSwift

class WeatherViewController: UIViewController {

    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var weatherDescription: UILabel!
    @IBOutlet weak var windLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var forecast: List<ForecastData> = List<ForecastData>()
    var networkManager: NetworkManagerProtocol

    init(networkManager: NetworkManagerProtocol = NetworkManager.shared) {
        self.networkManager = networkManager
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        self.networkManager = NetworkManager.shared
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getWeatherData(city: "dubai")
    }
    
    private func setupCollectionView() {
        collectionView.register(UINib(nibName: "WeatherCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "WeatherCollectionViewCell")
        collectionView.delegate = self
        collectionView.dataSource = self
    }

    func setupView(city: String) {
        guard let weatherData = getCachedWeatherData(for: city) else { return }
        self.cityLabel.text = weatherData.city
        self.temperatureLabel.text = "\(weatherData.temperature)°C"
        self.weatherDescription.text = weatherData.weatherDescription
        self.forecast = weatherData.forecast
        self.collectionView.reloadData()
    }
    
    @IBAction func searchAction(_ sender: UIButton) {
        let searchVC = SearchViewController(delegate: self)
        self.navigationController?.pushViewController(searchVC, animated: true)
    }

}

extension WeatherViewController: SearchPlacesProtocol {
    func didSelectCity(city: String) {
        getWeatherData(city: city)
    }
    
}


extension WeatherViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return forecast.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WeatherCollectionViewCell", for: indexPath) as? WeatherCollectionViewCell else { return UICollectionViewCell() }
         let forecastDay = forecast[indexPath.row]
        cell.configure(forecast: forecastDay)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: collectionView.frame.width / 3 - 20, height: collectionView.frame.height)
    }
}
