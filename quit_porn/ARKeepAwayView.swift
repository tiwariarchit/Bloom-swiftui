import SwiftUI
import ARKit
import RealityKit

struct ARKeepAwayView: UIViewRepresentable {
    
    @Binding var eyesClosed: Bool
    @Binding var headStraight: Bool
    
    func makeCoordinator() -> Coordinator {
        Coordinator(
            eyesClosed: $eyesClosed,
            headStraight: $headStraight
        )
    }
    
    func makeUIView(context: Context) -> ARView {
        
        let arView = ARView(frame: .zero)
        
        guard ARFaceTrackingConfiguration.isSupported else {
            print("Face tracking not supported on this device.")
            return arView
        }
        
        let config = ARFaceTrackingConfiguration()
        arView.session.delegate = context.coordinator
        arView.session.run(config)
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
    
    
    // MARK: - Coordinator
    
    class Coordinator: NSObject, ARSessionDelegate {
        
        var eyesClosed: Binding<Bool>
        var headStraight: Binding<Bool>
        
        init(
            eyesClosed: Binding<Bool>,
            headStraight: Binding<Bool>
        ) {
            self.eyesClosed = eyesClosed
            self.headStraight = headStraight
        }
        
        func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
            
            guard let faceAnchor = anchors.compactMap({ $0 as? ARFaceAnchor }).first else {
                return
            }
            
            let leftEye = faceAnchor.blendShapes[.eyeBlinkLeft]?.floatValue ?? 0
            let rightEye = faceAnchor.blendShapes[.eyeBlinkRight]?.floatValue ?? 0
            let closed = leftEye > 0.7 && rightEye > 0.7
            
            let yaw = faceAnchor.transform.columns.0.x
            let straight = abs(yaw) < 0.15
            
            DispatchQueue.main.async {
                self.eyesClosed.wrappedValue = closed
                self.headStraight.wrappedValue = straight
            }
        }
    }
}
