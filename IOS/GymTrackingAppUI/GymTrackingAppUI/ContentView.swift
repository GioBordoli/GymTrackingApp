//
//  ContentView.swift
//  GymTrackingAppUI
//
//  Created by Giorgio Bordoli on 1/25/25.
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    
    // Tracks whether we are currently recording
    @State private var isRecording = false
    
    // AVAudioRecorder to capture our audio
    @State private var recorder: AVAudioRecorder?
    
    // AVAudioPlayer to play back our audio
    @State private var audioPlayer: AVAudioPlayer?
    
    // Holds the URL where we save the recording
    @State private var audioFilename: URL?
    
    // For displaying status messages in the UI
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

            // Record/Stop button
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

            /*
            // Send to Server button (commented out for now)
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
    
    /// Starts an audio recording session and writes to "recording.m4a".
    func startRecording() {
        
        // Get the app’s Documents directory
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        // Create or use the "recordings" folder
        let recordingsFolder = documentsPath.appendingPathComponent("recordings")
        
        // Create the "recordings" directory if it doesn't exist
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
        
        // Determine the file path: Documents/recordings/recording.m4a
        audioFilename = recordingsFolder.appendingPathComponent("recording.m4a")
        
        // Configure our audio session for both playback and recording
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true)
        } catch {
            message = "Failed to configure audio session: \(error.localizedDescription)"
            return
        }
        
        // Make sure we have a valid URL to save to
        guard let audioFilename = audioFilename else {
            message = "Audio filename not set."
            return
        }
        
        // Define settings for the recording (AAC, 44100 Hz, etc.)
        let settings: [String : Any] = [
            AVFormatIDKey: kAudioFormatMPEG4AAC,
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 2,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        // Attempt to create and start the AVAudioRecorder
        do {
            recorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            recorder?.record()
            isRecording = true
            message = "Recording..."
        } catch {
            message = "Failed to start recording: \(error.localizedDescription)"
        }
    }
    
    /// Stops the recording, updates the UI, and immediately plays it back.
    func stopRecording() {
        // Stop the AVAudioRecorder
        recorder?.stop()
        isRecording = false
        
        // Update our message label
        message = "Audio recorded successfully."
        
        // Print the file path to the Xcode console
        if let path = audioFilename?.path {
            print("Audio file saved to: \(path)")
        }
        
        // As a quick test, let's immediately play back the recording:
        playRecording()
    }
    
    /// Attempts to play the recorded audio file once available.
    func playRecording() {
        // Ensure we have a valid file URL
        guard let fileURL = audioFilename else {
            print("No audio file URL available.")
            return
        }
        
        do {
            // Create the AVAudioPlayer using that file URL
            audioPlayer = try AVAudioPlayer(contentsOf: fileURL)
            
            // Prepare and play the audio
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            
            message = "Playing back recording..."
        } catch {
            message = "Failed to play audio: \(error.localizedDescription)"
        }
    }
    
    /*
    // We'll implement this later when hooking up to our backend
    func sendToServer() {
        message = "Audio saved to recordings folder!"
    }
    */
}
