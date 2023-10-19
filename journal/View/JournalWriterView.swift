//
//  JournalWriterView.swift
//  AppJournal
//
//  Created by Kun Chen on 2023-08-17.
//

import SwiftUI

struct IdentifiableImage: Identifiable {
    let id = UUID()
    let image: UIImage
    var caption: String = ""
}

enum ImagePickerSourceType {
    case camera
    case photoLibrary
}

struct JournalWriterView: View {
    
    @StateObject var imageManager = ImageManager()
    
    @State private var images: [IdentifiableImage] = []
    @State private var showingImagePicker = false
    @State private var sourceType: ImagePickerSourceType = .photoLibrary
    @State private var selectedImage: IdentifiableImage?
    @State private var journalText: String = ""
    @State private var toggleOn: Bool = false
        
    var body: some View {
        
        ZStack{
            
            Color.white
                .ignoresSafeArea()
            
            VStack{
                VStack {
                    JournalHeaderView(journalType: "Reflective Journal", journalTypeDescription: "Think about events, experiences, or new information, and reflect on their implications and meanings.")
                    
                    if images.isEmpty {
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white)
                                .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.theme.backgroundColor, lineWidth: 1))
                            
                            HStack(spacing: 10) {
                                Image(systemName: "square.and.arrow.up.on.square")
                                    .resizable()
                                    .foregroundColor(.purple)
                                    .frame(width: 20, height: 20)

                                Text("Add Photos")
                                    .foregroundColor(.black)
                                    .font(.footnote)
                            }
                        }
                        .padding()
                    } else {
                        ZStack{
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white)
                                .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.theme.backgroundColor, lineWidth: 1))

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach(images, id: \.id) { identifiableImage in
                                        ZStack(alignment: .topTrailing) {
                                            Image(uiImage: identifiableImage.image)
                                                .resizable()
                                                .scaledToFit()
                                                .frame(height: 130)
                                                .cornerRadius(8)
                                                .onTapGesture {
                                                    selectedImage = identifiableImage
                                                }
                                            Button(action: {
                                                if let index = images.firstIndex(where: { $0.id == identifiableImage.id }) {
                                                    images.remove(at: index)
                                                }
                                            }) {
                                                Image(systemName: "xmark.circle.fill")
                                                    .foregroundColor(.red)
                                            }
                                        }
                                        .padding()
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                    HStack() {
                        Button(action: {
                            sourceType = .camera
                            showingImagePicker.toggle()
                            
                        }) {
                            Image(systemName: "camera.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 25, height: 25)
                                .foregroundColor(.gray) // Color of the icon
                                .padding(.horizontal)

                        }
                        .disabled(!UIImagePickerController.isSourceTypeAvailable(.camera))

                        Button(action: {
                            sourceType = .photoLibrary
                            showingImagePicker.toggle()
                        }) {
                            Image(systemName: "folder.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 25, height: 25)
                                .foregroundColor(.gray)
                                .padding(.horizontal)
                        }
                    }
                }
                .sheet(isPresented: $showingImagePicker) {
                    CustomImagePicker(images: $images, sourceType: sourceType)
                }
                .sheet(item: $selectedImage) { selectedImage in
                    VStack{
                        Image(uiImage: selectedImage.image)
                            .resizable()
                            .scaledToFit()
                            .padding()
//                        Text(selectedImage.caption)
                    }
                }
                

                HStack{
                    Button(action: {
                        // Your action goes here
                        print("Mic button tapped!")
                    }) {
                        Image(systemName: "mic.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 22, height: 22)
                            .padding()
                            .background(Color.white)
                            .foregroundColor(.purple)
                            .clipShape(Circle())
                    }
                                
                    Toggle("", isOn: $toggleOn)

                    if toggleOn {
                        Text("Public")
                            .font(.subheadline)
                    } else {
                        Text("Private")
                            .font(.subheadline)
                    }
                }
                .padding(.horizontal)
                
                
                ZStack{
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white)
                        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.theme.backgroundColor, lineWidth: 1))
                    
                    ScrollView {
                        TextEditor(text: $journalText)
                            .scrollContentBackground(.hidden)
                            .background(.white)
                            .foregroundColor(.black)
                            .padding(.all, 20)
                    }
                }
                .padding()
            }
        }
        .onTapGesture {
            self.endEditing()
        }
    }
}





struct CustomImagePicker: UIViewControllerRepresentable {
    @Binding var images: [IdentifiableImage]
    @Environment(\.presentationMode) private var presentationMode
    var sourceType: ImagePickerSourceType = .photoLibrary

    func makeUIViewController(context: UIViewControllerRepresentableContext<CustomImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        switch sourceType {
        case .camera:
            picker.sourceType = .camera
        case .photoLibrary:
            picker.sourceType = .photoLibrary
        }
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<CustomImagePicker>) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        
        @StateObject private var huggingFaceAPIManager = HuggingFaceAPIManager()

        var parent: CustomImagePicker

        init(_ parent: CustomImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let uiImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                var identifiableImage = IdentifiableImage(image: uiImage)
                huggingFaceAPIManager.sendImageToEndpoint(originalImage: uiImage)
                identifiableImage.caption = huggingFaceAPIManager.imageCaption
                parent.images.append(identifiableImage)
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

struct JournalWriterView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self) {
            JournalHomeView().preferredColorScheme($0)
                .environmentObject(JournalManager())

        }
    }
}
