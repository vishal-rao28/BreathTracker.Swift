//
//  CopdApp.swift
//  Copd
//
//  Created by SAIL on 17/09/25.
//

import SwiftUI

@main
struct CopdApp: App {
    // Provide a shared session for the app
    @StateObject private var session = PatientSession()
    @StateObject private var notificationManager = LocalNotificationManager.shared

    var body: some Scene {
        WindowGroup {
            ZStack {
                Group {
                    if session.current != nil {
                        PatientMainTabView()
                    } else if session.hasSeenIntro {
                        NavigationStack {
                            AboutScreen2()
                        }
                    } else {
                        NavigationStack {
                            AboutScreen1()
                        }
                    }
                }
                .environmentObject(session)
                
                // IN-APP POPUP OVERLAY
                if let reminder = notificationManager.activeInhalerReminder {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .transition(.opacity)
                        .onTapGesture {
                            // Don't dismiss on background tap to force action
                        }
                    
                    VStack(spacing: Spacing.md) {
                        ZStack {
                            Circle()
                                .fill(Color.btPrimary.opacity(0.15))
                                .frame(width: 80, height: 80)
                            Image(systemName: "lungs.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.btPrimary)
                        }
                        .padding(.top, Spacing.md)
                        
                        Text(reminder.title)
                            .font(.btTitle)
                            .foregroundColor(.btTextPrimary)
                            .multilineTextAlignment(.center)
                        
                        Text(reminder.body)
                            .font(.btBodyMedium)
                            .foregroundColor(.btTextSecond)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, Spacing.sm)
                        
                        Divider().background(Color.btBorder)
                            .padding(.vertical, Spacing.sm)
                        
                        VStack(spacing: Spacing.sm) {
                            Button {
                                // "Taken" Action
                                let dateString = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .none)
                                UserDefaults.standard.set(true, forKey: "inhaler_taken_\(reminder.patientId)_\(dateString)")
                                UserDefaults.standard.synchronize()
                                
                                // NEW: Save to Server database
                                InhalerAPI.markAsTaken(patientId: reminder.patientId)
                                
                                withAnimation(.spring()) {
                                    notificationManager.activeInhalerReminder = nil
                                }
                            } label: {
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                    Text("Taken")
                                }
                                .font(.btHeadline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color.btAccentGreen)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                            }
                            
                            Button {
                                // "Remind Me Later" Action
                                notificationManager.scheduleSnoozeAlarm(patientId: reminder.patientId)
                                
                                withAnimation(.spring()) {
                                    notificationManager.activeInhalerReminder = nil
                                }
                            } label: {
                                HStack {
                                    Image(systemName: "clock.arrow.2.circlepath")
                                    Text("Remind Me Later")
                                }
                                .font(.btLabel)
                                .foregroundColor(.btPrimary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color.btPrimary.opacity(0.12))
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                            }
                        }
                        .padding(.bottom, Spacing.sm)
                    }
                    .padding(Spacing.lg)
                    .background(Color.btSurface)
                    .clipShape(RoundedRectangle(cornerRadius: 28))
                    .shadow(color: Color.black.opacity(0.15), radius: 20, y: 10)
                    .padding(.horizontal, Spacing.xl)
                    .transition(.scale.combined(with: .opacity))
                    .zIndex(100) // Ensure it's on top
                }
            }
            .animation(.spring(response: 0.5, dampingFraction: 0.8), value: notificationManager.activeInhalerReminder != nil)
        }
    }
}
