import Foundation

class ImageDownloadUsingDispatchGroup {
    static let shared = ImageDownloadUsingDispatchGroup()
    private init() {}
    private let group = DispatchGroup()
    private let imageService = ImageService(scheduler: MainScheduler())
    
    func parallelDownload(completion: @escaping ([Data]) -> Void) {
        let concurrentQueue = DispatchQueue(label: "Concurrent Queue", attributes: .concurrent)
        var images = [Data]()
        [ImageUrl.imageURL1, ImageUrl.imageURL2].forEach { url in
            group.enter()
            concurrentQueue.async {
                self.imageService.fetchImage(for: url) { [weak self] data in
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
            self.imageService.fetchImage(for: ImageUrl.imageURL1) { data in
                image1Completion(data)
                print("Task 1: \(Date.now.ISO8601Format()) : => \(String(describing: data))")
            }
        }
        serialQueue.async {
            self.imageService.fetchImage(for: ImageUrl.imageURL2) { data in
                image2Completion(data)
                print("Task 2: \(Date.now.ISO8601Format()) : => \(String(describing: data))")
            }
        }
    }
}
