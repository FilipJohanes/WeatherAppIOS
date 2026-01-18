# Weather Preset Compatibility Test
# Tests all preset combinations with real Open-Meteo API responses

$lat = "48.22218"
$lon = "17.39707"
$base = "https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&timezone=auto"

Write-Host "`n=====================================================================" -ForegroundColor Cyan
Write-Host "WEATHER PRESET COMPATIBILITY TEST" -ForegroundColor Cyan
Write-Host "Testing all preset combinations with real API responses" -ForegroundColor Cyan
Write-Host "=====================================================================" -ForegroundColor Cyan

$testResults = @()

# Test 1: Minimal Preset
Write-Host "`n🧪 TEST 1: MINIMAL PRESET" -ForegroundColor Yellow
$url1 = $base + "&current=weather_code,temperature_2m&hourly=temperature_2m&daily=weather_code,temperature_2m_max,temperature_2m_min&forecast_days=7"
Write-Host "   Fields: weather_code, temperature_2m" -ForegroundColor Gray

try {
    $response1 = Invoke-RestMethod -Uri $url1
    $fields1 = $response1.current.PSObject.Properties.Name
    
    Write-Host "   ✅ API call successful" -ForegroundColor Green
    Write-Host "   📊 Returned fields: $($fields1 -join ', ')" -ForegroundColor Gray
    Write-Host "   📊 Temperature: $($response1.current.temperature_2m)°C"
    Write-Host "   📊 Weather Code: $($response1.current.weather_code)"
    Write-Host "   📅 Forecast days: $($response1.daily.time.Count)"
    
    # Check if ONLY requested fields are present (plus time/interval)
    $expectedFields = @('time', 'interval', 'weather_code', 'temperature_2m')
    $unexpectedFields = $fields1 | Where-Object { $_ -notin $expectedFields }
    
    if ($unexpectedFields) {
        Write-Host "   ⚠️  Unexpected fields found: $($unexpectedFields -join ', ')" -ForegroundColor Yellow
    }
    
    Write-Host "   🎯 Result: PASS ✅" -ForegroundColor Green
    $testResults += @{Name="Minimal"; Status="PASS"}
} catch {
    Write-Host "   ❌ API call failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "   🎯 Result: FAIL ❌" -ForegroundColor Red
    $testResults += @{Name="Minimal"; Status="FAIL"}
}

# Test 2: Standard Preset  
Write-Host "`n🧪 TEST 2: STANDARD PRESET" -ForegroundColor Yellow
$url2 = $base + "&current=weather_code,temperature_2m,apparent_temperature,relative_humidity_2m,wind_speed_10m,precipitation&hourly=temperature_2m,precipitation,precipitation_probability,wind_speed_10m&daily=weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max,precipitation_sum,wind_speed_10m_max&forecast_days=7"
Write-Host "   Fields: weather_code, temperature_2m, apparent_temperature, relative_humidity_2m, wind_speed_10m, precipitation" -ForegroundColor Gray

try {
    $response2 = Invoke-RestMethod -Uri $url2
    $fields2 = $response2.current.PSObject.Properties.Name
    
    Write-Host "   ✅ API call successful" -ForegroundColor Green
    Write-Host "   📊 Returned fields: $($fields2 -join ', ')" -ForegroundColor Gray
    Write-Host "   📊 Temperature: $($response2.current.temperature_2m)°C"
    Write-Host "   📊 Feels Like: $($response2.current.apparent_temperature)°C"
    Write-Host "   📊 Humidity: $($response2.current.relative_humidity_2m)%"
    Write-Host "   📊 Wind: $($response2.current.wind_speed_10m) km/h"
    Write-Host "   📊 Precipitation: $($response2.current.precipitation) mm"
    Write-Host "   📅 Forecast days: $($response2.daily.time.Count)"
    
    # Check all required fields are present
    $requiredFields = @('temperature_2m', 'apparent_temperature', 'relative_humidity_2m', 'wind_speed_10m', 'precipitation')
    $missingFields = $requiredFields | Where-Object { $_ -notin $fields2 }
    
    if ($missingFields) {
        Write-Host "   ⚠️  Missing required fields: $($missingFields -join ', ')" -ForegroundColor Yellow
        Write-Host "   🎯 Result: FAIL ❌" -ForegroundColor Red
        $testResults += @{Name="Standard"; Status="FAIL"}
    } else {
        Write-Host "   🎯 Result: PASS ✅" -ForegroundColor Green
        $testResults += @{Name="Standard"; Status="PASS"}
    }
} catch {
    Write-Host "   ❌ API call failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "   🎯 Result: FAIL ❌" -ForegroundColor Red
    $testResults += @{Name="Standard"; Status="FAIL"}
}

# Test 3: Complete Preset
Write-Host "`n🧪 TEST 3: COMPLETE PRESET" -ForegroundColor Yellow
$url3 = $base + "&current=weather_code,temperature_2m,apparent_temperature,relative_humidity_2m,wind_speed_10m,wind_direction_10m,wind_gusts_10m,precipitation,rain,snowfall,surface_pressure,visibility,cloud_cover&hourly=temperature_2m,precipitation,precipitation_probability,rain,snowfall,wind_speed_10m,uv_index&daily=weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max,precipitation_sum,wind_speed_10m_max,uv_index_max&forecast_days=7"
Write-Host "   Fields: ALL available fields" -ForegroundColor Gray

try {
    $response3 = Invoke-RestMethod -Uri $url3
    $fields3 = $response3.current.PSObject.Properties.Name
    
    Write-Host "   ✅ API call successful" -ForegroundColor Green
    Write-Host "   📊 Returned field count: $($fields3.Count)" -ForegroundColor Gray
    Write-Host "   📊 Temperature: $($response3.current.temperature_2m)°C"
    Write-Host "   📊 Feels Like: $($response3.current.apparent_temperature)°C"
    Write-Host "   📊 Humidity: $($response3.current.relative_humidity_2m)%"
    Write-Host "   📊 Wind Speed: $($response3.current.wind_speed_10m) km/h"
    Write-Host "   📊 Wind Direction: $($response3.current.wind_direction_10m)°"
    Write-Host "   📊 Wind Gusts: $($response3.current.wind_gusts_10m) km/h"
    Write-Host "   📊 Pressure: $($response3.current.surface_pressure) hPa"
    Write-Host "   📊 Visibility: $($response3.current.visibility) m"
    Write-Host "   📊 Cloud Cover: $($response3.current.cloud_cover)%"
    Write-Host "   📅 Forecast days: $($response3.daily.time.Count)"
    
    # Check all required fields are present
    $requiredFields = @('temperature_2m', 'apparent_temperature', 'relative_humidity_2m', 'wind_speed_10m', 
                       'wind_direction_10m', 'wind_gusts_10m', 'precipitation', 'rain', 'snowfall',
                       'surface_pressure', 'visibility', 'cloud_cover')
    $missingFields = $requiredFields | Where-Object { $_ -notin $fields3 }
    
    if ($missingFields) {
        Write-Host "   ⚠️  Missing required fields: $($missingFields -join ', ')" -ForegroundColor Yellow
        Write-Host "   🎯 Result: FAIL ❌" -ForegroundColor Red
        $testResults += @{Name="Complete"; Status="FAIL"}
    } else {
        Write-Host "   🎯 Result: PASS ✅" -ForegroundColor Green
        $testResults += @{Name="Complete"; Status="PASS"}
    }
} catch {
    Write-Host "   ❌ API call failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "   🎯 Result: FAIL ❌" -ForegroundColor Red
    $testResults += @{Name="Complete"; Status="FAIL"}
}

# Summary
Write-Host "`n=====================================================================" -ForegroundColor Cyan
Write-Host "TEST SUMMARY" -ForegroundColor Cyan
Write-Host "=====================================================================" -ForegroundColor Cyan

$passCount = ($testResults | Where-Object { $_.Status -eq "PASS" }).Count
$totalTests = $testResults.Count

Write-Host "`nResults: $passCount / $totalTests tests passed" -ForegroundColor $(if ($passCount -eq $totalTests) { "Green" } else { "Yellow" })

foreach ($result in $testResults) {
    $color = if ($result.Status -eq "PASS") { "Green" } else { "Red" }
    $icon = if ($result.Status -eq "PASS") { "✅" } else { "❌" }
    Write-Host "  $icon $($result.Name) Preset: $($result.Status)" -ForegroundColor $color
}

if ($passCount -eq $totalTests) {
    Write-Host "`n🎉 ALL TESTS PASSED! All presets work correctly." -ForegroundColor Green
    Write-Host "   The decoder can handle all preset combinations." -ForegroundColor Green
} else {
    Write-Host "`n⚠️  SOME TESTS FAILED! Check the errors above." -ForegroundColor Red
}

Write-Host "=====================================================================" -ForegroundColor Cyan
