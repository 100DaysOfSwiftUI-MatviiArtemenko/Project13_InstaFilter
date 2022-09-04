//
//  ContentView.swift
//  Project13_InstaFilter
//
//  Created by admin on 31.08.2022.
//

import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

struct ContentView: View {
    @State private var image: Image?
    @State private var processedImage: UIImage?
    @State private var filterIntensity = 0.5
    
    @State private var filterRadius = 0.5
    @State private var filterScale = 0.5
    
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    
    @State private var currentFilter: CIFilter = CIFilter.sepiaTone()
    let context = CIContext()
    
    @State private var showingFilterSheet = false
    
    var body: some View {
        NavigationView {
            VStack {
                ZStack {
                    Rectangle()
                        .fill(.secondary)
                        .cornerRadius(10)
                    
                    Text("Tap to select your picture.")
                        .foregroundColor(.white)
                        .font(.title)
                    
                    image?
                        .resizable()
                        .scaledToFit()
                }
                .onTapGesture {
                    showingImagePicker = true
                }
                
                if currentFilter.inputKeys.contains(kCIInputRadiusKey) {
                    HStack {
                        ZStack(alignment: .leading) {
                            Text("Intensity").opacity(0) // force same width
                            Text("Radius")
                        }
                        Slider(value: $filterRadius)
                            .onChange(of: filterRadius) { _ in applyProcessing(for: filterRadius) }
                    }
                }
                
                VStack {
                    if currentFilter.inputKeys.contains(kCIInputIntensityKey) {
                        HStack {
                            Text("Intensity")
                            Slider(value: $filterIntensity)
                                .onChange(of: filterIntensity) { _ in applyProcessing(for: filterIntensity) }
                        }
                    }
                    if currentFilter.inputKeys.contains(kCIInputScaleKey) {
                        HStack {
                            ZStack(alignment: .leading) {
                                Text("Intensity").opacity(0) // force same width
                                Text("Scale")
                            }
                            Slider(value: $filterScale)
                                .onChange(of: filterScale, perform: {_ in applyProcessing(for: filterScale)})
                        }
                    }
                }
                .padding()
                
                
                HStack {
                    Button("Change filter") {
                        showingFilterSheet = true
                    }
                    Spacer()
                    
                    Button("Save changes", action: save)
                        .disabled(image == nil ? true : false)
                }
                .padding([.horizontal, .bottom])
                .navigationTitle("InstaFilter")
                .onChange(of: inputImage) { _ in loadImage() }
                .sheet(isPresented: $showingImagePicker) { ImagePicker(image: $inputImage)
                }
                .confirmationDialog("Select Filter", isPresented: $showingFilterSheet) {
                    Button("Crystallize") { setNewFilter(CIFilter.crystallize()) }
                    Button("Edges") { setNewFilter(CIFilter.edges()) }
                    Button("Gaussian Blur") { setNewFilter(CIFilter.gaussianBlur()) }
                    Button("Pixellate") { setNewFilter(CIFilter.pixellate()) }
                    Button("Sepia Tone") { setNewFilter(CIFilter.sepiaTone()) }
                    Button("Unsharp Mask") { setNewFilter(CIFilter.unsharpMask()) }
                    Button("Vignette") { setNewFilter(CIFilter.vignette()) }
                    Button("Bokeh") { setNewFilter(CIFilter.bokehBlur()) }
                    Button("Bloom") { setNewFilter(CIFilter.bloom()) }
                    Button("Cancel", role: .cancel) { }
                }
            }
        }
    }
    
    func loadImage() {
        guard let inputImage = inputImage else { return }
        let beginImage = CIImage(image: inputImage)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        applyProcessing(for: filterIntensity)
        
    }
    
    func save() {
        guard let processedImage = processedImage else { return }
        let imageSaver = ImageSaver()
        imageSaver.successHandler = {
            print("Success!")
        }
        
        imageSaver.errorHandler = {
            print("Error: \($0.localizedDescription)")
        }
        imageSaver.wrightToPhotoAlbum(image: processedImage)
        
    }
    func applyProcessing(for filter: Double ) {
        let inputKeys = currentFilter.inputKeys
        
        if inputKeys.contains(kCIInputIntensityKey) { currentFilter.setValue(filter, forKey: kCIInputIntensityKey) }
        if inputKeys.contains(kCIInputRadiusKey) { currentFilter.setValue(filter * 200, forKey: kCIInputRadiusKey) }
        if inputKeys.contains(kCIInputScaleKey) { currentFilter.setValue(filter * 10, forKey: kCIInputScaleKey) }
        
        
        
        guard let outputImage = currentFilter.outputImage else { return }
        
        if let sgImage = context.createCGImage(outputImage, from: outputImage.extent) {
            let uiImage = UIImage(cgImage: sgImage)
            image = Image(uiImage: uiImage)
            processedImage = uiImage
            
        }
    }
    func setNewFilter(_ filter: CIFilter) {
        currentFilter = filter
        loadImage()
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
