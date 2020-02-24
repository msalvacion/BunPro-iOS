//
//  Created by Andreas Braun on 24.02.20.
//  Copyright © 2020 Andreas Braun. All rights reserved.
//

import SwiftUI

struct InformationView: UIViewControllerRepresentable {
    typealias UIViewControllerType = InformationTableViewController
    typealias Category = InformationTableViewController.Category

    @State var category: Category

    func makeUIViewController(context: Context) -> InformationTableViewController {
        StoryboardScene.Main.informationTableViewController.instantiate()
    }

    func updateUIViewController(_ uiViewController: InformationTableViewController, context: Context) {
        uiViewController.category = category
    }
}

struct InformationView_Previews: PreviewProvider {
    static var previews: some View {
        InformationView(category: .about)
    }
}
