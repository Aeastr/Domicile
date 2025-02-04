//
//  LightControlView.swift
//  Abode
//
//  Created by Aether on 08/11/2024.
//


// LightControlView.swift

import SwiftUI
import HomeKit

struct LightControlView: View {
    let accessory: HMAccessory
    let homeStore: HomeStore
    @Binding var brightness: Double
    @Binding var color: Color
    @Binding var isOn: Bool
    @State private var showingColorPicker = false

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(accessory.name)
                Spacer()
                Button(action: {
                    homeStore.toggleLight(accessory)
                    isOn.toggle()
                }) {
                    Image(systemName: isOn ? "lightbulb.fill" : "lightbulb")
                }
            }
            
            Slider(value: $brightness, in: 0...100, step: 1) { _ in
                homeStore.adjustBrightness(accessory, to: Int(brightness))
                if brightness > 0 && !isOn {
                    isOn = true
                } else if brightness == 0 && isOn {
                    isOn = false
                }
            }

            if homeStore.supportsColor(accessory) {
                HStack {
                    Text("Color")
                    Spacer()
                    ColorPicker("Select color", selection: $color)
                        .onChange(of: color) { newColor in
                            homeStore.changeColor(accessory, to: UIColor(newColor))
                        }
                }
            }
        }
        .padding()
        .onAppear {
            initializeLightState()
        }
    }
    
    private func initializeLightState() {
        if let brightnessCharacteristic = accessory.find(serviceType: HMServiceTypeLightbulb, characteristicType: HMCharacteristicTypeBrightness) {
            brightness = brightnessCharacteristic.value as? Double ?? 0
        }
        if let powerCharacteristic = accessory.find(serviceType: HMServiceTypeLightbulb, characteristicType: HMCharacteristicTypePowerState) {
            isOn = powerCharacteristic.value as? Bool ?? false
        }
        if brightness > 0 {
            isOn = true
        }
        updateColor()
    }
    
    private func updateColor() {
        if let hueCharacteristic = accessory.find(serviceType: HMServiceTypeLightbulb, characteristicType: HMCharacteristicTypeHue),
           let satCharacteristic = accessory.find(serviceType: HMServiceTypeLightbulb, characteristicType: HMCharacteristicTypeSaturation) {

            if let hueValue = hueCharacteristic.value as? Double,
               let satValue = satCharacteristic.value as? Double {

                let normalizedHue = hueValue / 360.0
                let normalizedSaturation = satValue / 100.0

                color = Color(hue: normalizedHue, saturation: normalizedSaturation, brightness: 1.0)
            } else {
                print("Failed to cast characteristic values")
            }
        } else {
            print("Failed to retrieve characteristic values")
        }
    }
}