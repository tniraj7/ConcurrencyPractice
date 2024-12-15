import Foundation

class ImageDownloadOperation: Operation {
    private let imageURL: String
    private let imageService: ImageService
    private(set) var imageData: Data?
    
    init(imageURL: String, imageService: ImageService) {
        self.imageURL = imageURL
        self.imageService = imageService
        super.init()
    }
    
    private var _executing = false {
        willSet {
            willChangeValue(forKey: "isExecuting")
        }
        didSet {
            didChangeValue(forKey: "isExecuting")
        }
    }
    
    override var isExecuting: Bool {
        return _executing
    }
    
    private var _finished = false {
        willSet {
            willChangeValue(forKey: "isFinished")
        }
        didSet {
            didChangeValue(forKey: "isFinished")
        }
    }
    
    override var isFinished: Bool {
        return _finished
    }
    
    override func main() {
        guard !isCancelled else { return }
        imageService.fetchImage(for: imageURL) { [weak self] data in
            if let data {
                self?.imageData = data
                self?.completeOperation()
            }
        }
    }
    
    private func completeOperation() {
        guard !isFinished else { return }

        willChangeValue(forKey: "isFinished")
        _executing = false
        _finished = true
        didChangeValue(forKey: "isFinished")
    }
}
