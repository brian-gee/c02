import SwiftUI
import HomeKit

struct ContentView: View {
    @ObservedObject var homeKitManager = HomeKitManager()
    @State private var showingSelectionView = false
    
    // Define the grid layout
    private var gridLayout: [GridItem] = Array(repeating: .init(.flexible(), spacing: 10), count: 2)
    
    var body: some View {
        NavigationView {
            VStack {
                // LazyVGrid to display the sensor readings
                LazyVGrid(columns: gridLayout, spacing: 10) {
                    SensorReadingView(reading: homeKitManager.co2Level)
                    SensorReadingView(reading: homeKitManager.temperature)
                    SensorReadingView(reading: homeKitManager.humidity)
                    SensorReadingView(reading: homeKitManager.pm25Density)
                    SensorReadingView(reading: homeKitManager.vocDensity)
                    SensorReadingView(reading: homeKitManager.no2Density)
                }
                .padding(.horizontal)
                
                // Button to show selection view
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
}
