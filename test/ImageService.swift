import Foundation
import Combine

class ImageService<S: Scheduler> {
    private let scheduler: S
    init(scheduler: S) {
        self.scheduler = scheduler
    }
    
    func fetchImage(for url: String, completionHandler: @escaping (Data?) -> Void) {
        let task = URLSession.shared
            .dataTask(with: URLRequest(url: URL(string: url)!)) { data, res, error in
                guard let safeData = data,
                      let res = (res as? HTTPURLResponse),
                      (200...299).contains(res.statusCode)
                else {
                    completionHandler(nil)
                    return
                }
                completionHandler(safeData)
            }
        task.resume()
    }
    
    func fetchImage(for url: String) -> AnyPublisher<Data, CustomError> {
        return URLSession.shared.dataTaskPublisher(for: URL(string: url)!)
            .tryMap { (data: Data?, response: URLResponse) in
                guard let safeData = data,
                      let res = (response as? HTTPURLResponse),
                    (200...299).contains(res.statusCode)
                else {
                    throw CustomError.networkFailure
                }
                return safeData
            }
            .mapError({ $0 as! CustomError })
            .receive(on: scheduler)
            .eraseToAnyPublisher()
    }
    
    func fetchImage(for url: String) async throws -> Data {
        let (data, res) = try await URLSession.shared.data(from: URL(string: url)!)
        guard 
            let res = (res as? HTTPURLResponse),
            (200...299).contains(res.statusCode)
        else {
            throw CustomError.networkFailure
        }
        return data
    }
}
