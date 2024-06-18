Progress
* The AppModel type encapsulates all interactions with the persisted state of a user's collection of entries. It is the core part of the app that is truly multi-platform in nature and by design has no defined UI. The API is intended to strike a balance between flexibility and stability, as each specific platform will use it to create the platform-specific experience/UI.
* Right now, the AppModel can:
	* create new entries
	* remove entries (and all references to them)
	* tie entries together with specific language-domain relationships (like translations or roots)
	* remove the relationships between entries
	* update the core aspects of a given model, such as a word's spelling or a note's content
* Soon, we want it to:
	* CRUD media resources that can be referenced and accessed from related models, but be external to the actual relational database
	* donate its content to Apple Intelligence systems
	* expose intents to the Apple system for Siri and Widget integration
	* incorporate a temporal algorithm for suggesting and notifying the user about when to review what content
	* provide a shareable set of models for communicating with other users via messaging or other first party system integrations
	* provide a platform-agnostic model for displaying visual and organizational features such as pronunciation or tags