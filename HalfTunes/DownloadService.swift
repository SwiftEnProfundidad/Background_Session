
import Foundation

// Downloads song snippets, and stores in local file.
// Allows cancel, pause, resume download.
class DownloadService {
  
  // SearchViewController creates downloadsSession
  var downloadsSession: URLSession!
  var activeDownloads: [URL: Download] = [:]
  
  // MARK: - Download methods called by TrackCell delegate methods
  
  // Called when the Download button for a track is tapped
  func startDownload(_ track: Track) {
    let download = Download(url: track.url)
    download.task = downloadsSession.downloadTask(with: track.url)
    download.task!.resume()
    download.isDownloading = true
    activeDownloads[download.url] = download
  }
  
  // Called when the Pause button for a track is tapped
  func pauseDownload(_ track: Track) {
    guard let download = activeDownloads[track.url] else { return }
    if download.isDownloading {
      download.task?.cancel(byProducingResumeData: { data in
        download.resumeData = data
      })
      download.isDownloading = false
    }
  }
  
  // Called when the Cancel button for a track is tapped
  func cancelDownload(_ track: Track) {
    if let download = activeDownloads[track.url] {
      download.task?.cancel()
      activeDownloads[track.url] = nil
    }
  }
  
  // Called when the Resume button for a track is tapped
  func resumeDownload(_ track: Track) {
    guard let download = activeDownloads[track.url] else { return }
    if let resumeData = download.resumeData {
      download.task = downloadsSession.downloadTask(withResumeData: resumeData)
      download.task!.resume()
      download.isDownloading = true
    } else {
      download.task = downloadsSession.downloadTask(with: download.url)
      download.task!.resume()
      download.isDownloading = true
    }
  }
  
}


