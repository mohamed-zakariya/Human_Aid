import axios from 'axios';

const apiKeys = [
  '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',
  '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',
  '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',
  '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',
  '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'
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
