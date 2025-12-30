//
//  ContentView.swift
//  BetterRest
//
//  Created by Abdallah Kamash on 26/11/2025.
//

import CoreML
import SwiftUI

struct ContentView: View {
    @State private var wakeUp = defaultWaketime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    @State private var preferredBedtime = ""
    
    static var defaultWaketime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? .now
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                Form {
                    HStack {
                        Text("Wake up time:")
                            .font(.headline)
                        Spacer()
                        DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                            .onChange(of: wakeUp) { _,_ in
                                DispatchQueue.main.async {
                                    self.calculateBedtime()
                                }
                            }
                    }
                    
                    
                    HStack {
                        Text("Desired amount of sleep")
                            .font(.headline)
                        Spacer()
                        Stepper("\(sleepAmount.formatted()) hrs", value: $sleepAmount, in: 2...16, step: 0.25).fixedSize().onChange(of: sleepAmount) { _,_ in
                            DispatchQueue.main.async {
                                self.calculateBedtime()
                            }
                        }
                    }
                    
                    HStack {
                        Text("Daily coffee intake")
                            .font(.headline)
                        Spacer()
                        Stepper("^[\(coffeeAmount) cup](inflect: true)", value: $coffeeAmount, in: 0...10).fixedSize().onChange(of: coffeeAmount) { _,_ in
                            DispatchQueue.main.async {
                                self.calculateBedtime()
                            }
                        }
                    }
                    
                    Section {
                        HStack {
                            Spacer()
                            Text("Preferred Bedtime:").font(.title3.bold())
                            if (sleepAmount > 0) {
                                Text(preferredBedtime).font(.title3.weight(.black))
                            }
                            Spacer()
                        }
                    }
                    
                }
                .navigationTitle("BetterRest")
//                .toolbar {
//                    ToolbarItem(placement: .topBarTrailing) {
//                        Button {
//                            calculateBedtime()
//                        } label: {
//                            Text("Calculate")
//                        }
//                    }
//                }
                .alert(alertTitle, isPresented: $showingAlert) {
                    
                } message: {
                    Text(alertMessage)
                }
            }.onAppear() {
                DispatchQueue.main.async {
                    self.calculateBedtime()
                }
            }
        }
    }
    
    func calculateBedtime() {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            
            let sleepTime = wakeUp - prediction.actualSleep
            
            alertTitle = "Your ideal bedtime is..."
            alertMessage = sleepTime.formatted(date: .omitted, time: .shortened)
            preferredBedtime = alertMessage
            
        } catch {
            alertTitle = "Error"
            alertMessage = "Failed to calculate bedtime."
        }
        
        //showingAlert = true
    }
}

#Preview {
    ContentView()
}
