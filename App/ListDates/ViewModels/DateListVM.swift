//
//  DateListViewModel.swift
//  SwiftUIShowDateList
//
//  Created by topeerz on 27/08/2024.
//

import Foundation
import Observation
import SwiftUI // for NavigationPath


@Observable
class RootRouter {
    public protocol DestinationProtocol: Codable, Hashable {
    }

    public enum DateListViewDestination: DestinationProtocol {
        case dateDetail(date: Date)
        case two
    }

    public enum DateListViewDestination2: DestinationProtocol {
        case dateDetail2
        case two2
    }

    var navPath: Binding<NavigationPath>!

    func navigate(to destination: any DestinationProtocol) {
        navPath.wrappedValue.append(destination)
    }

    func navigateBack() {
        navPath.wrappedValue.removeLast()
    }

    func navigateToRoot() {
        navPath.wrappedValue.removeLast(navPath.wrappedValue.count)
    }
}

class DateListRouter {
    public enum DateListViewDestination3: RootRouter.DestinationProtocol {
        case dateDetail
    }

    var navPath: Binding<NavigationPath>!

    init(navPath: Binding<NavigationPath>!) {
        self.navPath = navPath
    }

    // TODO: redundant with RootRouter
    func navigate(to destination: any RootRouter.DestinationProtocol) {
        navPath.wrappedValue.append(destination)
    }
}

class AppI : ObservableObject {
    var appM: AppM?
    var appR: RootRouter?

    init(appM: AppM, appR: RootRouter) {
        self.appM = appM
        self.appR = appR
    }

    init() {
    }
}

@Observable
class AppM {
    var triangleMode = false
}

@MainActor
// TODO: move to Models (renamge to Interactors?)
class DateListI {
    var appI: AppI!
    var vm: DateListVM!
    var router: DateListRouter!

    // this will be created during initialization of swift ui - hence seems it will get called in UT (including sending requests) before we actually test anything?
    var dateService: DateServiceProtocol = DateService(urlSession: URLSession.shared)

    func populateList() async {
        vm.loading = true

        // Load new or reuse cached somewhere values ...
        vm.currentDates.removeAll()
        for _ in (1...3) {
            guard let date = try? await dateService.getDate() else {
                return
            }

            vm.currentDates.append(date)

        }

        vm.loading = false
    }

    func onClick() {
        vm.clicks += 1
    }

    func onTap(at index: Int) {
//        appI.appR?.navigate(to: RootRouter.DateListViewDestination.dateDetail(date: Date.now))
        router.navigate(to: DateListRouter.DateListViewDestination3.dateDetail)
    }

    func onInit() async {
        await populateList()
    }

    func onReloadButton() async {
        await populateList()
        appI.appM?.triangleMode = true
    }

    func onNavigateButton() async {
        appI.appR?.navigate(to: RootRouter.DateListViewDestination.dateDetail(date: Date.now))
    }

    func onCancelButton() async {
        appI.appM?.triangleMode = false
    }
}

@MainActor
@Observable
class DateListVM  {
    var text = "123"
    var currentDates = [CurrnetDate]()
    var loading = false
    var clicks: Int = 0
}

class UUIDProvider {
    static var forge = { UUID() }
    class func uuid() -> UUID {
        forge()
    }
}

struct CurrnetDate: Decodable, Identifiable, Hashable {
    let date: String
    let id: UUID = UUIDProvider.uuid()

    private enum CodingKeys: String, CodingKey {
        case date
    }

    init(date: String) {
        self.date = date
    }
}
