import SwiftUI
import HomeKit

struct ContentView: View {
    @ObservedObject var homeKitManager = HomeKitManager()
    @State private var showingSelectionView = false
    
    // Define the grid layout
    private var gridLayout: [GridItem] = Array(repeating: .init(.flexible(), spacing: 0), count: 2)

    var body: some View {
        VStack {
            Spacer()
            
            // LazyVGrid to display the sensor readings
            LazyVGrid(columns: gridLayout, spacing: 10) {
                SensorReadingView(reading: homeKitManager.co2Level)
                SensorReadingView(reading: homeKitManager.no2Density)
                SensorReadingView(reading: homeKitManager.pm25Density)
                SensorReadingView(reading: homeKitManager.vocDensity)
                SensorReadingView(reading: homeKitManager.temperature)
                SensorReadingView(reading: homeKitManager.humidity)
            }
            .padding(.horizontal)
            
            Spacer()
            
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
                .frame(minWidth: 100, maxWidth: 100, minHeight: 100, maxHeight: 100) // Sets the frame to be square
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
