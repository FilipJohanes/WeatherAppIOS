//
//  WeatherAvatarView.swift
//  DailyBrief
//
//  Animated weather avatar with dynamic outfit changes
//

import SwiftUI

struct WeatherAvatarView: View {
    let weather: Weather?
    let windSpeed: Double?
    
    @State private var breathingScale: CGFloat = 1.0
    @State private var accessoryOffset: CGFloat = 0
    @State private var accessoryRotation: Double = 0
    
    private let config = AvatarAnimationConfig.default
    
    init(weather: Weather?, windSpeed: Double? = nil) {
        self.weather = weather
        self.windSpeed = windSpeed
    }
    
    private var currentOutfit: WeatherOutfit {
        guard let weather = weather else { return .cloudy }
        return WeatherAvatarMapper.getOutfit(for: weather, windSpeed: windSpeed)
    }
    
    var body: some View {
        ZStack {
            // Base character layers
            baseCharacter
            
            // Outfit layer (changes with weather)
            outfitLayer
            
            // Accessory layer (optional, changes with weather)
            if let accessory = currentOutfit.accessoryImageName {
                accessoryLayer(accessory)
            }
        }
        .scaleEffect(breathingScale)
        .onAppear {
            startBreathingAnimation()
            if currentOutfit.hasAnimatedAccessory {
                startAccessoryAnimation()
            }
        }
        .onChange(of: currentOutfit) { _ in
            // Restart accessory animation if outfit changed
            if currentOutfit.hasAnimatedAccessory {
                startAccessoryAnimation()
            } else {
                stopAccessoryAnimation()
            }
        }
    }
    
    // MARK: - Layers
    
    private var baseCharacter: some View {
        VStack(spacing: 0) {
            // Head
            Image("character_head")
                .resizable()
                .scaledToFit()
            
            // Body
            Image("character_body")
                .resizable()
                .scaledToFit()
        }
    }
    
    private var outfitLayer: some View {
        Image(currentOutfit.outfitImageName)
            .resizable()
            .scaledToFit()
            .transition(.opacity)
            .animation(.easeInOut(duration: config.outfitTransitionDuration), value: currentOutfit)
    }
    
    private func accessoryLayer(_ accessoryName: String) -> some View {
        Image(accessoryName)
            .resizable()
            .scaledToFit()
            .offset(y: accessoryOffset)
            .rotationEffect(.degrees(accessoryRotation))
            .transition(.opacity)
            .animation(.easeInOut(duration: config.outfitTransitionDuration), value: currentOutfit)
    }
    
    // MARK: - Animations
    
    private func startBreathingAnimation() {
        withAnimation(
            .easeInOut(duration: config.breathingDuration)
            .repeatForever(autoreverses: true)
        ) {
            breathingScale = config.breathingScale
        }
    }
    
    private func startAccessoryAnimation() {
        switch currentOutfit {
        case .rainy:
            // Umbrella bounce
            withAnimation(
                .easeInOut(duration: config.umbrellaBounceDuration)
                .repeatForever(autoreverses: true)
            ) {
                accessoryOffset = -8
            }
            
        case .windy:
            // Scarf sway
            withAnimation(
                .easeInOut(duration: config.scarfSwayDuration)
                .repeatForever(autoreverses: true)
            ) {
                accessoryRotation = config.scarfSwayAngle
            }
            
        default:
            break
        }
    }
    
    private func stopAccessoryAnimation() {
        withAnimation(.easeOut(duration: 0.3)) {
            accessoryOffset = 0
            accessoryRotation = 0
        }
    }
}

// MARK: - Preview

struct WeatherAvatarView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 30) {
            // Sunny - Using .clear instead of 0
            WeatherAvatarView(weather: Weather.preview(temp: 25, condition: .clear))
                .frame(width: 200, height: 200)
            
            Text("Sunny Outfit")
            
            // Rainy - Using .rain instead of 61
            WeatherAvatarView(weather: Weather.preview(temp: 15, condition: .rain))
                .frame(width: 200, height: 200)
            
            Text("Rainy Outfit")
            
            // Snowy - Using .snow instead of 71
            WeatherAvatarView(weather: Weather.preview(temp: -5, condition: .snow))
                .frame(width: 200, height: 200)
            
            Text("Snowy Outfit")
        }
        .padding()
    }
}

// MARK: - Weather Preview Helper

extension Weather {
    static func preview(temp: Double, condition: WeatherCondition) -> Weather {
        Weather(
            location: "Preview City",
            currentTemp: temp,
            feelsLike: temp,
            condition: condition,
            humidity: 50,
            windSpeed: 10,
            tempMin: temp - 5,
            tempMax: temp + 5,
            weekForecast: []
        )
    }
}
