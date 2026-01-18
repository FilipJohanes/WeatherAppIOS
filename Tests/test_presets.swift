#!/usr/bin/env swift

import Foundation

// Copy of the response structures from WeatherService
struct OpenMeteoResponse: Codable {
    let current: CurrentWeather
    let daily: DailyWeather
    
    struct CurrentWeather: Codable {
        let temperature_2m: Double
        let weather_code: Int
        let relative_humidity_2m: Int?
        let apparent_temperature: Double?
        let wind_speed_10m: Double?
        let wind_direction_10m: Double?
        let wind_gusts_10m: Double?
        let precipitation: Double?
        let rain: Double?
        let snowfall: Double?
        let surface_pressure: Double?
        let visibility: Double?
        let cloud_cover: Int?
        let uv_index: Double?
    }
    
    struct DailyWeather: Codable {
        let time: [String]
        let weather_code: [Int]
        let temperature_2m_max: [Double]
        let temperature_2m_min: [Double]
        let precipitation_probability_max: [Int]?
        let precipitation_sum: [Double]?
        let wind_speed_10m_max: [Double]?
        let uv_index_max: [Double]?
    }
}

func testPreset(name: String, url: String) async throws {
    print("\n🧪 Testing \(name)...")
    print("   URL: \(url)")
    
    guard let apiURL = URL(string: url) else {
        throw NSError(domain: "TestError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
    }
    
    let (data, response) = try await URLSession.shared.data(from: apiURL)
    
    guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
        throw NSError(domain: "TestError", code: 2, userInfo: [NSLocalizedDescriptionKey: "HTTP error"])
    }
    
    // Try to decode
    do {
        let decoded = try JSONDecoder().decode(OpenMeteoResponse.self, from: data)
        print("   ✅ Decoding successful!")
        print("   📊 Temperature: \(decoded.current.temperature_2m)°C")
        print("   📊 Weather Code: \(decoded.current.weather_code)")
        
        if let humidity = decoded.current.relative_humidity_2m {
            print("   📊 Humidity: \(humidity)%")
        }
        if let feelsLike = decoded.current.apparent_temperature {
            print("   📊 Feels Like: \(feelsLike)°C")
        }
        if let wind = decoded.current.wind_speed_10m {
            print("   📊 Wind: \(wind) km/h")
        }
        if let pressure = decoded.current.surface_pressure {
            print("   📊 Pressure: \(pressure) hPa")
        }
        if let visibility = decoded.current.visibility {
            print("   📊 Visibility: \(visibility) m")
        }
        
        print("   📅 Forecast days: \(decoded.daily.time.count)")
        print("   🎯 Result: PASS ✅")
        
    } catch let error as DecodingError {
        print("   ❌ Decoding failed!")
        switch error {
        case .keyNotFound(let key, let context):
            print("   Missing key: \(key.stringValue)")
            print("   Context: \(context.debugDescription)")
        case .typeMismatch(let type, let context):
            print("   Type mismatch: \(type)")
            print("   Context: \(context.debugDescription)")
        case .valueNotFound(let type, let context):
            print("   Value not found: \(type)")
            print("   Context: \(context.debugDescription)")
        case .dataCorrupted(let context):
            print("   Data corrupted: \(context.debugDescription)")
        @unknown default:
            print("   Unknown error: \(error)")
        }
        print("   🎯 Result: FAIL ❌")
        throw error
    }
}

// Test all presets
Task {
    let lat = "48.22218"
    let lon = "17.39707"
    let base = "https://api.open-meteo.com/v1/forecast?latitude=\(lat)&longitude=\(lon)&timezone=auto"
    
    print("=" .repeating(70))
    print("WEATHER PRESET COMPATIBILITY TEST")
    print("Testing all preset combinations with real API responses")
    print("=" .repeating(70))
    
    do {
        // Test 1: Minimal preset
        try await testPreset(
            name: "MINIMAL PRESET",
            url: "\(base)&current=weather_code,temperature_2m&hourly=temperature_2m&daily=weather_code,temperature_2m_max,temperature_2m_min&forecast_days=7"
        )
        
        // Test 2: Standard preset
        try await testPreset(
            name: "STANDARD PRESET",
            url: "\(base)&current=weather_code,temperature_2m,apparent_temperature,relative_humidity_2m,wind_speed_10m,precipitation&hourly=temperature_2m,precipitation,precipitation_probability,wind_speed_10m&daily=weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max,precipitation_sum,wind_speed_10m_max&forecast_days=7"
        )
        
        // Test 3: Complete preset
        try await testPreset(
            name: "COMPLETE PRESET",
            url: "\(base)&current=weather_code,temperature_2m,apparent_temperature,relative_humidity_2m,wind_speed_10m,wind_direction_10m,wind_gusts_10m,precipitation,rain,snowfall,surface_pressure,visibility,cloud_cover&hourly=temperature_2m,precipitation,precipitation_probability,rain,snowfall,wind_speed_10m,uv_index&daily=weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max,precipitation_sum,wind_speed_10m_max,uv_index_max&forecast_days=7"
        )
        
        print("\n" + "=" .repeating(70))
        print("🎉 ALL TESTS PASSED! All presets work correctly.")
        print("=" .repeating(70))
        
    } catch {
        print("\n" + "=" .repeating(70))
        print("❌ TEST SUITE FAILED")
        print("=" .repeating(70))
        exit(1)
    }
    
    exit(0)
}

// Keep the script running
RunLoop.main.run()
