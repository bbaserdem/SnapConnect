# Phase 2: AI Enhancement

**Goal**: To elevate the Snapchat clone from a simple social app to an AI-first experience by integrating intelligent, personalized features that enhance content creation and community interaction, focusing on the body mod enthusiast niche.

---

## Key Tasks & Features

### 1. Backend AI Infrastructure Setup
- **Description**: Configure the backend infrastructure using Firebase Functions and Google's Vertex AI to power all AI features. This foundational step is critical for a scalable and secure AI implementation.
- **Tech Stack**: `Firebase Functions (TypeScript)`, `@google-cloud/vertexai`, `Firebase Emulator Suite`.
- **Steps**:
    1.  Initialize Firebase Functions with a TypeScript codebase.
    2.  Set up the Firebase Emulator Suite for local development and testing of AI-related functions.
    3.  Configure a Google Cloud project, enable the Vertex AI API, and set up necessary IAM permissions for the Firebase Functions service account.
    4.  Create a shared library within the Functions codebase for a reusable Vertex AI client, centralizing model interaction logic.
    5.  Specify function regions to minimize latency and configure memory/timeouts appropriately for AI workloads.

### 2. AI-Powered Caption & Tag Suggestions (RAG)
- **Description**: Implement an intelligent feature that suggests contextual captions and tags for a user's Snap. This will be the project's first implementation of Retrieval-Augmented Generation (RAG), using the user's interests to guide the AI's creative output.
- **Tech Stack**: `Firebase Functions`, `Vertex AI (Gemini)`, `Firestore`.
- **Steps**:
    1.  On the Snap edit screen, add an `IconButton` (e.g., a lightbulb icon) to trigger the AI suggestions.
    2.  Create an HTTP-callable Firebase Function that receives the user's ID and a reference to the Snap image in Firebase Storage.
    3.  In the function:
        a.  Fetch the user's interest tags from their profile in Firestore (the "retrieval" step).
        b.  Analyze the Snap's image content using a multimodal model in Vertex AI (e.g., Gemini Pro Vision).
        c.  Construct a detailed prompt for the AI that includes the image analysis and the retrieved user interests (the "augmentation" step).
        d.  Generate 3-5 relevant captions and a list of hashtags (the "generation" step).
    4.  The function returns the generated content to the Flutter app.
    5.  Display the suggestions in a `Dialog`, allowing the user to easily select and apply them.

### 3. Context-Aware Friend Recommendations
- **Description**: Provide users with personalized friend suggestions based on shared interests, improving community building and content discovery.
- **Tech Stack**: `Firebase Functions (Scheduled)`, `Firestore`.
- **Steps**:
    1.  Design and add a "Suggested Friends" component to the "Add Friends" screen, displayed when the search bar is empty.
    2.  Develop a scheduled Firebase Function to run periodically (e.g., daily) to pre-compute recommendations.
    3.  The function will iterate through users, analyze their declared interest tags, and find other users with significant overlap who are not already friends.
    4.  Store these recommendations in a dedicated `recommendations` subcollection on each user's document in Firestore.
    5.  The "Suggested Friends" component will read directly from this pre-computed list, ensuring a fast and responsive user experience.

### 4. AI-Generated Content Ideas
- **Description**: Help users overcome "creator's block" by providing personalized prompts and ideas for their next Snap or Story, tailored to their specific interests within the body mod community.
- **Tech Stack**: `Firebase Functions`, `Vertex AI (Gemini)`, `Firestore`.
- **Steps**:
    1.  Add a UI element (e.g., a `Card` or `IconButton`) on the Camera screen to access "AI Ideas."
    2.  Create an HTTP-callable Firebase Function that takes the user's ID as input.
    3.  The function will fetch the user's interest tags from Firestore.
    4.  It will then use Vertex AI to generate a list of personalized, creative prompts. Examples: "Show off your most recent tattoo and the story behind it," or "Do a 10-second video of your new piercing using the 'Sparkle' filter."
    5.  Display these prompts in a `Dialog` or a dismissible `Card` overlay, inspiring the user to create new content. 