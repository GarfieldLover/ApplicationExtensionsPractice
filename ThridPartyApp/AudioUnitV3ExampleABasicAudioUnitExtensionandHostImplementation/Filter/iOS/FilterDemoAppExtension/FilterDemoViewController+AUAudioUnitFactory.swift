/*
	Copyright (C) 2016 Apple Inc. All Rights Reserved.
	See LICENSE.txt for this sample’s licensing information
	
	Abstract:
	FilterDemoViewController is the app extension's principal class, responsible for creating both the audio unit and its view.
*/


/*Audio Unit Extension Point允许你的应用提供乐器、声音效果、声音发生器等等，它们可以在GarageBand、Logic这类AU宿主应用里使用。Extension Point还可以将完整的音频插件模式搬到iOS上并允许你在App Store里销售Audio Units插件。
*/

import CoreAudioKit
import FilterDemoFramework

extension FilterDemoViewController: AUAudioUnitFactory {
    /*
        This implements the required `NSExtensionRequestHandling` protocol method.
        Note that this may become unnecessary in the future, if `AUViewController`
        implements the override.
     */
    public override func beginRequestWithExtensionContext(context: NSExtensionContext) { }
    
    /*
        This implements the required `AUAudioUnitFactory` protocol method.
        When this view controller is instantiated in an extension process, it
        creates its audio unit.
     */
    public func createAudioUnitWithComponentDescription(componentDescription: AudioComponentDescription) throws -> AUAudioUnit {
        audioUnit = try AUv3FilterDemo(componentDescription: componentDescription, options: [])
        
        return audioUnit!
    }
}
