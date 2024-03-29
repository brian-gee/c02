import Foundation
import HomeKit

class HomeKitManager: NSObject, ObservableObject, HMHomeManagerDelegate {
    @Published var homes: [HMHome] = []
    @Published var selectedHome: HMHome?
    @Published var selectedAccessory: HMAccessory?
    @Published var selectedHomeInfo: String = "Select a Home"
    @Published var selectedAccessoryInfo: String = "Select an Accessory"
    @Published var sensorReadings: [SensorReading] = []
    // Separate properties for each sensor type
    @Published var co2Level: String = ""
    @Published var no2Density: String = ""
    @Published var pm25Density: String = ""
    @Published var vocDensity: String = ""
    @Published var temperature: String = ""
    @Published var humidity: String = ""
    
    private var homeManager: HMHomeManager = HMHomeManager()
    private let selectedHomeKey = "SelectedHomeIdentifier"
    private let selectedAccessoryKey = "SelectedAccessoryIdentifier"
    
    var updateTimer: Timer?
    
    override init() {
        super.init()
        self.selectedAccessoryInfo = "Loading data..."
        self.homeManager.delegate = self
        loadSavedSelections()
        startUpdatingCO2Level()
    }
    
    struct SensorReading {
        let type: String
        let value: String
    }
    
    func homeManagerDidUpdateHomes(_ manager: HMHomeManager) {
        self.homes = manager.homes
        if !homes.isEmpty {
            loadSavedSelections()
        }
    }
    
    private func loadSavedSelections() {
        if let homeIdentifier = UserDefaults.standard.string(forKey: selectedHomeKey),
           let accessoryIdentifier = UserDefaults.standard.string(forKey: selectedAccessoryKey),
           let home = homes.first(where: { $0.uniqueIdentifier.uuidString == homeIdentifier }),
           let accessory = home.accessories.first(where: { $0.uniqueIdentifier.uuidString == accessoryIdentifier }) {
            DispatchQueue.main.async {
                self.selectHome(home)
                self.selectAccessory(accessory)
            }
        }
    }
    
    func selectHome(_ home: HMHome) {
        UserDefaults.standard.set(home.uniqueIdentifier.uuidString, forKey: selectedHomeKey)
        self.selectedHome = home
        refreshAirQualityValues()
    }
    
    func selectAccessory(_ accessory: HMAccessory) {
        UserDefaults.standard.set(accessory.uniqueIdentifier.uuidString, forKey: selectedAccessoryKey)
        self.selectedAccessory = accessory
        refreshAirQualityValues()
    }
    
    func startUpdatingCO2Level() {
        updateTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            self?.refreshAirQualityValues()
        }
    }
    
    private func refreshAirQualityValues() {
        guard let accessory = self.selectedAccessory else {
            self.selectedAccessoryInfo = "No Accessory Selected"
            return
        }
        
        for service in accessory.services {
            for characteristic in service.characteristics {
                var shouldReadValue = false
                
                switch service.serviceType {
                case HMServiceTypeAirQualitySensor:
                    shouldReadValue = true
                case HMServiceTypeTemperatureSensor:
                    shouldReadValue = true
                case HMServiceTypeHumiditySensor:
                    shouldReadValue = true
                default: break
                }
                
                if shouldReadValue {
                    characteristic.readValue { error in
                        DispatchQueue.main.async {
                            self.updateSensorReading(characteristic)
                        }
                    }
                }
            }
        }
    }
    
    private func updateSensorReading(_ characteristic: HMCharacteristic) {
        if let value = characteristic.value as? Int{
            switch characteristic.characteristicType {
            case HMCharacteristicTypeCarbonDioxideLevel:
                co2Level = "\(value)"
            case HMCharacteristicTypeNitrogenDioxideDensity:
                no2Density = "\(value)"
            case HMCharacteristicTypePM2_5Density:
                pm25Density = "\(value)"
            case HMCharacteristicTypeVolatileOrganicCompoundDensity:
                vocDensity = "\(value)"
            case HMCharacteristicTypeCurrentTemperature:
                temperature = "\(round((Double(value)*1.8)+32))"
            case HMCharacteristicTypeCurrentRelativeHumidity:
                humidity = "\(value)"
            default: break
            }
        }
    }
}

