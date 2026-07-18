import SwiftUI
import UIKit
import CoreLocation
import WeatherKit

// ========== 自动获取位置和天气的工具类 ==========
class LocationWeatherService: NSObject, ObservableObject {
    static let shared = LocationWeatherService()

    @Published var locationText: String = ""
    @Published var weatherText: String = ""
    @Published var isUpdating: Bool = false

    private let locationManager = CLLocationManager()
    private var currentLocation: CLLocation?

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    func requestPermission() {
        locationManager.requestWhenInUseAuthorization()
    }

    func startUpdating() {
        isUpdating = true
        locationManager.requestLocation()
    }

    func reverseGeocode(location: CLLocation) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location, preferredLocale: Locale(identifier: "zh_CN")) { [weak self] placemarks, error in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if let place = placemarks?.first {
                    var parts: [String] = []
                    if let subLocality = place.subLocality, !subLocality.isEmpty {
                        parts.append(subLocality)
                    }
                    if let locality = place.locality, !locality.isEmpty {
                        parts.append(locality)
                    }
                    if let subAdministrative = place.subAdministrativeArea, !subAdministrative.isEmpty {
                        parts.append(subAdministrative)
                    }
                    if let administrative = place.administrativeArea, !administrative.isEmpty {
                        parts.append(administrative)
                    }
                    if parts.isEmpty {
                        parts.append(place.name ?? "未知位置")
                    }
                    self.locationText = parts.joined(separator: "·")
                }
                self.isUpdating = false
            }
        }
    }

    func fetchWeather(location: CLLocation) {
        // WeatherKit 在 iOS 16+ 可用，降级使用简单逻辑
        if #available(iOS 16.0, *) {
            fetchWeatherKit(location: location)
        } else {
            weatherText = "不支持自动获取"
        }
    }

    @available(iOS 16.0, *)
    private func fetchWeatherKit(location: CLLocation) {
        let weatherService = WeatherService()
        Task {
            do {
                let weather = try await weatherService.weather(for: location)
                let current = weather.currentWeather
                let temp = Int(current.temperature.value)
                let condition = mapCondition(current.condition)
                DispatchQueue.main.async {
                    self.weatherText = "\(condition) \(temp)\u{00B0}C"
                }
            } catch {
                DispatchQueue.main.async {
                    self.weatherText = "获取失败"
                }
            }
        }
    }

    @available(iOS 16.0, *)
    private func mapCondition(_ condition: WeatherCondition) -> String {
        switch condition {
        case .clear: return "晴"
        case .mostlyClear: return "晴"
        case .partlyCloudy: return "多云"
        case .mostlyCloudy: return "多云"
        case .cloudy: return "阴"
        case .blizzard: return "暴风雪"
        case .drizzle: return "小雨"
        case .rain: return "雨"
        case .heavyRain: return "大雨"
        case .snow: return "雪"
        case .heavySnow: return "大雪"
        case .sleet: return "雨夹雪"
        case .hail: return "冰雹"
        default: return "未知"
        }
    }
}

extension LocationWeatherService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        currentLocation = location
        locationManager.stopUpdatingLocation()
        reverseGeocode(location: location)
        fetchWeather(location: location)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.isUpdating = false
            self.locationText = "定位失败"
            self.weatherText = ""
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse ||
           manager.authorizationStatus == .authorizedAlways {
            manager.requestLocation()
        }
    }
}
