//
//  ContentView.swift
//  Jalapeño
//
//  Created by Joey Shapiro on 2/4/23.
//

import SwiftUI
import LibJalapen_o

struct ContentView: View {
    @State var images: [String] = ["/Users/oniichan/Pictures/WallpaperImagesR2/anime-computer-dawn-old.jpg"]
    var body: some View {
        let test = LibJalapen_o.init()
        VStack {
            HStack {
                ScrollView {
                    ForEach(images, id: \.self) { image in
                        WallpaperDisplay(filePath: image, height: 200, action: {
                            
                        })
                    }
                    WallpaperSystem(systemName: "plus", height: 200, action: {
                        
                    })
                }
                .padding()
                Spacer()
                VStack {
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
                                return f.absoluteString
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
                Text("Hello")
            }
        }
    }
}

struct WallpaperDisplay: View {
    var filePath: String
    var height: CGFloat
    var action: () -> Void
    
    var body: some View {
        let image = NSImage(contentsOfFile: filePath)
        Image(nsImage: image!)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: height * 1.333, height: height)
            .clipped()
            .cornerRadius(10)
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
