# SwiftUI Analysis App

This SwiftUI application provides functionalities to analyze audio and images. Users can log in with their email and choose between audio and image analysis. The app uses SwiftUI and integrates with a backend server to perform authentication and analysis tasks.

## Features

- **Email Authentication**: Secure login with email.
- **Audio Analysis**: Record, upload, and analyze audio files.
- **Image Analysis**: Select or capture an image, upload, and receive analysis.

## Screenshots

![Audio Analysis](screenshots/audio_analysis.png)
![Image Analysis](screenshots/image_analysis.png)

## Requirements

- iOS 14.0+
- Xcode 12.0+
- Swift 5.3+

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/SwiftUIAnalysisApp.git

1. Open the project in Xcode:
  ```bash
  cd SwiftUIAnalysisApp
  open SwiftUIAnalysisApp.xcodeproj
  ```

3. Build and run the project on a simulator or a physical device.


## Usage

1. Login: Enter your email to authenticate.

1. Choose Analysis: Select either audio or image analysis.
  - Audio: Start recording, stop when finished, and upload for analysis.
  - Image: Capture a new photo or select one from the library, then upload it for analysis.


## Configuration

Update the server URL in the ContentView.swift file to point to your backend server:
```swift
let serverURL = URL(string: "http://<your-server-ip>:3000/authenticate")!
```

## License
[MIT - 2024](https://github.com/carloshpdoc/get-describer-ads-iOS?tab=MIT-1-ov-file) / [Carlos hperc](https://carloshperc.com)

## Contributing

Contributions are welcome! Please fork the repository and submit a pull request for any improvements.

## Contact

For any questions or issues, please contact contato@carloshperc.com.

   
