import CoreLocation

class GeoTest: NSObject, CLLocationDelegate {
    let geocoder = CLGeocoder()
    
    func test() async {
        let location = CLLocation(latitude: 48.22218, longitude: 17.39706)
        do {
            let placemarks = try await geocoder.reverseGeocodeLocation(location)
            if let placemark = placemarks.first {
                print("Locality: \(placemark.locality ?? "nil")")
                print("SubLocality: \(placemark.subLocality ?? "nil")")
                print("Administrative Area: \(placemark.administrativeArea ?? "nil")")
                print("Country: \(placemark.country ?? "nil")")
            }
        } catch {
            print("Error: \(error)")
        }
    }
}

let tester = GeoTest()
await tester.test()
