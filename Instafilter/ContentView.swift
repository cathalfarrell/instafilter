//
//  ContentView.swift
//  Instafilter
//
//  Created by Cathal Farrell on 23/05/2020.
//  Copyright © 2020 Cathal Farrell. All rights reserved.
//

import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

struct ContentView: View {

    @State private var image: Image? //displayed in view
    @State private var filterIntensity = 0.5
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage? //selected from library before processing
    @State private var currentFilter: CIFilter = CIFilter.sepiaTone()
    @State private var showingFilterSheet = false
    @State private var processedImage: UIImage? //after filter applied
    @State private var selectedFilterName: String = FilterName.sepia.rawValue // Shown on button

    @State private var showAlert = false

    enum FilterName: String {
        case crystallize = "Crystallize"
        case edges = "Edges"
        case gaussianBlur = "Guassian Blur"
        case pixellate = "Pixellate"
        case sepia = "Sepia Tone"
        case unSharpMask = "Unsharp Mask"
        case vignette = "Vignette"
    }

    let context = CIContext()

    var body: some View {

        let intensity = Binding<Double>(
            get: {
                self.filterIntensity
            },
            set: {
                self.filterIntensity = $0
                self.applyProcessing()
            }
        )

        return NavigationView {
            VStack {
                ZStack {
                    Rectangle()
                        .fill(Color.secondary)

                    // display the image
                    if image != nil {
                        image?
                            .resizable()
                            .scaledToFit()
                    } else {
                        Text("Tap to select a picture")
                            .foregroundColor(.white)
                            .font(.headline)
                    }
                }
                .onTapGesture {
                    // select an image
                    self.showingImagePicker = true
                }

                HStack {
                    Text("Intensity")
                    Slider(value: intensity)
                }
                .padding(.vertical)

                HStack {
                    Button("\(selectedFilterName)") {
                        /* Challenge 2 - Make the Change Filter button change its title to show the name of the currently selected filter.
                         */
                        self.showingFilterSheet = true
                    }

                    Spacer()

                    Button("Save") {
                        self.saveImageToLibrary()
                    }
                }
            }
            .padding([.horizontal, .bottom])
            .navigationBarTitle("Instafilter")
            .sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
                ImagePicker(image: self.$inputImage)
            }
            .actionSheet(isPresented: $showingFilterSheet) {
                // action sheet here
                ActionSheet(title: Text("Select a filter"), buttons: [
                    .default(Text(FilterName.crystallize.rawValue)) { self.setFilter(CIFilter.crystallize(), name: .crystallize) },
                    .default(Text(FilterName.edges.rawValue)) { self.setFilter(CIFilter.edges(), name: .edges) },
                    .default(Text(FilterName.gaussianBlur.rawValue)) { self.setFilter(CIFilter.gaussianBlur(), name: .gaussianBlur) },
                    .default(Text(FilterName.pixellate.rawValue)) { self.setFilter(CIFilter.pixellate(), name: .pixellate) },
                    .default(Text(FilterName.sepia.rawValue)) { self.setFilter(CIFilter.sepiaTone(), name: .sepia) },
                    .default(Text(FilterName.unSharpMask.rawValue)) { self.setFilter(CIFilter.unsharpMask(), name: .unSharpMask) },
                    .default(Text(FilterName.vignette.rawValue)) { self.setFilter(CIFilter.vignette(), name: .vignette) },
                    .cancel()
                ])
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Missing Image"), message: Text("You need to select an image to save."), dismissButton: .default(Text("OK")))

            }
        }
    }

    func setFilter(_ filter: CIFilter, name: FilterName) {
        currentFilter = filter
        selectedFilterName = name.rawValue
        loadImage()
    }

    // MARK:- Loads image that is selected from image picker & apply filter to it
    func loadImage() {
        guard let inputImage = inputImage else { return }

        let beginImage = CIImage(image: inputImage)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        applyProcessing()
    }

    // Filter Processing

    func applyProcessing() {
        //Caters for all Filters by searching if they contain these keys
        let inputKeys = currentFilter.inputKeys
        if inputKeys.contains(kCIInputIntensityKey) { currentFilter.setValue(filterIntensity, forKey: kCIInputIntensityKey) }
        if inputKeys.contains(kCIInputRadiusKey) { currentFilter.setValue(filterIntensity * 200, forKey: kCIInputRadiusKey) }
        if inputKeys.contains(kCIInputScaleKey) { currentFilter.setValue(filterIntensity * 10, forKey: kCIInputScaleKey) }

        guard let outputImage = currentFilter.outputImage else { return }

        //CI->UI->Image

        if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
            let uiImage = UIImage(cgImage: cgimg)
            image = Image(uiImage: uiImage)
            processedImage = uiImage //for saving to library - must be UIImage
        }
    }

    func saveImageToLibrary() {

        /*
           Challenge 1 - Try making the Save button show an error if there was no image in the image view.
        */

        //Save the picture
        guard let processedImage = self.processedImage else {

            print("You must select an image first you donkey!")
            showAlert = true
            return
        }

        let imageSaver = ImageSaver()

        //Using completion handlers to check response.
        imageSaver.successHandler = {
            print("Image was saved to your library successfully!")
        }

        imageSaver.errorHandler = {
            print("Failed to save image: \($0.localizedDescription)")
        }

        imageSaver.writeToPhotoAlbum(image: processedImage)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
