//
//  PinProtectionView.swift
//  QP HT Applicationn
//
//  Created by Apps we love on 13/03/24.
//

import SwiftUI

struct PinProtectionView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var isPinCorrect: Bool
    @State private var pinInput = ""
    @State private var showError = false
    let correctPinForSettingScreen = "4756"
    let correctPinForAdvanceSettingScreen = "6879"
    
    var body: some View {
        VStack {
            SecureField("Enter PIN", text: $pinInput)
            
            if showError{
                Text("Enter valid PIN")
                    .foregroundColor(.red)
                    .font(.system(size: 12))
            }
            
            Button("Verify") {
                if isSettingsScreen{
                    if pinInput == correctPinForSettingScreen{
                        isPinCorrect = true
                        isSettingsScreen = false
                        presentationMode.wrappedValue.dismiss()
                    }else{
                        isPinCorrect = false
                        showError = true
                    }
                }else if isAdvanceSettingScreen{
                    if pinInput == correctPinForAdvanceSettingScreen{
                        isPinCorrect = true
                        isAdvanceSettingScreen = false
                        presentationMode.wrappedValue.dismiss()
                    }else{
                        isPinCorrect = false
                        showError = true
                    }
                }
            }
            .disabled(pinInput.count != 4)
        }
    }
}

