//
//  ContentView.swift
//  SwiftUIShowDateList
//
//  Created by topeerz on 21/08/2024.
//

import Observation
import SwiftUI

@Observable
class DummyWhatever {
    var test1 = false
}

struct DebugView: View {
    @EnvironmentObject var appI: AppI
    @State private var dummy = DummyWhatever()

    var body: some View {
        let _ = Self._printChanges()
        Text("DebugView")
        Button("go to detail") {
            appI.appR?.navigate(to: RootRouter.DateListViewDestination.dateDetail(date: Date.now))
        }
    }
}


struct DateListView: View {
    @State private var appM: AppM
    private let appI: AppI

    // TODO: vm doesn't work after screen reload by swiftUI. Seems VM are re-created but old ones are used by bindings?
    // How does it work and if I actually want screen to be "rested" or not? I think model should be preserved in this case (I am but treutrning to screen) so if I want clean state I should manually reset model (and hence view model).
    // It would seem that even when using observation framework @State (or it's properties) must _NOT_ be modifiled outside of swiftui.
    @State private var vm: DateListVM = DateListVM()
    @State private var clicks = 0
    @State private var vi: DateListI = DateListI()

    init(appM: AppM, appI: AppI) {
        self.appM = appM
        self.appI = appI

        // GOTHA!: accessing @StateObject in init will cause creation of new vm each time (`Accessing StateObject's object without being installed on a View. This will create a new instance each time.`). Using @ObservedObject or @State doesn't cause this issue howeveer when @State is used for model (and Observation framework is in use) updating model properties outside of swiftui (like in interactor) won't take effect. (because new interactor + model are created here, but old ones are used in swiftui hierarchy).
        // In other words: we must use ObservedObject for vm - even though it will trigger updates on any property change if should be ok as this is VM ... This though means we are back to resource releasing problems when it comes to VM.
        // OR we must use something with @State so swiftui manage lifecycle for us. So either we need to have all in model or we have @State interactor - even though it has no states ...

        // GOTHA!: can't initialize @State in init. It just fails silently (no warnings) - this is beacuse @State is just reference to storage maintained by swiftui
        vi.appI = appI
        vi.vm = vm
    }

    // TODO: what about SwiftData?
    // TODO: try profiling this in instruments
    var body: some View {
        let _ = Self._printChanges()
        Button("clock counter: \(vm.clicks)") {
            vi.onClick()
        }
        List(vm.currentDates.enumerated().map { $0 }, id: \.1) { index, date in
            // Note: without direct usage of naviagation link I am not getting > for free ... May want to use navigation path only for feature-level stuff.
            // Also, using NavigationLink doesn't alter navPath.count at all.
            Text("\(index + 1) \(date.date)")
                .onTapGesture {
                    vi.onTap(at: index)
                }
            // TODO: consider where to use path-navigation and where link-navigation. It seems that path-navigation should be use only where deep linking in needed?
            //            NavigationLink {
            //                SubView()
            //            } label: {
            //                Text("\(index + 1) \(date.date)")
            //            }
        }
        .listStyle(.plain)
        .navigationTitle("My List")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    Task {
                        await vi.onNavigateButton()
                    }
                }, label: {
                    Image(systemName: "arrow.clockwise.square")
                })
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    Task {
                        await vi.onReloadButton()
                    }
                }, label: {
                    Image(systemName: "arrow.clockwise.circle")
                })
            }
        }
        .task {
            await vi.onInit()
        }
        .alert("!!!", isPresented: $vm.loading) {
            Button("Cancel", role: .cancel) {
                Task {
                    await vi.onCancelButton()
                }
            }
        } message: {
            // TODO: add some animation ...
            Text("loading...")
        }
        // TODO: it is possible to put navigatipon destinationDestination here
        // however it will prevent enclosing navigationDestination from being callled (for the same destination type). Hence this can be used for local routers.
        .navigationDestination(for: RootRouter.DateListViewDestination2.self) { destination in
                OtherView()
        }
    }
}

struct SubView: View {
    @Environment(AppM.self) var appM

    var body: some View {
        HStack {
            Text("subView")
            Image(systemName: appM.triangleMode ? "triangle" : "figure.hiking")
        }
    }
}

struct OtherView: View {
    @Environment(AppM.self) var appM
    @EnvironmentObject var appI: AppI

    var body: some View {
        Text("OtherView")
        Image(systemName: "figure.mind.and.body")

        Button("go to detail") {
            appI.appR?.navigate(to: RootRouter.DateListViewDestination.dateDetail(date:Date.now))
        }
    }
}

#Preview {
    @Previewable @State var appM = AppM()
    @Previewable @State var appR = RootRouter()
    let appI = AppI(appM: appM, appR: appR)
//    NavigationStack {
        DateListView(appM: appM, appI: appI)
            .environmentObject(appI)  // so it can be later used in subviews if needed?
            .environment(appM)  // so it can be later used in subviews if needed?
//    }
}
