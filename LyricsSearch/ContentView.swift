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
    
    @State private var isShowingCurseWordSheetLongPressAlert = false
    @State private var isShowingCopyLyricsLongPressAlert = false
    @State private var isShowingColorSchemeLongPressAlert = false
    @State private var isShowingSiriReaderLongPressAlert = false
    @State private var isShowingLoadLyricsLongPressAlert = false
    @State private var isShowingSelectAllCurseWordsLongPressAlert = false
    @State private var isShowingDeselectAllCurseWordsLongPressAlert = false
    
    @State private var isLyricsTextCopied = false
    
    @FocusState private var focusedField: FocusedField?
    
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
        NavigationStack {
            Group {
                LabeledContent("Artist") {
                    TextField("Artist", text: $artist)
                        .focused($focusedField, equals: .artist)
                        .textInputAutocapitalization(.words)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .submitLabel(.next)
                        .onSubmit {
                            focusedField = .song
                        }
                }
                .padding(.top, 10)
                LabeledContent("Song") {
                    TextField("Song", text: $song)
                        .focused($focusedField, equals: .song)
                        .textInputAutocapitalization(.words)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .submitLabel(.search)
                        .onSubmit {
                            loadLyrics()
                        }
                }
            }
            .padding(.leading, 10)
            .padding(.trailing, 10)
            Divider()
                .padding(.top, 5)
                .padding(.bottom, 5)
            HStack {
                Text("Lyrics:")
                Spacer()
                Button(action: {}
                       , label: {
                    Text(isLyricsTextCopied ? "Copied!" : "Copy Lyrics")
                })
                .simultaneousGesture(LongPressGesture(minimumDuration: 0.35).onEnded { _ in
                    isShowingCopyLyricsLongPressAlert = true
                    PetersHaptics.process.impact(.heavy)
                })
                .simultaneousGesture(TapGesture().onEnded {
                    UIPasteboard.general.string = lyricsModified
                    isLyricsTextCopied = true
                })
                .alert(isPresented: $isShowingCopyLyricsLongPressAlert) {
                    Alert(title: Text("Copy Lyrics"),
                          message: Text("Tap to copy the current lyrics to the iOS clipboard."))
                }
                .disabled(lyricsModified.isEmpty || isLyricsTextCopied)
            }
            .padding(.leading, 10)
            .padding(.trailing, 10)
            Divider()
            ScrollView {
                TextField("",
                          text: $lyricsModified,
                          axis: .vertical)
            }
            .padding(.leading, 10)
            .padding(.trailing, 10)
            .navigationTitle("Peters Lyrics")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .topBarLeading) {
                    Button(action: {}
                           , label: {
                        let image = isDarkModeOn ? "lightbulb" : "lightbulb.fill"
                        Image(systemName: image)
                            .imageScale(.large)
                    })
                    .simultaneousGesture(LongPressGesture(minimumDuration: 0.35).onEnded { _ in
                        isShowingColorSchemeLongPressAlert = true
                        PetersHaptics.process.impact(.heavy)
                    })
                    .simultaneousGesture(TapGesture().onEnded {
                        isDarkModeOn.toggle()
                    })
                    .alert(isPresented: $isShowingColorSchemeLongPressAlert) {
                        Alert(title: Text("Toggle Color Scheme"),
                              message: Text("Tap here to toggle between light and dark mode."))
                    }
                    Button(action: {}
                           , label: {
                        let image = isSiriOn ? "waveform.circle.fill" : "waveform.circle"
                        Image(systemName: image)
                            .imageScale(.large)
                    })
                    .simultaneousGesture(LongPressGesture(minimumDuration: 0.35).onEnded { _ in
                        isShowingSiriReaderLongPressAlert = true
                        PetersHaptics.process.impact(.heavy)
                    })
                    .simultaneousGesture(TapGesture().onEnded {
                        isSiriOn.toggle()
                        if isSiriOn == false
                        {
                            lyricsReader.stopReading()
                        }
                    })
                    .alert(isPresented: $isShowingSiriReaderLongPressAlert) {
                        Alert(title: Text("Toggle Siri Singing"),
                              message: Text("Tap here to toggle Siri singing the loaded lyrics on or off. Tap mid-singing to stop that song."))
                    }
                }
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button(action: {}
                           , label: {
                        Text("&@!$#")
                    })
                    .simultaneousGesture(LongPressGesture(minimumDuration: 0.35).onEnded { _ in
                        isShowingCurseWordSheetLongPressAlert = true
                        PetersHaptics.process.impact(.heavy)
                    })
                    .simultaneousGesture(TapGesture()
                        .onEnded {
                            isShowingCurseWordSheet = true
                        })
                    .alert(isPresented: $isShowingCurseWordSheetLongPressAlert) {
                        Alert(title: Text("Curse Word Options"),
                              message: Text("Tap here to select which curse words to censor."))
                    }
                    .padding(.trailing, 15)
                    .sheet(isPresented: $isShowingCurseWordSheet) {
                        CurseWordSheet(isShowingCurseWordSheet: $isShowingCurseWordSheet,
                                       isShowingCurseWordSheetLongPressAlert: $isShowingCurseWordSheet,
                                       isShowingSelectAllCurseWordsLongPressAlert: $isShowingSelectAllCurseWordsLongPressAlert,
                                       isShowingDeselectAllCurseWordsLongPressAlert: $isShowingDeselectAllCurseWordsLongPressAlert)
                    }
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button {
                        focusedField = nil
                    } label: {
                        Image(systemName: "keyboard.chevron.compact.down")
                    }
                }
            }
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
        Divider()
        Button(action: {}
               , label: {
            Image(systemName: "music.quarternote.3")
            Text("Load Lyrics")
            Image(systemName: "music.quarternote.3")
        })
        .simultaneousGesture(LongPressGesture(minimumDuration: 0.35).onEnded { _ in
            isShowingLoadLyricsLongPressAlert = true
            PetersHaptics.process.impact(.heavy)
        })
        .simultaneousGesture(TapGesture().onEnded {
            loadLyrics()
        })
        .alert(isPresented: $isShowingLoadLyricsLongPressAlert) {
            Alert(title: Text("Load Lyrics"),
                  message: Text("Tap to load the lyrics for the entered Artist - Song combination."))
        }
        .padding(.top, 10)
        .onAppear {
            UITextField.appearance().clearButtonMode = .whileEditing
        }
        .task(id: "\(isAssCensored) \(isDamnCensored) \(isFuckCensored) \(isHellCensored) \(isShitCensored)") {
            censorLyrics()
        }
        .preferredColorScheme(isDarkModeOn ? .dark : .light)
    }
    
    func censorLyrics() {
        lyricsModified = lyrics
            .replacingOccurrences(of: "\n\n", with: "\n")
            .replacingOccurrences(of: isAssCensored ? "Ass" : "+++", with: "***", options: .caseInsensitive)
            .replacingOccurrences(of: isDamnCensored ? "Damn" : "+++", with: "****", options: .caseInsensitive)
            .replacingOccurrences(of: isFuckCensored ? "Fuck" : "+++", with: "****", options: .caseInsensitive)
            .replacingOccurrences(of: isHellCensored ? "Hell" : "+++", with: "****", options: .caseInsensitive)
            .replacingOccurrences(of: isShitCensored ? "Shit" : "+++", with: "****", options: .caseInsensitive)
    }
    
    func loadLyrics() {
        Task {
            lyricsReader.stopReading()
            let artistEdit = removeSpecialCharsFromString(text: artist).replacingOccurrences(of: " ", with: "%20")
            let songEdit = removeSpecialCharsFromString(text: song).replacingOccurrences(of: " ", with: "%20")
            
            let (data, _) = try await URLSession.shared.data(from: URL(string:"https://api.lyrics.ovh/v1/\(artistEdit)/\(songEdit)")!)
            let decodedResponse = try? JSONDecoder().decode(Song.self, from: data)
            searchedArtist = artist
            searchedSong = song
            lyrics = decodedResponse?.lyrics ?? ""
            
            censorLyrics()
            if isSiriOn
            {
                lyricsReader.readLyrics(lyricsModified, withVoice: "en-US", atRate: 1.0)
            }
            isLyricsTextCopied = false
        }
    }
}

struct Song: Codable {
    let lyrics: String
}

enum FocusedField {
    case artist
    case song
}

func removeSpecialCharsFromString(text: String) -> String {
    let okayChars = Set("abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLKMNOPQRSTUVWXYZ1234567890+-=().!_")
    return text.filter {okayChars.contains($0) }
}

class PetersHaptics {
    static let process = PetersHaptics()
    
    private init() { }
    
    func impact(_ feedbackStyle: UIImpactFeedbackGenerator.FeedbackStyle) {
        UIImpactFeedbackGenerator(style: feedbackStyle).impactOccurred()
    }
    
    func notification(_ feedbackType: UINotificationFeedbackGenerator.FeedbackType) {
        UINotificationFeedbackGenerator().notificationOccurred(feedbackType)
    }
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
