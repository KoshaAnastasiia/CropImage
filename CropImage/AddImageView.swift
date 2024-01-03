//
//  AddImageView.swift
//  CropImage
//
//  Created by kosha on 23.10.2023.
//

import SwiftUI
import PhotosUI

struct AddImageView: View {
    @State var images: [UIImage] = []
    @State var selectedImages: [PhotosPickerItem] = []
    @State private var showPhotosPicker: Bool = false
    @State private var showCropView: Bool = false
    @State private var selectedImageIndex: Int = 0
    
    private let columns: [GridItem] = [
        GridItem(.flexible(), alignment: .center),
        GridItem(.flexible(), alignment: .center),
        GridItem(.flexible(), alignment: .center)
    ]
    
    var body: some View {
        NavigationStack {
            VStack {
                if images.isEmpty {
                    Text("No Image is Selected")
                        .font(.caption)
                        .foregroundColor(.gray)
                } else {
                    LazyVGrid(columns: columns, spacing: 10) {
                        ForEach(images, id:\.cgImage) { image in
                            Button(action: { tapOnImage(image) },
                                   label: {
                                ZStack {
                                    Color.white.opacity(0.3)
                                        .cornerRadius(10)
                                    Image(uiImage: image)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 100, height: 100)
                                }
                                .overlay(
                                    Rectangle()
                                    .stroke(.gray, lineWidth: 0.3))
                                .shadow(radius: 5)
                                .frame(width: 120, height: 120)
                            })
                        }
                    }
                    .padding(5)
                }
            }
            .photosPicker(isPresented: $showPhotosPicker,
                          selection: $selectedImages,
                          maxSelectionCount: 5,
                          selectionBehavior: .ordered)
            .onChange(of: selectedImages) { _, _ in
                images = []
                for item in selectedImages {
                    Task {
                        if let imageData = try? await item.loadTransferable(type: Data.self),
                           let image = UIImage(data: imageData) {
                            await MainActor.run(body: {
                                self.images.append(image)
                            })
                        }
                    }
                }
            }
            .preferredColorScheme(.light)
            .navigationTitle("Crop Image Picker")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showPhotosPicker.toggle()
                    } label: {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.callout)
                    }
                    .tint(.black)
                }
            }
            .fullScreenCover(isPresented: $showCropView) {
                CropImageView(images: $images, 
                              selectedImageIndex: $selectedImageIndex)
            }
            
        }
    }
    
    func tapOnImage(_ image: UIImage) {
        if let index = images.firstIndex(of: image) {
            selectedImageIndex = index
        }
        showCropView.toggle()
    }
}

#Preview {
    AddImageView()
}
