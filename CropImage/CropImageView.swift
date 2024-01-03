//
//  CropImageView.swift
//  CropImage
//
//  Created by kosha on 23.10.2023.
//

import SwiftUI

struct CropImageView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var images: [UIImage]
    @State private var showGrids: Bool = false
    @Binding var selectedImageIndex: Int

    var body: some View {
        NavigationStack {
            VStack {
                TabView(selection: $selectedImageIndex) {
                    ForEach(images.indices, id:\.self) { index in
                        ZStack {
                            Color.black
                            ImageView(images: $images, 
                                      showGrids: $showGrids,
                                      selectedImageIndex: $selectedImageIndex,
                                      currentImageIndex: index)
                        }
                    }
                }
                .tabViewStyle(.page)
                .indexViewStyle(.page(backgroundDisplayMode: .interactive))
                .padding(10)
                .navigationTitle("Crop View")
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackground(.visible, for: .navigationBar)
                .toolbarBackground(Color.black, for: .navigationBar)
                .toolbarColorScheme(.dark, for: .navigationBar)
                .frame(maxWidth: .infinity,maxHeight: .infinity)
                .background { Color.black.ignoresSafeArea() }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            showGrids.toggle()
                        } label: {
                            Image(systemName: showGrids ? "checkmark" : "crop")
                                .font(.callout)
                                .fontWeight(.semibold)
                        }
                    }
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.callout)
                                .fontWeight(.semibold)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    CropImageView(images: .constant([]),
                  selectedImageIndex: .constant(0))
}
