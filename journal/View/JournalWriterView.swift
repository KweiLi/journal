//
//  JournalWriterView.swift
//  journal
//
//  Created by Kun Chen on 2023-10-03.
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
    @State private var images: [IdentifiableImage] = []
    @State private var showingImagePicker = false
    @State private var sourceType: ImagePickerSourceType = .photoLibrary
    @State private var selectedImage: IdentifiableImage?
    @State private var journalText: String = ""
    @State private var toggleOn: Bool = false
        
    var body: some View {
        VStack{
            VStack {
                
                Text("Journal Photos")
                    .font(.title3)
                    .fontWeight(.bold)
                
                if images.isEmpty {
                    HStack {
                        Spacer() // Pushes content to the right
                        Image("imagepickerimage")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 150, height: 150)
                            .foregroundColor(.gray)
                            .cornerRadius(8)
                            .padding()
                        Spacer()
                    }
                    .background(Color.gray.opacity(0.2))
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(images, id: \.id) { identifiableImage in
                                ZStack(alignment: .topTrailing) {
                                    Image(uiImage: identifiableImage.image)
                                        .resizable()
                                        .frame(width: 150, height: 150)
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
                    .background(Color.gray.opacity(0.2))
                }

                HStack() {
                    // Camera Button
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
                    Text(selectedImage.caption)
                }
            }
            

            HStack(){
                            
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
            
            TextEditor(text: $journalText)
                .padding()
                .background(Color.gray.opacity(0.2))
            
            HStack(spacing: 30) {
                Button("Cancel") {
                    // handle cancel action
                }
                .padding()
                .background(Color.gray)
                .foregroundColor(.white)
                .cornerRadius(8)
                                    
                Button("Submit") {
                    
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
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
        JournalWriterView()
    }
}

