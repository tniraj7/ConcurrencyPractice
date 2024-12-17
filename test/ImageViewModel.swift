import Foundation
import Combine

class ImageViewModel: ObservableObject {
    @Published var pic1: Data? = nil
    @Published var pic2: Data? = nil
    var cancellable = Set<AnyCancellable>()
    
    private let dispatchQueue: Dispatching
    private let imageService: ImageService<MainScheduler>
    init(dispatchQueue: Dispatching, imageService: ImageService<MainScheduler>) {
        self.dispatchQueue = dispatchQueue
        self.imageService = imageService
    }
    
    func loadPicturesSeriallyWithOperationQueue() {
        let queue = OperationQueue()
        
        let op1 = ImageDownloadOperation(imageURL: ImageUrl.imageURL1, imageService: imageService)
        op1.completionBlock = {
            self.dispatchQueue.executeOnMainThread(group: nil, qos: .unspecified, flags: []) {
                self.pic1 = op1.imageData
                print("op1 completed!")
            }
        }

        let op2 = ImageDownloadOperation(imageURL: ImageUrl.imageURL2, imageService: imageService)
        op2.completionBlock = {
            self.dispatchQueue.executeOnMainThread(group: nil, qos: .unspecified, flags: []) {
                self.pic2 = op2.imageData
                print("op2 completed!")
            }
        }

        op2.addDependency(op1)
        queue.maxConcurrentOperationCount = 1
        queue.addOperations([op1, op2], waitUntilFinished: true)
    }
    
    func loadPicturesParallelyWithOperationQueue() {
        let queue = OperationQueue()
        
        let op1 = ImageDownloadOperation(imageURL: ImageUrl.imageURL1, imageService: imageService)
        op1.completionBlock = {
            self.dispatchQueue.executeOnMainThread(group: nil, qos: .unspecified, flags: []) {
                self.pic1 = op1.imageData
                print("op1 completed!")
            }
        }

        let op2 = ImageDownloadOperation(imageURL: ImageUrl.imageURL2, imageService: imageService)
        op2.completionBlock = {
            self.dispatchQueue.executeOnMainThread(group: nil, qos: .unspecified, flags: []) {
                self.pic2 = op2.imageData
                print("op2 completed!")
            }
        }

        queue.addOperations([op1, op2], waitUntilFinished: false)
    }
    
    func loadPicturesSeriallyUsingCombine() {
        let img1Pub = imageService.fetchImage(for: ImageUrl.imageURL1)
        let img2Pub = imageService.fetchImage(for: ImageUrl.imageURL2)
        
        img1Pub
            .flatMap { data -> AnyPublisher<Data, CustomError> in
                self.pic1 = data
                return img2Pub.eraseToAnyPublisher()
            }
            .sink(receiveCompletion: {_ in }, receiveValue: { data in
                self.pic2 = data
            })
            .store(in: &cancellable)
    }
    
    func loadPicturesParallelyUsingCombine() {
        let img1Pub = imageService.fetchImage(for: ImageUrl.imageURL1)
        let img2Pub = imageService.fetchImage(for: ImageUrl.imageURL2)
        Publishers
            .Zip(img1Pub, img2Pub)
            .sink(receiveCompletion: { _ in }) { data1, data2 in
                self.pic1 = data1
                self.pic2 = data2
            }
            .store(in: &cancellable)
    }
    
    func loadPicturesUsingGCDParallely() {
        ImageDownloadUsingDispatchGroup.shared.parallelDownload { [weak self] images in
            self?.pic1 = images[0]
            self?.pic2 = images[1]
        }
    }
    
    func loadPicturesUsingGCDSerially() {
        ImageDownloadUsingDispatchGroup.shared.serialExecution(
            image1Completion:  { data in
                self.dispatchQueue.executeOnMainThread(group: nil, qos: .unspecified, flags: []) {
                    self.pic1 = data
                    print("task1 completed!")
                }
            },
            image2Completion:  { data in
                self.dispatchQueue.executeOnMainThread(group: nil, qos: .unspecified, flags: []) {
                    self.pic2 = data
                    print("task2 completed!")
                }
            }
        )
    }
    
    @MainActor
    func loadPicturesSeriallyWithStructuredConcurrency() async {
        do {
            let data1 = try await imageService.fetchImage(for: ImageUrl.imageURL1)
            pic1 = data1
            print("task1 completed!")
            
            let data2 = try await imageService.fetchImage(for: ImageUrl.imageURL2)
            pic2 = data2
            print("task2 completed!")
        } catch {}
    }
    
    @MainActor
    func loadPicturesParallelyWithStructuredConcurrency() async {
        do {
            async let task1 = imageService.fetchImage(for: ImageUrl.imageURL1)
            async let task2 = imageService.fetchImage(for: ImageUrl.imageURL2)
            
            let results = try await (task1, task2)
            print("all tasks completed!")
            pic1 = results.0
            pic2 = results.1
        } catch {}
    }
}
