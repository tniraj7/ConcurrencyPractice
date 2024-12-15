import Foundation
import Combine

class ImageService {

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
            .receive(on: DispatchQueue.main)
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
