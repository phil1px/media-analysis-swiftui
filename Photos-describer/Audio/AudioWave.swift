import SwiftUI
import Foundation

struct AudioWaveView: View {
    let amplitude: CGFloat

    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let midHeight = geometry.size.height / 2
                let width = geometry.size.width
                let height = geometry.size.height

                path.move(to: CGPoint(x: 0, y: midHeight))

                for x in stride(from: 0, through: width, by: 1) {
                    let relativeX = x / width
                    let sine = sin(relativeX * 2 * .pi * 4)
                    let y = midHeight + sine * amplitude * height * 0.5

                    path.addLine(to: CGPoint(x: x, y: y))
                }
            }
            .stroke(Color.blue, lineWidth: 2)
        }
    }
}
