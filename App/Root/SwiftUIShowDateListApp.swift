//
//  SwiftUIShowDateListApp.swift
//  SwiftUIShowDateList
//
//  Created by topeerz on 21/08/2024.
//

import Observation
import SwiftUI

@main
struct Launcher {
    static func main() throws {
        if NSClassFromString("XCTestCase") == nil { // this seems to work now event for Testing framework and UI testing
            SwiftUIShowDateListApp.main()

        } else {
            TestApp.main()
        }
    }
}

struct TestApp: App {
    var body: some Scene {
        WindowGroup {
            Text("This is test ...")
        }
    }
}

struct SwiftUIShowDateListApp: App {
    @State private var navPath = NavigationPath()
    @State private var appR: RootRouter = RootRouter()
    @State private var appM: AppM = AppM()
    private var appI: AppI!

    init() {
        self.appI = AppI(appM: self.appM, appR: self.appR)
    }

    var body: some Scene {
        let _ = appR.navPath = $navPath
        WindowGroup {
            // Gotha! nesting NavigationStacks seems to be bad idea: https://stackoverflow.com/questions/76301602/dealing-with-nested-navigationstacks-in-swiftui
            NavigationStack(path: appR.navPath) {
                DebugView()
                // TODO: why is this getting called when app is _leaving_ RootView?
                // This seems to be triggered even for dummy views which has not been changed ...
                // The issue realted to lack of releasing some instances of @State objects seems to be also present in simple view.
                // The problem seems to be caused by init called on View which we are leaving. It seems to be caused by notification which is coming due to
                // modification of NavigaitonPath when it is wrapped inside some class (like router). This problem doesn't seem to exist when navpath is created
                // on top level (in app) and router just hold binding to it.
                DateListView(appM: appM, appI: appI)
                .navigationDestination(for: RootRouter.DateListViewDestination.self) { destination in
                    switch(destination) {
                        case .dateDetail:
                            DateDetailView()

                        case .two:
                            OtherView()
                    }
                }
            }
            .environmentObject(appI)  // so it can be later used in subviews if needed?
            .environment(appM)  // so it can be later used in subviews if needed?
            .environment(appR)
        }
    }
}

#Preview {
    @Previewable @State var navPath = NavigationPath()
    @Previewable @State var appR: RootRouter = RootRouter()
    @Previewable @State var appM: AppM = AppM()
    let appI = AppI(appM: appM, appR: appR)
    let _ = appR.navPath = $navPath

    NavigationStack(path: appR.navPath) {
        DateListView(appM: appM, appI: appI)
        .navigationDestination(for: RootRouter.DateListViewDestination.self) { destination in
            switch(destination) {
                case .dateDetail:
                    DateDetailView()

                case .two:
                    OtherView()
            }
        }
        .environmentObject(appI)
        .environment(appM)
    }
}
