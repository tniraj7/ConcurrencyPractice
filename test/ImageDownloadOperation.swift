import Foundation

class ImageDownloadOperation: Operation {
    let imageURL: String
    var imageData: Data?
    
    init(imageURL: String) {
        self.imageURL = imageURL
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
        
        let task = URLSession.shared
            .dataTask(with: URLRequest(url: URL(string: imageURL)!))
        { [weak self] data, res, error in

            guard let safeData = data,
                  let res = (res as? HTTPURLResponse),
                (200...299).contains(res.statusCode)
            else {
                return
            }
            self?.imageData = safeData
            self?.completeOperation()
        }
        
        task.resume()
    }
    
    private func completeOperation() {
        guard !isFinished else { return }

        willChangeValue(forKey: "isFinished")
        _executing = false
        _finished = true
        didChangeValue(forKey: "isFinished")
    }
}
