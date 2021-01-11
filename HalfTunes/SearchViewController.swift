import UIKit
import AVKit
import AVFoundation

class SearchViewController: UIViewController {
  
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var searchBar: UISearchBar!
  lazy var tapRecognizer: UITapGestureRecognizer = {
    var recognizer = UITapGestureRecognizer(target:self, action: #selector(dismissKeyboard))
    return recognizer
  }()
  
  var searchResults: [Track] = []
  let queryService = QueryService()
  let downloadService = DownloadService()
  lazy var downloadsSession: URLSession = {
    let configuration = URLSessionConfiguration.background(withIdentifier: "es.swiftindepth.bgsessionconfiguration")
    return URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
  }()
  
  // MARK: - Document directory helpers
  // Get local file path: download task stores tune here; AV player plays it.
  let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
  func localFilePath(for url: URL) -> URL {
    return documentsPath.appendingPathComponent(url.lastPathComponent)
  }
  
  func localFileExists(for track: Track) -> Bool {
    let localUrl = localFilePath(for: track.url)
    var isDir: ObjCBool = false
    return FileManager.default.fileExists(atPath: localUrl.path, isDirectory: &isDir)
  }
  
  // MARK: - View controller methods
  
  override func viewDidLoad() {
    super.viewDidLoad()
    downloadService.downloadsSession = downloadsSession
    tableView.tableFooterView = UIView()
  }
  
  // This method attempts to play the local file (if it exists) when the cell is tapped
  func playDownload(_ track: Track) {
    let playerViewController = AVPlayerViewController()
    present(playerViewController, animated: true, completion: nil)
    let url = localFilePath(for: track.url)
    let player = AVPlayer(url: url)
    playerViewController.player = player
    player.play()
  }
  
}

// MARK: - TrackCellDelegate

extension SearchViewController: TrackCellDelegate {
  func pauseTapped(_ cell: TrackCell) {
    if let indexPath = tableView.indexPath(for: cell) {
      let track = searchResults[indexPath.row]
      downloadService.pauseDownload(track)
      tableView.reloadRows(at: [IndexPath(row: indexPath.row, section: 0)], with: .none)
    }
  }
  
  func resumeTapped(_ cell: TrackCell) {
    if let indexPath = tableView.indexPath(for: cell) {
      let track = searchResults[indexPath.row]
      downloadService.resumeDownload(track)
      tableView.reloadRows(at: [IndexPath(row: indexPath.row, section: 0)], with: .none)
    }
  }
  
  func cancelTapped(_ cell: TrackCell) {
    if let indexPath = tableView.indexPath(for: cell) {
      let track = searchResults[indexPath.row]
      downloadService.cancelDownload(track)
      tableView.reloadRows(at: [IndexPath(row: indexPath.row, section: 0)], with: .none)
    }
  }
  
  func downloadTapped(_ cell: TrackCell) {
    if let indexPath = tableView.indexPath(for: cell) {
      let track = searchResults[indexPath.row]
      downloadService.startDownload(track)
      tableView.reloadRows(at: [IndexPath(row: indexPath.row, section: 0)], with: .none)
    }
  }
}

// MARK: - UITableViewDataSource

extension SearchViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return searchResults.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell: TrackCell = tableView.dequeueReusableCell(for: indexPath)
    
    // Delegate cell button tap events to this view controller
    cell.delegate = self
    
    let track = searchResults[indexPath.row]
    cell.configure(track: track, download: downloadService.activeDownloads[track.url], downloaded: localFileExists(for: track))
    
    return cell
  }
}

// MARK: - UITableViewDelegate

extension SearchViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 62.0
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let track = searchResults[indexPath.row]
    if localFileExists(for: track) {
      playDownload(track)
    }
    tableView.deselectRow(at: indexPath, animated: true)
  }
}
