//
//  File.swift
//  Watch Ios App Watch App
//
//  Created by Apps we love on 15/12/23.
//

import Foundation
import Combine
import SwiftUI

let frequencyArr = [2.0, 5.0, 10.0,25.0,50.0]

let extensionsArr = ["usgovcloudapi", "windows"]

let updateFrequencyUserDefaultsKey = "updateFrequency"

let frequencyIndexUserDefaultsKey = "selectedFrequencyIndex"

let updateExtensionUserDefaultsKey = "updateExtension"

let extensionIndexUserDefaultKey = "selectedExtensionIndex"

let storageAccountNameDefaultsKey = "savedStorageAccountName"

let fileShareNameDefaultsKey = "savedFileShareName"

let sasTokenDefaultsKey = "savedSASToken"

let storageAccountNamesArrayDefaultsKey = "storageAccountNamesArray"

let fileShareNamesArrayDefaultsKey = "fileShareNamesArray"

let sasTokenOldDefaultsKey = "savedOldSASToken"

var locationManager = LocationManager()

let networkMonitor = NetworkMonitor()

var deviceBatteryPercentage = 0.0

var networkType = "WIFI"

let currDeviceID = CommonClass.getDeviceID()

let phoneNumberMissingTitle = "Phone Number Missing!"

let phoneNumberMissingMessage = "Please set the instructor's phone number in settings."

let activateBtnMessage = "Long press to activate Button"

var userDirections = ""

var lastTelemetryData: DeviceTelemetry?

var isSettingsScreen = false

var isAdvanceSettingScreen = false

var isAzureCredentialsPresent = Bool()

var sasTokenNew: String = ""

var sasTokenOld: String = ""

var storageAccountNamesArr: [String] = []

var fileShareNamesArr: [String] = []

var isSasTokenRefreshBtbTapped = false

var isStorageAndFileNameRefreshBtnTapped = false
