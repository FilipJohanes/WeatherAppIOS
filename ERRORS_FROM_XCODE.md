⚠️ [WeatherStore] No cached weather for: Current Location
⚠️ [WeatherStore] No cached weather for: Current Location
   🌐 [WeatherService] Making API call to Open-Meteo
      Coordinates: (48.2221804538452, 17.39706839552873)
      Using preset: Temperature
      Current params: weather_code,temperature_2m
      Hourly params: temperature_2m
      Daily params: weather_code,temperature_2m_max,temperature_2m_min
      URL: https://api.open-meteo.com/v1/forecast?latitude=48.2221804538452&longitude=17.39706839552873&timezone=auto&current=weather_code,temperature_2m&hourly=temperature_2m&daily=weather_code,temperature_2m_max,temperature_2m_min&forecast_days=7
      ✅ API call successful
   🌐 [WeatherService] Making API call to Open-Meteo
      Coordinates: (48.22218045384519, 17.39706839552873)
      Using preset: Temperature
      Current params: weather_code,temperature_2m
      Hourly params: temperature_2m
      Daily params: weather_code,temperature_2m_max,temperature_2m_min
      URL: https://api.open-meteo.com/v1/forecast?latitude=48.22218045384519&longitude=17.39706839552873&timezone=auto&current=weather_code,temperature_2m&hourly=temperature_2m&daily=weather_code,temperature_2m_max,temperature_2m_min&forecast_days=7
      ✅ API call successful

🌤️ [WeatherViewModel] === Fetching weather for all locations ===
   Total locations: 3
   📍 [updateCurrentLocation] Updating current location...
      GPS coordinates: (48.22218045384519, 17.39706839552873)
      Fetching weather for GPS location...
   🌐 [WeatherService] Making API call to Open-Meteo
      Coordinates: (48.22218045384519, 17.39706839552873)
      Using preset: Temperature
      Current params: weather_code,temperature_2m
      Hourly params: temperature_2m
      Daily params: weather_code,temperature_2m_max,temperature_2m_min
      URL: https://api.open-meteo.com/v1/forecast?latitude=48.22218045384519&longitude=17.39706839552873&timezone=auto&current=weather_code,temperature_2m&hourly=temperature_2m&daily=weather_code,temperature_2m_max,temperature_2m_min&forecast_days=7

🌤️ [WeatherViewModel] === Fetching weather for all locations ===
   Total locations: 3
   📍 [updateCurrentLocation] Updating current location...
      GPS coordinates: (48.22218045384519, 17.39706839552873)
      Fetching weather for GPS location...
   🌐 [WeatherService] Making API call to Open-Meteo
      Coordinates: (48.22218045384519, 17.39706839552873)
      Using preset: Temperature
      Current params: weather_code,temperature_2m
      Hourly params: temperature_2m
      Daily params: weather_code,temperature_2m_max,temperature_2m_min
      URL: https://api.open-meteo.com/v1/forecast?latitude=48.22218045384519&longitude=17.39706839552873&timezone=auto&current=weather_code,temperature_2m&hourly=temperature_2m&daily=weather_code,temperature_2m_max,temperature_2m_min&forecast_days=7
      ✅ API call successful
      ❌ Failed to fetch current location weather: keyNotFound(CodingKeys(stringValue: "relative_humidity_2m", intValue: nil), Swift.DecodingError.Context(codingPath: [CodingKeys(stringValue: "current", intValue: nil)], debugDescription: "No value associated with key CodingKeys(stringValue: \"relative_humidity_2m\", intValue: nil) (\"relative_humidity_2m\").", underlyingError: nil))
   📦 Using BULK API for 2 locations (scalable: 2-9)

🌐 [WeatherService] Bulk API call for 2 locations
   Latitudes: 48.3071483,50.0824379
   Longitudes: 18.0591213,14.4191593
   Using preset: Temperature
   URL: https://api.open-meteo.com/v1/forecast?latitude=48.3071483,50.0824379&longitude=18.0591213,14.4191593&timezone=auto&current=weather_code,temperature_2m&hourly=temperature_2m&daily=weather_code,temperature_2m_max,temperature_2m_min&forecast_days=7
   ✅ Bulk API call successful
   ❌ Bulk API error: The data couldn’t be read because it is missing.
   🔄 [fetchWeatherForLocation] Starting for: Nitra
      Type: Manual Location
      Coordinates: (48.3071483, 18.0591213)
   🌐 [WeatherService] Making API call to Open-Meteo
      Coordinates: (48.3071483, 18.0591213)
      Using preset: Temperature
      Current params: weather_code,temperature_2m
      Hourly params: temperature_2m
      Daily params: weather_code,temperature_2m_max,temperature_2m_min
      URL: https://api.open-meteo.com/v1/forecast?latitude=48.3071483&longitude=18.0591213&timezone=auto&current=weather_code,temperature_2m&hourly=temperature_2m&daily=weather_code,temperature_2m_max,temperature_2m_min&forecast_days=7
      ✅ API call successful
      ❌ Error: The data couldn’t be read because it is missing.
   🔄 [fetchWeatherForLocation] Starting for: Prague
      Type: Manual Location
      Coordinates: (50.0824379, 14.4191593)
   🌐 [WeatherService] Making API call to Open-Meteo
      Coordinates: (50.0824379, 14.4191593)
      Using preset: Temperature
      Current params: weather_code,temperature_2m
      Hourly params: temperature_2m
      Daily params: weather_code,temperature_2m_max,temperature_2m_min
      URL: https://api.open-meteo.com/v1/forecast?latitude=50.0824379&longitude=14.4191593&timezone=auto&current=weather_code,temperature_2m&hourly=temperature_2m&daily=weather_code,temperature_2m_max,temperature_2m_min&forecast_days=7
      ✅ API call successful
      ❌ Failed to fetch current location weather: keyNotFound(CodingKeys(stringValue: "relative_humidity_2m", intValue: nil), Swift.DecodingError.Context(codingPath: [CodingKeys(stringValue: "current", intValue: nil)], debugDescription: "No value associated with key CodingKeys(stringValue: \"relative_humidity_2m\", intValue: nil) (\"relative_humidity_2m\").", underlyingError: nil))
   📦 Using BULK API for 2 locations (scalable: 2-9)

🌐 [WeatherService] Bulk API call for 2 locations
   Latitudes: 48.3071483,50.0824379
   Longitudes: 18.0591213,14.4191593
   Using preset: Temperature
   URL: https://api.open-meteo.com/v1/forecast?latitude=48.3071483,50.0824379&longitude=18.0591213,14.4191593&timezone=auto&current=weather_code,temperature_2m&hourly=temperature_2m&daily=weather_code,temperature_2m_max,temperature_2m_min&forecast_days=7
      ✅ API call successful
      ❌ Error: The data couldn’t be read because it is missing.
🌤️ [WeatherViewModel] === Weather fetch complete ===

   ✅ Bulk API call successful
   ❌ Bulk API error: The data couldn’t be read because it is missing.
   🔄 [fetchWeatherForLocation] Starting for: Nitra
      Type: Manual Location
      Coordinates: (48.3071483, 18.0591213)
   🌐 [WeatherService] Making API call to Open-Meteo
      Coordinates: (48.3071483, 18.0591213)
      Using preset: Temperature
      Current params: weather_code,temperature_2m
      Hourly params: temperature_2m
      Daily params: weather_code,temperature_2m_max,temperature_2m_min
      URL: https://api.open-meteo.com/v1/forecast?latitude=48.3071483&longitude=18.0591213&timezone=auto&current=weather_code,temperature_2m&hourly=temperature_2m&daily=weather_code,temperature_2m_max,temperature_2m_min&forecast_days=7
      ✅ API call successful
      ❌ Error: The data couldn’t be read because it is missing.
   🔄 [fetchWeatherForLocation] Starting for: Prague
      Type: Manual Location
      Coordinates: (50.0824379, 14.4191593)
   🌐 [WeatherService] Making API call to Open-Meteo
      Coordinates: (50.0824379, 14.4191593)
      Using preset: Temperature
      Current params: weather_code,temperature_2m
      Hourly params: temperature_2m
      Daily params: weather_code,temperature_2m_max,temperature_2m_min
      URL: https://api.open-meteo.com/v1/forecast?latitude=50.0824379&longitude=14.4191593&timezone=auto&current=weather_code,temperature_2m&hourly=temperature_2m&daily=weather_code,temperature_2m_max,temperature_2m_min&forecast_days=7
      ✅ API call successful
      ❌ Error: The data couldn’t be read because it is missing.
🌤️ [WeatherViewModel] === Weather fetch complete ===


🌤️ [WeatherViewModel] === Fetching weather for all locations ===
   Total locations: 3
   📍 [updateCurrentLocation] Updating current location...
      GPS coordinates: (48.22218045384519, 17.39706839552873)
      Fetching weather for GPS location...
   🌐 [WeatherService] Making API call to Open-Meteo
      Coordinates: (48.22218045384519, 17.39706839552873)
      Using preset: Temperature
      Current params: weather_code,temperature_2m
      Hourly params: temperature_2m
      Daily params: weather_code,temperature_2m_max,temperature_2m_min
      URL: https://api.open-meteo.com/v1/forecast?latitude=48.22218045384519&longitude=17.39706839552873&timezone=auto&current=weather_code,temperature_2m&hourly=temperature_2m&daily=weather_code,temperature_2m_max,temperature_2m_min&forecast_days=7
      ✅ API call successful
      ❌ Failed to fetch current location weather: keyNotFound(CodingKeys(stringValue: "relative_humidity_2m", intValue: nil), Swift.DecodingError.Context(codingPath: [CodingKeys(stringValue: "current", intValue: nil)], debugDescription: "No value associated with key CodingKeys(stringValue: \"relative_humidity_2m\", intValue: nil) (\"relative_humidity_2m\").", underlyingError: nil))
   📦 Using BULK API for 2 locations (scalable: 2-9)

🌐 [WeatherService] Bulk API call for 2 locations
   Latitudes: 48.3071483,50.0824379
   Longitudes: 18.0591213,14.4191593
   Using preset: Temperature
   URL: https://api.open-meteo.com/v1/forecast?latitude=48.3071483,50.0824379&longitude=18.0591213,14.4191593&timezone=auto&current=weather_code,temperature_2m&hourly=temperature_2m&daily=weather_code,temperature_2m_max,temperature_2m_min&forecast_days=7
   ✅ Bulk API call successful
   ❌ Bulk API error: The data couldn’t be read because it is missing.
   🔄 [fetchWeatherForLocation] Starting for: Nitra
      Type: Manual Location
      Coordinates: (48.3071483, 18.0591213)
   🌐 [WeatherService] Making API call to Open-Meteo
      Coordinates: (48.3071483, 18.0591213)
      Using preset: Temperature
      Current params: weather_code,temperature_2m
      Hourly params: temperature_2m
      Daily params: weather_code,temperature_2m_max,temperature_2m_min
      URL: https://api.open-meteo.com/v1/forecast?latitude=48.3071483&longitude=18.0591213&timezone=auto&current=weather_code,temperature_2m&hourly=temperature_2m&daily=weather_code,temperature_2m_max,temperature_2m_min&forecast_days=7
      ✅ API call successful
      ❌ Error: The data couldn’t be read because it is missing.
   🔄 [fetchWeatherForLocation] Starting for: Prague
      Type: Manual Location
      Coordinates: (50.0824379, 14.4191593)
   🌐 [WeatherService] Making API call to Open-Meteo
      Coordinates: (50.0824379, 14.4191593)
      Using preset: Temperature
      Current params: weather_code,temperature_2m
      Hourly params: temperature_2m
      Daily params: weather_code,temperature_2m_max,temperature_2m_min
      URL: https://api.open-meteo.com/v1/forecast?latitude=50.0824379&longitude=14.4191593&timezone=auto&current=weather_code,temperature_2m&hourly=temperature_2m&daily=weather_code,temperature_2m_max,temperature_2m_min&forecast_days=7
      ✅ API call successful
      ❌ Error: The data couldn’t be read because it is missing.
🌤️ [WeatherViewModel] === Weather fetch complete ===

tcp_input [C2.1.1:3] flags=[R] seq=2770822237, ack=0, win=0 state=LAST_ACK rcv_nxt=2770828547, snd_una=3526596132
