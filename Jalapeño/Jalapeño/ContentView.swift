//
//  ContentView.swift
//  Jalapeño
//
//  Created by Joey Shapiro on 2/4/23.
//

import SwiftUI
import LibJalapen_o
import AVFoundation

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
    
    public func getCG() -> CGImage {
        return self.image.cgImage(forProposedRect: nil, context: nil, hints: nil)!
    }
}

struct WallpaperDynamic {
    var primary: UUID
    var forLight: UUID
    var forDark: UUID
    var images: [WallpaperImage]
    
    public init() {
        primary = UUID()
        forLight = UUID()
        forDark = UUID()
        images = []
        
        let _ = self.append(filePath: "/Users/oniichan/Pictures/WallpaperImagesR2/anime-computer-dawn-old.jpg")
        _ = self.append(filePath: "/Users/oniichan/Pictures/WallpaperImagesR2/anime-computer-dawn-old.jpg")
        _ = self.append(filePath: "garbage")
    }
    
    public mutating func append(filePath: String) -> UUID {
        let image = WallpaperImage(filePath: filePath)
        self.images.append(image)
        
        return image.id
    }
    
    public mutating func remove(id: UUID) {
        self.images.removeAll(where: { $0.id == id }) // should only be one
        
        // remove the image from any settings
        if primary == id {
            primary = UUID()
        }
        if forLight == id {
            forLight = UUID()
        }
        if forDark == id {
            forDark = UUID()
        }
    }
    
    public func getPrimary() -> WallpaperImage {
        return self.images.first(where: { $0.id == primary })!
    }
    
    public func getForLight() -> WallpaperImage {
        return self.images.first(where: { $0.id == forLight })!
    }
    
    public func getForDark() -> WallpaperImage {
        return self.images.first(where: { $0.id == forDark })!
    }
}

func create(wallpaper: WallpaperDynamic) {
    print(kCGImagePropertyExifUserComment)
    let data = NSMutableData()
    if let dst = CGImageDestinationCreateWithData(data, AVFileType.heic as CFString, wallpaper.images.count, nil) {
        CGImageDestinationAddImageAndMetadata(dst, wallpaper.images[0].getCG(), nil, nil)
        for i in 1...wallpaper.images.count {
            CGImageDestinationAddImage(dst, wallpaper.images[i].getCG(), nil)
        }
    }
    
    do {
        let out = URL(filePath: "test.heic")
        try (data as Data).write(to: out)
        print(out)
    } catch {
        print(error)
    }
}

struct ContentView: View {
    // it doesnt seem we need the path ever again. thank god, saves validating
    @State var selected = UUID()
    @State var curImage = WallpaperImage(filePath: "")
    @State var dynamicWallpaper = WallpaperDynamic()
    
    var body: some View {
        let test = LibJalapen_o.init()
        
        VStack {
            HStack {
                ScrollView {
                    ForEach(dynamicWallpaper.images, id: \.self) { image in
                        WallpaperDisplay(wallpaperImage: image, height: 200, highlight: selected == image.id, action: {
                            if let i = dynamicWallpaper.images.firstIndex(where: { selected == $0.id }) {
                                dynamicWallpaper.images[i] = curImage
                            }
                            
                            selected = image.id
                            curImage = image
                        })
                    }
                    WallpaperSystem(systemName: "plus", height: 200, action: {
                        
                    })
                }
                .padding()
                Spacer()
                VStack {
                    Picker("Primary", selection: $dynamicWallpaper.primary) {
                        ForEach(dynamicWallpaper.images, id: \.self) { image in
                            Text(image.name).tag(image.id)
                        }
                    }
                    Picker("For Light", selection: $dynamicWallpaper.forLight) {
                        ForEach(dynamicWallpaper.images, id: \.self) { image in
                            Text(image.name).tag(image.id)
                        }
                    }
                    Picker("For Dark", selection: $dynamicWallpaper.forDark) {
                        ForEach(dynamicWallpaper.images, id: \.self) { image in
                            Text(image.name).tag(image.id)
                        }
                    }
                    Divider()
                        .padding()
                    HStack {
                        Text("Azimuth")
                        TextField("Azimuth", value: $curImage.azimuth, format: .number)
                            .textFieldStyle(.roundedBorder) // TODO if blank, dont print text
                        Text("Altitude")
                        TextField("Alititude", value: $curImage.altitude, format: .number)
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
                        dynamicWallpaper.images.append(contentsOf: realImages.map({ f in return WallpaperImage(filePath: f) })) // TODO super inefficient
                    }
                } label: {
                    Image(systemName: "plus")
                }
                .padding(5)
                Spacer()
                Button {
                    create(wallpaper: dynamicWallpaper)
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
