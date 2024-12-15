import SwiftUI

struct ContentView: View {
    
    @StateObject var vm = ImageViewModel(dispatchQueue: DispatchQueue.main, imageService: ImageService())
    
    var body: some View {
        VStack(spacing: 8) {
            if vm.pic1 != nil {
                    Image(uiImage: UIImage(data: vm.pic1!)!)
                    .resizable()
                    .frame(width: 200, height: 200)
            } else {
                ProgressView()
            }
            if vm.pic2 != nil {
                    Image(uiImage: UIImage(data: vm.pic2!)!)
                    .resizable()
                    .frame(width: 200, height: 200)
            } else {
                ProgressView()
            }
        }
        .onAppear {
            vm.loadPicturesUsingGCDParallely()
        }
//        .task {
//          await vm.loadPicturesSeriallyWithStructuredConcurrency()
//        }
    }
}
