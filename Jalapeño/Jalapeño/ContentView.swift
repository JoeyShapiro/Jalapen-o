//
//  ContentView.swift
//  Jalapeño
//
//  Created by Joey Shapiro on 2/4/23.
//

import SwiftUI
import LibJalapen_o

struct ContentView: View {
    // TODO if i just need image and not fs, use NSImage list
    @State var images: [String] = ["/Users/oniichan/Pictures/WallpaperImagesR2/anime-computer-dawn-old.jpg", "/Users/oniichan/Pictures/WallpaperImagesR2/anime-computer-dawn-old.jpg"]
    
    @State var primary = ""
    @State var forLight = ""
    @State var forDark = ""
    @State var curAzimuth: Float = 0.0
    @State var curAltitude: Float = 0.0
    @State var selected = 0
    
    var body: some View {
        let test = LibJalapen_o.init()
        VStack {
            HStack {
                ScrollView {
                    ForEach(images, id: \.self) { image in
                        WallpaperDisplay(filePath: image, height: 200, highlight: selected == 0, action: {
                            selected = 0
                        })
                    }
                    WallpaperSystem(systemName: "plus", height: 200, action: {
                        
                    })
                }
                .padding()
                Spacer()
                VStack {
                    Picker("Primary", selection: $forLight) {
                        ForEach(images, id: \.self) { image in
                            Text(image)
                        }
                    }
                    Picker("For Light", selection: $forLight) {
                        ForEach(images, id: \.self) { image in
                            Text(image)
                        }
                    }
                    Picker("For Dark", selection: $forDark) {
                        ForEach(images, id: \.self) { image in
                            Text(image)
                        }
                    }
                    Divider()
                        .padding()
                    HStack {
                        Text("Azimuth")
                        TextField("Azimuth", value: $curAzimuth, format: .number)
                            .textFieldStyle(.roundedBorder) // TODO if blank, dont print text
                        Text("Altitude")
                        TextField("Alititude", value: $curAltitude, format: .number)
                            .textFieldStyle(.roundedBorder)
                    }
                    Image(systemName: "globe")
                        .imageScale(.large)
                        .foregroundColor(.accentColor)
                    Text(test.Greetings())
                }
                .padding()
            }
            Divider()
            HStack {
                Button {
                    let panel = NSOpenPanel()
                    panel.allowsMultipleSelection = true
                    panel.canChooseDirectories = false
                    if panel.runModal() == .OK {
                        let possibleImages: [String] = panel.urls.map({ f in
                            let possibleImage = NSImage(contentsOf: f) ?? NSImage()
                            if possibleImage.isValid {
                                return f.path
                            } else {
                                return ""
                            }
                        })
                        let realImages: [String] = possibleImages.filter({ f in return f != ""})
                        images.append(contentsOf: realImages)
                    }
                } label: {
                    Image(systemName: "plus")
                }
                .padding(5)
                Spacer()
                Button {
                    print("saved")
                } label: {
                    Image(systemName: "square.and.arrow.down")
                }
                Text("Hello")
            }
        }
    }
}

struct WallpaperDisplay: View {
    var filePath: String
    var height: CGFloat
    var highlight: Bool
    var action: () -> Void
    
    var body: some View {
        let image = NSImage(contentsOfFile: filePath)
        Image(nsImage: image!)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: height * 1.333, height: height)
            .clipped()
            .border(Color.accentColor.opacity(0.8), width: 5)
            .cornerRadius(10)
            .help(filePath)
            .onTapGesture {
                action()
            }
    }
}

struct WallpaperSystem: View {
    var systemName: String
    var height: CGFloat
    var action: () -> Void
    
    var body: some View {
        Image(systemName: systemName)
            .imageScale(.large)
            .frame(width: height * 1.333, height: height)
            .clipped()
            .cornerRadius(10)
            .onTapGesture {
                action()
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
