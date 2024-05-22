
import AppIntents

struct AppIntentExtension: AppIntent {
    /// Every intent needs to include metadata, such as a localized title. The title of the intent is displayed throughout the system.
    static var title: LocalizedStringResource = "Add a word"
    
    
    /// An intent can optionally provide a localized description that the Shortcuts app displays.
    static var description = IntentDescription("Opens the app and adds a new entry.")
    
    
    /**
     When the system runs the intent, it calls `perform()`.
     
     Intents run on an arbitrary queue. Intents that manipulate UI need to annotate `perform()` with `@MainActor`
     so that the UI operations run on the main actor.
     */
    @MainActor
    func perform() async throws -> some IntentResult {
        
        /// Return an empty result, indicating that the intent is complete.
        return .result()
    }
}
