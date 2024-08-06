//
//  DropDownMenuView.swift
//  QP HT Applicationn
//
//  Created by Apps we love on 22/03/24.
//

import SwiftUI

struct DropdownButton: View {
    @Binding var selectedOption: DropdownOption?
    @Binding var shouldShowDropdown: Bool
    
    var placeholder: String
    var options: [DropdownOption]
    
    var body: some View {
        Button(action: {
            self.shouldShowDropdown.toggle()
        }) {
            HStack {
                Text(selectedOption?.value ?? placeholder)
                    .foregroundColor(selectedOption == nil ? .gray : .white)
                    .padding(.leading, 5.0)
                Spacer(minLength: 1)
                Image(systemName: "chevron.down.circle")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundColor(.blue)
            }
            .padding()
            .frame(width: 170,height: 30 )
        }
        .background(Color.black)
        .cornerRadius(2)
        .padding(.horizontal)
        .overlay(
            DropdownOverlay(options: options, selectedOption: $selectedOption, shouldShowDropdown: $shouldShowDropdown)
                .frame(maxHeight: shouldShowDropdown ? .infinity : 0)
                .opacity(shouldShowDropdown ? 1 : 0)
        )
    }
}




struct DropdownOption: Hashable {
    let key: String
    let value: String

    public static func == (lhs: DropdownOption, rhs: DropdownOption) -> Bool {
        return lhs.key == rhs.key && lhs.value == rhs.value
    }
}

struct DropdownOverlay: View {
    var options: [DropdownOption]
    @Binding var selectedOption: DropdownOption?
    @Binding var shouldShowDropdown: Bool
    
    var body: some View {
        ScrollView{
            ZStack {
                Color.black.opacity(0.5)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        self.shouldShowDropdown.toggle()
                    }
                
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(options, id: \.self) { option in
                        DropdownRow(option: option, isSelected: option == selectedOption) {
                            self.selectedOption = option
                            self.shouldShowDropdown = false
                        }
                    }
                }
                .frame(width: 150, alignment: .center)
                .background(Color.white)
                .cornerRadius(5)
                .padding()
            }
            
        }
    }
}

struct DropdownRow: View {
    var option: DropdownOption
    var isSelected: Bool
    var onSelect: () -> Void

    var body: some View {
        Button(action: {
            self.onSelect()
        }) {
            HStack {
                Text(option.value)
                    .foregroundColor(isSelected ? .white : .black)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 10)
                    .background(isSelected ? Color.blue : Color.white)
                    .cornerRadius(5)
                    .font(.system(size: 16))
                    .frame(height: 50, alignment: .center)
            }
            .frame(width: 130,height: 50, alignment: .center)
        }
        .buttonStyle(PlainButtonStyle()) // Use PlainButtonStyle for better interaction
    }
}




