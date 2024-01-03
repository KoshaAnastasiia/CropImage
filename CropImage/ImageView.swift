//
//  ImageView.swift
//  CropImage
//
//  Created by kosha on 23.10.2023.
//

import SwiftUI

struct ImageView: View {
    @Binding var images: [UIImage]
    @Binding var showGrids: Bool
    @Binding var selectedImageIndex: Int
    
    var currentImageIndex: Int
    
    @State var scale: CGFloat = 1
    @State private var fixedRect = Crop.rectangle.size()
    @State private var actualRect = Crop.rectangle.size()
    
    @State private var isChanging: Bool = false
    
    var body: some View {
            ZStack {
                Image(uiImage: images[currentImageIndex])
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .overlay(content: {
                        GeometryReader { proxy in
                            if showGrids {
                                Grids()
                                    .onAppear {
                                        let screen = CGRect(origin: .zero, size: proxy.size)
                                        scale = min(images[currentImageIndex].size.width / proxy.size.width, images[currentImageIndex].size.height / proxy.size.height)
                                        let xScale = screen.width / actualRect.width
                                        let yScale = screen.height / actualRect.height
                                        let minScale = min(xScale, yScale)
                                        if minScale < 1 {
                                            actualRect = actualRect.applying(CGAffineTransform(scaleX: minScale, y: minScale))
                                        }
                                        actualRect = actualRect.offsetBy(dx: screen.midX - actualRect.midX, dy: screen.midY - actualRect.midY)
                                        fixedRect = actualRect
                                    }
                                    .onChange(of: actualRect, perform: { _ in
                                        let screen = CGRect(origin: .zero, size: proxy.size)
                                        let wratio = actualRect.width / actualRect.height
                                        let hratio = actualRect.height / actualRect.width
                                        let midX = actualRect.midX
                                        let midY = actualRect.midY
                                        if actualRect.width > screen.width {
                                            actualRect.size.width = screen.width
                                            actualRect.size.height = screen.width * hratio
                                            actualRect = actualRect.offsetBy(dx: midX - actualRect.midX, dy: midY - actualRect.midY)
                                        }
                                        if actualRect.height > screen.height {
                                            actualRect.size.height = screen.height
                                            actualRect.size.width = screen.height * wratio
                                            actualRect = actualRect.offsetBy(dx: midX - actualRect.midX, dy: midY - actualRect.midY)
                                        }
                                        if actualRect.minX < screen.minX {
                                            actualRect.origin.x = 0
                                        }
                                        if actualRect.minY < screen.minX {
                                            actualRect.origin.y = 0
                                        }
                                        if actualRect.maxX > screen.maxX {
                                            actualRect.origin.x -= actualRect.maxX - screen.maxX
                                        }
                                        if actualRect.maxY > screen.maxY {
                                            actualRect.origin.y -= actualRect.maxY - screen.maxY
                                        }
                                    })
                                
                            }
                        }
                    })
                    .overlay {
                        if showGrids {
                            Color.clear
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .contentShape(Rectangle())
                                .gesture(
                                    DragGesture()
                                        .onChanged({ value in
                                            isChanging = true
                                            if let anchor = fixedRect.anchor(for: value.startLocation) {
                                                actualRect = fixedRect.magnify(with: anchor, translation: value.translation)
                                            } else {
                                                actualRect = fixedRect.offsetBy(dx: value.translation.width, dy: value.translation.height)
                                            }
                                        })
                                        .onEnded({ _ in
                                            fixedRect = actualRect
                                            isChanging = false
                                        })
                                )
                                .gesture(
                                    MagnificationGesture()
                                        .onChanged({ value in
                                            isChanging = true
                                            actualRect = fixedRect.insetBy(dx: fixedRect.width / 2 - value * fixedRect.width / 2, dy: fixedRect.height / 2 - value * fixedRect.height / 2)
                                        })
                                        .onEnded({ _ in
                                            fixedRect = actualRect
                                            isChanging = false
                                        })
                                )
                        }
                    }
            }
            .onChange(of: showGrids, { oldValue, newValue in
                if newValue == false && selectedImageIndex == currentImageIndex {
                    let scaledRect = CGRect(
                        x: actualRect.origin.x * scale,
                        y: actualRect.origin.y * scale,
                        width: actualRect.width * scale,
                        height: actualRect.height * scale
                    )
                    actualRect = Crop.rectangle.size()
                    images[selectedImageIndex] = images[selectedImageIndex].croppedImage(inRect: scaledRect)
                    
                }
            })
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black)
            .coordinateSpace(name: "CROPVIEW")
    }
    
    @ViewBuilder
        func Grids() -> some View {
                ZStack{
                    HStack{
                        ForEach(1...3,id: \.self) {_ in
                            Rectangle()
                                .fill(isChanging ? .white.opacity(0.7) : .clear)
                                .frame(width: 1)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    VStack{
                        ForEach(1...4,id: \.self) {_ in
                            Rectangle()
                                .fill(isChanging ? .white.opacity(0.7) : .clear)
                                .frame(height: 1)
                                .frame(maxHeight: .infinity)
                        }
                    }
                }.overlay(RoundedRectangle(cornerRadius: 0)
                    .stroke(.white, lineWidth: 1.2))
                .overlay {
                    ZStack(alignment: .topLeading) {
                        Rectangle()
                            .fill(.white)
                            .frame(width: 3, height: 15)
                        Rectangle()
                            .fill(.white)
                            .frame(width: 15, height: 3)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    ZStack(alignment: .topTrailing) {
                        Rectangle()
                            .fill(.white)
                            .frame(width: 3, height: 15)
                        Rectangle()
                            .fill(.white)
                            .frame(width: 15, height: 3)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                    ZStack(alignment: .bottomLeading) {
                        Rectangle()
                            .fill(.white)
                            .frame(width: 3, height: 15)
                        Rectangle()
                            .fill(.white)
                            .frame(width: 15, height: 3)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                    ZStack(alignment: .bottomTrailing) {
                        Rectangle()
                            .fill(.white)
                            .frame(width: 3, height: 15)
                        Rectangle()
                            .fill(.white)
                            .frame(width: 15, height: 3)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                }
                .frame(actualRect)
        }
}

#Preview {
    ImageView(images: .constant([UIImage()]),
              showGrids: .constant(false),
              selectedImageIndex: .constant(0),
              currentImageIndex: 0)
}

enum Anchor: CaseIterable {
    case left, right, top, bottom
    case leftTop, leftBottom, rightTop, rightBottom
    
    static let delta: CGFloat = 15
    
    var opposite: Anchor {
        switch self {
        case .left:
            return .right
        case .right:
            return .left
        case .top:
            return .bottom
        case .bottom:
            return .top
        case .leftTop:
            return .rightBottom
        case .leftBottom:
            return .rightTop
        case .rightTop:
            return .leftBottom
        case .rightBottom:
            return .leftTop
        }
    }
}

extension CGPoint {
    func distance(to point: CGPoint) -> CGFloat {
        let dx = x - point.x
        let dy = y - point.y
        return CGFloat(sqrt(dx * dx + dy * dy))
    }
}

extension CGSize {
    var diagonal: CGFloat {
        return CGFloat(sqrt(width * width + height * height))
    }
}

extension CGRect {
    func anchor(for point: CGPoint) -> Anchor? {
        Anchor.allCases.first { anchor in
            point.distance(to: self.point(for: anchor)) < Anchor.delta
        }
    }
    
    func point(for anchor: Anchor) -> CGPoint {
        switch anchor {
        case .left:
            return CGPoint(x: minX, y: midY)
        case .right:
            return CGPoint(x: maxX, y: midY)
        case .top:
            return CGPoint(x: midX, y: minY)
        case .bottom:
            return CGPoint(x: midX, y: maxY)
        case .leftTop:
            return CGPoint(x: minX, y: minY)
        case .leftBottom:
            return CGPoint(x: minX, y: maxY)
        case .rightTop:
            return CGPoint(x: maxX, y: minY)
        case .rightBottom:
            return CGPoint(x: maxX, y: maxY)
        }
    }
    
    func scale(with anchor: Anchor, translation: CGSize) -> CGFloat {
        let staticAnchorPoint = point(for: anchor.opposite)
        let movementAnchorPoint = point(for: anchor)
        switch anchor {
        case .left:
            return max(0, -translation.width / width + 1)
        case .right:
            return max(0, translation.width / width + 1)
        case .top:
            return max(0, -translation.height / height + 1)
        case .bottom:
            return max(0, translation.height / height + 1)
        case .leftTop, .leftBottom, .rightTop, .rightBottom:
            let newSize = CGSize(
                width: movementAnchorPoint.x - staticAnchorPoint.x + translation.width,
                height: movementAnchorPoint.y - staticAnchorPoint.y + translation.height
            )
            return newSize.diagonal / size.diagonal
        }
    }
    
    func magnify(with anchor: Anchor, translation: CGSize) -> CGRect {
        let staticAnchorPoint = point(for: anchor.opposite)
        let translationScale = scale(with: anchor, translation: translation)
        let scaled = applying(CGAffineTransform.identity.scaledBy(x: translationScale, y: translationScale))
        let newStaticAnchorPoint = scaled.point(for: anchor.opposite)
        let translated = scaled.applying(CGAffineTransform.identity.translatedBy(
            x: staticAnchorPoint.x - newStaticAnchorPoint.x,
            y: staticAnchorPoint.y - newStaticAnchorPoint.y
        ))
        return translated
    }
}
