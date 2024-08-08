import SwiftUI

struct SettingsView: View {
    @State private var showPinEnterForAdvancedSettings = false
    @State private var navigateToAdvancedSettingsAfterPin = false

    @State private var phoneNumber: String = ""
    @State private var frequency: Int = 0
    @State private var isValidPhoneNumber = false
    @State private var showError = false
    @State private var updateFrequency: Double = 0.0
    
    
    var body: some View {
       
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Phone Number")
                    .font(.system(size: 16))
                    .multilineTextAlignment(.leading)
                
                HStack {
                    Text("+1")
                        .font(.headline)
                        .padding(.trailing, 8)
                    
                    TextField("Phone Number", text: $phoneNumber)
                        .frame(height: 2)
                        .textContentType(.telephoneNumber)
                        .font(.system(size: 16))
                        .lineLimit(1)
                }
                .padding(.vertical, 10)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.clear, lineWidth: 1)
                )
                
                if showError {
                    Text("Please enter a valid phone number")
                        .foregroundColor(.red)
                        .font(.system(size: 12))
                }
                
                Divider()
                
                Text("Frequency")
                    .font(.system(size: 16))
                
                VStack(alignment: .leading, spacing: 10) {
                    RadioButtonGroup(selectedIndex: $frequency, options: ["2 meter", "5 meter", "10 meter", "25 meter", "50 meter"])
                }.onChange(of: frequency){
                    setFrequency(frequencyIndex: frequency)
                }
                
                Divider()
                
                Button("Advanced Settings") {
                    showPinEnterForAdvancedSettings = true
                    isAdvanceSettingScreen = true
                }
                .sheet(isPresented: $showPinEnterForAdvancedSettings) {
                    PinProtectionView(isPinCorrect: $navigateToAdvancedSettingsAfterPin)
                }

                NavigationLink(destination: AdvancedSettingsView(), isActive: $navigateToAdvancedSettingsAfterPin) {
                    EmptyView()
                }.hidden()
                
                
            }
            .padding()
            .navigationBarTitle("Settings")
        }
        .onChange(of: phoneNumber) { newValue in
            isValidPhoneNumber = CommonClass.validatePhoneNumber(newValue)
            showError = !isValidPhoneNumber && !newValue.isEmpty
            
            if !showError {
                UserDefaults.standard.set(phoneNumber, forKey: "savedPhoneNumber")
            }
        }
        .onAppear {
            
            FirebaseDatabaseHelper().fetchDataFromFirebase()
            
            if let savedPhoneNumber = UserDefaults.standard.string(forKey: "savedPhoneNumber") {
                phoneNumber = savedPhoneNumber
                
            }
            
            if let storedFrequencyIndex = UserDefaults.standard.object(forKey: frequencyIndexUserDefaultsKey) as? Int {
                frequency = storedFrequencyIndex
            } else {
                frequency = 1 // Set the default frequency index if nothing is stored
            }
            
            updateFrequency = frequencyArr[frequency]
        }
    
    }
    func setFrequency(frequencyIndex: Int) {
        guard frequencyIndex >= 0 && frequencyIndex < frequencyArr.count else {
            return
        }

        frequency = frequencyIndex
        UserDefaults.standard.set(frequency, forKey: frequencyIndexUserDefaultsKey)
        updateFrequency = frequencyArr[frequency]
        UserDefaults.standard.set(updateFrequency, forKey: updateFrequencyUserDefaultsKey)
    }
}

struct RadioButtonGroup: View {
    @Binding var selectedIndex: Int
    var options: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(0..<options.count) { index in
                Button(action: {
                    selectedIndex = index
                }) {
                    HStack {
                        Image(systemName: selectedIndex == index ? "largecircle.fill.circle" : "circle")
                        Text(options[index])
                    }
                    .foregroundColor(selectedIndex == index ? .blue : .white)
                    .padding(.vertical, 5)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
}

struct RadioButtonPreView: PreviewProvider {
    @State static var selectedIndex = 0
    
    static var previews: some View {
        RadioButtonGroup(selectedIndex: $selectedIndex, options: ["IoTHub", "Cloud Storage"])
    }
}

//struct SettingsView_Previews: PreviewProvider {
//    static var previews: some View {
//        SettingsView()
//    }
//}
