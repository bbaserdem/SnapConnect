# Phase 3: Advanced AI Enhancements

**Goal**: To build upon the core AI features by introducing more sophisticated, context-aware functionalities that further personalize the user experience and encourage community interaction.

---

## Key Tasks & Features

### 1. Context-Aware Friend Recommendations
- **Description**: Provide users with personalized friend suggestions based on shared interests, improving community building and content discovery.
- **Tech Stack**: `Firebase Functions (Scheduled)`, `Firestore`.
- **Steps**:
    1.  Design and add a "Suggested Friends" component to the "Add Friends" screen, displayed when the search bar is empty.
    2.  Develop a scheduled Firebase Function to run periodically (e.g., daily) to pre-compute recommendations.
    3.  The function will iterate through users, analyze their declared interest tags, and find other users with significant overlap who are not already friends.
    4.  Store these recommendations in a dedicated `recommendations` subcollection on each user's document in Firestore.
    5.  The "Suggested Friends" component will read directly from this pre-computed list, ensuring a fast and responsive user experience.

### 2. AI-Generated Content Ideas
- **Description**: Help users overcome "creator's block" by providing personalized prompts and ideas for their next Snap or Story, tailored to their specific interests within the body mod community.
- **Tech Stack**: `Firebase Functions`, `Vertex AI (Gemini)`, `Firestore`.
- **Steps**:
    1.  Add a UI element (e.g., a `Card` or `IconButton`) on the Camera screen to access "AI Ideas."
    2.  Create an HTTP-callable Firebase Function that takes the user's ID as input.
    3.  The function will fetch the user's interest tags from Firestore.
    4.  It will then use Vertex AI to generate a list of personalized, creative prompts. Examples: "Show off your most recent tattoo and the story behind it," or "Do a 10-second video of your new piercing using the 'Sparkle' filter."
    5.  Display these prompts in a `Dialog` or a dismissible `Card` overlay, inspiring the user to create new content. 