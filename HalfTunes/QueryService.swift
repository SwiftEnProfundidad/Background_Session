import Foundation

// Runs query data task, and stores results in array of Tracks
class QueryService {

  typealias QueryResult = ([Track]?, String) -> ()
  var tracks: [Track] = []
  var errorMessage = ""

  lazy var defaultSession: URLSession = {
    let config = URLSessionConfiguration.default
    config.waitsForConnectivity = true
    return URLSession(configuration: config)
  }()
  var dataTask: URLSessionDataTask?
  let decoder = JSONDecoder()

  func getSearchResults(searchTerm: String, completion: @escaping QueryResult) {
    dataTask?.cancel()

    guard var urlComponents = URLComponents(string: "https://itunes.apple.com/search")
      else { return }
    urlComponents.query = "media=music&entity=song&term=\(searchTerm)"
    guard let url = urlComponents.url else { return }

    dataTask = defaultSession.dataTask(with: url) { data, response, error in
      defer { self.dataTask = nil }
      if let error = error {
        self.errorMessage += "DataTask error: " + error.localizedDescription + "\n"
      } else if let data = data,
        let response = response as? HTTPURLResponse,
        response.statusCode == 200 {
        self.updateSearchResults(data)
        OperationQueue.main.addOperation {
          completion(self.tracks, self.errorMessage)
        }
      }
    }
    dataTask?.resume()
  }

  // MARK: - Helper methods
  fileprivate func updateSearchResults(_ data: Data) {
    tracks.removeAll()
    do {
      let list = try decoder.decode(TrackList.self, from: data)
      tracks = list.results
    } catch let decodeError as NSError {
      errorMessage += "Decoder error: \(decodeError.localizedDescription)"
      return
    }
  }

}


