export const mockTranscribeAudio = async (audioFilePath) => {
    console.log("Mock processing audio:", audioFilePath);
  
    // Predefined mock words (your given words)
    const mockWords = [
      "تفاحة", "قمر"
    ];
  
    // Select a random word to simulate AI response
    const randomIndex = Math.floor(Math.random() * mockWords.length);
  
    return mockWords[randomIndex]; // Simulated transcribed word
  };
  