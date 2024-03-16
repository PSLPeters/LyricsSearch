//
//  ContentView.swift
//  LyricsSearch
//
//  Created by Michael Peters on 3/8/24.
//

import SwiftUI
import AVFoundation

let synthesizer = AVSpeechSynthesizer()
let lyricsReader = LyricsReader()

struct ContentView: View {
    @Environment(\.openURL) var openURL
    @State private var lyrics = ""
    @State private var lyricsModified = ""
    @State private var searchedArtist = ""
    @State private var searchedSong = ""
    @State private var isShowingCurseWordSheet = false
    @State private var isLyricsTextCopied = false
    
    @AppStorage("artist") var artist = ""
    @AppStorage("song") var song = ""
    @AppStorage("isDarkModeOn") var isDarkModeOn = false
    @AppStorage("isSiriOn") var isSiriOn = false
    
    @AppStorage("isAssCensored") var isAssCensored = false
    @AppStorage("isDamnCensored") var isDamnCensored = false
    @AppStorage("isFuckCensored") var isFuckCensored = false
    @AppStorage("isHellCensored") var isHellCensored = false
    @AppStorage("isShitCensored") var isShitCensored = false
    
    var body: some View {
        VStack {
            HStack {
                Button {
                    isDarkModeOn.toggle()
                } label: {
                    let image = isDarkModeOn ? "lightbulb" : "lightbulb.fill"
                    Image(systemName: image)
                }
                .padding(.leading, 15)
                .padding(.trailing, 15)
                Button {
                    isSiriOn.toggle()
                    if isSiriOn == false
                    {
                        lyricsReader.stopReading()
                    }
                } label: {
                    let image = isSiriOn ? "waveform.circle.fill" : "waveform.circle"
                    Image(systemName: image)
                }
                Spacer()
                Text("Peters Lyrics")
                    .font(.title)
                    .bold()
                Spacer()
                Button {
                    isShowingCurseWordSheet = true
                } label: {
                    Text("&@!$#")
                }
                .padding(.trailing, 15)
                .sheet(isPresented: $isShowingCurseWordSheet, onDismiss: {
                    lyricsModified = lyrics
                        .replacingOccurrences(of: "\(searchedSong) par \(searchedArtist)", with: "", options: .caseInsensitive)
                        .replacingOccurrences(of: "Paroles de la chanson ", with: "")
                        .replacingOccurrences(of: isAssCensored ? "Ass" : "+++", with: "***", options: .caseInsensitive)
                        .replacingOccurrences(of: isDamnCensored ? "Damn" : "+++", with: "****", options: .caseInsensitive)
                        .replacingOccurrences(of: isFuckCensored ? "Fuck" : "+++", with: "****", options: .caseInsensitive)
                        .replacingOccurrences(of: isHellCensored ? "Hell" : "+++", with: "****", options: .caseInsensitive)
                        .replacingOccurrences(of: isShitCensored ? "Shit" : "+++", with: "****", options: .caseInsensitive)
                }) {
                     ZStack {
                         HStack {
                             Button {
                                 isShowingCurseWordSheet = false
                             } label: {
                                 Text("Close")
                             }
                             .padding([.leading, .top])
                             Spacer()
                         }
                         HStack {
                             Text("Curse Word Options")
                             .padding(.top)
                            }
                    }
                    Spacer()
                    Form {
                        Section("Select which curse words to censor:") {
                            HStack {
                                Text("Options")
                                Spacer()
                                Divider()
                                Button {
                                    isAssCensored = false
                                    isDamnCensored = false
                                    isFuckCensored = false
                                    isHellCensored = false
                                    isShitCensored = false
                                } label: {
                                    Text("Deselect All")
                                }
                            }
                            Toggle("Ass", isOn: $isAssCensored)
                            Toggle("Damn", isOn: $isDamnCensored)
                            Toggle("Fuck", isOn: $isFuckCensored)
                            Toggle("Hell", isOn: $isHellCensored)
                            Toggle("Shit", isOn: $isShitCensored)
                        }
                            Section("Lyrics provided by:") {
                                Link("https://lyricsovh.docs.apiary.io",
                                     destination: URL(string: "https://lyricsovh.docs.apiary.io/#reference/0/lyrics-of-a-song/search")!)
                            }
                    }
                }
            }
            HStack {
                Text("Artist:")
                TextField("Artist", text: $artist)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            .padding(.leading, 10)
            .padding(.trailing, 10)
            HStack {
                Text("Song:")
                    .padding(.trailing, 1)
                TextField("Song", text: $song)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            .padding(.leading, 10)
            .padding(.trailing, 10)
            Divider()
            HStack {
                Text("Lyrics:")
                Spacer()
                Button(action: {
                    UIPasteboard.general.string = lyricsModified
                    isLyricsTextCopied = true
                }, label: {
                    Text(isLyricsTextCopied ? "Copied!" : "Copy All")
                })
                .disabled(lyricsModified.isEmpty || isLyricsTextCopied)
            }
            .padding(.leading, 10)
            .padding(.trailing, 10)
            ScrollView {
                TextField("",
                          text: $lyricsModified,
                          axis: .vertical)
            }
            .padding(.leading, 10)
            .padding(.trailing, 10)
        }
        .overlay {
            if lyrics.isEmpty
            {
                ContentUnavailableView(
                    label:
                        {
                            Label("No lyrics found!", systemImage: "music.mic")
                        }
                    , description:
                        {
                            Text("Adjust your search criteria and try again.")
                        })
            }
        }
        Button {
            Task {
                lyricsReader.stopReading()
                let artistEdit = removeSpecialCharsFromString(text: artist).replacingOccurrences(of: " ", with: "%20")
                let songEdit = removeSpecialCharsFromString(text: song).replacingOccurrences(of: " ", with: "%20")
                
                let (data, _) = try await URLSession.shared.data(from: URL(string:"https://api.lyrics.ovh/v1/\(artistEdit)/\(songEdit)")!)
                let decodedResponse = try? JSONDecoder().decode(Song.self, from: data)
                searchedArtist = artist
                searchedSong = song
                lyrics = decodedResponse?.lyrics ?? ""
                
                lyricsModified = lyrics
                    .replacingOccurrences(of: "\(searchedSong) par \(searchedArtist)", with: "", options: .caseInsensitive)
                    .replacingOccurrences(of: "Paroles de la chanson ", with: "")
                    .replacingOccurrences(of: isAssCensored ? "Ass" : "+++", with: "***", options: .caseInsensitive)
                    .replacingOccurrences(of: isDamnCensored ? "Damn" : "+++", with: "****", options: .caseInsensitive)
                    .replacingOccurrences(of: isFuckCensored ? "Fuck" : "+++", with: "****", options: .caseInsensitive)
                    .replacingOccurrences(of: isHellCensored ? "Hell" : "+++", with: "****", options: .caseInsensitive)
                    .replacingOccurrences(of: isShitCensored ? "Shit" : "+++", with: "****", options: .caseInsensitive)
                if isSiriOn
                {
                    lyricsReader.readLyrics(lyricsModified, withVoice: "en-US", atRate: 1.0)
                }
                isLyricsTextCopied = false
            }
        } label: {
            Image(systemName: "music.quarternote.3")
            Text("Load Lyrics")
            Image(systemName: "music.quarternote.3")
        }
        .padding(.top, 10)
        
        .preferredColorScheme(isDarkModeOn ? .dark : .light)
    }
}

struct Song: Codable {
    let lyrics: String
}

func removeSpecialCharsFromString(text: String) -> String {
    let okayChars = Set("abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLKMNOPQRSTUVWXYZ1234567890+-=().!_")
    return text.filter {okayChars.contains($0) }
}

// A robot generated this code
class LyricsReader {

    func readLyrics(_ lyrics: String, withVoice voice: String = "en-US", atRate rate: Float = 0.4) {
        let utterance = AVSpeechUtterance(string: lyrics)
        utterance.voice = AVSpeechSynthesisVoice(language: voice)
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate * rate
        synthesizer.speak(utterance)
    }

    func pauseReading() {
        synthesizer.pauseSpeaking(at: .immediate)
    }

    func continueReading() {
        synthesizer.continueSpeaking()
    }

    func stopReading() {
        synthesizer.stopSpeaking(at: .immediate)
    }

    func isSpeaking() -> Bool {
        return synthesizer.isSpeaking
    }

    func availableVoices() -> [AVSpeechSynthesisVoice] {
        return AVSpeechSynthesisVoice.speechVoices()
    }
}


#Preview {
    ContentView()
}
