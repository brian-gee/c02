import SwiftUI
import HomeKit

struct ContentView: View {
    @ObservedObject var homeKitManager = HomeKitManager()
    @State private var showingSelectionView = false
    @State private var isMenuOpen: Bool = false
    
    private var gridLayout: [GridItem] = Array(repeating: .init(.flexible(), spacing: 15), count: 2)
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    // LazyVGrid to display sensor readings
                    LazyVGrid(columns: gridLayout, spacing: 20) {
                        if homeKitManager.isCO2Visible {
                            SensorReadingView(reading: homeKitManager.co2Level)
                        }
                        if homeKitManager.isTemperatureVisible {
                            SensorReadingView(reading: homeKitManager.temperature)
                        }
                        if homeKitManager.isHumidityVisible {
                            SensorReadingView(reading: homeKitManager.humidity)
                        }
                        if homeKitManager.isPM25Visible {
                            SensorReadingView(reading: homeKitManager.pm25Density)
                        }
                        if homeKitManager.isVOCVisible {
                            SensorReadingView(reading: homeKitManager.vocDensity)
                        }
                        if homeKitManager.isNO2Visible {
                            SensorReadingView(reading: homeKitManager.no2Density)
                        }
                    }
                    .padding(.horizontal)
                    
                    Button(action: {
                        showingSelectionView.toggle()
                    }) {
                        Text("Select Home and Accessory")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue.opacity(0.7))
                            .cornerRadius(8)
                    }
                    .padding()
                }
                .navigationBarTitle("Brian's Air Monitor", displayMode: .inline)
                .navigationBarItems(leading: Button(action: {
                    withAnimation {
                        self.isMenuOpen.toggle()
                    }
                }) {
                    Image(systemName: "line.horizontal.3") // Hamburger icon
                })
                
                // Side Menu
                if isMenuOpen {
                    GeometryReader { geometry in
                        SideMenuView(isCO2Visible: $homeKitManager.isCO2Visible,
                                     isTemperatureVisible: $homeKitManager.isTemperatureVisible,
                                     isHumidityVisible: $homeKitManager.isHumidityVisible,
                                     isPM25Visible: $homeKitManager.isPM25Visible,
                                     isVOCVisible: $homeKitManager.isVOCVisible,
                                     isNO2Visible: $homeKitManager.isNO2Visible)
                    }
                }
            }
        }
        .sheet(isPresented: $showingSelectionView) {
            VStack {
                Spacer()
                
                // Home Selection
                if showingSelectionView {
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
                }
                
                Spacer()
            }
        }
    }
    struct SensorReadingView: View {
        let reading: String
        
        var body: some View {
            Text(reading)
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 100, maxHeight: 100) // Flexible width
                .multilineTextAlignment(.center) // Centers the text horizontally
                .padding() // Adds padding inside the frame
                .background(Color.blue.opacity(0.7)) // Sets the background color
                .cornerRadius(10) // Rounds the corners
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.white, lineWidth: 2) // Optional: Adds a border
                )
        }
    }
    
    struct SideMenuView: View {
        @Binding var isCO2Visible: Bool
        @Binding var isTemperatureVisible: Bool
        @Binding var isHumidityVisible: Bool
        @Binding var isPM25Visible: Bool
        @Binding var isVOCVisible: Bool
        @Binding var isNO2Visible: Bool
        
        var body: some View {
            VStack(alignment: .leading) {
                Toggle("CO2 Level", isOn: $isCO2Visible)
                Toggle("Temperature", isOn: $isTemperatureVisible)
                Toggle("Humidity", isOn: $isHumidityVisible)
                Toggle("PM2.5 Density", isOn: $isPM25Visible)
                Toggle("VOC Density", isOn: $isVOCVisible)
                Toggle("NO2 Density", isOn: $isNO2Visible)
                Spacer()
            }
            .padding()
            .background(.gray)
        }
    }
}
