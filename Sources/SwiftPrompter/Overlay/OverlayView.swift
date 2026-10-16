import SwiftUI

struct OverlayView: View {
    @ObservedObject var model: AppModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: model.clickThrough ? "cursorarrow" : "hand.draw")
                Text(model.clickThrough ? "Click-through · disable in main window" : "Drag background to move · resize at edges")
                    .font(.caption)
                Spacer()
            }
            Text(AppModel.previewLines(from: model.script))
                .font(.system(size: model.fontSize, weight: .semibold, design: .rounded))
                .lineSpacing(6)
                .lineLimit(5)
                .frame(maxWidth: .infinity, alignment: .leading)
            Spacer(minLength: 0)
        }
        .foregroundStyle(.white)
        // Multiple black shadows preserve contrast when the panel background is clear.
        .shadow(color: .black, radius: 1, x: 1, y: 1)
        .shadow(color: .black, radius: 1, x: -1, y: -1)
        .shadow(color: .black.opacity(0.9), radius: 3)
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(.black.opacity(model.backgroundOpacity), in: RoundedRectangle(cornerRadius: 18))
    }
}
