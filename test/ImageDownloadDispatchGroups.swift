import Foundation

class ImageDownloadDispatchGroups {
    static let shared = ImageDownloadDispatchGroups()
    let group = DispatchGroup()
    
    func downloadImage(
        url: String,
        completion: @escaping (Data?) -> Void
    ) {
        let task = URLSession.shared.dataTask(with: URLRequest(url: URL(string: url)!))
        { data, response, error in
            guard
                let safeData = data,
                error == nil,
                let res = (response as? HTTPURLResponse),
                (200...299).contains(res.statusCode)
            else {
                completion(nil)
                return
            }
            completion(safeData)
        }
        task.resume()
    }
    
    func parallelDownload(completion: @escaping ([Data]) -> Void) {
        let concurrentQueue = DispatchQueue(label: "Concurrent Queue", attributes: .concurrent)
        var images = [Data]()
        [ImageUrl.imageURL1, ImageUrl.imageURL2].forEach { url in
            group.enter()
            concurrentQueue.async {
                self.downloadImage(url: url) { [weak self] data in
                    if let safeData = data {
                        images.append(safeData)
                    }
                    self?.group.leave()
                }
            }
        }
        group.notify(queue: .main) {
            completion(images)
        }
    }
    
    func serialExecution(
        image1Completion: @escaping (Data?) -> Void,
        image2Completion: @escaping (Data?) -> Void
    ) {
        let serialQueue = DispatchQueue(label: "Serial Queue")
        serialQueue.async {
            self.downloadImage(url: ImageUrl.imageURL1) { data in
                image1Completion(data)
                print("Task 1: \(Date.now.ISO8601Format()) : => \(String(describing: data))")
            }
        }
        serialQueue.async {
            self.downloadImage(url: ImageUrl.imageURL2) { data in
                image2Completion(data)
                print("Task 2: \(Date.now.ISO8601Format()) : => \(String(describing: data))")
            }
        }
    }
}
