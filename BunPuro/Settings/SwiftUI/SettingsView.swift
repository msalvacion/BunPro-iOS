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
            Section(footer: Text("settings.review.bunnymode.explaination")) {
                PickerCell(
                    "settings.review.furigana",
                    selection: $settingsController.selectedFuriganaOption,
                    options: settingsController.furiganaOptions
                )

                Toggle(isOn: $settingsController.isEnglishHidden) {
                    Text("settings.review.hideenglish")
                }.foregroundColor(.accentColor)

                Toggle(isOn: $settingsController.isBunnyModeOn) {
                    Text("settings.review.bunnymode")
                }.foregroundColor(.accentColor)
            }

            Section {
                Button("settings.informstion.about") {
                    self.displayedCategory = .about
                }
                Button("settings.informstion.privacy") {
                    self.displayedCategory = .privacy
                }
                Button("settings.informstion.terms") {
                    self.displayedCategory = .terms
                }
                Button("settings.informstion.contact") {
                }
                Button("settings.informstion.community") {
                    guard let url = URL(string: "https://community.bunpro.jp/") else { return }

                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }.foregroundColor(.accentColor)

            Section(footer: Text("")) {
                PickerCell(
                    "settings.other.appearance",
                    selection: $settingsController.selectedAppearanceOption,
                    options: settingsController.appearanceOptions
                )
            }

            Section {
                Button("settings.actions.logout") {
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
    }

    init(_ label: LocalizedStringKey, selection: Binding<Int>, options: [LocalizedStringKey]) {
        self.label = label
        self.selection = selection
        self.options = options
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(settingsController: SettingsController(presentingViewController: UIViewController()))
    }
}
