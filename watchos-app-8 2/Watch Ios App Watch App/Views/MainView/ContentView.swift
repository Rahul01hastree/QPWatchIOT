import SwiftUI

struct ContentView: View {

    @State private var showNumberMissingAlert = false
    @State private var showHoldForLongPressAlert = false
    @State private var showPinEnterForSettings = false
    @State private var navigateToSettingsAfterPin = false
    @State private var rotationDegreesForSettingsIcon = 0.0
    let phoneNumberKey = "savedPhoneNumber"
    @StateObject private var locationManager = LocationManager()

    var body: some View {
        NavigationView {
            VStack {
                VStack {

                    Image(systemName: "gearshape.fill")
                        .resizable()
                        .tint(.black)
                        .frame(width: 25, height: 25)
                        .foregroundColor(.white)
                        .background(Color.clear)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(Color.clear, lineWidth: 0)
                                .background(Circle().fill(Color.clear))
                        )
                        .onTapGesture {
                            
                            self.showPinEnterForSettings = true
                            isSettingsScreen = true
                            withAnimation(.easeInOut(duration: 0.5)) {
                                self.rotationDegreesForSettingsIcon += 360
                            }
                        }
                        .sheet(isPresented: $showPinEnterForSettings) {
                            PinProtectionView(isPinCorrect: $navigateToSettingsAfterPin)
                        }
                    
                    NavigationLink(destination: SettingsView(), isActive: $navigateToSettingsAfterPin) {
                        EmptyView()
                    }.hidden()
                                    
                }
                .padding(.leading, 135.0)

                Spacer()

                HStack {
                    Spacer()

                    Image(systemName: "phone")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30, height: 30)
                        .foregroundColor(.white)
                        .padding(EdgeInsets(top: 15, leading: 15, bottom: 15, trailing: 15))
                        .background(Color.green)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(Color.black, lineWidth: 2)
                        )
                        .simultaneousGesture(
                            LongPressGesture(minimumDuration: 1.0)
                                .onEnded { _ in
                                    generateHapticFeedback()
                                    didTapCallBtn()
                                }
                        )
                        .simultaneousGesture(
                            TapGesture()
                                .onEnded { _ in
                                    showHoldForLongPress()
                                }
                        )

                    Spacer()

                    Image(systemName: "exclamationmark.triangle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30, height: 30)
                        .foregroundColor(.white)
                        .padding(EdgeInsets(top: 15, leading: 15, bottom: 15, trailing: 15))
                        .background(Color.red)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(Color.black, lineWidth: 2)
                        )
                        .simultaneousGesture(
                            LongPressGesture(minimumDuration: 1.0)
                                .onEnded { _ in
                                    generateHapticFeedback()
                                    didTapSOSBtn()
                                }
                        )
                        .simultaneousGesture(
                            TapGesture()
                                .onEnded { _ in
                                    showHoldForLongPress()
                                }
                        )

                    Spacer()
                }
            }
            .onAppear {
              //  locationManager.updateLocationManagerWithFrequency()
            }
            .navigationBarBackButtonHidden(false)
            .navigationBarTitleDisplayMode(.inline)
            .alert(isPresented: $showHoldForLongPressAlert) {
                Alert(
                    title: Text("Alert"),
                    message: Text("Hold for a long press."),
                    dismissButton: .default(Text("OK")){
                        showHoldForLongPressAlert = false
                    }
                )
                
            }
            .alert(isPresented: $showNumberMissingAlert) {
                Alert(
                    title: Text(phoneNumberMissingTitle)
                        .font(.system(size: 10)),
                    message: Text(phoneNumberMissingMessage)
                        .font(.system(size: 8)),
                    dismissButton: .default(Text("OK")){
                        showNumberMissingAlert = false
                    }
                )
            }
            
        }
    }

    func didTapSOSBtn() {
        print("didTapSOSBtn")
        let location = locationManager.userLocation
        if let currentLocation = location {
            if let savedPhoneNumber = UserDefaults.standard.string(forKey: phoneNumberKey), !savedPhoneNumber.isEmpty {
                 CommonClass.sendSMS(to: savedPhoneNumber, location: currentLocation)
                print("Send SOS SMS to \(savedPhoneNumber) with location \(currentLocation)")
            } else {
                showNumberMissingAlert = true
            }
        //    print(currentLocation.coordinate.longitude)
          //  print(currentLocation.coordinate.latitude)
        }
    }

    func didTapCallBtn() {
        print("didTapCallBtn")
        if let instructorNumber = UserDefaults.standard.string(forKey: phoneNumberKey) {
            if instructorNumber.isEmpty {
                showNumberMissingAlert = true
            } else {
                if let phoneURL = URL(string: "tel://\(instructorNumber)") {
                    WKExtension.shared().openSystemURL(phoneURL)
               }
            }
        } else {
            showNumberMissingAlert = true
        }
    }

    func showHoldForLongPress() {
        showHoldForLongPressAlert = true
    }
    
    func generateHapticFeedback() {
        WKInterfaceDevice.current().play(.success)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
