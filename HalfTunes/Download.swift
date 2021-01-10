
import Foundation

class Download: NSObject {
  var url: URL
  var isDownloading = false
  var progress: Float = 0
  
  var task: URLSessionDownloadTask?
  var resumeData: Data?
  
  init(url: URL) {
    self.url = url
  }
}
