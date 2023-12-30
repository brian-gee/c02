import SwiftUI
import HomeKit

struct ContentView: View {
    @ObservedObject var homeKitManager = HomeKitManager()
    @State private var isMenuOpen: Bool = false
    
    private var gridLayout: [GridItem] = Array(repeating: .init(.flexible(), spacing: 15), count: 1)
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    // LazyVGrid to display sensor readings
                    LazyVGrid(columns: gridLayout, spacing: 20) {
                        MainReadingView(reading: homeKitManager.co2Level, text:"CO2(ppm)")
                        SensorReadingView(reading: homeKitManager.pm25Density, text: "PM2.5", unit: "(μg/m³)", lower: 25, upper: 50)
                        SensorReadingView(reading: homeKitManager.vocDensity, text: "TVOC", unit: "μg/m³", lower: 50, upper: 100)
                        SensorReadingView(reading: homeKitManager.no2Density, text: "NOx", unit: "μg/m³", lower:25, upper: 50)
                        SensorReadingView(reading: homeKitManager.temperature, text: "Temp", unit: "°F")
                        SensorReadingView(reading: homeKitManager.humidity, text: "Humidity", unit: "%")
                    }
                    .padding(.horizontal)
                }
                .navigationBarTitle("OpenAir Monitor", displayMode: .inline)
                .navigationBarItems(leading: Button(action: {
                    withAnimation {
                        self.isMenuOpen.toggle()
                    }
                }) {
                    Image(systemName: "line.horizontal.3") // Hamburger icon
                })
                
                // Side Menu
                if isMenuOpen {
                    SideMenuView(
                        homeKitManager: homeKitManager
                    )
                }
            }
        }
    }
}


struct MainReadingView: View {
    let reading: String
    let text: String
    
    var body: some View {
        ZStack {
            // Circle background with dynamic color
            Circle()
                .fill(backgroundColor(for: reading))
            
            // Stacked texts with different sizes
            VStack {
                Text(reading)
                    .font(.system(size: 36, weight: .bold)) // Larger text for the reading
                    .foregroundColor(.white)
                
                Text(text)
                    .font(.system(size: 16)) // Smaller text for the additional text
                    .foregroundColor(.white)
            }
        }
        .frame(width: 200, height: 200) // Set the frame size for the circle
    }
    
    // Helper function to determine background color based on reading
    private func backgroundColor(for reading: String) -> Color {
        // Assuming 'reading' is a string representation of a number
        if let value = Double(reading) {
            switch value {
            case ..<800:
                return .green.opacity(0.7)
            case 800..<1500:
                return .yellow.opacity(0.7)
            default:
                return .red.opacity(0.7)
            }
        } else {
            return .blue.opacity(0.7) // Default color if 'reading' is not a number
        }
    }
}

struct SensorReadingView: View {
    let reading: String
    let text: String
    let unit: String
    let lower: Int?
    let upper: Int?
    
    init(reading: String, text: String, unit: String, lower: Int? = nil, upper: Int? = nil) {
          self.reading = reading
          self.text = text
          self.unit = unit
          self.lower = lower
          self.upper = upper
      }
    
    var body: some View {
        HStack {
            Text(text)
                .frame(maxWidth: .infinity, alignment: .leading) // Left-align the text
            Text(reading)
                .font(.system(size: 24, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .center) // Center-align the reading
            Text(unit)
                .frame(maxWidth: .infinity, alignment: .center) // Center-align the reading
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 40, maxHeight: 40) // Flexible width and height for the whole HStack
        .padding() // Adds padding inside the frame
        .background(backgroundColor(for: reading)) // Sets the background color
        .cornerRadius(10) // Rounds the corners
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.white, lineWidth: 2) // Optional: Adds a border
        )
    }
    
    private func backgroundColor(for reading: String) -> Color {
        guard let value = Int(reading) else {
            return .blue.opacity(0.7) // Default color if 'reading' is not a number
        }

        if let lowerBound = lower, let upperBound = upper {
            switch value {
            case ..<lowerBound:
                return .green.opacity(0.7)
            case lowerBound..<upperBound:
                return .yellow.opacity(0.7)
            default:
                return .red.opacity(0.7)
            }
        } else {
            // Return a default color when there are no bounds
            return .blue.opacity(0.7)
        }
    }
}



struct SideMenuView: View {
    @ObservedObject var homeKitManager: HomeKitManager
    
    var body: some View {
        VStack(alignment: .leading) {
            Spacer()
            // Home Selection
            Picker("Select Home", selection: $homeKitManager.selectedHome) {
                ForEach(homeKitManager.homes, id: \.uniqueIdentifier) { home in
                    Text(home.name).tag(home as HMHome?)
                }
            }
            .onChange(of: homeKitManager.selectedHome) { newHome in
                if let home = newHome {
                    homeKitManager.selectHome(home)
                }
            }
            
            // Accessory Selection
            if let home = homeKitManager.selectedHome, !home.accessories.isEmpty {
                Picker("Select Accessory", selection: $homeKitManager.selectedAccessory) {
                    ForEach(home.accessories, id: \.uniqueIdentifier) { accessory in
                        Text(accessory.name).tag(accessory as HMAccessory?)
                    }
                }
                .onChange(of: homeKitManager.selectedAccessory) { newAccessory in
                    if let accessory = newAccessory {
                        homeKitManager.selectAccessory(accessory)
                    }
                }
            }
            Spacer()
        }
        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
        .padding()
        .background(Color.black)
    }
}
