
# On-device customizable lipreader on iOS

This is a iOS lipreading app that uses the front camera of iPhone to recognize unvoiced speech (silent speech). You can access to various functionalities such as opening apps, getting directions, playing music, and so on by using silent speech.

To get started, download Core ML format lipreading encoder model from [here](https://drive.google.com/file/d/1RK7no1QH8QFZzjVrmg64X8wuCLRfJzu3/view?usp=share_link) and put it under the Xcode project you want to build (iOS or iPadOS).

```
mv ./weight.bin LipLearner_iOS/LipEncoder.mlpackage/Data/com.apple.CoreML/weights/
```

![UI design](src/UIdesign.png)
*User experience and interface design. (A) The interface of the initialization phase. The user first needs to record keyword and non-speaking samples to enable KWS activation. (B) The user says a command aloud for command registration. The voice signal will be leveraged to label the silent speech, allowing fast command registration (Voice2Lip). (C) The interface for querying the right label in the active learning mode. Users can slide through the existing commands sorted by similarity to select and add a new sample to the model. Users can update the model at any time by using the button at the upper-right corner, which usually takes around 2 seconds on iPhone. (D) An example showing the command "play some music" is recognized correctly and executed successfully by the pre-set shortcut. (E) The interface for correcting the predictions in on-demand learning mode. The user can review recent utterances displayed as a GIF animation*


Please note that our testing has shown that the app works best on iPhone 11 or newer models. If you experience overheating or frequent crashes, we recommend turning off the camera view from the settings menu as video rendering can be taxing on the CPU. For older iPhone models, the inference may take longer time than the slide window length of our visual KWS function. In such cases, it's best to turn off the KWS function and use the recording button (long-press) to start recognition.

To avoid overheating, we added a silent speech activity detection (SSAD) function that works like the voice activity detection (VAD) function in speech recognition systems. It detects the keyword only when the user’s mouth is open. Note that this trick was not used in the user study in our paper.

In the free use mode, you can use your silent speech command to activate different functions. You need to create your own shortcuts, such as “play some music”, and register a silent speech command that matches the shortcut’s name exactly.



# License

The MIT License
