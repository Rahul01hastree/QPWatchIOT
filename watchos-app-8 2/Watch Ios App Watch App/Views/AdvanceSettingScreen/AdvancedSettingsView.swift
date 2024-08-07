//
//  AdvancedSettingsView.swift
//  QP HT Applicationn
//
//  Created by Apps we love on 13/03/24.
//

import SwiftUI

struct AdvancedSettingsView: View {
    @State private var sasTokenText: String = "SAS Token"
    @State private var extensions: Int = 0
    @State private var currentDeviceIndex: Int = 0
    @State private var updateExtenion: String = ""
    @State private var selectedFileShareName: String = "Select Device SAS"
    @State private var selectedStorageAccountName: String = "Select Device"
    @State private var isStorageAccountNameDropdown = false
    @State private var isFileShareNamesDropdown = false
    @State private var rotationDegreesForSASToken = 0.0
    @State private var rotationDegreesForFolderNames = 0.0
    @State private var storageAccountNamesLocalArr: [String] = storageAccountNamesArr
    @State private var fileShareNamesLocalArr: [String] = fileShareNamesArr
    
    @State private var iotHubDeviceIDs = [String]()
    @State private var iotDeviceSASTokens = [String]()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading){
                
                VStack(alignment: .leading, spacing: 5) {
                    RadioButtonGroup(selectedIndex: $currentDeviceIndex, options: ["IoTHub", "Cloud Storage"])
                }.onChange(of: currentDeviceIndex){
                    selectedDeviceToSendData(from: currentDeviceIndex)
                }
                .padding(.leading, 10.0)
                
            }
            .frame(width: 180, alignment: .leading)
            .padding()
            
            Divider()
            
            VStack(alignment: .trailing) {
                Image(systemName: "arrow.clockwise.circle")
                    .resizable()
                    .scaledToFit()
                    .tint(.black)
                    .frame(width: 25, height: 25)
                    .foregroundColor(.blue)
                    .background(Color.clear)
                    .clipShape(Circle())
                    .rotationEffect(.degrees(rotationDegreesForFolderNames))
                    .onTapGesture {
                        
                        isStorageAndFileNameRefreshBtnTapped = true
                        FirebaseDatabaseHelper().fetchDataFromFirebase()
                       
                        let data = CommonClass().retrieveFromUserDefaults()
                        if let ioTHubDevices = data?["IoTHubDevices"] as? [String: String] {
                            print(ioTHubDevices)
                            iotHubDeviceIDs.removeAll()
                            for (_, value) in ioTHubDevices {
                                self.iotHubDeviceIDs.append(value)
                              }
                        }else{
                            print("error in : ioTHubDevices ")
                        }
                        if let deviceSAS = data?["IotHubSASToken"] as? [String: String] {
                            self.iotDeviceSASTokens.removeAll()
                            print(deviceSAS)
                            for(key,_ ) in deviceSAS {
                                self.iotDeviceSASTokens.append(key)
                            }
                        }else{
                            print("error in : IotHubSASToken ")
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            storageAccountNamesLocalArr = storageAccountNamesArr
                            fileShareNamesLocalArr = fileShareNamesArr
                            
                        }
                        withAnimation(.easeInOut(duration: 1)) {
                            self.rotationDegreesForFolderNames += 360
                        }
                    }
            }
            .padding(.leading, 145.0)
            
            VStack(alignment: .leading) {
                // Planet Dropdown
                
                Button(action: {
                    withAnimation {
                        self.isStorageAccountNameDropdown.toggle()
                    }
                }) {
                    HStack {
                      
                        Text(selectedStorageAccountName)
                            .foregroundColor(selectedStorageAccountName == nil ? .gray : .white)
                            .font(.system(size: 14))
                            .lineLimit(1)
                        Spacer()
                        Image(systemName: "chevron.down.circle")
                            .rotationEffect(.degrees(isStorageAccountNameDropdown ? 180 : 0))
                            .foregroundColor(.blue)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.black)
                    .cornerRadius(15)
                }
                .overlay(
                    storageAccountNamesDropdownView,
                    alignment: .top
                )
            
                // Conditional spacing to prevent overlap
                if isStorageAccountNameDropdown {
                    Spacer(minLength: calculateDropdownHeight(for: storageAccountNamesArr.count) <= 50 ? 30 : calculateDropdownHeight(for: storageAccountNamesArr.count) )
                }
                Spacer(minLength: 10)
                
                Button(action: {
                    withAnimation {
                        self.isFileShareNamesDropdown.toggle()
                    }
                }) {
                    HStack {
                        Text(selectedFileShareName)
                            .foregroundColor(selectedFileShareName == nil ? .gray : .white)
                            .font(.system(size: 14))
                            .lineLimit(1)
                        Spacer()
                        Image(systemName: "chevron.down.circle")
                            .rotationEffect(.degrees(isFileShareNamesDropdown ? 180 : 0))
                            .foregroundColor(.blue)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.black)
                    .cornerRadius(15)
                    
                }
                .overlay(
                    fileShareNamesDropdownView,
                    alignment: .top
                )
            }
            .padding([.leading, .trailing], 5)
            if isFileShareNamesDropdown {
                Spacer(minLength: calculateDropdownHeight(for: fileShareNamesArr.count) <= 50 ?  30 : calculateDropdownHeight(for: fileShareNamesArr.count) )
            }else{
                Spacer(minLength: 10)
            }
            if currentDeviceIndex == 1 {
            Divider()
            
            VStack(alignment: .leading) {
                
                HStack{
                    Text(sasTokenText)
                        .font(.system(size: 14))
                        .lineLimit(1)
                        .padding(.leading, 10)
                    Spacer()
                    Image(systemName: "arrow.clockwise.circle")
                        .resizable()
                        .scaledToFit()
                        .tint(.black)
                        .frame(width: 20, height: 20)
                        .foregroundColor(.blue)
                        .background(Color.clear)
                        .clipShape(Circle())
                        .rotationEffect(.degrees(rotationDegreesForSASToken))
                        .onTapGesture {
                            isSasTokenRefreshBtbTapped = true
                            let firebaseDatabaseHelper = FirebaseDatabaseHelper()
                            firebaseDatabaseHelper.fetchDataFromFirebase()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                if sasTokenNew != "" {
                                    self.sasTokenText = sasTokenNew
                                    
                                }
                            }
                            withAnimation(.easeInOut(duration: 1)) {
                                self.rotationDegreesForSASToken += 360
                            }
                        }
                }.padding(.trailing, 10)
            }
            .padding()
            
            Spacer(minLength: 10)
            
            
                Divider()
                VStack(alignment: .leading){
                Text("Cloud")
                    .font(.system(size: 16))
                    .padding(.leading, 10)
                
                VStack(alignment: .leading, spacing: 5) {
                    RadioButtonGroup(selectedIndex: $extensions, options: ["Government", "Commercial"])
                }.onChange(of: extensions){
                    setExtension(extensionIndex: extensions)
                }
                .padding(.leading, 10.0)
                
            }
                .frame(width: 180, alignment: .leading)
                .padding()
        }
           
        }
        .onAppear() {
            
            let data = CommonClass().retrieveFromUserDefaults()
            if let ioTHubDevices = data?["IoTHubDevices"] as? [String: String] {
                iotHubDeviceIDs.removeAll()
                print(ioTHubDevices)
                for (_, value) in ioTHubDevices {
                    self.iotHubDeviceIDs.append(value)
                }
                print(iotHubDeviceIDs)
            }else{
                print("error in : ioTHubDevices ")
            }
            
            if let deviceSAS = data?["IotHubSASToken"] as? [String: String] {
                self.iotDeviceSASTokens.removeAll()
                print(deviceSAS)
                for(key,_) in deviceSAS {
                    self.iotDeviceSASTokens.append(key)
                }
            }else{
                print("error in : IotHubSASToken ")
            }
            
            if let savedSelectedStorageAccountName = UserDefaults.standard.string(forKey: storageAccountNameDefaultsKey) {
                selectedStorageAccountName = savedSelectedStorageAccountName
            }
            if let savedSelectedFileShareName = UserDefaults.standard.string(forKey: fileShareNameDefaultsKey) {
                selectedFileShareName = savedSelectedFileShareName
            }
            if let savedSASTokenText = UserDefaults.standard.string(forKey: sasTokenDefaultsKey) {
                sasTokenText = savedSASTokenText
            }
            
            if let storedExtensions = UserDefaults.standard.object(forKey: extensionIndexUserDefaultKey) as? Int {
                extensions = storedExtensions
            }
        }
        .onDisappear() {
            if selectedStorageAccountName != "Select Storage Account Name" {
                UserDefaults.standard.set(selectedStorageAccountName, forKey: storageAccountNameDefaultsKey)
            }
            if selectedFileShareName != "Select File Share Name" {
                UserDefaults.standard.set(selectedFileShareName, forKey: fileShareNameDefaultsKey)
            }
            if sasTokenText != "SAS Token"{
                UserDefaults.standard.set(sasTokenText, forKey: sasTokenDefaultsKey)
            }
            UserDefaults.standard.set(extensions, forKey: extensionIndexUserDefaultKey)
        }

    }
        
    // MARK: this fucntion is for storageAccountNames list
    private var storageAccountNamesDropdownView: some View {
        Group {
            if isStorageAccountNameDropdown {
                VStack(alignment: .leading) {
                    List {
                        if storageAccountNamesLocalArr.isEmpty {
                            Text("No Option")
                                .foregroundColor(.black)
                                .font(.system(size: 14))
                                .padding()
                        } else {
                            let requiredArray = currentDeviceIndex == 0 ? iotHubDeviceIDs : storageAccountNamesLocalArr
                                ForEach(requiredArray, id: \.self) { storageAccountName in
                                    Button(action: {
                                        withAnimation {
                                            if currentDeviceIndex == 0 {
                                                UserDefaults.standard.set(storageAccountName, forKey: "currentSelectedDeviceID")
                                            }

                                            self.selectedStorageAccountName = storageAccountName
                                            self.isStorageAccountNameDropdown = false
                                        }
                                    }) {
                                        Text(storageAccountName.capitalized)
                                            .foregroundColor(self.selectedStorageAccountName == storageAccountName ? .blue : .black)
                                            .font(.system(size: 14))
                                            .padding()
                                    }
                                }
                        }
                    }
                    .frame(width: 120, height: calculateDropdownHeight(for: storageAccountNamesLocalArr.count))
                    .background(Color.white)
                    .cornerRadius(5)
                    .shadow(radius: 5)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
    }


    // MARK: this fucntion is for storageAccountNames list
    private var fileShareNamesDropdownView: some View {
        Group {
            if isFileShareNamesDropdown {
                VStack(alignment: .leading) {
                    List {
                        var requiredArray = currentDeviceIndex == 0 ? iotDeviceSASTokens : fileShareNamesArr
                        if requiredArray.isEmpty {
                            Text("No Option")
                                .foregroundColor(.black)
                                .font(.system(size: 14))
                                .padding()
                        } else {
                            ForEach(requiredArray, id: \.self) { fileShareName in
                                Button(action: {
                                    withAnimation {
                                        
                                        if currentDeviceIndex == 0 {
                                            setSASTokenFrom(deviceID: fileShareName)
                                        }else{
                                            self.selectedFileShareName = fileShareName

                                        }
                                        self.isFileShareNamesDropdown = false
                                    }
                                }) {
                                    Text(fileShareName.capitalized)
                                        .foregroundColor(self.selectedFileShareName == fileShareName ? .blue : .black)
                                        .font(.system(size: 14))
                                        .padding()
                                }
                            }
                        }
                    }
                    .frame(width: 120, height: calculateDropdownHeight(for: fileShareNamesArr.count))
                    .background(Color.white)
                    .cornerRadius(5)
                    .shadow(radius: 5)
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
        }
    }

    
    private func setSASTokenFrom(deviceID: String){
        
        let data = CommonClass().retrieveFromUserDefaults()
        if let deviceSAS = data?["IotHubSASToken"] as? [String: String] {
            for(key,value) in deviceSAS {
                if deviceID == key {
                    self.selectedFileShareName = value
                    UserDefaults.standard.set(value, forKey: "currentSelectedSAS")

                }
            }
        }else{
            print("error in : IotHubSASToken ")
        }
    }
    
    
    func setExtension(extensionIndex: Int) {
        guard extensionIndex >= 0 && extensionIndex < extensionsArr.count else {
            return
        }

        extensions = extensionIndex
        UserDefaults.standard.set(extensions, forKey: extensionIndexUserDefaultKey)
        updateExtenion = extensionsArr[extensions]
        UserDefaults.standard.set(updateExtenion, forKey: updateExtensionUserDefaultsKey)
    }
    
    
    private func selectedDeviceToSendData(from currentDeviceIndex : Int){
        print(currentDeviceIndex)
        
        selectedFileShareName = currentDeviceIndex == 0 ? "Select Device SAS" : "Select File Share Name"
        selectedStorageAccountName = currentDeviceIndex == 0 ? "Select Device" : "Select Storage Account Name"
        UserDefaults.standard.set(currentDeviceIndex, forKey: "currentDeviceIndex")
    }
    
    
    private func calculateDropdownHeight(for itemCount: Int) -> CGFloat {
        let elementHeight: CGFloat = 50
        let calculatedHeight = CGFloat(itemCount) * elementHeight
        let minHeight: CGFloat = 50
        let maxHeight: CGFloat = 150
        return max(minHeight, min(calculatedHeight, maxHeight))
    }
}


#Preview {
    AdvancedSettingsView()
}


//.onAppear(){
//            if let savedStorageAccountName = UserDefaults.standard.string(forKey: storageAccountNameDefaultsKey) {
//                storageAccountName = savedStorageAccountName
//            }
//            if let savedFileShareName = UserDefaults.standard.string(forKey: fileShareNameDefaultsKey) {
//                fileShareName = savedFileShareName
//            }
//            if let savedSASToken = UserDefaults.standard.string(forKey: sasTokenDefaultsKey) {
//                sasToken = savedSASToken
//            }
//
//            if let storedExtensionIndex = UserDefaults.standard.object(forKey: extensionIndexUserDefaultKey) as? Int {
//                extensions = storedExtensionIndex
//            }
//        }
//        .onDisappear(){
//            let savedStorageAccountName = UserDefaults.standard.string(forKey: storageAccountNameDefaultsKey) ?? ""
//            let savedFileShareName = UserDefaults.standard.string(forKey: fileShareNameDefaultsKey) ?? ""
//            let savedSASToken = UserDefaults.standard.string(forKey: sasTokenDefaultsKey) ?? ""
//            let storedExtensionIndex = UserDefaults.standard.object(forKey: extensionIndexUserDefaultKey) as? Int ?? 0
//
//            if savedStorageAccountName.isEmpty && savedFileShareName.isEmpty && savedSASToken.isEmpty && (storedExtensionIndex == 0 || storedExtensionIndex == 1) {
//                isAzureCredentialsPresent = false
//            } else {
//                isAzureCredentialsPresent = true
//            }
//        }
