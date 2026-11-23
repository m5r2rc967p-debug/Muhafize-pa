import SwiftUI

struct ContentView: View {
    @StateObject private var scanner = PlateScanner()
    @State private var manual = ""
    @State private var result: PlateResult?
    @State private var db = PlateDatabase()
    
    var body: some View {
        ZStack {
            Color(red: 0.06, green: 0.08, blue: 0.12).ignoresSafeArea()
            VStack(spacing: 16) {
                Text("MÜHAFİZƏÇİ").font(.largeTitle.bold()).foregroundStyle(.white)
                Text("Maşın nömrələrinin yoxlanması").foregroundStyle(.gray)
                CameraPreview(session: scanner.session).frame(height: 280).clipShape(RoundedRectangle(cornerRadius: 18)).overlay(RoundedRectangle(cornerRadius: 18).stroke(.cyan, lineWidth: 2))
                Text(scanner.readText.isEmpty ? "Nömrə kamerada görünəndə oxumağa çalışır" : scanner.readText).foregroundStyle(.white).lineLimit(2)
                if let r = result {
                    VStack(spacing: 8) {
                        Text(r.plate).font(.title2.bold()).foregroundStyle(.white)
                        Text(r.found ? "BAZADA VAR" : "BAZADA YOXDUR").font(.headline.bold()).foregroundStyle(r.found ? .green : .red)
                        if let company = r.company { Text(company).foregroundStyle(.white) }
                    }.padding().frame(maxWidth: .infinity).background(r.found ? Color.green.opacity(0.18) : Color.red.opacity(0.18)).clipShape(RoundedRectangle(cornerRadius: 14))
                }
                HStack {
                    TextField("Nömrəni əl ilə daxil et", text: $manual).textInputAutocapitalization(.characters).autocorrectionDisabled().padding().background(.white).clipShape(RoundedRectangle(cornerRadius: 12))
                    Button("Yoxla") { check(manual) }.padding().background(.cyan).foregroundStyle(.black).clipShape(RoundedRectangle(cornerRadius: 12))
                }
                Button(scanner.running ? "Kameranı dayandır" : "Kameranı başlat") { scanner.running ? scanner.stop() : scanner.start() }.buttonStyle(.borderedProminent)
                Spacer()
            }.padding()
        }.onAppear { scanner.onPlate = { p in check(p) }; scanner.start() }
        .onDisappear { scanner.stop() }
    }
    private func check(_ raw: String) {
        let p = PlateDatabase.normalize(raw)
        guard p.count >= 5 else { return }
        result = db.lookup(p)
        if result?.found == false { scanner.alert() }
    }
}

struct PlateResult { let plate: String; let found: Bool; let company: String? }

final class PlateDatabase {
    private var records: [String:String] = [:]
    init() {
        if let url = Bundle.main.url(forResource: "plates", withExtension: "txt"), let contents = try? String(contentsOf: url, encoding: .utf8) {
            for line in contents.components(separatedBy: .newlines) {
                let parts = line.split(separator: ";", maxSplits: 1).map(String.init)
                if parts.count == 2 { records[Self.normalize(parts[0])] = parts[1].trimmingCharacters(in: .whitespaces) }
            }
        }
    }
    static func normalize(_ s: String) -> String { s.uppercased().filter { $0.isLetter || $0.isNumber } }
    func lookup(_ plate: String) -> PlateResult { let p = Self.normalize(plate); if let c = records[p] { return PlateResult(plate: p, found: true, company: c) }; return PlateResult(plate: p, found: false, company: nil) }
}
