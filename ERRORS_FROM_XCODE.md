⚠️ [WeatherStore] No cached weather for: Prague
⚠️ [WeatherStore] No cached weather for: Prague
   🌐 [WeatherService] Making API call to Open-Meteo
      Coordinates: (50.0824379, 14.4191593)
      Using preset: Temperature, Feels Like, Humidity, Wind, Precipitation
      Current params: weather_code,temperature_2m,apparent_temperature,relative_humidity_2m,wind_speed_10m,precipitation
      Hourly params: temperature_2m,precipitation,precipitation_probability,wind_speed_10m
      Daily params: weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max,precipitation_sum,wind_speed_10m_max
      URL: https://api.open-meteo.com/v1/forecast?latitude=50.0824379&longitude=14.4191593&timezone=auto&current=weather_code,temperature_2m,apparent_temperature,relative_humidity_2m,wind_speed_10m,precipitation&hourly=temperature_2m,precipitation,precipitation_probability,wind_speed_10m&daily=weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max,precipitation_sum,wind_speed_10m_max&forecast_days=7
      ✅ API call successful
      Resolved location: Prague 1
      Temperature: 2.9°C
📍 [WeatherStore] Updating weather cache for: Prague
   Coordinates: (50.0824379, 14.4191593)
   Weather location: Prague 1
   Temperature: 2.9°C
✅ [WeatherStore] Retrieved cached weather for: Prague
✅ [WeatherStore] Retrieved cached weather for: Prague

🌤️ [WeatherViewModel] === Fetching weather for all locations ===
   Total locations: 3
   📍 [updateCurrentLocation] Updating current location...
      GPS coordinates: (48.22218321982454, 17.397063439300968)
      Fetching weather for GPS location...
      ✅ Weather fetched: Prague 1, 2.9°C
📍 [WeatherStore] Updating weather cache for: Current Location
   Coordinates: (48.22218321982454, 17.397063439300968)
   Weather location: Prague 1
   Temperature: 2.9°C
      ✅ Current location updated in view model
   📦 Using BULK API for 2 locations (scalable: 2-9)

🌐 [WeatherService] Bulk API call for 2 locations
   Latitudes: 48.3071483,50.0824379
   Longitudes: 18.0591213,14.4191593
   Using preset: Temperature, Feels Like, Humidity, Wind, Precipitation
   URL: https://api.open-meteo.com/v1/forecast?latitude=48.3071483,50.0824379&longitude=18.0591213,14.4191593&timezone=auto&current=weather_code,temperature_2m,apparent_temperature,relative_humidity_2m,wind_speed_10m,precipitation&hourly=temperature_2m,precipitation,precipitation_probability,wind_speed_10m&daily=weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max,precipitation_sum,wind_speed_10m_max&forecast_days=7

🌤️ [WeatherViewModel] === Fetching weather for all locations ===
   Total locations: 3
   📍 [updateCurrentLocation] Updating current location...
      GPS coordinates: (48.22218321982454, 17.397063439300968)
      Fetching weather for GPS location...
      ✅ Weather fetched: Prague 1, 2.9°C
📍 [WeatherStore] Updating weather cache for: Current Location
   Coordinates: (48.22218321982454, 17.397063439300968)
   Weather location: Prague 1
   Temperature: 2.9°C
      ✅ Current location updated in view model
   📦 Using BULK API for 2 locations (scalable: 2-9)

🌐 [WeatherService] Bulk API call for 2 locations
   Latitudes: 48.3071483,50.0824379
   Longitudes: 18.0591213,14.4191593
   Using preset: Temperature, Feels Like, Humidity, Wind, Precipitation
   URL: https://api.open-meteo.com/v1/forecast?latitude=48.3071483,50.0824379&longitude=18.0591213,14.4191593&timezone=auto&current=weather_code,temperature_2m,apparent_temperature,relative_humidity_2m,wind_speed_10m,precipitation&hourly=temperature_2m,precipitation,precipitation_probability,wind_speed_10m&daily=weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max,precipitation_sum,wind_speed_10m_max&forecast_days=7
✅ [WeatherStore] Retrieved cached weather for: Prague
✅ [WeatherStore] Retrieved cached weather for: Prague
✅ [WeatherStore] Retrieved cached weather for: Prague
✅ [WeatherStore] Retrieved cached weather for: Prague
   ✅ Bulk API call successful
   ❌ Bulk API error: The data couldn’t be read because it isn’t in the correct format.
   🔄 [fetchWeatherForLocation] Starting for: Nitra
      Type: Manual Location
      Coordinates: (48.3071483, 18.0591213)
      ✅ Successfully fetched weather
📍 [WeatherStore] Updating weather cache for: Nitra
   Coordinates: (48.3071483, 18.0591213)
   Weather location: Prague 1
   Temperature: 2.9°C
   🔄 [fetchWeatherForLocation] Starting for: Prague
      Type: Manual Location
      Coordinates: (50.0824379, 14.4191593)
      ✅ Successfully fetched weather
📍 [WeatherStore] Updating weather cache for: Prague
   Coordinates: (50.0824379, 14.4191593)
   Weather location: Prague 1
   Temperature: 2.9°C
🌤️ [WeatherViewModel] === Weather fetch complete ===

✅ [WeatherStore] Retrieved cached weather for: Prague
✅ [WeatherStore] Retrieved cached weather for: Prague
✅ [WeatherStore] Retrieved cached weather for: Prague
✅ [WeatherStore] Retrieved cached weather for: Prague
   ✅ Bulk API call successful
   ❌ Bulk API error: The data couldn’t be read because it isn’t in the correct format.
   🔄 [fetchWeatherForLocation] Starting for: Nitra
      Type: Manual Location
      Coordinates: (48.3071483, 18.0591213)
      ✅ Successfully fetched weather
📍 [WeatherStore] Updating weather cache for: Nitra
   Coordinates: (48.3071483, 18.0591213)
   Weather location: Prague 1
   Temperature: 2.9°C
   🔄 [fetchWeatherForLocation] Starting for: Prague
      Type: Manual Location
      Coordinates: (50.0824379, 14.4191593)
      ✅ Successfully fetched weather
📍 [WeatherStore] Updating weather cache for: Prague
   Coordinates: (50.0824379, 14.4191593)
   Weather location: Prague 1
   Temperature: 2.9°C
🌤️ [WeatherViewModel] === Weather fetch complete ===

✅ [WeatherStore] Retrieved cached weather for: Prague
✅ [WeatherStore] Retrieved cached weather for: Prague
✅ [WeatherStore] Retrieved cached weather for: Prague
✅ [WeatherStore] Retrieved cached weather for: Prague
💾 [WeatherPresetStore] Saved preset: Temperature
💾 [WeatherPresetStore] Saved preset: Temperature, Feels Like, Humidity, Wind, Precipitation
💾 [WeatherPresetStore] Saved preset: Temperature, Feels Like, Humidity, Wind, Precipitation, Pressure, Visibility, UV Index
💾 [WeatherPresetStore] Saved preset: Temperature

🌤️ [WeatherViewModel] === Fetching weather for all locations ===
   Total locations: 3
   📍 [updateCurrentLocation] Updating current location...
      GPS coordinates: (48.22218263959571, 17.39706320099821)
      Fetching weather for GPS location...
      ✅ Weather fetched: Prague 1, 2.9°C
📍 [WeatherStore] Updating weather cache for: Current Location
   Coordinates: (48.22218263959571, 17.39706320099821)
   Weather location: Prague 1
   Temperature: 2.9°C
      ✅ Current location updated in view model
   📦 Using BULK API for 2 locations (scalable: 2-9)

🌐 [WeatherService] Bulk API call for 2 locations
   Latitudes: 48.3071483,50.0824379
   Longitudes: 18.0591213,14.4191593
   Using preset: Temperature
   URL: https://api.open-meteo.com/v1/forecast?latitude=48.3071483,50.0824379&longitude=18.0591213,14.4191593&timezone=auto&current=weather_code,temperature_2m&hourly=temperature_2m&daily=weather_code,temperature_2m_max,temperature_2m_min&forecast_days=7
✅ [WeatherStore] Retrieved cached weather for: Current Location
✅ [WeatherStore] Retrieved cached weather for: Current Location
   ✅ Bulk API call successful
   ❌ Bulk API error: The data couldn’t be read because it isn’t in the correct format.
   🔄 [fetchWeatherForLocation] Starting for: Nitra
      Type: Manual Location
      Coordinates: (48.3071483, 18.0591213)
      ✅ Successfully fetched weather
📍 [WeatherStore] Updating weather cache for: Nitra
   Coordinates: (48.3071483, 18.0591213)
   Weather location: Prague 1
   Temperature: 2.9°C
   🔄 [fetchWeatherForLocation] Starting for: Prague
      Type: Manual Location
      Coordinates: (50.0824379, 14.4191593)
      ✅ Successfully fetched weather
📍 [WeatherStore] Updating weather cache for: Prague
   Coordinates: (50.0824379, 14.4191593)
   Weather location: Prague 1
   Temperature: 2.9°C
🌤️ [WeatherViewModel] === Weather fetch complete ===

✅ [WeatherStore] Retrieved cached weather for: Current Location
✅ [WeatherStore] Retrieved cached weather for: Current Location
✅ [WeatherStore] Retrieved cached weather for: Current Location
✅ [WeatherStore] Retrieved cached weather for: Current Location
