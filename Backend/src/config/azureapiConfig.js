import axios from 'axios';
import FormData from 'form-data';
import fs from 'fs';

export const azureTranscribeAudio = async (filePath) => {
  try {
    const formData = new FormData();
    formData.append('file', fs.createReadStream(filePath));  // <--- Correct way

    const response = await axios.post(
      'http://fiestconainer.acezb3fsf4djaacc.uaenorth.azurecontainer.io:8000/transcribe/',
      formData,
      { headers: formData.getHeaders() }
    );

    console.log('Azure Response:', response.data);
    return response.data.transcription;
  } catch (error) {
    console.error('Azure Transcription Error:', error.response?.data || error.message);
    throw new Error('Speech-to-text processing failed.');
  }
};
