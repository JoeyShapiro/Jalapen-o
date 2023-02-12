//
//  ContentView.swift
//  Jalapeño
//
//  Created by Joey Shapiro on 2/4/23.
//

import SwiftUI
import LibJalapen_o

struct WallpaperImage: Hashable {
    let id: UUID
    let name: String
    let image: NSImage
    var azimuth: Float = 0.0
    var altitude: Float = 0.0
    
    public init(filePath: String) {
        id = UUID()
        name = filePath
        image = NSImage(contentsOfFile: filePath) ?? NSImage(systemSymbolName: "square.and.arrow.up.trianglebadge.exclamationmark", accessibilityDescription: nil)!
    }
}

struct ContentView: View {
    // it doesnt seem we need the path ever again. thank god, saves validating
    @State var images: [WallpaperImage] = [ WallpaperImage(filePath: "/Users/oniichan/Pictures/WallpaperImagesR2/anime-computer-dawn-old.jpg"), WallpaperImage(filePath: "/Users/oniichan/Pictures/WallpaperImagesR2/anime-computer-dawn-old.jpg"), WallpaperImage(filePath: "garbage")
    ]
    
    @State var primary = ""
    @State var forLight = ""
    @State var forDark = ""
    @State var curAzimuth: Float = 0.0
    @State var curAltitude: Float = 0.0
    @State var selected = UUID()
    @State var curImage = WallpaperImage(filePath: "")
    
    var body: some View {
        let test = LibJalapen_o.init()
        VStack {
            HStack {
                ScrollView {
                    ForEach(images, id: \.self) { image in
                        WallpaperDisplay(wallpaperImage: image, height: 200, highlight: selected == image.id, action: {
                            
                            
                            selected = image.id
                            curAzimuth = image.azimuth // TODO i dont think these update. also use an object
                            curAltitude = image.altitude
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
                            Text(image.name)
                        }
                    }
                    Picker("For Light", selection: $forLight) {
                        ForEach(images, id: \.self) { image in
                            Text(image.name)
                        }
                    }
                    Picker("For Dark", selection: $forDark) {
                        ForEach(images, id: \.self) { image in
                            Text(image.name)
                        }
                    }
                    Divider()
                        .padding()
                    HStack {
                        Text("Azimuth")
                        TextField("Azimuth", value: $curImage.azimuth, format: .number)
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
                        images.append(contentsOf: realImages.map({ f in return WallpaperImage(filePath: f) })) // TODO super inefficient
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
    var wallpaperImage: WallpaperImage
    var height: CGFloat
    var highlight: Bool
    var action: () -> Void
    
    var body: some View {
        let image = wallpaperImage.image
        let color = highlight ? Color.accentColor.opacity(0.8) : Color.accentColor.opacity(0)
        Image(nsImage: image)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: height * 1.333, height: height)
            .clipped()
            .border(color, width: 5)
            .cornerRadius(10)
            .help(wallpaperImage.name)
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
