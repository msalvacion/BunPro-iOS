//
//  Created by Andreas Braun on 20.02.20.
//  Copyright © 2020 Andreas Braun. All rights reserved.
//

import BunProKit
import Combine
import SwiftUI

struct SettingsView: View {
    @ObservedObject var settingsController: SettingsController

    @State private var showSheet: Bool = false
    @State private var displayedCategory: InformationView.Category? {
        didSet { showSheet = displayedCategory != nil }
    }

    var body: some View {
        Form {
            Section(footer: Text("When Bunny Mode is active, you'll advance to the next review without further confirmation if your answer was correct.")) {
                PickerCell(
                    "settings.review.furigana",
                    selection: $settingsController.selectedFuriganaOption,
                    options: settingsController.furiganaOptions
                )
//                Picker(selection: $settingsController.selectedFuriganaOption, label: Text("settings.review.furigana").foregroundColor(.accentColor)) {
//                    ForEach(settingsController.furiganaOptions) { key in
//                        Text(key)
//                    }
//                }

                Toggle(isOn: $settingsController.isEnglishHidden) {
                    Text("Hide English")
                }.foregroundColor(.accentColor)

                Toggle(isOn: $settingsController.isBunnyModeOn) {
                    Text("Bunny Mode")
                }.foregroundColor(.accentColor)
            }

            Section {
                Button("About") {
                    self.displayedCategory = .about
                }
                Button("Privacy") {
                    self.displayedCategory = .privacy
                }
                Button("Terms and Conditions") {
                    self.displayedCategory = .terms
                }
                Button("Contact") {
                }
                Button("Community") {
                    guard let url = URL(string: "https://community.bunpro.jp/") else { return }

                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }.foregroundColor(.accentColor)

            Section(footer: Text("")) {
                Picker(selection: $settingsController.selectedAppearanceOption, label: Text("Appearance").foregroundColor(.accentColor)) {
                    ForEach(0 ..< SettingsController.appearanceOptions.count) {
                        Text(SettingsController.appearanceOptions[$0])
                            .tag($0)
                    }
                }
            }

            Section {
                Button("Logout") {
                    Server.logout()
                }.foregroundColor(.red)
            }
        }
        .navigationBarTitle("tabbar.settings")
        .sheet(isPresented: $showSheet) {
            NavigationView {
                InformationView(category: self.displayedCategory ?? .about)
                    .edgesIgnoringSafeArea([.top, .bottom])
                    .navigationBarTitle(self.displayedCategory?.title ?? "")
                    .navigationBarItems(
                        trailing: Button(
                            action: {
                                self.displayedCategory = nil
                            }, label: {
                                Text("Close")
                            }
                    )
                )
            }.navigationViewStyle(StackNavigationViewStyle())
        }
    }
}

struct PickerCell: View {
    private var selection: Binding<Int>
    private let label: LocalizedStringKey
    private var options: [LocalizedStringKey]

    @State private var showSheet: Bool = false

    var body: some View {
        HStack {
            Button(label) {
                self.showSheet.toggle()
            }
            Spacer()
            Text(options[selection.wrappedValue])
                .foregroundColor(.secondary)
        }
        .actionSheet(isPresented: $showSheet) {
            ActionSheet(
                title: Text(label),
                buttons: self.options.enumerated().compactMap { index, option in
                    ActionSheet.Button.default(Text(option)) {
                        self.selection.wrappedValue = index
                    }
                } + [.cancel()]
            )
        }
//        Picker(selection: selection, label: Text(label).foregroundColor(.accentColor)) {
//            ForEach(options) { key in
//                Text(key)
//            }
//        }
    }

    init(_ label: LocalizedStringKey, selection: Binding<Int>, options: [LocalizedStringKey]) {
        self.label = label
        self.selection = selection
        self.options = options
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(settingsController: SettingsController())
    }
}

/*
 var url: URL? {
     switch self {
     case .community:
         return URL(string: "https://community.bunpro.jp/")

     case .about:
         return nil // URL(string: "https://bunpro.jp/about")

     case .contact:
         return URL(string: "https://bunpro.jp/contact")

     case .privacy:
         return nil // URL(string: "https://bunpro.jp/privacy")

     case .terms:
         return nil // URL(string: "https://bunpro.jp/terms")
     }
 }
 */
