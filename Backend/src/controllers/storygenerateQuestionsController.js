import axios from 'axios';

const apiKeys = [
  process.env.api_story_1,
  process.env.api_story_2,
  process.env.api_story_3,
  process.env.api_story_4,
  process.env.api_story_5
];

let currentKeyIndex = 0;
const apiUrl = 'https://openrouter.ai/api/v1/chat/completions';

const isApiKeyError = (status, responseBody) => {
  const msg = responseBody.toLowerCase();
  return [401, 403].includes(status) ||
    msg.includes('unauthorized') ||
    msg.includes('invalid') ||
    msg.includes('expired') ||
    msg.includes('quota') ||
    msg.includes('limit exceeded');
};

async function generateQuestionsFromStory(story) {
  const prompt = `
اقرأ القصة التالية المكتوبة باللغة العربية، ثم أنشئ 10 أسئلة اختيار من متعدد باللغة العربية أيضًا. يجب أن تكون الأسئلة متنوعة وغير متكررة وتغطي جوانب مختلفة من القصة. يجب أن يكون لكل سؤال 4 اختيارات، وحدد الخيار الصحيح باستخدام الحقل "correctIndex" (مثلاً 0 أو 1 أو 2 أو 3).

تأكد من أن الأسئلة تغطي:
- الأحداث الرئيسية في القصة
- الشخصيات المذكورة
- المكان والزمان
- الدروس المستفادة
- التفاصيل المهمة
- الأسباب والنتائج
- المشاعر والأفكار
- القيم والأخلاق المطروحة

القصة:
${story}

رجاءً أعد النتيجة بصيغة JSON فقط، وبدون أي شرح أو نص إضافي، مثل الشكل التالي:
[
  {
    "question": "ما هو موضوع القصة الرئيسي؟",
    "choices": ["الأمان", "الصداقة", "النظافة", "الرياضة"],
    "correctIndex": 0
  }
]
  `;

  const body = {
    model: 'meta-llama/llama-3-70b-instruct',
    messages: [{ role: 'user', content: prompt }],
    temperature: 0.3,
  };

  for (let i = 0; i < apiKeys.length; i++) {
    try {
      const res = await axios.post(apiUrl, body, {
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${apiKeys[currentKeyIndex]}`
        }
      });

      const content = res.data.choices[0].message.content;

      const jsonMatch = content.match(/\[\s*{[\s\S]*?}\s*]/);
      if (!jsonMatch) {
        throw new Error('لم يتم العثور على بيانات JSON صالحة في الرد.');
      }

      const questions = JSON.parse(jsonMatch[0]);
      return questions;

    } catch (err) {
      const status = err.response?.status || 0;
      const bodyText = err.response?.data ? JSON.stringify(err.response.data) : '';
      const isKeyError = isApiKeyError(status, bodyText);

      if (isKeyError && currentKeyIndex < apiKeys.length - 1) {
        currentKeyIndex++;
        continue;
      }

      throw new Error(`فشل توليد الأسئلة: ${err.message}`);
    }
  }

  throw new Error('فشل في توليد الأسئلة: تم تجربة جميع مفاتيح API.');
}

export default { generateQuestionsFromStory };
