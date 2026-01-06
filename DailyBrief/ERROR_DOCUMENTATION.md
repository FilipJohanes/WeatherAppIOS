# Trident Error Messages Documentation

This document provides a comprehensive list of all error messages in the Trident app, their causes, and solutions.

## Table of Contents
1. [Authentication Errors](#authentication-errors)
2. [API Communication Errors](#api-communication-errors)
3. [Data Parsing Errors](#data-parsing-errors)
4. [Network Errors](#network-errors)
5. [App Configuration Errors](#app-configuration-errors)

---

## Authentication Errors

### Login Failed
**Error Message:** `"Login failed: [reason]"`

**Possible Causes:**
- Invalid email or password
- Account does not exist
- Account is locked or disabled
- API endpoint is incorrect

**Solutions:**
1. Verify email and password are correct
2. Check if account exists in the backend
3. Ensure API endpoint is properly configured in APIConfig.swift
4. Check backend logs for authentication issues

### Token Expired
**Error Message:** `"Authentication token has expired"`

**Possible Causes:**
- JWT token has expired (typically after 24 hours)
- Token was invalidated on the server

**Solutions:**
1. Log out and log back in to get a fresh token
2. Implement automatic token refresh mechanism
3. Check token expiration time in backend configuration

### Keychain Access Error
**Error Message:** `"Failed to store/retrieve credentials from keychain"`

**Possible Causes:**
- Keychain access permissions denied
- Keychain data corrupted
- iOS security restrictions

**Solutions:**
1. Reset app and clear keychain data
2. Check app entitlements and keychain access groups
3. Verify device has proper security settings

---

## API Communication Errors

### Invalid API Key
**Error Message:** `"Invalid API key"`

**Possible Causes:**
- API key not configured in APIConfig.swift
- API key is incorrect or expired
- API key not sent in request headers

**Solutions:**
1. Add or update API key in APIConfig.swift
2. Verify API key with backend team
3. Check that API key is included in request headers

### API Endpoint Not Found
**Error Message:** `"404: Endpoint not found"`

**Possible Causes:**
- Incorrect base URL in APIConfig.swift
- API endpoint path is wrong
- Backend service is not deployed

**Solutions:**
1. Verify base URL in APIConfig.swift matches backend
2. Check endpoint paths in APIService.swift
3. Confirm backend services are running

### Rate Limit Exceeded
**Error Message:** `"429: Too many requests"`

**Possible Causes:**
- Making too many API calls in short time
- Rate limiting configured on backend

**Solutions:**
1. Implement request throttling
2. Add caching to reduce API calls
3. Contact backend team to increase rate limits

### Server Error
**Error Message:** `"500: Internal server error"`

**Possible Causes:**
- Backend service crashed or has bugs
- Database connection issues
- Third-party API failures

**Solutions:**
1. Check backend logs for errors
2. Retry the request after a delay
3. Contact backend team if issue persists

---

## Data Parsing Errors

### Network Error: The data couldn't be read because it is missing
**Error Message:** `"Network Error: The data couldn't be read because it is missing"`

**Possible Causes:**
- API returned empty response body
- Response content-type header is incorrect
- Backend returned null/nil data
- URLSession didn't receive any data

**Solutions:**
1. Check if backend endpoint is returning data:
   ```bash
   curl -X GET "https://your-api.com/endpoint" -H "X-API-KEY: your-key"
   ```
2. Verify the endpoint exists and is properly configured
3. Check backend logs to see if request was received
4. Ensure backend returns proper Content-Type header (application/json)
5. Add error handling for empty responses:
   ```swift
   guard let data = data, !data.isEmpty else {
       throw APIError.emptyResponse
   }
   ```

### JSON Decoding Failed
**Error Message:** `"Failed to decode response: [details]"`

**Possible Causes:**
- Backend response format doesn't match Swift models
- Missing required fields in response
- Type mismatch (e.g., expecting Int but got String)
- Extra fields in response not accounted for

**Solutions:**
1. Print raw response data to see actual format:
   ```swift
   print(String(data: data, encoding: .utf8) ?? "Invalid data")
   ```
2. Compare response structure with model definitions in APIModels.swift
3. Update models to match backend response structure
4. Use optional properties for fields that might be missing
5. Add custom decoding logic if needed

### Invalid Date Format
**Error Message:** `"Invalid date format in response"`

**Possible Causes:**
- Backend returns dates in different format than expected
- Timezone issues
- Missing date formatting strategy

**Solutions:**
1. Check date format in backend response
2. Update date decoding strategy in APIService
3. Use ISO8601DateFormatter if dates are in ISO format
4. Handle multiple date formats if needed

---

## Network Errors

### No Internet Connection
**Error Message:** `"No internet connection available"`

**Possible Causes:**
- Device is offline
- Wi-Fi/cellular data is disabled
- Airplane mode is enabled

**Solutions:**
1. Check device network settings
2. Enable Wi-Fi or cellular data
3. Disable airplane mode
4. Implement network reachability monitoring

### Request Timeout
**Error Message:** `"Request timed out"`

**Possible Causes:**
- Slow network connection
- Backend taking too long to respond
- Timeout value is too short

**Solutions:**
1. Increase timeout value in URLSessionConfiguration
2. Check network connection speed
3. Optimize backend response time
4. Show loading indicator to user

### SSL/TLS Error
**Error Message:** `"SSL certificate validation failed"`

**Possible Causes:**
- Invalid SSL certificate on server
- Self-signed certificate in development
- Certificate expired

**Solutions:**
1. Ensure backend has valid SSL certificate
2. For development, add App Transport Security exception
3. Update expired certificates on server

### Connection Refused
**Error Message:** `"Connection refused"`

**Possible Causes:**
- Backend service is down
- Firewall blocking connection
- Incorrect port number

**Solutions:**
1. Verify backend service is running
2. Check firewall settings
3. Confirm port number in base URL

---

## App Configuration Errors

### Missing API Configuration
**Error Message:** `"API configuration is missing"`

**Possible Causes:**
- APIConfig.swift not properly set up
- Base URL or API key not defined
- Environment variables not set

**Solutions:**
1. Review APIConfig.swift and ensure all required values are set:
   ```swift
   static let baseURL = "https://your-api.com"
   static let apiKey = "your-api-key"
   ```
2. Check that no placeholder values remain
3. Verify environment-specific configuration

### Cache Error
**Error Message:** `"Failed to read/write cache"`

**Possible Causes:**
- Disk space full
- Cache directory permissions issue
- Cache data corrupted

**Solutions:**
1. Clear app cache
2. Check available storage space
3. Reset app data if needed
4. Implement cache validation

### Invalid User Data
**Error Message:** `"User data is invalid or corrupted"`

**Possible Causes:**
- User profile incomplete on backend
- Data model mismatch
- Database migration issues

**Solutions:**
1. Verify user data structure on backend
2. Update User model to match backend
3. Force re-fetch user data
4. Log out and log back in

---

## Error Handling Best Practices

### For Developers

1. **Always Log Errors**
   ```swift
   catch {
       print("Error: \(error)")
       print("Error details: \(error.localizedDescription)")
   }
   ```

2. **Provide User-Friendly Messages**
   - Don't show raw error messages to users
   - Translate technical errors to simple explanations
   - Offer actionable solutions

3. **Implement Retry Logic**
   ```swift
   func fetchWithRetry(maxAttempts: Int = 3) async throws -> Data {
       for attempt in 1...maxAttempts {
           do {
               return try await fetchData()
           } catch {
               if attempt == maxAttempts { throw error }
               try await Task.sleep(nanoseconds: UInt64(attempt) * 1_000_000_000)
           }
       }
       throw APIError.maxRetriesExceeded
   }
   ```

4. **Use Proper Error Types**
   ```swift
   enum APIError: Error {
       case invalidResponse
       case emptyResponse
       case decodingFailed(Error)
       case networkError(Error)
       case authenticationFailed
       case serverError(statusCode: Int)
   }
   ```

### For Users

1. **Check Your Connection**
   - Most errors can be resolved by checking internet connectivity
   - Try switching between Wi-Fi and cellular data

2. **Restart the App**
   - Force close and reopen Trident
   - This refreshes connections and clears temporary issues

3. **Update the App**
   - Ensure you're running the latest version
   - Check App Store for updates

4. **Clear Cache**
   - Go to Settings → Clear Cache
   - This removes potentially corrupted data

5. **Reinstall if Necessary**
   - As a last resort, delete and reinstall the app
   - Note: This will log you out

---

## Common Error Scenarios

### Scenario 1: App Shows "Network Error: The data couldn't be read because it is missing"

**Step-by-step Troubleshooting:**
1. Check if device has internet connection
2. Verify API endpoint is accessible (use curl or Postman)
3. Check APIConfig.swift for correct base URL and API key
4. Review backend logs to see if request was received
5. Check if backend is returning empty response for certain conditions
6. Verify Content-Type header is set correctly on backend
7. Add logging in APIService.swift to see raw response

### Scenario 2: Login Fails Repeatedly

**Step-by-step Troubleshooting:**
1. Verify credentials are correct
2. Check if account exists in backend database
3. Review backend authentication logs
4. Ensure API key is set in request headers
5. Verify login endpoint URL is correct
6. Check for any password complexity requirements
7. Test login directly with backend API using Postman

### Scenario 3: Data Not Refreshing

**Step-by-step Troubleshooting:**
1. Check if pull-to-refresh is working
2. Verify API calls are being made (check network logs)
3. Look for caching issues
4. Ensure view models are fetching fresh data
5. Check if authentication token is still valid
6. Verify backend is returning updated data

---

## Debug Mode

To enable detailed error logging:

1. Add debug flag in APIService.swift:
   ```swift
   static let debugMode = true
   ```

2. Print detailed error information:
   ```swift
   if APIService.debugMode {
       print("Request URL: \(request.url?.absoluteString ?? "unknown")")
       print("Headers: \(request.allHTTPHeaderFields ?? [:])")
       print("Response: \(String(data: data, encoding: .utf8) ?? "no data")")
   }
   ```

3. Use breakpoints in error handlers to inspect state

---

## Getting Help

If you encounter an error not listed here:

1. **Collect Information**
   - Exact error message
   - Steps to reproduce
   - Device and iOS version
   - App version

2. **Check Logs**
   - Enable debug mode
   - Review console output
   - Save relevant log entries

3. **Contact Support**
   - Provide collected information
   - Include screenshots if applicable
   - Describe expected vs actual behavior

---

*Last Updated: January 6, 2026*
*Version: 1.0*
