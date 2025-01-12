//
//  CurseWordSheet.swift
//  LyricsSearch
//
//  Created by Michael Peters on 1/11/25.
//

import SwiftUI

struct CurseWordSheet: View {
    
    @Binding var isShowingCurseWordSheet: Bool
    @Binding var isShowingCurseWordSheetLongPressAlert: Bool
    @Binding var isShowingSelectAllCurseWordsLongPressAlert: Bool
    @Binding var isShowingDeselectAllCurseWordsLongPressAlert: Bool
    
    @AppStorage("isDarkModeOn") var isDarkModeOn = false
    @AppStorage("isAssCensored") var isAssCensored = false
    @AppStorage("isDamnCensored") var isDamnCensored = false
    @AppStorage("isFuckCensored") var isFuckCensored = false
    @AppStorage("isHellCensored") var isHellCensored = false
    @AppStorage("isShitCensored") var isShitCensored = false
    
    @State private var totalCurseWords = 5.0

    var body: some View {
        
        var assCount: Double {
            isAssCensored == true ? 1 : 0
        }
        var damnCount: Double {
            isDamnCensored == true ? 1 : 0
        }
        var fuckCount: Double {
            isFuckCensored == true ? 1 : 0
        }
        var hellCount: Double {
            isHellCensored == true ? 1 : 0
        }
        var shitCount: Double {
            isShitCensored == true ? 1 : 0
        }
            
        var censoredCurseWords: Double {
            assCount + damnCount + fuckCount + hellCount + shitCount
        }
        
        var censoredCurseWordsPercentage: Double {
            (censoredCurseWords / totalCurseWords) == 0 ? 0.0 : (censoredCurseWords / totalCurseWords)
        }
        
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
                    Button(action: {}
                           , label: {
                        Text("Select All")
                    })
                    .simultaneousGesture(LongPressGesture(minimumDuration: 0.35).onEnded { _ in
                        isShowingSelectAllCurseWordsLongPressAlert = true
                        PetersHaptics.process.impact(.heavy)
                    })
                    .simultaneousGesture(TapGesture().onEnded {
                        isAssCensored = true
                        isDamnCensored = true
                        isFuckCensored = true
                        isHellCensored = true
                        isShitCensored = true
                    })
                    .alert(isPresented: $isShowingSelectAllCurseWordsLongPressAlert) {
                        Alert(title: Text("Select All Curse Words"),
                              message: Text("Tap to Select all curse words selected below."))
                    }
                    Divider()
                    Button(action: {}
                           , label: {
                        Text("Deselect All")
                    })
                    .simultaneousGesture(LongPressGesture(minimumDuration: 0.35).onEnded { _ in
                        isShowingDeselectAllCurseWordsLongPressAlert = true
                        PetersHaptics.process.impact(.heavy)
                    })
                    .simultaneousGesture(TapGesture().onEnded {
                        isAssCensored = false
                        isDamnCensored = false
                        isFuckCensored = false
                        isHellCensored = false
                        isShitCensored = false
                    })
                    .alert(isPresented: $isShowingDeselectAllCurseWordsLongPressAlert) {
                        Alert(title: Text("Deselect All Curse Words"),
                              message: Text("Tap to deselect all curse words selected below."))
                    }
                }
                Toggle("Ass", isOn: $isAssCensored)
                    .toggleStyle(SwitchToggleStyle(tint: Color.blue))
                Toggle("Damn", isOn: $isDamnCensored)
                    .toggleStyle(SwitchToggleStyle(tint: Color.blue))
                Toggle("Fuck", isOn: $isFuckCensored)
                    .toggleStyle(SwitchToggleStyle(tint: Color.blue))
                Toggle("Hell", isOn: $isHellCensored)
                    .toggleStyle(SwitchToggleStyle(tint: Color.blue))
                Toggle("Shit", isOn: $isShitCensored)
                    .toggleStyle(SwitchToggleStyle(tint: Color.blue))
            }
            Gauge(value: censoredCurseWords, in: 0...totalCurseWords) {
                Text("Censored Curse Word Percentage")
            } currentValueLabel: {
                Text((censoredCurseWordsPercentage).formatted(
                    .percent.precision(.fractionLength(2)))
                )
            } minimumValueLabel: {
                Text("\(0)")
            } maximumValueLabel: {
                Text("\(totalCurseWords.formatted(.number))")
            }
            HStack {
                Spacer()
                Gauge(value: censoredCurseWords, in: 0...totalCurseWords) {
                    Text("Censored Curse Word Percentage")
                } currentValueLabel: {
                    Text((censoredCurseWordsPercentage).formatted(
                        .percent.precision(.fractionLength(2)))
                    )
                } minimumValueLabel: {
                    Text("\(0)")
                } maximumValueLabel: {
                    Text("\(totalCurseWords.formatted(.number))")
                }
                .tint(.blue)
                .gaugeStyle(.accessoryCircularCapacity)
                Spacer()
            }
            
            Section("Lyrics provided by:") {
                Link("https://lyricsovh.docs.apiary.io",
                     destination: URL(string: "https://lyricsovh.docs.apiary.io/#reference/0/lyrics-of-a-song/search")!)
            }
        }
        .preferredColorScheme(isDarkModeOn ? .dark : .light)
    }
}

#Preview {
    @Previewable @State var isShowingCurseWordSheet = false
    @Previewable @State var isShowingCurseWordSheetLongPressAlert = false
    @Previewable @State var isShowingSelectAllCurseWordsLongPressAlert = false
    @Previewable @State var isShowingDeselectAllCurseWordsLongPressAlert = false
    
    CurseWordSheet(isShowingCurseWordSheet: $isShowingCurseWordSheet,
                   isShowingCurseWordSheetLongPressAlert: $isShowingCurseWordSheetLongPressAlert,
                   isShowingSelectAllCurseWordsLongPressAlert: $isShowingSelectAllCurseWordsLongPressAlert,
                   isShowingDeselectAllCurseWordsLongPressAlert: $isShowingDeselectAllCurseWordsLongPressAlert)
}
