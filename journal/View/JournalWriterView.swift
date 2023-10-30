//
//  JournalWriterView.swift
//  AppJournal
//
//  Created by Kun Chen on 2023-08-17.
//

import SwiftUI

struct IdentifiableImage: Identifiable {
    var id = UUID()
    var image: UIImage
    var url: URL?
    var caption: String?
}

enum ImagePickerSourceType {
    case camera
    case photoLibrary
}

struct JournalWriterView: View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    @EnvironmentObject var journalManager: JournalManager

    @State var journalImages:[UIImage] = []
    @State var journalImageCaptions:[String] = []
    @State var journalImageURLs:[URL] = []
    
    @State private var showingImagePicker = false
    @State private var sourceType: ImagePickerSourceType = .photoLibrary
    
    @State private var selectedImage: UIImage?
    @State private var isShowingSelectedImage = false

    @State private var journalText: String = ""
    @State private var toggleOn: Bool = false
        
    var body: some View {
        
        ZStack{
            
            Color.white
                .ignoresSafeArea()
            
            VStack{
                VStack {
                    JournalHeaderView(journalType: "Reflective Journal", journalTypeDescription: "Think about events, experiences, or new information, and reflect on their implications and meanings.")
                    
                    if journalImages.isEmpty {
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
                                    ForEach(journalImages.indices, id: \.self) { index in
                                        ZStack(alignment: .topTrailing) {
                                            Image(uiImage: journalImages[index])
                                                .resizable()
                                                .scaledToFit()
                                                .frame(height: 130)
                                                .cornerRadius(8)
                                                .onTapGesture {
                                                    selectedImage = journalImages[index]
                                                    isShowingSelectedImage.toggle()
                                                }

                                            Button(action: {
                                                journalImages.remove(at: index)
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
                                .frame(width: 20, height: 20)
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
                                .frame(width: 20, height: 20)
                                .foregroundColor(.gray)
                                .padding(.horizontal)
                        }
                    }
                }
                .sheet(isPresented: $showingImagePicker) {
                    CustomImagePicker(journalImages: $journalImages, journalImageURLs: $journalImageURLs, journalImageCaptions: $journalImageCaptions, sourceType: sourceType)
                }
                .sheet(isPresented: $isShowingSelectedImage)  {
                    if let image = selectedImage {
                        VStack {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .padding()
                        }
                    }
                }
                
                
                JournalPublicToggleView(toggle: $toggleOn)
                    .padding(.horizontal)
                
                ZStack{
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white)
                        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.theme.backgroundColor, lineWidth: 1))
                    
                    ScrollView {
                        VStack (alignment: .leading){
                            if journalImageCaptions.count > 0{
                                ForEach(journalImageCaptions, id: \.self) { caption in
                                    if let extractedCaption = extractCaption(from: caption) {
                                        (Text("Observation: ").bold() + Text(extractedCaption))                  .font(.footnote)
                                            .padding()
                                            .foregroundColor(Color.black)
                                            .background(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .fill(Color.purple.opacity(0.3))
                                                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.purple.opacity(0.6), lineWidth: 1))
                                            )
                                            .cornerRadius(10)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                }
                            }
                        }
                        .padding()
//
//                        Spacer()
//
//                        TextEditor(text: $journalText)
//                            .font(.caption)
//                            .scrollContentBackground(.hidden)
//                            .background(Color.theme.backgroundColor)
//                            .clipShape(RoundedRectangle(cornerRadius: 8))
//                            .foregroundColor(.black)
//                            .padding()
                    }
                }
                .padding()
                
                
                TextEditor(text: $journalText)
                    .font(.caption)
                    .scrollContentBackground(.hidden)
                    .background(Color.theme.backgroundColor)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .foregroundColor(.black)
                    .padding()
            
            }
        }
        .onTapGesture {
            self.endEditing()
        }
        .navigationBarTitle("Reflective Journal", displayMode: .inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action: {
            self.presentationMode.wrappedValue.dismiss()
            
            journalManager.resetJournal()
            
            journalManager.currentJournal.title = "My Reflective Journal"
            journalManager.currentJournal.category = "reflective"
            journalManager.currentJournal.text = journalText
            journalManager.currentJournal.imageUrls = journalImageURLs
            journalManager.currentJournal.imageCaptions = journalImageCaptions
            journalManager.currentJournal.publishIndicator = toggleOn
            
            if journalManager.currentJournal.text.isEmpty && journalManager.currentJournal.imageUrls.isEmpty {
                print("Journal is empty.")
            } else {
                journalManager.saveJournal(journal: journalManager.currentJournal)
            }
            
        }) {
            Image(systemName: "arrowshape.turn.up.backward")
        })
    }
}





struct CustomImagePicker: UIViewControllerRepresentable {
    @Binding var journalImages: [UIImage]
    @Binding var journalImageURLs: [URL]
    @Binding var journalImageCaptions: [String]
    
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
        @StateObject var imageManager = ImageManager()

        var parent: CustomImagePicker

        init(_ parent: CustomImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let uiImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                parent.journalImages.append(uiImage)
                
                // Dismiss the image picker immediately after appending the selected image
                parent.presentationMode.wrappedValue.dismiss()
                
                // Proceed with the asynchronous tasks
                imageManager.submitImageToFirebase(image: uiImage) { [weak self] result in
                    switch result {
                    case .success(let url):
                        self?.parent.journalImageURLs.append(url)
                        print("Success")
                    case .failure(let error):
                        print("Failed to upload image: \(error.localizedDescription)")
                    }
                }
                
                huggingFaceAPIManager.sendImageToEndpoint(originalImage: uiImage) { receivedCaption in
                    DispatchQueue.main.async {
                        if let caption = receivedCaption {
                            self.parent.journalImageCaptions.append(caption)
                            print(receivedCaption!)
                        } else {
                            self.parent.journalImageCaptions.append("")
                        }
                    }
                }
            } else {
                // In case there's an error or user cancels the picker without selecting an image
                parent.presentationMode.wrappedValue.dismiss()
            }
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
