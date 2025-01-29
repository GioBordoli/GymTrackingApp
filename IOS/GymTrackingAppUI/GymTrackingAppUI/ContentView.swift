//
//  ContentView.swift
//  GymTrackingAppUI
//
//  Created by Giorgio Bordoli on 1/25/25.
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    @State private var isRecording = false
    @State private var recorder: AVAudioRecorder?
    @State private var audioFilename: URL?
    @State private var message = ""
    
    var body: some View {
        VStack {
            // Title
            Text("GymTrackApp")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()

            // Placeholder for keyboard (text field for mockup)
            TextField("Enter something...", text: .constant(""))
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            // Record button
            Button(action: {
                if isRecording {
                    stopRecording()
                } else {
                    startRecording()
                }
            }) {
                Text(isRecording ? "Stop Recording" : "Start Recording")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(isRecording ? Color.red : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()

            // Send to Server button (commented out for now)
/*
            Button(action: sendToServer) {
                Text("Send to Server")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
*/

            // Message Display
            Text(message)
                .foregroundColor(.gray)
                .padding()
        }
        .padding()
    }
    
    func startRecording() {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let recordingsFolder = documentsPath.appendingPathComponent("recordings")
        
        // Create the recordings folder if needed
        if !FileManager.default.fileExists(atPath: recordingsFolder.path) {
            do {
                try FileManager.default.createDirectory(at: recordingsFolder,
                                                        withIntermediateDirectories: true,
                                                        attributes: nil)
            } catch {
                message = "Failed to create recordings folder: \(error.localizedDescription)"
                return
            }
        }
        
        // Audio file path
        audioFilename = recordingsFolder.appendingPathComponent("recording.m4a")
        
        // Configure AVAudioSession
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true)
        } catch {
            message = "Failed to configure audio session: \(error.localizedDescription)"
            return
        }
        
        // Start recording
        guard let audioFilename = audioFilename else {
            message = "Audio filename not set."
            return
        }
        let settings = [
            AVFormatIDKey: kAudioFormatMPEG4AAC,
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 2,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ] as [String : Any]
        
        do {
            recorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            recorder?.record()
            isRecording = true
            message = "Recording..."
        } catch {
            message = "Failed to start recording: \(error.localizedDescription)"
        }
    }
    
    func stopRecording() {
        recorder?.stop()
        isRecording = false
        message = "Audio recorded successfully"
        
        // Print the file path to confirm it's saved
        if let path = audioFilename?.path {
            print("Audio file saved to: \(path)")
        }
    }
    
    // Commented out for now
    /*
    func sendToServer() {
        // We'll handle this later once we're sure recording works
    }
    */
}
