import AVFoundation
import Vision
import UIKit
import AudioToolbox

final class PlateScanner: NSObject, ObservableObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    let session = AVCaptureSession()
    @Published var readText = ""
    @Published var running = false
    var onPlate: ((String)->Void)?
    private let queue = DispatchQueue(label: "plate.scan.queue")
    private var configured = false
    private var last = ""
    private var streak = 0
    
    func start() {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            guard granted else { DispatchQueue.main.async { self.readText = "Kamera icazəsi verilməyib" }; return }
            self.queue.async { self.configureAndRun() }
        }
    }
    private func configureAndRun() {
        if !configured {
            session.beginConfiguration(); session.sessionPreset = .high
            guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back), let input = try? AVCaptureDeviceInput(device: camera), session.canAddInput(input) else { session.commitConfiguration(); return }
            session.addInput(input)
            let output = AVCaptureVideoDataOutput(); output.setSampleBufferDelegate(self, queue: queue); output.alwaysDiscardsLateVideoFrames = true
            if session.canAddOutput(output) { session.addOutput(output) }
            session.commitConfiguration(); configured = true
        }
        if !session.isRunning { session.startRunning() }
        DispatchQueue.main.async { self.running = true }
    }
    func stop() { queue.async { if self.session.isRunning { self.session.stopRunning() }; DispatchQueue.main.async { self.running = false } } }
    func alert() { AudioServicesPlaySystemSound(1005); AudioServicesPlaySystemSound(kSystemSoundID_Vibrate) }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let image = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let request = VNRecognizeTextRequest(); request.recognitionLevel = .accurate; request.usesLanguageCorrection = false
        request.recognitionLanguages = ["en-US"]
        do { try VNImageRequestHandler(cvPixelBuffer: image, options: [:]).perform([request]) } catch { return }
        let candidates = (request.results ?? []).compactMap { $0.topCandidates(1).first?.string }
        let joined = candidates.joined(separator: " ")
        let cleaned = PlateDatabase.normalize(joined)
        DispatchQueue.main.async { self.readText = joined }
        // Heuristic plate-like sequence: 2 digits + 2 letters + 3 digits or 2 digits + 1-2 letters + 3 digits.
        let patterns = ["[0-9]{2}[A-Z]{2}[0-9]{3}", "[0-9]{2}[A-Z]{1,2}[0-9]{3}"]
        for pattern in patterns {
            if let range = cleaned.range(of: pattern, options: .regularExpression) {
                let plate = String(cleaned[range])
                if plate == last { streak += 1 } else { last = plate; streak = 1 }
                if streak >= 3 { DispatchQueue.main.async { self.onPlate?(plate) }; streak = 0 }
                return
            }
        }
        streak = 0
    }
}

struct CameraPreview: UIViewRepresentable {
    let session: AVCaptureSession
    func makeUIView(context: Context) -> PreviewView { let v = PreviewView(); v.previewLayer.session = session; v.previewLayer.videoGravity = .resizeAspectFill; return v }
    func updateUIView(_ uiView: PreviewView, context: Context) { uiView.previewLayer.session = session }
}
class PreviewView: UIView { override class var layerClass: AnyClass { AVCaptureVideoPreviewLayer.self }; var previewLayer: AVCaptureVideoPreviewLayer { layer as! AVCaptureVideoPreviewLayer } }
